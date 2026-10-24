#pragma once

struct SLSFW_Message;

// SL Survival's notifications routed to a HUD instead of the vanilla waterfall (once a HUD claims them).
namespace SLSFW::Messages
{
	void          Register(RE::BSScript::IVirtualMachine* a_vm);  // re-registers Debug.Notification
	bool          Claim();
	bool          Claimed();
	void          PushText(std::string_view a_text);  // a native mod's line (SLSFW_PushMessage)
	std::uint32_t Get(SLSFW_Message* a_out, std::uint32_t a_max, std::uint32_t a_afterId);
	std::string   Report();
}
