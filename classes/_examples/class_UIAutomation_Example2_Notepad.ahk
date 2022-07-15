#NoEnv
#SingleInstance force
SetTitleMatchMode, 2

#include ..\class_UIA_Interface.ahk

F5::ExitApp
F1::
	Run, notepad.exe
	UIA := UIA_Interface() ; Initialize UIA interface
	WinWaitActive, ahk_exe notepad.exe
	npEl := UIA.ElementFromHandle(WinExist("ahk_exe notepad.exe")) ; Get the element for the Notepad window
	MsgBox, % npEl.DumpAll() ; Display all the sub-elements for the Notepad window. Press OK to continue
	editEl := npEl.FindFirstByType("Edit") ; Find the first Edit control (in Notepad there is only one)
	editEl.SetValue("Lorem ipsum") ; Set the value of the edit control
	MsgBox, Press OK to test saving. ; Wait for the user to press OK
	fileEl := npEl.FindFirstByNameAndType("File", "MenuItem").Click() ; Click the "File" menu item
	saveEl := npEl.WaitElementExistByName("Save",,2) ; Wait for the "Save" menu item to exist
	saveEl.Click() ; And now click Save
	return

