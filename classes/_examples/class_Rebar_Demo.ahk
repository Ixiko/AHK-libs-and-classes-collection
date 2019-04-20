#NoEnv
#SingleInstance, Force
SetBatchLines, -1
Process, Priority,, High
;#Include Class_Rebar.ahk
;#Include Class_Toolbar.ahk ; https://github.com/Pulover/Class_Toolbar

Gui, +Resize
; TBSTYLE_FLAT      := 0x0800 Required to show separators as bars.
; TBSTYLE_TOOLTIPS  := 0x0100 Required to show Tooltips.
; CCS_NODIVIDER     := 0x0040 Removes separator line above controls.
; CCS_NOPARENTALIGN := 0x0008 Required tow allow positioning of toolbar.
; CCS_NORESIZE      := 0x0004 Required tow allow resizing of toolbar.
Gui, Add, Custom, ClassToolbarWindow32 hwndhToolbar x0 y0 h23 w500 0x0800 0x0100 0x0040 0x0008 0x0004
; RBS_VARHEIGHT    := 0x0200 - Allow bands to have different heights.
; RBS_BANDBORDERS  := 0x0400 - Add a separator border between bands in different rows.
; RBS_DBLCLKTOGGLE := 0x8000 - Toggle maximize/minimize with double-click instead of single.
Gui, Add, Custom, ClassReBarWindow32 hwndhRebar 0x0200 0x0400 0x0040 0x8000
Gui, Add, Combobox, hwndhCombo vFontFace gChangeFont, Arial||Verdana|Tahoma|Times New Roman
Gui, Add, Edit, x5 y60 w280 r10 hwndhTextEdit, Some text sample.
Gui, Add, Button, hwndhSave gSave, Save Layout
Gui, Add, Button, hwndhLoad gLoad, Load Layout
Gui, Show, h205 w400 x600 y300, [Class] Rebar - Demostration Script

GoSub, DefineToolbar

; ========== Rebar ==========

; Get sizes from the controls that will be added to the bands.
TB.Get("", "", "", tbBtnWidth, tbBtnHeight)
NumButtons := TB.GetCount()
tbWidth := NumButtons * tbBtnWidth
GuiControlGet, rc, Pos, %hCombo%
GuiControlGet, re, Pos, %hTextEdit%

; You can set a Bitmap file to be used as background.
BG := "bg.bmp"

; Create an Image List for the rebar.
IL := IL_Create(1, 1)
IL_Add(IL, "shell32.dll", 74)
IL_Add(IL, "shell32.dll", 76)

; Initialize class.
RB := New Rebar(hRebar)

; Set an Image List.
RB.SetImageList(IL)

; Add bands with hwnd's of controls to be inserted and their sizes/positions.
RB.InsertBand(hToolbar, 0, "", 10, "", 100, 0, "", tbBtnHeight, 25, 100)
RB.InsertBand(hCombo, 0, "", 20, "Font:", 200, 1, BG, rch, rcw, 75)
RB.InsertBand(hTextEdit, 0, "Break", 30, "", 290, 0, "", reh, rew) ; "Break" sends the band to a new row.
RB.InsertBand(hSave, 0, "Break", 40, "", 180)
RB.InsertBand(hLoad, 0, "", 50, "", 180)

; Set a function to monitor the Chevron button notification.
WM_NOTIFY := 0x4E
OnMessage(WM_NOTIFY, "RB_Notify")
return

; This function monitors rebar's notifications. Only required for the Chevron and SetMaxRows.
RB_Notify(wParam, lParam)
{
    Global RB ; Function (or at least the Handles) must be global.
    If (RB.OnNotify(lParam, MX, MY, BandID)) ; Handles notifications.
        ShowChevronMenu(BandID, MX, MY) ; If the ChevronPushed notification is caught
                                 ; it returns the returns the band's ID and coordinates to show a menu.
}

ShowChevronMenu(Band, X, Y)
{
    Global TB
    HidBtns := TB.GetHiddenButtons() ; Retrives which buttons are hidden by the band.
    Loop, % HidBtns.MaxIndex()
        Menu, TestMenu, Add, % HidBtns[A_Index].Text, % HidBtns[A_Index].Label
    Menu, TestMenu, Show, %X%, %Y%
    Menu, TestMenu, DeleteAll
}

; ========== Toolbar ==========
; http://www.autohotkey.com/board/topic/94750-class-toolbar-create-and-modify

DefineToolbar:
ILA := IL_Create(3, 2)
IL_Add(ILA, "shell32.dll", 260)
IL_Add(ILA, "shell32.dll", 135)
IL_Add(ILA, "shell32.dll", 261)
IL_Add(ILA, "shell32.dll", 72)

TB := New Toolbar(hToolbar)
TB.SetImageList(ILA)
TB.Add("", "Cut=Cut:1", "Copy=Copy:2", "Paste=Paste:3", "Test=Run Tests on Band 2:4")
TB.SetMaxTextRows(0)
TB.SetExStyle(0x10)
OnMessage(0x111, "TB_Messages")
return

TB_Messages(wParam, lParam)
{
    Global
    TB.OnMessage(wParam)
}

; =============================

ChangeFont:
Gui, Submit, NoHide
Gui, Font,, %FontFace%
GuiControl, Font, %hTextEdit%
return

Save:
Layout := RB.GetLayout()
return

Load:
RB.SetLayout(Layout)
return

Test:
RB.ModifyBand(2, "Text", "Select:")
RB.ModifyBand(2, "Image", 2)
RB.MaximizeBand(2, True)
; RB.MinimizeBand(2)
RB.GetBand(2, ID, Text, Size, Image, Background, Style)
GuiControl,, %hTextEdit%, % "Band 2 Info:"
                    .     "`n`tID: " ID
                    .     "`n`tText: " Text
                    .     "`n`tSize: " Size
                    .     "`n`tIcon: " Image
                    .     "`n`thBitmap: " Background
                    .     "`n`tStyle: " Style
                    .     "`n`nRebar Info:"
                    .     "`n`tBands: " RB.GetBandCount()
                    .     "`n`tRows: " RB.GetRowCount()
                    .     "`n`tBar Height: " RB.GetBarHeight()
                    .     "`n`tRow Height: " RB.GetRowHeight(2)
return

Cut:
GuiControl, Focus, %hTextEdit%
ControlSend,, {Control Down}{x}{Control Up}, ahk_id %hTextEdit%
return

Copy:
GuiControl, Focus, %hTextEdit%
ControlSend,, {Control Down}{c}{Control Up}, ahk_id %hTextEdit%
return

Paste:
GuiControl, Focus, %hTextEdit%
ControlSend,, {Control Down}{v}{Control Up}, ahk_id %hTextEdit%
return

GuiClose:
ExitApp
return

GuiSize:
RB.ShowBand(1) ; Updates band sizes when gui is resized.
return
