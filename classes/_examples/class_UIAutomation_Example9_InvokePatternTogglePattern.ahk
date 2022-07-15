#SingleInstance, force
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetTitleMatchMode, 2

#include ..\class_UIA_Interface.ahk

Run, explore C:\
UIA := UIA_Interface()
WinWaitActive, (C:)
explorerEl := UIA.ElementFromHandle(WinActive("A"))
fileEl := explorerEl.FindFirstByNameAndType("File tab", "Button")
invokePattern := fileEl.GetCurrentPatternAs("Invoke")
MsgBox, % "Invoke pattern doesn't have any properties. Press OK to call Invoke on the ""File"" button..."
invokePattern.Invoke()

Sleep, 1000
MsgBox, Press OK to navigate to the View tab to test TogglePattern... ; Not part of this demonstration
explorerEl.FindFirstByNameAndType("View", "TabItem").GetCurrentPatternAs("SelectionItem").Select() ; Not part of this demonstration

hiddenItemsCB := explorerEl.FindFirstByNameAndType("Hidden items", "CheckBox")
togglePattern := hiddenItemsCB.GetCurrentPatternAs("Toggle")
Sleep, 500
MsgBox, % "TogglePattern properties for ""Hidden items"" checkbox: "
	. "`nCurrentToggleState: " togglePattern.CurrentToggleState

MsgBox, % "Press OK to toggle"
togglePattern.Toggle()
Sleep, 500
MsgBox, % "Press OK to toggle again"
togglePattern.Toggle()

ExitApp
