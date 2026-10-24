#pragma once

// Stage 2: one TESEquipEvent sink for the player instead of 17 SLS alias scripts that each received every
// OnObjectEquipped / OnObjectUnequipped. Each subscriber gets a call to its own SLSFW_Equipped /
// SLSFW_Unequipped function only when the item is one it acts on, in the Papyrus state it acts in.
// Init.PlayerIsHardGagged (a dialogue condition) is kept in sync natively.
namespace SLSFW::Equip
{
	void Register();            // kDataLoaded
	void Tick(float a_seconds);  // main thread: delayed re-checks after an equip
	void OnGameLoaded();         // recompute derived state for the save just entered
	std::string Report();
}
