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

ListLines, Off
Process, Priority, , R
SetBatchLines, -1
SetWorkingDir, % A_ScriptDir . "\..\..\.."

;===============           Variable           ===============;

IniRead, Debug, % A_WorkingDir . "\cfg\Settings.ini", Debug, Debug
Global Debug
	, Canvas := new GDIp.Canvas({"x": A_ScreenWidth - (150*2 + 50 + 10 + 1), "y": 50, "Width": 150*2 + 10, "Height": 150*2 + 10}, "-Caption +AlwaysOnTop +ToolWindow +OwnDialogs +E0x20")
		, Brush := [new GDIp.Brush(), new GDIp.LineBrush(new Rectangle(5, 5, Canvas.Rectangle.Width - 10, Canvas.Rectangle.Height - 10), [Color.Random(), Color.Random()])]
		, Pen := [new GDIp.Pen(), new GDIp.Pen(Brush[1])]

	, ScriptObject := {"Rectangle": new Rectangle(5, 5, Canvas.Rectangle.Width - 10, Canvas.Rectangle.Height - 10)
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
	ScriptObject.SpeedRatio /= 2

	KeyWait("Left")
	Return

~$Right::
	ScriptObject.SpeedRatio *= 2

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
	Static Time := 0

	If (QueryPerformanceCounter_Passive()) {
		Time := Mod(Time + 1*ScriptObject.SpeedRatio, 360)

		Canvas.DrawString(Brush[0], Round(Time) . "°", "Bold r4 s10 x10 y10")
		If (ScriptObject.SpeedRatio != 1) {
			Canvas.DrawString(Brush[0], (v := Round(ScriptObject.SpeedRatio, 2)) . "x", Format("Bold r4 s10 x{} y10", Canvas.Rectangle.Width - (15 + 6*StrLen(v))))
		}

		Canvas.DrawRectangle(Pen[0], ScriptObject.Rectangle)

		Canvas.Update()
	}

	SetTimer, Update, -1
}

;=====            Class             =========================;

Class Class {
	__New() {

	}

	Update() {

	}

	Draw() {

	}
}