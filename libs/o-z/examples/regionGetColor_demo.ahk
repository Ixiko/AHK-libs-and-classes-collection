; Tuncay: I made small changes only.
; Thanks to tic for most of the demonstration script.
; #include regionGetColor.ahk
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
;region ;AutoExec; #######################################################################
#SingleInstance, Force
CoordMode, Mouse, Screen
MsgBox Press Alt+LeftMouseButton for selecting new area.`n`nPress Alt+r for rechecking that area and refreshing the gui.
RegionMain:
If !regionInit
{
   OnExit, Exit
   Gui, 1:+AlwaysOnTop +ToolWindow
   Gui, 1:Color, 0xffffff
   Gui, 1:Add, Edit, vGuiTextVar +ReadOnly h160 w180, Color: 0xffffff`nCount: `nTime: `n`n`n`n`n`n`n
   Gui, 1:Show, , regionColor
   Gui, 2:Color, 0xCCCCCC
   Gui, 2:+ToolWindow -Caption +Border +AlwaysOnTop +0x20 ; 0x20=click-thru
   Gui, 2:Add, Text, vGuiTextVar2 w80
   Gui, 2:+LastFound
   2GuiID := WinExist()
   Gui, 2:Show, X-2000 Y-2000 W1 H1
   WinSet, Trans, 150, ahk_id %2GuiID%
;   CoordMode, Mouse, Screen
   Process, Priority,, High
   SetBatchLines, -1
   SetWinDelay, -1
   RegionInit = 1
   GuiX := GuiY := 0
   GuiW := GuiH := 100
}
Gui, 1:Show
return
;end_region

;region ;Labels and Hotkeys; #############################################################
Esc::
Exit:
GuiClose:
   ExitApp

!LButton::
; use gui 2 to create a rectangle for area selection
   If !RegionInit
      GoSub RegionMain
   MouseGetPos, s_MSX, s_MSY, s_ID, s_CID, 2 ;start mouse X and Y
   WinSet, AlwaysOnTop, On, ahk_id %2GuiID%
   Loop
   {
      Sleep 20
      If !GetKeyState("LButton", "P")                  ;break if user releases the mouse
         Break   
      MouseGetPos, c_MSX, c_MSY                     ;current mouse X and Y
      GuiX := (s_MSX < c_MSX ? s_MSX : c_MSX)            ;use whichever smaller for X and Y
      GuiY := (s_MSY < c_MSY ? s_MSY : c_MSY)
      GuiW := Abs(Abs(s_MSX)-Abs(c_MSX))               ;doesn't matter which is bigger,
      GuiH := Abs(Abs(s_MSY)-Abs(c_MSY))               ;the absloute difference will be the same
      WinMove, ahk_id %2GuiID%,, GuiX, GuiY, GuiW, GuiH   ;move the window there
      GuiControl, 2:, GuiTextVar2, % GuiW ", " GuiH
   }
!r::               ;to retry at the last used coord.
   WinMove, ahk_id %2GuiID%,, GuiX, GuiY, GuiW, GuiH      ;to see where it's retrying
   Sleep 100
   WinMove, ahk_id %2GuiID%,, -2000,-2000, 2, 2          ;hide the window away
      WinGetPos, WinX, WinY, WinW, WinH, ahk_id %s_ID%
      ControlGetPos, CtrX, CtrY, CtrW, CtrH, , ahk_id %s_CID%
      regionInfo := "Relative to:`n   Screen: " GuiX "," GuiY
      regionInfo .= "`n   Window: " GuiX-WinX "," GuiY-WinY
      regionInfo .= "`n   Control: " GuiX-WinX-CtrX "," Guiy-WinY-CtrY
      regionInfo .= "`nWidth/Height: " GuiW "," GuiH
   Info1 := "RGB:`t"
   Color1 := regionGetColor(GuiX, GuiY, GuiW, GuiH) ;get the color of the region
   Time1 := "Time: " ErrorLevel
   Gui, 1:Color, %Color1%
   GuiControl, , GuiTextVar, % Info1 Color1 "`n`t" Time1 "`n`n" regionInfo
return
;end_region