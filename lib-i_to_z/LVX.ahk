/*
		Title: LVX Library
		
		Row colouring and cell editing functions for ListView controls.
		
		Remarks:
			Cell editing code adapted from Michas <http://www.autohotkey.com/forum/viewtopic.php?t=19929>;
			row colouring by evl <http://www.autohotkey.com/forum/viewtopic.php?t=9266>.
			Many thanks to them for providing the code base of these functions!
		
		License:
			- Version 1.04 by Titan <http://www.autohotkey.net/~Titan/#lvx>
			- zlib License <http://www.autohotkey.net/~Titan/zlib.txt>
*/

/*
		
		Function: LVX_Setup
			Initalization function for the LVX library. Must be called before all other functions.
		
		Parameters:
			name - associated variable name (or Hwnd) of ListView control to setup for colouring and cell editing.
		
*/
LVX_Setup(name) {
	global lvx
	If name is xdigit
		h = %name%
	Else GuiControlGet, h, Hwnd, %name%
	VarSetCapacity(lvx, 4 + 255 * 9, 0)
	NumPut(h + 0, lvx)
	OnMessage(0x4e, "WM_NOTIFY")
	LVX_SetEditHotkeys() ; initialize default hotkeys
}

/*
		
		Function: LVX_CellEdit
			Makes the specified cell editable with an Edit control overlay.
		
		Parameters:
			r - (optional) row number (default: 1)
			c - (optional) column (default: 1)
			set - (optional) true to automatically set the cell to the new user-input value (default: true)
		
		Remarks:
			The Edit control may be slightly larger than its corresponding row,
			depending on the current font setting. 
		
*/
LVX_CellEdit(set = true) {
	global lvx, lvxb
	static i = 1, z = 48, e, h, k = "Enter|Esc|NumpadEnter"
	If i
	{
		Gui, %A_Gui%:Add, Edit, Hwndh ve Hide r1
		;make row resize to fit this height.. then back
		h += i := 0
	}
	If r < 1
		r = %A_EventInfo%
	If !LV_GetNext()
		Return
	If !(A_Gui or r)
		Return
	l := NumGet(lvx)
	SendMessage, 4135, , , , ahk_id %l% ; LVM_GETTOPINDEX
	vti = %ErrorLevel%
	VarSetCapacity(xy, 16, 0)
	ControlGetPos, bx, t, , , , ahk_id %l%
	bw = 0
	by = 0
	bpw = 0
	SendMessage, 4136, , , , ahk_id %l% ; LVM_GETCOUNTPERPAGE
	Loop, %ErrorLevel% {
		cr = %A_Index%
		NumPut(cr - 1, xy, 4), NumPut(2, xy) ; LVIR_LABEL
		SendMessage, 4152, vti + cr - 1, &xy, , ahk_id %l% ; LVM_GETSUBITEMRECT
		by := NumGet(xy, 4)
		If (LV_GetNext() - vti == cr)
			Break
	}
	by += t + 1
	cr--
	VarSetCapacity(xy, 16, 0)
	CoordMode, Mouse, Relative
	MouseGetPos, mx
	Loop, % LV_GetCount("Col") {
		cc = %A_Index%
		NumPut(cc - 1, xy, 4), NumPut(2, xy) ; LVIR_LABEL
		SendMessage, 4152, cr, &xy, , ahk_id %l% ; LVM_GETSUBITEMRECT
		bx += bw := NumGet(xy, 8) - NumGet(xy, 0)
		If !bpw
			bpw := NumGet(xy, 0)
		If (mx <= bx)
			Break
	}
	bx -= bw - bpw - 2
	LV_GetText(t, cr + 1, cc)
	GuiControl, , e, %t%
	ControlMove, , bx, by, bw, , ahk_id %h%
	GuiControl, Show, e
	GuiControl, Focus, e
	VarSetCapacity(g, z, 0)
	NumPut(z, g)
	LVX_SetEditHotkeys(~1, h)
	Loop {
		DllCall("GetGUIThreadInfo", "UInt", 0, "Str", g)
		If (lvxb or NumGet(g, 12) != h)
			Break
		Sleep, 100
	}
	GuiControlGet, t, , e
	If (set and lvxb != 2)
		LVX_SetText(t, cr + 1, cc)
	GuiControl, Hide, e
	Return, lvxb == 2 ? "" : t
}

