; #Include PixPut.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

; Example by SKAN, copied from his first posting at discussion page.
#SingleInstance, Force
SetBatchLines -1
Gui +LastFound -Caption
Gui1 := WinExist()
Gui, Show, w640 h480

PixPut( Gui1, 0xFF0000, 0, 0, 640, 2 )   ; Frame Top
PixPut( Gui1, 0xFF0000, 0, 0, 2, 480 )   ; Frame Left
PixPut( Gui1, 0xAA0000, 638, 0, 2, 480 ) ; Frame Right
PixPut( Gui1, 0xAA0000, 0, 478, 640, 2 ) ; Frame Bottom

; Create Vertical Lines
Loop 309
   BGR := DllCall( "shlwapi.dll\ColorHLSToRGB", Int,A_Index, Int,120, Int,240 )
 , RGB := ( BGR & 0xFF ) << 16 | (( BGR >> 8) & 0xFF ) | ( BGR >> 16 )
 , PixPut( Gui1, BGR, 10+(A_Index*2), 10, 2, 25 )

; Create Solid Blocks
PixPut( Gui1, 0xFF0000, 100, 100, 200, 200 ) ; R
PixPut( Gui1, 0x00FF00, 150, 150, 200, 200 ) ; G
PixPut( Gui1, 0x0000FF, 200, 200, 200, 200 ) ; B

; Create Horizontal Lines
PixPut( Gui1, 0xFF00FF, 10, 461, 620, 1 )    ; C
PixPut( Gui1, 0xFFFF00, 10, 462, 620, 1 )    ; Y
PixPut( Gui1, 0x00FFFF, 10, 463, 620, 1 )    ; M
PixPut( Gui1, 0x000000, 10, 464, 620, 1 )    ; K
Return

GuiEscape:
ExitApp