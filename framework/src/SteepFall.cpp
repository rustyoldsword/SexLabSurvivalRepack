#include "SteepFall.h"

#include "Bridge.h"
#include "Util.h"

namespace SLSFW::SteepFall
{
	namespace
	{
		struct State
		{
			RE::BGSRefAlias* alias{ nullptr };
			float            fallHeight{ 150.0f };
			float            crawlAllowance{ 60.0f };
			bool             active{ false };

			// main thread only
			bool             holding{ false };
			bool             hasBase{ false };
			RE::NiPoint3     base{};
			float            sinceSample{ 0.0f };
			RE::TESObjectCELL* cell{ nullptr };
			std::uint32_t    trips{ 0 };
			std::uint32_t    teleports{ 0 };
			float            lastDelta{ 0.0f };
			float            lastAllowance{ 0.0f };
		};

		constexpr float kMaxRunPerSecond = 1500.0f;

		std::mutex g_lock;
		State      g_state;

		bool ForwardHeld()
		{
			auto* controls = RE::PlayerControls::GetSingleton();
			auto* map = RE::ControlMap::GetSingleton();
			auto* camera = RE::PlayerCamera::GetSingleton();
			return controls && controls->data.moveInputVec.y > 0.0f && map && map->IsMovementControlsEnabled() && camera && !camera->IsInFreeCameraMode();
		}

		// _SLS_SteepFall.OnUpdate: fallheight + Whirlwind + Ethereal + IsCrawling * crawlallowance
		float Allowance(const Bridge::Object& a_script, const State& a_state)
		{
			float allowance = a_state.fallHeight + Bridge::GetFloat(a_script, "Whirlwind").value_or(0.0f) + Bridge::GetFloat(a_script, "Ethereal").value_or(0.0f);
			if (Bridge::GetBool(Bridge::GetObject(a_script, "Init"), "IsCrawling").value_or(false)) {
				allowance += a_state.crawlAllowance;
			}
			return allowance;
		}
	}

	void Start(RE::BGSRefAlias* a_alias, float a_fallHeight, float a_crawlAllowance)
	{
		std::scoped_lock lock(g_lock);
		g_state.alias = a_alias;
		g_state.fallHeight = a_fallHeight;
		g_state.crawlAllowance = a_crawlAllowance;
		g_state.active = a_alias != nullptr;
		g_state.hasBase = false;
		g_state.holding = false;
		logger::info("SteepFall monitor {} (fall height {}, crawl allowance {})", g_state.active ? "on" : "off", a_fallHeight, a_crawlAllowance);
	}

	void Stop()
	{
		std::scoped_lock lock(g_lock);
		if (g_state.active) {
			logger::info("SteepFall monitor off");
		}
		g_state.active = false;
		g_state.alias = nullptr;
	}

	void Rebase()
	{
		std::scoped_lock lock(g_lock);
		g_state.hasBase = false;
	}

	void Reset()
	{
		Stop();
	}

	void Tick(float a_seconds)
	{
		std::scoped_lock lock(g_lock);
		auto& s = g_state;
		if (!s.active || !s.alias) {
			return;
		}
		auto* player = RE::PlayerCharacter::GetSingleton();
		if (!player || !player->Is3DLoaded()) {
			return;
		}
		if (Util::GameMenuOpen()) {
			return;  // the Papyrus update timer does not run in menus either
		}
		const auto script = Bridge::Find(s.alias, "_SLS_SteepFall");
		if (!script || !Bridge::State(script).empty()) {
			s.hasBase = false;  // jumping or fallen: Papyrus owns it, RecordHeight on return
			s.holding = false;
			return;
		}
		if (player->GetParentCell() != s.cell) {
			s.cell = player->GetParentCell();
			s.hasBase = false;  // OnCellLoad / OnLocationChange -> RecordHeight
		}
		const auto pos = player->GetPosition();
		if (!ForwardHeld()) {
			s.holding = false;  // OnControlUp -> UnRegisterForUpdate
			return;
		}
		if (!s.holding || !s.hasBase) {
			// OnControlDown -> first update after 1 s; a stale base made Trip() just record height
			s.holding = true;
			s.hasBase = true;
			s.base = pos;
			s.sinceSample = 0.0f;
			return;
		}
		s.sinceSample += a_seconds;
		if (s.sinceSample < 1.0f) {
			return;
		}
		s.sinceSample = 0.0f;
		// more ground than anyone covers in a second (sprint, horse) is a teleport within the same cell: a scripted
		// MoveTo, an unstuck push. The old poll compared heights blindly and tripped on it.
		const float run = std::hypot(pos.x - s.base.x, pos.y - s.base.y);
		if (run > kMaxRunPerSecond) {
			++s.teleports;
			s.base = pos;
			logger::info("SteepFall: moved {:.0f} units in 1 s: teleport, no trip", run);
			return;
		}
		s.lastDelta = std::fabs(s.base.z - pos.z);
		s.lastAllowance = Allowance(script, s);
		if (s.lastDelta > s.lastAllowance) {
			++s.trips;
			s.hasBase = false;
			logger::info("SteepFall: {:.0f} units in 1 s (allowance {:.0f}) -> Trip", s.lastDelta, s.lastAllowance);
			Bridge::Call(script, "Trip", true);
		} else {
			s.base = pos;
		}
	}

	std::string Report()
	{
		std::scoped_lock lock(g_lock);
		const auto& s = g_state;
		return std::format("SLSFW steep fall: {} holding={} baseZ={} lastDelta={:.0f} allowance={:.0f} trips={} teleports={}\n",
			s.active ? "on" : "off", s.holding, s.hasBase ? std::format("{:.0f}", s.base.z) : "-", s.lastDelta, s.lastAllowance, s.trips, s.teleports);
	}
}
