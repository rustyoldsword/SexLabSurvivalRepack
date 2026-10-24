#include "GuardWatch.h"

#include "BaboGuard.h"

#include "Bridge.h"
#include "Forms.h"
#include "Session.h"

namespace SLSFW::GuardWatch
{
	namespace
	{
		struct Stats
		{
			std::uint32_t checks{ 0 };
			std::uint32_t hits{ 0 };
		};

		std::mutex                  g_lock;
		std::map<std::string, Stats> g_stats;  // "<quest> <search>" -> counts

		void Count(RE::TESQuest* a_quest, std::string_view a_search, bool a_hit)
		{
			const char*      id = a_quest->GetFormEditorID();
			const auto       key = std::format("{} {}", id && *id ? id : std::format("{:08X}", a_quest->GetFormID()), a_search);
			std::scoped_lock l{ g_lock };
			auto&            stats = g_stats[key];
			++stats.checks;
			stats.hits += a_hit ? 1 : 0;
		}

		const RE::BGSRefAlias* RefAliasOf(RE::TESQuest* a_quest, std::int32_t a_id)
		{
			for (auto* alias : a_quest->aliases) {
				if (alias && alias->aliasID == static_cast<std::uint32_t>(a_id)) {
					return alias->GetVMTypeID() == RE::BGSRefAlias::VMTYPEID ? static_cast<const RE::BGSRefAlias*>(alias) : nullptr;
				}
			}
			return nullptr;
		}

		// the candidates a "matching reference in loaded area" fill can pick from: every actor with an AI process
		template <class F>
		void ForEachCandidate(const RE::TESCondition& a_conditions, F&& a_fn)
		{
			auto* lists = RE::ProcessLists::GetSingleton();
			if (!lists) {
				return;
			}
			for (const auto* handles : { &lists->highActorHandles, &lists->middleHighActorHandles, &lists->middleLowActorHandles, &lists->lowActorHandles }) {
				for (const auto& handle : *handles) {
					const auto actor = handle.get();
					if (actor && !actor->IsDisabled() && !actor->IsDeleted() && a_conditions.IsTrue(actor.get(), nullptr)) {
						if (!a_fn(actor.get())) {
							return;
						}
					}
				}
			}
		}

		// what Stop/Start of the search quest would put in its aliases: the closest matching actors, one per alias
		// (every alias of the toll-dodge guard search carries the same conditions)
		std::vector<RE::Actor*> ClosestMatches(RE::TESQuest* a_quest)
		{
			std::vector<RE::Actor*> found;
			const auto*             alias = RefAliasOf(a_quest, 0);
			auto*                   player = RE::PlayerCharacter::GetSingleton();
			if (!alias || !alias->conditions || !player) {
				return found;
			}
			ForEachCandidate(*alias->conditions, [&](RE::Actor* a_actor) {
				found.push_back(a_actor);
				return true;
			});
			const auto origin = player->GetPosition();
			std::ranges::sort(found, {}, [&](RE::Actor* a_actor) { return a_actor->GetPosition().GetSquaredDistance(origin); });
			if (found.size() > a_quest->aliases.size()) {
				found.resize(a_quest->aliases.size());
			}
			return found;
		}

		// Papyrus PlayerRef.IsDetectedBy(akGuard)
		bool Detects(RE::Actor* a_guard, RE::Actor* a_player)
		{
			return a_guard->RequestDetectionLevel(a_player) > 0;
		}
	}

	namespace
	{
		// Guard warnings: SLS sets _SLS_GuardWarnTypeAndCooldown to the warning type and sends a guard to approach
		// (_SLS_GuardWarnDoApproach = 1); only the end of that conversation or its approach timeout starts the cooldown
		// quest that puts the type back to 0. When the guard never comes (busy in a scene) and the player draws or
		// equips again, SLS cancels the approach but leaves the type set - and every warning check waits for 0 forever.
		// After 60 s of that state the DLL starts SLS's own cooldown (SLS_Utility.BeginGuardWarnCooldown).
		constexpr float kStuckSeconds = 60.0f;
		RE::TESGlobal*  g_warnType{ nullptr };
		RE::TESGlobal*  g_warnApproach{ nullptr };
		RE::TESQuest*   g_warnCooldown{ nullptr };
		float           g_stuckFor{ 0.0f };
		std::uint32_t   g_unstuck{ 0 };
	}

	namespace
	{
		// Curfew: SLS sends its curfew guards (_SLS_CurfewGuardAliases, up to 20 loaded guards) only when the curfew
		// starts or the player changes location. A guard who walks into range later never comes, so a heroine who
		// broke curfew where no guard stood could roam all night. While SLS has flagged a violation
		// (_SLS_CurfewViolation = 1) and no curfew guard is assigned, the DLL checks every 2 s whether a loaded actor
		// passes the alias conditions and then lets _SLS_Curfew.IsViolatingCurfew run its own licence check and fill.
		constexpr float kCurfewEvery = 2.0f;
		RE::TESGlobal*  g_curfewInEffect{ nullptr };
		RE::TESGlobal*  g_curfewViolation{ nullptr };
		RE::TESQuest*   g_curfewQuest{ nullptr };
		RE::TESQuest*   g_curfewGuards{ nullptr };
		float           g_curfewFor{ 0.0f };
		std::uint32_t   g_curfewSends{ 0 };

		bool CurfewGuardAssigned()
		{
			if (!g_curfewGuards->IsRunning()) {
				return false;
			}
			for (const auto& [id, handle] : g_curfewGuards->refAliasMap) {
				if (handle.get()) {
					return true;
				}
			}
			return false;
		}