/*
		
		Function: LVX_SetText
			Set the text of a specified cell.
		
		Parameters:
			text - new text content of cell
			row - (optional) row number
			col - (optional) column number
		 
*/
LVX_SetText(text, row = 1, col = 1) {
	global lvx
	l := NumGet(lvx)
	row--
	VarSetCapacity(d, 60, 0)
	SendMessage, 4141, row, &d, , ahk_id %l%  ; LVM_GETITEMTEXT
	NumPut(col - 1, d, 8)
	NumPut(&text, d, 20)
	SendMessage, 4142, row, &d, , ahk_id %l% ; LVM_SETITEMTEXT
}

/*
		
		Function: LVX_SetEditHotkeys
			Change accept/cancel hotkeys in cell editing mode.
		
		Parameters:
			enter - comma seperated list of hotkey names/modifiers that will save
				the current input text and close editing mode
			esc - same as above but will ignore text entry (i.e. to cancel)
		
		Remarks:
			The default hotkeys are Enter and Esc (Escape) respectively,
				and such will be used if either parameter is blank or omitted.
		 
*/
LVX_SetEditHotkeys(enter = "Enter,NumpadEnter", esc = "Esc") {
	global lvx, lvxb
	static h1, h0
	If (enter == ~1) {
		If esc > 0
		{
			lvxb = 0
			Hotkey, IfWinNotActive, ahk_id %esc%
		}
		Loop, Parse, h1, `,
			Hotkey, %A_LoopField%, _lvxb
		Loop, Parse, h0, `,
			Hotkey, %A_LoopField%, _lvxc
		Hotkey, IfWinActive
		Return
	}
	If enter !=
		h1 = %enter%
	If esc !=
		h0 = %esc%
}

_lvxc: ; these labels are for internal use:
lvxb++
_lvxb:
lvxb++
LVX_SetEditHotkeys(~1, -1)
Return

/*
		
		Function: LVX_SetColour
			Set the background and/or text colour of a specific row on a ListView control.
		
		Parameters:
			index - row index (1-based)
			back - (optional) background row colour, must be hex code in RGB format (default: 0xffffff)
			text - (optional) similar to above, except for font colour (default: 0x000000)
		
		Remarks:
			Sorting will not affect coloured rows. 
		 
*/
LVX_SetColour(index, back = 0xffffff, text = 0x000000) {
	global lvx
	a := (index - 1) * 9 + 5
	NumPut(LVX_RevBGR(text) + 0, lvx, a)
	If !back
		back = 0x010101 ; since we can't use null
	NumPut(LVX_RevBGR(back) + 0, lvx, a + 4)
	h := NumGet(lvx)
	WinSet, Redraw, , ahk_id %h%
}

/*
		
		Function: LVX_RevBGR
			Helper function for internal use. Converts RGB to BGR.
		
		Parameters:
			i - BGR hex code
		
*/
LVX_RevBGR(i) {
	Return, (i & 0xff) << 16 | (i & 0xffff) >> 8 << 8 | i >> 16
}

/*
		Function: LVX_Notify
			Handler for WM_NOTIFY events on ListView controls. Do not use this function.
*/
LVX_Notify(wParam, lParam, msg) {
	global lvx
	If (NumGet(lParam + 0) == NumGet(lvx) and NumGet(lParam + 8, 0, "Int") == -12) {
		st := NumGet(lParam + 12)
		If st = 1
			Return, 0x20
		Else If (st == 0x10001) {
			a := NumGet(lParam + 36) * 9 + 9
			If NumGet(lvx, a)
      	NumPut(NumGet(lvx, a - 4), lParam + 48), NumPut(NumGet(lvx, a), lParam + 52)
		}
	}
}

WM_NOTIFY(wParam, lParam, msg, hwnd) {
	; if you have your own WM_NOTIFY function you will need to merge the following three lines:
	global lvx
	If (NumGet(lParam + 0) == NumGet(lvx))
		Return, LVX_Notify(wParam, lParam, msg)
}