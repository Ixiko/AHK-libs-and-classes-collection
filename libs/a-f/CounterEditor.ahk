; LintaList [standalone script]
; Purpose: Counters variable Editor [see Lintalist doc]
; Version: 1.0.3
; Date:    20140426

#NoTrayIcon
#SingleInstance, force
SetTitleMatchMode, 2
Menu, Tray, Icon, %A_ScriptDir%\..\icons\lintalist.ico 

ini=%1%

OnExit, 20GuiClose 
EditorTitle=Lintalist counters editor
Save=0

IfWinExist, Lintalist ahk_class AutoHotkeyGUI
	WinGet, LintalistHwnd, ID, Lintalist ahk_class AutoHotkeyGUI

	 IniRead, Counters, %ini%, settings, Counters, 0	
	 If (Counters <> 0)
	 	{
	 	 Loop, parse, counters, |
	 	 	{
	 	 	 If (A_LoopField = "")
	 	 	 	Continue
	 	 	 StringSplit, _ctemp, A_LoopField, `,
	 	 	 LocalCounter_%_ctemp1% := _ctemp2
	 	 	 LocalCounter_0 .= _ctemp1 ","
	 	 	 _ctemp1=
	 	 	 _ctemp2=
	 	 	}
	 	 StringTrimRight,LocalCounter_0,LocalCounter_0,1
	 	}

;Gui, 20: +Toolwindow
If LintalistHwnd
	Gui, 20: +0x40000000 -0x80000000 +Owner%LintalistHwnd%
Gui, 20: Add, Text, x10  y10 , Counter (double Click to edit)

Gui, 20: Add, Listview, h300 w377 x10 y30 gCheck Grid, Name|Value
Gui, 20:Default
Loop, parse, LocalCounter_0, CSV
	{
	 If (A_LoopField = "")
	 	Continue
	 LV_Add("", A_LoopField, LocalCounter_%A_LoopField%)
	}
LV_ModifyCol(1,200)
LV_ModifyCol(2,100)
Gui, 20: Add, Button,  x10   w65 h25 g20Scan, Scan
Gui, 20: Add, Button,  xp+78 w65 h25 g20New, New
Gui, 20: Add, Button,  xp+78 w65 h25 g20Del, Del
Gui, 20: Add, Button,  xp+78 w65 h25 g20Save, Save
Gui, 20: Add, Button,  xp+78 yp w65 h25 g20GuiClose, Cancel
Gui, 20: Show, autosize center, %EditorTitle%
Save=0
Return

#IfWinActive, Lintalist counters editor
Down::

Return

Up::

Return
#IfWinActive

Check: 
Gui, 20:submit, nohide
SelItem := LV_GetNext()
If (SelItem =0)
	Return
LV_GetText(VarName, SelItem, 1)
LV_GetText(VarValue, SelItem, 2)
Gosub, GetNewCounter
LV_Modify(SelItem, "", VarName, VarValue)
VarName=
VarValue=
Save=1
Return

20Del:
Gui, 20:submit, nohide
SelItem := LV_GetNext()
LV_GetText(VarName, SelItem, 1)
LV_GetText(VarValue, SelItem, 2)
MsgBox, 4, Delete, Do you want to delete %VarName%?
IfMsgbox, Yes
	{
	 LV_Delete(SelItem)
	 DeletedItems .= VarName ","
	}
Save=1	
Return

20New:
Gosub, GetNewCounter
If (VarName <> "") and (VarValue <> "")
	LV_Add("", VarName, VarValue)
VarName=
VarValue=
Save=1
Return

20Save:
Counters=
Loop
	{
	 LV_GetText(VarName, A_Index, 1)
	 LV_GetText(VarValue, A_Index, 2)
	 If (VarName = "") and (VarValue = "")
	 	break
 	 Counters .= VarName "," VarValue "|"
	}
iniwrite, %Counters%, %ini%, Settings, Counters
Save=0
ExitApp
Return

Esc::
20GuiEscape:
20GuiClose:
If (Save = 1)
	{
	 MsgBox, 4, Save?, Do you want to save your changes?
	 IfMsgBox, Yes
		Gosub, 20Save
	 Else
		{
		 Save=0
		 ExitApp
		} 
	}	
Else 
	ExitApp	
Return

20Scan:
Progress, b1 w300 CWFFFFFF CB000080, , Scanning for new Counters, Scanning
Progress, 5 ; Set the position of the bar to 5%.
BundleFiles=
NewScannedVars=
ScannedVarList=
Loop, %A_ScriptDir%\..\bundles\*.txt
	{
	 Counter:=A_Index
	 BundleFiles .= A_LoopFileLongPath . ","
	}
StringTrimRight, BundleFiles, BundleFiles, 1 ; trim trailing
Progress, 10
Loop, parse, BundleFiles, CSV
	{
	 If (A_LoopField = "")
	 	Continue
	 File=
	 PBar:=Floor((a_index/counter)*90)
	 Progress, %PBar%
	 FileRead, File, %A_LoopField%
	 StringReplace, File, File, [[, `n[[, All
	 StringReplace, File, File, ]], ]]`n, All
	 Loop, parse, file, `n, `r
		{
		 IfInString, A_LoopField, [[Counter=
			ScannedVarList .= StrSplit(A_LoopField,"|").1 "`n"
		}
	}
StringReplace, ScannedVarList, ScannedVarList, [[Counter=,,all
StringReplace, ScannedVarList, ScannedVarList, ]],,all
Sort, ScannedVarList, U
Progress, Off

Loop, parse, ScannedVarList, `n, `r%A_Space%%A_Tab%
	{
	 If (A_LoopField = "")
	 	Continue
	 If (InStr(A_LoopField,"|"))
	 	_ctempcheck:=SubStr(A_LoopField,1,InStr(A_LoopField,"|")-1)
	 Else
		_ctempcheck:=A_LoopField	
	 If _ctempcheck in %LocalCounter_0%
		Continue
	 NewScannedVars .= 	A_LoopField . "`n"
	}
StringTrimRight, NewScannedVars, NewScannedVars, 1	
Progress, 100
Progress, Off

If (NewScannedVars = "")
	{
	 MsgBox, 48, Nothing found, No new counter variables where found in your bundles.
	 Return
	}
MsgBox,4,Found new counter variables, % "Do you want to add these new counters?`n`n"NewScannedVars
IfMsgBox, Yes
	{
	 Loop, parse, NewScannedVars, `n
		{
		 If (A_LoopField = "")
			Continue
		 LV_Add("", A_LoopField, 1)
		 ScannedVarList .= "`n" A_LoopField
		} 
	 Save=1
	}

Return

GetNewCounter:
InputBox, VarName, Name, Name of the counter, , 400, 150, , , , , %VarName%
if ErrorLevel or (VarName = "")
	{
	 MsgBox, You either cancelled or entered an empty name
	 Return
	} 
CheckEnterValue:  
InputBox, VarValue, Value, Value of counter, , 400, 150, , , , , %VarValue%
if ErrorLevel or (VarValue = "")
	{
	 MsgBox, You either cancelled or entered an empty value
	 Return
	} 
If VarValue is not number
	{
	 MsgBox, Numeric value only please
	 Gosub, CheckEnterValue
	}
Return	