#include "SlsMenu.h"

#include "Bridge.h"
#include "Forms.h"
#include "Session.h"

#include <nlohmann/json.hpp>

#pragma warning(push)
#pragma warning(disable : 4099 5054)
#include <SKSEMenuFramework.h>
#pragma warning(pop)

#include <chrono>
#include <deque>
#include <fstream>
#include <map>
#include <unordered_map>

namespace SLSFW::SlsMenu
{
	namespace
	{
		using json = nlohmann::json;

		// where an option's current value lives (see gen_menu.py parse_read)
		struct Read
		{
			enum class Kind
			{
				kNone,
				kVar,     // path of properties from sls_mcm, the last one holds the value
				kGlob,    // path from sls_mcm to a GlobalVariable property
				kGlobId,  // a GlobalVariable by plugin + local FormID
				kScript,  // a property of a script bound to a form (plugin + local FormID)
				kSu,      // StorageUtil value: no native API, read once per menu open through Papyrus
				kMenu     // a string array (path from sls_mcm) and an index (its own Read)
			};
			Kind                     kind{ Kind::kNone };
			std::vector<std::string> path;
			bool                     negate{ false };
			RE::FormID               id{ 0 };
			std::string              plugin, script, prop;
			bool                     isFloat{ false };
			bool                     ownerSelf{ true };
			std::string              key;
			float                    missing{ 0.0f };
			std::shared_ptr<Read>    index;
		};

		enum class Type
		{
			kText,
			kToggle,
			kSlider,
			kMenu,
			kKeyMap,
			kButton
		};

		struct Option
		{
			int         id{ 0 };
			Type        type{ Type::kText };
			std::string label, info, oidVar, oidSu, fmt;
			std::string raw;           // the label as the page code passes it (matched against the page capture)
			char        ctype{ '?' };  // the capture's type letter for this option
			bool        hard{ false };
			bool        confirm{ false };       // the MCM handler asks first: the menu asks instead
			bool        rangeRuntime{ false };  // slider range computed in code: taken from the page capture
			Read        read;
			float       min{ 0.0f }, max{ 100.0f }, step{ 1.0f }, def{ 0.0f };
		};

		struct Page
		{
			std::string         id, title;
			bool                dynamic{ false };  // built in loops: drawn from the page capture only
			std::vector<Option> items;
		};

		// ---- page capture (0.9.2): the MCM draws the page into a buffer (sls_mcm.SLSFW_CapturePage) ----
		struct CapItem
		{
			char                     type{ '?' };  // E empty, H header, T text, G toggle, S slider, M menu, K keymap, C color
			std::int32_t             oid{ 0 };
			int                      flags{ 0 };   // SkyUI OPTION_FLAG_*: 1 disabled, 2 hidden
			std::string              value, fmt, label, info;
			std::optional<float>     min, max, step, def, start;
			std::vector<std::string> items;
		};
		struct Capture
		{
			bool                         requested{ false };
			bool                         done{ false };
			std::vector<CapItem>         items;
			std::unordered_map<int, int> byOption;  // static option id -> capture index
		};
		std::mutex           g_capLock;
		std::vector<Capture> g_caps;               // one per page
		std::atomic_int      g_capWant{ -1 };      // page the renderer is showing and has no capture for
		// 0.9.3: one page capture at a time. sls_mcm.SLSFW_CapturePage keeps its state in one flag and shared StorageUtil
		// lists; two captures on the same script interleave at every latent call, the second one's end switches the
		// flag off under the first, and the first page then lost most of its options (2026-11-10: Licences 1 came back
		// with 45 entries / 0 matched instead of 101 / 26 while the player clicked through the pages).
		std::deque<int>      g_capQueue;           // main thread only: pages waiting for their capture
		int                  g_capBusy{ -1 };      // main thread only: page whose capture is running
		float                g_capBusyFor{ 0.0f };
		std::atomic_int      g_capReturned{ -1 };     // page whose capture just answered (set on the VM thread)
		std::atomic_uint     g_capGen{ 0 };           // ForgetCaptures: a capture started before it is stale
		constexpr std::int32_t kCapOidBase = 0x50000000;  // + page * 1024 + index; FreshOid() uses 0x40000000 + id
		constexpr int          kDynIdBase = 1000000;      // pending ids of capture-only options: + page * 1024 + index

		// filled once in Load, read-only afterwards
		std::vector<Page>                                  g_pages;
		std::unordered_map<std::string, std::string>       g_strings;  // lower-case $SLS_ key -> English
		std::unordered_map<int, std::pair<size_t, size_t>> g_where;    // option id -> page, item

		// what the menu shows: written on the main thread, read by the render thread
		struct Snapshot
		{
			std::unordered_map<int, float>                    values;
			std::unordered_map<int, std::vector<std::string>> menus;
			bool                                              hardLocked{ false };
			bool                                              loaded{ false };
		};
		std::mutex g_snapLock;
		Snapshot   g_snap;

		// what the player changed: written by the render thread, applied on the main thread after the menu closes
		struct Pending
		{
			float value{ 0.0f };  // toggle: wanted state (0/1), slider: value, menu: index, keymap: key code
			int   presses{ 0 };   // toggle with an unknown state / button: how often it was clicked
		};
		std::mutex                  g_pendLock;
		std::map<int, Pending>      g_pending;

		std::atomic_bool g_open{ false };  // SMF's open/close event (only SMF builds that export RegisterEventPriority send it)
		// 0.9.3: the render thread stamps every page it draws, so the menu knows it is on screen even when SMF sends no
		// open event. Before, an SMF without that event left every page on "Reading SL Survival settings..." for good -
		// and the MCM is hidden whenever this menu is active, so such a player had no settings at all (dwemermods 5022).
		std::atomic<std::int64_t> g_lastDrawMs{ 0 };
		bool                      g_visible{ false };  // main thread: open state seen by the last Tick

		std::int64_t NowMs()
		{
			return std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::steady_clock::now().time_since_epoch()).count();
		}
		std::atomic_bool g_suDue{ false };
		float            g_sinceSnapshot{ 1.0f };

		// ---- 0.9.3: remembered settings (see SlsMenu.h) ----
		// An option is remembered under a key that survives a regenerated Menu.json (option ids are positions):
		// page id | capture type letter | label as the page code passes it | its occurrence on the page.
		const std::filesystem::path                  kProfilePath{ "Data/SKSE/Plugins/SLSurvivalFramework/UserSettings.json" };
		std::unordered_map<int, std::string>         g_keyOf;  // static option id -> key (filled in Load)
		std::unordered_map<std::string, int>         g_idOf;   // key -> static option id
		std::mutex                                   g_profLock;
		std::map<std::string, float>                 g_profile[2];  // [0] male, [1] female

