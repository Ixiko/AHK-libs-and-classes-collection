; ----------------------------------------------------------------------------------------------------------------------
; Name .........: TermWait library
; Description ..: Implement the RegisterWaitForSingleObject Windows API.
; AHK Version ..: AHK_L 1.1.13.01 x32/64 Unicode
; Author .......: Cyruz (http://ciroprincipe.info) & SKAN (http://goo.gl/EpCq0Z)
; License ......: WTFPL - http://www.wtfpl.net/txt/copying/
; Changelog ....: Sep. 15, 2012 - v0.1 - First revision.
; ..............: Jan. 02, 2014 - v0.2 - AHK_L Unicode and x64 version.
; ----------------------------------------------------------------------------------------------------------------------

; ----------------------------------------------------------------------------------------------------------------------
; Function .....: TermWait_WaitForProcTerm
; Description ..: This function initializes a global structure and start an asynchrounous thread to wait for program 
; ..............: termination. The global structure is used to pass arbitrary data at offset 24/36. Offsets are:
; ..............: < +0 = hWnd | +4/+8 = nMsgId | +8/+12 = nPid | +12/+16 = hProc | +16/+24 = hWait | +20/+32 = sDataIn >
; Parameters ...: hWnd	   - Handle of the window that will receive the notification.
; ..............: nMsgId   - Generic message ID (msg).
; ..............: nPid	   - PID of the process that needs to be waited for.
; ..............: sDataIn  - Arbitrary data (use this to pass any data in string form).
; ..............: getExitCode - allow your notification function to get the exit code of the process (if nPidIsHandle is true, however, then the handle must have the required rights)
; ..............: nPidIsHandle - treats the nPid parameter as if it is a valid process handle instead (WARNING: TermWait_StopWaiting will always close the handle. You should duplicate it yourself beforehand if needed.)
; Return .......: On success, address of global allocated structure. 0 on failure. If you passed a handle, it will not be closed on failure.
; ----------------------------------------------------------------------------------------------------------------------
TermWait_WaitForProcTerm(hWnd, nMsgId, nPid, ByRef sDataIn:="", getExitCode := False, nPidIsHandle := False) {
	static addrCallback := 0

	if (!addrCallback)
	{
		fnRegisterSyncCallback := Func("RegisterSyncCallback")
		if (fnRegisterSyncCallback)
			addrCallback := fnRegisterSyncCallback.Call("__TermWait_TermNotifier")
		else
			addrCallback := RegisterCallback("__TermWait_TermNotifier")
	}

	if (nPid < 1)
		return 0

	if (!nPidIsHandle) {
		procOpenFlags := 0x00100000 ; SYNCHRONIZE
		if (getExitCode) {
			if A_OSVersion in WIN_2003,WIN_XP,WIN_2000
				procOpenFlags |= 0x0400 ; PROCESS_QUERY_INFORMATION
			else
				procOpenFlags |= 0x1000 ; PROCESS_QUERY_LIMITED_INFORMATION
		}

		hProc := DllCall("OpenProcess", "UInt", procOpenFlags, "Int", False, "UInt", nPid, "Ptr")
		if (!hProc)
			return 0
	} else {
		hProc := nPid
	}

	szDataIn := VarSetCapacity(sDataIn)
	pGlobal	 := DllCall("GlobalAlloc", "UInt", 0x0040, "UInt", (A_PtrSize == 8 ? 32 : 20) + szDataIn, "Ptr")

	NumPut(hWnd, pGlobal+0,, "Ptr")
	,NumPut(nMsgId, pGlobal+0, A_PtrSize, "UInt")
	if (!nPidIsHandle)
		NumPut(nPid, pGlobal+0, A_PtrSize == 8 ? 12 : 8, "UInt")
	NumPut(hProc, pGlobal+0, A_PtrSize == 8 ? 16 : 12, "Ptr")
	
	DllCall("RtlMoveMemory", "Ptr", pGlobal+(A_PtrSize == 8 ? 32 : 20), "Ptr", &sDataIn, "Ptr", szDataIn)
	if (!DllCall("RegisterWaitForSingleObject", "Ptr", pGlobal+(A_PtrSize == 8 ? 24 : 16), "Ptr", hProc, "Ptr", addrCallback
						  , "Ptr", pGlobal, "UInt", 0xFFFFFFFF, "UInt", 0x00000004 | 0x00000008)) {  ; INFINITE, WT_EXECUTEINWAITTHREAD | WT_EXECUTEONLYONCE
		TermWait_StopWaiting(pGlobal, True)
		return 0
	}
	return pGlobal
}

; ----------------------------------------------------------------------------------------------------------------------
; Function .....: TermWait_StopWaiting
; Description ..: This function cleans all handles and frees global allocated memory.
; Parameters ...: pGlobal - Global structure address.
; ----------------------------------------------------------------------------------------------------------------------
TermWait_StopWaiting(pGlobal, justFreepGlobal := False) {
	if (pGlobal) {
		if (!justFreepGlobal) {
			DllCall("UnregisterWait", "Ptr", NumGet(pGlobal+0, A_PtrSize == 8 ? 24 : 16, "Ptr"))
			,DllCall("CloseHandle", "Ptr", NumGet(pGlobal+0, A_PtrSize == 8 ? 16 : 12))
		}
		DllCall("GlobalFree", "Ptr", pGlobal, "Ptr")
	}
}

; ----------------------------------------------------------------------------------------------------------------------
; Function .....: __TermWait_TermNotifier
; Description ..: This callback is called when a monitored process signal its closure. It gets executed on a different 
; ..............: thread because of the RegisterWaitForSingleObject, so it could interferee with the normal AutoHotkey 
; ..............: behaviour (eg. it's not bug free).
; Parameters ...: pGlobal - Global structure.
; ----------------------------------------------------------------------------------------------------------------------
__TermWait_TermNotifier(pGlobal) {
	Critical 1000
	DllCall("SendNotifyMessage",Ptr,NumGet(pGlobal+0,"Ptr"),UInt,NumGet((A_PtrSize==4)?pGlobal+4:pGlobal+8,"UInt"),UInt,0,Ptr,pGlobal)
	Critical Off
}

;EXAMPLE CODE:
/*
#SingleInstance force
#NoEnv
MSGID := 0x8500 ; msg
OnMessage(MSGID, "AHK_TERMNOTIFY")
Run, %A_WinDir%\System32\cmd.exe,,, nPid
sSomeData := "WTF! I was waiting for " . nPid . " to terminate. Now it's not running anymore. I'm cool."
TermWait_WaitForProcTerm(A_ScriptHwnd, MSGID, nPid, sSomeData, True)
Return
AHK_TERMNOTIFY(wParam, lParam) {
	; ... DO SOMETHING
	if (DllCall("GetExitCodeProcess", "Ptr", NumGet(lParam+0, A_PtrSize + 8, "Ptr"), "UInt*", dwExitCode))
		msg := " Terminated with exit code: " . dwExitCode
	MsgBox % DllCall("MulDiv", "Int", (A_PtrSize==8)?lParam+32:lParam+20, "Int", 1, "Int", 1, "Str") . msg ; you're probably better off using NumGet/StrGet depending on what sDataIn is...
	; ... DO SOMETHING
	TermWait_StopWaiting(lParam)
	ExitApp
}
*/