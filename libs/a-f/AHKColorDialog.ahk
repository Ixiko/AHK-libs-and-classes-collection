; ======================================================================================================================
versioninfo =
(
========================================================================
 Description ...: A Custom ColorDialog
 Usage..........: Run from your script and selected color is saved to colors.ini as RGB
 .................: runwait, colordialog.ahk  ; run script, return when exited
..................:	IniRead, color, colors.ini, Color, color_selected,0x00000 ; load color from dialog into %color%
 Version .......: 1.0
 Modified ......: 2017.07.06
 Author ........: Peared
 AHK-Version....: 1.1.26.00 U32
 OS-Versions....: Win 10 64
========================================================================
Copyright (C) 2014-2016

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
It would never been anything other than an idea without all help ihave 4
found in Autohotkey.com forum, so thank you all for sharing.
)
#NoEnv
color_dialog_tool()

color_dialog_tool(){

	global
	colorlist2:=[0xffff0000,0xffff6600,0xffffcc00,0xffccff00,0xff66ff00,0xff00ff00,0xff00ff66,0xff00ffcc,0xff00ccff,0xff0066ff,0xff0000ff,0xff6600ff,0xffcc00ff,0xffff00cc,0xffff0066,0xffff0004]
	colorlist1:=[0xff000000,0xffff0000,0xffffffff]
	colorlist1pos := [0.0,0.3,1.0]
	c1:=0
	gui colordial:+alwaysontop +lastfound -DPIScale
	Gui, colordial:Margin, 5, 5
	Gui, colordial:color, white
	Gui, colordial:FONT, BLACK

	loop 8 {
	IniRead, v%c1%, colors.ini, Color, v%c1%,0x000000
	tmpcol := v%c1%
	Gui, colordial:Add, text,+E0x20 0x200 w20 h20 BackgroundTrans v1%c1% gcolor_preset,
	Gui, colordial:Add, Progress, x+-20 y+-20 w20 h20 Background%tmpcol% vv%c1%
	c1++
	GuiControl,+Background%tmpcol%,v%c1%
	}
	loop 4 {

		IniRead, v%c1%, colors.ini, Color, v%c1%,0x000000
		tmpcol := v%c1%
		Gui, colordial:Add, text,+E0x20 0x200 x+5 y5 w20 h20 BackgroundTrans v1%c1% gcolor_preset,
		Gui, colordial:Add, Progress, x+-20 y+-20 w20 h20 Background%tmpcol% vv%c1%

		c1++
		GuiControl,+Background%tmpcol%,v%c1%

		loop 7 {
			IniRead, v%c1%, colors.ini, Color, v%c1%,0x000000
			tmpcol := v%c1%
			Gui, colordial:Add, text,y+5 +E0x20 0x200 w20 h20 BackgroundTrans v2%c1% gcolor_preset,
			Gui, colordial:Add, progress, x+-20 y+-20 w20 h20 Background%tmpcol% vv%c1%
			GuiControl,+Background%tmpcol%,v%c1%
			c1++
		}

	}

	gui, colordial:font, s10 w700,
	Gui, colordial:Add, Pic, x+5 y5 w200 h200 gcolorpal hwndHPI1C
	Gui, colordial:Add, Pic, x+5 w15 h200 gcolorver hwndHPIC
	Gui, colordial:Add, text, x+5 y5 +E0x20 0x200 w60 h30 section BackgroundTrans gcolor_preset_set,
	Gui, colordial:Add, Progress, x+-60 y+-30 w60 h30 Background%RGB_v% vpC
	Gui, colordial:Add, text, x+5 +E0x20 0x200 w110 h30 BackgroundTrans vrgbval, # %color_main%
	gui, colordial:add, button, x+5 w80 h30 gcopy, Copy
	Gui, colordial:Add, text,xs y+0 +E0x20 0x200 w60 h30 BackgroundTrans gcolor_preset_set,
	Gui, colordial:Add, Progress, x+-60 y+-30 w60 h30 Background%RGB_v2% vpC2
	Gui, colordial:Add, text, x+5 +E0x20 0x200 w110 h30 BackgroundTrans vrgbvalold, # %color_old%
	gui, colordial:add, button, x+5 w80 h30 gcopyold, Copy

	Gui, colordial:Add, Slider,xs y+10 w160 h20 AltSubmit +NoTicks +Range0-255 vsR gSlidermove line1, %R_v%
	Gui, colordial:Add, Text, x+5 w35 h32 +Border vtr cBLACK +BackgroundTrans, R:
	gui, colordial:font
	Gui, colordial:Add, Edit, X+-10 W70 r1 LIMIT3 number vS_Red hwndRED gedit_set,%R_v%
	Gui, colordial:Add, UpDown, vU_redDown Range0-255 gupdown_set, %R_v%

	Gui, colordial:Add, Slider, xs y+7 w160 h20 AltSubmit +NoTicks +Range0-255 vsG gSlidermove line1, %G_v%
	gui, colordial:font, s10 w700,
	Gui, colordial:Add, Text,x+5 w35 h32 +Border vtg cBLACK +BackgroundTrans, G:
	gui, colordial:font
	Gui, colordial:Add, Edit, X+-10 W70 r1 LIMIT3 number r1 vS_GREEN hwndGREEN gedit_set,%G_v%
	Gui, colordial:Add, UpDown, vU_greenDown Range0-255 gupdown_set, %G_v%

	Gui, colordial:Add, Slider, xs y+8 w160 h20 AltSubmit +NoTicks +Range0-255 vsB gSlidermove line1, %B_v%
	gui, colordial:font, s10 w700,
	Gui, colordial:Add, Text, x+5 w35 h32 +Border vtb cBLACK +BackgroundTrans, B:
	gui, colordial:font
	Gui, colordial:Add, Edit, X+-10 W70 r1 LIMIT3 number r1 vS_BLUE hwndBLUE gedit_set,%B_v%
	Gui, colordial:Add, UpDown, vU_blueDown Range0-255 gupdown_set, %B_v%

	IC := Colors.MaxIndex()
	Ip := pos.MaxIndex()
	gui, colordial:add, button, xs+11 y+18 w80 h30 gcolor_ok_button, OK
	gui, colordial:add, button, x+12 w80 h30 gcolor_cancel_button, Cancel
	LinearGradient(HPI1C, Colorlist1, colorlist1pos, 2,1,200, 200)
	LinearGradient(HPIC, Colorlist2, , 1,1)
	Gui, colordial:Font, s14, Tahoma
	Gui, colordial:Show, , AHK ColorPick

return

; -------------------------------------------------------------------------------------------------------
color_cancel_button: ;{
gui, colordial:destroy
exitapp
return ;}
; -------------------------------------------------------------------------------------------------------
color_ok_button: ;{
gui, colordial:destroy
IniWrite, %color%, colors.ini, Color,color_selected
exitapp
return ;}
; ------------------------------------------------------------------------------------------------------
copy: ;{
clipboard = %color%
return ;}
; ---------------------------------------------------------------------------------------------------------
copyold: ;{
clipboard = %color_old%
return ;}
; ------------------------------------------------------------------------------------------------------
colorver: ;{

	color_old := color
	loop
	{
		MouseGetPos, ,,, OutputVarControl,3
		if (OutputVarControl = HPIC)
		{
			MouseGetPos, MouseX, MouseY
			PixelGetColor, color, %MouseX%, %MouseY%, RGB
			set_color_sel(color)
			c := Hex2RGB(color)
			r_v := rgb("1" ,color), g_v:=rgb("2",color) ,B_v:=rgb("3" ,color)
			set_control_val(r_v, g_v, b_v)
			GuiControl,+Background%color%,pC
			GuiControl,+Background%color_old%,pC2
			stringtrimleft,color, color, 2
			color_main := color
			color_view(color_main)
		}

		GetKeyState, OutputVar, lbutton
		if outputvar = U
			break
	}

return ;}
; ------------------------------------------------------------------------------------------------------
color_preset_set: ;{
set_col := 1
return ;}
; --------------------------------------------------------
color_preset: ;{

	if (set_col = 1) {
		var := A_GuiControl
		stringtrimleft,var, var, 1
		GuiControl,+Background%color%,v%var%
		v%var% = %color%
		set_col = 0
				IniWrite, %color%, colors.ini, Color,v%var%
	} else {
		var := A_GuiControl
		stringtrimleft,var, var, 1
		color := v%var%
		GuiControl,+Background%color%,pC
		color_main := Hex2RGB(color)
		r_v := rgb("1" ,color), g_v:=rgb("2",color) ,B_v:=rgb("3" ,color)
		set_control_val(r_v, g_v, b_v)
		color_view(color)
		set_color_sel(color)
	}

return ;}
;-------------------------------------------------------------
colorpal: ;{

	color_old := color
	loop
	{
		MouseGetPos, ,,, OutputVarControl,3
		if (OutputVarControl = HPI1C) 		{
			MouseGetPos, MouseX, MouseY
			PixelGetColor, color, %MouseX%, %MouseY%, RGB
			set_color_sel(color)
			c := Hex2RGB(color)
			r_v := rgb("1" ,color), g_v:=rgb("2",color) ,B_v:=rgb("3" ,color)
			set_control_val(r_v, g_v, b_v)
			stringtrimleft,color, color, 2
		}
		GetKeyState, OutputVar, lbutton
		if outputvar = U
			break
	}

return ;}
; ------------------------------------------------------------------------------------------------------
edit_set: ;{
	GuiControlGet,R_v,,s_red
		GuiControlGet,G_v,,s_green
		GuiControlGet,B_v,,s_blue
	set_control_val(r_v, g_v, b_v)
	rgb_c = %R_v%,%G_v%,%B_v%
		hex_c := RGB2Hex(rgb_c)
		set_color_sel("0x" hex_c)
	return
updown_set:
	GuiControlGet,R_v,,U_redDown
		GuiControlGet,G_v,,U_greenDown
		GuiControlGet,B_v,,U_blueDown
	set_control_val(r_v, g_v, b_v)
	rgb_c = %R_v%,%G_v%,%B_v%
		hex_c := RGB2Hex(rgb_c)
		color_view(hex_c)
	set_color_sel("0x" hex_c)
return ;}
; ------------------------------------------------------------------------------------------------------
colordialGuiClose:
ExitApp
}