		enum class Replay
		{
			kIdle,
			kWaitRaceMenu,  // new game: the sex is chosen in RaceMenu
			kCapturing      // reading the pages the remembered options are on
		};
		Replay           g_replay{ Replay::kIdle };  // main thread only
		bool             g_raceSeen{ false };
		float            g_replayWait{ 0.0f };
		std::vector<int> g_replayPages;
		bool             g_replaying{ false };  // Apply() is applying the remembered list: nothing new to remember

		std::string Translate(std::string_view a_text)
		{
			if (!a_text.starts_with('$')) {
				return std::string(a_text);
			}
			std::string lower(a_text);
			std::ranges::transform(lower, lower.begin(), [](unsigned char c) { return static_cast<char>(std::tolower(c)); });
			const auto it = g_strings.find(lower);
			return it != g_strings.end() ? it->second : std::string(a_text);
		}

		Read ParseRead(const json& a_j)
		{
			Read r;
			if (!a_j.is_object()) {
				return r;
			}
			const auto k = a_j.value("k", "");
			r.negate = a_j.value("not", false);
			if (k == "var" || k == "glob") {
				r.kind = k == "var" ? Read::Kind::kVar : Read::Kind::kGlob;
				r.path = a_j.value("path", std::vector<std::string>{});
			} else if (k == "globid" || k == "script") {
				r.kind = k == "globid" ? Read::Kind::kGlobId : Read::Kind::kScript;
				r.id = a_j.value("id", 0u);
				r.plugin = a_j.value("plugin", "");
				r.script = a_j.value("script", "");
				r.prop = a_j.value("prop", "");
			} else if (k == "su") {
				r.kind = Read::Kind::kSu;
				r.isFloat = a_j.value("float", false);
				r.ownerSelf = a_j.value("owner", "self") == "self";
				r.key = a_j.value("key", "");
				r.missing = a_j.value("missing", 0.0f);
			} else if (k == "menu") {
				r.kind = Read::Kind::kMenu;
				r.path = a_j.value("items", std::vector<std::string>{});
				if (a_j.contains("index")) {
					r.index = std::make_shared<Read>(ParseRead(a_j["index"]));
				}
			}
			return r;
		}

		std::optional<float> Number(const RE::BSScript::Variable* a_var)
		{
			if (!a_var) {
				return std::nullopt;
			}
			if (a_var->IsBool()) {
				return a_var->GetBool() ? 1.0f : 0.0f;
			}
			if (a_var->IsInt()) {
				return static_cast<float>(a_var->GetSInt());
			}
			if (a_var->IsFloat()) {
				return a_var->GetFloat();
			}
			return std::nullopt;
		}

		// follow all but the last name of a property path from sls_mcm
		Bridge::Object Walk(const Bridge::Object& a_mcm, const std::vector<std::string>& a_path, size_t a_keep)
		{
			auto obj = a_mcm;
			for (size_t i = 0; obj && i + a_keep < a_path.size(); ++i) {
				obj = Bridge::GetObject(obj, a_path[i]);
			}
			return obj;
		}

		std::optional<float> Eval(const Read& a_read, const Bridge::Object& a_mcm)
		{
			std::optional<float> value;
			switch (a_read.kind) {
			case Read::Kind::kVar:
				if (!a_read.path.empty()) {
					value = Number(Bridge::Var(Walk(a_mcm, a_read.path, 1), a_read.path.back()));
				}
				break;
			case Read::Kind::kGlob:
				if (const auto obj = Walk(a_mcm, a_read.path, 0)) {
					if (auto* global = static_cast<RE::TESGlobal*>(obj->Resolve(static_cast<RE::VMTypeID>(RE::FormType::Global)))) {
						value = global->value;
					}
				}
				break;
			case Read::Kind::kGlobId:
				if (auto* dh = RE::TESDataHandler::GetSingleton()) {
					if (auto* global = dh->LookupForm<RE::TESGlobal>(a_read.id, a_read.plugin)) {
						value = global->value;
					}
				}
				break;
			case Read::Kind::kScript:
				if (auto* dh = RE::TESDataHandler::GetSingleton()) {
					if (auto* form = dh->LookupForm(a_read.id, a_read.plugin)) {
						value = Number(Bridge::Var(Bridge::Find(form, a_read.script), a_read.prop));
					}
				}
				break;
			case Read::Kind::kMenu:
				if (a_read.index) {
					value = Eval(*a_read.index, a_mcm);
				}
				break;
			default:
				break;
			}
			if (value && a_read.negate) {
				value = *value != 0.0f ? 0.0f : 1.0f;
			}
			return value;
		}

		std::vector<std::string> MenuItems(const Read& a_read, const Bridge::Object& a_mcm)
		{
			std::vector<std::string> items;
			if (a_read.path.empty()) {
				return items;
			}
			const auto* var = Bridge::Var(Walk(a_mcm, a_read.path, 1), a_read.path.back());
			if (!var || !var->IsArray()) {
				return items;
			}
			if (const auto array = var->GetArray()) {
				for (size_t i = 0; i < array->size(); ++i) {
					const auto& element = (*array)[static_cast<std::uint32_t>(i)];
					items.push_back(element.IsString() ? Translate(element.GetString()) : std::string{});
				}
			}
			return items;
		}

		// StorageUtil has no native API: ask Papyrus (static call, takes no SLS script lock) and keep the answer
		class SuCallback final : public RE::BSScript::IStackCallbackFunctor
		{
		public:
			explicit SuCallback(int a_id, bool a_negate) :
				_id(a_id), _negate(a_negate) {}

			void operator()(RE::BSScript::Variable a_result) override
			{
				auto value = Number(std::addressof(a_result));
				if (!value) {
					return;
				}
				if (_negate) {
					value = *value != 0.0f ? 0.0f : 1.0f;
				}
				std::scoped_lock lock(g_snapLock);
				g_snap.values[_id] = *value;
			}

			void SetObject(const RE::BSTSmartPointer<RE::BSScript::Object>&) override {}

		private:
			int  _id;
			bool _negate;
		};

