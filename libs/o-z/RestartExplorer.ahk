; Title:   	RestartExplorer() : Updated version
; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=6&t=81252
; Author:	SKAN
; Date:   	20-09-2020
; for:     	AHK_L

/*


*/

RestartExplorer( WaitSecs:=10 ) { ; requires OS Vista+    ; v2.10 by SKAN on CSC7/D39N
Local PID, Explorer, ID:=WinExist("ahk_class Progman")  ; @ tiny.cc/restartexplorer2
  WinGet, PID, PID
  WinGet, Explorer, ProcessPath
  PostMessage, 0x5B4, 0, 0,, ahk_class Shell_TrayWnd ; WM_USER+436
  Process, WaitClose, %PID%, % ( PID ? WaitSecs : (WaitSecs:=0) )
  If (PID && !Errorlevel)
    Run, %Explorer%
  WinWait, ahk_class Progman,, %WaitSecs%
Return (WinExist()!=ID)
}