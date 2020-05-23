#NoEnv
#SingleInstance, Force
SetBatchLines, -1
Process, Priority,, High
#Include %A_ScriptDir%\..\Class_Toolbar.ahk

; Icons from Win7 (change them for other OS's).
; Create 2 Default ImageLists for the first Toolbar (small and large).
Loop, 2
{
    ILA%A_Index% := IL_Create(11, 2, A_Index-1)
    IL_Add(ILA%A_Index%, "imageres.dll", 3)  ; 1: New
    IL_Add(ILA%A_Index%, "shell32.dll", 46)  ; 2: Open
    IL_Add(ILA%A_Index%, "shell32.dll", 259) ; 3: Save
    IL_Add(ILA%A_Index%, "shell32.dll", 260) ; 4: Cut
    IL_Add(ILA%A_Index%, "shell32.dll", 135) ; 5: Copy
    IL_Add(ILA%A_Index%, "shell32.dll", 261) ; 6: Paste
    IL_Add(ILA%A_Index%, "shell32.dll", 304) ; 7: Toggle Icons
    IL_Add(ILA%A_Index%, "shell32.dll", 300) ; 8: Toggle View
    IL_Add(ILA%A_Index%, "shell32.dll", 44)  ; 9: Insert button
    IL_Add(ILA%A_Index%, "shell32.dll", 132) ; 10: Delete button
    IL_Add(ILA%A_Index%, "shell32.dll", 1)   ; 11: Empty Icon
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
Loop, 5
    IL_Add(ILBP, "explorer.exe", 8)

; Presets menu:
Loop, 5
{
    Menu, SaveMenu, Add, Slot %A_Index%, SaveLayout
    Menu, LoadMenu, Add, Slot %A_Index%, LoadLayout
    Menu, LoadMenu, Disable, Slot %A_Index%
}
Menu, PresetsMenu, Add, Save, :SaveMenu
Menu, PresetsMenu, Add, Load, :LoadMenu
Menu, PresetsMenu, Add, Clear, ClearPresets
Menu, Presets, Add, Presets, :PresetsMenu
Menu, Customize, Add, Customize Upper, Customize1
Menu, Customize, Add, Customize Side, Customize2
Menu, Presets, Add, Customize , :Customize
Gui, Menu, Presets

Gui, +hwndTestGui
Gui, Add, Text, x2 y60, Tests:
Gui, Add, Button, Section x+10 yp gTests, Enable
Gui, Add, Button, x+5 yp gTests, Check
Gui, Add, Button, x+5 yp gTests, Mark
Gui, Add, Button, x+5 yp gTests, Press
Gui, Add, Button, x+5 yp gTests, Hide
Gui, Add, Button, x+5 yp gChangeImage, Change Icon
Gui, Add, Button, x+5 yp gChangeText, Change Caption
Gui, Add, Button, x+5 yp gMoveB vMoveB, Move
Gui, Add, Text, x+5 yp+5, (SHIFT + Drag buttons or Double-Click a toolbar to customize it)
Gui, Add, Button, xs y+5 gHotItem, HotItem
Gui, Add, Button, x+5 yp gChangeSize, Change Size
Gui, Add, Button, x+5 yp gIndent, Indent
Gui, Add, Button, x+5 yp gGap, Gap
Gui, Add, Button, x+5 yp gPadding, Padding
Gui, Add, Button, x+5 yp gGetInfo, Get Info
Gui, Add, Button, x+5 yp gGetButtonInfo, Get Button Info
Gui, Add, Text, x+5 yp+5, (Click the Save button to save toolbars layouts and presets)
Gui, Add, Edit, x2 y+10 w750 r36 hwndTextEdit

; TBSTYLE_FLAT     := 0x0800 Required to show separators as bars.
; TBSTYLE_TOOLTIPS := 0x0100 Required to show Tooltips.
; CCS_ADJUSTABLE   := 0x0020 Required to allow customization by double-click and shift-drag.
; CCS_NODIVIDER    := 0x0040 Removes the separator line above the toolbar.
Gui, Add, Custom, ClassToolbarWindow32 hwndTopBar vTop 0x0800 0x0100 0x0020 0x0040
; CCS_VERT          := 0x0080 Required for correct height of vertical toolbars.
; CCS_NOPARENTALIGN := 0x0008 Required tow allow positioning of toolbar.
; CCS_NORESIZE      := 0x0004 Required tow allow resizing of toolbar.
Gui, Add, Custom, ClassToolbarWindow32 hwndSideBar x760 y110 w50 h400 vSide 0x0800 0x0100 0x0020 0x0080 0x0040 0x0008 0x0004

; Check for saved button positions and presets in INI file.
IniRead, TopButtons, tbPosInfo.ini, ToolbarButtons, TopButtons
IniRead, SideButtons, tbPosInfo.ini, ToolbarButtons, SideButtons
Loop, 5
    IniRead, Preset%A_Index%, tbPosInfo.ini, ToolbarPresets, TopPresets%A_Index%

; Methods should be called after Gui, Show or they might fail eventually.
Gui, Show, w800 h600, [Class] Toolbar - Demostration Script

; Initialize Toolbars.
TB1 := New Toolbar(TopBar)

; Set ImageLists.
TB1.SetImageList(ILA1)

BtnsArray := []

; Define default buttons.
DefArray1 := [ "New=New:1", "Open=Open:2(Enabled Dropdown)", "Save=Save:3(Enabled Dropdown)"
        , "", "Cut=Cut:4", "Copy=Copy:5", "Paste=Paste:6"
        , "", "ToggleIcons=Icons:7", "ToggleStyle=View:8"
        , "", "Insert=Insert:9", "Delete=Delete:10" ]
If (TopButtons = "ERROR")   ; If no INI file found, use default.
    BtnsArray := DefArray1 
Else
    Loop, Parse, TopButtons, `,, %A_Space%
        BtnsArray[A_Index] := A_LoopField

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
Loop, 5
{
    If (Preset%A_Index% <> "ERROR") && (Preset%A_Index% <> "")
    {
        PresetArray := []
        Loop, Parse, Preset%A_Index%, `,, %A_Space%
            PresetArray[A_Index] := A_LoopField
        TB1.Presets.Import(A_Index, "", PresetArray*)
        Menu, LoadMenu, Enable, Slot %A_Index%
    }
}

