; © Drugwash, July 28, 2011
#Persistent
#NoEnv
#SingleInstance, force
#MaxMem 1
SetBatchLines, -1
SetControlDelay, 0
SetTitleMatchMode, Slow
SetTitleMatchMode, 3
SetWinDelay, -1
DetectHiddenWindows, On
DetectHiddenText, On
CoordMode, Mouse, Screen
CoordMode, Pixel, Screen

appname=PIG
version=1.4
release=July 28, 2011
;iconlocal=%A_ScriptDir%\info.ico
bkg=0
ex=0
roll=0
wt1=Programmer's Info Gatherer
wt2=F11-OnTop
wt3=F12-Freeze
wTitle = %wt1% (%wt2%, %wt3%)
param = Checked|Enabled|Visible|Tab|LineCount|CurrentLine|CurrentCol|Choice
style1 := "-0x800 +0x100 -0x4000000 -0x80 -0x800000 -0x200000 -E0x300 +E0x20"
style2 := "-0x80 +0x40 +0x200000 -0x100000 +E0x20 -E0x20300"

if !A_IsCompiled
	hIL := ILC_List("5", "res\bkg.bmp", 0, 0)
else
	hIL := ILC_List("5", A_ScriptFullPath, "100", 0)
Icnt := DllCall("ImageList_GetImageCount", "UInt", hIL)

SetWorkingDir, %A_Temp%

if !A_IsCompiled
	;Menu, Tray, Icon, %iconlocal%
Menu, Tray, NoStandard
Menu, Tray, Add, Hide window, show
Menu, Tray, Default, Hide window
Menu, Tray, Add, About, about
Menu, Tray, Add
Menu, Tray, Add, Reload, reload
Menu, Tray, Add, Exit
Menu, Tray, Tip, %appname% v%version%

