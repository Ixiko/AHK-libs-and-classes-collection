;* 13/11/2020:
	;* Added a check to determine if the sine wave visualization needs to be redrawn.
	;* Added a new Canvas to avoid redrawing the sine wave visualization all the time.
	;* Refactored code.
;* 11/11/2020:
	;* Initial commit.

;=====         Auto-execute         =========================;
;===============           Setting            ===============;

#Include, <Color>
#Include, <General>
#Include, <ObjectOriented>
#Include, <Math>
#Include, <GDIp>
#Include, <Geometry>

#KeyHistory, 0
#NoEnv
#Persistent
#SingleInstance, Force

CoordMode, Mouse, Screen
ListLines, Off
Process, Priority, , R
SetBatchLines, -1
SetWorkingDir, % A_ScriptDir . "\..\..\.."

;===============           Variable           ===============;

IniRead, Debug, % A_WorkingDir . "\cfg\Settings.ini", Debug, Debug
Global Debug

	, Radius := 150, Diameter := Radius*2

	, Canvas1 := new GDIp.Canvas({"x": A_ScreenWidth - (Diameter + 50 + 10 + 1), "y": 50, "Width": Diameter + 10, "Height": Diameter + 10}, "-Caption +AlwaysOnTop +ToolWindow +OwnDialogs +E0x20", "gCanvas1")
	, Canvas2 := new GDIp.Canvas({"x": Canvas1.Position.x - (Diameter + 10), "y": Canvas1.Position.y, "Width": Canvas1.Position.Width, "Height": Diameter/3 + 10}, "-Caption +AlwaysOnTop +ToolWindow +OwnDialogs +E0x20", "gCanvas2")
	, Canvas3 := new GDIp.Canvas(new Rectangle(0, 0, A_ScreenWidth - 5, A_ScreenHeight - 5), "-Caption +AlwaysOnTop +ToolWindow +OwnDialogs +E0x20", "gCanvas3")
		, Brush := [new GDIp.Brush(), new GDIp.Brush(0xFFFF0000)]
		, Pen := [new GDIp.Pen(0x80FFFFFF), new GDIp.Pen()]

;===============             Gui              ===============;

Gui, gControl: New, -Caption +AlwaysOnTop +ToolWindow +OwnDialogs +LastFound +HwndgControl
WinSet, Transparent, 127.5
Gui, Color, 0xFFFFFF  ;! Color.Random("")
Gui, Show, % "x" . 5 + Canvas1.Position.x - 140 - 100 . " y" . 5 + Canvas1.Position.y + Radius - 80/2 . " w" . 140 . " h" . 80 . " NA", gControl
;* Reset
Gui, Add, Button, x5 y5 w20 h20 gReset, &R
;* Sectors
Gui, Add, Edit, x30 y5 w45 h20 Center Number Limit5
Gui, Add, UpDown, Left Range0-500 gCreateSectors vsectors 0x80
;* Multiplier
Gui, Add, Edit, x80 y5 w55 h20 Center Number Limit5 vmultiplier
Gui, Add, UpDown, Left Range0-1 gOffset v__multiplier -2
;* Color Setting
Gui, Add, DropDownList, x5 y30 w105 h20 r4 gColorSetting vcolorSetting, Solid|Distance Alpha|Distance Color|Oscillate Color
;* Cycle
Gui, Add, Button , x115 y30 w20 h20 gCycle, &C
;* Pen Width
Gui, Add, Edit, x5 y55 w30 h20 Left Number +HwndgDefault1
Gui, Add, UpDown, Left Wrap Range1-3 +HwndgDefault2 gPenWidth
Gui, Add, Edit, x5 y105 w30 h20 Left Number
Gui, Add, UpDown, Left Wrap Range1-3 gPenWidth
;* Anti Alias
Gui, Add, Checkbox, x40 y55 w18 h20 Checked +HwndgDefault3 gAntiAlias
Gui, Add, Checkbox, x40 y105 w18 h20 Checked gAntiAlias
;* Hide
Gui, Add, Button, x58 y55 w52 h20 +HwndgDefault4 gHide, &NSFW
Gui, Add, Button, x58 y105 w52 h20 gHide, &NSFW
;* Help
Gui, Add, Button, x115 y55 w20 h20 +HwndgDefault5 gHelp, &H
Gui, Add, Button, x115 y105 w20 h20 gHelp, &H
;* Oscillate Color
Gui, Add, Edit, w20 h20 Center Disabled Hidden +HwndgExtended1 vfrequency
Gui, Add, Slider, x5 y55 w108 h20 AltSubmit Hidden Buddy2frequency Range0-60 Thick10 TickInterval10 +HwndgExtended2 gOffset v__frequency
Gui, Add, Edit, w20 h20 Center Disabled Hidden +HwndgExtended3 vphase
Gui, Add, Slider, x5 y80 w108 h20 AltSubmit Hidden Buddy2phase Range0-12 Thick10 TickInterval2 +HwndgExtended4 gOffset v__phase