		void ReadStorageUtil()
		{
			auto* vm = Bridge::VM();
			auto* quest = Forms::Get().main;
			if (!vm || !quest) {
				return;
			}
			for (const auto& page : g_pages) {
				for (const auto& o : page.items) {
					if (o.read.kind != Read::Kind::kSu) {
						continue;
					}
					RE::TESForm* owner = o.read.ownerSelf ? quest : nullptr;
					RE::BSTSmartPointer<RE::BSScript::IStackCallbackFunctor> callback{ new SuCallback(o.id, o.read.negate) };
					std::unique_ptr<RE::BSScript::IFunctionArguments>          args;
					if (o.read.isFloat) {
						args.reset(RE::MakeFunctionArguments(std::move(owner), RE::BSFixedString(o.read.key), static_cast<float>(o.read.missing)));
						vm->DispatchStaticCall("StorageUtil", "GetFloatValue", args.get(), callback);
					} else {
						args.reset(RE::MakeFunctionArguments(std::move(owner), RE::BSFixedString(o.read.key), static_cast<std::int32_t>(o.read.missing)));
						vm->DispatchStaticCall("StorageUtil", "GetIntValue", args.get(), callback);
					}
				}
			}
		}

		std::optional<float> ParseFloat(const std::string& a_text)
		{
			if (a_text.empty()) {
				return std::nullopt;
			}
			char*       end = nullptr;
			const float v = std::strtof(a_text.c_str(), std::addressof(end));
			return end != a_text.c_str() ? std::optional<float>(v) : std::nullopt;
		}

		// "type|oid|flags|value|format|min|max|step|default|start|items(^)|label|info" - info is the rest of the line
		CapItem ParseCapture(std::string_view a_rec)
		{
			std::vector<std::string> f;
			size_t                   pos = 0;
			while (f.size() < 12) {
				const auto bar = a_rec.find('|', pos);
				if (bar == std::string_view::npos) {
					break;
				}
				f.emplace_back(a_rec.substr(pos, bar - pos));
				pos = bar + 1;
			}
			f.emplace_back(a_rec.substr(std::min(pos, a_rec.size())));
			f.resize(13);
			CapItem c;
			c.type = f[0].empty() ? '?' : f[0][0];
			c.oid = static_cast<std::int32_t>(std::strtol(f[1].c_str(), nullptr, 10));
			c.flags = static_cast<int>(std::strtol(f[2].c_str(), nullptr, 10));
			c.value = f[3];
			c.fmt = f[4];
			c.min = ParseFloat(f[5]);
			c.max = ParseFloat(f[6]);
			c.step = ParseFloat(f[7]);
			c.def = ParseFloat(f[8]);
			c.start = ParseFloat(f[9]);
			if (!f[10].empty()) {
				size_t from = 0;
				while (true) {
					const auto caret = f[10].find('^', from);
					c.items.push_back(Translate(f[10].substr(from, caret == std::string::npos ? std::string::npos : caret - from)));
					if (caret == std::string::npos) {
						break;
					}
					from = caret + 1;
				}
			}
			c.label = f[11];
			c.info = f[12];
			return c;
		}

		std::string Lower(std::string a_text)
		{
			std::ranges::transform(a_text, a_text.begin(), [](unsigned char c) { return static_cast<char>(std::tolower(c)); });
			return a_text;
		}

		class CaptureCallback final : public RE::BSScript::IStackCallbackFunctor
		{
		public:
			explicit CaptureCallback(size_t a_page, unsigned a_gen) :
				_page(a_page), _gen(a_gen) {}

			void operator()(RE::BSScript::Variable a_result) override
			{
				if (_gen != g_capGen) {  // the captures were dropped while this one ran: its values may be stale
					g_capReturned = static_cast<int>(_page);
					return;
				}
				Capture cap;
				cap.requested = cap.done = true;
				if (a_result.IsArray()) {
					if (const auto array = a_result.GetArray()) {
						for (std::uint32_t i = 0; i < array->size(); ++i) {
							const auto& e = (*array)[i];
							cap.items.push_back(e.IsString() ? ParseCapture(e.GetString()) : CapItem{});
						}
					}
				}
				// static options -> capture entries: same type letter and the same label as the page code passes,
				// the k-th static option with that key takes the k-th capture entry with it
				std::map<std::string, std::vector<int>> byKey;
				for (int i = 0; i < static_cast<int>(cap.items.size()); ++i) {
					byKey[std::string(1, cap.items[i].type) + Lower(cap.items[i].label)].push_back(i);
				}
				std::map<std::string, size_t> used;
				if (_page < g_pages.size()) {
					for (const auto& o : g_pages[_page].items) {
						if (o.type == Type::kText || o.raw.empty()) {
							continue;
						}
						const auto key = std::string(1, o.ctype) + Lower(o.raw);
						const auto it = byKey.find(key);
						auto&      n = used[key];
						if (it != byKey.end() && n < it->second.size()) {
							cap.byOption[o.id] = it->second[n++];
						}
					}
				}
				logger::info("menu: captured page {} ({} entries, {} matched)", _page < g_pages.size() ? g_pages[_page].title : "?",
					cap.items.size(), cap.byOption.size());
				{
					std::scoped_lock lock(g_capLock);
					if (_page < g_caps.size()) {
						g_caps[_page] = std::move(cap);
					}
				}
				g_capReturned = static_cast<int>(_page);
			}

			void SetObject(const RE::BSTSmartPointer<RE::BSScript::Object>&) override {}

		private:
			size_t   _page;
			unsigned _gen;
		};

		// main thread: ask the MCM to draw one page (async - the menu draws "reading" meanwhile); false = not started
		bool DispatchCapture(int page)
		{
			{
				std::scoped_lock lock(g_capLock);
				if (g_caps[page].requested) {
					return false;
				}
				g_caps[page].requested = true;
			}
			auto* vm = Bridge::VM();
			auto  mcm = Bridge::Find(Forms::Get().main, "SLS_Mcm");  // non-const: DispatchMethodCall takes it by reference
			std::unique_ptr<RE::BSScript::IFunctionArguments> args{ RE::MakeFunctionArguments(
				RE::BSFixedString(g_pages[page].id), static_cast<std::int32_t>(kCapOidBase + page * 1024)) };
			RE::BSTSmartPointer<RE::BSScript::IStackCallbackFunctor> callback{ new CaptureCallback(static_cast<size_t>(page), g_capGen) };
			if (!vm || !mcm || !vm->DispatchMethodCall(mcm, "SLSFW_CapturePage", args.get(), callback)) {
				std::scoped_lock lock(g_capLock);
				g_caps[page].requested = false;
				return false;
			}
			return true;
		}

		// queue a page for capture; PumpCaptures starts it when no other capture is running
		void RequestCaptureFor(int page)
		{
			if (page >= 0 && static_cast<size_t>(page) < g_pages.size() && std::ranges::find(g_capQueue, page) == g_capQueue.end()) {
				g_capQueue.push_back(page);
			}
		}

