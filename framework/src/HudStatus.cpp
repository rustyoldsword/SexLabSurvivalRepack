// SLSFW_GetHudStatus: the player's SLS state for HUD mods, read on demand from SLS's own globals and Papyrus objects
// (the same values SLS's scripts and dialogue conditions use). Main thread only.
#include "SLSFW_HudStatus.h"

#include "Bridge.h"
#include "Forms.h"

namespace SLSFW::HudStatus
{
	namespace
	{
		struct Sources
		{
			bool                                       loaded{ false };
			std::array<RE::TESGlobal*, SLSFW_LicCount> validUntil{};
			RE::TESQuest*  licenceQuest{ nullptr };   // _SLS_LicenceQuest 0420BB: _SLS_LicenceUtil
			RE::TESQuest*  fatigueQuest{ nullptr };   // _SLS_OrgasmFatigueQuest 0E857D: _SLS_OrgasmFatigue
			RE::TESGlobal* curfewInEffect{ nullptr }; // _SLS_CurfewIsInEffect
			RE::TESGlobal* curfewViolation{ nullptr };
			RE::TESGlobal* curfewBegin{ nullptr };
			RE::TESGlobal* curfewEnd{ nullptr };
			RE::TESGlobal* grounded{ nullptr };       // _SLS_IsGrounded
			RE::TESGlobal* tollCost{ nullptr };
			RE::TESGlobal* fatigueLevel{ nullptr };   // _SLS_OrgasmFatigueLevel
			RE::SpellItem* bikiniCurse{ nullptr };    // _SLS_LicBikiniCurseSpell
			RE::SpellItem* magicCurse{ nullptr };     // _SLS_MagicLicenceCurse
			RE::SpellItem* magicCollar{ nullptr };    // _SLS_MagicLicenceCollarSpell
		};
		Sources g_src;

		template <class T>
		T* Form(RE::FormID a_id)
		{
			return RE::TESDataHandler::GetSingleton()->LookupForm<T>(a_id, Forms::kPlugin);
		}

		void Load()
		{
			if (g_src.loaded) {
				return;
			}
			g_src.loaded = true;
			// SLSFW_Licence order: magic, weapon, armor, bikini, clothes, curfew, whore, freedom, property
			constexpr std::array<RE::FormID, SLSFW_LicCount> kValidUntil{ 0x043647, 0x043649, 0x043648, 0x049300, 0x049301, 0x0D09E7, 0x0D09E8, 0x0D1A27, 0x0D1A28 };
			for (std::size_t i = 0; i < kValidUntil.size(); ++i) {
				g_src.validUntil[i] = Form<RE::TESGlobal>(kValidUntil[i]);
			}
			g_src.licenceQuest = Form<RE::TESQuest>(0x0420BB);
			g_src.fatigueQuest = Form<RE::TESQuest>(0x0E857D);
			g_src.curfewInEffect = Form<RE::TESGlobal>(0x07B44E);
			g_src.curfewViolation = Form<RE::TESGlobal>(0x0E95B3);
			g_src.curfewBegin = Form<RE::TESGlobal>(0x07B44C);
			g_src.curfewEnd = Form<RE::TESGlobal>(0x07B44D);
			g_src.grounded = Form<RE::TESGlobal>(0x08E819);
			g_src.tollCost = Form<RE::TESGlobal>(0x00B1B8);
			g_src.fatigueLevel = Form<RE::TESGlobal>(0x0E8ADE);
			g_src.bikiniCurse = Form<RE::SpellItem>(0x063A89);
			g_src.magicCurse = Form<RE::SpellItem>(0x045C3C);
			g_src.magicCollar = Form<RE::SpellItem>(0x045161);
		}

		float Value(const RE::TESGlobal* a_global, float a_fallback = 0.0f)
		{
			return a_global && std::isfinite(a_global->value) ? a_global->value : a_fallback;
		}

		bool Has(RE::Actor* a_actor, RE::SpellItem* a_spell)
		{
			return a_spell && a_actor->HasSpell(a_spell);
		}

