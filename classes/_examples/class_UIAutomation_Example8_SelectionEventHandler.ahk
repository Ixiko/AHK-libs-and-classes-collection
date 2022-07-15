#SingleInstance, force
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetTitleMatchMode, 2

#include ..\class_UIA_Interface.ahk

TextSelectionChangedEventHandler(el, eventId) {
	textPattern := el.GetCurrentPatternAs("TextPattern")
	selectionArray := textPattern.GetSelection() ; Gets the currently selected text in Notepad as an array of TextRanges (some elements support selecting multiple pieces of text at the same time, thats why an array is returned)
	selectedRange := selectionArray[1] ; Our range of interest is the first selection (TextRange)
	wholeRange := textPattern.DocumentRange ; For comparison, get the whole range (TextRange) of the document
	selectionStart := selectedRange.CompareEndpoints(UIA_Enum.TextPatternRangeEndpoint_Start, wholeRange, UIA_Enum.TextPatternRangeEndpoint_Start) ; Compare the start point of the selection to the start point of the whole document
	selectionEnd := selectedRange.CompareEndpoints(UIA_Enum.TextPatternRangeEndpoint_End, wholeRange, UIA_Enum.TextPatternRangeEndpoint_Start) ; Compare the end point of the selection to the start point of the whole document

	ToolTip, % "Selected text: " selectedRange.GetText() "`nSelection start location: " selectionStart "`nSelection end location: " selectionEnd  ; Display the selected text and locations of selection
}

ExitFunc() {
	global UIA, handler, NotepadEl
	try UIA.RemoveAutomationEventHandler(UIA.Text_TextSelectionChangedEventId, NotepadEl, handler) ; Remove the event handler. Alternatively use UIA.RemoveAllEventHandlers() to remove all handlers. If the Notepad window doesn't exist any more, this throws an error.
}

lorem =
(
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
) ; Some sample text to play around with
Run, notepad.exe
WinActivate, ahk_exe notepad.exe
WinWaitActive, ahk_exe notepad.exe
UIA := UIA_Interface()

NotepadEl := UIA.ElementFromHandle(WinExist("ahk_exe notepad.exe"))
DocumentControlCondition := UIA.CreatePropertyCondition(UIA.ControlTypePropertyId, UIA.DocumentControlTypeId) ; If UIA Interface version is 1, then the ControlType is Edit instead of Document!
DocumentControl := NotepadEl.FindFirst(DocumentControlCondition)
DocumentControl.SetValue(lorem) ; Set the value to our sample text

handler := UIA_CreateEventHandler("TextSelectionChangedEventHandler") ; Create a new event handler that points to the function TextSelectionChangedEventHandler, which must accept two arguments: element and eventId.
UIA.AddAutomationEventHandler(UIA.Text_TextSelectionChangedEventId, NotepadEl,,, handler) ; Add a new automation handler for the TextSelectionChanged event
OnExit("ExitFunc") ; Set up an OnExit call to clean up the handler when exiting the script
return

F5::ExitApp
