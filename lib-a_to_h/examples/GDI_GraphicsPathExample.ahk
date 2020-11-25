#NoEnv

;=== Create Gui, OnMessage ===
Gui 1: -Caption +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs
hGui := WinExist()
Gui 1: Show, NA
w := 550, h := 280
OnMessage(0x201, "WM_LBUTTONDOWN")


;===GDI+ prepare ===
pToken := Gdip_Startup()
hbm := CreateDIBSection(w, h), hdc := CreateCompatibleDC(), obm := SelectObject(hdc, hbm)
G := Gdip_GraphicsFromHDC(hdc), Gdip_SetSmoothingMode(G, 4)


;=== Background ===
pBrush := Gdip_CreateLineBrushFromRect(0, 0, w, h, 0xff555555, 0xff050505)
Gdip_FillRectangle(G, pBrush, 0, 0, w, h)
Gdip_DeleteBrush(pBrush)

pBrush := Gdip_BrushCreateHatch(0xff000000, 0x00000000, 8)
Gdip_FillRectangle(G, pBrush, 0, 0, w, h)
Gdip_DeleteBrush(pBrush)


;=== Create path (Bat) ===
pPath := Gdip_CreatePath() ; creates a Path (GraphicsPath object)

Gdip_StartPathFigure(pPath) ; starts a new figure in this Path
Gdip_AddPathLine(pPath, 110,95, 220,95) ; adds a line to the current figure of this path
Gdip_AddPathBezier(pPath, 220,95, 228,112, 233,120, 262,120) ; adds bezier
Gdip_AddPathLines(pPath, "262,120|265,95|269,110|280,110|284,95|287,120") ; adds lines
Gdip_AddPathBezier(pPath, 287,120, 305,120, 320,120, 330,95)
Gdip_AddPathLine(pPath, 330,95, 439,95)
Gdip_AddPathBeziers(pPath, "439,95|406,108|381,126|389,159|322,157|287,170|275,206|262,170|227,157|160,159|168,126|144,109|110,95") ; adds beziers
Gdip_ClosePathFigure(pPath) ; closes the current figure of this path


;=== Fill & draw path (Bat) === ; now when the path is finished, we can fill it with brushes and outline with pens
;pPen := Gdip_CreatePen(0x22ffffff, 14), Gdip_DrawPath(G, pPen, pPath), Gdip_DeletePen(pPen) ; uncomment to draw extra outline

pBrush := Gdip_CreateLineBrushFromRect(0, 95, w, (h-190)/2, 0xff110000, 0xff664040)
Gdip_FillPath(G, pBrush, pPath) ; fill Bat background 1
Gdip_DeleteBrush(pBrush)

pBrush := Gdip_BrushCreateHatch(0xff000000, 0x00000000, 21)
Gdip_FillPath(G, pBrush, pPath) ; fill Bat background 2
Gdip_DeleteBrush(pBrush)

pPen := Gdip_CreatePen(0xffa5a5a5, 5)
Gdip_DrawPath(G, pPen, pPath) ; draw Bat outline 1
Gdip_DeletePen(pPen)

pPen := Gdip_CreatePen(0xff000000, 1)
Gdip_DrawPath(G, pPen, pPath) ; draw Bat outline 2
Gdip_DeletePen(pPen)

Gdip_DeletePath(pPath) ; delete the Path as it is no longer needed and wastes memory


;=== Update, Delete, Shutdown ===
UpdateLayeredWindow(hGui, hdc, (A_ScreenWidth-w)//2, (A_ScreenHeight-h)//2, w, h)
SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc)
Gdip_DeleteGraphics(G)
Gdip_Shutdown(pToken)
return


Esc::ExitApp


;===Functions===========================================================================


WM_LBUTTONDOWN() {
PostMessage, 0xA1, 2
}

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

; Notes The first spline is constructed from the first point through the fourth point in the array and uses the second and third points as control points. Each subsequent spline in the sequence needs exactly three more points: the ending point of the previous spline is used as the starting point, the next two points in the sequence are control points, and the third point is the ending point.