		void CurfewTick(float a_seconds)
		{
			if (!g_curfewInEffect || !g_curfewViolation || !g_curfewQuest || !g_curfewGuards) {
				return;
			}
			g_curfewFor += a_seconds;
			if (g_curfewFor < kCurfewEvery) {
				return;
			}
			g_curfewFor = 0.0f;
			if (g_curfewInEffect->value != 1.0f || g_curfewViolation->value != 1.0f || !Session::Settled() || BaboGuard::Busy()) {
				return;
			}
			auto*       player = RE::PlayerCharacter::GetSingleton();
			const auto* cell = player ? player->GetParentCell() : nullptr;
			auto*       ui = RE::UI::GetSingleton();
			if (!cell || cell->IsInteriorCell() || (ui && ui->IsMenuOpen(RE::DialogueMenu::MENU_NAME)) || CurfewGuardAssigned()) {
				return;
			}
			if (!AliasHasMatch(g_curfewGuards, 0)) {
				return;
			}
			if (Bridge::Call(Bridge::Find(g_curfewQuest, "_SLS_Curfew"), "IsViolatingCurfew")) {
				++g_curfewSends;
				logger::info("curfew: a guard came into range after the location check, SLS re-checks the violation");
			}
		}
	}

	void Register()
	{
		auto* data = RE::TESDataHandler::GetSingleton();
		g_warnType = data->LookupForm<RE::TESGlobal>(0x0A0C2C, Forms::kPlugin);
		g_warnApproach = data->LookupForm<RE::TESGlobal>(0x091353, Forms::kPlugin);
		g_warnCooldown = data->LookupForm<RE::TESQuest>(0x0A0C2B, Forms::kPlugin);
		g_curfewInEffect = data->LookupForm<RE::TESGlobal>(0x07B44E, Forms::kPlugin);
		g_curfewViolation = data->LookupForm<RE::TESGlobal>(0x0E95B3, Forms::kPlugin);
		g_curfewQuest = data->LookupForm<RE::TESQuest>(0x0E3F3D, Forms::kPlugin);
		g_curfewGuards = data->LookupForm<RE::TESQuest>(0x0E9049, Forms::kPlugin);
	}

	void Tick(float a_seconds)
	{
		CurfewTick(a_seconds);
		if (!g_warnType || !g_warnApproach || !g_warnCooldown) {
			return;
		}
		auto*      ui = RE::UI::GetSingleton();
		const bool talking = ui && ui->IsMenuOpen(RE::DialogueMenu::MENU_NAME);
		const bool stuck = g_warnType->value != 0.0f && g_warnApproach->value == 0.0f && !g_warnCooldown->IsRunning() && !talking;
		g_stuckFor = stuck ? g_stuckFor + a_seconds : 0.0f;
		if (g_stuckFor < kStuckSeconds) {
			return;
		}
		g_stuckFor = 0.0f;
		const auto utility = Bridge::Find(Forms::Get().main, "SLS_Utility");
		if (Bridge::Call(utility, "BeginGuardWarnCooldown")) {
			++g_unstuck;
			logger::info("guard warning type {} was left set with no guard coming: started SLS's cooldown", g_warnType->value);
		}
	}

	bool AliasHasMatch(RE::TESQuest* a_quest, std::int32_t a_aliasId)
	{
		if (BaboGuard::Busy()) {
			return false;  // BaboDialogue owns the player: report no candidate, the script skips its search
		}
		const auto* alias = a_quest ? RefAliasOf(a_quest, a_aliasId) : nullptr;
		if (!alias || !alias->conditions) {
			return true;  // nothing to pre-check: let the script restart its quest as before
		}
		bool match = false;
		ForEachCandidate(*alias->conditions, [&](RE::Actor*) {
			match = true;
			return false;
		});
		Count(a_quest, "restart", match);
		return match;
	}

	RE::Actor* FindSpottingGuard(RE::TESQuest* a_quest)
	{
		auto* player = RE::PlayerCharacter::GetSingleton();
		if (!a_quest || !player || BaboGuard::Busy()) {
			return nullptr;
		}
		RE::Actor* spotter = nullptr;
		for (auto* guard : ClosestMatches(a_quest)) {
			bool unused = false;
			if (Detects(guard, player) && guard->HasLineOfSight(player, unused)) {
				spotter = guard;
				break;
			}
		}
		Count(a_quest, "spotted", spotter != nullptr);
		return spotter;
	}

	std::vector<RE::Actor*> FindDetectingGuards(RE::TESQuest* a_quest)
	{
		std::vector<RE::Actor*> detecting;
		auto*                   player = RE::PlayerCharacter::GetSingleton();
		if (!a_quest || !player || BaboGuard::Busy()) {
			return detecting;
		}
		for (auto* guard : ClosestMatches(a_quest)) {
			if (Detects(guard, player)) {
				detecting.push_back(guard);
			}
		}
		Count(a_quest, "hunters", !detecting.empty());
		return detecting;
	}

	void Reset()
	{
		g_stuckFor = 0.0f;
		g_curfewFor = 0.0f;
		std::scoped_lock l{ g_lock };
		g_stats.clear();
	}

	std::string Report()
	{
		std::scoped_lock l{ g_lock };
		std::string      out = std::format("SLSFW guard watch: stuck warnings released {}, late curfew guards {}", g_unstuck, g_curfewSends);
		if (g_stats.empty()) {
			return out + ", no searches since load\n";
		}
		out += '\n';
		for (const auto& [key, stats] : g_stats) {
			out += std::format("  {}: {} checks, {} hits\n", key, stats.checks, stats.hits);
		}
		return out;
	}
}
