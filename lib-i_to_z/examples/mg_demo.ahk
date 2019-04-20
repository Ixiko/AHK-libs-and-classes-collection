; #Include mg.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

MsgBox Hold right mouse button and make movements up to four different directions and release that button. If a gesture was recognized, it should show it code.`n`nThe middle mouse button calls predefined functions.

; Example 1: store gesture in variable and show it in MsgBox if it isn't blank or zero.

RButton::
Gesture := MG_Recognize()
if Gesture
MsgBox,,, %Gesture%, 1
Return

; Example 2: execute existing MG function

MButton::MG_Recognize()

MG_R()   {
MsgBox,,, %A_ThisFunc%, 1
}

MG_RD()   {
MsgBox,,, %A_ThisFunc%, 1
}

MG_RDL()   {
MsgBox,,, %A_ThisFunc%, 1
}

