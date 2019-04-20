; #Include QPX.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
SetBatchLines -1

;;** Basic Usage **
QPX( True )         ; Initialise Counter
Sleep 1000
Ti := QPX( False )  ; Retrieve Time consumed ( & reset internal vars )

MsgBox, 0, Sleep 1000, %Ti% seconds

;;** Extended Usage **
While QPX( 1000 )   ; Loops 1000 times and keeps internal track of the total time
 Tooltip %A_Index%
Ti := QPX()      ; Retrieve Avg time consumed per iteration ( & reset internal vars )

MsgBox, 0, Avg Time Taken for ToolTip, %Ti% Seconds / Iteration