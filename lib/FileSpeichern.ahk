; This script was created using Pulover's Macro Creator
; www.macrocreator.com

#NoEnv
SetWorkingDir %A_ScriptDir%
CoordMode, Mouse, Window
SendMode Input
#SingleInstance Force
SetTitleMatchMode 2
#WinActivateForce
SetControlDelay 1
SetWinDelay 0
SetKeyDelay -1
SetMouseDelay -1
SetBatchLines -1


F3::
Macro1:
WinGetText, Fenstertitel, ahk_class Progman ahk_exe Explorer.EXE ahk_id 0x101e0 ahk_pid 8308
FileAppend, AAA, D:\Eigene Dateien\Eigene Dokumente\AutoIt Scripte\AlbisCounter.dat
Return

