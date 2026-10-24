#pragma once

namespace SLSFW::Util
{
	// a full-screen game menu is open. UI::GameIsPaused() cannot be used on this setup: with Skyrim Souls RE
	// and always-open menus (SkyParkour, TrueHUD) the pause counter never returns to zero (Vitals HUD, 2026-10-04)
	inline bool GameMenuOpen()
	{
		auto* ui = RE::UI::GetSingleton();
		if (!ui) {
			return false;
		}
		static const std::array<std::string_view, 23> kMenus{
			RE::InventoryMenu::MENU_NAME, RE::MagicMenu::MENU_NAME, RE::MapMenu::MENU_NAME, RE::JournalMenu::MENU_NAME,
			RE::TweenMenu::MENU_NAME, RE::ContainerMenu::MENU_NAME, RE::BarterMenu::MENU_NAME, RE::GiftMenu::MENU_NAME,
			RE::CraftingMenu::MENU_NAME, RE::LockpickingMenu::MENU_NAME, RE::BookMenu::MENU_NAME, RE::StatsMenu::MENU_NAME,
			RE::LevelUpMenu::MENU_NAME, RE::TrainingMenu::MENU_NAME, RE::SleepWaitMenu::MENU_NAME, RE::RaceSexMenu::MENU_NAME,
			RE::LoadingMenu::MENU_NAME, RE::MainMenu::MENU_NAME, RE::FavoritesMenu::MENU_NAME, RE::MessageBoxMenu::MENU_NAME,
			RE::Console::MENU_NAME, RE::TutorialMenu::MENU_NAME, RE::DialogueMenu::MENU_NAME
		};
		return std::any_of(kMenus.begin(), kMenus.end(), [&](std::string_view a_name) { return ui->IsMenuOpen(a_name); });
	}
}
