; gdi+ ahk tutorial 1 written by tic (Tariq Porter)
; Requires Gdip_all.ahk v1.69
; GDI+ library compilation of user contributed GDI+ functions
; made by Marius Șucan: https://github.com/marius-sucan/AHK-GDIp-Library-Compilation
;

#SingleInstance Force
#NoEnv
SetWorkingDir %A_ScriptDir%
SetBatchLines -1

;Need to include your path to Gdip or have in the same directory as script
#Include ../../Gdip_All.ahk

; Start gdi+
If !pToken := Gdip_Startup()
{
	MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
	ExitApp
}
OnExit, Exit

; Set the width and height we want as our drawing area, to draw everything in. This will be the dimensions of our bitmap
Width :=1400, Height := 1050

; Create a layered window (+E0x80000 : must be used for UpdateLayeredWindow to work!) that is always on top (+AlwaysOnTop), has no taskbar entry or caption
Gui, 1: -Caption -DPIScale +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs

; Show the window
Gui, 1: Show, NA

; Get a handle to this window we have created in order to update it later
hwnd1 := WinExist()

; Create a gdi bitmap with width and height of what we are going to draw into it. This is the entire drawing area for everything
hbm := CreateDIBSection(Width, Height)

; Get a device context compatible with the screen
hdc := CreateCompatibleDC()

; Select the bitmap into the device context
obm := SelectObject(hdc, hbm)

; Get a pointer to the graphics of the bitmap, for use with drawing functions
G := Gdip_GraphicsFromHDC(hdc)

; Set the smoothing mode to antialias = 4 to make shapes appear smother (only used for vector drawing and filling)
Gdip_SetSmoothingMode(G, 4)

; fill the background
pBrushBgr := Gdip_BrushCreateSolid(0xFF66ffee)
Gdip_FillRectangle(G, pBrushBgr, 1, 1, 990, 990)

; Create a slightly transparent (66) blue brush (ARGB = Transparency, red, green, blue) to draw a rectangle
pBrush := Gdip_BrushCreateSolid(0xFF000088)

; Draws a text along a polygonal line defined by PolygonalLine
PolygonalLine := "50,190|400,390|890,190|800,990"
Gdip_DrawStringAlongPolygon(G, "Oh my goodness!", "Arial", 80, 3, pBrush, PolygonalLine)

; Now draw a text contour rotated at 45 degrees
pPen := Gdip_CreatePen("0xCC990011", 5)
Gdip_SetPenDashStyle(pPen, 2)
Gdip_DrawOrientedString(G, "Contour text example", "Verdana", 90, 1, 20, 500, 800, 800, 45, pBrushBgr, pPen, 1)

; Delete the brush as it is no longer needed and wastes memory
Gdip_DeleteBrush(pBrush)
Gdip_DeleteBrush(pBrushBgr)
Gdip_DeletePen(pPen)


; Update the specified window we have created (hwnd1) with a handle to our bitmap (hdc), specifying the x,y,w,h we want it positioned on our screen
; So this will position our gui at (0,0) with the Width and Height specified earlier
UpdateLayeredWindow(hwnd1, hdc, 0, 0, Width, Height)


; Select the object back into the hdc
SelectObject(hdc, obm)

; Now the bitmap may be deleted
DeleteObject(hbm)

; Also the device context related to the bitmap may be deleted
DeleteDC(hdc)

; The graphics may now be deleted
Gdip_DeleteGraphics(G)
Return

;#######################################################################

Esc::
GoSub, Exit
Return

Exit:
; gdi+ may now be shutdown on exiting the program
Gdip_Shutdown(pToken)
ExitApp
Return