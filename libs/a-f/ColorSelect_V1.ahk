; Link:   	https://raw.githubusercontent.com/TheArkive/CallTipsForAll/master/LibV1/_Color_Picker_Dialog_v1.ahk
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

; AHK v1
; originally posted by maestrith 
; https://autohotkey.com/board/topic/94083-ahk-11-font-and-color-dialogs/

; #SingleInstance,Force

; === optional input color object, max 16 indexes number 1-16 ===
; === can be Array(), [], or Object()
; defColor := Array(0xFF0000,"",0x00FF00,"",0x0000FF)
; ===============================================================

; cc := 0x00FF00 ; green

; Gui,Color,% cc
; Gui,+hwndhwnd +ToolWindow
; Gui,Add,Button,gchoose,Choose Color
; Gui,Show,,Color Test
; return

; choose:
	; cc := ColorSelect(cc,hwnd,defColor,"basic") ; hwnd and defColor are optional
	
	; if (cc = -1)
		; return
	
	; colorList := ""
	; For k, v in defColor {
		; If v {
			; colorList .= "Index: " k " / Color: " v "`r`n"
		; }
	; }
		
	; If cc
		; msgbox % "Output color: " cc "`r`n`r`nCustom colors saved:`r`n`r`n" Trim(colorList,"`r`n")
	
	; Gui, Color, % cc
; return

; GuiEscape:
; GuiClose:
	; ExitApp
; return

; =============================================================================================
; Color			= Start color
; hwnd			= Parent window
; custColorObj	= Use for input to init custom colors, or output to save custom colors, or both.
;                 ... custColorObj can be Array() or Object().
; disp			= full / basic ... full displays custom colors panel, basic does not
; =============================================================================================
; All params are optional.  With no hwnd dialog will show at top left of screen.  User must
; parse output custColorObj and decide how to save custom colors... no more automatic ini file.
; =============================================================================================

ColorSelect(Color := 0, hwnd := 0, ByRef custColorObj := "",disp:=1) {
	Color := (Color = "") ? 0 : Color ; fix silly user "oops"
	disp := disp ? 0x3 : 0x1 ; init disp / 0x3 = full panel / 0x1 = basic panel
	
	c1 := Format("0x{:02X}",(Color&255)<<16)	; convert RGB colors to BGR for input
	c2 := Format("0x{:02X}",Color&65280)		; init start Color
	c3 := Format("0x{:02X}",Color>>16)
	Color := Format("0x{:06X}",c1|c2|c3)
	
	VarSetCapacity(CUSTOM, 16 * A_PtrSize,0) ; init custom colors obj
	size := VarSetCapacity(CHOOSECOLOR, 9 * A_PtrSize,0) ; init dialog
	
	If (IsObject(custColorObj)) {
		Loop 16 {
			If (custColorObj.HasKey(A_Index)) {
				col := custColorObj[A_Index]
				c4 := Format("0x{:02X}",(col&255)<<16)	; convert RGB colors to BGR for input
				c5 := Format("0x{:02X}",col&65280)		; 
				c6 := Format("0x{:02X}",col>>16)
				custCol := Format("0x{:06X}",c4|c5|c6)
				NumPut(custCol, CUSTOM, (A_Index-1) * 4, "UInt")
			}
		}
	}
	
	NumPut(size, CHOOSECOLOR, 0, "UInt")
	NumPut(hwnd, CHOOSECOLOR, A_PtrSize, "UPtr")
	NumPut(Color, CHOOSECOLOR, 3 * A_PtrSize, "UInt")
	NumPut(disp, CHOOSECOLOR, 5 * A_PtrSize, "UInt") ; flags? - original = 3 (0x1 and 0x2)
	NumPut(&CUSTOM, CHOOSECOLOR, 4 * A_PtrSize, "UPtr")
	
	ret := DllCall("comdlg32\ChooseColor", "UPtr", &CHOOSECOLOR, "UInt")
	
	if !ret
		return -1
	
	custColorObj := Array()
	Loop 16 {
		newCustCol := NumGet(custom, (A_Index-1) * 4, "UInt")
		c7 := Format("0x{:02X}",(newCustCol&255)<<16)	; convert RGB colors to BGR for input
		c8 := Format("0x{:02X}",newCustCol&65280)
		c9 := Format("0x{:02X}",newCustCol>>16)
		newCustCol := Format("0x{:06X}",c7|c8|c9)
		custColorObj.InsertAt(A_Index, newCustCol)
	}
	
	Color := NumGet(CHOOSECOLOR, 3 * A_PtrSize, "UInt")
	
	c1 := Format("0x{:02X}",(Color&255)<<16)	; convert RGB colors to BGR for input
	c2 := Format("0x{:02X}",Color&65280)
	c3 := Format("0x{:02X}",Color>>16)
	Color := Format("0x{:06X}",c1|c2|c3)
	
	CUSTOM := "", CHOOSECOLOR := ""
	
	return Color
}