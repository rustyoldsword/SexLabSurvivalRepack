#include "Profiler.h"

namespace SLSFW::Profiler
{
	namespace
	{
		// BSFixedString data pointers are interned, so (type name, event name) pointers identify the pair
		struct Key
		{
			const char* script;
			const char* event;
			bool        operator==(const Key&) const = default;
		};

		struct KeyHash
		{
			std::size_t operator()(const Key& a_key) const noexcept
			{
				return std::hash<const void*>{}(a_key.script) ^ (std::hash<const void*>{}(a_key.event) * 31);
			}
		};

		std::mutex                                       g_lock;
		std::unordered_map<Key, std::uint64_t, KeyHash> g_counts;
		std::unordered_map<const char*, std::uint64_t>   g_events;  // sends per event name, scripted or not
		std::chrono::steady_clock::time_point            g_since{ std::chrono::steady_clock::now() };

		using SendEvent_t = void(RE::BSScript::Internal::VirtualMachine*, RE::VMHandle, const RE::BSFixedString&, RE::BSScript::IFunctionArguments*);
		REL::Relocation<SendEvent_t> g_original;
		bool                         g_installed{ false };

		void Count(RE::BSScript::Internal::VirtualMachine* a_vm, RE::VMHandle a_handle, const RE::BSFixedString& a_event)
		{
			const char* event = a_event.data();
			if (!event || !*event) {
				return;
			}
			std::vector<const char*> scripts;
			{
				RE::BSSpinLockGuard guard(a_vm->attachedScriptsLock);
				if (const auto it = a_vm->attachedScripts.find(a_handle); it != a_vm->attachedScripts.end()) {
					for (auto& attached : it->second) {
						const auto* object = attached.get();
						const auto* type = object ? object->GetTypeInfo() : nullptr;
						if (const char* name = type ? type->GetName() : nullptr; name && *name) {
							scripts.push_back(name);
						}
					}
				}
			}
			std::scoped_lock lock(g_lock);
			++g_events[event];
			for (const auto* name : scripts) {
				++g_counts[{ name, event }];
			}
		}

		void SendEventHook(RE::BSScript::Internal::VirtualMachine* a_vm, RE::VMHandle a_handle, const RE::BSFixedString& a_event, RE::BSScript::IFunctionArguments* a_args)
		{
			Count(a_vm, a_handle, a_event);
			g_original(a_vm, a_handle, a_event, a_args);
		}

		std::string Lower(std::string_view a_text)
		{
			std::string out(a_text);
			std::ranges::transform(out, out.begin(), [](unsigned char c) { return static_cast<char>(std::tolower(c)); });
			return out;
		}
	}

	void Install()
	{
		REL::Relocation<std::uintptr_t> vtbl{ RE::VTABLE_BSScript__Internal__VirtualMachine[0] };
		g_original = vtbl.write_vfunc(0x24, SendEventHook);
		g_installed = true;
		logger::info("profiler: VirtualMachine::SendEvent hooked");
	}

	void Reset()
	{
		std::scoped_lock lock(g_lock);
		g_counts.clear();
		g_events.clear();
		g_since = std::chrono::steady_clock::now();
	}

	void Tick(float a_seconds)
	{
		if (!g_installed) {
			return;
		}
		static float sinceDump = 0.0f;
		sinceDump += a_seconds;
		if (sinceDump >= 300.0f) {
			sinceDump = 0.0f;
			logger::info("periodic {}", Report(80, ""));
		}
	}

	std::string Report(std::uint32_t a_limit, std::string_view a_filter)
	{
		if (!g_installed) {
			return "SLSFW profile: off (SLSurvivalFramework.ini [Debug] Profiler=1 to enable)\n";
		}
		std::vector<std::pair<Key, std::uint64_t>> rows;
		std::vector<std::pair<const char*, std::uint64_t>> events;
		double minutes = 0.0;
		{
			std::scoped_lock lock(g_lock);
			rows.assign(g_counts.begin(), g_counts.end());
			events.assign(g_events.begin(), g_events.end());
			minutes = std::chrono::duration<double>(std::chrono::steady_clock::now() - g_since).count() / 60.0;
		}
		const auto filter = Lower(a_filter);
		if (!filter.empty()) {
			std::erase_if(rows, [&](const auto& r) { return Lower(r.first.script).find(filter) == std::string::npos; });
		}
		std::ranges::sort(rows, std::greater{}, &std::pair<Key, std::uint64_t>::second);
		std::ranges::sort(events, std::greater{}, &std::pair<const char*, std::uint64_t>::second);

		std::uint64_t total = 0;
		for (const auto& r : rows) {
			total += r.second;
		}
		std::string out = std::format("SLSFW profile: {:.1f} min, {} deliveries{} ({} pairs)\n", minutes, total,
			filter.empty() ? "" : std::format(" to *{}*", filter), rows.size());
		for (std::uint32_t i = 0; i < rows.size() && i < a_limit; ++i) {
			out += std::format("  {:>8} {:>8.1f}/min  {}.{}\n", rows[i].second, minutes > 0 ? rows[i].second / minutes : 0.0,
				rows[i].first.script, rows[i].first.event);
		}
		out += "events sent (all handles):\n";
		for (std::uint32_t i = 0; i < events.size() && i < 25; ++i) {
			out += std::format("  {:>8}  {}\n", events[i].second, events[i].first);
		}
		return out;
	}
}
