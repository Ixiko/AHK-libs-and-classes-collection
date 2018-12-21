#NoEnv
/*
Handles binding of the hotkeys for Bind Mode
Runs as a separate thread to the main application,
so that bind mode keys can be turned on and off quickly with Suspend
*/
/*
#Persistent
#NoTrayIcon
#MaxHotkeysPerInterval 9999
autoexecute_done := 1
*/
class _BindMapper {
	DetectionState := 0
	static IOClasses := {AHK_Common: 0, AHK_KBM_Input: 0, AHK_JoyBtn_Input: 0, AHK_JoyHat_Input: 0}
	__New(CallbackPtr){
		this.Callback := ObjShare(CallbackPtr)
		;this.Callback := CallbackPtr
		; Instantiate each of the IOClasses specified in the IOClasses array
		for name, state in this.IOClasses {
			; Instantiate an instance of a class that is a child class of this one. Thanks to HotkeyIt for this code!
			; Replace each 0 in the array with an instance of the relevant class
			call:=this.base[name]
			this.IOClasses[name] := new call(this.Callback)
			; debugging string
			if (i)
				names .= ", "
			names .= name
			i++
		}
		if (i){
			;OutputDebug % "UCR| Bind Mode Thread loaded IOClasses: " names
		} else {
			OutputDebug % "UCR| Bind Mode Thread WARNING! Loaded No IOClasses!"
		}
		Suspend, On
		global InterfaceSetDetectionState := ObjShare(this.SetDetectionState.Bind(this))
	}
	
	; A request was received from the main thread to set the Dection state
	SetDetectionState(state, IOClassMappingsPtr){
		if (state == this.DetectionState)
			return
		IOClassMappings := {}
		IOClassMappings := this.IndexedToAssoc(ObjShare(IOClassMappingsPtr))
		for name, ret in IOClassMappings {
			;OutputDebug % "UCR| BindModeThread Starting watcher " name " with return type " ret
			this.IOClasses[name].SetDetectionState(state, ret)
		}
		this.DetectionState := state
	}
	
	; Converts an Indexed array of objects to an associative array
	; If you pass an associative array via ObjShare, you cannot enumerate it
	; So it is converted to an indexed array of objects, this converts it back.
	IndexedToAssoc(arr){
		ret := {}
		Loop % arr.length(){
			obj := arr[A_Index], ret[obj.k] := obj.v
		}
		return ret
	}

	; ==================================================================================================================

	class AHK_Common {
		__New(callback){
			this.Callback := callback
		}
		
		SetDetectionState(state, ReturnIOClass){
			;OutputDebug % "Turning Hotkeys " (state ? "On" : "Off")
			Suspend, % (state ? "Off", "On")
		}
	}
	
	; ==================================================================================================================
	class AHK_KBM_Input {
		static IOClass := "AHK_KBM_Input"
		DebugMode := 2
		
		__New(callback){
			this.Callback := callback
			this.CreateHotkeys()
		}

		SetDetectionState(state, ReturnIOClass){
			;this.ReturnIOClass := ( state ? ReturnIOClass : 0)
			this.ReturnIOClass := ReturnIOClass

		}

		; Binds a key to every key on the keyboard and mouse
		; Passes VK codes to GetKeyName() to obtain names for all keys
		; List of VKs: https://msdn.microsoft.com/en-us/library/windows/desktop/dd375731(v=vs.85).aspx
		; Keys are stored in the settings file by VK number, not by name.
		; AHK returns non-standard names for some VKs, these are patched to Standard values
		; Numpad Enter appears to have no VK, it is synonymous with Enter (VK0xD). Seeing as VKs 0xE to 0xF are Undefined by MSDN, we use 0xE for Numpad Enter.
		CreateHotkeys(){
			static replacements := {33: "PgUp", 34: "PgDn", 35: "End", 36: "Home", 37: "Left", 38: "Up", 39: "Right", 40: "Down", 45: "Insert", 46: "Delete"}
			static pfx := "$*"
			static updown := [{e: 1, s: ""}, {e: 0, s: " up"}]
			; Cycle through all keys / mouse buttons
			Loop 256 {
				; Get the key name
				i := A_Index
				code := Format("{:x}", i)
				if (ObjHasKey(replacements, i)){
					n := replacements[i]
				} else {
					n := GetKeyName("vk" code)
				}
				if (n = "")
					continue
				; Down event, then Up event
				Loop 2 {
					blk := this.DebugMode = 2 || (this.DebugMode = 1 && i <= 2) ? "~" : ""
					fn := this.InputEvent.Bind(this, updown[A_Index].e, i)
					hotkey, % pfx blk n updown[A_Index].s, % fn, % "On"
				}
			}
			i := 14, n := "NumpadEnter"	; Use 0xE for Nupad Enter
			Loop 2 {
				blk := this.DebugMode = 2 || (this.DebugMode = 1 && i <= 2) ? "~" : ""
				fn := this.InputEvent.Bind(this, updown[A_Index].e, i)
				hotkey, % pfx blk n updown[A_Index].s, % fn, % "On"
			}
			/*
			; Cycle through all Joystick Buttons
			Loop 8 {
				j := A_Index
				Loop % this.JoystickCaps[j].btns {
					btn := A_Index
					n := j "Joy" A_Index
					fn := this._JoystickButtonDown.Bind(this, 1, 2, btn, j)
					hotkey, % pfx n, % fn, % "On"
				}
			}
			*/
			critical off
		}
		
