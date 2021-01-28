/*
WinSet_Click_Through - Makes a window unclickable.

Paramenters:
I - ID of the window to set as unclickable.
T - The transparency to set the window. Leaving it blank will set it to 150. It can also be set On, Off, or Toggled. Any numbers lower then 0 or greater then 255 will simply be changed to 150.

Returns:
If the window ID doesn't exist, it returns -1.
If the window was set as unclickable, it returns 1.
If the window was set as clickable, it returns 0.

Examples:
WinSet_Click_Through(I, "T|150") - Toggles click-through for the window I with 150 transparency.
WinSet_Click_Through(I, "T") - Toggles click-through for the window I with default transparency.
WinSet_Click_Through("", 50) - Enables click-through for the active window with 50 transparency.
WinSet_Click_Through("", "On") - Enables click-through for the active window with default transparency.
WinSet_Click_Through(I, "Off") - Makes the window I clickable.
*/

WinSet_Click_Through(I="", T="150") {
   If(I==""||I=="A")
      I := WinExist("A")
   IfWinNotExist, % "ahk_id " I
      Return -1
   WinGetClass, C, % "ahk_id " I
   If(C=="Progman"||C=="WorkerW")
      Return -1
   If T is Number
   {
      If(T<0||T>254)
         F:=254
      Else
         F:=T
      GoTo, Set_Click_Through
   }
   Else If T is Alpha
   {
      If(T=="On"||T=="True")
      {
         F:=254
         GoTo, Set_Click_Through
      }
      Else If(T=="Off"||T=="False")
         GoTo, Remove_Click_Through
      Else If(T=="T")
      {
         If WinGet_Click_Through(I)
            GoTo, Remove_Click_Through
         F:=150
         GoTo, Set_Click_Through
      }
      Return -1
   }
   Else
   {
      If(InStr(T,"T")==1)
      {
         If WinGet_Click_Through(I)
            GoTo, Remove_Click_Through
         If(InStr(T,"|")==2)
         {
            StringSplit, T, T, |
            WinSet_Click_Through("", T2)
            Return
         }
      }
      Else
         Return -1
   }      
   Set_Click_Through:
      WinSet, AlwaysOnTop, On, % "ahk_id " I
      WinSet, Transparent, % F, % "ahk_id " I
      WinSet, ExStyle, +0x20, % "ahk_id " I
   Return 1
   Remove_Click_Through:
      WinSet, AlwaysOnTop, Off, % "ahk_id " I
      WinSet, Transparent, Off, % "ahk_id " I
      WinSet, ExStyle, -0x20, % "ahk_id " I
   Return 0
}

/*
WinGet_Click_Through - Checks if a window is unclickable.

Parameters:
I - ID of the window to set as unclickable.

Returns:
If the window ID doesn't exist, it returns -1.
If the window is set as unclickable, it returns 1.
If the window is set as clickable, it returns 0.
*/

WinGet_Click_Through(I="") {
   If(I == "" || I == "A")
      I := WinExist("A")
   IfWinNotExist, % "ahk_id " I
      Return -1
   WinGet, S, ExStyle, % "ahk_id " I
   If (S & 0x80000 && S & 0x8 && S & 0x00000020)
      Return True
   Else
      Return False
}

/*
WinSet_Click_Through_Class - Makes a class of window unclickable.

Paramenters:
I - Class of the windows to set as unclickable.
T - The transparency to set the windows. Leaving it blank will set it to 150. It can also be set On, Off, or Toggled. Any numbers lower then 0 or greater then 255 will simply be changed to 150.

Returns:
If the window class doesn't exist, it returns -1.
If the window class was set as unclickable, it returns 1.
If the window class was set as clickable, it returns 0.
*/

WinSet_Click_Through_Class(I="", T="150") {
   If(I==""||I=="A")
      WinGetClass, I, A
   IfWinNotExist, % "ahk_class " I
      Return -1
   If(I=="Progman"||I=="WorkerW")
      Return -1
   If T is Number
   {
      If(T<0||T>254)
         F:=254
      Else
         F:=T
      GoTo, Set_Click_Through_Class
   }
   Else If T is Alpha
   {
      If(T=="On"||T=="True")
      {
         F:=254
         GoTo, Set_Click_Through_Class
      }
      Else If(T=="Off"||T=="False")
         GoTo, Remove_Click_Through_Class
      Else If(T=="T")
      {
         If WinGet_Click_Through_Class(I)
            GoTo, Remove_Click_Through_Class
         F:=150
         GoTo, Set_Click_Through_Class
      }
      Else
         Return -1
   }
   Else
   {
      If(InStr(T,"T")==1)
      {
         If WinGet_Click_Through_Class(I)
         GoTo, Remove_Click_Through_Class
         If(InStr(T,"|")==2)
         {
            StringSplit, T, T, |
            WinSet_Click_Through_Class("", T2)
            Return
         }
      }
      Else
         Return -1
   }      
   Set_Click_Through_Class:
      WinGet, L, List
      Loop, % L
      {
         WinGetClass, C, % "ahk_id " L%A_Index%
         If(C==I)
            WinSet_Click_Through(L%A_Index%, F)
      }
   Return 1
   Remove_Click_Through_Class:
      WinGet, L, List
      Loop, % L
      {
         WinGetClass, C, % "ahk_id " L%A_Index%
         If(C==I)
            WinSet_Click_Through(L%A_Index%, "Off")
      }
   Return 0
}

