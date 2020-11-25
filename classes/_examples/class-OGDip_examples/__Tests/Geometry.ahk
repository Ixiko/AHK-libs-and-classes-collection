;* 11/11/2020:
	;* Initial commit.

;=====         Auto-execute         =========================;
;===============           Settings           ===============;

#Include, %A_ScriptDir%\..\..\..\lib\General.ahk
#Include, %A_ScriptDir%\..\..\..\lib\Geometry.ahk
#Include, %A_ScriptDir%\..\..\..\lib\Math.ahk
#Include, %A_ScriptDir%\..\..\..\lib\ObjectOriented.ahk
#Include, %A_ScriptDir%\..\..\..\lib\String.ahk

#NoEnv
#SingleInstance, Force

Process, Priority, , Normal

;===============            Other             ===============;

;-----            Point2            -------------------------;
CurrentClass := "Point2"

CurrentMethod := "__New"
AssertMethod(new Point2(1, 2), "{x: 1, y: 2}")
AssertMethod(new Point2(1), "{x: 1, y: 1}")
AssertMethod(new Point2(new Point2(1, 2)), "{x: 1, y: 2}")
AssertMethod(new Point2({"x": 1, "y": 2}), "{x: 1, y: 2}")

CurrentMethod := "Angle"
AssertMethod(new Point2(0, 0), new Point2(1, 1), "0.7853981633974483")

CurrentMethod := "Distance"
AssertMethod(new Point2(0, 0), new Point2(1, 1), "1.4142135623730952")

CurrentMethod := "Equals"
AssertMethod(new Point2(1, 1), new Point2(1, 1), "1")
AssertMethod(new Point2(2, 1), new Point2(1, 1), "0")

CurrentMethod := "Slope"
AssertMethod(new Point2(0, 0), new Point2(1, 1), "1")

CurrentMethod := "MidPoint"
AssertMethod(new Point2(0, 0), new Point2(3, 3), "{x: 1.5, y: 1.5}")

CurrentMethod := "Rotate"
AssertMethod(new Point2(1, 1), new Point2(0, 0), 0.785398163397448, "{x: 0.000000000000001, y: 1.414213562373095}")

CurrentMethod := "Circumcenter"
AssertMethod(new Point2(0, 2), new Point2(2, 2), new Point2(2, 0), "{x: 1, y: 1}")

CurrentMethod := "Circumradius"
AssertMethod(new Point2(0, 2), new Point2(2, 2), new Point2(2, 0), "1.4142135623730952")

;-----           Vector2            -------------------------;
CurrentClass := "Vector2"

CurrentMethod := "__New"
AssertMethod(new Vector2(1, 2), "{x: 1, y: 2}")
AssertMethod(new Vector2(1), "{x: 1, y: 1}")
AssertMethod(new Vector2(new Vector2(1, 2)), "{x: 1, y: 2}")
AssertMethod(new Vector2({"x": 1, "y": 2}), "{x: 1, y: 2}")

CurrentMethod := "Multiply"
AssertMethod(new Vector2(1, 2), new Vector2(2, 1), "{x: 2, y: 2}")
AssertMethod(new Vector2(1, 2), {"x": 2, "y": 1}, "{x: 2, y: 2}")
AssertMethod(new Vector2(1, 2), 2, "{x: 2, y: 4}")

CurrentMethod := "Divide"
AssertMethod(new Vector2(2, 2), new Vector2(2, 2), "{x: 1, y: 1}")
AssertMethod(new Vector2(2, 2), {"x": 2, "y": 2}, "{x: 1, y: 1}")
AssertMethod(new Vector2(2, 2), 2, "{x: 1, y: 1}")

CurrentMethod := "Add"
AssertMethod(new Vector2(1, 2), new Vector2(1, 1), "{x: 2, y: 3}")
AssertMethod(new Vector2(1, 2), {"x": 1, "y": 1}, "{x: 2, y: 3}")
AssertMethod(new Vector2(1, 2), 1, "{x: 2, y: 3}")

CurrentMethod := "Subtract"
AssertMethod(new Vector2(1, 2), new Vector2(1, 3), "{x: 0, y: -1}")
AssertMethod(new Vector2(1, 2), {"x": 1, "y": 3}, "{x: 0, y: -1}")
AssertMethod(new Vector2(1, 2), 2, "{x: -1, y: 0}")

CurrentMethod := "Clamp"
AssertMethod(new Vector2(4, -2), new Vector2(1, 1), new Vector2(3, 3), "{x: 3, y: 1}")
AssertMethod(new Vector2(4, -2), 1, 3, "{x: 3, y: 1}")

CurrentMethod := "Cross"
AssertMethod(new Vector2(1, 1), new Vector2(3, 2), "-1")
AssertMethod(new Vector2(1, 1), {"x": 3, "y": 2}, "-1")

CurrentMethod := "Distance"
AssertMethod(new Vector2(1, 1), new Vector2(3, 2), "2.236067977499790")
AssertMethod(new Vector2(1, 1), {"x": 3, "y": 2}, "2.236067977499790")

