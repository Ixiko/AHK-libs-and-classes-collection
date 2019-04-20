Class AppFactory {
	_ThreadHeader := "`n#Persistent`n#NoTrayIcon`n#MaxHotkeysPerInterval 9999`n"
	_ThreadFooter := "`nautoexecute_done := 1`nreturn`n"
	InputThread := 0
	IOControls := {}
	GuiControls := {}
	Settings := {}
	
	; ====================== PUBLIC METHODS. USER SCRIPTS SHOULD ONLY CALL THESE ========================
	AddInputButton(guid, options, callback){
		this.IOControls[guid] := new this._IOControl(this, guid, options, callback)
		this.IOControls[guid].SetBinding(this.Settings.IOControls[guid])
	}
	
	AddControl(guid, ctrltype, options, default, callback){
		this.GuiControls[guid] := new this._GuiControl(this, guid, ctrltype, options, default, callback)
		if (this.Settings.GuiControls.Haskey(guid)){
			this.GuiControls[guid].SetValue(this.Settings.GuiControls[guid])
		} else {
			if (this.GuiControls[guid].IsListType){
				d := RegExMatch(default, "(.*)\|\|", out)
				default := out1
			}
			this.GuiControls[guid].SetValue(default)
		}
		
	}
	
	; ====================== PRIVATE METHODS. USER SCRIPTS SHOULD NOT CALL THESE ========================
	__New(hwnd := 0){
		this._SettingsFile := RegExReplace(A_ScriptName, ".ahk|.exe", ".ini")

		this.InitBindMode()
		this.InitInputThread()
		
		if (hwnd == 0)
			Gui, +Hwndhwnd
		this.hwnd := hwnd
		
		FileRead, j, % this._SettingsFile
		if (j == ""){
			j := {IOControls: {}, GuiControls: {}}
		} else {
			j := JSON.Load(j)
		}
		this.Settings := j
		this.InputThread.SetDetectionState(1)
	}
	
	; When bind mode ends, the GuiControl will call this method to request that the setting be saved
	_BindingChanged(ControlGuid, bo){
		this.Settings.IOControls[ControlGuid] := bo
		this._SaveSettings()
	}
	
	_GuiControlChanged(ControlGuid, value){
		this.Settings.GuiControls[ControlGuid] := value
		this._SaveSettings()
	}
	
	_SaveSettings(){
		FileReplace(JSON.Dump(this.Settings, ,true), this._SettingsFile)
	}
	
	; ============================================================================================
	; ==================================== GUICONTROLS ===========================================
	; ============================================================================================
	class _GuiControl {
		static _ListTypes := {ListBox: 1, DDL: 1, DropDownList: 1, ComboBox: 1, Tab: 1, Tab2: 1, Tab3: 1}
		_Value := ""
		
		Get(){
			return this._Value
		}
		
		__New(parent, guid, ctrltype, options, default, callback){
			this.id := guid
			this.parent := parent
			this.Callback := callback
			this.Default := default
			
			if (ObjHasKey(this._ListTypes, ctrltype)){
				this.IsListType := 1
				; Detect if this List Type uses AltSubmit
				if (InStr(options, "altsubmit"))
					this.IsAltSubmitType := 1
				else 
					this.IsAltSubmitType := 0
			} else {
				this.IsListType := 0
				this.IsAltSubmitType := 0
			}
			
			Gui, % this.parent.hwnd ":Add", % ctrltype, % "hwndhwnd " options, % default
			this.hwnd := hwnd
			fn := this.ControlChanged.Bind(this)
			this.ChangeValueFn := fn
			this._SetGLabel(1)
			
			return this
		}
		
		SetControlState(value){
			this._SetGlabel(0)						; Turn off g-label to avoid triggering save
			cmd := ""
			if (this.IsListType){
				cmd := (this.IsAltSubmitType ? "choose" : "choosestring")
			}
			GuiControl, % this.parent.hwnd ":" cmd, % this.hwnd, % value
			this._SetGlabel(1)						; Turn g-label back on
		}
		
		; Turns on or off the g-label for the GuiControl
		; This is needed to work around not being able to programmatically set GuiControl without triggering g-label
		_SetGlabel(state){
			if (state){
				fn := this.ChangeValueFn
				GuiControl, % this.parent.hwnd ":+g", % this.hwnd, % fn
			} else {
				GuiControl, % this.parent.hwnd ":-g", % this.hwnd
			}
		}
		
		; User interacted with GuiControl
		ControlChanged(){
			GuiControlGet, value, % this.parent.hwnd ":" , % this.hwnd
			this._Value := value
			this.Callback.call(value)
			this.parent._GuiControlChanged(this.id, value)
		}
		
		; Called on load of settings
		SetValue(value){
			this._Value := value
			this.SetControlState(value)
		}
	}
	
	; ============================================================================================
	; ==================================== IOCONTROLS ============================================
	; ============================================================================================
	class _IOControl {
		guid := 0			; The unique ID/Name for this IOControl
		Callback := 0		; Holds the user's callback for this IOControl
		BindObject := 0		; Holds the BindObject describing the current binding
		State := 0			; The State of the input. Only really used for Repeat Suppression
		
		static _Modifiers := ({91: {s: "#", v: "<"},92: {s: "#", v: ">"}
		,160: {s: "+", v: "<"},161: {s: "+", v: ">"}
		,162: {s: "^", v: "<"},163: {s: "^", v: ">"}
		,164: {s: "!", v: "<"},165: {s: "!", v: ">"}})

		__New(parent, guid, options, callback){
			this.id := guid
			this.parent := parent
			this.Callback := callback
			this.BindObject := new this.parent._BindObject()
			Gui, % this.parent.hwnd ":Add", Button, % "hwndhReadout " options , Select an Input Button
			this.hReadout := hReadout
			fn := this.OpenMenu.Bind(this)
			GuiControl, % this.parent.hwnd ":+g", % hReadout, % fn			
			
			fn := this.IOControlChoiceMade.Bind(this, 1)
			Menu, % this.id, Add, % "Select Binding...", % fn
			
			fn := this.IOControlChoiceMade.Bind(this, 2)
			Menu, % this.id, Add, % "Block", % fn
			
			fn := this.IOControlChoiceMade.Bind(this, 3)
			Menu, % this.id, Add, % "Wild", % fn
			
			fn := this.IOControlChoiceMade.Bind(this, 4)
			Menu, % this.id, Add, % "Suppress Repeats", % fn
			
			fn := this.IOControlChoiceMade.Bind(this, 5)
			Menu, % this.id, Add, % "Clear", % fn
			
		}
		
		SetBinding(bo){
			if (IsObject(bo)){
				bo := bo
				this.BindObject := bo
			} else {
				this.BindObject.Binding := []
			}
			this.parent.InputThread.UpdateBinding(this.id, ObjShare(this.BindObject))
			GuiControl, % this.parent.hwnd ":" , % this.hReadout, % this.BuildHumanReadable()
			for opt, state in bo.BindOptions {
				this.SetMenuCheckState(opt, state)
			}
		}
		
		IOControlChoiceMade(val){
			if (val == 1){
				; Bind
				this.parent.InputThread.SetDetectionState(0)
				this.parent.StartBindMode(this.BindModeEnded.Bind(this))
			} else if (val == 2){
				; Block
				this.BindObject.BindOptions.Block := !this.BindObject.BindOptions.Block
				this.SetMenuCheckState("Block")
				this.BindModeEnded(this.BindObject)
			} else if (val == 3){
				; Wild
				this.BindObject.BindOptions.Wild := !this.BindObject.BindOptions.Wild
				this.SetMenuCheckState("Wild")
				this.BindModeEnded(this.BindObject)
			} else if (val == 4){
				; Suppress Repeats
				this.BindObject.BindOptions.Suppress := !this.BindObject.BindOptions.Suppress
				this.SetMenuCheckState("Suppress")
				this.BindModeEnded(this.BindObject)
			} else if (val == 5){
				; Clear
				this.BindObject := new this.parent._BindObject()
				this.BindModeEnded(this.BindObject)
			}
		}
		
		SetMenuCheckState(which){
			state := this.BindObject.BindOptions[which]
			try Menu, % this.id, % (state ? "Check" : "UnCheck"), % which
		}
		
		BindModeEnded(bo){
			this.SetBinding(bo)
			this.parent._BindingChanged(this.id, bo)
			this.parent.InputThread.SetDetectionState(1)
		}
		
		OpenMenu(){
			ControlGetPos, cX, cY, cW, cH,, % "ahk_id " this.hReadout
			Menu, % this.id, Show, % cX+1, % cY + cH
		}
		
		; Builds a human-readable form of the BindObject
		BuildHumanReadable(){
			str := ""
			if (!this.BindObject.IOClass){
				str := "Select an Input Button..."
			} else if (this.BindObject.IOClass == "AHK_KBM_Input"){
				max := this.BindObject.Binding.length()
				Loop % max {
					str .= this.BuildKeyName(this.BindObject.Binding[A_Index])
					if (A_Index != max)
						str .= " + "
				}
			} else if (this.BindObject.IOClass == "AHK_JoyBtn_Input"){
				return "Stick " this.BindObject.DeviceID " Button " this.BindObject.Binding[1]
			} else if (this.BindObject.IOClass == "AHK_JoyHat_Input"){
				static hat_directions := ["Up", "Right", "Down", "Left"]
				return "Stick " this.BindObject.DeviceID ", Hat " hat_directions[this.BindObject.Binding[1]]
			}
			return str
		}
		
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
	}
	
	; ====================================== BINDMODE THREAD ==============================================
	; An additional thread that is always running and handles detection of input while in Bind Mode (User selecting hotkeys)
	InitBindMode(){
		FileRead, Script, % A_ScriptDir "\BindModeThread.ahk"
		this.__BindModeThread := AhkThread(this._ThreadHeader "`nBindMapper := new _BindMapper(" ObjShare(this.ProcessBindModeInput.Bind(this)) ")`n" this._ThreadFooter Script)
		While !this.__BindModeThread.ahkgetvar.autoexecute_done
			Sleep 50 ; wait until variable has been set.
		
		; Create object to hold thread-safe boundfunc calls to the thread
		this._BindModeThread := {}
		this._BindModeThread.SetDetectionState := ObjShare(this.__BindModeThread.ahkgetvar("InterfaceSetDetectionState"))
		
		Gui, +HwndhOld
		Gui, new, +HwndHwnd
		Gui +ToolWindow -Border
		Gui, Font, S15
		Gui, Color, Red
		this.hBindModePrompt := hwnd
		Gui, Add, Text, Center, Press the button(s) you wish to bind to this control.`n`nBind Mode will end when you release a key.
		Gui, % hOld ":Default"
	}
	
	;IOClassMappings, this._BindModeEnded.Bind(this, callback)
	StartBindMode(callback){
		IOClassMappings := {AHK_Common: 0, AHK_KBM_Input: "AHK_KBM_Input", AHK_JoyBtn_Input: "AHK_JoyBtn_Input", AHK_JoyHat_Input: "AHK_JoyHat_Input"}
		this._callback := callback
		
		this.SelectedBinding := new this._BindObject()
		this.BindMode := 1
		this.EndKey := 0
		this.HeldModifiers := {}
		this.ModifierCount := 0
		; IOClassMappings controls which type each IOClass reports as.
		; ie we need the AHK_KBM_Input class to report as AHK_KBM_Output when we are binding an output key
		this.IOClassMappings := IOClassMappings
		this.SetHotkeyState(1)
	}
	
	; Bind Mode ended. Pass the BindObject and it's IOClass back to the GuiControl that requested the binding
	_BindModeEnded(callback, bo){
		;OutputDebug % "UCR| UCR: Bind Mode Ended. Binding[1]: " bo.Binding[1] ", DeviceID: " bo.DeviceID ", IOClass: " this.SelectedBinding.IOClass
		callback.Call(bo)
	}
	
	; Turns on or off the hotkeys
	SetHotkeyState(state){
		if (state){
			Gui, % this.hBindModePrompt ":Show"
			;UCR.MoveWindowToCenterOfGui(this.hBindModePrompt)
		} else {
			Gui, % this.hBindModePrompt ":Hide"
		}
		; Convert associative array to indexed, as ObjShare breaks associative array enumeration
		IOClassMappings := this.AssocToIndexed(this.IOClassMappings)
		this._BindModeThread.SetDetectionState(state, ObjShare(IOClassMappings))
	}
	
	; Converts an associative array to an indexed array of objects
	; If you pass an associative array via ObjShare, you cannot enumerate it
	; So each base key/value pair is added to an indexed array
	; And the thread can re-build the associative array on the other end.
	AssocToIndexed(arr){
		ret := []
		for k, v in arr {
			ret.push({k: k, v: v})
		}
		return ret
	}
	
	; The BindModeThread calls back here
	ProcessBindModeInput(e, i, deviceid, IOClass){
		;ToolTip % "e " e ", i " i ", deviceid " deviceid ", IOClass " IOClass
		;if (ObjHasKey(this._Modifiers, i))
		if (this.SelectedBinding.IOClass && (this.SelectedBinding.IOClass != IOClass)){
			; Changed binding IOCLass part way through.
			if (e){
				SoundBeep, 500, 100
			}
			return
		}
		max := this.SelectedBinding.Binding.length()
		if (e){
			for idx, code in  this.SelectedBinding.Binding {
				if (i == code)
					return	; filter repeats
			}
			this.SelectedBinding.Binding.push(i)
			this.SelectedBinding.DeviceID := DeviceID
			if (this.AHK_KBM_Input.IsModifier(i)){
				if (max > this.ModifierCount){
					; Modifier pressed after end key
					SoundBeep, 500, 100
					return
				}
				this.ModifierCount++
			} else if (max > this.ModifierCount) {
				; Second End Key pressed after first held
				SoundBeep, 500, 100
				return
			}
			this.SelectedBinding.IOClass := IOClass
		} else {
			this.BindMode := 0
			this.SetHotkeyState(0, this.IOClassMappings)
			;ret := {Binding:[i], DeviceID: deviceid, IOClass: this.IOClassMappings[IOClass]}
			
			;OutputDebug % "UCR| BindModeHandler: Bind Mode Ended. Binding[1]: " this.SelectedBinding.Binding[1] ", DeviceID: " this.SelectedBinding.DeviceID ", IOClass: " this.SelectedBinding.IOClass
			this._Callback.Call(this.SelectedBinding)
		}
	}

	; ====================================== INPUT THREAD ==============================================
	; An additional thread that is always running and handles detection of input while in Normal Mode
	; This is done in an additional thread so that fixes to joystick input (Buttons and Hats) do not have to have loops in the main thread
	InitInputThread(){
		FileRead, Script, % A_ScriptDir "\InputThread.ahk"
		
		; Cache script for profile InputThreads
		this._InputThreadScript := this._ThreadFooter Script 
		this._StartInputThread()
	}
	
	; Starts the "Input Thread" which handles detection of input
	_StartInputThread(){
		if (this.InputThread == 0){
			this.id := 1
			this._InputThread := AhkThread(this._ThreadHeader "`nInputThread := new _InputThread(""" this.id """," ObjShare(this.InputEvent.Bind(this)) ")`n" this._InputThreadScript)

			While !this._InputThread.ahkgetvar.autoexecute_done
				Sleep 10 ; wait until variable has been set.
			OutputDebug % "UCR| Input Thread started"

			; Get thread-safe boundfunc object for thread's SetHotkeyState
			this.InputThread := {}
			this.InputThread.UpdateBinding := ObjShare(this._InputThread.ahkgetvar("InterfaceUpdateBinding"))
			;this.InputThread.UpdateBindings := ObjShare(this._InputThread.ahkgetvar("InterfaceUpdateBindings"))
			this.InputThread.SetDetectionState := ObjShare(this._InputThread.ahkgetvar("InterfaceSetDetectionState"))
		}
	}
	
	InputEvent(ControlGUID, e){
		; Suppress repeats
		if (this.IOControls[ControlGuid].BindObject.BindOptions.Suppress && (this.IOControls[ControlGuid].State == e))
			return
		this.IOControls[ControlGuid].State := e
		; Fire the callback
		this.IOControls[ControlGuid].Callback.call(e)
	}
	
	; ====================================== MISC ==============================================
	; Describes a binding. Used internally and dumped to the INI file
	class _BindObject {
		IOClass := ""
		DeviceID := 0 		; Device ID, eg Stick ID for Joystick input or vGen output
		Binding := []		; Codes of the input(s) for the Binding. Is an indexed array once set
							; Normally a single element, but for KBM could be up to 4 modifiers plus a key/button
		BindOptions := {Block: 0, Wild: 0, Suppress: 0}
	}
}

/**
 * Lib: JSON.ahk
 *     JSON lib for AutoHotkey.
 * Version:
 *     v2.1.0 [updated 01/28/2016 (MM/DD/YYYY)]
 * License:
 *     WTFPL [http://wtfpl.net/]
 * Requirements:
 *     Latest version of AutoHotkey (v1.1+ or v2.0-a+)
 * Installation:
 *     Use #Include JSON.ahk or copy into a function library folder and then
 *     use #Include <JSON>
 * Links:
 *     GitHub:     - https://github.com/cocobelgica/AutoHotkey-JSON
 *     Forum Topic - http://goo.gl/r0zI8t
 *     Email:      - cocobelgica <at> gmail <dot> com
 */


/**
 * Class: JSON
 *     The JSON object contains methods for parsing JSON and converting values
 *     to JSON. Callable - NO; Instantiable - YES; Subclassable - YES;
 *     Nestable(via #Include) - NO.
 * Methods:
 *     Load() - see relevant documentation before method definition header
 *     Dump() - see relevant documentation before method definition header
 */
class JSON
{
	/**
	 * Method: Load
	 *     Parses a JSON string into an AHK value
	 * Syntax:
	 *     value := JSON.Load( text [, reviver ] )
	 * Parameter(s):
	 *     value      [retval] - parsed value
	 *     text      [in, opt] - JSON formatted string
	 *     reviver   [in, opt] - function object, similar to JavaScript's
	 *                           JSON.parse() 'reviver' parameter
	 */
	class Load extends JSON.Functor
	{
		Call(self, text, reviver:="")
		{
			this.rev := IsObject(reviver) ? reviver : false
			this.keys := this.rev ? {} : false

			static q := Chr(34)
			     , json_value := q . "{[01234567890-tfn"
			     , json_value_or_array_closing := q . "{[]01234567890-tfn"
			     , object_key_or_object_closing := q . "}"

			key := ""
			is_key := false
			root := {}
			stack := [root]
			next := json_value
			pos := 0

			while ((ch := SubStr(text, ++pos, 1)) != "") {
				if InStr(" `t`r`n", ch)
					continue
				if !InStr(next, ch, 1)
					this.ParseError(next, text, pos)

				holder := stack[1]
				is_array := holder.IsArray

				if InStr(",:", ch) {
					next := (is_key := !is_array && ch == ",") ? q : json_value

				} else if InStr("}]", ch) {
					ObjRemoveAt(stack, 1)
					next := stack[1]==root ? "" : stack[1].IsArray ? ",]" : ",}"

				} else {
					if InStr("{[", ch) {
					; Check if Array() is overridden and if its return value has
					; the 'IsArray' property. If so, Array() will be called normally,
					; otherwise, use a custom base object for arrays
						static json_array := Func("Array").IsBuiltIn || ![].IsArray ? {IsArray: true} : 0
					
					; sacrifice readability for minor(actually negligible) performance gain
						(ch == "{")
							? ( is_key := true
							  , value := {}
							  , next := object_key_or_object_closing )
						; ch == "["
							: ( value := json_array ? new json_array : []
							  , next := json_value_or_array_closing )
						
						ObjInsertAt(stack, 1, value)

						if (this.keys)
							this.keys[value] := []
					
					} else {
						if (ch == q) {
							i := pos
							while (i := InStr(text, q,, i+1)) {
								value := StrReplace(SubStr(text, pos+1, i-pos-1), "\\", "\u005c")

								static ss_end := A_AhkVersion<"2" ? 0 : -1
								if (SubStr(value, ss_end) != "\")
									break
							}

							if (!i)
								this.ParseError("'", text, pos)

							  value := StrReplace(value,    "\/",  "/")
							, value := StrReplace(value, "\" . q,    q)
							, value := StrReplace(value,    "\b", "`b")
							, value := StrReplace(value,    "\f", "`f")
							, value := StrReplace(value,    "\n", "`n")
							, value := StrReplace(value,    "\r", "`r")
							, value := StrReplace(value,    "\t", "`t")

							pos := i ; update pos
							
							i := 0
							while (i := InStr(value, "\",, i+1)) {
								if !(SubStr(value, i+1, 1) == "u")
									this.ParseError("\", text, pos - StrLen(SubStr(value, i+1)))

								uffff := Abs("0x" . SubStr(value, i+2, 4))
								if (A_IsUnicode || uffff < 0x100)
									value := SubStr(value, 1, i-1) . Chr(uffff) . SubStr(value, i+6)
							}

							if (is_key) {
								key := value, next := ":"
								continue
							}
						
						} else {
							value := SubStr(text, pos, i := RegExMatch(text, "[\]\},\s]|$",, pos)-pos)

							static number := "number"
							if value is %number%
								value += 0
							else if (value == "true" || value == "false")
								value := %value% + 0
							else if (value == "null")
								value := ""
							else
							; we can do more here to pinpoint the actual culprit
							; but that's just too much extra work.
								this.ParseError(next, text, pos, i)

							pos += i-1
						}

						next := holder==root ? "" : is_array ? ",]" : ",}"
					} ; If InStr("{[", ch) { ... } else

					is_array? key := ObjPush(holder, value) : holder[key] := value

					if (this.keys && this.keys.HasKey(holder))
						this.keys[holder].Push(key)
				}
			
			} ; while ( ... )

			return this.rev ? this.Walk(root, "") : root[""]
		}

		ParseError(expect, text, pos, len:=1)
		{
			static q := Chr(34)
			
			line := StrSplit(SubStr(text, 1, pos), "`n", "`r").Length()
			col := pos - InStr(text, "`n",, -(StrLen(text)-pos+1))
			msg := Format("{1}`n`nLine:`t{2}`nCol:`t{3}`nChar:`t{4}"
			,     (expect == "")      ? "Extra data"
			    : (expect == "'")     ? "Unterminated string starting at"
			    : (expect == "\")     ? "Invalid \escape"
			    : (expect == ":")     ? "Expecting ':' delimiter"
			    : (expect == q)       ? "Expecting object key enclosed in double quotes"
			    : (expect == q . "}") ? "Expecting object key enclosed in double quotes or object closing '}'"
			    : (expect == ",}")    ? "Expecting ',' delimiter or object closing '}'"
			    : (expect == ",]")    ? "Expecting ',' delimiter or array closing ']'"
			    : InStr(expect, "]")  ? "Expecting JSON value or array closing ']'"
			    :                       "Expecting JSON value(string, number, true, false, null, object or array)"
			, line, col, pos)

			static offset := A_AhkVersion<"2" ? -3 : -4
			throw Exception(msg, offset, SubStr(text, pos, len))
		}

		Walk(holder, key)
		{
			value := holder[key]
			if IsObject(value)
				for i, k in this.keys[value]
					value[k] := this.Walk.Call(this, value, k) ; bypass __Call
			
			return this.rev.Call(holder, key, value)
		}
	}

	/**
	 * Method: Dump
	 *     Converts an AHK value into a JSON string
	 * Syntax:
	 *     str := JSON.Dump( value [, replacer, space ] )
	 * Parameter(s):
	 *     str        [retval] - JSON representation of an AHK value
	 *     value          [in] - any value(object, string, number)
	 *     replacer  [in, opt] - function object, similar to JavaScript's
	 *                           JSON.stringify() 'replacer' parameter
	 *     space     [in, opt] - similar to JavaScript's JSON.stringify()
	 *                           'space' parameter
	 */
	class Dump extends JSON.Functor
	{
		Call(self, value, replacer:="", space:="")
		{
			this.rep := IsObject(replacer) ? replacer : ""

			this.gap := ""
			if (space) {
				static integer := "integer"
				if space is %integer%
					Loop, % ((n := Abs(space))>10 ? 10 : n)
						this.gap .= " "
				else
					this.gap := SubStr(space, 1, 10)

				this.indent := "`n"
			}

			return this.Str({"": value}, "")
		}

		Str(holder, key)
		{
			value := holder[key]

			if (this.rep)
				value := this.rep.Call(holder, key, value)

			if IsObject(value) {
			; Check object type, skip serialization for other object types such as
			; ComObject, Func, BoundFunc, FileObject, RegExMatchObject, Property, etc.
				static type := A_AhkVersion<"2" ? "" : Func("Type")
				if (type ? type.Call(value) == "Object" : ObjGetCapacity(value) != "") {
					if (this.gap) {
						stepback := this.indent
						this.indent .= this.gap
					}

					is_array := value.IsArray
				; Array() is not overridden, rollback to old method of
				; identifying array-like objects. Due to the use of a for-loop
				; sparse arrays such as '[1,,3]' are detected as objects({}). 
					if (!is_array) {
						for i in value
							is_array := i == A_Index
						until !is_array
					}

					str := ""
					if (is_array) {
						Loop, % value.Length() {
							if (this.gap)
								str .= this.indent
							
							v := this.Str(value, A_Index)
							str .= (v != "") && value.HasKey(A_Index) ? v . "," : "null,"
						}
					} else {
						colon := this.gap ? ": " : ":"
						for k in value {
							v := this.Str(value, k)
							if (v != "") {
								if (this.gap)
									str .= this.indent

								str .= this.Quote(k) . colon . v . ","
							}
						}
					}

					if (str != "") {
						str := RTrim(str, ",")
						if (this.gap)
							str .= stepback
					}

					if (this.gap)
						this.indent := stepback

					return is_array ? "[" . str . "]" : "{" . str . "}"
				}
			
			} else ; is_number ? value : "value"
				return ObjGetCapacity([value], 1)=="" ? value : this.Quote(value)
		}

		Quote(string)
		{
			static q := Chr(34)

			if (string != "") {
				  string := StrReplace(string,  "\",    "\\")
				; , string := StrReplace(string,  "/",    "\/") ; optional in ECMAScript
				, string := StrReplace(string,    q, "\" . q)
				, string := StrReplace(string, "`b",    "\b")
				, string := StrReplace(string, "`f",    "\f")
				, string := StrReplace(string, "`n",    "\n")
				, string := StrReplace(string, "`r",    "\r")
				, string := StrReplace(string, "`t",    "\t")

				static rx_escapable := A_AhkVersion<"2" ? "O)[^\x20-\x7e]" : "[^\x20-\x7e]"
				while RegExMatch(string, rx_escapable, m)
					string := StrReplace(string, m.Value, Format("\u{1:04x}", Ord(m.Value)))
			}

			return q . string . q
		}
	}

	/**
	 * Property: Undefined
	 *     Proxy for 'undefined' type
	 * Syntax:
	 *     undefined := JSON.Undefined
	 * Remarks:
	 *     For use with reviver and replacer functions since AutoHotkey does not
	 *     have an 'undefined' type. Returning blank("") or 0 won't work since these
	 *     can't be distnguished from actual JSON values. This leaves us with objects.
	 *     The caller may return a non-serializable AHK objects such as ComObject,
	 *     Func, BoundFunc, FileObject, RegExMatchObject, and Property to mimic the
	 *     behavior of returning 'undefined' in JavaScript but for the sake of code
	 *     readability and convenience, it's better to do 'return JSON.Undefined'.
	 *     Internally, the property returns a ComObject with the variant type of VT_EMPTY.
	 */
	Undefined[]
	{
		get {
			static empty := {}, vt_empty := ComObject(0, &empty, 1)
			return vt_empty
		}
	}

	class Functor
	{
		__Call(method, args*)
		{
		; When casting to Call(), use a new instance of the "function object"
		; so as to avoid directly storing the properties(used across sub-methods)
		; into the "function object" itself.
			if IsObject(method)
				return (new this).Call(method, args*)
			else if (method == "")
				return (new this).Call(args*)
		}
	}
}