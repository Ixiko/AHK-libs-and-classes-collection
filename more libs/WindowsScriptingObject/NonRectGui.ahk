; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=6&t=60903&hilit=createForm&sid=da4b6b3a472c35848194cd9df22b03db
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

;WindowSystemObject (WSO) example
;Copyright (C) Veretennikov A. B. 2004-2015
;This script by burque505, taken
;from a WSO stock demo in JScript

#Include WSOConsts.ahk

global Wso := ComObjCreate("Scripting.WindowSystemObject")
global Regions := Wso.Regions

; Form creation and init
global Form := Wso.CreateForm()
Form.SizeGrip := false
Form.Caption := false
Form.MaximizeBox := false
Form.Text := "Region Demo"
Form.ClientWidth := 300
Form.ClientHeight := 200
Form.CenterControl()

; "Close" button code
x := Form.CreateButton(120,90,75,25,"Close")
x.OnClick := func("Bail")
x.Default := true
x.Cancel := true

; The code here is really beyond me, especially the Wso.Translate stuff.
; But it does work :)
Ellipse := Regions.CreateEllipticRgn(20,20,260,160)
Ring := Regions.CombineRgn(Ellipse,Regions.CreateEllipticRgn(30,30,240,140),Wso.Translate("RGN_DIFF"))
Star := Regions.CreatePolygonRgn(150,0,220,200,0,60,300,60,80,200,Wso.Translate("WINDING"))
Region := Regions.CombineRgn(Ring,Star,Wso.Translate("RGN_OR"))

Form.Region := Region

; Note the color definition.
Form.Brush.Color := 0x00FF0000
Form.DrawRegion(0,0,Region)

global Text := Form.TextOut(40,70,"")
; must be global, apparently.
Text.Font.Bold := true
Text.Font.Color := 0x00FFFFFF

; This is to keep the clock ticking.
Timer1 := Wso.CreateTimer()
Timer1.Interval := 100
Timer1.Active := true
Timer1.OnExecute := Func("TimerExecute")

Form.Show()

Wso.Run()

TimerExecute(This) {
	FormatTime, outvar, %A_Now%,   HH:mm:ss tt              MMM dd`, yyyy 
	Text.text := outvar
}

Bail(this) {
	ExitApp
}