		// main thread, every tick: finish the running capture, then start the next one (the page on screen first)
		void PumpCaptures(float a_seconds)
		{
			if (g_capBusy >= 0) {
				if (g_capReturned.exchange(-1) != g_capBusy) {  // a late answer of a page given up on does not count
					g_capBusyFor += a_seconds;
					if (g_capBusyFor < 15.0f) {
						return;
					}
					logger::warn("menu: page {} not read in 15 s, will ask again", g_pages[g_capBusy].title);
					std::scoped_lock lock(g_capLock);
					if (!g_caps[g_capBusy].done) {
						g_caps[g_capBusy].requested = false;
					}
				}
				g_capBusy = -1;
			}
			int page = g_capWant.exchange(-1);
			if (page < 0 || static_cast<size_t>(page) >= g_pages.size()) {
				page = -1;
				while (page < 0 && !g_capQueue.empty()) {
					page = g_capQueue.front();
					g_capQueue.pop_front();
				}
			}
			if (page >= 0) {
				std::erase(g_capQueue, page);
				g_capReturned = -1;
				if (DispatchCapture(page)) {
					g_capBusy = page;
					g_capBusyFor = 0.0f;
				}
			}
		}

		void ForgetCaptures()
		{
			++g_capGen;
			std::scoped_lock lock(g_capLock);
			for (auto& c : g_caps) {
				c = Capture{};
			}
		}

		// SkyUI slider format ("{1}%", "$SLS_Gold" = "{0} Gold") -> printf
		std::string SkyFormat(const std::string& a_fmt)
		{
			const auto  text = Translate(a_fmt.empty() ? std::string("{0}") : a_fmt);
			std::string out;
			bool        number = false;
			for (size_t i = 0; i < text.size(); ++i) {
				if (text[i] == '{' && i + 2 < text.size() && std::isdigit(static_cast<unsigned char>(text[i + 1])) && text[i + 2] == '}') {
					out += "%." + std::string(1, text[i + 1]) + "f";
					number = true;
					i += 2;
				} else if (text[i] == '%') {
					out += "%%";
				} else {
					out += text[i];
				}
			}
			return number ? out : out + " %.0f";
		}

		void TakeSnapshot()
		{
			const auto mcm = Bridge::Find(Forms::Get().main, "SLS_Mcm");
			if (!mcm) {
				return;
			}
			Snapshot snap;
			for (const auto& page : g_pages) {
				for (const auto& o : page.items) {
					if (o.read.kind == Read::Kind::kSu) {
						continue;  // answered by SuCallback
					}
					if (const auto value = Eval(o.read, mcm)) {
						snap.values[o.id] = *value;
					}
					if (o.type == Type::kMenu) {
						snap.menus[o.id] = MenuItems(o.read, mcm);
					}
				}
			}
			snap.hardLocked = Bridge::GetBool(mcm, "IsHardcoreLocked").value_or(false);
			snap.loaded = true;
			std::scoped_lock lock(g_snapLock);
			for (auto& [id, value] : g_snap.values) {
				if (!snap.values.contains(id)) {
					snap.values[id] = value;  // keep StorageUtil answers
				}
			}
			g_snap = std::move(snap);
		}

		// ---- remembered settings ----

		// key of the a_index-th entry of a page capture (loop-built pages have no static options)
		std::string CaptureKey(size_t a_page, const std::vector<CapItem>& a_items, size_t a_index)
		{
			const auto& c = a_items[a_index];
			const auto  base = g_pages[a_page].id + "|" + std::string(1, c.type) + "|" + Lower(c.label);
			int         k = 0;
			for (size_t i = 0; i < a_index; ++i) {
				if (a_items[i].type == c.type && Lower(a_items[i].label) == Lower(c.label)) {
					++k;
				}
			}
			return base + "#" + std::to_string(k);
		}

		// 1 female, 0 male, -1 not known yet (a new game before RaceMenu still has the default male player base)
		int PlayerSex()
		{
			if (g_replay == Replay::kWaitRaceMenu) {
				return -1;
			}
			const auto* player = RE::PlayerCharacter::GetSingleton();
			const auto* base = player ? player->GetActorBase() : nullptr;
			return base ? (base->GetSex() == RE::SEX::kFemale ? 1 : 0) : -1;
		}

		// read once at kDataLoaded; a broken file is reported and ignored, never half-used
		void LoadProfile()
		{
			std::ifstream file(kProfilePath);
			if (!file) {
				logger::info("menu: no remembered settings yet ({})", kProfilePath.string());
				return;
			}
			try {
				const auto root = json::parse(file);
				std::map<std::string, float> read[2];
				for (int sex = 0; sex < 2; ++sex) {
					for (const auto& [k, v] : root.value(sex ? "female" : "male", json::object()).items()) {
						if (v.is_number()) {
							read[sex][k] = v.get<float>();
						}
					}
				}
				std::scoped_lock lock(g_profLock);
				g_profile[0] = std::move(read[0]);
				g_profile[1] = std::move(read[1]);
				logger::info("menu: remembered settings: {} female, {} male", g_profile[1].size(), g_profile[0].size());
			} catch (const std::exception& e) {
				logger::error("menu: {} is invalid, remembered settings ignored: {}", kProfilePath.string(), e.what());
			}
		}

		// written in place (not via a temp file + rename): under MO2 the existing file stays in the mod that holds it
		void SaveProfile()
		{
			json root;
			{
				std::scoped_lock lock(g_profLock);
				root["version"] = 1;
				root["female"] = g_profile[1];
				root["male"] = g_profile[0];
			}
			std::ofstream file(kProfilePath, std::ios::trunc);
			if (!file) {
				logger::warn("menu: could not write {}", kProfilePath.string());
				return;
			}
			file << root.dump(1, '\t') << '\n';
		}

		// ---- apply: through the MCM's own SkyUI handlers, after the menu closed ----

		// An option ID no SkyUI page uses (pages give (page+1)*256 + position with position < 128), unique per option,
		// so a stale OID left in another option's variable can never match first.
		std::int32_t FreshOid(int a_id) { return 0x40000000 + a_id; }

