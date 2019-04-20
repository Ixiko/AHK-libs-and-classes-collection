#NoTrayIcon
#Persistent
#NoEnv
#Include *i %A_ScriptDir%\Lib\FastDefaults.ahk
SetKeyDelay, -1, -1
SetWorkingDir %A_ScriptDir%	 ; Ensures a consistent starting directory.
#SingleInstance Off ; This same script is launched multiple times
#UseHook Off ; Remove if you need complex hotkeys. WM_HOTKEY suits me fine; I don't want a low-level keyboard/mouse hook installed on WinSta0\Winlogon
#Include %A_ScriptDir%\Lib\LogonDesktop.ahk ; Naturally, this one is needed

#Include *i %A_ScriptDir%\Lib\WatchLenovoBatteryKey.ahk ; Ignore this one; it's only going to exist on my system
#Include *i %A_ScriptDir%\Lib\RegisterSyncCallback.ahk ; Used by TermWait for a thread-safe RegisterCallback. Get it from https://autohotkey.com/boards/viewtopic.php?t=21223
#Include *i %A_ScriptDir%\Lib\TermWait.ahk ; Used to implement dieOnParentTermination. Get it from the same place you got this script
#Include *i %A_ScriptDir%\Lib\SaveSetColours.ahk ; Used to implement GetColourSettingsForLoggedOnUser. Also in my Gists. W10, on my laptop for some reason, doesn't retain my profile's accent etc. colour when the desktop is switched, so I set it myself again

; Global constants:
clientSwitch := " /userPipeName:"
pipeNameTemplate := "AHK_LogonMediaKeys_" ; + sessionId

