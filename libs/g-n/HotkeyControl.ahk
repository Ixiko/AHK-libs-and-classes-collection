HotkeyControl(QuotedVarName, GuiNameOrHwnd, ControlOptions="w180 h20", InitialText="", InitialTextColor="Gray") {
	;v1.0.0 by A_Samurai http://sites.google.com/site/ahkref/libraries/hotkeycontrol
	Static HwndDummy, HwndHotkeyControl, Controls := [], OnMessageFunctions := []
	Static ThisFunc
	Static PreviousKey, ModifierKeyList := "Control,Shift,Alt,LWin,RWin", ClearControlStack := [] , MouseParamToVK := {1:1, 2:2, 0x10:4, 0x20:5, 0x40:6} ; L,R,M,X1,X2
	ThisFunc := A_ThisFunc
	
	If ControlOptions not in 256,513,516,519,260,523		;means it's not called from OnMessage(). The numbers are the monitoring messages.
	{ 	
		;check if the second parameter is a hwnd or name
		DHW := A_DetectHiddenWindows
		DetectHiddenWindows, On
		If !(GuiHwnd := WinExist("ahk_id " GuiNameOrHwnd)) {
			Gui, %GuiNameOrHwnd%:+LastFoundExist
			if !(GuiHwnd := WinExist())
				Return False
		}
		DetectHiddenWindows % DHW
		
		;build the hotkey control: there are two; the edit control and the dummy text control which is to steal the focus so that it hides the caret cursor 
		Gui, %GuiHwnd%: Font, c%InitialTextColor%
		Gui, %GuiHwnd%: Add, Edit, HwndHwndHotkeyControl %ControlOptions%, % InitialText
		GuiControlGet, GuiHotkeyControl, Pos, % HwndHotkeyControl
		DummyX := GuiHotkeyControlX + GuiHotkeyControlW, DummyY := GuiHotkeyControlY + GuiHotkeyControlH
		Gui, %GuiHwnd%: Add, Text, HwndHwndDummy x%GuiHotkeyControlX% y%DummyY% w%GuiHotkeyControlW% h0 
		ControlFocus,, ahk_id %HwndDummy%	;unhighlight the text
		Gui, %GuiHwnd%: Font, cDefault
		
		;store control information in the static objects for later use
		if (%QuotedVarName% = "")	;if ther is not value in the given variable
			HotkeyControl_GlobalVar(QuotedVarName)	;this creates a variable
		Controls[HwndHotkeyControl] := {VarName: QuotedVarName, GuiHwnd: GuiHwnd, InitialText: InitialText, InitialTextColor: InitialTextColor, HwndEditControl: HwndHotkeyControl, HwndDummyControl: HwndDummy, IsDummy: False}	;store the window reference
		Controls[HwndDummy] := {IsDummy: HwndHotkeyControl}
		
		;Register hotkeys to prevent the default Windoews key shortcuts and for arrow keys to be recognized.
		RegisterKeys := "*LWin|*RWin|^+Esc|*Up|*Down|*Left|*Right|Delete|BackSpace|NumpadLeft|NumpadRight|NumpadUp|NumpadDown"
		Hotkey, IfWinActive, ahk_id %GuiHwnd%
			Loop, Parse, RegisterKeys, |
				Hotkey, % A_LoopField, HotkeyControl_KeyDetectFixes
		Hotkey, IfWinActive
		
		;Monitor key and mouse presses 
		Messages := "0x100|0x201|0x204|0x207|0x0104|0x20B"		;WM_KEYDOWN|WM_LBUTTONDOWN|WM_MBUTTONDOWN|WM_SYSKEYDOWN|WM_XBUTTONDOWN
		Loop, Parse, Messages, |
		{
			;if a function is already assigned to this message, store the reference and call it after the execution of this function is done
			if ((AssignedFunc := OnMessage(A_LoopField)) <> A_ThisFunc) 
				if AssignedFunc
					OnMessageFunctions[A_LoopFIeld] := AssignedFunc
			OnMessage(A_LoopField, A_ThisFunc)	
		}
		
		Return HwndHotkeyControl
		
		HotkeyControl_KeyDetectFixes:	;invoked by the hotkeys
			; Retrieve the hwndFocus field from the struct.		
			GuiThreadInfoSize := 48
			VarSetCapacity(GuiThreadInfo, GuiThreadInfoSize)
			NumPut(GuiThreadInfoSize, GuiThreadInfo, 0)
			if not DllCall("GetGUIThreadInfo", uint, 0, str, GuiThreadInfo) 
				return
			ThisHotkeyControl := NumGet(GuiThreadInfo, 12)  
		
			;call the function
			if InStr(A_ThisHotkey, "LWin") 	
				PostMessage, 0x100, 0x5B, 0x15B0001,, ahk_id %ThisHotkeyControl%	; HotkeyControl(91, 22740993, 256, "MyEdit")		
			else if InStr(A_ThisHotkey, "RWin")
				PostMessage, 0x100, 0x5C, 0x15C0001,, ahk_id %ThisHotkeyControl%	; HotkeyControl(92, 22806529, 256, "MyEdit")
			else if (A_ThisHotkey = "^+Esc")
				PostMessage, 0x100, 0x1B, 0x10001,, ahk_id %ThisHotkeyControl%
			else if InStr(A_ThisHotkey, "*")	
				%ThisFunc%(LTrim(A_ThisHotkey, "*"), "", 256, ThisHotkeyControl)	;avoid Up/Down/Left/Right/Delete being NumpadUp/NumpadDown/NumpadLeft/NumpadRight
			else
				%ThisFunc%(A_ThisHotkey, "", 256, ThisHotkeyControl)		;NumpadLeft/NumpadRight/NumpadUp/NumpadDown is to prevent text highlighting. Delete is to avoid being NumpadDel. BackSpace is to avoid beepsounds.
		Return
	} else {
		;this section is for the OnMessage() call and retrieves the pressed keys and mouse buttons 
		
		;setup the variables
		wParam := QuotedVarName, lParam := GuiNameOrHwnd, msg := ControlOptions, HwndEditControl := InitialText , GuiHwnd := Controls[HwndEditControl].GuiHwnd

		;first execute previously regiesterd OnMessage() function.
		if (Function := OnMessageFunctions[msg])
			%Function%(wParam, lParam, msg, HwndEditControl)
		
		;if this is from the dummy control 
		if Controls[HwndEditControl].IsDummy
			HwndEditControl := Controls[HwndEditControl].IsDummy, GuiHwnd := Controls[HwndEditControl].GuiHwnd
		if !HwndEditControl || !GuiHwnd
			Return
		
		;Determine where this function is called and return it is not a valid calling place.
		If wParam in Up,Down,Left,Right,NumpadLeft,NumpadRight,NumpadUp,NumpadDown,Delete,BackSpace		;means either one of Up, Down, Left, or Right is pressed
			PressedKeyName := wParam
		else {
			if (msg < 0x200 && lParam & 1<<30) ; Not a mouse message && key-repeat.
				return 0	;0 prevents key repeats
			if (HwndEditControl <> Controls[HwndEditControl].HwndEditControl) && (HwndEditControl <> Controls[HwndEditControl].HwndDummyControl)	;make sure it's called from the edit control
				return
			if msg >= 0x201 ; Mouse message.
				wParam := MouseParamToVK[wParam & ~12] 
			SetFormat IntegerFast, H
			PressedKeyName := GetKeyName("VK" SubStr(wParam+0, 3))			
		}		

		;Detect pressed modifier keys
		NumPMods := PressedModifiers := WinKey := ""
		Loop, Parse, ModifierKeyList, `,
		{
			if NumPMods > 2      ;if more than three modifier keys are pressed. NumPMods starts from 0.
				break
			if WinKey && (InStr(PressedKeyName, "Win") || InStr(A_LoopFIeld, "Win"))    ;already either LWin or RWin has been pressed
				Continue
			If GetKeyState(A_LoopField, "P") {      ;if it is pressed
				PressedModifiers .= A_LoopField " + "
				NumPMods++
				if InStr(A_LoopField, "Win")
					WinKey := True
			}
		} 
		
		;initialize the text if the pressed key is Delete or Backspace 
		If PressedKeyName in Delete,Backspace
			if !PressedModifiers  {
				;initialize the edit box
				Gui, %GuiHwnd%: Font, % "c" Controls[HwndEditControl].InitialTextColor
				GuiControl, %GuiHwnd%: Font, % Controls[HwndEditControl].HwndEditControl
				ControlSetText,, % Controls[HwndEditControl].InitialText, % "ahk_id " Controls[HwndEditControl].HwndEditControl
				ControlFocus,, % "ahk_id " Controls[HwndEditControl].HwndDummyControl

				;update the associated variable 
				VarName := Controls[HwndEditControl].VarName
				HotkeyControl_UpdateVar(VarName, "")
			
				return
			}

		;make the text color the system defalut
		Gui, %GuiHwnd%: Font, cDefault
		GuiControl, %GuiHwnd%: Font, % Controls[HwndEditControl].HwndEditControl	
		
		;for Shift + NumpadN, check if Shift is the one sent by the system automatically 
		if RegexMatch(PreviousKey, "Numpad[^\d]") && InStr(PressedModifiers, "Shift") {
			PreviousKey := ""
			Return
		}
		If (PressedKeyName = "Shift") && !InStr(PressedModifiers, "Shift")		;this means the system sent Shift, not the user's
			Return
		PreviousKey := PressedKeyName
			
		;update the text in the hotkey edit control
		If PressedKeyName in %ModifierKeyList%
			ControlSetText,, % PressedModifiers, % "ahk_id " Controls[HwndEditControl].HwndEditControl
		Else {
			ControlSetText,, % PressedModifiers PressedKeyName, % "ahk_id " Controls[HwndEditControl].HwndEditControl		
			
			;convert the displayed text into the Autohotkey Hotkey format
			;update the associated variable 

			; GoSub, HotkeyControl_UpdateVariable
			DisplayedKeys := PressedModifiers PressedKeyName
			StringReplace, DefiningHotkeys, DisplayedKeys, +,, All
			StringReplace, DefiningHotkeys, DefiningHotkeys, LWin, <#, All
			StringReplace, DefiningHotkeys, DefiningHotkeys, RWin, >#, All
			StringReplace, DefiningHotkeys, DefiningHotkeys, Shift, +, All
			StringReplace, DefiningHotkeys, DefiningHotkeys, Control, ^, All
			StringReplace, DefiningHotkeys, DefiningHotkeys, Alt, !, All
			DefiningHotkeys := RegExReplace(DefiningHotkeys, "\s+", "")
			HotkeyControl_UpdateVar(Controls[HwndEditControl].VarName, DefiningHotkeys)	
		}
	
		;remove the flashing "|" sign from the edit control by setting the focus to a text control
		ControlFocus,, % "ahk_id " Controls[HwndEditControl].HwndDummyControl
		
		;clear the text value if it consists of only modifier keys.
		ObjInsert(ClearControlStack, HwndEditControl)
		SetTimer, HotkeyControl_ClearModifierOnlyValue, -500 
		
		Return 1				
		HotkeyControl_UpdateVariable:
			
		Return
		HotkeyControl_ClearModifierOnlyValue:
			if !(HwndEditControl := ObjRemove(ClearControlStack, ObjMaxIndex(ClearControlStack)))
				Return
			GuiHwnd := Controls[HwndEditControl].GuiHwnd
			ControlGetText, DisplayedKeys,, % "ahk_id " Controls[HwndEditControl].HwndEditControl
			if (SubStr(Trim(DisplayedKeys, A_Space), 0) = "+") {
				Loop, Parse, ModifierKeyList, `,
					If GetKeyState(A_LoopField, "P")       ;still holding down
						Return   
				;initialize the edit box
				Gui, %GuiHwnd%: Font, % "c" Controls[HwndEditControl].InitialTextColor
				GuiControl, %GuiHwnd%: Font, % Controls[HwndEditControl].HwndEditControl
				ControlSetText,, % Controls[HwndEditControl].InitialText, % "ahk_id " Controls[HwndEditControl].HwndEditControl
				ControlFocus,, % "ahk_id " Controls[HwndEditControl].HwndDummyControl
				
				;update the associated variable 
				HotkeyControl_UpdateVar(Controls[HwndEditControl].VarName, "")
		    }
		    if ObjMaxIndex(ClearControlStack)	;means there are still hotkey controls to initialize its text
				SetTimer,, -500
		Return
	}
	Return
}
HotkeyControl_GlobalVar(VarName) {
	;registers the given variable name in the variable list. This is only necessary if the variable hasn't been created.
	global
	%VarName% := %VarName%	
}
HotkeyControl_UpdateVar(VarName, Value) {
	;updates the given global variable
	global
	%VarName% := Value
}
;v1.0.0 2011/11/10 Initial Release.