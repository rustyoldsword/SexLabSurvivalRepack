#pragma once

namespace DomGuard
{
	// Diary of Mine: SL Survival's collide line "Nice ass baby" (_SLS_AssSlapQuestTopic, ActorCollideWithActor) spanks
	// the player. During a DoM capture the player lies on the victim, the engine reports a collision and the victim
	// spanks her. With DiaryOfMine.esm loaded, that line and every other SLS line whose fragment slaps the player get two
	// more conditions in memory: the speaker is not a DoM actor (slave or slaver) and is not being captured. The fragment
	// holds the whole slap (sound, notification, mark, resistance loss), so none of it runs. No-op without DoM.
	void Apply(float a_seconds);  // scheduler tick: once a second until every line is guarded, then idle until the next load
	void Reset();  // load / new game: the engine re-creates the INFO objects, guard them again
}
