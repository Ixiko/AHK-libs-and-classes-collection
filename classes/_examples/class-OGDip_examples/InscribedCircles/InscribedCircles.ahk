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

CoordMode, Mouse, Screen
ListLines, Off
Process, Priority, , R
SetBatchLines, -1
SetWorkingDir, % A_ScriptDir . "\..\..\.."

;===============           Variable           ===============;

IniRead, vDebug, % A_WorkingDir . "\cfg\Settings.ini", Debug, Debug
Global vDebug
	, oCanvas := new GDIp.Canvas({"x": A_ScreenWidth - (150*2 + 50 + 10 + 1), "y": 50, "Width": 150*2 + 10, "Height": 150*2 + 10}, "-Caption +AlwaysOnTop +ToolWindow +OwnDialogs +E0x20")
		, oBrush := new GDIp.Brush()
		, oPen := [new GDIp.Pen(c := Color.Random(), 5), new GDIp.Pen(new GDIp.LineBrush(new Rectangle(5, 5, (oCanvas.Rectangle.Width - 10)//2, (oCanvas.Rectangle.Height - 10)//2), [c, Color.Random()]), 3)]

	, oEllipse := {"Ellipse": new Ellipse(5, 5, oCanvas.Rectangle.Width - 10, oCanvas.Rectangle.Height - 10)
		, "SpeedRatio": 1}

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
	oEllipse.SpeedRatio /= 2

	KeyWait("Left")
	Return

~$Right::
	oEllipse.SpeedRatio *= 2

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
	Static __Theta := 0

	If (QueryPerformanceCounter_Passive()) {
		__Theta := Mod(__Theta + 1*oEllipse.SpeedRatio, 360)

		oCanvas.DrawString(oBrush, Round(__Theta) . "°", "Bold r4 s10 x10 y10")
		If (oEllipse.SpeedRatio != 1) {
			v := Round(oEllipse.SpeedRatio, 2), oCanvas.DrawString(oBrush, v . "x", Format("Bold r4 s10 x{} y10", oCanvas.Rectangle.Width - (15 + 6*StrLen(v))))
		}

		oCanvas.DrawEllipse(oPen[0], oEllipse.Ellipse)

		o := Ellipse.InscribeEllipse(oEllipse.Ellipse, oEllipse.Ellipse.Radius*2/3, __Theta, oPen[0].Width)
		oCanvas.DrawEllipse(oPen[1], o)

		o := [Ellipse.InscribeEllipse(o, o.Radius*2/3, __Theta + 180, oPen[1].Width), Ellipse.InscribeEllipse(o, o.Radius*.75, __Theta, oPen[1].Width)]
		For i, v in o {
			oCanvas.DrawEllipse(oPen[1], v)
		}

		oCanvas.Update()
	}

	SetTimer, Update, -1
}