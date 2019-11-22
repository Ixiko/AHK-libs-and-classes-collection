
;https://www.autohotkey.com/boards/viewtopic.php?f=5&t=58131
;request: "For conversion, I need a function that can report whether something looks like a hotkey. I'm asking in case anyone has any suggestions."
;solution by swagfag

/*
;#include %A_ScriptDir%\..\isLikeHotkey.ahk
#NoEnv
#SingleInstance Force
SetBatchLines -1

fn := Func("isLikeHotkey")
eq := Func("assert").Bind(true, fn)
neq := Func("assert").Bind(false, fn)

valid := "Testing valid hotkeys`n`n"
valid .= eq.Call("Up Up")
valid .= eq.Call("Up")
valid .= eq.Call("``") ; hotkey is meant to be single `::
valid .= eq.Call("`; Up")
valid .= eq.Call(":")
valid .= eq.Call("  	 &   & & ")
valid .= eq.Call("  	 &   & k")
valid .= eq.Call("h  	  & 		 j Up")
valid .= eq.Call("~*>$>>+!^#<g Up")
valid .= eq.Call("vk24 & vk23")
valid .= eq.Call("sc123")
valid .= eq.Call("z")
MsgBox % valid

invalid := "Testing invalid hotkeys`n`n"
invalid .= neq.Call("") ; blank hotkey, ie ::
invalid .= neq.Call("    	*  	g &   	 h Up")
invalid .= neq.Call("not_a_hotkey")
invalid .= neq.Call("g Up & g Up")
invalid .= neq.Call("vk12sc123")
invalid .= neq.Call("vk123456")
MsgBox % invalid

Clipboard := valid invalid
ExitApp

Esc::ExitApp
*/

isLikeHotkey(str) {
	static VALID_HOTKEY := "(\b(LButton|RButton|MButton|XButton1|XButton2|WheelDown|WheelUp|WheelLeft|WheelRight|CapsLock|Space|Tab|Enter|Return|Escape|Esc|Backspace|BS|ScrollLock|Delete|Del|Insert|Ins|Home|End|PgUp|PgDn|Up|Down|Left|Right|Numpad0|NumpadIns|Numpad1|NumpadEnd|Numpad2|NumpadDown|Numpad3|NumpadPgDn|Numpad4|NumpadLeft|Numpad5|NumpadClear|Numpad6|NumpadRight|Numpad7|NumpadHome|Numpad8|NumpadUp|Numpad9|NumpadPgUp|NumpadDot|NumpadDel|NumLock|NumpadDiv|NumpadMult|NumpadAdd|NumpadSub|NumpadEnter|F1|F2|F3|F4|F5|F6|F7|F8|F9|F10|F11|F12|F13|F14|F15|F16|F17|F18|F19|F20|F21|F22|F23|F24|LWin|RWin|Control|Ctrl|Alt|Shift|LControl|LCtrl|RControl|RCtrl|LShift|RShift|LAlt|RAlt|Browser_Back|Browser_Forward|Browser_Refresh|Browser_Stop|Browser_Search|Browser_Favorites|Browser_Home|Volume_Mute|Volume_Down|Volume_Up|Media_Next|Media_Prev|Media_Stop|Media_Play_Pause|Launch_Mail|Launch_Media|Launch_App1|Launch_App2|AppsKey|PrintScreen|CtrlBreak|Pause|Break|Help|Sleep|vk[a-fA-F0-9]{2}|sc[a-fA-F0-9]{3})\b|`;|([^\s](?!\w)))"
		 , OPTIONAL_PASSTHROUGH := "(~?)"
		 , WHITESPACE := "(\s*)"
		 , AMPERSAND := "(&)"
		 , OPTIONAL_UP := "(\s*Up)?"
		 , BOL := "^"
		 , SINGLE_HOTKEY_MODIFIERS := "([~*$+^!#<>]*)"
		 , AMPERSAND_HOTKEY := BOL WHITESPACE SINGLE_HOTKEY_MODIFIERS AMPERSAND WHITESPACE OPTIONAL_UP
		 , SINGLE_HOTKEY := BOL WHITESPACE SINGLE_HOTKEY_MODIFIERS VALID_HOTKEY WHITESPACE OPTIONAL_UP
		 , MULTI_HOTKEY := BOL WHITESPACE OPTIONAL_PASSTHROUGH VALID_HOTKEY WHITESPACE AMPERSAND WHITESPACE OPTIONAL_PASSTHROUGH VALID_HOTKEY WHITESPACE OPTIONAL_UP

	if (str = "") ; bail early
		return false

	StrReplace(strCopy := str, "&",, numAmpersands) ; count how many '&' in hotkey

	; handle case, where ampersand is a single hotkey '&::',
	; and not a joining char or left/right part of a multihotkey
	if (numAmpersands = 1 && RegExMatch(str, AMPERSAND_HOTKEY))
		numAmpersands := 0 ; this forces the ampersand hotkey to be evaluated as a single hotkey

	if numAmpersands in 0 ; single hotkey check
		return !!RegExMatch(str, SINGLE_HOTKEY)

	else if numAmpersands in 1,2,3 ; multihotkey check
		return !!RegExMatch(str, MULTI_HOTKEY)

	else ; invalid hotkey, too many & & & & ...
		return false

	throw new Exception(Format("Error: {}(""{}"") wasnt caught by any of the checks", A_ThisFunc, str))
}

assert(condition, fn, arg) {
	static MSG := "<{}>: {}(""{}"") == '{}'`n"
	return Format(MSG
			, fn.Call(arg) == condition ? "PASS" : "FAIL"
			, fn.Name
			, arg
			, condition ? "true" : "false")
}
