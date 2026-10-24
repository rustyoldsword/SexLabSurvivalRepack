#include "BaboGuard.h"
#include "DomGuard.h"
#include "Equip.h"
#include "Forms.h"
#include "Gates.h"
#include "Inequality.h"
#include "GuardWatch.h"
#include "LostItems.h"
#include "Nudity.h"
#include "Papyrus.h"
#include "Profiler.h"
#include "Scheduler.h"
#include "Session.h"
#include "SteepFall.h"
#include "Swim.h"

namespace
{
	void InitializeLogging()
	{
		auto path = logger::log_directory();
		if (!path) {
			SKSE::stl::report_and_fail("Unable to lookup SKSE logs directory.");
		}
		*path /= "SLSurvivalFramework.log";

		auto log = std::make_shared<spdlog::logger>("Global", std::make_shared<spdlog::sinks::basic_file_sink_mt>(path->string(), true));
		log->set_level(spdlog::level::info);
		log->flush_on(spdlog::level::info);

		spdlog::set_default_logger(std::move(log));
		spdlog::set_pattern("[%Y-%m-%d %H:%M:%S.%e] [%l] %v");
	}

	void OnMessage(SKSE::MessagingInterface::Message* a_message)
	{
		using namespace SLSFW;
		switch (a_message->type) {
		case SKSE::MessagingInterface::kDataLoaded:
			{
				const bool ok = Forms::Load();
				Papyrus::SetReady(ok);
				if (ok) {
					Scheduler::Add(SteepFall::Tick);
					Scheduler::Add(Papyrus::ReportTick);
					Scheduler::Add(Equip::Tick);
					Scheduler::Add(LostItems::Tick);
					Scheduler::Add(Nudity::Tick);
					Scheduler::Add(Profiler::Tick);
					Scheduler::Add(GuardWatch::Tick);
					Scheduler::Add(Gates::Tick);
					Scheduler::Add(DomGuard::Apply);
					if (Inequality::Load()) {
						Scheduler::Add(Inequality::Tick);
					}
					Swim::Load();
					Scheduler::Add(Swim::Tick);
					Equip::Register();
					Nudity::Register();
					GuardWatch::Register();
					// SKSE\Plugins\SLSurvivalFramework.ini [Guards] BaboGuard=1: no guard search while a
					// BaboDialogue scene owns the player (no-op without BaboDialogue)
					BaboGuard::Configure(GetPrivateProfileIntW(L"Guards", L"BaboGuard", 1,
						(std::filesystem::current_path() / L"Data" / L"SKSE" / L"Plugins" / L"SLSurvivalFramework.ini").c_str()) == 1);
					Scheduler::Start();
				}
			}
			break;
		case SKSE::MessagingInterface::kPreLoadGame:
			// monitors are re-armed by their scripts (OnPlayerLoadGame / Begin) for the save being entered
			Session::OnPreLoad();
			SteepFall::Reset();
			break;
		case SKSE::MessagingInterface::kNewGame:
			Session::OnNewGame();
			Gates::Reset();
			Profiler::Reset();
			LostItems::Reset();
			Nudity::Reset();
			GuardWatch::Reset();
			SteepFall::Reset();
			DomGuard::Reset();
			Swim::Reset();
			Equip::OnGameLoaded();
			Papyrus::ScheduleLoadReport();
			break;
		case SKSE::MessagingInterface::kPostLoadGame:
			// data = success flag; after a failed load the game is back in the main menu with nothing to recompute
			Session::OnPostLoad(static_cast<bool>(a_message->data));
			if (!a_message->data) {
				break;
			}
			Gates::Reset();
			Profiler::Reset();
			LostItems::Reset();
			Nudity::Reset();
			GuardWatch::Reset();
			DomGuard::Reset();
			Swim::Reset();
			Equip::OnGameLoaded();
			Papyrus::ScheduleLoadReport();
			break;
		default:
			break;
		}
	}
}

SKSEPluginLoad(const SKSE::LoadInterface* a_skse)
{
	InitializeLogging();

	const auto* plugin = SKSE::PluginDeclaration::GetSingleton();
	logger::info("{} {} is loading", plugin->GetName(), plugin->GetVersion().string());

	// own logger: keep CommonLib from re-initialising (and truncating) it
	SKSE::Init(a_skse, false);

	if (!SKSE::GetMessagingInterface()->RegisterListener(OnMessage)) {
		SKSE::stl::report_and_fail("Unable to register the SKSE message listener.");
	}
	// diagnostics only, off by default: SKSE\Plugins\SLSurvivalFramework.ini [Debug] Profiler=1 hooks the VM's SendEvent
	const auto ini = std::filesystem::current_path() / L"Data" / L"SKSE" / L"Plugins" / L"SLSurvivalFramework.ini";
	if (GetPrivateProfileIntW(L"Debug", L"Profiler", 0, ini.c_str()) == 1) {
		SLSFW::Profiler::Install();
	} else {
		logger::info("profiler: off");
	}

	if (!SKSE::GetPapyrusInterface()->Register(SLSFW::Papyrus::Register)) {
		SKSE::stl::report_and_fail("Unable to register Papyrus functions.");
	}

	logger::info("{} loaded", plugin->GetName());
	return true;
}
