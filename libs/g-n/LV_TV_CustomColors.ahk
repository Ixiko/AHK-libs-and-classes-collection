; http://www.autohotkey.com/board/topic/51488-treeviews-color-individual-rows-multiple-tv-support/

;LV functions
LV_Initialize(Gui_Number="", Control="", Column="") {
	local hGUI, hLV
	;Get either class or hWnd of control
	If !Control												;Control omitted
	{
		If (Gui_Number > 99)
			hLV := Gui_Number
		Else												;No hWnd => default
			Control = SysListView321
	}
	Else If RegExMatch(Control, "^[1-9]\d*$")				;ClassNN Number provided
		Control = SysListView32%Control%
	Else If !RegExMatch(Control, "^(SysListView32)?[1-9]\d*$")	;Not a ClassNN => control's associated var
	{
		If (!(Gui_Number > 0) || (Gui_Number > 99))
			Gui_Number = 1
		If _%Gui_Number%_%Control%_
			Return
		GuiControlGet, hLV, %Gui_Number%:hWnd, %Control%
		If ErrorLevel
			Return
		_%Gui_Number%_%Control%_ := hLV
	}														;Otherwise, ClassNN was provided.
		
	If hLV
	{
		If (_%hLV%_ || !HWND2GuiNClass(hLV, Gui_Number, Control))
			Return
	}
	Else If Control											;Control found/provided
	{
		If (!(Gui_Number > 0) || (Gui_Number > 99))
			Gui_Number = 1
		If _%Gui_Number%_%Control%_
			Return
		Gui, %Gui_Number%:+LastFoundExist
		If !(hGUI := WinExist())
			Return
		GuiControlGet, hLV, %Gui_Number%:HWND, %Control%
		If ErrorLevel
			Return
	}
	Else
		Return
	
	hLV+=0
	;Save handle to quickly get it from gui+control
	_%Gui_Number%_%Control%_ := hLV
	;Save gui and control to quickly get it from handle
	_%hLV%_ := Gui_Number "|" Control
	;Save column containing indexes
	If !Column
		_%hLV%_Col_ = 1
	Else
		_%hLV%_Col_ := Column
	;Maintain a list of registered handles for wm_notify to operate on every registered control
	If !_LTV_h_List_
		_LTV_h_List_ := "|" hLV "|"
	Else
		_LTV_h_List_ .= hLV "|"
	;Maintain a list of modified indexes for disposal
	;Colors bound to indexes
	_%hLV%_0_Text = |
	_%hLV%_0_Back = |
	;Colors bound to lines
	_%hLV%_0_LText = |
	_%hLV%_0_LBack = |
	OnMessage( 0x4E, "WM_NOTIFY" )
	Return hLV
}

LV_Change(Gui_Number="", Control="", Select="", Column="") {
	local hLV
	;Get either class or hWnd of control
	If !Control												;Control omitted
	{
		If (Gui_Number > 99)
			hLV := Gui_Number
		Else												;No hWnd => default
			Control = SysListView321
	}
	Else If RegExMatch(Control, "^[1-9]\d*$")				;ClassNN Number provided
		Control = SysListView32%Control%
	Else If !RegExMatch(Control, "^(SysListView32)?[1-9]\d*$")		;Not a ClassNN or a NN => control's associated var
	{
		If (!(Gui_Number > 0) || (Gui_Number > 99))
			Gui_Number = 1
		If !(hLV := _%Gui_Number%_%Control%_)		;May not have been initialized
		{
			If !(hLV := LV_Initialize(Gui_Number, Control, Column))
				Return
		}
	}														;Otherwise, ClassNN was provided.
	
	If hLV
	{
		hLV+=0
		If !_%hLV%_		;May not have been initialized
		{
			If !LV_Initialize(hLV, "", Column)
				Return
		}
		Loop, Parse, _%hLV%_, |
		{
			If (A_Index = 1)
				Gui_Number := A_LoopField
			Else
				Control := A_LoopField
		}
	}
	Else If Control											;Control found/provided
	{
		If (!(Gui_Number > 0) || (Gui_Number > 99))
			Gui_Number = 1
		If !(hLV := _%Gui_Number%_%Control%_)		;May not have been initialized
		{
			If !(hLV := LV_Initialize(Gui_Number, Control, Column))
				Return
		}
	}
	Else
		Return
	
	_LV_h_ := hLV+0
	If (Select != 0)
	{
		Gui, %Gui_Number%:Default
		Gui, ListView, %Control%
	}
	If (Column && (Column != _%hLV%_Col_))
		_%hLV%_Col_ := Column
	Return 1
}

