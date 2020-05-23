;***************************************************************************************************
;***************************************************************************************************
#Include %A_ScriptDir%\..\..\lib-a_to_h\GDIP_All.ahk
;***************************************************************************************************
;***************************************************************************************************
#Include %A_ScriptDir%\..\class_LayeredWindow.ahk
;***************************************************************************************************
;***************************************************************************************************
#SingleInstance, Force
SetBatchLines, -1
#NoEnv
CoordMode, Mouse, Screen
LineDrawWindow := New LayeredWindow( 0 , 0 , A_ScreenWidth , A_ScreenHeight , 1 , " " , 2 , "+AlwaysOnTop +ToolWindow -DPIScale +E0x20" , 1 , 1 )
Pen := Gdip_CreatePen("0xFFFF0000", 2)
SetTimer, DrawLine, 10
return

DrawLine:
	MouseGetPos, tx, ty
	LineDrawWindow.ClearWindow()
	Gdip_DrawLine( LineDrawWindow.G , Pen , A_ScreenWidth/2 , A_ScreenHeight/2 , tx , ty )
	LineDrawWindow.UpdateWindow()
	return

*ESC::ExitApp