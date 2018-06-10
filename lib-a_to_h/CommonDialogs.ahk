ChooseFont(ByRef FontName, ByRef FontOptions, Effects := True, hOwner := 0) {
    Static LogPixels, Size, Style, Color, lfHeight, OldFormat, x64

    LogPixels := DllCall("GetDeviceCaps", "UInt", DllCall("GetDC", "UInt", hOwner), "UInt", 90)

    VarSetCapacity(LOGFONT, (A_IsUnicode) ? 92 : 60, 0)
    StrPut(FontName, &LOGFONT + 28, 32) ; Initial name

    If (IsObject(FontOptions)) {
        Size  := FontOptions.Size
        Style := FontOptions.Style
        Color := FontOptions.Color
    } Else {
        Style := ""
        Loop Parse, FontOptions, %A_Space%
        {
            If (A_LoopField ~= "^s\d") {
                Size := SubStr(A_LoopField, 2)
            } Else If (A_LoopField ~= "^c\d") {
                Color := SubStr(A_LoopField, 2)
            } Else If (A_LoopField ~= "i)(italic|bold|semibold|underline|strikeout)") {
                Style .= A_LoopField . " "
            }
        }
    }

    lfHeight := (Size) ? -DllCall("MulDiv", "Int", Size, "Int", LogPixels, "int", 72) : 12 ; Initial size
    NumPut(lfHeight, LOGFONT, 0, "Int")
    
    ; Initial style
    If (InStr(Style, "semibold")) {
        NumPut(600, LOGFONT, 16, "UInt")
    } Else If (InStr(Style, "bold")) {
        NumPut(700, LOGFONT, 16, "UInt")
    }
    If (InStr(Style, "italic")) {
        NumPut(255, LOGFONT, 20, "Char")
    }
    If (InStr(Style, "underline")) {
        NumPut(1, LOGFONT, 21, "Char")
    }
    If (InStr(Style, "strikeout")) {
        NumPut(1, LOGFONT, 22, "Char")
    }

    Color := ((Color & 0xFF) << 16) + (Color & 0xFF00) + ((Color >> 16) & 0xFF) ; RGB -> BGR

    Effects := (Effects) ? 0x141 : 0x41 ; CF_SCREENFONTS = 1, CF_INITTOLOGFONTSTRUCT = 0x40, CF_EFFECTS = 0x100

    x64 := A_PtrSize == 8
    NumPut(VarSetCapacity(CHOOSEFONT, (A_PtrSize == 8) ? 104 : 60, 0), CHOOSEFONT, 0, "UInt")
    NumPut(hOwner,   CHOOSEFONT, A_PtrSize, "UInt")     ; hwndOwner
    NumPut(&LOGFONT, CHOOSEFONT, x64 ? 24 : 12, "UInt") ; lpLogFont
    NumPut(Effects,  CHOOSEFONT, x64 ? 36 : 20, "UInt") ; Flags
    NumPut(Color,    CHOOSEFONT, x64 ? 40 : 24, "UInt") ; rgbColors

    If !(DllCall("comdlg32.dll\ChooseFont" . (A_IsUnicode ? "W" : "A"), "UInt", &CHOOSEFONT)) {
        Return False
    }

    FontName := StrGet(&LOGFONT + 28, 32)

    Size := DllCall("MulDiv", "Int", Abs(NumGet(LOGFONT, 0, "Int")), "Int", 72, "Int", LogPixels)

    Style := ""
    If (NumGet(LOGFONT, 16) >= 700) {
        Style .= "bold "
    } Else If (NumGet(LOGFONT, 16) == 600) {
        Style .= "semibold "
    }
    If (NumGet(LOGFONT, 20, "UChar")) {
        Style .= "italic "
    }
    If (NumGet(LOGFONT, 21, "UChar")) {
        Style .= "underline "
    }
    If (NumGet(LOGFONT, 22, "UChar")) {
        Style .= "strikeout "
    }

    OldFormat := A_FormatInteger
    SetFormat Integer, Hex
    Color := NumGet(CHOOSEFONT, x64 ? 40 : 24, "UInt")
    Color := (Color & 0xFF00) + ((Color & 0xFF0000) >> 16) + ((Color & 0xFF) << 16) ; BGR -> RGB
    StringTrimLeft, Color, Color, 2 
    Loop % (6 - StrLen(Color)) {
        Color := "0" . Color
    }
    Color := "0x" . Color
    SetFormat Integer, %OldFormat% 

    If (IsObject(FontOptions)) {
        FontOptions := {"Size": Size, "Style": RTrim(Style), "Color": Color}
    } Else {
        Size := (Size != "") ? "s" . Size . " " : ""
        Color := (Color != "") ? "c" . Color : ""
        FontOptions := RTrim(Size . Style . Color)
    }

    Return True
}