LV_SetColor(Index="", TextColor="", BackColor="", Redraw=1) {
	local i, j, L
	If !_LV_h_
		Return
	Index+=0
	If (Index < 0)
	{
		L = L
		i = 1
		Index := -Index-1
	}
	Else If (Index > 0)
	{
		i = 1
		Index--
	}	
	Else If ((Index = "-0") || (Index = "-"))
	{
		L = L
		Index = 0
		ControlGet, i, List, Count, , ahk_id %_LV_h_%
	}
	Else
	{
		Index = 0
		ControlGet, i, List, Count, , ahk_id %_LV_h_%
	}
	Loop, %i%
	{
		j := A_Index+Index
		If (TextColor != "")
		{
			If (TextColor >= 0)
			{
				If !InStr(_%_LV_h_%_0_%L%Text, "|" j "|")
					_%_LV_h_%_0_%L%Text .= j "|"
				_%_LV_h_%_%j%_%L%Text := TextColor
			}
			Else
			{
				_%_LV_h_%_%j%_%L%Text =
				StringReplace, _%_LV_h_%_0_%L%Text, _%_LV_h_%_0_%L%Text, |%j%|, |
			}
		}
		If (BackColor != "")
		{
			If (BackColor >= 0)
			{
				If !InStr(_%_LV_h_%_0_%L%Back, "|" j "|")
					_%_LV_h_%_0_%L%Back .= j "|"
				_%_LV_h_%_%j%_%L%Back := BackColor
			}
			Else
			{
				_%_LV_h_%_%j%_%L%Back =
				StringReplace, _%_LV_h_%_0_%L%Back, _%_LV_h_%_0_%L%Back, |%j%|, |	
			}
		}
	}
	If Redraw
		WinSet, Redraw,, ahk_id %_LV_h_%
	Return 1
}

LV_GetColor(Index, T="Text") {		;Index of the item from which to get color , T="Text" ; T="Back" , L=0 : linked to lines; L=1 : linked to rows 
	local L
	If (Index<0)
	{
		L = L
		Index := -Index
	}
	Return _%_LV_h_%_%Index%_%L%%T%
}

LV_Destroy(Gui_Number="", Control="", DeactivateWMNotify="") {
	local hLV
	;Get either class or hWnd of control
	If !Control												;Control omitted
	{
		If (Gui_Number > 99)
			hLV := Gui_Number
		Else												;No hWnd => default
			Control = SysListView321
	}
	Else If Control RegExMatch(Control, "^[1-9]\d*$")								;ClassNN Number provided
		Control = SysListView32%Control%
	Else If !RegExMatch(Control, "^(SysListView32)?[1-9]\d*$")		;Not a ClassNN or a NN => control's associated var
	{
		If (!(Gui_Number > 0) || (Gui_Number > 99))
			Gui_Number = 1
		If !(hLV := _%Gui_Number%_%Control%_)
			Return
	}														;Otherwise, ClassNN was provided.
	
	If hLV
	{
		hLV+=0
		If !_%hLV%_
			Return
		Loop, Parse, _%hLV%_, |
		{
			If (A_Index = 1)
				Gui_Number := A_LoopField
			Else
				Control := A_LoopField
		}
	}
	Else If Control											;Control found/provided
	{
		If (!(Gui_Number > 0) || (Gui_Number > 99))
			Gui_Number = 1
		If !(hLV := _%Gui_Number%_%Control%_)
			Return
	}
	Else
		Return

	Loop, Parse, _%hLV%_0_Text, |
		_%hLV%_%A_LoopField%_Text =
	_%hLV%_0_Text =
	Loop, Parse, _%hLV%_0_Back, |
		_%hLV%_%A_LoopField%_Back =
	_%hLV%_0_Back =
	Loop, Parse, _%hLV%_0_LText, |
		_%hLV%_%A_LoopField%_LText =
	_%hLV%_0_LText =
	Loop, Parse, _%hLV%_0_LBack, |
		_%hLV%_%A_LoopField%_LBack =
	_%hLV%_0_LBack =
	_%Gui_Number%_%Control%_ =
	_%hLV%_Col_ =
	_%hLV%_ =
	WinSet, Redraw,, ahk_id %hLV%
	StringReplace, _LTV_h_List_, _LTV_h_List_, |%hLV%|, |, A 
	If ((_LTV_h_List_ = "|") && DeactivateWMNotify)
		OnMessage( 0x4E, "" )
	If (hLV = _LV_h_)
		_LV_h_ =
	
	Return 1
}


