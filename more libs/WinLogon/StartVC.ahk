#NoTrayIcon
Process, Priority, , A
#Include <FastDefaults>
#SingleInstance Ignore
#Include <LogonDesktop>

CanWeWorkWithThisSystemToken(proc, ByRef hNonDuplicatedToken, wantedSystemTokenPrivs)
{
	static cbTOKEN_PRIVILEGES := 16, TokenPrivileges := 3, SecurityImpersonation := 2, TokenImpersonation := 2
	static TokenDesiredAccess := TOKEN_DUPLICATE := 0x0002 | TOKEN_IMPERSONATE := 0x0004 | TOKEN_QUERY := 0x0008 | TOKEN_ASSIGN_PRIMARY := 0x0001 | TOKEN_ADJUST_PRIVILEGES := 0x0020

	gotAGoodToken := False	
	hDupSystemToken := 0
	numPrivsToFind := wantedSystemTokenPrivs.SetCapacity(0)
	if (LogonDesktop_DuplicateTokenEx(hNonDuplicatedToken, TokenDesiredAccess, 0, SecurityImpersonation, TokenImpersonation, hDupSystemToken))
	{
		if (!_GetTokenInformation(hDupSystemToken, TokenPrivileges, 0, 0, neededSize) && neededSize && A_LastError == 122) {
			VarSetCapacity(tokenPrivs, neededSize)
			if (_GetTokenInformation(hDupSystemToken, TokenPrivileges, &tokenPrivs, neededSize, neededSize)) {
				VarSetCapacity(privName, (260+1) * 2)
				tokenPrivCount := NumGet(tokenPrivs,, "UInt")
				if (tokenPrivCount) {
					Loop % tokenPrivCount {
						luidOffset := 4 + ((cbTOKEN_PRIVILEGES - 4) * (A_Index - 1))
						if (DllCall("advapi32\LookupPrivilegeNameW", "Ptr", 0, "Ptr", &tokenPrivs+luidOffset, "WStr", privName, "UInt*", 260)) {
							if (wantedSystemTokenPrivs[privName])
								--numPrivsToFind
							if (!numPrivsToFind)
								break
						}
					}
					if (!numPrivsToFind)
						gotAGoodToken := True
				}
			}
		}
	}

	LogonDesktop_CloseHandle(hNonDuplicatedToken)
	if (gotAGoodToken) {
		hNonDuplicatedToken := hDupSystemToken
		return True
	} else {
		LogonDesktop_CloseHandle(hDupSystemToken)
		hNonDuplicatedToken := 0
		return False
	}
}

if (LogonDesktop_AdjustThisProcessPrivileges({"SeImpersonatePrivilege": True, "SeIncreaseQuotaPrivilege": True, "SeDebugPrivilege": True}, PreviousState)) {
	if ((sessionId := DllCall("WTSGetActiveConsoleSessionId", "UInt")) != 0xFFFFFFFF) {
		tokenSuitabilityCb := Func("CanWeWorkWithThisSystemToken")
		wantedSystemTokenPrivs := {"SeImpersonatePrivilege": True, "SeIncreaseQuotaPrivilege": True, "SeDebugPrivilege": True, "SeTcbPrivilege": True, "SeAssignPrimaryTokenPrivilege": True}
		for _, sessId in [sessionId, 0, 0xFFFFFFFE]
			if ((hDupSystemToken := _FindASystemProcessToken(, tokenSuitabilityCb, wantedSystemTokenPrivs, sessId)))
				break
		if (hDupSystemToken) {
			if (DllCall("advapi32\ImpersonateLoggedOnUser", "Ptr", hDupSystemToken)) {
				if (LogonDesktop_AdjustTokenPrivileges(hDupSystemToken, wantedSystemTokenPrivs)) {
					if (LogonDesktop_WTSQueryUserToken(sessionId, hToken)) {
						if (_GetTokenInformation(hToken, 19, hUserToken, A_PtrSize,, "Ptr*")) { ; TokenLinkedToken - duplicate if changing its attributes, like session ID
							LogonDesktop_EasyCreateProcessUsingToken(hUserToken, A_ProgramFiles . "\VeraCrypt\VeraCrypt.exe", "WinSta0\Default", True,, SW_HIDE := 0)
							LogonDesktop_CloseHandle(hUserToken)
						}
						LogonDesktop_CloseHandle(hToken)
					}
				}
				if (!DllCall("advapi32\RevertToSelf"))
					DllCall("TerminateProcess", "Ptr", LogonDesktop_GetCurrentProcess(), "UInt", 1)
			}
			LogonDesktop_CloseHandle(hDupSystemToken)
		}
	}
	LogonDesktop_AdjustThisProcessPrivileges(0, PreviousState)
}