TB2 := New Toolbar(SideBar)

; Side toolbar will show different buttons when hovered (hot) or pressed.
TB2.SetImageList(ILB, ILBH, ILBP)

BtnsArray := []

; The Cmd label has a "-" and will be hidden on start, but available in customize dialog.
DefArray2 := [ "Explorer:1", "Notepad:2", "Calc:3", "", "msPaint:4", "Cmd:5" ]

If (SideButtons = "ERROR")
    BtnsArray := DefArray2
Else
    Loop, Parse, SideButtons, `,, %A_Space%
        BtnsArray[A_Index] := A_LoopField

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
TB_Messages(wParam, lParam)
{
    Global ; Function (or at least the Handles) must be global.
    TB1.OnMessage(wParam) ; Handles messages from TB1
    TB2.OnMessage(wParam) ; Handles messages from TB2
}

; This function will receive the notifications.
TB_Notify(wParam, lParam)
{
    Global TB1, TB2 ; Function (or at least the Handles) must be global.
    ReturnCode := TB1.OnNotify(lParam, MX, MY, Label, ID) ; Handles notifications.
    If (ReturnCode = "") ; Check if previous return was blank to know if you should call OnNotify for the next.
        ReturnCode := TB2.OnNotify(lParam)                 ; The return value contains the required
    If (Label)                                             ; return for the call, so it must be
        ShowMenu(Label, MX, MY)                            ; passed as return parameter.
    return ReturnCode
}

; This is a method to show a menu using the values returned from OnNotify method.
; You can also use GoSub if the function or the variables used are global.
ShowMenu(Menu, X, Y)
{
    Menu, TestMenu, Add, %Menu% As, %Menu%
    Menu, TestMenu, Show, %X%, %Y%
    Menu, TestMenu, DeleteAll
}

#If WinActive("ahk_id " TestGui)

SaveLayout:
Preset := TB1.Export(True)
If (TB1.Presets.Save(A_ThisMenuItemPos, Preset))
{
    Menu, LoadMenu, Enable, Slot %A_ThisMenuItemPos%
    GuiControl,, %TextEdit%, Upper Toolbar preset saved to Slot %A_ThisMenuItemPos%
}
return

LoadLayout:
TB1.Presets.Load(A_ThisMenuItemPos)
return

ClearPresets:
Loop, 5
{
    TB1.Presets.Delete(A_Index)
    Menu, LoadMenu, Disable, Slot %A_Index%
}
return

Tests:
OnOff := !OnOff
TB1.ModifyButton(12, A_GuiControl, OnOff)
return

ChangeImage:
ImageN++
If (ImageN > 11)
    ImageN := 1
TB1.ModifyButtonInfo(12, "Image", ImageN)
return

ChangeText:
Loop, % TB1.GetCount()
    TB1.ModifyButtonInfo(A_Index, "Text", "Label " A_Index)
return

ChangeSize:
nSize := (n := !n) ? 40 : 20
TB1.SetButtonSize(nSize, nSize)
TB1.AutoSize()
return

HotItem:
hItem++
If (hItem > TB1.GetCount())
    hItem := 1
TB1.SetHotItem(hItem)
return

Indent:
TB1.SetIndent((tInd := !tInd) ? 50 : 0)
return

Gap:
TB1.SetListGap((tGap := !tGap) ? 10 : 0)
return

Padding:
TB1.SetPadding(50, 50)
return

MoveB:
TB1.MoveButton(12, 13)
return

F5::
GetInfo:
TB1.Get(hItemA, TxRowsA, RowsA, WidthA, HeightA, StyleA, ExStyleA)
TB2.Get(hItemB, TxRowsB, RowsB, WidthB, HeightB, StyleB, ExStyleB)
GuiControl,, %TextEdit%, % "Upper toolbar info:"
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
return

F6::
GetButtonInfo:
AllBtnInfo := "Upper Toolbar:`n"
Loop, % TB1.GetCount()
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
Loop, % TB2.GetCount()
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
GuiControl,, %TextEdit%, % AllBtnInfo
return

