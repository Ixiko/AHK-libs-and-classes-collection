; Link:   	https://raw.githubusercontent.com/Onimuru/GDIp/master/lib/GDIp.ahk
; Author:	Onimuru
; Date:   	13.11.2020
; for:     	AHK_L

/*


*/

;* 13/11/2020:
	;* Changed `Canvas.Smoothing` default to 4.
	;* Changed `Canvas.Interpolation` default to 7.
	;! Changed `Canvas.Rectangle` to `Canvas.Position`
;* 11/11/2020:
	;* Initial commit.

;=====           Function           =========================;

CreatePoint(oData, ByRef vPoint) {
	VarSetCapacity(vPoint, 8)

	NumPut(oData[0], vPoint, 0, "Float"), NumPut(oData[1], vPoint, 4, "Float")
}

CreateRect(oData, ByRef vRect, vFormat := "Float") {
	VarSetCapacity(vRect, 16)

	If (Type(oData) == "Object") {
		oData := [oData.x, oData.y, oData.Width, oData.Height]
	}
	NumPut(oData[0], vRect, 0, vFormat), NumPut(oData[1], vRect, 4, vFormat), NumPut(oData[2], vRect, 8, vFormat), NumPut(oData[3], vRect, 12, vFormat)
}

QueryPerformanceCounter_Passive() {
	Static __Previous := !DllCall("QueryPerformanceFrequency", "Int64P", f), __Frequency := f/100000000000  ;* Super minor performance boost depending on your processor (division vs multiplication).

	Return, (!DllCall("QueryPerformanceCounter", "Int64P", c) + ((__Previous) ? (((d := (c - __Previous)*__Frequency) >= 50) ? (!(__Previous := c - Mod(d, 50)) + 1) : (0)) : (!(__Previous := c) - 1)))
}

;=====             Class            =========================;

Class GDI {

	Class DC {

		__New(vHWND := 0) {
			If (!p := DllCall("GetDC", "Ptr", vHWND, "Ptr")) {
				Return, (ErrorLevel := -1)
			}

			this.HWND := vHWND, this.HDC := p
			Return, (ErrorLevel := 0)
		}

		__Delete() {
			If (!this.HDC) {
				MsgBox("DC.__Delete()")
			}

			ErrorLevel := DllCall("ReleaseDC", "Ptr", this.HWND, "Ptr", this.HDC), this.Base := ""
			Return, (ErrorLevel)
		}
	}
}

