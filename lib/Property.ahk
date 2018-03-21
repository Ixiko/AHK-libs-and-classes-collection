/*
  Title:		Property
				Properties viewer and editor.

  Dependencies:
				<SpreadSheet>
 */

/*

 Function:		Add
				Creates property control.

 Parameters:
				hGui	- Handle of the parent.
				X..H	- Control coordinates.
				Style   - White space separated list of style names. Currently any SS style can be added.
				Handler - Notification handler.
 
 Handler:
 >			Result : Handler(hCtrl, Event, Name, Value, Param)

				hCtrl	- Handle of the control that sends notification.
				Event	- Event name. Can be S (Select) EB (Edit Before), EA (Edit After) and CB (ComboBox).
				Name	- Name of the selected property.
				Value	- Value of the selected property. If event is EA, this argument contains user input.
				Param	- Parameter of the selected property.  If event is EA, this argument contains user input.
				Result	- Return 1 to prevent selection (S) or to prevent user changing the value (EA). For details about CB, see <Insert> and <Define>.

 Events:		
				S   - Select
				EB	- Edit before. 
				EA	- Edit after. Value contains user input. Return 1 to prevent change of value / param.
				CB	- ComboBox event. <Insert> & <Define> fire up this event when they encounter ComboBox type (and so, functions using them, <InsertFile> & <Save>). 
					  Insert fires it up automatically when it encounters ComboBox without Value. Define requires this event to be explicitly enabled.
				F	- ForEach. You can fire this event with <ForEach> function and it will iterate all properties in the control.

 Retunrs:
				Control's handle.
 */
Property_Add(HParent, X=0, Y=0, W=200, H=100, Style="", Handler="") {
	hCtrl := SS_Add(HParent, X, Y, W, H, "GRIDMODE CELLEDIT ROWSELECT " style, "Property_handler")
	Property_initSheet(hCtrl), Property_SetColSize(hCtrl)
	if IsFunc(Handler)
		Property(hCtrl "handler", Handler)
	return hCtrl
}

/*
 Function:		Clear
				Clear Property control.
 */
Property_Clear(HCtrl){
	SS_NewSheet(HCtrl), Property_initSheet(HCtrl), 	SS_Redraw(HCtrl)
}

Property_Count(HCtrl) {
	return SS_GetRowCount(HCtrl)
}

/*
	Function:		Define
					Export the propety definition list from the control.

	Parameters:
					ComboEvent	- Set to TRUE to generate combobox event (CB). 
								  From the handler, return text you want to put in the Value parameter or "*" to let the function automatically set it up. 
								  Value holds the handle of the ListBox.

 */