		void Apply()
		{
			std::map<int, Pending> pending;
			{
				std::scoped_lock lock(g_pendLock);
				pending.swap(g_pending);
			}
			if (pending.empty()) {
				return;
			}
			const auto mcm = Bridge::Find(Forms::Get().main, "SLS_Mcm");
			if (!mcm) {
				logger::warn("menu: SLS_Mcm not found, {} change(s) dropped", pending.size());
				return;
			}
			std::vector<RE::BSFixedString> pages, suKeys;
			std::vector<std::int32_t>      kinds, oids;
			std::vector<float>             values;
			std::map<std::string, float>   remember;  // what the player chose, by key (buttons are actions, not settings)
			// a toggle's wanted state: the checkbox state, or - drawn as a button while its state was unknown - the
			// current state flipped once per press
			const auto wanted = [](const Pending& a_p, std::optional<float> a_current) -> std::optional<float> {
				if (a_p.presses == 0) {
					return a_p.value != 0.0f ? 1.0f : 0.0f;
				}
				if (!a_current) {
					return std::nullopt;
				}
				return ((*a_current != 0.0f) != (a_p.presses % 2 == 1)) ? 1.0f : 0.0f;
			};
			for (const auto& [id, p] : pending) {
				if (id >= kDynIdBase) {
					// an option of a loop-built page: its OID is the one the capture handed the page code, which the
					// page code stored where its handlers look for it
					const auto pageIdx = static_cast<size_t>((id - kDynIdBase) / 1024);
					const auto capIdx = static_cast<size_t>((id - kDynIdBase) % 1024);
					CapItem     c;
					std::string key;
					{
						std::scoped_lock lock(g_capLock);
						if (pageIdx >= g_caps.size() || capIdx >= g_caps[pageIdx].items.size()) {
							continue;
						}
						c = g_caps[pageIdx].items[capIdx];
						key = CaptureKey(pageIdx, g_caps[pageIdx].items, capIdx);
					}
					std::int32_t kind = 0;
					float        value = p.value;
					if (c.type == 'G') {
						const float current = ParseFloat(c.value).value_or(0.0f);
						const auto  want = wanted(p, current);
						remember[key] = *want;
						if ((current != 0.0f) == (*want != 0.0f)) {
							continue;
						}
						value = *want;
					} else if (c.type == 'S') {
						kind = 1;
					} else if (c.type == 'M') {
						kind = 2;
					} else if (c.type == 'K') {
						kind = 3;
					} else if (c.type != 'T') {
						continue;
					}
					if (kind != 0) {
						remember[key] = value;
					}
					pages.emplace_back(g_pages[pageIdx].id);
					suKeys.emplace_back("");
					kinds.push_back(kind);
					oids.push_back(c.oid);
					values.push_back(value);
					logger::info("menu: apply \"{}\" ({}) = {}", Translate(c.label), g_pages[pageIdx].title, value);
					continue;
				}
				const auto where = g_where.find(id);
				if (where == g_where.end()) {
					continue;
				}
				const auto& page = g_pages[where->second.first];
				const auto& o = page.items[where->second.second];
				const auto   key = g_keyOf.find(id);
				std::int32_t kind = 0;
				switch (o.type) {
				case Type::kToggle:
					{
						// the handler flips the stored value: call it only if the state the player chose differs
						auto current = Eval(o.read, mcm);
						if (!current) {
							std::scoped_lock lock(g_capLock);
							const auto& cap = g_caps[where->second.first];
							if (const auto m = cap.byOption.find(id); m != cap.byOption.end()) {
								current = ParseFloat(cap.items[m->second].value);
							}
						}
						const auto want = wanted(p, current);
						if (want && key != g_keyOf.end()) {
							remember[key->second] = *want;
						}
						if (!current) {
							if (p.presses % 2 == 0) {  // state unknown: only an odd number of presses means "switch"
								if (p.presses == 0) {
									logger::warn("menu: \"{}\": current state unknown, not switched", o.label);
								}
								continue;
							}
						} else if ((*current != 0.0f) == (*want != 0.0f)) {
							continue;
						}
						kind = 0;
						break;
					}
				case Type::kButton:
					kind = 0;
					break;
				case Type::kSlider:
					kind = 1;
					break;
				case Type::kMenu:
					kind = 2;
					break;
				case Type::kKeyMap:
					kind = 3;
					break;
				default:
					continue;
				}
				if (o.type != Type::kToggle && o.type != Type::kButton && key != g_keyOf.end()) {
					remember[key->second] = p.value;
				}
				const auto oid = FreshOid(id);
				if (!o.oidVar.empty() && !Bridge::SetInt(mcm, o.oidVar, oid)) {
					logger::warn("menu: \"{}\": OID variable {} not found, skipped", o.label, o.oidVar);
					continue;
				}
				pages.emplace_back(page.id);
				suKeys.emplace_back(o.oidSu);
				kinds.push_back(kind);
				oids.push_back(oid);
				values.push_back(p.value);
				logger::info("menu: apply \"{}\" ({}) = {}", o.label, page.title, p.value);
			}
			if (!g_replaying && !remember.empty()) {
				if (const int sex = PlayerSex(); sex >= 0) {
					{
						std::scoped_lock lock(g_profLock);
						for (const auto& [k, v] : remember) {
							g_profile[sex][k] = v;
						}
					}
					SaveProfile();
					logger::info("menu: remembered {} setting(s) for new games ({})", remember.size(), sex ? "female" : "male");
				} else {
					logger::info("menu: player sex not chosen yet (before RaceMenu), {} setting(s) not remembered", remember.size());
				}
			}
			if (kinds.empty()) {
				return;
			}
			// one call: the MCM runs the handlers in order, then its own OnConfigClose (deferred Do* flags)
			if (!Bridge::Call(mcm, "SLSFW_ApplyBatch", std::move(pages), std::move(kinds), std::move(oids), std::move(suKeys), std::move(values))) {
				logger::warn("menu: SLSFW_ApplyBatch dispatch failed");
			}
			ForgetCaptures();  // the values changed: the next open draws fresh pages
		}