;===============            Other             ===============;

OnExit("Exit"), OnMessage(0x101, "RegisterKeys")  ;* Hack to register {0 -> 9} and {Enter} on Edit1 and Edit2.

GoSub, Reset

Exit

;=====            Hotkey            =========================;

#If (WinActive(A_ScriptName) || WinActive("GDIp.ahk") || WinActive("Geometry.ahk"))

	~$^s::
		Critical

		Sleep, 200
		Reload
		Return

	$F10::ListVars

#If

~$Space::
	If (KeyWait("Space", "T0.5")) {
		GoSub, Hide

		KeyWait("Space")
	}

	Return

~$Esc::
	If (KeyWait("Esc", "T1")) {
		Exit()
	}

	Return

;=====            Label             =========================;

Reset:
	If (cycle) {
		GoSub, Cycle
	}

	Pen[1].Width := 1
		, sectors := 200, multiplier := 2.00

	GuiControl, Choose, ComboBox1, 1
	Loop, 8 {
		GuiControl, , % ((A_Index < 7) ? ("Edit" . A_Index) : ("msctls_trackbar32" . A_Index - 6)), % ((A_Index == 1) ? (sectors) : (((A_Index == 2) ? (multiplier) : (((A_Index < 5) ? (1) : (((A_Index == 5) ? (2.0) : (((A_Index == 6) ? (4.0) : (((A_Index == 7) ? (20) : (8))))))))))))
	}

ColorSetting:
	Gui, gControl: Submit, NoHide

	guiMode1 := (colorSetting == "Oscillate Color")

	If (guiMode2 != guiMode1) {
		If (!guiMode1) {
			Pen[0].Color := 0x80FFFFFF

			Gui, gControl: Show, h80 NA

			Loop, 5 {
				Control, Show, , , % "ahk_id" . gDefault%A_Index%
				If (A_Index < 5) {
					Control, Hide, , , % "ahk_id" . gExtended%A_Index%
				}
			}

			Gui, gCanvas2: Hide
		}
		Else {
			Pen[0].Color := Format("{:#X}{:02X}{:02X}{:02X}", 128, Sin(phase)*127.5 + 127.5, Sin(phase + 2.094395102393196)*127.5 + 127.5, Sin(phase + 4.188790204786391)*127.5 + 127.5)

			Gui, gControl: Show, h130 NA

			Loop, 5 {
				Control, Hide, , , % "ahk_id" . gDefault%A_Index%
				If (A_Index < 5) {
					Control, Show, , , % "ahk_id" . gExtended%A_Index%
				}
			}

			GoSub, Sine

			Gui, gCanvas2: Show, NA
		}

		If (help) {
			help := "*"

			GoSub, Help
		}
	}

	guiMode2 := guiMode1

CycleCheck:
	If (cycle) {
		Return
	}

