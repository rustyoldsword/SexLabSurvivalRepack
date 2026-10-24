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