CurrentMethod := "DistanceSquared"
AssertMethod(new Vector2(1, 1), new Vector2(3, 2), "5")
AssertMethod(new Vector2(1, 1), {"x": 3, "y": 2}, "5")

CurrentMethod := "Dot"
AssertMethod(new Vector2(2, 1), new Vector2(3, -2), "4")
AssertMethod(new Vector2(2, 1), {"x": 3, "y": -2}, "4")

CurrentMethod := "Equals"
AssertMethod(new Vector2(2, 1), new Vector2(3, -2), "0")
AssertMethod(new Vector2(2, 1), {"x": 2, "y": 1}, "1")

CurrentMethod := "Lerp"
AssertMethod(new Vector2(2, 1), new Vector2(3, -2), 0.73, "{x: 2.73, y: -1.19}")
AssertMethod(new Vector2(2, 1), {"x": 3, "y": -2}, 0.73, "{x: 2.73, y: -1.19}")

CurrentMethod := "Min"
AssertMethod(new Vector2(2, 1), new Vector2(3, -2), 0.73, "{x: 2, y: -2}")
AssertMethod(new Vector2(2, 1), {"x": 3, "y": -2}, 0.73, "{x: 2, y: -2}")

CurrentMethod := "Max"
AssertMethod(new Vector2(2, 1), new Vector2(3, -2), 0.73, "{x: 3, y: 1}")
AssertMethod(new Vector2(2, 1), {"x": 3, "y": -2}, 0.73, "{x: 3, y: 1}")

CurrentMethod := "Transform"
AssertMethod(new Vector2(2, 1), {"Elements": [1.29, 1, 0, 0, 0.73, 0, 0, 0, 1]}, "{x: 2.58, y: 2.73}")

CurrentMethod := "Negate"
AssertMethod(new Vector2(2, 1), "{x: -2, y: -1}")

CurrentMethod := "Normalize"
AssertMethod(new Vector2(2, 1), "{x: 0.894427190999916, y: 0.447213595499958}")

CurrentMethod := "Copy"
AssertMethod(new Vector2(2, 1), new Vector2(-3, 1), "{x: -3, y: 1}")

;-----           Vector3            -------------------------;
CurrentClass := "Vector3"

CurrentMethod := "__New"
AssertMethod(new Vector3(1, 2, 3), "{x: 1, y: 2, z: 3}")
AssertMethod(new Vector3(1), "{x: 1, y: 1, z: 1}")
AssertMethod(new Vector3(new Vector3(1, 2, 3)), "{x: 1, y: 2, z: 3}")
AssertMethod(new Vector3({"x": 1, "y": 2, "z": 3}), "{x: 1, y: 2, z: 3}")

CurrentMethod := "Multiply"
AssertMethod(new Vector3(1, 2, 3), new Vector3(2, 1, 2), "{x: 2, y: 2, z: 6}")
AssertMethod(new Vector3(1, 2, 3), {"x": 2, "y": 1, "z": 2}, "{x: 2, y: 2, z: 6}")
AssertMethod(new Vector3(1, 2, 3), 2, "{x: 2, y: 4, z: 6}")

CurrentMethod := "Divide"
AssertMethod(new Vector3(2, 2, 8), new Vector3(2, 2, 4), "{x: 1, y: 1, z: 2}")
AssertMethod(new Vector3(2, 2, 8), {"x": 2, "y": 2, "z": 4}, "{x: 1, y: 1, z: 2}")
AssertMethod(new Vector3(2, 2, 4), 2, "{x: 1, y: 1, z: 2}")

CurrentMethod := "Add"
AssertMethod(new Vector3(1, 2, 3), new Vector3(1, 1, 1), "{x: 2, y: 3, z: 4}")
AssertMethod(new Vector3(1, 2, 3), {"x": 1, "y": 1, "z": 1}, "{x: 2, y: 3, z: 4}")
AssertMethod(new Vector3(1, 2, 3), 1, "{x: 2, y: 3, z: 4}")

CurrentMethod := "Subtract"
AssertMethod(new Vector3(1, 2, 3), new Vector3(1, 3, 2), "{x: 0, y: -1, z: 1}")
AssertMethod(new Vector3(1, 2, 3), {"x": 1, "y": 3, "z": 2}, "{x: 0, y: -1, z: 1}")
AssertMethod(new Vector3(1, 2, 3), 2, "{x: -1, y: 0, z: 1}")

CurrentMethod := "Clamp"
AssertMethod(new Vector3(1, -2, 5), new Vector3(1, 1, 1), new Vector3(3, 3, 3), "{x: 1, y: 1, z: 3}")
AssertMethod(new Vector3(1, -2, 5), 1, 3, "{x: 1, y: 1, z: 3}")

CurrentMethod := "Cross"
AssertMethod(new Vector3(1, 2, 3), new Vector3(2, 1, 1), "{x: -1, y: 5, z: -3}")
AssertMethod(new Vector3(1, 2, 3), {"x": 2, "y": 1, "z": 1}, "{x: -1, y: 5, z: -3}")

CurrentMethod := "Distance"
AssertMethod(new Vector3(1, 2, 3), new Vector3(2, 1, 1), 2.449489742783178)
AssertMethod(new Vector3(1, 2, 3), {"x": 2, "y": 1, "z": 1}, 2.449489742783178)

