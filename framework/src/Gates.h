#pragma once

// Gates v1: one town's gates always change together (SLS-001), and a readable cross-check of what the
// doors are against what SLS believes.
// Gates v2: SLS decided a gate's lock when the door's cell attached, after Utility.Wait(1.0) "for LocTrackCentral to
// update IsTollPaid" - a race between two Papyrus events. The DLL now watches the inputs of that decision (toll paid,
// inside the walls, town index, lockdown and toll options, confinement) and, once they have been quiet for half a
// second after any change or door attach, runs SLS's own decision once (_SLS_TollUtil.FrameworkRecheckGates).
// The rules themselves stay in _SLS_TollUtil.OnTollDoorAttach.
namespace SLSFW::Gates
{
	// the town index (0..4) whose _SLS_TollDoors list holds this door, -1 when it is not a toll door
	std::int32_t TownOf(const RE::TESObjectREFR* a_door);

	// locks or unlocks every door of the door's town through vanilla ObjectReference.Lock (SLSFW._LockDoor),
	// so doors close, OnLockStateChanged fires and the lock is saved. Returns the number of doors queued.
	std::int32_t SetTownLocked(const RE::TESObjectREFR* a_door, bool a_lock, std::int32_t a_lockLevel);

	void Changed(std::string_view a_reason);  // a toll door attached or SLS asked for a recheck
	void Tick(float a_seconds);               // main thread
	void Reset();

	// Gates v3: hold the recheck while the SLS MCM is writing a batch of settings (the gender gate, an open MCM
	// session). FrameworkRecheckGates takes _SLS_TollUtil and then reads SLS_Init / SLS_Mcm, while an MCM pass holds
	// SLS_Init / SLS_Mcm and then calls _SLS_TollUtil - opposite lock order. On 2026-10-15 the two met at a load: the
	// gender gate stopped after two of five towns and every SLS script (the MCM page included) hung for good. Holds
	// nest; one recheck runs when the last one is released.
	void Hold(bool a_hold);
	bool Held();

	std::string Report();
}
