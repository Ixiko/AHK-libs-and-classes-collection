	/*    	DESCRIPTION of library RegEasy
        	-------------------------------------------------------------------------------------------------------------------
			Description  	:	write/read registry settings for Standard/Current User, or other specific user, when elevation is needed
                                    	Not sure the best way to wrap this into a nice stdlib function/library, RegWriteStandardUser() seems too specific but likely the most used...
                                    	but basically, as shown in the example below, using the following four functions I was finally able to change some registry settings that are 
										in HKey_Current_User but require administrator privileges to access, which means the current user changes once the script is elevated.
                                    	I feel like there should be a proper way to do this (with the api not group policy) but haven't found anything. This works by (trying) to get 
										the SID (security identifier) of the standard/unelevated user, and writing to HKey_Users\%SID%\... instead.
			Link              	:	https://www.autohotkey.com/boards/viewtopic.php?t=60190
			Author         	:	gwarble
			Date             	:	20.12.2018
			AHK-Version	:	AHK_V1
			Dependencies	:	none
        	-------------------------------------------------------------------------------------------------------------------
	*/

/*
RegWriteUser(User, ValueType, KeyName , ValueName="", Value="")
RegReadUser(User, KeyName , ValueName="")
GetStandardUser()
GetUserSID(UserName)
; or
RegWrite, %ValueType%, % "HKU\" GetUserSID(GetStandardUser()) "\" HKCUKeyNameWithoutRoot, %ValueName%, %Value%
*/


If not A_IsAdmin
{
 Run *RunAs "%A_ScriptFullPath%"
 ExitApp
}
dlw1 := RegReadUser(GetStandardUser(),              "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\System", "DisableLockWorkstation")
       RegWriteUser(GetStandardUser(), "REG_DWORD", "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\System", "DisableLockWorkstation", !dlw1)
dlw2 := RegReadUser(GetStandardUser(),              "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\System", "DisableLockWorkstation")
       RegWrite, REG_DWORD, % "HKEY_USERS\" GetUserSID(GetStandardUser()) "\Software\Microsoft\Windows\CurrentVersion\Policies\System", DisableLockWorkstation, % !dlw2
dlw3 := RegReadUser(GetStandardUser(),              "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\System", "DisableLockWorkstation")

MsgBox, % "DisableLockWorkstation`nOriginally:          " dlw1 "`nRegWriteUser:   " dlw2 "`nRegWrite:           " dlw3


RegWriteUser(User, ValueType, KeyName , ValueName="", Value="") {
 StringReplace, KeyName, KeyName, HKEY_CURRENT_USER, % "HKEY_USERS\" GetUserSID(User)
 RegWrite, %ValueType%, %KeyName%, %ValueName%, %Value%
Return
}


RegReadUser(User, KeyName , ValueName="") {
 StringReplace, KeyName, KeyName, HKEY_CURRENT_USER, % "HKEY_USERS\" GetUserSID(User)
 RegRead, OutputVar, %KeyName%, %ValueName%
Return OutputVar
}

GetStandardUser() {
 wtsapi32 := DllCall("LoadLibrary", Str, "wtsapi32.dll", Ptr)
 DllCall("wtsapi32\WTSEnumerateSessionsEx", Ptr, 0, "UPtr*", 1, UPtr, 0, "Ptr*", pSessionInfo, "UPtr*", wtsSessionCount)
 Loop % wtsSessionCount {
  _ := ((A_PtrSize == 8 ? 56 : 32) * (A_Index - 1)) + 8 + (A_PtrSize * 3)
  If(UserName := StrGet(NumGet(pSessionInfo+0, _, "Ptr"),, A_IsUnicode ? "UTF-16" : "CP0"))
   Break
 }
Return Username
}

GetUserSID(UserName) {
 DllCall("wtsapi32\WTSFreeMemoryEx", UPtr, 2, Ptr, pSessionInfo, UPtr, wtsSessionCount)
 DllCall("FreeLibrary", Ptr, wtsapi32)
 DllCall("advapi32\LookupAccountName", Str, System, Str, UserName, UPtr, 0, UPtrP, nSizeSID, UPtr, 0, UPtrP, nSizeRDN, UPtrP, eUser)
 VarSetCapacity(SID, nSizeSID, 0)
 VarSetCapacity(RDN, nSizeRDN, 0)
 DllCall("advapi32\LookupAccountName", Str, S, Str, UserName, Str, SID, UPtrP, nSizeSID, Str, RDN, UPtrP, nSizeRDN, UPtrP, eUser)
 DllCall("advapi32\ConvertSidToStringSid", Str, SID, UPtrP, pString)
 VarSetCapacity(sSid, DllCall("lstrlenW", UPtr, pString)*2)
 DllCall("lstrcpyW", Str, sSid, UPtr, pString)
 DllCall("LocalFree", UPtr, pString)
Return sSid
}