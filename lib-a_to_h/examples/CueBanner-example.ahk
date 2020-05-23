;================================================================
; EXAMPLE CUE BANNER
#NoEnv
#SingleInstance, force
SetBatchLines, -1
SetControlDelay, -1
SetWinDelay, -1
ListLines, Off
SetFormat, Integer, D
DetectHiddenWindows, On
#include %A_ScriptDir%		; drag'n'drop on AHK icon doesn't work without this!
#include updates.ahk		; better put this in the global Lib folder, all my scripts need it
updates()
;================================================================
appname=Cue Banners
version=2.6.1
;================================================================
GetFullSysVer(OSname, OSver, Kver)
ahkT := FileGetVersionInfo(A_AhkPath, "FileDescription")
ahkV := FileGetVersionInfo(A_AhkPath, "FileVersion")
StringReplace, ahkV, ahkV, %A_Space%,, All	; required in AHK Basic for consistency
StringReplace, ahkV, ahkV, `,, ., All			; with later AHK versions
VarSetCapacity(DVI, 20, 0), NumPut(20, DVI, 0, "UInt"), DllCall("comctl32\DllGetVersion", Ptr, &DVI)
ccv := NumGet(DVI, 4, "UInt") "." NumGet(DVI, 8, "UInt") "." NumGet(DVI, 12, "UInt")	; file version 
ccv .= NumGet(DVI, 16, "UInt")=1 ? " ANSI" : " Unicode"	; file encoding type (ANSI/Unicode)
VarSetCapacity(DVI, 0)
;================================================================
cTver = %OSname% v%OSver%`n%ahkT% v%ahkV%`ncomctl32 v%ccv%
cT0 := "original cue banner [EM_SETCUEBANNER]"
cT00 := "original cue banner [CB_SETCUEBANNER]"
cT1 := "şţâăî right-aligned simulated cue banner"
cT2 := "white centered cue text with blurred shadow"
cT3 := "this is DropDownList, bold, no shadow`t`tand expanded tabs that go beyond"
cT4 := "pay attention to this persistent pink cue!"
;cT5 := "blue centered cue for ComboBox"
;cT6 := "אדופמסרױױכןפקשرشطقو۳۸ﮎﮐﮕ"
cT5 := "ความพยายามอยู่�ี่ไหน ความสำเร็จอยู่�ี่นั่น"
cT6 := "உலகம் பேச நினைக்கும் போது Unicode பேசுகிறது"
cT7 := "normal"
cT8 := "pale shadow"
cT9 := "E0x1000"
cT10 := "no focus"

Menu, Tray, Tip, %appname% %version%
Gui, Font, s8, Tahoma
Gui Margin, 2, 2
Gui, Add, Edit, x5 y18 w450 h21 hwndhEdit0,
Gui, Add, ComboBox, wp h21 R5 hwndhCombo0, combo1|combo2|combo3|combo4
Gui, Add, Edit, wp h21 hwndhEdit1,
Gui, Font, s12 Italic, Tahoma
Gui, Add, Edit, wp h25 hwndhEdit2,
Gui, Font, Norm s8 Bold, Tahoma
Gui, Add, DDL, wp h21 R5 E0x402000 hwndhDDL1, |item1|item2|item3|item4
Gui, Font, Norm s8, Tahoma
Gui, Add, Edit, wp h21 hwndhEdit3,
Gui, Font, s12, Tahoma
Gui, Font, s12, Segoe UI
Gui, Font, s12, Arial Unicode MS
; With E0x400000 style in ComboBox, shadow is broken (at least in XP)
;Gui, Add, ComboBox, wp h21 R5 E0x402000 hwndhCombo1, combo1|combo2|combo3|combo4	
Gui, Add, ComboBox, wp h21 R5 E0x2000 hwndhCombo1, combo1|combo2|combo3|combo4
Gui, Font, s8, Tahoma
Gui, Add, Checkbox, w100 h16 hwndhChk1,
Gui, Add, Checkbox, x+5 yp w100 h16 E0x1000 hwndhChk2,
Gui, Add, Radio, x5 w100 h16 hwndhRadio1,
Gui, Add, Radio, x+5 yp w100 h16 E0x1000 hwndhRadio2,
Gui, Add, GroupBox, x2 y2 w456 h230, Cue banner examples
Gui, Add, Button, w80 h38 Default hwndhBtn,
Gui, Font, s7, Tahoma
Gui, Add, Text, x+5 yp w360 hp Center hwndhVer gtt, `nClick me�
Gui, Font, s8, Tahoma

if !A_IsUnicode
	{
	CueBanner_A2U(&cT0, Out1), pcT0 := &Out1
	}
else pcT0 := &cT0
if !A_IsUnicode
	{
	CueBanner_A2U(&cT00, Out2), pcT00 := &Out2
	}
else pcT00 := &cT00
SendMessage, 0x1501, 1, %pcT0%,, ahk_id %hEdit0%		; EM_SETCUEBANNER
SendMessage, 0x1703, 0, %pcT00%,, ahk_id %hCombo0%	; CB_SETCUEBANNER

CueBanner(hEdit1		, &cT1	, "ru")
CueBanner(hEdit2		, &cT2	, "sc"	, 0xFFFFFF	, "0xFF4040|3|2")
CueBanner(hDDL1		, &cT3	, ""		, 0x0000FF)
CueBanner(hEdit3		, &cT4	, "ps"	, 0xFF01FF)
CueBanner(hCombo1	, &cT5	, "cu"	, 0xFF0000)
CueBanner(hVer		, &cTver	, "pscm"	, 0x00F0F0	, 0x808080)
CueBanner(hChk1		, &cT7	, "ps"	, 0x3001FF)
CueBanner(hRadio1	, &cT8	, "ps"	, 0x3001FF	, "|||192")
CueBanner(hChk2		, &cT9	, "psr"	, 0xFFFF20	, "|||128")
CueBanner(hRadio2	, &cT9	, "psr"	, 0xFFFF20	, "|||64")
CueBanner(hBtn		, &cT10	, "psc"	, 0x101010)

Gui, Show,, %appname% %version%
OnExit, cleanup
sleep, 6000
CueBanner(hCombo1	, &cT6	, "psaru"	, 0x777700	, 0x999999)
;SetTimer, tt, 3500
return
;================================================================
cleanup:
CueBanner(0)
SendMessage, 0x1501, 0, 0,, ahk_id %hEdit0%
SendMessage, 0x1703, 0, 0,, ahk_id %hCombo0%
GuiClose:
ExitApp
;================================================================
tt:
isT := !isT
GuiControl,, Static1, % isT ? cTver : ""
if !isT
	WinSet, Redraw,, ahk_id %hVer%
return
;================================================================
#include func_CueBanner 2.6.1.ahk
#include extra
#include func_GetFileVersionInfo 1.4.ahk
#include func_GetFullSysVer.ahk
