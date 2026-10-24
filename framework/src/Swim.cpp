#include "Swim.h"

#include "Session.h"

namespace SLSFW::Swim
{
	namespace
	{
		bool          g_active{ false };  // Frostfall absent
		std::optional<bool> g_swimming;   // last state sent, empty = send the next one
		std::uint32_t g_sent{ 0 };

		void Send(bool a_start)
		{
			SKSE::ModCallbackEvent event{ a_start ? "Frostfall_OnPlayerStartSwimming" : "Frostfall_OnPlayerStopSwimming", "", 0.0f, nullptr };
			if (auto* source = SKSE::GetModCallbackEventSource()) {
				source->SendEvent(&event);
				++g_sent;
			}
		}
	}

	namespace
	{
		// Havok metres -> Skyrim units, as Underwater NG converts its drift (kHavokWorldScale)
		constexpr float kHavokWorldScale = 0.0142875f;
		constexpr float kMaxDelta = 0.10f;

		struct Settings
		{
			bool  enabled{ true };
			float sinkSpeed{ 0.9f };    // m/s downward while bound
			float strokeMult{ 0.35f };  // forward / sideways swimming
			float ascentMult{ 0.0f };   // swimming upward
		} g_settings;

		// what keeps the arms out of use (absent plugins leave them null)
		struct Restraints
		{
			RE::BGSKeyword* heavyBondage{ nullptr };  // DD armbinder, yoke, elbowbinder, box binder, straitjacket
			RE::BGSKeyword* petSuit{ nullptr };       // DD pet suit
			RE::BGSKeyword* zazWrists{ nullptr };     // ZaZ wrist ties and cuffs that bind
			RE::TESFaction* ampArmLeft{ nullptr };    // Amputator.esm _AMP_AmputeeArmLeftFact (rank >= 0: hand gone)
			RE::TESFaction* ampArmRight{ nullptr };
		} g_restraints;

		std::atomic_bool g_bound{ false };  // written on the main thread (Tick), read by the movement hook
		bool             g_hooked{ false };
		bool             g_sinkOrSwim{ false };
		bool             g_underwaterNG{ false };
		std::uint32_t    g_boundDives{ 0 };
		bool             g_wasSinking{ false };

		float IniFloat(const wchar_t* a_key, float a_default, const std::filesystem::path& a_ini)
		{
			wchar_t buffer[32]{};
			GetPrivateProfileStringW(L"Swim", a_key, L"", buffer, 32, a_ini.c_str());
			if (!buffer[0]) {
				return a_default;
			}
			try {
				return std::stof(buffer);
			} catch (...) {
				return a_default;
			}
		}

		bool ArmsBound(RE::Actor* a_actor)
		{
			if (g_restraints.ampArmLeft && g_restraints.ampArmRight) {
				int left = -1;
				int right = -1;
				// the faction list directly: the virtual GetFactionRank has answered wrongly in this build
				a_actor->VisitFactions([&](RE::TESFaction* a_faction, std::int8_t a_rank) {
					if (a_faction == g_restraints.ampArmLeft) {
						left = a_rank;
					} else if (a_faction == g_restraints.ampArmRight) {
						right = a_rank;
					}
					return false;
				});
				if (left >= 0 && right >= 0) {
					return true;
				}
			}
			auto* changes = a_actor->GetInventoryChanges();
			if (!changes || !changes->entryList) {
				return false;
			}
			for (const auto* entry : *changes->entryList) {
				if (!entry || !entry->object || !entry->object->IsArmor() || !entry->IsWorn()) {
					continue;
				}
				const auto* armor = entry->object->As<RE::TESObjectARMO>();
				for (const auto* keyword : { g_restraints.heavyBondage, g_restraints.petSuit, g_restraints.zazWrists }) {
					if (keyword && armor->HasKeyword(keyword)) {
						return true;
					}
				}
			}
			return false;
		}

		struct ModifyMovementDataHook
		{
			static void thunk(RE::PlayerCharacter* a_player, float a_delta, RE::NiPoint3& a_movement, RE::NiPoint3& a_rotation)
			{
				func(a_player, a_delta, a_movement, a_rotation);
				if (!g_bound.load(std::memory_order_relaxed)) {
					return;
				}
				const auto* state = a_player ? a_player->AsActorState() : nullptr;
				if (!state || !state->IsSwimming() || state->GetLifeState() == RE::ACTOR_LIFE_STATE::kDead) {  // not the virtual IsDead (lies here)
					return;
				}
				auto movement = a_movement;
				movement.x *= g_settings.strokeMult;
				movement.y *= g_settings.strokeMult;
				if (movement.z > 0.0f) {
					movement.z *= g_settings.ascentMult;
				}
				const float delta = std::clamp(a_delta, 0.0f, kMaxDelta);
				movement.z -= g_settings.sinkSpeed * delta / kHavokWorldScale;
				if (std::isfinite(movement.x) && std::isfinite(movement.y) && std::isfinite(movement.z)) {
					a_movement = movement;  // all or nothing: a bad value keeps the engine's own vector
				}
			}