Property_Define(HCtrl, ComboEvent=false) {
	n := SS_GetRowCount(hCtrl)
	loop, %n%
	{
		type := SS_GetCellType(HCtrl, 2, A_Index) 
		p := SS_GetCellText(HCtrl, 1, A_Index) 
		v := SS_GetCellText(HCtrl, 2, A_Index) 
		
		s = %s%Name=%p%`nType=
		if type=EXPANDED
			s .= "Separator", v := SS_GetCell(hCtrl, 2, A_Index, "h")
		else if type contains BUTTON
			s .= "Button"
		else if type contains WIDEBUTTON
			s .= "WideButton"
		else if type contains INTEGER
			s .= "Integer"
		else if type contains HYPERLINK
			s .= "HyperLink"
		else if type contains CHECKBOX,COMBOBOX
		{
			s .= (cb := InStr(type, "CHECKBOX")) ? "CheckBox" : "ComboBox"
			s .= "`nParam=" SS_GetCellData(hCtrl, 2, A_Index) 
			if (!cb && ComboEvent)
			{				
				handler := Property(hCtrl "handler")
				v1 := %handler%(hCtrl, "CB", p, hList := SS_GetCell(hCtrl, 2, A_Index, "txt"), "Define")
				ifNotEqual, v1, *, SetEnv, v, %v1%
				else {
					ControlGet, v1, List,, ,ahk_id %hList%
					StringReplace, v, v1, `n, |, A
				}
			}
		}
		else s .= "Text"

		if type != EXPANDED
			s .= "`nValue=" v 
		else if v 
			s .= "`nValue=" v 

		s .= "`n`n"
	}
	return SubStr(s, 1, -2)
}

/*	Function:	Remove
				Removes one or more properties from the list.

	Parameters:
				PropertyNames	- New line separated list of property names.
	
 */
Property_Remove(hCtrl, PropertyNames){
	plist := "`n" PropertyNames "`n"
	cnt := SS_GetRowCount(hCtrl)
	while (cnt > 0)
	{
		Name := SS_GetCellText(hCtrl, 1, cnt)
		if InStr(plist, "`n" Name "`n")
			SS_DeleteRow(hCtrl, cnt)
		cnt--
	}
	SS_Redraw(hCtrl)
}

/*	Function:	Find
				Returns the current index of the property.

	Parameters:
				Name	- Name of the property, the one with lower index will be returned.
				StartAt	- Index from which to start searching, by default 0.
	
	Returns:
				Positive number or 0 if property by that name is not found.
 */
Property_Find(hCtrl, Name, StartAt=0) {
	cnt := SS_GetRowCount(hCtrl)
	loop, % cnt - StartAt
		if SS_GetCellText(hCtrl, 1, startAt + A_Index) = Name
			return A_Index
	return 0
}

/*	Function:	ForEach
				Iterator

	Parameters:
			    SkipSeparators	- Set to FALSE not to skip separators while iterating.

	Remarks:
				The function will rise "F" event for the control.
 */
Property_ForEach(hCtrl, SkipSeparators=TRUE)
{
	handler := Property(hctrl "handler")
	ifEqual, handler, ,return

	cnt := SS_GetRowCount(hCtrl)
	loop, % cnt
	{
		t := SS_GetCellType(hCtrl, 2, A_Index, 2), param := ""
		ifEqual, t, 15, continue

		if t in 11,12								
			 param := SS_GetCellData(hCtrl, 2, A_Index)
		
		%handler%(hCtrl, "F", SS_GetCellText(hCtrl, 1, A_Index), SS_GetCellText(hCtrl, 2, A_Index), param )
	}
}

/*
 Function:		GetParam
				Get the property parameter.

 Parameters:
				Name	- Property name or index for which to get the value.

 Returns:
				Parameter
 */
Property_GetParam(hCtrl, Name) {
	ifEqual Name,,return	
	if Name is not integer
		 i := Property_Find( hCtrl, Name)
	else i := Name
	return SS_GetCellData(hCtrl, 2, i)
}

/*
 Function:		GetValue
				Get the property value.

 Parameters:
				Name	- Property name or index for which to get the value.

 Returns:
				Value
 */
Property_GetValue( hCtrl, Name ) {
	ifEqual Name,,return	
	if Name is not integer
		 i := Property_Find( hCtrl, Name)
	else i := Name
	return SS_GetCellText(hCtrl, 2, i)
}

/*
  Function:		Insert
				Insert properties in the list on a given position.

  Parameters:
				Properties	- Property Definition List. Definition is a multiline string containing 1 property attribute per line.
							  Definition List is the list of such definitions, separated by at least one blank line.
				Position	- Position in the list (1 based) at which to insert properties from the Definition List. 
							  0 (default) means that properties will be appended to the list. Insertion is very slow operation compared to appending.

  Definition:
				Name		- Name of the property to be displayed in the first column.
				Type		- Type of the property. Currently supported types are:
							  Text, Button, WideButton, CheckBox, ComboBox, Integer, Float, Hyperlink, Separator. If not specified, Text is used by default.
				Value		- Value of the property. For ComboBox item this contains pipe delimited list of items. In the case of Separator, you can put its desired height as value.
							  If omited, notification handler will be called in time of population with CE event, and Param="Insert", so you can handle the ComboBox the way you want.
				Param		- Index of the selected item (ComboBox), 1|0 (Checkbox).

  Remarks:
				The fastest way to add properties into the list is to craft property definition list and append it into the control with one call to this function.
				Using this function in a loop in many iterations will lead to seriously degraded performance (especially with Position option) with very large number of properties ( around 1K  )

				Property defintion list can contain comments - lines that start with ";" char.
 */
Property_Insert(hCtrl, Properties, Position=0){


	StringReplace, Properties, Properties, `n`n, `a, A
	StringSplit, a, Properties, `a
	
	nrows := SS_GetRowCount(hCtrl)
	if (Position > nrows+1)
		Position := 0

	if (Position != 0)
	{
		Loop, %a0%
			if (a%A_Index% != "")
				SS_InsertRow(hCtrl, Position)
	}
	else if (a0 = 1)
		 SS_InsertRow(hCtrl, -1)		
	else SS_SetGlobalFields(hCtrl, "nrows", nrows+a0)
	Property("", hCtrl ")pb pf vb vf sb sf", _pb, _pf, _vb, _vf, _sb, _sf),  k:=1

	Position--
	loop, %a0%
	{
		p := a%A_Index%
		ifEqual, p, ,continue

		if Position != -1
			 i := Position + k++
		else i := nrows + k++
		
	 ;initialize
		name := value := param := "", type := "Text"
		state:="Default", fnt1=0, fnt2=1, txtal:="RIGHT MIDDLE", imgal="MIDDLE RIGHT", txtal2="MIDDLE LEFT"
		PB := _PB,  PF := _PF  ,VF := _VF,  VB := _VB

	 ;parse property into local variables
		loop, parse, p, `n
		{
			ifEqual, A_LoopField,, continue
			j := InStr(A_LoopField, "="),    desc := SubStr(A_LoopField, 1, j-1)
			%desc% := SubStr(A_LoopField, j+1, StrLen(A_LoopField))
		}

	 ;set SpreadSheet options
		if (bSeparator := (Type="Separator") ) 
			tpe:= "FORCETEXT", state := "Locked", fnt1 := 2,  PB := _SB, PF :=_SF, 	txtal := "CENTER MIDDLE"
		
		tpe := type " FORCETYPE"

		if (type="HyperLink")
			fnt2 := 3

		if (type="ComboBox") 
		{
	 		tpe := "COMBOBOX FIXEDSIZE"
			if value =
				 handler := Property(hctrl "handler"),  value := %handler%(hCtrl, "CB", name, "", "Insert")
			else value := SS_CreateCombo(hCtrl, value)
			data := Param
		}		
		if (type="Button")		
			tpe := "BUTTON FORCETEXT FIXEDSIZE"

		if (type="WideButton")	
			 tpe := "WIDEBUTTON FORCETEXT", txtal2="CENTER MIDDLE"
		
		if (Type="CheckBox")
			tpe := "CHECKBOX FIXEDSIZE"
		
	 ;set row
		SS_SetCell(	hCtrl, 1, i
					,"type=TEXT", "txt=" name
					,"bg=" PB, "fg=" PF
					,"state=LOCKED", "txtal=" txtal, "fnt=" fnt1, bSeparator ? "h=" value : "")

		if (bSeparator)
			SS_ExpandCell( hCtrl, 1, i, 2, i )
		else
			SS_SetCell( hCtrl, 2, i
				,"type=" tpe 
				,"txt="  value
				,"bg=" VB, "fg=" VF
				,"txtal=" txtal2, "imgal=" imgal
				,"fnt=" fnt2, "state=" state, InStr("CheckBox,Combobox", type) ? "data=" param : "")

	}
	if !nrows
		SS_SetCurrentCell(hCtrl, 2,1)
	sleep, -1
}

/*
 Function:		InsertFile
				Insert properties from a file.

 Parameters:
				FileName - File from which to import properties. The file contains property definition list.
				ParseIni - Set to TRUE if file is an INI file.

 Remarks:
				<Insert> function doesn't tolerate `r symbol. If you are manually loading text from a file, make sure you replace `r`n with `n
				or use *t option with FileRead.

 */
Property_InsertFile( hCtrl, FileName, ParseIni = false ) {
	FileRead, txt, *t %FileName%
	ifEqual, ParseIni, 0, return Property_Insert( hCtrl, txt )

	oldTrim := A_AutoTrim
	AutoTrim, on

	loop, parse, ini, `r`n, `r`n
	{
		ifEqual, A_LoopField, , continue
		line = %A_LoopField%
		c := SubStr(A_LoopField,1,1)

		if (c=";")
			continue
			
		if (c = "[")
			s .= "Type=Separator`nText=" line
		else	{
			j := InStr(line, "="), v := SubStr(line, j+1)

			if v is integer
				 Type := "Integer"
			else Type := "Text"

			s .= "Name=" SubStr(line, 1, j-1) "`nType=" Type "`nText=" v
		}
		s .= "`n`n"
	}

	AutoTrim, %oldTrim%
	return Property_Insert(hctrl, SubStr(s,1,-2))
}

/*
 Function:		Save
				Save content of the control in a file.

 Parameters:
				FileName	- File to save to. If exists, it will be first deleted (without confirmation).
				ComboEvent	- Set to TRUE to generate combobox event (CB). See <Define> for more details.
 
 Returns:
				FALSE if there was a problem saving file, TRUE otherwise.

 */
Property_Save(hCtrl, FileName, ComboEvent=false) {
	FileDelete, %FileName%
	FileAppend, % Property_Define(hCtrl, ComboEvent) , %FileName%
	return ErrorLevel
}


/*
 Function:		Set
				Set property value and parameter.

 Parameters:
				Name	- Property name for which to get the value, or its index in the list
				Value	- Property value.
				Param	- Optional property parameter.
 */
Property_Set( hCtrl, Name, Value, Param="") {
	ifEqual Name,,return A_ThisFunc "> Name can't be empty"	
	if Name is not integer
		 i := Property_Find( hCtrl, Name)
	else i := Name
	return SS_SetCell(hCtrl, 2, i, "data=" Param, Value != "" ? "txt=" Value : "")
}

/*
 Function:	SetColSize
			Set column size.
 
 Parameters:
	
			C	- Size of the first column, by default 120. The other column will be sized automatically according to the control width.
  
 */
Property_SetColSize(HCtrl, C=120) {
	static b
	ifEqual, b, ,SysGet, b, 46		;get 3d border dim	
	ControlGetPos, ,,w,,,ahk_id %hCtrl%
	ifEqual, w, 0, SetEnv, w, 300
	SS_SetColWidth(HCtrl, 1, C-b), SS_SetColWidth(HCtrl, 2, w-C-b)
}

/*
 Function:		SetColors
				Set colors of property elements.

 Parameters:
				Colors	- String containing white space separated colors of property elements.

 Colors:		
				PB PF - property bg & fg 
				VB VF - value bg & fg
				SB SF - separator bg & fg

 Example:
>				Property_SetColors("pbAAEEAA sbBFFFFF")   ;set property and separator background color
 */
Property_SetColors(hCtrl, Colors){
	Loop, parse, Colors, %A_Space%%A_Tab%,%A_Space%%A_Tab%
	{
		ifEqual, A_LoopField,,continue
		StringLeft c, A_LoopField, 2
		%c% := "0x" SubStr(A_LoopField, 3)
		Property(hCtrl c, %c%)
	}
}

/*
  Function:		SetFont
 				Set font of propety element.

  Parameters:
				Element	- One of the four available elements: Property, Value, Separator, Hyperlink.
				Font	- Font description in AHK format
*/

Property_SetFont(HCtrl, Element, Font) {

	if (Element="Property")
		idx := 0
	else if (Element="Value")
		idx := 1
	else if (Element="Separator")
		idx := 2
	else if (Element="HyperLink")
		idx := 3

	return SS_SetFont(HCtrl, idx, Font)
}

/*
 Function:		SetParam
				Set property parameter.

 Parameters:
				Name	- Property name for which to get the value, or its index in the list
				Param	- Property parameter.
 */
Property_SetParam( HCtrl, Name, Param) {
	ifEqual Name,,return A_ThisFunc "> Name can't be empty"

	if Name is not integer
		 i := Property_Find( HCtrl, Name)
	else i := Name
	return SS_SetCell(HCtrl, 2, i, "data=" Param)
}

/*
	Function:	SetRowHeight
				Set row height.
	
 */

Property_SetRowHeight(hCtrl, Height) {
    c := Property_Count(hCtrl)
	SS_SetGlobalFields(hCtrl, "gcellht", Height)
	if !c
		SS_DeleteRow(hCtrl, 1)
	SS_SetRowHeight(hCtrl, 0, 0)
}

;==================================================== PRIVATE ============================================
Property_add2Form(hParent, Txt, Opt){
	static parse = "Form_Parse"
	%parse%(Opt, "x# y# w# h# style g*", x, y, w, h, style, handler)
	return Property_Add(hParent, x, y, w, h, style, handler)	
}

Property_handler(hCtrl, event, earg, col, row){
	static lastParam, lastSel=1, _hctrl, rowToSet

	if (event = "S") {		
		ifEqual, lastSel, %row%, return

		bSeparator := SS_GetCellType(hCtrl, 2, row)	= "Expanded"
		if (col = 1) && !bSeparator {
			rowToSet := row, _hctrl := hCtrl
			SetTimer, Property_timer, -1					;if user selects first column, switch to 2nd so he can use shortcuts on combobox, checkbox etc...	
			return 	"", 
		} 

		if (bSeparator) {
			rowToSet := abs(lastSel-row) > 1 ? row+1 : lastSel-row > 0 ? row -1 : row+1,  _hctrl := hCtrl
			SetTimer, Property_timer, -1
			return 1				;don't allow selection of separators.
		} 
		lastSel := row
	}

	handler := Property(hctrl "handler")
	ifEqual, handler, ,return

	t := SS_GetCellType(hCtrl, col, row, 2)				;return base type of the cell
	if t in 11,12										;checkbox, combobox
		param := SS_GetCellData(hCtrl, col, row)		; get their data

	name  := SS_GetCellText(hCtrl, 1, row)
	value := event = "EA" ? earg : SS_GetCellText(hCtrl, 2, row)

	if event in UB,UA
	{	
		if t not in 11,12
			return

		if (event="UB")
			lastParam := param

		StringReplace, event, event, U, E
	}

	;tooltip %etype% %event%,300, 300, 4
	r := %handler%(hCtrl, event, name, value, param)
	if (r && event="EA" && param != "")	; checkbox & combobox don't have EDIT, but only UPDATE notification and in that case you can't prevent change.
		SS_SetCellData(hCtrl, lastParam, col, row), SS_Redraw(hCtrl)
	return r

 Property_timer:
	SS_SetCurrentCell(_hCtrl, 2, lastSel := rowToSet), SS_Redraw(_hCtrl), Property_handler(_hCtrl, "S", "", 2, rowToSet)
 return
}

Property_initSheet(hCtrl){
	 SS_SetColCount(hCtrl, 2),  SS_SetLockCol(Hctrl, 1)
	 SS_SetRowCount(hCtrl, 0),  SS_SetRowHeight(hCtrl, 0, 0)
}

/*
	Storage function
			  
	
	Parameters:
			  var		- Variable name to retreive. To get up to 5 variables at once, omit this parameter.
			  value		- Optional variable value to set. If var is empty value contains list of vars to retreive with optional prefix
			  o1 .. o5	- If present, reference to variables to receive values.
	
	Returns:
			  o	if _value_ is omited, function returns the current value of _var_
			  o	if _value_ is set, function sets the _var_ to _value_ and returns previous value of the _var_
			  o if _var_ is empty, function accepts list of variables in _value_ and returns values of those varaiables in o1 .. o5

	Examples:
	(start code)			
 			v(x)	 - return value of x
 			v(x, v)  - set value of x to v and return previous value
 			v("", "x y z", x, y, z)  - get values of x, y and z into x, y and z
 			v("", "preffix_)x y z", x, y, z) - get values of preffix_x, preffix_y and preffix_z into x, y and z
	(end code)
			
*/
Property(var="", value="~`a", ByRef o1="", ByRef o2="", ByRef o3="", ByRef o4="", ByRef o5="", ByRef o6="") { 
	static
	if (var = "" ){
		if ( _ := InStr(value, ")") )
			__ := SubStr(value, 1, _-1), value := SubStr(value, _+1)
		loop, parse, value, %A_Space%
			_ := %__%%A_LoopField%,  o%A_Index% := _ != "" ? _ : %A_LoopField%
		return
	} else _ := %var%
	ifNotEqual, value, ~`a, SetEnv, %var%, %value%
	return _
}

/* Group: About
	o Module ver 1.02 by majkinetor
	o SpreadSheet control Version: 0.0.2.1 by KetilO <http://www.masm32.com/board/index.php?topic=6913.0>.
	o Licensed under BSD <http://creativecommons.org/licenses/BSD/>.

 */

#include SpreadSheet.ahk	