/*
Use:
BalloonTip(sTitle = "", sText = "", hlicon=0, TitleCodePage = "", TextCodePage = "", Clickable=1, Timeout = 10000, MinTimeDisp = 200, RefreshRate = 100)
- sTitle: Title of the tooltip. Leave it empty for no title.
- sText: Text of the tooltip. Cannot be empty.
- hlicon: Icon displayed left to the title (0: None, 1:Info, 2: Warning, 3: Error, >3: assumed to be an hIcon.)
- TitleCodePage: Code page used for the title (empty: ascii, U8: UTF8, U16: UTF16) Note that if U16 is to be used, you must use the address of the variable containing the title for sTitle instead of the variable itself (by means of &Var instead of Var).
- TextCodePage: Same as TitleCodePage, for the text.
- Clickable: Determines the balloontip behavior when clicked (0: clicks are forwarded through the balloontip, 1: the balloontip disappears when clicked (flickers the active win), 2: the balloontip gets focused on click, 3: Same as 1, plus the balloontip displays a close button,  4: the balloontip gets focused on click and has a working close button). Note that on 98 and previous, the close button won't show and the balloontip may not show properly when using 0.
- Timeout: Delay before the balloontip disappears (in ms).
- MinTimeDisp: Delay during which the balloontip cannot disappear, except when control focus changes or active window loses focus. After this delay, moving the window or the caret will destroy the balloontip.
- RefreshRate: Delay between two checks of caret position, active win and focused control.
Entering no parameters at all (or simply an empty string as sText parameter) hides the balloontip unconditionally.

#include BalloonTip.ahk
#SingleInstance, Force

F1::
BalloonTip()
sleep 200 ;Waits for the previous tooltip to disappear and the previous window to retrieve focus, if Clickable is >0
i++
BalloonTip("Tooltip nбу" i, "A" A_Tab "few`n" A_Space A_Space "words.", 1)
KeyWait F1
return

F2::
Transform, U8Str, Unicode ;Retrieves the UTF8-formatted clipboard content.
BalloonTip()
sleep 200
i++
BalloonTip(U8Str, U8Str, 1, "U8", "U8")
KeyWait F2
return

F3::
Transform, U8Str, Unicode ;Retrieves the UTF8-formatted clipboard content.
;Transforms it into unicode
nSize := DllCall("MultiByteToWideChar", "Uint", 65001, "Uint", 0, "Uint", &U8Str, "int",  -1, "Uint", 0, "int",  0)
VarSetCapacity(sU16Title, nSize * 2)
DllCall("MultiByteToWideChar", "Uint", 65001, "Uint", 0, "Uint", &U8Str, "int",  -1, "Uint", &sU16Title, "int",  nSize)
VarSetCapacity(sU16Text, nSize * 2)
DllCall("MultiByteToWideChar", "Uint", 65001, "Uint", 0, "Uint", &U8Str, "int",  -1, "Uint", &sU16Text, "int",  nSize)
BalloonTip()
sleep 200
i++
BalloonTip(&sU16Title, &sU16Text, 1, "U16", "U16")
KeyWait F3
return

F4::
BalloonTip()
KeyWait F4
Return
*/

