#include "Scheduler.h"

namespace SLSFW::Scheduler
{
	namespace
	{
		std::vector<Tick>                     g_ticks;  // filled before Start, then read-only
		std::atomic_bool                      g_queued{ false };
		std::chrono::steady_clock::time_point g_last{};

		void RunTicks()
		{
			g_queued = false;
			const auto  now = std::chrono::steady_clock::now();
			const float seconds = g_last == std::chrono::steady_clock::time_point{} ? 0.0f : std::min(1.0f, std::chrono::duration<float>(now - g_last).count());
			g_last = now;
			for (auto& tick : g_ticks) {
				tick(seconds);
			}
		}
	}

	void Add(Tick a_tick)
	{
		g_ticks.push_back(std::move(a_tick));
	}

	void Start()
	{
		static std::once_flag once;
		std::call_once(once, [] {
			std::thread([] {
				for (;;) {
					std::this_thread::sleep_for(100ms);
					if (!g_queued.exchange(true)) {
						SKSE::GetTaskInterface()->AddTask(RunTicks);
					}
				}
			}).detach();
		});
	}
}
