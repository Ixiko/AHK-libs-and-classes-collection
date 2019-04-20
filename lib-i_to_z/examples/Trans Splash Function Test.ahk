
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
#SingleInstance, Force
#Include %A_ScriptDir%\..\TransSplashText.ahk

Gui, Add, GroupBox, x5 y5 w390 h40, Text to Display
Gui, Add, Edit, x10 y20 w380 r1 vText, Transparent Splash Text

Gui, Add, GroupBox, x5 y50 w100 h40, Font
Gui, Add, Edit, x10 y65 w90 r1 vFont, Impact

Gui, Add, GroupBox, x110 y50 w100 h40 , Text Color
Gui, Add, Edit, x115 y65 w90 r1 vFontColor, White

Gui, Add, GroupBox, x215 y50 w100 h40 , Shadow Color
Gui, Add, Edit, x220 y65 w90 r1 vShadowColor, 828284

Gui, Add, GroupBox, x320 y50 w75 h40 , Font Size
Gui, Add, Edit, x325 y65 w65 r1 vFontSize, 35

Gui, Add, GroupBox, x5 y95 w60 h40 , X Position
Gui, Add, Edit, x10 y110 w50 r1 vxPos, Center

Gui, Add, GroupBox, x70 y95 w60 h40 , Y Position
Gui, Add, Edit, x75 y110 w50 r1 vyPos, 10

Gui, Add, GroupBox, x135 y95 w100 h40 , Time Out in MS
Gui, Add, Edit, x140 y110 w90 r1 vTimeOut, 10000

Gui, Add, GroupBox, x240 y95 w75 h40 ,
Gui, Add, Button, x245 y111 w65 h20 gShow, Show Text

Gui, Add, GroupBox, x320 y95 w75 h40 ,
Gui, Add, Button, x325 y111 w65 h20 gHide, Hide Text

Gui, Add, GroupBox, x5 y140 w390 h205 , Notes
Gui, Add, Text, x10 y155, ShadowColor, 0 = No Shadow
Gui, Add, Text, x10 y+5 w380, TimeOut, 0 = Text stays on screen until TransSplashText_Off() is called.
Gui, Add, Text, x10 y+10, Text - defaults to "TransSplashText".
Gui, Add, Text, x10 y+5, Font - defaults to "Impact".
Gui, Add, Text, x10 y+5, TC (Text Color) - defaults to "White".
Gui, Add, Text, x10 y+5, SC (Shadow Color) - defaults to "828284".
Gui, Add, Text, x10 y+5, TS (Text Size) - defaults to "20".
Gui, Add, Text, x10 y+5, xPos - defaults to "Center".
Gui, Add, Text, x10 y+5, yPos - defaults to "Center".
Gui, Add, Text, x10 y+5, TimeOut - defaults to "0" or no timeout.

Gui, Show, w400 h350, Test
Return

Show:
Gui, Submit, NoHide
;TransSplashText_On()
TransSplashText_On(Text,Font,FontColor,ShadowColor,FontSize,xPos,yPos,TimeOut)
;TransSplashText_On(Text,"","","Red","","","","")
Return

Hide:
TransSplashText_Off()
Return

Esc::
Exit:
GuiClose:
Gui, Destroy
ExitApp

