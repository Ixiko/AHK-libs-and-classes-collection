; ================================================================================================================================
; This is a rewrite of jethrow's "Accessible Info Viewer" published at
; autohotkey.com/board/topic/77888-accessible-info-viewer-alpha-release-2012-09-20/
; to be used with the AccObj library. Only mandatory basic features have been implemented.
; ================================================================================================================================
#NoEnv

SetBatchLines, -1
OnExit, CleanUpOnExit
; ================================================================================================================================
; Settings
; ================================================================================================================================
; Hotkey to start looking for accessible info
AccHotkey := "^+a"
; AccFrame color
FrameColor := "Yellow"
; AccFrame width
FrameWidth := 2
; Delay to hide the AccFrame
HideFrameDelay := -3000
; Width of the ListViews
LVW := 800
; ================================================================================================================================
; Initialization
AccControl := ""
AccObject := ""
AccObjRole := ""
AccObjPos := ""
AccObjPath := ""
AccWindow := ""
AccWinRole := ""
TreeShown := False
Hotkey, Esc, Off
; ================================================================================================================================
; GUI menues
Menu, File, Add, Quit, MainGuiClose
Menu, Action, Add, Get Parent`t(F1), GetParent
Menu, Action, Add, Get Path`t(F2), GetPath
Menu, Action, Add, Show Frame`t(F3), ShowFrame
Menu, MenuBar, Add, &File, :File
Menu, Menubar, Add, &Action, :Action
; ================================================================================================================================
; AccFrame GUI
AccFrame := New FrameGui(FrameColor, FrameWidth)
; ================================================================================================================================
; Main GUI
Gui, Main: New, +LastFound +HwndHMAIN +AlwaysOnTop
Gui, Menu, MenuBar
Gui, Margin, 10, 10
HCROSS := DllCall("LoadCursor", "Ptr", 0, "Ptr", 32515, "Ptr")
Gui, Add, Pic, xm gAccStart, HICON:%HCROSS%
Gui, Add, Text, xp yp wp hp BackGroundTrans Border gAccStart
Gui, Add, Text, x+10 yp, Click the cross-hair && move the mouse to get accessible info.`nPress <Esc> to stop.
; AHK window info
Gui, Add, Text, xm w%LVW%, AHK Window Info:
WinRows := ["Title", "Class", "Exe", "Pos"]
Rows := WinRows.Length()
Gui, Add, ListView, xm y+2 wp r%Rows% vWinLV -Hdr +Grid +LV0x4000 +hwndHLVW, 1|2
GuiControlGet, P1, Pos, WinLV
SetExplorerTheme(HLVW)
For Index, Row In WinRows
LV_Add("", Row)
; Acc control / window info
Gui, Add, Text, xm wp, Acc Control / Window Info:
CtlRows := ["Class", "ID", "Pos"]
Rows := CtlRows.Length()
Gui, Add, ListView, xm y+2 wp r%Rows% vCtlLV -Hdr +Grid +LV0x4000 +hwndHLVC, 1|2
SetExplorerTheme(HLVC)
For Index, Row In CtlRows
LV_Add("", Row)
; Accessible object info
Gui, Add, Text, xm wp, Accessible Info:
AccRows := ["ChildID", "Name", "Value", "Role", "State", "Location", "ChildCount", "Shortcut", "Action", "Description", "Help"]
Rows := AccRows.Length()
Gui, Add, ListView, xm y+2 wp r%Rows% vAccLV -Hdr +Grid +LV0x4000 +hwndHLVA, 1|2
SetExplorerTheme(HLVA)
For Index, Row In AccRows
LV_Add("", Row)
LV_ModifyCol(1, "AutoHdr")
LV_ModifyCol(2, "AutoHdr")
; Synchronize the ListViews grid lines
SendMessage, 0x101D, 0, 0, , ahk_id %HLVA% ; LVM_GETCOLUMNWIDTH
Col1W := ErrorLevel
SendMessage, 0x101E, 0, %Col1W%, , ahk_id %HLVW% ; LVM_SETCOLUMNWIDTH
SendMessage, 0x101E, 1, -2, , ahk_id %HLVW% ; LVM_SETCOLUMNWIDTH - LVSCW_AUTOSIZE_USEHEADER
SendMessage, 0x101E, 0, %Col1W%, , ahk_id %HLVC% ; LVM_SETCOLUMNWIDTH
SendMessage, 0x101E, 1, -2, , ahk_id %HLVC% ; LVM_SETCOLUMNWIDTH - LVSCW_AUTOSIZE_USEHEADER
; Object Path
Gui, Add, Text, xm wp, Object Path:
Gui, Add, Edit, xm y+2 wp vPathED																;removed - +ReadOnly - maybe you need a copy
GuiControlGet, P2, Pos, PathED
Gui, Show, AutoSize, AccObject Viewer
; ================================================================================================================================
; GUI related hotkeys
Hotkey, IfWinActive, ahk_id %HMAIN%
Hotkey, %AccHotkey%, AccStart
Hotkey, F1, GetParent
Hotkey, F2, GetPath
Hotkey, F3, ShowFrame
Hotkey, IfWinActive
Return
; ================================================================================================================================
MainGuiClose:
ExitApp
; ================================================================================================================================
CleanUpOnExit:
;0x0057 (SPI_SETCURSORS) - Reloads the system cursors. Set the uiParam parameter to zero and the pvParam parameter to NULL.
DllCall("SystemParametersInfo", "UInt", 0x0057, "UInt", 0, "Ptr", 0, "UInt", 2)		
ExitApp
; ================================================================================================================================
; Start to look for accessible info
AccStart:
HotKey, Esc, On
CrossHair(1)
SetTimer, GetAccInfo, 10
Return
; --------------------------------------------------------------------------------------------------------------------------------
; Stop looking for accessible info
Esc::
HotKey, Esc, Off
SetTimer, GetAccInfo, Off
CrossHair(0)
AccFrame.Hide()
Return
; --------------------------------------------------------------------------------------------------------------------------------
CrossHair(Set) {
Static Cross := DllCall("LoadCursor", "Ptr", 0, "Ptr", 32515, "UPtr")
Static CursorIDs := [32512, 32513, 32514, 32516, 32642, 32643, 32644, 32645, 32646, 32648, 32649, 32650, 32651]
If (Set)
For Each, ID In CursorIDs
DllCall("SetSystemCursor", "Ptr", DllCall("CopyIcon", "Ptr", Cross, "UPtr"), "UInt", ID)
Else
DllCall("SystemParametersInfo", "UInt", 0x0057, "UInt", 0, "Ptr", 0, "UInt", 2)
}
; ================================================================================================================================
; Get accessibility info
GetAccInfo:
Gui, Main: Default
MouseGetPos, , , InfoWindow
If (InfoWindow = AccFrame.HGUI)
Return
AccObject := AccObj_FromPoint()
If (InfoWindow = HMAIN) {
If (InfoWindow <> AccWindow) {
Gui, ListView, WinLV
Loop, % WinRows.Length()
LV_Modify(A_Index, "Col2", "")
Gui, ListView, CtlLV
Loop, % CtlRows.Length()
LV_Modify(A_Index, "Col2", "")
Gui, ListView, AccLV
Loop, % AccRows.Length()
LV_Modify(A_Index, "Col2", "")
GuiControl, , PathED
AccFrame.Hide()
AccControl := ""
AccObject := ""
AccObjRole := ""
AccObjPath := ""
AccObjPos := ""
AccWindow := InfoWindow
}
Return
}
; Window info
If (InfoWindow <> AccWindow) {
AccWindow := InfoWindow
AccWinRole := AccObj_FromWindow(AccWindow).Role
AccFrame.SetTarget(AccWindow)
Gosub, UpdWindow
}
; Is accessible info available?
If !IsObject(AccObject) {
Gui, ListView, CtlLV
Loop, % CtlRows.Length()
LV_Modify(A_Index, "Col2", "")
Gui, ListView, AccLV
Loop, % AccRows.Length()
LV_Modify(A_Index, "Col2", "")
GuiControl, , PathED
AccFrame.Hide()
AccControl := ""
AccObjRole := ""
AccObjPath := ""
AccObjPos := ""
Return
}
; Check for a child object if AccObject is an element
If (AccObject.CID) && (ChildObject := AccObject.Child) {
AccObject := ChildObject
ChildObject := ""
}
; Acc control info
InfoControl := AccObject.Window
If (InfoControl <> AccControl) {
AccControl := InfoControl
Gosub, UpdAccCtrl
}
; Acc object info
InfoObjRole := AccObject.Role
InfoObjPos := AccObject.Location.Str
If (InfoObjRole <> AccObjRole) || (InfoObjPos <> AccObjPos) {
AccObjRole := InfoObjRole
AccObjPos := InfoObjPos
AccObjPath := ""
Gosub, UpdAccObject
Try AccFrame.Show(Loc.X, Loc.Y, Loc.W, Loc.H)
}
Return
; --------------------------------------------------------------------------------------------------------------------------------
; Update window related values
UpdWindow:
Gui, Listview, WinLV
WinGetTitle, Title, ahk_id %AccWindow%
WinGetClass, Class, ahk_id %AccWindow%
WinGet, Exe, ProcessName, ahk_id %AccWindow%
WinGetPos, X, Y, W, H, ahk_id %AccWindow%
Pos := "x" . X . " y" . Y . " w" . W . " h" . H
LV_Modify(1, "Col2", Title)
LV_Modify(2, "Col2", Class)
LV_Modify(3, "Col2", Exe)
LV_Modify(4, "Col2", Pos)
Return
; --------------------------------------------------------------------------------------------------------------------------------
; Update acc control / window related values
UpdAccCtrl:
Gui, Listview, CtlLV
Pos := AccObj_FromWindow(AccControl).Location.Str
WinGetClass, Class, ahk_id %AccControl%
ID := DllCall("GetDlgCtrlID", "Ptr", AccControl, "Ptr")
LV_Modify(1, "Col2", Class)
LV_Modify(2, "Col2", ID)
LV_Modify(3, "Col2", Pos)
Return
; --------------------------------------------------------------------------------------------------------------------------------
; Update accessible object related values
UpdAccObject:
Gui, Listview, AccLV
LV_Modify(1, "Col2", AccObject.CID)
LV_Modify(2, "Col2", SubStr(AccObject.Name, 1, 260))
Role := AccObject.Role
LV_Modify(4, "Col2", Role . " " . AccObj_GetRoleName(Role))
LV_Modify(5, "Col2", Format("0x{:08X}", AccObject.State))
Loc := AccObject.Location
LV_Modify(6, "Col2", Loc.Str)
LV_Modify(7, "Col2", AccObject.ChildCount)
LV_Modify(8, "Col2", AccObject.KeyboardShortcut)
LV_Modify(9, "Col2", AccObject.DefaultAction)
LV_Modify(10, "Col2", AccObject.Description)
LV_Modify(11, "Col2", AccObject.Help)
GuiControl, , PathED, % (AccObjPath := AccObj_GetPath(AccObject))
Return
; --------------------------------------------------------------------------------------------------------------------------------
; Remove the AccFrame
HideFrame:
Try AccFrame.Hide()
Return
; ================================================================================================================================
; Get the current object's parent
GetParent:
If !IsObject(AccObject)
Return
If (AccObject.Window = AccWindow) && (AccObject.Role = AccWinRole)
Return
If !(Parent := AccObject.Parent)
Return
AccObject := Parent
AccObjRole := AccObject.Role
AccObjPos := AccObject.Location.Str
Parent := ""
Gui, Main: Default
GoSub, UpdAccCtrl
Gosub, UpdAccObject
AccFrame.Show(Loc.X, Loc.Y, Loc.W, Loc.H)
SetTimer, HideFrame, %HideFrameDelay%
Return
; ================================================================================================================================
; Get the current object's path
GetPath:
If !IsObject(AccObject)
Return
Gui, Main: Default
GuiControl, , PathED, % (AccObjPath := AccObj_GetPath(AccObject))
Return
; ================================================================================================================================
; Show the AccFrame upon the current AccObj
ShowFrame:
If IsObject(AccObject) && (AccFrame.Target = AccWindow) {
Pos := AccObject.Location
AccFrame.Show(Pos.X, Pos.Y, Pos.W, Pos.H)
SetTimer, HideFrame, %HideFrameDelay%
}
Return
; ================================================================================================================================
SetExplorerTheme(HCTL) {
If (DllCall("GetVersion", "UChar") > 5) {
VarSetCapacity(ClassName, 256, 0)
If DllCall("GetClassName", "Ptr", HCTL, "Str", ClassName, "Int", 128, "Int")
If (ClassName = "SysListView32") || (ClassName = "SysTreeView32")
Return !DllCall("UxTheme.dll\SetWindowTheme", "Ptr", HCTL, "WStr", "Explorer", "Ptr", 0)
}
Return False
}
; ================================================================================================================================
Class FrameGui {
; -----------------------------------------------------------------------------------------------------------------------------
__New(Color := "Red", Width := 2) {
DefGui := A_DefaultGui ; store the current default Gui
Gui, New, -Caption -DPIScale +hwndHGUI +ToolWindow
Gui, Color, %Color%
Gui, %DefGui%: Default ; restore the default Gui
This.HGUI := HGUI
This.Width := Width
This.Target := 0
}
; -----------------------------------------------------------------------------------------------------------------------------
__Delete() {
Try Gui, % This.HGUI . ":Destroy"
}
; -----------------------------------------------------------------------------------------------------------------------------
Show(X, Y, W, H) {
If !(HGUI := This.HGUI) || !(Width := This.Width)
Return False
X1 := Width, X2 := W - Width, Y1 := Width, Y2 := H - Width
Gui, %HGUI%: +LastFound
WinSet, Region, 0-0 %W%-0 %W%-%H% 0-%H% 0-0 %X1%-%Y1% %X2%-%Y1% %X2%-%Y2% %X1%-%Y2% %X1%-%Y1%
Gui, %HGUI%: Show, NA x%X% y%Y% w%W% h%H%
; The following two lines are taken from the original AccViewer source released by jethrow.
; I still don't really understand, how this works, but it's needed sometimes and it does the job.
If (Above := DllCall("GetWindow", "Ptr", This.Target, "UInt", 3, "UPtr"))
DllCall("SetWindowPos", "Ptr", HGUI, "Ptr", Above, "Int", 0, "Int", 0, "Int", 0, "Int", 0, "UInt", 0x13)
Return True
}
; -----------------------------------------------------------------------------------------------------------------------------
Hide() {
Try Gui, % This.HGUI . ":Hide"
}
; -----------------------------------------------------------------------------------------------------------------------------
SetTarget(TargetHwnd) {
If DllCall("IsWindow", "Ptr", TargetHwnd, "UInt") {
WinGet, ExStyle, ExStyle, ahk_id %TargetHwnd%
Gui, % This.HGUI . (ExStyle & 0x8 ? ":+AlwaysOnTop" : ":-AlwaysOnTop") ; 0x8 is WS_EX_TOPMOST.
This.Target := TargetHwnd
}
}
}
; ================================================================================================================================
#Include %A_ScriptDir%\..\class_AccObj.ahk