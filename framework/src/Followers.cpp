#include "Followers.h"

namespace SLSFW::Followers
{
	std::vector<RE::Actor*> List(RE::TESQuest* a_followerQuest, RE::TESFaction* a_creature, RE::TESFaction* a_animal)
	{
		std::set<RE::FormID> counted;
		std::vector<RE::Actor*> actors;
		// the virtual Actor::IsDead / IsInFaction lied for Diary of Mine slaves on this setup (DoM Framework, 2026-10-09):
		// read the life state and walk the faction list directly
		const auto dead = [](RE::Actor* a_actor) {
			const auto* state = a_actor->AsActorState();
			if (!state) {
				return true;
			}
			const auto life = state->GetLifeState();
			return life == RE::ACTOR_LIFE_STATE::kDying || life == RE::ACTOR_LIFE_STATE::kDead;
		};
		const auto inFaction = [](RE::Actor* a_actor, const RE::TESFaction* a_faction) {
			if (!a_faction) {
				return false;
			}
			std::optional<int> rank;
			a_actor->VisitFactions([&](RE::TESFaction* a_f, std::int8_t a_rank) {
				if (a_f == a_faction) {
					rank = a_rank;  // runtime changes come after the base list and win
				}
				return false;
			});
			return rank && *rank != -1;
		};
		const auto consider = [&](RE::Actor* a_actor) {
			// summoned creatures and thralls are player teammates too, but not followers
			if (!a_actor || a_actor->IsPlayerRef() || dead(a_actor) || a_actor->IsDisabled() || a_actor->IsCommandedActor()) {
				return;
			}
			if (inFaction(a_actor, a_creature) || inFaction(a_actor, a_animal)) {
				return;
			}
			if (counted.insert(a_actor->GetFormID()).second) {
				actors.push_back(a_actor);
			}
		};

		// what SLS counted: the follower quest's reference aliases
		if (a_followerQuest) {
			for (auto* alias : a_followerQuest->aliases) {
				if (alias && alias->GetVMTypeID() == RE::BGSRefAlias::VMTYPEID) {
					consider(static_cast<RE::BGSRefAlias*>(alias)->GetActorReference());
				}
			}
		}
		// followers a framework keeps elsewhere: player teammates around the player
		if (auto* lists = RE::ProcessLists::GetSingleton()) {
			for (const auto* handles : { &lists->highActorHandles, &lists->middleHighActorHandles }) {
				for (const auto& handle : *handles) {
					const auto actor = handle.get();
					if (actor && actor->IsPlayerTeammate()) {
						consider(actor.get());
					}
				}
			}
		}
		return actors;
	}

	std::int32_t Count(RE::TESQuest* a_followerQuest, RE::TESFaction* a_creature, RE::TESFaction* a_animal)
	{
		return static_cast<std::int32_t>(List(a_followerQuest, a_creature, a_animal).size());
	}
}
