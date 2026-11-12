#include "BaboGuard.h"
#include "Bridge.h"
#include "DomGuard.h"
#include "Equip.h"
#include "Forms.h"
#include "Gates.h"
#include "Inequality.h"
#include "MagicCurse.h"
#include "GuardWatch.h"
#include "LostItems.h"
#include "Nudity.h"
#include "Papyrus.h"
#include "Profiler.h"
#include "Scheduler.h"
#include "Session.h"
#include "SlsMenu.h"
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

	// 3.0.2: _SLS_LocTrackCentral reports town changes as mod events instead of calling _SLS_Curfew and
	// _SLS_LicTownCheck while it holds its own lock. Saves from before that never registered those events, so ask the
	// two scripts to register on every load - dispatched from here, so no SLS script waits for another's lock.
	void RegisterLocationEvents()
	{
		using namespace SLSFW;
		auto* data = RE::TESDataHandler::GetSingleton();
		auto* curfew = data ? data->LookupForm<RE::TESQuest>(0x0E3F3D, Forms::kPlugin) : nullptr;     // _SLS_CurfewQuest
		auto* townCheck = data ? data->LookupForm<RE::TESQuest>(0x058C8E, Forms::kPlugin) : nullptr;  // _SLS_LicTownCheckQuest
		const bool a = Bridge::Call(Bridge::Find(curfew, "_SLS_Curfew"), "EnsureLocEvent");
		const bool b = Bridge::Call(Bridge::Find(townCheck, "_SLS_LicTownCheck"), "RegisterForLocEvents");
		logger::info("location events: curfew {}, town check {}", a ? "asked" : "not found", b ? "asked" : "not found");
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
					if (MagicCurse::Load()) {
						Scheduler::Add(MagicCurse::Tick);
					}
					Swim::Load();
					Scheduler::Add(Swim::Tick);
					SlsMenu::Load();
					Scheduler::Add(SlsMenu::Tick);
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
			SlsMenu::OnNewGame();
			Gates::Reset();
			Profiler::Reset();
			Inequality::Reset();
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
			SlsMenu::OnLoaded();
			Gates::Reset();
			Profiler::Reset();
			Inequality::Reset();
			LostItems::Reset();
			Nudity::Reset();
			GuardWatch::Reset();
			DomGuard::Reset();
			Swim::Reset();
			Equip::OnGameLoaded();
			Papyrus::ScheduleLoadReport();
			RegisterLocationEvents();
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
