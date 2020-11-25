;=====         Auto-execute         =========================;
;===============           Setting            ===============;

#Include, %A_ScriptDir%\..\..\..\lib\Color.ahk
#Include, %A_ScriptDir%\..\..\..\lib\General.ahk
#Include, %A_ScriptDir%\..\..\..\lib\ObjectOriented.ahk
#Include, %A_ScriptDir%\..\..\..\lib\Math.ahk
#Include, %A_ScriptDir%\..\..\..\lib\GDIp.ahk
#Include, %A_ScriptDir%\..\..\..\lib\Geometry.ahk

#KeyHistory 0
#NoEnv
#Persistent
#SingleInstance, Force

ListLines, Off
Process, Priority, , R
SetBatchLines, -1
SetWorkingDir, % A_ScriptDir . "\..\..\.."

;===============           Variable           ===============;

IniRead, vDebug, % A_WorkingDir . "\cfg\Settings.ini", Debug, Debug
Global vDebug
	, oCanvas := new GDIp.Canvas({"x": A_ScreenWidth - (150*2 + 50 + 10 + 1), "y": 50, "Width": 150*2 + 10, "Height": 150*2 + 10}, "-Caption +AlwaysOnTop +ToolWindow +OwnDialogs +E0x20")
		, oBrush := new GDIp.Brush()
		, oPen := [new GDIp.Pen("0xFFFFFFFF", 2), new GDIp.Pen("0x80FFFFFF")]

	, oParticleCircle := {"Ellipse": new Ellipse(5, 5, oCanvas.Rectangle.Width - 10, oCanvas.Rectangle.Height - 10)
		, "SpeedRatio": 1

		, "Mean": -1
		, "StandardDeviation": 3
		, "MaxDelay": 35

		, "Particles": []}

Loop, 100 {
	oParticleCircle.Particles.Push([])
}

;* Precompile all of the points as its allot of data to calculate all the time:
Loop, 1800 {  ;? 1800 = 360*5
	n := ((Math.RandomNormal(oParticleCircle.Mean, oParticleCircle.StandardDeviation))*oParticleCircle.MaxDelay)
		, t := A_Index - 1

	Loop, % Round(50 + n/2) {  ;* `n/2` is the time it takes a particle to reach the expanding ellipse after being delayed by `n`.
		d := (1 - Max(0, (A_Index - n)/100))*oParticleCircle.Ellipse.Diameter ;* Diameter of the ellipse scaled by a ratio to get coordinates for this particle.
			, p := Point2.OnEllipse(new Ellipse(oParticleCircle.Ellipse.h - d/2, oParticleCircle.Ellipse.k - d/2, d, d), t)

		oParticleCircle.Particles[A_Index - 1].Push(p)
	}
}

;===============            Other             ===============;

OnExit("Exit"), Update()

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

~$Left::
	oParticleCircle.SpeedRatio /= 2

	KeyWait("Left")
	Return

~$Right::
	oParticleCircle.SpeedRatio *= 2

	KeyWait("Right")
	Return

~$Esc::
	If (KeyWait("Esc", "T1")) {
		Exit()
	}
	Return

;=====           Function           =========================;

Exit() {
	Critical

	GDIp.Shutdown()
	ExitApp
}

Update() {
	Static __Time := 99
		, __Alpha := [["FF", "E6", "CC", "B3", "99", "80", "66", "4D", "33", "1A"], ["1A", "33", "4D", "66", "80", "99", "B3", "CC", "E6", "FF"]]

	If (QueryPerformanceCounter_Passive()) {
		__Time := Mod(__Time, 100) + 1*oParticleCircle.SpeedRatio  ;!  + (1 - .5*(__Time >= 50))*oParticleCircle.SpeedRatio

		oCanvas.DrawString(oBrush, Round(__Time), "Bold r4 s10 x10 y10")
		If (oParticleCircle.SpeedRatio != 1) {
			v := Round(oParticleCircle.SpeedRatio, 2), oCanvas.DrawString(oBrush, v . "x", Format("Bold r4 s10 x{} y10", oCanvas.Rectangle.Width - (15 + 6*StrLen(v))))
		}

		If (__Time >= 50) {
			d := (__Time/100)*oParticleCircle.Ellipse.Diameter
				, o := new Ellipse(oParticleCircle.Ellipse.h - d/2, oParticleCircle.Ellipse.k - d/2, d, d)  ;* Scale the ellipse and offset it's x and y by half of the new diameter.

			If (__Time < 60) {
				oPen[0].Color := Format("0x{}FFFFFF", __Alpha[0][Round(60 - __Time) - 1])
			}

			oCanvas.DrawEllipse(oPen[0], o)
		}
		Else {
			If (__Time < 10) {
				oPen[0].Color := Format("0x{}FFFFFF", __Alpha[1][Round(10 - __Time) - 1])

				oCanvas.DrawEllipse(oPen[0], oParticleCircle.Ellipse)
			}
		}

		For i, v in oParticleCircle.Particles[Floor(__Time) - 1] {
			oCanvas.DrawEllipse(oPen[1], {"x": v.x - 1, "y": v.y - 1, "Width": 2, "Height": 2})
		}

		oCanvas.Update()
	}

	SetTimer, Update, -1
}