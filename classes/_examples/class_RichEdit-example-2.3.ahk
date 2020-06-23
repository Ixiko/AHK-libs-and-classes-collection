; ======================================================================================================================
; Class RichEdit Demo
; This is just me's sample script, modified
; by burque505 slightly;
; Image pasting and table pasting work in
; ======================================================================================================================
#NoEnv
SetBatchLines, -1
SetWinDelay, -1
SetControlDelay, -1
SendMode, Input
; ======================================================================================================================
; Create a Gui with RichEdit controls
; ======================================================================================================================
; SB Helptext ---------------------------------------------------------------------------------------------------------- ;{
SBHelp := {"BTSTB": "Bold (Alt+B)"
         , "BTSTI": "Italic (Alt+I)"
         , "BTSTU": "Underline (Alt+U)"
         , "BTSTS": "Strikeout (Alt+S)"
         , "BTSTH": "Superscript (Ctrl+Shift+""+"")"
         , "BTSTL": "Subscript (Ctrl+""+"")"
         , "BTSTN": "Normal (Alt+N)"
         , "BTTXC": "Text color (Alt+T)"
         , "BTBGC": "Text backcolor"
         , "BTCHF": "Choose font"
         , "BTSIP": "Increase size (Alt+""+"")"
         , "BTSIM": "Decrease size (Alt+""-"")"
         , "BTTAL": "Align left (Ctrl+L)"
         , "BTTAC": "Align center (Ctrl+E)"
         , "BTTAR": "Align right (Ctrl+R)"
         , "BTTAJ": "Align justified"
         , "BTL10": "Linespacing 1 line (Ctrl+1)"
         , "BTL15": "Linespacing 1,5 lines (Ctrl+5)"
         , "BTL20": "Linespacing 2 lines (Ctrl+2)"}
;}

; Initial values ------------------------------------------------------------------------------------------------------- ;{
EditW := 800
EditH := 400
MarginX := 10
MarginY := 10
GuiTitle := "AHK Rich Edit"
BackColor := "Auto"
FontName := "Arial"
FontSize := "10"
FontStyle := "N"
FontCharSet := 1
TextColor := "Auto"
TextBkColor := "Lime"
WordWrap := False
AutoURL := False
Zoom := "100 %"
ShowWysiwyg := False
CurrentLine := 0
CurrentLineCount := 0
HasFocus := False
;}

