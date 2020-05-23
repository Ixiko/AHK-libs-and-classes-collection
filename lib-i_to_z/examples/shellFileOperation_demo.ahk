; #Include ShellFileOperation.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

ShellFileOperation( 0x2, A_AhkPath, A_DeskTop )                     ; Copy a Single file
ShellFileOperation( 0x2, "C:\Program Files\AutoHotkey", A_DeskTop ) ; Copy the whole folder
