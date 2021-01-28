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
; Parameters ...: hWnd     - Handle of the window that will receive the notification.
; ..............: nMsgId   - Generic message ID (msg).
; ..............: nPid     - PID of the process that needs to be waited for.
; ..............: sDataIn  - Arbitrary data (use this to pass any data in string form).
; Return .......: Address of global allocated structure.
; ----------------------------------------------------------------------------------------------------------------------
TermWait_WaitForProcTerm(hWnd, nMsgId, nPid, ByRef sDataIn:="") {
    Static addrCallback := RegisterCallback("__TermWait_TermNotifier")
        
    szDataIn := VarSetCapacity( sDataIn )
    pGlobal  := DllCall( "GlobalAlloc", UInt,0x0040, UInt,(A_PtrSize==4)?20+szDataIn:32+szDataIn )
    hProc    := DllCall( "OpenProcess", UInt,0x00100000, UInt,0, UInt,nPid                       )

    NumPut( hWnd,   pGlobal+0                                  )
    NumPut( nMsgId, (A_PtrSize == 4) ? pGlobal+4  : pGlobal+8  )
    NumPut( nPid,   (A_PtrSize == 4) ? pGlobal+8  : pGlobal+12 )
    NumPut( hProc,  (A_PtrSize == 4) ? pGlobal+12 : pGlobal+16 )
    
    DllCall( "RtlMoveMemory", Ptr,(A_PtrSize==4)?pGlobal+20:pGlobal+32, Ptr,&sDataIn, UInt,szDataIn               )
    DllCall( "RegisterWaitForSingleObject", Ptr,(A_PtrSize==4)?pGlobal+16:pGlobal+24, Ptr,hProc, Ptr,addrCallback
                                          , Ptr,pGlobal, UInt,0xFFFFFFFF, UInt,0x00000004|0x00000008              )
    Return pGlobal
}

; ----------------------------------------------------------------------------------------------------------------------
; Function .....: TermWait_StopWaiting
; Description ..: This function cleans all handles and frees global allocated memory.
; Parameters ...: pGlobal - Global structure address.
; ----------------------------------------------------------------------------------------------------------------------
TermWait_StopWaiting(pGlobal) {
    DllCall( "UnregisterWait", UInt,NumGet((A_PtrSize==4)?pGlobal+16:pGlobal+24) )
    DllCall( "CloseHandle",    UInt,NumGet((A_PtrSize==4)?pGlobal+12:pGlobal+16) )
    DllCall( "GlobalFree",     UInt,pGlobal                                      )
}

; ----------------------------------------------------------------------------------------------------------------------
; Function .....: __TermWait_TermNotifier
; Description ..: This callback is called when a monitored process signal its closure. It gets executed on a different 
; ..............: thread because of the RegisterWaitForSingleObject, so it could interferee with the normal AutoHotkey 
; ..............: behaviour (eg. it's not bug free).
; Parameters ...: pGlobal - Global structure.
; ----------------------------------------------------------------------------------------------------------------------
__TermWait_TermNotifier(pGlobal) { ; THIS FUNCTION GETS EXECUTED IN A DIFFERENT THREAD!!!
    DllCall( "SendNotifyMessage", Ptr,NumGet(pGlobal+0), UInt,NumGet((A_PtrSize==4)?pGlobal+4:pGlobal+8)
                                , UInt,0, UInt,pGlobal )
}

/* EXAMPLE CODE:
#SingleInstance force
#Persistent

MSGID   := 0x8500   ; msg
OnMessage(MSGID, "AHK_TERMNOTIFY")

Gui, +LastFound +HwndhWnd

Run, %A_WinDir%\System32\cmd.exe,,, nPid
sSomeData := "WTF! I was waiting for " . nPid . " to terminate. Now it's not running anymore. I'm cool."
TermWait_WaitForProcTerm(hWnd, MSGID, nPid, sSomeData)
Return

AHK_TERMNOTIFY(wParam, lParam) {
    ; ... DO SOMETHING
    MsgBox, % DllCall("MulDiv", Int, lParam+20, Int, 1, Int, 1, Str)
    ; ... DO SOMETHING
    TermWait_StopWaiting(lParam)
}
*/