; #Include DamerauLevenshteinDistance.ahk
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


tests =
( LTrim
   AHK,ahk
   He,ben
   this,tihs
   Toralf,Titan
   google,goggle
)
Loop, Parse, tests, `n
{
   StringSplit, w, A_LoopField, `,
   l .= """" . w1 . """   =>   """ . w2 . """   " . DamerauLevenshteinDistance(w1, w2) . "`n"
}
MsgBox, %l%