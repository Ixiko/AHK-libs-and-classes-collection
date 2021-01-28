/*
ScriptMem - Reduce Memory consumption of your AHK Script
by Avi Aryan

Thanks --
HERESY - for EmptyMem function
just me - for GetScriptPID fucntion

Works with all AHK

USING ------
Recommended to use at the end of Auto-Execute section.
AND
only at frequent intervals

WHY ??
Any process tends to assume higher memory consumption than it actually needs.
So, after end of Auto-execute you are likely to have max. extra memory for the script
process.
*/


ScriptMem()
{
static PID
IfEqual,PID
{
DHW := A_DetectHiddenWindows
TMM := A_TitleMatchMode
DetectHiddenWindows, On
SetTitleMatchMode, 2
WinGet, PID, PID, \%a_ScriptName% - ahk_class AutoHotkey
DetectHiddenWindows, %DHW%
SetTitleMatchMode, %TMM%
}
h:=DllCall("OpenProcess", "UInt", 0x001F0FFF, "Int", 0, "Int", pid)
DllCall("SetProcessWorkingSetSize", "UInt", h, "Int", -1, "Int", -1)
DllCall("CloseHandle", "Int", h)
}