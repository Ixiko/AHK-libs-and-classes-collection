; #Include GetAvailableFileName.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

;######################## Testing

Eval( GetAvailableFileName( A_ScriptName ))      ; should be error
Eval( GetAvailableFileName( "xyz.ahk" ))         ; ok
Eval( GetAvailableFileName( "xy#z.ahk" ))        ; ok
Eval( GetAvailableFileName( "x#y#z.ahk" ))       ; ok
Eval( GetAvailableFileName( "xy##z.ahk" ))       ; ok
Eval( GetAvailableFileName( "x#.#y##z.ahk" ))    ; ok
Eval( GetAvailableFileName( "####.ahk" ))        ; ok
Eval( GetAvailableFileName( "xy##z.ahk", "C:\" ))              ; ok
Eval( GetAvailableFileName( "xy##z.ahk", "C:\Windows" ))       ; ok
Eval( GetAvailableFileName( "xy##z.ahk", "C:\XYZ0125RET\" ))   ; should be error
Eval( GetAvailableFileName( "xy##z.ahk", "", 5 ))              ; ok
Eval( GetAvailableFileName( "xy##z.ahk", "", 115 ))            ; should be error
Eval( GetAvailableFileName( "xy##z.ahk", "", 33 ))             ; ok
Eval( GetAvailableFileName( "xy##z.ahk", "", 33.3 ))           ; ok
Msgbox, % Eval("")                                             ;%
Return

Eval(FileName)
{
  static MsgTxt
  If FileName = 0
    MsgTxt = %MsgTxt%Error: %ErrorLevel%`n`n
  Else
    MsgTxt = %MsgTxt%%FileName%`n`n
  Return  MsgTxt
}