		// ---- new game: apply the remembered list for the chosen sex (main thread, menu closed) ----
		void ReplayTick(float a_seconds)
		{
			if (g_replay == Replay::kWaitRaceMenu) {
				auto* ui = RE::UI::GetSingleton();
				if (ui && ui->IsMenuOpen(RE::RaceSexMenu::MENU_NAME)) {
					g_raceSeen = true;
					return;
				}
				if (!g_raceSeen) {
					return;
				}
				g_replay = Replay::kIdle;
				const int sex = PlayerSex();
				std::map<std::string, float> list;
				if (sex >= 0) {
					std::scoped_lock lock(g_profLock);
					list = g_profile[sex];
				}
				if (list.empty()) {
					logger::info("menu: new game - no remembered settings for this sex");
					return;
				}
				// read every page a remembered option is on: toggles kept in StorageUtil and loop-built pages are
				// known only from the page capture
				ForgetCaptures();
				g_replayPages.clear();
				for (size_t p = 0; p < g_pages.size(); ++p) {
					const auto prefix = g_pages[p].id + "|";
					if (std::ranges::any_of(list, [&](const auto& e) { return e.first.starts_with(prefix); })) {
						g_replayPages.push_back(static_cast<int>(p));
						RequestCaptureFor(static_cast<int>(p));
					}
				}
				g_replayWait = 0.0f;
				g_replay = Replay::kCapturing;
				logger::info("menu: new game - applying {} remembered setting(s) ({}), reading {} page(s)", list.size(),
					sex ? "female" : "male", g_replayPages.size());
				return;
			}
			if (g_replay != Replay::kCapturing) {
				return;
			}
			g_replayWait += a_seconds;
			bool done = true;
			{
				std::scoped_lock lock(g_capLock);
				for (const int p : g_replayPages) {
					done = done && g_caps[p].done;
				}
			}
			if (!done && g_replayWait < 60.0f) {  // pages are read one at a time
				return;
			}
			g_replay = Replay::kIdle;
			if (!done) {
				logger::warn("menu: new game - some pages were not read in 60 s, their remembered options may be skipped");
			}
			const int                    sex = PlayerSex();
			std::map<std::string, float> list;
			{
				std::scoped_lock lock(g_profLock);
				list = g_profile[sex > 0 ? 1 : 0];
			}
			std::map<int, Pending> replay;
			size_t                 unknown = 0;
			for (const auto& [key, value] : list) {
				if (const auto it = g_idOf.find(key); it != g_idOf.end()) {
					replay[it->second] = Pending{ value, 0 };
					continue;
				}
				bool found = false;
				for (const int p : g_replayPages) {
					if (!g_pages[p].dynamic || !key.starts_with(g_pages[p].id + "|")) {
						continue;
					}
					std::scoped_lock lock(g_capLock);
					const auto&      items = g_caps[p].items;
					for (size_t i = 0; i < items.size() && !found; ++i) {
						if (CaptureKey(static_cast<size_t>(p), items, i) == key) {
							replay[kDynIdBase + p * 1024 + static_cast<int>(i)] = Pending{ value, 0 };
							found = true;
						}
					}
				}
				if (!found) {
					++unknown;
					logger::info("menu: new game - remembered option \"{}\" is not in this menu, skipped", key);
				}
			}
			{
				// Tick applied anything the player queued before this runs; a newer own change would still win
				std::scoped_lock lock(g_pendLock);
				for (const auto& [id, p] : replay) {
					g_pending.try_emplace(id, p);
				}
			}
			g_replaying = true;
			Apply();
			g_replaying = false;
			logger::info("menu: new game - remembered settings sent to SL Survival ({} not found)", unknown);
		}

		// ---- drawing (render thread) ----

		void Help(const std::string& a_text)
		{
			if (!a_text.empty() && ImGuiMCP::IsItemHovered()) {
				ImGuiMCP::SetTooltip("%s", a_text.c_str());
			}
		}

		// an option whose MCM handler asks for confirmation: the menu asks, the change is queued only on "Yes"
		struct Ask
		{
			int         id{ 0 };
			Pending     change;
			std::string label, info;
		};
		std::optional<Ask> g_ask;  // render thread only
		bool               g_askOpen{ false };

		void Queue(int a_id, const Pending& a_change, bool a_confirm, const std::string& a_label, const std::string& a_info)
		{
			if (a_confirm) {
				g_ask = Ask{ a_id, a_change, a_label, a_info };
				g_askOpen = true;
				return;
			}
			std::scoped_lock lock(g_pendLock);
			g_pending[a_id] = a_change;
		}

		void DrawAsk()
		{
			if (g_askOpen) {
				ImGuiMCP::OpenPopup("Confirm##slsfw");
				g_askOpen = false;
			}
			if (ImGuiMCP::BeginPopupModal("Confirm##slsfw", nullptr, 0)) {
				if (g_ask) {
					ImGuiMCP::TextWrapped("%s", g_ask->label.c_str());
					if (!g_ask->info.empty()) {
						ImGuiMCP::TextWrapped("%s", g_ask->info.c_str());
					}
					ImGuiMCP::TextDisabled("The MCM asks for confirmation before this change.");
				}
				if (ImGuiMCP::Button("Yes")) {
					if (g_ask) {
						std::scoped_lock lock(g_pendLock);
						g_pending[g_ask->id] = g_ask->change;
					}
					g_ask.reset();
					ImGuiMCP::CloseCurrentPopup();
				}
				ImGuiMCP::SameLine();
				if (ImGuiMCP::Button("No")) {
					g_ask.reset();
					ImGuiMCP::CloseCurrentPopup();
				}
				ImGuiMCP::EndPopup();
			}
		}

		// one interactive row: shared by the static options and the capture-only pages
		struct Row
		{
			int                      id{ 0 };
			Type                     type{ Type::kText };
			std::string              label, info, fmt;
			bool                     confirm{ false }, locked{ false };
			std::optional<float>     value;
			float                    min{ 0.0f }, max{ 100.0f }, step{ 1.0f }, def{ 0.0f };
			bool                     rangeKnown{ true };
			std::vector<std::string> items;
		};

