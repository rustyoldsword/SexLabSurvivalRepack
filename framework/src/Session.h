#pragma once

// Where the game is in its lifecycle. Every scheduler tick and event sink that touches SLS's quest aliases or Papyrus
// objects asks Settled() first: during a save load or the start of a new game the engine rebuilds quests, aliases and
// the VM (the player has no parent cell yet), and a BGSBaseAlias* seen a moment earlier can already be freed
// (CRASH-004, 2026-10-10/11: Equip::Tick -> Bridge::Find(alias) on the first tick after kPostLoadGame).
namespace SLSFW::Session
{
	void OnPreLoad();       // kPreLoadGame: a save is being read
	void OnNewGame();       // kNewGame
	void OnPostLoad(bool a_success);  // kPostLoadGame

	bool Loading();  // between kPreLoadGame and kPostLoadGame
	// not loading, the player exists, has 3D and a parent cell, and no loading screen / main menu is open
	bool Settled();
}
