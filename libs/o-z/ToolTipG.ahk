; ======================================================================================================================
; ToolTipG()      Display ToolTips with custom fonts and colors using a GUI.
;                 Code based on just me's ToolTipEx.
; Requires format.ahk, which is distributed with AutoHotkey v2-alpha.
; Tested with:    AHK 1.1.16.05 (U32/U64)
; Tested on:      Win 7 Pro (x64)
; Parameters:
;     Text           -  the text to display in the ToolTip.
;                       If omitted or empty, the ToolTip will be destroyed.
;     X              -  the X position of the ToolTip.
;                       Default: "" (mouse cursor)
;     Y              -  the Y position of the ToolTip.
;                       Default: "" (mouse cursor)
;     WhichToolTip   -  the number of the ToolTip.
;                       Values:  1 - 20
;                       Default: 1
;     Font           -  Font options and name separated by a comma.
;                       Default: none (default GUI font)
;     BgColor        -  the background color of the ToolTip.
;                       Values:  RGB integer value or HTML color name.
;                       Default: "" (default color)
;     TxColor        -  the text color of the ToolTip.
;                       Values:  RGB integer value or HTML color name.
;                       Default: "" (default color)
;     Image          -  not implemented.
;                       Default: "" (no image)
;     CoordMode      -  the coordinate mode for the X and Y parameters, if specified.
;                       Values:  "C" (Client), "S" (Screen), "W" (Window)
;                       Default: "W" (CoordMode, ToolTip, Window)
; Return values:
;     On success: The HWND of the ToolTip window.
;     On failure: False (ErrorLevel contains additional informations)
; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=4350&start=20
; ======================================================================================================================
ToolTipG(Text:="", X:="", Y:="", WhichToolTip:=1, Font:="", BgColor:="", TxColor:="", Image:="", CoordMode:="W") {
   ; -------------------------------------------------------------------------------------------------------------------
   ; Check params
   TTTX := Text
   TTXP := X
   TTYP := Y
   TTIX := "ToolTip" (WhichToolTip = "" ? 1 : WhichToolTip)
   TTHF := Font = "" ? "" : StrSplit(Font, ",", " `t")
   TTBC := BgColor
   TTTC := TxColor
   TTIC := Image
   TTCM := CoordMode = "" ? "W" : SubStr(CoordMode, 1, 1)
   If TTXP Is Not Digit
      Return False, ErrorLevel := "Invalid parameter X-position!", False
   If TTYP Is Not Digit
      Return  False, ErrorLevel := "Invalid parameter Y-Position!", False
   If !InStr("CSW", CoordMode)
      Return False, ErrorLevel := "Invalid parameter CoordMode!", False
   ; -------------------------------------------------------------------------------------------------------------------
   ; Destroy the ToolTip window, if Text is empty
   If (TTTX = "") {
      Gui %TTIX%: Destroy
      Return True
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Save thread settings.
   DHW := A_DetectHiddenWindows
   DetectHiddenWindows On
   LFW := WinExist()
   ; -------------------------------------------------------------------------------------------------------------------
   ; Get the virtual desktop rectangle
   SysGet, X, 76
   SysGet, Y, 77
   SysGet, W, 78
   SysGet, H, 79
   DTW := {L: X, T: Y, R: X + W, B: Y + H}
   ; -------------------------------------------------------------------------------------------------------------------
   ; Initialise the ToolTip coordinates. If either X or Y is empty, use the cursor position for the present.
   PT := {X: 0, Y: 0}
   If (TTXP = "") || (TTYP = "") {
      VarSetCapacity(Cursor, 8, 0)
      DllCall("User32.dll\GetCursorPos", "Ptr", &Cursor)
      Cursor := {X: NumGet(Cursor, 0, "Int"), Y: NumGet(Cursor, 4, "Int")}
      PT := {X: Cursor.X + 16, Y: Cursor.Y + 16}
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; If either X or Y  is specified, get the position of the active window considering CoordMode.
   Origin := {X: 0, Y: 0}
   If ((TTXP <> "") || (TTYP <> "")) && ((TTCM = "W") || (TTCM = "C")) { ; if (*aX || *aY) // Need the offsets.
      HWND := DllCall("User32.dll\GetForegroundWindow", "UPtr")
      If (TTCM = "W") {
         WinGetPos, X, Y, , , ahk_id %HWND%
         Origin := {X: X, Y: Y}
      }
      Else {
         VarSetCapacity(OriginPT, 8, 0)
         DllCall("User32.dll\ClientToScreen", "Ptr", HWND, "Ptr", &OriginPT)
         Origin := {X: NumGet(OriginPT, 0, "Int"), Y: NumGet(OriginPT, 0, "Int")}
      }
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; If either X or Y is specified, use the window related position for this parameter.
   If (TTXP <> "")
      PT.X := TTXP + Origin.X
   If (TTYP <> "")
      PT.Y := TTYP + Origin.Y
   ; -------------------------------------------------------------------------------------------------------------------
   ; If the ToolTip window doesn't exist, create it.
   Gui %TTIX%: +LastFoundExist
   If !TTHW := WinExist() {
      Gui %TTIX%: +AlwaysOnTop +HwndTTHW +ToolWindow -Caption -DPIScale
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Update the text and the font and colors, if specified.
   If (TTBC = "")
      TTBC := format("{1:08x}", DllCall("GetSysColor", "int", 24))
   if (TTTC = "")
      TTTC := format("{1:08x}", DllCall("GetSysColor", "int", 23))
   Gui %TTIX%: Color, %TTTC% ; border
   If (TTIC <> "") {
      ; TODO: Add image
   }
   If (TTHF) ; font
      Gui %TTIX%: Font, % TTHF[1], % TTHF[2]
   ; -------------------------------------------------------------------------------------------------------------------
   ; (Re)create a sub-GUI to simplify text control sizing.
   Gui %TTIX%T: Destroy
   if TTHF
      Gui %TTIX%T: Font, % TTHF[1], % TTHF[2]
   Gui %TTIX%T: +Parent%TTIX% +HwndTTHWT -Caption 
   Gui %TTIX%T: Margin, 3, 2
   Gui %TTIX%T: Color, %TTBC%
   Gui %TTIX%T: Add, Text, c%TTTC%, %TTTX%
   Gui %TTIX%T: Show, NA x1 y1
   ; -------------------------------------------------------------------------------------------------------------------
   ; Get the ToolTip window dimensions.
   VarSetCapacity(RC, 16, 0)
   DllCall("User32.dll\GetWindowRect", "Ptr", TTHWT, "Ptr", &RC)
   TTRC := {L: NumGet(RC, 0, "Int"), T: NumGet(RC, 4, "Int"), R: NumGet(RC, 8, "Int"), B: NumGet(RC, 12, "Int")}
   TTW := TTRC.R - TTRC.L + 2
   TTH := TTRC.B - TTRC.T + 2
   ; -------------------------------------------------------------------------------------------------------------------
   ; Check if the Tooltip will be partially outside the virtual desktop and adjust the position, if necessary.
   If (PT.X + TTW >= DTW.R)
      PT.X := DTW.R - TTW - 1
   If (PT.Y + TTH >= DTW.B)
      PT.Y := DTW.B - TTH - 1
   ; -------------------------------------------------------------------------------------------------------------------
   ; Check if the cursor is inside the ToolTip window and adjust the position, if necessary.
   If (TTXP = "") || (TTYP = "") {
      TTRC.L := PT.X, TTRC.T := PT.Y, TTRC.R := TTRC.L + TTW, TTRC.B := TTRC.T + TTH
      If (Cursor.X >= TTRC.L) && (Cursor.X <= TTRC.R) && (Cursor.Y >= TTRC.T) && (Cursor.Y <= TTRC.B)
         PT.X := Cursor.X - TTW - 3, PT.Y := Cursor.Y - TTH - 3
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Show the Tooltip using the final coordinates.
   Gui %TTIX%: Show, % "NA x" PT.X " y" PT.Y " w" TTW " h" TTH
   ; -------------------------------------------------------------------------------------------------------------------
   ; Restore thread settings.
   WinExist("ahk_id " LFW)
   DetectHiddenWindows %DHW%
   Return TTHW
}