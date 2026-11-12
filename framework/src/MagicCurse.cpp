#include "MagicCurse.h"

#include "Session.h"

namespace SLSFW::MagicCurse
{
	namespace
	{
		constexpr float kShare = 0.5f;   // the most of the maximum the curse leaves
		constexpr float kPeriod = 0.25f;  // seconds between checks

		RE::SpellItem* g_curse{ nullptr };  // _SLS_MagicLicenceCurse 045C3C
		float          g_wait{ 0.0f };
		bool           g_logged{ false };   // one log line per curse, not one per check
	}

	bool Load()
	{
		g_curse = RE::TESDataHandler::GetSingleton()->LookupForm<RE::SpellItem>(0x045C3C, "SL Survival.esp"sv);
		logger::info("magicka curse: {}", g_curse ? "magicka capped at half of the maximum while cursed" : "off (spell not found)");
		return g_curse != nullptr;
	}

	void Tick(float a_seconds)
	{
		g_wait -= a_seconds;
		if (!g_curse || g_wait > 0.0f) {
			return;
		}
		g_wait = kPeriod;
		if (!Session::Settled()) {
			return;
		}
		auto* player = RE::PlayerCharacter::GetSingleton();
		if (!player || !player->HasSpell(g_curse)) {
			g_logged = false;
			return;
		}
		auto*       avs = player->AsActorValueOwner();
		const float max = player->GetActorValueMax(RE::ActorValue::kMagicka);
		const float now = avs->GetActorValue(RE::ActorValue::kMagicka);
		const float cap = max * kShare;
		if (max <= 0.0f || now <= cap + 0.01f) {
			return;
		}
		avs->DamageActorValue(RE::ActorValue::kMagicka, now - cap);
		if (!g_logged) {
			g_logged = true;
			logger::info("magicka curse: magicka {:.1f} of {:.1f} held at {:.1f}", now, max, cap);
		}
	}
}