ChooseColor(ByRef Color, hOwner := 0) {
    ; Color: specifies the color initially selected when the dialog box is created.
    ; hOwner: Optional handle to the window that owns the dialog. Affects dialog position.
    ; Return value: Nonzero if the user clicks the OK button.

    rgbResult := ((Color & 0xFF) << 16) + (Color & 0xFF00) + ((Color >> 16) & 0xFF)

    VarSetCapacity(CUSTOM, 64, 0)
    NumPut(VarSetCapacity(CHOOSECOLOR, A_PtrSize * 9, 0), CHOOSECOLOR, 0)
    NumPut(hOwner,      CHOOSECOLOR, A_PtrSize)    ; hwndOwner
    NumPut(rgbResult, CHOOSECOLOR, A_PtrSize * 3)  ; rgbResult
    NumPut(&CUSTOM, CHOOSECOLOR, A_PtrSize * 4)    ; COLORREF *lpCustColors
    NumPut(0x103, CHOOSECOLOR, A_PtrSize * 5)      ; Flags: CC_ANYCOLOR | CC_RGBINIT | CC_FULLOPEN

    RetVal := DllCall("comdlg32\ChooseColor", "Ptr", &CHOOSECOLOR)
    If (ErrorLevel != 0) || (RetVal == 0) {
        Return False
    }

    rgbResult := NumGet(CHOOSECOLOR, A_PtrSize * 3)
    
    OldFormat := A_FormatInteger
    SetFormat Integer, Hex
    Color := (rgbResult & 0xFF00) + ((rgbResult & 0xFF0000) >> 16) + ((rgbResult & 0xFF) << 16)
    StringTrimLeft Color, Color, 2
    Loop % 6 - StrLen(Color) {
        Color := "0" . Color
    }
    Color := "0x" . Color
    SetFormat Integer, %OldFormat%
    Return True
}

ChooseIcon(ByRef Icon, ByRef Index, hOwner := 0) {
    ; Icon: Icon resource (input/output).
    ; Index: Icon index (input/output).
    ; hOwner: Optional handle to the window that owns the dialog. Affects dialog position.
    ; Return value: Nonzero if the user clicks the OK button.

    Static IconIndex, Len

    VarSetCapacity(wIcon, 1025, 0)
    If (Icon && !StrPut(Icon, &wIcon, StrLen(Icon) + 1, "UTF-16")) {
        Return False
    }

    IconIndex := Index - 1
    If (DllCall("Shell32.dll\PickIconDlg", "UInt", hOwner, "Ptr", &wIcon, "UInt", 1025, "Int*", IconIndex)) {
        Index := IconIndex + 1

        If (A_IsUnicode) {
            VarSetCapacity(wIcon, -1)
            Icon := wIcon
        } Else {
            Len := DllCall("lstrlenW", "UInt", &wIcon)
            If (!Icon := StrGet(&wIcon, Len + 1, "UTF-16")) {
                Return False
            }
        }

        Return True
    } Else {
        Return False
    }
}
