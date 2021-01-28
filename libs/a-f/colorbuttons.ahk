; Link:   	
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

; Color Buttons - Flat buttons with any text and background color.
;
; ColorButtons(x,by,ty,w,h,bv,tv,g,bc,tc,text)
; 
; x = Control's x position.  Both the text and background will share this coordinate.
; by = The background's y position.  Used only by the background.
; ty = The Text's y position.  Used to center text on the background.
; w = Control's width. Used by both background and text.
; H = Background's height.  Text height is set with Gui, Font, Size
; bv = Background's variable.
; tv = Text's variable.
; g = Control's glable. Used by both background and text.
; bc = Background Color.  Must be a hexadecimal including the 0x prefix.
; tc = Text Color.  Overrides color set by Gui, Font, Color
; text = Text button will display.
; 
; Tip, to see where the entire text box is in relation to the background insert "Border" in the text options below. 


ColorButtons(x,by,ty,w,h,bv,tv,g,bc,tc,text)
	{
	Global
	Gui, Add, Pic, x%x% y%by% w%w% h%h% +0x40 v%bv% g%g%, % "HBITMAP:" . CreateUniDIB(bc) ; 
	Gui, Add, Text, x%x% y%ty% w%w% c%tc% Center BackgroundTrans v%tv% g%g%, %text%
	Return 
	}

;=================================================================================================
; Modified version of a function by SKAN, 01-Apr-2014, autohotkey.com/boards/viewtopic.php?t=3203
; Creates an uni-colored bitmap of 1 * 1 pixels.
;=================================================================================================
CreateUniDIB(Color) 
	{
   VarSetCapacity(BMBITS, 4, 0)
   , Numput(Color, BMBITS, "UInt")
   , HBM := DllCall("CreateBitmap", "Int", 1, "Int", 1, "UInt", 1, "UInt", 24, "Ptr", 0, "UPtr")
   , HBM := DllCall("CopyImage", "Ptr", HBM, "UInt", 0, "Int", 0, "Int", 0, "UInt", 0x2008, "UPtr")
   , DllCall("SetBitmapBits", "Ptr", HBM, "UInt", 4, "Ptr", &BMBITS)
   Return HBM
	}

/* 
Example Script

Gui, Font, s12 cWhite, Tahoma 
#Include, ColorButtons.ahk

;ColorButtons(x,by,ty,w,h,bv,tv,g,bc,tc,text)
ColorButtons(5,5,10,100,30,"exb1","b1","gl1","0xA80903","White","Button 1")
ColorButtons(125,5,10,100,30,"exb2","b2","gl2","0xffffff","Black","Button 2")
ColorButtons(245,5,10,100,30,"exb3","b3","gl3","0x064F93","White","Button 3")

Gui, Show, w350 h100 , Color Buttons 
Return

gl1:
click("b1","White","Black")
Return

gl2:
click("b2","Black","Blue")
Return

gl3:
click("b3","White","Black")
Return

click(button,c1,c2)
	{
	Gui, Font, c%c2%
	GuiControl, Font, %button%,
	Sleep, 100
	Gui, Font, c%c1%
	GuiControl, Font, %button%,	
	}

Exit:
GuiEscape:
GuiClose:
Gui, Destroy
ExitApp
Return
*/
