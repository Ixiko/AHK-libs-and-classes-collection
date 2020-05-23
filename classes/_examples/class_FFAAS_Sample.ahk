#SingleInstance force
#NoEnv
SetBatchLines -1
SetControlDelay, -1
SetWinDelay, -1

#Include %A_ScriptDir%\..\class_FFAAS.ahk ; ScriptDir
; #Include <FFAAS>   ; Library



Gui 1: +Resize +hwndGUI1
gui 1: add, button, gFFAAS_ENABLE,Enable
gui 1: add, button, gFFAAS_DISABLE x+10,Disbale
Gui 1:Add, Edit, y+10 xm  r5 vEditText  -WantReturn hwndjjjj
Gui 1:Add, Tab2, xm r20  vTAB hwndh_TAB, General|Preview|Source|SETTINGS
Gui 1:Add, ListView, x+2 y+2 r20  altsubmit  hwndLVX vMyListView  Grid +LV0x10000 +LV0x2 +LV0x40 Count10000 , #|Layer|Start|(*)
Gui, 1:Add, StatusBar, hwndStatusBar x333, StatusBar - Resize window by top border or them corner (bestly left up corner) and look how everythink shake `;p. Is in any window, not only AHK
l := "3B|2F|3F|3A|40|26|3D|2B|24|2C|23"
Loop, parse, l, |
{
var := "0x" A_LoopField
	LV_Add("", Chr(var), var)
}
loop 700
LV_Add("", Chr(A_Index-1), A_Index-1)
gui, 1:show, w600 x0, FFAAS - Flicker Free & Anti Shake by smarq

GuiSize:
if A_EventInfo = 1
    return

	GuiControl, Move, tab,	% "W" . (A_GuiWidth-22) . "H" . (A_GuiHeight-222)
	GuiControl, Move, MyListView,	% "W" . (A_GuiWidth-32) . "H" . (A_GuiHeight-252)
	GuiControl, Move, EditText, % "W" A_GuiWidth/2-30
return


f3::reload

FFAAS_ENABLE:
FFAAS.Enable()
return

FFAAS_DISABLE:
FFAAS.Enable(0)
return
