class ITL_TypeLibWrapper
{
	__New(lib)
	{
		static valid_typekinds := "", VT_USERDEFINED := 29, MEMBERID_NIL := -1
			, TYPEKIND_ENUM := 0, TYPEKIND_RECORD := 1, TYPEKIND_MODULE := 2, TYPEKIND_INTERFACE := 3, TYPEKIND_COCLASS := 5, TYPEKIND_ALIAS := 6
		local typeKind := -1, hr, typeName, obj, typeInfo := 0, attr := 0, vt, mappings := [], refInfo := 0, hrefType, refAttr := 0, refKind, typeLibName, alias := ""

		if (!IsObject(valid_typekinds)) ; init static field
		{
			 valid_typekinds := { (TYPEKIND_ENUM)		: ITL.ITL_EnumWrapper
								, (TYPEKIND_RECORD)		: ITL.ITL_StructureWrapper
								, (TYPEKIND_MODULE)		: ITL.ITL_ModuleWrapper
								, (TYPEKIND_INTERFACE)	: ITL.ITL_InterfaceWrapper
								, (TYPEKIND_COCLASS)	: ITL.ITL_CoClassWrapper }
		 }

		if (this != ITL.ITL_TypeLibWrapper)
		{
			ObjInsert(this, "__New", Func("ITL_AbstractClassConstructor"))
			this[ITL.Properties.LIB_TYPELIB] := lib
			typeLibName := this[ITL.Properties.LIB_NAME] := this.GetName()

			Loop % DllCall(NumGet(NumGet(lib+0), 03*A_PtrSize, "Ptr"), "Ptr", lib, "Int") ; ITypeLib::GetTypeInfoCount()
			{
				hr := DllCall(NumGet(NumGet(lib+0), 05*A_PtrSize, "Ptr"), "Ptr", lib, "UInt", A_Index - 1, "UInt*", typeKind, "Int") ; ITypeLib::GetTypeKind()
				if (ITL_FAILED(hr) || typeKind == -1)
				{
					throw Exception(ITL_FormatException("Failed to wrap type library """ typeLibName """."
													, "Type information kind no. " A_Index - 1 " could not be read."
													, ErrorLevel, hr
													, typeKind == -1, "Invalid TYPEKIND: " typeKind)*)
				}

				if (!valid_typekinds.HasKey(typeKind) && typeKind != TYPEKIND_ALIAS)
				{
					ObjRelease(typeInfo), typeKind := -1, typeName := "", typeInfo := 0
					continue
				}

				hr := DllCall(NumGet(NumGet(lib+0), 04*A_PtrSize, "Ptr"), "Ptr", lib, "UInt", A_Index - 1, "Ptr*", typeInfo, "Int") ; ITypeLib::GetTypeInfo()
				if (ITL_FAILED(hr) || !typeInfo)
				{
					throw Exception(ITL_FormatException("Failed to wrap type library """ typeLibName """."
													, "Type information no. " A_Index - 1 " could not be read."
													, ErrorLevel, hr
													, !typeInfo, "Invalid ITypeInfo pointer: " typeInfo)*)
				}

				typeName := this.GetName(A_Index - 1)
				if (typeKind == TYPEKIND_ALIAS)
				{
					;MsgBox %typeName% is an alias...
					hr := DllCall(NumGet(NumGet(typeInfo+0), 03*A_PtrSize, "Ptr"), "Ptr", typeInfo, "Ptr*", attr, "Int") ; ITypeInfo::GetTypeAttr()
					if (ITL_FAILED(hr) || !attr)
					{
						throw Exception(ITL_FormatException("Failed to wrap type library """ typeLibName """."
														, "ITypeInfo::GetTypeAttr() for type """ typeName """ failed."
														, ErrorLevel, hr
														, !attr, "Invalid TYPEATTR pointer: " attr)*)
					}

					vt := NumGet(1*attr, 56 + 2*A_PtrSize, "UShort") ; TYPEATTR::tdescAlias::vt
					if (vt == VT_USERDEFINED)
					{
						hrefType := NumGet(1*attr, 56 + A_PtrSize, "UInt")
						hr := DllCall(NumGet(NumGet(typeInfo+0), 14*A_PtrSize, "Ptr"), "Ptr", typeInfo, "UInt", hrefType, "Ptr*", refInfo) ; ITypeInfo::GetRefTypeInfo()
						if (ITL_FAILED(hr) || !refInfo)
						{
							throw Exception(ITL_FormatException("Failed to wrap type library """ typeLibName """."
															, "ITypeInfo::GetRefTypeInfo() for type """ typeName """ failed."
															, ErrorLevel, hr
															, !refInfo, "Invalid ITypeInfo pointer: " refInfo)*)
						}

						hr := DllCall(NumGet(NumGet(refInfo+0), 03*A_PtrSize, "Ptr"), "Ptr", refInfo, "Ptr*", refAttr, "Int") ; ITypeInfo::GetTypeAttr()
						if (ITL_FAILED(hr) || !refAttr)
						{
							throw Exception(ITL_FormatException("Failed to wrap type library """ typeLibName """."
															, "ITypeInfo::GetTypeAttr() for type """ typeName """ failed."
															, ErrorLevel, hr
															, !refAttr, "Invalid TYPEATTR pointer: " refAttr)*)
						}

						refKind := NumGet(1*attr, 36+A_PtrSize, "UInt") ; TYPEATTR::typekind
						if (valid_typekinds.HasKey(refKind))
						{
							mappings.Insert(typeName, refInfo)
						}

						DllCall(NumGet(NumGet(refInfo+0), 19*A_PtrSize, "Ptr"), "Ptr", refInfo, "Ptr", refAttr) ; ITypeInfo::ReleaseTypeAttr()
						, ObjRelease(refInfo)
						, refInfo := 0, refAttr := 0
					}

					DllCall(NumGet(NumGet(typeInfo+0), 19*A_PtrSize, "Ptr"), "Ptr", typeInfo, "Ptr", attr) ; ITypeInfo::ReleaseTypeAttr()
					, ObjRelease(typeInfo)
					, attr := 0
				}
				else
				{
					obj := valid_typekinds[typeKind], this[typeName] := new obj(typeInfo, this)
				}
				typeName := "", typeInfo := 0, typeKind := -1
			}

			for alias, typeInfo in mappings
			{
				hr := DllCall(NumGet(NumGet(typeInfo+0), 12*A_PtrSize, "Ptr"), "Ptr", typeInfo, "Int", MEMBERID_NIL, "Ptr*", typeName, "Int")
				if (ITL_FAILED(hr) || !typeName)
				{
					throw Exception(ITL_FormatException("Failed to wrap type library """ typeLibName """."
													, "ITypeInfo::GetDocumentation() for an alias failed."
													, ErrorLevel, hr
													, !typeName, "Invalid type name pointer: " typeName)*)
				}
				this[alias] := this[StrGet(typeName)]
				ObjRelease(typeInfo)
			}
		}
	}

	GetName(index = -1)
	{
		local hr, name := 0, lib

		lib := this[ITL.Properties.LIB_TYPELIB]
		hr := DllCall(NumGet(NumGet(lib+0), 09*A_PtrSize, "Ptr"), "Ptr", lib, "UInt", index, "Ptr*", name, "Ptr*", 0, "UInt*", 0, "Ptr*", 0, "Int") ; ITypeLib::GetDocumentation()
		if (ITL_FAILED(hr) || !name)
		{
			throw Exception(ITL_FormatException("The name for the " (index == -1 ? "type library" : "type description no. " index) " could not be read."
											, "ITypeLib::GetDocumentation() failed."
											, ErrorLevel, hr
											, !name, "Invalid name pointer: " name)*)
		}

		return StrGet(name, "UTF-16")
	}

	GetGUID(obj = -1, returnRaw = false, passRaw = false)
	{
		local hr, guid, lib, info, attr := 0, result

		lib := this[ITL.Properties.LIB_TYPELIB]
		if obj is not integer
		{
			if (!IsObject(obj)) ; it's a string, a field name
				obj := this[obj]

			if (IsObject(obj)) ; a field, either passed directly or via name
			{
				if obj[ITL.Properties.TYPE_GUID] ; if it's already stored, do not retrieve it again
				{
					if (!returnRaw)
						return obj[ITL.Properties.TYPE_GUID]

					guid := ITL_Mem_Allocate(16)
					, ITL_GUID_FromString(obj[ITL.Properties.TYPE_GUID], attr)
					, ITL_Mem_Copy(&attr, guid, 16)
					return guid
				}
				info := obj[ITL.Properties.TYPE_TYPEINFO]
			}
			else
			{
				throw Exception(ITL_FormatException("A type GUID could not be read."
												, "The type wrapper object could not be retrieved."
												, ErrorLevel, ""
												, !IsObject(obj), "Not an object: """ obj """.")*)
			}
		}
		else if (obj != -1)
		{
			if (passRaw)
				info := obj ; also allow passing an ITypeInfo pointer directly
			else
			{
				hr := DllCall(NumGet(NumGet(lib+0), 04*A_PtrSize, "Ptr"), "Ptr", lib, "UInt", obj, "Ptr*", info, "Int") ; ITypeLib::GetTypeInfo()
				if (ITL_FAILED(hr) || !info)
				{
					throw Exception(ITL_FormatException("A type GUID could not be read."
													, "ITypeLib::GetTypeInfo() failed on index " obj "."
													, ErrorLevel, hr
													, !info, "Invalid ITypeInfo pointer: " info)*)
				}
			}
		}

		if (obj == -1)
		{
			hr := DllCall(NumGet(NumGet(lib+0), 07*A_PtrSize, "Ptr"), "Ptr", lib, "Ptr*", attr, "Int") ; ITypeLib::GetLibAttr()
			if (ITL_FAILED(hr) || !attr)
			{
				throw Exception(ITL_FormatException("The type library GUID could not be read."
													, "ITypeLib::GetLibAttr() failed."
													, ErrorLevel, hr
													, !attr, "Invalid TLIBATTR pointer: " attr)*)
			}

			guid := ITL_Mem_Allocate(16), ITL_Mem_Copy(attr, guid, 16) ; TLIBATTR::guid
			if (returnRaw)
				result := guid
			else
				result := ITL_GUID_ToString(guid), ITL_Mem_Release(guid)

			DllCall(NumGet(NumGet(lib+0), 12*A_PtrSize, "Ptr"), "Ptr", lib, "Ptr", attr) ; ITypeLib::ReleaseTLibAttr()
		}
		else
		{
			hr := DllCall(NumGet(NumGet(info+0), 03*A_PtrSize, "Ptr"), "Ptr", info, "Ptr*", attr, "Int") ; ITypeInfo::GetTypeAttr()
			if (ITL_FAILED(hr) || !attr)
			{
				throw Exception(ITL_FormatException("A type GUID could not be read."
												, "ITypeInfo::GetTypeAttr() failed."
												, ErrorLevel, hr
												, !attr, "Invalid TYPEATTR pointer: " attr)*)
			}

			guid := ITL_Mem_Allocate(16), ITL_Mem_Copy(attr, guid, 16) ; TYPEATTR::guid
			if (returnRaw)
				result := guid
			else
				result := ITL_GUID_ToString(guid), ITL_Mem_Release(guid)

			DllCall(NumGet(NumGet(info+0), 19*A_PtrSize, "Ptr"), "Ptr", info, "Ptr", attr, "Int") ; ITypeInfo::ReleaseTypeAttr()
		}

		return result
	}
}