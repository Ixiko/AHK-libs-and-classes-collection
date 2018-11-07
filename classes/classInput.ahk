
; As Im not accounting for mouse buttons (just want to see how well this works)
; make sure to check Mousebuttons are not down before calling releaseKeys()
; Same with Windows keys (as releasing these will cause the windows menu to appear) - although the automation
; may still work

; Note** Do not call releaseKeys() (this used sendInput) while thread is in critical! As the LL-Hooks wont process the input
; until the thread comes out of critical, or an AHK sleep command is used.
; pReleaseKeys uses post message and is find to use while in critical
; Also note, any AHK command which has an internal sleep (including eg controlsend) will cause AHK to check its msg queue
; and the hooks will then process any user pressed key which could interrupt the automation!


; I've just realised sendPlay probably performs  exactly the same as my pSendInput :(
; Though i haven't tested it but it seems that the only difference is it always sends keys to
; the active window
; also it wont work on vista and above while UAC is enabled unless you use
; a script to digitally sign the exe, but then you cant modify the exe as this would
; invalidate the signature

; I probably wasted ages working on this input function and it wasnt required lol
; but at least I know how pSend works 

class Input 
{
;	static keys := ["LControl", "RControl", "LAlt", "RAlt", "LShift", "RShift", "LWin", "RWin"
	static keys := ["Control", "Alt", "Shift", "LWin", "RWin"  ; use neurtral modifiers as postmessage cant release left/right
				, "AppsKey", "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12"
				, "Left", "Right", "Up", "Down", "Home", "End", "PgUp", "PgDn", "Del", "Ins", "BS", "Capslock", "Numlock", "PrintScreen" 
				, "Pause", "Space", "Enter", "Tab", "Esc", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "B", "C", "D", "E", "F", "G"
				, "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
	 	, aMouseClickButtons := {  "LButton": "L" 	; converts Lbutton or xbutton2 etc into L, x2
								, "RButton": "R"
								, "MButton": "M"
								, "XButton1": "X1"
								, "XButton2": "X2" }
	 	,	MouseButtons := ["LButton", "RButton", "MButton", "XButton1", "XButton2"]
		,	downSequence
		,	MouseBlocked := False
		,	KybdBlocked := False
		, 	pCurrentClickDelay := -1
		, 	pClickPressDuration := -1
		, 	pCurrentSendDelay := -1
		,	pSendPressDuration := -1
		, 	pCurrentCharDelay := -1
		, 	dragLeftClick := False
		, 	LastLeftClickX, LastLeftClickY
		;,	lastKeyboardTick, lastMouseTick
		, 	Control, WinTitle, WinText,	ExcludeTitle, ExcludeText

	; Very Important Note about logical and physical hotkey states
	; if the hotkey has no modifiers, then physical state will be down
	; and the logical will be up (as expected)
	; But if the hotkey has modifiers
	; then both the hotkey key and its modifiers will be physically AND logically down!! 

	releaseKeys(checkMouse := False)
	{
		this.downSequence := this.dragLeftClick := ""
		SetFormat, IntegerFast, hex
		for index, key in this.keys 
		{
			if GetKeyState(key) 	; check the logical state (as AHK will block the physical)
			{
				; This masks the windows keyup - if its seen as coming up by itself it will make the win bar appear
				; i.e. just as if you pressed it by itself. (This is how AHK does it)
				; This isn't needed when releasing vis postmessage.

				if (key = "LWin" || key = "RWin")
					upsequence .= "{LControl Down}{LControl Up}"

				upsequence .= "{VK" GetKeyVK(key) " Up}", this.downSequence .= "{" key " Down}" 
			}
		}
		SetFormat, IntegerFast, d
		if checkMouse
		{
			for index, key in this.MouseButtons 
			{
				if GetKeyState(key) 	; check the logical state
				{
					key := this.aMouseClickButtons[key]
					upsequence .= "{click " key " Up}"
					if instr(key, "l") ; for left button drag click
					{
						this.dragLeftClick := True
						this.downSequence .= "{click " input.LastLeftClickX " " input.LastLeftClickY " " key " Down}"
					}
					else this.downSequence .= "{click " key " Down}"
				}
			}
		}
		if upsequence
		{
			SendInput, {BLIND}%upsequence%
			return upsequence 	; This will indicate that we should sleep for 15ms (after activating critical)
		}	 					; to prevent out of order command sequence with sendinput vs. post message
		return 
	}

	; To restore box drags correctly requires a pass through hotkey on lbutton 
	; So we can determine the x, y location of the start of the box drag
	; i.e.
	; *~LButton::
	;	input.setLastLeftClickPos()
	;	return
	setLastLeftClickPos()
	{
		MouseGetPos, x, y
		input.LastLeftClickX := x
		input.LastLeftClickY := y
		return
	}

	; If not blocking input, i.e. just buffering/placing thread in critical then can release 
	; pressed keys using postmessage without fear of getting stuck keys outside of sc 
	; Technically I guess you should have a 10ms buffer after starting critical before calling this
	; but i haven't noticed the need.

	pReleaseKeys(checkMouse := False)
	{
		this.downSequence := this.dragLeftClick := ""
		for index, key in this.keys 
			if GetKeyState(key) 	; check the logical state (as AHK will block the physical)
				upsequence .= "{" key " Up}", this.downSequence .= "{" key " Down}" 
		if checkMouse
		{
			for index, key in this.MouseButtons 
			{
				if GetKeyState(key) 	; check the logical state
				{
					key := this.aMouseClickButtons[key]
					upsequence .= "{click " key " Up}"
					if instr(key, "l") ; for left button drag click
						this.dragLeftClick := True, this.downSequence .= "{click " input.LastLeftClickX " " input.LastLeftClickY " " key " Down}" 	
					else this.downSequence .= "{click " key " Down}"
					
				}
					
			}
		}
		if upsequence
		{
			this.pSend(upsequence)
			return upsequence 	; This will indicate that we should sleep for 15ms (after activating critical)
		}	 					; to prevent out of order command sequence with sendinput vs. post message
		return 
	}

	revertKeyState()
	{
		if this.downSequence
		{
			this.pSend(this.downSequence)
			if this.dragLeftClick
			{
				; SetCursorPos is so the green box drag will appear in SC.
				; otherwise the box drag wont appear until the user moves the mouse 
				MouseGetPos, x, y
				dllcall("SetCursorPos", "int", x, "int", y)
			}	
		}
		return							
	}

	; the new command is handy if you wish to send input to multiple programs
	; inputSC2 := new input(, "Starcraft II")
	; inputSC2.pSendChars("Hello World!")
	__new(Control := "", winTitle := "", winText := "", excludeTitle := "", excludeText := "")
	{
		this.Control := control 
		this.WinTitle := winTitle 
		this.WinText := winText
		this.ExcludeTitle := excludeTitle 
		this.ExcludeText := excludeText
		return this
	}

	; The same as:
	; 			input.KybdBlocked := 1/0, input.MouseBlocked := 1/0
	hookBlock(kybd := False, mouse := False)
	{
		input.KybdBlocked := kybd
		input.MouseBlocked := mouse
		return
	}

	; This command can be used with the similar syntax as AHKs sendInput command
	; pSend("^+ap") 		Result:	Control+Shift+a p
	; pSend("+{click}")		Result: Shift Left click the mouse (down and up event)
	; pSend("{click D " x1 " " y1 "}{Click U " x2 " " y2 "}") ; Result: Box drag the mouse with the LButton
	; pSend("+{click MM}")		Result: Shift Left click the mouse (down and up event) at current location and also send a WM_MouseMove event
	
	; Tabs, spaces and new lines can also be sent. 
	; Their escaped character representations will also work
	; pSend("`n`thello") Would start a tabbed new line with the word 'hello'
	
	; Notes:
	; This is designed to send exact key presses. For example psend("AB CD") 
	; would send "ab cd" - non capitalised. 
	; Depending on the program, pSend("{shift down}ab cd{shift up}") or psend("+a+b +c+d") may capitalise the text
	; But for most purposes, it is better to use pSendChars() to send lengths of text to text/input fields.
	; For example pSendChars("I ♥ NY!") will appear as "I ♥ NY!"
	; Note: For game chat boxes, you will have to use pSend("{Enter}") to open and then send/close
	; the chat box
	;
	; Repeating a keypress like {a 12} is not supported


/*
Bits	Meaning
0-15	The repeat count for the current message. The value is the number of times the keystroke is autorepeated as a result of the user holding down the key. The repeat count is always 1 for a WM_KEYUP message.
16-23	The scan code. The value depends on the OEM.
24		Indicates whether the key is an extended key, such as the right-hand ALT and CTRL keys that appear on an enhanced 101- or 102-key keyboard. The value is 1 if it is an extended key; otherwise, it is 0.
25-28	Reserved; do not use.
29		The context code. The value is always 0 for a WM_KEYUP message.
30		The previous key state. The value is always 1 for a WM_KEYUP message.
31		The transition state. The value is always 1 for a WM_KEYUP message.

If you want to send text to a text box/field, consider using the pSendChar
It is capable of sending capitalised letters, as well as non-Standard ACII chars eg ♥
*/
	
	pSend(Sequence := "")
	{
		static 	WM_KEYDOWN := 0x100
				, WM_KEYUP := 0x101

		pKeyDelay := this.pCurrentSendDelay
		pClickDelay := this.pCurrentClickDelay

		SetFormat, IntegerFast, hex
		aSend := []
		C_Index := 1
	;	StringReplace, Sequence, Sequence, `t , %A_Space%, All ;Removed 20/02/14 so a space will generate a space

		Currentmodifiers := []
		length := strlen(Sequence) 
		while (C_Index <= length)
		{
			char := SubStr(Sequence, C_Index, 1)
		/* Removed 20/02/14	
			if (char = " ")
			{
				C_Index++
				continue
			}
		*/
			if char in +,^,!
			{		
				if (char = "+")
					Modifier := "Shift"
				else if (char = "^")
					Modifier := "Ctrl"
				else 
					Modifier :="Alt"

				CurrentmodifierString .= char
				Currentmodifiers.insert( {"wParam": GetKeyVK(Modifier) 
								, "sc": GetKeySC(Modifier)})			

				aSend.insert({	  "message": WM_KEYDOWN
								, "sc": GetKeySC(Modifier)
								, "wParam": GetKeyVK(Modifier)})
				C_Index++
				continue
				
			}
			if (char = "{") 								; send {}} will fail with this test. It could be fixed with another if statement
			{ 												; but cant use that key anyway, as a ] is really shift+] 
				if (Position := instr(Sequence, "}", False, C_Index, 1)) ; lets find the closing bracket) n
				{
					key := trim(substr(Sequence, C_Index+1, Position -  C_Index - 1))
					C_Index := Position ;PositionOfClosingBracket
					while instr(key, A_space A_space) ; loops needed to ensure only 1 space eg "ab           ba"
						StringReplace, key, key, %A_space%%A_space%, %A_space%, All
					StringReplace, key, key, `t,, All ;added 20/02/14			
					if instr(key, "click")
					{
						StringReplace, key, key, click ; remove the word click
					   	StringSplit, clickOutput, key, %A_space%, %A_Space%%A_Tab%`,
					    numbers := []
					    SetFormat, IntegerFast, d ; otherwise A_Index is 0x and doesnt work with var%A_Index%
					    loop, % clickOutput0
					    {
					    	command := clickOutput%A_index% 
					        if command is number
					            numbers.insert(command)    
					    }
					   
					    if (!numbers.maxindex() || numbers.maxindex() = 1)
					    {
					        MouseGetPos, x, y  ; will cause problems if send hex number to insertpClickObject
					        clickCount := numbers.maxindex() ? numbers.1 : 1
					    }
					    else if (numbers.maxindex() = 2 || numbers.maxindex() = 3)
					        x := numbers.1, y := numbers.2, clickCount := numbers.maxindex() = 3 ? numbers.3 : 1
					    else 
					    {
					    	SetFormat, IntegerFast, hex
					    	continue ; error
					    }	 
					    SetFormat, IntegerFast, hex
					    this.insertpClickObject(aSend, x, y, key, clickCount, CurrentmodifierString, instr(key, "MM")) ; MM - Insert MouseMove
						skip := True ; as already inserted a mouse click event
					}
					else 
					{
						StringSplit, outputKey, key, %A_Space%
						if (outputKey0 = 2)
						{
							aSend.insert({	  "message": instr(outputKey2, "Down") ? WM_KEYDOWN : WM_KEYUP
											, "sc": GetKeySC(outputKey1)
											, "wParam": GetKeyVK(outputKey1)})
							skip := True  ; as already inserted the key			
						}
						else 
							char := outputKey1
					}
				}
				else skip := True ; something went wrong
			}

			if skip
				skip := False
			else 
			{
				loop, 2
					aSend.insert({	  "message": A_Index = 1 ? WM_KEYDOWN : WM_KEYUP
									, "sc": GetKeySC(char)
									, "wParam": GetKeyVK(char)})
			}

			if Modifier
			{
				for index, modifier in Currentmodifiers
					aSend.insert({	  "message": WM_KEYUP
									, "sc": modifier.sc
									, "wParam": modifier.wParam})
				Modifier := False
				CurrentmodifierString := "", Currentmodifiers := []
			}
			C_Index++
		}
		SetFormat, IntegerFast, d


		for index, message in aSend
		{
			
			if (WM_KEYDOWN = message.message)
			{
				 ; repeat code | (scan code << 16)
				lparam := 1 | (message.sc << 16)
				postmessage, message.message, message.wParam, lparam, % this.Control, % this.WinTitle, % this.WinText, % this.ExcludeTitle, % this.ExcludeText
				if (this.pSendPressDuration != -1)
					DllCall("Sleep", Uint, this.pSendPressDuration)		
			
			}
			else if (WM_KEYUP = message.message)
			{
				 ; repeat code | (scan code << 16) | (previous state << 30) | (transition state << 31)
				lparam := 1 | (message.sc << 16) | (1 << 30) | (1 << 31)
				postmessage, message.message, message.wParam, lparam, % this.Control, % this.WinTitle, % this.WinText, % this.ExcludeTitle, % this.ExcludeText
				if (pKeyDelay != -1)
					DllCall("Sleep", Uint, pClickDelay)			
			}
			else 
			{
				; If mouse move is included it actually moves the mouse for an instant!!
				postmessage, message.message, message.wParam, message.lparam, % this.Control, % this.WinTitle, % this.WinText, % this.ExcludeTitle, % this.ExcludeText
				if (message.HasKey("delay") && message.delay != -1)
					DllCall("Sleep", Uint, message.delay)
			}

		}
		return aSend
	}
	; for use in chat boxes
	; can send ascii art and capitalised letters i.e. just text  eg GLF♥HF! 
	; if shift key is down sending a "." wont do anything in notepad
	pSendChars(Sequence := "")
	{
		static WM_CHAR := 0x102
		
		loop, % strlen(Sequence) 
		{
			char := SubStr(Sequence, A_Index, 1)
			postmessage, WM_CHAR, Asc(char),, % this.Control, % this.WinTitle, % this.WinText, % this.ExcludeTitle, % this.ExcludeText
			if (this.pCurrentCharDelay != -1)
				DllCall("Sleep", Uint, this.pCurrentCharDelay)
		}	
		return	
	}

	; wParam Indicates whether various virtual keys are down. This parameter can be one or more of the following values.
	; but doesnt seem to affect sc2

	; Note WM_MOUSEMOVE May be required in some situations. E.g. when the chat box is up and the cursor is not 
	; in the viewport e.g over the control cards


	pClick(x, y, button := "L", count := 1, Modifiers := "", MouseMove := False)
	{
		static	  WM_MOUSEFIRST := 0x200
				, WM_MOUSEMOVE = 0x200
				, WM_LBUTTONDOWN = 0x201
				, WM_LBUTTONUP = 0x202
				, WM_LBUTTONDBLCLK = 0x203  	; double click
				, WM_RBUTTONDOWN = 0x204
				, WM_RBUTTONUP = 0x205
				, WM_RBUTTONDBLCLK = 0x206
				, WM_MBUTTONDOWN = 0x207
				, WM_MBUTTONUP = 0x208
				, WM_MBUTTONDBLCLK = 0x209
				, WM_MOUSEWHEEL = 0x20A
				, WM_MOUSEHWHEEL = 0x20E
				, WM_XBUTTONDOWN := 0x020B
				, WM_XBUTTONUP := 0x020C
				, MK_LBUTTON := 0x0001
				, MK_RBUTTON := 0x0002
				, MK_SHIFT := 0x0004
				, MK_CONTROL := 0x0008
				, MK_MBUTTON := 0x0010
				, MK_XBUTTON1 := 0x0020
				, MK_XBUTTON2 := 0x0040


		pKeyDelay :=  this.pCurrentClickDelay
		lParam := x & 0xFFFF | (y & 0xFFFF) << 16
		WParam := 0 ; Needed for the |= to work

		if instr(Modifiers, "+")
			WParam |= MK_SHIFT
		if instr(Modifiers, "^")
			WParam |= MK_CONTROL
		if instr(Modifiers, "x1")
			WParam |= MK_XBUTTON1
		if instr(Modifiers, "x2")
			WParam |= MK_XBUTTON2
		if MouseMove
			PostMessage, %WM_MOUSEMOVE%, , %lParam%, % this.Control, % this.WinTitle, % this.WinText, % this.ExcludeTitle, % this.ExcludeText

		if button contains r
			message := "WM_RBUTTON", WParam |= MK_RBUTTON
		else if button contains M 
			message := "WM_MBUTTON", WParam |= MK_MBUTTON
		else if button contains x1 
			message := "WM_XBUTTON", WParam |= MK_XBUTTON1
		else if button contains x2 
			message := "WM_XBUTTON", WParam |= MK_XBUTTON2
		else if button contains WheelUp,WU,WheelDown,WD  
		{
			if button contains WheelUp,WU
				direction := 1
			else direction := -1
			WParam |= (direction * count * 120)  << 16
			PostMessage, %WM_MOUSEWHEEL%, %WParam%, %lParam%, % this.Control, % this.WinTitle, % this.WinText, % this.ExcludeTitle, % this.ExcludeText
			if (pKeyDelay != -1)
				DllCall("Sleep", Uint, pKeyDelay)			
			return	
		}
		else message := "WM_LBUTTON", WParam |= MK_LBUTTON
		; remove the word button eg Lbutton as the U will cause an UP-event to be sent
		StringReplace, button, button, button, %A_Space%, All
		if button contains up,U
			message .= "UP", delay := this.pCurrentClickDelay
		else if button contains down,D 
		 	message .= "DOWN", delay := this.pClickPressDuration
		else 
		{
			mdown := message . "DOWN"
			mup := message . "UP"
			mdown := %mdown%
			mup := %mup%
			loop % count 
			{
				PostMessage, %mdown%, %WParam%, %lParam%, % this.Control, % this.WinTitle, % this.WinText, % this.ExcludeTitle, % this.ExcludeText
				if (this.pSendPressDuration != -1)
					DllCall("Sleep", Uint, this.pSendPressDuration)				
				PostMessage, %mup%, %WParam%, %lParam%, % this.Control, % this.WinTitle, % this.WinText, % this.ExcludeTitle, % this.ExcludeText
				if (pKeyDelay != -1)
					DllCall("Sleep", Uint, pKeyDelay)
			}	
			return	
		}
		message := %message%
		PostMessage, %message%, %WParam% , %lParam%, % this.Control, % this.WinTitle, % this.WinText, % this.ExcludeTitle, % this.ExcludeText
		if (delay != -1)
			DllCall("Sleep", Uint, delay)
		return
	}

	insertpClickObject(ByRef sendObject, x, y, button := "L", count := 1, Modifiers := "", MouseMove := False)
	{
		static	  WM_MOUSEFIRST := 0x200
				, WM_MOUSEMOVE = 0x200
				, WM_LBUTTONDOWN = 0x201
				, WM_LBUTTONUP = 0x202
				, WM_LBUTTONDBLCLK = 0x203  	; double click
				, WM_RBUTTONDOWN = 0x204
				, WM_RBUTTONUP = 0x205
				, WM_RBUTTONDBLCLK = 0x206
				, WM_MBUTTONDOWN = 0x207
				, WM_MBUTTONUP = 0x208
				, WM_MBUTTONDBLCLK = 0x209
				, WM_MOUSEWHEEL = 0x20A
				, WM_MOUSEHWHEEL = 0x20E
				, WM_XBUTTONDOWN := 0x020B
				, WM_XBUTTONUP := 0x020C
				, MK_LBUTTON := 0x0001
				, MK_RBUTTON := 0x0002
				, MK_SHIFT := 0x0004
				, MK_CONTROL := 0x0008
				, MK_MBUTTON := 0x0010
				, MK_XBUTTON1 := 0x0020
				, MK_XBUTTON2 := 0x0040

		lParam := x & 0xFFFF | (y & 0xFFFF) << 16
		WParam := 0 ; Needed for the |= to work

		if instr(Modifiers, "+")
			WParam |= MK_SHIFT
		if instr(Modifiers, "^")
			WParam |= MK_CONTROL
		if instr(Modifiers, "x1")
			WParam |= MK_XBUTTON1
		if instr(Modifiers, "x2")
			WParam |= MK_XBUTTON2

		if MouseMove
			sendObject.insert({ "message": WM_MOUSEMOVE
							, "lParam": lParam})

		if button contains r
			message := "WM_RBUTTON", WParam |= MK_RBUTTON
		else if button contains M 
			message := "WM_MBUTTON", WParam |= MK_MBUTTON
		else if button contains x1 
			message := "WM_XBUTTON", WParam |= MK_XBUTTON1
		else if button contains x2 
			message := "WM_XBUTTON", WParam |= MK_XBUTTON2
		else if button contains WheelUp,WU,WheelDown,WD  
		{
			if button contains WheelUp,WU
				direction := 1
			else direction := -1
			
			sendObject.insert({ "message": WM_MOUSEWHEEL
							, "wParam": WParam |= (direction * count * 120)  << 16
							, "lParam": lParam
							, "delay": this.pCurrentClickDelay})
			return	
		}
		else message := "WM_LBUTTON", WParam |= MK_LBUTTON
		; remove the word button eg Lbutton as the U will cause an UP-event to be sent
		StringReplace, button, button, button, %A_Space%, All
		
		if button contains up,U
			message .= "UP", delay := this.pCurrentClickDelay
		else if button contains down,D 
		 	message .= "DOWN", delay := this.pClickPressDuration
		else 
		{
			mdown := message . "DOWN"
			mup := message . "UP"
			loop % count 
			{
				sendObject.insert({ "message": %mdown%
								, "wParam": WParam
								, "lParam": lParam
								, "delay": this.pClickPressDuration})

				sendObject.insert({ "message": %mup%
					, "wParam": WParam
					, "lParam": lParam
					, "delay": this.pCurrentClickDelay})
			}	
			return
		}

		sendObject.insert({ "message": %message%
							, "wParam": WParam
							, "lParam": lParam
							, "delay": delay})
		return
	}
}
