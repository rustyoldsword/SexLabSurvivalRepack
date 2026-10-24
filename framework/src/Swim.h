#pragma once

// Frostfall's swim events without Frostfall. SLS hangs two things on Frostfall_OnPlayerStartSwimming /
// StopSwimming: drowning in heavy bondage (_SLS_DeviousEffects) and, with the integration patch, the small chance
// that swimming ruins a licence (_SLS_InterfaceFrostfall, Local state). Without Frostfall nobody sent them; this module
// sends them on the player's swim state changes. With Frostfall installed it stays quiet (Frostfall sends its own).
//
// Sinking in bondage (0.8.0): a heroine whose arms are out of use (DD heavy bondage or pet suit, ZaZ wrist ties,
// both hands gone with Amputator) cannot swim. The same hook Underwater NG uses for armor buoyancy
// (PlayerCharacter::ModifyMovementData, vfunc 0x11A: the frame's movement vector) slows her strokes, cancels upward
// swimming and adds a steady downward drift, so she sinks to the bottom and SLS's drowning takes over.
// Underwater NG installs its own hook on the same vfunc and calls ours inside it, so its armor buoyancy adds to this
// one instead of replacing it. With Sink Or Swim (SinkOrSwim.esp) installed the bondage sink stays off: that mod owns
// swimming movement, as Underwater NG also assumes.
// SKSE\Plugins\SLSurvivalFramework.ini [Swim]: bSinkWhenBound=1, fBoundSinkSpeed=0.9 (metres per second),
// fBoundStrokeMult=0.35 (forward/sideways swimming), fBoundAscentMult=0 (swimming upward).
namespace SLSFW::Swim
{
	void Load();               // kDataLoaded
	void Reset();              // new game / save loaded: re-send the current state on the next tick
	void Tick(float a_seconds);  // scheduler, main thread
	std::string Report();
}
