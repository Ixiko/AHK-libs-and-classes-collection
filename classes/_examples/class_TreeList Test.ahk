; TreeList Test

#NoEnv
#SingleInstance Force
SetBatchLines -1

#Include TreeList.ahk

Menu Tray, Icon, shell32.dll, 42

Gui +Resize +hWndhMainWnd
Gui Font, s9, Segoe UI
Gui Color, White

Gui Add, Button, x8 y8   w100 h23 gAddRoot, Add Root
Gui Add, Button, x8 y38  w100 h23 gAddChild, Add Child
Gui Add, Button, x8 y68  w100 h23 gGetText, Get Text
Gui Add, Button, x8 y98  w100 h23 gChangeItem, Change Item
Gui Add, Button, x8 y128 w100 h23 gSelectParent, Select Parent
Gui Add, Button, x8 y158 w100 h23 gSelectChild, Select Child
Gui Add, Button, x8 y188 w100 h23 gSelectNext, Select Next
Gui Add, Button, x8 y218 w100 h23 gExpand, Expand
Gui Add, Button, x8 y248 w100 h23 gCollapse, Collapse
Gui Add, Button, x8 y278 w100 h23 gToggleIcons, Toggle Icons
Gui Add, Button, x8 y308 w100 h23 gToggleGrid, Toggle Grid
Gui Add, Button, x8 y338 w100 h23 gDelete, Delete
Gui Add, Button, x8 y368 w100 h23 gDeleteAll, Delete All
Gui Add, Button, x8 y398 w100 h23 gReloadItems, Reload

; TreeList ImageList
Global ImageListID := IL_Create(12)
Loop 10 {
    IL_Add(ImageListID, "shell32.dll", A_Index)
}
IL_Add(ImageListID, "shell32.dll", 70)
IL_Add(ImageListID, "shell32.dll", 71)

; Create the TreeList
Global TL := New TreeList(hMainWnd, DPIScale(117), DPIScale(8), DPIScale(510), DPIScale(413))

TL.SetImageList(ImageListID)

; Add columns (mandatory)
TL.AddColumn("Column 1", DPIScale(289))
TL.AddColumn("Column 2", DPIScale(95))
TL.AddColumn("Column 3", DPIScale(123))

LoadItems()

TL.SetEventHandler("OnTreeList")

Gui Add, StatusBar
SB_SetParts(120, 80, 80)

Gui Show, w635 h453, TreeList Test
Return

GuiSize:
    If (A_EventInfo == 1) {
        Return
    }

    ControlMove,,,, % DPIScale(A_GuiWidth - 125), % DPIScale(A_GuiHeight - 40), % "ahk_id" . TL.hWnd
    ControlMove,,,, % DPIScale(A_GuiWidth - 125), % DPIScale(A_GuiHeight - 40), % "ahk_id" . TL.hLV
Return

GuiEscape:
GuiClose:
    Gui Destroy
    DllCall("FreeLibrary", "Ptr", TL.hMod)
    ExitApp

; Default items
LoadItems() {
    DateTime := GetDateTime()

    RootID1 := TL.Add(0, "4", "Files", "<DIR>", DateTime)
    TL.Add(RootID1, "12", "Commands.txt", "5 KB", DateTime)
    TL.Add(RootID1, "2", "Database.xml", "7 MB", DateTime)

    RootID2 := TL.Add(0, "4", "Settings", "<DIR>", DateTime)
    TL.Add(RootID2, "11", "Settings.ini", "1 KB", DateTime)
    TL.Add(RootID2, "2", "Config.xml", "2 KB", DateTime)

    TL.Expand(RootID1)
    TL.Expand(RootID2)
    TL.Select(RootID1)
}

GetDateTime() {
    FormatTime DateTime, D1
    DateTime := RegExReplace(DateTime, "(.*)\s(.*)", "$2 $1")
    Return DateTime
}

AddRoot() {
    Folder := GetRandomName()
    DateTime := GetDateTime()
    ItemID := TL.Add(0, "4", Folder, "<DIR>", DateTime)
    TL.Select(ItemID)
}

AddChild() {
    Filename := GetRandomName() . ".EXT"
    DateTime := GetDateTime()

    ParentID := TL.GetSelection()
    Size := TL.GetText(ParentID, 2)
    If (Size != "<DIR>") {
        TL.SetIcon(ParentID, 4)
        Name := TL.GetText(ParentID, 1)
        Name := SubStr(Name, 1, InStr(Name, ".") - 1)
        TL.SetText(ParentID, 1, Name)
        TL.SetText(ParentID, 2, "<DIR>")
    }

    ItemId := TL.Add(ParentID, "1", Filename, "1 KB", DateTime)
    TL.Expand(ParentID)
    TL.Select(ItemID)
}

GetText() {
    Col1 := TL.GetText(TL.GetSelection(), 1)
    Col2 := TL.GetText(TL.GetSelection(), 2)
    Col3 := TL.GetText(TL.GetSelection(), 3)

    Gui +OwnDialogs
    MsgBox 0x40, TreeList, % "Column 1:  " . Col1 . "`nColumn 2:  " . Col2 . "`nColumn 3:  " Col3
}

ChangeItem() {
    ItemID := TL.GetSelection()
    Size := TL.GetText(ItemID, 2)
    Name := GetRandomName()
    If (Size != "<DIR>") {
        Name .= ".EXT"
        TL.SetIcon(ItemID, 0)
    }

    TL.SetText(ItemID, 1, Name)
    TL.SetText(ItemID, 3, GetDateTime())
}

SelectParent() {
    TL.Select(TL.GetParent(TL.GetSelection()))
}

SelectChild() {
    TL.Select(TL.GetChild(TL.GetSelection()))
}

SelectNext() {
    TL.Select(TL.GetNext(TL.GetSelection()))
}

Expand() {
    TL.Expand(TL.GetSelection())
}

Collapse() {
    TL.Collapse(TL.GetSelection())
}

ToggleIcons() {
    If (TL.GetImageList()) {
        TL.SetImageList(0)
    } Else {
        TL.SetImageList(ImageListID)
    }
}

ToggleGrid() {
    SendMessage 0x1037,,,, % "ahk_id " . TL.hLV ; LVM_GETEXTENDEDLISTVIEWSTYLE
    ExtStyle := ErrorLevel & 1 ? 0 : 1
    SendMessage 0x1036, 1, %ExtStyle%,, % "ahk_id " . TL.hLV ; LVM_SETEXTENDEDLISTVIEWSTYLE
}

Delete() {
    TL.Delete(TL.GetSelection())
}

DeleteAll() {
    TL.Delete()
}

ReloadItems() {
    DeleteAll()
    DeleteAll() ; ?
    LoadItems()
}

GetRandomName() {
    String := ""
    Loop 8 {
        Random Num, 65, 90
        String .= Chr(Num)
    }
    Return String
}

OnTreeList(hWnd, Event, Row, Col, Key) {
    If (Event == "Click") {
        SB_SetText(" ID: " . TL.GetSelection())
        SB_SetText("Row: " . Row, 2)
        SB_SetText("Column: " . Col, 3)
    }
    Else If (Event == "RightClick") {
        Menu ContextMenu, Add, Get Text, GetText
        Menu ContextMenu, Show
    }
    Else If (Event == "DoubleClick") {
        GetText()
    }
}

DPIScale(x) {
    Return (x * A_ScreenDPI) // 96
}
