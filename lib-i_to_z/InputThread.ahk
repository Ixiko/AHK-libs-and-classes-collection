; Can use  #Include %A_LineFile%\..\other.ahk to include in same folder
Class _InputThread {
	static IOClasses := {AHK_KBM_Input: 0, AHK_JoyBtn_Input: 0, AHK_JoyHat_Input: 0}
	DetectionState := 0
	UpdateBindingQueue := []	; An array of bindings waiting to be updated.
	UpdatingBindings := 0
	ControlMappings := {}
	
	__New(ProfileID, CallbackPtr){
		this.Callback := ObjShare(CallbackPtr)
		;this.Callback := CallbackPtr
		this.ProfileID := ProfileID ; Profile ID of parent profile. So we know which profile this thread serves
		names := ""
		i := 0
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
			; OutputDebug % "UCR| Input Thread loaded IOClasses: " names
		} else {
			OutputDebug % "UCR| Input Thread WARNING! Loaded No IOClasses!"
		}
		
		; Set up interfaces that the main thread can call
		global InterfaceUpdateBinding := ObjShare(this.UpdateBinding.Bind(this))
		;global InterfaceUpdateBindings := ObjShare(this.UpdateBindings.Bind(this))
		global InterfaceSetDetectionState := ObjShare(this.SetDetectionState.Bind(this))
		
		; Get a boundfunc for the method that processes binding updates
		;this.BindingQueueFn := this._ProcessBindingQueue.Bind(this)
		
		; Unreachable dummy label for hotkeys to bind to to clear binding
		if(0){
			UCR_INPUTHREAD_DUMMY_LABEL:
				return
		}

	}

	UpdateBinding(ControlGUID, boPtr){
		bo := ObjShare(boPtr).clone()
		iom := this.ControlMappings[ControlGuid]
		if (this.ControlMappings.HasKey(ControlGuid) && iom != bo.IOClass){
			this.IOClasses[iom].RemoveBinding(ControlGUID)
		}
		this.ControlMappings[ControlGuid] := bo.IOClass
		;OutputDebug % "UCR| Updating binding for ControlGUID " ControlGUID ", IOClass " bo.IOClass
		; Direct the request to the appropriate IOClass that handles it
		this.IOClasses[bo.IOClass].UpdateBinding(ControlGUID, bo)
	}
	
	;~ _SetDetectionState(state){
	SetDetectionState(state){
		OutputDebug % "UCR| InputThread: Hotkey detection " (state ? "On" : "Off")
		if (state == this.DetectionState)
			return
		this.DetectionState := state
		for name, cls in this.IOClasses {
			cls.SetDetectionState(state)
		}
	}
	
	; Listens for Keyboard and Mouse input using the AHK Hotkey command
	class AHK_KBM_Input {
		DetectionState := 0
		_AHKBindings := {}
		
		__New(callback){
			this.callback := callback
			Suspend, On	; Start with detection off, even if we are passed bindings
		}
		
		UpdateBinding(ControlGUID, bo){
			this.RemoveBinding(ControlGUID)
			if (bo.Binding[1]){
				keyname := "$" this.BuildHotkeyString(bo)
				fn := this.KeyEvent.Bind(this, ControlGUID, 1)
				hotkey, % keyname, % fn, On
				fn := this.KeyEvent.Bind(this, ControlGUID, 0)
				hotkey, % keyname " up", % fn, On
				;OutputDebug % "UCR| AHK_KBM_Input Added hotkey " keyname " for ControlGUID " ControlGUID
				this._AHKBindings[ControlGUID] := keyname
			}
		}
		
		SetDetectionState(state){
			; Are we already in the requested state?
			; This code is rigged so that either AHK_KBM_Input or AHK_JoyBtn_Input or both will not clash...
			; ... As long as all are turned on or off together, you won't get weird results.
			if (A_IsSuspended == state){
				;OutputDebug % "UCR| Thread: AHK_KBM_Input IOClass turning Hotkey detection " (state ? "On" : "Off")
				Suspend, % (state ? "Off" : "On")
			}
			this.DetectionState := state
		}
		
		RemoveBinding(ControlGUID){
			keyname := this._AHKBindings[ControlGUID]
			if (keyname){
				;OutputDebug % "UCR| AHK_KBM_Input Removing hotkey " keyname " for ControlGUID " ControlGUID
				hotkey, % keyname, UCR_INPUTHREAD_DUMMY_LABEL
				hotkey, % keyname, Off
				hotkey, % keyname " up", UCR_INPUTHREAD_DUMMY_LABEL
				hotkey, % keyname " up", Off
				this._AHKBindings.Delete(ControlGUID)
			}
		}
		
		KeyEvent(ControlGUID, e){
			;OutputDebug % "UCR| AHK_KBM_Input Key event for GuiControl " ControlGUID
			fn := this.InputEvent.Bind(this, ControlGUID, e)
			SetTimer, % fn, -0
		}
		
		InputEvent(ControlGUID, state){
			this.Callback.Call(ControlGUID, state)
		}

		; Builds an AHK hotkey string (eg ~^a) from a BindObject
		BuildHotkeyString(bo){
			if (!bo.Binding.Length())
				return ""
			str := ""
			if (bo.BindOptions.Wild)
				str .= "*"
			if (!bo.BindOptions.Block)
				str .= "~"
			max := bo.Binding.Length()
			Loop % max {
				key := bo.Binding[A_Index]
				if (A_Index = max){
					islast := 1
					nextkey := 0
				} else {
					islast := 0
					nextkey := bo[A_Index+1]
				}
				if (this.IsModifier(key) && (max > A_Index)){
					str .= this.RenderModifier(key)
				} else {
					str .= this.BuildKeyName(key)
				}
			}
			return str
		}
		
		; === COMMON WITH IOCLASS. MOVE TO INCLUDE =====
		static _Modifiers := ({91: {s: "#", v: "<"},92: {s: "#", v: ">"}
		,160: {s: "+", v: "<"},161: {s: "+", v: ">"}
		,162: {s: "^", v: "<"},163: {s: "^", v: ">"}
		,164: {s: "!", v: "<"},165: {s: "!", v: ">"}})

		; Builds the AHK key name
		BuildKeyName(code){
			static replacements := {33: "PgUp", 34: "PgDn", 35: "End", 36: "Home", 37: "Left", 38: "Up", 39: "Right", 40: "Down", 45: "Insert", 46: "Delete"}
			static additions := {14: "NumpadEnter"}
			if (ObjHasKey(replacements, code)){
				return replacements[code]
			} else if (ObjHasKey(additions, code)){
				return additions[code]
			} else {
				return GetKeyName("vk" Format("{:x}", code))
			}
		}
		
		; Returns true if this Button is a modifier key on the keyboard
		IsModifier(code){
			return ObjHasKey(this._Modifiers, code)
		}
		
		; Renders the keycode of a Modifier to it's AHK Hotkey symbol (eg 162 for LCTRL to ^)
		RenderModifier(code){
			return this._Modifiers[code].s
		}
		; ================= END MOVE TO INCLUDE ======================
	}
	
	; Listens for Joystick Button input using AHK's Hotkey command
	; Joystick button Hotkeys in AHK immediately fire the up event after the down event...
	; ... so up events are emulated up using AHK's GetKeyState() function
	class AHK_JoyBtn_Input {
		HeldButtons := {}
		TimerWanted := 0		; Whether or not we WANT to run the ButtonTimer (NOT if it is actually running!)
		TimerRunning := 0
		DetectionState := 0		; Whether or not we are allowed to have hotkeys or be running the timer
		
		__New(Callback){
			this.Callback := Callback
			this.TimerFn := this.ButtonWatcher.Bind(this)
			Suspend, On	; Start with detection off, even if we are passed bindings
		}
		
		UpdateBinding(ControlGUID, bo){
			this.RemoveBinding(ControlGUID)
			if (bo.Binding[1]){
				keyname := this.BuildHotkeyString(bo)
				fn := this.KeyEvent.Bind(this, ControlGUID, 1)
				if (GetKeyState(bo.DeviceID "JoyAxes")) 
					try {
						hotkey, % keyname, % fn, On
					}
				else
					OutputDebug % "UCR| Warning! AHK_JoyBtn_Input did not declare hotkey " keyname " because the stick is disconnected"
				;OutputDebug % "UCR| AHK_JoyBtn_Input Added hotkey " keyname " for ControlGUID " ControlGUID
				this._AHKBindings[ControlGUID] := keyname
			}
		}
		
		SetDetectionState(state){
			; Are we already in the requested state?
			if (A_IsSuspended == state){
				;OutputDebug % "UCR| Thread: AHK_JoyBtn_Input IOClass turning Hotkey detection " (state ? "On" : "Off")
				Suspend, % (state ? "Off" : "On")
			}
			this.DetectionState := state
			this.ProcessTimerState()
		}
		
		RemoveBinding(ControlGUID){
			keyname := this._AHKBindings[ControlGUID]
			if (keyname){
				;OutputDebug % "UCR| AHK_JoyBtn_Input Removing hotkey " keyname " for ControlGUID " ControlGUID
				try{
					hotkey, % keyname, UCR_INPUTHREAD_DUMMY_LABEL
				}
				try{
					hotkey, % keyname, Off
				}
				this._AHKBindings.Delete(ControlGUID)
			}
			;this._CurrentBinding := 0
		}
		
		KeyEvent(ControlGUID, e){
			; ToDo: Parent will not exist in thread!
			
			;OutputDebug % "UCR| AHK_JoyBtn_Input Key event " e " for GuiControl " ControlGUID
			;this.Callback.Call(ControlGUID, e)
			fn := this.InputEvent.Bind(this, ControlGUID, e)
			SetTimer, % fn, -0
			
			this.HeldButtons[this._AHKBindings[ControlGUID]] := ControlGUID
			if (!this.TimerWanted){
				this.TimerWanted := 1
				this.ProcessTimerState()
			}
		}
		
		InputEvent(ControlGUID, state){
			this.Callback.Call(ControlGUID, state)
		}

		ButtonWatcher(){
			for bindstring, ControlGUID in this.HeldButtons {
				if (!GetKeyState(bindstring)){
					this.HeldButtons.Delete(bindstring)
					;OutputDebug % "UCR| AHK_JoyBtn_Input Key event 0 for GuiControl " ControlGUID
					;this.Callback.Call(ControlGUID, 0)
					fn := this.InputEvent.Bind(this, ControlGUID, 0)
					SetTimer, % fn, -0
					if (IsEmptyAssoc(this.HeldButtons)){
						this.TimerWanted := 0
						this.ProcessTimerState()
						return
					}
				}
			}
		}
		
		ProcessTimerState(){
			fn := this.TimerFn
			if (this.TimerWanted && this.DetectionState && !this.TimerRunning){
				SetTimer, % fn, 10
				this.TimerRunning := 1
				;OutputDebug % "UCR| AHK_JoyBtn_Input Started ButtonWatcher " ControlGUID
			} else if ((!this.TimerWanted || !this.DetectionState) && this.TimerRunning){
				SetTimer, % fn, Off
				this.TimerRunning := 0
				;OutputDebug % "UCR| AHK_JoyBtn_Input Stopped ButtonWatcher " ControlGUID
			}
		}

		BuildHotkeyString(bo){
			return bo.Deviceid "Joy" bo.Binding[1]
		}
	}

	; Listens for Joystick Hat input using AHK's GetKeyState() function
	class AHK_JoyHat_Input {
		; Indexed by GetKeyState string (eg "1JoyPOV")
		; The HatWatcher timer is active while this array has items.
		; Contains an array of objects whose keys are the GUIDs of GuiControls mapped to that POV
		; Properties of those keys are the direction of the mapping and the state of the binding
		HatBindings := {}
		
		; GUID-Indexed array of sticks + directions that each GUIControl is mapped to, plus it's current state
		ControlMappings := {}
		
		; Which cardinal directions are pressed for each of the 8 compass directions, plus centre
		; Order is U, R, D, L
		static PovMap := {-1: [0,0,0,0], 1: [1,0,0,0], 2: [1,1,0,0] , 3: [0,1,0,0], 4: [0,1,1,0], 5: [0,0,1,0], 6: [0,0,1,1], 7: [0,0,0,1], 8: [1,0,0,1]}
		
		TimerRunning := 0
		TimerWanted := 0
		ConnectedSticks := [0,0,0,0,0,0,0,0]
		
		__New(Callback){
			this.Callback := Callback
			
			this.TimerFn := this.HatWatcher.Bind(this)
		}
		
		; Request from main thread to update binding
		UpdateBinding(ControlGUID, bo){
			;OutputDebug % "UCR| AHK_JoyHat_Input " (bo.Binding[1] ? "Update" : "Remove" ) " Hat Binding - Device: " bo.DeviceID ", Direction: " bo.Binding[1]
			this._UpdateArrays(ControlGUID, bo)
			this.TimerWanted := !IsEmptyAssoc(this.ControlMappings)
			this.ProcessTimerState()
		}
		
		SetDetectionState(state){
			this.DetectionState := state
			this.ProcessTimerState()
		}
		
		ProcessTimerState(){
			fn := this.TimerFn
			if (this.TimerWanted && this.DetectionState && !this.TimerRunning){
				; Pre-cache connected sticks, as polling disconnected sticks takes lots of CPU
				Loop 8 {
					this.ConnectedSticks[A_Index] := GetKeyState(A_Index "JoyInfo")
				}
				SetTimer, % fn, 10
				this.TimerRunning := 1
				;OutputDebug % "UCR| AHK_JoyHat_Input Started HatWatcher"
			} else if ((!this.TimerWanted || !this.DetectionState) && this.TimerRunning){
				SetTimer, % fn, Off
				this.TimerRunning := 0
				;OutputDebug % "UCR| AHK_JoyHat_Input Stopped HatWatcher"
			}
		}

		; Updates the arrays which drive hat detection
		_UpdateArrays(ControlGUID, bo := 0){
			if (ObjHasKey(this.ControlMappings, ControlGUID)){
				; GuiControl already has binding
				bindstring := this.ControlMappings[ControlGUID].bindstring
				this.HatBindings[bindstring].Delete(ControlGUID)
				this.ControlMappings.Delete(ControlGUID)
				if (IsEmptyAssoc(this.HatBindings[bindstring])){
					this.HatBindings.Delete(bindstring)
					;OutputDebug % "UCR| AHK_JoyHat_Input Removing Hat Bindstring " bindstring
				}
			}
			if (bo != 0 && bo.Binding[1]){
				; there is a new binding
				bindstring := bo.DeviceID "JoyPOV"
				if (!ObjHasKey(this.HatBindings, bindstring)){
					this.HatBindings[bindstring] := {}
					;OutputDebug % "UCR| AHK_JoyHat_Input Adding Hat Bindstring " bindstring
				}
				this.HatBindings[bindstring, ControlGUID] := {dir: bo.Binding[1], state: 0}
				this.ControlMappings[ControlGUID] := {bindstring: bindstring}
			}
		}
		
		; Called on a timer when we are trying to detect hats
		HatWatcher(){
			for bindstring, bindings in this.HatBindings {
				if (!this.ConnectedSticks[SubStr(bindstring, 1, 1)]){
					; Do not poll unconnected sticks, it consumes a lot of cpu
					continue
				}
				state := GetKeyState(bindstring)
				state := (state = -1 ? -1 : round(state / 4500) + 1)
				for ControlGUID, obj in bindings {
					new_state := (this.PovMap[state, obj.dir] == 1)
					if (obj.state != new_state){
						obj.state := new_state
						;OutputDebug % "UCR| InputThread: AHK_JoyHat_Input Direction " obj.dir " state " new_state " calling ControlGUID " ControlGUID
						; Use the thread-safe object to tell the main thread that the hat direction changed state
						;this.Callback.Call(ControlGUID, new_state)
						fn := this.InputEvent.Bind(this, ControlGUID, new_state)
						SetTimer, % fn, -0
					}
				}
			}
		}
		
		InputEvent(ControlGUID, state){
			this.Callback.Call(ControlGUID, state)
		}
	}	
}

; Is an associative array empty?
IsEmptyAssoc(assoc){
	return !assoc._NewEnum()[k, v]
}