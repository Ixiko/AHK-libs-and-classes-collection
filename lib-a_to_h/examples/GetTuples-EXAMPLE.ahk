ListLines, Off
#NoEnv
SetBatchLines, -1

#Include GetTuples.ahk

CHARS := ".A.B..C."
PICK := 3
VAR = MsgBox, `% GetTuples(   "%CHARS%"   ,   %PICK%   ,   ""   ,   "``t  ."   ,   "-"   ,   "||"   ,   true )
VAR .= "`n---------------`n"
VAR .= GetTuples(  CHARS  ,  PICK  ,  ""  ,  "`t  ."  ,  "-"  ,  "||"  ,  true )
MSGBOX, % "Example 1 of 4`n---------------`n" VAR

CHARS := "abcdef"
PICK := 2
VAR = MsgBox, `% GetTuples(   "%CHARS%"   ,   %PICK%   ,   ""   ,   ""   ,   ""   ,   "_"   )
VAR .= "`n---------------`n"
VAR .= GetTuples(  CHARS  ,  PICK  ,  ""  ,  ""  ,  ""  ,  "_"  )
MSGBOX, % "Example 2 of 4`n---------------`n" VAR

CHARS := "a_B &  c*A&3_ G "
PICK := 2
VAR = MsgBox, `% GetTuples(   "%CHARS%"   ,   %PICK%   ,   "*_&"   ,   " "   ,   ".."   ,   "="   )
VAR .= "`n---------------`n"
VAR .= GetTuples(  CHARS  ,  PICK  ,  "*_&"  ,  " "  ,  ".."  ,  "="  )
MSGBOX, % "Example 3 of 4`n---------------`n" VAR

CHARS := "123154"
PICK := 2
VAR = MsgBox, `% GetTuples(   "%CHARS%"   ,   %PICK%   ,   ""   ,   ""   ,   ""   ,   "``t"   )
VAR .= "`n---------------`n"
VAR .= GetTuples(  CHARS  ,  PICK  ,  ""  ,  ""  ,  ""  ,  "`t"  )
MSGBOX, % "Example 4 of 4`n---------------`n" VAR