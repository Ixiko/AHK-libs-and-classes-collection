; Title:   	ShowMenu() : in center screen.
; Link:   	autohotkey.com/boards/viewtopic.php?p=353075#p353075
; Author:	SKAN
; Date:   	16.09.2020
; for:     	AHK_L

; Intro: : Default Menu command doesn't have flags options to control the display of menu. for eg. displaying a menu at absolute center of screen.
; My need: When we click on Start button, start menu appears nicely docked to the task bar. But if we right-click on the AHK notification icon, it appears
; partly over the tray obstructing view of other icons. To make tray menu behave like Start menu, I need the alignment flags and hence I wrote this function.
; Edit: A demo Start menu like Tray menu has been posted a few posts below.

/*  ShowMenu(hMenu, MenuLoop, X, Y, Flags)

  Parameters:

  hMenu. Create a menu and use MenuGetHandle() to get a Win32 handle.
  MenuLoop: By default, AutoHotkey block timers, non-system messages etc., when a Menu is being shown.
  Pass true if you want to bypass this. I don't recommend this option for serious/sensitive scripts.
  X, Y. The screen position/point for Menu. If you use MouseGetPos to get X,Y then set CoordMode to screen.
  Flags. Default value is 0 (TPM_LEFTALIGN |TPM_TOPALIGN). Combine one each from vertical/horizontal for menu alignment relative to X,Y
  Horizontal
  TPM_CENTERALIGN 0x04
  TPM_LEFTALIGN 0x00
  TPM_RIGHTALIGN 0x08
  Vertical
  TPM_BOTTOMALIGN 0x02
  TPM_TOPALIGN 0x00
  TPM_VCENTERALIGN 0x10
  The demo uses TPM_VCENTERALIGN | TPM_CENTERALIGN

*/

/*  Example

*/

#NoEnv
#SingleInstance, Force
Menu, Tray, NoStandard
Menu, Tray, Add, Menu, Routine
Menu, Tray, Default, Menu
Menu, Tray, Add
Menu, Tray, Click, 1
Menu, Tray, Standard
Return

Routine:
  ShowMenu(MenuGetHandle("Tray"), False, TrayMenuParams()*)
Return

ShowMenu(hMenu, MenuLoop:=0, X:=0, Y:=0, Flags:=0) {            ; Ver 0.61 by SKAN on D39F/D39G
Local                                                           ;            @ tiny.cc/showmenu
  If (hMenu="WM_ENTERMENULOOP")
    Return True
  Fn := Func("ShowMenu").Bind("WM_ENTERMENULOOP"), n := MenuLoop=0 ? 0 : OnMessage(0x211,Fn,-1)
  DllCall("SetForegroundWindow","Ptr",A_ScriptHwnd)
  R := DllCall("TrackPopupMenu", "Ptr",hMenu, "Int",Flags, "Int",X, "Int",Y, "Int",0
             , "Ptr",A_ScriptHwnd, "Ptr",0, "UInt"),                     OnMessage(0x211,Fn, 0)
  DllCall("PostMessage", "Ptr",A_ScriptHwnd, "Int",0, "Ptr",0, "Ptr",0)
Return R
}


TrayMenuParams() {      ; Original function is TaskbarEdge() by SKAN @ tiny.cc/taskbaredge
Local    ; This modfied version to be passed as parameter to ShowMenu() @ tiny.cc/showmenu
  VarSetCapacity(var,84,0), v:=&var,   DllCall("GetCursorPos","Ptr",v+76)
  X:=NumGet(v+76,"Int"), Y:=NumGet(v+80,"Int"),  NumPut(40,v+0,"Int64")
  hMonitor := DllCall("MonitorFromPoint", "Int64",NumGet(v+76,"Int64"), "Int",0, "Ptr")
  DllCall("GetMonitorInfo", "Ptr",hMonitor, "Ptr",v)
  DllCall("GetWindowRect", "Ptr",WinExist("ahk_class Shell_SecondaryTrayWnd"), "Ptr",v+68)
  DllCall("SubtractRect", "Ptr",v+52, "Ptr",v+4, "Ptr",v+68)
  DllCall("GetWindowRect", "Ptr",WinExist("ahk_class Shell_TrayWnd"), "Ptr",v+36)
  DllCall("SubtractRect", "Ptr",v+20, "Ptr",v+52, "Ptr",v+36)
  Loop % (8, offset:=0)
    v%A_Index% := NumGet(v+0, offset+=4, "Int")
Return ( v3>v7 ? [v7, Y, 0x18] : v4>v8 ? [X, v8, 0x24]
       : v5>v1 ? [v5, Y, 0x10] : v6>v2 ? [X, v6, 0x04] : [0,0,0] )
}