#include "Session.h"

namespace SLSFW::Session
{
	namespace
	{
		std::atomic_bool g_loading{ false };
	}

	void OnPreLoad() { g_loading = true; }

	void OnNewGame() { g_loading = false; }  // no kPostLoadGame follows a new game; Settled() waits for the cell

	void OnPostLoad(bool a_success)
	{
		g_loading = false;
		if (!a_success) {
			logger::warn("session: the save did not load successfully");
		}
	}

	bool Loading() { return g_loading; }

	bool Settled()
	{
		if (g_loading) {
			return false;
		}
		auto* player = RE::PlayerCharacter::GetSingleton();
		if (!player || !player->Is3DLoaded() || !player->GetParentCell()) {
			return false;
		}
		auto* ui = RE::UI::GetSingleton();
		if (ui && (ui->IsMenuOpen(RE::LoadingMenu::MENU_NAME) || ui->IsMenuOpen(RE::MainMenu::MENU_NAME))) {
			return false;
		}
		return true;
	}
}