			static inline REL::Relocation<decltype(thunk)> func;
			static constexpr std::size_t idx{ 0x11A };
		};

		void LoadSink()
		{
			const auto ini = std::filesystem::current_path() / L"Data" / L"SKSE" / L"Plugins" / L"SLSurvivalFramework.ini";
			g_settings.enabled = GetPrivateProfileIntW(L"Swim", L"bSinkWhenBound", 1, ini.c_str()) == 1;
			g_settings.sinkSpeed = std::clamp(IniFloat(L"fBoundSinkSpeed", 0.9f, ini), 0.0f, 8.0f);
			g_settings.strokeMult = std::clamp(IniFloat(L"fBoundStrokeMult", 0.35f, ini), 0.0f, 1.0f);
			g_settings.ascentMult = std::clamp(IniFloat(L"fBoundAscentMult", 0.0f, ini), 0.0f, 1.0f);

			auto* data = RE::TESDataHandler::GetSingleton();
			g_sinkOrSwim = data->LookupModByName("SinkOrSwim.esp") != nullptr;
			g_underwaterNG = GetModuleHandleW(L"UnderwaterNG.dll") != nullptr;
			if (!g_settings.enabled || g_sinkOrSwim) {
				logger::info("bondage sink: off ({})", g_sinkOrSwim ? "Sink Or Swim owns swimming movement" : "bSinkWhenBound=0");
				return;
			}
			g_restraints.heavyBondage = RE::TESForm::LookupByEditorID<RE::BGSKeyword>("zad_DeviousHeavyBondage");
			g_restraints.petSuit = RE::TESForm::LookupByEditorID<RE::BGSKeyword>("zad_DeviousPetSuit");
			g_restraints.zazWrists = RE::TESForm::LookupByEditorID<RE::BGSKeyword>("zbfEffectWrist");
			g_restraints.ampArmLeft = data->LookupForm<RE::TESFaction>(0x00BF77, "Amputator.esm");
			g_restraints.ampArmRight = data->LookupForm<RE::TESFaction>(0x00BF79, "Amputator.esm");

			REL::Relocation<std::uintptr_t> vtbl{ RE::VTABLE_PlayerCharacter[0] };
			ModifyMovementDataHook::func = vtbl.write_vfunc(ModifyMovementDataHook::idx, ModifyMovementDataHook::thunk);
			g_hooked = true;
			logger::info("bondage sink: on (sink {:.2f} m/s, strokes x{:.2f}, ascent x{:.2f}; DD {}, ZaZ {}, Amputator {}; Underwater NG {})",
				g_settings.sinkSpeed, g_settings.strokeMult, g_settings.ascentMult, g_restraints.heavyBondage != nullptr,
				g_restraints.zazWrists != nullptr, g_restraints.ampArmLeft != nullptr,
				g_underwaterNG ? "present - its armor buoyancy adds to this" : "absent");
		}
	}

	void Load()
	{
		g_active = !RE::TESDataHandler::GetSingleton()->LookupModByName("Frostfall.esp");
		logger::info("swim events: {}", g_active ? "sent by the framework" : "off (Frostfall sends them)");
		LoadSink();
	}

	void Reset()
	{
		g_swimming.reset();
		g_bound = false;
		g_wasSinking = false;
	}

	void Tick(float)
	{
		if (!Session::Settled()) {
			return;
		}
		auto* player = RE::PlayerCharacter::GetSingleton();
		const auto* state = player ? player->AsActorState() : nullptr;
		if (!state) {
			return;
		}
		const bool swimming = state->IsSwimming();  // AE: through AsActorState() (Heels Fix lesson)
		if (g_hooked) {
			const bool bound = swimming && ArmsBound(player);  // inventory scan only while in the water
			g_bound = bound;
			if (bound && !g_wasSinking) {
				++g_boundDives;
				logger::info("bondage sink: the player is in the water with her arms bound - sinking");
			}
			g_wasSinking = bound;
		}
		if (!g_active) {
			return;
		}
		if (!g_swimming) {
			g_swimming = swimming;
			if (swimming) {
				Send(true);  // loaded or started while in the water
			}
			return;
		}
		if (*g_swimming != swimming) {
			g_swimming = swimming;
			Send(swimming);
		}
	}

	std::string Report()
	{
		return std::format("swim events: {} sent {}; bondage sink: {} (bound swims {})\n", g_active ? "on" : "off", g_sent,
			g_hooked ? "hooked" : "off", g_boundDives);
	}
}