CurrentMethod := "DistanceSquared"
AssertMethod(new Vector3(1, 2, 3), new Vector3(2, 1, 1), 6)
AssertMethod(new Vector3(1, 2, 3), {"x": 2, "y": 1, "z": 1}, 6)

CurrentMethod := "Dot"
AssertMethod(new Vector3(1, 2, 3), new Vector3(2, 1, 1), 7)
AssertMethod(new Vector3(1, 2, 3), {"x": 2, "y": 1, "z": 1}, 7)

CurrentMethod := "Equals"
AssertMethod(new Vector3(1, 2, 3), {"x": 1, "y": 2, "z": 3}, 1)
AssertMethod(new Vector3(1, 2, 3), new Vector3(1, 2, 3), 1)
AssertMethod(new Vector3(1, 2, 3), new Vector3(2, 1, 3), 0)

CurrentMethod := "Lerp"
AssertMethod(new Vector3(1, 2, 0), new Vector3(2, 1, 1), 0.25, "{x: 1.25, y: 1.75, z: 0.25}")
AssertMethod(new Vector3(1, 2, 0), {x: 2, y: 1, z: 1}, 0.25, "{x: 1.25, y: 1.75, z: 0.25}")

CurrentMethod := "Min"
AssertMethod(new Vector3(1, 2, 0), new Vector3(2, 1, 1), "{x: 1, y: 1, z: 0}")
AssertMethod(new Vector3(1, 2, 0), {x: 2, y: 1, z: 1}, "{x: 1, y: 1, z: 0}")

CurrentMethod := "Max"
AssertMethod(new Vector3(1, 2, 0), new Vector3(2, 1, 1), "{x: 2, y: 2, z: 1}")
AssertMethod(new Vector3(1, 2, 0), {x: 2, y: 1, z: 1}, "{x: 2, y: 2, z: 1}")

CurrentMethod := "Transform"
AssertMethod(new Vector3(2, 1, -3), {"Elements": [1.29, 1, 0, 0, 0.73, 0, 0, 0, 2.34]}, "{x: 2.58, y: 2.73, z: -7.02}")

CurrentMethod := "Negate"
AssertMethod(new Vector3(1, -2, 5), "{x: -1, y: 2, z: -5}")

CurrentMethod := "Normalize"
AssertMethod(new Vector3(1, -2, 5), "{x: 0.182574185835055, y: -0.365148371670111, z: 0.912870929175277}")

CurrentMethod := "Copy"
AssertMethod(new Vector3(2, 1, 5), new Vector3(3, 1, -5), "{x: 3, y: 1, z: -5}")

;-----           Matrix3            -------------------------;
CurrentClass := "Matrix3"

CurrentMethod := "__New"
AssertMethod(new Matrix3(), "{Elements: [1, 0, 0, 0, 1, 0, 0, 0, 1]}")

CurrentMethod := "Multiply"
AssertMethod(new Matrix3().Set([1, 0, 0, 0, 0.3, 0, 0, 0, 2]), new Matrix3().Set([1.2, 0, 0, 0, 1, 0, 0, 0, 2]), "{Elements: [1.2, 0, 0, 0, 0.3, 0, 0, 0, 4]}")

CurrentMethod := "Equals"
AssertMethod(Matrix3.Multiply(new Matrix3(), Matrix3.RotateX(1.2)), new Matrix3().RotateX(1.2), "1")

AssertMethod(Matrix3.Multiply(new Matrix3(), Matrix3.RotateY(1.2)), new Matrix3().RotateY(1.2), "1")

AssertMethod(Matrix3.Multiply(new Matrix3(), Matrix3.RotateZ(1.2)), new Matrix3().RotateZ(1.2), "1")

MsgBox("Finished.")

ExitApp

;=====           Hotkeys            =========================;

#If (WinActive(A_ScriptName))

	~$^s::
		Critical

		Sleep, 200
		Reload
		Return

	$F10::ListVars

#If

;=====          Functions           =========================;

AssertMethod(parameters*) {
	Global CurrentClass, CurrentMethod

	primary := parameters.RemoveAt(1), secondary := []
	For i, v in parameters {
		If (!parameters[i + 1]) {  ;* Last parameter passed is the desired result.
			result := v
		}
		Else {
			secondary.Push(v)
		}
	}

	Loop, % %CurrentClass%["HasKey"](CurrentMethod) + primary.base.HasKey(CurrentMethod) {
		query := ((%CurrentClass%["HasKey"](CurrentMethod) && A_Index == 1) ? (%CurrentClass%[CurrentMethod](primary, secondary[0], secondary*))
																			: ((secondary.Length) ? (primary[CurrentMethod](secondary[0], secondary*))
																										: (primary[CurrentMethod]())))  ;* If I ever manage to fix variadic arrays, this will break.

		If (query.base.base.HasKey("Print")) {
			query := query.Print()
		}

		If (query != result) {
			MsgBox(CurrentClass . "." . CurrentMethod . "(): " . query . " != " . result)
		}
	}
}