;=====         Auto-execute         =========================;
;===============           Setting            ===============;

#Include, %A_ScriptDir%\..\..\..\AutoHotkey\lib\Color.ahk
#Include, %A_ScriptDir%\..\..\..\AutoHotkey\lib\General.ahk
#Include, %A_ScriptDir%\..\..\..\AutoHotkey\lib\ObjectOriented.ahk
#Include, %A_ScriptDir%\..\..\..\AutoHotkey\lib\Math.ahk
#Include, %A_ScriptDir%\..\..\lib\GDIp.ahk
#Include, %A_ScriptDir%\..\..\lib\Geometry.ahk

#KeyHistory 0
#NoEnv
#Persistent
#SingleInstance, Force

CoordMode, Mouse, Screen
ListLines, Off
Process, Priority, , R
SetBatchLines, -1
SetWorkingDir, % A_ScriptDir . "\..\.."

;===============           Variable           ===============;

IniRead, vDebug, % A_WorkingDir . "\..\AutoHotkey\cfg\Settings.ini", Debug, Debug
Global vDebug

Global oCanvas := new GDIp.Canvas([A_ScreenWidth - 150*2.5 + 5, 150*.5 + 5, 150*2 + 10, 150*2 + 10], "-Caption +AlwaysOnTop +ToolWindow +OwnDialogs +E0x20")
	, oPen := [new GDIp.Pen(), new GDIp.Pen("0x40FFFFFF")]

	, oEllipse := new Ellipse([5, 5, oCanvas.Size.Width - 20, oCanvas.Size.Height - 20])

(oCanvas.Points := []).Length := 8

Loop, % oCanvas.Points.Length {
	i := A_Index - 1
		, v := Color.ToHSB(Mod(360/oCanvas.Points.Length*i, 360)/360, 1, 1)

	oCanvas.Points[i] := (new Point(i, 5, Math.ToRadians(180/oCanvas.Points.Length*i), new GDIp.Brush(Format("0xFF{:02X}{:02X}{:02X}", Round(v[0]*255), Round(v[1]*255), Round(v[2]*255)))))
}

;===============            Timer             ===============;

SetTimer, Update, -1

;===============            Other             ===============;

OnExit("Exit")

Exit

;=====            Hotkey            =========================;

#If (WinActive(A_ScriptName) || WinActive("GDIp.ahk") || WinActive("Geometry.ahk"))

	~$^s::
		Critical

		Sleep, 200
		Reload
		Return

	$F10::ListVars

#IF

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
		__Theta := Mod(__Theta + 3, 360)

		oCanvas.DrawEllipse(oPen[0], oEllipse)

		For i, v in oCanvas.Points {  ;* Draw the lines first so that the ellipses are drawn over them.
			oCanvas.DrawLine(oPen[1], v.Points)
		}

		For i, v in oCanvas.Points {
			v.Draw(__Theta)
		}

		oCanvas.Update()
	}

	SetTimer, Update, -1
}

;=====            Class             =========================;

Class Point {
	__New(vIndex, vRadius, vTheta, oBrush) {
		this.Index := vIndex
		this.Radius := vRadius
			, this.Diameter := vRadius*2
		this.Angle := vTheta

		c := Math.Cos(vTheta), s := Math.Sin(vTheta)

		;* Points of the radius at this angle:
		this.Points := [new Point2D([oEllipse.h + oEllipse.Radius*c, oEllipse.k + oEllipse.Radius*s]), new Point2D([oEllipse.h - oEllipse.Radius*c, oEllipse.k - oEllipse.Radius*s])]

		this.Brush := oBrush
	}

	Draw(vTheta) {
		r := (oEllipse.Radius)*Math.Cos((Math.Tau/360*vTheta) + ((this.Index*Math.Pi)/oCanvas.Points.Length))

		oCanvas.FillEllipse(this.Brush, {"x": oEllipse.h + r*Math.Cos(this.Angle) - this.Radius, "y": oEllipse.k + r*Math.Sin(this.Angle) - this.Radius, "Width": this.Diameter, "Height": this.Diameter})
	}
}