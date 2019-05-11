class ITL_WrapperBaseClass
{
	__New(typeInfo, lib)
	{
		local hr, name := 0, typeInfo2
		static IID_ITypeInfo2 := "{00020412-0000-0000-C000-000000000046}"

		if (this != ITL.ITL_WrapperBaseClass)
		{
			this[ITL.Properties.TYPE_TYPELIBOBJ] := lib, ObjAddRef(lib[ITL.Properties.LIB_TYPELIB])

			hr := DllCall(NumGet(NumGet(typeInfo+0), 12*A_PtrSize, "Ptr"), "Ptr", typeInfo, "Int", -1, "Ptr*", name, "Ptr*", 0, "UInt*", 0, "Ptr*", 0, "Int") ; ITypeInfo::GetDocumentation()
			if (ITL_FAILED(hr) || !name)
			{
				throw Exception(ITL_FormatException("Failed to create a wrapper instance."
												, "ITypeInfo::GetDocumentation() failed."
												, ErrorLevel, hr
												, !name, "Invalid name pointer: " name)*)
			}

			this[ITL.Properties.TYPE_NAME] := StrGet(name, "UTF-16")
			this[ITL.Properties.TYPE_GUID] := lib.GetGUID(typeInfo, false, true)

			typeInfo2 := ComObjQuery(typeInfo, IID_ITypeInfo2)
			if (!typeInfo2)
			{
				throw Exception(ITL_FormatException("Failed to create a wrapper instance."
												, "QueryInterface() for ITypeInfo2 failed."
												, ErrorLevel, ""
												, !typeInfo2, "Invalid ITypeInfo2 pointer returned by ComObjQuery() : " typeInfo2)*)
			}
			this[ITL.Properties.TYPE_TYPEINFO] := typeInfo2, ObjAddRef(typeInfo2)
		}
	}

	__Delete()
	{
		ObjRelease(this[ITL.Properties.TYPE_TYPELIBOBJ][ITL.Properties.LIB_TYPELIB])
		, ObjRelease(this[ITL.Properties.TYPE_TYPEINFO])
	}
}