		// _SLS_LicenceUtil.UpdateGlobalLicVariables: which licences SLS uses, plus IsAvailableLic* (purchase unlock)
		void Licences(SLSFW_HudStatus& a_out, const Bridge::Object& a_init)
		{
			const auto  lic = Bridge::Find(g_src.licenceQuest, "_SLS_LicenceUtil");
			const bool  system = lic && Bridge::GetBool(a_init, "LicencesEnable").value_or(false);
			const auto  flag = [&](std::string_view a_name) { return Bridge::GetBool(lic, a_name).value_or(true); };
			const auto  level = [&](std::string_view a_name) { return Bridge::GetInt(lic, a_name).value_or(0) > 0; };
			const std::array<bool, SLSFW_LicCount> inUse{
				flag("LicMagicEnable") && flag("IsAvailableLicMagic"),
				flag("IsAvailableLicWeapon"),
				flag("IsAvailableLicArmor"),
				flag("LicBikiniEnable") && flag("IsAvailableLicBikini"),
				level("LicClothesEnable") && flag("IsAvailableLicClothes"),
				flag("LicCurfewEnable"),
				flag("LicWhoreEnable"),
				level("LicFreedomEnable"),
				flag("LicPropertyEnable"),
			};
			const float today = RE::Calendar::GetSingleton()->GetDaysPassed();
			for (std::size_t i = 0; i < SLSFW_LicCount; ++i) {
				if (!system || !inUse[i] || !g_src.validUntil[i]) {
					a_out.licence[i] = -1;
					a_out.licenceDaysLeft[i] = 0.0f;
					continue;
				}
				const float left = Value(g_src.validUntil[i]) - today;
				a_out.licence[i] = left > 0.0f ? 1 : 0;
				a_out.licenceDaysLeft[i] = std::max(0.0f, left);
			}
		}

		// ---- contraband: what a missing licence covers, by SLS's gate search (_SLS_LicenceUtil) ----------------
		struct Contraband
		{
			bool                loaded{ false };
			RE::BGSListForm*    exceptArmor{ nullptr };   // _SLS_LicExceptionsArmor 063A8D
			RE::BGSListForm*    exceptWeapon{ nullptr };  // _SLS_LicExceptionsWeapon 063A95
			RE::BGSKeyword*     vendorWeapon{ nullptr };
			RE::BGSKeyword*     vendorArmor{ nullptr };
			RE::BGSKeyword*     vendorClothing{ nullptr };
			RE::BGSKeyword*     vendorStaff{ nullptr };
			RE::BGSKeyword*     vendorSpellTome{ nullptr };
			RE::BGSKeyword*     jewelry{ nullptr };
			RE::BGSKeyword*     noStrip{ nullptr };
			RE::BGSKeyword*     bikini{ nullptr };
			RE::BGSKeyword*     shield{ nullptr };
			RE::BGSKeyword*     boots{ nullptr };
			RE::BGSKeyword*     gauntlets{ nullptr };
			RE::BGSKeyword*     helmet{ nullptr };
		};
		Contraband g_cb;

		void LoadContraband()
		{
			if (g_cb.loaded) {
				return;
			}
			g_cb.loaded = true;
			const auto kw = [](const char* a_id) { return RE::TESForm::LookupByEditorID<RE::BGSKeyword>(a_id); };
			g_cb.exceptArmor = Form<RE::BGSListForm>(0x063A8D);
			g_cb.exceptWeapon = Form<RE::BGSListForm>(0x063A95);
			g_cb.vendorWeapon = kw("VendorItemWeapon");
			g_cb.vendorArmor = kw("VendorItemArmor");
			g_cb.vendorClothing = kw("VendorItemClothing");
			g_cb.vendorStaff = kw("VendorItemStaff");
			g_cb.vendorSpellTome = kw("VendorItemSpellTome");
			g_cb.jewelry = kw("ArmorJewelry");
			g_cb.noStrip = kw("SexLabNoStrip");
			g_cb.bikini = kw("_SLS_BikiniArmor");
			g_cb.shield = kw("ArmorShield");
			g_cb.boots = kw("ArmorBoots");
			g_cb.gauntlets = kw("ArmorGauntlets");
			g_cb.helmet = kw("ArmorHelmet");
		}

		bool HasKw(const RE::TESForm* a_form, RE::BGSKeyword* a_keyword)
		{
			const auto keywords = a_form ? a_form->As<RE::BGSKeywordForm>() : nullptr;
			return a_keyword && keywords && keywords->HasKeyword(a_keyword);
		}

		bool InList(RE::BGSListForm* a_list, RE::TESForm* a_form)
		{
			return a_list && a_list->HasForm(a_form);
		}

		bool Named(const RE::TESForm* a_form)
		{
			const auto name = a_form ? a_form->GetName() : nullptr;
			return name && *name;
		}

