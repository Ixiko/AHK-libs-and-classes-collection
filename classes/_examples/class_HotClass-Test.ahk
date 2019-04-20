; Proof of concept for replacement for HotClass
#include hotclass.ahk

OutputDebug, DBGVIEWCLEAR
/*
============================================================================================================
Test script for Hotclass
Performs automated tests, plus loads a bunch of bindings for manual testing

Automated tests send fake input objects to _ProcessInput and assert that the callbacks were fired correctly.
Only matching logic is tested by the automated tests.
============================================================================================================
*/
#SingleInstance force
th := new TestHarness()
return

GuiClose:
	ExitApp

class TestHarness {
	__New(){
		this.HotkeyStates := []
		this.HotClass := new HotClass()
		; Order
		; 0 = Off
		; 1 = End key must match
		; 2 = Order must match (may be keys inbeteen)
		; 3 = Absolute order (no keys inbetween)
		this.HotClass.EnforceOrder := 0
		Loop % 12 {
			this.HotkeyStates[A_Index] := 1
			name := "hk" A_Index
			this.HotClass.AddHotkey(name, this.hkPressed.Bind(this, A_Index), "w280 xm")
			Gui, Add, Checkbox, Disabled hwndhwnd xp+290 yp+4
			this.hStateChecks[name] := hwnd
		}
		Gui, Show, x0 y0
		
		; Build a list of keys. UIDs would not normally be needed, but seeing as we will be simulating input, we will need them.
		keys := {}
		keys.a := {type: "k", code: 30, uid: "k30"}
		keys.ctrl := {type: "k", code: 29, uid: "k29"}
		keys.shift := {type: "k", code: 42, uid: "k42"}
		keys.alt := {type: "k", code: 56, uid: "k56"}
		keys.s := {type: "k", code: 31, uid: "k31"}
		keys.lbutton := {type: "m", code: 1, uid: "m1"}
		
		; Load bindings
		this.HotClass.DisableHotkeys()
		this.HotClass.SetHotkey("hk1", [keys.a])
		this.HotClass.SetHotkey("hk2", [keys.ctrl,keys.a])
		this.HotClass.SetHotkey("hk3", [keys.shift,keys.a])
		this.HotClass.SetHotkey("hk4", [keys.ctrl,keys.shift,keys.a])
		this.HotClass.SetHotkey("hk5", [keys.s])
		this.HotClass.SetHotkey("hk6", [keys.ctrl,keys.s])
		this.HotClass.SetHotkey("hk7", [keys.shift,keys.s])
		this.HotClass.SetHotkey("hk8", [keys.ctrl,keys.shift,keys.s])
		this.HotClass.SetHotkey("hk9", [keys.ctrl,keys.shift])
		this.HotClass.SetHotkey("hk10", [keys.alt,keys.ctrl,keys.shift,keys.a])
		this.HotClass.SetHotkey("hk11", [keys.ctrl,keys.lbutton])
		this.HotClass.SetHotkey("hk12", [{type: "m", code: 4},{type: "h", joyid: 2, code: 1}])
		this.HotClass.EnableHotkeys()
		
		;this.DoTests()
	}
	
	DoTests(){
		; Perform Automated Tests
		; Press A+S
		this.TestInput(keys.a,1).TestInput(keys.s,1)
		this.Assert(1, true, "1")
		this.Assert(5, true, "1")
		
		; Press CTRL
		this.TestInput(keys.ctrl,1)
		this.Assert(1, false, "2")
		this.Assert(2, true, "2")
		this.Assert(6, true, "3")
		
		; Press Shift
		this.TestInput(keys.shift,1)
		this.Assert(4, true, "4")
		this.Assert(7, true, "4")
		this.Assert(2, false, "4")
		this.Assert(6, false, "4")
		
		; Press Alt
		this.TestInput(keys.alt,1)
		this.Assert(9, true, "5")
		this.Assert(4, false, "5")
		
		; Release Alt
		this.TestInput(keys.alt,0)
		this.Assert(3, true, "6")
		
		; Release A+S
		this.TestInput(keys.a, 0).TestInput(keys.s, 0)
		this.Assert(9, true, "7")
		
		; Press A
		this.TestInput(keys.a, 1)
		this.Assert(9, false, "7")
		this.Assert(4, true, "7")
		
		; Release Ctrl + Shift
		this.TestInput(keys.ctrl, 0).TestInput(keys.shift, 0)
		this.Assert(1, true, "8")
		
		; Release A
		this.TestInput(keys.a, 0)
		this.Assert(1, false, "9")
	}
	
	; called when hk1 goes up or down.
	hkPressed(hk, event){
		name := "hk" hk
		GuiControl,,% this.hStateChecks[name], % event
		this.HotkeyStates[hk] := event
	}
	
	Assert(hk, state, testid){
		sleep 100
		if (this.HotkeyStates[hk] = state){
			return 1
		} else {
			msgbox % "Test " testid " FAIL:`nHotkey: hk" hk "`nExpected State: " state "`nActual State: " this.HotkeyStates[hk]
		return 0
		}
	}
	
	; Simulate input
	TestInput(keys, event){
		this.HotClass._ProcessInput(event(keys,event))
		return this
	}
}

event(obj, event){
	obj.event := event
	return obj
}
