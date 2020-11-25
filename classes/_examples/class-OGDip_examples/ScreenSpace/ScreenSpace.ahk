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
	, oCanvas := [new GDIp.Canvas({"x": 0, "y": 0, "Width": A_ScreenWidth, "Height": A_ScreenHeight}, "-Caption +AlwaysOnTop +ToolWindow +OwnDialogs +E0x20", "gCanvas1"), new GDIp.Canvas({"x": 0, "y": 0, "Width": A_ScreenWidth, "Height": A_ScreenHeight}, "-Caption +AlwaysOnTop +ToolWindow +OwnDialogs +E0x20", "gCanvas2")]
		, oPen := new GDIp.Pen("0x80FFFFFF")

	, oRectangle := [new Rectangle(A_ScreenWidth/2, A_ScreenHeight/2, A_ScreenWidth/2, A_ScreenHeight/2)  ;* Bottom right.
		, new Rectangle(0, A_ScreenHeight/2, A_ScreenWidth/2, A_ScreenHeight/2)  ;* Bottom left.
		, new Rectangle(0, 0, A_ScreenWidth/2, A_ScreenHeight/2)  ;* Top left.
		, new Rectangle(A_ScreenWidth/2, 0, A_ScreenWidth/2, A_ScreenHeight/2)]  ;* Top right.
	, oPoint := [[{}]]

For i, v in oRectangle {
	oCanvas[0].DrawRectangle(oPen, v)
}
oCanvas[0].Update()

;===============            Other             ===============;

OnExit("Exit"), Update()

Exit

;=====            Hotkey            =========================;
;===============            Mouse             ===============;

$^LButton::
	If (oPoint[oPoint.Length - 1].Length != 3) {
		oPoint[oPoint.Length - 1].Push(MouseGet("Pos"))

		If (oPoint[oPoint.Length - 1].Length == 3) {
			oPoint.Push([{}])
		}
	}
	Return

$^RButton::
	oPoint := [[{}]]
	Return

;===============           Keyboard           ===============;

#If (WinActive(A_ScriptName) || WinActive("GDIp.ahk") || WinActive("Geometry.ahk"))

	~$^s::
		Critical

		Sleep, 200
		Reload
		Return

	$F10::ListVars

#If

$^Up::
$^Left::
$^Down::
$^Right::MouseMove, % Round({"Left": -1, "Right": 1}[k := KeyGet(A_ThisHotkey)]), % Round({"Up": -1, "Down": 1}[k]), 0, R

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

q::
	MouseMove, 50, 50
	Return

Update() {
	If (QueryPerformanceCounter_Passive()) {
		For i, v in oPoint {
			Switch (v.Length) {
				Case "2":
					m := MouseGet("Pos")

					v[0].Distance := Point2D.Distance(v[1], m)
					v[0].MidPoint := Point2D.MidPoint(v[1], m)

					If (v[0].Distance) {
						v[0].Color := Format("{:#X}{:06X}", 255, DllCall("shlwapi\ColorHLSToRGB", "UInt", (r := Floor(v[0].Distance/A_ScreenWidth*240) + 160) + (r > 240 ? -240 : 0), "UInt", 120, "UInt", 240))

						oCanvas[1].DrawLine(new GDIp.Pen(v[0].Color), v[1], m)
						oCanvas[1].DrawString(new GDIp.Brush(v[0].Color), v[0].Distance, Format("Bold r4 s20 x{} y{}", v[0].MidPoint.x, v[0].MidPoint.y))
					}
				Case "3":
					oCanvas[1].DrawLine(new GDIp.Pen(v[0].Color), v[1], v[2])
					oCanvas[1].DrawString(new GDIp.Brush(v[0].Color), v[0].Distance, Format("Bold r4 s20 x{} y{}", v[0].MidPoint.x, v[0].MidPoint.y))
			}
		}

;		oCanvas[1].DrawLine(new GDIp.Pen("0xFFFFFFFF", 3), {"x": 5, "y": 5}, {"x": 5, "y": 10})

		e := oCanvas[1].DrawEllipse(new GDIp.Pen("0xFFFFFFFF", 1), {"x": 5, "y": 5, "Width": 10, "Height": 10})
;		oCanvas[1].FillEllipse(new GDIp.Brush("0xFFFFFFFF"), {"x": 5, "y": 5, "Width": 10, "Height": 10})

;		oCanvas[1].DrawRectangle(new GDIp.Pen("0xFFFFFFFF", 2), {"x": 5, "y": 5, "Width": 5, "Height": 10})
;		oCanvas[1].FillRectangle(new GDIp.Brush("0xFFFFFFFF"), {"x": 5, "y": 5, "Width": 5, "Height": 10})

		oCanvas[1].Update()
	}

	SetTimer, Update, -1
}
