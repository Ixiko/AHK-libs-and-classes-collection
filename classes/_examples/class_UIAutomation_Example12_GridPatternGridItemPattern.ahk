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

gridPattern := listEl.GetCurrentPatternAs("Grid")
Sleep, 500
MsgBox, % "GridPattern properties: "
	. "`nCurrentRowCount: " gridPattern.CurrentRowCount
	. "`nCurrentColumnCount: " gridPattern.CurrentColumnCount

MsgBox, % "Getting grid item from row 4, column 1 (0-based indexing)"
editEl := gridPattern.GetItem(3,0)
MsgBox, % "Got this element: `n" editEl.Dump()

gridItemPattern := editEl.GetCurrentPatternAs("GridItem")
MsgBox, % "GridItemPattern properties: "
	. "`nCurrentRow: " gridItemPattern.CurrentRow
	. "`nCurrentColumn: " gridItemPattern.CurrentColumn
	. "`nCurrentRowSpan: " gridItemPattern.CurrentRowSpan
	. "`nCurrentColumnSpan: " gridItemPattern.CurrentColumnSpan
	; gridItemPattern.CurrentContainingGrid should return listEl

ExitApp
