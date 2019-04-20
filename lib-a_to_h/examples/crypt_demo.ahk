; #Include Crypt.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

V := "The quick brown fox jumps over the lazy dog"
L := StrLen(V)
MsgBox,, MD5 with Crypt_Hash(), % V . ":`n`n" . Crypt_Hash(&V, L, "MD5") ; Notice, &V instead of just V