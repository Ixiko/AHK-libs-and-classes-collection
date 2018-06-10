; Instance() - 0.41 - gwarble
;  creates another instance to perform a task
;    help: http://www.autohotkey.com/forum/viewtopic.php?p=310694
;
; Instance(Label,Params,AltWM)
;
;  Label   "" to initialize, in autoexecute section usually
;          "Label" to start a new instance, whose execution will be
;            redirected to the "Label" subroutine
;
;  Params  parameters to pass to new instance (retrieved normally, ie: %2%)
;          when initializing (ie: label="") Params is a label prefix for all calls
;          last param received by script is calling-instance's ProcessID
;
;  AltWM   Alternate WindowsMessage number if 0x1357 (arbitrary anyway) will conflict
;
;  Return  0 on normal initialization (ie: label="" and %1% <> any label:)
;          Process ID of new instance
;          0 on failed new instance (called label name not exist)

Instance(Label="", Params="", WM="0x1357") {
 global 1		; uses first command line parameter to redirect auto-execute section
 If Label =
 {
  Label = %1%
  If (InStr(Label, Params) = 1)
  {
   If IsLabel(Label)
   {
    GoSub, %Label%
    Return 1
   }
  }
  Else
  {
   pDHW := A_DetectHiddenWindows
   DetectHiddenWindows, On
   WinGet, Instance_ID, List, %A_ScriptFullPath%
   If (Params <> "Single")
    Loop %Instance_ID%
     SendMessage, WM, WM, 0, , % "ahk_id " Instance_ID%A_Index%
   DetectHiddenWindows, %pDHW%
   OnMessage(WM, "Instance_")
  }
  Return 0
 }
 Else
 {
  If IsLabel(Label)
  {
   ProcessID := DllCall("GetCurrentProcessId")
   If A_IsCompiled
    Run, "%A_ScriptFullPath%" /f "%Label%" %Params% %ProcessID%,,,Instance_PID
   Else
    Run, "%A_AhkPath%" /f "%A_ScriptFullPath%" "%Label%" %Params% %ProcessID%,,,Instance_PID 
   Return %Instance_PID%
  }
  Return 0
 }
 #SingleInstance, Off 	; your script needs this anyway for Instance() to be useful
}


Instance_(wParam, lParam) {	; OnMessage Handler for singleInstance behavior or to
 Critical		; send messages back to calling instance via subroutine to run
 If lParam = 0		; (ie status updates, "i'm finished", etc)
  ExitApp		 ; if message lparam sent back besides 0, calling
 Else If IsLabel(Label := "Instance_" lParam) ; ; instance looks for and runs label Instance_%lParam%
  GoSub, %Label%		; so the script would have a label like:
 Return		; Instance_1: and Instance_2: or Instance_%Integer%:
}		; and the new instance can SendMessage,WM,WM,Integer to the calling instance