		InputEvent(e, i){
			;tooltip % "code: " i ", e: " e
			this.Callback.Call(e, i, 0, this.ReturnIOClass)
		}
	}
	
	; ==================================================================================================================
	class AHK_JoyBtn_Input {
		static IOClass := "AHK_JoyBtn_Input"
		DebugMode := 1
		JoystickCaps := []
		
		__New(callback){
			this.Callback := callback
			this.CreateHotkeys()
		}
		
		SetDetectionState(state, ReturnIOClass){
			;this.ReturnIOClass := ( state ? ReturnIOClass : 0)
			this.ReturnIOClass := ReturnIOClass
		}

		; Binds a key to every key on the keyboard and mouse
		; Passes VK codes to GetKeyName() to obtain names for all keys
		; List of VKs: https://msdn.microsoft.com/en-us/library/windows/desktop/dd375731(v=vs.85).aspx
		; Keys are stored in the settings file by VK number, not by name.
		; AHK returns non-standard names for some VKs, these are patched to Standard values
		; Numpad Enter appears to have no VK, it is synonymous with Enter (VK0xD). Seeing as VKs 0xE to 0xF are Undefined by MSDN, we use 0xE for Numpad Enter.
		CreateHotkeys(){
			static updown := [{e: 1, s: ""}, {e: 0, s: " up"}]
			this.GetJoystickCaps()
			Loop 8 {
				j := A_Index
				Loop % this.JoystickCaps[j].btns {
					btn := A_Index
					n := j "Joy" A_Index
					fn := this.InputEvent.Bind(this, 1, btn, j)
					hotkey, % n, % fn, % "On"
					fn := this.InputEvent.Bind(this, 0, btn, j)
					hotkey, % n " up", % fn, % "On"
				}
			}
		}
		
		GetJoystickCaps(){
			Loop 8 {
				cap := {}
				cap.btns := GetKeyState(A_Index "JoyButtons")
				this.JoystickCaps.push(cap)
			}
		}
		
		InputEvent(e, i, deviceid){
			this.Callback.Call(e, i, deviceid, this.ReturnIOClass)
		}
	}

	; ==================================================================================================================
	class AHK_JoyHat_Input {
		static IOClass := "AHK_JoyHat_Input"
		DebugMode := 1
		HatStrings := {}
		
		__New(callback){
			this.Callback := callback
			Loop 8 {
				ji := GetKeyState(A_Index "JoyInfo")
				if (InStr(ji, "P")){
					this.HatStrings[A_Index "JoyPov"] := {DeviceID: A_Index, State: -1}
				}
			}
			this.HatWatcherFn := this.HatWatcher.Bind(this)
		}
		

		SetDetectionState(state, ReturnIOClass){
			;this.ReturnIOClass := ( state ? ReturnIOClass : 0)
			this.ReturnIOClass := ReturnIOClass
			fn := this.HatWatcherFn
			t := state ? 10 : "Off"
			SetTimer, % fn, % t
		}
		
		HatWatcher(){
			for bindstring, obj in this.HatStrings {
				state := GetKeyState(bindstring)
				if (obj.state == -1 && state != -1){
					; Press
					e := 1
				} else if (obj.state != -1 && state == -1){
					; Release
					e := 0
				} else {
					; No Change / Bad values
					continue
				}
				i := state == -1 ? -1 : (round(state / 9000) + 1)
				DeviceID := obj.DeviceID
				obj.state := state
				this.Callback.Call(e, i, deviceid, this.ReturnIOClass)
			}
		}
	}
}
