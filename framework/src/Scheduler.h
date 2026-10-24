#pragma once

// One background clock that queues a single main-thread tick every 100 ms. Each tick runs every
// registered monitor with the real seconds since the previous tick; nothing re-queues itself.
namespace SLSFW::Scheduler
{
	using Tick = std::function<void(float a_seconds)>;

	void Add(Tick a_tick);
	void Start();
}
