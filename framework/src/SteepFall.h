#pragma once

// Native replacement for _SLS_SteepFall's 1 s height poll while Forward is held. Calls the script's
// own Trip(true) when the player climbed or dropped more than the allowance within one second;
// everything after the trip (states, perks, stripping, sounds) stays in Papyrus.
namespace SLSFW::SteepFall
{
	void Start(RE::BGSRefAlias* a_alias, float a_fallHeight, float a_crawlAllowance);
	void Stop();
	void Rebase();  // _SLS_SteepFall.RecordHeight
	void Reset();   // before a save loads

	void        Tick(float a_seconds);  // main thread
	std::string Report();
}