set_color_sel(color){
global
IfInString, color, 0x
stringtrimleft,color, color, 2
GuiControl,+Background%color%,pC
GuiControl,+Background%color_old%,pC2
GuiControl,,rgbval,# %color%
GuiControl,,rgbvalold,# %color_old%
}

set_control_val(r_v, g_v, b_v){
	GuiControl,,sr,%R_v%
	GuiControl,,sg,%G_v%
	GuiControl,,sb,%B_v%
	GuiControl,,s_red,%R_v%
	GuiControl,,s_green,%G_v%
	GuiControl,,s_blue,%B_v%
	GuiControl,,U_redDown,%R_v%
	GuiControl,,U_greenDown,%G_v%
	GuiControl,,U_blueDown,%B_v%
return
}


slidermove: ;{
	GuiControlGet,R_v,,sR
	GuiControlGet,G_v,,sG
	GuiControlGet,B_v,,sB
	set_control_val(r_v, g_v, b_v)
	rgb_c = %R_v%,%G_v%,%B_v%
	hex_c := RGB2Hex(rgb_c)
	color_main := hex_c
    color_view(color_main)
	GuiControl,+Background%hex_c%,pC
	GuiControl,,s_red,%R_v%
	GuiControl,,s_green,%G_v%
	GuiControl,,s_blue,%B_v%
	GuiControl,,U_redDown,%R_v%
	GuiControl,,U_greenDown,%G_v%
	GuiControl,,U_blueDown,%B_v%
return ;}

