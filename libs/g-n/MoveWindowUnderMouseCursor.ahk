; Title:   	MoveWindowUnderMouseCursor() with a hotkey
; Link:    	autohotkey.com/boards/viewtopic.php?p=349760#p349760
; Author:	SKAN
; Date:
; for:     	AHK_L

/*

  #NoEnv
  #SingleInstance, Force
  ^#RButton:: MoveWindowUnderMouseCursor()

*/

MoveWindowUnderMouseCursor(Except:="Progman WorkerW Shell_TrayWnd") {  ;    By SKAN on D38S/D38S
Local                                            ; @ autohotkey.com/boards/viewtopic.php?t=80416
  MouseGetPos,,, hWnd
  WinGetClass, Class, % "ahk_id" . WinExist("ahk_id" . hWnd)
  If ( DllCall("IsZoomed", "Ptr",hWnd)  ||  InStr(" " . Except . " ", " " . Class . " ", True) )
    Return
  WinActivate
  WinWaitActive,,, 0
  PostMessage, 0x112, 0xF010                                       ;      WM_SYSCOMMAND, SC_MOVE
  SendEvent ^{Down}
}