;TV functions
TV_GetIDFromPos(PosList, RootID="", hTV="")	{	;PosList is a list of the position of the parents of the item and ultimately its position itself among their siblings, separated by commas.

	Global _TV_h_
	If !hTV
		hTV := _TV_h_
	Loop, Parse, PosList, `,
	{
		If (A_Index=1)
		{
			If RootID
				hItem := RootID
			Else
			{
				If !(hItem := dllcall("SendMessageA", "uint", hTV, "uint", 4362, "uint", 0, "uint", 0))		;0=TVGN_ROOT ; 4362=TVM_GETNEXTITEM
					Return
			}
		}
		Else
			hItem := dllcall("SendMessageA", "uint", hTV, "uint", 4362, "uint", 4, "uint", hItem)		;4=TVGN_CHILD ; 4362=TVM_GETNEXTITEM
		If !hItem
			Return
		Loop, % A_LoopField-1
		{
			If !(hItem := dllcall("SendMessageA", "uint", hTV, "uint", 4362, "uint", 1, "uint", hItem))		;1=TVGN_NEXT ; 4362=TVM_GETNEXTITEM
				Return
		}
	}
	Return hItem
}

TV_GetPosFromID(hItem, hTV="") {
	Global _TV_h_
	If !hTV
		hTV := _TV_h_
	l=0
	If !(hItem0 := dllcall("SendMessageA", "uint", hTV, "uint", 4362, "uint", 0, "uint", 0))		;0=TVGN_ROOT ; 4362=TVM_GETNEXTITEM
		Return
	If (hItem=hItem0)
		Return 1
	Pos0=1
	Loop
	{
		m := l+1
		If !(hItem%m% := dllcall("SendMessageA", "uint", hTV, "uint", 4362, "uint", 4, "uint", hItem%l%))		;4=TVGN_CHILD ; 4362=TVM_GETNEXTITEM
		{
			hItem%l% := dllcall("SendMessageA", "uint", hTV, "uint", 4362, "uint", 1, "uint", hItem%l%)		;1=TVGN_NEXT ; 4362=TVM_GETNEXTITEM
			Loop
			{
				If !hItem%l%
				{
					l--
					If (l<0)
						Break
				}
				Else
				{
					Pos%l%++
					If (hItem%l%=hItem)
					{
						Loop, %l%
							Pos0 .= "," Pos%A_Index%
						Return Pos0
					}
					Break
				}
				hItem%l% := dllcall("SendMessageA", "uint", hTV, "uint", 4362, "uint", 1, "uint", hItem%l%)		;1=TVGN_NEXT ; 4362=TVM_GETNEXTITEM
			}
			if (l<0)
				Break
		}
		Else
		{
			l++
			Pos%l%=1
			If (hItem%l%=hItem)
			{
				Loop, %l%
					Pos0 .= "," Pos%A_Index%
				Return Pos0
			}
		}
	}
	Return
}

TV_ListID(hTV="") {
	Global _TV_h_
	If !hTV
		hTV := _TV_h_
	l=0
	List := (hItem%l% := dllcall("SendMessageA", "uint", hTV, "uint", 4362, "uint", 0, "uint", 0))		;0=TVGN_ROOT ; 4362=TVM_GETNEXTITEM
	Loop
	{
		m := l+1
		If !(hItem%m% := dllcall("SendMessageA", "uint", hTV, "uint", 4362, "uint", 4, "uint", hItem%l%))		;4=TVGN_CHILD ; 4362=TVM_GETNEXTITEM
		{
			hItem%l% := dllcall("SendMessageA", "uint", hTV, "uint", 4362, "uint", 1, "uint", hItem%l%)		;1=TVGN_NEXT ; 4362=TVM_GETNEXTITEM
			Loop
			{
				If !hItem%l%
				{
					l--
					If (l<0)
						Break
				}
				Else
				{
					List .= "," hItem%l%
					Break
				}
				hItem%l% := dllcall("SendMessageA", "uint", hTV, "uint", 4362, "uint", 1, "uint", hItem%l%)		;1=TVGN_NEXT ; 4362=TVM_GETNEXTITEM
			}
			if (l<0)
				Break
		}
		Else
		{
			List .= "," hItem%m%
			l++
		}
	}
	Return List
}

TV_Initialize(Gui_Number="", Control="") {
	Local hGUI, hTV
	;Get either class or hWnd of control
	If !Control												;Control omitted
	{
		If (Gui_Number > 99)
			hTV := Gui_Number
		Else												;No hWnd => default
			Control = SysTreeView321
	}
	Else If RegExMatch(Control, "^[1-9]\d*$")				;ClassNN Number provided
		Control = SysTreeView32%Control%
	Else If !RegExMatch(Control, "^(SysTreeView32)?[1-9]\d*$")	;Not a ClassNN => control's associated var
	{
		If (!(Gui_Number > 0) || (Gui_Number > 99))
			Gui_Number = 1
		If _%Gui_Number%_%Control%_
			Return
		GuiControlGet, hTV, %Gui_Number%:hWnd, %Control%
		If ErrorLevel
			Return
		_%Gui_Number%_%Control%_ := hTV
	}														;Otherwise, ClassNN was provided.
		
	If hTV
	{
		If (_%hTV%_ || !HWND2GuiNClass(hTV, Gui_Number, Control))
			Return
	}
	Else If Control											;Control found/provided
	{
		If (!(Gui_Number > 0) || (Gui_Number > 99))
			Gui_Number = 1
		If _%Gui_Number%_%Control%_
			Return
		Gui, %Gui_Number%:+LastFoundExist
		If !(hGUI := WinExist())
			Return
		GuiControlGet, hTV, %Gui_Number%:HWND, %Control%
		If ErrorLevel
			Return
	}
	Else
		Return
	
	hTV+=0
	;Save handle to quickly get it from gui+control
	_%Gui_Number%_%Control%_ := hTV
	;Save gui and control to quickly get it from handle
	_%hTV%_ := Gui_Number "|" Control
	;Maintain a list of registered handles for wm_notify to operate on every registered control
	If !_LTV_h_List_
		_LTV_h_List_ := "|" hTV "|"
	Else
		_LTV_h_List_ .= hTV "|"
	;Maintain a list of modified indexes for disposal
	__0_Text = |
	__0_Back = |
	OnMessage( 0x4E, "WM_NOTIFY" )
	Return hTV
}

TV_Change(Gui_Number="", Control="", Select=1) {
	Local hTV
	;Get either class or hWnd of control
	If !Control												;Control omitted
	{
		If (Gui_Number > 99)
			hTV := Gui_Number
		Else												;No hWnd => default
			Control = SysTreeView321
	}
	Else If RegExMatch(Control, "^[1-9]\d*$")				;ClassNN Number provided
		Control = SysTreeView32%Control%
	Else If !RegExMatch(Control, "^(SysTreeView32)?[1-9]\d*$")		;Not a ClassNN or a NN => control's associated var
	{
		If (!(Gui_Number > 0) || (Gui_Number > 99))
			Gui_Number = 1
		If !(hTV := _%Gui_Number%_%Control%_)		;May not have been initialized
		{
			If !(hTV := TV_Initialize(Gui_Number, Control))
				Return
		}
	}														;Otherwise, ClassNN was provided.
	
	If hTV
	{
		hTV+=0
		If !_%hTV%_		;May not have been initialized
		{
			If !TV_Initialize(hTV)
				Return
		}
		Loop, Parse, _%hTV%_, |
		{
			If (A_Index = 1)
				Gui_Number := A_LoopField
			Else
				Control := A_LoopField
		}
	}
	Else If Control											;Control found/provided
	{
		If (!(Gui_Number > 0) || (Gui_Number > 99))
			Gui_Number = 1
		If !(hTV := _%Gui_Number%_%Control%_)		;May not have been initialized
		{
			If !(hTV := TV_Initialize(Gui_Number, Control))
				Return
		}
	}
	Else
		Return
	
	_TV_h_ := hTV+0
	If (Select!=0)
	{
		Gui, %Gui_Number%:Default
		Gui, TreeView, %Control%
	}
	Return 1
}

TV_SetColor(Index="", TextColor="", BackColor="", Redraw=1) {
	Local L
	Index+=0
	If (Index > 0)
		Gosub _TV_SetColor_
	Else
	{
		If !_TV_h_
			Return
		L := TV_ListID(_TV_h_)
		Loop, Parse, L, `,
		{
			Index := A_LoopField
			Gosub _TV_SetColor_
		}
	}
	If Redraw
		WinSet, Redraw,, ahk_id %_TV_h_%
	Return 1

	
	_TV_SetColor_:
	If (TextColor != "")
	{
		If (TextColor >= 0)
		{
			If !InStr(__0_Text, "|" Index "|")
				__0_Text .= Index "|"
			__%Index%_Text := TextColor
		}
		Else
		{
			__%Index%_Text =
			StringReplace, __0_Text, __0_Text, |%Index%|, |
		}
	}
	If (BackColor != "")
	{
		If (BackColor >= 0)
		{
			If !InStr(__0_Back, "|" Index "|")
				__0_Back .= Index "|"
			__%Index%_Back := BackColor
		}
		Else
		{
			__%Index%_Back =
			StringReplace, __0_Back, __0_Back, |%Index%|, |	
		}
	}
	Return
}

