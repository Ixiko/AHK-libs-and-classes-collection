; *******************************************************************
; AddGraphicButton.ahk
; *******************************************************************
; Version: 1.0 Updated: Jun 21, 2010
; by Kdoske
; http://www.autohotkey.com/forum/viewtopic.php?p=364153#364153
;******************************************************************* 
;GUI_Number: The GUI number
;Button_X: X Position of button - "x10"
;Button_Y: Y Position of button - "y+10"
;Button_H: Height of button - "h50"
;Button_w: Width of button - "W50"
;Button_Identifier: This will be used as the Variable Name, HWND, and Gusubs.
;Button_Variable - %Button_Identifier%
;Button_HWND - %Button_Identifier%_hwnd
;Button_Gosubs: There are two gosubs generated for each button. Gosub Down and Gosub Down_Up. Gosub Down is launched when the image is clicked on the downward stroke. Gosub Down_up is launched only when the image is clicked down and the mouse button is released over the image. (When you want the button to execute code is up to you)
;Image Gosub down = %Button_Identifier%_Down
;Image Gosub down_up = %Button_Identifier%_Down_up 
;Button_Up: Image location of button in up state
;Button_Hover: Image location of button in hover state
;Button_Down: Image location of button in Downstate
; ******************************************************************* 

AddGraphicButton(GUI_Number, Button_X, Button_Y, Button_H, Button_W, Button_Identifier, Button_Up, Button_Hover, Button_Down) {
	Global
	if(Graphic_Button_List = "")
		Graphic_Button_List .= Button_Identifier
	else
		Graphic_Button_List .= "|" . Button_Identifier
	current_Button_HWND := Button_Identifier . "_hwnd"
	%Button_Identifier%_Up_Image := Button_Up
	%Button_Identifier%_Hover_Image := Button_Hover
	%Button_Identifier%_Down_Image := Button_Down
	%Button_Identifier%_GUI_Number := GUI_Number	
	Gui, %GUI_Number%:Add, Picture, +altsubmit %Button_X% %Button_Y% %Button_H% %Button_W% g%Button_Identifier%_Down v%Button_Identifier% hwnd%current_Button_HWND%, %Button_Up%
}

MouseMove(wParam, lParam, msg, hwnd) { 
	Global
	local Current_Hover_Image
	local Current_Main_Image
	local Current_GUI
	loop, parse, Graphic_Button_List, |
	{
		Current_GUI := %a_loopField%_GUI_Number
		If (hwnd = %a_loopField%_HWND) and (%a_loopField%LastButtonData1 != %a_loopField%_HWND)
		{
			Current_Hover_Image := %a_loopField%_Hover_Image
			guicontrol, %Current_GUI%:, %a_loopField%, %Current_Hover_Image%
			%a_loopField%LastButtonData1 := hwnd
		}
		else if(hwnd != %a_loopField%_HWND) and (%a_loopField%LastButtonData1 = %a_loopField%_HWND)
		{
			Current_Up_Image := %a_loopField%_Up_Image
			guicontrol, %Current_GUI%:, %a_loopField%, %Current_Up_Image%
			%a_loopField%LastButtonData1 := hwnd
			%a_loopField%LastButtonData2 =
		}
	}
	Return 
} 

MouseLDown(wParam, lParam, msg, hwnd) {
	Global
	Local Current_Down_Image
	Local Current_GUI
	loop, parse, Graphic_Button_List, |
	{
		If (hwnd = %a_loopField%_HWND) and (%a_loopField%LastButtonData2 != %a_loopField%_HWND)
		{
			Current_GUI := %a_loopField%_GUI_Number
			Current_Down_Image := %a_loopField%_Down_Image
			guicontrol, %Current_GUI%:, %a_loopField%, %Current_Down_Image%
			%a_loopField%LastButtonData2 := hwnd
			break
		}
	}
	Return 
}

MouseLUp(wParam, lParam, msg, hwnd) { 
	Global
	local Current_Main_Image
	Local Current_GUI
	loop, parse, Graphic_Button_List, |
	{
		If (hwnd = %a_loopField%_HWND) and (%a_loopField%LastButtonData2 = %a_loopField%_HWND)
		{
			Current_GUI := %a_loopField%_GUI_Number
			Current_Hover_Image := %a_loopField%_Hover_Image
			guicontrol, %Current_GUI%:, %a_loopField%, %Current_Hover_Image%
			%a_loopField%LastButtonData2 =
			GOSUB % a_loopField . "_Down_Up"
			break
		}
	}
	Return
}