; Link:   	
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

#If GetInputLangName(GetInputLangID(WinExist("A"))) = "English"
:*:ttt::the
#If
 
GetInputLangID(hWnd) {
 WinGet, processName, ProcessName, ahk_id %hWnd%
 If (processName = "ApplicationFrameHost.exe") {
  WinGet, PID, PID, ahk_id %hWnd%
  WinGet, controlList, controlListHwnd, ahk_id %hWnd%
  Loop, parse, controlList, `n
   DllCall("GetWindowThreadProcessId", "Ptr", A_LoopField, "UIntP", childPID)
  Until childPID != PID
  dhw_prev := A_DetectHiddenWindows
  DetectHiddenWindows, On
  hWnd := WinExist("ahk_pid" childPID)
  DetectHiddenWindows, % dhw_prev
 }
 threadId := DllCall("GetWindowThreadProcessId", "Ptr", hWnd, "UInt", 0), lyt := DllCall("GetKeyboardLayout", "Ptr", threadId, "UInt")
 Return langID := Format("{:#x}", lyt & 0x3FFF)
}
 
GetInputLangName(langId) {
 Static LOCALE_SENGLANGUAGE := 0x1001
 charCount := DllCall("GetLocaleInfo", "UInt", langId, "UInt", LOCALE_SENGLANGUAGE, "UInt", 0, "UInt", 0)
 VarSetCapacity(localeSig, size := charCount << !!A_IsUnicode, 0)
 DllCall("GetLocaleInfo", "UInt", langId, "UInt", LOCALE_SENGLANGUAGE, "Str", localeSig, "UInt", size)
 Return localeSig
}