#include "Equip.h"

#include "Bridge.h"
#include "Forms.h"
#include "Session.h"

namespace SLSFW::Equip
{
	namespace
	{
		bool IsArmor(const RE::TESForm* a_form) { return a_form && a_form->Is(RE::FormType::Armor); }
		bool IsWeapon(const RE::TESForm* a_form) { return a_form && a_form->Is(RE::FormType::Weapon); }
		bool IsPotion(const RE::TESForm* a_form) { return a_form && a_form->Is(RE::FormType::AlchemyItem); }

		bool HasKeyword(const RE::TESForm* a_form, std::string_view a_editorID)
		{
			const auto* keywords = a_form ? a_form->As<RE::BGSKeywordForm>() : nullptr;
			return keywords && keywords->HasKeywordString(a_editorID);
		}

		bool IsPlayable(const RE::TESForm* a_form)
		{
			return a_form && (a_form->GetFormFlags() & RE::TESObjectARMO::RecordFlags::kNonPlayable) == 0;
		}

		// Actor.WornHasKeyword over every biped slot
		bool WornHasKeyword(RE::Actor* a_actor, std::string_view a_editorID)
		{
			if (!a_actor) {
				return false;
			}
			for (std::uint32_t bit = 0; bit < 32; ++bit) {
				const auto slot = static_cast<RE::BGSBipedObjectForm::BipedObjectSlot>(1u << bit);
				if (HasKeyword(a_actor->GetWornArmor(slot), a_editorID)) {
					return true;
				}
			}
			return false;
		}

		struct Event
		{
			const RE::TESForm*   base;
			RE::TESObjectREFR*   ref;
			bool                 equipped;
			const Bridge::Object& script;
			std::string_view     state;
		};

		struct Subscriber
		{
			std::string_view script;
			RE::FormID       quest;  // SL Survival.esp local id
			std::uint32_t    alias;  // alias id on that quest
			bool (*wants)(const Event&);
			std::uint32_t    dispatched{ 0 };
			RE::TESQuest*    questForm{ nullptr };
			// no cached BGSBaseAlias*: the engine frees and re-creates alias objects when quests revert on a load or a
			// new game, and a pointer taken at kDataLoaded pointed at freed memory on the first tick after a load
			// (CRASH-004). The alias is looked up on the quest at every use instead.
		};

		// Each filter reproduces the first test the original Papyrus handler made, in the state it made it in;
		// anything past that test stays in Papyrus. SLS_BeggingPlayerAlias had only empty handlers (removed).
		std::array<Subscriber, 15> g_subscribers{ {
			// potions: skooma/milk fatigue, drinking, cum breath. DD gag state is native (UpdateGag)
			{ "SLS_Main", 0x000D64, 0, [](const Event& e) { return e.equipped && IsPotion(e.base); } },
			{ "_SLS_LicBikiniCurse", 0x063A8C, 0, [](const Event& e) { return e.state != "Off" && IsArmor(e.base); } },
			{ "_SLS_GuardWarnArmorEquipped", 0x0969D9, 0, [](const Event& e) { return e.equipped && IsArmor(e.base); } },
			{ "_SLS_GuardWarnWeapEquipped", 0x0969E2, 0, [](const Event& e) { return IsWeapon(e.base); } },
			{ "_SLS_GuardWarnDrugsAlias", 0x09597E, 1, [](const Event& e) { return e.equipped && !e.state.empty() && IsPotion(e.base); } },
			{ "_SLS_OrgasmFatigueAlcohol", 0x0E857D, 0, [](const Event& e) { return e.equipped && IsPotion(e.base); } },
			{ "SLS_GluttonyPlayerAlias", 0x03BFBB, 0, [](const Event& e) {
				 return e.equipped && (e.state == "InProgress" || (IsPotion(e.base) && HasKeyword(e.base, "VendorItemFood")));
			 } },
			{ "SLS_DclBondageAdventure", 0x026890, 0, [](const Event& e) { return IsArmor(e.base) && HasKeyword(e.base, "zad_DeviousHeavyBondage"); } },
			{ "_SLS_MapAndCompassAlias", 0x04A8A2, 1, [](const Event& e) { return e.state == "Devious" && IsArmor(e.base) && HasKeyword(e.base, "zad_DeviousBlindfold"); } },
			{ "_SLS_CoverMyself", 0x0A1707, 2, [](const Event& e) { return e.equipped && e.state == "Covered" && IsArmor(e.base); } },
			{ "_SLS_CombatEquip", 0x12872A, 0, [](const Event& e) { return e.equipped && e.state == "InCombat" && IsArmor(e.base); } },
			{ "_SLS_DeviousEffects", 0x04F44A, 0, [](const Event& e) {
				 return IsArmor(e.base) && HasKeyword(e.base, "SexLabNoStrip") && HasKeyword(e.base, "zad_DeviousHeavyBondage");
			 } },
			{ "_SLS_TollDodgeDisguise", 0x094EB7, 0, [](const Event& e) { return IsArmor(e.base); } },
			{ "_SLS_AmputationHelplessAlias", 0x06A123, 1, [](const Event& e) {
				 return e.equipped && (e.state == "LeftHand" || e.state == "RightHand" || e.state == "BothHands") && e.base &&
				        (e.base->Is(RE::FormType::Weapon) || e.base->Is(RE::FormType::Spell) || e.base->Is(RE::FormType::Armor) || e.base->Is(RE::FormType::Light));
			 } },
			{ "_SLS_HalfNakedCover", 0x04C8FF, 0, [](const Event& e) {
				 if (e.state == "InProc" || !IsArmor(e.base) || !IsPlayable(e.base) || HasKeyword(e.base, "SexLabNoStrip")) {
					 return false;
				 }
				 // body (32), and the panty / bra slots chosen in the MCM
				 std::uint32_t mask = 1u << 2;
				 for (const auto* name : { "PantySlot", "BraSlot" }) {
					 const auto slot = Bridge::GetInt(e.script, name).value_or(0);
					 if (slot >= 30 && slot <= 61) {
						 mask |= 1u << (slot - 30);
					 }
				 }
				 const auto* armor = e.base->As<RE::TESObjectARMO>();
				 return armor && (armor->GetSlotMask().underlying() & mask) != 0;
			 } },
		} };

