; Outlined Text with Some String Path functions
; Based mostly on gdi+ ahk tutorial 8 written by tic (Tariq Porter)
; Requires Gdip.ahk either in your Lib folder as standard library or using #Include
; reference - http://www.codeproject.com/KB/GDI-plus/OutlineText.aspx
; Hit F1, F2, and F3!

#SingleInstance, Force
#NoEnv
SetBatchLines, -1

; Uncomment if Gdip.ahk is not in your standard library
;#Include, Gdip.ahk


If !pToken := Gdip_Startup()
{
   MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
   ExitApp
}
OnExit, Exit

; Set the width and height we want as our drawing area, to draw everything in. This will be the dimensions of our bitmap
Width := 800, Height := 400

; Create a layered window (+E0x80000 : must be used for UpdateLayeredWindow to work!) that is always on top (+AlwaysOnTop), has no taskbar entry or caption
Gui, 1: -Caption +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs
Gui, 1: Add, Edit, w%Width% h20 y300, vMeEdit
; Show the window
Gui, 1: Show, NA

; Get a handle to this window we have created in order to update it later
hwnd1 := WinExist()
hbm := CreateDIBSection(Width, Height)
hdc := CreateCompatibleDC()
obm := SelectObject(hdc, hbm)
G := Gdip_GraphicsFromHDC(hdc)
Gdip_SetSmoothingMode(G, 4)


Font = Tahoma

If !Gdip_FontFamilyCreate(Font)
{
   MsgBox, 48, Font error!, The font you have specified does not exist on the system
   ExitApp
}

Gdip_SetInterpolationMode(g,7)

pPath := Gdip_CreatePath(0)
Options = x18 y10 w800 h400 cFF00ff00 r4 bold center s48
Gdip_AddString(pPath, "** SIMPLE OUTLINED TEXT **`n- Tahoma -", "Tahoma", options)	
; pPen := Gdip_CreatePen(0xAA00aa00, 6)	
pPen := Gdip_CreatePen(0xaa0000ee, 6)
Gdip_DrawPath(G, pPen, pPath)
pBrush := Gdip_BrushCreateSolid(0xFFffffff)
Gdip_FillPath(G, pBrush, pPath)

Gdip_DeletePen(pPen)
Gdip_DeletePath(pPath)
Gdip_DeleteBrush(pBrush)

