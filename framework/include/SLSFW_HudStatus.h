#pragma once

// SexLab Survival Framework: the player's SLS state for HUD mods (Vitals HUD).
//
//   auto get = reinterpret_cast<SLSFW_GetHudStatusFn>(GetProcAddress(GetModuleHandleW(L"SLSurvivalFramework.dll"), "SLSFW_GetHudStatus"));
//   SLSFW_HudStatus status{}; status.size = sizeof(status);
//   if (get && get(&status)) { ... }
//
// Call it on the game's main thread (an SKSE task): it reads SLS's Papyrus objects. Returns false while SLS is not
// loaded or the call came too early; fields not filled by an older framework keep the caller's values.
#include <cstdint>

enum SLSFW_Licence : std::uint8_t
{
	SLSFW_LicMagic,
	SLSFW_LicWeapon,
	SLSFW_LicArmor,
	SLSFW_LicBikini,
	SLSFW_LicClothes,
	SLSFW_LicCurfew,
	SLSFW_LicWhore,
	SLSFW_LicFreedom,
	SLSFW_LicProperty,
	SLSFW_LicCount
};

struct SLSFW_HudStatus
{
	std::uint32_t size;  // sizeof(SLSFW_HudStatus), set by the caller

	// licences: -1 not in use (licence system or this licence switched off, or not yet unlocked), 0 none or expired,
	// 1 valid; daysLeft > 0 while valid (game days)
	std::int8_t licence[SLSFW_LicCount];
	float       licenceDaysLeft[SLSFW_LicCount];

	// toll town the player is in: -1 none, 0 Whiterun, 1 Solitude, 2 Markarth, 3 Windhelm, 4 Riften
	std::int8_t town;
	bool        tollEnabled;
	bool        tollPaid;
	bool        insideWalls;
	bool        grounded;  // ordered to stay in town (toll dodge)
	float       tollCost;

	// curfew in the current town: in effect now, and the player is breaking it
	bool  curfewInEffect;
	bool  curfewViolation;
	float curfewBegin;  // hour of day
	float curfewEnd;

	// curses
	bool bikiniCurse;  // licence bikini curse spell on the player
	bool magicCurse;   // magic licence curse (collar or curse spell)

	// orgasm fatigue: level 0..3, count against the daily threshold (count runs up to 20)
	std::int8_t fatigueLevel;
	float       orgasmCount;
	float       orgasmThreshold;

	// 0.7.0: the player carries what a missing licence covers, in a toll town (SLS's gate search rules,
	// _SLS_LicenceUtil.HasAnyContraband, on the player's own inventory): weapons or ammo, armor, enchanted clothing /
	// staves / spell tomes / scrolls, clothes. Only for licences in use and not valid.
	bool licenceViolation[SLSFW_LicCount];
};

using SLSFW_GetHudStatusFn = bool (*)(SLSFW_HudStatus*);

// ---- SL Survival messages ---------------------------------------------------------------------------------------------
//
// SL Survival talks to the player through Debug.Notification, which drowns in the vanilla notification waterfall. A
// HUD that shows them itself calls SLSFW_ClaimMessages() once (kDataLoaded or later); from then on notifications from
// SLS scripts (_SLS_* / SLS_*) are no longer shown by the game but queued here, every other mod's stay in the
// waterfall. Without a claim nothing changes. SLSFW_GetMessages copies the messages newer than a_afterId (oldest
// first) and returns how many; any thread.
struct SLSFW_Message
{
	std::uint32_t id;         // increasing, never 0
	char          text[248];  // UTF-8, truncated
};

using SLSFW_ClaimMessagesFn = bool (*)();
using SLSFW_GetMessagesFn = std::uint32_t (*)(SLSFW_Message* a_out, std::uint32_t a_max, std::uint32_t a_afterId);
// 0.7.3: a native mod hands a line to the same panel; false = no HUD claimed the messages, show it yourself
using SLSFW_PushMessageFn = bool (*)(const char* a_text);