		// SLS_MinAv: re-balances speed / carry weight when an equip changed them, or the hobble state changed
		constexpr RE::FormID kMinAvQuest = 0x026E22;
		RE::TESQuest*        g_minAvQuest{ nullptr };
		// written by the equip sink (any thread) and read by Tick (main thread): atomics
		std::atomic<float>              g_minAvIn{ -1.0f };
		std::atomic<const RE::TESForm*> g_minAvBase{ nullptr };
		std::uint32_t                   g_minAvDispatched{ 0 };

		// Init.PlayerIsHardGagged (dialogue condition) = player WornHasKeyword zad_DialGagHard
		std::atomic_bool g_gagPending{ false };
		std::uint32_t    g_gagUpdates{ 0 };

		// _SLS_PlayerIsBareFoot (0783BF), the condition of the barefoot slow-walk ability. _SLS_LicBikiniCurse sets it
		// only after its "wait until the menu closes / equipping stops" loop (2 s steps); the DLL sets it on the equip
		// itself with the same rule: nothing on the feet slot, or feet armour carrying the "BareFeet" keyword.
		constexpr RE::FormID      kBarefootGlobal = 0x0783BF;
		RE::TESGlobal*            g_barefootGlobal{ nullptr };
		constexpr RE::FormID      kBarefootSpell = 0x0783C1;  // _SLS_BarefootSpeedSpell, ability conditioned on the global
		RE::SpellItem*            g_barefootSpell{ nullptr };
		std::atomic_bool          g_barefootPending{ false };
		std::atomic<float>        g_barefootRecheckIn{ -1.0f };  // the worn list settles after the event
		std::uint32_t             g_barefootUpdates{ 0 };

		std::uint64_t g_events{ 0 };

		RE::BGSBaseAlias* AliasOf(RE::TESQuest* a_quest, std::uint32_t a_id)
		{
			if (!a_quest) {
				return nullptr;
			}
			for (auto* alias : a_quest->aliases) {
				if (alias && alias->aliasID == a_id) {
					return alias;
				}
			}
			return nullptr;
		}

		// TESQuest::IsRunning() in CommonLib NG is "!IsStopping() && !promoteTask" - true for a quest that never
		// started. What SLS's handlers relied on is the quest being enabled (started) and not stopping.
		bool QuestRunning(const RE::TESQuest* a_quest)
		{
			return a_quest && a_quest->IsEnabled() && !a_quest->IsStopping();
		}

		Bridge::Object ScriptOf(Subscriber& a_sub)
		{
			if (!QuestRunning(a_sub.questForm)) {
				return {};
			}
			return Bridge::Find(AliasOf(a_sub.questForm, a_sub.alias), a_sub.script);
		}