		void DrawRow(const Row& r, const std::map<int, Pending>& a_pending)
		{
			ImGuiMCP::PushID(r.id);
			ImGuiMCP::BeginDisabled(r.locked);
			const auto  wait = a_pending.find(r.id);
			std::string label = r.label;
			if (wait != a_pending.end()) {
				label += "  *";
			}
			switch (r.type) {
			case Type::kToggle:
				if (r.value || (wait != a_pending.end() && wait->second.presses == 0)) {
					bool on = wait != a_pending.end() ? wait->second.value != 0.0f : *r.value != 0.0f;
					if (ImGuiMCP::Checkbox(label.c_str(), std::addressof(on))) {
						Queue(r.id, Pending{ on ? 1.0f : 0.0f, 0 }, r.confirm, r.label, r.info);
					}
				} else {
					const int   presses = wait != a_pending.end() ? wait->second.presses : 0;
					std::string text = label + (presses % 2 ? "  (will switch)" : "  (reading...)");
					if (ImGuiMCP::Button(text.c_str())) {
						Queue(r.id, Pending{ 0.0f, presses + 1 }, r.confirm, r.label, r.info);
					}
				}
				break;
			case Type::kSlider:
				if (!r.rangeKnown) {
					ImGuiMCP::TextDisabled("%s  (reading...)", label.c_str());
				} else {
					float v = wait != a_pending.end() ? wait->second.value : r.value.value_or(r.def);
					if (ImGuiMCP::SliderFloat(label.c_str(), std::addressof(v), r.min, r.max, r.fmt.c_str())) {
						if (r.step > 0.0f) {
							v = r.min + std::round((v - r.min) / r.step) * r.step;
						}
						v = std::clamp(v, r.min, r.max);
						Queue(r.id, Pending{ v, 0 }, r.confirm, r.label, r.info);
					}
					if (!r.value && wait == a_pending.end()) {
						ImGuiMCP::SameLine();
						ImGuiMCP::TextDisabled("(reading...)");
					}
				}
				break;
			case Type::kMenu:
				{
					const int   count = static_cast<int>(r.items.size());
					const int   current = static_cast<int>(wait != a_pending.end() ? wait->second.value : r.value.value_or(-1.0f));
					const char* preview = current >= 0 && current < count ? r.items[current].c_str() : "?";
					if (count > 0 && ImGuiMCP::BeginCombo(label.c_str(), preview)) {
						for (int i = 0; i < count; ++i) {
							if (ImGuiMCP::Selectable(r.items[i].c_str(), i == current)) {
								Queue(r.id, Pending{ static_cast<float>(i), 0 }, r.confirm, r.label, r.info);
							}
						}
						ImGuiMCP::EndCombo();
					} else if (count == 0) {
						ImGuiMCP::TextDisabled("%s  (reading...)", label.c_str());
					}
					break;
				}
			case Type::kKeyMap:
				{
					int code = static_cast<int>(wait != a_pending.end() ? wait->second.value : r.value.value_or(0.0f));
					if (ImGuiMCP::InputInt(label.c_str(), std::addressof(code), 1, 10)) {
						Queue(r.id, Pending{ static_cast<float>(std::clamp(code, 0, 255)), 0 }, r.confirm, r.label, r.info);
					}
					break;
				}
			case Type::kButton:
				{
					const bool queued = wait != a_pending.end();
					if (ImGuiMCP::Button(queued ? (r.label + "  (queued)").c_str() : r.label.c_str()) && !queued) {
						Queue(r.id, Pending{ 0.0f, 1 }, r.confirm, r.label, r.info);
					}
					break;
				}
			default:
				break;
			}
			ImGuiMCP::EndDisabled();
			Help(r.info);
			ImGuiMCP::PopID();
		}

		void DrawPage(size_t a_page)
		{
			if (a_page >= g_pages.size()) {
				return;
			}
			g_lastDrawMs = NowMs();
			const auto& page = g_pages[a_page];
			Snapshot     snap;
			{
				std::scoped_lock lock(g_snapLock);
				snap = g_snap;
			}
			std::map<int, Pending> pending;
			{
				std::scoped_lock lock(g_pendLock);
				pending = g_pending;
			}
			Capture cap;
			{
				std::scoped_lock lock(g_capLock);
				if (a_page < g_caps.size()) {
					cap = g_caps[a_page];
				}
			}
			if (!cap.requested) {
				g_capWant = static_cast<int>(a_page);  // the main thread asks the MCM for this page
			}
			if (!snap.loaded) {
				ImGuiMCP::TextDisabled("Reading SL Survival settings...");
				return;
			}
			ImGuiMCP::TextDisabled("Changes are applied when this menu closes. %zu waiting.", pending.size());
			ImGuiMCP::TextDisabled("They are also remembered and applied on every new game after RaceMenu (UserSettings.json).");
			ImGuiMCP::Separator();

			if (page.dynamic) {
				if (!cap.done) {
					ImGuiMCP::TextDisabled("Reading this page from SL Survival...");
				}
				for (int i = 0; i < static_cast<int>(cap.items.size()); ++i) {
					const auto& c = cap.items[i];
					if (c.flags & 2) {
						continue;  // OPTION_FLAG_HIDDEN
					}
					const auto label = Translate(c.label);
					if (c.type == 'H') {
						ImGuiMCP::SeparatorText(label.c_str());
						continue;
					}
					if (c.type == 'E') {
						continue;
					}
					if (c.type == 'T') {
						ImGuiMCP::Text("%s: %s", label.c_str(), Translate(c.value).c_str());
						continue;
					}
					Row r;
					r.id = kDynIdBase + static_cast<int>(a_page) * 1024 + i;
					r.type = c.type == 'G' ? Type::kToggle : c.type == 'S' ? Type::kSlider : c.type == 'M' ? Type::kMenu : c.type == 'K' ? Type::kKeyMap : Type::kText;
					if (r.type == Type::kText) {
						continue;
					}
					r.label = label;
					r.info = Translate(c.info);
					r.locked = (c.flags & 1) != 0;
					r.value = r.type == Type::kMenu ? c.start : ParseFloat(c.value);
					r.fmt = SkyFormat(c.fmt);
					r.min = c.min.value_or(0.0f);
					r.max = c.max.value_or(100.0f);
					r.step = c.step.value_or(1.0f);
					r.def = c.def.value_or(r.min);
					r.rangeKnown = r.type != Type::kSlider || (c.min && c.max);
					r.items = c.items;
					DrawRow(r, pending);
				}
				DrawAsk();
				return;
			}

			for (const auto& o : page.items) {
				if (o.type == Type::kText) {
					ImGuiMCP::SeparatorText(o.label.c_str());
					continue;
				}
				const CapItem* c = nullptr;
				if (const auto m = cap.byOption.find(o.id); m != cap.byOption.end()) {
					c = std::addressof(cap.items[m->second]);
				}
				if (c && (c->flags & 2)) {
					continue;  // the page hides it right now (OPTION_FLAG_HIDDEN)
				}
				Row r;
				r.id = o.id;
				r.type = o.type;
				r.label = o.label;
				r.info = o.info;
				r.confirm = o.confirm;
				r.fmt = o.fmt;
				r.min = o.min;
				r.max = o.max;
				r.step = o.step;
				r.def = o.def;
				const bool hardLocked = o.hard && snap.hardLocked;
				r.locked = hardLocked || (c && (c->flags & 1));
				if (const auto known = snap.values.find(o.id); known != snap.values.end()) {
					r.value = known->second;
				} else if (c) {
					r.value = o.type == Type::kMenu ? c->start : ParseFloat(c->value);
				}
				if (o.type == Type::kMenu) {
					if (const auto items = snap.menus.find(o.id); items != snap.menus.end() && !items->second.empty()) {
						r.items = items->second;
					} else if (c) {
						r.items = c->items;
					}
				}
				if (o.rangeRuntime) {
					r.rangeKnown = c && c->min && c->max;
					if (r.rangeKnown) {
						r.min = *c->min;
						r.max = *c->max;
						r.step = c->step.value_or(o.step);
						r.def = c->def.value_or(r.min);
					}
				}
				if (hardLocked) {
					r.info = "Locked by Hardcore mode.\n\n" + r.info;
				} else if (o.confirm) {
					r.info = "Asks for confirmation.\n\n" + r.info;
				}
				DrawRow(r, pending);
			}
			DrawAsk();
		}