; Update the specified window we have created (hwnd1) with a handle to our bitmap (hdc), specifying the x,y,w,h we want it positioned on our screen
; With some simple maths we can place the gui in the centre of our primary monitor horizontally and vertically at the specified heigth and width
UpdateLayeredWindow(hwnd1, hdc, (A_ScreenWidth-Width)//2, (A_ScreenHeight-Height)//2, Width, Height)

; By placing this OnMessage here. The function WM_LBUTTONDOWN will be called every time the user left clicks on the gui
OnMessage(0x201, "WM_LBUTTONDOWN")



Return

;#######################################################################

; This function is called every time the user clicks on the gui
; The PostMessage will act on the last found window (this being the gui that launched the subroutine, hence the last parameter not being needed)
WM_LBUTTONDOWN()
{
   PostMessage, 0xA1, 2
}

;#######################################################################

Exit:
; gdi+ may now be shutdown on exiting the program
Gdip_Shutdown(pToken)
ExitApp
Return


F1::
Gdip_GraphicsClear(g, 0x00ffffff)
pBrush := Gdip_BrushCreateSolid(0xff000000)
Gdip_FillRoundedRectangle(G, pBrush, 0, 0, Width, Height, 10)
Gdip_DeleteBrush(pBrush)

Gdip_SetInterpolationMode(g,7)

pPath := Gdip_CreatePath(0)
Options = x18 y10 w800 h400 cFF00ff00 center r4 bold s48
Gdip_AddString(pPath, "** Glowing Text 1 **`n- Verdana -", "Verdana", options)	
; pPen := Gdip_CreatePen(0xAA00aa00, 6)	
Loop, 6
{
	pPen := Gdip_CreatePen(0x55ffffff, A_index)
	Gdip_SetLineJoin(pPen)	
	Gdip_DrawPath(G, pPen, pPath)
}		

pBrush := Gdip_BrushCreateSolid(0xff0055bb)
Gdip_FillPath(G, pBrush, pPath)
Gdip_DeletePen(pPen)
Gdip_DeletePath(pPath)
Gdip_DeleteBrush(pBrush)
UpdateLayeredWindow(hwnd1, hdc, (A_ScreenWidth-Width)//2, (A_ScreenHeight-Height)//2, Width, Height)

return


F2::
Gdip_GraphicsClear(g, 0x00ffffff)
Gdip_SetInterpolationMode(g,7)

pPath := Gdip_CreatePath(0)
Options = x18 y10 w800 h400 cFF00ff00 center r4 bold s48
Gdip_AddString(pPath, "** Glowing Text 2 **`n- Georgia -", "Georgia", options)	
; pPen := Gdip_CreatePen(0xAA00aa00, 6)	
Loop, 4
{
	pPen := Gdip_CreatePen(0x880088ff, A_index*2)
	Gdip_SetLineJoin(pPen)	
	Gdip_DrawPath(G, pPen, pPath)
}		

pBrush := Gdip_BrushCreateSolid(0xFFffffff)
Gdip_FillPath(G, pBrush, pPath)
Gdip_DeletePen(pPen)
Gdip_DeletePath(pPath)
Gdip_DeleteBrush(pBrush)
UpdateLayeredWindow(hwnd1, hdc, (A_ScreenWidth-Width)//2, (A_ScreenHeight-Height)//2, Width, Height)
return

F3::
Gdip_GraphicsClear(g, 0x00ffffff)
Gdip_SetInterpolationMode(g,7)	
pPath := Gdip_CreatePath(0)
Options = x18 y10 w800 h400 cFF00ff00 r4 bold center s48
Gdip_AddString(pPath, "** SIMPLE OUTLINED TEXT **`n- Tahoma -", "Tahoma", options)	
; pPen := Gdip_CreatePen(0xAA00aa00, 6)	
pPen := Gdip_CreatePen(0xaa0000ee, 6)
Gdip_DrawPath(G, pPen, pPath)
pBrush := Gdip_BrushCreateSolid(0xFFffffff)
Gdip_FillPath(G, pBrush, pPath)

Gdip_DeletePen(pPen)
Gdip_DeletePath(pPath)
Gdip_DeleteBrush(pBrush)
UpdateLayeredWindow(hwnd1, hdc, (A_ScreenWidth-Width)//2, (A_ScreenHeight-Height)//2, Width, Height)
return

; Added Fuctions. I hope Tic or someone more skilled would modify these or write new ones.

; http://msdn.microsoft.com/en-us/library/ms534038%28VS.85%29.aspx
Gdip_AddString(Path, sString,fontName, options,stringFormat=0x4000)
{
   nSize := DllCall("MultiByteToWideChar", "UInt", 0, "UInt", 0, "UInt", &sString, "Int", -1, "UInt", 0, "Int", 0)
   VarSetCapacity(wString, nSize*2)
   DllCall("MultiByteToWideChar", "UInt", 0, "UInt", 0, "UInt", &sString, "Int", -1, "UInt", &wString, "Int", nSize)

	hFamily := Gdip_FontFamilyCreate(fontName)
	RegExMatch(Options, "i)X([\-0-9]+)", xpos)
	RegExMatch(Options, "i)Y([\-0-9]+)", ypos)
	RegExMatch(Options, "i)W([0-9]+)", Width)
	RegExMatch(Options, "i)H([0-9]+)", Height)
	RegExMatch(Options, "i)R([0-9])", Rendering)	
		
	Style := 0, Styles := "Regular|Bold|Italic|BoldItalic|Underline|Strikeout"
	Loop, Parse, Styles, |
	{
		If RegExMatch(Options, "i)\b" A_loopField)
		Style |= (A_LoopField != "StrikeOut") ? (A_Index-1) : 8
	}
	RegExMatch(Options, "i)S([0-9]+)", fontSize)
	Align := 0, Alignments := "Near|Left|Centre|Center|Far|Right"
	Loop, Parse, Alignments, |
	{
		If RegExMatch(Options, "i)\b" A_loopField)
		Align |= A_Index//2.1      ; 0|0|1|1|2|2
	}
	hFormat := Gdip_StringFormatCreate(stringFormat)
	Gdip_SetStringFormatAlign(hFormat, Align)	
	Gdip_SetTextRenderingHint(pGraphics, Rendering)
	CreateRectF(textbox, xpos1, ypos1, Width1, Height1)	
	iRet := DllCall("gdiplus\GdipAddPathString", "UInt", Path,  "UInt", &wString, "Int", -1, "Uint",hFamily, "Int", Style, "Float", fontSize1,"UInt", &textbox, "UInt", hFormat)
	Gdip_DeleteFontFamily(hFamily)
	Gdip_DeleteStringFormat(hFormat)
	return iRet 			
}

Gdip_DrawPath(pGraphics, pPen, Path)
{
	return DllCall("gdiplus\GdipDrawPath", "UInt", pGraphics, "UInt", pPen, "UInt", Path)
}

Gdip_SetLineJoin(pPen, linejoin=2) ;LineJoinMiter = 0,LineJoinBevel = 1,LineJoinRound = 2,LineJoinMiterClipped = 3
{
	return DllCall("gdiplus\GdipSetPenLineJoin", "Uint", pPen, "uInt", linejoin)
}
