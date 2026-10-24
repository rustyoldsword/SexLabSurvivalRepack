#pragma once

// Advanced Nudity Detection relay. AND broadcasts "AdvancedNudityDetectionUpdate" on every scan pass (each footstep,
// each equip, its timer) - about once a second - and _SLS_LicBikiniCurse woke for every one of them to ask AND ten
// questions and find nothing changed. AND (an SKSE plugin) sends that event straight into Papyrus, so the DLL cannot
// hear it; instead it reads AND's verdict from the player's AND faction ranks twice a second and calls the script
// only when the player's exposure actually changed.
namespace SLSFW::Nudity
{
	void Register();  // kDataLoaded; no-op without Advanced Nudity Detection.esp
	void Reset();     // load / new game: the next check is passed through
	void Tick(float a_seconds);
	std::string Report();
}
