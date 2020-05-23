#SingleInstance Force
#NoEnv
SetWorkingDir %A_ScriptDir%
SetBatchLines -1

;Need to include your path to Gdip or have in the same directory as script
#Include ../../Gdip_All.ahk

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