		bool Playable(RE::TESForm* a_form)
		{
			return a_form && a_form->GetPlayable();
		}

		struct Carried
		{
			bool weapon{ false };        // HasWeapon: VendorItemWeapon weapon not excepted, or any ammo
			bool armor{ false };         // ActorHasArmor: light/heavy VendorItemArmor armor
			bool nonBikiniWorn{ false };  // IsActorWearingNonBikiniArmor: worn body/head-slot armor that is not a bikini
			bool magic{ false };         // HasMagicItem: enchanted clothing, staff, spell tome, scroll
			bool clothes{ false };       // HasClothes: VendorItemClothing clothing
		};

		Carried Scan(RE::Actor* a_player)
		{
			Carried c;
			const auto counts = a_player->GetInventoryCounts();
			for (const auto& [object, count] : counts) {
				if (count <= 0 || !object) {
					continue;
				}
				if (const auto armor = object->As<RE::TESObjectARMO>()) {
					const bool usable = !HasKw(armor, g_cb.noStrip) && Playable(armor) && Named(armor);
					if (!usable) {
						continue;
					}
					const bool clothing = armor->GetArmorType() == RE::BIPED_MODEL::ArmorType::kClothing;
					if (!clothing) {
						c.armor = c.armor || HasKw(armor, g_cb.vendorArmor);
					} else {
						const bool excepted = InList(g_cb.exceptArmor, armor);
						c.magic = c.magic || (armor->formEnchanting && !HasKw(armor, g_cb.jewelry) && !excepted);
						c.clothes = c.clothes || (HasKw(armor, g_cb.vendorClothing) && !excepted);
					}
				} else if (const auto weapon = object->As<RE::TESObjectWEAP>()) {
					if (HasKw(weapon, g_cb.vendorStaff)) {
						c.magic = true;
					} else if (HasKw(weapon, g_cb.vendorWeapon) && !InList(g_cb.exceptWeapon, weapon)) {
						c.weapon = true;
					}
				} else if (object->Is(RE::FormType::Ammo)) {
					c.weapon = true;
				} else if (object->Is(RE::FormType::Book)) {
					c.magic = c.magic || HasKw(object, g_cb.vendorSpellTome);
				} else if (object->Is(RE::FormType::Scroll)) {
					c.magic = true;
				}
			}
			// worn full armor that is not a bikini (slots 30 head, 31 hair, 32 body, 33 hands, 37 feet)
			using Slot = RE::BGSBipedObjectForm::BipedObjectSlot;
			for (const auto slot : { Slot::kHead, Slot::kHair, Slot::kBody, Slot::kHands, Slot::kFeet }) {
				const auto worn = a_player->GetWornArmor(slot);
				if (worn && worn->GetArmorType() != RE::BIPED_MODEL::ArmorType::kClothing && !HasKw(worn, g_cb.bikini) && !HasKw(worn, g_cb.noStrip) && Named(worn) &&
					!HasKw(worn, g_cb.shield) && !InList(g_cb.exceptArmor, worn) && !HasKw(worn, g_cb.boots) && !HasKw(worn, g_cb.gauntlets) && !HasKw(worn, g_cb.helmet)) {
					c.nonBikiniWorn = true;
				}
			}
			return c;
		}