/*
WinGet_Click_Through_Class - Checks if a window is unclickable.

Parameters:
I - ID of the window to set as unclickable.

Returns:
If the window ID doesn't exist, it returns -1.
If the window is set as unclickable, it returns 1.
If the window is set as clickable, it returns 0.
*/

WinGet_Click_Through_Class(I="") {
   If(I==""||I=="A")
      WinGetClass, I, A
   IfWinNotExist, % "ahk_class " I
      Return -1
   WinGet, L, List
   Loop, % L
   {
      WinGetClass, C, % "ahk_id " L%A_Index%
      If(C==I)
         If !WinGet_Click_Through(L%A_Index%)
            Return False
   }
   Return True
}

/*
WinSet_Click_Through_PIDs - Makes a set of window with PID P unclickable.

Paramenters:
P - PID of the windows to set as unclickable.
T - The transparency to set the windows. Leaving it blank will set it to 150. It can also be set On, Off, or Toggled. Any numbers lower then 0 or greater then 255 will simply be changed to 150.

Returns:
If the PID doesn't exist, it returns -1.
If the PID was set as unclickable, it returns 1.
If the PID was set as clickable, it returns 0.
*/

WinSet_Click_Through_PID(P="", T="150") {
   Process, Exist, % P
   If !ErrorLevel
      Return -1
   P:=ErrorLevel
   If T is Number
   {
      If(T<0||T>254)
         F:=254
      Else
         F:=T
      GoTo, Set_Click_Through_PID
   }
   Else If T is Alpha
   {
      If(T=="On"||T=="True")
      {
         F:=254
         GoTo, Set_Click_Through_PID
      }
      Else If(T=="Off"||T=="False")
         GoTo, Remove_Click_Through_PID
      Else If(T=="T")
      {
         If WinGet_Click_Through_PID(P)
            GoTo, Remove_Click_Through_PID
         F:=150
         GoTo, Set_Click_Through_PID
      }
      Else
         Return -1
   }
   Else
   {
      If(InStr(T,"T")==1)
      {
         If WinGet_Click_Through_PID(P)
            GoTo, Remove_Click_Through_PID
         If(InStr(T,"|")==2)
         {
            StringSplit, T, T, |
            WinSet_Click_Through_PID("", T2)
            Return
         }
      }
      Else
         Return -1
   }      
   Set_Click_Through_PID:
      WinGet, L, List
      Loop, % L
      {
         WinGet, WP, PID, % "ahk_id " L%A_Index%
         If(WP==P)
            WinSet_Click_Through(L%A_Index%, F)
      }
   Return 1
   Remove_Click_Through_PID:
      WinGet, L, List
      Loop, % L
      {
         WinGet, WP, PID, % "ahk_id " L%A_Index%
         If(WP==P)
            WinSet_Click_Through(L%A_Index%, "Off")
      }
   Return 1
}

/*
WinGet_Click_Through_PID - Checks set of windows with PID P are unclickable.

Parameters:
P - PID of the windows to get as unclickable.

Returns:
If the PID doesn't exist, it returns -1.
If the PID is set as unclickable, it returns 1.
If the PID is set as clickable, it returns 0.
*/

WinGet_Click_Through_PID(P="") {
   Process, Exist, % P
   If !ErrorLevel
      Return 0
   P:=ErrorLevel
   WinGet, L, List
   Loop, % L
   {
      WinGet, WP, PID, % "ahk_id " L%A_Index%
      If(WP==P)
         If !WinGet_Click_Through(L%A_Index%)
            Return False
   }
   Return True
}

/*
WinGet_Transparent - Gets the transparency of a given window.

Paramenters:
I - ID of the window to set as unclickable.

Returns:
If the window ID doesn't exist, it returns -1.
If the window exists, it returns the transparency.
*/

WinGet_Transparent(I="") {
   If(I==""||I=="A")
      I := WinExist("A")
   IfWinNotExist, % "ahk_id " I
      Return -1
   WinGet, T, Transparent, % "ahk_id " I
   If(T=="")
      T:=255
   Return T
}

/*
WinSet_Click_Through_Click - Clicks on an unclickable window without activating it.

Returns:
If the window ID doesn't exist, it returns -1.
If an unclickable window was clicked, it returns 1.
*/

WinSet_Click_Through_Click() {
   R:=0
   WinGet, L, List
   Loop, % L
   {
      If WinGet_Click_Through(L%A_Index%)
      {
         WinGetPos, W_X, W_Y, W_W, W_H, % "ahk_id " L%A_Index%
         MouseGetPos, M_X, M_Y
         If(M_X>W_X&&M_X<W_X+W_W&&M_Y>W_Y&&M_Y<W_Y+W_H)
         {
            R:=1
            WinSet, ExStyle, -0x20, % "ahk_id " L%A_Index%
            WinSet_NoActivate(L%A_Index%, "On")
            Click
            WinSet_NoActivate(L%A_Index%, "Off")
            WinSet, ExStyle, +0x20, % "ahk_id " L%A_Index%
         }
      }
   }
   Return R
}