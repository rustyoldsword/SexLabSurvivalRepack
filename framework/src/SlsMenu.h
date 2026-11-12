#pragma once

// SL Survival's settings in SKSE Menu Framework (3.0.2, stage 2 of the 2026-10-31 audit).
//
// The SkyUI MCM froze because every page reads other SLS scripts that are often busy. This menu never calls Papyrus
// while it is open: it draws from a snapshot of the setting variables read natively on the main thread, and remembers
// what the player changed. When the menu closes, each change goes through the MCM's own SkyUI handler
// (sls_mcm.SLSFW_ApplyOption), so every setting keeps exactly the side effects the MCM gives it. The option table is
// generated from sls_mcm.psc (work\SLS_SkseMenu\gen_menu.py -> SKSE\Plugins\SLSurvivalFramework\Menu.json).
namespace SLSFW::SlsMenu
{
	void Load();                 // kDataLoaded: read Menu.json and register the SMF section
	void Tick(float a_seconds);  // scheduler (main thread): snapshot while open, apply after close, replay on a new game
	bool Active();               // the menu loaded (SKSE Menu Framework present, Menu.json valid): the MCM hides itself

	// 0.9.3: every option the player sets here is remembered in SKSE\Plugins\SLSurvivalFramework\UserSettings.json,
	// one list per player sex. SL Survival keeps its settings in the save only, so a new game started with the stock
	// defaults and Snowberry Start - which must be set inside the start cell - was lost every time. On a new game the
	// remembered list for the chosen sex is applied once, right after RaceMenu closes, through the same MCM handlers.
	void OnNewGame();  // kNewGame: replay after the next RaceMenu close
	void OnLoaded();   // kPostLoadGame: a loaded save keeps its own settings
}