Class GDIp {

	;-----          Constructor         -------------------------;

	__New(oParameters*) {
        Throw, Exception(Format("0x{:08x}", 6), -1, "new GDIp(): This class object should not be constructed.")
	}

	;-----            Method            -------------------------;

	Startup() {
		If (!GDIp.Token) {
			If (!DllCall( "GetModuleHandle", "Str", "Gdiplus", "Ptr")) {
				If (!DllCall("LoadLibrary", "Str", "Gdiplus")) {
					Throw, (Exception(Format("0x{:08x}", ErrorLevel), -1, "Could not load the Gdiplus library."))
				}
			}

			VarSetCapacity(s, A_PtrSize == 8 ? 24 : 16, 0), s := Chr(1)  ;: https://docs.microsoft.com/en-us/windows/win32/api/gdiplusinit/ns-gdiplusinit-gdiplusstartupinput

			DllCall("Gdiplus\GdiplusStartup","Ptr*", p, "Ptr", &s, "Ptr", 0)
			If (p) {
				GDIp.Token := p
			}

			Return, (p)
		}
	}

	Shutdown() {
		If (GDIp.Token) {
			DllCall("Gdiplus\GdiplusShutdown", "Ptr", GDIp.Token)

			If (h := DllCall("GetModuleHandle", "Str", "Gdiplus", "Ptr")) {
				DllCall("FreeLibrary", "Ptr", h)
			}

			GDIp.Token := ""
		}
	}

	;-----         Nested Class         -------------------------;

	Class Canvas {

		;-----          Constructor         -------------------------;

		__Init() {
			GDIp.Startup()
		}

		;* new GDIp.Canvas(RectangleObject, Options, Name, Smoothing, Interpolation, HideOnCreation)
		__New(oRectangle, vOptions, vName := "gCanvas", vSmoothing := 4, vInterpolation := 7, vHide := 0) {
			VarSetCapacity(s, 20, 0), NumPut(40, s, 0, "UInt"), NumPut(oRectangle.Width, s, 4, "UInt"), NumPut(oRectangle.Height, s, 8, "UInt"), NumPut(1, s, 12, "UShort"), NumPut(32, s, 14, "UShort"), NumPut(0, s, 16, "UInt")

			ObjRawSet(this, "HBM", DllCall("CreateDIBSection", "UPtr", new GDI.DC(), "UPtr", &s, "UInt", 0, "UPtr*", 0, "UPtr", 0, "UInt", 0, "UPtr")), ObjRawSet(this, "HDC", DllCall("CreateCompatibleDC", "UPtr", 0)), ObjRawSet(this, "OBM", DllCall("SelectObject", "UPtr", this.HDC, "UPtr", this.HBM))

			ObjRawSet(this, "Position", oRectangle), ObjRawSet(this, "Name", vName)
			DllCall("Gdiplus\GdipCreateFromHDC", "UPtr", this.HDC, "UPtr*", p), ObjRawSet(this, "Handle", p), DllCall("Gdiplus\GdipSetSmoothingMode", "UPtr", this.Handle, "Int", vSmoothing), DllCall("Gdiplus\GdipSetInterpolationMode", "UPtr", this.Handle, "Int", vInterpolation)

			ObjRawSet(this, "Camera", {"Base": this.__Camera
				, "x": 0
				, "y": 0
				, "z": 0

				, "FocalLength": 300})

			Gui, % vName . ": New", % RegExReplace(vOptions, "\+(LastFound|E0x80000)") . " +LastFound +E0x80000"
			Gui, Show, % Format("x{} y{} w{} h{} {}", oRectangle.x, oRectangle.y, oRectangle.Width, oRectangle.Height, vHide ? "Hide" : "NA")
			ObjRawSet(this, "HWND", WinExist())
		}

		__Delete() {
			Gui, % this.Name . ": Destroy"

			DllCall("SelectObject", "UPtr", this.HDC, "UPtr", this.OBM), DllCall("DeleteObject", "UPtr", this.HBM), DllCall("DeleteDC", "UPtr", this.HDC)
			ErrorLevel := DllCall("Gdiplus\GdipDeleteGraphics", "UPtr", this.Handle), this.Base := ""  ;* Prevent all bad calls to Gdiplus.dll by disconnecting the base and freeing all references towards such functions from the object.

			Return, (ErrorLevel)
		}

		;-----           Property           -------------------------;

		__Set(vKey, vValue) {
			Switch (vKey) {
				Case "CompositingMode":  ;? 0 = SourceOver (blend), 1 = SourceCopy (overwrite)
					Return, (ErrorLevel := DllCall("Gdiplus\GdipSetCompositingMode", "UPtr", this.Handle, "Int", Math.Clamp(vValue, 0, 1)))
				Case "InterpolationMode":  ;? 0 = Default, 1 = LowQuality, 2 = HighQuality, 3 = Bilinear, 4 = Bicubic, 5 = NearestNeighbor, 6 = HighQualityBilinear, 7 = HighQualityBicubic
					Return, (ErrorLevel := DllCall("Gdiplus\GdipSetInterpolationMode", "UPtr", this.Handle, "Int", Math.Clamp(vValue, 0, 7)))
				Case "SmoothingMode":  ;? 0 = Default, 1 = HighSpeed, 2 = HighQuality, 3 = None, 4 = AntiAlias
					Return, (ErrorLevel := DllCall("Gdiplus\GdipSetSmoothingMode", "UPtr", this.Handle, "Int", Math.Clamp(vValue, 0, 4)))
				Case "TextRendering":  ;? 0 = SystemDefault, 1 = SingleBitPerPixelGridFit, 2 = SingleBitPerPixel, 3 = AntiAliasGridFit, 4 = AntiAlias, 5 = ClearTypeGridFit
					Return, (ErrorLevel := DllCall("Gdiplus\GdipSetTextRenderingHint", "UPtr", this.Handle, "Int", Math.Clamp(vValue, 0, 5)))
				Defualt:
					MsgBox(Format("Canvas.__Set({}, {})", vKey, vValue))
					Return
			}
		}

		;-----            Method            -------------------------;
		;-------------------------            Graphic           -----;

		;-----              Pen             -----;

		DrawArc(oPen, oRectangle, vStartAngle, vSweepAngle) {
			Return, (ErrorLevel := DllCall("Gdiplus\GdipDrawArc", "UPtr", this.Handle, "UPtr", oPen.Handle, "Float", oRectangle.x, "Float", oRectangle.y, "Float", oRectangle.Width - (o := oPen.Width), "Float", oRectangle.Height - o, "Float", vStartAngle, "Float", vSweepAngle))
		}

		DrawBezier(oPen, oPoints*) {
			oPoints := [oPoints*]

			Return, (ErrorLevel := DllCall("Gdiplus\GdipDrawBezier", "UPtr", this.Handle, "UPtr", oPen.Handle, "Float", oPoints[0].x, "Float", oPoints[0].y, "Float", oPoints[1].x, "Float", oPoints[1].y, "Float", oPoints[2].x, "Float", oPoints[2].y, "Float", oPoints[3].x, "Float", oPoints[3].y))
		}

		;* CanvasObject.DrawEllipse(PenObject, EllipseObject || RectangleObject)
		DrawEllipse(oPen, oEllipse) {
			Return, (ErrorLevel := DllCall("Gdiplus\GdipDrawEllipse", "UPtr", this.Handle, "UPtr", oPen.Handle, "Float", oEllipse.x + (o := oPen.Width//2), "Float", oEllipse.y + o, "Float", oEllipse.Width - (o := oPen.Width), "Float", oEllipse.Height - o))
		}

		;* CanvasObject.DrawLine(PenObject, PointObject, PointObject)
		DrawLine(oPen, oPoint2D1, oPoint2D2) {
			Return, (ErrorLevel := DllCall("Gdiplus\GdipDrawLine", "UPtr", this.Handle, "UPtr", oPen.Handle, "Float", oPoint2D1.x, "Float", oPoint2D1.y, "Float", oPoint2D2.x, "Float", oPoint2D2.y))
		}

		DrawLines(oPen, oPoints*) {
			m := oPoints.Length, VarSetCapacity(s, 8*m)

			For i, v in [oPoints*] {
				NumPut(v.x, s, 8*i, "Float"), NumPut(v.y, s, 8*i + 4, "Float")
			}
			Return, (ErrorLevel := DllCall("Gdiplus\GdipDrawLines", "UPtr", this.Handle, "UPtr", oPen.Handle, "UPtr", &s, "Int", m))
		}

		DrawPie(oPen, oRectangle, vStartAngle, vSweepAngle) {
			Return (ErrorLevel := DllCall("Gdiplus\GdipDrawPie", "UPtr", this.Handle, "UPtr", oPen.Handle, "Float", oRectangle.x, "Float", oRectangle.y, "Float", oRectangle.Width, "Float", oRectangle.Height, "Float", vStartAngle, "Float", vSweepAngle))
		}

		;* CanvasObject.DrawRectangle(PenObject, RectangleObject)
		DrawRectangle(oPen, oRectangle) {
;			w := oRectangle.Width - oPen.Width  ;*** I attempted to account for pen width being greater than the width/height but I would have to make clones of the pen (to a) not modify the original pen's width and b) have one for width and height each) and its not worth it.
;			If (w <= 0) {
;				w := 1, oPen.Width := oRectangle.Width - 1
;			}

			Return, (ErrorLevel := DllCall("Gdiplus\GdipDrawRectangle", "UPtr", this.Handle, "UPtr", oPen.Handle, "Float", oRectangle.x + (o := oPen.Width//2), "Float", oRectangle.y + o, "Float", oRectangle.Width - (o := oPen.Width), "Float", oRectangle.Height - o))
		}

		;-----             Brush            -----;

		;* CanvasObject.FillEllipse(BrushObject, EllipseObject || RectangleObject)
		FillEllipse(oBrush, oEllipse) {
			Return, (ErrorLevel := DllCall("Gdiplus\GdipFillEllipse", "UPtr", this.Handle, "UPtr", oBrush.Handle, "Float", oEllipse.x, "Float", oEllipse.y, "Float", oEllipse.Width, "Float", oEllipse.Height))
		}

		FillPie(oBrush, oRectangle, vStartAngle, vSweepAngle) {
			Return, (ErrorLevel := DllCall("Gdiplus\GdipFillPie", "UPtr", this.Handle, "UPtr", oBrush.Handle, "Float", oRectangle.x, "Float", oRectangle.y, "Float", oRectangle.Width, "Float", oRectangle.Height, "Float", vStartAngle, "Float", vSweepAngle))
		}

		FillPolygon(oBrush, oPoints, vFillMode := 0) {  ;? FillMode: 0 = Alternate (fill the polygon as a whole), 1 = Winding (fill each new "segment")
			VarSetCapacity(b, 8*oPoints.Length, 0)

			For i, v in oPoints {
				NumPut(v.x, b, i*8, "Float"), NumPut(v.y, b, i*8 + 4, "Float")
			}
			Return, (ErrorLevel := DllCall("Gdiplus\GdipFillPolygon", "UPtr", this.Handle, "UPtr", oBrush.Handle, "UPtr", &b, "Int", oPoints.Length, "Int", vFillMode))
		}

		;* CanvasObject.FillRectangle(BrushObject, RectangleObject)
		FillRectangle(oBrush, oRectangle) {
			Return, (ErrorLevel := DllCall("Gdiplus\GdipFillRectangle", "UPtr", this.Handle, "UPtr", oBrush.Handle, "Float", oRectangle.x, "Float", oRectangle.y, "Float", oRectangle.Width, "Float", oRectangle.Height))
		}

		;-----            String            -----;

		DrawString(oBrush, vString, vOptions := "", vFontName := "Arial", measureString := 0) {
			Static __Options := "undefined", __Font, __StringFormat, __Rect1 := CreateRect([0, 0, 0, 0], __Rect1), __Rect2 := VarSetCapacity(__Rect2, 16, 0)

			If (__Options != vOptions) {
				If (!o := new GDIp.FontFamily(vFontName)) {
					Return, (ErrorLevel := -1)
				}

				s := 0
				For k, v In {"Regular": 0, "Bold": 1, "Italic": 2, "BoldItalic": 3, "Underline": 4, "StrikeOut": 8} {
					If (RegExMatch(vOptions, "i)" . k)) {
						s |= v
					}
				}

				RegExMatch(vOptions, "i)((?<=S)\d+)", r)
				If (!__Font := new GDIp.Font(o, (r >= 1) ? (r) : (12), s)) {
					Return, (ErrorLevel := -2)
				}

				RegExMatch(vOptions, "i)NoWrap", r)
				If (!__StringFormat := new GDIp.StringFormat(0x4000 | (r ? 0x1000 : 0))) {
					Return, (ErrorLevel := -3)
				}

				Loop, 4 {
					i := A_Index - 1

					RegExMatch(vOptions, "i)((?<=" . ["X", "Y", "W", "H"][i] . ")\d+)", r)
					NumPut(Round(r), __Rect1, i*4, "Float")
				}

				RegExMatch(vOptions, "i)((?<=H)[a-z]+)", r)  ;? hValue (horizontal alignment): 0 = Left, 1 = Center, 2 = Right
				If (r && !o[2]) {
					Return, (ErrorLevel := 5)
				}
				DllCall("Gdiplus\GdipSetStringFormatAlign", "UPtr", __StringFormat.Handle, "Int", Round({"Left": 0, "Center": 1, "Centre": 1, "Right": 2}[r]))

				RegExMatch(vOptions, "i)((?<=V)[a-z]+)", r)  ;? vValue (vertical alignment): 0 = Top, 1 = Center, 2 = Bottom
				If (r && !o[3]) {
					Return, (ErrorLevel := 5)
				}
				DllCall("Gdiplus\GdipSetStringFormatLineAlign", "UPtr", __StringFormat.Handle, "Int", Round({"Top": 0, "Center": 1, "Centre": 1, "Bottom": 2}[r]))

				RegExMatch(vOptions, "i)((?<=R)\d+)", r)
				DllCall("gdiplus\GdipSetTextRenderingHint", "UPtr", this.Handle, "Int", Math.Clamp(r, 0, 5))

				__Options := vOptions
			}

			If (measureString) {
				If (ErrorLevel := DllCall("gdiplus\GdipMeasureString", "UPtr", this.Handle, "WStr", vString, "Int", -1, "UPtr", __Font.Handle, "UPtr", &__Rect1, "UPtr", __StringFormat.Handle, "UPtr", &__Rect2, "UInt*", c, "UInt*", l)) {
					Return, (ErrorLevel)
				}

				Return, (&__Rect2 ? [NumGet(__Rect2, 0, "Float"), NumGet(__Rect2, 4, "Float"), NumGet(__Rect2, 8, "Float"), NumGet(__Rect2, 12, "Float"), c, l] : 0)
			}

			Return, (ErrorLevel := DllCall("Gdiplus\GdipDrawString", "UPtr", this.Handle, "WStr", vString, "Int", -1, "UPtr", __Font.Handle, "UPtr", &__Rect1, "UPtr", __StringFormat.Handle, "UPtr", oBrush.Handle))
		}

;		MeasureString(vString, oFont, oStringFormat, ByRef RectF) {
;			Static __Rect2 := VarSetCapacity(__Rect2, 16, 0)
;
;			If (ErrorLevel := DllCall("gdiplus\GdipMeasureString", "UPtr", this.Handle, "WStr", vString, "Int", -1, "UPtr", oFont.Handle, "UPtr", &RectF, "UPtr", oStringFormat.Handle, "UPtr", &__Rect2, "UInt*", c, "UInt*", l)) {
;				Return, (ErrorLevel)
;			}
;			Return, (&__Rect2 ? [NumGet(__Rect2, 0, "Float"), NumGet(__Rect2, 4, "Float"), NumGet(__Rect2, 8, "Float"), NumGet(__Rect2, 12, "Float"), c, l] : 0)
;		}

		;-------------------------           Control            -----;

		;* Note:
			;* Using clipping regions you can clear a particular area on the graphics rather than clearing the entire graphics.
		Clear(vColor := "0x00000000") {
			Return, (ErrorLevel := DllCall("Gdiplus\GdipGraphicsClear", "UPtr", this.Handle, "Int", vColor))
		}

;		Resize(oData) {
;			this.Pos.Width := oData[0], this.Pos.Height := oData[1]
;
;			this.hBitmap := DllCall("CreateCompatibleBitmap", "UPtr", this.HDC, "Int", w, "Int", h, "UPtr")
;			hPrevBitmap := DllCall("SelectObject", "UPtr", this.hMemDC, "UPtr", this.hBitmap)
;			DllCall("DeleteObject", "UPtr", hPrevBitmap)
;		}

		Update(vClear := 1, vReset := 1, oRectangle := "", vAlpha := 255) {
			Static __Point := CreatePoint([0, 0], __Point), __Rect := CreateRect([0, 0, 0, 0], __Rect)  ;* 16 on both 32 and 64.

			If (!oRectangle.x && !oRectangle.y) {
				NumPut(oRectangle.x, __Point, 0, "UInt"), NumPut(oRectangle.y, __Point, 4, "UInt")
			}

			If (!oRectangle.Width || !oRectangle.Height) {
				oRectangle := new Rectangle(oRectangle.x, oRectangle.y, this.Position.Width, this.Position.Height)
			}

			If (ErrorLevel := DllCall("UpdateLayeredWindow", "UPtr", this.HWND, "UPtr", 0, "UPtr", (oRectangle.x == "" && oRectangle.y == "") ? (0) : (&__Point), "Int64*", oRectangle.Width | oRectangle.Height << 32, "UPtr", this.HDC, "Int64*", 0, "UInt", 0, "UInt*", vAlpha << 16 | 1 << 24, "UInt", 2)) {
				If (vClear) {
					DllCall("Gdiplus\GdipGraphicsClear", "UPtr", this.Handle, "Int", 0)
				}

				If (vReset) {
					DllCall("Gdiplus\GdipResetWorldTransform", "UPtr", this.Handle)
				}
			}
			Return, (!ErrorLevel)
		}

		Gdip_GetLastStatus(pMatrix) {
			return DllCall("gdiplus\GdipGetLastStatus", "UPtr", pMatrix)
		}

		;-------------------------            Matrix            -----;

		Gdip_ResetMatrix(pMatrix) {
			return DllCall("gdiplus\GdipResetMatrix", "UPtr", pMatrix)
		}


		Gdip_RotateMatrix(pMatrix, Angle, MatrixOrder=0) {
			return DllCall("gdiplus\GdipRotateMatrix", "UPtr", pMatrix, "Float", Angle, "Int", MatrixOrder)
		}

		Gdip_GetPathWorldBounds(pPath) {
			rData := {}

			VarSetCapacity(RectF, 16)
			NumPut(0, RectF, 0, "Float"), NumPut(0, RectF, 4, "Float"), NumPut(0, RectF, 8, "Float"), NumPut(0, RectF, 12, "Float")

			status := DllCall("gdiplus\GdipGetPathWorldBounds", "UPtr", pPath, "UPtr", &RectF)

			If (!status) {
					rData.x := NumGet(RectF, 0, "Float")
					, rData.y := NumGet(RectF, 4, "Float")
					, rData.w := NumGet(RectF, 8, "Float")
					, rData.h := NumGet(RectF, 12, "Float")
			}
			Else {
				Return status
			}

			return rData
		}

		Gdip_ScaleMatrix(pMatrix, scaleX, scaleY, MatrixOrder=0) {
			return DllCall("gdiplus\GdipScaleMatrix", "UPtr", pMatrix, "Float", scaleX, "Float", scaleY, "Int", MatrixOrder)
		}

		Gdip_TranslateMatrix(pMatrix, offsetX, offsetY, MatrixOrder=0) {
			return DllCall("gdiplus\GdipTranslateMatrix", "UPtr", pMatrix, "Float", offsetX, "Float", offsetY, "Int", MatrixOrder)
		}

		Gdip_TransformPath(pPath, pMatrix) {
			return DllCall("gdiplus\GdipTransformPath", "UPtr", pPath, "UPtr", pMatrix)
		}

		Gdip_SetMatrixElements(pMatrix, m11, m12, m21, m22, x, y) {
			return DllCall("gdiplus\GdipSetMatrixElements", "UPtr", pMatrix, "Float", m11, "Float", m12, "Float", m21, "Float", m22, "Float", x, "Float", y)

		}

		;-------------------------        World Transform       -----;

		Translate(oData) {
			Return, (ErrorLevel := DllCall("Gdiplus\GdipTranslateWorldTransform", "UPtr", this.Handle, "Float", oData[0], "Float", oData[1], "Int", 1))
		}

		Rotate(vAngle, oData := "") {
			If (!oData) {
				Return, (ErrorLevel := DllCall("Gdiplus\GdipRotateWorldTransform", "UPtr", this.Handle, "Float", vAngle, "Int", 1))
			}
			Return, (ErrorLevel := DllCall("Gdiplus\GdipTranslateWorldTransform", "UPtr", this.Handle, "Float", -oData[0], "Float", -oData[1], "Int", 1) + DllCall("Gdiplus\GdipRotateWorldTransform", "UPtr", this.Handle, "Float", vAngle, "Int", 1) + DllCall("Gdiplus\GdipTranslateWorldTransform", "UPtr", this.Handle, "Float", oData[0], "Float", oData[1], "Int", 1))
		}

		Scale(oData) {
			Return, (ErrorLevel := DllCall("Gdiplus\GdipScaleWorldTransform", "UPtr", this.Handle, "Float", oData[0], "Float", oData[1], "Int", 1))
		}

		Reset() {
			Return, (ErrorLevel := DllCall("Gdiplus\GdipResetWorldTransform", "UPtr", this.Handle))
		}
	}

	Class Brush {

		;-----          Constructor         -------------------------;

		__New(vColor := "0xFFFFFFFF")  {
			If (ErrorLevel := DllCall("Gdiplus\GdipCreateSolidFill", "UInt", vColor, "UPtr*", p)) {
				Return, (ErrorLevel)
			}

			ObjRawSet(this, "Handle", p)
		}

		__Delete() {
			If (!this.Handle) {
				MsgBox("Brush.__Delete()")
			}

			ErrorLevel := DllCall("Gdiplus\GdipDeleteBrush", "UPtr", this.Handle), this.Base := ""
			Return, (ErrorLevel)
		}

		__Get(vKey){
			Switch (vKey) {
				Case "Color":
					If (ErrorLevel := DllCall("Gdiplus\GdipGetSolidFillColor", "UPtr", this.Handle, "UInt*", c)) {
						Return, (ErrorLevel)
					}

					Return, (Math.ToBase(c, 10, 16))  ;! new Color(c[0, 2], c[2, 4], c[4, 6], c[6, 8])
			}
		}

		__Set(vKey, vValue) {
			Switch (vKey) {
				Case "Color":
					Return, (ErrorLevel := DllCall("Gdiplus\GdipSetSolidFillColor", "UPtr", this.Handle, "UInt", vValue))
			}
		}

		;-----            Method            -------------------------;

		Clone() {
			If (ErrorLevel := DllCall("Gdiplus\GdipCloneBrush", "UPtr", this.Handle, "UPtr*", p)) {
				Return, (ErrorLevel)
			}
			Return, ({"Handle": p, "Base": this.Base})
		}
	}

	Class LineBrush Extends GDIp.Brush {

		;-----          Constructor         -------------------------;

		__New(oRectangle, oColors, vDegrees := 0, vWrapMode := 1) {  ;? WrapMode: 0 = Tile, 1 = TileFlipX, 2 = TileFlipY, 3 = TileFlipXY, 4 = Clamp
			If (!oRectangle.Width || !oRectangle.Height) {
				CreatePoint(oRectangle.x, b1), CreatePoint(oRectangle.y, b2)

				ErrorLevel := DllCall("Gdiplus\GdipCreateLineBrush", "UPtr", &b1, "UPtr", &b2, "UInt", oColors[0], "UInt", oColors[1], "UInt", vWrapMode, "UPtr*", p)
			}
			Else {
				CreateRect(oRectangle, b, "Float")

				ErrorLevel := DllCall("Gdiplus\GdipCreateLineBrushFromRectWithAngle", "UPtr", &b, "UInt", oColors[0], "UInt", oColors[1], "Float", vDegrees, "UInt", 0, "UInt", vWrapMode, "UPtr*", p)
			}

			If (ErrorLevel) {
				Return, (ErrorLevel)
			}
			ObjRawSet(this, "Handle", p)
		}

		__Get(vKey){
			Switch (vKey) {
				Case "Color":
					VarSetCapacity(c, 8, 0)

					If (ErrorLevel := DllCall("Gdiplus\GdipGetLineColors", "UPtr", this.Handle, "Ptr", &c)) {
						Return, (ErrorLevel)
					}
					Return, (["0x" . Math.ToBase(NumGet(c, 0, "UInt"), 10, 16), "0x" . Math.ToBase(NumGet(c, 4, "UInt"), 10, 16)])
			}
		}

		__Set(vKey, vValue) {
			Switch (vKey) {
				Case "Color":
					Return, (ErrorLevel := DllCall("Gdiplus\GdipSetLineColors", "UPtr", this.Handle, "UInt", vValue[0], "UInt", vValue[1]))
			}
		}
	}

	Class Pen {

		;-----          Constructor         -------------------------;

		__New(vColor := "0xFFFFFFFF", vWidth := 1) {
			If (ErrorLevel := IsObject(vColor) ? DllCall("Gdiplus\GdipCreatePen2", "UPtr", vColor.Handle, "Float", vWidth, "Int", 2, "UPtr*", p) : DllCall("Gdiplus\GdipCreatePen1", "UInt", vColor, "Float", vWidth, "Int", 2, "UPtr*", p)) {
				Return, (ErrorLevel)
			}
			ObjRawSet(this, "Handle", p)
		}

		__Delete() {
			If (!this.Handle) {
				MsgBox("Pen.__Delete()")
			}

			ErrorLevel := DllCall("Gdiplus\GdipDeletePen", "UPtr", this.Handle), this.Base := ""
			Return, (ErrorLevel)
		}

		__Get(vKey){
			Switch (vKey) {
				Case "Color":
					If (ErrorLevel := DllCall("Gdiplus\GdipGetPenColor", "UPtr", this.Handle, "UInt*", c)) {
						Return, (ErrorLevel)
					}
					Return, (Math.ToBase(c, 10, 16))
				Case "Width":
					If (ErrorLevel := DllCall("Gdiplus\GdipGetPenWidth", "UPtr", this.Handle, "Float*", c)) {
						Return, (ErrorLevel)
					}
					Return, (~~c)
			}
		}

		__Set(vKey, vValue) {
			Switch (vKey) {
				Case "Brush":
					Return, (ErrorLevel := DllCall("Gdiplus\GdipSetPenBrushFill", "UPtr", this.Handle, "UPtr", vValue.Handle))
				Case "Color":
					Return, (ErrorLevel := DllCall("Gdiplus\GdipSetPenColor", "UPtr", this.Handle, "UInt", vValue))
				Case "Width":
					Return, (ErrorLevel := DllCall("Gdiplus\GdipSetPenWidth", "UPtr", this.Handle, "Float", vValue))
			}
		}

		;-----            Method            -------------------------;

		Clone() {
			If (ErrorLevel := DllCall("Gdiplus\GdipClonePen", "UPtr", this.Handle, "UPtr*", p)) {
				Return, (ErrorLevel)
			}
			Return, ({"Handle": p, "Base": this.Base})
		}
	}

	Class FontFamily {

		;-----          Constructor         -------------------------;

		__New(vFont := "Arial") {
			If (ErrorLevel := DllCall("Gdiplus\GdipCreateFontFamilyFromName", "WStr", vFont, "UPtr", 0, "UPtr*", p)) {  ;: http://www.jose.it-berater.org/gdiplus/reference/flatapi/fontfamily/gdipcreatefontfamilyfromname.htm
				Return, (ErrorLevel)
			}
			ObjRawSet(this, "Handle", p)
		}

		__Delete() {
			If (!this.Handle) {
				MsgBox("FontFamily.__Delete()")
			}

			ErrorLevel := DllCall("Gdiplus\GdipDeleteFontFamily", "UPtr", this.Handle), this.Base := ""
			Return, (ErrorLevel)
		}
	}

	Class Font {

		;-----          Constructor         -------------------------;

		__New(oFontFamily, vSize := "", vStyle := 0) {  ;? Style: 0 = Regular, 1 = Bold, 2 = Italic, 3 = BoldItalic, 4 = Underline, 8 = Strikeout
			If (ErrorLevel := DllCall("Gdiplus\GdipCreateFont", "UPtr", oFontFamily.Handle, "Float", vSize, "Int", vStyle, "UInt", 2, "UPtr*", p)) {  ;: http://www.jose.it-berater.org/gdiplus/reference/flatapi/font/gdipcreatefont.htm
				Return, (ErrorLevel)
			}
			ObjRawSet(this, "Handle", p)
		}

		__Delete() {
			If (!this.Handle) {
				MsgBox("Font.__Delete()")
			}

			ErrorLevel := DllCall("Gdiplus\GdipDeleteFont", "UPtr", this.Handle), this.Base := ""
			Return, (ErrorLevel)
		}

	}

	Class StringFormat {

		;-----          Constructor         -------------------------;

		__New(vFormat := 0, vLanguage := 0) {  ;? Format: 0x0001 = StringFormatFlagsDirectionRightToLeft, 0x0002 = StringFormatFlagsDirectionVertical, 0x0004 = StringFormatFlagsNoFitBlackBox, 0x0020 = StringFormatFlagsDisplayFormatControl, 0x0400 = StringFormatFlagsNoFontFallback, 0x0800 = StringFormatFlagsMeasureTrailingSpaces, 0x1000 = StringFormatFlagsNoWrap, 0x2000 = StringFormatFlagsLineLimit, 0x4000 = StringFormatFlagsNoClip
			If (ErrorLevel := DllCall("Gdiplus\GdipCreateStringFormat", "UInt", vFormat, "UShort", vLanguage, "UPtr*", p)) {
				Return, (ErrorLevel)
			}
			ObjRawSet(this, "Handle", p)
		}

		__Delete() {
			If (!this.Handle) {
				MsgBox("StringFormat.__Delete()")
			}

			ErrorLevel := DllCall("Gdiplus\GdipDeleteStringFormat", "UPtr", this.Handle), this.Base := ""
			Return, (ErrorLevel)
		}

		__Set(vKey, vValue) {
			Switch (vKey) {
				Case "Align":
					Return, (ErrorLevel := DllCall("Gdiplus\GdipSetStringFormatAlign", "UPtr", this.Handle, "Int", Math.Clamp(vValue, 0, 2)))  ;? Align (Horizontal): 0 = Left, 1 = Center, 2 = Right
				Case "LineAlign":
					Return, (ErrorLevel := DllCall("Gdiplus\GdipSetStringFormatLineAlign", "UPtr", this.Handle, "Int", Math.Clamp(vValue, 0, 2)))  ;? LineAlign (Vertical): 0 = Top, 1 = Center, 2 = Bottom
			}
		}
	}
}