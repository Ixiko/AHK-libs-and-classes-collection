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
		, oBrush := [new GDIp.Brush(Color.Random()), new GDIp.Brush(Color.Random()), new GDIp.Brush(Color.Random()), new GDIp.Brush(Color.Random()), new GDIp.Brush(Color.Random()), new GDIp.Brush(Color.Random())]
		, oPen := [new GDIp.Pen(), new GDIp.Pen(oBrush[1])]

	, oObject := {"Rectangle": new Rectangle(5, 5, oCanvas.Rectangle.Width - 10, oCanvas.Rectangle.Height - 10)
		, "SpeedRatio": 1}

	, oMatrix3 := new Matrix3()
		, vTheta_x := 0, vTheta_y := 0, vTheta_z := 0, vOffset_z := 2

	, oCube := new Cube(1.0)

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

*!q::
*!a::
*!w::
*!s::
*!e::
*!d::
*!r::
*!f::
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
	Static __Step := [1/30*3.1415926535897932, 2*(1/30)]

	If (QueryPerformanceCounter_Passive()) {
		oCanvas.DrawRectangle(oPen[0], oObject.Rectangle)

		If (GetKeyState("Alt", "P")) {
			If (GetKeyState("q", "P")) {
				vTheta_x := Mod(vTheta_x + __Step[0], Math.Tau)
			}
			Else If (GetKeyState("a", "P")) {
				vTheta_x := Mod(vTheta_x - __Step[0], Math.Tau)
			}

			If (GetKeyState("w", "P")) {
				vTheta_y := Mod(vTheta_y + __Step[0], Math.Tau)
			}
			Else If (GetKeyState("s", "P")) {
				vTheta_y := Mod(vTheta_y - __Step[0], Math.Tau)
			}

			If (GetKeyState("e", "P")) {
				vTheta_z := Mod(vTheta_z + __Step[0], Math.Tau)
			}
			Else If (GetKeyState("d", "P")) {
				vTheta_z := Mod(vTheta_z - __Step[0], Math.Tau)
			}

			If (GetKeyState("r", "P")) {
				vOffset_z += __Step[1]
			}
			Else If (GetKeyState("f", "P")) {
				vOffset_z := Max(2, vOffset_z - __Step[1])
			}
		}

		o := [], c := []  ;* Temporary array to avoid changing the cube's vertices from model space into screen space and another to track whether a triangle should be culled.
			, oMatrix3 := Matrix3.Multiply(Matrix3.Multiply(Matrix3.RotateX(vTheta_x), Matrix3.RotateY(vTheta_y)), Matrix3.RotateZ(vTheta_z))  ;* Generate a rotation matrix from Euler angles.

		For i, v in oCube.Vertices {
			o[i] := Vector3.Transform(v, oMatrix3).Add({"x": 0, "y": 0, "z": vOffset_z})  ;* Transform from model space to world space.
		}

		For i, v in oCube.Indices {  ;* Backface culling check (must be done before perspective transformation).
			v0 := o[v[0]], v1 := o[v[1]], v2 := o[v[2]]

;			c[i] := Vector3.Dot(Vector3.Cross(Vector3.Subtract(v1, v0), Vector3.Subtract(v2, v0)), v0) >= 0
			c[i] := (((v1.y - v0.y)*(v2.z - v0.z) - (v1.z - v0.z)*(v2.y - v0.y))*v0.x + ((v1.z - v0.z)*(v2.x - v0.x) - (v1.x - v0.x)*(v2.z - v0.z))*v0.y + ((v1.x - v0.x)*(v2.y - v0.y) - (v1.y - v0.y)*(v2.x - v0.x))*v0.z) >= 0
		}

		For i, v in oCube.Vertices {
			o[i] := ToScreenSpace.Transform(o[i])  ;* Transform to screen space with perspective transform.
		}

		For i, v in oCube.Indices {
			If (!c[i]) {  ;* Skip triangles already determined to be back-facing.
				DrawTriangle(o[v[0]], o[v[1]], o[v[2]], i//2)

				If (vDebug && GetKeyState("RShift", "P")) {
					oCanvas.Update(0)

					MsgBox(i)
				}
			}
		}

		oCanvas.Update()
	}

	SetTimer, Update, -1
}

;=====            Class             =========================;

Class ToScreenSpace {
	Static vWidth := 155, vHeight := 155  ;* Static vars are evaluated before `oCanvas` is created so these variables need to be changed manually.

	Transform(oVector3) {
		z := 1/oVector3.z  ;* Perspective transform.

		oVector3.x := (oVector3.x*z + 1)*this.vWidth, oVector3.y := (-oVector3.y*z + 1)*this.vHeight

		Return, (oVector3)
	}
}

Class Cube {
	__New(vSize) {
		s := vSize/2.0

		Return, ({"Vertices": [new Vector3(-s, -s, -s), new Vector3(s, -s, -s), new Vector3(-s,  s, -s), new Vector3(s,  s, -s), new Vector3(-s, -s,  s), new Vector3(s, -s,  s), new Vector3(-s,  s,  s), new Vector3(s,  s,  s)]
			, "Indices": [[0, 2, 1], [2, 3, 1]
				, [1, 3, 5], [3, 7, 5]
				, [2, 6, 3], [3, 6, 7]
				, [4, 5, 7], [4, 7, 6]
				, [0, 4, 2], [2, 4, 6]
				, [0, 1, 4], [1, 5, 4]]})
	}
}

