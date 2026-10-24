// SL Survival's notifications for a HUD (see include\SLSFW_HudStatus.h). Debug.Notification is re-registered: a call
// from an SLS script goes to the queue once a HUD has claimed it, everything else reaches the game as before.
#include "Messages.h"

#include "SLSFW_HudStatus.h"

namespace SLSFW::Messages
{
	namespace
	{
		constexpr std::size_t kKeep = 64;

		struct Entry
		{
			std::uint32_t id;
			std::string   text;
		};

		std::mutex        g_lock;
		std::deque<Entry> g_queue;
		std::uint32_t     g_nextId{ 1 };
		std::atomic_bool  g_claimed{ false };
		std::atomic<std::uint32_t> g_routed{ 0 };

		void Push(std::string_view a_text)
		{
			std::scoped_lock lock(g_lock);
			g_queue.push_back({ g_nextId++, std::string(a_text) });
			while (g_queue.size() > kKeep) {
				g_queue.pop_front();
			}
			++g_routed;
		}

		bool IsSlsScript(std::string_view a_name)
		{
			const auto starts = [&](std::string_view a_prefix) {
				return a_name.size() >= a_prefix.size() &&
				       std::equal(a_prefix.begin(), a_prefix.end(), a_name.begin(), [](char a, char b) { return std::tolower(static_cast<unsigned char>(a)) == std::tolower(static_cast<unsigned char>(b)); });
			};
			// Diary of Mine (DOM_*, DOM* effects, its pahcore) shares the panel since 0.7.3
			return starts("_SLS_") || starts("SLS_") || starts("SLSFW") || starts("DOM") || starts("pahcore");
		}

		// the script that called Debug.Notification: the first frame on the stack that is not Debug's own
		std::string Caller(RE::BSScript::Internal::VirtualMachine* a_vm, RE::VMStackID a_stackID)
		{
			if (!a_vm) {
				return {};
			}
			RE::BSSpinLockGuard locker(a_vm->runningStacksLock);
			const auto          it = a_vm->allRunningStacks.find(a_stackID);
			if (it == a_vm->allRunningStacks.end() || !it->second) {
				return {};
			}
			for (auto* frame = it->second->top; frame; frame = frame->previousFrame) {
				const char* name = frame->owningObjectType ? frame->owningObjectType->GetName() : nullptr;
				if (name && _stricmp(name, "Debug") != 0) {
					return name;
				}
			}
			return {};
		}

		void Notification(RE::BSScript::Internal::VirtualMachine* a_vm, RE::VMStackID a_stackID, RE::StaticFunctionTag*, RE::BSFixedString a_text)
		{
			if (!a_text.c_str() || !*a_text.c_str()) {
				return;
			}
			if (g_claimed && IsSlsScript(Caller(a_vm, a_stackID))) {
				Push(a_text.c_str());
				return;
			}
			RE::SendHUDMessage::ShowHUDMessage(a_text.c_str());  // what Debug.Notification does
		}
	}

	void Register(RE::BSScript::IVirtualMachine* a_vm)
	{
		a_vm->RegisterFunction("Notification", "Debug", Notification, true);
	}

	std::string Report()
	{
		return std::format("SLSFW messages: {}, {} routed to the HUD since start\n", g_claimed ? "claimed by a HUD" : "not claimed (game notifications)", g_routed.load());
	}

	bool Claimed() { return g_claimed; }

	void PushText(std::string_view a_text) { Push(a_text); }

	bool Claim()
	{
		if (!g_claimed.exchange(true)) {
			logger::info("messages: a HUD shows SL Survival's notifications from now on");
		}
		return true;
	}

	std::uint32_t Get(SLSFW_Message* a_out, std::uint32_t a_max, std::uint32_t a_afterId)
	{
		if (!a_out || a_max == 0) {
			return 0;
		}
		std::scoped_lock lock(g_lock);
		std::uint32_t    count = 0;
		for (const auto& entry : g_queue) {
			if (entry.id <= a_afterId) {
				continue;
			}
			auto& out = a_out[count];
			out.id = entry.id;
			const auto length = std::min(entry.text.size(), sizeof(out.text) - 1);
			std::memcpy(out.text, entry.text.data(), length);
			out.text[length] = '\0';
			if (++count == a_max) {
				break;
			}
		}
		return count;
	}
}

extern "C" __declspec(dllexport) bool SLSFW_ClaimMessages()
{
	return SLSFW::Messages::Claim();
}

// for other native mods (Diary Of Mine Framework): false = no HUD claimed the messages, show it yourself
extern "C" __declspec(dllexport) bool SLSFW_PushMessage(const char* a_text)
{
	if (!SLSFW::Messages::Claimed() || !a_text || !*a_text) {
		return false;
	}
	SLSFW::Messages::PushText(a_text);
	return true;
}

extern "C" __declspec(dllexport) std::uint32_t SLSFW_GetMessages(SLSFW_Message* a_out, std::uint32_t a_max, std::uint32_t a_afterId)
{
	return SLSFW::Messages::Get(a_out, a_max, a_afterId);
}
