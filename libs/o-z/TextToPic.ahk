; Title:   	TextToPic() : Converts a text control to picture control (with limitations)
; Link:   	autohotkey.com/boards/viewtopic.php?f=6&t=92338
; Author:	SKAN
; Date:   	05.07.2021
; for:     	AHK_L

/* DESCRIPTION

       TextToPic( hCtrl, OptionsAsObject )
       Converts a text control to picture control (with limitations).
       GDI doesn't support anti-aliasing. This function is a hack-job.
       I need to replace OK Cancel buttons in my ChooseColors() and hence have been experimenting.
       I don't want to load GdiPlus.dll just for the sake of a text button couple.

       Parameters:
       hCtrl : Hwnd of Text control
       Text control should have only single-line text. (Multi-line not supported).
       Only these text alignment styles are recognized: Left Center Right, and 0x200 (Vertical center)
       Options: This parameter needs an Object, even an empty object would work.
       If this parameter is given an non object, It will act as RGBtoBGR() when parameter is blank "", or as DeleteAssociatedBitmap() when non-blank.
       All options have been used in examples, except WindowColor. You need to specify WindowColor if Gui color is different from System window color.

       Pass RGB values for these options: WindowColor, ButtonColor, BorderColor, TextColor
       Pass percentage ( 10% to 100% ) for Roundness, Smoothness
       Text is not smoothened by default. Pass "SmoothText": True to make text smoother.

*/

;  DEMO

       #NoEnv
       #Warn
       #SingleInstance, Force
       SetWorkingDir, %A_ScriptDir%
       SetBatchLines, -1

       Gui, New, -MinimizeBox, TextToPic()
       Gui, Margin, 16, 16
       Gui, Font, S11, Calibri

       Gui, Add, Text, xm y+m  w74 h28 0x200 Center Border HwndhTxt01, &Cancel
       Gui, Add, Text, x+m yp  w48 hp  0x200 Center Border HwndhTxt02, &Ok

       Obj := { "ButtonColor": 0x3399FF
              , "BorderColor": 0xE3F1FF
              , "Roundness":   40
              , "Smoothness":  50
              , "TextColor":   0xFFFFFF }

       TextToPic(hTxt01, Obj)
       TextToPic(hTxt02, Obj)

       Gui, Add, Text, xm y+m  w74 h32 0x200 Center Border HwndhTxt03, &Cancel
       Gui, Add, Text, x+m yp  wp  hp  0x200 Center Border HwndhTxt04, &Ok

       Obj := { "ButtonColor": 0x7F7F7F
              , "BorderColor": 0xA0A0A0
              , "Roundness":   100
              , "Smoothness":  100
              , "TextColor":   0xFFFFFF
              , "SmoothText":  False}

       TextToPic(hTxt03, Obj)
       TextToPic(hTxt04, Obj)

       Gui, Add, Text, xm y+m  w64  h64 0x200 Center Border HwndhTxt05, &Cancel
       Gui, Add, Text, x+m yp  wp   hp  0x200 Center Border HwndhTxt06, &Ok

       Obj := { "ButtonColor": 0xFF9252
              , "BorderColor": 0xD87B44
              , "Roundness":   100
              , "Smoothness":  11
              , "SmoothText":  False}

       TextToPic(hTxt05, Obj)

       Obj := { "ButtonColor": 0x1AFFA4
              , "BorderColor": 0x14CC83
              , "Roundness":   100
              , "Smoothness":  11
              , "SmoothText":  False}

       TextToPic(hTxt06, Obj)

       Gui, Add, Text, xm y+m  w64  h24 0x200 Center Border HwndhTxt07, &Cancel
       Gui, Add, Text, x+m yp  wp   hp  0x200 Center Border HwndhTxt08, &Ok

       TextToPic(hTxt07, { "BorderColor": 0xD87B44 })
       TextToPic(hTxt08, { "BorderColor": 0x14CC83 })

       Gui, Show, AutoSize
       Return

       GuiClose:
       GuiEscape:
       ; Make sure images are deleted before Gui is destroyed
        TextToPic(hTxt01, False)
        TextToPic(hTxt02, False)
        TextToPic(hTxt03, False)
        TextToPic(hTxt04, False)
        TextToPic(hTxt05, False)
        TextToPic(hTxt06, False)
        TextToPic(hTxt07, False)
        TextToPic(hTxt08, False)
        Gui, Destroy
        ExitApp

;*/


