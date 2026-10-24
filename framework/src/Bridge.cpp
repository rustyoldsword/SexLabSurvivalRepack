#include "Bridge.h"

namespace SLSFW::Bridge
{
	namespace
	{
		Object FindByHandle(RE::VMHandle a_handle, std::string_view a_script)
		{
			Object result;
			auto*  vm = VM();
			auto*  policy = vm ? vm->GetObjectHandlePolicy() : nullptr;
			if (!policy || a_handle == policy->EmptyHandle()) {
				return result;
			}
			vm->FindBoundObject(a_handle, std::string(a_script).c_str(), result);
			return result;
		}
	}

	RE::BSScript::Internal::VirtualMachine* VM()
	{
		return RE::BSScript::Internal::VirtualMachine::GetSingleton();
	}

	Object Find(const RE::TESForm* a_form, std::string_view a_script)
	{
		auto* vm = VM();
		auto* policy = vm ? vm->GetObjectHandlePolicy() : nullptr;
		if (!policy || !a_form) {
			return {};
		}
		return FindByHandle(policy->GetHandleForObject(a_form->GetFormType(), a_form), a_script);
	}

	Object Find(const RE::BGSBaseAlias* a_alias, std::string_view a_script)
	{
		auto* vm = VM();
		auto* policy = vm ? vm->GetObjectHandlePolicy() : nullptr;
		if (!policy || !a_alias) {
			return {};
		}
		return FindByHandle(policy->GetHandleForObject(a_alias->GetVMTypeID(), a_alias), a_script);
	}

	RE::BSScript::Variable* Var(const Object& a_object, std::string_view a_name)
	{
		if (!a_object) {
			return nullptr;
		}
		if (auto* var = a_object->GetVariable(RE::BSFixedString(a_name))) {
			return var;
		}
		return a_object->GetVariable(RE::BSFixedString(std::format("::{}_var", a_name)));
	}

	std::optional<float> GetFloat(const Object& a_object, std::string_view a_name)
	{
		const auto* var = Var(a_object, a_name);
		if (!var) {
			return std::nullopt;
		}
		if (var->IsFloat()) {
			return var->GetFloat();
		}
		if (var->IsInt()) {
			return static_cast<float>(var->GetSInt());
		}
		return std::nullopt;
	}

	std::optional<bool> GetBool(const Object& a_object, std::string_view a_name)
	{
		const auto* var = Var(a_object, a_name);
		if (!var) {
			return std::nullopt;
		}
		if (var->IsBool()) {
			return var->GetBool();
		}
		if (var->IsInt()) {
			return var->GetSInt() != 0;
		}
		return std::nullopt;
	}

	std::optional<std::int32_t> GetInt(const Object& a_object, std::string_view a_name)
	{
		const auto* var = Var(a_object, a_name);
		if (!var) {
			return std::nullopt;
		}
		if (var->IsInt()) {
			return var->GetSInt();
		}
		if (var->IsBool()) {
			return var->GetBool() ? 1 : 0;
		}
		return std::nullopt;
	}

	Object GetObject(const Object& a_object, std::string_view a_name)
	{
		const auto* var = Var(a_object, a_name);
		if (!var || !var->IsObject()) {
			return {};
		}
		return var->GetObject();
	}

	bool SetBool(const Object& a_object, std::string_view a_name, bool a_value)
	{
		auto* var = Var(a_object, a_name);
		if (!var || !var->IsBool()) {
			return false;
		}
		var->SetBool(a_value);
		return true;
	}

	std::string State(const Object& a_object)
	{
		return a_object ? std::string(a_object->currentState.c_str()) : std::string{};
	}
}
