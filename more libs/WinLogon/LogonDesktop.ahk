; LogonDesktop - run scripts on the Winlogon desktop
; 26/02/17 - qwerty12

; Modified version of RunAsTask() by SKAN: https://autohotkey.com/boards/viewtopic.php?t=4334
LogonDesktop_AddTask(runNow, runOnStartup)
{
	local TaskName, XML, TaskSchd, TaskRoot, RunAsTask
	local TASK_CREATE := 0x2, TASK_LOGON_SERVICE_ACCOUNT := 5, scriptDir := A_ScriptDir

	try 
		TaskSchd := ComObjCreate("Schedule.Service"), TaskSchd.Connect(), TaskRoot := TaskSchd.GetFolder("\")
	catch
		return ""

	TaskName := "[AHKLogonDesktop]" . A_ScriptName . " - " . DllCall("NTDLL\RtlComputeCrc32", "Int", 0, "Ptr", &scriptDir, "UInt", StrLen(scriptDir) * 2, "UInt")

	try 
		RunAsTask := TaskRoot.GetTask(TaskName)
	catch
		RunAsTask := ""

	if (!RunAsTask) {
		trigger := runOnStartup ? "<Triggers><BootTrigger><Enabled>true</Enabled></BootTrigger></Triggers>" : "<Triggers />"

		XML := "
			( LTrim Join
			<?xml version=""1.0"" ?><Task xmlns=""http://schemas.microsoft.com/windows/2004/02/mit/task"">
			<RegistrationInfo />" . trigger . "<Principals><Principal id=""Author""><UserId>S-1-5-18</UserId><RunLevel>HighestAvailable</RunLevel>
			</Principal></Principals><Settings><MultipleInstancesPolicy>Parallel</MultipleInstancesPolicy>
			<DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries><StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>
			<AllowHardTerminate>false</AllowHardTerminate><StartWhenAvailable>false</StartWhenAvailable><RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAva
			ilable><IdleSettings><StopOnIdleEnd>false</StopOnIdleEnd><RestartOnIdle>false</RestartOnIdle></IdleS
			ettings><AllowStartOnDemand>true</AllowStartOnDemand><Enabled>true</Enabled><Hidden>false</Hidden><
			RunOnlyIfIdle>false</RunOnlyIfIdle><DisallowStartOnRemoteAppSession>false</DisallowStartOnRemoteApp
			Session><UseUnifiedSchedulingEngine>false</UseUnifiedSchedulingEngine><WakeToRun>false</WakeToRun><
			ExecutionTimeLimit>PT0S</ExecutionTimeLimit><Priority>4</Priority></Settings><Actions Context=""Author""><Exec>
			<Command>" . """" . A_AhkPath . """" . "</Command>
			<Arguments>" . (A_IsCompiled ? "" : """" . A_ScriptFullPath . """") . " /ErrorStdOut" . "</Arguments>
			<WorkingDirectory>" . scriptDir . "</WorkingDirectory></Exec></Actions></Task>
			)"
		TaskRoot.RegisterTask(TaskName, XML, TASK_CREATE, "", "", TASK_LOGON_SERVICE_ACCOUNT)
	}

	if (!RunAsTask) {
		try 
			RunAsTask := TaskRoot.GetTask(TaskName)
		catch
			return ""
	}

	if (runNow)
		RunAsTask.Run("")

	return TaskName
}

LogonDesktop_LaunchOnWinlogonDesktop(cmdLine, sessionId, ignoreSentinel := False, InheritHandles := False)
{
	static tokenPerms := 0x0100 | 0x0008 | 0x0002 | 0x0001, neededPrivs := {"SeTcbPrivilege": True, "SeImpersonatePrivilege": True, "SeAssignPrimaryTokenPrivilege": True, "SeIncreaseQuotaPrivilege": True} ; TOKEN_ADJUST_SESSIONID | TOKEN_QUERY | TOKEN_DUPLICATE | TOKEN_ASSIGN_PRIMARY
	ret := False

	if (!ignoreSentinel) {
		EnvGet, _LOGON_DESKTOP_SENTINEL, _LOGON_DESKTOP_SENTINEL
		if (_LOGON_DESKTOP_SENTINEL == "1")
			return ret
	}

	if (LogonDesktop_AdjustThisProcessPrivileges(neededPrivs, PreviousState)) {
		if (LogonDesktop_OpenProcessToken(LogonDesktop_GetCurrentProcess(), tokenPerms, hToken)) {
			if (LogonDesktop_DuplicateTokenEx(hToken, 0x02000000, 0, 1, 1, hNewToken)) { ; MAXIMUM_ALLOWED, SecurityIdentification, TokenPrimary
				if (_SetTokenInformation(hNewToken, 12, sessionId, 4, "UInt*")) { ; TokenSessionId
					EnvSet, _LOGON_DESKTOP_SENTINEL, 1
					ret := LogonDesktop_EasyCreateProcessUsingToken(hNewToken, cmdLine, "WinSta0\Winlogon", False, InheritHandles)
					EnvSet, _LOGON_DESKTOP_SENTINEL, 0
				}
				LogonDesktop_CloseHandle(hNewToken)
			}
			LogonDesktop_CloseHandle(hToken)
		}
		LogonDesktop_AdjustThisProcessPrivileges(0, PreviousState)
	}

	return ret
}

_IsSystemSid(pSid) {
	return DllCall("advapi32\IsWellKnownSid", "Ptr", pSid, "UInt", 22) ; WinLocalSystemSid
}

LogonDesktop_IsScriptProcessSYSTEM()
{
	ret := hToken := 0

	if (LogonDesktop_OpenProcessToken(LogonDesktop_GetCurrentProcess(), 0x0008, hToken)) { ; TOKEN_QUERY
		if (LogonDesktop_GetTokenUser(hToken, TOKEN_USER))
			ret := _IsSystemSid(NumGet(TOKEN_USER,, "Ptr"))
		LogonDesktop_CloseHandle(hToken)
	}

	return ret
}

LogonDesktop_AdjustTokenPrivileges(hToken, privNames, ByRef PreviousState := 0, ByRef notAllAssigned := 0) {
	static cbTOKEN_PRIVILEGES := 16, skipPrivCount := cbTOKEN_PRIVILEGES - 4
	static LookupPrivilegeValueW := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandleW", "WStr", "advapi32.dll", "Ptr"), "AStr", "LookupPrivilegeValueW", "Ptr"), AdjustTokenPrivileges := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandleW", "WStr", "advapi32.dll", "Ptr"), "AStr", "AdjustTokenPrivileges", "Ptr")
	ret := False

	DllCall("SetLastError", "UInt", 0)

	if (IsObject(privNames)) {
		if (!(privNamesOrPrevStateLen := privNames.SetCapacity(0)))
			return ret

		VarSetCapacity(TOKEN_PRIVILEGES, (sizeTp := 4 + (skipPrivCount * privNamesOrPrevStateLen)), 0)
		NumPut(privNamesOrPrevStateLen, TOKEN_PRIVILEGES,, "UInt")
		for priv, enabled in privNames {
			luidOffset := 4 + (skipPrivCount * (A_Index - 1))
			if (DllCall(LookupPrivilegeValueW, "Ptr", 0, "WStr", priv, "Ptr", &TOKEN_PRIVILEGES+luidOffset))
				if (enabled)
					NumPut(0x00000002, TOKEN_PRIVILEGES, luidOffset+8, "UInt")
		}
	} else {
		if (!privNames && !IsByRef(PreviousState))
			return ret
	}

	if (hToken) {
		psBr := IsByRef(PreviousState)
		if (privNames) {
			if (psBr)
				VarSetCapacity(PreviousState, sizeTp, 0)
			ret := DllCall(AdjustTokenPrivileges, "Ptr", hToken, "Int", False, "Ptr", &TOKEN_PRIVILEGES, "UInt", psBr ? 0 : sizeTp, "Ptr", psBr ? &PreviousState : 0, "UInt*", ReturnLength)
			if (!ret && psBr && ReturnLength && A_LastError == 122) { ; ERROR_INSUFFICIENT_BUFFER
				VarSetCapacity(PreviousState, ReturnLength)
				ret := DllCall(AdjustTokenPrivileges, "Ptr", hToken, "Int", False, "Ptr", &TOKEN_PRIVILEGES, "UInt", ReturnLength, "Ptr", &PreviousState, "UInt*", ReturnLength)
			}
		} else {
			if (psBr && PreviousState)
				ret := DllCall(AdjustTokenPrivileges, "Ptr", hToken, "Int", False, "Ptr", &PreviousState, "UInt", 0, "Ptr", 0, "Ptr", 0)
		}
	}

	if (ret)
		notAllAssigned := A_LastError == 1300 ; ERROR_NOT_ALL_ASSIGNED

	return ret
}