		void UpdateGag()
		{
			g_gagPending = false;
			if (!RE::TESForm::LookupByEditorID("zad_DialGagHard")) {
				return;  // no Devious Devices: SLS's interface answers false and never touches the flag
			}
			const auto init = Bridge::Find(Forms::Get().main, "SLS_Init");
			const bool gagged = WornHasKeyword(RE::PlayerCharacter::GetSingleton(), "zad_DialGagHard");
			if (Bridge::GetBool(init, "PlayerIsHardGagged") != gagged && Bridge::SetBool(init, "PlayerIsHardGagged", gagged)) {
				++g_gagUpdates;
				logger::info("Init.PlayerIsHardGagged = {}", gagged);
			}
		}

		bool BarefootTracked()
		{
			if (!g_barefootGlobal) {
				return false;
			}
			// same gate as SLS: the bikini-curse alias only checks while its quest runs and it is not in state "Off"
			const auto it = std::ranges::find_if(g_subscribers, [](const Subscriber& a_sub) { return a_sub.script == "_SLS_LicBikiniCurse"sv; });
			if (it == g_subscribers.end()) {
				return false;
			}
			const auto script = ScriptOf(*it);
			return script && Bridge::State(script) != "Off";
		}

		void SetBarefoot(bool a_barefoot)
		{
			const float value = a_barefoot ? 1.0f : 0.0f;
			if (g_barefootGlobal->value == value) {
				return;
			}
			g_barefootGlobal->value = value;
			++g_barefootUpdates;
			// the engine re-checks an ability's conditions only about once a second; re-adding the ability checks
			// them now, and a carry-weight nudge makes the movement speed follow at once (what the effect's own
			// OnEffectStart does)
			auto* player = RE::PlayerCharacter::GetSingleton();
			if (player && g_barefootSpell && player->HasSpell(g_barefootSpell)) {
				player->RemoveSpell(g_barefootSpell);
				player->AddSpell(g_barefootSpell);
				auto* avs = player->AsActorValueOwner();
				avs->ModActorValue(RE::ACTOR_VALUE_MODIFIER::kTemporary, RE::ActorValue::kCarryWeight, 0.01f);
				avs->ModActorValue(RE::ACTOR_VALUE_MODIFIER::kTemporary, RE::ActorValue::kCarryWeight, -0.01f);
			}
		}

		// feet armour equipped or removed: decide from the event itself, the worn list still shows the old state
		void BarefootFromEvent(const RE::TESObjectARMO* a_armor, bool a_equipped)
		{
			if (!a_armor || !a_armor->HasPartOf(RE::BGSBipedObjectForm::BipedObjectSlot::kFeet) || !BarefootTracked()) {
				return;
			}
			SetBarefoot(!a_equipped || a_armor->HasKeywordString("BareFeet"));
			g_barefootRecheckIn = 0.5f;
		}

		void UpdateBarefoot()
		{
			g_barefootPending = false;
			auto* player = RE::PlayerCharacter::GetSingleton();
			if (!player || !BarefootTracked()) {
				return;
			}
			const auto* feet = player->GetWornArmor(RE::BGSBipedObjectForm::BipedObjectSlot::kFeet);
			SetBarefoot(!feet || feet->HasKeywordString("BareFeet"));
		}

		void CheckMinAv()
		{
			g_minAvIn = -1.0f;
			if (!QuestRunning(g_minAvQuest)) {
				return;
			}
			const auto script = Bridge::Find(AliasOf(g_minAvQuest, 0), "SLS_MinAv");
			auto*      player = RE::PlayerCharacter::GetSingleton();
			if (!script || !player) {
				return;
			}
			const auto state = Bridge::State(script);
			const bool hobbled = WornHasKeyword(player, "zad_DeviousHobbleSkirt");
			auto*      avs = player->AsActorValueOwner();
			const bool speedChanged = avs->GetActorValue(RE::ActorValue::kSpeedMult) != Bridge::GetFloat(script, "OldSpeedMult").value_or(-1.0f);
			const bool carryChanged = avs->GetActorValue(RE::ActorValue::kCarryWeight) != Bridge::GetFloat(script, "OldCarryWeight").value_or(-1.0f);
			bool       wants = false;
			if (state == "Hobbled") {
				wants = !hobbled;
			} else if (state == "EventBased") {
				wants = hobbled || speedChanged || carryChanged;
			} else if (state == "StopUpdates") {
				wants = true;  // an update is running; the handler only flags RecentEquip
			}
			if (wants) {
				++g_minAvDispatched;
				Bridge::Call(script, "SLSFW_Equipped", const_cast<RE::TESForm*>(g_minAvBase.load()), static_cast<RE::TESObjectREFR*>(nullptr));
			}
		}

		class Sink : public RE::BSTEventSink<RE::TESEquipEvent>
		{
		public:
			static Sink* GetSingleton()
			{
				static Sink singleton;
				return std::addressof(singleton);
			}