CreateSectors:
	Critical

	If (cycle) {
		multiplier := Round((multiplier == 500) ? (0) : (multiplier + 0.05), 2)

		ControlSetText, Edit2, % multiplier, % "ahk_id" . gControl
	}

	Canvas1.DrawEllipse(Pen[0], {"x": 5, "y": 5, "Width": Diameter, "Height": Diameter})

	s := Min(200, sectors)

	If (guiMode1 && sine != s) {  ;* Only draw the sine wave visualization as needed.
		;* This would be less computationally intensive but because the rectangle won't be drawn if `width` is below 1, `sectors` must be limited to ~200 to maintain the `width` and `height` ratio:
		If (sectors <= 200) {
			r := Diameter/s
				, x := 5 - r*0.25, y := Canvas2.Position.Height/2 + 1

				, colorSetting := "*"

			Canvas2.DrawRectangle(Pen[0], {"x": 5, "y": Canvas2.Position.Height/2, "Width": Canvas2.Position.Width - 10, "Height": 2})
		}
		Else {
			GoSub, Sine
		}
	}

	o := 5 + Radius, f := 3.141592653589793*frequency/sectors

	Loop, % sectors {
		;* Calculate the points for the start and end of the line that needs to be drawn:
		i := A_Index - 1, a := i*(-6.283185307179587/sectors)
			, x1 := Radius*Cos(a), y1 := Radius*Sin(a)
			, x2 := Radius*Cos(a *= Mod(multiplier, sectors)), y2 := Radius*Sin(a)

		;* Calculate the color of the line that needs to be drawn:
		Switch (colorSetting) {
			Case "Solid":
				Pen[1].Color := 0xFFFFFFFF
			Case "Distance Alpha":
				;* Calculate the distance between the start and end of the line and translate that into a range of 0 -> 255:
				v := Abs(Floor(Sqrt((x2 - x1)**2 + (y2 - y1)**2)/Diameter*255) - 255)
					, Pen[1].Color := Format("{:#X}{:02X}{2:02X}{2:02X}", v, 255)
			Case "Distance Color":
				;* Calculate the distance between the start and end of the line and translate that into a range of 0 -> 240 with an offset to have red (160) at the center and then to a range of 0 -> 255:
				v := (v := Floor(Sqrt((x2 - x1)**2 + (y2 - y1)**2)/Diameter*240) + 160) + ((v > 240) ? (-240) : (0))
					, Pen[1].Color := Format("{:#X}{:06X}", 255, DllCall("shlwapi\ColorHLSToRGB", "UInt", v, "UInt", 120, "UInt", 240))
			Case "Oscillate Color":
				;* Calculate values for the R, G and B components with out of sync sine waves and translate that to a range of 0 -> 255:
				v := f*i + phase
					, Pen[1].Color := Format("{:#X}{:02X}{:02X}{:02X}", 255, Sin(v)*127.5 + 127.5, Sin(v + 2.094395102393196)*127.5 + 127.5, Sin(v + 4.188790204786391)*127.5 + 127.5)
			Case "*":
				v := f*i + phase
					, Pen[1].Color := Format("{:#X}{:02X}{:02X}{:02X}", 255, Sin(v)*127.5 + 127.5, Sin(v + 2.094395102393196)*127.5 + 127.5, Sin(v + 4.188790204786391)*127.5 + 127.5)

					, v := Sin(v - phase)*25

				Canvas2.DrawRectangle(Pen[1], {"x": x + i*r, "y": y + (v < 1)*v, "Width": r*1.25, "Height": Abs(v)})
		}

		;* Draw the line:
		Canvas1.DrawLine(Pen[1], {"x": o + x1, "y": o + y1}, {"x": o + x2, "y": o + y2})
	}

	Canvas1.Update()

	If (colorSetting == "*") {
		sine := s
			, colorSetting := "Oscillate Color"

		Canvas2.Update()
	}

	Return

Offset:
	Switch (A_GuiControl) {
		Case "__multiplier":
			multiplier := Round(Math.Clamp((__multiplier) ? (multiplier + 0.05) : (multiplier - 0.05), 0, 500), 2)

			GuiControl, , multiplier, % multiplier

			GoTo, CycleCheck
		Case "__frequency":
			frequency := Round(__frequency/10, 1)
				, sine := "*"

			GuiControl, , frequency, % frequency
		Case "__phase":
			phase := Round(__phase/2, 1)
				, Pen[0].Color := Format("{:#X}{:02X}{:02X}{:02X}", 128, Sin(phase)*127.5 + 127.5, Sin(phase + 2.094395102393196)*127.5 + 127.5, Sin(phase + 4.188790204786391)*127.5 + 127.5)
				, sine := "*"

			GuiControl, , phase, % phase
	}

Sine:
	s := Min(200, sectors)

	If (sine != s) {
		r := Diameter/s
			, x := 5 - r*0.25, y := Canvas2.Position.Height/2 + 1
			, f := 3.141592653589793*frequency/s

		Canvas2.DrawRectangle(Pen[0], {"x": 5, "y": Canvas2.Position.Height/2, "Width": Canvas2.Position.Width - 10, "Height": 2})

		Loop, % s {
			i := A_Index - 1, v := f*i + phase
				, Pen[1].Color := Format("{:#X}{:02X}{:02X}{:02X}", 255, Sin(v)*127.5 + 127.5, Sin(v + 2.094395102393196)*127.5 + 127.5, Sin(v + 4.188790204786391)*127.5 + 127.5)

				, v := Sin(v - phase)*25

			Canvas2.DrawRectangle(Pen[1], {"x": x + i*r, "y": y + (v < 1)*v, "Width": r*1.25, "Height": Abs(v)})  ;* Offset `x` and `Width` to achieve overlapping.
		}

		sine := s

		Canvas2.Update()
	}

	GoTo, CycleCheck

