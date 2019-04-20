#include %A_ScriptDir%\..\MouseDelta.ahk
#SingleInstance,Force
 
Gui, Add, ListBox, w300 h200 hwndhOutput
Gui, Add, Text, xm w300 center, Hit F12 to toggle on / off
Gui, Show,, Mouse Watcher
 
MacroOn := 0
md := new MouseDelta("MouseEvent")
 
return
 
GuiClose:
	md.Delete()
	md := ""
	ExitApp

F12::
	MacroOn := !MacroOn
	md.SetState(MacroOn)
	return
 
; Gets called when mouse moves
; x and y are DELTA moves (Amount moved since last message), NOT coordinates.
MouseEvent(MouseID, x := 0, y := 0){
	global hOutput
	static text := ""
	static LastTime := 0
 
	t := A_TickCount
	text := "x: " x ", y: " y (LastTime ? (", Delta Time: " t - LastTime " ms, MouseID: " MouseID) : "")
	GuiControl, , % hOutput, % text
	sendmessage, 0x115, 7, 0,, % "ahk_id " hOutput
	LastTime := t
}