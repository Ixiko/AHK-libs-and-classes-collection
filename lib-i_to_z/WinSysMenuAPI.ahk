; WinSysMenuAPI.ahk - Window System Menu Manipulator Library
;
; Functions to remove or reenable window managing menu items and commands.
;
; Example:
;   DisableWindowClosing(WinExist(ahk_class TTOTAL_CMD))
;   This will prevent closing Total Commander by mouse, but you can still close it with Alt+F4.
;
; If you call a function without the hWnd parameter,
; it will be performed on the active window.
;
; The functions can be used on the script's own Gui window too:
;   Gui +LastFoundExist  ; Set the GUI window as the last found
;   GUIhWnd := WinExist()  ; Get last found window handle
;   DisableWindowMoving(GUIhWnd)  ; Prevent window from moving
;
; You can always restore the original menu by calling RevertSystemMenu() function.
;
; Tested with AutoHotkey 1.0.47.04
;
; Created by HuBa
; Contact: http://www.autohotkey.com/forum/profile.php?mode=viewprofile&u=4693
;
; Discussion forum: http://www.autohotkey.com/forum/topic19303.html
;
; For system command constants see: http://source.winehq.org/source/include/winuser.h

GetSystemMenu(ByRef hWnd, Revert = False) { ; Get system menu handle
  hWnd := hWnd ? hWnd : WinExist("A")  ; Active window handle
  Return DllCall("GetSystemMenu", "UInt", hWnd, "UInt", Revert)
}
DrawMenuBar(hWnd) { ; Internal function: this is needed to apply menu changes
  Return DllCall("DrawMenuBar", "UInt", hWnd)
}
RevertSystemMenu(hWnd = "") { ; Restores all removed menu items

  Return DrawMenuBar(GetSystemMenu(hWnd, True))  ; Revert system menu
}
RemoveMenu(hWnd, Position, Flags = 0) { ; MF_BYCOMMAND = 0x0000
  DllCall("RemoveMenu", "UInt", GetSystemMenu(hWnd), "UInt", Position, "UInt", Flags)
  Return DrawMenuBar(hWnd)
}
DeleteWindowResizing(hWnd = "") {
  Return RemoveMenu(hWnd, 0xF000)  ; SC_SIZE = 0xF000
}
DeleteWindowMoving(hWnd = "") {
  Return RemoveMenu(hWnd, 0xF010)  ; SC_MOVE = 0xF010
}
DeleteWindowMinimizing(hWnd = "") {
  Return RemoveMenu(hWnd, 0xF020)  ; SC_MINIMIZE = 0xF020
}
DeleteWindowMaximizing(hWnd = "") {
  Return RemoveMenu(hWnd, 0xF030)  ; SC_MAXIMIZE = 0xF030
}
DeleteWindowArranging(hWnd = "") {
  Return RemoveMenu(hWnd, 0xF110)  ; SC_ARRANGE = 0xF110
}
DeleteWindowRestoring(hWnd = "") {
  Return RemoveMenu(hWnd, 0xF120)  ; SC_RESTORE = 0xF120
}
DeleteWindowClosing(hWnd = "") {
  Return RemoveMenu(hWnd, 0xF060)  ; SC_CLOSE = 0xF060
}
DeleteWindowMenuSeparator(hWnd = "") {  ; Removes the line above Close menuitem
  Return RemoveMenu(hWnd, 0)
}
EnableMenuItem(hWnd, SystemCommand, EnableFlag) {
  DllCall("EnableMenuItem", "UInt", GetSystemMenu(hWnd), "UInt", SystemCommand, "UInt", EnableFlag)  ; MF_BYCOMMAND = 0
  Return DrawMenuBar(hWnd)
}
DisableWindowResizing(hWnd = "") {
  Return DeleteWindowResizing()  ; Disabling has no effect, use delete instead
}
DisableWindowMoving(hWnd = "") {
  Return DeleteWindowMoving()
}
DisableWindowMinimizing(hWnd = "") {
  Return DeleteWindowMinimizing()
}
DisableWindowMaximizing(hWnd = "") {
  Return DeleteWindowMaximizing()
}
DisableWindowArranging(hWnd = "") {
  Return DeleteWindowArranging()
}
DisableWindowRestoring(hWnd = "") {
  Return DeleteWindowRestoring()
}
DisableWindowClosing(hWnd = "") {
  Return EnableMenuItem(hWnd, 0xF060, 1)  ; MF_GRAYED = 0x0001
}
EnableWindowResizing(hWnd = "") {
  Return EnableMenuItem(hWnd, 0xF000, 0)  ; MF_ENABLED = 0x0000
}
EnableWindowMoving(hWnd = "") {
  Return EnableMenuItem(hWnd, 0xF010, 0)
}
EnableWindowMinimizing(hWnd = "") {
  Return EnableMenuItem(hWnd, 0xF020, 0)
}
EnableWindowMaximizing(hWnd = "") {
  Return EnableMenuItem(hWnd, 0xF030, 0)
}
EnableWindowArranging(hWnd = "") {
  Return EnableMenuItem(hWnd, 0xF110, 0)
}
EnableWindowRestoring(hWnd = "") {
  Return EnableMenuItem(hWnd, 0xF120, 0)
}
EnableWindowClosing(hWnd = "") {
  Return EnableMenuItem(hWnd, 0xF060, 0)
}