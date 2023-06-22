; ===========================================================================================================================================================================
; Retrieves join status information for the specified computer.
; Tested with AutoHotkey v2.0-beta.3
; ===========================================================================================================================================================================

NetGetJoinInformation(Server := "127.0.0.1")
{
	#DllLoad "netapi32.dll"

	static NERR_SUCCESS := 0
	static JOIN_STATUS  := Map(0, "Unknown", 1, "Unjoined", 2, "WorkgroupName", 3, "DomainName")

	NET_API_STATUS := DllCall("netapi32\NetGetJoinInformation", "WStr", Server
	                                                          , "Ptr*", &Buf := 0
	                                                          , "Int*", &Status := 0
	                                                          , "UInt")

	if (NET_API_STATUS = NERR_SUCCESS)
	{
		JOIN_INFO := Map()
		JOIN_INFO["Name"] := StrGet(Buf)
		JOIN_INFO["Type"] := JOIN_STATUS[Status]

		DllCall("netapi32\NetApiBufferFree", "Ptr", Buf, "UInt")
		return JOIN_INFO
	}

	DllCall("netapi32\NetApiBufferFree", "Ptr", Buf, "UInt")
	return false
}

; ===========================================================================================================================================================================

for k, v in NetGetJoinInformation()
	output .= k ": " v "`n"
MsgBox output