Class RichEditDlgs {
   ; ===================================================================================================================
   ; ===================================================================================================================
   ; RICHEDIT COMMON DIALOGS ===========================================================================================
   ; ===================================================================================================================
   ; ===================================================================================================================
   ; Most of the following methods are based on DLG 5.01 by majkinetor
   ; http://www.autohotkey.com/board/topic/15836-module-dlg-501/
   ; ===================================================================================================================
   ChooseColor(RE, Color := "") { ; Choose color dialog box
   ; ===================================================================================================================
      ; RE : RichEdit object
      Static CC_Size := A_PtrSize * 9, CCU := "Init"
      GuiHwnd := RE.GuiHwnd
      If (Color = "T")
         Font := RE.GetFont(), Color := Font.Color = "Auto" ? 0x0 : RE.GetBGR(Font.Color)
      Else If (Color = "B")
         Font := RE.GetFont(), Color := Font.BkColor = "Auto" ? 0x0 : RE.GetBGR(Font.BkColor)
      Else If (Color != "")
         Color := RE.GetBGR(Color)
      Else
         Color := 0x000000
      If (CCU = "Init")
         VarSetCapacity(CCU, 64, 0)
      VarSetCapacity(CC, CC_Size, 0)            ; CHOOSECOLOR structure
      NumPut(CC_Size, CC, 0, "UInt")            ; lStructSize
      NumPut(GuiHwnd, CC, A_PtrSize, "UPtr")    ; hwndOwner makes dialog modal
      NumPut(Color, CC, A_PtrSize * 3, "UInt")  ; rgbResult
      NumPut(&CCU, CC, A_PtrSize * 4, "UPtr")   ; COLORREF *lpCustColors (16)
      NumPut(0x0101, CC, A_PtrSize * 5, "UInt") ; Flags: CC_ANYCOLOR | CC_RGBINIT | ; CC_FULLOPEN
      R := DllCall("Comdlg32.dll\ChooseColor", "Ptr", &CC, "UInt")
      If (ErrorLevel <> 0) || (R = 0)
         Return False
      Return RE.GetRGB(NumGet(CC, A_PtrSize * 3, "UInt"))
   }
   ; ===================================================================================================================
   ChooseFont(RE) { ; Choose font dialog box
   ; ===================================================================================================================
      ; RE : RichEdit object
      DC := DllCall("User32.dll\GetDC", "Ptr", RE.GuiHwnd, "Ptr")
      LP := DllCall("GetDeviceCaps", "Ptr", DC, "UInt", 90, "Int") ; LOGPIXELSY
      DllCall("User32.dll\ReleaseDC", "Ptr", RE.GuiHwnd, "Ptr", DC)
      ; Get current font
      Font := RE.GetFont()
      ; LF_FACENAME = 32
      VarSetCapacity(LF, 92, 0)             ; LOGFONT structure
      Size := -(Font.Size * LP / 72)
      NumPut(Size, LF, 0, "Int")            ; lfHeight
      If InStr(Font.Style, "B")
         NumPut(700, LF, 16, "Int")         ; lfWeight
      If InStr(Font.Style, "I")
         NumPut(1, LF, 20, "UChar")         ; lfItalic
      If InStr(Font.Style, "U")
         NumPut(1, LF, 21, "UChar")         ; lfUnderline
      If InStr(Font.Style, "S")
         NumPut(1, LF, 22, "UChar")         ; lfStrikeOut
      NumPut(Font.CharSet, LF, 23, "UChar") ; lfCharSet
      StrPut(Font.Name, &LF + 28, 32)
      ; CF_BOTH = 3, CF_INITTOLOGFONTSTRUCT = 0x40, CF_EFFECTS = 0x100, CF_SCRIPTSONLY = 0x400
      ; CF_NOVECTORFONTS = 0x800, CF_NOSIMULATIONS = 0x1000, CF_LIMITSIZE = 0x2000, CF_WYSIWYG = 0x8000
      ; CF_TTONLY = 0x40000, CF_FORCEFONTEXIST =0x10000, CF_SELECTSCRIPT = 0x400000
      ; CF_NOVERTFONTS =0x01000000
      Flags := 0x00002141 ; 0x01013940
      Color := RE.GetBGR(Font.Color)
      CF_Size := (A_PtrSize = 8 ? (A_PtrSize * 10) + (4 * 4) + A_PtrSize : (A_PtrSize * 14) + 4)
      VarSetCapacity(CF, CF_Size, 0)                     ; CHOOSEFONT structure
      NumPut(CF_Size, CF, "UInt")                        ; lStructSize
      NumPut(RE.GuiHwnd, CF, A_PtrSize, "UPtr")		      ; hwndOwner (makes dialog modal)
      NumPut(&LF, CF, A_PtrSize * 3, "UPtr")	            ; lpLogFont
      NumPut(Flags, CF, (A_PtrSize * 4) + 4, "UInt")     ; Flags
      NumPut(Color, CF, (A_PtrSize * 4) + 8, "UInt")     ; rgbColors
      OffSet := (A_PtrSize = 8 ? (A_PtrSize * 11) + 4 : (A_PtrSize * 12) + 4)
      NumPut(4, CF, Offset, "Int")                       ; nSizeMin
      NumPut(160, CF, OffSet + 4, "Int")                 ; nSizeMax
      ; Call ChooseFont Dialog
      If !DllCall("Comdlg32.dll\ChooseFont", "Ptr", &CF, "UInt")
         Return false
      ; Get name
      Font.Name := StrGet(&LF + 28, 32)
   	; Get size
   	Font.Size := NumGet(CF, A_PtrSize * 4, "Int") / 10
      ; Get styles
   	Font.Style := ""
   	If NumGet(LF, 16, "Int") >= 700
   	   Font.Style .= "B"
   	If NumGet(LF, 20, "UChar")
         Font.Style .= "I"
   	If NumGet(LF, 21, "UChar")
         Font.Style .= "U"
   	If NumGet(LF, 22, "UChar")
         Font.Style .= "S"
      OffSet := A_PtrSize * (A_PtrSize = 8 ? 11 : 12)
      FontType := NumGet(CF, Offset, "UShort")
      If (FontType & 0x0100) && !InStr(Font.Style, "B") ; BOLD_FONTTYPE
         Font.Style .= "B"
      If (FontType & 0x0200) && !InStr(Font.Style, "I") ; ITALIC_FONTTYPE
         Font.Style .= "I"
      If (Font.Style = "")
         Font.Style := "N"
      ; Get character set
      Font.CharSet := NumGet(LF, 23, "UChar")
      ; We don't use the limited colors of the font dialog
      ; Return selected values
      Return RE.SetFont(Font)
   }
   ; ===================================================================================================================
   FileDlg(RE, Mode, File := "") { ; Open and save as dialog box
   ; ===================================================================================================================
      ; RE   : RichEdit object
      ; Mode : O = Open, S = Save
      ; File : optional file name
   	Static OFN_ALLOWMULTISELECT := 0x200,    OFN_EXTENSIONDIFFERENT := 0x400, OFN_CREATEPROMPT := 0x2000
           , OFN_DONTADDTORECENT := 0x2000000, OFN_FILEMUSTEXIST := 0x1000,     OFN_FORCESHOWHIDDEN := 0x10000000
           , OFN_HIDEREADONLY := 0x4,          OFN_NOCHANGEDIR := 0x8,          OFN_NODEREFERENCELINKS := 0x100000
           , OFN_NOVALIDATE := 0x100,          OFN_OVERWRITEPROMPT := 0x2,      OFN_PATHMUSTEXIST := 0x800
           , OFN_READONLY := 0x1,              OFN_SHOWHELP := 0x10,            OFN_NOREADONLYRETURN := 0x8000
           , OFN_NOTESTFILECREATE := 0x10000,  OFN_ENABLEXPLORER := 0x80000
           , OFN_Size := (4 * 5) + (2 * 2) + (A_PtrSize * 16)
      Static FilterN1 := "RichText",   FilterP1 :=  "*.rtf"
           , FilterN2 := "Text",       FilterP2 := "*.txt"
           , FilterN3 := "AutoHotkey", FilterP3 := "*.ahk"
           , DefExt := "rtf", DefFilter := 1
   	SplitPath, File, Name, Dir
      Flags := OFN_ENABLEXPLORER
      Flags |= Mode = "O" ? OFN_FILEMUSTEXIST | OFN_PATHMUSTEXIST | OFN_HIDEREADONLY
                          : OFN_OVERWRITEPROMPT
   	VarSetCapacity(FileName, 1024, 0)
      FileName := Name
   	LenN1 := (StrLen(FilterN1) + 1) * 2, LenP1 := (StrLen(FilterP1) + 1) * 2
   	LenN2 := (StrLen(FilterN2) + 1) * 2, LenP2 := (StrLen(FilterP2) + 1) * 2
   	LenN3 := (StrLen(FilterN3) + 1) * 2, LenP3 := (StrLen(FilterP3) + 1) * 2
      VarSetCapacity(Filter, LenN1 + LenP1 + LenN2 + LenP2 + LenN3 + LenP3 + 4, 0)
      Adr := &Filter
      StrPut(FilterN1, Adr)
      StrPut(FilterP1, Adr += LenN1)
      StrPut(FilterN2, Adr += LenP1)
      StrPut(FilterP2, Adr += LenN2)
      StrPut(FilterN3, Adr += LenP2)
      StrPut(FilterP3, Adr += LenN3)
      VarSetCapacity(OFN , OFN_Size, 0)      ; OPENFILENAME Structure
   	NumPut(OFN_Size, OFN, 0, "UInt")
      Offset := A_PtrSize
   	NumPut(RE.GuiHwnd, OFN, Offset, "Ptr") ; HWND owner
      Offset += A_PtrSize * 2
   	NumPut(&Filter, OFN, OffSet, "Ptr")    ; Pointer to FilterStruc
      OffSet += (A_PtrSize * 2) + 4
      OffFilter := Offset
   	NumPut(DefFilter, OFN, Offset, "UInt") ; DefaultFilter Pair
      OffSet += 4
   	NumPut(&FileName, OFN, OffSet, "Ptr")  ; lpstrFile / InitialisationFileName
      Offset += A_PtrSize
   	NumPut(512, OFN, Offset, "UInt")       ; MaxFile / lpstrFile length
      OffSet += A_PtrSize * 3
   	NumPut(&Dir, OFN, Offset, "Ptr")       ; StartDir
      Offset += A_PtrSize * 2
   	NumPut(Flags, OFN, Offset, "UInt")     ; Flags
      Offset += 8
   	NumPut(&DefExt, OFN, Offset, "Ptr")    ; DefaultExt
      R := Mode = "S" ? DllCall("Comdlg32.dll\GetSaveFileNameW", "Ptr", &OFN, "UInt")
                      : DllCall("Comdlg32.dll\GetOpenFileNameW", "Ptr", &OFN, "UInt")
   	If !(R)
         Return ""
      DefFilter := NumGet(OFN, OffFilter, "UInt")
   	Return StrGet(&FileName)
   }
   ; ===================================================================================================================
   FindText(RE) { ; Find dialog box
   ; ===================================================================================================================
      ; RE : RichEdit object
   	Static FINDMSGSTRING := "commdlg_FindReplace"
   	     , FR_DOWN := 1, FR_MATCHCASE := 4, FR_WHOLEWORD := 2
   	     , Buf := "", FR := "", Len := 256
           , FR_Size := A_PtrSize * 10
      Text := RE.GetSelText()
      VarSetCapacity(FR, FR_Size, 0)
   	NumPut(FR_Size, FR, 0, "UInt")
      VarSetCapacity(Buf, Len, 0)
      If (Text && !RegExMatch(Text, "\W"))
         Buf := Text
      Offset := A_PtrSize
   	NumPut(RE.GuiHwnd, FR, Offset, "UPtr") ; hwndOwner
      OffSet += A_PtrSize * 2
   	NumPut(FR_DOWN, FR, Offset, "UInt")	   ; Flags
      OffSet += A_PtrSize
   	NumPut(&Buf, FR, Offset, "UPtr")	      ; lpstrFindWhat
      OffSet += A_PtrSize * 2
   	NumPut(Len,	FR, Offset, "Short")       ; wFindWhatLen
      This.FindTextProc("Init", RE.HWND, "")
   	OnMessage(DllCall("User32.dll\RegisterWindowMessage", "Str", FINDMSGSTRING), "RichEditDlgs.FindTextProc")
   	Return DllCall("Comdlg32.dll\FindTextW", "Ptr", &FR, "UPtr")
   }
   ; -------------------------------------------------------------------------------------------------------------------
   FindTextProc(L, M, H) { ; skipped wParam, can be found in "This" when called by system
      ; Find dialog callback procedure
      ; EM_FINDTEXTEXW = 0x047C, EM_EXGETSEL = 0x0434, EM_EXSETSEL = 0x0437, EM_SCROLLCARET = 0x00B7
      ; FR_DOWN = 1, FR_WHOLEWORD = 2, FR_MATCHCASE = 4,
   	Static FINDMSGSTRING := "commdlg_FindReplace"
   	     , FR_DOWN := 1, FR_MATCHCASE := 4, FR_WHOLEWORD := 2 , FR_FINDNEXT := 0x8, FR_DIALOGTERM := 0x40
           , HWND := 0
      If (L = "Init") {
         HWND := M
         Return True
      }
      Flags := NumGet(L + 0, A_PtrSize * 3, "UInt")
      If (Flags & FR_DIALOGTERM) {
         OnMessage(DllCall("User32.dll\RegisterWindowMessage", "Str", FINDMSGSTRING), "")
         ControlFocus, , ahk_id %HWND%
         HWND := 0
         Return
      }
      VarSetCapacity(CR, 8, 0)
      SendMessage, 0x0434, 0, &CR, , ahk_id %HWND%
      Min := (Flags & FR_DOWN) ? NumGet(CR, 4, "Int") : NumGet(CR, 0, "Int")
      Max := (Flags & FR_DOWN) ? -1 : 0
      OffSet := A_PtrSize * 4
      Find := StrGet(NumGet(L + Offset, 0, "UPtr"))
      VarSetCapacity(FTX, 16 + A_PtrSize, 0)
      NumPut(Min, FTX, 0, "Int")
      NumPut(Max, FTX, 4, "Int")
      NumPut(&Find, FTX, 8, "Ptr")
      SendMessage, 0x047C, %Flags%, &FTX, , ahk_id %HWND%
      S := NumGet(FTX, 8 + A_PtrSize, "Int"), E := NumGet(FTX, 12 + A_PtrSize, "Int")
      If (S = -1) && (E = -1)
         MsgBox, 262208, Find, No (further) occurence found!
      Else {
         Min := (Flags & FR_DOWN) ? E : S
         SendMessage, 0x0437, 0, % (&FTX + 8 + A_PtrSize), , ahk_id %HWND%
         SendMessage, 0x00B7, 0, 0, , ahk_id %HWND%
      }
   }
   ; ===================================================================================================================
   PageSetup(RE) { ; Page setup dialog box
   ; ===================================================================================================================
      ; RE : RichEdit object
      ; http://msdn.microsoft.com/en-us/library/ms646842(v=vs.85).aspx
      Static PSD_DEFAULTMINMARGINS             := 0x00000000 ; default (printer's)
           , PSD_INWININIINTLMEASURE           := 0x00000000 ; 1st of 4 possible
           , PSD_MINMARGINS                    := 0x00000001 ; use caller's
           , PSD_MARGINS                       := 0x00000002 ; use caller's
           , PSD_INTHOUSANDTHSOFINCHES         := 0x00000004 ; 2nd of 4 possible
           , PSD_INHUNDREDTHSOFMILLIMETERS     := 0x00000008 ; 3rd of 4 possible
           , PSD_DISABLEMARGINS                := 0x00000010
           , PSD_DISABLEPRINTER                := 0x00000020
           , PSD_NOWARNING                     := 0x00000080 ; must be same as PD_*
           , PSD_DISABLEORIENTATION            := 0x00000100
           , PSD_RETURNDEFAULT                 := 0x00000400 ; must be same as PD_*
           , PSD_DISABLEPAPER                  := 0x00000200
           , PSD_SHOWHELP                      := 0x00000800 ; must be same as PD_*
           , PSD_ENABLEPAGESETUPHOOK           := 0x00002000 ; must be same as PD_*
           , PSD_ENABLEPAGESETUPTEMPLATE       := 0x00008000 ; must be same as PD_*
           , PSD_ENABLEPAGESETUPTEMPLATEHANDLE := 0x00020000 ; must be same as PD_*
           , PSD_ENABLEPAGEPAINTHOOK           := 0x00040000
           , PSD_DISABLEPAGEPAINTING           := 0x00080000
           , PSD_NONETWORKBUTTON               := 0x00200000 ; must be same as PD_*
           , I := 1000 ; thousandth of inches
           , M := 2540 ; hundredth of millimeters
           , Margins := {}
           , Metrics := ""
           , PSD_Size := (4 * 10) + (A_PtrSize * 11)
           , PD_Size := (A_PtrSize = 8 ? (13 * A_PtrSize) + 16 : 66)
           , OffFlags := 4 * A_PtrSize
           , OffMargins := OffFlags + (4 * 7)
      VarSetCapacity(PSD, PSD_Size, 0)              ; PAGESETUPDLG structure
      NumPut(PSD_Size, PSD, 0, "UInt")
      NumPut(RE.GuiHwnd, PSD, A_PtrSize, "UPtr")    ; hwndOwner
      Flags := PSD_MARGINS | PSD_DISABLEPRINTER | PSD_DISABLEORIENTATION | PSD_DISABLEPAPER
      NumPut(Flags, PSD, OffFlags, "Int")           ; Flags
      Offset := OffMargins
      NumPut(RE.Margins.L, PSD, Offset += 0, "Int") ; rtMargin left
      NumPut(RE.Margins.T, PSD, Offset += 4, "Int") ; rtMargin top
      NumPut(RE.Margins.R, PSD, Offset += 4, "Int") ; rtMargin right
      NumPut(RE.Margins.B, PSD, Offset += 4, "Int") ; rtMargin bottom
      If !DllCall("Comdlg32.dll\PageSetupDlg", "Ptr", &PSD, "UInt")
         Return False
      DllCall("Kernel32.dll\GobalFree", "Ptr", NumGet(PSD, 2 * A_PtrSize, "UPtr"))
      DllCall("Kernel32.dll\GobalFree", "Ptr", NumGet(PSD, 3 * A_PtrSize, "UPtr"))
      Flags := NumGet(PSD, OffFlags, "UInt")
      Metrics := (Flags & PSD_INTHOUSANDTHSOFINCHES) ? I : M
      Offset := OffMargins
      RE.Margins.L := NumGet(PSD, Offset += 0, "Int")
      RE.Margins.T := NumGet(PSD, Offset += 4, "Int")
      RE.Margins.R := NumGet(PSD, Offset += 4, "Int")
      RE.Margins.B := NumGet(PSD, Offset += 4, "Int")
      RE.Margins.LT := Round((RE.Margins.L / Metrics) * 1440) ; Left as twips
      RE.Margins.TT := Round((RE.Margins.T / Metrics) * 1440) ; Top as twips
      RE.Margins.RT := Round((RE.Margins.R / Metrics) * 1440) ; Right as twips
      RE.Margins.BT := Round((RE.Margins.B / Metrics) * 1440) ; Bottom as twips
      Return True
   }
   ; ===================================================================================================================
   ReplaceText(RE) { ; Replace dialog box
   ; ===================================================================================================================
      ; RE : RichEdit object
   	Static FINDMSGSTRING := "commdlg_FindReplace"
   	     , FR_DOWN := 1, FR_MATCHCASE := 4, FR_WHOLEWORD := 2
   	     , FBuf := "", RBuf := "", FR := "", Len := 256
           , FR_Size := A_PtrSize * 10
      Text := RE.GetSelText()
      VarSetCapacity(FBuf, Len, 0)
      VarSetCapacity(RBuf, Len, 0)
      VarSetCapacity(FR, FR_Size, 0)
   	NumPut(FR_Size, FR, 0, "UInt")
      If (Text && !RegExMatch(Text, "\W"))
         FBuf := Text
      Offset := A_PtrSize
   	NumPut(RE.GuiHwnd, FR, Offset, "UPtr") ; hwndOwner
      OffSet += A_PtrSize * 2
   	NumPut(FR_DOWN, FR, Offset, "UInt")	   ; Flags
      OffSet += A_PtrSize
   	NumPut(&FBuf, FR, Offset, "UPtr")      ; lpstrFindWhat
      OffSet += A_PtrSize
   	NumPut(&RBuf, FR, Offset, "UPtr")      ; lpstrReplaceWith
      OffSet += A_PtrSize
   	NumPut(Len,	FR, Offset, "Short")       ; wFindWhatLen
   	NumPut(Len,	FR, Offset + 2, "Short")   ; wReplaceWithLen
      This.ReplaceTextProc("Init", RE.HWND, "")
   	OnMessage(DllCall("User32.dll\RegisterWindowMessage", "Str", FINDMSGSTRING), "RichEditDlgs.ReplaceTextProc")
   	Return DllCall("Comdlg32.dll\ReplaceText", "Ptr", &FR, "UPtr")
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ReplaceTextProc(L, M, H) { ; skipped wParam, can be found in "This" when called by system
      ; Replace dialog callback procedure
      ; EM_FINDTEXTEXW = 0x047C, EM_EXGETSEL = 0x0434, EM_EXSETSEL = 0x0437
      ; EM_REPLACESEL = 0xC2, EM_SCROLLCARET = 0x00B7
      ; FR_DOWN = 1, FR_WHOLEWORD = 2, FR_MATCHCASE = 4,
   	Static FINDMSGSTRING := "commdlg_FindReplace"
   	     , FR_DOWN := 1, FR_MATCHCASE := 4, FR_WHOLEWORD := 2, FR_FINDNEXT := 0x8
           , FR_REPLACE := 0x10, FR_REPLACEALL=0x20, FR_DIALOGTERM := 0x40
           , HWND := 0, Min := "", Max := "", FS := "", FE := ""
           , OffFind := A_PtrSize * 4, OffRepl := A_PtrSize * 5
      If (L = "Init") {
         HWND := M, FS := "", FE := ""
         Return True
      }
      Flags := NumGet(L + 0, A_PtrSize * 3, "UInt")
      If (Flags & FR_DIALOGTERM) {
         OnMessage(DllCall("User32.dll\RegisterWindowMessage", "Str", FINDMSGSTRING), "")
         ControlFocus, , ahk_id %HWND%
         HWND := 0
         Return
      }
      If (Flags & FR_REPLACE) {
         IF (FS >= 0) && (FE >= 0) {
            SendMessage, 0xC2, 1, % NumGet(L + 0, OffRepl, "UPtr" ), , ahk_id %HWND%
            Flags |= FR_FINDNEXT
         } Else {
            Return
         }
      }
      If (Flags & FR_FINDNEXT) {
         VarSetCapacity(CR, 8, 0)
         SendMessage, 0x0434, 0, &CR, , ahk_id %HWND%
         Min := NumGet(CR, 4)
         FS := FE := ""
         Find := StrGet(NumGet(L + OffFind, 0, "UPtr"))
         VarSetCapacity(FTX, 16 + A_PtrSize, 0)
         NumPut(Min, FTX, 0, "Int")
         NumPut(-1, FTX, 4, "Int")
         NumPut(&Find, FTX, 8, "Ptr")
         SendMessage, 0x047C, %Flags%, &FTX, , ahk_id %HWND%
         S := NumGet(FTX, 8 + A_PtrSize, "Int"), E := NumGet(FTX, 12 + A_PtrSize, "Int")
         If (S = -1) && (E = -1)
            MsgBox, 262208, Replace, No (further) occurence found!
         Else {
            SendMessage, 0x0437, 0, % (&FTX + 8 + A_PtrSize), , ahk_id %HWND%
            SendMessage, 0x00B7, 0, 0, , ahk_id %HWND%
            FS := S, FE := E
         }
         Return
      }
      If (Flags & FR_REPLACEALL) {
         VarSetCapacity(CR, 8, 0)
         SendMessage, 0x0434, 0, &CR, , ahk_id %HWND%
         If (FS = "")
            FS := FE := 0
         DllCall("User32.dll\LockWindowUpdate", "Ptr", HWND)
         Find := StrGet(NumGet(L + OffFind, 0, "UPtr"))
         VarSetCapacity(FTX, 16 + A_PtrSize, 0)
         NumPut(FS, FTX, 0, "Int")
         NumPut(-1, FTX, 4, "Int")
         NumPut(&Find, FTX, 8, "Ptr")
         While (FS >= 0) && (FE >= 0) {
            SendMessage, 0x044F, %Flags%, &FTX, , ahk_id %HWND%
            FS := NumGet(FTX, A_PtrSize + 8, "Int"), FE := NumGet(FTX, A_PtrSize + 12, "Int")
            If (FS >= 0) && (FE >= 0) {
               SendMessage, 0x0437, 0, % (&FTX + 8 + A_PtrSize), , ahk_id %HWND%
               SendMessage, 0xC2, 1, % NumGet(L + 0, OffRepl, "UPtr" ), , ahk_id %HWND%
               NumPut(FE, FTX, 0, "Int")
            }
         }
         SendMessage, 0x0437, 0, &CR, , ahk_id %HWND%
         DllCall("User32.dll\LockWindowUpdate", "Ptr", 0)
         Return
      }
   }
}
