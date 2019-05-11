ITL_VARIANT_Create(value, byRef buffer)
{
	static VT_VARIANT := 0xC, sizeof_VARIANT := 8 + 2 * A_PtrSize
	local arr_data := 0, array := ComObjArray(VT_VARIANT, 1)

	array[0] := value

	DllCall("oleaut32\SafeArrayAccessData", "Ptr", ComObjValue(array), "Ptr*", arr_data)
	VarSetCapacity(buffer, 16, 00), ITL_Mem_Copy(arr_data, &buffer, sizeof_VARIANT)
	DllCall("oleaut32\SafeArrayUnaccessData", "Ptr", ComObjValue(array))

	return &buffer
}

ITL_VARIANT_GetValue(variant)
{
	static VT_VARIANT := 0xC, VT_UNKNOWN := 0xD
	local array := ComObjArray(VT_VARIANT, 1), vt := 0

	vt := NumGet(1*variant, 00, "UShort")
	array[0] := ComObjParameter(vt, NumGet(1*variant, 08, "Int64"))

	return vt == VT_UNKNOWN ? NumGet(1*variant, 08, "Ptr") : array[0]
}

ITL_VARIANT_MapType(variant)
{
	; handled types:
	static VT_EMPTY := 0, VT_NULL := 1, VT_BYREF := 0x4000, VT_I1 := 16, VT_UI1 := 17, VT_I2 := 2, VT_UI2 := 18, VT_I4 := 3, VT_BOOL := 0xB, VT_INT := 22, VT_ERROR := 0xA, VT_HRESULT := 25, VT_UI4 := 19, VT_UINT := 23, VT_I8 := 20, VT_UI8 := 21, VT_CY := 6, VT_R4 := 4, VT_R8 := 5, VT_BSTR := 0x8, VT_LPSTR := 30, VT_LPWSTR := 31, VT_DISPATCH := 9, VT_UNKNOWN := 13, VT_PTR := 26, VT_INT_PTR := 37, VT_UINT_PTR := 38

	; unhandled types:
	static VT_DATE := 7, VT_VARIANT := 12, VT_DECIMAL := 14, VT_VOID := 24, VT_SAFEARRAY := 27, VT_ARRAY := 0x2000, VT_CARRAY := 28, VT_USERDEFINED := 29, VT_RECORD := 36, VT_FILETIME := 64, VT_BLOB := 65, VT_STREAM := 66, VT_STORAGE := 67, VT_STREAMED_OBJECT := 68, VT_STORED_OBJECT := 69, VT_BLOB_OBJECT := 70, VT_CF := 71, VT_CLSID := 72, VT_VERSIONED_STREAM := 73, VT_BSTR_BLOB := 0xffff, VT_VECTOR := 0x1000

	static map := ""
	local vt := 0, suffix := "", type := ""

	; init static var:
	if (!IsObject(map))
	{
		map := {  (VT_I1)		: "Char",	(VT_UI1)	: "UChar"
				, (VT_I2)		: "Short",	(VT_UI2)	: "UShort"
				, (VT_I4)		: "Int",	(VT_BOOL)	: "Int",	(VT_INT)	: "Int",	(VT_HRESULT) : "Int", (VT_ERROR) : "Int", (VT_UI4) : "UInt", (VT_UINT) : "UInt"
				, (VT_I8)		: "Int64",	(VT_CY)		: "Int64",	(VT_UI8)	: "Int64"
				, (VT_R4)		: "Float",	(VT_R8)		: "Double"
				, (VT_BSTR)		: "WStr",	(VT_LPSTR)	: "Str",	(VT_LPWSTR) : "WStr"
				, (VT_DISPATCH)	: "Ptr",	(VT_UNKNOWN): "Ptr",	(VT_PTR)	: "Ptr",	(VT_INT_PTR) : "Ptr", (VT_UINT_PTR) : "UPtr" }
	}

	vt := NumGet(1*variant, 00, "UShort")
	if (ITL_HasEnumFlag(vt, VT_BYREF))
	{
		vt ^= VT_BYREF, suffix := "*" ; change this handling (?)
	}

	if (vt == VT_EMPTY || vt == VT_NULL)
		throw Exception("Cannot map type 'EMPTY' or 'NULL'.", -1)
	else if (map.HasKey(vt))
		return map[vt] . suffix

	throw Exception("Could not map type " vt ".", -1)
}

ITL_VARIANT_GetByteCount(variant)
{
	throw Exception("Could not retrieve byte count.", -1, "Not implemented.")
}