; #Include difference.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

MsgBox % Difference( "A H K", "A H Kn" )       ;0.083333
MsgBox % Difference( "A H K", "A H K" )        ;0.000000
MsgBox % Difference( "A H K", "A h K" )        ;0.040000
MsgBox % Difference( "AHK", "" )               ;1.000000
MsgBox % Difference( "He", "Ben" )             ;0.500000
MsgBox % Difference( "Toralf", "ToRalf" )      ;0.033333
MsgBox % Difference( "Toralf", "esromneb" )    ;0.750000
MsgBox % Difference( "Toralf", "RalfLaDuce" )  ;0.420000