Gui, Margin, 0, 0
Gui, Color, White, White
Gui, Font, s8, Tahoma
Gui, Add, Edit, x88 y11 w369 h14 %style1% vfp1, 
Gui, Add, Edit, x56 y26 w53 h14 %style1% vfp2, 
Gui, Add, Edit, x175 y26 w282 h14 %style1% vfp3, 
Gui, Add, Edit, x131 y41 w326 h14 %style1% vfp4, 
Gui, Add, Edit, x102 y58 w140 h14 %style1% vfp5, 
Gui, Add, Edit, x317 y58 w140 h14 %style1% vfp6, 
Gui, Add, Edit, x111 y73 w80 h14 %style1% vfp7, 
Gui, Add, Edit, x257 y73 w70 h14 %style1% vfp8, 
Gui, Add, Edit, x387 y73 w70 h14 %style1% vfp9, 
Gui, Add, Edit, x89 y90 w55 h14 %style1% vfp10, 
Gui, Add, Edit, x194 y90 w263 h14 %style1% vfp11, 
Gui, Add, Edit, x46 y105 w148 h14 %style1% vfp12, 
Gui, Add, Edit, x309 y105 w148 h14 %style1% vfp13, 
Gui, Add, Edit, x121 y120 w140 h14 %style1% vfp14, 
Gui, Add, Edit, x317 y120 w140 h14 %style1% vfp15, 
Gui, Add, Edit, x68 y135 w50 h14 %style1% vfp16, 
Gui, Add, Edit, x173 y135 w50 h14 %style1% vfp17, 
Gui, Add, Edit, x269 y135 w50 h14 %style1% vfp18, 
Gui, Add, Edit, x81 y151 w30 h14 %style1% vfp19, 
Gui, Add, Edit, x180 y151 w70 h14 %style1% vfp20, 
Gui, Add, Edit, x327 y151 w60 h14 %style1% +Right vfp21, 
Gui, Add, Edit, x397 y151 w60 h14 %style1% vfp22, 
Gui, Add, Edit, x205 y167 w252 h14 %style1% vfp23, 
Gui, Add, Edit, x9 y196 w448 h61 %style2% vfp24, 
Gui, Add, Edit, x469 y24 w250 h98 %style2% Hidden vfp25, 
Gui, Add, Edit, x469 y137 w250 h55 %style2% Hidden vfp26, 
Gui, Add, Edit, x469 y207 w250 h50 %style2% Hidden vfp27, 
Gui, Font, s9, Webdings
Gui, Add, Button, x433 y134 w24 h15, 4
Gui, Font, s8 Bold CWhite, Tahoma
Gui, Add, Text, x0 y0  w466 h266 +0x0600000E hwndhBkg vbgpic gmoveit,
Gui, Add, Text, x9 y9 w450 h1 0x10, 
Gui, Add, Text, x9 y11 w79 h14 0x200 BackgroundTrans +Right, Window title :
Gui, Add, Text, x9 y26 w47 h14 0x200 BackgroundTrans +Right, ahk_id :
Gui, Add, Text, x109 y26 w66 h14 0x200 BackgroundTrans +Right, ahk_class :
Gui, Add, Text, x9 y41 w122 h14 0x200 BackgroundTrans +Right, Position (on screen) :
Gui, Add, Text, x9 y56 w450 h1 0x10, 
Gui, Add, Text, x9 y58 w93 h14 0x200 BackgroundTrans +Right, Mouse (screen):
Gui, Add, Text, x242 y58 w75 h14 0x200 BackgroundTrans +Right, (window) :
Gui, Add, Text, x9 y73 w102 h14 0x200 BackgroundTrans +Right, Pixel color (RGB):
Gui, Add, Text, x197 y73 w60 h14 0x200 BackgroundTrans +Right, hex RGB:
Gui, Add, Text, x327 y73 w60 h14 0x200 BackgroundTrans +Right, hex BGR:
Gui, Add, Text, x9 y88 w450 h1 0x10, 
Gui, Add, Text, x9 y90 w80 h14 0x200 BackgroundTrans +Right, Control hwnd :
Gui, Add, Text, x144 y90 w50 h14 0x200 BackgroundTrans +Right, classNN :
Gui, Add, Text, x9 y105 w37 h14 0x200 BackgroundTrans +Right, Style :
Gui, Add, Text, x194 y105 w115 h14 0x200 BackgroundTrans +Right, Extended style :
Gui, Add, Text, x9 y120 w112 h14 0x200 BackgroundTrans +Right, Position (window) :
Gui, Add, Text, x261 y120 w56 h14 0x200 BackgroundTrans +Right, (screen) :
Gui, Add, Text, x9 y135 w59 h14 0x200 BackgroundTrans +Right, Checked :
Gui, Add, Text, x118 y135 w55 h14 0x200 BackgroundTrans +Right, Enabled :
Gui, Add, Text, x223 y135 w46 h14 0x200 BackgroundTrans +Right, Visible :
Gui, Add, Text, x9 y149 w450 h1 0x10, 
Gui, Add, Text, x9 y151 w72 h14 0x200 BackgroundTrans +Right, Current tab :
Gui, Add, Text, x111 y151 w69 h14 0x200 BackgroundTrans +Right, Line count :
Gui, Add, Text, x250 y151 w77 h14 0x200 BackgroundTrans +Right, Line/column :
Gui, Add, Text, x387 y151 w10 h14 0x200 Center BackgroundTrans, /
Gui, Add, Text, x9 y165 w450 h1 0x10, 
Gui, Add, Text, x9 y167 w196 h14 0x200 BackgroundTrans +Right, Chosen item in current control :
Gui, Add, Text, x9 y182 w390 h14 0x200 BackgroundTrans, All items in current control (DropDownList`, ComboBox`, ListView`, etc.) :
Gui, Add, Text, x469 y10 w159 h14 0x200 BackgroundTrans Hidden, Controls in current window :
Gui, Add, Text, x469 y123 w127 h14 0x200 BackgroundTrans Hidden, Current control's text :
Gui, Add, Text, x469 y193 w185 h14 0x200 BackgroundTrans Hidden, Selected text in current control :
Gui, Add, Text, x463 y9 w1 h250 0x11 Hidden, 
Gui, Font, , 
; Generated using SmartGUI Creator 4.3w
Gui, Show, w466 h266, %wTitle%
Gui, +LastFound
WinGet, mwID, ID, %wTitle%
gosub GuiContextMenu
;OnMessage(0xA3, "rollit")
;OnMessage(0xA4, "hideit")
SetTimer, getinfo, 200
Return

moveit:
PostMessage, 0xA1, 2,,, A
return

Button4:
ex := !ex
GuiControl, Focus, Edit1
GuiControl, % (ex ? "Show" : "Hide"), Static31
GuiControl, % (ex ? "Show" : "Hide"), Static32
GuiControl, % (ex ? "Show" : "Hide"), Static33
GuiControl, % (ex ? "Show" : "Hide"), Static34
GuiControl, % (ex ? "Show" : "Hide"), Edit25
GuiControl, % (ex ? "Show" : "Hide"), Edit26
GuiControl, % (ex ? "Show" : "Hide"), Edit27
GuiControl, MoveDraw, bgpic, % "w" 466 + ex*260
GuiControl,, Button1, % (ex ? "3" : "4")
Gui, Show, AutoSize
return

F11::
aot := !aot
Gui, % (aot ? "+" : "-") "AlwaysOnTop"
wt2 := "F11-OnTop" (aot ? " [on]" : "")
wTitle = %wt1% (%wt2%, %wt3%)
WinSetTitle, ahk_id %mwID%,, %wTitle%
IfWinNotActive, ahk_id %mwID%
	if aot
		WinActivate, ahk_id %mwID%
return

F12::
freeze := !freeze
wt3 := "F12-Freeze" (freeze ? " [on]" : "")
wTitle = %wt1% (%wt2%, %wt3%)
WinSetTitle, ahk_id %mwID%,, %wTitle%
return

GuiContextMenu:
bkg := bkg < Icnt ? ++bkg : 1
hBmp := ILC_FitBmp(hBkg, hIL, bkg)
WinSet, Redraw,, ahk_id %mwID%
Sleep, 10
return

show:
GuiEscape:
hideit()
return

about:
Gui, 2:+ToolWindow -Caption +Border +AlwaysOnTop
Gui, 2:Margin, 0, 5
Gui, 2:Add, Text, x0 y0 w190 h80 +0xE hwndhAbt gdismiss,
hBmpA := ILC_FitBmp(hAbt, hIL, bkg)
Gui, 2:Font, s7 Bold, Tahoma
Gui, 2:Add, Text, xm ym+5 h14 w180 0x200 BackgroundTrans Center, © Drugwash, %release%
Gui, 2:Add, Text, xm y+5 h14 w180 0x200 BackgroundTrans Center, version %version%
Gui, 2:Font, Norm
Gui, 2:Add, Text, xm y+10 h14 w180 0x200 BackgroundTrans Center, icon from www.famfamfam.com
Gui, 2:Show, w180 h80, About %appname%
return

dismiss:
2GuiContextMenu:
Gui, 2:Destroy
return

reload:
DllCall("DeleteObject", "UInt", hBmp)
if hBmpA
	DllCall("DeleteObject", "UInt", hBmpA)
ILC_Destroy(hIL)
Reload

exit:
GuiClose:
DllCall("DeleteObject", "UInt", hBmp)
ILC_Destroy(hIL)
ExitApp

getinfo:
SetFormat, Integer, D
if freeze
	return
r := info()
if (cwID = mwID && lastwID != mwID)
	{
	Loop, 27
		GuiControl,, Edit%A_Index%,
	GuiControl,, Edit1, [©__©] _¸==O  d(?o?)b  .oO(... I did it my waaaaaaaaay !)
	}
else if !r
	Loop, 27
		{
		data := fp%A_Index%
		if A_Index between 16 and 18
			data := (data ? "Yes" : "No")
;		GuiControl,, Edit%A_Index%, % (SubStr(fp11, 1, 4)!="Edit" && A_Index="22") ? "N/A" : data
		GuiControl,, Edit%A_Index%, % (!InStr(fp11, "Edit") && A_Index="22") ? "N/A" : data
		}
lastwID := cwID
return
;———————————————————————————————
;				FUNCTIONS
;———————————————————————————————
info()
{
Global
Static lastX, lastY
SetFormat, IntegerFast, D
MouseGetPos, cmpX, cmpY, cwID, fp11
if (cmpX = lastX && cmpY = lastY) OR (cwID = mwID)
	return 1
lastX := cmpX
lastY := cmpY
SetFormat, IntegerFast, H
PixelGetColor, fp9, cmpX, cmpY, Slow
PixelGetColor, fp8, cmpX, cmpY, Slow RGB
WinGetTitle, fp1, ahk_id %cwID%
WinGetClass, fp3, ahk_id %cwID%
SetFormat, IntegerFast, D
WinGetPos, cwX, cwY, cwW, cwH, ahk_id %cwID%
; the following might require border/titlebar/menu fixing
miwX := cmpX - cwX
miwY := cmpY - cwY
WinGet, fp25, ControlList, ahk_id %cwID%
ControlGet, fp10, Hwnd,, %fp11%, ahk_id %cwID%
ControlGet, fp12, Style,, %fp11%, ahk_id %cwID%
ControlGet, fp13, ExStyle,, %fp11%, ahk_id %cwID%
ControlGetPos, ccpX, ccpY, ccpW, ccpH, %fp11%, ahk_id %cwID%
Loop, Parse, param, |
	{
	i := A_Index+15
	ControlGet, fp%i%, %A_LoopField%,, %fp11%, ahk_id %cwID%
	}
ControlGet, fp24, List,, %fp11%, ahk_id %cwID%
ControlGetText, fp26, %fp11%, ahk_id %cwID%
ControlGet, fp27, Selected,, %fp11%, ahk_id %cwID%
;StringReplace, fp12, fp12, 0x5, 0x0
fp2 = %cwID%
fp4 = x%cwX%  y%cwY%  w%cwW%  h%cwH%
fp5 = x%cmpX% y%cmpY%
fp6 = x%miwX% y%miwY%
fp7 := (fp8 & 0xFF0000) >> 16 " " (fp8 & 0xFF00) >> 8 " " (fp8 & 0xFF)
fp12 := fp12 " (" SubStr(fp12, 3, 4) "." SubStr(fp12, 7) ")"
fp13 := fp13 " (" SubStr(fp13, 3, 4) "." SubStr(fp13, 7) ")"
fp14 = x%ccpX%  y%ccpY%  w%ccpW%  h%ccpH%
fp15 := "x" cwX+ccpX " y" cwY+ccpY
}
;———————————————————————————————
hideit()
{
Global roll, mwID
Static s=0
s := !s
Menu, Tray, Rename, % (s ? "Hide" : "Show") " window", % (!s ? "Hide" : "Show") " window"
Gui, % (s ? "Hide" : "Show")
if (roll & !s)
	rollit()
return 1
}
;———————————————————————————————
rollit()
{
Critical
Global aot, roll, mwID, wTitle
Static wh=266, ww=466
roll := !roll
if roll
	{
	SetTimer, getinfo, off
	SysGet, cm, 4
	SysGet, hb, 46
	mm := cm+2*hb
	WinGetPos,,, ww, wh, ahk_id %mwID%
	WinMove, ahk_id %mwID%, , , , 200, %mm%
	WinSetTitle, ahk_id %mwID%,, PIG [rollup]
	Gui, +AlwaysOnTop
	}
else
	{
	WinMove, ahk_id %mwID%, , , , %ww%, %wh%
	WinSetTitle, ahk_id %mwID%,, %wTitle%
	Gui, % (aot ? "+" : "-") "AlwaysOnTop"
	SetTimer, getinfo, on
	}
GuiControl,, Edit24, r=%r%, mm=%mm%, wh=%wh%, ww=%ww%
WinActivate
return 1
}

;#include func_ImageList.ahk


;func_ImageList function below:

; © Drugwash, February-August 2011
; Set of ImageList functions that allow custom icon sizes
; Many thanks to SKAN for fixing bitmap stretch issue under XP

; default: 16x16 ILC_COLOR24 ILC_MASK
; M=ILC_MASK P=ILC_PALETTE D=ILC_COLORDDB accepted colors: 4 8 16 24 32

ILC_Create(i, g="1", s="16x16", f="M24")
{
if i<1
	return 0
StringSplit, s, s, x
s2 := s2 ? s2 : s1
c=
Loop, Parse, f
	if A_LoopField is digit
		c .= A_LoopField
StringReplace, f, f, c,,
m := c|(InStr(f, "M") ? 0x1 : 0)|(InStr(f, "P") ? 0x800 : 0)|(InStr(f, "D") ? 0xFE : 0)
return DllCall("ImageList_Create", "Int", s1, "Int", s2, "UInt", m, "Int", i, "Int", g)	; ILC_COLOR24 ILC_MASK
}

ILC_List(cx, file, idx="100", cd="1")	; cd=color depth 32bit, set 0 for 24bit or lower
{
mask := cd ? 0xFF000000 : 0xFFFFFFFF
Loop, %file%
	if A_LoopFileExt in exe,dll
		{
		if !hInst := DllCall("GetModuleHandle", "Str", file)
			hL := hInst := DllCall("LoadLibrary", "Str", file)
		if idx is not integer
			i := &idx
		else i := idx
		hIL := DllCall("ImageList_LoadImage", "UInt", hInst, "UInt", i, "Int", cx, "Int", 1, "UInt", mask, "UInt", 0, "UInt", 0x2000)
		}
	else if A_LoopFileExt in bmp
		hIL := DllCall("ImageList_LoadImage", "UInt", 0, "Str", file, "Int", cx, "Int", 1, "UInt", mask, "UInt", 0, "UInt", 0x2010)
if (hInst && hL)
	DllCall("FreeLibrary", "UInt", hInst)
return hIL
}

ILC_FitBmp(hPic, hIL, idx="1")
{
Static
WinGetPos,,, W1, H1, ahk_id %hPic%
if (W1 && H1)
	W := W1, H := H1
VarSetCapacity(IMAGEINFO, 32, 0)
DllCall("ImageList_GetImageInfo", "UInt", hIL, "Int", idx-1, "UInt", &IMAGEINFO)
bx := NumGet(IMAGEINFO, 16, "Int")
by := NumGet(IMAGEINFO, 20, "Int")
bw := NumGet(IMAGEINFO, 24, "Int")-bx
bh := NumGet(IMAGEINFO, 28, "Int")-by
;GuiControl,, Static1, Image %idx% @ %bx%.%by% size %bw%x%bh%
hDC := DllCall("CreateCompatibleDC", "UInt", 0)
hBm1 := DllCall("CreateBitmap" , "Int", bw, "Int", bh, "UInt", 1, "UInt", 0x18, "UInt", 0)
hBmp2 := DllCall("CopyImage", "UInt", hBm1, "UInt", 0, "Int", 0, "Int", 0, "UInt", 0x2008, "UInt")	; 0=IMAGE_BITMAP
DllCall("SelectObject", "UInt", hDC, "UInt", hBmp2)
DllCall("ImageList_Draw", "UInt", hIL, "Int", idx-1, "UInt", hDC, "Int", 0, "Int", 0, "UInt", 0x0) ; ILD_NORMAL
DllCall("DeleteObject", "UInt", hBm1)
DllCall("DeleteDC", "UInt", hDC)
hBmp := DllCall("CopyImage", "UInt", hBmp2, "UInt", 0, "Int", W, "Int", H, "UInt", 0x2008, "UInt")	; 0=IMAGE_BITMAP
if hP := DllCall("SendMessage", "UInt", hPic, "UInt", 0x172, "UInt", 0, "UInt", hBmp)	; STM_SETIMAGE, IMAGE_BITMAP
	DllCall("DeleteObject", "UInt", hP)
DllCall("DeleteObject", "UInt", hBmp2)
return hBmp
}

ILC_Destroy(hwnd)
{
return DllCall("ImageList_Destroy", "UInt", hwnd)
}

; LR_CREATEDIBSECTION=0x2000 LR_LOADFROMFILE=0x10 LR_LOADTRANSPARENT=0x20 LR_SHARED=0x8000
; IMAGE_BITMAP=0x0 IMAGE_ICON=0x1 IMAGE_CURSOR=0x2
ILC_Add(hIL, icon, idx="1")
{
Static it="BIC"
StringLeft, t, icon, 1
StringTrimLeft, icon, icon, 1
Loop, Parse, it
	if (A_LoopField=t)
		{
		t := A_Index-1
		break
		}
hInst=0
if icon is integer
	hIcon := icon
else
	{
	Loop, %icon%
		if A_LoopFileExt in exe,dll
			{
			if !hInst := DllCall("GetModuleHandle", "Str", icon)
				hL := hInst := DllCall("LoadLibrary", "Str", icon)
			flags=0x2000
		; need to use MAKEINTRESOURCE here
			if idx is not integer
				i := &idx
			else i := idx
			hIcon := DllCall("LoadImage", "UInt", hInst, "UInt", i, "UInt", t, "Int", 0, "Int", 0, "UInt", flags)
			}
		else if A_LoopFileExt in bmp,ico,cur,ani
			{
			flags=0x2010
			hIcon := DllCall("LoadImage", "UInt", hInst, "Str", icon, "UInt", t, "Int", 0, "Int", 0, "UInt", flags)
			}
		else
			{
			i := idx
			flags=0x8000
			hIcon := DllCall("LoadImage", "UInt", hInst, "UInt", i, "UInt", t, "Int", 0, "Int", 0, "UInt", flags)
			}
	}
if (hInst && hL)
	DllCall("FreeLibrary", "UInt", hInst)
if t=0
	{
	DllCall("ImageList_Add", "UInt", hIL, "UInt", hIcon, "UInt", 0)
	DllCall("DeleteObject", "UInt", hIcon)
	}
if t=1
	{
	DllCall("ImageList_ReplaceIcon", "UInt", hIL, "UInt", -1, "UInt", hIcon)
	DllCall("DestroyIcon", "UInt", hIcon)
	}
if t=2
	{
	DllCall("ImageList_ReplaceIcon", "UInt", hIL, "UInt", -1, "UInt", hIcon)
	DllCall("DestroyCursor", "UInt", hIcon)
	}
}