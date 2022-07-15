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
windowPattern := explorerEl.GetCurrentPatternAs("Window")
Sleep, 500
MsgBox, % "WindowPattern properties: "
	. "`nCurrentCanMaximize: " windowPattern.CurrentCanMaximize
	. "`nCurrentCanMinimize: " windowPattern.CurrentCanMinimize
	. "`nCurrentIsModal: " windowPattern.CurrentIsModal
	. "`nCurrentIsTopmost: " windowPattern.CurrentIsTopmost
	. "`nCurrentWindowVisualState: " (visualState := windowPattern.CurrentWindowVisualState) " (" UIA_Enum.WindowVisualState(visualState) ")"
	. "`nCurrentWindowInteractionState: " (interactionState := windowPattern.CurrentWindowInteractionState) " (" UIA_Enum.WindowInteractionState(interactionState) ")"
Sleep, 50
MsgBox, Press OK to try minimizing
windowPattern.SetWindowVisualState(UIA_Enum.WindowVisualState_Minimized)

Sleep, 500
MsgBox, Press OK to bring window back to normal
windowPattern.SetWindowVisualState(UIA_Enum.WindowVisualState_Normal)

transformPattern := explorerEl.GetCurrentPatternAs("TransformPattern") ; Note: for some reason TransformPattern2 doesn't extend TransformPattern properties/methods. If we called GetCurrentPatternAs("Transform"), we would get TransformPattern2 and wouldn't be able to access these properties and methods. Thats why previously we could use GetCurrentPatternAs("Window") instead of GetCurrentPatternAs("WindowPattern"), but here we need GetCurrentPatternAs("TransformPattern") to get TransformPattern explicitly.
Sleep, 500
MsgBox, % "TransformPattern properties: "
	. "`nCurrentCanMove: " transformPattern.CurrentCanMove
	. "`nCurrentCanResize: " transformPattern.CurrentCanResize
	. "`nCurrentCanRotate: " transformPattern.CurrentCanRotate

MsgBox, Press OK to move to coordinates x100 y200
transformPattern.Move(100,200)

Sleep, 500
MsgBox, Press OK to resize to w600 h400
transformPattern.Resize(600,400)

Sleep, 500
MsgBox, Press OK to close window
windowPattern.Close()