; Menus ---------------------------------------------------------------------------------------------------------------- ;{
Menu, Zoom, Add, 200 `%, Zoom
Menu, Zoom, Add, 150 `%, Zoom
Menu, Zoom, Add, 125 `%, Zoom
Menu, Zoom, Add, 100 `%, Zoom100
Menu, Zoom, Check, 100 `%
Menu, Zoom, Add, 75 `%, Zoom
Menu, Zoom, Add, 50 `%, Zoom
Menu, File, Add, &Open, FileOpen
Menu, File, Add, &Append, FileAppend
Menu, File, Add, &Insert, FileInsert
Menu, File, Add, &Close, FileClose
Menu, File, Add, &Save, FileSave
Menu, File, Add, Save &as, FileSaveAs
Menu, File, Add
Menu, File, Add, Page &Margins, PageSetup
Menu, File, Add, &Print, Print
Menu, File, Add
Menu, File, Add, &Exit, GuiClose
Menu, Edit, Add, &Undo`tCtrl+Z, Undo
Menu, Edit, Add, &Redo`tCtrl+Y, Redo
Menu, Edit, Add
Menu, Edit, Add, C&ut`tCtrl+X, Cut
Menu, Edit, Add, &Copy`tCtrl+C, Copy
Menu, Edit, Add, &Paste`tCtrl+V, Paste
Menu, Edit, Add, C&lear`tDel, Clear
Menu, Edit, Add
Menu, Edit, Add, Select &all `tCtrl+A, SelALL
Menu, Edit, Add, &Deselect all, Deselect
Menu, Search, Add, &Find, Find
Menu, Search, Add, &Replace, Replace
Menu, Alignment, Add, Align &left`tCtrl+L, AlignLeft
Menu, Alignment, Add, Align &center`tCtrl+E, AlignCenter
Menu, Alignment, Add, Align &right`tCtrl+R, AlignRight
Menu, Alignment, Add, Align &justified, AlignRight
Menu, Indentation, Add, &Set, Indentation
Menu, Indentation, Add, &Reset, ResetIndentation
Menu, LineSpacing, Add, 1 line`tCtrl+1, Spacing10
Menu, LineSpacing, Add, 1.5 lines`tCtrl+5, Spacing15
Menu, LineSpacing, Add, 2 lines`tCtrl+2, Spacing20
Menu, Numbering, Add, &Set, Numbering
Menu, Numbering, Add, &Reset, ResetNumbering
Menu, Tabstops, Add, &Set Tabstops, SetTabstops
Menu, Tabstops, Add, &Reset to Default, ResetTabStops
Menu, Tabstops, Add
Menu, Tabstops, Add, Set &Default Tabs, SetDefTabs
Menu, ParaSpacing, Add, &Set, ParaSpacing
Menu, ParaSpacing, Add, &Reset, ResetParaSpacing
Menu, Paragraph, Add, &Alignment, :Alignment
Menu, Paragraph, Add, &Indentation, :Indentation
Menu, Paragraph, Add, &Numbering, :Numbering
Menu, Paragraph, Add, &Linespacing, :LineSpacing
Menu, Paragraph, Add, &Space before/after, :ParaSpacing
Menu, Paragraph, Add, &Tabstops, :Tabstops
Menu, Character, Add, &Font, ChooseFont
Menu, TextColor, Add, &Choose, MTextColor
Menu, TextColor, Add, &Auto, MTextColor
Menu, Character, Add, &Text color, :TextColor
Menu, TextBkColor, Add, &Choose, MTextBkColor
Menu, TextBkColor, add, &Auto, MTextBkColor
Menu, Character, Add, Text &Backcolor, :TextBkColor
Menu, Format, Add, &Character, :Character
Menu, Format, Add, &Paragraph, :Paragraph
MenuWordWrap := "&Word-wrap"
Menu, View, Add, %MenuWordWrap%, WordWrap
MenuWysiwyg := "Wrap as &printed"
Menu, View, Add, %MenuWysiwyg%, Wysiwyg
Menu, View, Add, &Zoom, :Zoom
Menu, View, Add
Menu, Background, Add, &Choose, BackGroundColor
Menu, Background, Add, &Auto, BackgroundColor
Menu, View, Add, &Background Color, :Background
Menu, View, Add, &URL Detection, AutoURLDetection
Menu, GuiMenu, Add, &File, :File
Menu, GuiMenu, Add, &Edit, :Edit
Menu, GuiMenu, Add, &Search, :Search
Menu, GuiMenu, Add, F&ormat, :Format
Menu, GuiMenu, Add, &View, :View
Menu, ContextMenu, Add, &Edit, :Edit
Menu, ContextMenu, Add, &File, :File
Menu, ContextMenu, Add, &Search, :Search
Menu, ContextMenu, Add, &Format, :Format
Menu, ContextMenu, Add, &View, :View
; Main Gui -------------------------------------------------------------------------------------------------------------
GuiNum := 1
Gui, +ReSize +MinSize +hwndGuiID
Gui, Menu, GuiMenu
Gui, Margin, %MarginX%, %MarginY%
; Style buttons
Gui, Font, Bold, Arial
Gui, Add, Button, xm y3 w20 h20 vBTSTB gSetFontStyle, &B
Gui, Font, Norm Italic
Gui, Add, Button, x+0 yp wp hp vBTSTI gSetFontStyle, &I
Gui, Font, Norm Underline
Gui, Add, Button, x+0 yp wp hp vBTSTU gSetFontStyle, &U
Gui, Font, Norm Strike
Gui, Add, Button, x+0 yp wp hp vBTSTS gSetFontStyle, &S
Gui, Font, Norm, Arial
Gui, Add, Button, x+0 yp wp hp vBTSTH gSetFontStyle, % Chr(175)
Gui, Add, Button, x+0 yp wp hp vBTSTL gSetFontStyle, _
Gui, Add, Button, x+0 yp wp hp vBTSTN gSetFontStyle, &N
Gui, Add, Button, x+10 yp wp hp vBTTXC gBTextColor, &T
Gui, Add, Progress, x+0 yp wp hp BackgroundYellow cNavy Border, 50
Gui, Add, Button, x+0 yp wp hp vBTBGC gBTextBkColor, B
Gui, Add, Edit, x+10 yp w150 hp ReadOnly vFNAME, %FontName%
Gui, Add, Button, x+0 yp w20 hp vBTCHF gChooseFont, ...
Gui, Add, Button, x+5 yp wp hp vBTSIP gChangeSize, &+
Gui, Add, Edit, x+0 yp w30 hp ReadOnly vFSIZE, %FontSize%
Gui, Add, Button, x+0 yp w20 hp vBTSIM gChangeSize, &-
; RichEdit #1
Gui, Font, Bold Italic, Arial
Gui, Add, Text, x+10 yp hp vT1, WWWWWWWW
GuiControlGet, T, Pos, T1
TX := EditW - TW + MarginX
GuiControl, Move, T1, x%TX%
Gui, Font, s8, Arial
Options := " x" . TX . " y" . TY . " w" . TW . " h" . TH
If !IsObject(RE1 := New RichEdit(1, Options, False)) {
   MsgBox, 16, Error, %ErrorLevel%
   ExitApp
}
RE1.ReplaceSel("AaBbYyZz")
RE1.AlignText("CENTER")
RE1.SetOptions(["READONLY"], "SET")
Gui, Font, Norm, Arial
; Alignment & line spacing
Gui, Add, Text, xm y+2 w%EditW% h2 0x1000
Gui, Add, Button, x10 y+1 w30 h20 vBTTAL gAlignLeft, |<
Gui, Add, Button, x+0 yp wp hp vBTTAC gAlignCenter, ><
Gui, Add, Button, x+0 yp wp hp vBTTAR gAlignRight, >|
Gui, Add, Button, x+0 yp wp hp vBTTAJ gAlignJustify, |<>|
Gui, Add, Button, x+10 yp wp hp vBTL10 gSpacing10, 1
Gui, Add, Button, x+0 yp wp hp vBTL15 gSpacing15, % "1" . Chr(189)
Gui, Add, Button, x+0 yp wp hp vBTL20 gSpacing20, 2
; RichEdit #2
Gui, Font, s10, Arial
Options := "xm y+5 w" . EditW . " r20 gRE2MessageHandler" ; " h" . EditH
If !IsObject(RE2 := New RichEdit(1, Options)) {
   MsgBox, 16, Error, %ErrorLevel%
   ExitApp
}
GuiControlGet, RE, Pos, % RE2.HWND
RE_SetOleCallback(RE2.HWND)
OnMessage(0x204, "RightClick") ; WM_RIGHTBUTTONDOWN added - burque505
RE2.SetBkgndColor(BackColor)
RE2.SetEventMask(["SELCHANGE"])
Gui, Font
; The rest
Gui, Add, Statusbar
SB_SetParts(10, 200)
GuiW := GuiH := 0
Gui Show, , %GuiTitle%
OnMessage(WM_MOUSEMOVE := 0x200, "ShowSBHelp")
GuiControl, Focus, % RE2.HWND
GoSub, UpdateGui
Return ;}

