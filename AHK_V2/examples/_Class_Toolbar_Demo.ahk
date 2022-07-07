; AHK v2
ProcessSetPriority "High"
#Include _Class_Toolbar.ahk
#Include TheArkive_Debug.ahk

; Icons from Win7 (change them for other OS's).
; Create 2 Default ImageLists for the first Toolbar (small and large).
Global IL := []

Loop 2
{
    ; ILA%A_Index% := IL_Create(11, 2, A_Index-1)
	IL.InsertAt(A_Index,IL_Create(11, 2, A_Index-1))
    IL_Add(IL[A_Index], "imageres.dll", 3)  ; 1: New      ; ILA%A_Index%
    IL_Add(IL[A_Index], "shell32.dll", 46)  ; 2: Open
    IL_Add(IL[A_Index], "shell32.dll", 259) ; 3: Save
    IL_Add(IL[A_Index], "shell32.dll", 260) ; 4: Cut
    IL_Add(IL[A_Index], "shell32.dll", 135) ; 5: Copy
    IL_Add(IL[A_Index], "shell32.dll", 261) ; 6: Paste
    IL_Add(IL[A_Index], "shell32.dll", 304) ; 7: Toggle Icons
    IL_Add(IL[A_Index], "shell32.dll", 300) ; 8: Toggle View
    IL_Add(IL[A_Index], "shell32.dll", 44)  ; 9: Insert button
    IL_Add(IL[A_Index], "shell32.dll", 132) ; 10: Delete button
    IL_Add(IL[A_Index], "shell32.dll", 1)   ; 11: Empty Icon
}

; Create Default ImageList for the second Toolbar with large icons.
ILB := IL_Create(5, 2, True)
IL_Add(ILB, "explorer.exe", 1)  ; 1: Windows Explorer
IL_Add(ILB, "notepad.exe", 1)   ; 2: Notepad
IL_Add(ILB, "calc.exe", 1)      ; 3: Calculator
IL_Add(ILB, "mspaint.exe", 1)   ; 4: Paint
IL_Add(ILB, "cmd.exe", 1)       ; 5: Command Prompt

; Create Hot ImageList for the second Toolbar with large icons.
ILBH := IL_Create(5, 2, True)
IL_Add(ILBH, "explorer.exe", 2)  ; 1: Windows Explorer
IL_Add(ILBH, "explorer.exe", 4)  ; 2: Notepad
IL_Add(ILBH, "explorer.exe", 11) ; 3: Calculator
IL_Add(ILBH, "mspaint.exe", 2)   ; 4: Paint
IL_Add(ILBH, "cmd.exe", 1)       ; 5: Command Prompt

; Create Pressed ImageList for the second Toolbar with large icons.
ILBP := IL_Create(5, 2, True)
Loop 5
    IL_Add(ILBP, "explorer.exe", 8)

; Presets menu:
Global g, TestGui, TextEdit, TopBar, SideBar, TB1, TB2, loadMenu, saveMenu
Global LargeView := 0, IsList := 0, ImageN := 0, OnOff := 0, hItem := 0, n := 0, tInd := 0, tGap := 0
; Global saveMenu, loadMenu, presetsMenu, presets, customize
saveMenu := Menu.New()
loadMenu := Menu.New()
presetsMenu := Menu.New()
presets := MenuBar.New()
customize := Menu.New()
Loop 5 {
	saveMenu.Add("Slot " A_Index, "SaveLayout")
	loadMenu.Add("Slot " A_Index, "LoadLayout")
	loadMenu.Disable("Slot " A_Index)
	
    ; Menu, SaveMenu, Add, Slot %A_Index%, SaveLayout
    ; Menu, LoadMenu, Add, Slot %A_Index%, LoadLayout
    ; Menu, LoadMenu, Disable, Slot %A_Index%
}

presetsMenu.Add("Save",saveMenu)
presetsMenu.Add("Load",loadMenu)
presetsMenu.Add("Clear","ClearPresets")
presets.Add("Presets",presetsMenu)

customize.Add("Customize Upper","Customize1")
customize.Add("Customize Side","Customize2")
presets.Add("Customize",customize)

; Menu, PresetsMenu, Add, Save, :SaveMenu
; Menu, PresetsMenu, Add, Load, :LoadMenu
; Menu, PresetsMenu, Add, Clear, ClearPresets
; Menu, Presets, Add, Presets, :PresetsMenu
; Menu, Customize, Add, Customize Upper, Customize1
; Menu, Customize, Add, Customize Side, Customize2
; Menu, Presets, Add, Customize , :Customize

g := Gui.New("+OwnDialogs","[Class] Toolbar - Demostration Script")
g.OnEvent("close","GuiClose")
g.MenuBar := presets
TestGui := g.hwnd
g.Add("Text","x2 y60","Tests:")
g.Add("Button","Section x+10 yp","Enable").OnEvent("click","Tests")
g.Add("Button","x+5 yp","Check").OnEvent("click","Tests")
g.Add("Button","x+5 yp","Mark").OnEvent("click","Tests")
g.Add("Button","x+5 yp","Press").OnEvent("click","Tests")
g.Add("Button","x+5 yp","Hide").OnEvent("click","Tests")
g.Add("Button","x+5 yp","Change Icon").OnEvent("click","ChangeImage")
g.Add("Button","x+5 yp","Change Caption").OnEvent("click","ChangeText")
g.Add("Button","x+5 yp vMoveB","Move").OnEvent("click","MoveB")

g.Add("Text","x+5 yp+5","(SHIFT + Drag buttons or Double-Click a toolbar to customize it)")
g.Add("Button","xs y+5","HotItem").OnEvent("click","HotItem")
g.Add("Button","x+5 yp","Change Size").OnEvent("click","ChangeSize")
g.Add("Button","x+5 yp","Indent").OnEvent("click","Indent")
g.Add("Button","x+5 yp","Gap").OnEvent("click","Gap")
g.Add("Button","x+5 yp","Padding").OnEvent("click","Padding")
g.Add("Button","x+5 yp","Get Info").OnEvent("click","GetInfo")
g.Add("Button","x+5 yp","Get Button Info").OnEvent("click","GetButtonInfo")
g.Add("Text","x+5 yp+5","(Click the Save button to save toolbars layouts and presets)")
ctl := g.Add("Edit","x2 y+10 w750 r36 vTextEdit")
TextEdit := ctl.hwnd

; Gui, Menu, Presets

; Gui, +hwndTestGui
; Gui, Add, Text, x2 y60, Tests:
; Gui, Add, Button, Section x+10 yp gTests, Enable
; Gui, Add, Button, x+5 yp gTests, Check
; Gui, Add, Button, x+5 yp gTests, Mark
; Gui, Add, Button, x+5 yp gTests, Press
; Gui, Add, Button, x+5 yp gTests, Hide
; Gui, Add, Button, x+5 yp gChangeImage, Change Icon
; Gui, Add, Button, x+5 yp gChangeText, Change Caption
; Gui, Add, Button, x+5 yp gMoveB vMoveB, Move
; Gui, Add, Text, x+5 yp+5, (SHIFT + Drag buttons or Double-Click a toolbar to customize it)
; Gui, Add, Button, xs y+5 gHotItem, HotItem
; Gui, Add, Button, x+5 yp gChangeSize, Change Size
; Gui, Add, Button, x+5 yp gIndent, Indent
; Gui, Add, Button, x+5 yp gGap, Gap
; Gui, Add, Button, x+5 yp gPadding, Padding
; Gui, Add, Button, x+5 yp gGetInfo, Get Info
; Gui, Add, Button, x+5 yp gGetButtonInfo, Get Button Info
; Gui, Add, Text, x+5 yp+5, (Click the Save button to save toolbars layouts and presets)
; Gui, Add, Edit, x2 y+10 w750 r36 hwndTextEdit

; TBSTYLE_FLAT     := 0x0800 Required to show separators as bars.
; TBSTYLE_TOOLTIPS := 0x0100 Required to show Tooltips.
; CCS_ADJUSTABLE   := 0x0020 Required to allow customization by double-click and shift-drag.
; CCS_NODIVIDER    := 0x0040 Removes the separator line above the toolbar.

ctl := g.Add("Custom","ClassToolbarWindow32 vTop 0x0800 0x0100 0x0020 0x0040")
TopBar := ctl.hwnd

; Gui, Add, Custom, ClassToolbarWindow32 hwndTopBar vTop 0x0800 0x0100 0x0020 0x0040


; CCS_VERT          := 0x0080 Required for correct height of vertical toolbars.
; CCS_NOPARENTALIGN := 0x0008 Required tow allow positioning of toolbar.
; CCS_NORESIZE      := 0x0004 Required tow allow resizing of toolbar.

ctl := g.Add("Custom","ClassToolbarWindow32 x760 y110 w50 h400 vSide 0x0800 0x0100 0x0020 0x0080 0x0040 0x0008 0x0004")
SideBar := ctl.hwnd
; Gui, Add, Custom, ClassToolbarWindow32 hwndSideBar x760 y110 w50 h400 vSide 0x0800 0x0100 0x0020 0x0080 0x0040 0x0008 0x0004

; Check for saved button positions and presets in INI file.
TopButtons := "", SideButtons := ""

TopButtons := IniRead("tbPosInfo.ini", "ToolbarButtons", "TopButtons", "ERROR")
SideButtons := IniRead("tbPosInfo.ini", "ToolbarButtons", "SideButtons", "ERROR")
Loop 5
	Preset%A_Index% := IniRead("tbPosInfo.ini", "ToolbarPresets", "TopPresets" A_Index, "ERROR")
; Methods should be called after Gui, Show or they might fail eventually.

g.Show("w800 h600")

; Gui, Show, w800 h600, [Class] Toolbar - Demostration Script

; Initialize Toolbars.
TB1 := Toolbar.New(TopBar)

; Set ImageLists.
TB1.SetImageList(IL[1])

BtnsArray := []

; Define default buttons.
DefArray1 := [ "New=New:1", "Open=Open:2(Enabled Dropdown)", "Save=Save:3(Enabled Dropdown)"
        , "", "Cut=Cut:4", "Copy=Copy:5", "Paste=Paste:6"
        , "", "ToggleIcons=Icons:7", "ToggleStyle=View:8"
        , "", "Insert=Insert:9", "Delete=Delete:10" ]
If (TopButtons = "ERROR")   ; If no INI file found, use default.
    BtnsArray := DefArray1 
Else
    Loop Parse TopButtons, Chr(44), A_Space
        BtnsArray.InsertAt(A_Index,A_LoopField)

; Add buttons.
TB1.Add("", BtnsArray*) ; The * passes the whole array as a variadic parameter.

; Removes text labels and show them as tooltips.
TB1.SetMaxTextRows(0)

; Draw arrows in Dropdown style buttons.
TB1.SetExStyle("DrawDDArrows")

; Set default buttons.
; If this is not done reset would set the layout loaded from the INI.
TB1.SetDefault("", DefArray1*)

; Load presets.
Loop 5 {
	If (!IsSet(Preset%A_Index%))
		Continue
    Else If (Preset%A_Index% != "ERROR") && (Preset%A_Index% != "") {
        PresetArray := []
        Loop Parse Preset%A_Index%, Chr(44), A_Space
            PresetArray.InsertAt(A_Index,A_LoopField)
        ; TB1.Presets.Import(A_Index, "", PresetArray*)
		TB1.pImport(A_Index, "", PresetArray*)
		loadMenu.Enable("Slot " A_Index)
        ; Menu, LoadMenu, Enable, Slot %A_Index%
    }
}

TB2 := Toolbar.New(SideBar)

; Side toolbar will show different buttons when hovered (hot) or pressed.
TB2.SetImageList(ILB, ILBH, ILBP)

BtnsArray := []

; The Cmd label has a "-" and will be hidden on start, but available in customize dialog.
DefArray2 := [ "Explorer:1", "Notepad:2", "Calc:3", "", "msPaint:4", "Cmd:5" ]

If (SideButtons = "ERROR" Or SideButtons = "")
    BtnsArray := DefArray2
Else
    Loop Parse SideButtons, Chr(44), A_Space
        BtnsArray.InsertAt(A_Index,A_LoopField)

TB2.Add("Enabled Wrap", BtnsArray*)

TB2.SetDefault("Enabled Wrap", DefArray2*)

; Set a function to monitor the Toolbar's messages.
WM_COMMAND := 0x111
OnMessage(WM_COMMAND, "TB_Messages")

; Set a function to monitor notifications.
WM_NOTIFY := 0x4E
OnMessage(WM_NOTIFY, "TB_Notify")

return

; This function will receive the messages sent by both Toolbar's buttons.
TB_Messages(wParam, lParam, *)
{
    Global ; Function (or at least the Handles) must be global.
    TB1.OnMessage(wParam) ; Handles messages from TB1
    TB2.OnMessage(wParam) ; Handles messages from TB2
}

; This function will receive the notifications.
TB_Notify(wParam, lParam, *)
{
	Label := ""
    Global TB1, TB2 ; Function (or at least the Handles) must be global.
    ReturnCode := TB1.OnNotify(lParam, MX, MY, Label:="", ID:=0) ; Handles notifications.
    If (ReturnCode = "") ; Check if previous return was blank to know if you should call OnNotify for the next.
        ReturnCode := TB2.OnNotify(lParam)                 ; The return value contains the required
    If (Label)                                             ; return for the call, so it must be
        ShowMenu(Label, MX, MY)                            ; passed as return parameter.
    return ReturnCode
}

; This is a method to show a menu using the values returned from OnNotify method.
; You can also use GoSub if the function or the variables used are global.
ShowMenu(MenuStuff, X, Y) {
	; Debug.Msg(menu)
	; m := MenuFromHwnd
	testMenu := Menu.New()
	testMenu.Add(MenuStuff " As",MenuStuff)
	testMenu.Show(X,Y)
	testMenu.Delete()
}

#HotIf WinActive("ahk_id " TestGui)

SaveLayout(ItemName, ItemPos, m) {
	Preset := TB1.Export(True)
	If (TB1.pSave(ItemPos, Preset)) { ; TB1.Presets.Save(ItemPos, Preset)
		loadMenu.Enable("Slot " ItemPos)
		g["TextEdit"].Value := "Upper Toolbar preset saved to Slot " ItemPos
	}
}

LoadLayout(ItemName, ItemPos, m) {
	TB1.pLoad(ItemPos) ; TB1.Presets.Load(ItemPos)
}

ClearPresets(ItemName, ItemPos, m) {
	Loop 5 {
		TB1.pDelete(A_Index)
		loadMenu.Disable("Slot " A_Index)
	}
}

Tests(ctl,info) {
	OnOff := !OnOff
	TB1.ModifyButton(12, ctl.Text, OnOff)
}

ChangeImage(ctl,info) {
	ImageN++
	If (ImageN > 11)
		ImageN := 1
	TB1.ModifyButtonInfo(12, "Image", ImageN)
}

ChangeText(ctl,info) {
	Loop TB1.GetCount()
		TB1.ModifyButtonInfo(A_Index, "Text", "Label " A_Index)
}

ChangeSize(ctl,info) {
	nSize := (n := !n) ? 40 : 20
	; n := !n ? 1 : 0
	
	TB1.SetButtonSize(nSize, nSize)
	TB1.AutoSize()
}

HotItem(ctl,info) {
	hItem++
	If (hItem > TB1.GetCount())
		hItem := 1
	TB1.SetHotItem(hItem)
}

Indent(ctl,info) {
	TB1.SetIndent((tInd := !tInd) ? 50 : 0)
}

Gap(ctl,info) {
	TB1.SetListGap((tGap := !tGap) ? 10 : 0)
	; Debug.Msg(tGap)
	; tGap := !tGap ? 1 : 0
}

Padding(ctl,info) {
	TB1.SetPadding(50, 50)
}

MoveB(ctl,info) {
	TB1.MoveButton(12, 13)
}

; F5::
GetInfo(ctl,info) {
	TB1.Get(hItemA, TxRowsA, RowsA, WidthA, HeightA, StyleA, ExStyleA)
	TB2.Get(hItemB, TxRowsB, RowsB, WidthB, HeightB, StyleB, ExStyleB)

	ctlText := "Upper toolbar info:"
			.  "`n`tButtons: " TB1.GetCount()
			.  "`n`tHotItem: " hItemA
			.  "`n`tText Rows: " TxRowsA
			.  "`n`tRows: " RowsA
			.  "`n`tButtons Size: " WidthA " x " HeightA
			.  "`n`tStyle: " StyleA
			.  "`n`tExStyle: " ExStyleA
			.  "`n`nSide toolbar info:"
			.  "`n`tButtons: " TB2.GetCount()
			.  "`n`tHotItem: " hItemB
			.  "`n`tText Rows: " TxRowsB
			.  "`n`tRows: " RowsB
			.  "`n`tButtons Size: " WidthB " x " HeightB
			.  "`n`tStyle: " StyleB
			.  "`n`tExStyle: " ExStyleB

	g["TextEdit"].Value := ctlText
}

; F6::
GetButtonInfo(ctl,info) {
	AllBtnInfo := "Upper Toolbar:`n"
	Loop TB1.GetCount()
	{
		TB1.GetButton(A_Index, IDA, TextA, StateA, StyleA, IconA, LabelA)
		AllBtnInfo .= "Button " A_Index " info:"
		.  "`n`tCommand ID: " IDA
		.  "`n`tText Caption: " TextA
		.  "`n`tState: " StateA
		.  "`n`tStyle: " StyleA
		.  "`n`tIcon Index: " IconA
		.  "`n`tLabel: " LabelA "`n`n"
	}
	AllBtnInfo .= "`nSide Toolbar:`n"
	Loop TB2.GetCount()
	{
		TB2.GetButton(A_Index, IDA, TextA, StateA, StyleA, IconA, LabelA)
		AllBtnInfo .= "Button " A_Index " info:"
		.  "`n`tCommand ID: " IDA
		.  "`n`tText Caption: " TextA
		.  "`n`tState: " StateA
		.  "`n`tStyle: " StyleA
		.  "`n`tIcon Index: " IconA
		.  "`n`tLabel: " LabelA "`n`n"
	}
	g["TextEdit"].Value := AllBtnInfo
}

New(*) {
	g["TextEdit"].Value := ""
	g.Show()
}

Open(*) {
	TextFile := FileSelect(3)
	If !TextFile
		return
	InText := FileRead(TextFile)
	
	g["TextEdit"].Value := InText
	g.Show()
}

Save(*) {
	; Save toolbars current buttons.
	Buttons1 := TB1.Export(), Buttons2 := TB2.Export()
	IniWrite Buttons1, "tbPosInfo.ini", "ToolbarButtons", "TopButtons"
	IniWrite Buttons2, "tbPosInfo.ini", "ToolbarButtons", "SideButtons"
	Loop 5  ; Save Upper toolbar presets.
		IniWrite TB1.pExport(A_Index), "tbPosInfo.ini", "ToolbarPresets", "TopPresets" A_Index
		; IniWrite TB1.Presets.Export(A_Index), "tbPosInfo.ini", "ToolbarPresets", "TopPresets" A_Index
	q := Chr(34)
	g.Title := "Saved Toolbars layouts and presets to " q A_ScriptDir "\tbPosInfo.ini" q
}

Cut(*) {
	g["TextEdit"].Focus()
	ControlSend "{Control Down}{x}{Control Up}", g["TextEdit"].hwnd
}

Copy(*) {
	g["TextEdit"].Focus()
	ControlSend "{Control Down}{c}{Control Up}", g["TextEdit"].hwnd
}

Paste(*) {
	g["TextEdit"].Focus()
	ControlSend "{Control Down}{v}{Control Up}", g["TextEdit"].hwnd
}

ToggleIcons(*) {
	; View := "ILA" ((LargeView := !LargeView) ? 2 : 1)
	If (!LargeView)
		View := IL[2], LargeView := 1 ; LargeView is now global for this toggle
	Else
		View := IL[1], LargeView := 0
	TB1.SetImageList(View)
	TB1.AutoSize()
}

ToggleStyle(*) {
	TB1.ToggleStyle("List")
	TB1.SetMaxTextRows(isList := !isList ? 1 : 0)
	TB1.AutoSize()
}

Insert(*) {
	TB1.Insert(14, "", "Null=Null:11")
}

Delete(*) {
	TB1.Delete(14)
}

Null(*) {
	; Gui, +OwnDialogs
	MsgBox("This button does nothing!")
}

Explorer(*) {
	; Notepad:
	; Calc:
	; msPaint:
	; Cmd:
	Run A_ThisFunc
}

Notepad(*) {
	Run A_ThisFunc 
}

Calc(*) {
	Run A_ThisFunc
}

msPaint(*) {
	Run A_ThisFunc
}

Cmd(*) {
	Run A_ThisFunc
}

Customize1(ItemName, ItemPos, m) {
	TB1.Customize()
}

Customize2(ItemName, ItemPos, m) {
	TB2.Customize()
}

GuiClose(*) {
	ExitApp
}