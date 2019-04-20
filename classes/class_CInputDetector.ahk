;------------------------------------------------------------------------------------------------------------
; Sets up the hooks etc to watch for input
; belongs to class_HotClass.ahk and class_radical.ahk
;------------------------------------------------------------------------------------------------------------
class CInputDetector {
	__New(callback, options := 0){
		if (options = 0){
			options := {}
		}
		this.options := options
		this._HooksEnabled := 0
		this._Callback := callback
		this._JoyUpFuncs := []
		
		this.EnableHooks()
	}
	
	EnableHooks(){
		static WH_KEYBOARD_LL := 13, WH_MOUSE_LL := 14
		
		if (this._HooksEnabled){
			return 1
		}
		
		this._HooksEnabled := 1

		; Hook Input
		this._hHookKeybd := this._SetWindowsHookEx(WH_KEYBOARD_LL, RegisterCallback(this._ProcessKHook,,,&this))
		this._hHookMouse := this._SetWindowsHookEx(WH_MOUSE_LL, RegisterCallback(this._ProcessMHook,,,&this))
		
		this._JoysticksWithHats := []
		Loop 8 {
			joyid := A_Index
			joyinfo := GetKeyState(joyid "JoyInfo")
			if (joyinfo){
				; watch buttons
				Loop % 32 {
					fn := this._ProcessJHook.Bind(this, joyid, A_Index)
					hotkey, % joyid "Joy" A_Index, % fn
					hotkey, % joyid "Joy" A_Index, On
				}
				this._JoyUpFuncs[joyid] := []
				; disablejoystick option is useful when debugging, so you do not keep getting interrupted by the settimer.
				; Watch POVs
				if (instr(joyinfo, "p")){
					this._JoysticksWithHats.push(joyid)
				}
			}
		}
		if (this.options.disablejoystickhats != 1){
			fn := this._WatchJoystickPOV.Bind(this)
			SetTimer, % fn, 10
		}
		return 1
	}
	
	DisableHooks(){
		if (!this._HooksEnabled){
			return 1
		}
		
		this._HooksEnabled := 0

		this._UnhookWindowsHookEx(this._hHookKeybd)
		this._UnhookWindowsHookEx(this._hHookMouse)

		this._JoysticksWithHats := []
		Loop 8 {
			joyid := A_Index
			joyinfo := GetKeyState(joyid "JoyInfo")
			if (joyinfo){
				; stop watching buttons
				Loop % 32 {
					hotkey, % joyid "Joy" A_Index, Off
				}
			}
		}
		fn := this._WatchJoystickPOV.Bind(this)
		SetTimer, % fn, Off
		return 1
	}
	
	; Process Joystick button down events
	_ProcessJHook(joyid, btn){
		;ToolTip % "Joy " joyid " Btn " btn
		this._Callback.({Type: "j", Code: btn, joyid: joyid, event: 1, uid: joyid "j" btn})
		fn := this._WaitForJoyUp.Bind(this, joyid, btn)
		SetTimer, % fn, -0
	}
	
	; Emulate up events for joystick buttons
	_WaitForJoyUp(joyid, btn){
		fn := this.__WaitForJoyUp.Bind(this, joyid, btn)
		this._JoyUpFuncs[joyid, btn] := fn
		SetTimer, % fn, 10
	}
	
	__WaitForJoyUp(joyid, btn){
		str := joyid "Joy" btn
		if (!GetKeyState(str)){
			fn := this._JoyUpFuncs[joyid, btn]
			SetTimer, % fn, Off
			this._Callback.({Type: "j", Code: btn, joyid: joyid, event: 0, uid: joyid "j" btn})
		}
		
	}
	
	; A constantly running timer to emulate "button events" for Joystick POV directions (eg 2JoyPOVU, 2JoyPOVD...)
	_WatchJoystickPOV(){
		static pov_states := [-1, -1, -1, -1, -1, -1, -1, -1]
		static pov_strings := ["1JoyPOV", "2JoyPOV", "3JoyPOV", "4JoyPOV", "5JoyPOV", "6JoyPOV" ,"7JoyPOV" ,"8JoyPOV"]
		static pov_direction_map := [[0,0,0,0], [1,0,0,0], [1,1,0,0] , [0,1,0,0], [0,1,1,0], [0,0,1,0], [0,0,1,1], [0,0,0,1], [1,0,0,1]]
		static pov_direction_states := [[0,0,0,0], [0,0,0,0], [0,0,0,0], [0,0,0,0], [0,0,0,0], [0,0,0,0], [0,0,0,0], [0,0,0,0]]
		Loop % this._JoysticksWithHats.length() {
			joyid := this._JoysticksWithHats[A_Index]
			pov := GetKeyState(pov_strings[joyid])
			if (pov = pov_states[joyid]){
				; do not process stick if nothing changed
				continue
			}
			if (pov = -1){
				state := 1
			} else {
				state := round(pov / 4500) + 2
			}
			
			Loop 4 {
				if (pov_direction_states[joyid, A_Index] != pov_direction_map[state, A_Index]){
					this._Callback.({Type: "h", Code: A_Index, joyid: joyid, event: pov_direction_map[state, A_Index], uid: joyid "h" A_Index})
				}
			}
			pov_states[joyid] := pov
			pov_direction_states[joyid] := pov_direction_map[state]
		}
	}
	
