#pragma once

// Guard searches. SLS found a guard by restarting a search quest (Stop/Start) every 1.5-3 s and reading its aliases.
// - AliasHasMatch runs that alias's own ESP conditions over the loaded actors; when none passes, the restart would
//   only fill an empty alias, so the script skips it (guard warnings).
// - FindSpottingGuard / FindDetectingGuards do the whole toll-dodge search natively: the closest actors passing the
//   search alias's conditions (one per alias, as the quest would fill them), then the script's own detection test.
// All run on the main thread (Papyrus natives).
namespace SLSFW::GuardWatch
{
	bool                    AliasHasMatch(RE::TESQuest* a_quest, std::int32_t a_aliasId);
	RE::Actor*              FindSpottingGuard(RE::TESQuest* a_quest);    // detects the player and has line of sight
	std::vector<RE::Actor*> FindDetectingGuards(RE::TESQuest* a_quest);  // detect the player
	void                    Register();             // kDataLoaded
	void                    Tick(float a_seconds);  // main thread: stuck guard-warning watchdog
	void                    Reset();
	std::string             Report();
}
