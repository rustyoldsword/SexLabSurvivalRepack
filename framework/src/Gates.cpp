#include "Gates.h"

#include "Bridge.h"
#include "Forms.h"
#include "Session.h"

namespace SLSFW::Gates
{
	namespace
	{
		std::vector<RE::TESObjectREFR*> Doors(const RE::BGSListForm* a_list)
		{
			std::vector<RE::TESObjectREFR*> doors;
			if (!a_list) {
				return doors;
			}
			// covers the CK entries and the ones SLS adds at runtime (JK's Skyrim Riften doors)
			a_list->ForEachForm([&](RE::TESForm* a_form) {
				if (auto* ref = a_form ? a_form->As<RE::TESObjectREFR>() : nullptr) {
					doors.push_back(ref);
				}
				return RE::BSContainer::ForEachResult::kContinue;
			});
			return doors;
		}

		// gates v2 (main thread)
		constexpr float kQuietSeconds = 0.5f;
		bool            g_dirty{ false };
		float           g_quiet{ 0.0f };
		std::string     g_inputs;
		bool            g_seedInputs{ true };  // after a load: take the first reading as the baseline, not as a change
		std::string     g_reason;
		std::string     g_lastReason;
		std::uint32_t   g_rechecks{ 0 };

		// gates v3 (Hold): taken from the VM thread, read by the tick on the main thread. The tick owns the
		// non-atomic state above (g_reason is a std::string), so a release only raises a flag here.
		std::atomic_int32_t g_holds{ 0 };
		std::atomic_bool    g_released{ false };
		float               g_heldFor{ 0.0f };
		// the SLS MCM can stay open for minutes; this is only the last resort for a pass that dies mid-way
		constexpr float kHoldLimit = 300.0f;

		std::string Opt(const std::optional<bool>& a_value)
		{
			return a_value ? (*a_value ? "true" : "false") : "?";
		}
	}

	std::int32_t TownOf(const RE::TESObjectREFR* a_door)
	{
		if (!a_door) {
			return -1;
		}
		const auto& lists = Forms::Get().tollDoors;
		for (std::size_t i = 0; i < lists.size(); ++i) {
			if (lists[i] && lists[i]->HasForm(a_door)) {
				return static_cast<std::int32_t>(i);
			}
		}
		return -1;
	}

	std::int32_t SetTownLocked(const RE::TESObjectREFR* a_door, bool a_lock, std::int32_t a_lockLevel)
	{
		const auto town = TownOf(a_door);
		if (town < 0) {
			logger::warn("SetTownLocked: {:08X} is not a toll door", a_door ? a_door->GetFormID() : 0);
			return 0;
		}
		std::int32_t queued = 0;
		for (auto* door : Doors(Forms::Get().tollDoors[static_cast<std::size_t>(town)])) {
			if (Bridge::CallStatic("SLSFW", "_LockDoor", static_cast<RE::TESObjectREFR*>(door), a_lock, a_lockLevel)) {
				++queued;
			}
		}
		logger::info("{} gates {}: {} doors", Forms::kTownNames[static_cast<std::size_t>(town)], a_lock ? "locked" : "unlocked", queued);
		return queued;
	}

	// what OnTollDoorAttach decides from; any change means the gates may have to follow
	std::string Inputs()
	{
		const auto& forms = Forms::Get();
		const auto  init = Bridge::Find(forms.main, "SLS_Init");
		const auto  menu = Bridge::Find(forms.main, "SLS_Mcm");
		const auto  loc = Bridge::Find(forms.locTrack, "_SLS_LocTrackCentral");
		const auto  grounded = RE::TESDataHandler::GetSingleton()->LookupForm<RE::TESGlobal>(0x08E819, Forms::kPlugin);  // _SLS_IsGrounded
		return std::format("paid={} inside={} toll={} lockdown={} town={} grounded={}", Opt(Bridge::GetBool(init, "IsTollPaid")),
			Opt(Bridge::GetBool(init, "IsPlayerInside")), Opt(Bridge::GetBool(init, "TollEnable")), Opt(Bridge::GetBool(menu, "DoorLockDownT")),
			Bridge::GetInt(loc, "PlayerCurrentLocIndex").value_or(-2), grounded ? grounded->value : -1.0f);
	}

	void Changed(std::string_view a_reason)
	{
		g_dirty = true;
		g_quiet = 0.0f;
		g_reason = a_reason;
	}

	void Hold(bool a_hold)
	{
		if (a_hold) {
			if (g_holds++ == 0) {
				g_heldFor = 0.0f;
				logger::info("gates: recheck held while the MCM writes its settings");
			}
			return;
		}
		if (g_holds <= 0) {
			return;  // never held, or the limit below already let go
		}
		if (--g_holds > 0) {
			return;
		}
		// the batch moved the very variables the recheck reads: the tick takes them as the new baseline and runs
		// SLS's own decision exactly once, instead of once per changed option
		g_released = true;
		logger::info("gates: recheck released");
	}

