#include "Nudity.h"

#include "Bridge.h"
#include "Forms.h"
#include "Session.h"

namespace SLSFW::Nudity
{
	namespace
	{
		constexpr auto kAndPlugin = "Advanced Nudity Detection.esp"sv;

		struct Factions
		{
			RE::TESFaction* nude{ nullptr };        // 000831 AND_NudeActorFaction
			RE::TESFaction* topless{ nullptr };     // 000832 AND_ToplessFaction
			RE::TESFaction* bottomless{ nullptr };  // 000833 AND_BottomlessFaction
			RE::TESFaction* bra{ nullptr };         // 000834 AND_ShowingBraFaction
			RE::TESFaction* underwear{ nullptr };   // 000835 AND_ShowingUnderwearFaction
			RE::TESFaction* chest{ nullptr };       // 00082F AND_ShowingChestFaction
			RE::TESFaction* genitals{ nullptr };    // 000830 AND_ShowingGenitalsFaction
			RE::TESFaction* ass{ nullptr };         // 00082E AND_ShowingAssFaction
		} g_and;

		// _SLS_LicBikiniCurseQuest 063A8C, alias 0
		constexpr RE::FormID kCurseQuest = 0x063A8C;
		RE::TESQuest*        g_curseQuest{ nullptr };  // the alias is looked up per check: never cache a BGSBaseAlias* (CRASH-004)

		RE::BGSBaseAlias* CurseAlias()
		{
			if (!g_curseQuest || !g_curseQuest->IsEnabled() || g_curseQuest->IsStopping()) {
				return nullptr;
			}
			for (auto* alias : g_curseQuest->aliases) {
				if (alias && alias->aliasID == 0) {
					return alias;
				}
			}
			return nullptr;
		}

		std::atomic<std::int32_t> g_lastSig{ -1 };
		std::atomic<std::uint64_t> g_events{ 0 };
		std::uint32_t             g_dispatched{ 0 };

		// AND keeps the player in all of its factions and encodes the verdict as the rank: 1 yes, 0 no
		bool In(RE::Actor* a_actor, RE::TESFaction* a_faction)
		{
			return a_faction && a_actor->GetFactionRank(a_faction, a_actor->IsPlayerRef()) >= 1;
		}

		// the same signature as _SLS_LicBikiniCurse.AndExposureSig / _SLS_IntAnd:
		// bit 0 naked (nude, or topless and bottomless), bit 1 bra/underwear showing, bit 2 anything revealing
		std::int32_t Signature(RE::Actor* a_player)
		{
			const bool topless = In(a_player, g_and.topless);
			const bool bottomless = In(a_player, g_and.bottomless);
			std::int32_t sig = 0;
			if (In(a_player, g_and.nude) || (topless && bottomless)) {
				sig |= 1;
			}
			if (In(a_player, g_and.bra) || In(a_player, g_and.underwear)) {
				sig |= 2;
			}
			if (topless || bottomless || In(a_player, g_and.chest) || In(a_player, g_and.genitals) || In(a_player, g_and.ass)) {
				sig |= 4;
			}
			return sig;
		}

		void Check()  // main thread
		{
			auto* player = RE::PlayerCharacter::GetSingleton();
			if (!player || !Session::Settled()) {
				return;
			}
			const auto sig = Signature(player);
			if (sig == g_lastSig) {
				return;
			}
			const auto script = Bridge::Find(CurseAlias(), "_SLS_LicBikiniCurse");
			if (!script) {
				return;  // quest stopped: SLS ignored these passes too
			}
			if (Bridge::Call(script, "SLSFW_AndNudityUpdate")) {
				g_lastSig = sig;  // only a delivered change counts; a failed dispatch is retried on the next tick
				++g_dispatched;
			}
		}

		float g_sinceCheck{ 0.0f };
	}

	void Register()
	{
		auto* data = RE::TESDataHandler::GetSingleton();
		if (!data->LookupModByName(kAndPlugin)) {
			logger::info("nudity relay: {} not loaded", kAndPlugin);
			return;
		}
		g_and.nude = data->LookupForm<RE::TESFaction>(0x000831, kAndPlugin);
		g_and.topless = data->LookupForm<RE::TESFaction>(0x000832, kAndPlugin);
		g_and.bottomless = data->LookupForm<RE::TESFaction>(0x000833, kAndPlugin);
		g_and.bra = data->LookupForm<RE::TESFaction>(0x000834, kAndPlugin);
		g_and.underwear = data->LookupForm<RE::TESFaction>(0x000835, kAndPlugin);
		g_and.chest = data->LookupForm<RE::TESFaction>(0x00082F, kAndPlugin);
		g_and.genitals = data->LookupForm<RE::TESFaction>(0x000830, kAndPlugin);
		g_and.ass = data->LookupForm<RE::TESFaction>(0x00082E, kAndPlugin);
		g_curseQuest = data->LookupForm<RE::TESQuest>(kCurseQuest, Forms::kPlugin);
		bool haveAlias = false;
		if (g_curseQuest) {
			for (auto* alias : g_curseQuest->aliases) {
				haveAlias = haveAlias || (alias && alias->aliasID == 0);
			}
		}
		logger::info("nudity relay: polling AND faction ranks (factions {}, bikini curse alias {})", g_and.nude ? "ok" : "MISSING",
			haveAlias ? "ok" : "MISSING");
	}

	void Reset()
	{
		g_lastSig = -1;
	}

	void Tick(float a_seconds)
	{
		g_sinceCheck += a_seconds;
		if (g_sinceCheck < 0.5f || !g_and.nude) {
			return;
		}
		g_sinceCheck = 0.0f;
		++g_events;
		Check();
	}

	std::string Report()
	{
		auto*      player = RE::PlayerCharacter::GetSingleton();
		const auto sig = player && g_and.nude ? Signature(player) : -1;
		return std::format("SLSFW nudity relay: {} checks, {} sent to the bikini curse, signature now {} (last sent {})\n",
			g_events.load(), g_dispatched, sig, g_lastSig.load());
	}
}
