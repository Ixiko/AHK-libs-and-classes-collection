#SingleInstance, force
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetTitleMatchMode, 2

#include ..\class_UIA_Interface.ahk

Run, explore C:\
UIA := UIA_Interface()
DriveGet, CDriveName, Label, C:
CDriveName := CDriveName " (C:)"
WinWaitActive, %CDriveName%
explorerEl := UIA.ElementFromHandle(WinActive("A"))
listEl := explorerEl.FindFirstByType("List")

tablePattern := listEl.GetCurrentPatternAs("Table")
MsgBox, % "TablePattern properties: "
	. "`nCurrentRowOrColumnMajor: " tablePattern.CurrentRowOrColumnMajor


rowHeaders := tablePattern.GetCurrentRowHeaders()
rowHeadersDump := ""
for _,header in rowHeaders
	rowHeadersDump .= header.Dump() "`n"
MsgBox, % "TablePattern elements from GetCurrentRowHeaders:`n" rowHeadersDump ; Should be empty, there aren't any row headers
columnHeaders := tablePattern.GetCurrentColumnHeaders()
columnHeadersDump := ""
for _,header in columnHeaders
	columnHeadersDump .= header.Dump() "`n"
MsgBox, % "TablePattern elements from GetCurrentColumnHeaders:`n" columnHeadersDump

editEl := listEl.GetCurrentPatternAs("Grid").GetItem(3,0) ; To test the TableItem pattern, we need to get an element supporting that using Grid pattern...
tableItemPattern := editEl.GetCurrentPatternAs("TableItem")
rowHeaderItems := tableItemPattern.GetCurrentRowHeaderItems()
rowHeaderItemsDump := ""
for _,headerItem in rowHeaderItems
	rowHeaderItemsDump .= headerItem.Dump() "`n"
MsgBox, % "TableItemPattern elements from GetCurrentRowHeaderItems:`n" rowHeaderItemsDump ; Should be empty, there aren't any row headers
columnHeaderItems := tableItemPattern.GetCurrentColumnHeaderItems()
columnHeaderItemsDump := ""
for _,headerItem in columnHeaderItems
	columnHeaderItemsDump .= headerItem.Dump() "`n"
MsgBox, % "TableItemPattern elements from GetCurrentColumnHeaderItems:`n" columnHeaderItemsDump
ExitApp
