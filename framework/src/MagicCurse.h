#pragma once

// The magicka curse (_SLS_MagicLicenceCurse, the tattoo a guard puts on for casting without a magic licence) keeps the
// player's magicka at no more than half of its maximum (owner decision 2026-11-10). A constant-effect magicka value
// modifier cannot do that: on an ability its magnitude is a one-off offset, not a drain per second, so magicka fell
// once and then regenerated to full. The framework caps it instead; the halved regeneration stays the spell's own
// second effect.
namespace SLSFW::MagicCurse
{
	bool Load();                 // kDataLoaded; false = the spell is missing, the module stays off
	void Tick(float a_seconds);  // scheduler, main thread
}
