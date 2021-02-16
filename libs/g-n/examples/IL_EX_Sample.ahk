#NoEnv
#Include IL_EX.ahk
SetBatchLines, -1
; Create an ImageList of appropriate size ------------------------------------------------------------------------------
W := A_ScreenWidth // 2
H := A_ScreenHeight // 2
PicFiles := []
PicNum := 16
Loop, %A_WinDir%\Web\Wallpaper\*.jpg, 0, 1
   PicFiles.Insert(A_LoopFileLongPath)
Until (A_Index = 16)
PicNum := PicFiles.MaxIndex()
If (PicNum > 16)
   PicNum := 16
HIL := IL_Create(PicNum)
IL_EX_SetSize(HIL, W, H)
IL_EX_SetBkColor(HIL)
HIcons := []
Loop, % PicNum {
   Progress, % (100 / PicNum * A_Index), % PicFiles[A_Index], Image %A_Index% of %PicNum%, Loading Images
   I := IL_Add(HIL, PicFiles[A_Index], 0xFFFFFF, 1)
   HIcons.Insert(IL_EX_GetHICON(HIL, I))
}
Progress, Off
; GUI ------------------------------------------------------------------------------------------------------------------
Gui, -Caption +ToolWindow +hwndHGUI
Gui, Color, 000000
Gui, Margin, 20, 20
Gui, Add, Pic, xm ym w%W% h%H% hwndHPIC gGuiMove +0x03, ; % PicFiles[PicNum] ; 0x03 = SS_ICON
Gui, Font, s10 Bold, Arial
Gui, Add, Text, xm y+10 h25 w100 vRep gRepeat Center +0x200 Hidden cLime +E0x01, Repeat
X := 140
W2 := W - X - 120
Gui, Add, Text, x%X% yp w%W2% hp Center +0x200 cWhite vPicName
X := 20 + W - 100
Gui, Add, Text, x%X% yp hp w100 vCls gGuiClose Center +0x200 Hidden cRed +E0x01, Close
Gui, Show
; ----------------------------------------------------------------------------------------------------------------------
ShowImages:
   GuiControl, Hide, Rep
   GuiControl, Hide, Cls
   Loop, % PicNum {
      GuiControl, , PicName, % "Pic " . A_Index . " of " . PicNum . " - " . PicFiles[A_Index]
      ; SendMessage, 0x0170, % HIcons[A_Index], 0, , ahk_id %HPIC% ; STM_SETICON
      IL_EX_Draw(HIL, A_Index, HPIC)
      Sleep, 1000
   }
   GuiControl, Show, Rep
   GuiControl, Show, Cls
Return
; ----------------------------------------------------------------------------------------------------------------------
Repeat:
   Gosub, ShowImages
return
; ----------------------------------------------------------------------------------------------------------------------
Esc::
GuiClose:
   IL_Destroy(HIL)
ExitApp
GuiMove:
   PostMessage, 0xA1, 2, 0, , ahk_id %HGUI%
Return