DrawTriangle(oVector2a, oVector2b, oVector2c, vIndex) {
	;* Sorting vertices by y:
	If (oVector2b.y < oVector2a.y) {
		Swap(oVector2a, oVector2b)
	}

	If (oVector2c.y < oVector2b.y) {
		Swap(oVector2b, oVector2c)
	}

	If (oVector2b.y < oVector2a.y) {
		Swap(oVector2a, oVector2b)
	}

	If (oVector2a.y == oVector2b.y) {  ;* Natural flat top triangle.
		;* Sort top vertices by x:
		If (oVector2b.x < oVector2a.x) {
			Swap(oVector2a, oVector2b)
		}

		DrawFlatTopTriangle(oVector2a, oVector2b, oVector2c, vIndex)
	}
	Else If (oVector2b.y == oVector2c.y) {  ;* Natural flat bottom triangle.
		;* Sort bottom vertices by x:
		If (oVector2c.x < oVector2b.x) {
			Swap(oVector2b, oVector2c)
		}

		DrawFlatBottomTriangle(oVector2a, oVector2b, oVector2c, vIndex)
	}
	Else {  ;* General triangle.
		;* Find splitting vertex:
		a := (oVector2b.y - oVector2a.y)/(oVector2c.y - oVector2a.y)  ;* Alpha.
			, s := new Vector2(oVector2a.x + (oVector2c.x - oVector2a.x)*a, oVector2a.y + (oVector2c.y - oVector2a.y)*a)

		If (oVector2b.x < s.x) {  ;* Major right triangle.
			DrawFlatBottomTriangle(oVector2a, oVector2b, s, vIndex)
			DrawFlatTopTriangle(oVector2b, s, oVector2c, vIndex)
		}
		Else {  ;* Major left triangle.
			DrawFlatBottomTriangle(oVector2a, s, oVector2b, vIndex)
			DrawFlatTopTriangle(s, oVector2b, oVector2c, vIndex)
		}
	}
}

DrawFlatTopTriangle(oVector2a, oVector2b, oVector2c, vIndex) {  ;: https://docs.microsoft.com/en-us/windows/win32/direct3d11/d3d10-graphics-programming-guide-rasterizer-stage-rules
	;* Calulcate the slopes in screen space:
	m0 := (oVector2c.x - oVector2a.x)/(oVector2c.y - oVector2a.y), m1 := (oVector2c.x - oVector2b.x)/(oVector2c.y - oVector2b.y)

	;* Calculate start and end scanlines:
	y := Ceil(oVector2a.y - 0.5), s0 := Ceil(oVector2c.y - 0.5) ;* `s0` is the scanline AFTER the last line drawn.

	While (y < s0) {
		;* Caluclate start and end x-coords:
		x0 := m0*(y - oVector2a.y + 0.5) + oVector2a.x, x1 := m1*(y - oVector2b.y + 0.5) + oVector2b.x  ;* Add 0.5 to y value because we're calculating based on pixel CENTERS.

		;* Calculate start and end pixels:
		x := Ceil(x0 - 0.5), s1 := Ceil(x1 - 0.5) ;* `s1` is the pixel AFTER the last pixel drawn.

		While (x < s1) {
			DllCall("Gdiplus\GdipFillRectangle", "UPtr", oCanvas.Handle, "UPtr", oBrush[vIndex].Handle, "Float", x, "Float", y, "Float", 1, "Float", 1)

			x++
		}

		y++
	}
}

DrawFlatBottomTriangle(oVector2a, oVector2b, oVector2c, vIndex) {
	;* Calulcate the slopes in screen space:
	m0 := (oVector2b.x - oVector2a.x)/(oVector2b.y - oVector2a.y), m1 := (oVector2c.x - oVector2a.x)/(oVector2c.y - oVector2a.y)

	;* Calculate start and end scanlines:
	y := Ceil(oVector2a.y - 0.5), s0 := Ceil(oVector2c.y - 0.5) ;* `s0` is the scanline AFTER the last line drawn.

	While (y < s0) {
		;* Caluclate start and end points:
		x0 := m0*(y - oVector2a.y + 0.5) + oVector2a.x, x1 := m1*(y - oVector2a.y + 0.5) + oVector2a.x  ;* Add 0.5 to y value because we're calculating based on pixel CENTERS.

		;* Calculate start and end pixels
		x := Ceil(x0 - 0.5), s1 := Ceil(x1 - 0.5) ;* `s1` is the pixel AFTER the last pixel drawn.

		While (x < s1) {
			DllCall("Gdiplus\GdipFillRectangle", "UPtr", oCanvas.Handle, "UPtr", oBrush[vIndex].Handle, "Float", x, "Float", y, "Float", 1, "Float", 1)

			x++
		}

		y++
	}
}