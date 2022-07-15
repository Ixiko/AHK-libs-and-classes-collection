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
	editEl := npEl.FindFirstByType("Edit") ; Find the first Edit control (in Notepad there is only one)
	editEl.SetValue("Lorem ipsum") ; Set the value for the edit control
	return
