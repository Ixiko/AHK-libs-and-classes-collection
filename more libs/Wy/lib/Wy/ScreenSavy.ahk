class ScreenSavy {
	/*
	Class: ScreenSaver
	Working with standard windows ScreenSaver
		
	Authors:
	<hoppfrosch at hoppfrosch@gmx.de>: Original	
		
	About: License
	This program is free software. It comes without any warranty, to the extent permitted by applicable law. You can redistribute it and/or modify it under the terms of the Do What The Fuck You Want To Public License, Version 2, as published by Sam Hocevar. See <WTFPL at http://www.wtfpl.net/> for more details.	
	*/
	_version := "0.1.0"
	
	; ##################### Start of Properties ############################################################################
	activated[] {
	/* ------------------------------------------------------------------------------- 
	Property: activated [get/set]
	Get/Set whether the screensaver is activated
	
	Value:
	flag - *1* or *0* (activates/deactivates Screensaver)
	
	Remarks:		
	* To toogle, simply use
	ScreenSaver.activated := !ScreenSaver.activated
	*/
		get {
			return RegRead("HKEY_CURRENT_USER\Control Panel\Desktop", "ScreenSaveActive")
		}
		set {
			if (value != 0) {
				value := 1
			}
			RegWrite(value, "REG_SZ", "HKEY_CURRENT_USER\Control Panel\Desktop", "ScreenSaveActive")
			return this.activated
		}
	}
	exe[] {
	/* ------------------------------------------------------------------------------- 
	Property: exe [get/set]
	Get/Set the screensaver executable
	
	Value:
	value - screensaver executable
	*/
		get {
			return RegRead("HKEY_CURRENT_USER\Control Panel\Desktop", "SCRNSAVE.EXE")
		}
		set {
			if FileExist(value) {
				RegWrite(value, "REG_SZ", "HKEY_CURRENT_USER\Control Panel\Desktop", "SCRNSAVE.EXE")
			}
			return this.exe
		}
	}
	secured[] {
	/* ------------------------------------------------------------------------------- 
	Property: secured [get/set]
	Get/Set whether the screensaver is secured
	
	Value:
	flag - *1* or *0* (activates/deactivates password protected screensaver)
	
	Remarks:		
	* To toogle, simply use
	ScreenSaver.secured := !ScreenSaver.secured
	*/
		get {
			return RegRead("HKEY_CURRENT_USER\Control Panel\Desktop", "ScreenSaverIsSecure")
		}
		set {
			if (value != 0) {
				value := 1
			}
			RegWrite(value, "REG_SZ", "HKEY_CURRENT_USER\Control Panel\Desktop", "ScreenSaverIsSecure")
			return this.secured
		}
	}
	timeout[] {
	/* ------------------------------------------------------------------------------- 
	Property: timeout [get/set]
	Get/Set whether the screensaver timeout (in sec)
	
	Value:
	value - timeout of screensaver (in sec)
	*/
		get {
			return RegRead("HKEY_CURRENT_USER\Control Panel\Desktop", "ScreenSaveTimeOut")
		}
		set {
			if (value < 0) {
				value := 0
			}
			RegWrite(value, "REG_SZ", "HKEY_CURRENT_USER\Control Panel\Desktop", "ScreenSaveTimeOut")
			return this.timeout
		}
	}
}