dieOnParentTermination := True ; quick-n-dirty way to have all children exit when the session 0 script gets stopped (no, jobs won't work: "All processes associated with a job must run in the same session")
parentHandleSwitch := " /parentHandle:"

winlogonSessionIDs := [] ; Used by the session 0 instance of this script to store the child sessions another instance of itself is running in

main(), return

main()
{
	; LogonDesktop assumes a Unicode build of AutoHotkey throughout. Sorry.
	if (!A_IsUnicode)
		ExitApp 1

	DllCall("SetErrorMode", "UInt", DllCall("GetErrorMode", "UInt") | 0x0002, "UInt") ; AND SEM_NOGPFAULTERRORBOX to stop Windows from throwing up WER dialog boxes in case of error

	OnExit("AtExit")

	global dieOnParentTermination, parentHandleSwitch
	if (dieOnParentTermination) {
		fnTermWait_WaitForProcTerm := Func("TermWait_WaitForProcTerm")
		if (!fnTermWait_WaitForProcTerm) {
			dieOnParentTermination := False ; No point in enabling if the function to wait on a process's termination isn't there...
		} else {
			global hDupProc
			if (!DllCall("DuplicateHandle", "Ptr", LogonDesktop_GetCurrentProcess(), "Ptr", LogonDesktop_GetCurrentProcess(), "Ptr", LogonDesktop_GetCurrentProcess(), "Ptr*", hDupProc, "UInt", 0x00100000, "Int", True, "UInt", 0)) ; Duplicate the psuedo handle returned by GetCurrentProcess() to obtain a real handle for this process and mark it as inheritable
				dieOnParentTermination := False

			cmdLine := DllCall("GetCommandLineW", "WStr")
			if (InStr(cmdLine, parentHandleSwitch)) { ; if there was a handle passed to this process, enable watching for its termination now.
				MSGID := 0x8500
				OnMessage(MSGID, "AHK_TERMNOTIFY")
				fnTermWait_WaitForProcTerm.Call(A_ScriptHwnd, MSGID, StrSplit(cmdLine, parentHandleSwitch, " """"")[2],,, True)
			}
		}
	}

	if (LogonDesktop_IsScriptProcessSYSTEM()) {
		global scriptSessionId
		if (!LogonDesktop_ProcessIdToSessionId(LogonDesktop_GetCurrentProcessId(), scriptSessionId))
			ExitApp 1

		DllCall("SetProcessShutdownParameters", "UInt", 0, "UInt", 0) ; Make us one of the last things to shutdown - done so that my accent colour is retained...
		if (scriptSessionId == 0) {
			HandleSessionZeroScriptInitialisation()
		} else {
			HandleSessionsWinlogonDesktopInitialisation()
		}
	} else {
		HandleUserDefaultDesktopInstance()
	}

}

; Simply put: die if our parent process dies and dieOnParentTermination is enabled
AHK_TERMNOTIFY(wParam, lParam) {
	Func("TermWait_StopWaiting").Call(lParam)
	ExitApp
}

AtExit()
{
	Critical 1000
	global wtsHandle, hDupProc, watchForColourChange, SaveSetColoursFunc

	OnExit(A_ThisFunc, 0)

	if (watchForColourChange) {
		watchForColourChange := False
		PostMessage, 0x0000,,,, ahk_id %A_ScriptHwnd% ; WM_NULL
		SetTimer, SetupColourChange, Off
		SaveSetColoursFunc.Call(True, False)
	}

	if (wtsHandle) {
		if (OnMessage(0x2B1, ""))
			DllCall("wtsapi32.dll\WTSUnRegisterSessionNotification", "Ptr", A_ScriptHwnd)
		LogonDesktop_UnloadWtsApi(wtsHandle), wtsHandle := 0
	}
	if (hDupProc)
		LogonDesktop_CloseHandle(hDupProc), hDupProc := 0

	Critical Off
	return 0
}

; --- Here lies the functions used when this script is running as LocalSystem

; Here we perform the initialisation needed when this script is the first instance of itself, running in the services session --
HandleSessionZeroScriptInitialisation()
{
	global wtsHandle
;	if (LogonDesktop_AllUsersCanWriteToThisScript())
;		OutputDebug % A_ScriptName . ": [LogonDesktop] WARNING: it's seemingly possible for Everyone and/or all Users to modify this script"

	if (!LogonDesktop_WaitForTermSrvInit()) ; Probably redundant since Task Scheduler starts this script so late, and probably checks itself...
		ExitApp 1

	; wtsapi32.dll isn't loaded by default. For the notifications to actually work, we must load it ourselves
	if (!(wtsHandle := LogonDesktop_LoadWtsApi()))
		ExitApp 1

	EnumerateSessionsAndLaunchWinlogonClient()

	; In session zero, watch for new sessions and launch the Winlogon instances of this script in each newly-created session
	if (DllCall("wtsapi32.dll\WTSRegisterSessionNotification", "Ptr", A_ScriptHwnd, "UInt", 1)) ; NOTIFY_FOR_ALL_SESSIONS
		OnMessage(0x2B1, "WM_WTSSESSION_CHANGE")
}

; If the script is running on the Winlogon desktop of a non-service session, then:
HandleSessionsWinlogonDesktopInitialisation()
{
	if ((!LogonDesktop_GetThreadDesktopName(desktopName)) || desktopName != "Winlogon")
		ExitApp 1

	; Raise the process's priority, just 'cause.
	Process, Priority,, A

	; As we're on the Winlogon desktop, where the logon/lock screen actually displays itself, let's now register the hotkeys. 
	; Done here because including them in the normal AHK way would mean that they're registered in the services session and on the Default desktop of a user's session...

	for _, key in ["Volume_Mute", "Volume_Up", "Volume_Down"]
		Hotkey, %key%, HandleVolumeKeys, UseErrorLevel On

	for _, key in ["Media_Prev", "Media_Next", "Media_Play_Pause"]
		Hotkey, %key%, HandleMediaKeys, UseErrorLevel On

	; ignore. this section is for my personal tasks
	if (true)
	{
		if ((wlbk_st := Func("WatchLenovoBatteryKey_SetThresholds"))) {
			wlbk_st.Call()
			wlbk_st := ""
		}

		if (IsFunc("SaveSetColours")) {
			if (!SetupColourChange()) { ; if we're not started when logged on, this will fail - as expected. Can't get logon token of a user that's not logged on...
				global wtsHandle := LogonDesktop_LoadWtsApi() ; so monitor for logons ourselves if needed
				if (wtsHandle && DllCall("wtsapi32.dll\WTSRegisterSessionNotification", "Ptr", A_ScriptHwnd, "UInt", NOTIFY_FOR_THIS_SESSION := 0))
					OnMessage(0x2B1, "WM_WTSSESSION_CHANGE")
			}
		}
	}
}

WM_WTSSESSION_CHANGE(wParam, lParam)
{
	Critical
	global winlogonSessionIDs, scriptSessionId, watchForColourChange
;	username := ""
;	if (LogonDesktop_WTSQueryUserToken(lParam, hToken)) {
;		LogonDesktop_GetTokenUsername(hToken, username)
;		LogonDesktop_CloseHandle(hToken)
;	}
;	OutputDebug % ("WTSSESSION_CHANGE: wParam: " . wParam . " lParam: " . lParam . " username: " . username)
	if (scriptSessionId == 0) {
		if (wParam == 6) ; user logged out. Typically speaking, this means the session will be deleted
			winlogonSessionIDs.Delete(lParam)
		else if (wParam == 1) ; WTS_CONSOLE_CONNECT - new sessions are created just to show a logon window on them, which is why WTS_SESSION_LOGON doesn't work here
			SetTimer, EnumerateSessionsAndLaunchWinlogonClient, -1000
	} 
	else {
		if (wParam == 5) { ; user logged in on our session
;			 I used to also register for session notifications in the Winlogon instance to see if a user had logged on, to start the pipe server instance as soon as that happened,
;			 but moved away to the more reliable method of starting said AHKLogonMediaKeys instance when a media key is actually pressed at the logon screen
			LaunchUserPipeServerInSameSessionAsWinlogonScript()
			if (!watchForColourChange)
				SetTimer, SetupColourChange, -1000 ; now try again to set the colour settings
		}
	}
	Critical Off
}

; This function's aim is to go through all the present sessions, seeing which ones do not have a Winlogon instance of this script running on them
EnumerateSessionsAndLaunchWinlogonClient()
{
;	Critical
	global winlogonSessionIDs, dieOnParentTermination, parentHandleSwitch, hDupProc
	static cbWTS_SESSION_INFO_1 := A_PtrSize == 8 ? 56 : 32, WTSEnumerateSessionsExW, WTSFreeMemoryExW := 0, cmdLine := 0
	
	if (!WTSFreeMemoryExW) {
		global wtsHandle
		WTSFreeMemoryExW := DllCall("GetProcAddress", "Ptr", wtsHandle, "AStr", "WTSFreeMemoryExW", "Ptr")
		WTSEnumerateSessionsExW := DllCall("GetProcAddress", "Ptr", wtsHandle, "AStr", "WTSEnumerateSessionsExW", "Ptr")
	}

	if (!cmdLine) {
		cmdLine := DllCall("GetCommandLineW", "WStr")
		for _, switch in [" /force", " /restart"] {
			if (!InStr(cmdLine, switch))
				cmdLine .= switch
		}
		if (dieOnParentTermination) {
			if (!InStr(cmdLine, parentHandleSwitch))
				cmdLine .= parentHandleSwitch . hDupProc
		}
	}

	if (DllCall(WTSEnumerateSessionsExW, "Ptr", 0, "UInt*", 1, "UInt", 0, "Ptr*", pSessionInfo, "UInt*", wtsSessionCount)) { ; WTS_CURRENT_SERVER_HANDLE
;		WTS_CONNECTSTATE_CLASS := {0: "WTSActive", 1: "WTSConnected", 2: "WTSConnectQuery", 3: "WTSShadow", 4: "WTSDisconnected", 5: "WTSIdle", 6: "WTSListen", 7: "WTSReset", 8: "WTSDown", 9: "WTSInit"}
		Loop % wtsSessionCount {
			currSessOffset := cbWTS_SESSION_INFO_1 * (A_Index - 1) ;, ExecEnvId := NumGet(pSessionInfo+0, currSessOffset, "UInt")
			currSessOffset += 4, State := NumGet(pSessionInfo+0, currSessOffset, "UInt")
			currSessOffset += 4, SessionId := NumGet(pSessionInfo+0, currSessOffset, "UInt")
;			currSessOffset += A_PtrSize, SessionName := StrGet(NumGet(pSessionInfo+0, currSessOffset, "Ptr"),, "UTF-16")
;			currSessOffset += A_PtrSize, HostName := StrGet(NumGet(pSessionInfo+0, currSessOffset, "Ptr"),, "UTF-16")
;			currSessOffset += A_PtrSize, UserName := StrGet(NumGet(pSessionInfo+0, currSessOffset, "Ptr"),, "UTF-16")
;			currSessOffset += A_PtrSize, DomainName := StrGet(NumGet(pSessionInfo+0, currSessOffset, "Ptr"),, "UTF-16")
;			currSessOffset += A_PtrSize, FarmName := StrGet(NumGet(pSessionInfo+0, currSessOffset, "Ptr"),, "UTF-16")

			if (SessionId) { ; if the session ID is not zero (I don't think you get negative session IDs...)
				if (State == 0 || State == 1) { ; active / connected
					; check to see if we already launched a Winlogon instance in that session
					foundSessionId := False
					for _, s in winlogonSessionIDs {
						if (s == sessionId) {
							foundSessionId := True
							break
						}
					}
					if (!foundSessionId) {
						if (LogonDesktop_LaunchOnWinlogonDesktop(cmdLine, sessionId,, dieOnParentTermination))
							winlogonSessionIDs.Push(sessionId)
					}
				}
			}
		}
		DllCall(WTSFreeMemoryExW, "UInt", 2, "Ptr", pSessionInfo, "UInt", wtsSessionCount) ; WTSTypeSessionInfoLevel1
	}
;	Critical Off
}

SetupColourChange()
{
	global SaveSetColoursFunc := Func("SaveSetColours"), watchForColourChange
	ret := False
	if (SaveSetColoursFunc) { ; does SaveSetColours() exist? Great, get a function object pointing to it
		if (GetColourSettingsForLoggedOnUser()) { ; did we get the profile colours of the logged in user? great:
			ret := watchForColourChange := True
			while (watchForColourChange) {
				if (LogonDesktop_WaitForDesktopSwitchSync() && _OnWinLogonDesktop()) ; now the script waits for the desktop to be switched back to WinSta0\Winlogon
					Loop 3
						SaveSetColoursFunc.Call(True, False) ; and if so, set our retained colours
			}
		}
	}
	return ret
}

GetColourSettingsForLoggedOnUser()
{
	global scriptSessionId, SaveSetColoursFunc
	ret := False
	if (IsObject(SaveSetColoursFunc) && IsFunc(SaveSetColoursFunc)) {
		if (LogonDesktop_AdjustThisProcessPrivileges({"SeTcbPrivilege": True, "SeImpersonatePrivilege": True}, PreviousState)) {
			Critical 1000 ; don't allow this to be interrupted

			; wait until Explorer signals Winlogon's event to tell it to switch to the desktop
			if ((ShellDesktopSwitchEvent := DllCall("OpenEventW", "UInt", 0x00100000, "Int", False, "WStr", "ShellDesktopSwitchEvent", "Ptr"))) { ; SYNCHRONIZE
				DllCall("WaitForSingleObject", "Ptr", ShellDesktopSwitchEvent, "UInt", -1)
				LogonDesktop_CloseHandle(ShellDesktopSwitchEvent)
			}

			Loop 120 {
				DllCall("Sleep", "UInt", 500) ; wait before trying again
				if (LogonDesktop_WTSEnumerateProcessesEx(sessionProcesses,, scriptSessionId)) ; get only processes in our session
					for _, proc in sessionProcesses
						if (proc.ProcessName = "explorer.exe")
							break 2
			}
			DllCall("Sleep", "UInt", 1750)

			if (DllCall("advapi32\RegDisablePredefinedCache") == 0) { ; force WinAPI registry functions to read the HKEY_CURRENT_USER key of the user we're going to impersonate
				if (LogonDesktop_WTSQueryUserToken(scriptSessionId, hToken)) {
					if (DllCall("advapi32\ImpersonateLoggedOnUser", "Ptr", hToken)) { ; make this thread impersonate as the logged on user
						SaveSetColoursFunc.Call() ; get the colour settings for said user
						ret := True

						if (!DllCall("advapi32\RevertToSelf")) ; go back to being SYSTEM
							DllCall("TerminateProcess", "Ptr", LogonDesktop_GetCurrentProcess(), "UInt", 1) ; if that fails, we need to bail
					}
					LogonDesktop_CloseHandle(hToken)
				}
			}
			LogonDesktop_AdjustThisProcessPrivileges(0, PreviousState)
			Critical Off
		}
	}
	return ret
}

; handles when the Media_* keys are pressed in the Winlogon script instance
HandleMediaKeys()
{
	static pipe_name := 0, CreateFileW := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandleW", "WStr", "kernel32.dll", "Ptr"), "AStr", "CreateFileW", "Ptr"), WaitNamedPipe := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandleW", "WStr", "kernel32.dll", "Ptr"), "AStr", "WaitNamedPipeW", "Ptr")

	if (!pipe_name) {
		global pipeNameTemplate, scriptSessionId
		pipe_name := "\\.\pipe\" . pipeNameTemplate . scriptSessionId
	}

	; wait to see if the pipe actually exists
	if (!DllCall(WaitNamedPipe, "WStr", pipe_name, "uint", 1000)) {
		if (A_LastError != 2) ; ERROR_FILE_NOT_FOUND
			return
		; if not, launch the pipe server on the user's desktop
		Critical ; don't allow this function to try starting the server as many times as a media key is pressed
		LaunchUserPipeServerInSameSessionAsWinlogonScript()
		DllCall("Sleep", "UInt", 250)
		Critical Off
	}

	; open handle to named pipe. Use CreateFile because it allows us to prevent the pipe server from impersonating us when we connect
	hPipe := DllCall(CreateFileW, "WStr", pipe_name, "UInt", 0x40000000, "UInt", 0, "Ptr", 0, "UInt", 3, "UInt", 0x00100000, "Ptr", 0, "Ptr") ; GENERIC_WRITE, OPEN_EXISTING, SECURITY_SQOS_PRESENT | SECURITY_ANONYMOUS(0)
	if (hPipe != -1) { ; INVALID_HANDLE_VALUE
		if ((media_pipe := FileOpen(hPipe, "h", "UTF-16-RAW")))
			media_pipe.Write(A_ThisHotkey), media_pipe := ""
		LogonDesktop_CloseHandle(hPipe)
	}
}

; this is easier. As long as we're in the same session, Windows Audio can be controlled normally regardless of the current desktop
HandleVolumeKeys()
{
	if (A_ThisHotkey == "Volume_Mute") {
		SoundSet +1,, Mute
	} else if (A_ThisHotkey == "Volume_Down") {
		SoundSet -2
	} else if (A_ThisHotkey == "Volume_Up") {
		SoundSet +2
	}
}

LaunchUserPipeServerInSameSessionAsWinlogonScript() {
	ret := False
	global clientSwitch, pipeNameTemplate, scriptSessionId, dieOnParentTermination, parentHandleSwitch, hDupProc
	pipe_name := pipeNameTemplate . scriptSessionId
	if (LogonDesktop_AdjustThisProcessPrivileges({"SeTcbPrivilege": True, "SeImpersonatePrivilege": True, "SeAssignPrimaryTokenPrivilege": True, "SeIncreaseQuotaPrivilege": True}, PreviousState)) { ; usually enabled by default when SYSTEM, but just in case...
		if (LogonDesktop_WTSQueryUserToken(scriptSessionId, hToken)) { ; get the token for the logged-on user in the same session the Winlogon script is running on
			if (LogonDesktop_DuplicateTokenEx(hToken, 0x02000000, 0, 1, 1, hUserToken)) { ; Duplicate it to get a token we can use with CreateProcess. MAXIMUM_ALLOWED, SecurityIdentification, TokenPrimary
				; I don't want to run the pipe server elevated, but if Spotify for whatever reason is, run with the uiAccess attribute set to ensure there's no problems
				LogonDesktop_SetUiAccessToken(hUserToken, LogonDesktop_DoesTokenContainAdminGroupDirectlyOrNot(hToken, True)) ; need to know if the user logged on is an admin to set the right higher integrity level
				extra := dieOnParentTermination ? parentHandleSwitch . hDupProc : ""
				ret := LogonDesktop_EasyCreateProcessUsingToken(hUserToken, """" . A_AhkPath . """" . " /force /restart " . """" . A_ScriptFullPath . """" . clientSwitch . pipe_name . extra, "WinSta0\Default", True, dieOnParentTermination)
				LogonDesktop_CloseHandle(hUserToken)
			}
			LogonDesktop_CloseHandle(hToken)
		}
		LogonDesktop_AdjustThisProcessPrivileges(0, PreviousState)
	}
	return ret
}

; --- These functions are used in pipe server mode, running on the user's Default desktop

HandleUserDefaultDesktopInstance()
{
	global clientSwitch, hDupProc
	cmdLine := DllCall("GetCommandLineW", "WStr")
	if (InStr(cmdLine, clientSwitch)) { ; if the name of the pipe to create is specified on the command line (which it will be when started by the Winlogon instance)
		if (hDupProc)
			LogonDesktop_CloseHandle(hDupProc), hDupProc := 0 ; we don't spawn any further scripts from the pipe server instance
		pipe_name := StrSplit(cmdLine, clientSwitch, " """"")[2]
		if ((spaceChrPos := InStr(pipe_name, " "))) ; the quick-and-dirty C way of replacing a character
			NumPut(0, pipe_name, (spaceChrPos - 1) * 2, "UShort"), VarSetCapacity(pipe_name, -1)
		RunPipeServer(pipe_name)
	} else { ; Assume this script was started by double-clicking it by the user
		if (A_IsAdmin) { ; if we are elevated
			if (LogonDesktop_PossiblyDetermineIfUnelevatedUserCanWriteToScript())
				OutputDebug % A_ScriptName . ": [LogonDesktop] WARNING: unelevated you has the right to edit this script. Consider fixing that."
			LogonDesktop_AddTask(True, True) ; run on startup and start session zero instance of this script now
		} else {
			Run *RunAs "%A_AhkPath%" "%A_ScriptFullPath%",, UseErrorLevel ; ask for elevation and run ^
		}
	}
	
	ExitApp
}

; we only create this named pipe because SetThreadDesktop isn't really possible in AutoHotkey, and I don't want to run a script as SYSTEM on the user's Default desktop anyway
RunPipeServer(pipe_name)
{
	; This (and the pipe functions at the bottom) is mostly Lexikos' code: https://autohotkey.com/board/topic/94445-looping-command-line-parameters/
	; Any screwups are, of course, mine only

	; if there is no pipe to create, or if it already exists (another pipe server script running?), then exit
	if (!pipe_name || FileExist("\\.\pipe\" . pipe_name))
		ExitApp 1

	; default DACL on the pipe allows for all users to send messages to the pipe. Use a subset of the default rules: only SYSTEM and the user who created the pipe has full control; the rest are denied any access to it
	lpSECURITY_ATTRIBUTES := 0
	if (LogonDesktop_OpenProcessToken(LogonDesktop_GetCurrentProcess(), TOKEN_QUERY := 0x0008, hToken)) {
		if (LogonDesktop_GetTokenUser(hToken, TOKEN_USER)) { ; get SID of user who created this process
			if (DllCall("advapi32.dll\ConvertSidToStringSidW", "Ptr", NumGet(TOKEN_USER,, "Ptr"), "Ptr*", StringSid)) { ; and convert it to string form
				VarSetCapacity(SECURITY_ATTRIBUTES, (saCb := A_PtrSize == 8 ? 24 : 12), 0), NumPut(saCb, SECURITY_ATTRIBUTES,, "UInt")
				; get SD from SDDL string (given the amount of struct manipulations I'd have to do to do this in pure WinAPI, I'll stick with SDDL in AutoHotkey, TYVM)
				if (DllCall("advapi32.dll\ConvertStringSecurityDescriptorToSecurityDescriptorW", "WStr", Format("D:(A;;0x1fffff;;;{:s})(A;;0x1fffff;;;SY)", StrGet(StringSid,, "UTF-16")), "UInt", 1, "Ptr", &SECURITY_ATTRIBUTES+A_PtrSize, "Ptr", 0)) ; SDDL_REVISION_1
					lpSECURITY_ATTRIBUTES := &SECURITY_ATTRIBUTES
				; purposely don't free the SD memory allocated by ConvertStringSecurityDescriptorToSecurityDescriptor - doing so causes a crash 90% of the time, and we won't leak because this is only called once anyway
				DllCall("LocalFree", "Ptr", StringSid, "Ptr")
			}
		}
		LogonDesktop_CloseHandle(hToken)
	}

	hpipe := CreateNamedPipe(pipe_name, 0x00000001 | 0x40000000,, 1, lpSECURITY_ATTRIBUTES)  ; PIPE_ACCESS_INBOUND | FILE_FLAG_OVERLAPPED, PIPE_TYPE_BYTE
	if (hpipe == -1) ; INVALID_HANDLE_VALUE
		ExitApp 1
	pipe := FileOpen(hpipe, "h", "UTF-16-RAW")
	DisconnectNamedPipe := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandleW", "WStr", "kernel32.dll", "Ptr"), "AStr", "DisconnectNamedPipe", "Ptr")

	; Wait for a connection.
	while (ConnectNamedPipe(hpipe))
	{
		; Read the message incrementally (if it is long).
		message := ""
		while (data := pipe.Read(4096))
			message .= data

		; Process the message.
		if (message == "Media_Next") {
			PostMessage, 0x319,, 0xB0000,, ahk_class SpotifyMainWindow
		} else if (message == "Media_Prev") {
			PostMessage, 0x319,, 0xC0000,, ahk_class SpotifyMainWindow
		} else if (message == "Media_Play_Pause") {
			PostMessage, 0x319,, 0xE0000,, ahk_class SpotifyMainWindow
		}

		; Disconnect so that we can accept another connection.
		DllCall(DisconnectNamedPipe, "Ptr", hpipe)
	}

	pipe := ""
	LogonDesktop_CloseHandle(hpipe)
}

CreateNamedPipe(Name, OpenMode=3, PipeMode=0, MaxInstances=255, lpSecurityAttributes := 0) {
	return DllCall("CreateNamedPipe","str","\\.\pipe\" Name,"uint",OpenMode
		,"uint",PipeMode,"uint",MaxInstances,"uint",0,"uint",0,"uint",0,"ptr",lpSecurityAttributes,"ptr")
}

ConnectNamedPipe(hNamedPipe) {
	static ConnectNamedPipe := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandleW", "WStr", "kernel32.dll", "Ptr"), "AStr", "ConnectNamedPipe", "Ptr")
		  ,GetOverlappedResult := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandleW", "WStr", "kernel32.dll", "Ptr"), "AStr", "GetOverlappedResult", "Ptr")
		  ,MsgWaitForMultipleObjectsEx := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandleW", "WStr", "user32.dll", "Ptr"), "AStr", "MsgWaitForMultipleObjectsEx", "Ptr")
		  ,hEvent := DllCall("CreateEvent", "ptr", 0, "int", true, "int", false, "ptr", 0, "ptr"), overlapped
	if (!VarSetCapacity(overlapped)) {
		VarSetCapacity(overlapped, 32, 0)
		NumPut(hEvent, overlapped, 2*A_PtrSize+8, "Ptr")
	}
	if (!DllCall(ConnectNamedPipe, "ptr", hNamedPipe, "ptr", &overlapped) && A_LastError == 997) {	; ERROR_IO_PENDING
		loop {
			; Wait for the event to be signaled or any window message received.
			r := DllCall(MsgWaitForMultipleObjectsEx, "uint", 1, "ptr*", hEvent, "uint", -1, "uint", 0x4FF, "uint", 0x6)
			Sleep -1 ; Allow AutoHotkey to dispatch messages.
		} until r=0 or r=-1  ; WAIT_OBJECT_0 or WAIT_FAILED
	}
	r := DllCall(GetOverlappedResult, "ptr", hNamedPipe, "ptr", &overlapped, "uint*", 0, "int", true)
;	if (r == 0)
;		DllCall("ResetEvent", "Ptr", hEvent)
	;LogonDesktop_CloseHandle(hEvent)
	return r
}