		// _SLS_LicenceUtil.HasAnyContraband / HasArmor / GateLicenceCheckClothes, for the player in a toll town
		void Violations(SLSFW_HudStatus& a_out, RE::Actor* a_player, const Bridge::Object& a_lic, const Bridge::Object& a_loc)
		{
			if (a_out.town < 0) {
				return;
			}
			LoadContraband();
			// a HUD may ask every frame: the inventory walk is cached for half a second
			static Carried                               cached;
			static std::chrono::steady_clock::time_point cachedAt;
			const auto                                   now = std::chrono::steady_clock::now();
			if (cachedAt == std::chrono::steady_clock::time_point{} || now - cachedAt > 500ms) {
				cached = Scan(a_player);
				cachedAt = now;
			}
			const auto c = cached;
			const auto missing = [&](SLSFW_Licence a_lic) { return a_out.licence[a_lic] == 0; };
			const auto valid = [&](SLSFW_Licence a_lic) { return a_out.licence[a_lic] == 1; };
			auto&      v = a_out.licenceViolation;

			v[SLSFW_LicWeapon] = missing(SLSFW_LicWeapon) && c.weapon;
			v[SLSFW_LicMagic] = missing(SLSFW_LicMagic) && c.magic;
			if (missing(SLSFW_LicArmor)) {
				if (a_out.licence[SLSFW_LicBikini] >= 0) {
					// bikini licences in use: without either licence any armor is contraband, with a bikini licence
					// only worn armor that is not a bikini
					const bool noneHeld = !valid(SLSFW_LicBikini) && c.armor;
					v[SLSFW_LicArmor] = noneHeld || (valid(SLSFW_LicBikini) && c.nonBikiniWorn);
					v[SLSFW_LicBikini] = noneHeld;
				} else {
					v[SLSFW_LicArmor] = c.armor;
				}
			}
			// clothes licence: 1 always, 2 only in a town Slaverun rules - SLS's own answer for the current town
			// (_SLS_LocTrackCentral.PlayerIsInSlavetown; without Slaverun every town is free, so never). SLSFW-006: this
			// used to read "no Slaverun installed = everywhere" and flagged clothes SLS never asks a licence for
			const auto clothesMode = Bridge::GetInt(a_lic, "LicClothesEnable").value_or(0);
			const bool slavetown = Bridge::GetInt(a_loc, "PlayerIsInSlavetown").value_or(0) == 1;
			v[SLSFW_LicClothes] = missing(SLSFW_LicClothes) && c.clothes && (clothesMode == 1 || (clothesMode == 2 && slavetown));
		}
	}

	bool Get(SLSFW_HudStatus* a_out)
	{
		if (!a_out || a_out->size < sizeof(std::uint32_t)) {
			return false;
		}
		const auto& forms = Forms::Get();
		auto*       player = RE::PlayerCharacter::GetSingleton();
		if (!forms.main || !player) {
			return false;
		}
		Load();
		const auto init = Bridge::Find(forms.main, "SLS_Init");
		if (!init) {
			return false;
		}
		SLSFW_HudStatus s{};
		s.size = sizeof(s);
		Licences(s, init);

		const auto loc = Bridge::Find(forms.locTrack, "_SLS_LocTrackCentral");
		const auto town = Bridge::GetInt(loc, "PlayerCurrentLocIndex").value_or(-1);
		s.town = static_cast<std::int8_t>(town >= 0 && town < 5 ? town : -1);
		s.tollEnabled = Bridge::GetBool(init, "TollEnable").value_or(false);
		s.tollPaid = Bridge::GetBool(init, "IsTollPaid").value_or(false);
		s.insideWalls = Bridge::GetBool(init, "IsPlayerInside").value_or(false);
		s.grounded = Value(g_src.grounded) >= 1.0f;
		s.tollCost = Value(g_src.tollCost);
		Violations(s, player, Bridge::Find(g_src.licenceQuest, "_SLS_LicenceUtil"), loc);

		s.curfewInEffect = Value(g_src.curfewInEffect) >= 1.0f;
		s.curfewViolation = Value(g_src.curfewViolation, -1.0f) >= 1.0f;
		s.curfewBegin = Value(g_src.curfewBegin, 21.0f);
		s.curfewEnd = Value(g_src.curfewEnd, 6.0f);

		s.bikiniCurse = Has(player, g_src.bikiniCurse);
		s.magicCurse = Has(player, g_src.magicCurse) || Has(player, g_src.magicCollar);

		const auto fatigue = Bridge::Find(g_src.fatigueQuest, "_SLS_OrgasmFatigue");
		s.fatigueLevel = static_cast<std::int8_t>(std::clamp(static_cast<int>(Value(g_src.fatigueLevel)), 0, 3));
		s.orgasmCount = Bridge::GetFloat(fatigue, "OrgasmCount").value_or(0.0f);
		s.orgasmThreshold = Bridge::GetFloat(fatigue, "OrgasmThreshold").value_or(1.0f);

		// an older caller passes a smaller struct: copy what it knows about
		std::memcpy(reinterpret_cast<std::byte*>(a_out) + sizeof(std::uint32_t), reinterpret_cast<const std::byte*>(&s) + sizeof(std::uint32_t),
			std::min<std::size_t>(a_out->size, sizeof(s)) - sizeof(std::uint32_t));
		return true;
	}
}

extern "C" __declspec(dllexport) bool SLSFW_GetHudStatus(SLSFW_HudStatus* a_out)
{
	return SLSFW::HudStatus::Get(a_out);
}
