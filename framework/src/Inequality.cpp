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

		// The amount in place is kept in the base value, not in a modifier: the stats menu and the HUD paint ANY value
		// below its base red - a permanent modifier (the first native version) as much as the spell's effect did. The
		// globals hold kBaseMode + amount once the amount lives in the base; a value below kBaseMode is an older save
		// whose amount is still a permanent modifier, moved into the base once (the maximum stays the same).
		constexpr float kBaseMode = 10000.0f;

		float InPlace(const RE::TESGlobal* a_global)
		{
			return a_global->value >= kBaseMode ? a_global->value - kBaseMode : a_global->value;
		}

		void Migrate(RE::PlayerCharacter* a_player, RE::ActorValue a_av, RE::TESGlobal* a_global, bool a_last)
		{
			if (a_global->value >= kBaseMode) {
				return;
			}
			const float have = a_global->value;
			if (have > 0.0f) {
				auto* avs = a_player->AsActorValueOwner();
				avs->ModActorValue(RE::ACTOR_VALUE_MODIFIER::kPermanent, a_av, have);
				avs->SetBaseActorValue(a_av, avs->GetBaseActorValue(a_av) - have);
				logger::info("inequality: {} moved {} from the permanent modifier into the base value", static_cast<int>(a_av), have);
			}
			if (a_last) {
				a_global->value = kBaseMode + have;
			}
		}

		// move the base value of a_av from a_have (what is in place) to a_want
		void Apply(RE::PlayerCharacter* a_player, RE::ActorValue a_av, float a_have, float a_want)
		{
			if (std::abs(a_want - a_have) < 0.01f) {
				return;
			}
			auto* avs = a_player->AsActorValueOwner();
			avs->SetBaseActorValue(a_av, avs->GetBaseActorValue(a_av) + a_have - a_want);  // a shorter bar, not a red one
			logger::info("inequality: {} {} -> {}", static_cast<int>(a_av), a_have, a_want);
		}

		// A race switch rebuilds the player's base health, magicka and stamina (2026-11-10: AP's RaceMenu on a new game
		// put them back to 100 after the amount was in place, the globals still said 40 and nothing was taken off again).
		// The base each value had after our last change is kept here; after a race switch a different base means the
		// game rebuilt it and nothing of ours is in it any more. Only a race switch is checked: a level-up raises the base
		// legitimately.
		constexpr std::array<RE::ActorValue, 3> kAvs{ RE::ActorValue::kHealth, RE::ActorValue::kMagicka, RE::ActorValue::kStamina };
		std::array<float, 3> g_expected{};
		bool                 g_expectedKnown{ false };
		std::atomic_bool     g_raceSwitched{ false };

		struct RaceSink final : RE::BSTEventSink<RE::TESSwitchRaceCompleteEvent>
		{
			RE::BSEventNotifyControl ProcessEvent(const RE::TESSwitchRaceCompleteEvent* a_event, RE::BSTEventSource<RE::TESSwitchRaceCompleteEvent>*) override
			{
				if (a_event && a_event->subject && a_event->subject->IsPlayerRef()) {
					g_raceSwitched = true;
				}
				return RE::BSEventNotifyControl::kContinue;
			}
		};
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
			return false;
		}
		static RaceSink sink;
		RE::ScriptEventSourceHolder::GetSingleton()->AddEventSink<RE::TESSwitchRaceCompleteEvent>(std::addressof(sink));
		return true;
	}

	void Reset()
	{
		g_expectedKnown = false;
		g_raceSwitched = false;
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
		// RaceMenu may still switch the race, which rebuilds the base: take the amount off once it is closed
		if (auto* ui = RE::UI::GetSingleton(); ui && ui->IsMenuOpen(RE::RaceSexMenu::MENU_NAME)) {
			return;
		}
		Migrate(player, RE::ActorValue::kHealth, g_inHealth, true);
		Migrate(player, RE::ActorValue::kMagicka, g_inMagStam, false);
		Migrate(player, RE::ActorValue::kStamina, g_inMagStam, true);

		auto*                avs = player->AsActorValueOwner();
		std::array<float, 3> have{ InPlace(g_inHealth), InPlace(g_inMagStam), InPlace(g_inMagStam) };
		if (g_raceSwitched.exchange(false) && g_expectedKnown) {
			for (std::size_t i = 0; i < kAvs.size(); ++i) {
				const float now = avs->GetBaseActorValue(kAvs[i]);
				if (have[i] > 0.0f && std::abs(now - g_expected[i]) > 0.5f) {
					logger::info("inequality: race switch rebuilt {} ({} -> {}), its {} is no longer in place", static_cast<int>(kAvs[i]),
						g_expected[i], now, have[i]);
					have[i] = 0.0f;
				}
			}
		}

		const bool on = !g_suspended && g_statOn->value == 1.0f && base->GetSex() == RE::SEX::kFemale && !InFaction(player, g_strong);

		float health = on ? Magnitude(1) : 0.0f;
		if (health > 0.0f) {
			// SLS's cushion: the debuff never takes the maximum below the cushion
			const float maxWithout = avs->GetPermanentActorValue(RE::ActorValue::kHealth) + have[0];
			health = std::clamp(maxWithout - g_cushion->value, 0.0f, health);
		}
		const float magStam = on ? Magnitude(3) : 0.0f;
		const std::array<float, 3> want{ health, magStam, magStam };

		for (std::size_t i = 0; i < kAvs.size(); ++i) {
			Apply(player, kAvs[i], have[i], want[i]);
			g_expected[i] = avs->GetBaseActorValue(kAvs[i]);
		}
		g_expectedKnown = true;
		g_inHealth->value = kBaseMode + health;
		g_inMagStam->value = kBaseMode + magStam;
	}

	std::string Report()
	{
		if (!g_spell) {
			return "inequality: off\n";
		}
		return std::format("inequality: health -{} magicka/stamina -{}{}\n", InPlace(g_inHealth), InPlace(g_inMagStam), g_suspended ? " (suspended)" : "");
	}
}