LogonDesktop_AdjustThisProcessPrivileges(privNames, ByRef PreviousState := 0, ByRef notAllAssigned := 0) {
	ret := False

	if (LogonDesktop_OpenProcessToken(LogonDesktop_GetCurrentProcess(), 0x0028, hToken)) { ; TOKEN_ADJUST_PRIVILEGES := 0x0020 | TOKEN_QUERY := 0x0008
		ret := LogonDesktop_AdjustTokenPrivileges(hToken, privNames, PreviousState, notAllAssigned)
		LogonDesktop_CloseHandle(hToken)
	}

	return ret
}

LogonDesktop_EasyCreateProcessUsingToken(hToken, cmdLine, desktop, useTokenEnvBlock, InheritHandles := False, ShowWindow := -1) {
	ret := envModule := pEnv := 0

	if (!cmdLine)
		return ret

	if (useTokenEnvBlock) {
		if (!(envModule := _PrepareEnvironmentBlockCall()))
			return ret

		; http://stackoverflow.com/a/13733317
		if (!_CreateEnvironmentBlock(pEnv, hToken, False)) {
			_EndEnvironmentBlockCall(envModule)
			return ret
		}
	}

	_PROCESS_INFORMATION(pi)
	_STARTUPINFO(si, desktop ? &desktop : 0, ShowWindow)
	dwCreationFlags := 0x01000000 | (pEnv ? 0x00000400 : 0) ; CREATE_BREAKAWAY_FROM_JOB | CREATE_UNICODE_ENVIRONMENT

	if (!(ret := _CreateProcessAsUserW(hToken, 0, &cmdLine, 0, 0, InheritHandles, dwCreationFlags, pEnv, 0, &si, &pi)))
		ret := _CreateProcessWithTokenW(hToken, 0x00000001, 0, &cmdLine, dwCreationFlags, pEnv, 0, &si, &pi) ; LOGON_WITH_PROFILE

	if (ret) {
		LogonDesktop_CloseHandle(_PROCESS_INFORMATION_hProcess(pi))
		LogonDesktop_CloseHandle(_PROCESS_INFORMATION_hThread(pi))
	}

	if (useTokenEnvBlock) {
		if (pEnv)
			_DestroyEnvironmentBlock(pEnv)

		if (envModule)
			_EndEnvironmentBlockCall(envModule)
	}

	return ret
}

LogonDesktop_WaitForTermSrvInit()
{
	ret := False
	if ((TermSrvReadyEvent := DllCall("OpenEventW", "UInt", 0x00100000, "Int", False, "WStr", "Global\TermSrvReadyEvent", "Ptr"))) { ; SYNCHRONIZE
		ret := DllCall("WaitForSingleObject", "Ptr", TermSrvReadyEvent, "UInt", -1) == 0
		LogonDesktop_CloseHandle(TermSrvReadyEvent)
	}
	return ret
}