TV_GetColor(Index, T="Text")	{	;Index of the item from which to get color , T="Text" ; T="Back" , L=0 : linked to lines; L=1 : linked to rows 

	Global
	Index+=0
	Return __%Index%_%T%
}

TV_Destroy(Gui_Number="", Control="", DeactivateWMNotify="") {
	Local hTV, L
	;Get either class or hWnd of control
	If !Control												;Control omitted
	{
		If (Gui_Number > 99)
			hTV := Gui_Number
		Else												;No hWnd => default
			Control = SysTreeView321
	}
	Else If Control RegExMatch(Control, "^[1-9]\d*$")								;ClassNN Number provided
		Control = SysTreeView32%Control%
	Else If !RegExMatch(Control, "^(SysTreeView32)?[1-9]\d*$")		;Not a ClassNN or a NN => control's associated var
	{
		If (!(Gui_Number > 0) || (Gui_Number > 99))
			Gui_Number = 1
		If !(hTV := _%Gui_Number%_%Control%_)
			Return
	}														;Otherwise, ClassNN was provided.
	
	If hTV
	{
		hTV+=0
		If !_%hTV%_
			Return
		Loop, Parse, _%hTV%_, |
		{
			If (A_Index = 1)
				Gui_Number := A_LoopField
			Else
				Control := A_LoopField
		}
	}
	Else If Control											;Control found/provided
	{
		If (!(Gui_Number > 0) || (Gui_Number > 99))
			Gui_Number = 1
		If !(hTV := _%Gui_Number%_%Control%_)
			Return
	}
	Else
		Return
	
	L := TV_ListID(hTV)
	Loop, Parse, L, `,
	{
		__%A_LoopField%_Text =
		StringReplace, __0_Text, __0_Text, |%A_LoopField%|, |
		_%hTV%_%A_LoopField%_Back =
		StringReplace, __0_Back, __0_Back, |%A_LoopField%|, |
	}
	_%Gui_Number%_%Control%_ =
	_%hTV%_ =
	WinSet, Redraw,, ahk_id %hTV%
	StringReplace, _LTV_h_List_, _LTV_h_List_, |%hTV%|, |, A 
	If ((_LTV_h_List_ = "|") && DeactivateWMNotify)
		OnMessage( 0x4E, "" )
	If (hTV = _TV_h_)
		_TV_h_ =
	
	Return 1
}


;Common functions
DecodeInteger( p_type, p_address, p_offset, p_hex=true ) {
	StringRight, size, p_type, 1
	loop, %size%
		value += *( ( p_address+p_offset )+( A_Index-1 ) ) << ( 8*( A_Index-1 ) )
	if ( size <= 4 and InStr( p_type, "u" ) != 1 and *( p_address+p_offset+( size-1 ) ) & 0x80 )
		value := -( ( ~value+1 ) & ( ( 2**( 8*size ) )-1 ) )
	return, value
}

EncodeInteger( p_value, p_size, p_address, p_offset ) {
	loop, %p_size%
		DllCall( "RtlFillMemory", "uint", p_address+p_offset+A_Index-1, "uint", 1, "uchar", p_value >> ( 8*( A_Index-1 ) ) )
}

;Retrieves gui number and classNN from hwnd of a gui control
HWND2GuiNClass(hWnd, ByRef Gui = "", ByRef Control = "") {
	WinGetClass, Cc, ahk_id %hWnd%
	Loop, 99
	{
		Gui, %A_Index%:+LastFoundExist
		If !WinExist()
			Continue
		Gui_Number := A_Index
		Loop
		{
			GuiControlGet, hWCc, %Gui_Number%:HWND, %Cc%%A_Index%
			If !hWCc
				Break
			If (hWnd = hWCc)
			{
				Ctrl := Cc A_Index
				Break
			}
		}
		If Ctrl
		{
			Gui := A_Index
			Control := Ctrl
			Return 1
		}
	}
}

LTV_WM_NOTIFY(p_l) {
	Local draw_stage, Index, hLTV, Index1, Index
	Static IndexList
	Critical
	If InStr(_LTV_h_List_, "|" (hLTV := DecodeInteger( "uint4", p_l, 0 )+0) "|")
	{
		If ( DecodeInteger( "int4", p_l, 8 ) = -12 )						; NM_CUSTOMDRAW
		{
			draw_stage := DecodeInteger( "uint4", p_l, 12 )
			If ( draw_stage = 1 )											; CDDS_PREPAINT
			{
				If InStr(_%hLTV%_, "List")
				{
					ControlGet, IndexList, List, % "Col" _%hLTV%_Col_, , ahk_id %hLTV%
					If !RegexMatch(IndexList, "S)^([1-9]\d*\n)*[1-9]\d*$")		;The index column must contain exclusively strictly positive decimal integers
						IndexList =
				}
				Return, 0x20												; CDRF_NOTIFYITEMDRAW
			}
			Else If ( draw_stage = 0x10001 )								; CDDS_ITEM
			{
				If InStr(_%hLTV%_, "List")
				{
					Current_Line := DecodeInteger( "uint4", p_l, 36 )+1
					If IndexList
						RegexMatch(IndexList, "S)(?:.*?\n){" Current_Line-1 "}(.*?)(?:\n|$)", Index)
					If (IndexList && (_%hLTV%_%Index1%_Text != ""))
						EncodeInteger( _%hLTV%_%Index1%_Text, 4, p_l, 48 )	; indexed foreground
					Else If (_%hLTV%_%Current_Line%_LText != "")
						EncodeInteger( _%hLTV%_%Current_Line%_LText, 4, p_l, 48 )	; line foreground
					If (IndexList && (_%hLTV%_%Index1%_Back != ""))
						EncodeInteger( _%hLTV%_%Index1%_Back, 4, p_l, 52 )	; indexed background
					Else If (_%hLTV%_%Current_Line%_LBack != "")
						EncodeInteger( _%hLTV%_%Current_Line%_LBack, 4, p_l, 52 )	; line background
				}
				Else
				{
					Index := DecodeInteger( "uint4", p_l, 36 )+0
					If (__%Index%_Text != "")
					{
						EncodeInteger( __%Index%_Text, 4, p_l, 48 )	; line foreground
						}
					If (__%Index%_Back != "")
						EncodeInteger( __%Index%_Back, 4, p_l, 52 )	; line background
				}
			}
		}
	}
}

WM_NOTIFY( p_w, p_l, p_m ) {
	Critical
	/*
	;Prevents column resizing in LV, uncomment if resizing is buggy
	Index := DecodeInteger( "int4", p_l, 8 )
	If ((Index = -326) || (Index = -306))		; HDN_BEGINTRACKA = -306, HDN_BEGINTRACKW = -326
		Return 1
	*/
	
	;ADD YOUR CODE HERE	
		
	Return LTV_WM_NOTIFY(p_l)
}
