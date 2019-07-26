#SingleInstance force
#include %A_ScriptDir%\..\class_RADical.ahk
#include %A_ScriptDir%\..\..\lib-i_to_z\JSON.ahk                        	; http://ahkscript.org/boards/viewtopic.php?t=627
#include %A_ScriptDir%\..\..\lib-i_to_z\ProfileHandler.ahk		    	; https://github.com/evilC/ProfileHandler
#include %A_ScriptDir%\..\class_HotClass.ahk               					; https://github.com/evilC/HotClass
;#include %A_ScriptDir%\..\class_CInputDetector.ahk               					

; ===========================================================================================================
; =====================================   SAMPLE CLIENT SCRIPT   ============================================
; ===========================================================================================================
rc := new RADicalClient()

class RADicalClient extends RADical {
	; Configure RADical - this is called before the GUI is created. Set RADical options etc here.

	Config(){
		; Client Scripts can consist of more than one tab... Let's add two
		RADical.Tabs(["Client Tab A", "Client Tab B"])
		RADical.Title("RADical Demo")
	}
	
	; Called after Initialization - Assemble your GUI, set up your hotkeys etc here.
	Init(){
		Gui, Add, Text, w100 xm ym, Per-Profile Hotkey
		RADical.AddHotkey("hk1", this.hk1Changed.Bind(this), "w200 xp+100 yp-2")
		
		Gui, Add, Text, w100 xm yp+30, Per-Profile EditBox
		this.MyEdit := RADical.GuiAdd("MyEdit", this.MyEditChanged.Bind(this), "Edit", "w200 xp+100",,"Default Text")
		
		Loop 10 {
			Gui, Add, Edit, xm
		}
		
		RADical.Tab("Client Tab B")
		Gui, Add, Text, xm ym, Client Scripts can consist of more than one tab...
		
		Loop 20 {
			Gui, Add, Edit, xm
		}

	}
	
	; Once all setup is done, this function is called
	Main(){
		
	}
	
	; User-defined Callbacks
	
	hk1Changed(event){
		events := {0: "Released", 1: "Pressed"}
		tooltip % "Hotkey hk1 was " events[event]
	}
	
	MyEditChanged(){
		Tooltip % "MyEdit changed to: " this.MyEdit.value
	}
}
