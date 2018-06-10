#NoEnv
Loop, %A_WinDir%\Web\Wallpaper\*.jpg, 0, 1
{
   PicFile := A_LoopFileLongPath
   Break
}
; PicFile := A_WinDir . "\Web\Wallpaper\Blaues Fenster.jpg"   ; German Win XP
; PicFile := A_WinDir . "\Web\Wallpaper\Landscapes\img7.jpg"  ; Win 7
; PicFile := A_WinDir . "\Web\Wallpaper\theme2\img10.jpg"     ; Win 8.1
Content := "One|Two|Three|Four|Five|Six|Seven|Eight|Nine|Ten|Eleven|Twelve|Thirteen|Fourteen|Fifteen|Sixteen"
; ----------------------------------------------------------------------------------------------------------------------
Global hMain
Gui, New, hwndhMain
Gui, Font, s12
Gui, Add, Picture, x0 y0 w600 h400 hwndhPic, %PicFile%
Gui, Add, ListBox, x50 y50 w200 r8 vLB1 gSel1 Choose1, %Content%
Gui, Add, ListBox, x+100 yp wp hp hwndhLB vLB Choose1 gSelection -VScroll -E0x0200, %Content%
TLB := New TransparentListBox(hLB, hPic, 0xFFFFFF, 0x000000, 0xFFFFFF, 128)
Gui, Show, w600 h400, Transparent ListBox
Return
; ----------------------------------------------------------------------------------------------------------------------
GuiClose:
ExitApp
; ----------------------------------------------------------------------------------------------------------------------
#If WinActive("ahk_id " . hMain)
!x::
   Random, R, 0, % TLB.ItemCount
   GuiControl, %hMain%:Choose, LB, %R%
Return
#If
; ----------------------------------------------------------------------------------------------------------------------
Selection:
   GuiControlGet, LB
   ToolTip, Selected: %LB%`nA_GuiEvent: %A_GuiEvent%`nA_EventInfo: %A_EventInfo%
   SetTimer, KillTT, -750
Return
Sel1:
   GuiControlGet, LB1
   ToolTip, Selected: %LB1%`nA_GuiEvent: %A_GuiEvent%`nA_EventInfo: %A_EventInfo%
   SetTimer, KillTT, -750
Return
KillTT:
   ToolTip
Return
; ----------------------------------------------------------------------------------------------------------------------
#Include Class_TransparentListBox.ahk