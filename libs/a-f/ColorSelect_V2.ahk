; Link:   	https://raw.githubusercontent.com/TheArkive/CallTipsForAll/master/LibV2/_Color_Picker_Dialog_v2.ahk
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

; AHK v2
; originally posted by maestrith 
; https://autohotkey.com/board/topic/94083-ahk-11-font-and-color-dialogs/

; #SingleInstance,Force

; Global defColor

; === optional input color object, max 16 indexes number 1-16 ===
; === can be Array(), [], or Map()
; defColor := Array(0xFF0000,0,0x00FF00,0,0x0000FF)
; ===============================================================
; Example
; ===============================================================

; global cc, defColor
; cc := 0x00FF00 ; green
; defColor := [0xAA0000,0x00AA00,0x0000AA]

; oGui := Gui.New("-MinimizeBox -MaximizeBox","Choose Color")
; oGui.OnEvent("close","close_event")
; oGui.OnEvent("escape","close_event")
; oGui.AddButton("w150","Choose Color").OnEvent("click","choose_event")
; oGui.BackColor := cc
; oGui.Show("")
; return


; choose_event(ctl,info) {
	; hwnd := ctl.gui.hwnd ; grab hwnd
	; cc := "0x" ctl.gui.BackColor ; pre-select color from gui background (optional)
	
	; cc := ColorSelect(cc,hwnd,defColor,0) ; hwnd and defColor are optional
	
	; If (cc = -1)
		; return
	
	; colorList := ""
	; For k, v in defColor {
		; If v {
			; colorList .= "Index: " k " / Color: " v "`r`n"
		; }
	; }
		
	; If cc
		; msgbox "Output color: " cc "`r`n`r`nCustom colors saved:`r`n`r`n" Trim(colorList,"`r`n")
	
	; ctl.gui.BackColor := cc ; set gui background color
; }

; close_event(guiObj) {
	; ExitApp
; }

; ===============================================================
; END Example
; ===============================================================

; =============================================================================================
; Color			= Start color
; hwnd			= Parent window
; custColorObj	= Use for input to init custom colors, or output to save custom colors, or both.
;                 ... custColorObj can be Array() or Map().
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
	
	CUSTOM := BufferAlloc(16 * A_PtrSize,0) ; init custom colors obj
	
	CHOOSECOLOR := BufferAlloc(9 * A_PtrSize,0) ; init dialog
	size := CHOOSECOLOR.size
	
	If (IsObject(custColorObj)) {
		Loop 16 {
			If (custColorObj.Has(A_Index)) {
				col := custColorObj[A_Index] = "" ? 0 : custColorObj[A_Index] ; init "" to 0 (black)
				
				c4 := Format("0x{:02X}",(col&255)<<16)	; convert RGB colors to BGR for input
				c5 := Format("0x{:02X}",col&65280)		; 
				c6 := Format("0x{:02X}",col>>16)
				custCol := Format("0x{:06X}",c4|c5|c6)
				NumPut "UInt", custCol, CUSTOM, ((A_Index-1) * 4) ; type, number, target, offset
			}
		}
	}
	
	NumPut "UInt", size, CHOOSECOLOR, 0
	NumPut "UPtr", hwnd, CHOOSECOLOR, A_PtrSize
	NumPut "UInt", Color, CHOOSECOLOR, 3 * A_PtrSize
	NumPut "UInt", disp, CHOOSECOLOR, 5 * A_PtrSize
	NumPut "UPtr", CUSTOM.ptr, CHOOSECOLOR, 4 * A_PtrSize
	
	ret := DllCall("comdlg32\ChooseColor", "UPtr", CHOOSECOLOR.ptr, "UInt")
	
	if !ret
		return -1
	
	custColorObj := Array()
	Loop 16 {
		newCustCol := NumGet(CUSTOM, (A_Index-1) * 4, "UInt")
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
