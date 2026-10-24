#pragma once

// Follower count for SLS's escort rule. SLS counted the references in DialogueFollower's aliases, but follower
// frameworks (Simple Follower Framework, NFF, ...) keep their followers in their own aliases, so a hired escort counted
// as nobody and the guards arrested the player again. This counts every loaded player teammate plus anyone still in
// akFollowerQuest's aliases, skipping members of the two factions SLS skipped (creatures, potential animal companions).
namespace SLSFW::Followers
{
	std::vector<RE::Actor*> List(RE::TESQuest* a_followerQuest, RE::TESFaction* a_creature, RE::TESFaction* a_animal);  // main thread
	std::int32_t Count(RE::TESQuest* a_followerQuest, RE::TESFaction* a_creature, RE::TESFaction* a_animal);  // main thread
}