;~ Gdip_AddPathBeziers(pPath, Points) {
;~ StringSplit, Points, Points, |
;~ VarSetCapacity(PointF, 8*Points0)
;~ Loop, %Points0%
;~ {
;~ StringSplit, Coord, Points%A_Index%, `,
;~ NumPut(Coord1, PointF, 8*(A_Index-1), "float"), NumPut(Coord2, PointF, (8*(A_Index-1))+4, "float")
;~ }
;~ return DllCall("gdiplus\GdipAddPathBeziers", "uint", pPath, "uint", &PointF, "int", Points0)
;~ }

;~ Gdip_AddPathBezier(pPath, x1, y1, x2, y2, x3, y3, x4, y4) { ; Adds a Bézier spline to the current figure of this path
;~ return DllCall("gdiplus\GdipAddPathBezier", "uint", pPath
;~ , "float", x1, "float", y1, "float", x2, "float", y2
;~ , "float", x3, "float", y3, "float", x4, "float", y4)
;~ }

; Function Gdip_AddPathLines
; Description Adds a sequence of connected lines to the current figure of this path.
;
; pPath Pointer to the GraphicsPath
; Points the coordinates of all the points passed as x1,y1|x2,y2|x3,y3.....
;
; return status enumeration. 0 = success

;~ Gdip_AddPathLines(pPath, Points) {
;~ StringSplit, Points, Points, |
;~ VarSetCapacity(PointF, 8*Points0)
;~ Loop, %Points0%
;~ {
;~ StringSplit, Coord, Points%A_Index%, `,
;~ NumPut(Coord1, PointF, 8*(A_Index-1), "float"), NumPut(Coord2, PointF, (8*(A_Index-1))+4, "float")
;~ }
;~ return DllCall("gdiplus\GdipAddPathLine2", "uint", pPath, "uint", &PointF, "int", Points0)
;~ }

;~ Gdip_AddPathLine(pPath, x1, y1, x2, y2) {
;~ return DllCall("gdiplus\GdipAddPathLine", "uint", pPath
;~ , "float", x1, "float", y1, "float", x2, "float", y2)
;~ }

;~ Gdip_AddPathArc(pPath, x, y, w, h, StartAngle, SweepAngle) {
;~ return DllCall("gdiplus\GdipAddPathArc", "uint", pPath, "float", x, "float", y, "float", w, "float", h, "float", StartAngle, "float", SweepAngle)
;~ }

;~ Gdip_AddPathPie(pPath, x, y, w, h, StartAngle, SweepAngle) {
;~ return DllCall("gdiplus\GdipAddPathPie", "uint", pPath, "float", x, "float", y, "float", w, "float", h, "float", StartAngle, "float", SweepAngle)
;~ }

;~ Gdip_StartPathFigure(pPath) { ; Starts a new figure without closing the current figure. Subsequent points added to this path are added to the new figure.
;~ return DllCall("gdiplus\GdipStartPathFigure", "uint", pPath)
;~ }

;~ Gdip_ClosePathFigure(pPath) { ; Closes the current figure of this path.
;~ return DllCall("gdiplus\GdipClosePathFigure", "uint", pPath)
;~ }

; Function Gdip_DrawPath
; Description draws a sequence of lines and curves defined by a GraphicsPath object
;
; pGraphics Pointer to the Graphics of a bitmap
; pPen Pointer to a pen
; pPath Pointer to a Path
;
; return status enumeration. 0 = success

;~ Gdip_DrawPath(pGraphics, pPen, pPath) {
;~ return DllCall("gdiplus\GdipDrawPath", "uint", pGraphics, "uint", pPen, "uint", pPath)
;~ }

;~ Gdip_WidenPath(pPath, pPen, Matrix=0, Flatness=1) { ; Replaces this path with curves that enclose the area that is filled when this path is drawn by a specified pen. This method also flattens the path.
;~ return DllCall("gdiplus\GdipWidenPath", "uint", pPath, "uint", pPen, "uint", Matrix, "float", Flatness)
;~ }

;~ Gdip_ClonePath(pPath) {
;~ DllCall("gdiplus\GdipClonePath", "uint", pPath, "uint*", pPathClone)
;~ return pPathClone
;~ }

#include ..\GDIP_ALL.ahk