======================================================================================================================
; End of auto-execute section
; ======================================================================================================================
; ----------------------------------------------------------------------------------------------------------------------

; Testing
^+f::
   RE2.FindText("Test", ["Down"])
Return
^+b::
   RE2.SetBorder([10], [2])
Return
^+m::
   SendMessage, 0xD3, 3, % (60 | (60 << 16)), , % "ahk_id " . RE2.HWND ; EM_SETMARGINS
   WinSet, Redraw, , % "ahk_id " . RE2.HWND
Return
; ======================================================================================================================
; ----------------------------------------------------------------------------------------------------------------------
RE2MessageHandler: ;{

      If (A_GuiEvent = "N") && (NumGet(A_EventInfo + 0, A_PtrSize * 2, "Int") = 0x0702) ; EN_SELCHANGE
      {
         SetTimer, UpdateGui, -10
      }
      Else {
         If (A_EventInfo = 0x0100) ; EN_SETFOCUS
            HasFocus := True
         Else If (A_EventInfo = 0x0200) ; EN_KILLFOCUS
            HasFocus := False
      }
Return ;}

#If (HasFocus) ;{
; FontStyles
^!b::  ; bold
^!h::  ; superscript
^!i::  ; italic
^!l::  ; subscript
^!n::  ; normal
^!p::  ; protected
^!s::  ; strikeout
^!u::  ; underline
RE2.ToggleFontStyle(SubStr(A_ThisHotkey, 3))
GoSub, UpdateGui
Return
#If ;}
; ----------------------------------------------------------------------------------------------------------------------
UpdateGui: ;{

   Font := RE2.GetFont()
   If (FontName != Font.Name || FontCharset != Font.CharSet || FontStyle != Font.Style || FontSize != Font.Size
   || TextColor != Font.Color || TextBkColor != Font.BkColor) {
      FontStyle := Font.Style
      TextColor := Font.Color
      TextBkColor := Font.BkColor
      FontCharSet := Font.CharSet
      If (FontName != Font.Name) {
         FontName := Font.Name
         GuiControl, , FNAME, %FontName%
      }
      If (FontSize != Font.Size) {
         FontSize := Round(Font.Size)
         GuiControl, , FSIZE, %FontSize%
      }
      Font.Size := 8
      RE1.SetSel(0, -1) ; select all
      RE1.SetFont(Font)
      RE1.SetSel(0, 0)  ; deselect all
   }
   Stats := RE2.GetStatistics()
   SB_SetText(Stats.Line . " : " . Stats.LinePos . " (" . Stats.LineCount . ")  [" . Stats.CharCount . "]", 2)

Return ;}
; ======================================================================================================================
; Gui related
; ======================================================================================================================
GuiClose: ;{
If IsObject(RE1)
  RE1 := ""
If IsObject(RE2)
  RE2 := ""
Gui, %A_Gui%:Destroy
ExitApp ;}
; ----------------------------------------------------------------------------------------------------------------------
GuiSize: ;{
Critical
If (A_EventInfo = 1)
   Return
If (GuiW = 0) {
   GuiW := A_GuiWidth
   GuiH := A_GuiHeight
   Return
}
If (A_GuiWidth != GuiW || A_GuiHeight != GuiH) {
   REW += A_GuiWidth - GuiW
   REH += A_GuiHeight - GuiH
   GuiControl, Move, % RE2.HWND, w%REW% h%REH%
   GuiW := A_GuiWidth
   GuiH := A_GuiHeight
}
Return ;}
; ----------------------------------------------------------------------------------------------------------------------
RightClick(wParam, lParam) {
    X := lParam & 0xFFFF
    Y := lParam >> 16
	Gosub, MakeMenu
	return
}