	bool Held() { return g_holds > 0; }

	void Tick(float a_seconds)
	{
		if (!Session::Settled()) {
			return;
		}
		if (g_holds > 0) {
			g_heldFor += a_seconds;
			if (g_heldFor < kHoldLimit) {
				return;
			}
			logger::warn("gates: the MCM has held the recheck for {:.0f}s - letting go", g_heldFor);
			g_holds = 0;
			g_released = true;
		}
		if (g_released.exchange(false)) {
			g_heldFor = 0.0f;
			g_seedInputs = true;  // the MCM wrote the inputs: re-baseline them instead of reacting per option
			Changed("the MCM finished writing");
		}
		static float sinceRead = 0.0f;  // the inputs are Papyrus variables: read them a few times a second
		sinceRead += a_seconds;
		if (sinceRead >= 0.25f) {
			sinceRead = 0.0f;
			if (g_seedInputs) {
				// right after a load SLS's own PlayerLoadsGame has not run yet; comparing against an empty baseline fired
				// a recheck with stale IsTollPaid (gates locked for a few seconds until the second recheck)
				g_inputs = Inputs();
				g_seedInputs = false;
			} else if (auto inputs = Inputs(); inputs != g_inputs) {
				g_inputs = std::move(inputs);
				Changed(g_inputs);
			}
		}
		if (!g_dirty) {
			return;
		}
		g_quiet += a_seconds;
		if (g_quiet < kQuietSeconds) {
			return;
		}
		g_dirty = false;
		if (Bridge::Call(Bridge::Find(Forms::Get().tolledGates, "_SLS_TollUtil"), "FrameworkRecheckGates")) {
			++g_rechecks;
			g_lastReason = g_reason;
			logger::info("gates: recheck ({})", g_reason);
		}
	}

	void Reset()
	{
		g_dirty = false;
		g_quiet = 0.0f;
		g_inputs.clear();
		g_seedInputs = true;
		g_holds = 0;  // a save taken while the MCM held the recheck must not hold it in the next session
		g_released = false;
		g_heldFor = 0.0f;
	}

	std::string Report()
	{
		const auto& forms = Forms::Get();
		const auto  init = Bridge::Find(forms.main, "SLS_Init");
		const auto  menu = Bridge::Find(forms.main, "SLS_Mcm");
		const auto  toll = Bridge::Find(forms.tolledGates, "_SLS_TollUtil");
		const auto  loc = Bridge::Find(forms.locTrack, "_SLS_LocTrackCentral");

		std::string out = std::format("SLSFW gates (v3: {} rechecks, last: {}{}{})\n", g_rechecks, g_lastReason.empty() ? "-" : g_lastReason,
			g_dirty ? ", one pending" : "", g_holds > 0 ? std::format(", held by the MCM for {:.0f}s", g_heldFor) : "");
		out += std::format("  TollEnable={} DoorLockDownT={} IsTollPaid={} IsPlayerInside={} ResidentsDontPayTolls={}\n",
			Opt(Bridge::GetBool(init, "TollEnable")), Opt(Bridge::GetBool(menu, "DoorLockDownT")), Opt(Bridge::GetBool(init, "IsTollPaid")),
			Opt(Bridge::GetBool(init, "IsPlayerInside")), Opt(Bridge::GetBool(loc, "ResidentsDontPayTolls")));
		const auto index = Bridge::GetInt(loc, "PlayerCurrentLocIndex");
		out += std::format("  PlayerCurrentLocIndex={}\n", index ? std::to_string(*index) : "?");

		const auto now = RE::Calendar::GetSingleton() ? RE::Calendar::GetSingleton()->GetCurrentGameTime() : 0.0f;
		for (std::size_t t = 0; t < forms.tollDoors.size(); ++t) {
			const auto grounded = Bridge::GetFloat(toll, std::format("GroundedUntil{}", Forms::kTownNames[t]));
			std::string line = std::format("  {}: grounded={}", Forms::kTownNames[t], grounded ? (*grounded > now ? "yes" : "no") : "?");
			std::int32_t locked = 0, total = 0;
			for (auto* door : Doors(forms.tollDoors[t])) {
				++total;
				const bool isLocked = door->IsLocked();
				locked += isLocked ? 1 : 0;
				line += std::format(" [{:08X} {}{}]", door->GetFormID(), isLocked ? "locked" : "open", door->Is3DLoaded() ? "" : " unloaded");
			}
			line += (locked != 0 && locked != total) ? "  MIXED\n" : "\n";
			out += line;
		}
		return out;
	}
}
