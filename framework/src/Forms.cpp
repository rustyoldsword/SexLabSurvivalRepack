#include "Forms.h"

namespace SLSFW::Forms
{
	namespace
	{
		Set g_set;

		template <class T>
		T* Lookup(RE::FormID a_id, std::string_view a_what, bool& a_ok)
		{
			auto* form = RE::TESDataHandler::GetSingleton()->LookupForm<T>(a_id, kPlugin);
			if (!form) {
				logger::error("{} {:06X}:{} not found", a_what, a_id, kPlugin);
				a_ok = false;
			}
			return form;
		}
	}

	bool Load()
	{
		if (!RE::TESDataHandler::GetSingleton()->LookupModByName(kPlugin)) {
			logger::error("{} is not loaded: the framework stays inactive", kPlugin);
			return false;
		}
		bool ok = true;
		g_set.main = Lookup<RE::TESQuest>(0x000D64, "_SLS_Main", ok);
		g_set.tolledGates = Lookup<RE::TESQuest>(0x009ED6, "_SLS_TolledGates", ok);
		g_set.locTrack = Lookup<RE::TESQuest>(0x0ECBC2, "_SLS_LocationTrackCentralQuest", ok);
		g_set.steepFall = Lookup<RE::TESQuest>(0x116EFF, "_SLS_SteepFallQuest", ok);
		g_set.lostFound = Lookup<RE::TESQuest>(0x12B24F, "_SLS_LostFoundQuest", ok);
		// town order follows _SLS_LocTrackCentral's index: Whiterun, Solitude, Markarth, Windhelm, Riften
		g_set.tollDoors = {
			Lookup<RE::BGSListForm>(0x016EF7, "_SLS_TollDoorsWhiterun", ok),
			Lookup<RE::BGSListForm>(0x016EF6, "_SLS_TollDoorsSolitude", ok),
			Lookup<RE::BGSListForm>(0x016EF5, "_SLS_TollDoorsMarkarth", ok),
			Lookup<RE::BGSListForm>(0x016EF8, "_SLS_TollDoorsWindhelm", ok),
			Lookup<RE::BGSListForm>(0x016EF9, "_SLS_TollDoorsRiften", ok),
		};
		logger::info("SL Survival forms {}", ok ? "resolved" : "INCOMPLETE");
		return ok;
	}

	const Set& Get()
	{
		return g_set;
	}
}
