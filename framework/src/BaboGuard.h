#pragma once

// BaboDialogue 6.20 owns the player for whole scenes (kidnapping, bad end, riekling capture, its own staged scenes).
// SL Survival's guard searches run on their own timers and would walk a guard into that scene and start a toll or a
// warning on top of it - two mods talking over each other. While Babo is busy the three native guard searches report
// "nobody", which is a state SL Survival handles every day (no guard nearby), so nothing of its own logic changes.
//
// Deliberately narrow (the owner's rule): only while a Babo scene is actually running. Outside that, SL Survival and
// BaboDialogue keep sharing the air through their own MCM percentages - Babo must not drown SLS out.
//
// This module only READS BaboDialogue. The shared _SG_SceneBusy bit 4 stays unused: SL Survival never owns the player
// the way a capture does, so it has no business blocking Babo's events.
namespace SLSFW::BaboGuard
{
	void Configure(bool a_enabled);

	bool Installed();
	const char* BusyReason();  // nullptr when BaboDialogue is free, absent or the guard is off
	bool        Busy();
}
