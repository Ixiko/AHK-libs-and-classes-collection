/*
AutoHotkey Version: 1.1.14.01
Language:   English
Platform:   Windows XP
Author:     JPV alias Oldman <myemail@nowhere.com>

Script Function:
				Test GetExternalHeaderText


1 - Open Explorer and select AutoHotkey directory.
2 - Open AutoHotkey Help.
3 - Launch the test.
*/

#SingleInstance ignore
#NoEnv            ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input    ; Recommended for new scripts due to its superior speed and reliability.
SetBatchLines, -1
SetFormat, IntegerFast, D
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

DetectHiddenWindows On
	
;--------
; Test 1
;--------
WinTitle1 = AutoHotkey ahk_class CabinetWClass

Arr_ClassNN1 := GetExternalHeaderClassNN(WinTitle1)

if !Arr_ClassNN1.MaxIndex()
{
	MsgBox, % "No header control found in " WinTitle1
	return
}

for key, aClassNN in Arr_ClassNN1
{
	if !Arr_Headers1 := GetExternalHeaderText(WinTitle1, aClassNN)
		return
	
	HeaderLine1 := ""
	for key, item in Arr_Headers1
		HeaderLine1 .= (A_Index = 1 ? "" : "|") A_Index "|" item
	
	Msgbox, % aClassNN " - " HeaderLine1
}

;--------
; Test 2
;--------
WinTitle2 = AutoHotkey Help ahk_class HH Parent

Arr_ClassNN2 := GetExternalHeaderClassNN(WinTitle2)

if !Arr_ClassNN2.MaxIndex()
{
	MsgBox, % "No header control found in " WinTitle2
	return
}

for key, aClassNN in Arr_ClassNN2
{
	if !Arr_Headers2 := GetExternalHeaderText(WinTitle2, aClassNN)
		return

	HeaderLine2 := ""
	for key, item in Arr_Headers2
		HeaderLine2 .= (A_Index = 1 ? "" : "|") A_Index "|" item
	
	Msgbox, % aClassNN " - " HeaderLine2
}

return

#Include %A_ScriptDir%\..\lib-a_to_i\ExternalHeaderLib.ahk
