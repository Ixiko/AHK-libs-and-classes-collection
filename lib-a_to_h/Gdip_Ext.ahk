Gdip_TextToGraphics2(pGraphics, Text, Options, Font="Arial", Width="", Height="", Measure=0){
	IWidth := Width, IHeight:= Height
	
	RegExMatch(Options, "i)X([\-\d\.]+)(p*)", xpos)
	RegExMatch(Options, "i)Y([\-\d\.]+)(p*)", ypos)
	RegExMatch(Options, "i)W([\-\d\.]+)(p*)", Width)
	RegExMatch(Options, "i)H([\-\d\.]+)(p*)", Height)
	RegExMatch(Options, "i)OC([a-f\d]+)", OutlineColour)
	RegExMatch(Options, "i)OW([\d\.]+)", OutlineWidth)
	RegExMatch(Options, "i)OF(0|1)", OutlineUseFill)
	RegExMatch(Options, "i)C(?!(entre|enter))([a-f\d]+)", Colour)
	RegExMatch(Options, "i)Top|Up|Bottom|Down|vCentre|vCenter", vPos)
	RegExMatch(Options, "i)NoWrap", NoWrap)
	RegExMatch(Options, "i)R(\d)", Rendering)
	RegExMatch(Options, "i)S(\d+)(p*)", Size)

	if !Gdip_DeleteBrush(Gdip_CloneBrush(Colour2))
		PassBrush := 1, pBrush := Colour2
	
	if !(IWidth && IHeight) && (xpos2 || ypos2 || Width2 || Height2 || Size2)
		return -1

	Style := 0, Styles := "Regular|Bold|Italic|BoldItalic|Underline|Strikeout"
	Loop, Parse, Styles, |
	{
		if RegExMatch(Options, "\b" A_loopField)
		Style |= (A_LoopField != "StrikeOut") ? (A_Index-1) : 8
	}
  
	Align := 0, Alignments := "Near|Left|Centre|Center|Far|Right"
	Loop, Parse, Alignments, |
	{
		if RegExMatch(Options, "\b" A_loopField)
			Align |= A_Index//2.1      ; 0|0|1|1|2|2
	}

	xpos := (xpos1 != "") ? xpos2 ? IWidth*(xpos1/100) : xpos1 : 0
	ypos := (ypos1 != "") ? ypos2 ? IHeight*(ypos1/100) : ypos1 : 0
	Width := Width1 ? Width2 ? IWidth*(Width1/100) : Width1 : IWidth
	Height := Height1 ? Height2 ? IHeight*(Height1/100) : Height1 : IHeight
	if !PassBrush
		Colour := "0x" (Colour2 ? Colour2 : "ff000000")
	Rendering := ((Rendering1 >= 0) && (Rendering1 <= 5)) ? Rendering1 : 4
	Size := (Size1 > 0) ? Size2 ? IHeight*(Size1/100) : Size1 : 12

	hFamily := Gdip_FontFamilyCreate(Font)
	hFont := Gdip_FontCreate(hFamily, Size, Style)
	FormatStyle := NoWrap ? 0x4000 | 0x1000 : 0x4000
	hFormat := Gdip_StringFormatCreate(FormatStyle)
	pBrush := PassBrush ? pBrush : Gdip_BrushCreateSolid(Colour)
	if !(hFamily && hFont && hFormat && pBrush && pGraphics)
		return !pGraphics ? -2 : !hFamily ? -3 : !hFont ? -4 : !hFormat ? -5 : !pBrush ? -6 : 0
   
	CreateRectF(RC, xpos, ypos, Width, Height)
	Gdip_SetStringFormatAlign(hFormat, Align)
	Gdip_SetTextRenderingHint(pGraphics, Rendering)
	ReturnRC := Gdip_MeasureString(pGraphics, Text, hFont, hFormat, RC)

	if vPos
	{
		StringSplit, ReturnRC, ReturnRC, |
		
		if (vPos = "vCentre") || (vPos = "vCenter")
			ypos += (Height-ReturnRC4)//2
		else if (vPos = "Top") || (vPos = "Up")
			ypos := 0
		else if (vPos = "Bottom") || (vPos = "Down")
			ypos := Height-ReturnRC4
		
		CreateRectF(RC, xpos, ypos, Width, ReturnRC4)
		ReturnRC := Gdip_MeasureString(pGraphics, Text, hFont, hFormat, RC)
	}

	if(!Measure){
		if(OutlineWidth1){
			; With antialiasing turned on the path and the text do not line up perfectly, shifting the path slightly up and left will improve it slightly
			; The offset is caused by the differences in the way text and paths rendered/antialiased, so the OF option will draw the text using FillPath instead of DrawText
			; Because the outline and the fill are both drawn using the path the outline will match the text better
			if(!OutlineUseFill1){
				RC_x := NumGet(RC, 0, "float")
				RC_y := NumGet(RC, 4, "float")
				NumPut(RC_x - 1, RC, 0, "float")
				NumPut(RC_y - 0.5, RC, 4, "float")
				out("YO1", RC_x, RC_y)
			}
			
			; Create a path to draw the outline with
			OutlineColour := "0x" (OutlineColour1 ? OutlineColour1 : "ff000000")
			pOutlinePath := Gdip_CreatePath(1)
			pOutlinePen := Gdip_CreatePen(OutlineColour, OutlineWidth1)
			Gdip_AddPathString(pOutlinePath, Text, hFamily, Style, Size, RC, hFormat)
			Gdip_DrawPath(pGraphics, pOutlinePen, pOutlinePath)
			
			if(!OutlineUseFill1){
				NumPut(RC_x, RC, 0, "float") ; Reset RC x and y
				NumPut(RC_y, RC, 4, "float")
				E := Gdip_DrawString(pGraphics, Text, hFont, hFormat, pBrush, RC)
			}
			else{
				E := Gdip_FillPath(pGraphics, pBrush, pOutlinePath)
			}
			
			Gdip_DeletePath(pOutlinePath)
			Gdip_DeletePen(pOutlinePen)
		}
		else
			E := Gdip_DrawString(pGraphics, Text, hFont, hFormat, pBrush, RC)
	}

	if !PassBrush
		Gdip_DeleteBrush(pBrush)
	Gdip_DeleteStringFormat(hFormat)   
	Gdip_DeleteFont(hFont)
	Gdip_DeleteFontFamily(hFamily)
	return E ? E : ReturnRC
}

