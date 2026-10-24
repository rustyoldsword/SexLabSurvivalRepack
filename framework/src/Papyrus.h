#pragma once

namespace SLSFW::Papyrus
{
	inline constexpr auto kClass = "SLSFW"sv;
	inline constexpr std::int32_t kApiVersion = 1;

	void SetReady(bool a_ready);

	// every module's state as text; main thread or VM thread (reads Papyrus variables)
	std::string BuildReport();

	// writes BuildReport() to the log a few seconds after a save or a new game has loaded
	void ScheduleLoadReport();
	void ReportTick(float a_seconds);
	bool Register(RE::BSScript::IVirtualMachine* a_vm);
}