TextToPic(hTxt, OxO:="") { ;                                  v0.50 by SKAN on D475/D475 @ tiny.cc/t92338
Local
  If ( IsObject(OxO) = False )
       Return StrLen(OxO) ? DllCall("Gdi32.dll\DeleteObject", "Ptr"
            , DllCall("User32.dll\SendMessage", "Ptr",hTxt, "Int",0x172, "Ptr",0, "Ptr",OxO, "Ptr"))
            : Format("0x{5:}{6:}{3:}{4:}{1:}{2:}", StrSplit(Format("{:06X}",hTxt & 0xFFFFFF))*)

  WinGetClass, Class, ahk_id %hTxt%
  ControlGetText, Text,, ahk_id %hTxt%
  If ( Class != "Static" || InStr(Text, "`n"))
       Return 0

  hFnt := DllCall("User32.dll\SendMessage", "Ptr",hTxt, "Int",0x31, "Ptr",0, "Ptr",0, "Ptr") ; WM_GETFONT
  ControlGet, F, Style,,, ahk_id %hTxt%
  Control, Style, 0x5000000E,, ahk_id %hTxt%

  VarSetCapacity(RECT, 16)
  DllCall("User32.dll\GetClientRect", "Ptr",hTxt, "Ptr",&RECT)
  x1 := NumGet(RECT,0, "Int"),   y1 := NumGet(RECT,4, "Int")
  x2 := NumGet(RECT,8, "Int"),   y2 := NumGet(RECT,12,"Int")
  W  := x2-x1,                   H  := y2-y1

  WindowColor := OxO.HasKey("WindowColor") ? Format("{:d}", OxO.WindowColor)
              :  TextToPic(DllCall("User32.dll\GetSysColor", "Int",15))

  LRFlag := OxO.Win7 ? 0x2008 : 0x8
  hBM    := DllCall("Gdi32.dll\CreateBitmap", "Int",1, "Int",1, "Int",0x1, "Int",24, "Ptr",0, "Ptr")
  hBM    := DllCall("User32.dll\CopyImage", "Ptr",hBM, "Int",0x0, "Int",1, "Int",1, "Int",0x2008, "Ptr")
            DllCall("Gdi32.dll\SetBitmapBits", "Ptr",hBM, "UInt",4, "UIntP",WindowColor)
  hBM    := DllCall("User32.dll\CopyImage", "Ptr",hBM, "Int",0x0, "Int",W, "Int",H, "Int",LRFlag, "Ptr")

  ButtonColor := OxO.HasKey("ButtonColor") ? TextToPic(OxO.ButtonColor)
              :  DllCall("User32.dll\GetSysColor", "Int",15)
  hBrush := DllCall("CreateSolidBrush", "Int",ButtonColor, "Ptr")

  BorderColor := OxO.HasKey("BorderColor") ? TextToPic(OxO.BorderColor)
              :  DllCall("User32.dll\GetSysColor", "Int",15)
  hPen   := DllCall("CreatePen", "Int",0, "Int",1, "Int",BorderColor, "Ptr" )

  mDC    := DllCall("Gdi32.dll\CreateCompatibleDC", "Ptr",0, "Ptr")
  DllCall("Gdi32.dll\SaveDC", "Ptr",mDC)
  DllCall("Gdi32.dll\SelectObject", "Ptr",mDC, "Ptr",hBrush)
  DllCall("Gdi32.dll\SelectObject", "Ptr",mDC, "Ptr",hPen)
  DllCall("Gdi32.dll\SelectObject", "Ptr",mDC, "Ptr",hBM)

  R := Max(0, Min(100, Format("{:d}",OxO.Roundness))) / 100
  DllCall("Gdi32.dll\RoundRect", "Ptr",mDC, "Int",0, "Int",0, "Int",W, "Int",H, "Int",H*R, "Int",H*R)

  DllCall("Gdi32.dll\RestoreDC", "Ptr",mDC, "Int",-1)
  DllCall("Gdi32.dll\DeleteObject", "Ptr",hBrush)
  DllCall("Gdi32.dll\DeleteObject", "Ptr",hPen)

  S := Max(0, Min(100, Format("{:d}",OxO.Smoothness))) / 10
  If (S>1 && Format("{:d}",OxO.SmoothText) = False)
    hBM := DllCall("User32.dll\CopyImage", "Ptr",hBM, "Int",0, "Int",W*S, "Int",H*S, "Int",LRFlag, "Ptr")
  , hBM := DllCall("User32.dll\CopyImage", "Ptr",hBM, "Int",0, "Int",W,   "Int",H,   "Int",0x2008, "Ptr")

  DllCall("Gdi32.dll\SelectObject", "Ptr",mDC, "Ptr",hBM)
  DllCall("Gdi32.dll\SelectObject", "Ptr",mDC, "Ptr",hFnt)

  TextColor := OxO.HasKey("TextColor") ? TextToPic(OxO.TextColor)
            :  DllCall("User32.dll\GetSysColor", "Int",18) ; COLOR_BTNTEXT
  DllCall("Gdi32.dll\SetTextColor", "Ptr",mDC, "Int",TextColor)
  DllCall("Gdi32.dll\SetBkMode", "Ptr",mDC, "Int",1) ; TRANSPARENT=1
  Flags := 0x20 | (F & 0x200 ? 0x4 : 0) | (F & 0x3)
  DllCall("User32.dll\DrawText", "Ptr",mDC, "Str",Text, "Int",StrLen(Text), "Ptr",&RECT, "Int",Flags)
  DllCall("Gdi32.dll\RestoreDC", "Ptr",mDC, "Int",-1)
  DllCall("Gdi32.dll\DeleteDC", "Ptr",mDC)

  If (S>1 && Format("{:d}",OxO.SmoothText) = True)
    hBM := DllCall("User32.dll\CopyImage", "Ptr",hBM, "Int",0, "Int",W*S, "Int",H*S, "Int",LRFlag, "Ptr")
  , hBM := DllCall("User32.dll\CopyImage", "Ptr",hBM, "Int",0, "Int",W,   "Int",H,   "Int",0x2008, "Ptr")

Return TextToPic(hTxt, hBM)
}



