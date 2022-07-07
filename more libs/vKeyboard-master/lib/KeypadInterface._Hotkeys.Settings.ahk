Class Settings {
	autocomplete :=
	(LTrim Join C
		{
			"keyboard": {
				"listboxDismiss": "Esc"
				, "listboxSelectUp": "NumpadPgUp"
				, "listboxSelectDown": "NumpadPgDn"
				, "dataLookUp1": "!Left"
				, "dataLookUp2": "!Right"
				, "complete1": "Tab"
				, "complete2": "+Tab"
			},
			"joystick": {
				"listboxDismiss": "Joy1"
				, "listboxSelectUp": "Joy7"
				, "listboxSelectDown": "Joy8"
				, "dataLookUp1": "!Joy7"
				, "dataLookUp2": "!Joy8"
				, "complete1": "Joy6"
				, "complete2": "!Joy6"
			}
		}
	)
	, keypad :=
	(LTrim Join C
	{
		"keyboard": {
			"pressKey": "Enter"
			, "altReset": "Esc"
			, "sendBackSpace": "BackSpace"
			, "sendSpace": "Space"
			, "startNewLine": "NumpadEnter"
			, "submit": "+Enter"
			, "switchLayer": "F2"
			, "decreaseFontSize": "NumpadSub"
			, "increaseFontSize": "NumpadAdd"
			, "clearContent": "+Delete"
		},
		"joystick": {
			"pressKey": "Joy3"
			, "altReset": "Joy1"
			, "sendBackSpace": "Joy4"
			, "sendSpace": "Joy2"
			, "startNewLine": "!Joy2"
			, "submit": "Joy10"
			, "switchLayer": "!Joy3"
			, "decreaseFontSize": "Joy9"
			, "increaseFontSize": "!Joy9"
			, "clearContent": "!Joy1"
		}
	}
	)
	, window :=
	(LTrim Join C
		{
			"keyboard": {
				"showHide": "F1"
			},
			"joystick": {
				"showHide": "Joy12"
			}
		}
	)
}