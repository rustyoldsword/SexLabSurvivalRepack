#pragma once

// Reading, writing and calling into SLS's own Papyrus objects. Main thread or VM thread only.
namespace SLSFW::Bridge
{
	using Object = RE::BSTSmartPointer<RE::BSScript::Object>;

	RE::BSScript::Internal::VirtualMachine* VM();

	// the script object bound to a form (quest, reference) or to an alias
	Object Find(const RE::TESForm* a_form, std::string_view a_script);
	Object Find(const RE::BGSBaseAlias* a_alias, std::string_view a_script);

	// a script variable; auto properties live in "::<Name>_var", which is tried second
	RE::BSScript::Variable* Var(const Object& a_object, std::string_view a_name);

	std::optional<float> GetFloat(const Object& a_object, std::string_view a_name);
	std::optional<bool>  GetBool(const Object& a_object, std::string_view a_name);
	std::optional<std::int32_t> GetInt(const Object& a_object, std::string_view a_name);
	Object               GetObject(const Object& a_object, std::string_view a_name);
	bool                 SetBool(const Object& a_object, std::string_view a_name, bool a_value);
	bool                 SetInt(const Object& a_object, std::string_view a_name, std::int32_t a_value);

	// the object's current Papyrus state ("" = empty state)
	std::string State(const Object& a_object);

	// fire-and-forget calls; arguments are taken by value (FunctionArguments stores decayed types) and copied
	// into the VM during dispatch
	template <class... Args>
	bool Call(Object a_object, std::string_view a_function, Args... a_args)
	{
		auto* vm = VM();
		if (!vm || !a_object) {
			return false;
		}
		std::unique_ptr<RE::BSScript::IFunctionArguments> args{ RE::MakeFunctionArguments(std::move(a_args)...) };
		RE::BSTSmartPointer<RE::BSScript::IStackCallbackFunctor> callback;
		return vm->DispatchMethodCall(a_object, RE::BSFixedString(a_function), args.get(), callback);
	}

	// Calls the engine has accepted but Papyrus has not finished yet. A sender that fires on a timer or on every event
	// (nudity relay, equip hub, curfew watch) checks it, so a script that is stuck - waiting on a lock, a Wait() in a
	// menu - is not handed a second, third... copy that piles up behind the first (cold audit 2026-10-31, item 13).
	// The count drops when the call returns; a count that has not moved for kStale ms is taken as lost (a load drops
	// the VM's pending stacks and their callbacks with them) and starts over.
	struct InFlight
	{
		std::atomic<std::int32_t>  count{ 0 };
		std::atomic<std::uint64_t> since{ 0 };    // GetTickCount64 when the oldest call still counted was sent
		std::atomic<std::uint32_t> skipped{ 0 };  // sends refused because the limit was reached
		static constexpr std::uint64_t kStale = 30000;
	};

	namespace detail
	{
		class InFlightDone final : public RE::BSScript::IStackCallbackFunctor
		{
		public:
			explicit InFlightDone(InFlight* a_flight) :
				_flight(a_flight) {}
			void operator()(RE::BSScript::Variable) override
			{
				auto n = _flight->count.load();
				while (n > 0 && !_flight->count.compare_exchange_weak(n, n - 1)) {}
			}
			void SetObject(const RE::BSTSmartPointer<RE::BSScript::Object>&) override {}

		private:
			InFlight* _flight;  // a static of the sender: outlives every call
		};
	}

	// Call(), unless a_limit calls of this sender are still running. False = not sent (refused or failed), so a
	// caller that retries on false (the nudity relay) simply tries again on its next tick.
	template <class... Args>
	bool CallTracked(InFlight& a_flight, std::int32_t a_limit, Object a_object, std::string_view a_function, Args... a_args)
	{
		auto* vm = VM();
		if (!vm || !a_object) {
			return false;
		}
		const auto now = GetTickCount64();
		if (a_flight.count.load() >= a_limit) {
			if (now - a_flight.since.load() < InFlight::kStale) {
				++a_flight.skipped;
				return false;
			}
			a_flight.count.store(0);  // lost callbacks
		}
		if (a_flight.count.fetch_add(1) == 0) {
			a_flight.since.store(now);
		}
		std::unique_ptr<RE::BSScript::IFunctionArguments> args{ RE::MakeFunctionArguments(std::move(a_args)...) };
		RE::BSTSmartPointer<RE::BSScript::IStackCallbackFunctor> callback{ new detail::InFlightDone(std::addressof(a_flight)) };
		if (!vm->DispatchMethodCall(a_object, RE::BSFixedString(a_function), args.get(), callback)) {
			--a_flight.count;
			return false;
		}
		return true;
	}

	template <class... Args>
	bool CallStatic(std::string_view a_class, std::string_view a_function, Args... a_args)
	{
		auto* vm = VM();
		if (!vm) {
			return false;
		}
		std::unique_ptr<RE::BSScript::IFunctionArguments> args{ RE::MakeFunctionArguments(std::move(a_args)...) };
		RE::BSTSmartPointer<RE::BSScript::IStackCallbackFunctor> callback;
		return vm->DispatchStaticCall(RE::BSFixedString(a_class), RE::BSFixedString(a_function), args.get(), callback);
	}
}
