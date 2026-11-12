#include "BaboGuard.h"

namespace SLSFW::BaboGuard
{
	namespace
	{
		constexpr std::string_view kPlugin = "BaboInteractiveDia.esp"sv;

		constexpr RE::FormID kKidnapQuest = 0x3BE3E7;  // BaboKidnapEvent
		constexpr RE::FormID kBadEndQuest = 0xF8A6CE;  // BaboBadEnd
		constexpr RE::FormID kRieklingQuest = 0x07AD9B;  // BaboEventRieklingThirsk
		constexpr RE::FormID kTiedUp = 0xBE6470;  // BaboKidnapTiedUp: 1 while bound or caged
		constexpr RE::FormID kTrapped = 0x02CF41;  // BaboKidnapPlayerGotTrappedGlobal
		constexpr RE::FormID kSceneStandBy = 0xAA0C39;  // BaboSceneStandBy

		bool g_enabled{ true };

		RE::TESGlobal* Global(RE::FormID a_id)
		{
			auto* handler = RE::TESDataHandler::GetSingleton();
			return handler ? handler->LookupForm<RE::TESGlobal>(a_id, kPlugin) : nullptr;
		}

		RE::TESQuest* Quest(RE::FormID a_id)
		{
			auto* handler = RE::TESDataHandler::GetSingleton();
			return handler ? handler->LookupForm<RE::TESQuest>(a_id, kPlugin) : nullptr;
		}

		// TESQuest::IsRunning() in CommonLib NG is true for a quest that never started (SLSFW-004), so "running" is
		// enabled and not stopping.
		bool Running(RE::FormID a_id)
		{
			auto* quest = Quest(a_id);
			return quest && quest->IsEnabled() && !quest->IsStopping();
		}

		bool NonZero(RE::FormID a_id)
		{
			auto* global = Global(a_id);
			return global && global->value != 0.0f;
		}

		std::uint32_t SceneBusy()
		{
			auto* handler = RE::TESDataHandler::GetSingleton();
			auto* flag = handler ? handler->LookupForm<RE::TESGlobal>(0x000800, "BaboDialogue - Patches.esp"sv) : nullptr;
			return flag ? static_cast<std::uint32_t>(std::max(0.0f, flag->value)) : 0u;
		}
	}

	void Configure(bool a_enabled)
	{
		g_enabled = a_enabled;
		logger::info("babo guard: {} ({})", g_enabled ? "on" : "off", Installed() ? "BaboDialogue found" : "BaboDialogue not installed");
	}

	bool Installed() { return Quest(kKidnapQuest) != nullptr; }

	const char* BusyReason()
	{
		if (!g_enabled) {
			return nullptr;
		}
		if (NonZero(kTiedUp)) {
			return "Babo: the player is tied up";
		}
		if (NonZero(kTrapped)) {
			return "Babo: the player is trapped";
		}
		if (Running(kKidnapQuest)) {
			return "Babo: a kidnapping is running";
		}
		if (Running(kBadEndQuest)) {
			return "Babo: a bad end is running";
		}
		if (Running(kRieklingQuest)) {
			return "Babo: the riekling capture is running";
		}
		if (NonZero(kSceneStandBy)) {
			return "Babo: a scene is running";
		}
		// the shared _SG_SceneBusy: 1 a Diary of Mine capture, 2 the knocked-out menu, 8 SexLab Horrible Harassment.
		// Bit 4 is SL Survival's own reservation and never pauses its guards.
		if (const auto mask = SceneBusy(); mask & 1u) {
			return "a Diary of Mine capture is running";
		} else if (mask & 2u) {
			return "the knocked-out menu is open";
		} else if (mask & 8u) {
			return "SLHH: a harassment is running";
		}
		return nullptr;
	}

	bool Busy()
	{
		static bool wasBusy = false;
		const auto* why = BusyReason();
		if ((why != nullptr) != wasBusy) {
			wasBusy = why != nullptr;
			logger::info("babo guard: guard searches {}{}{}", wasBusy ? "paused - " : "resumed", wasBusy && why ? why : "", wasBusy ? "" : "");
		}
		return why != nullptr;
	}
}
