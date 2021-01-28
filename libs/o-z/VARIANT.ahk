VARIANT_Create(value, byRef buffer)
{
	static VT_VARIANT := 0xC, sizeof_VARIANT := 8 + 2 * A_PtrSize
	local arr_data := 0, array := ComObjArray(VT_VARIANT, 1)

	array[0] := value

	DllCall("oleaut32\SafeArrayAccessData", "Ptr", ComObjValue(array), "Ptr*", arr_data)
	VarSetCapacity(buffer, 16, 00), Mem_Copy(arr_data, &buffer, sizeof_VARIANT)
	DllCall("oleaut32\SafeArrayUnaccessData", "Ptr", ComObjValue(array))

	return &buffer
}

VARIANT_GetValue(variant)
{
	static VT_VARIANT := 0xC, VT_UNKNOWN := 0xD
	local array := ComObjArray(VT_VARIANT, 1), vt := 0

	vt := NumGet(1*variant, 00, "UShort")
	array[0] := ComObjParameter(vt, NumGet(1*variant, 08, "Ptr"))

	return vt == VT_UNKNOWN ? NumGet(1*variant, 08, "Ptr") : array[0]
}