; shows the script own traymenu
; https://www.autohotkey.com/boards/viewtopic.php?f=9&t=104867

ShowTray() {
   Local
   Static SizeOfNII := (A_PtrSize * 3) + 16
   VarSetCapacity(NII, SizeOfNII, 0)
   NumPut(SizeOfNII, NII, 0, "UInt")
   NumPut(A_ScriptHwnd, NII, A_PtrSIze, "UPtr")
   NumPut(0x0404, NII, A_PtrSize * 2, "UInt")
   VarSetCapacity(RC, 16, 0)
   If !DllCall("Shell32.dll\Shell_NotifyIconGetRect", "Ptr", &NII, "Ptr", &RC, "UInt") {
      CMM := A_CoordModeMenu
      CoordMode, Menu, Screen
      L := NumGet(RC, 0, "Int")
      T := NumGet(RC, 4, "Int")
      R := NumGet(RC, 8, "Int")
      B := NumGet(RC, 12, "Int")
      X := (L + R) // 2
      Y := (T + B) // 2
      Menu, Tray, Show, %X%, %Y%
      CoordMode, Menu, %CMM%
   }
}