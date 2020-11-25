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
		, oBrush := [new GDIp.Brush()]

	, oPolarCurves := {"Rectangle": new Rectangle(5, 5, oCanvas.Rectangle.Width - 10, oCanvas.Rectangle.Height - 10)
		, "Magnitude": 150  ;* Magnitude of each petal (in pixels).
		, "Coefficient": 3  ;* Coefficient that determines how many petals there are. An even number generates twice the number.
		, "Points": 12  ;* Number of points on each petal (anything over `180/Coefficient` is redundant).

		, "SpeedRatio": 1}

Loop, % oPolarCurves.Points {
	oBrush.Push(new GDIp.Brush(Format("{:#X}{:06X}", 255, DllCall("shlwapi\ColorHLSToRGB", "UInt", ((360/oPolarCurves.Points)*(A_Index - 1))/360*240, "UInt", 120, "UInt", 240))))  ;* Create a nice effect with a brush color based on the angle a point starts at.
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
	oPolarCurves.SpeedRatio /= 2

	KeyWait("Left")
	Return

~$Right::
	oPolarCurves.SpeedRatio *= 2

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
	Static __Time := 0

	If (QueryPerformanceCounter_Passive()) {
		__Time := Mod(__Time, 360) + 1*oPolarCurves.SpeedRatio

		oCanvas.DrawString(oBrush[0], Round(__Time) . "°", "Bold r4 s10 x10 y10")
		If (oPolarCurves.SpeedRatio != 1) {
			oCanvas.DrawString(oBrush[0], (v := Round(oPolarCurves.SpeedRatio, 2)) . "x", Format("Bold r4 s10 x{} y10", oCanvas.Rectangle.Width - (15 + 6*StrLen(v))))
		}

		n := oPolarCurves.Coefficient + oPolarCurves.Coefficient*Math.IsEven(oPolarCurves.Coefficient)  ;* An even coefficient generates double the number of petals so account for that here.

		Loop, % n {  ;* Number of petals to draw.
			t := __Time + (360/n)*(A_Index - 1)

			Loop, % oPolarCurves.Points {  ;* Number of points to draw on each petal.
				i := A_Index - 1
					, a := Math.ToRadians(t + (180/oPolarCurves.Coefficient/oPolarCurves.Points)*i), r := oPolarCurves.Magnitude*Math.Sin(a*oPolarCurves.Coefficient)  ;* Calculate the current position of each point based on `__Time` and the space between each point.

				oCanvas.FillEllipse(oBrush[A_Index], {"x": oCanvas.Rectangle.Width/2 + r*Math.Cos(a), "y": oCanvas.Rectangle.Height/2 + r*Math.Sin(a), "Width": 5, "Height": 5})
			}
		}

		oCanvas.Update()
	}

	SetTimer, Update, -1
}
