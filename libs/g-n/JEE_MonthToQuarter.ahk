; Title:
; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=76&t=55696&hilit=Quarter
; Author:
; Date:
; for:     	AHK_L

/*


*/

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance, Force ; Prevent double execution of this script
Gui, Color, c454545
Gui, Margin, 30, 10

;-- Current Quarter
Gui, Font, cWhite bold s8
CurMonth:=A_MM,CurQuarter:=JEE_MonthToQuarter(CurMonth,FirstMonth), CurYear:=(A_MM < FirstMonth ? A_YYYY-1:"")
Gui, Add, Text, % "xm y+50 +0x4000 vCurQuarter", % "CURRENT QUARTER: " CurQuarter
Gui, Font
;-- First month of fiscal year
Gui, Font, cWhite s8
Gui, Add, Text, % "x+m yp +0x4000", First month of fiscal year:
Gui, Font, cBlack s8
Gui, Add, DropDownList, % "x+5 yp-4 w78 vFirstMonth gFirstMonth r12 AltSubmit", January||Febuary|March|April|May|June|Jully|August|September|October|November|December
GuiControl,Choose,FirstMonth,%FirstMonth%
Gui, Add, picture,x+7 yp-9, Images\GUI_CalendarIcon.png
;-- Quarter periods
Gui, Font, cWhite s8
Gui, Add, Text, % "xm+30 y+18 w300 +0x4000 vQuarter1"
Gui, Add, Text, % "xp y+2 w300 +0x4000 vQuarter2"
Gui, Add, Text, % "xp y+2 w300 +0x4000 vQuarter3"
Gui, Add, Text, % "xp y+2 w300 +0x4000 vQuarter4"
Gui, Add, picture,% "x32 y1 w6 h2 vImgWhitePixel", Images\WhitePixel.png
Gui, Font

Gui, show

FirstMonth:
GuiControlGet, FirstMonth
CurMonth:=A_MM,CurQuarter:=JEE_MonthToQuarter(CurMonth,FirstMonth), CurYear:=(A_MM < FirstMonth ? A_YYYY-1:"")
GuiControl,,CurQuarter,% "CURRENT QUARTER: " CurQuarter
GuiControl,,Quarter1,% "Quarter 1:   " JEE_QuarterGetStart(1, FirstMonth, CurYear) "  to  " JEE_QuarterGetEnd(1, FirstMonth, CurYear)
GuiControl,,Quarter2,% "Quarter 2:   " JEE_QuarterGetStart(2, FirstMonth,CurYear) "  to  " JEE_QuarterGetEnd(2, FirstMonth,CurYear)
GuiControl,,Quarter3,% "Quarter 3:   " JEE_QuarterGetStart(3, FirstMonth,CurYear) "  to  " JEE_QuarterGetEnd(3, FirstMonth,CurYear)
GuiControl,,Quarter4,% "Quarter 4:   " JEE_QuarterGetStart(4, FirstMonth,CurYear) "  to  " JEE_QuarterGetEnd(4, FirstMonth,CurYear)
GuiControlGet,Pos,Pos,Quarter%CurQuarter%
GuiControl,Move,ImgWhitePixel,% "y"PosY+6
return


;--------------------------------------------------------------------------------
;where vMonth and vMonthFirst are between 1 and 12
;where vMonthFirst is the first month of the 'year'
;returns a number between 1 and 4
JEE_MonthToQuarter(vMonth, vMonthFirst:=1) {
;--------------------------------------------------------------------------------
	return Floor((Mod(vMonth+12-vMonthFirst, 12) + 3)/3)
}
;note: vQuarter: an integer between 1 and 4 (or higher)
;note: vMonthFirst: an integer between 1 and 12
JEE_QuarterGetStart(vQuarter, vMonthFirst:=1, vYear:="")
{
	local
	;--1--
	if (vYear = "")
		vYear:= A_YYYY
	vMonth:= vMonthFirst+(vQuarter-1)*3
	if (vMonth < 1)
		return
	if (vMonth > 12)
		vYear += (vMonth-1) // 12, vMonth:= Mod(vMonth-1, 12)+1
	;--2--
	QuarterStart:=vYear Format("{:02}", vMonth) "01000000"
	FormatTime,QuarterStart,%QuarterStart%,yyyy-MM-dd ; ShortDate
	return QuarterStart
}
JEE_QuarterGetEnd(vQuarter, vMonthFirst:=1, vYear:="")
{
	local
	if (vYear = "")
		vYear:= A_YYYY
	vMonth:= vMonthFirst+vQuarter*3
	if (vMonth < 1)
		return
	if (vMonth > 12)
		vYear += (vMonth-1) // 12, vMonth:= Mod(vMonth-1, 12)+1
	QuarterEnd:= vYear Format("{:02}", vMonth)
	EnvAdd QuarterEnd, -1, S
	FormatTime,QuarterEnd,%QuarterEnd%,yyyy-MM-dd ; Short Date
	return QuarterEnd
}


GuiEscape:
ExitApp