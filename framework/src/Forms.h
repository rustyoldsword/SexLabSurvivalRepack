#pragma once

// SL Survival.esp forms the framework works with, resolved once at kDataLoaded.
namespace SLSFW::Forms
{
	inline constexpr auto kPlugin = "SL Survival.esp"sv;

	struct Set
	{
		RE::TESQuest* main{ nullptr };        // _SLS_Main 000D64: SLS_Init, SLS_Mcm, SLS_Utility
		RE::TESQuest* tolledGates{ nullptr };  // _SLS_TolledGates 009ED6: _SLS_TollUtil
		RE::TESQuest* locTrack{ nullptr };     // _SLS_LocationTrackCentralQuest 0ECBC2
		RE::TESQuest* steepFall{ nullptr };    // _SLS_SteepFallQuest 116EFF
		RE::TESQuest* lostFound{ nullptr };    // _SLS_LostFoundQuest 12B24F: _SLS_LostFound

		// _SLS_TollDoors<Town> 016EF5..016EF9, in SLS's town index order (0 Whiterun .. 4 Riften)
		std::array<RE::BGSListForm*, 5> tollDoors{};
	};

	inline constexpr std::array<std::string_view, 5> kTownNames{ "Whiterun", "Solitude", "Markarth", "Windhelm", "Riften" };

	bool       Load();  // false: SL Survival.esp missing or a form is gone
	const Set& Get();
}
