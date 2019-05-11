class ITL_ModuleWrapper extends ITL.ITL_ConstantMemberWrapperBaseClass
{
	__New(typeInfo, lib)
	{
		local Base

		if (this != ITL.ITL_ModuleWrapper)
		{
			Base.__New(typeInfo, lib)
			ObjInsert(this, "__New", Func("ITL_AbstractClassConstructor"))
		}
	}

	__Call(method, params*)
	{
		static DISPID_UNKNOWN := -1, INVOKEKIND_FUNC := 1
		local id := DISPID_UNKNOWN, hr := 0, addr := 0, info

		info := this[ITL.Properties.TYPE_TYPEINFO]

		hr := DllCall(NumGet(NumGet(info+0), 10*A_PtrSize, "Ptr"), "Ptr", info, "Str*", method, "UInt", INVOKEKIND_FUNC, "Ptr*", id, "Int") ; ITypeInfo::GetIDsOfNames()
		if (ITL_FAILED(hr) || id == DISPID_UNKNOWN)
		{
			throw Exception(ITL_FormatException("Failed to call method """ method """ on module """ this[ITL.Properties.TYPE_NAME] """."
											, "ITypeInfo::GetIDsOfNames() failed."
											, ErrorLevel, hr
											, id == DISPID_UNKNOWN, "Invalid DISPID: " id)*)
		}

		hr := DllCall(NumGet(NumGet(info+0), 15*A_PtrSize, "Ptr"), "Ptr", info, "UInt", id, "UInt", 1, "Ptr*", addr, "Int") ; ITypeInfo::AddressOfMember()
		if (ITL_FAILED(hr) || !addr)
		{
			throw Exception(ITL_FormatException("Failed to call method """ method """ on module """ this[ITL.Properties.TYPE_NAME] """."
											, "ITypeInfo::AddressOfMember() failed."
											, ErrorLevel, hr
											, !addr, "Invalid member address: " addr)*)
		}

		return DllCall(addr, params*)
	}
}