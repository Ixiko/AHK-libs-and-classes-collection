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
treeEl := explorerEl.FindFirstByType("Tree")

MsgBox, % "For this example, make sure that the folder tree on the left side in File Explorer has some scrollable elements (make the window small enough)."
scrollPattern := treeEl.GetCurrentPatternAs("Scroll")
Sleep, 500
MsgBox, % "ScrollPattern properties: "
	. "`nCurrentHorizontalScrollPercent: " scrollPattern.CurrentHorizontalScrollPercent ; If this returns an error about not existing, make sure you have the latest UIA_Interface.ahk
	. "`nCurrentVerticalScrollPercent: " scrollPattern.CurrentVerticalScrollPercent
	. "`nCurrentHorizontalViewSize: " scrollPattern.CurrentHorizontalViewSize
	. "`nCurrentHorizontallyScrollable: " scrollPattern.CurrentHorizontallyScrollable
	. "`nCurrentVerticallyScrollable: " scrollPattern.CurrentVerticallyScrollable
Sleep, 50
MsgBox, % "Press OK to set scroll percent to 50% vertically and 0% horizontally."
scrollPattern.SetScrollPercent(,50)
Sleep, 500
MsgBox, % "Press OK to scroll a Page Up equivalent upwards vertically."
scrollPattern.Scroll(, UIA.ScrollAmount_LargeDecrement) ; LargeDecrement is equivalent to pressing the PAGE UP key or clicking on a blank part of a scroll bar. SmallDecrement is equivalent to pressing an arrow key or clicking the arrow button on a scroll bar.

Sleep, 500
MsgBox, Press OK to scroll drive C: into view.
CDriveEl := explorerEl.FindFirstByNameAndType(CDriveName, "TreeItem")
if !CDriveEl {
	MsgBox, C: drive element not found! Exiting app...
	ExitApp
}
scrollItemPattern := CDriveEl.GetCurrentPatternAs("ScrollItem")
scrollItemPattern.ScrollIntoView()

ExitApp
