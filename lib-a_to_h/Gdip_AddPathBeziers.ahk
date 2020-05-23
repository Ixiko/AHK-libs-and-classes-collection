;#####################################################################################
; GraphicsPath functions added by Learning one
;#####################################################################################

; Function Gdip_AddPathBeziers
; Description Adds a sequence of connected Bézier splines to the current figure of this path.
;
; pPath Pointer to the GraphicsPath
; Points the coordinates of all the points passed as x1,y1|x2,y2|x3,y3.....
;
; return status enumeration. 0 = success

; Notes The first spline is constructed from the first point through the fourth point in the array and uses the second and third points as control points.
; Each subsequent spline in the sequence needs exactly three more points: the ending point of the previous spline is used as the starting point,
; the next two points in the sequence are control points, and the third point is the ending point.

Gdip_AddPathBeziers(pPath, Points) {
StringSplit, Points, Points, |
VarSetCapacity(PointF, 8*Points0)
Loop, %Points0%
{
StringSplit, Coord, Points%A_Index%, `,
NumPut(Coord1, PointF, 8*(A_Index-1), "float"), NumPut(Coord2, PointF, (8*(A_Index-1))+4, "float")
}
return DllCall("gdiplus\GdipAddPathBeziers", "uint", pPath, "uint", &PointF, "int", Points0)
}

Gdip_AddPathBezier(pPath, x1, y1, x2, y2, x3, y3, x4, y4) { ; Adds a Bézier spline to the current figure of this path
return DllCall("gdiplus\GdipAddPathBezier", "uint", pPath
, "float", x1, "float", y1, "float", x2, "float", y2
, "float", x3, "float", y3, "float", x4, "float", y4)
}

Gdip_AddPathLines(pPath, Points) {

	; Function Gdip_AddPathLines
	; Description Adds a sequence of connected lines to the current figure of this path.
	;
	; pPath Pointer to the GraphicsPath
	; Points the coordinates of all the points passed as x1,y1|x2,y2|x3,y3.....
	;
	; return status enumeration. 0 = success

	StringSplit, Points, Points, |
	VarSetCapacity(PointF, 8*Points0)
	Loop, %Points0%
	{
		StringSplit, Coord, Points%A_Index%, `,
		NumPut(Coord1, PointF, 8*(A_Index-1), "float"), NumPut(Coord2, PointF, (8*(A_Index-1))+4, "float")
	}

return DllCall("gdiplus\GdipAddPathLine2", "uint", pPath, "uint", &PointF, "int", Points0)
}

Gdip_AddPathLine(pPath, x1, y1, x2, y2) {
return DllCall("gdiplus\GdipAddPathLine", "uint", pPath
, "float", x1, "float", y1, "float", x2, "float", y2)
}

Gdip_AddPathArc(pPath, x, y, w, h, StartAngle, SweepAngle) {
return DllCall("gdiplus\GdipAddPathArc", "uint", pPath, "float", x, "float", y, "float", w, "float", h, "float", StartAngle, "float", SweepAngle)
}

Gdip_AddPathPie(pPath, x, y, w, h, StartAngle, SweepAngle) {
return DllCall("gdiplus\GdipAddPathPie", "uint", pPath, "float", x, "float", y, "float", w, "float", h, "float", StartAngle, "float", SweepAngle)
}

Gdip_StartPathFigure(pPath) { ; Starts a new figure without closing the current figure. Subsequent points added to this path are added to the new figure.
return DllCall("gdiplus\GdipStartPathFigure", "uint", pPath)
}

Gdip_ClosePathFigure(pPath) { ; Closes the current figure of this path.
return DllCall("gdiplus\GdipClosePathFigure", "uint", pPath)
}

Gdip_DrawPath(pGraphics, pPen, pPath) {

	; Function Gdip_DrawPath
	; Description draws a sequence of lines and curves defined by a GraphicsPath object
	;
	; pGraphics Pointer to the Graphics of a bitmap
	; pPen Pointer to a pen
	; pPath Pointer to a Path
	;
	; return status enumeration. 0 = success

return DllCall("gdiplus\GdipDrawPath", "uint", pGraphics, "uint", pPen, "uint", pPath)
}

Gdip_WidenPath(pPath, pPen, Matrix=0, Flatness=1) { ; Replaces this path with curves that enclose the area that is filled when this path is drawn by a specified pen. This method also flattens the path.
return DllCall("gdiplus\GdipWidenPath", "uint", pPath, "uint", pPen, "uint", Matrix, "float", Flatness)
}

Gdip_ClonePath(pPath) {
DllCall("gdiplus\GdipClonePath", "uint", pPath, "uint*", pPathClone)
return pPathClone
}