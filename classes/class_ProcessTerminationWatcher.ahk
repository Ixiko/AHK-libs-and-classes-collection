/**
 * @file
 * @copyright Dedicated to Public Domain. See UNLICENSE.txt for details
 */

#include %A_LineFile%\..\ErrMsg.ahk

/**
 * Allows to subscribe on system process termination event and execute user defined callback when
 * this occur.
 *
 * @code{.ahk}
   #NoEnv

   #incldue <ProcessTerminationWatcher>

   global g_ptw := new ProcessTerminationWatcher()
   Run notepad,,,procPid
   g_ptw.watch(procPid, Func("onProcessTerminated").Bind(procPid))

   onProcessTerminated(pid) {
   	MsgBox 4,, % "Process with PID " pid " just terminated.`n`n"
   	           . "Would you like to repeat?"
   	IfMsgBox, No
   		ExitApp

   	;Run notepad and subscribe again
   	Run notepad,,,procPid
   	g_ptw.watch(procPid, Func(A_ThisFunc).Bind(procPid))
   }
 * @endcode
 */
class ProcessTerminationWatcher {

	watch(watchedPid, callback) {
		Process Exist, % watchedPid
		if !ErrorLevel {
				OutputDebug % "Requested PID " watchedPid " doesn't exist anymore"
				return false
		}
		; OutputDebug %  "Start watching PID " watchedPid

		static PROCESS_ALL_ACCESS := 0x1F0FFF
		static WT_EXECUTEONLYONCE := 0x00000008
		static INFINITE := 0xFFFFFFFF

		if (this.m_procData.HasKey(watchedPid)) {
			this.unwatch(watchedPid)
		}

		hProcWatched := DllCall("OpenProcess", "UInt",PROCESS_ALL_ACCESS, "Int",false, "UInt",watchedPid, "Ptr")
		ahkRegisterCallback := RegisterCallback("ProccessTerminationWatcher_WaitOrTimerCallback",,,watchedPid)
		;From docs on 'Ptr*' DllCall:
		;Since variables in AutoHotkey have no fixed type, the address passed to the function points to temporary memory rather than the variable itself.
		;It is not necessary to call VarSetCapacity() on the variable as DllCall will update it correctly after the function returns
		; VarSetCapacity(waitHandle, A_PtrSize)
		waitHandle := ""
		if !DllCall("RegisterWaitForSingleObject"
									, "Ptr*", waitHandle
									, "Ptr", hProcWatched
									, "Ptr", ahkRegisterCallback
									, "Ptr", &this ; context passed as lpParameter of WaitOrTimerCallback() below
									, "UInt", INFINITE
									, "UInt", WT_EXECUTEONLYONCE) {
			OutputDebug % "Failed call to RegisterWaitForSingleObject(): " ErrMsg()
			DllCall("CloseHandle", "Ptr", hProcWatched)
			return false
		}
		if !DllCall("CloseHandle", "Ptr",hProcWatched) {
			OutputDebug % "Failed to CloseHandle() for PID " watchedPid ": " ErrMsg()
			return false
		}

		this.m_procData[watchedPid] := {userCallback        : callback
		                              , ahkRegisterCallback : ahkRegisterCallback
		                              , hWait               : waitHandle }
		return true
	}

	unwatch(pid) {
		if this.m_procData.HasKey(pid) {
			DllCall("GlobalFree", "Ptr",this.m_procData[pid].ahkRegisterCallback, "Ptr")

			;IMPORTANT: using async timer call beacuse UnregisterWait() must NOT be called from within userCallback (according to docs).
			functor := ObjBindMethod(this, "unregisterWait", this.m_procData[pid].hWait)
			SetTimer %functor%, -100

			this.m_procData.Remove(pid)
		}
	}

	__Delete() {
		for watchedPid, procData in this.m_procData {
			DllCall("GlobalFree", "Ptr",procData.ahkRegisterCallback, "Ptr")
			this.unregisterWait(procData.hWait)
		}
	}

;private:
	unregisterWait(hWait) {
		; OutputDebug % "Calling UnregisterWait()"
		if !DllCall("UnregisterWait", "Ptr",hWait) {
			OutputDebug % "Failed call to UnregisterWait(): " ErrMsg()
		}
	}

	; {watchedPid : {hWait:, userCallback:, ahkRegisterCallback:}}
	m_procData := {}
}

ProccessTerminationWatcher_WaitOrTimerCallback(lpParameter, TimerOrWaitFired) {
	terminatedPid := A_EventInfo
	; OutputDebug % A_ThisFunc ": PID " terminatedPid " terminated"
	this := object(lpParameter)
	userCallback := this.m_procData[terminatedPid].userCallback
	this.unwatch(terminatedPid)
	SetTimer %userCallback%, -1
}