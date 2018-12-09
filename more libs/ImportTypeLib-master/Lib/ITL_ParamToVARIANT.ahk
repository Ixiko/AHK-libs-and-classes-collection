ITL_ParamToVARIANT(info, tdesc, value, byRef variant, index)
{
	static VT_PTR := 26, VT_USERDEFINED := 29, VT_VOID := 24, VT_BYREF := 0x4000, VT_RECORD := 36, VT_UNKNOWN := 13, VT_SAFEARRAY := 27
		, sizeof_VARIANT := 8 + 2 * A_PtrSize
		, TYPEKIND_RECORD := 1, TYPEKIND_INTERFACE := 3
	local hr, vt := NumGet(1*tdesc, A_PtrSize, "UShort"), converted := false, indirectionLevel := 0
		, refHandle, refInfo := 0, refAttr := 0, refKind

	VarSetCapacity(variant, sizeof_VARIANT, 00) ; init variant
	while (vt == VT_PTR)
	{
		tdesc := NumGet(1*tdesc, 00, "Ptr") ; TYPEDESC::lptdesc
		, vt := NumGet(1*tdesc, A_PtrSize, "UShort") ; TYPEDESC::vt
		, indirectionLevel++
	}

	if (vt == VT_USERDEFINED && IsObject(value) && !ITL_IsComObject(value)) ; a struct or interface wrapper was passed
	{
		NumPut(value[ITL.Properties.INSTANCE_POINTER], variant, 08, "Ptr") ; put instance pointer into VARIANT

		; get the type kind of the given wrapper:
		; =============================================
		refHandle := NumGet(1*tdesc, 00, "UInt") ; TYPEDESC::hreftype
		hr := DllCall(NumGet(NumGet(info+0), 14*A_PtrSize, "Ptr"), "Ptr", info, "UInt", refHandle, "Ptr*", refInfo, "Int") ; ITypeInfo::GetRefTypeInfo()
		if (ITL_FAILED(hr) || !refInfo)
		{
			throw Exception(ITL_FormatException("Failed to convert parameter #" index "."
											, "ITypeInfo::GetRefTypeInfo() (handle: " refHandle ") failed."
											, ErrorLevel, hr
											, !refInfo, "Invalid ITypeInfo pointer: " refInfo)*)
		}
		hr := DllCall(NumGet(NumGet(refInfo+0), 03*A_PtrSize, "Ptr"), "Ptr", refInfo, "Ptr*", refAttr, "Int") ; ITypeInfo::GetTypeAttr()
		if (ITL_FAILED(hr) || !refAttr)
		{
			throw Exception(ITL_FormatException("Failed to convert parameter #" index "."
											, "ITypeInfo::GetTypeAttr() failed."
											, ErrorLevel, hr
											, !refAttr, "Invalid TYPEATTR pointer: " refAttr)*)
		}
		refKind := NumGet(1*refAttr, 36+A_PtrSize, "UInt")
		; =============================================

		if (refKind == TYPEKIND_RECORD)
		{
			; if (indirectionLevel > 0)
			; 	...
			NumPut(VT_RECORD, variant, 00, "UShort")
			, NumPut(value.base[ITL.Properties.TYPE_RECORDINFO], variant, 08 + A_PtrSize, "Ptr")
		}
		else if (refKind == TYPEKIND_INTERFACE)
		{
			if (indirectionLevel < 1)
			{
				throw Exception(ITL_FormatException("Failed to convert parameter #" index "."
												, "Interfaces cannot be passed by value."
												, ErrorLevel, ""
												, indirectionLevel < 1, "Invalid indirection level: " indirectionLevel)*)
			}
			NumPut(VT_UNKNOWN, variant, 00, "UShort")
		}
		else
		{
			ObjRelease(refInfo) ; cleanup
			throw Exception(ITL_FormatException("Failed to convert parameter #" index "."
											, "Cannot handle other wrappers than interfaces and structures."
											, ErrorLevel, "")*)
		}
		ObjRelease(refInfo), refInfo := 0, refAttr := 0 ; cleanup
		converted := true
	}
	else if (!IsObject(value) && vt == VT_VOID && indirectionLevel == 1)
	{
		value := ComObjParameter(VT_BYREF, value)
	}
	else if (vt == VT_SAFEARRAY && indirectionLevel == 0)
	{
		; get the type of the SAFEARRAY elements:
		tdesc := NumGet(1*tdesc, 00, "Ptr") ; TYPEDESC::lptdesc
		, vt := NumGet(1*tdesc, A_PtrSize, "UShort") ; TYPEDESC::vt

		if (!IsObject(value)) ; a raw pointer was passed
		{
			value := ComObjParameter(VT_ARRAY|vt, value)
		}
		if (!ITL_IsComObject(value)) ; a normal AHK-array (or object)
		{
			value := ITL_ArrayToSafeArray(value, vt)
		}
		; (if it is already a COM wrapper object, do nothing)
	}
	; todo: handle arrays (native)

	if (!converted)
		ITL_VARIANT_Create(value, variant) ; create VARIANT

	; handle: VT_CARRAY, VT_I8, VT_LPSTR, VT_LPWSTR, VT_SAFEARRAY, VT_PTR, VT_UI8, ...
}