PenWidth:
	;* The same variable can't be assigned to two controls and moving a control with a buddy screws up the buddy control's position so we need to ensure they match here. Changing one, changes the other:
	GuiControlGet, v, , % "Edit" . 3 + guiMode1

	Pen[1].Width := v
	GuiControl, , % "Edit" . 4 - guiMode1, % v

	sine := "*"

	GoTo, CycleCheck

AntiAlias:
	GuiControlGet, v, , % "Button" . 3 + guiMode1

	Canvas1.SmoothingMode := 3 + v  ;? 3 = None, 4 = AntiAlias
	Canvas2.SmoothingMode := 3 + v
	GuiControl, , % "Button" . 4 - guiMode1, % v

	sine := "*"

	GoTo, CycleCheck

Cycle:
	SetTimer("CreateSectors", ((cycle := !cycle) ? (50) : ("Delete")))

	Return

Hide:
	If (hide := !hide) {
		If (cycle) {
			GoSub, Cycle
		}

		Gui, gControl: Hide
		Loop, 3 {
			Gui, % "gCanvas" . A_Index . ": Hide"
		}
	}
	Else {
		Gui, gControl: Show, NA
		Gui, gCanvas1: Show, NA
		If (guiMode1) {
			Gui, gCanvas2: Show, NA
		}
		If (help) {
			Gui, gCanvas3: Show, NA
		}
	}

	Return

Help:
	help := !help + (help == "*")


	If (help) {
		x := 5 + Canvas1.Position.x - 140 - 100, y := 5 + Canvas1.Position.y + Radius - 80/2
			, v := 50*guiMode1

		Loop, % 10 + 2*guiMode1 {
			Canvas3.DrawString(Brush[[1, 8, 9].Includes(A_Index)], ((A_Index == 1) ? ("Reset ⮞") : (((A_Index == 2) ? ("Line count ⮟") : (((A_Index == 3) ? ("⮟ Multiplier") : (((A_Index == 4) ? ("⮜ Cycle") : (((A_Index == 5) ? ("Color mode ⮞") : (((A_Index == 6) ? ("Line width ⮞") : (((A_Index == 7) ? ("AntiAlias ⮝") : (((A_Index == 8) ? ("⮝ Hide Gui") : (((A_Index == 9) ? ("(Hold spacebar)") : (((A_Index == 10) ? ("⮜ Help") : (((A_Index == 11) ? ("Frequency ⮞") : ("Phase ⮞")))))))))))))))))))))) , ((A_Index == 1) ? ("x" . x - 66 . "y" . y + 7) : (((A_Index == 2) ? ("x" . x - 53 . "y" . y - 19) : (((A_Index == 3) ? ("x" . x + 80 . "y" . y - 19) : (((A_Index == 4) ? ("x" . x + 142 . "y" . y + 32) : (((A_Index == 5) ? ("x" . x - 110 . "y" . y + 32) : (((A_Index == 6) ? ("x" . x - 101 . "y" . y + 57 + v) : (((A_Index == 7) ? ("x" . x - 35 . "y" . y + 83 + v) : (((A_Index == 8) ? ("x" . x + 74 . "y" . y + 83 + v) : (((A_Index == 9) ? ("x" . x + 92 . "y" . y + 99 + v) : (((A_Index == 10) ? ("x" . x + 142 . "y" . y + 57 + v) : (((A_Index == 11) ? ("x" . x - 103 . "y" . y + 56) : ("x" . x - 70 . "y" . y + 81)))))))))))))))))))))) . "Bold r4 s15")
		}

		Gui, gCanvas3: Show, NA
	}
	Else {
		Gui, gCanvas3: Hide
	}

	Canvas3.Update()

	Return

;=====           Function           =========================;

Exit() {
	Critical

	GDIp.Shutdown()
	ExitApp
}

RegisterKeys(wParam, lParam) {
	Global

	ControlGetFocus, v, % "ahk_id" . gControl

	If (v ~= "Edit1|Edit2" &&  wParam ~= "13|48|49|50|51|52|53|54|55|56|57|96|97|98|99|100|101|102|103|104|105") {
		Gui, gControl: Submit, NoHide

		multiplier := Round((multiplier > 500 ? 500 : multiplier), 1)

		GuiControl, , Edit1, % sectors
		GuiControl, , Edit2, % multiplier

		If (wParam == 13) {
			Gosub, CycleCheck
		}
	}
}