			RE::BSEventNotifyControl ProcessEvent(const RE::TESEquipEvent* a_event, RE::BSTEventSource<RE::TESEquipEvent>*) override
			{
				if (!a_event || !a_event->actor || !a_event->actor->IsPlayerRef()) {
					return RE::BSEventNotifyControl::kContinue;
				}
				// the saved inventory is re-equipped from the loader thread while the VM and the aliases are still being
				// rebuilt: nothing to dispatch to yet; the derived flags are recomputed by OnGameLoaded anyway
				if (!Session::Settled()) {
					return RE::BSEventNotifyControl::kContinue;
				}
				const auto* base = RE::TESForm::LookupByID(a_event->baseObject);
				if (!base) {
					return RE::BSEventNotifyControl::kContinue;
				}
				++g_events;
				auto* ref = a_event->originalRefr ? RE::TESForm::LookupByID<RE::TESObjectREFR>(a_event->originalRefr) : nullptr;

				for (auto& sub : g_subscribers) {
					const auto script = ScriptOf(sub);
					if (!script) {
						continue;
					}
					const auto  state = Bridge::State(script);
					const Event e{ base, ref, a_event->equipped, script, state };
					if (sub.wants(e)) {
						++sub.dispatched;
						Bridge::Call(script, a_event->equipped ? "SLSFW_Equipped" : "SLSFW_Unequipped", const_cast<RE::TESForm*>(base), ref);
					}
				}

				if (base->Is(RE::FormType::Armor)) {
					BarefootFromEvent(base->As<RE::TESObjectARMO>(), a_event->equipped);
				}
				if (IsArmor(base) && HasKeyword(base, "zad_Lockable")) {
					g_gagPending = true;  // the worn list settles after the event
				}
				if (base->Is(RE::FormType::Armor) || base->Is(RE::FormType::Weapon) || base->Is(RE::FormType::Ammo) || base->Is(RE::FormType::Light)) {
					g_minAvBase = base;
					g_minAvIn = 0.5f;  // SLS_MinAv waited for enchantments to apply before comparing
				}
				return RE::BSEventNotifyControl::kContinue;
			}
		};
	}

	void Register()
	{
		auto* data = RE::TESDataHandler::GetSingleton();
		for (auto& sub : g_subscribers) {
			sub.questForm = data->LookupForm<RE::TESQuest>(sub.quest, Forms::kPlugin);
			if (!AliasOf(sub.questForm, sub.alias)) {
				logger::warn("equip subscriber {}: quest {:06X} alias {} not found", sub.script, sub.quest, sub.alias);
			}
		}
		g_minAvQuest = data->LookupForm<RE::TESQuest>(kMinAvQuest, Forms::kPlugin);
		g_barefootGlobal = data->LookupForm<RE::TESGlobal>(kBarefootGlobal, Forms::kPlugin);
		g_barefootSpell = data->LookupForm<RE::SpellItem>(kBarefootSpell, Forms::kPlugin);
		RE::ScriptEventSourceHolder::GetSingleton()->AddEventSink<RE::TESEquipEvent>(Sink::GetSingleton());
		logger::info("equip hub: {} subscribers + MinAV + gag flag", g_subscribers.size());
	}

	void Tick(float a_seconds)
	{
		if (!Session::Settled()) {
			return;  // the pending flags wait until the quests and aliases exist again
		}
		if (g_gagPending) {
			UpdateGag();
		}
		if (const float in = g_barefootRecheckIn; in >= 0.0f) {
			g_barefootRecheckIn = in - a_seconds;
			if (in - a_seconds < 0.0f) {
				g_barefootPending = true;
			}
		}
		if (g_barefootPending) {
			UpdateBarefoot();
		}
		if (const float in = g_minAvIn; in >= 0.0f) {
			g_minAvIn = in - a_seconds;
			if (in - a_seconds <= 0.0f) {
				CheckMinAv();
			}
		}
	}

	void OnGameLoaded()
	{
		g_gagPending = true;
		g_barefootPending = true;
		g_minAvIn = -1.0f;
	}

	std::string Report()
	{
		std::string out = std::format("SLSFW equip: {} player equip events, gag flag updates {}, barefoot flag updates {}, MinAV calls {}\n", g_events,
			g_gagUpdates, g_barefootUpdates, g_minAvDispatched);
		for (auto& sub : g_subscribers) {
			const bool running = QuestRunning(sub.questForm);
			const auto script = running ? ScriptOf(sub) : Bridge::Object{};
			out += std::format("  {} {} state=\"{}\" calls={}\n", sub.script, running ? (script ? "bound" : "running, unbound") : "stopped",
				Bridge::State(script), sub.dispatched);
		}
		return out;
	}
}