/*
; NOTE: I don't recommend using LogonDesktop_WaitForDesktopSwitchSync(). With AutoHotkey, it's nicer to use the accessibility framework to be be notified asynchronously:

OnDesktopSwitch(hWinEventHook, event, hWnd, idObject, idChild, dwEventThread, dwmsEventTime)
{
	MsgBox Desktop switched
}
DllCall("SetWinEventHook", "UInt", (EVENT_SYSTEM_DESKTOPSWITCH := 0x0020), "UInt", EVENT_SYSTEM_DESKTOPSWITCH, "Ptr", 0, "Ptr", (lpfnWinEventProc := RegisterCallback("OnDesktopSwitch", "")), "UInt", 0, "UInt", 0, "UInt", WINEVENT_OUTOFCONTEXT := 0x0000 | WINEVENT_SKIPOWNPROCESS := 0x0002)

(You should include a corresponding call to UnhookWinEvent, and GlobalFree for the callback function pointer at exit.)

; If you really don't want to use the accessibility framework, you might be able to use RegisterWaitForSingleObject in lieu of MsgWaitForMultipleObjectsEx,
; in combination with Lexikos' RegisterSyncCallback library to be notified asynchronously, in the style of SetWinEventHook.
*/
; The following blocks the current thread unless a message is recieved, waiting fails or WinSta0_DesktopSwitch is signalled
LogonDesktop_WaitForDesktopSwitchSync()
{
	static SYNCHRONIZE := 0x00100000, evt := DllCall("OpenEventW", "UInt", SYNCHRONIZE, "Int", False, "WStr", "WinSta0_DesktopSwitch", "Ptr"), MsgWaitForMultipleObjectsEx := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandleW", "WStr", "user32.dll", "Ptr"), "AStr", "MsgWaitForMultipleObjectsEx", "Ptr")

	desktopSwitched := False
	Loop {
		r := DllCall(MsgWaitForMultipleObjectsEx, "UInt", 1, "Ptr*", evt, "UInt", -1, "UInt", 0x4FF, "UInt", 0x0002) ; INFINITE, QS_ALLINPUT, MWMO_ALERTABLE - stolen from Lexikos
		Sleep -1 ; let AutoHotkey process messages
		if (r == 0) { ; WAIT_OBJECT_0
			desktopSwitched := True
			break
		} else if (r == -1) { ; WAIT_FAILED
			break
		}
	}

	;LogonDesktop_CloseHandle(evt)
	return desktopSwitched
}

LogonDesktop_GetTokenUser(hToken, ByRef TOKEN_USER)
{
	ret := dwLengthNeeded := 0

	if (!_GetTokenInformation(hToken, TokenUser := 1, 0, 0, dwLengthNeeded))
		if (A_LastError == 122 && VarSetCapacity(TOKEN_USER, dwLengthNeeded)) ; ERROR_INSUFFICIENT_BUFFER
			ret := _GetTokenInformation(hToken, TokenUser, &TOKEN_USER, dwLengthNeeded, dwLengthNeeded)

	return ret
}

_LookupAccountSidW(lpSid, ByRef username, ByRef domain := 0, ByRef use := 0) ; thanks to jNizM: https://autohotkey.com/boards/viewtopic.php?t=4365
{
	cchName := cchReferencedDomainName := 0
	if (!DllCall("advapi32.dll\LookupAccountSidW", "Ptr", 0, "Ptr", lpSid, "Ptr", 0, "UInt*", cchName, "Ptr", 0, "UInt*", cchReferencedDomainName, "UInt*", peUse) && A_LastError == 122) {
		VarSetCapacity(n, cchName * 2), VarSetCapacity(d, cchReferencedDomainName * 2)
		ret := DllCall("advapi32.dll\LookupAccountSidW", "Ptr", 0, "Ptr", lpSid, "Ptr", &n, "UInt*", cchName, "Ptr", &d, "UInt*", cchReferencedDomainName, "UInt*", peUse)
		if (ret) {
			if (IsByRef(username))
				username := StrGet(&n,, "UTF-16")
			if (IsByRef(domain))
				domain := StrGet(&d,, "UTF-16")
			if (IsByRef(use))
				use := _use
		}
		return ret
	}
	return False
}

LogonDesktop_GetTokenUsername(hToken, ByRef username, ByRef domain := 0, ByRef use := 0)
{
	if (LogonDesktop_GetTokenUser(hToken, TOKEN_USER))
		return _LookupAccountSidW(NumGet(TOKEN_USER,, "Ptr"), username, domain, use)

	return False
}

LogonDesktop_GetProcessWindowStationName(ByRef out)
{
	ret := False

	if ((hWinSta := DllCall("GetProcessWindowStation", "Ptr"))) 
		ret := LogonDesktop_GetUserObjectName(hWinSta, out)
	
	return ret
}

LogonDesktop_GetThreadDesktopName(ByRef out, tId := -1)
{
	ret := False
	
	if ((hDesk := DllCall("GetThreadDesktop", "UInt", tId == -1 ? DllCall("GetCurrentThreadId", "UInt") : tId, "Ptr"))) 
		ret := LogonDesktop_GetUserObjectName(hDesk, out)
	
	return ret
}

LogonDesktop_ProcessIdToSessionId(dwProcessId, ByRef dwSessionId)
{
	static ProcessIdToSessionId := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandleW", "WStr", "kernel32.dll", "Ptr"), "AStr", "ProcessIdToSessionId", "Ptr")
	return DllCall(ProcessIdToSessionId, "UInt", dwProcessId, "UInt*", dwSessionId)
}

/*
	LogonDesktop_OpenProcessToken(LogonDesktop_GetCurrentProcess(), 0x0008, hToken) ; TOKEN_QUERY
	if (!LogonDesktop_GetTokenSessionId(hToken, scriptSessionId))
		return
	LogonDesktop_CloseHandle(hToken)
*/
LogonDesktop_GetTokenSessionId(hToken, ByRef out)
{
	ret := dwLengthNeeded := 0
		
	if (hToken)
		ret := _GetTokenInformation(hToken, 12, out, 4, dwLengthNeeded, "UInt*") ; TokenSessionId

	return ret
}

