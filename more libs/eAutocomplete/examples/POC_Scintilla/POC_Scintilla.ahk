#NoEnv
#SingleInstance force
SetWorkingDir % A_ScriptDir
SendMode, Input
#Warn
; tested on Windows 10 (19041) 64 bit with Autohotkey v1.1.32.00 32-bit Unicode


; note: require SciLexer.dll

if not (hModule:=DllCall("LoadLibrary", "Str", A_ScriptDir . "\SciLexer.dll")) {
	MsgBox, 16,, Failed to load library (\SciLexer.dll).`r`nThe script will exit.
ExitApp
}

#Include %A_ScriptDir%\..\..\eAutocomplete.ahk

wordlist := eAutocomplete.Wordlist.buildFromFile("myAutocompleteList", A_ScriptDir . "\Autocompletion\Autocompletion_en")
; Load a list of suggestions from a file and prepare the given list for use as an autocompletion list.
query := wordlist.Query
query.Word.minLength := 1
query.Word.edgeKeys := RegExReplace(query.Word.edgeKeys, "[\.\*\?\+\{\}\\\[\]\(\)\^\$\|]", "")
/*
Known limitation: for now, the script is unable to make a distinction between 'edge chars' and symbols commonly used in the regex syntax: if
; you want to use a regex symbol as such, it must not be listed in edgeKeys.
*/
query.Sift.option := "REGEX" ; Needle is an REGEX expression to check against Haystack item
GUI, New
GUI, +Resize +hwndGUIID ;  +HwndGUIID stores the HWND (unique identifier) of the window in GUIID
Gui, Add, Custom, ClassScintilla +hwndhSci w400 h400 ; create the host scintilla control (+hwndhSci stores the HWND (unique identifier) of the control in hSci)
eAutocomplete.wrap(hSci) ; wrap it into an eAutocomplete object
eAutocomplete.resource := wordlist.name ; set the instance's autocomplete list (can be changed at any time thereafter)
GUI, Show, AutoSize
OnExit, handleExit
return

handleExit:
	if (WinExist("ahk_id " . GUIID))
		GUI % GUIID ":Destroy"
	if (hModule)
		DllCall("FreeLibrary", "Ptr", hModule)
ExitApp

!x::ExitApp

Class sciEventsMessenger {
	_Init() {
	static _ := sciEventsMessenger._Init()
	eAutocomplete._HostControlWrapper.base.EventsMessenger := sciEventsMessenger
	eAutocomplete._HostControlWrapper.base._getTextFromEvent := Func("sciEventsMessenger.Utils.controlGetText")
	eAutocomplete._HostControlWrapper.base._getCaretPos := Func("sciEventsMessenger.Utils.getCaretPos")
	eAutocomplete._HostControlWrapper.COMPATIBLE_CLASSES := "Scintilla"
	}
	static instances := []
	__New(_hwnd) {
		static WM_COMMAND := 0x0111
		static WM_NOTIFY := 0x4E
		static _init := false
		this.instances[ _hwnd+0 ] := this
		if not (_init) {
			_fn := this.__sciNotify.bind("", this.instances)
			OnMessage(WM_COMMAND, _fn, -1), OnMessage(WM_NOTIFY, _fn, -1), _init := true
		}
	}
	_dispose(_hwnd) {
		local
		_instances := this.instances, _key := Format("{:i}", _hwnd)
		if (_instances.hasKey(_key)) {
			this.instances[_key] := ""
			this.instances.delete(_key)
		} else throw Exception("The instance does not exists.", -1, _hwnd)
	}
	_disposeAll() {
		local
		for _hControl in this.instances.clone()
			this._dispose(_hControl)
	}
	__sciNotify(_instances, _wParam, _lParam, _msg, _hwnd) {
		local
		static WM_COMMAND := 0x0111
		static WM_NOTIFY := 0x4E
		static EN_CHANGE := 0x0300 ; https://www.scintilla.org/ScintillaDoc.html#SCN_MODIFIED
		static SCN_UPDATEUI := 2007 ; https://www.scintilla.org/ScintillaDoc.html#SCN_UPDATEUI
		if (_msg = WM_NOTIFY) {
			if (_instances.hasKey(_hwnd:=NumGet(_lParam + 0, 0, "UPtr"))) {
				_SCNCode := NumGet(_lParam + A_Ptrsize * 2) ; https://github.com/kczx3/Scintilla/blob/master/Scintilla.ahk#L134
				if (_SCNCode = SCN_UPDATEUI) {
					DllCall("User32.dll\PostMessage", "Ptr", A_ScriptHwnd, "Uint", 0x8004, "Ptr", _hwnd, "Ptr", 0) ; WM_APP + 4
				}
			}
		} else if (_msg = WM_COMMAND) {
			if (_instances.hasKey(_lParam:=_lParam+0)) {
				_notificationCode := (_wParam >> 16) ; https://docs.microsoft.com/en-us/windows/win32/menurc/wm-command#remarks
				if (_notificationCode = EN_CHANGE) {
					DllCall("User32.dll\PostMessage", "Ptr", A_ScriptHwnd, "Uint", 0x8004, "Ptr", _lParam, "Ptr", 0) ; WM_APP + 4
				}
			}
		}
	}
	Class Utils {
		controlGetText(ByRef _text:="", _params*) {
			local
			ControlGetText, _text,, % "ahk_id " this.lastFound
		}
		getCaretPos(ByRef _startPos:="", ByRef _endPos:="") {
			local
			static SCI_GETSELECTIONSTART := 2143 ; https://www.scintilla.org/ScintillaDoc.html#SCI_GETSELECTIONSTART
			static SCI_GETSELECTIONEND := 2145 ; https://www.scintilla.org/ScintillaDoc.html#SCI_GETSELECTIONEND
			SendMessage % SCI_GETSELECTIONSTART, 0, 0,, % "ahk_id " . this.lastFound
			_startPos := ErrorLevel
			SendMessage % SCI_GETSELECTIONEND, 0, 0,, % "ahk_id " . this.lastFound
			_endPos := ErrorLevel
		return _endPos
		}
	}
}