#include "Inequality.h"

#include "Session.h"

namespace SLSFW::Inequality
{
	namespace
	{
		constexpr auto kSls = "SL Survival.esp"sv;
		constexpr auto kPatch = "SL Survival - Revision Tweaks.esp"sv;

		RE::SpellItem*   g_spell{ nullptr };     // _SLS_InequalitySpell 070253: effect 1 health, 3 magicka + stamina
		RE::TESFaction*  g_strong{ nullptr };    // _SLS_IneqStrongFemaleFact 0A7DA4
		RE::TESGlobal*   g_statOn{ nullptr };    // _SLS_IneqStat 070258
		RE::TESGlobal*   g_cushion{ nullptr };   // _SLS_IneqDebuffPlusCushion 073848
		RE::TESGlobal*   g_inHealth{ nullptr };  // _SLS_IneqNativeHealth (patch 000800): amount in place
		RE::TESGlobal*   g_inMagStam{ nullptr }; // _SLS_IneqNativeMagStam (patch 000801)
		std::atomic_bool g_suspended{ false };
		float            g_wait{ 0.0f };

		float Magnitude(std::size_t a_index)
		{
			if (!g_spell || a_index >= g_spell->effects.size() || !g_spell->effects[a_index]) {
				return 0.0f;
			}
			return std::max(0.0f, g_spell->effects[a_index]->effectItem.magnitude);
		}

		// faction ranks read directly: the virtual IsInFaction lied on this setup (DoM Framework, 2026-10-09)
		bool InFaction(RE::Actor* a_actor, const RE::TESFaction* a_faction)
		{
			if (!a_faction) {
				return false;
			}
			std::optional<int> rank;
			a_actor->VisitFactions([&](RE::TESFaction* a_f, std::int8_t a_rank) {
				if (a_f == a_faction) {
					rank = a_rank;
				}
				return false;
			});
			return rank && *rank >= 0;
		}

		// move the permanent modifier of a_av from what is in place (a_global) to a_want
		void Apply(RE::PlayerCharacter* a_player, RE::ActorValue a_av, RE::TESGlobal* a_global, float a_want)
		{
			const float have = a_global->value;
			if (std::abs(a_want - have) < 0.01f) {
				return;
			}
			a_player->AsActorValueOwner()->ModActorValue(RE::ACTOR_VALUE_MODIFIER::kPermanent, a_av, have - a_want);  // the maximum, not a red "drained" part
			logger::info("inequality: {} {} -> {}", static_cast<int>(a_av), have, a_want);
		}
	}

	bool Load()
	{
		auto* dh = RE::TESDataHandler::GetSingleton();
		g_spell = dh->LookupForm<RE::SpellItem>(0x070253, kSls);
		g_strong = dh->LookupForm<RE::TESFaction>(0x0A7DA4, kSls);
		g_statOn = dh->LookupForm<RE::TESGlobal>(0x070258, kSls);
		g_cushion = dh->LookupForm<RE::TESGlobal>(0x073848, kSls);
		g_inHealth = dh->LookupForm<RE::TESGlobal>(0x000800, kPatch);
		g_inMagStam = dh->LookupForm<RE::TESGlobal>(0x000801, kPatch);
		const bool ok = g_spell && g_strong && g_statOn && g_cushion && g_inHealth && g_inMagStam;
		logger::info("inequality: {}", ok ? "native player stats on" : "off (SL Survival - Revision Tweaks.esp or an SLS form missing)");
		if (!ok) {
			g_spell = nullptr;
		}
		return ok;
	}

	void Suspend(bool a_suspend)
	{
		g_suspended = a_suspend;
		g_wait = 0.0f;
	}

	void Tick(float a_seconds)
	{
		g_wait -= a_seconds;
		if (!g_spell || g_wait > 0.0f) {
			return;
		}
		g_wait = 1.0f;
		if (!Session::Settled()) {
			return;
		}
		auto* player = RE::PlayerCharacter::GetSingleton();
		auto* base = player ? player->GetActorBase() : nullptr;
		if (!base) {
			return;
		}
		const bool on = !g_suspended && g_statOn->value == 1.0f && base->GetSex() == RE::SEX::kFemale && !InFaction(player, g_strong);

		float health = on ? Magnitude(1) : 0.0f;
		if (health > 0.0f) {
			// SLS's cushion: the debuff never takes the maximum below the cushion
			const float maxWithout = player->AsActorValueOwner()->GetPermanentActorValue(RE::ActorValue::kHealth) + g_inHealth->value;
			health = std::clamp(maxWithout - g_cushion->value, 0.0f, health);
		}
		const float magStam = on ? Magnitude(3) : 0.0f;

		Apply(player, RE::ActorValue::kHealth, g_inHealth, health);
		g_inHealth->value = health;
		Apply(player, RE::ActorValue::kMagicka, g_inMagStam, magStam);
		Apply(player, RE::ActorValue::kStamina, g_inMagStam, magStam);
		g_inMagStam->value = magStam;
	}

	std::string Report()
	{
		if (!g_spell) {
			return "inequality: off\n";
		}
		return std::format("inequality: health -{} magicka/stamina -{}{}\n", g_inHealth->value, g_inMagStam->value, g_suspended ? " (suspended)" : "");
	}
}
