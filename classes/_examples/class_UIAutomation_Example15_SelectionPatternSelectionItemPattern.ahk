#SingleInstance, force
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetTitleMatchMode, 2

#include <UIA_Interface>

Run, explore C:\
UIA := UIA_Interface()
DriveGet, CDriveName, Label, C:
CDriveName := CDriveName " (C:)"
WinWaitActive, %CDriveName%
explorerEl := UIA.ElementFromHandle(WinActive("A"))
listEl := explorerEl.FindFirstByType("List")

selectionPattern := listEl.GetCurrentPatternAs("SelectionPattern") ; If we called this method with just "Selection" instead of "SelectionPattern", we would get "SelectionPattern2" which doesn't extend SelectionPattern methods and properties
MsgBox, % "SelectionPattern properties: "
	. "`nCurrentCanSelectMultiple: " selectionPattern.CurrentCanSelectMultiple
	. "`nCurrentIsSelectionRequired: " selectionPattern.CurrentIsSelectionRequired

currentSelectionEls := selectionPattern.GetCurrentSelection()
currentSelections := ""
for index,selection in currentSelectionEls
	currentSelections .= index ": " selection.Dump() "`n"

windowsListItem := explorerEl.FindFirstByNameAndType("Windows", "ListItem")
selectionItemPattern := windowsListItem.GetCurrentPatternAs("SelectionItem")
MsgBox, % "ListItemPattern properties for Windows folder list item:"
	. "`nCurrentIsSelected: " selectionItemPattern.CurrentIsSelected
	. "`nCurrentSelectionContainer: " selectionItemPattern.CurrentSelectionContainer.Dump()

MsgBox, % "Press OK to select ""Windows"" folder list item."
selectionItemPattern.Select()
MsgBox, % "Press OK to add to selection ""Program Files"" folder list item."
explorerEl.FindFirstByNameAndType("Program Files", "ListItem").GetCurrentPatternAs("SelectionItem").AddToSelection()
MsgBox, % "Press OK to remove selection from ""Windows"" folder list item."
selectionItemPattern.RemoveFromSelection()

ExitApp
