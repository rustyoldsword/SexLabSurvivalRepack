#include "Papyrus.h"

#include "Equip.h"
#include "Followers.h"
#include "Gates.h"
#include "Inequality.h"
#include "GuardWatch.h"
#include "Messages.h"
#include "LostItems.h"
#include "Nudity.h"
#include "Profiler.h"
#include "SteepFall.h"
#include "Swim.h"

namespace SLSFW::Papyrus
{
	namespace
	{
		std::atomic_bool g_ready{ false };

		bool IsReady(RE::StaticFunctionTag*)
		{
			return g_ready;
		}

		std::int32_t GetApiVersion(RE::StaticFunctionTag*)
		{
			return kApiVersion;
		}

		RE::BSFixedString Report(RE::StaticFunctionTag*)
		{
			const std::string text = BuildReport();
			logger::info("{}", text);
			if (auto* console = RE::ConsoleLog::GetSingleton()) {
				std::size_t start = 0;
				while (start < text.size()) {
					const auto end = text.find('\n', start);
					const auto line = text.substr(start, end == std::string::npos ? std::string::npos : end - start);
					if (!line.empty()) {
						console->Print("%s", line.c_str());
					}
					if (end == std::string::npos) {
						break;
					}
					start = end + 1;
				}
			}
			return text;
		}

		std::int32_t SetTownGatesLocked(RE::StaticFunctionTag*, RE::TESObjectREFR* a_door, bool a_lock, std::int32_t a_lockLevel)
		{
			return g_ready ? Gates::SetTownLocked(a_door, a_lock, a_lockLevel) : 0;
		}

		std::int32_t GetTollTown(RE::StaticFunctionTag*, RE::TESObjectREFR* a_door)
		{
			return Gates::TownOf(a_door);
		}

		void GatesChanged(RE::StaticFunctionTag*, RE::BSFixedString a_reason)
		{
			if (g_ready) {
				Gates::Changed(a_reason.c_str());
			}
		}

		void GatesHold(RE::StaticFunctionTag*, bool a_hold)
		{
			if (g_ready) {
				Gates::Hold(a_hold);
			}
		}

		void SteepFallStart(RE::StaticFunctionTag*, RE::BGSRefAlias* a_alias, float a_fallHeight, float a_crawlAllowance)
		{
			if (g_ready) {
				SteepFall::Start(a_alias, a_fallHeight, a_crawlAllowance);
			}
		}

		void SteepFallStop(RE::StaticFunctionTag*)
		{
			SteepFall::Stop();
		}

		void SteepFallRebase(RE::StaticFunctionTag*)
		{
			SteepFall::Rebase();
		}

		RE::BSFixedString ProfileReport(RE::StaticFunctionTag*, std::int32_t a_limit, RE::BSFixedString a_filter)
		{
			const std::string text = Profiler::Report(a_limit > 0 ? static_cast<std::uint32_t>(a_limit) : 60u, a_filter.c_str());
			logger::info("{}", text);
			return text;
		}

		void LostItemsTracking(RE::StaticFunctionTag*, std::int32_t a_spots)
		{
			LostItems::SetActiveSpots(a_spots);
		}

		bool AliasHasMatch(RE::StaticFunctionTag*, RE::TESQuest* a_quest, std::int32_t a_aliasId)
		{
			return !g_ready || GuardWatch::AliasHasMatch(a_quest, a_aliasId);
		}

		RE::Actor* FindSpottingGuard(RE::StaticFunctionTag*, RE::TESQuest* a_quest)
		{
			return g_ready ? GuardWatch::FindSpottingGuard(a_quest) : nullptr;
		}

		std::vector<RE::Actor*> FindDetectingGuards(RE::StaticFunctionTag*, RE::TESQuest* a_quest)
		{
			return g_ready ? GuardWatch::FindDetectingGuards(a_quest) : std::vector<RE::Actor*>{};
		}

		std::int32_t CountFollowers(RE::StaticFunctionTag*, RE::TESQuest* a_followerQuest, RE::TESFaction* a_creature, RE::TESFaction* a_animal)
		{
			return Followers::Count(a_followerQuest, a_creature, a_animal);
		}

		std::vector<RE::Actor*> GetFollowers(RE::StaticFunctionTag*, RE::TESQuest* a_followerQuest, RE::TESFaction* a_creature, RE::TESFaction* a_animal)
		{
			return Followers::List(a_followerQuest, a_creature, a_animal);
		}

		void InequalitySuspend(RE::StaticFunctionTag*, bool a_suspend)
		{
			Inequality::Suspend(a_suspend);
		}

		void ProfileReset(RE::StaticFunctionTag*)
		{
			Profiler::Reset();
		}
	}

	void SetReady(bool a_ready)
	{
		g_ready = a_ready;
	}

	std::string BuildReport()
	{
		std::string text = std::format("SLSFW api {} ready={}\n", kApiVersion, g_ready.load());
		text += Gates::Report();
		text += SteepFall::Report();
		text += Equip::Report();
		text += LostItems::Report();
		text += Nudity::Report();
		text += GuardWatch::Report();
		text += Messages::Report();
		text += Inequality::Report();
		text += Swim::Report();
		return text;
	}

	namespace
	{
		std::atomic<float> g_reportIn{ -1.0f };  // seconds until the post-load report, -1 none pending
	}

	void ScheduleLoadReport()
	{
		g_reportIn = 5.0f;  // let SLS's own OnPlayerLoadGame work settle first
	}

	void ReportTick(float a_seconds)
	{
		float left = g_reportIn;
		if (left < 0.0f || !g_ready) {
			return;
		}
		left -= a_seconds;
		if (left > 0.0f) {
			g_reportIn = left;
			return;
		}
		g_reportIn = -1.0f;
		logger::info("after load:\n{}", BuildReport());
	}

	bool Register(RE::BSScript::IVirtualMachine* a_vm)
	{
		a_vm->RegisterFunction("IsReady", kClass, IsReady, true);
		a_vm->RegisterFunction("GetApiVersion", kClass, GetApiVersion, true);
		a_vm->RegisterFunction("Report", kClass, Report);
		a_vm->RegisterFunction("SetTownGatesLocked", kClass, SetTownGatesLocked);
		a_vm->RegisterFunction("GetTollTown", kClass, GetTollTown);
		a_vm->RegisterFunction("GatesChanged", kClass, GatesChanged);
		a_vm->RegisterFunction("GatesHold", kClass, GatesHold);
		a_vm->RegisterFunction("SteepFallStart", kClass, SteepFallStart);
		a_vm->RegisterFunction("SteepFallStop", kClass, SteepFallStop);
		a_vm->RegisterFunction("SteepFallRebase", kClass, SteepFallRebase);
		a_vm->RegisterFunction("ProfileReport", kClass, ProfileReport);
		a_vm->RegisterFunction("ProfileReset", kClass, ProfileReset);
		a_vm->RegisterFunction("LostItemsTracking", kClass, LostItemsTracking);
		a_vm->RegisterFunction("AliasHasMatch", kClass, AliasHasMatch);
		a_vm->RegisterFunction("FindSpottingGuard", kClass, FindSpottingGuard);
		a_vm->RegisterFunction("FindDetectingGuards", kClass, FindDetectingGuards);
		a_vm->RegisterFunction("CountFollowers", kClass, CountFollowers);
		a_vm->RegisterFunction("GetFollowers", kClass, GetFollowers);
		a_vm->RegisterFunction("InequalitySuspend", kClass, InequalitySuspend);
		Messages::Register(a_vm);
		logger::info("Papyrus class {} registered (api {})", kClass, kApiVersion);
		return true;
	}
}
