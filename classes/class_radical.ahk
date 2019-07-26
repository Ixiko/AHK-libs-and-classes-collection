; ===========================================================================================================
; ========================================   RADICAL LIBRARY   ==============================================
; ===========================================================================================================

; Bootstrap class - Client Script must derive from this Class
; Instantiates client script
; Instantiates RADical class
; Fires off class methods in pre-determined order
class RADical {
	__New(){
		;static autostart := new RADicalClient()	; Trick to automatically instantiate Client Script
		OutputDebug DBGVIEWCLEAR
		OutputDebug % "Instantiating RADical class..."
		global RADical := new _radical(this)
		
		OutputDebug % "Configuring RADical..."
		this.Config()
		OutputDebug % "Initializing RADical..."
		RADical._Init()
		OutputDebug % "Initializing Client Script..."
		this.Init()
		OutputDebug % "Starting RADical..."
		RADical._Start()
		OutputDebug % "Calling Client Script Main()..."
		this.Main()
	}
}

; The main class that does the heavy lifting
; Client Scripts will call methods in this class
class _RADical {
	; --------------------- Public Routines ---------------------
	; Stuff Intended to be called by Client Scripts

	; Sets a custom title for the script Gui
	Title(title){
		this._Title := title
	}
	
	; Equivalent to Gui, Tab, Name
	Tab(name){
		Gui, % this._TabGuiHwnds[name] ":Default"
	}
	
	; Called during config phase to declare required Client Tabs
	Tabs(tabarr){
		if (tabarr.length()){
			this._ClientTabs := tabarr
		}
	}

	; Add a hotkey
	AddHotkey(name, callback, options := ""){
		this.Hotkeys[name] := this.HotClass.AddHotkey(name, callback, options)
	}
	
	; Adds a persistent GuiControl
	GuiAdd(name, callback, ctrltype, options := "", text := "", Default := ""){
		this.GuiControls[name] := new this._PersistentGuiControl(this._ClientGuiControlChanged.Bind(this, name), ctrltype, options, text, Default)
		this.GuiControls[name]._ClientCallback := callback
		return this.GuiControls[name]
	}
	
	; Closes the script. Also causes the script to exit on Gui Close
	Exit(){
		GuiClose:
			ExitApp
	}
	
	; --------------------- Private Routines ---------------------
	; Behind-the-scenes stuff the user should not be touching
	_ClientTabs := ["Main"]			; Indexed Array of Client Tab names
	_TabFrameHwnds := {}			; Hwnds of the Textboxes that are the parents of the Child Guis inside the tabs
	_TabGuiHwnds := {}				; Hwnds of the child GUIs inside the tabs
	__New(clientscript){
		; Speed Optimizations
		SetBatchLines -1
		
		; Default Title to Script Name without the .ahk / .exe extension
		if (A_IsCompiled){
			title := StrSplit(A_ScriptName, ".exe")
		} else {
			title := StrSplit(A_ScriptName, ".ahk")
		}
		this._Title := title[1]
		
		; Initialize values
		this._ClientScript := clientscript
		Gui, +Resize
		Gui, +Hwndhwnd
		this._MainHwnd := hwnd
		this.Hotkeys := {}
		this.GuiControls := {}
		this._GuiSettings := {PosX: {_PHDefaultValue: 0}, PosY: {_PHDefaultValue: 0}, PosW: {_PHDefaultValue: 350}, PosH: {_PHDefaultValue: 250}}
		this.HotClass := new HotClass({OnChangeCallback: this._HotkeyChanged.Bind(this)})
		;this.HotClass := new HotClass({OnChangeCallback: this._HotkeyChanged.Bind(this), disablejoystickhats: 1}) ; Disabling Joystick hats stops the Timer interrupting debugging
		this.HotClass.DisableHotkeys()
	}
	
	; Sets up the GUI ready for the Client Script to add it's own GuiControls
	; Mainly for handling adding of the Tabs and Profile Management GuiControls
	_Init(){
		; Configure Tabs
		this._Tabs := []
		Loop % this._ClientTabs.length(){
			this._Tabs.push(this._ClientTabs[A_Index])
		}
		this._Tabs.push("Profiles")
		tablist := ""
		Loop % this._Tabs.length(){
			if (A_Index > 1){
				tablist .= "|"
			}
			tablist .= this._Tabs[A_Index]
		}
		Gui, Add, Tab2, w350 h240 hwndhTab -Wrap, % tablist
		this.hTab := hTab
		;colors := {"Tab A": "FF0000", "Tab B": "0000FF", "Profiles": "00FF00"}	; debugging - remove
		Loop % this._Tabs.length(){
			tabname := this._Tabs[A_Index]
			; Inject child gui into Tab
			Gui, % this._GuiCmd("Tab"), % tabname
			Gui, % this._GuiCmd("Add"), Text, % "hwndhwnd w330 h200"
			this._TabFrameHwnds[tabname] := hwnd
			try {
				; Experimental AHK scrollbar support
				Gui, New, hwndhwnd -Caption +Scroll
			} catch {
				Gui, New, hwndhwnd -Caption
			}
			this._TabGuiHwnds[tabname] := hwnd
			Gui, % "+Parent" this._TabFrameHwnds[tabname]
			;Gui, Color, % colors[tabname]	; debugging - remove
			Gui, Show
		}
		fn := this._OnSize.Bind(this)
		OnMessage(0x0005, fn)	; WM_SIZE
		
		this.Tab("Profiles")
		this._ProfileHandler := new ProfileHandler()
		this._ProfileHandler.SetPreLoadCallback(this._PreProfileLoad.Bind(this))
		this._ProfileHandler.SetPostLoadCallback(this._PostProfileLoad.Bind(this))
		
		; Set Default Gui as Child Gui of first Client Tab
		this.Tab(this._ClientTabs[1])
	}

