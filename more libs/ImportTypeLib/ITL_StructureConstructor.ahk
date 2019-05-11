ITL_StructureConstructor(this, ptr = 0, noInit = false)
{
	local hr, rcinfo := this.base[ITL.Properties.TYPE_RECORDINFO]

	if (!ptr)
	{
		ptr := DllCall(NumGet(NumGet(rcinfo+0), 16*A_PtrSize, "Ptr"), "Ptr", rcinfo, "Ptr") ; IRecordInfo::RecordCreate()
		if (!ptr)
		{
			throw Exception(ITL_FormatException("Failed to create an instance of the """ this.base[ITL.Properties.TYPE_NAME] """ structure."
											, "IRecordInfo::RecordCreate() failed."
											, ErrorLevel, ""
											, !ptr, "Invalid instance pointer: " ptr)*)
		}
	}
	else if (!noInit)
	{
		hr := DllCall(NumGet(NumGet(rcinfo+0), 03*A_PtrSize, "Ptr"), "Ptr", rcinfo, "Ptr", ptr, "Int") ; IRecordInfo::RecordInit()
		if (ITL_FAILED(hr))
		{
			throw Exception(ITL_FormatException("Failed create an instance of the """ this.base[ITL.Properties.TYPE_NAME] """ structure."
											, "IRecordInfo::RecordInit() failed."
											, ErrorLevel, hr)*)
		}
	}

	this[ITL.Properties.INSTANCE_POINTER] := ptr
}