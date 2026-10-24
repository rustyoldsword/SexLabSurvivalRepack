#include "LostItems.h"

#include "Bridge.h"
#include "Forms.h"

namespace SLSFW::LostItems
{
	namespace
	{
		constexpr float kMoveStep = 300.0f;  // units walked before the count is refreshed
		constexpr float kMinGap = 1.0f;      // seconds between refreshes

		std::atomic<std::int32_t> g_spots{ 0 };
		RE::NiPoint3              g_lastPos;
		bool                      g_havePos{ false };
		float                     g_sinceRefresh{ 0.0f };
		std::uint32_t             g_refreshes{ 0 };
		float                     g_loadRefreshIn{ -1.0f };  // one refresh after a load, -1 none pending

		void Refresh()
		{
			if (auto lostFound = Bridge::Find(Forms::Get().lostFound, "_SLS_LostFound")) {
				Bridge::Call(lostFound, "UpdateLostCount");
				++g_refreshes;
			}
		}
	}

	void SetActiveSpots(std::int32_t a_count)
	{
		g_spots = a_count;
	}

	void Reset()
	{
		g_spots = 0;
		g_havePos = false;
		g_loadRefreshIn = 5.0f;  // the saved widget text may be stale; SLS's own scripts settle first
	}

	void Tick(float a_seconds)
	{
		g_sinceRefresh += a_seconds;
		if (g_loadRefreshIn >= 0.0f) {
			g_loadRefreshIn -= a_seconds;
			if (g_loadRefreshIn < 0.0f) {
				Refresh();
			}
		}
		if (g_spots <= 0 || g_sinceRefresh < kMinGap) {
			return;
		}
		auto* player = RE::PlayerCharacter::GetSingleton();
		if (!player || !player->Is3DLoaded()) {
			return;
		}
		const auto pos = player->GetPosition();
		if (!g_havePos) {
			g_lastPos = pos;
			g_havePos = true;
			return;
		}
		if (pos.GetDistance(g_lastPos) < kMoveStep) {
			return;
		}
		g_lastPos = pos;
		g_sinceRefresh = 0.0f;
		Refresh();
	}

	std::string Report()
	{
		return std::format("SLSFW lost items: {} active drop spots, {} refreshes on movement\n", g_spots.load(), g_refreshes);
	}
}
