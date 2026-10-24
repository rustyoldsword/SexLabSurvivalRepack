#pragma once

// Event profiler: counts every Papyrus event the VM delivers, per (script type, event), so migration work goes to the
// handlers that really fire in this load order. Hooks IVirtualMachine::SendEvent; the counting is a hash-map increment.
namespace SLSFW::Profiler
{
	void Install();
	void Reset();
	void Tick(float a_seconds);  // writes the report to the log every 5 minutes, so a crash keeps the numbers

	// top a_limit lines; a_filter keeps only script names containing it (case-insensitive), empty = all
	std::string Report(std::uint32_t a_limit, std::string_view a_filter);
}