	; Process Keyboard Hook messages
	_ProcessKHook(wParam, lParam){
		; KBDLLHOOKSTRUCT structure: https://msdn.microsoft.com/en-us/library/windows/desktop/ms644967%28v=vs.85%29.aspx
		; KeyboardProc function: https://msdn.microsoft.com/en-us/library/windows/desktop/ms644984(v=vs.85).aspx
		static WM_KEYDOWN := 0x100, WM_KEYUP := 0x101, WM_SYSKEYDOWN := 0x104
		Critical
		
		if (this<0){
			Return DllCall("CallNextHookEx", "Uint", Object(A_EventInfo)._hHookKeybd, "int", this, "Uint", wParam, "Uint", lParam)
		}
		this:=Object(A_EventInfo)
		
		vk := NumGet(lParam+0, "UInt")
		Extended := NumGet(lParam+0, 8, "UInt") & 1
		sc := (Extended<<8)|NumGet(lParam+0, 4, "UInt")
		sc := sc = 0x136 ? 0x36 : sc
		event := wParam = WM_SYSKEYDOWN || wParam = WM_KEYDOWN
		
		if ( sc != 541 ){		; ignore non L/R Control. This key never happens except eg with RALT
			block := this._Callback.({ Type: "k", Code: sc, event: event, uid: "k" sc})
			if (block){
				return 1
			}
		}
		Return DllCall("CallNextHookEx", "Uint", Object(A_EventInfo)._hHookKeybd, "int", this, "Uint", wParam, "Uint", lParam)

	}
	
	; Process Mouse Hook messages
	_ProcessMHook(wParam, lParam){
		; MSLLHOOKSTRUCT structure: https://msdn.microsoft.com/en-us/library/windows/desktop/ms644970(v=vs.85).aspx
		static WM_LBUTTONDOWN := 0x0201, WM_LBUTTONUP := 0x0202 , WM_RBUTTONDOWN := 0x0204, WM_RBUTTONUP := 0x0205, WM_MBUTTONDOWN := 0x0207, WM_MBUTTONUP := 0x0208, WM_MOUSEHWHEEL := 0x20E, WM_MOUSEWHEEL := 0x020A, WM_XBUTTONDOWN := 0x020B, WM_XBUTTONUP := 0x020C
		static button_map := {0x0201: 1, 0x0202: 1 , 0x0204: 2, 0x0205: 2, 0x0207: 3, 0x208: 3}
		static button_event := {0x0201: 1, 0x0202: 0 , 0x0204: 1, 0x0205: 0, 0x0207: 1, 0x208: 0}
		Critical
		
		if (this<0 || wParam = 0x200){
			Return DllCall("CallNextHookEx", "Uint", Object(A_EventInfo)._hHookMouse, "int", this, "Uint", wParam, "Uint", lParam)
		}
		this:=Object(A_EventInfo)
		out := "Mouse: " wParam " "
		
		keyname := ""
		event := 0
		button := 0
		
		;if (IsObject(this._MouseLookup[wParam])){
		if (ObjHasKey(button_map, wParam)){
			; L / R / M  buttons
			button := button_map[wParam]
			event := button_event[wParam]
		} else {
			; Wheel / XButtons
			; Find HiWord of mouseData from Struct
			mouseData := NumGet(lParam+0, 10, "Short")
			
			if (wParam = WM_MOUSEHWHEEL || wParam = WM_MOUSEWHEEL){
				; Mouse Wheel - mouseData indicate direction (up/down)
				event := 1	; wheel has no up event, only down
				if (wParam = WM_MOUSEWHEEL){
					if (mouseData > 1){
						button := 6
					} else {
						button := 7
					}
				} else {
					if (mouseData < 1){
						button := 8
					} else {
						button := 9
					}
				}
			} else if (wParam = WM_XBUTTONDOWN || wParam = WM_XBUTTONUP){
				; X Buttons - mouseData indicates Xbutton 1 or Xbutton2
				if (wParam = WM_XBUTTONDOWN){
					event := 1
				} else {
					event := 0
				}
				button := 3 + mouseData
			}
		}

		block := this._Callback.({Type: "m", Code: button, event: event, uid: "m" button})
		if (wParam = WM_MOUSEHWHEEL || wParam = WM_MOUSEWHEEL){
			; Mouse wheel does not generate up event, simulate it.
			this._Callback.({Type: "m", Code: button, event: 0, uid: "m" button})
		}
		if (block){
			return 1
		}
		Return DllCall("CallNextHookEx", "Uint", Object(A_EventInfo)._hHookMouse, "int", this, "Uint", wParam, "Uint", lParam)
	}
	
	; ============= HOOK HANDLING =================
	_SetWindowsHookEx(idHook, pfn){
		Return DllCall("SetWindowsHookEx", "Ptr", idHook, "Ptr", pfn, "Uint", DllCall("GetModuleHandle", "Uint", 0, "Ptr"), "Uint", 0, "Ptr")
	}
	
	_UnhookWindowsHookEx(idHook){
		Return DllCall("UnhookWindowsHookEx", "Ptr", idHook)
	}
}