LogonDesktop_PossiblyDetermineIfUnelevatedUserCanWriteToScript()
{
	AccessStatus := grantedAccess := hPrimaryToken := TokenIsElevated := hToken := dwLengthNeeded := ret := 0
	
	if ((desktopHwnd := DllCall("GetShellWindow", "Ptr"))) {
		WinGet, explorerPid, PID, ahk_id %desktopHwnd%
		if (explorerPid) {
			if ((hProc := DllCall("OpenProcess", "UInt", PROCESS_QUERY_LIMITED_INFORMATION := 0x1000, "Int", False, "UInt", explorerPid, "Ptr"))) {
				if (LogonDesktop_OpenProcessToken(hProc, TOKEN_QUERY := 0x0008 | TOKEN_DUPLICATE := 0x0002, hToken)) {
					if (_GetTokenInformation(hToken, TokenElevation := 20, TokenIsElevated, 4, dwLengthNeeded, "UInt*")) {
						if (!TokenIsElevated) {
							; From Aaron Ballman @ http://blog.aaronballman.com/2011/08/how-to-check-access-rights/
							dwLengthNeeded := 0
							if (!DllCall("advapi32.dll\GetFileSecurity", "WStr", A_ScriptFullPath, "UInt", DACL_SECURITY_INFORMATION := 0x00000004 | OWNER_SECURITY_INFORMATION := 0x00000001 | GROUP_SECURITY_INFORMATION := 0x00000002, "Ptr", 0, "Ptr", 0, "UInt*", dwLengthNeeded)) {
								if (A_LastError == (ERROR_INSUFFICIENT_BUFFER := 122) && VarSetCapacity(sd, dwLengthNeeded) && DllCall("advapi32.dll\GetFileSecurity", "WStr", A_ScriptFullPath, "UInt", DACL_SECURITY_INFORMATION | OWNER_SECURITY_INFORMATION | GROUP_SECURITY_INFORMATION, "Ptr", &sd, "Ptr", dwLengthNeeded, "UInt*", dwLengthNeeded)) {
									VarSetCapacity(GENERIC_MAPPING, 16)
									NumPut(0x00020000 | 0x0001 | 0x0080 | 0x0008 | 0x00100000, GENERIC_MAPPING, 0, "UInt")	
									NumPut(0x00020000 | 0x0002 | 0x0100 | 0x0010 | 0x0004 | 0x00100000, GENERIC_MAPPING, 4, "UInt")
									NumPut(0x00020000 | 0x0080 | 0x0020 | 0x00100000, GENERIC_MAPPING, 8, "UInt")
									NumPut(0x000F0000 | 0x00100000 | 0x1FF, GENERIC_MAPPING, 12, "UInt")
									GENERIC_WRITE := 0x40000000

									VarSetCapacity(PRIVILEGE_SET, cbPS := 20, 0)
									DllCall("advapi32.dll\MapGenericMask", "UInt*", GENERIC_WRITE, "Ptr", &GENERIC_MAPPING)
									if (DllCall("advapi32.dll\DuplicateToken", "Ptr", hToken, "UInt", SecurityIdentification := 1, "Ptr*", hPrimaryToken)) {
										if (DllCall("advapi32.dll\AccessCheck", "Ptr", &sd, "Ptr", hPrimaryToken, "UInt", GENERIC_WRITE, "Ptr", &GENERIC_MAPPING, "Ptr", &PRIVILEGE_SET, "UInt*", cbPS, "UInt*", grantedAccess, "Int*", AccessStatus))
											ret := AccessStatus
										LogonDesktop_CloseHandle(hPrimaryToken)
									}
								}
							}
						}
					}
					LogonDesktop_CloseHandle(hToken)
				}
				LogonDesktop_CloseHandle(hProc)
			}
		}
	}
	
	return ret
}

; Pretty much from the GetEffectiveRightsFromAcl MSDN sample
LogonDesktop_AllUsersCanWriteToThisScript()
{
	; This doesn't check the allowed ACEs for users that are only part of the Users group. Bear that in mind...
	hAuthzResourceManager := hAuthzClientContext := psd := pacl := ret := 0

	SECURITY_MAX_SID_SIZE := 68
	SIDs := {"WinBuiltinUsersSid": "27", "WinWorldSid": "1"}
	for k, v in SIDs {
		cbSize := SECURITY_MAX_SID_SIZE
		SIDs.SetCapacity(k, cbSize)
		if (!_CreateWellKnownSid(v+0, 0, SIDs.GetAddress(k), cbSize))
			return ret
	}

	if (!authzMod := _LoadLibrary("Authz.dll"))
		return ret

	if (!DllCall("advapi32.dll\GetNamedSecurityInfoW", "WStr", A_ScriptFullPath, "UInt", SE_FILE_OBJECT := 1, "UInt", DACL_SECURITY_INFORMATION := 0x00000004 | OWNER_SECURITY_INFORMATION := 0x00000001 | GROUP_SECURITY_INFORMATION := 0x00000002, "Ptr", 0, "Ptr", 0, "Ptr*", pacl, "Ptr", 0, "Ptr*", psd, "UInt")) {
		if (DllCall("Authz\AuthzInitializeResourceManager", "UInt", AUTHZ_RM_FLAG_NO_AUDIT := 0x1, "Ptr", 0, "Ptr", 0, "Ptr", 0, "Ptr", 0, "Ptr*", hAuthzResourceManager)) {
			for k, v in SIDs {
				if (DllCall("Authz\AuthzInitializeContextFromSid", "UInt", 0, "Ptr", SIDs.GetAddress(k), "Ptr", hAuthzResourceManager, "Ptr", 0, "Int64", 0, "Ptr", 0, "Ptr*", hAuthzClientContext)) {				
					VarSetCapacity(AUTHZ_ACCESS_REQUEST, 20 * (A_PtrSize == 8 ? 2 : 1), 0)
					VarSetCapacity(AUTHZ_ACCESS_REPLY, 16 * (A_PtrSize == 8 ? 2 : 1), 0)
					VarSetCapacity(buf, 1024, 0)
					
					NumPut(MAXIMUM_ALLOWED := 0x02000000, AUTHZ_ACCESS_REQUEST,, "UInt")
					NumPut(1, AUTHZ_ACCESS_REPLY,, "UInt")
					NumPut(&buf, AUTHZ_ACCESS_REPLY, A_PtrSize, "Ptr")
					NumPut(&buf+4, AUTHZ_ACCESS_REPLY, 12 * (A_PtrSize == 8 ? 2 : 1), "Ptr")

					if (DllCall("Authz\AuthzAccessCheck", "UInt", 0, "Ptr", hAuthzClientContext, "Ptr", &AUTHZ_ACCESS_REQUEST, "Ptr", 0, "Ptr", psd, "Ptr", 0, "UInt", 0, "Ptr", &AUTHZ_ACCESS_REPLY, "Ptr", 0)) {
						GrantedAccessMask := NumGet(buf,, "UInt")
						GENERIC_WRITE := 0x40000000
						FILE_GENERIC_WRITE := 0x00020000 | 0x0002 | 0x0100 | 0x0010 | 0x0004 | 0x00100000
						if (((GrantedAccessMask & GENERIC_WRITE) == GENERIC_WRITE) || ((GrantedAccessMask & FILE_GENERIC_WRITE) == FILE_GENERIC_WRITE))
							ret := True
					}
					DllCall("Authz\AuthzFreeContext", "Ptr", hAuthzClientContext)
					VarSetCapacity(buf, 0)

					if (ret)
						break
				}
			}
			DllCall("Authz\AuthzFreeResourceManager", "Ptr", hAuthzResourceManager)
		}
	}
	
	_FreeLibrary(authzMod)
	return ret
}

