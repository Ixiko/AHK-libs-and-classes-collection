; GLOBAL SETTINGS ===============================================================================================================

#NoEnv
#SingleInstance Force
#Persistent

SetBatchLines -1

; SCRIPT ========================================================================================================================

; Win + Numpad Add (+)    ->  Set Brightness incremental by 1
#NumpadAdd::
    CLR := Monitor.GetBrightness()
    Monitor.SetBrightness(CLR.Red + 1, CLR.Green + 1, CLR.Blue + 1)
return


; Win + Numpad Sub (-)    ->  Set Brightness decremental by 1
#NumpadSub::
    CLR := Monitor.GetBrightness()
    Monitor.SetBrightness(CLR.Red - 1, CLR.Green - 1, CLR.Blue - 1)
return


; Win + Numpad Mult (*)   ->  Set Brightness to default (128)
#NumpadMult::
    Monitor.SetBrightness(128, 128, 128)
return


; Win + Numpad Div (/)    -> Get Brightness
#NumpadDiv::
    GetBrightness := Monitor.GetBrightness()
    MsgBox % "Red:`t" GetBrightness.Red "`nGreen:`t" GetBrightness.Green "`nBlue:`t" GetBrightness.Blue
return


; INCLUDES ======================================================================================================================

#Include Class_Monitor.ahk

; ===============================================================================================================================