#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
WinSetTitle, World of Warcraft,,WOWWINDOW

#include %A_ScriptDir%\..\get_variance.ahk


hexWhite := 0xFFFFFF
hexBlack := 0x000000
hexBlue  := 0x0000FC
hexYellow := 0xFFFF00
hexRed := 0xFF0300
hexCyan := 0x03FFFF
hexLime := 0x05FC00

ST2MBx = 500
ST2MBy = 500




x::
	if GetKeyState("x", "P")
;Loop
{

time1 = %A_TickCount%

foundcolor := pixel_get(ST2MBx, ST2MBy)

MsgBox, %foundcolor%

cvWhite := get_variance(hexWhite, foundcolor)
cvRed := get_variance(hexRed, foundcolor)
cvBlue := get_variance(hexBlue, foundcolor)
cvBlack := get_variance(hexBlack, foundcolor)
cvYellow := get_variance(hexYellow, foundcolor)
cvCyan := get_variance(hexCyan, foundcolor)
cvLime := get_variance(hexLime, foundcolor)

a := {(cvWhite): "cvWhite", (cvRed): "cvRed", (cvBlue): "cvBlue", (cvCyan): "cvCyan", (cvLime): "cvLime", (cvBlack): "cvBlack", (cvYellow): "cvYellow"}

lowest := a[a.MinIndex()]

	if ( %lowest% = cvWhite )
		{
		MsgBox, looks like white, variance was %cvwhite% -
		}
	else
	if ( %lowest% = cvRed )
		{
		MsgBox, looks like red, variance was %cvRed%
		}
	else
	if ( %lowest% = cvCyan )
		{
		MsgBox, looks like red, variance was %cvCyan%
		}
	else
	if ( %lowest% = cvLime )
		{
		MsgBox, looks like red, variance was %cvLime%
		}
	else
	if ( %lowest% = cvBlack )
		{
		MsgBox, looks like red, variance was %cvBlack%
		}
	else
	if ( %lowest% = cvBlue ) or ( %lowest% cvYellow )
		{
		MsgBox, looks like red, variance was %cvBlue%
		}
	else
	if ( %lowest% cvYellow )
		{
		MsgBox, looks like red, variance was %cvYellow%
		}


}
return



pixel_get(X, Y)
{
		PixelGetColor, Color, X, Y, RGB
		return Color

}