LogonDesktop_SetUiAccessToken(hToken, reallyHigh) {
	; Unsure if there is more to it
	static tilSize := 8 * (A_PtrSize == 8 ? 2 : 1), SECURITY_LABEL_MEDIUM_MORE_SID := 0, SECURITY_LABEL_HIGH_SID

	if (hToken) {
		if (reallyHigh) {
			; 0x3000
			if (!VarSetCapacity(SECURITY_LABEL_HIGH_SID)) {
				VarSetCapacity(SECURITY_LABEL_HIGH_SID, cbSize := 256) ; MAX_SID_SIZE
				if (!_CreateWellKnownSid(68, 0, &SECURITY_LABEL_HIGH_SID, cbSize)) ; WinHighLabelSid
					return
			}
		} else {
			; SECURITY_MANDATORY_MEDIUM_RID (0x2000) + 0x10 - not the same thing as SECURITY_MANDATORY_MEDIUM_PLUS_RID (0x100)!
			if (!SECURITY_LABEL_MEDIUM_MORE_SID) {
				if (!DllCall("advapi32.dll\ConvertStringSidToSidW", "WStr", "S-1-16-8208", "Ptr*", SECURITY_LABEL_MEDIUM_MORE_SID)) ; "higherIntegrityLevelSidForLimitedAccounts"
					return
			}
		}

		lpSecLabel := reallyHigh ? &SECURITY_LABEL_HIGH_SID : SECURITY_LABEL_MEDIUM_MORE_SID
		if (_SetTokenInformation(hToken, 26, True, 4, "UInt*")) { ; TokenUIAccess
			; https://msdn.microsoft.com/en-us/library/bb625960.aspx
			VarSetCapacity(TOKEN_MANDATORY_LABEL, tilSize, 0), NumPut(lpSecLabel, TOKEN_MANDATORY_LABEL,, "Ptr"), NumPut(0x00000020, TOKEN_MANDATORY_LABEL, A_PtrSize, "UInt") ; SE_GROUP_INTEGRITY
			_SetTokenInformation(hToken, 25, &TOKEN_MANDATORY_LABEL, tilSize + _GetLengthSid(lpSecLabel)) ; TokenIntegrityLevel
		}
		
;		if (SECURITY_LABEL_MEDIUM_MORE_SID)
;			DllCall("LocalFree", "Ptr", SECURITY_LABEL_MEDIUM_MORE_SID, "Ptr")
	}
}

; https://code.msdn.microsoft.com/windowsapps/CppUACSelfElevation-5bfc52dd
LogonDesktop_DoesTokenContainAdminGroupDirectlyOrNot(hToken, fallBackToLegacyMethod := False)
{
	static adminSID, CheckTokenMembership := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandleW", "WStr", "advapi32.dll", "Ptr"), "AStr", "CheckTokenMembership", "Ptr"), DuplicateToken := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandleW", "WStr", "advapi32.dll", "Ptr"), "AStr", "DuplicateToken", "Ptr")
	hTokenToCheck := fInAdminGroup := 0

	if (!hToken)
		return fInAdminGroup

	; Create the SID corresponding to the Administrators group.
	if (!VarSetCapacity(adminSID)) {
		VarSetCapacity(adminSID, cbSize := 68) ; SECURITY_MAX_SID_SIZE
		if (!_CreateWellKnownSid(26, 0, &adminSID, cbSize)) { ; WinBuiltinAdministratorsSid 
			VarSetCapacity(adminSID, 0)
			return fInAdminGroup
		}
	}

	; Determine token type: limited, elevated, or default
	if (!_GetTokenInformation(hToken, 18, elevType, 4, cbSize, "UInt*")) ; TokenElevationType
		return fInAdminGroup

	; If limited, get the linked elevated token for further check.
	if (3 == elevType) ; TokenElevationTypeLimited
	{
		if (!_GetTokenInformation(hToken, 19, hTokenToCheck, A_PtrSize, cbSize, "Ptr*")) ; TokenLinkedToken
			return fInAdminGroup
	}

	/* CheckTokenMembership requires an impersonation token. If we just got a 
	 linked token, it already is an impersonation token.  If we did not get 
	 a linked token, duplicate the original into an impersonation token for 
	 CheckTokenMembership.
	*/
	if (!hTokenToCheck)
	{
		if (!DllCall(DuplicateToken, "Ptr", hToken, "UInt", 1, "Ptr*", hTokenToCheck)) ; SecurityIdentification
			return fInAdminGroup
	}

	/* Check if the token to be checked contains admin SID.
	 http://msdn.microsoft.com/en-us/library/aa379596(VS.85).aspx:
	 To determine whether a SID is enabled in a token, that is, whether it 
	 has the SE_GROUP_ENABLED attribute, call CheckTokenMembership.
	*/
	if (!DllCall(CheckTokenMembership, "Ptr", hTokenToCheck, "Ptr", &adminSID, "Int*", fInAdminGroup) && fallBackToLegacyMethod && A_LastError == 1309) ; ERROR_NO_IMPERSONATION_TOKEN
		fInAdminGroup := _DetermineIfTheTokenHasAGroupTheNT4Way(hTokenToCheck, &adminSID)

	if (hTokenToCheck)
		LogonDesktop_CloseHandle(hTokenToCheck)

	return fInAdminGroup
}

_isTokenUiAccess(hToken)
{
	ret := False
	if (hToken)
		_GetTokenInformation(hToken, TokenUIAccess := 26, ret, 4, dwLengthNeeded, "UInt*")
	return ret
}

LogonDesktop_isThisProcessUiAccess()
{
	ret := False
	if (LogonDesktop_OpenProcessToken(LogonDesktop_GetCurrentProcess(), TOKEN_QUERY := 0x0008, hToken)) {
		ret := _isTokenUiAccess(hToken)
		LogonDesktop_CloseHandle(hToken)
	}
	return ret
}

LogonDesktop_isThisProcessHighIntegrity()
{
	ret := false
	if (LogonDesktop_OpenProcessToken(LogonDesktop_GetCurrentProcess(), TOKEN_QUERY := 0x0008, hToken)) {
		if (!_GetTokenInformation(hToken, TokenIntegrityLevel := 25, 0, 0, dwLengthNeeded))
			if (A_LastError == (ERROR_INSUFFICIENT_BUFFER := 122))
				if (VarSetCapacity(pTIL, dwLengthNeeded) && _GetTokenInformation(hToken, TokenIntegrityLevel, &pTIL, dwLengthNeeded, dwLengthNeeded))
					ret := (DllCall("advapi32.dll\GetSidSubAuthority", "Ptr", (pSid := NumGet(pTil,, "Ptr")), "UInt", DllCall("advapi32.dll\GetSidSubAuthorityCount", "Ptr", pSid, "UChar*")-1, "UInt*")) >= 0x00002010
		LogonDesktop_CloseHandle(hToken)
	}

	return ret
}