	; Finish startup process
	_Start(){
		this.HotClass.DisableHotkeys()
		; Why does this line stop debugging from working, and stop Gui coordinates being remembered?
		this._ProfileHandler.Init({Global: {GuiSettings: this._GuiSettings}, PerProfile: {Hotkeys: this.Hotkeys, GuiControls: this.GuiControls}})
		;this._ProfileHandler.Init({Global: {GuiSettings: this._GuiSettings}})
		; ToDo: Check if coords lie outside screen area and move On-Screen if so.
		Gui, % this._GuiCmd("Show"), % "x" this._GuiSettings.PosX.value " y" this._GuiSettings.PosY.value " w" this._GuiSettings.PosW.value " h" this._GuiSettings.PosH.value, % this._Title
		; Hook into WM_MOVE after window is shown
		fn := this._OnMove.Bind(this)
		OnMessage(0x0003, fn)	; WM_MOVE
		this.HotClass.EnableHotkeys()
	}

	; Sizes child Guis in Tabs to fill size of tab
	_OnSize(wParam, lParam, msg, hwnd){
		; ToDo: Use DeferWindowPos to reduce flicker?
		if (hwnd != this._MainHwnd){
			return
		}
		;critical
		w := (lParam & 0xffff), h := (lParam >> 16), fw := w - 45, fh := h - 55, gw := w - 45, gh := h - 55
		dllcall("MoveWindow", "Ptr", this.hTab, "int", 10,"int", 10, "int", w - 20, "int", h - 20, "Int", 1)
		Loop % this._Tabs.length(){
			tabname := this._Tabs[A_Index]
			dllcall("MoveWindow", "Ptr", this._TabFrameHwnds[tabname], "int", 25,"int", 35, "int", fw, "int", fh, "Int", 1)
			;ControlMove, % this._TabFrameHwnds[tabname], , , % w, % h
			dllcall("MoveWindow", "Ptr", this._TabGuiHwnds[tabname], "int", 0,"int", 0, "int", gw, "int", gh, "Int", 1)
		}
		this._GuiSettings.PosW.value := w
		this._GuiSettings.PosH.value := h
		this._ProfileHandler.SettingChanged()
	}
	
	; Called when window moves. Store new coords in settings file
	_OnMove(wParam, lParam, msg, hwnd){
		if (hwnd != this._MainHwnd){
			return
		}
		;this._GuiSettings.PosX.value := (lParam & 0xffff) - 45
		;this._GuiSettings.PosY.value := (lParam >> 16) - 45
		; wParam and lParam are coords of the CLIENT area, and we want window position. Use WinGetPos instead
		WinGetPos, x, y
		this._GuiSettings.PosX.value := x
		this._GuiSettings.PosY.value := y
		this._ProfileHandler.SettingChanged()
	}
	
	; Prefixes _MainHwnd hwnd to guicommand
	_GuiCmd(cmd){
		return this._MainHwnd ":" cmd
	}
	
	; Put HotClass into IDLE state before loading hotkeys
	_PreProfileLoad(){
		this.HotClass.DisableHotkeys()
	}
	
	; Put HotClass into ACTIVE state after loading hotkeys
	_PostProfileLoad(){
		this.HotClass.EnableHotkeys()
	}

	; Called when a Hotkey changes binding
	_HotkeyChanged(aParams*){
		if (!this._ProfileHandler.ProfileLoading){
			; If ProfileHandler is loading a profile, do not fire SettingChanged...
			; ... as this will cause the profile Handler to save the profile part way through loading
			; ToDo: This seems a little hacky. Can it be improved?
			this._ProfileHandler.SettingChanged()
		}
	}

	; Called when a Client GuiControl changes
	_ClientGuiControlChanged(name){
		this._ProfileHandler.SettingChanged()
		; Asynchronously fire Client Callback
		fn := this.GuiControls[name]._ClientCallback
		SetTimer, % fn, -0
	}
	
	; ========================= GuiControl Wrapper ===================================
	/*
	This wraps GuiControls in a manner suitable for use with the ProfileHandler

	It ensures that any get or set of the .value property sets or gets the contents of the GuiControl
	First param specifies the "g-label" to call when the GuiControl changes through user interaction
	Next, it accepts the normal params as would be used in a Gui, Add command (eg ControlType, Options, Text)
	Next, it accepts a "Default" param to specify the Default Value
	*/
	class _PersistentGuiControl {
		__New(callback, ctrltype, options := "", text := "", Default := ""){
			this._PHDefaultValue := Default ; This property will be expected by the ProfileHandler class, and should contain the Default Value
			this._callback := callback
			Gui, Add, % ctrltype, % options " hwndhwnd", % text
			this.hwnd := hwnd
			fn := this.ControlChanged.Bind(this)
			GuiControl +g, % hwnd, % fn
		}
		
		; The control changed state either through user interaction, or through change of profile
		ControlChanged(){
			GuiControlGet, val, , % this.hwnd
			this._value := val
			this._callback.()
		}
		
		; Getters and Setters.
		; Trap Gets or sets of .value, and re-route to ._value
		; On Set of .value, also change state of GuiControl
		value[]{
			get {
				return this._value
			}
			
			set {
				GuiControl,, % this.hwnd, % value
				return this._value := value
			}
		}
	}

}

;#include <JSON>											     	    	; http://ahkscript.org/boards/viewtopic.php?t=627
;#include <ProfileHandler>							     	    		; https://github.com/evilC/ProfileHandler
;#include %A_LineFile%\..\class_HotClass.ahk					; https://github.com/evilC/HotClass