BalloonTip(sTitle = "", sText = "", hlicon=0, TitleCodePage = "", TextCodePage = "", Clickable=1, Timeout = 10000, MinTimeDisp = 200, RefreshRate = 100)
{
   Static hwnd, ActiveWinID, ActiveCtrl, CtrlContent, CaretX, CaretY, MinTime, ClickableSave
   If !sText
      Goto _DestroyBalloonTip
   ActiveWinID := WinExist("A")
   SetTimer, _DestroyBalloonTip, Off
   Gosub _DestroyBalloonTip
   ClickableSave := Clickable
   ControlGetFocus, ActiveCtrl, Ahk_ID %ActiveWinID%
   If !ActiveCtrl
      Return
   MinTime = 1
   ControlGetText, CtrlContent, %ActiveCtrl%, Ahk_ID %ActiveWinID%
   coordmode, caret, screen
   CaretX := A_CaretX
   CaretY := A_CaretY
   hwnd := DllCall("CreateWindowEx", "Uint", (Clickable ? 0x80088 : 0x80028), "str", "tooltips_class32", "str", "", "Uint", (Clickable>2 ? 0xC3 : 0x42), "int", 0, "int", 0, "int", 0, "int", 0, "Uint", 0, "Uint", 0, "Uint", 0, "Uint", 0)
   VarSetCapacity(ti, 40, 0)
   ti := Chr(40)
   DllCall("ntdll\RtlFillMemoryUlong", "Uint", &ti + 4, "Uint", 4, "Uint", 0x20)   ; TTF_TRACK
   If !TitleCodePage
   {
      If (StrLen(sTitle)>99)
         sTitle := SubStr(sTitle, 1, 98) "бн"
      DllCall("SendMessage", "Uint", hWnd, "Uint", 1056, "Uint", hlicon, "Uint", &sTitle)   ; TTM_SETTITLE   ; 0: None, 1:Info, 2: Warning, 3: Error. n > 3: assumed to be an hIcon.
   }
   Else If (TitleCodePage = "U8")
   {
      ;Retrieve size of the title in unicode
      nSize := DllCall("MultiByteToWideChar", "Uint", 65001, "Uint", 0, "Uint", &sTitle, "int",  -1, "Uint", 0, "int",  0)
      VarSetCapacity(sU16, nSize * 2)
      DllCall("MultiByteToWideChar", "Uint", 65001, "Uint", 0, "Uint", &sTitle, "int",  -1, "Uint", &sU16, "int",  nSize)
      ;Cut the string at the proper size by writing an end char in memory.
      If (nSize>100) ;100=string+end char
         NumPut(0x2026, &sU16+196, "UInt") ;2026 is "бн" .UInt is 32bits. The remaining bits will be filled with 0, creating the end char.
      DllCall("SendMessage", "Uint", hWnd, "Uint", 1057, "Uint", hlicon, "Uint", &sU16)
   }
   Else If (TitleCodePage = "U16")
   {
      ;The variable sTitle contains the address of the U16-formatted title
      ;Cut the string if too long
      Loop
      {
         If (A_Index>100)
         {
            NumPut(0x2026, sTitle+196, "UInt") ;2026 is "бн" .UInt is 32bits. The remaining bits will be filled with 0, creating the end char.
            Break
         }
         If !NumGet(sTitle+0, 2*(A_Index-1), "UShort")
            Break
      }
      DllCall("SendMessage", "Uint", hWnd, "Uint", 1057, "Uint", hlicon, "Uint", sTitle)
   }
   If !TextCodePage
      DllCall("ntdll\RtlFillMemoryUlong", "Uint", &ti +36, "Uint", 4, "Uint", &sText)
   Else If (TextCodePage = "U8")
   {
      ;Retrieve size of the text in unicode
      nSize := DllCall("MultiByteToWideChar", "Uint", 65001, "Uint", 0, "Uint", &sText, "int",  -1, "Uint", 0, "int",  0)
      VarSetCapacity(sU16, nSize * 2)
      ;Converts U8 to unicode
      DllCall("MultiByteToWideChar", "Uint", 65001, "Uint", 0, "Uint", &sText, "int",  -1, "Uint", &sU16, "int",  nSize)
      DllCall("ntdll\RtlFillMemoryUlong", "Uint", &ti +36, "Uint", 4, "Uint", &sU16)
   }
   Else If (TextCodePage = "U16")
      DllCall("ntdll\RtlFillMemoryUlong", "Uint", &ti +36, "Uint", 4, "Uint", sText)
   DllCall("SendMessage", "Uint", hWnd, "Uint", 1028, "Uint", 0, "Uint", &ti)   ; TTM_ADDTOOL
   WinGetPos, WinX, WinY, , , Ahk_ID %ActiveWinID%
   ControlGetPos, CtrlX, CtrlY, CtrlW, CtrlH, %ActiveCtrl%, Ahk_ID %ActiveWinID%
   ; TTM_TRACKPOSITION
   If ((CaretY < CtrlY+WinY) || (CaretY > CtrlY+CtrlH-11+WinY) || (CaretX < CtrlX+WinX) || (CaretX > CtrlX+CtrlW-4+WinX))
      DllCall("SendMessage", "Uint", hWnd, "Uint", 1042, "Uint", 0, "Uint", (CtrlX+4+WinX & 0xFFFF)|(CtrlY+CtrlH-9+WinY & 0xFFFF)<<16)
   Else
      DllCall("SendMessage", "Uint", hWnd, "Uint", 1042, "Uint", 0, "Uint", (CaretX+4 & 0xFFFF)|(CaretY+11 & 0xFFFF)<<16)
   DllCall("SendMessage", "Uint", hWnd, "Uint", 1048, "Uint", 0, "Uint", A_ScreenWidth)   ; TTM_SETMAXTIPWIDTH (allows A_Tab to be displayed)
   If !TextCodePage
      DllCall("SendMessage", "Uint", hWnd, "Uint", 1036, "Uint", 0, "Uint", &ti)   ; TTM_UPDATETIPTEXT
   Else
      DllCall("SendMessage", "Uint", hWnd, "Uint", 1081, "Uint", 0, "Uint", &ti)   ; TTM_UPDATETIPTEXTW
   DllCall("SendMessage", "Uint", hWnd, "Uint", 1041, "Uint", 1, "Uint", &ti)   ; TTM_TRACKACTIVATE
   ;WinShow, Ahk_ID %hwnd%
   SetTimer, _UpdateBalloonTip, %RefreshRate%
   If MinTimeDisp
      SetTimer, _MinTimeDisp, -%MinTimeDisp%
   If Timeout
      SetTimer, _DestroyBalloonTip, -%Timeout%
   Return
   _MinTimeDisp:
   MinTime =
   Return
   _UpdateBalloonTip:
   F := WinExist("A")
   If (F = ActiveWinID)
   {
      ControlGetFocus, F, Ahk_ID %ActiveWinID%
      If (F = ActiveCtrl)
      {
         ControlGetText, F, %F%, Ahk_ID %ActiveWinID%
         coordmode, caret, screen
         If ((A_CaretX = CaretX) && (A_CaretY = CaretY) && (CtrlContent = F))
            Return
         Else If MinTime
         {
            CaretX := A_CaretX
            CaretY := A_CaretY
            CtrlContent := F
            WinGetPos, WinX, WinY, , , Ahk_ID %ActiveWinID%
            ControlGetPos, CtrlX, CtrlY, CtrlW, CtrlH, %ActiveCtrl%, Ahk_ID %ActiveWinID%
            If ((CaretY < CtrlY+WinY) || (CaretY > CtrlY+CtrlH-11+WinY) || (CaretX < CtrlX+WinX) || (CaretX > CtrlX+CtrlW-4+WinX))
               DllCall("SendMessage", "Uint", hWnd, "Uint", 1042, "Uint", 0, "Uint", (CtrlX+4+WinX & 0xFFFF)|(CtrlY+CtrlH-9+WinY & 0xFFFF)<<16)
            Else
               DllCall("SendMessage", "Uint", hWnd, "Uint", 1042, "Uint", 0, "Uint", (CaretX+4 & 0xFFFF)|(CaretY+11 & 0xFFFF)<<16)
            Return
         }
      }
   }
   Else If ((F = hwnd) && InStr("2|4", ClickableSave))
      Return
   _DestroyBalloonTip:
   SetTimer, _UpdateBalloonTip, Off
   SetTimer, _MinTimeDisp, Off
   SetWinDelay, -1
   DllCall("SendMessage", "Uint", hWnd, "Uint", 0x10, "Uint", 0)
   hwnd =
   Return
}