color_view(color_main){
global
colorlist1.RemoveAt(2 , 2)
colorlist1.InsertAt(2 , "0xff" color_main, "0x00" color_main)
LinearGradient(HPI1C, Colorlist1, colorlist1pos, 2,1,200, 200)
return
}
Hex2RGB(CR) {
 	NumPut( "0x" SubStr(CR,-5), (V:="000000") )
	return NumGet(V,2,"UChar") "," NumGet(V,1,"UChar") "," NumGet(V,0,"UChar")
}
RGB(vNum, sColor) {
	vRGB := Hex2RGB(sColor)
	StringSplit, aRGB, vRGB, `,
	if (vNum = 1)
		return aRGB1
	else if (vNum = 2)
		return aRGB2
	else if (vNum = 3)
		return aRGB3
}
RGB2Hex(s, d="") {
   StringSplit, s, s, % d = "" ? "," : d
   SetFormat, Integer, % (f := A_FormatInteger) = "D" ? "H" : f
   h := s1 + 0 . s2 + 0 . s3 + 0
   SetFormat, Integer, %f%
   Return, RegExReplace(RegExReplace(h, "0x(.)(?=$|0x)", "0$1"), "0x")
}
;-------------- Code by JustMe
LinearGradient(HWND, oColors, oPositions = "", D = 0, GC = 0, BW = 0, BH = 0) {

	Static SS_BITMAP    := 0xE
	Static SS_ICON      := 0x3
	Static STM_SETIMAGE := 0x172
	Static IMAGE_BITMAP := 0x0

	If !IsObject(oColors) || (oColors.MaxIndex() < 2) {
		ErrorLevel := "Invalid parameter oColors!"
		Return False
	}
	IC := oColors.MaxIndex()
	If IsObject(oPositions) {
		If (oPositions.MaxIndex() <> IC) {
			ErrorLevel := "Invalid parameter oPositions!"
			Return False
		}
	} Else {
		oPositions := [0.0]
		P := 1.0 / (IC - 1)
		Loop, % (IC - 2)
			oPositions.Insert(P * A_Index)
		oPositions.Insert(1.0)
	}
	; -------------------------------------------------------------------------------------------------------------------
	; Check HWND
	WinGetClass, Class, ahk_id %HWND%
	If (Class != "Static") {
		ErrorLevel := "Class " . Class . " is not supported!"
		Return False
	}
	If !DllCall("GetModuleHandle", "Str", "Gdiplus")
		hGDIP := DllCall("LoadLibrary", "Str", "Gdiplus")
	VarSetCapacity(SI, 16, 0)
	Numput(1, SI, "UInt")
	DllCall("Gdiplus.dll\GdiplusStartup", "PtrP", pToken, "Ptr", &SI, "Ptr", 0)
	If (!pToken) {
		ErrorLevel := "GDIPlus could not be started!`nCheck the availability of GDIPlus on your system, please!"
		Return False
	}
