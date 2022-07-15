#NoEnv
#SingleInstance force
SetTitleMatchMode, 2

#include ..\UIA_Interface

Run, notepad.exe
UIA := UIA_Interface() ; Initialize UIA interface
WinWaitActive, ahk_exe notepad.exe
npEl := UIA.ElementFromHandle(WinExist("ahk_exe notepad.exe")) ; Get the element for the Notepad window
documentEl := npEl.FindFirstByType("Document") ; Find the first Document control (in Notepad there is only one). This assumes the user is running a relatively recent Windows and UIA interface version 2+ is available. In UIA interface v1 this control was Edit, so an alternative option instead of "Document" would be "UIA.__Version > 1 ? "Document" : "Edit""
documentEl.SetValue("Lorem ipsum") ; Set the value for the document control
ExitApp
