; #Include md5.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

MsgBox,, MD5_File(), % A_AhkPath . ":`n`n" . MD5_File( A_AhkPath )

V := "The quick brown fox jumps over the lazy dog"
L := StrLen(V)
MsgBox,, MD5(), % V . ":`n`n" . MD5( V,L )