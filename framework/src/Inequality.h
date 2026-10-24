#pragma once

// SLS gender inequality for the player without the red bars. SLS lowers a woman's health, magicka and stamina with
// magic effects of _SLS_InequalitySpell; the HUD draws any effect-lowered value as a red, "drained" bar, so the heroine
// looked ill all game. SL Survival - Revision Tweaks.esp keeps those two effects off the player (GetIsReference
// Player == 0) and this module lowers her maximum instead, with a permanent modifier (ModActorValue): the bar is
// just shorter. Same inputs as the spell: _SLS_IneqStat on, female, not in the strong female faction; the size is
// the spell's own effect magnitude, so the MCM sliders still drive it. Health keeps SLS's cushion. The amounts in
// place live in two globals of the patch, which travel with the save.
namespace SLSFW::Inequality
{
	bool Load();               // kDataLoaded; false = the patch plugin is missing, the module stays off
	void Tick(float a_seconds);  // scheduler, main thread
	void Suspend(bool a_suspend);  // SLSFW.InequalitySuspend: true takes everything off and keeps it off
	std::string Report();
}
