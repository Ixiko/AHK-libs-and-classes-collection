#SingleInstance, force
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetTitleMatchMode, 2

#include ..\class_UIA_Interface.ahk
#include <UIA_Browser>

EventHandler(el) {
	global cUIA
	ToolTip, % "Caught event!`nElement name: " el.CurrentName
	if cUIA.CompareElements(cUIA.URLEditElement, el) ; Check if the focused element is the same as Chrome's address bar element (comparison using == won't work)
		el.SetValue("") ; If the Address bar was focused, clear it
}

ExitFunc() {
	global cUIA, h
	UIA.RemoveFocusChangedEventHandler(h) ; Remove the event handler. Alternatively use cUIA.RemoveAllEventHandlers() to remove all handlers
}

browserExe := "chrome.exe"
Run, %browserExe%  -incognito
WinWaitActive, ahk_exe %browserExe%
cUIA := new UIA_Browser("ahk_exe " browserExe)

h := UIA_CreateEventHandler("EventHandler", "FocusChanged") ; Create a new FocusChanged event handler that calls the function EventHandler (required arguments: element)
cUIA.AddFocusChangedEventHandler(h) ; Add a new FocusChangedEventHandler
OnExit("ExitFunc") ; Set up an OnExit call to clean up the handler when exiting the script
return

F5::ExitApp