Gdip_AddPathString(Path, sString, FontFamily, Style, Size, ByRef RectF, Format){
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	
	if (!A_IsUnicode)
	{
		nSize := DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, Ptr, &sString, "int", -1, Ptr, 0, "int", 0)
		VarSetCapacity(wString, nSize*2)
		DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, Ptr, &sString, "int", -1, Ptr, &wString, "int", nSize)
	}
	
	return DllCall("gdiplus\GdipAddPathString"
					, Ptr, Path
					, Ptr, A_IsUnicode ? &sString : &wString
					, "int", -1
					, Ptr, FontFamily
					, "int", Style
					, "float", Size
					, Ptr, &RectF
					, Ptr, Format)
}

Gdip_GetPathWorldBounds(Path){
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	VarSetCapacity(RectF, 16)
	DllCall("gdiplus\GdipGetPathWorldBounds", Ptr, Path, Ptr, &RectF)
	
	return &RectF ? NumGet(RectF, 0, "float") "|" NumGet(RectF, 4, "float") "|" NumGet(RectF, 8, "float") "|" NumGet(RectF, 12, "float") : 0
}

Gdip_GetPathPoints(Path){
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	PointCount := Gdip_GetPointCount(Path)
	if(PointCount = 0)
		return "Count: " 0
	VarSetCapacity(Points, PointCount * 8)
	DllCall("gdiplus\GdipGetPathPoints", Ptr, Path, Ptr, &Points, "Int", PointCount)
	Offset = 0
	Loop %PointCount%{
		out("  " NumGet(Points, Offset, "float") ", " NumGet(Points, Offset + 4, "float"))
		if(A_Index > 5)
			break
		Offset += 8
	}
	;~ return PointCount
	return "Count: " . PointCount
}

Gdip_GetPointCount(Path){
	VarSetCapacity(PointCount, 8)
	DllCall("gdiplus\GdipGetPointCount", A_PtrSize ? "UPtr" : "UInt", Path, "Int*", PointCount)
	return PointCount
}

Gdip_DrawPath(pGraphics, pPen, pPath){
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	return DllCall("gdiplus\GdipDrawPath", Ptr, pGraphics, Ptr, pPen, Ptr, pPath)
}

; =========================

/*
; Function              Gdip_AddPathBeziers
; Description           Adds a sequence of connected Bézier splines to the current figure of this path.
;
; pPath                 Pointer to the GraphicsPath
; Points                the coordinates of all the points passed as x1,y1|x2,y2|x3,y3.....
;
; return                status enumeration. 0 = success

; Notes                 The first spline is constructed from the first point through the fourth point in the array and uses the second and third points as control points. Each subsequent spline in the sequence needs exactly three more points: the ending point of the previous spline is used as the starting point, the next two points in the sequence are control points, and the third point is the ending point.
 */
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

Gdip_AddPathBezier(pPath, x1, y1, x2, y2, x3, y3, x4, y4) {	; Adds a Bézier spline to the current figure of this path
	return DllCall("gdiplus\GdipAddPathBezier", "uint", pPath
	, "float", x1, "float", y1, "float", x2, "float", y2
	, "float", x3, "float", y3, "float", x4, "float", y4)
}

/*
; Function              Gdip_AddPathLines
; Description           Adds a sequence of connected lines to the current figure of this path.
;
; pPath                 Pointer to the GraphicsPath
; Points                the coordinates of all the points passed as x1,y1|x2,y2|x3,y3.....
;
; return                status enumeration. 0 = success
*/
Gdip_AddPathLines(pPath, Points) {
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

Gdip_StartPathFigure(pPath) {	; Starts a new figure without closing the current figure. Subsequent points added to this path are added to the new figure.
	return DllCall("gdiplus\GdipStartPathFigure", "uint", pPath)
}

Gdip_ClosePathFigure(pPath) {	; Closes the current figure of this path.
	return DllCall("gdiplus\GdipClosePathFigure", "uint", pPath)
}

Gdip_WidenPath(pPath, pPen, Matrix=0, Flatness=1) {	; Replaces this path with curves that enclose the area that is filled when this path is drawn by a specified pen. This method also flattens the path.
	return DllCall("gdiplus\GdipWidenPath", "uint", pPath, "uint", pPen, "uint", Matrix, "float", Flatness)
}

Gdip_ClonePath(pPath) {
	DllCall("gdiplus\GdipClonePath", "uint", pPath, "uint*", pPathClone)
	return pPathClone
}