VarSetCapacity(RECT, 16, 0)
	DllCall("User32.dll\GetClientRect", "Ptr", HWND, "Ptr", &RECT)
	W := NumGet(RECT, 8, "Int")
	H := NumGet(RECT, 12, "Int")
If D Not In 0,1,2,3
		D := 0
	If GC Not In 0,1
		GC := 0
	If BW Not Between 1 And W
		BW := W
	If BH Not Between 1 And H
		BH := H
DllCall("Gdiplus.dll\GdipCreateBitmapFromScan0", "Int", W, "Int", H, "Int", 0
         , "Int", 0x26200A, "Ptr", 0, "PtrP", pBitmap)
DllCall("Gdiplus.dll\GdipGetImageGraphicsContext", "Ptr", pBitmap, "PtrP", pGraphics)
VarSetCapacity(RECTF, 16, 0)
	NumPut(BW, RECTF,  8, "Float")
	NumPut(BH, RECTF, 12, "Float")
DllCall("Gdiplus.dll\GdipCreateLineBrushFromRect", "Ptr", &RECTF
         , "Int", 0, "Int", 0, "Int", D, "Int", 0, "PtrP", pBrush)
DllCall("Gdiplus.dll\GdipSetLineGammaCorrection", "Ptr", pBrush, "Int", GC)
	VarSetCapacity(COLORS, IC * 4, 0)
	O := -4
	For I, V In oColors
		NumPut(V | 0x00000000, COLORS, O += 4, "UInt")
