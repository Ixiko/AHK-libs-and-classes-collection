/*
WinSet_NoActivate - Makes a window impossible to take focus.

Paramenters:
I - ID of the window to set as NoActivate.
T - The status of the NoActivate. This can be On, Off, T, Toggle, 0, or 1.

Returns:
If the window ID doesn't exist, it returns -1.
If the window was set as NoActvate, it returns 1.
If the window's NoActivate was removed, it returns 0.

Examples:
WinSet_NoActivate("A", "On") - Sets the active window to be NoActivate.
WinSet_NoActivate("", "T") - Toggles the NoActivate of the activate window.
WinSet_NoActivate() - Sets the active window to be NoActivate.
WinSet_NoActivate("A", "Off") - Removes the NoActivate from a window.
*/

WinSet_NoActivate(I="", T="On") {
   If(I == "" || I == "A")
      I := WinExist("A")
   IfWinNotExist, % "ahk_id " I
      Return -1
   If T is Alpha
   {
      If(T=="On")
         GoTo, WinSet_NoActivate
      Else If(T=="Off")
         GoTo, Remove_NoActivate
      Else If(T=="T"||T=="Toggle")
      {
         If !WinGet_NoActivate(I)
            GoTo, Remove_NoActivate
         GoTo, WinSet_NoActivate
      }
      Else
         Return -1
   }
   Else If T is Number
   {
      If(T==True)
         GoTo, WinSet_NoActivate
      Else If(T==False)
         GoTo, Remove_NoActivate
      Else
         Return -1
   }
   Else
      Return -1
   WinSet_NoActivate:
      WinSet, ExStyle, +0x08000000, % "ahk_id " I
   Return 1
   Remove_NoActivate:
      WinSet, ExStyle, -0x08000000, % "ahk_id " I
   Return 0
}

/*
WinGet_NoActivate - Checks if a window is set to NoActivate.

Parameters:
I - ID of the window to check.

Returns:
If the window ID doesn't exist, it returns -1.
If the window is set as NoActivate, it returns 1.
If the window is set as activatable, it returns 0.
*/

WinGet_NoActivate(I="") {
   If(I == "" || I == "A")
      I := WinExist("A")
   IfWinNotExist, % "ahk_id " I
      Return -1
   WinGet, S, ExStyle, % "ahk_id " I
   If (S & 0x08000000)
      Return True
   Else
      Return False
}