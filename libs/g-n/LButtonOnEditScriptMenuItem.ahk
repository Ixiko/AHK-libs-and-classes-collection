; Title:   	https://www.autohotkey.com/boards/viewtopic.php?t=38875
; Link:
; Author:
; Date:
; for:     	AHK_L

/*

   MyEditor := "Notepad++.exe"

   SetBatchLines, -1
   OnMessage( 0x111, Func("WM_COMMAND").Bind(MyEditor) )
   Return

   #If scriptPath := LButtonOnEditScriptMenuItem()
   LButton:: Run %MyEditor% "%scriptPath%"

*/


LButtonOnEditScriptMenuItem()  {
   CoordMode, Mouse
   MouseGetPos, X, Y, hWnd
   WinGetClass, WinClass, ahk_id %hWnd%
   if (WinClass != "#32768")
      Return

   WinGet, PID, PID, ahk_id %hWnd%
   DetectHiddenWindows, On
   if !WinExist("ahk_class AutoHotkey ahk_pid " . PID)
      Return

   SendMessage, MN_GETHMENU := 0x1E1,,,, ahk_id %hWnd%
   hMenu := ErrorLevel
   POINT := X | Y << 32
   VarSetCapacity(RECT, 16, 0)
   Loop % DllCall("GetMenuItemCount", Ptr, hMenu)
      DllCall("GetMenuItemRect", Ptr, 0, Ptr, hMenu, UInt, pos := A_Index - 1, Ptr, &RECT)
   until DllCall("PtInRect", Ptr, &RECT, Int64, POINT)

   VarSetCapacity(itemText, 64, 0)
   DllCall("GetMenuString", Ptr, hMenu, UInt, pos, Str, itemText, Int, 32, UInt, MF_BYPOSITION := 0x400)
   if !(itemText = "&Edit This Script" || itemText = "&Edit Script" . A_Tab . "Ctrl+E")
      Return

   WinClose, ahk_id %hWnd%
   WinGetTitle, title
   Return scriptPath := RegExReplace(title, "(.*\.ahk) - AutoHotkey v.*", "$1")
}

WM_COMMAND(MyEditor, wp)  {
   static ID_FILE_EDITSCRIPT := 65401, ID_TRAY_EDITSCRIPT := 65304
   if wp in %ID_FILE_EDITSCRIPT%,%ID_TRAY_EDITSCRIPT%
   {
      Run %MyEditor% "%A_ScriptFullPath%"
      Return 0
   }
}