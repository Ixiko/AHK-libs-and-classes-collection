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
#SingleInstance Force

ListLines, Off
Process, Priority, , R
SetBatchLines, -1
SetWorkingDir, % A_ScriptDir . "\.."

;===============           Variable           ===============;

IniRead, vDebug, % A_WorkingDir . "\..\AutoHotkey\cfg\Settings.ini", Debug, Debug
Global vDebug

v := 150
Global oCanvas := new GDIp.Canvas([A_ScreenWidth - v*3.5 + 5, v*.5 + 5, v*2 + 10, v*2 + 10], "-Caption +AlwaysOnTop +ToolWindow +OwnDialogs +E0x20")
	, oBrush := [new GDIp.Brush()], oPen := [new GDIp.Pen()]

	, vSolarSystem := {"h": oCanvas.Size.Width/2
		, "k": oCanvas.Size.Height/2

		, "Ratio": 1
		, "Depth": 0

		, "Planets": []

		, "Date": 0
		, "SpeedRatio": 1}

vSolarSystem.Planets.Push(new Planet("Sun", Min(oCanvas.Size.Width, oCanvas.Size.Height)/10, 0, 0, 0, vSolarSystem))  ;? (Name, Diameter, OrbitAngle, OrbitRadius, OrbitRevolution (in days), Parent)
Loop, % Math.Random(1, 5) {
	vSolarSystem.Planets.Push(new Planet(A_Index, Math.Random(10, vSolarSystem.Planets[0].Diameter[0]*1.35), Math.Random(0, 360), Math.Random(vSolarSystem.Planets[0].Diameter[0], Min(oCanvas.Size.Width/2, oCanvas.Size.Height/2)), Math.Random(250, 2500), vSolarSystem.Planets[0]))
	Loop, % Math.Random(-5, 3)
		vSolarSystem.Planets.Push(new Planet(Round(vSolarSystem.Planets[vSolarSystem.Planets.Length - A_Index].Name + A_Index/10, 1), Math.Random(5, vSolarSystem.Planets[vSolarSystem.Planets.Length - A_Index].Diameter[0]*.5), Math.Random(0, 360), Math.Random(vSolarSystem.Planets[vSolarSystem.Planets.Length - A_Index].Diameter[0]*1.25, vSolarSystem.Planets[vSolarSystem.Planets.Length - A_Index].Diameter[0]*1.75), Math.Random(35, 800), vSolarSystem.Planets[vSolarSystem.Planets.Length - A_Index]))
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
		SetTitleMatchMode, 2

		Sleep, 200
		Reload
		Return

	$F10::ListVars

#IF

~$Left::
	vSolarSystem.SpeedRatio /= 2

	KeyWait, Left
	Return

~$Right::
	vSolarSystem.SpeedRatio *= 2

	KeyWait, Right
	Return

~$Space::
	If (KeyWait("Space", "T0.5")) {
		Gui, gCanvas: Show, NA
		If (vSolarSystem.IsVisible := !vSolarSystem.IsVisible)
			Gui, gCanvas: Hide
	}

	KeyWait, Space
	Return

~$Esc::
	If (KeyWait("Esc", "T1")) {
		Exit()
	}
	Return

;=====            Label             =========================;

Update:
	If (QueryPerformanceCounter_Passive()) {
		p := [0]

		vSolarSystem.Date += 1*vSolarSystem.SpeedRatio
		oCanvas.DrawString(oBrush[0], Round(vSolarSystem.Date) . " days", "Bold r4 s10")
		For i, v in vSolarSystem.Planets {
			v.Update(vSolarSystem.Date)
		}

		If (vSolarSystem.SpeedRatio != 1) {
			v := Round(vSolarSystem.SpeedRatio, 1)

			oCanvas.DrawString(oBrush[0], v . "x", "x" . oCanvas.Size.Width - (15 + 6*StrLen(v)) . "Bold r4 s10")
		}

		p[0] := vSolarSystem.Planets.Clone()
		Loop, % p[0].Length {
			p[2] := A_ScreenWidth*2.25 + 1  ;* Should be greater than any potential Orbit.Radius*Parent.Ratio (min: 0.5, max: 1.5**2 (unless you have have moons with moons, in that case it would be 1.5**3 but it shouldn't matter that much since it'll be a smaller and smaller orbit at each level down.)).

			For i, v in p[0] {  ;* Find the planet with the lowest depth ("furthest" away).
				If (p[2] > v.Depth) {
					p[1] := i
					p[2] := v.Depth
				}
			}

			If (vDebug) {
				p[""] .= (A_Index > 1 ? "|" : "") . p[0][p[1]].Name
			}

			p[0].RemoveAt(p[1]).Draw(vSolarSystem.Date)  ;* Draw the "furthest" planet and delete it from the temporary array so that "closer" planets will be drawn over it.
		}

		For i, v in vSolarSystem.Planets {
			oCanvas.DrawLine(oPen[0], [{"x": v.h, "y": v.k}, {"x": v.Parent.h, "y": v.Parent.k}])
		}

		oCanvas.Update()

		If (vDebug) {
			ToolTip, % (GetKeyState("q", "P") ? p[""] : "")
		}
	}

	SetTimer, Update, -1

	Return

;=====           Function           =========================;

Exit() {
	Critical

	GDIp.Shutdown()
	ExitApp
}

;=====            Class             =========================;

Class Planet {
	__New(vName, vDiameter, vOrbitAngle, vOrbitRadius, vOrbitRevolution, vParent) {
		a := Math.ToRadians((vOrbitAngle >= 0) ? Mod(vOrbitAngle, 360) : 360 - Mod(-vOrbitAngle, -360))

		this.Name := vName
		this.Diameter := [vDiameter]
		this.Orbit := {"x": vOrbitRadius*Math.Cos(a)
			, "y": vOrbitRadius*Math.Sin(a)

			, "Angle": vOrbitAngle
			, "Radius": vOrbitRadius
			, "Revolution": vOrbitRevolution}
		this.Parent := vParent

		this.Brush := (vName == "Sun" ? new GDIp.Brush("0xFF" . ["FFFF00", "00FFFF", "FFFFFF"][Math.Random(0, 2)]) : new GDIp.LinearGradientBrush([vOrbitRadius/4, vOrbitRadius/4, vOrbitRadius/2, vOrbitRadius/2], [Color.Random(), Color.Random()], vOrbitAngle))
	}

	Update(vDate) {
		a := Math.ToRadians((vDate/this.Orbit.Revolution)*360)

		this.Ratio := (this.Diameter[1] := (this.Diameter[0] + this.Diameter[0]*Math.Sin(a)/2)*this.Parent.Ratio)/this.Diameter[0]
		this.Depth := this.Parent.Depth + (this.Ratio - 1)*this.Orbit.Radius*2

		this.h := this.Parent.h + this.Orbit.x*Math.Cos(a)*this.Parent.Ratio, this.k := this.Parent.k + this.Orbit.y*Math.Sin(a + 1.5707963267948966192313216916398)*this.Parent.Ratio
	}

	Draw(vDate) {
		oCanvas.FillEllipse(this.Brush, {"x": this.h - this.Diameter[1]/2, "y": this.k - this.Diameter[1]/2, "Width": this.Diameter[1], "Height": this.Diameter[1]})
		oCanvas.DrawString(oBrush[0], this.Name . ((this.Parent.Name == "Sun") ? (" (" . Round(Mod((vDate/this.Orbit.Revolution)*360, 360)) . "°)") : ("")), "x" . this.h + this.Diameter[1]/2 . "y" . this.k - this.Diameter[1]/2 . "r4 s10")
	}
}