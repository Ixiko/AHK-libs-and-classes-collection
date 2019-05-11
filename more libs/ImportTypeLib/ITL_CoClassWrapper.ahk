class ITL_CoClassWrapper extends ITL.ITL_WrapperBaseClass
{
	__New(typeInfo, lib)
	{
		local hr, typeAttr := 0, implCount, implFlags := 0, implHref := -1, implInfo := 0, implAttr := 0, iid, Base, typeName
		static IMPLTYPEFLAG_FDEFAULT := 1

		if (this != ITL.ITL_CoClassWrapper)
		{
			Base.__New(typeInfo, lib)
			, ObjInsert(this, "__New", Func("ITL_CoClassConstructor"))
			, typeName := this[ITL.Properties.TYPE_NAME]

			; get default interface:
			; =======================================
			hr := DllCall(NumGet(NumGet(typeInfo+0), 03*A_PtrSize, "Ptr"), "Ptr", typeInfo, "Ptr*", typeAttr, "Int") ; ITypeInfo::GetTypeAttr()
			if (ITL_FAILED(hr) || !typeAttr)
			{
				throw Exception(ITL_FormatException("Failed to retrieve the default interface for the """ typeName """ class."
												, "ITypeInfo::GetTypeAttr() failed."
												, ErrorLevel, hr
												, !typeAttr, "Invalid TYPEATTR pointer: " typeAttr)*)
			}

			implCount := NumGet(1*typeAttr, 44+1*A_PtrSize, "UShort") ; TYPEATTR::cImplTypes
			Loop % implCount
			{
				hr := DllCall(NumGet(NumGet(typeInfo+0), 09*A_PtrSize, "Ptr"), "Ptr", typeInfo, "UInt", A_Index - 1, "UInt*", implFlags, "Int") ; ITypeInfo::GetImplTypeFlags()
				if (ITL_FAILED(hr))
				{
					throw Exception(ITL_FormatException("Failed to retrieve the default interface for the """ typeName """ class."
														, "ITypeInfo::GetImplTypeFlags() failed."
														, ErrorLevel, hr)*)
				}
				if (ITL_HasEnumFlag(implFlags, IMPLTYPEFLAG_FDEFAULT))
				{
					hr := DllCall(NumGet(NumGet(typeInfo+0), 08*A_PtrSize, "Ptr"), "Ptr", typeInfo, "UInt", A_Index - 1, "UInt*", implHref, "Int") ; ITypeInfo::GetRefTypeOfImplType()
					if (ITL_FAILED(hr) || implHref == -1)
					{
						throw Exception(ITL_FormatException("Failed to retrieve the default interface for the """ typeName """ class."
														, "ITypeInfo::GetRefTypeOfImplType() failed."
														, ErrorLevel, hr
														, implHref == -1, "Invalid HREFTYPE: " implHref)*)
					}

					hr := DllCall(NumGet(NumGet(typeInfo+0), 14*A_PtrSize, "Ptr"), "Ptr", typeInfo, "UInt", implHref, "Ptr*", implInfo, "Int") ; ITypeInfo::GetRefTypeInfo()
					if (ITL_FAILED(hr) || !implInfo)
					{
						throw Exception(ITL_FormatException("Failed to retrieve the default interface for the """ typeName """ class."
														, "ITypeInfo::GetRefTypeInfo() failed."
														, ErrorLevel, hr
														, !implInfo, "Invalid ITypeInfo pointer: " implInfo)*)
					}

					hr := DllCall(NumGet(NumGet(implInfo+0), 03*A_PtrSize, "Ptr"), "Ptr", implInfo, "Ptr*", implAttr, "Int") ; ITypeInfo::GetTypeAttr()
					if (ITL_FAILED(hr) || !implAttr)
					{
						throw Exception(ITL_FormatException("Failed to retrieve the default interface for the """ typeName """ class."
														, "ITypeInfo::GetTypeAttr() failed."
														, ErrorLevel, hr
														, !implAttr, "Invalid TYPEATTR pointer: " implAttr)*)
					}

					VarSetCapacity(iid, 16, 00)
					ITL_Mem_Copy(implAttr, &iid, 16) ; TYPEATTR::guid
					this[ITL.Properties.TYPE_DEFAULTINTERFACE] := ITL_GUID_ToString(&iid)

					DllCall(NumGet(NumGet(implInfo+0), 19*A_PtrSize, "Ptr"), "Ptr", implInfo, "Ptr", implAttr) ; ITypeInfo::ReleaseTypeAttr()
					break
				}
			}
			DllCall(NumGet(NumGet(typeInfo+0), 19*A_PtrSize, "Ptr"), "Ptr", typeInfo, "Ptr", typeAttr) ; ITypeInfo::ReleaseTypeAttr()
			; =======================================
		}
	}
}