New:
GuiControl,, %TextEdit%
Gui, Show,, [Class] Toolbar - Demostration Script
return

Open:
Gui, +OwnDialogs
FileSelectFile, TextFile, 3
If !TextFile
    return
FileRead, InText, %TextFile%
GuiControl,, %TextEdit%, %InText%
Gui, Show,, [Class] Toolbar - Demostration Script
return

Save:
; Save toolbars current buttons.
Buttons1 := TB1.Export(), Buttons2 := TB2.Export()
IniWrite, %Buttons1%, tbPosInfo.ini, ToolbarButtons, TopButtons
IniWrite, %Buttons2%, tbPosInfo.ini, ToolbarButtons, SideButtons
Loop, 5  ; Save Upper toolbar presets.
    IniWrite, % TB1.Presets.Export(A_Index), tbPosInfo.ini, ToolbarPresets, TopPresets%A_Index%
Gui, Show,, Saved Toolbars layouts and presets to "%A_ScriptDir%\tbPosInfo.ini"
return

Cut:
GuiControl, Focus, %TextEdit%
ControlSend,, {Control Down}{x}{Control Up}, ahk_id %TextEdit%
return

Copy:
GuiControl, Focus, %TextEdit%
ControlSend,, {Control Down}{c}{Control Up}, ahk_id %TextEdit%
return

Paste:
GuiControl, Focus, %TextEdit%
ControlSend,, {Control Down}{v}{Control Up}, ahk_id %TextEdit%
return

ToggleIcons:
View := "ILA" ((LargeView := !LargeView) ? 2 : 1)
TB1.SetImageList(%View%)
TB1.AutoSize()
return

ToggleStyle:
TB1.ToggleStyle("List")
TB1.SetMaxTextRows(isList := !isList ? 1 : 0)
TB1.AutoSize()
return

Insert:
TB1.Insert(14, "", "Null=Null:11")
return

Delete:
TB1.Delete(14)
return

Null:
Gui, +OwnDialogs
MsgBox, This button does nothing!
return

Explorer:
Notepad:
Calc:
msPaint:
Cmd:
Run, %A_ThisLabel%
return

Customize1:
TB1.Customize()
return

Customize2:
TB2.Customize()
return

GuiClose:
ExitApp