LogonDesktop_SessionIsLocked(sessionId)
{
	static WTS_CURRENT_SERVER_HANDLE := 0, WTSSessionInfoEx := 25, WTS_SESSIONSTATE_LOCK := 0x00000000, WTS_SESSIONSTATE_UNLOCK := 0x00000001 ;, WTS_SESSIONSTATE_UNKNOWN := 0xFFFFFFFF
	ret := False
	
	if (DllCall("wtsapi32\WTSQuerySessionInformation", "Ptr", WTS_CURRENT_SERVER_HANDLE, "UInt", sessionId, "UInt", WTSSessionInfoEx, "Ptr*", sesInfo, "Ptr*", BytesReturned)) {
		SessionFlags := NumGet(sesInfo+0, 16, "Int")
		; "Windows Server 2008 R2 and Windows 7: Due to a code defect, the usage of the WTS_SESSIONSTATE_LOCK and WTS_SESSIONSTATE_UNLOCK flags is reversed."
		ret := A_OSVersion != "WIN_7" ? SessionFlags == WTS_SESSIONSTATE_LOCK : SessionFlags == WTS_SESSIONSTATE_UNLOCK
		DllCall("wtsapi32\WTSFreeMemory", "Ptr", sesInfo)
	}

	return ret
}

LogonDesktop_WTSEnumerateProcessesEx(ByRef WTS, hServer := 0, SessionID := 0xFFFFFFFE) ; WTS_CURRENT_SERVER_HANDLE, WTS_ANY_SESSION
{ ; Todo: 32-Bit support. https://msdn.microsoft.com/en-us/library/ee621013(v=vs.85).aspx. Based on jNizM's code: https://github.com/jNizM/AHK_ProcessExplorer/blob/HEAD/src/ProcessExplorer.ahk#L112
	local PI := PI_EX := TTL := 0
	if (!DllCall("wtsapi32\WTSEnumerateProcessesEx", "ptr", hServer, "UInt*", 1, "UInt", SessionID, "Ptr*", PI_EX, "UInt*", TTL))
		return False
	PI := PI_EX, WTS := []
	loop % TTL
	{
		entry := {"SessionID": NumGet(PI+0, "UInt")
				 ,"ProcessID": NumGet(PI+4, "UInt")
				 ,"ProcessName": StrGet(NumGet(PI+8, "ptr"))
				 ,"NumberOfThreads": NumGet(PI+24, "UInt")
				 ,"HandleCount": NumGet(PI+28, "UInt")
				 ,"PagefileUsage": NumGet(PI+32, "UInt")
				 ,"PeakPagefileUsage": NumGet(PI+36, "UInt")
				 ,"WorkingSetSize": NumGet(PI+40, "UInt")
				 ,"PeakWorkingSetSize": NumGet(PI+44, "UInt")
				 ,"UserTime": NumGet(PI+48, "Int64")
				 ,"KernelTime": NumGet(PI+56, "Int64")}

		SID := NumGet(PI+16, "ptr")
		if (_IsValidSid(SID)) {
			if (_LookupAccountSidW(SID, Name, Domain)) {
				entry["UserName"] := Name
				entry["UserDomain"] := Domain
			}

			SIDLength := _GetLengthSid(SID)
			if (entry.SetCapacity("UserSID", SIDLength) >= SIDLength)
				DllCall("ntdll\RtlMoveMemory", "Ptr", entry.GetAddress("UserSID"), "Ptr", SID, "Ptr", SIDLength)
		}
		WTS.Push(entry)

		PI += 64
	}
	DllCall("wtsapi32\WTSFreeMemoryEx", "UInt", 1, "ptr", PI_EX, "UInt", TTL)
	return True
}

_DetermineIfTheTokenHasAGroupTheNT4Way(hToken, pSid) { ; Seriously, don't use this.
	static SE_GROUP_ENABLED := 0x00000004, SE_GROUP_USE_FOR_DENY_ONLY := 0x00000010, cbSID_AND_ATTRIBUTES := 8 * (A_PtrSize == 8 ? 2 : 1)
	retval := False

	if (!hToken || !pSid)
		return retval

	if (!_GetTokenInformation(hToken, TokenGroups := 2, 0, 0, dwSize))
		if (A_LastError != 122) ; ERROR_INSUFFICIENT_BUFFER
			return retval

	VarSetCapacity(groupInfo, dwSize, 0)
	if (!_GetTokenInformation(hToken, TokenGroups, &groupInfo, dwSize, dwSize))
		return retval

	GroupCount := NumGet(groupInfo,, "UInt")
	Loop % GroupCount {
		currGroupOffset := A_PtrSize + (cbSID_AND_ATTRIBUTES * (A_Index - 1)) 
		Attributes := NumGet(groupInfo, currGroupOffset + A_PtrSize, "UInt")
		if (Attributes & SE_GROUP_USE_FOR_DENY_ONLY)
			continue
		if ((Attributes & SE_GROUP_ENABLED) && _EqualSid(pSID, NumGet(groupInfo, currGroupOffset, "Ptr"))) {
			retval := true
			break
		}
	}

	return retval
}

_EqualSid(pSid1, pSid2)
{
	static EqualSid := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandleW", "WStr", "advapi32.dll", "Ptr"), "AStr", "EqualSid", "Ptr")
	return DllCall(EqualSid, "Ptr", pSid1, "Ptr", pSid2)
}

LogonDesktop_GetUserObjectName(hObj, ByRef out) {
	static GetUserObjectInformationW := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandleW", "WStr", "user32.dll", "Ptr"), "AStr", "GetUserObjectInformationW", "Ptr")
	nLengthNeeded := VarSetCapacity(out)

	if (!(ret := DllCall(GetUserObjectInformationW, "Ptr", hObj, "Int", 2, "WStr", out, "UInt", nLengthNeeded, "UInt*", nLengthNeeded))) ; UOI_NAME
		if (A_LastError == 122 && VarSetCapacity(out, nLengthNeeded)) ; ERROR_INSUFFICIENT_BUFFER
			ret := DllCall(GetUserObjectInformationW, "Ptr", hObj, "Int", 2, "WStr", out, "UInt", nLengthNeeded, "Ptr", 0)

	return ret
}

