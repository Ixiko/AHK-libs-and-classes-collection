/* 
 * this function is used when a hotkey combo is pressed. It directs the program to the appropriate function in the appropriate class
 */ 
JPGIncDesktopManagerCallback(desktopManager, functionName, keyCombo)
{
	desktopManager[functionName](getDesktopNumberFromHotkey(keyCombo))
	return
}

class JPGIncHotkeyManager
{
	_notAnAutohotkeyModKeyRegex := "[^#!^+<>*~$]"

	__new() 
	{
		return this
	}

	setupNumberedHotkey(callbackClass, callbackFunctionName, hotkeyKey)
	{
		if(this._doesHotkeyRequireCustomHotkeySyntax(hotkeyKey))
		{
			hotkeyKey .= " & "
		}
		Loop, 10
		{
			this.setupHotkey(callbackClass, callbackFunctionName, hotkeyKey (A_Index - 1))
		}
		return this
	}
	
	setupHotkey(callbackClass, callbackFunctionName, hotkeyKey)
	{
		;~ debugger("Setting up callback: " callbackFunctionName " as " hotkeyKey)
		callback := Func("JPGIncDesktopManagerCallback").Bind(callbackClass, callbackFunctionName, hotkeyKey)
		Hotkey, % hotkeyKey, % callback, On
		return this
	}
	
	/*
	 * If the modifier key used is only a modifier symbol then we don't need to do anything (https://autohotkey.com/docs/Hotkeys.htm#Symbols)
	 * but if it contains any other characters then it means that the hotkey is a combination hotkey then we need to add " & " 
	 */
	_doesHotkeyRequireCustomHotkeySyntax(key)
	{
		return RegExMatch(key, this._notAnAutohotkeyModKeyRegex)
	}
}