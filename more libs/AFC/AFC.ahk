;
; AFC Base Functions
;

/*!
	Library: AutoHotkey Foundation Classes, v0.1
		AFC is a thin object-oriented wrapper around some of AutoHotkey's functionality.
		It mainly takes care of wrapping long-time present commands and functions that
		use old and quirky paradigms into a saner and cleaner class-based API.
		
		AFC is designed to be modular, and to be as direct as possible with the original
		API. This translates to not having otherwise obvious properties that are implemented
		through flexi-lists. The author believes that the performance and code size penalty
		is not justified.
		
		AFC provides:
		* Structured class-based entry points.
		* GUI API
		* Default base object, which provides OOP syntax sugar for non-object values (such as `str.Length`)
		
		AFC will provide in the future:
		* Menus
		* Timers
		* Hotkeys and hotstrings (perhaps?)
	Author: fincs
	License: WTFPL
*/

;!GenDocs-Import CPropImpl.ahk
;!GenDocs-Import CDefaultBase.ahk

;!GenDocs-Import CWindow.ahk
;!GenDocs-Import CControl.ahk

;!GenDocs-Import CImageList.ahk
;!GenDocs-Import CMsgDispatch.ahk

;!GenDocs-Import CCtrlLabel.ahk
;!GenDocs-Import CCtrlEdit.ahk
;!GenDocs-Import CCtrlUpDown.ahk
;!GenDocs-Import CCtrlImage.ahk
;!GenDocs-Import CCtrlButton.ahk
;!GenDocs-Import CCtrlCheckBox.ahk
;!GenDocs-Import CCtrlRadio.ahk
;!GenDocs-Import CCtrlDropDown.ahk
;!GenDocs-Import CCtrlComboBox.ahk
;!GenDocs-Import CCtrlListBox.ahk
;!GenDocs-Import CCtrlListView.ahk
;!GenDocs-Import CCtrlTreeView.ahk
;!GenDocs-Import CCtrlLink.ahk
;!GenDocs-Import CCtrlHotkey.ahk
;!GenDocs-Import CCtrlDateTime.ahk
;!GenDocs-Import CCtrlCalendar.ahk
;!GenDocs-Import CCtrlSlider.ahk
;!GenDocs-Import CCtrlProgress.ahk
;!GenDocs-Import CCtrlGroupBox.ahk
;!GenDocs-Import CCtrlTab.ahk
;!GenDocs-Import CCtrlStatusBar.ahk
;!GenDocs-Import CCtrlActiveX.ahk

/*!
	Page: Entry points
	Filename: EntryPoints
	Contents: @file:../doc-pages/EntryPoints.md
*/

/*!
	Page: Event handlers
	Filename: EventHandlers
	Contents: @file:../doc-pages/EventHandlers.md
*/

#NoEnv

global AFC_AppObj, AFC_AppArgs

__AFC_AppArgs()
{
	global
	static _ := __AFC_AppArgs()
	AFC_AppArgs := []
	Loop, %0%
		AFC_AppArgs.Insert(%A_Index%), VarSetCapacity(%A_Index%, 0)
}

/*!
	Function: AFC_EntryPoint(class, setWD := true)
		Main entry point function for structured AFC applications. Usage
		is optional although recommended.
	Parameters:
		class - Reference to the application class to be used.
		setWD - *(Optional)* Set to `true` in order to set the
			working directory to `A_ScriptDir`. Defaults to `true`.
	Remarks:
		In order to use this, call the function in the auto-execute section.
		Said section should not contain any more code.
		
		An instance of the specified class is created and stored in
		the `AFC_AppObj` super-global. The class' constructor is passed
		an array containing the command line arguments (which can also
		be found in the `AFC_AppArgs` super-global).
		
		When this function is used, several defaults are changed in order
		to match those of AutoHotkey v2, namely:
		
		* `#NoEnv` is active.
		* `SetBatchLines` defaults to -1.
		* `SendMode` defaults to `Input`.
		* `SetTitleMatchMode` defaults to 2.
		* `CoordMode` defaults to `Client`.
*/

AFC_Entrypoint(clsRef, setWD := true)
{
	; Set modern AutoHotkey defaults similar to that of v2
	SetBatchLines, -1
	SendMode, Input
	SetTitleMatchMode, 2
	CoordMode, ToolTip, Client
	CoordMode, Pixel, Client
	CoordMode, Mouse, Client
	CoordMode, Caret, Client
	CoordMode, Menu, Client
	
	; Set OnExit trap
	OnExit, __AFC_AtExit
	
	if setWD
		SetWorkingDir, %A_ScriptDir%
	
	; Create an instance of the application class and store a reference
	AFC_AppObj := new clsRef(AFC_AppArgs)
}

/*!
	Function: AFC_AtExit(func)
		Registers a function to be called when a structured application exits. Analogous to `OnExit`.
	Parameters:
		func - Function to call. It is recommended that it be a function reference.
	Remarks:
		The function can accept up to two parameters:
		
		> AtExitFunc(appObj, exitReason)
		> {
		>     ; ... body of function ...
		> }
		
		The first parameter receives a reference to the [main application object](AFC_EntryPoint.html),
		while the second one is equivalent to `A_ExitReason`.
		
		If the function returns `true`, the exit attempt is aborted.
*/

AFC_AtExit(method)
{
	global
	local _k,_v
	static _ := []
	_.Insert(method)
	return
	
	__AFC_AtExit:
	for _k,_v in _
		if _v.(AFC_AppObj, A_ExitReason)
			return
	ExitApp
}
