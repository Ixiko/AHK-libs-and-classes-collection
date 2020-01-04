        ; Note: **** it seems when using *~LButton to monitor user mouse/drag position
        ; it stuffs up using *lbutton as a modifier for blocking the button press is still passed to the active window
        ; hence have to manually enter all the +^! combinations
        ; this does not work when placing the *modifier in front of the modifier+Lbutton Combos in bufferinput command
        ; hence why every key in the keylist file (except LbuttonMods) has the * modifier (saves having an If button contains Lbutton
        ; in the blocking section)
        ; Also need the plain " LButton " here

        ; **** note can't use critical with the buffer function as it will prevent the hotkeys running tracking input
        ; instead use :
		;	BatchLines := A_BatchLines
		;   	Thread, NoTimers, true
		;	SetBatchLines, -1

		;	SetBatchLines, %BatchLines%
		;	Thread, NoTimers, false ; dont think is required as the thread is about to end


        ; another possible way, though untested of buffering input would be to put the script into critical mode
        ; then  remap every 'blocked' key to itself - AHk should then buffer these and send them when critical ends

        ; Need to be wary of moving the mouse for clicks, as if input is blocked for a command which moves the mouse fast
        ; the clicks will probably be recorded somewhere different to where the user is intending to click!!
        ; Probably best to use Move MouseDuringClicks/Disable MouseBlocking only for automations which dont actually move the mouse
        ; Mouse blocking has two functions 1. During block on to block mousemovement
        ; 2. during send to either allow the mouse to move or to block movement

BufferInput(byref aKeys, Mode="Off", MouseBlocking=1, IgnoreHotkey="") {

 	STATIC aBuffer
	STATIC MouseButtons :=  "LButton,RButton,MButton,XButton1,XButton2"

	If (Mode = "Buffer")
		label := "g_bufferInput", aBuffer := []
	Else if (Mode = "RetrieveKeys")
		return aBuffer
	Else if (Mode = "Block")
		label := "g_Return", aBuffer := []
	Else if (Mode = "Send" || Mode = "Off")
	{
		MouseGetPos, Xstart, Ystart
		if (Mode = "Send")
		{
			for index, Button in aBuffer
			{
				if isObject(Button) ;so its a mouse button or at least has move co-ordinates
				{
					MouseHasMoved := !MouseBlocking
					x := Button.x, y := Button.y
					if InStr(Button.Button, "LButton") && !InStr(Button.Button, "UP") && !MouseBlocking ; so lbutton down (not up)
					{
						if modifiers := getModifiersFromString(Button.Button)
							send %modifiers%{click down %x%, %y%}
						else send {click down %x%, %y%}
					;	sleep, 5 ; some programs may require a sleep here - SC2 and many others don't.
						continue
					}
					else if InStr(Button.Button, "LButton Up") && MouseBlocking ;
						continue ; as don't need to send the lbutton up command as it was never held down
					else if !MouseBlocking
						send {click  %x%, %y%, 0} ;move the mouse
					Button := Button.Button
				}
				send % Button
			}

			if !GetKeyState("Lbutton", "P") && GetKeyState("Lbutton") 	; so if the button is up, but the game thinks it down
				send {click Up}  										; send and up command to unstick it - but doesnt seem to work here
			if !GetKeyState("Rbutton", "P") && GetKeyState("Rbutton")
				send {click Up Right}
			if MouseHasMoved
    			send {click  %Xstart%, %Ystart%, 0}

		}

		for index, Button in aKeys
			Try Hotkey, %Button%, Off


		BlockInput, MouseMoveOff
		CreateHotkeys()		;function which remakes the previously destroyed hotkeys
		return
    }
    else msgbox Error in BufferInput function mode
	if MouseBlocking
		BlockInput, MouseMove
	for index, Button in aKeys
		Try Hotkey, %Button%, %label%, On
	if IgnoreHotkey	;this hotkey will not be buffered - generally put the function hotkey here so it doesnt get spammed if the user holds it down for ages
	{				; Actually after, testing this probably isnt required as with 1 maxthread hotkey, that hotkey cant fire (and probably wont be reassigned above)
		StringReplace, IgnoreHotkey, IgnoreHotkey, ^
		StringReplace, IgnoreHotkey, IgnoreHotkey, +
		StringReplace, IgnoreHotkey, IgnoreHotkey, !
		Try Hotkey, *%IgnoreHotkey%, g_Return, On
	}
	return

	g_BufferInput:
	    pressedKey := Trim(A_ThisHotkey, " `t") ; trim spaces and tabs....probably not required
	    StringReplace, pressedKey, pressedKey, ^
		StringReplace, pressedKey, pressedKey, + ;	these are needed in case the hotkey/keyname in key list contains these modifiers
		StringReplace, pressedKey, pressedKey, !
		StringReplace, pressedKey, pressedKey, *

	    If (GetKeyState("CapsLock", "T") && !GetKeyState("Shift", "P"))
	    || !GetKeyState("CapsLock", "T") && !GetKeyState("Shift", "P")
	        pressedKey := setCase(0, pressedKey) ; change to lower case as the keys in 'pressed keys' are always in upper case
	    if pressedKey contains %MouseButtons% 	;	need to use contain as check for 'lbutton up' modifier/key
	    { 										;	e.g. "+LButton Up"	will still return true (but the + modifier is stripped above anyway)
	    	MouseGetPos, X, Y
	    	pressedKey := getModifierState() "{" pressedKey "}"
	    	MouseObject := {Button: pressedKey, x: x, y: y}
	    	aBuffer.insert(MouseObject)
	    	return
	    }
		if StrLen(pressedKey) > 1
		    pressedKey := "{" pressedKey "}"
	    aBuffer.insert(getModifierState() pressedKey)
	return

	g_Return:
	return
}