		template <size_t N>
		void __stdcall PageFn()
		{
			DrawPage(N);
		}

		template <size_t... I>
		constexpr std::array<SKSEMenuFramework::Model::RenderFunction, sizeof...(I)> MakePageFns(std::index_sequence<I...>)
		{
			return { PageFn<I>... };
		}

		constexpr size_t kMaxPages = 24;
		constexpr auto   kPageFns = MakePageFns(std::make_index_sequence<kMaxPages>{});

		void __stdcall OnMenuEvent(SKSEMenuFramework::Model::EventType a_type)
		{
			if (a_type == SKSEMenuFramework::Model::EventType::kOpenMenu) {
				g_open = true;  // Tick does the open work, also when only page drawing shows the menu is open
			} else if (a_type == SKSEMenuFramework::Model::EventType::kCloseMenu) {
				g_open = false;
			}
		}

		Option ParseOption(const json& a_j)
		{
			Option o;
			const auto t = a_j.value("type", "text");
			o.type = t == "toggle" ? Type::kToggle : t == "slider" ? Type::kSlider : t == "menu" ? Type::kMenu : t == "keymap" ? Type::kKeyMap : t == "button" ? Type::kButton : Type::kText;
			o.id = a_j.value("id", 0);
			o.label = a_j.value("label", "");
			o.info = a_j.value("info", "");
			o.oidVar = a_j.value("oidVar", "");
			o.oidSu = a_j.value("oidSu", "");
			o.hard = a_j.value("hard", false);
			o.confirm = a_j.value("confirm", false);
			o.rangeRuntime = a_j.value("rangeRuntime", false);
			o.raw = a_j.value("raw", "");
			const auto ct = a_j.value("ctype", "?");
			o.ctype = ct.empty() ? '?' : ct[0];
			o.min = a_j.value("min", 0.0f);
			o.max = a_j.value("max", 100.0f);
			o.step = a_j.value("step", 1.0f);
			o.def = a_j.value("default", o.min);
			o.fmt = a_j.value("fmt", "%.0f");
			if (a_j.contains("read")) {
				o.read = ParseRead(a_j["read"]);
			}
			return o;
		}
	}

	void Load()
	{
		if (!SKSEMenuFramework::IsInstalled()) {
			logger::info("menu: SKSE Menu Framework not installed, settings stay MCM-only");
			return;
		}
		// the MCM hides itself whenever this menu is active: only claim that when SMF can really show our pages
		using namespace SKSEMenuFramework::Model;
		const bool hasSection = Internal::GetFunction<AddSectionItemFunction>("AddSectionItem") != nullptr;
		const bool hasEvents = Internal::GetFunction<RegisterEventFuction>("RegisterEventPriority") != nullptr;
		logger::info("menu: SKSE Menu Framework {:.2f}, sections {}, open/close events {}", SKSEMenuFramework::GetMenuFrameworkVersion(),
			hasSection ? "yes" : "NO", hasEvents ? "yes" : "no (pages detect the open menu themselves)");
		if (!hasSection) {
			logger::warn("menu: this SKSE Menu Framework cannot add sections - settings stay in the MCM (update SKSE Menu Framework)");
			return;
		}
		const std::filesystem::path path{ "Data/SKSE/Plugins/SLSurvivalFramework/Menu.json" };
		std::ifstream               file(path);
		if (!file) {
			logger::warn("menu: {} not found", path.string());
			return;
		}
		try {
			const auto root = json::parse(file);
			for (const auto& [k, v] : root.value("strings", json::object()).items()) {
				g_strings[k] = v.get<std::string>();
			}
			for (const auto& p : root.at("pages")) {
				Page page;
				page.id = p.value("id", "");
				page.title = p.value("title", page.id);
				page.dynamic = p.value("dynamic", false);
				for (const auto& item : p.at("items")) {
					page.items.push_back(ParseOption(item));
				}
				g_pages.push_back(std::move(page));
			}
		} catch (const std::exception& e) {
			logger::error("menu: {} is invalid: {}", path.string(), e.what());
			g_pages.clear();
			return;
		}
		if (g_pages.size() > kMaxPages) {
			g_pages.resize(kMaxPages);
		}
		g_caps.resize(g_pages.size());
		size_t options = 0;
		for (size_t p = 0; p < g_pages.size(); ++p) {
			std::map<std::string, int> seen;
			for (size_t i = 0; i < g_pages[p].items.size(); ++i) {
				const auto& o = g_pages[p].items[i];
				if (o.type == Type::kText) {
					continue;
				}
				g_where[o.id] = { p, i };
				++options;
				if (o.type != Type::kButton && !o.raw.empty()) {
					const auto base = g_pages[p].id + "|" + std::string(1, o.ctype) + "|" + Lower(o.raw);
					const auto key = base + "#" + std::to_string(seen[base]++);
					g_keyOf[o.id] = key;
					g_idOf[key] = o.id;
				}
			}
		}
		LoadProfile();
		SKSEMenuFramework::SetSection("SL Survival");
		for (size_t p = 0; p < g_pages.size(); ++p) {
			SKSEMenuFramework::AddSectionItem(g_pages[p].title, kPageFns[p]);
		}
		static auto* event = SKSEMenuFramework::AddEvent(OnMenuEvent, 0.0f);
		(void)event;
		logger::info("menu: {} pages, {} options", g_pages.size(), options);
	}

	bool Active() { return !g_pages.empty(); }

	void Tick(float a_seconds)
	{
		if (g_pages.empty() || !Session::Settled()) {
			return;
		}
		const bool visible = g_open || NowMs() - g_lastDrawMs < 500;
		if (visible && !g_visible) {
			g_suDue = true;
			ForgetCaptures();  // values may have changed in play since the last open
			g_sinceSnapshot = 1.0f;
		}
		if (!visible && g_visible) {
			g_open = false;  // a close event SMF never sent must not keep the menu "open"
		}
		g_visible = visible;
		if (visible) {
			g_sinceSnapshot += a_seconds;
			if (g_sinceSnapshot >= 0.25f) {
				g_sinceSnapshot = 0.0f;
				TakeSnapshot();
			}
			if (g_suDue.exchange(false)) {
				ReadStorageUtil();
			}
			PumpCaptures(a_seconds);
			return;
		}
		Apply();
		PumpCaptures(a_seconds);
		ReplayTick(a_seconds);
	}

	void OnNewGame()
	{
		g_replay = Replay::kWaitRaceMenu;
		g_raceSeen = false;
	}

	void OnLoaded() { g_replay = Replay::kIdle; }
}
