; ===========================================================================================================================================================================
; Creates an Globally Unique IDentifier (GUID)
; A GUID provides a unique 128-bit integer used for CLSIDs and interface identifiers.
; ===========================================================================================================================================================================

CreateGUID()
{
	static S_OK := 0, GUID := ""

	PGUID := Buffer(16, 0)
	if (DllCall("ole32\CoCreateGuid", "Ptr", PGUID) = S_OK)
	{
		VarSetStrCapacity(&GUID, 38)
		if (DllCall("ole32\StringFromGUID2", "Ptr", PGUID, "Str", GUID, "Int", 39))
		{
			return GUID
		}
	}
	return GUID
}

; ===========================================================================================================================================================================

MsgBox CreateGUID()
