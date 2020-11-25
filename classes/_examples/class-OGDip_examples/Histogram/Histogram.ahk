;=====         Auto-execute         =========================;
;===============           Settings           ===============;

#Include, %A_ScriptDir%\..\..\..\AutoHotkey\lib\Color.ahk
#Include, %A_ScriptDir%\..\..\..\AutoHotkey\lib\General.ahk
#Include, %A_ScriptDir%\..\..\..\AutoHotkey\lib\ObjectOriented.ahk
#Include, %A_ScriptDir%\..\..\..\AutoHotkey\lib\Math.ahk
#Include, %A_ScriptDir%\..\..\lib\GDIp.ahk

#KeyHistory, 0
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

GDIp.Startup()
Global oCanvas := new GDIp.Canvas([0, 0, A_ScreenWidth, A_ScreenHeight - 1], "-Caption +AlwaysOnTop +ToolWindow +OwnDialogs +E0x20")

;===============            Other             ===============;

Histogram([], 30, {"x": A_ScreenWidth - 350, "y": 50, "Width": 300, "Height": 200})

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

~$Esc::
	If (KeyWait("Esc", "T0.5")) {
		Exit()
	}
	Return

;=====           Function           =========================;

Exit() {
	Critical

	GDIp.Shutdown()
	ExitApp
}

Histogram(oData, vBins, oPos, vMode := 0) {
	oPen := [new GDIp.Pen("0xFF000000", 2)], oBrush := [new GDIp.Brush("0xFF000000")]

	o :=
	(LTrim Join
	{
		"Backround": {
			"x": oPos.x,
			"y": oPos.y,
			"Width": oPos.Width,
			"Height": oPos.Height
		},
		"Outer": {
			"x": oPos.x + 5,
			"y": oPos.y + 5,
			"Width": oPos.Width - 10,
			"Height": oPos.Height - 10
		},
		"Inner": {
			"x": oPos.x + 15,
			"y": oPos.y + 15,
			"Width": oPos.Width - 30,
			"Height": oPos.Height - 30
		},
		"Data": []
	}
	)

	If (vDebug == "On") {
		oData := [[], [], []], vBins := 25

		Loop, % 5000 {
			oData[0].Push(Math.Random(-6.0, 6.0)), oData[1].Push(Math.MarsagliaPolar(-1)), oData[2].Push(Math.Ziggurat(0, 1.25))
		}
	}

	m := Math.Min(oData.Flat()), s := (Math.Max(oData.Flat()) - m)/vBins  ;* Determine the threshold for each bin.

	For i, v in oData {
		If (Type(v) == "Array" || o.Depth == "") {
			o.Depth := Round(o.Depth + 1), (o.Data[o.Depth] := []).Length := vBins, o.Data[o.Depth].Fill(0)

			Switch (vMode) {
				Case 1:
					oPen.Push(new GDIp.Pen("0xFF" . ((vDebug == "On") ? (["00FF00", "FF0000", "0000FF"][o.Depth]) : (Color.Random())), 2))
				Default:
					c := (vDebug == "On") ? (["00FF00", "FF0000", "0000FF"][o.Depth]) : (Color.Random())

					oPen.Push(new GDIp.Pen("0xFF" . c, 2))
					oBrush.Push(new GDIp.Brush("0x33" . c))
			}

			For i, v in v {
				Loop, % vBins {
					i := A_Index - 1

					If (v <= m + s + s*i) {
						o.Data[o.Depth][i]++

						Break
					}
				}
			}
		}
		Else {
			Loop, % vBins {
				i := A_Index - 1

				If (v <= m + s + s*i) {
					o.Data[o.Depth][i]++

					Break
				}
			}
		}
	}

	If (vDebug == "On") {
		Loop, % vBins {
			i := A_Index - 1, r .= "    " . m + s + s*i . ": " . o.Data[2][i] . "`n"
		}
		MsgBox("s = " . s . "`no.Data =`n" . r)
	}

	oCanvas.FillRectangle((v := new GDIp.Brush("0xFFFFFFFF")), o.Backround)  ;* Backround.
	oCanvas.DrawRectangle(oPen[0], o.Outer)  ;* Outer.

	h := o.Inner.Height/Ceil(Math.Max(o.Data.Flat())), w := o.Inner.Width/vBins  ;* Determine y-axis and x-axis spacing with a ratio of the available space divided by the largest bin and the number of bins respectively.
	Loop, % o.Depth + 1 {
		x := A_Index - 1

		Switch (vMode) {
			Case 1:
				p := []

				For i, v in o.Data[x] {
					p.Push({"x": o.Inner.x + w*A_Index - w/2
						, "y": o.Inner.y + o.Inner.Height - h*v})
				}

				oCanvas.DrawLine(oPen[x + 1], [{"x": o.Inner.x, "y": p[0].y}, p[0]])  ;* Connect the first point to the left y-axis.
				For i, v in p {
					If (i != 0) {
						oCanvas.DrawLine(oPen[x + 1], [p[i - 1], v])
					}
					e := oCanvas.FillEllipse(oBrush[0], {"x": v.x - 2.5, "y": v.y - 2.5, "Width": 5, "Height": 5})
				}
				oCanvas.DrawLine(oPen[x + 1], [p[i], {"x": o.Backround.x + o.Backround.Width - 15, "y": p[i].y}])  ;* Connect the last point to the right y-axis.
			Default:
				For i, v in o.Data[x] {
					v := {"x": o.Inner.x + w*i, "y": o.Inner.y + o.Inner.Height - h*v, "Width": w, "Height": h*v}

					oCanvas.FillRectangle(oBrush[x + 1], v)
					oCanvas.DrawRectangle(oPen[x + 1], v)
				}
		}
	}

	h := (o.Inner.Height/5)
	Loop, % 5 + 1 {  ;?  5(100, 80, ..., 20) + 1(0)
		v := h*(A_Index - 1)

		oCanvas.DrawLine(oPen[0], [{"x": o.Inner.x - 2.5, "y": o.Inner.y + v}, {"x": o.Inner.x + 2.5, "y": o.Inner.y + v}])  ;* y-axis indicators.
	}

	w := (o.Inner.Width/10)
	Loop, % 1 + 10 {  ;? 1(0) + 10(10, 20, ..., 100)
		v := w*(A_Index - 1)

		oCanvas.DrawLine(oPen[0], [{"x": o.Inner.x + v, "y": o.Inner.y + o.Inner.Height - 2.5}, {"x": o.Inner.x + v, "y": o.Inner.y + o.Inner.Height + 2.5}])  ;* x-axis indicators.
	}

	oPen[0].Width := 1
	oCanvas.DrawRectangle(oPen[0], o.Inner)  ;* Inner.

	oCanvas.Update()

	If (vDebug == "On") {
		MsgBox("Mean:`n    0] " . Math.Mean(oData[0]) . "`n    1] " . Math.Mean(oData[1]) .  "`n    2] " . Math.Mean(oData[2]) . "`n"
			. "Min:`n    0] " . Math.Min(oData[0]) . "`n    1] " . Math.Min(oData[1]) .  "`n    2] " . Math.Min(oData[2]) . "`n"
			. "Max:`n    0] " . Math.Max(oData[0]) . "`n    1] " . Math.Max(oData[1]) .  "`n    2] " . Math.Max(oData[2]))
	}
}