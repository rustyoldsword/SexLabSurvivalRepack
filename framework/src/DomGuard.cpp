#include "DomGuard.h"
#include "Session.h"
#include <unordered_set>

namespace DomGuard
{
	namespace
	{
		// every SL Survival line whose fragment slaps the player (sound, notification, spank mark, resistance loss): the
		// collide line "Nice ass baby" (_SLS_AssSlapQuestTopic) and the begging refusals that end in a slap
		constexpr std::array<RE::FormID, 7> kSpankInfos{ 0x03E57A, 0x0201A0, 0x0974BC, 0x0974C1, 0x0974C4, 0x0974C7, 0x09BB16 };
		constexpr RE::FormID kDomActorFaction = 0x58FC50;  // DOMActorFaction: every DoM slave and slaver
		constexpr RE::FormID kDomBeingCaptured = 0x1598FF;  // DOMBeingCaptured: from the start of a capture until it is done

		// GetInFaction <faction> == 0, run on the speaker
		RE::TESConditionItem* NotInFaction(RE::TESFaction* a_faction)
		{
			auto* item = new RE::TESConditionItem();
			item->next = nullptr;
			item->data.object = RE::CONDITIONITEMOBJECT::kSelf;
			item->data.functionData.function = RE::FUNCTION_DATA::FunctionID::kGetInFaction;
			item->data.functionData.params[0] = a_faction;
			item->data.functionData.params[1] = nullptr;
			item->data.comparisonValue.f = 0.0f;
			item->data.flags.isOR = false;
			item->data.flags.opCode = RE::CONDITION_ITEM_DATA::OpCode::kEqualTo;
			return item;
		}

		bool HasFactionCheck(const RE::TESCondition& a_conditions, const RE::TESFaction* a_faction)
		{
			for (auto* item = a_conditions.head; item; item = item->next) {
				if (item->data.functionData.function == RE::FUNCTION_DATA::FunctionID::kGetInFaction && item->data.functionData.params[0] == a_faction) {
					return true;
				}
			}
			return false;
		}
	}

	namespace
	{
		bool  g_done{ false };   // every line guarded since the last load
		float g_since{ 0.0f };
	}

	void Reset()
	{
		g_done = false;
		g_since = 1.0f;
	}

	void Apply(float a_seconds)
	{
		if (g_done || !SLSFW::Session::Settled()) {
			return;
		}
		g_since += a_seconds;
		if (g_since < 1.0f) {
			return;  // the lines appear when their topics load; once a second is plenty
		}
		g_since = 0.0f;
		auto* data = RE::TESDataHandler::GetSingleton();
		if (!data || !data->LookupModByName("DiaryOfMine.esm")) {
			g_done = true;
			return;
		}
		static auto* actor = data->LookupForm<RE::TESFaction>(kDomActorFaction, "DiaryOfMine.esm");
		static auto* captured = data->LookupForm<RE::TESFaction>(kDomBeingCaptured, "DiaryOfMine.esm");
		if (!actor || !captured) {
			static bool warned = false;
			if (!warned) {
				warned = true;
				logger::warn("dom guard: DoM factions not found (DOMActorFaction {}, DOMBeingCaptured {})", actor != nullptr, captured != nullptr);
			}
			return;
		}
		// the engine creates dialogue lines after kDataLoaded (only 1 of the 7 existed then), so this runs once a
		// second: a line that exists and still lacks the checks gets them; once all are guarded the tick goes idle
		bool allGuarded = true;
		for (const auto id : kSpankInfos) {
			auto* info = data->LookupForm<RE::TESTopicInfo>(id, "SL Survival.esp");
			if (!info) {
				allGuarded = false;
				continue;
			}
			if (HasFactionCheck(info->objConditions, actor) && HasFactionCheck(info->objConditions, captured)) {
				continue;
			}
			auto**                tail = &info->objConditions.head;
			RE::TESConditionItem* last = nullptr;
			while (*tail) {
				last = *tail;
				tail = &(*tail)->next;
			}
			if (last && last->data.flags.isOR) {
				// an item after an OR joins that OR group and would loosen the line instead of tightening it
				static std::unordered_set<RE::FormID> warned;
				if (warned.insert(id).second) {
					logger::warn("dom guard: SL Survival line {:06X} ends in an OR condition - left unchanged", id);
				}
				continue;
			}
			// appended after the last condition, an AND: the line (and so its fragment, the whole slap) also needs both
			int added = 0;
			for (auto* faction : { actor, captured }) {
				if (!HasFactionCheck(info->objConditions, faction)) {
					*tail = NotInFaction(faction);
					tail = &(*tail)->next;
					++added;
				}
			}
			logger::info("dom guard: SL Survival slap line {:08X} now skips DoM actors and NPCs being captured ({} conditions added)", info->GetFormID(), added);
		}
		g_done = allGuarded;
	}
}
