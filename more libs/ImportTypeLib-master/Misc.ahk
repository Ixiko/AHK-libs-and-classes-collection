; various misc. helper functions, later to be sorted out to separate classes / libs / files.

ITL_IsSafeArray(obj)
{
	static VT_ARRAY := 0x2000
	local vt := 0
	return (IsObject(obj) && ITL_HasEnumFlag(ComObjType(obj), VT_ARRAY)) ; a wrapper object was passed
		|| (ITL_SUCCEEDED(DllCall("OleAut32\SafeArrayGetVartype", "Ptr", obj, "UShort*", vt, "Int")) && vt && ITL_IsSafeArray(ComObjParameter(VT_ARRAY|vt, obj))) ; a raw SAFEARRAY pointer was passed
}

ITL_IsPureArray(obj, zeroBased = false)
{
	for key in obj
	{
		if (!zeroBased && key != A_Index)
		{
			return false
		}
		else if (zeroBased && key != (A_Index - 1))
		{
			return false
		}
	}
	return true
}

ITL_SafeArrayType(obj)
{
	static VT_ARRAY := 0x2000
	local vt := 0
	if (ITL_IsSafeArray(obj))
		return IsObject(obj)
			? (ComObjType(obj) ^ VT_ARRAY) ; a wrapper object was passed
			: (ITL_SUCCEEDED(DllCall("OleAut32\SafeArrayGetVartype", "Ptr", obj, "UShort*", vt, "Int")) && vt) ? vt : "" ; a raw SAFEARRAY pointer was passed
}

ITL_CreateStructureSafeArray(type, dims*)
{
	static VT_RECORD := 0x24
	local arr, hr

	if (dims.MaxIndex() > 8 || dims.MinIndex() != 1)
		throw Exception(ITL_FormatException("Failed to create a structure SAFEARRAY."
										, "Invalid dimensions were specified."
										, ErrorLevel)*)

	; TODO: enable arrays with > 8 dimensions!
	arr := ComObjArray(VT_RECORD, dims*)
	hr := DllCall("OleAut32\SafeArraySetRecordInfo", "Ptr", ComObjValue(arr), "Ptr", type[ITL.Properties.TYPE_RECORDINFO], "Int")
	if (ITL_FAILED(hr))
		throw Exception(ITL_FormatException("Failed to create a structure SAFEARRAY."
										, "Could not set IRecordInfo."
										, ErrorLevel, hr)*)

	return arr
}

ITL_CreateStructureArray(type, count)
{
	return new ITL.ITL_StructureArray(type, count)
}

ITL_ArrayToSafeArray(array, vt)
{
	static VT_ARRAY := 0x2000
	local dimensions, dimCount, bounds, psa, each, dim

	dimensions := ITL_ArrayGetDimensions(array), dimCount := dimensions.maxIndex(), bounds := ITL_Mem_Allocate(dimCount * 8)
	for each, dim in dimensions
	{
		NumPut(dim.uBound - dim.lBound + 1,	bounds + (A_Index - 1) * 8, 00, "Int") ; SAFEARRAYBOUND::cElements
		NumPut(dim.lBound,					bounds + (A_Index - 1) * 8, 04, "Int") ; SAFEARRAYBOUND::lLbound
	}

	psa := DllCall("OleAut32\SafeArrayCreate", "UShort", vt, "UInt", dimCount, "Ptr", bounds, "Ptr"), ITL_Mem_Release(bounds)
	if (!psa)
	{
		throw Exception(ITL_FormatException("Failed to convert an array to a SAFEARRAY."
										, "SafeArrayCreate() returned NULL."
										, ErrorLevel)*)
	}

	ITL_ArrayCopyToSafeArray(array, psa)

	return ComObjParameter(VT_ARRAY|vt, psa)
}

ITL_ArrayCopyToSafeArray(array, psa) ; TODO
{
	local dimCount, indices

	if ITL_IsComObject(psa)
		psa := ComObjValue(psa)

	dimCount := ITL_ArrayGetDimensionCount(array)

	; ...
	indices := ITL_Mem_Allocate(dimCount * 4)
	; ...
	ITL_Mem_Release(indices)
	; ...
}

ITL_SafeArrayCopyToArray(psa, array) ; TODO
{
	local dimCount, indices

	if ITL_IsComObject(psa)
		psa := ComObjValue(psa)

	dimCount := DllCall("OleAut32\SafeArrayGetDim", "Ptr", psa, "UInt")

	; ...
	indices := ITL_Mem_Allocate(dimCount * 4)
	; ...
	ITL_Mem_Release(indices)
	; ...
}

ITL_SafeArrayToArray(safearray)
{
	local array := []
	ITL_SafeArrayCopyToArray(safearray, array)
	return array
}

ITL_ArrayGetDimensions(array, dimensions = "", index = 1)
{
	local dim, k, v

	if (!dimensions)
		dimensions := []

	dim := ITL_ArrayGetBounds(array)
	if (!dimensions.HasKey(index))
		dimensions[index] := dim
	else
		dimensions[index].uBound := ITL_Max(dimensions[index].uBound, dim.uBound)
		, dimensions[index].lBound := ITL_Min(dimensions[index].lBound, dim.lBound)

	for k, v in array
	{
		if (IsObject(v) && (ITL_IsPureArray(v, true) || ITL_IsPureArray(v, false)))
			dimensions := ITL_ArrayGetDimensions(v, dimensions, index + 1)
	}

	return dimensions
}

; all "arms" of the array must be of equal "depth"
ITL_ArrayGetDimensionCount(array)
{
	local k, v, dimCount := 0
	while (IsObject(v) && (ITL_IsPureArray(v, true) || ITL_IsPureArray(v, false)))
	{
		dimCount++
		for k, v in array
		{
			array := v
			break
		}
	}
	return dimCount
}

ITL_ArrayGetBounds(obj, byRef lBound = 0, byRef uBound = 0)
{
	local index

	for index in obj
	{
		if (A_Index == 1)
			lBound := uBound := index
		else
			uBound := ITL_Max(index, uBound), lBound := ITL_Min(index, lBound)
	}

	return { "lBound" : lBound, "uBound" : uBound }
}