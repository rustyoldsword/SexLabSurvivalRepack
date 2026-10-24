#pragma once

// "Nearby Lost Items" widget: _SLS_LostFound.UpdateLostCount now counts only drop spots near the player and reports
// how many spots exist; while any do, this re-runs UpdateLostCount once the player has moved far enough.
namespace SLSFW::LostItems
{
	void SetActiveSpots(std::int32_t a_count);  // from Papyrus (VM thread)
	void Reset();                               // new game / load: one refresh once SLS has settled
	void Tick(float a_seconds);                 // main thread
	std::string Report();
}