VarSetCapacity(POSITIONS, IC * 4, 0)
	O := -4
	For I, V In oPositions
		NumPut(V, POSITIONS, O += 4, "Float")
	DllCall("Gdiplus.dll\GdipSetLinePresetBlend", "Ptr", pBrush, "Ptr", &COLORS, "Ptr", &POSITIONS, "Int", IC)
VarSetCapacity(ColourMatrix, 100, 0)
	Matrix := 1.5|0|0|0|0|0|1.5|0|0|0|0|0|1.5|0|0|0|0|0|1|0|0.05|0.05|0.05|0|1


	StringSplit, Matrix, Matrix, |
	Loop, 25
	{
		Matrix := (Matrix%A_Index% != "") ? Matrix%A_Index% : Mod(A_Index-1, 6) ? 0 : 1
		NumPut(Matrix, ColourMatrix, (A_Index-1)*4, "float")
	}
	DllCall("gdiplus\GdipCreateImageAttributes", "ptr*", ImageAttr)
	DllCall("gdiplus\GdipSetImageAttributesColorMatrix", "ptr", ImageAttr, "int", 1, "int", 1, "ptr", &ColourMatrix, "ptr", 0, "int", 0)
DllCall("Gdiplus.dll\GdipFillRectangle", "Ptr", pGraphics, "Ptr", pBrush
         , "Float", 0, "Float", 0, "Float", W, "Float", H)
	; -------------------------------------------------------------------------------------------------------------------
	; Create HBITMAP from bitmap
	DllCall("Gdiplus.dll\GdipCreateHBITMAPFromBitmap", "Ptr", pBitmap, "PtrP", hBitmap, "Int", 0X00FFFFFF)
	; -------------------------------------------------------------------------------------------------------------------
	; Free resources
	DllCall("gdiplus\GdipSetSmoothingMode", "uint", pGraphics, "int", 4)
DllCall("gdiplus\GdipCreatePen1", "int", 0xffff0000, "float", 3, "int", 2, "uint*", pPen)
	; Create HBITMAP from bitmap


DllCall("gdiplus\GdipDrawEllipse", "uint", pGraphics, "uint", pPen, "float", 0, "float", 80, "float", 80, "float", 60)

	DllCall("Gdiplus.dll\GdipDisposeImage", "Ptr", pBitmap)
	DllCall("Gdiplus.dll\GdipDeleteBrush", "Ptr", pBrush)
	DllCall("Gdiplus.dll\GdipDeleteGraphics", "Ptr", pGraphics)
	; Shutdown GDI+
	DllCall("Gdiplus.dll\GdiplusShutdown", "Ptr", pToken)
	If (hGDIP)
		DllCall("FreeLibrary", "Ptr", hGDIP)
	; -------------------------------------------------------------------------------------------------------------------
	; Set control styles
	Control, Style, -%SS_ICON%, , ahk_id %HWND%
	Control, Style, +%SS_BITMAP%, , ahk_id %HWND%
	; Assign the bitmap
	SendMessage, STM_SETIMAGE, IMAGE_BITMAP, hBitmap, , ahk_id %HWND%
	; Done!
	DllCall("Gdi32.dll\DeleteObject", "Ptr", hBitmap)
	Return True
}

