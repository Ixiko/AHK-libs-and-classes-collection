#NoEnv
#SingleInstance force
SetTitleMatchMode, 2

#include ..\class_UIA_Interface.ahk

Run, notepad.exe
UIA := UIA_Interface() ; Initialize UIA interface
WinWaitActive, ahk_exe notepad.exe
npEl := UIA.ElementFromHandle(WinExist("ahk_exe notepad.exe")) ; Get the element for the Notepad window
MsgBox, % npEl.DumpAll() ; Display all the sub-elements for the Notepad window. Press OK to continue
documentEl := npEl.FindFirstByType("Document") ; Find the first Document control (in Notepad there is only one). This assumes the user is running a relatively recent Windows and UIA interface version 2+ is available. In UIA interface v1 this control was Edit, so an alternative option instead of "Document" would be "UIA.__Version > 1 ? "Document" : "Edit""
documentEl.SetValue("Lorem ipsum") ; Set the value of the document control
MsgBox, Press OK to test saving. ; Wait for the user to press OK
fileEl := npEl.FindFirstByNameAndType("File", "MenuItem").Click() ; Click the "File" menu item
saveEl := npEl.WaitElementExistByName("Save",,2) ; Wait for the "Save" menu item to exist
saveEl.Click() ; And now click Save
ExitApp