_OnWinLogonDesktop()
{
	static OpenInputDesktop := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandleW", "WStr", "user32.dll", "Ptr"), "AStr", "OpenInputDesktop", "Ptr"), desktopName

	if !VarSetCapacity(desktopName)
		VarSetCapacity(desktopName, 65534)

	if hDesk := DllCall(OpenInputDesktop, "UInt", 0, "Int", False, "UInt", 0, "Ptr")
		return !LogonDesktop_GetUserObjectName(hDesk, desktopName) || desktopName == "Winlogon", LogonDesktop_CloseDesktop(hDesk)

	return True
}

LogonDesktop_LoadWtsApi() {
	static lib := "wtsapi32.dll"
	return _LoadLibrary(lib)
}

LogonDesktop_UnloadWtsApi(wtsapiModule) {
	return _FreeLibrary(wtsapiModule)
}

LogonDesktop_WTSQueryUserToken(SessionId, ByRef phToken) {
	return DllCall("wtsapi32\WTSQueryUserToken", "UInt", SessionId, "Ptr*", phToken)
}

LogonDesktop_DuplicateTokenEx(hExistingToken, dwDesiredAccess, lpTokenAttributes, ImpersonationLevel, TokenType, ByRef phNewToken) {
	static DuplicateTokenEx := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandleW", "WStr", "advapi32.dll", "Ptr"), "AStr", "DuplicateTokenEx", "Ptr")
	return DllCall(DuplicateTokenEx, "Ptr", hExistingToken, "UInt", dwDesiredAccess, "Ptr", lpTokenAttributes, "UInt", ImpersonationLevel, "UInt", TokenType, "Ptr*", phNewToken)
}

_CreateProcessAsUserW(hToken, lpApplicationName, lpCommandLine, lpProcessAttributes, lpThreadAttributes, bInheritHandles, dwCreationFlags, lpEnvironment, lpCurrentDirectory, lpStartupInfo, lpProcessInformation) {
	static CreateProcessAsUserW := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandleW", "WStr", "advapi32.dll", "Ptr"), "AStr", "CreateProcessAsUserW", "Ptr")
	return DllCall(CreateProcessAsUserW, "Ptr", hToken, "Ptr", lpApplicationName, "Ptr", lpCommandLine, "Ptr", lpProcessAttributes, "Ptr", lpThreadAttributes, "Int", bInheritHandles, "UInt", dwCreationFlags, "Ptr", lpEnvironment, "Ptr", lpCurrentDirectory, "Ptr", lpStartupInfo, "Ptr", lpProcessInformation)
}

_CreateProcessWithTokenW(hToken, dwLogonFlags, lpApplicationName, lpCommandLine, dwCreationFlags, lpEnvironment, lpCurrentDirectory, lpStartupInfo, lpProcessInfo) {
	static CreateProcessWithTokenW := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandleW", "WStr", "advapi32.dll", "Ptr"), "AStr", "CreateProcessWithTokenW", "Ptr")
	return DllCall(CreateProcessWithTokenW, "Ptr", hToken, "UInt", dwLogonFlags, "Ptr", lpApplicationName, "Ptr", lpCommandLine, "UInt", dwCreationFlags, "Ptr", lpEnvironment, "Ptr", lpCurrentDirectory, "Ptr", lpStartupInfo, "Ptr", lpProcessInformation)
}

LogonDesktop_OpenProcessToken(ProcessHandle, DesiredAccess, ByRef TokenHandle) {
	static OpenProcessToken := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandleW", "WStr", "advapi32.dll", "Ptr"), "AStr", "OpenProcessToken", "Ptr")
	return DllCall(OpenProcessToken, "Ptr", ProcessHandle, "UInt", DesiredAccess, "Ptr*", TokenHandle)
}

LogonDesktop_CloseHandle(hObject) {
	static CloseHandle := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandleW", "WStr", "kernel32.dll", "Ptr"), "AStr", "CloseHandle", "Ptr"), INVALID_HANDLE_VALUE := -1
	return (hObject && hObject != INVALID_HANDLE_VALUE) ? DllCall(CloseHandle, "Ptr", hObject) : False
}

LogonDesktop_CloseDesktop(hDesktop) {
	static CloseDesktop := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandleW", "WStr", "user32.dll", "Ptr"), "AStr", "CloseDesktop", "Ptr")
	return DllCall(CloseDesktop, "Ptr", hDesktop)
}

_PROCESS_INFORMATION(ByRef pi) {
	static piCb := A_PtrSize == 8 ? 24 : 16
	if (IsByRef(pi))
		VarSetCapacity(pi, piCb, 0)
}

_PROCESS_INFORMATION_hProcess(ByRef pi) {
	return NumGet(pi,, "Ptr")
}

_PROCESS_INFORMATION_hThread(ByRef pi) {
	return NumGet(pi, A_PtrSize, "Ptr")
}

_STARTUPINFO(ByRef si, lpDesktop := 0, ShowWindow := -1, restOneDay*) {
	static siCb := A_PtrSize == 8 ? 104 : 68
	if (IsByRef(si)) {
		dwFlags := 0
		VarSetCapacity(si, siCb, 0), NumPut(siCb, si,, "UInt")
		if (lpDesktop)
			NumPut(lpDesktop, si, A_PtrSize * 2, "Ptr")
		if (ShowWindow > -1) {
			dwFlags |= 0x00000001 ; STARTF_USESHOWWINDOW
			NumPut(ShowWindow, si, A_PtrSize == 8 ? 64 : 48, "UShort")
		}
		NumPut(dwFlags, si, A_PtrSize == 8 ? 60 : 44, "UInt")
	}
}

_PrepareEnvironmentBlockCall() {
	static lib := "userenv.dll"
	return _LoadLibrary(lib)
}

_CreateEnvironmentBlock(ByRef lpEnvironment, hToken, bInherit) {
	return DllCall("userenv.dll\CreateEnvironmentBlock", "Ptr*", lpEnvironment, "Ptr", hToken, "Int", bInherit)
}

_DestroyEnvironmentBlock(lpEnvironment) {
	return DllCall("userenv.dll\DestroyEnvironmentBlock", "Ptr", lpEnvironment)
}