GuiContextMenu: ;{
MouseGetPos, , , , HControl, 2
WinGetClass, Class, ahk_id %HControl%
If (Class = RichEdit.Class)
   Menu, ContextMenu, Show
Return ;}
; ======================================================================================================================
; Text operations
; ======================================================================================================================
SetFontStyle: ;{
RE2.ToggleFontStyle(SubStr(A_GuiControl, 0))
GoSub, UpdateGui
GuiControl, Focus, % RE2.HWND
Return ;}
; ----------------------------------------------------------------------------------------------------------------------
ChangeSize: ;{
Size := RE2.ChangeFontSize(SubStr(A_GuiControl, 0) = "P" ? 1 : -1)
GoSub, UpdateGui
GuiControl, Focus, % RE2.HWND
Return ;}
; ======================================================================================================================
; Menu File
; ======================================================================================================================
FileAppend:
FileOpen:
FileInsert: ;{
If (File := RichEditDlgs.FileDlg(RE2, "O")) {
   RE2.LoadFile(File, SubStr(A_ThisLabel, 5))
   If (A_ThisLabel = "FileOpen") {
      Gui, +LastFound
      WinGetTitle, Title
      StringSplit, Title, Title, -, %A_Space%
      WinSetTitle, %Title1% - %File%
      Open_File := File
   }
   GoSub, UpdateGui
}
RE2.SetModified()
GuiControl, Focus, % RE2.HWND
Return ;}
; ----------------------------------------------------------------------------------------------------------------------
FileClose: ;{
If (Open_File) {
   If RE2.IsModified() {
      Gui, +OwnDialogs
      MsgBox, 35, Close File, Content has been modified!`nDo you want to save changes?
      IfMsgBox, Cancel
      {
         GuiControl, Focus, % RE2.HWND
         Return
      }
      IfMsgBox, Yes
         GoSub, FileSave
   }
   If RE2.SetText() {
      Gui, +LastFound
      WinGetTitle, Title
      StringSplit, Title, Title, -, %A_Space%
      WinSetTitle, %Title1%
      Open_File := ""
   }
   GoSub, UpdateGui
}
RE2.SetModified()
GuiControl, Focus, % RE2.HWND
Return ;}
; ----------------------------------------------------------------------------------------------------------------------
FileSave: ;{
If !(Open_File) {
   GoSub, FileSaveAs
   Return
}
RE2.SaveFile(Open_File)
RE2.SetModified()
GuiControl, Focus, % RE2.HWND
Return ;}
; ----------------------------------------------------------------------------------------------------------------------
FileSaveAs: ;{
If (File := RichEditDlgs.FileDlg(RE2, "S")) {
   RE2.SaveFile(File)
   Gui, +LastFound
   WinGetTitle, Title
   StringSplit, Title, Title, -, %A_Space%
   WinSetTitle, %Title1% - %File%
   Open_File := File
}
GuiControl, Focus, % RE2.HWND
Return ;}
; ----------------------------------------------------------------------------------------------------------------------
PageSetup: ;{
RichEditDlgs.PageSetup(RE2)
GuiControl, Focus, % RE2.HWND
Return ;}
; ----------------------------------------------------------------------------------------------------------------------
Print: ;{
RE2.Print()
GuiControl, Focus, % RE2.HWND
Return ;}
; ======================================================================================================================
; Menu Edit
; ======================================================================================================================
Undo:
RE2.Undo()
GuiControl, Focus, % RE2.HWND
Return
; ----------------------------------------------------------------------------------------------------------------------
Redo:
RE2.Redo()
GuiControl, Focus, % RE2.HWND
Return
; ----------------------------------------------------------------------------------------------------------------------
Cut:
RE2.Cut()
GuiControl, Focus, % RE2.HWND
Return
; ----------------------------------------------------------------------------------------------------------------------
Copy:
RE2.Copy()
GuiControl, Focus, % RE2.HWND
Return
; ----------------------------------------------------------------------------------------------------------------------
Paste:
RE2.Paste()
GuiControl, Focus, % RE2.HWND
Return
; ----------------------------------------------------------------------------------------------------------------------
Clear:
RE2.Clear()
GuiControl, Focus, % RE2.HWND
Return
; ----------------------------------------------------------------------------------------------------------------------
SelAll:
RE2.SelAll()
GuiControl, Focus, % RE2.HWND
Return
; ----------------------------------------------------------------------------------------------------------------------
Deselect:
RE2.Deselect()
GuiControl, Focus, % RE2.HWND
Return
; ======================================================================================================================
; Menu View
; ======================================================================================================================
WordWrap:
WordWrap ^= True
RE2.WordWrap(WordWrap)
Menu, %A_ThisMenu%, ToggleCheck, %A_ThisMenuItem%
If (WordWrap)
   Menu, %A_ThisMenu%, Disable, %MenuWysiwyg%
Else
   Menu, %A_ThisMenu%, Enable, %MenuWysiwyg%
GuiControl, Focus, % RE2.HWND
Return
; ----------------------------------------------------------------------------------------------------------------------
Zoom:
Zoom100:
Menu, Zoom, UnCheck, %Zoom%
If (A_ThisLabel = "Zoom100")
   Zoom := "100 %"
Else
   Zoom := A_ThismenuItem
Menu, Zoom, Check, %Zoom%
RegExMatch(Zoom, "\d+", Ratio)
RE2.SetZoom(Ratio)
GuiControl, Focus, % RE2.HWND
Return
; ----------------------------------------------------------------------------------------------------------------------
WYSIWYG:
ShowWysiwyg ^= True
If (ShowWysiwyg)
   GoSub, Zoom100
RE2.WYSIWYG(ShowWysiwyg)
Menu, %A_ThisMenu%, ToggleCheck, %A_ThisMenuItem%
If (ShowWysiwyg)
   Menu, %A_ThisMenu%, Disable, %MenuWordWrap%
Else
   Menu, %A_ThisMenu%, Enable, %MenuWordWrap%
GuiControl, Focus, % RE2.HWND
Return
; ----------------------------------------------------------------------------------------------------------------------
BackgroundColor:
If InStr(A_ThisMenuItem, "Auto")
   RE2.SetBkgndColor("Auto")
Else If ((NC := RichEditDlgs.ChooseColor(RE2, BackColor)) <> "")
   RE2.SetBkgndColor(BackColor := BGC := NC)
GuiControl, Focus, % RE2.HWND
Return
; ----------------------------------------------------------------------------------------------------------------------
AutoURLDetection:
RE2.AutoURL(AutoURL ^= True)
Menu, %A_ThisMenu%, ToggleCheck, %A_ThisMenuItem%
GuiControl, Focus, % RE2.HWND
Return
; ======================================================================================================================
; Menu Character
; ======================================================================================================================
ChooseFont:
RichEditDlgs.ChooseFont(RE2)
Font := RE2.GetFont()
Gui, ListView, FNAME
LV_Modify(1, "", Font.Name)
Gui, ListView, FSIZE
LV_Modify(1, "", Font.Size)
GuiControl, Focus, % RE2.HWND
Return
; ----------------------------------------------------------------------------------------------------------------------
MTextColor:    ; menu label
BTextColor:    ; button label
If (A_ThisLabel = "MTextColor") && InStr(A_ThisMenuItem, "Auto")
   RE2.SetFont({Color: "Auto"}), TXC := ""
Else If (StrLen(NC := RichEditDlgs.ChooseColor(RE2, "T")) <> "")
   RE2.SetFont({Color: NC}), TXC := NC
ControlFocus,, % "ahk_id " . RE2.HWND
Return
; ----------------------------------------------------------------------------------------------------------------------
MTextBkColor:  ; menu label
BTextBkColor:  ; button label
If (A_ThisLabel = "MTextBkColor") && InStr(A_ThisMenuItem, "Auto")
    RE2.SetFont({BkColor: "Auto"}), TBC := ""
Else If (StrLen(NC := RichEditDlgs.ChooseColor(RE2, "B")) <> "")
   RE2.SetFont({BkColor: NC}), TBC := NC
ControlFocus,, % "ahk_id " . RE2.HWND
Return
; ======================================================================================================================
; Menu Paragraph
; ======================================================================================================================
AlignLeft:
AlignCenter:
AlignRight:
AlignJustify:
RE2.AlignText({AlignLeft: 1, AlignRight: 2, AlignCenter: 3, AlignJustify: 4}[A_ThisLabel])
GuiControl, Focus, % RE2.HWND
Return
; ----------------------------------------------------------------------------------------------------------------------
Indentation:
ParaIndentGui(RE2)
GuiControl, Focus, % RE2.HWND
Return
ResetIndentation:
RE2.SetParaIndent()
GuiControl, Focus, % RE2.HWND
Return
; ----------------------------------------------------------------------------------------------------------------------
Numbering:
ParaNumberingGui(RE2)
GuiControl, Focus, % RE2.HWND
Return
ResetNumbering:
RE2.SetParaNumbering()
GuiControl, Focus, % RE2.HWND
Return
; ----------------------------------------------------------------------------------------------------------------------
ParaSpacing:
ParaSpacingGui(RE2)
GuiControl, Focus, % RE2.HWND
Return
ResetParaSpacing:
RE2.SetParaSpacing()
GuiControl, Focus, % RE2.HWND
Return
; ----------------------------------------------------------------------------------------------------------------------
Spacing10:
Spacing15:
Spacing20:
RegExMatch(A_ThisLabel, "\d+$", S)
RE2.SetLineSpacing(S / 10)
GuiControl, Focus, % RE2.HWND
Return
; ----------------------------------------------------------------------------------------------------------------------
SetTabStops:
SetTabStopsGui(RE2)
Return
ResetTabStops:
RE2.SetTabStops()
GuiControl, Focus, % RE2.HWND
Return
; ----------------------------------------------------------------------------------------------------------------------
SetDefTabs:
RE2.SetDefaultTabs(1)
GuiControl, Focus, % RE2.HWND
Return
; ======================================================================================================================
; Menu Search
; ======================================================================================================================
Find:
RichEditDlgs.FindText(RE2)
Return
; ----------------------------------------------------------------------------------------------------------------------
Replace:
RichEditDlgs.ReplaceText(RE2)
Return

; ======================================================================================================================

; ======================================================================================================================
; Additions below by burque505
; ======================================================================================================================
MakeMenu: ;{
Menu, RTE_Menu, Add, &Copy, Copy2  ; Simple context menu
Menu, RTE_Menu, Add, &Paste, Paste2  ;
Menu, RTE_Menu, Add, Cu&t, Cut2  ;
Menu, RTE_Menu, Add, Select &All, All2 ;
Menu, RTE_Menu, Add, &Undo, Undo2 ;
Menu, RTE_Menu, Add, &Redo, Redo2 ;
Menu, RTE_Menu, Add
Menu, RTE_Menu, Color, e6FFe6
Menu, RTE_Menu, Add, &Edit, :Edit
Menu, RTE_Menu, Add, &File, :File
Menu, RTE_Menu, Add, &Search, :Search
Menu, RTE_Menu, Add, &Format, :Format
Menu, RTE_Menu, Add, &View, :View
Menu, RTE_Menu, Show
Menu, RTE_Menu, Color, FFFFFF
return

Copy2:
Send, ^c
return

Paste2:
Send, ^v
return

Cut2:
Send, ^x
return

All2:
Send, ^a
return

Undo2:
Send, ^z
return

Redo2:
Send, ^y
return

^!m::
gosub, MakeMenu
;MsgBox Context Menu: %A_ThisLabel%
return ;}

EM_SETMARGINS(Hwnd, Left := "", Right := "") {
   ; EM_SETMARGINS = 0x00D3 -> http://msdn.microsoft.com/en-us/library/bb761649(v=vs.85).aspx
      Set := 0 + (Left <> "") + ((Right <> "") * 2)
      Margins := (Left <> "" ? Left & 0xFFFF : 0) + (Right <> "" ? (Right & 0xFFFF) << 16 : 0)

   Return DllCall("User32.dll\SendMessage", "Ptr", HWND, "UInt", 0x00D3, "Ptr", Set, "Ptr", Margins, "Ptr")
}
ShowSBHelp() {
   Global SBHelp, GuiNum
   Static Current := 0
   If (A_Gui = GuiNum) && (A_GuiControl <> Current)
      SB_SetText(SBHelp[(Current := A_GuiControl)], 3)
   Return
}

ParaIndentGui(RE) {
   Static Owner := ""
        , Success := False
   Metrics := RE.GetMeasurement()
   PF2 := RE.GetParaFormat()
   Owner := RE.GuiName
   Gui, ParaIndentGui: New
   Gui, +Owner%Owner% +ToolWindow +LastFound +LabelParaIndentGui
   Gui, Margin, 20, 10
   Gui, Add, Text, Section h20 0x200, First line left indent (absolute):
   Gui, Add, Text, xs hp 0x200, Other lines left indent (relative):
   Gui, Add, Text, xs hp 0x200, All lines right indent (absolute):
   Gui, Add, Edit, ys hp Limit5 hwndhLeft1
   Gui, Add, Edit, hp Limit6 hwndhLeft2
   Gui, Add, Edit, hp Limit5 hwndhRight
   Gui, Add, CheckBox, ys x+5 hp hwndhCBStart, Apply
   Gui, Add, CheckBox, hp hwndhCBOffset, Apply
   Gui, Add, CheckBox, hp hwndhCBRight, Apply
   Left1 := Round((PF2.StartIndent / 1440) * Metrics, 2)
   If (Metrics = 2.54)
      Left1 := RegExReplace(Left1, "\.", ",")
   GuiControl, , %hLeft1%, %Left1%
   Left2 := Round((PF2.Offset / 1440) * Metrics, 2)
   If (Metrics = 2.54)
      Left2 := RegExReplace(Left2, "\.", ",")
   GuiControl, , %hLeft2%, %Left2%
   Right := Round((PF2.RightIndent / 1440) * Metrics, 2)
   If (Metrics = 2.54)
      Right := RegExReplace(Right, "\.", ",")
   GuiControl, , %hRight%, %Right%
   Gui, Add, Button, xs gParaIndentGuiApply hwndhBtn1, Apply
   Gui, Add, Button, x+10 yp gParaIndentGuiClose hwndhBtn2, Cancel
   GuiControlGet, B, Pos, %hBtn2%
   GuiControl, Move, %hBtn1%, w%BW%
   GuiControlGet, E, Pos, %hCBRight%
   GuiControl, Move, %hBtn2%, % "x" . (EX + EW - BW)
   Gui, %Owner%:+Disabled
   Gui, Show, , Paragraph Indentation
   WinWaitActive
   WinWaitClose
   Return Success
   ; -------------------------------------------------------------------------------------------------------------------
   ParaIndentGuiClose:
      Success := False
      Gui, %Owner%:-Disabled
      Gui, Destroy
   Return
   ; -------------------------------------------------------------------------------------------------------------------
   ParaIndentGuiApply:
      GuiControlGet, ApplyStart, , %hCBStart%
      GuiControlGet, ApplyOffset, , %hCBOffset%
      GuiControlGet, ApplyRight, , %hCBRight%
      Indent := {}
      If ApplyStart {
         GuiControlGet, Start, , %hLeft1%
         If (Start = "")
            Start := 0
         If !RegExMatch(Start, "^\d{1,2}((\.|,)\d{1,2})?$") {
            GuiControl, , %hLeft1%
            GuiControl, Focus, %hLeft1%
            Return
         }
         StringReplace, Start, Start, `,, .
         Indent.Start := Start
      }
      If (ApplyOffset) {
         GuiControlGet, Offset, , %hLeft2%
         If (Offset = "")
            Offset := 0
         If !RegExMatch(Offset, "^(-)?\d{1,2}((\.|,)\d{1,2})?$") {
            GuiControl, , %hLeft2%
            GuiControl, Focus, %hLeft2%
            Return
         }
         StringReplace, OffSet, OffSet, `,, .
         Indent.Offset := Offset
      }
      If (ApplyRight) {
         GuiControlGet, Right, , %hRight%
         If (Right = "")
            Right := 0
         If !RegExMatch(Right, "^\d{1,2}((\.|,)\d{1,2})?$") {
            GuiControl, , %hRight%
            GuiControl, Focus, %hRight%
            Return
         }
         StringReplace, Right, Right, `,, .
         Indent.Right := Right
      }
      Success := RE.SetParaIndent(Indent)
      Gui, %Owner%:-Disabled
      Gui, Destroy
   Return
}
ParaNumberingGui(RE) {
   Static Owner := ""
        , Bullet := "•"
        , PFN := ["Bullet", "Arabic", "LCLetter", "UCLetter", "LCRoman", "UCRoman"]
        , PFNS := ["Paren", "Parens", "Period", "Plain", "None"]
        , Success := False
   Metrics := RE.GetMeasurement()
   PF2 := RE.GetParaFormat()
   Owner := RE.GuiName
   Gui, ParaNumberingGui: New
   Gui, +Owner%Owner% +ToolWindow +LastFound +LabelParaNumberingGui
   Gui, Margin, 20, 10
   Gui, Add, Text, Section h20 w100 0x200, Type:
   Gui, Add, DDL, xp y+0 wp AltSubmit hwndhType, %Bullet%|0, 1, 2|a, b, c|A, B, C|i, ii, iii|I, I, III
   If (PF2.Numbering)
      GuiControl, Choose, %hType%, % PF2.Numbering
   Gui, Add, Text, xs h20 w100 0x200, Start with:
   Gui, Add, Edit, y+0 wp hp Limit5 hwndhStart
   GuiControl, , %hStart%, % PF2.NumberingStart
   Gui, Add, Text, ys h20 w100 0x200, Style:
   Gui, Add, DDL, y+0 wp AltSubmit hwndhStyle Choose1, 1)|(1)|1.|1|w/o
   If (PF2.NumberingStyle)
      GuiControl, Choose, %hStyle%, % ((PF2.NumberingStyle // 0x0100) + 1)
   Gui, Add, Text, h20 w100 0x200, % "Distance:  (" . (Metrics = 1.00 ? "in." : "cm") . ")"
   Gui, Add, Edit, y+0 wp hp Limit5 hwndhDist
   Tab := Round((PF2.NumberingTab / 1440) * Metrics, 2)
   If (Metrics = 2.54)
      Tab := RegExReplace(Tab, "\.", ",")
   GuiControl, , %hDist%, %tab%
   Gui, Add, Button, xs gParaNumberingGuiApply hwndhBtn1, Apply
   Gui, Add, Button, x+10 yp gParaNumberingGuiClose hwndhBtn2, Cancel
   GuiControlGet, B, Pos, %hBtn2%
   GuiControl, Move, %hBtn1%, w%BW%
   GuiControlGet, D, Pos, %hStyle%
   GuiControl, Move, %hBtn2%, % "x" . (DX + DW - BW)
   Gui, %Owner%:+Disabled
   Gui, Show, , Paragraph Numbering
   WinWaitActive
   WinWaitClose
   Return Success
   ; -------------------------------------------------------------------------------------------------------------------
   ParaNumberingGuiClose:
      Success := False
      Gui, %Owner%:-Disabled
      Gui, Destroy
   Return
   ; -------------------------------------------------------------------------------------------------------------------
   ParaNumberingGuiApply:
      GuiControlGet, Type, , %hType%
      GuiControlGet, Style, , %hStyle%
      GuiControlGet, Start, , %hStart%
      GuiControlGet, Tab, , %hDist%
      If !RegExMatch(Tab, "^\d{1,2}((\.|,)\d{1,2})?$") {
         GuiControl, , %hDist%
         GuiControl, Focus, %hDist%
         Return
      }
      Numbering := {Type: PFN[Type], Style: PFNS[Style]}
      Numbering.Tab := RegExReplace(Tab, ",", ".")
      Numbering.Start := Start
      Success := RE.SetParaNumbering(Numbering)
      Gui, %Owner%:-Disabled
      Gui, Destroy
   Return
}
ParaSpacingGui(RE) {
   Static Owner := ""
        , Success := False
   PF2 := RE.GetParaFormat()
   Owner := RE.GuiName
   Gui, ParaSpacingGui: New
   Gui, +Owner%Owner% +ToolWindow +LastFound +LabelParaSpacingGui
   Gui, Margin, 20, 10
   Gui, Add, Text, Section h20 0x200, Space before in points:
   Gui, Add, Text, xs y+10 hp 0x200, Space after in points:
   Gui, Add, Edit, ys hp hwndhBefore Number Limit2 Right, 00
   GuiControl, , %hBefore%, % (PF2.SpaceBefore // 20)
   Gui, Add, Edit, xp y+10 hp hwndhAfter Number Limit2 Right, 00
   GuiControl, , %hAfter%, % (PF2.SpaceAfter // 20)
   Gui, Add, Button, xs gParaSpacingGuiApply hwndhBtn1, Apply
   Gui, Add, Button, x+10 yp gParaSpacingGuiClose hwndhBtn2, Cancel
   GuiControlGet, B, Pos, %hBtn2%
   GuiControl, Move, %hBtn1%, w%BW%
   GuiControlGet, E, Pos, %hAfter%
   X := EX + EW - BW
   GuiControl, Move, %hBtn2%, x%X%
   Gui, %Owner%:+Disabled
   Gui, Show, , Paragraph Spacing
   WinWaitActive
   WinWaitClose
   Return Success
   ; -------------------------------------------------------------------------------------------------------------------
   ParaSpacingGuiClose:
      Success := False
      Gui, %Owner%:-Disabled
      Gui, Destroy
   Return
   ; -------------------------------------------------------------------------------------------------------------------
   ParaSpacingGuiApply:
      GuiControlGet, Before, , %hBefore%
      GuiControlGet, After, , %hAfter%
      Success := RE.SetParaSpacing({Before: Before, After: After})
      Gui, %Owner%:-Disabled
      Gui, Destroy
   Return
}
SetTabStopsGui(RE) {
   ; Set paragraph's tabstobs
   ; Call with parameter mode = "Reset" to reset to default tabs
   ; EM_GETPARAFORMAT = 0x43D, EM_SETPARAFORMAT = 0x447
   ; PFM_TABSTOPS = 0x10
   Static Owner   := ""
        , Metrics := 0
        , MinTab  := 0.30     ; minimal tabstop in inches
        , MaxTab  := 8.30     ; maximal tabstop in inches
        , AL := 0x00000000    ; left aligned (default)
        , AC := 0x01000000    ; centered
        , AR := 0x02000000    ; right aligned
        , AD := 0x03000000    ; decimal tabstop
        , Align := {0x00000000: "L", 0x01000000: "C", 0x02000000: "R", 0x03000000: "D"}
        , TabCount := 0       ; tab count
        , MAX_TAB_STOPS := 32
        , Success := False    ; return value
   Metrics := RE.GetMeasurement()
   PF2 := RE.GetParaFormat()
   TL := ""
   TabCount := PF2.TabCount
   Tabs := PF2.Tabs
   Loop, %TabCount% {
      Tab := Tabs[A_Index]
      TL .= Round(((Tab & 0x00FFFFFF) * Metrics) / 1440, 2) . ":" . (Tab & 0xFF000000) . "|"
   }
   If (TabCount)
      TL := SubStr(TL, 1, -1)
   Owner := RE.GuiName
   Gui, SetTabStopsGui: New
   Gui, +Owner%Owner% +ToolWindow +LastFound +LabelSetTabStopsGui
   Gui, Margin, 10, 10
   Gui, Add, Text, Section, % "Position: (" . (Metrics = 1.00 ? "in." : "cm") . ")"
   Gui, Add, ComboBox, xs y+2 w120 r6 Simple +0x800 hwndCBBID AltSubmit gSetTabStopsGuiSelChanged
   If (TabCount) {
      Loop, Parse, TL, |
      {
         StringSplit, T, A_LoopField, :
         SendMessage, 0x0143, 0, &T1, , ahk_id %CBBID% ; CB_ADDSTRING
         SendMessage, 0x0151, ErrorLevel, T2, , ahk_id %CBBID% ; CB_SETITEMDATA
      }
   }
   Gui, Add, Text, ys Section, Alignment:
   Gui, Add, Radio, xs w60 Section y+2 hwndRLID Checked Group, Left
   Gui, Add, Radio, wp hwndRCID, Center
   Gui, Add, Radio, ys wp hwndRRID, Right
   Gui, Add, Radio, wp hwndRDID, Decimal
   Gui, Add, Button, xs Section w60 gSetTabStopsGuiAdd Disabled hwndBTADDID, &Add
   Gui, Add, Button, ys w60 gSetTabStopsGuiRemove Disabled hwndBTREMID, &Remove
   GuiControlGet, P1, Pos, %BTADDID%
   GuiControlGet, P2, Pos, %BTREMID%
   W := P2X + P2W - P1X
   Gui, Add, Button, xs w%W% gSetTabStopsGuiRemoveAll hwndBTCLAID, &Clear all
   Gui, Add, Text, xm h5
   Gui, Add, Button, xm y+0 w60 gSetTabStopsGuiOK, &OK
   X := P2X + P2W - 60
   Gui, Add, Button, x%X% yp wp gSetTabStopsGuiClose, &Cancel
   Gui, %Owner%:+Disabled
   Gui, Show, , Set Tabstops
   WinWaitActive
   WinWaitClose
   Return Success
   ; -------------------------------------------------------------------------------------------------------------------
   SetTabStopsGuiClose:
      Success := False
      Gui, %Owner%:-Disabled
      Gui, Destroy
   Return
   ; -------------------------------------------------------------------------------------------------------------------
   SetTabStopsGuiSelChanged:
      If (TabCount < MAX_TAB_STOPS) {
         GuiControlGet, T, , %CBBID%, Text
         If RegExMatch(T, "^\s*$")
            GuiControl, Disable, %BTADDID%
         Else
            GuiControl, Enable, %BTADDID%
      }
      SendMessage, 0x0147, 0, 0, , ahk_id %CBBID% ; CB_GETCURSEL
      I := ErrorLevel
      If (I > 0x7FFFFFFF) {
         GuiControl, Disable, %BTREMID%
         Return
      }
      GuiControl, Enable, %BTREMID%
      SendMessage, 0x0150, I, 0, , ahk_id %CBBID% ; CB_GETITEMDATA
      A := ErrorLevel
      C := A = AC ? RCID : A = AR ? RRID : A = AD ? RDID : RLID
      GuiControl, , %C%, 1
   Return
   ; -------------------------------------------------------------------------------------------------------------------
   SetTabStopsGuiAdd:
      GuiControlGet, T, ,%CBBID%, Text
      If !RegExMatch(T, "^\d*[.,]?\d+$") {
         GuiControl, Focus, %CBBID%
         Return
      }
      StringReplace, T, T, `,, .
      T := Round(T, 2)
      If (Round(T / Metrics, 2) < MinTab) {
         GuiControl, Focus, %CBBID%
         Return
      }
      If (Round(T / Metrics, 2) > MaxTab) {
         GuiControl, Focus, %CBBID%
         Return
      }
      GuiControlGet, RL, , %RLID%
      GuiControlGet, RC, , %RCID%
      GuiControlGet, RR, , %RRID%
      GuiControlGet, RD, , %RDID%
      A := RC ? AC : RR ? AR : RD ? AD : AL
      ControlGet, TL, List, , , ahk_id %CBBID%
      P := -1
      Loop, Parse, TL, `n
      {
         If (T < A_LoopField) {
            P := A_Index - 1
            Break
         }
         IF (T = A_LoopField) {
            P := A_Index - 1
            SendMessage, 0x0144, P, 0, , ahk_id %CBBID% ; CB_DELETESTRING
            Break
         }
      }
      SendMessage, 0x014A, P, &T, , ahk_id %CBBID% ; CB_INSERTSTRING
      SendMessage, 0x0151, ErrorLevel, A, , ahk_id %CBBID% ; CB_SETITEMDATA
      TabCount++
      If !(TabCount < MAX_TAB_STOPS)
         GuiControl, Disable, %BTADDID%
      GuiControl, Text, %CBBID%
      GuiControl, Focus, %CBBID%
   Return
   ; -------------------------------------------------------------------------------------------------------------------
   SetTabStopsGuiRemove:
      SendMessage, 0x0147, 0, 0, , ahk_id %CBBID% ; CB_GETCURSEL
      I := ErrorLevel
      If (I > 0x7FFFFFFF)
         Return
      SendMessage, 0x0144, I, 0, , ahk_id %CBBID% ; CB_DELETESTRING
      GuiControl, Text, %CBBID%
      TabCount--
      GuiControl, , %RLID%, 1
      GuiControl, Focus, %CBBID%
   Return
   ; -------------------------------------------------------------------------------------------------------------------
   SetTabStopsGuiRemoveAll:
      GuiControl, , %CBBID%, |
      TabCount := 0
      GuiControl, , %RLID%, 1
      GuiControl, Focus, %CBBID%
   Return
   ; -------------------------------------------------------------------------------------------------------------------
   SetTabStopsGuiOK:
      SendMessage, 0x0146, 0, 0, , ahk_id %CBBID% ; CB_GETCOUNT
      If ((TabCount := ErrorLevel) > 0x7FFFFFFF)
         Return
      If (TabCount > 0) {
         ControlGet, TL, List, , , ahk_id %CBBID%
         TabStops := {}
         Loop, Parse, TL, `n
         {
            SendMessage, 0x0150, A_Index - 1, 0, , ahk_id %CBBID% ; CB_GETITEMDATA
            TabStops[A_LoopField * 100] := Align[ErrorLevel]
         }
      }
      Success := RE.SetTabStops(TabStops)
      Gui, %Owner%:-Disabled
      Gui, Destroy
   Return
}



^Escape::ExitApp

#Include %A_ScriptDir%\..\Class_RichEdit.ahk
#Include %A_ScriptDir%\..\Class_RichEditDlgs.ahk
#Include %A_ScriptDir%\..\..\lib-i_to_z\RichEdit OleCallback.ahk

