; #Include Affinity.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

Process, Exist, calc.exe
PID := errorLevel
Affinity_Set( 3, PID ) ; presuming Affinity.ahk is available in User Library