_EndEnvironmentBlockCall(userenvModule) {
	return _FreeLibrary(userenvModule)
}

_GetTokenInformation(TokenHandle, TokenInformationClass, ByRef TokenInformation, TokenInformationLength, ByRef ReturnLength := 0, _tokenInfoType := "Ptr") {
	static GetTokenInformation := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandleW", "WStr", "advapi32.dll", "Ptr"), "AStr", "GetTokenInformation", "Ptr")
	return DllCall(GetTokenInformation, "Ptr", TokenHandle, "UInt", TokenInformationClass, _tokenInfoType, TokenInformation, "UInt", TokenInformationLength, "UInt*", ReturnLength)
}

_SetTokenInformation(TokenHandle, TokenInformationClass, ByRef TokenInformation, TokenInformationLength, _tokenInfoType := "Ptr") {
	static SetTokenInformation := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandleW", "WStr", "advapi32.dll", "Ptr"), "AStr", "SetTokenInformation", "Ptr")
	return DllCall(SetTokenInformation, "Ptr", TokenHandle, "UInt", TokenInformationClass, _tokenInfoType, TokenInformation, "UInt", TokenInformationLength)
}

_CreateWellKnownSid(WellKnownSidType, DomainSid, pSid, ByRef cbSid) {
	static CreateWellKnownSid := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandleW", "WStr", "advapi32.dll", "Ptr"), "AStr", "CreateWellKnownSid", "Ptr")
	return DllCall(CreateWellKnownSid, "UInt", WellKnownSidType, "Ptr", DomainSid, "Ptr", pSid, "UInt*", cbSid)
}

_IsValidSid(pSid) {
	static IsValidSid := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandleW", "WStr", "advapi32.dll", "Ptr"), "AStr", "IsValidSid", "Ptr")
	return DllCall(IsValidSid, "Ptr", pSid)
}

_GetLengthSid(pSid) {
	static GetLengthSid := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandleW", "WStr", "advapi32.dll", "Ptr"), "AStr", "GetLengthSid", "Ptr")
	return DllCall(GetLengthSid, "Ptr", pSid, "UInt")
}

_FindASystemProcessToken(TokenWantedPerms := 0xF, FilterFunc := 0, FilterFuncExtraData := 0, lookInSession := 0) { ; TOKEN_DUPLICATE | TOKEN_ASSIGN_PRIMARY | TOKEN_QUERY | TOKEN_IMPERSONATE - the token returned isn't a duplicated one
	static PROCESS_QUERY_INFORMATION := 0x0400
	ret := 0

	if (LogonDesktop_AdjustThisProcessPrivileges({"SeDebugPrivilege": True}, PreviousState)) {
		if (LogonDesktop_WTSEnumerateProcessesEx(WTS,, lookInSession)) {
			FilterFuncValid := IsObject(FilterFunc) && IsFunc(FilterFunc)
			for _, proc in WTS {
				if (_IsSystemSid(proc.GetAddress("UserSID"))) {
					if ((hProc := DllCall("OpenProcess", "UInt", PROCESS_QUERY_INFORMATION, "Int", False, "UInt", proc.ProcessID, "Ptr"))) {
						if (LogonDesktop_OpenProcessToken(hProc, TokenWantedPerms, ret), LogonDesktop_CloseHandle(hProc)) {
							if (!FilterFuncValid || FilterFunc.Call(proc, ret, FilterFuncExtraData))
								break
						}
					}
				}
			}
		}
		LogonDesktop_AdjustThisProcessPrivileges(0, PreviousState)
	}
	
	return ret
}

LogonDesktop_GetCurrentProcessId() {
	static dwProcessId := DllCall("GetCurrentProcessId", "UInt") ; well, it's not like this one is going to change each time we call it
	return dwProcessId
}

LogonDesktop_GetCurrentProcess() {
	static hProc := DllCall("GetCurrentProcess", "Ptr") ; always -1
	return hProc
}

_LoadLibrary(lpFileName) {
	static LoadLibraryW := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandleW", "WStr", "kernel32.dll", "Ptr"), "AStr", "LoadLibraryW", "Ptr")
	return DllCall(LoadLibraryW, "WStr", lpFileName, "Ptr")
}

_FreeLibrary(hModule) {
	static FreeLibrary := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandleW", "WStr", "kernel32.dll", "Ptr"), "AStr", "FreeLibrary", "Ptr")
	return DllCall(FreeLibrary, "Ptr", hModule)
}

_TOKEN_ALL_ACCESS()
{
	return (STANDARD_RIGHTS_REQUIRED := 0x000F0000 | TOKEN_ASSIGN_PRIMARY := 0x0001 | TOKEN_DUPLICATE := 0x0002 | TOKEN_IMPERSONATE := 0x0004 | TOKEN_QUERY := 0x0008 | TOKEN_QUERY_SOURCE := 0x0010 | TOKEN_ADJUST_PRIVILEGES := 0x0020 | TOKEN_ADJUST_GROUPS := 0x0040 | TOKEN_ADJUST_DEFAULT := 0x0080 | TOKEN_ADJUST_SESSIONID := 0x0100)
}

GetParentProcessID()
{
	; Undocumented, and could break at any time, but far easier than the CreateToolhelp32Snapshot way...
	VarSetCapacity(PROCESS_BASIC_INFORMATION, pbiSz := A_PtrSize == 8 ? 48 : 24)
	if (DllCall("ntdll\NtQueryInformationProcess", "Ptr", LogonDesktop_GetCurrentProcess(), "UInt", 0, "Ptr", &PROCESS_BASIC_INFORMATION, "UInt", pbiSz, "Ptr", 0) >= 0)
		return NumGet(PROCESS_BASIC_INFORMATION, pbiSz - A_PtrSize, "UInt")
	return 0
}

GetParentProcessName()
{
	if (parentPID := GetParentProcessID()) {
		if (hProc := DllCall("OpenProcess", "UInt", 0x1000 | 0x0010, "Int", False, "UInt", parentPID, "Ptr")) { ; PROCESS_QUERY_LIMITED_INFORMATION | PROCESS_VM_READ
			VarSetCapacity(procName, (260 + 1) * 2)
			bnOK := !!DllCall("K32GetModuleBaseNameW", "Ptr", hProc, "Ptr", 0, "WStr", procName, "UInt", 260, "UInt")
			LogonDesktop_CloseHandle(hProc)
			if (bnOK)
				return procName
		}
	}
	return ""
}
