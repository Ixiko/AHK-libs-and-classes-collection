/*  
	Title:  SpreadSheet 
			SpreadSheet control is extremelly fast and small Excell like control, developed in Assembler.

			(See SpreadSheet.png)
 */

/*
	Function: Add
			  Add control to the Gui

	Parameters:
			  HParent	- Parent's handle.
			  X..H		- Control coordinates.
			  Style		- White separated list of control styles.
			  Handler	- Notification handler, optional.
			  DllPath	- Path to the dll, by default look at the working folder.

	Styles:
			 VSCROLL  HSCROLL  STATUS  GRIDLINES  ROWSELECT  CELLEDIT  GRIDMODE  COLSIZE  ROWSIZE  WINSIZE  MULTISELECT 
	
	Handler:
>			result := Handler(HCtrl, Event, EArg, Col, Row)

			HCtrl	- Handle of the speradsheet control that sends the notification.
			Event	- Event that ocured. Can be *S* (select), *EB* (before edit), *EA* (after edit), *UB* (before update), *UA* (after update), *C* (click) and *D* (draw)
			EArg    - Event argument. Depends on event. See below.
			Col		- Column of the associated cell.
			Row		- Row of the associated cell.
			
			result	- Handler result, depends on event. See bellow.
			

	Event types and returns:
			Handler's _EArg_ parameter is specific to each event:

			S	- Current splitt window number. Return 1 to prevent selection.
			EA	- User input. Return 1 to discard user input.
			C	- B (Button) or H (Hyperlink). Return value isn't used.
			EB,UB,UB - Empty (argument isn't used). Return value isn't used.
			D	- Pointer to DRAWITEMSTRUCT. See <http://msdn.microsoft.com/en-us/library/bb775802(VS.85).aspx>.

	Returns:
			Control's handle.	

  */
SS_Add(HParent,X,Y,W,H, Style="", Handler="", DllPath=""){
	static MODULEID
	static WS_CLIPCHILDREN=0x2000000, WS_VISIBLE=0x10000000, WS_CHILD=0x40000000
	static VSCROLL=0x0001, HSCROLL=0x0002, STATUS=0x0004, GRIDLINES=0x0008, ROWSELECT=0x0010, CELLEDIT=0x0020, GRIDMODE=0x0040, COLSIZE=0x0080, ROWSIZE=0x0100, WINSIZE=0x0200, MULTISELECT=0x0400

  ;standard registering procedure
	if !MODULEID { 
		ifEqual, DllPath,,SetEnv, DllPath, SprSht.dll
		if !DllCall("LoadLibrary", "str", DllPath)	
			return A_ThisFunc "> Can't load library - " DllPath		
		old := OnMessage(0x4E, "SS_onNotify"),	MODULEID := 260609
		if old != SS_onNotify
			SS("oldNotify", RegisterCallback(old))
	}

  ;parse style
	hStyle := 0
	loop, parse, style, %A_Tab%%A_Space%
		IfEqual, A_LoopField,, continue
		else hStyle |= %A_LOOPFIELD%
	
	hCtrl := DllCall("CreateWindowEx"
      , "Uint", 0x200           ; WS_EX_CLIENTEDGE
      , "str",  "SPREAD_SHEET"  ; ClassName
      , "str",  ""		        ; WindowName
      , "Uint", WS_CLIPCHILDREN | WS_CHILD | WS_VISIBLE | hStyle
      , "int",  x				; Left
      , "int",  y				; Top
      , "int",  w				; Width
      , "int",  h				; Height
      , "Uint", HParent			; hWndParent
      , "Uint", MODULEID		; hMenu
      , "Uint", 0				; hInstance
      , "Uint", 0, "Uint")
	ifEqual, hCtrl, 0, return A_ThisFunc "> Error creating control"

	if IsFunc(Handler)
		SS(hCtrl "Handler", Handler)

	return hCtrl
}

/*
	Function:	BlankCell
				Erase the cell.
  */
SS_BlankCell(hCtrl, Col="", Row="") {
	static SPRM_BLANKCELL=0x477		;Blank a cell. wParam=col, lParam=row
	if Col=
		SS_GetCurrentCell(hCtrl, Col, Row) 
	SendMessage,SPRM_BLANKCELL,Col,Row,, ahk_id %hCtrl%
	return ErrorLevel 
}

/*
	Function: CreateCombo
			  Creates COMBOBOX cell type.
	
	Parameters:
			  Content	- | separated list of ComboBox items.
			  Height	- Height of the combo box.
	
	Returns:
			  Handle of the ComboBox. Use it with _txt_ parameter of the <CetCell> function.
  */
SS_CreateCombo(hCtrl, Content, Height=150) {
	static SPRM_CREATECOMBO=0x491	;Creates a ComboBox. wPatam=Height, lParam=0

	ifEqual, Content,, return A_ThisFunc "> Content can't be empty"

	SendMessage,SPRM_CREATECOMBO,Height,0,,ahk_id %hCtrl% 
	hListBox := ErrorLevel

	old := A_DetectHiddenWindows
	DetectHiddenWindows, on
	loop, parse, content, |
		Control, Add, %A_LoopField%,, ahk_id %hListBox%
	DetectHiddenWindows, %old%

	return hListBox
}

/*
	Function: ConvertDate
			  Converts date from / to integer.
	
	Parameters:
			  Date			- Integer or textual representation of the date.
			  RefreshFormat - Set to TRUE to refresh control's date format that is stored internaly on first call.
	
	Returns:
			 If Date is integer the return value is the date string, otherwise the retun value is integer representation of the date.
  */
SS_ConvertDate(hCtrl, Date, RefreshFormat=false) {
	static format
	var := 16010101,  format .= (format="") || RefreshFormat ? SS_GetDateFOrmat(hCtrl) : ""

	if Date is integer
	{
		EnvAdd, var, %Date%, D
		FormatTime, var, %var%, %format%
		return var
	}
	else {
			loop, parse, format
			{
				if A_LoopField not in d,M,y
					continue
				ifEqual, A_LoopField, y, SetEnv, y, % y SubStr(Date, A_Index, 1) 
				ifEqual, A_LoopField, d, SetEnv, d, % d SubStr(Date, A_Index, 1) 
				ifEqual, A_LoopField, m, SetEnv, m, % m SubStr(Date, A_Index, 1) 					
			}		
			time := y m d
			EnvSub, time, %var%, D
			return time
	}
}

/*
	Function: DeleteCell
			  Delete cell.
	
	Remarks:
			  Its misterious to me what is the difference between this one and <BlankCell>.
  */
SS_DeleteCell(hCtrl, Col="", Row="") {
	static SPRM_DELETECELL=0x493	;Deletes a cell. wParam=col, lParam=row
	if Col=
		SS_GetCurrentCell(hCtrl, Col, Row) 
	SendMessage,SPRM_DELETECELL,Col,Row,, ahk_id %hCtrl%
	return ErrorLevel 
}

/*
	Function: DeleteCol
			  Delete column.
	
	Parameters:
			  Col - Column index. Of omited, current column is used.
  */
SS_DeleteCol(hCtrl, Col="") {
	static SPRM_DELETECOL=0x46E	;Delete col. wParam=col, lParam=0
	if Col=
		Col := SS_GetCurrentCol(hCtrl)
	SendMessage,SPRM_DELETECOL,Col,,, ahk_id %hCtrl%
	return ErrorLevel 
}

/*

/*
	Function: DeleteRow
			  Delete row.

	Parameters:
			  Row - Row index. Of omited, current row is used.
  */
SS_DeleteRow(hCtrl, Row="") {
	static SPRM_DELETEROW=0x470	;Delete row. wParam=row, lParam=0
	if Row =
		Row := SS_GetCurrentRow(hCtrl)
	SendMessage,SPRM_DELETEROW,Row,,, ahk_id %hCtrl%
	return ErrorLevel 
}


/*
	Function: ExpandCell
			  Expand a cell to cover more than one cell.
	
	Parameters:
			  Left, Top, Right, Bottom	- Coordinates of the expanded cell.
  */
SS_ExpandCell(hCtrl, Left, Top, Right, Bottom ){
	static SPRM_EXPANDCELL=0x48E		;wParam=0, lParam=pointer to RECT struct
	VarSetCapacity(RECT, 16), NumPut(Left,  RECT),  NumPut(Top,RECT,4), NumPut(Right, RECT, 8), NumPut(Bottom, RECT, 12)
	SendMessage,SPRM_EXPANDCELL,,&RECT,, ahk_id %hCtrl%
	return ERRORLEVEL
}

/*
	Function: GetCell
			  Get the cell parameters.

	Parameters:
			  Col, Row	- Cell coordinates. If set to empty current cell coordinates will be used.
			  pQ		- Query parameter. See <SetCell> for the list of possible cell parameters (txt, data, w, h, bg, fg, type, state, txtal, imgal, fnt)
			  o1 .. o5	- Reference to variables to receive output in order specified in pQ parameter.

	Returns:	
			  o1, so you don't need to use reference variables to grab only 1 field i.e. state := SS_GetCell(hctrl, 1,1, "state").
  */
SS_GetCell(hCtrl, Col, Row, pQ, ByRef o1="", ByRef o2="", ByRef o3="", ByRef o4="", ByRef o5=""){
	static SPRM_GETCELLDATA=0x482				;wParam=0, lParam=Pointer to SPR_ITEM struct
	static SPRIF_TYPE=0x40,SPRIF_DATA=0x200,SPRIF_WIDTH=0x80,SPRIF_BACKCOLOR=1,SPRIF_TEXTCOLOR=2,SPRIF_TEXTALIGN=4,SPRIF_HEIGHT=0x100,SPRIF_STATE=0x20,SPRIF_FONT=0x10,SPRIF_IMAGEALIGN=8,SPRIF_COMPILE=0x80000000, SPRIF_DOUBLE=0x400, SPRIF_SINGLE=0x800
	static data="DATA", txt="DATA", w="WIDTH", h="HEIGHT", bg="BACKCOLOR", fg="TEXTCOLOR", state="STATE", txtal="TEXTALIGN", imgal="IMAGEALIGN", font="FONT", type="TYPE"
	static EMPTY=0, COLHDR=1, ROWHDR=2, WINHDR=3, TEXT=4, TEXTMULTILINE=5, INTEGER=6, FLOAT=7, FORMULA=8, GRAPH=9, HYPERLINK=10, CHECKBOX=11, COMBOBOX=12, OWNERDRAWBLOB=13, OWNERDRAWINTEGER=14, EXPANDED=15, BUTTON=16, WIDEBUTTON=0x20, DATE=0x30, FORCETEXT=0x44, FORCETYPE=0x40, FIXEDSIZE=0x80
	static _state=14.1,_bg=16,_fg=20,_txtal=24.1,_imgal=25.1,_fnt=26.1,_type=27.1, _txt=36,_data=36, _w=28, _h=32

 ;use col="-1" internally to pass ITEM pointer via row param if I have it already via different means (for instance onNotify)
	if Col=
		SS_GetCurrentCell(hCtrl, Col, Row)

	flag := SPRIF_TYPE
	StringSplit, a, pQ, %A_Space%, %A_Space%%A_Tab%
	loop, %a0%
	{
		f := a%A_Index%, f := %f%, f := SPRIF_%f%
		ifEqual,f, ,return A_ThisFunc ">Invalid parameter - " a%A_Index%
		flag |= f
	}

	VarSetCapacity(ITEM, 40, 0),  pItem := &ITEM
	NumPut(flag, ITEM),  NumPut(Col, ITEM, 4),   NumPut(Row,ITEM, 8)
	SendMessage,SPRM_GETCELLDATA,,&ITEM,, ahk_id %hCtrl%
	
	type  := NumGet(pITEM+27, 0, "UChar") & ~0xF0	;get base type
	pData := NumGet(pITEM+36)
	loop, %a0%
	{	
		field := a%A_Index%, offset := _%field%, t := SubStr(offset, -1)
		v := NumGet(pITEM + floor(offset), 0, t = ".1" ? "UChar" : "Uint")  

		if (field="txt"){
			if type in %INTEGER%,%OWNERDRAWINTEGER%
				 v := NumGet(pData+0)
			else if type in %FLOAT%,%FORMULA%
				 v := SS_getCellFloat(hCtrl, col, row)
			else if (type=COMBOBOX)
				 v := NumGet(pData+4)			
			else v := SS_strAtAdr(pData + (type=CHECKBOX || type=OWNERDRAWBLOB ? 4 : 0))
		} 

		if (field="data")
			if type in %CHECKBOX%,%COMBOBOX%,%OWNERDRAWBLOB%
				v := NumGet(pData+0)

		if SubStr(field, -1) = "al"
			field := "align"
		if field in type,state,align
			fun := "SS_get" field, v := %fun%( v )		

		o%A_Index% := v
	}
	return o1
}

/*
	Function: GetCellArray
			  Get all cell parameters into array.

	Parameters:
			  V	- Array prefix. The array is used to return data back. See <SetCell> for the list of possible cell parameters.
			  Col, Row	- Cell coordinates. If omited current cell coordinates will be used.

	Remarks:
			  To get individual fields, its faster to use <GetCell>. Also, this function creates global variables.
  */
SS_GetCellArray(hCtrl, V, Col="", Row=""){
	local ITEM, flag, pData, type, flag
	static SPRM_GETCELLDATA=0x482				;wParam=0, lParam=Pointer to SPR_ITEM struct
	static EMPTY=0, COLHDR=1, ROWHDR=2, WINHDR=3, TEXT=4, TEXTMULTILINE=5, INTEGER=6, FLOAT=7, FORMULA=8, GRAPH=9, HYPERLINK=10, CHECKBOX=11, COMBOBOX=12, OWNERDRAWBLOB=13, OWNERDRAWINTEGER=14, EXPANDED=15, BUTTON=16, WIDEBUTTON=0x20, DATE=0x30, FORCETEXT=0x44, FORCETYPE=0x40, FIXEDSIZE=0x80
	static SPRIF_TYPE=0x40,SPRIF_DATA=0x200,SPRIF_WIDTH=0x80,SPRIF_BACKCOLOR=1,SPRIF_TEXTCOLOR=2,SPRIF_TEXTALIGN=4,SPRIF_HEIGHT=0x100,SPRIF_STATE=0x20,SPRIF_FONT=0x10,SPRIF_IMAGEALIGN=8,SPRIF_COMPILE=0x80000000, SPRIF_DOUBLE=0x400, SPRIF_SINGLE=0x800
	flag := SPRIF_BACKCOLOR | SPRIF_TEXTCOLOR | SPRIF_TEXTALIGN | SPRIF_IMAGEALIGN | SPRIF_FONT | SPRIF_TYPE | SPRIF_STATE | SPRIF_DATA 

	if Col=
		SS_GetCurrentCell(hCtrl, Col, Row)

	VarSetCapacity(ITEM, 40, 0)
	NumPut(flag, ITEM, 0),  NumPut(Col, ITEM, 4),  NumPut(Row, ITEM, 8)					
	SendMessage,SPRM_GETCELLDATA,,&ITEM,, ahk_id %hCtrl%

	%V%_state	:= NumGet(ITEM, 14, "UChar"),	%V%_state := SS_getState(%V%_state)		;state		db ?    14

  ;FORMAT struct																			                                                                                 
	%V%_bg		:= NumGet(ITEM, 16)														;bckcol		dd ? 0 		;Back color                                         
	%V%_fg		:= NumGet(ITEM, 20)														;txtcol		dd ? 4		;Text color                                         
	%V%_txtal	:= NumGet(ITEM, 24,"UChar"), %V%_txtal := SS_getAlign(%V%_txtal)		;txtal		db ? 8		;Text alignment and decimals                        
	%V%_imgal	:= NumGet(ITEM, 25,"UChar"), %V%_imgal := SS_getAlign(%V%_imgal)		;imgal		db ? 9		;Image alignment and imagelist/control index        
	%V%_fnt		:= NumGet(ITEM, 26,"UChar")												;fnt		db ? 10		;Font index (0-15)                                  
	type		:= NumGet(ITEM, 27,"UChar")

	%V%_type := SS_getType(type)				;tpe		db ? 11	26	;Cell type                                          

	pData := NumGet(ITEM, 36),	%V%_data  := ""
	type &= ~0xF0
	ifEqual, type, %EXPANDED%, return

	if type in %CHECKBOX%,%COMBOBOX%,%OWNERDRAWBLOB%
	{
		%V%_data:= NumGet(pData+0)
		%V%_txt	:= type=COMBOBOX ? NumGet(pData+4) : SS_strAtAdr(pData + 4)
	} 
	else if type in %FLOAT%,%FORMULA%
		%V%_txt := SS_getCellFloat(hCtrl, col, row)		
	else if type in %INTEGER%,%OWNERDRAWINTEGER%
		%V%_txt	:= NumGet(pData+0)
	else 
		%V%_txt	:= SS_strAtAdr(pData)	;copy text
}


/*  Function: GetCellBlob
			  Returns pointer to the current cell BLOB.

	Parameters:
			  EArg	   - D event handlers event argument (pointer to DRAWITEM struct).
			  GetText? - Set to true to return text instead of binary data.
*/

SS_GetCellBLOB(EArg, GetText=false) {	
	pData := NumGet( NumGet(EArg+44)+36 )
	return GetText ? DllCall("MulDiv","UInt",pData+4,"UInt",1,"UInt",1, "str") : pData
}

/*
	Function: GetCellData
			  Get the cell data. 

	Parameters:
			  Col, Row	- Cell coordinates. If omited, current cell will be used.

	Remarks:
			  This funcion also returns data for OVERDRAWINTEGER type. Its faster to use to get the integer then other functions.
  */
SS_GetCellData(hCtrl, Col="", Row="") {
	static SPRM_GETCELLDATA=0x482, SPRIF_DATA=0x200, init
	if !init
		init++, VarSetCapacity(ITEM, 40, 0), NumPut(SPRIF_DATA, ITEM) 
	if Col=
		SS_GetCurrentCell(hCtrl, Col, Row)

	NumPut(Col, ITEM, 4),  NumPut(Row, ITEM, 8)
	SendMessage,SPRM_GETCELLDATA,,&ITEM,, ahk_id %hCtrl%
	return NumGet( NumGet(ITEM, 36) )
}


/*
	Function: GetCellRect
	Get the current cells rect in active splitt.

	Returns:
			Handle of active splitt window.
  */
SS_GetCellRect(hCtrl, ByRef top, ByRef left, ByRef right, ByRef bottom){
	static SPRM_GETCELLRECT=0x469		; wParam=0, lParam=pointer to RECT struct.
	
	VarSetCapacity(RECT, 16)
	SendMessage,SPRM_GETCELLRECT,0,&RECT,, ahk_id %hCtrl%
	left	:= NumGet(RECT, 0)
	top		:= NumGet(RECT, 4)
	right	:= NumGet(RECT, 8)
	bottom	:= NumGet(RECT, 12)
	return ERRORLEVEL
}

/*
	Function: GetCellText
			  Get cell text

	Parameters:
			  Col, Row	- Coordinates of the cell. If omited, current cell will be used.

	Remarks:
			  This function retrieves any kind of text from all types of cells, no matter the internal representation.
			  For ComboBox selected item will be returned and for CheckBox 1 or 0.
  */
SS_GetCellText(hCtrl, Col="", Row=""){
   ;fast version for GetCell but only for text
   static EMPTY=0, COLHDR=1, ROWHDR=2, WINHDR=3, TEXT=4, TEXTMULTILINE=5, INTEGER=6, FLOAT=7, FORMULA=8, GRAPH=9, HYPERLINK=10, CHECKBOX=11, COMBOBOX=12, OWNERDRAWBLOB=13, OWNERDRAWINTEGER=14, EXPANDED=15, BUTTON=16, WIDEBUTTON=0x20, DATE=0x30, FORCETEXT=0x44, FORCETYPE=0x40, FIXEDSIZE=0x80
   static SPRM_GETCELLDATA=0x482, SPRIF_DATA=0x200, SPRIF_TYPE=0x40
   static ITEM, init

   if !init
      init++, VarSetCapacity(ITEM, 40, 0), NumPut(SPRIF_DATA | SPRIF_TYPE, ITEM)

   if Col=
      SS_GetCurrentCell(hCtrl, Col, Row)

   NumPut(Col,   ITEM, 4), NumPut(Row, ITEM, 8)
   SendMessage,SPRM_GETCELLDATA,,&ITEM,, ahk_id %hCtrl%

   type := NumGet(ITEM, 27, "UChar") & ~0xF0   ;get base type

   if type=%COLHDR%
      return SS_strAtAdr( NumGet(ITEM, 36)+2 )

   if type in %TEXT%,%TEXTMULTILINE%,%HYPERLINK%,%CHECKBOX%,%OWNERDRAWBLOB%      ;GRAPH and FORMULA don't return text, I don't know how to get their text.
      return SS_strAtAdr( NumGet(ITEM, 36) + (type=CHECKBOX || type=OWNERDRAWBLOB ? 4 : 0))

   if type in %INTEGER%,%COMBOBOX%,%OWNERDRAWINTEGER%
   {
      pData := NumGet(ITEM, 36), txt := NumGet( pData+0 )
      if (type=COMBOBOX)      ;combobox, get the item from the listbox
      {
         hCombo := NumGet(pData + 4)
         old := A_DetectHiddenWindows
         DetectHiddenWindows, on
         ControlGet, lst, list,,, ahk_id %hCombo%
         DetectHiddenWindows, %old%
         loop, parse, lst, `n
            if (A_index = txt+1) {
               txt := A_LoopField
               break
            }
      }
      return txt
   }

   if type in %FLOAT%,%FORMULA%
       return SS_getCellFloat(hCtrl, col, row)
}

/*
	Function: GetCellType
			  Get cell data type

	Parameters:
			  Col, Row	- Coordinates. If omited, current cell will be used
			  Flag		- Used internaly. 1 to return numeric type, 2 to return numeric base type without modifiers
	Returns:
			  Number (not text for now)

  */
SS_GetCellType(hCtrl, Col="", Row="", Flag=0) {
	static SPRM_GETCELLTYPE=0x48F		;wParam=col, lParam=row. Returns cell type.

	if Col=
		SS_GetCurrentCell(hCtrl, Col, Row)

	SendMessage,SPRM_GETCELLTYPE,Col,Row,, ahk_id %hCtrl%
	return !Flag ? SS_getTYpe(ErrorLevel) : Flag=1 ? ErrorLevel : ErrorLevel & ~0xF0
}


/*
	Function: GetColCount
			  Get number of columns
  */
SS_GetColCount(hCtrl){
	static SPRM_GETCOLCOUNT=0x472
	SendMessage,SPRM_GETCOLCOUNT,0,0,, ahk_id %hCtrl% 
	return ErrorLevel 
}

/*
	Function: GetColWidth
	Get column width. 
  */
SS_GetColWidth(hCtrl, col){
	static SPRM_GETCOLWIDTH=0x47E		;wParam=col, lParam=0. Returns column width.
	SendMessage,SPRM_GETCOLWIDTH,col,,, ahk_id %hCtrl%
	return ERRORLEVEL
}

/*
	Function:	GetCurrentCell
				Get current cell in active window.

	Parameters:
				Col, Row - Reference to variables to receive output.
  */
SS_GetCurrentCell(hCtrl, ByRef Col, ByRef Row) {
	static SPRM_GETCURRENTCELL=0x47A		; wParam=0, lParam=0. Returns Hiword=row, Loword=col
	SendMessage,SPRM_GETCURRENTCELL,,,, ahk_id %hCtrl%
	VarSetCapacity(s, 4), NumPut(ERRORLEVEL, s), col := NumGet(s, 0, "UShort"), row := NumGet(s, 2, "UShort")
}

/*
	Function:	GetCurrentCol
				Get current column in active window. 

	Returns:
				Current column index.
  */
SS_GetCurrentCol(hCtrl) {
 	static SPRM_GETCURRENTCELL=0x47A		;wParam=0, lParam=0. Returns Hiword=row, Loword=col
	SendMessage,SPRM_GETCURRENTCELL,,,, ahk_id %hCtrl%
	VarSetCapacity(s, 4), NumPut(ERRORLEVEL, s)
	return NumGet(s, 0, "UShort")
}


/*
	Function: GetCurrentRow
	Get current row in active window. 

	Returns:
			Current row index.
  */
SS_GetCurrentRow(hCtrl) {
	static SPRM_GETCURRENTCELL=0x47A		;GwParam=0, lParam=0. Returns Hiword=row, Loword=col
	SendMessage,SPRM_GETCURRENTCELL,,,, ahk_id %hCtrl%
	VarSetCapacity(s, 4), NumPut(ERRORLEVEL, s)
	return NumGet(s, 2, "UShort")
}


/*
	Function: GetCurrentWin
	Get active splitt window.
  */
SS_GetCurrentWin(hCtrl){
	static SPRM_GETCURRENTWIN=0x478			; wParam=0, lParam=0
	SendMessage,SPRM_GETCURRENTWIN,,,, ahk_id %hCtrl%
	return ERRORLEVEL
}

/*
	Function: GetDateFormat
			  Get date format.	
  */
SS_GetDateFormat(hCtrl) {
	static SPRM_GETDATEFORMAT=0x494	;Returns date format string. wParam=0, lParam=0
	SendMessage,SPRM_GETDATEFORMAT,,,, ahk_id %hCtrl%
	return SS_strAtAdr(ErrorLevel)
}

/*
   Function: GetGlobalFields
			 Get individual global parameters from the control.
	
   Parameters:
			 Fields -   White space separated list of field names to get.
			 v1 .. v7 - Field values, respecting the order of names in fields argument.

   Example:
  >			SS_GetGlobalFields(hCtrl, "nrows ncols", rows, cols)
 */
SS_GetGlobalFields(hCtrl, Fields, ByRef v1="", ByRef v2="", ByRef v3="", ByRef v4="", ByRef v5="", ByRef v6="", ByRef v7="") {
   static SPRM_SETGLOBAL=0x489, SPRM_GETGLOBAL=0x488      ; wParam=0, lParam=cols
   static colhdrbtn=0,rowhdrbtn=4,winhdrbtn=8,lockcol=12,hdrgrdcol=16,grdcol=20,bcknfcol=24,txtnfcol=28,bckfocol=32,txtfocol=36,ncols=40,nrows=44,ghdrwt=48,ghdrht=52,gcellw=56,gcellht=60
   static _bg=0, _fg=4, _txtal=8.1, _imgal=9.1, _fnt=10.1, _tpe=11.1
   static colhdr=64, rowhdr=76, winhdr=88, cell=100
   static LEFT=0x10, CENTER=0x20, RIGHT=0x30, MIDDLE=0x40, BOTTOM=0x80, GLOBAL=0xF0, MASK=0xF0, XMASK=0x30, YMASK=0xC0
   static alignments := "LEFT CENTER RIGHT MIDDLE BOTTOM"

   VarSetCapacity(GLOBAL, 112, 0)
   SendMessage,SPRM_GETGLOBAL,0,&GLOBAL,, ahk_id %hCtrl%

   loop, parse, Fields, %A_Space%%A_Tab%
   {
      field := A_LoopField
      if (j := InStr(field, "_"))
           offset := SubStr(field, 1, j-1),  offset := %offset%, _ := SubStr(field, j), _ := %_%,  offset += floor(_), t := SubStr(_, -1)
      else offset := %field%
      ifEqual, offset, ,return A_ThisFunc "> Invalid field name - " field

      v := NumGet(GLOBAL, offset, t=".1" ? "UChar" : "Uint" )
      if InStr(field, "al") {
         v%a_index% := ""
         loop, parse, alignments, %A_Space%
            if ( v & %A_LOOPFIELD% )
               v%a_index% .= A_LOOPFIELD " "
      } else
         v%a_index% := v
   }
   return ERRORLEVEL
}

/*
	Function: GetLockCol
	Get lock cols in active splitt.
  */
SS_GetLockCol(hCtrl){
	static SPRM_GETLOCKCOL=0x46A	; wParam=0, lParam=0
	SendMessage,SPRM_GETLOCKCOL,,,, ahk_id %hCtrl%
	return ERRORLEVEL
}

/*
	Function: GetLockRow
	Get lock rows in active splitt.
  */
SS_GetLockRow(hCtrl){
	static SPRM_GETLOCKROW=0x46C	; wParam=0, lParam=0
	SendMessage,SPRM_GETLOCKROW,,,, ahk_id %hCtrl%
	return ERRORLEVEL
}

/*
	Function: GetMultiSel
			  Get multiselection.

	Parameters:
			  Top, Left, Right, Bottm	- Reference to variables to receive the output. You can omit any you don't need.
  */
SS_GetMultiSel(hCtrl, ByRef Top="", ByRef Left="", ByRef Right="", ByRef Bottom=""){
	static SPRM_GETMULTISEL=0x484		;wParam=0, lParam=pointer to a RECT struct.
	VarSetCapacity(RECT, 16)
	SendMessage,SPRM_GETMULTISEL,0,&RECT,, ahk_id %hCtrl%
	Left := NumGet(RECT, 0), Top := NumGet(RECT, 4), Right := NumGet(RECT, 8), Bottom := NumGet(RECT, 12)
	return ERRORLEVEL
}

/*
	Function: GetRowCount
			  Get number of rows.
  */
SS_GetRowCount(hCtrl){ 
	static SPRM_GETROWCOUNT=0x474
	SendMessage,SPRM_GETROWCOUNT,0,0,, ahk_id %hCtrl% 
	return ErrorLevel 
}

/*
	Function: GetRowHeight
			  Returns row height.
  */
SS_GetRowHeight(hCtrl, Row) {
	static SPRM_GETROWHEIGHT=0x480		;wParam=row, lParam=0
	SendMessage,SPRM_GETROWHEIGHT,Row,,, ahk_id %hCtrl%
	return ErrorLevel 
}



/*
	Function: ImportLine
			   Import a line of data.
	
	Parameters:
			  DataLine	- Text containing the data.
			  SepChar	- Data separator, by default ";".
  */
SS_ImportLine(hCtrl, DataLine, SepChar=";") {
	static SPRM_IMPORTLINE=0x48A ; wParam=SepChar, lParam=pointer to data line.
	SendMessage,SPRM_IMPORTLINE,asc(SepChar),&DataLine,, ahk_id %hCtrl%
	return ERRORLEVEL
}

/*
	Function: InsertCol
			  Insert column.

	Parameters:
			  Col - Column index after which to insert column. By deault -1 means to append it.
  */
SS_InsertCol(hCtrl, Col=-1) {
	static SPRM_INSERTCOL=0x46F		;wParam=col, lParam=0

	if Col=-1
		Col := SS_GetColCount(hCtrl)+1

	SendMessage,SPRM_INSERTCOL,Col,,, ahk_id %hCtrl%
	return ErrorLevel 
}

/*
	Function: InsertRow
			  Insert row.
	
	Parameters:
			  Row	- Position after which to insert row. By deault -1 means to append it.
  */
SS_InsertRow(hCtrl, Row=-1) {
	static SPRM_INSERTROW=0x471	;wParam=row, lParam=0

	if Row=-1
		row := SS_GetRowCount(hCtrl)+1

	SendMessage,SPRM_INSERTROW,Row,,, ahk_id %hCtrl%
	return ErrorLevel 
}

/*
	Function: LoadFile
			  Load a file.
	
	Parameters:
			  File	- File name.

  */
SS_LoadFile(hCtrl, File) {
	static SPRM_LOADFILE=0x48B	;wParam=0, lParam=pointer to filename
	SendMessage,SPRM_LOADFILE,,&File,, ahk_id %hCtrl%
	return ERRORLEVEL
}

/*
	Function: NewSheet
	Clears the sheet.
  */
SS_NewSheet(hCtrl) {
	static SPRM_NEWSHEET=0x48D		; wParam=0, lParam=0
	SendMessage,SPRM_NEWSHEET,,,, ahk_id %hCtrl%
	return ErrorLevel 	
}

/*
	Function: ReCalc
			  Recalculates the sheet.
  */
SS_ReCalc(hCtrl){
	static SPRM_RECALC=0x476		
	SendMessage,SPRM_RECALC,,,, ahk_id %hCtrl%
	return ERRORLEVEL
}

/*
	Function: Redraw
			  Redraw the control.
  */
SS_Redraw(hCtrl){
	static RDW_ALLCHILDREN:=0x80, RDW_INVALIDATE:=0x1
	return DllCall("RedrawWindow", "uint", hCtrl, "uint", 0, "uint", 0, "uint", RDW_INVALIDATE | RDW_ALLCHILDREN)
}

/*
	Function: SaveFile
			  Save a file.
  */
SS_SaveFile(hCtrl, File){
	static SPRM_SAVEFILE=0x48C	;wParam=0, lParam=pointer to filename
	SendMessage,SPRM_SAVEFILE,,&File,, ahk_id %hCtrl%
	return ERRORLEVEL
}

/*
	Function: ScrollCell
			  Scrolls current cell into view.
  */
SS_ScrollCell(hCtrl) {
	static SPRM_SCROLLCELL=0x492
	SendMessage,SPRM_SCROLLCELL,,,, ahk_id %hCtrl%
	return ERRORLEVEL
}

/*
	Function: SetCell
			  Set content of the cell.

	Parameters:
			  Col, Row	- Cell coordinates.
			  o1 .. o11	- Named parameters.
	
	Named Parameters:
			  type		- Type of the cell. See bellow for list of types. You will generally use type when setting up cells initially and omit it when changing existing cells.
			  w, h	    - Width, height of the cell.
			  bg, fg	- Background, foreground color.
			  state		- Cell state.
			  txtal		- Text alignment and decimals. See aligment section for list of kewords. Use number to set FLOAT precision (1-12, all, sci).
			  imgal		- Image alignment  and imagelist/control index .
			  fnt		- Cell font index (0-15).

	Type Dependent Named Parameters:
			  txt		- String (TEXT,CHECKBOX,*HDR), Number (INTEGER), hwndCombo (COMBOBOX), Formula Definition (FORMULA), Graph Definition (GRAPH)
			  data		- 0-based selected index, 0 by default (COMBOBOX), 1|0 (CHECKBOX), size (OVERDRAWBLOB, return)

	Types:
			o TEXT TEXTMULTILINE INTEGER(32b) FLOAT(32b-80b) HYPERLINK CHECKBOX COMBOBOX FORMULA GRAPH
			o OWNERDRAWINTEGER - Ownerdraw integer. You can implement D (draw) event.
			o OWNERDRAWBLOB	- Ownerdraw BLOB. You can put any binary data as cell's BLOB content. There is special support for textual BLOBs.
			o EMPTY	- The cell contains formatting only.
			o COLHDR ROWHDR WINHDR	- Column, row and window (splitt) header.
			o EXPANDED - Part of expanded cell, internally used.

	Type Modifiers:
	
			BUTTON		- The cell contains button. Can be combined with TEXT or TEXTMULTILINE.
			WIDEBUTTON	- The cell will be entirely covered by button. Can be combined with TEXT or TEXTMULTILINE.
			DATE		- Can be combined with INTEGER.
			FORCETYPE	- The cell will preserve its type when edited.
						  Can be combined with TEXT, INTEGER, FLOAT, TEXTMULTILINE, BUTTON, WIDEBUTTON or HYPERLINK.
			FIXEDSIZE	- Will force a 15 by 15 pixel image. To be combined with BUTTON, CHECKBOX or COMBOBOX. 
						  Can be combined with BUTTON, CHECKBOX or COMBOBOX	.	

	States:
			LOCKED - Cell is locked for editing.
			HIDDEN - Cell content is not displayed.
			REDRAW - Cell is being redrawn.
			RECALC - Cell is being recalculated.
			ERROR  - There are 4 error states: ERROR DIV0 UNDERFLOW OVERFLOW.
			
	Aligments:
			LEFT RIGHT MIDDLE - X aligments.
			TOP CENTER BOTTOM - Y aligments.
			AUTO - Text left middle, numbers right middle.
			GLOBAL	- If you omit aligment attribute, this one will be used.
  */
SS_SetCell(hCtrl, Col="", Row="", o1="", o2="", o3="", o4="", o5="", o6="", o7="", o8="", o9="", o10="", o11=""){
	static SPRM_SETCELLDATA=0x483, SPRM_GETCELLDATA=0x482, SPRM_GETCELLTYPE=0x48F, WM_DRAWITEM := 0x02B, initOverDraw
	static EMPTY=0, COLHDR=1, ROWHDR=2, WINHDR=3, TEXT=4, TEXTMULTILINE=5, INTEGER=6, FLOAT=7, FORMULA=8, GRAPH=9, HYPERLINK=10, CHECKBOX=11, COMBOBOX=12, OWNERDRAWBLOB=13, OWNERDRAWINTEGER=14, BUTTON=16, WIDEBUTTON=0x20, DATE=0x30, FORCETEXT=0x44, FORCETYPE=0x40, FIXEDSIZE=0x80
	static SPRIF_TYPE=0x40,SPRIF_DATA=0x200,SPRIF_WIDTH=0x80,SPRIF_BACKCOLOR=1,SPRIF_TEXTCOLOR=2,SPRIF_TEXTALIGN=4,SPRIF_HEIGHT=0x100,SPRIF_STATE=0x20,SPRIF_FONT=0x10,SPRIF_IMAGEALIGN=8,SPRIF_COMPILE=0x80000000, SPRIF_DOUBLE=0x400, SPRIF_SINGLE=0x800
	static TOP=0, LEFT=0x10, CENTER=0x20, RIGHT=0x30, MIDDLE=0x40, BOTTOM=0x80, GLOBAL=0xF0, ALL=13, SCI=14		;aligments																
	static LOCKED=1, HIDDEN=2, REDRAW=8

  ;named parameters:  txt, data, w, h, bg, fg, type, state, txtal, imgal, fnt
	txt := "~`a "
	loop, 10 {
		ifEqual, o%A_Index%,,break
		j := InStr( o%A_index%, "=" ), 	prop := SubStr(	o%A_index%, 1, j-1 ), %prop% := SubStr( o%A_index%, j+1, StrLen(o%A_Index%))
		if prop in type,state,imgal,txtal								
		{																	
			p := "h" prop,  s := %prop%,  %p% := 0
			loop, parse, s, %A_Tab%%A_Space%
				if A_LoopField is integer
					 %p% |= A_LoopField
				else %p% |= %A_LOOPFIELD%
		}	
	}
    flag := 0
	 ,flag |= (data!=""||txt!="~`a ") ? SPRIF_DATA  : 0
	 ,flag |= (type!="")	? SPRIF_TYPE		: 0
	 ,flag |= (w != "")		? SPRIF_WIDTH		: 0
	 ,flag |= (h != "")		? SPRIF_HEIGHT		: 0
	 ,flag |= (bg!= "")		? SPRIF_BACKCOLOR	: 0
	 ,flag |= (fg!= "")		? SPRIF_TEXTCOLOR	: 0
	 ,flag |= (state !="")	? SPRIF_STATE		: 0
	 ,flag |= (txtal != "")	? SPRIF_TEXTALIGN	: 0
	 ,flag |= (imgal != "")	? SPRIF_IMAGEALIGN	: 0
	 ,flag |= (fnt != "")	? SPRIF_FONT		: 0

	VarSetCapacity(ITEM, 40, 0), NumPut(Col, ITEM, 4),  NumPut(Row, ITEM, 8)
	if type =					;user is changing the cell
	{	
		bChange := true
		SendMessage,SPRM_GETCELLTYPE,Col,Row,, ahk_id %hCtrl%
		hType := ErrorLevel
	}
	
	type := hType & ~0xF0		;get the base type
	if type in %FORMULA%,%GRAPH%
		flag |= SPRIF_COMPILE
	
	if type = %FLOAT%
		flag |= SPRIF_SINGLE,  NumPut(txt, txt, 0, "Float")

	if type in %INTEGER%,%OWNERDRAWINTEGER%
		NumPut(txt,txt)

	if type in %OWNERDRAWINTEGER%,%OWNERDRAWBLOB%
	{
		if !initOverDraw
		{
			old := OnMessage(WM_DRAWITEM, "SS_onDrawItem")
			if old != SS_onDrawItem
				SS("oldDrawItem", RegisterCallback(old))
		}

		if type=%OWNERDRAWBLOB%
			data := StrLen(txt)+3			;first word is size of the blob + 1 for \0 of txt.
	}
	
	if type in %COMBOBOX%,%CHECKBOX%,%OWNERDRAWBLOB%
	{
		; in this case both txt and data must be set at the same time, so if user didn't provide one, get it.
		if (bChange && (txt="~`a " || data=""))
		{
			NumPut(SPRIF_DATA, ITEM)
			SendMessage,SPRM_GETCELLDATA,,&ITEM,, ahk_id %hCtrl%
			pData := NumGet(ITEM, 36)
			if (data != "") 
				 txt := type=COMBOBOX ? NumGet(pData+4) : SS_strAtAdr(pData + 4)
			else data := NumGet(pData,36)
		}	
		ifEqual, txt, ~`a , SetEnv, txt

		if (type = COMBOBOX)
			NumPut(txt,txt)		;put combobox handle as txt
		txt := "1234" txt,   NumPut(data, txt)			;make the room for the data and insert index
	}
	
	NumPut(flag,  ITEM)
	NumPut(hState,ITEM, 14)
	;FORMAT struct
	NumPut(bg,	  ITEM, 16)				  
	NumPut(fg,	  ITEM, 20)				  
	NumPut(htxtal,ITEM, 24,"UChar")		  
	NumPut(himgal,ITEM, 25,"UChar")		  
	NumPut(fnt,	  ITEM, 26,"UChar")		  
	NumPut(hType, ITEM, 27,"UChar")		  
	NumPut(w,	  ITEM, 28)
	NumPut(h,	  ITEM, 32)
	NumPut(&txt,  ITEM, 36)

	SendMessage,SPRM_SETCELLDATA,,&ITEM,, ahk_id %hCtrl% 
	return ErrorLevel 
}

/*
	Function:	SetCellData
				Set the data of the cell.
	
	Parameters:
				Data - Data to set.
				Col,Row - Cell coordinates. If omited current cell will be used.
  */
SS_SetCellData(hCtrl, Data, Col="", Row="") {
	static SPRM_SETCELLDATA=0x483, SPRM_GETCELLDATA=0x482, SPRIF_DATA=0x200, init
	if !init
		init++, VarSetCapacity(ITEM, 40, 0), NumPut(SPRIF_DATA, ITEM) 
	if Col=
		SS_GetCurrentCell(hCtrl, Col, Row)

	NumPut(Col, ITEM, 4),  NumPut(Row, ITEM, 8)
	SendMessage,SPRM_GETCELLDATA,,&ITEM,, ahk_id %hCtrl%
	NumPut( Data, NumGet(ITEM, 36)+0)
	SendMessage,SPRM_SETCELLDATA,,&ITEM,, ahk_id %hCtrl%
}

/*
	Function: SetCellBLOB
			  Set the cell binary data.

	Parameters:
			  BLOB		- Reference to binary data to set. First word contains BLOB size.
			  Col, Row	- Cell coordinates. If omited current cell coordinates will be used.
			  
  */
SS_SetCellBLOB(hCtrl, ByRef BLOB, Col="", Row="") {
	static SPRM_SETCELLDATA=0x483, SPRIF_DATA=0x200, init
	if !init
		init++, VarSetCapacity(ITEM, 40, 0), NumPut(SPRIF_DATA, ITEM) 
	if Col=
		SS_GetCurrentCell(hCtrl, Col, Row)

	NumPut(Col, ITEM, 4), NumPut(Row, ITEM, 8), NumPut(&BLOB, ITEM, 36)
	SendMessage,SPRM_SETCELLDATA,,&ITEM,, ahk_id %hCtrl%
	return ErrorLevel
}

/*
	Function:	SetCellString
				Set the text of the selected cell.
	
	Parameters:
				Txt -  Text to set, by default empty.
				Type - Type. If omited current cell type will be used.	
  */
SS_SetCellString(hCtrl, Txt="", Type=""){
	static SPRM_SETCELLSTRING=0x47D		; wParam=type, lParam=pointer to string.
	if Type=
		Type := SS_GetCellType(hCtrl, "", "", 1)
	SendMessage,SPRM_SETCELLSTRING,Type,&txt,, ahk_id %hCtrl%
	return ERRORLEVEL
}

/*
	Function: SetColWidth
			  Set column width.
  */
SS_SetColWidth(hCtrl, Col, Width){
	static SPRM_SETCOLWIDTH=0x47F	
	SendMessage,SPRM_SETCOLWIDTH,Col,Width,, ahk_id %hCtrl%
	return ERRORLEVEL
}

/*
	Function:	SetCurrentCell
				Set current cell in the active window.

	Parameters:
				Col, Row	- Coordinates of the cell to select.
  */
SS_SetCurrentCell(hCtrl, Col, Row) {
	static SPRM_SETCURRENTCELL=0x47B		;wParam=col, lParam=row
	SendMessage,SPRM_SETCURRENTCELL,Col,Row,, ahk_id %hCtrl%
	return ErrorLevel 
}

/*
	Function:	SetCurrentWin
				Set active splitt window.
	
	Parameters:
				Win	- Window number (0-7).
  */
SS_SetCurrentWin(hCtrl, Win){
	static	SPRM_SETCURRENTWIN=0x479		;wParam=0, lParam=nWin (0-7)
	SendMessage,SPRM_SETCURRENTWIN,,Win,, ahk_id %hCtrl%
	return ERRORLEVEL
}


/*
	Function: SetDateFormat
			  Set date format.
	
	Parameters:
			  Format - Date format. See Date Formats section in FormatTime AHK documentation for details.
  */
SS_SetDateFormat(hCtrl, Format) {
	static SPRM_SETDATEFORMAT=0x495		;Sets date format string. wParam=0, lParam=lpDateFormat (yyyy-MM-dd)
	SendMessage,SPRM_SETDATEFORMAT,,&Format,, ahk_id %hCtrl%
	return ErrorLevel
}

/*
	Function: SetColCount
			  Set number of columns.
  */
SS_SetColCount(hCtrl, nCols){
	static SPRM_SETCOLCOUNT=0x473
	SendMessage,SPRM_SETCOLCOUNT,nCols,0,, ahk_id %hCtrl% 
	return ErrorLevel 
}

/*
	Function: SetFont
			  Set font.
	
	Parameters:
			  Idx	- Font index to set (0-15).
			  Font	- Font description in usual AHK format ( "style, name").

	Returns:
			  Font handle
  */
SS_SetFont(HCtrl, Idx, Font) {
	static SPRM_SETFONT=0x487		;wParam=index, lParam=pointer to FONT struct. Returns font handle
	

	StringSplit, Font, Font, `,,%A_Space%%A_Tab%
	fontStyle := Font1, fontFace := Font2

 ;parse font 
    italic      := InStr(fontStyle, "italic")    ?  1 : 0 
    underline   := InStr(fontStyle, "underline") ?  1 : 0 
    strikeout   := InStr(fontStyle, "strikeout") ?  1 : 0 
    bold		:= InStr(fontStyle, "bold")      ?  1 : 0

 ;height 
    RegExMatch(fontStyle, "S)(?<=[S|s])(\d{1,2})(?=[ ,]*)", height) 
    ifEqual, height,, SetEnv, height, 0 

    RegRead, LogPixels, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows NT\CurrentVersion\FontDPI, LogPixels 
    height := -DllCall("MulDiv", "int", Height, "int", LogPixels, "int", 72) 

	VarSetCapacity(FONT,48,0 )
	DllCall("RtlMoveMemory", "uint", &FONT+4, "str", fontFace, "uint", StrLen(fontFace))

	NumPut(height,	  FONT, 40)				;	ht			40	dd ?					;Height   
	NumPut(bold,	  FONT, 44,"UChar")		;	bold		44	db ?					;Bold   
	NumPut(italic,	  FONT, 45,"UChar")		;	italic		45	db ?					;Italics 
	NumPut(underline, FONT, 46,"UChar")		;	underline	46	db ?					;Underline    
	NumPut(strikeout, FONT, 47,"UChar")		;	strikeout	47	db ?					;Strikeout    

	SendMessage,SPRM_SETFONT,Idx,&FONT,, ahk_id %hCtrl%
	return ErrorLevel 	
}

/*
	Function: SetGlobal
			  Set all global parameters for the control.

	Parameters:
				g		- Global formating array base name.
				cell	- Cell formatting array base name.
				colhdr	- Column header formatting array base name.
				rowhdr	- Row header formatting array base name.
				winhdr	- Window header formatting array base name.

	Global array elements:
				colhdrbtn	- Column header button.
				rowhdrbtn	- Row header button.
				winhdrbtn	- Win header button.
				lockcol     - Back color of locked cell.
				hdrgrdcol	- Header grid color.                    
				grdcol		- Cell grid color.
				bcknfcol	- Back color of active cell, lost focus.
				txtnfcol	- Text color of active cell, lost focus.
				bckfocol	- Back color of active cell, has focus.
				txtfocol	- Text color of active cell, has focus. 
				ncols		- Number of columns,  0-600, by default 255.
				nrows		- Number of rows, 0-65000, by default 255.
				ghdrwt		- Header width.
				ghdrht		- Header height.
				gcellw		- Cell width.
				gcellht		- Cell height.

	Header and cell formating elements:
				bg			- Background color.
				fg			- Foreground color.
				imgal		- Image align.
				txtal		- Text align.	
				fnt			- Font index.
				tpe			- Control type.

  */
SS_SetGlobal(hCtrl, g, cell, colhdr, rowhdr, winhdr) {
	local p, N, s, params, himgal, htxtal
	static SPRM_SETGLOBAL=0x489		; wParam=0, lParam=pointer to GLOBAL struct.
	static LEFT=0x10, CENTER=0x20, RIGHT=0x30, MIDDLE=0x40, BOTTOM=0x80, GLOBAL=0xF0, MASK=0xF0, XMASK=0x30, YMASK=0xC0					;formats
	static params = "colhdr rowhdr winhdr cell"

	VarSetCapacity(GLOBAL, 112, 0)							;GLOBAL struct                                                                                                 	 
	ifEqual,%g%_ncols, ,SetEnv,%g%_ncols, 255
	ifEqual,%g%_nrows, ,SetEnv,%g%_nrows, 255

	NumPut(%g%_colhdrbtn   ,GLOBAL,  00)                               
	NumPut(%g%_rowhdrbtn   ,GLOBAL,  04)                                  
	NumPut(%g%_winhdrbtn   ,GLOBAL,  08)                                  
	NumPut(%g%_lockcol     ,GLOBAL,  12)   
	NumPut(%g%_hdrgrdcol   ,GLOBAL,  16)   
	NumPut(%g%_grdcol      ,GLOBAL,  20)   
	NumPut(%g%_bcknfcol    ,GLOBAL,  24)   
	NumPut(%g%_txtnfcol    ,GLOBAL,  28)   
	NumPut(%g%_bckfocol    ,GLOBAL,  32)   
	NumPut(%g%_txtfocol    ,GLOBAL,  36)   
	NumPut(%g%_ncols       ,GLOBAL,  40)                                
	NumPut(%g%_nrows       ,GLOBAL,  44)                                
	NumPut(%g%_ghdrwt      ,GLOBAL,  48)                                
	NumPut(%g%_ghdrht      ,GLOBAL,  52)                                
	NumPut(%g%_gcellw      ,GLOBAL,  56)                                
	NumPut(%g%_gcellht     ,GLOBAL,  60)                                
														
	N := 52											
	loop, parse, params, %A_Space%							;colhdr    64	FORMAT <12>				;Column header formatting  	
	{												 		;rowhdr	   76	FORMAT <12>             ;Row header formatting     
		N+=12,  p := %A_LoopField%							;winhdr	   88	FORMAT <12>             ;Window header formatting  
		ifEqual,p,,continue									;cell	   100	FORMAT <12>				;Cell formatting           
		s := %p%_txtal,  htxtal := 0
		loop, parse, s, %A_Tab%%A_Space%	
			htxtal |= %A_LOOPFIELD%

		s := %p%_imgal,  himgal := 0
		loop, parse, s, %A_Tab%%A_Space%	
			himgal |= %A_LOOPFIELD%

		NumPut( %p%_bg	, GLOBAL, N+0)								
		NumPut( %p%_fg	, GLOBAL, N+4)
		NumPut( htxtal,   GLOBAL, N+8, "UChar" )	
		NumPut( himgal,   GLOBAL, N+9, "UChar")	
		NumPut( %p%_fnt	, GLOBAL, N+10,"UChar" )	
		NumPut( %p%_tpe	, GLOBAL, N+11,"UChar" )	
	}
	SendMessage,SPRM_SETGLOBAL,0,&GLOBAL,, ahk_id %hCtrl%
	return ERRORLEVEL
}

/*
	Function: SetGlobalFields
			  Set individual global parameters for the control.
			 
	Parameters:
			  fields -	White space separated list of field names to set.
			  v1 .. v7 - Field values, respecting the order of names in fields argument.

	Example:x
 >			SS_SetGlobalFields(hCtrl, "nrows ncols", 2, 2)
 >			SS_SetGlobalFields(hCtrl, "cell_txtal", "RIGHT MIDDLE")
 */
SS_SetGlobalFields(hCtrl, Fields, v1="", v2="", v3="", v4="", v5="", v6="", v7="") {
	static SPRM_SETGLOBAL=0x489, SPRM_GETGLOBAL=0x488		; wParam=0, lParam=cols
	static colhdrbtn=0,rowhdrbtn=4,winhdrbtn=8,lockcol=12,hdrgrdcol=16,grdcol=20,bcknfcol=24,txtnfcol=28,bckfocol=32,txtfocol=36,ncols=40,nrows=44,ghdrwt=48,ghdrht=52,gcellw=56,gcellht=60
	static _bg=0, _fg=4, _txtal=8.1, _imgal=9.1, _fnt=10.1, _tpe=11.1
	static colhdr=64, rowhdr=76, winhdr=88, cell=100
	static LEFT=0x10, CENTER=0x20, RIGHT=0x30, MIDDLE=0x40, BOTTOM=0x80, GLOBAL=0xF0, MASK=0xF0, XMASK=0x30, YMASK=0xC0	

	VarSetCapacity(GLOBAL, 112, 0)
	SendMessage,SPRM_GETGLOBAL,0,&GLOBAL,, ahk_id %hCtrl%

	loop, parse, Fields, %A_Space%%A_Tab%
	{
		field := A_LoopField
		if (j := InStr(field, "_"))
			  offset := SubStr(field, 1, j-1),  offset := %offset%, _ := SubStr(field, j), _ := %_%,  offset += floor(_), t := SubStr(_, -1)
		else  offset := %field%
		ifEqual, offset, ,return A_ThisFunc ": Invalid field name - " field

		v := v%A_Index%
		if InStr(field, "al") {
			align := 0
			loop, parse, v, %A_Tab%%A_Space%	
				align |= %A_LOOPFIELD%
			v := align
		}
		NumPut(v, GLOBAL, offset, t=".1" ? "UChar" : "Uint" )  
	}

	SendMessage,SPRM_SETGLOBAL,0,&GLOBAL,, ahk_id %hCtrl%
	return ERRORLEVEL
}

/*
	Function: SetLockCol
			  Lock columns in active split.

	Parameter:
			  Cols	- Number of columns to lock.
  */
SS_SetLockCol(hCtrl, Cols=1) {
	static SPRM_SETLOCKCOL = 0x46B	;L wParam=0, lParam=cols
	SendMessage,SPRM_SETLOCKCOL,0,Cols,, ahk_id %hCtrl%
	return ERRORLEVEL
}

/*
	Function: SetLockRow
			  Lock rows in active split.		
	
	Parameter:
			  Rows	- Number of rows to lock.
  */
SS_SetLockRow(hCtrl, Rows=1) {
	static SPRM_SETLOCKROW = 0x46D	; wParam=0, lParam=rows
	SendMessage,SPRM_SETLOCKROW,,Rows,, ahk_id %hCtrl%
	return ERRORLEVEL
}

/*
	Function: SetMultiSel
			  Set multiselection	
  */
SS_SetMultiSel(hCtrl, Left, Top, Right, Bottom ){
	static SPRM_SETMULTISEL=0x485		;wParam=0, lParam=pointer to a RECT struct. 

	VarSetCapacity(RECT, 16), NumPut(left, RECT, 0), NumPut(top, RECT, 4),  NumPut(right, RECT, 8),	NumPut(bottom,RECT, 12)
	SendMessage,SPRM_SETMULTISEL,,&RECT,, ahk_id %hCtrl%
	return ERRORLEVEL
}
/*
	Function: SetRowCount
			  Set number of rows.
  */
SS_SetRowCount(hCtrl, nRows){
	static SPRM_SETROWCOUNT=0x475
	SendMessage,SPRM_SETROWCOUNT,nRows,,, ahk_id %hCtrl% 
	return ErrorLevel 
}

/*
	Function: SetRowHeight
			  Set row height.

	Parameters:
			  Row	 - Index of the row, by default 0 (header)
			  Height - Height of the row, by default 0.
  */
SS_SetRowHeight(hCtrl, Row=0, Height=0) {
	static SPRM_SETROWHEIGHT=0x481		; wParam=row, lParam=height.
	SendMessage,SPRM_SETROWHEIGHT,Row,Height,, ahk_id %hCtrl%
	return ErrorLevel 
}


/*
	Function: SplittHor
	Create horizontal splitt in current splitt at current row.
  */
SS_SplittHor(hCtrl) {
	static SPRM_SPLITTHOR=0x464		; wParam=0, lParam=0
	SendMessage,SPRM_SPLITTHOR,,,, ahk_id %hCtrl%
	return ERRORLEVEL
}

/*
	Function: SplittVer
	Create vertical splitt in current splitt at current col.
  */
SS_SplittVer(hCtrl) {
	static SPRM_SPLITTVER=0x465		;wParam=0, lParam=0
	SendMessage,SPRM_SPLITTVER,,,, ahk_id %hCtrl%
	return ERRORLEVEL
}

/*
	Function: SplittClose
	Close the current splitt.
  */
SS_SplittClose(hCtrl) {
	static SPRM_SPLITTCLOSE=0x466	; wParam=0, lParam=0
	SendMessage,SPRM_SPLITTCLOSE,,,, ahk_id %hCtrl%
	return ERRORLEVEL
}

/*
	Function:	SplittSync
				Synchronizes a splitt window with it's parent.
  */
SS_SplittSync(hCtrl, Flag=1 ) {	;. wParam=0, lParam=TRUE/FALSE
	static SPRM_SPLITTSYNC=0x467	
	SendMessage,SPRM_SPLITTSYNC,,Flag,, ahk_id %hCtrl%
	return ERRORLEVEL
}

;=============================================== PRIVATE ===============================================
;required by the Forms framework
SpreadSheet_add2Form(hParent, Txt, Opt) {
	static f := "Form_Parse"
	
	%f%(Opt, "x# y# w# h# style dllPath g*", x, y, w, h, style, dllPath, handler)
	h := SS_Add(hParent, x, y, w, h, style, handler, dllPath)
	ifNotEqual, Txt,, ControlSetText,, %Txt%, ahk_id %h%

	return h
}

SS_onNotify(wparam, lparam, msg, hwnd){
	static MODULEID := 260609, oldNotify="*"
	static SPRN_SELCHANGE=1, SPRN_BEFOREEDIT=2, SPRN_AFTEREDIT=3, SPRN_BEFOREUPDATE=4, SPRN_AFTERUPDATE=5, SPRN_HYPERLINKENTER=6, SPRN_HYPERLINKLEAVE=7, SPRN_HYPERLINKCLICK=8, SPRN_BUTTONCLICK=9

	if (_ := (NumGet(Lparam+4))) != MODULEID
	 ifLess _, 10000, return	;if ahk control, return asap (AHK increments control ID starting from 1. Custom controls use IDs > 10000 as its unlikely that u will use more then 10K ahk controls.
	 else {
		ifEqual, oldNotify, *, SetEnv, oldNotify, % SS("oldNotify")		
		if oldNotify !=
			return DllCall(oldNotify, "uint", Wparam, "uint", Lparam, "uint", Msg, "uint", Hwnd)
	 }

	hw := NumGet(lparam+0),  code := NumGet(lparam+8)
	handler := SS(hw "Handler")
	ifEqual, handler,, return
	
	if (code = SPRN_SELCHANGE) {
		nwin  := NumGet(lparam+12),  col := NumGet(lparam+16),  row := NumGet(lparam+20)
		r := %handler%(hw, "S", nwin, col, row )
		return NumPut(r, lparam+24)		;hm... fcancel doesn't work for some reason like it should
	}

	spri := NumGet(lparam+12), col := NumGet(spri+4), row := NumGet(spri+8)

	if (code = SPRN_HYPERLINKCLICK)
		return %handler%(hw, "C", "H", col, row)

	if (code = SPRN_BUTTONCLICK)
		return %handler%(hw, "C", "B", col, row)

	if (code = SPRN_BEFOREEDIT) {
		r := %handler%(hw, "EB", txt, col, row)
		return NumPut(r, lparam+16)
	}
	if (code = SPRN_AFTEREDIT) {
		r := %handler%(hw, "EA", SS_strAtAdr(NumGet(spri+36)), col, row)
		return NumPut(r, lparam+16)
	}
	if (code = SPRN_BEFOREUPDATE)
		return %handler%(hw, "UB", "", col, row)
	
	if (code = SPRN_AFTERUPDATE)
		return %handler%(hw, "UA", "", col, row)

/*
	if (code = SPRN_HYPERLINKENTER)
		return %handler%(hw, "hyperlink", "enter", col, row)

	if (code = SPRN_HYPERLINKLEAVE)
		return %handler%(hw, "hyperlink", "leave", col, row)
*/
}

SS_onDrawItem(wParam, lParam, msg, hwnd) {
	static SS_MODULEID := 260609, oldDrawItem="*", OWNERDRAWBLOB=13, OWNERDRAWINTEGER=14
	critical, 100

	if (wparam != SS_MODULEID){
		ifEqual, oldDrawItem, *, SetEnv, oldDrawItem, % SS("oldDrawItem")		
		ifNotEqual, oldDrawItem,,return DllCall(oldDrawItem, "uint", wparam, "uint", lparam, "uint", msg, "uint", hwnd)		
		return
	}
	hw := NumGet(lparam+20),   handler := SS(hw "Handler")																
	ifEqual, handler,, return																
																							
   ;wparam=moduleid   lParam=DRAWITEMSTRUCT													
	lpspri := NumGet(lparam+44)																
	 ,col := NumGet(lpspri+4), row := NumGet(lpspri+8)										
	 ,type := NumGet(lpspri+27,0, "UChar"),	data := NumGet(lpspri+36)
	
	return %handler%(hw, "D", lparam, col, row)																														                                  	
}

; return textual or numeric definition of type, depending on input
SS_getType( pType ) {
	static EMPTY =0, COLHDR=1, ROWHDR=2, WINHDR=3, TEXT=4, TEXTMULTILINE=5, INTEGER=6, FLOAT=7, FORMULA=8, GRAPH=9, HYPERLINK=10, CHECKBOX=11, COMBOBOX=12, OWNERDRAWBLOB=13, OWNERDRAWINTEGER=14, EXPANDED=15, BUTTON=0x10, WIDEBUTTON=0x20, DATE=0x30, FORCETYPE=0x40, FORCETEXT=0x44, FIXEDSIZE=0x80
	static 0="EMPTY",1="COLHDR",2="ROWHDR",3="WINHDR",4="TEXT",5="TEXTMULTILINE",6="INTEGER",7="FLOAT",8="FORMULA",9="GRAPH",10="HYPERLINK",11="CHECKBOX",12="COMBOBOX", 13="OWNERDRAWBLOB", 14="OWNERDRAWINTEGER", 15="EXPANDED"
	static mods = "FORCETYPE,DATE,BUTTON,WIDEBUTTON,FIXEDSIZE", TYPEMASK=0xF0
	if pType is integer
	{
		ifEqual, pType, 0, return "EMPTY"
		loop, parse, mods, `,
			if (pType & %A_LoopField% = %A_LoopField%)
				v .= A_LoopFIeld " ", pType &= ~%A_LoopField%
		pType &= ~TYPEMASK
		return %pType% (v ? " " v : "")
	}
	else {
		v = 0
		loop, parse, pType, %A_Space%, %A_Space%
			ifEqual, A_LoopField,,continue
			else v |= %A_LoopField%
	}
	return v
}
; return textual or numeric definiton of state, depending on input
SS_getState( pState ) {
	static LOCKED=0x01, HIDDEN=0x02, REDRAW=0x08, ERROR=0x10, DIV0=0x20, UNDERFLOW=0x30, OVERFLOW=0x40, RECALC=0x80, ERRMASK=0xF0		;states
	static 1="LOCKED",2="HIDDEN",8="REDRAW"
	static errs="ERROR,DIV0,UNDERFLOW,OVERFLOW,RECALC"

	if pState is integer
	{
		ifEqual, pState,0,return
		p := pState & ERRMASK
		loop, parse, errs, `,
			if (p = %A_LoopField%){	
				v .= A_LoopFIeld
				break
			}

		p := pState & ~ERRMASK
		return p ? %p% (v ? " " v : "") : v
	}
	else {
		v = 0
		loop, parse, pState, %A_Space%, %A_Space%
			ifEqual, A_LoopField,,continue
			else v |= %A_LoopField%
	}
	return v
}

; return textual or numeric definiton of align, depending on input
SS_getAlign( pAlign ) {
	static LEFT=0x10, CENTER=0x20, RIGHT=0x30, MIDDLE=0x40, BOTTOM=0x80, GLOBAL=0xF0		;aligments	
	static MASK=0xF0, XMASK=0x30, YMASK=0xC0
	static 16="LEFT",32="CENTER",48="RIGHT",64="MIDDLE",128="BOTTOM",13="ALL",14="SCI"

	if pAlign is integer
	{	
		ifLess, pAlign, -1, return "GLOBAL"
		ifEqual, pAlign, 0, return "AUTO"

		p := pAlign & ~MASK
		if (p>0) and (p <13)
			v := p
		
		p := pAlign & XMASK
		ifNotEqual,p, 0, SetEnv, v,% v A_Space %p%
		p := pAlign & YMASK
		ifNotEqual,p, 0, SetEnv, v,% v A_Space %p%
	}
	else {
		v = 0
		loop, parse, pAlign, %A_Space%, %A_Space%
			ifEqual, A_LoopField,,continue
			else v |= %A_LoopField%
	}

	return v
}


SS_getCellFloat(hCtrl, col, row) {
	static SPRM_GETCELLDATA=0x482, SPRIF_DATA=0x200, SPRIF_DOUBLE=0x400, SPRIF_SINGLE=0x800
	static ITEM, init=0
	if !init
		init++, VarSetCapacity(ITEM, 40, 0), NumPut(SPRIF_DATA | SPRIF_SINGLE, ITEM) 
		
	NumPut(col,	ITEM, 4), NumPut(row, ITEM, 8)					
	SendMessage,SPRM_GETCELLDATA,,&ITEM,, ahk_id %hCtrl%
	return NumGet( NumGet(ITEM, 36), 0, "Float")
}

SS_strAtAdr(adr) { 
   Return DllCall("MulDiv", "Int",adr, "Int",1, "Int",1, "str") 
}

;Storage function
ss(var="", value="~`a", ByRef o1="", ByRef o2="", ByRef o3="", ByRef o4="", ByRef o5="", ByRef o6="") { 
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

/* Group: Formulas

	Functions:

(start code)
	Type						Example						Description
	---------------------------------------------------------------------------------------------------
	And, Or, Xor				AA1>=0 And AA2<=0			Logical operators
	<, <=, =, >=, >, <>			AA1>=5.5					Compare operators
	+, -, *, /					((AA1+AA2)/2-3.5)*4			Basic math operators
	x^y							AA1^3.5						x to the power of y
	Sum(r1:r2)					Sum(AA1:AC6)				Sum of all cells in an area
	Cnt(r1:r2)					Cnt(AA1:AA5)				Number of cells in an area that contains a value
	Avg(r1:r2)					Avg(AB1:AB6)				Average value of an area
	Min(r1:r2)					Min(AA1:AA7)				Returns smallest number in an area
	Max(r1:r2)					Max(AA1:AB3)				Returns largest number in an area
	Var(r1:r2)					Var(AB1:AC6)				The variance of an area
	Std(r1:r2)					Std(AB1:AB6)				The standard deviation of an area
	Sqt(num)					Sqt(AA1+AA2)				Sqear root
	Sin(num)					Sin(AA5)					Sine of an angle in radians
	Cos(num)					Cos(PI()/8)					Cosine of an angle in radians
	Tan(num)					Tan(Rad(45))				Tangent of an angle in radians
	Rad(num)					Rad(45)						Converts grades to radians
	PI()						PI()/4						Returns PI 
	IIf(Cnd,TP,FP)				IIf(AA1=0,AA2,AA3)			IIf(Condition,TruePart,FalsePart)
	On(val,num[,num[,num...]])	On(AA1,AA2,AA3,AA4)			Depending on val, return num
																If val<=0, return first num
																If val>=number of num, return last num
	Abs(num)					Abs(AA5-7)					Absolute. Returns absolute value of num
	Sgn(num)					Sgn(AA5)					Sign. Returns -1, 0 or +1
	Int(num)					Int(AA5)					Integer. Returns integer value of num
	Log(num)					Log(AA5)					Logarithm to base 10
	Ln(num)						Ln(e())						Natural Logarithm
	e()							e()^AA5						Returns e 
	Asin(num)					Asin(AA4)					Inverse Sine
	Acos(num)					Acos(AA3)					Inverse Cosine
	Atan(num)					Atan(AA1)					Inverse Tangent
	Grd(num)					Grd(PI()/4)					Converts radians to grades
	Rgb(num,num,num)			Rgb(255,0,0)				Converts red, green, blue to color
	x()							Sin(x())					x value used in calculating graphs fx()	math functions
	@(rc,rr)					@(-1,2)						Relative cell reference
	CDate(str)					CDate("2008-01-01")			Converts a date string to days since 1601-01-01
(end code)

	Error Conditions:
(start code)
	Type						Dscription
	---------------------------------------------------------------------------------------------------
	####Ref						Circular reference or reference to cell with error condition
	####Err						Meaning depends on function
	####Div						Division by zero
	####Ovf						Overflow
	####Unf						Underflow
(end code)


 Group: Graphs

	Syntax:

>		Grp( [T], X, Y, fx1 | gx1, fx2 | gx2, ...)		;no spaces allowed

	Definition:

	T(xp,yp,Orientation,Color,"Text"	)		- Text (max 16)
	X,Y(xMin,xMax,xOrigo,xStep,Color,"Text")	- X and Y axis (max 1)
	fx(function,xStep,Color,"Text")				- Graph from math function (max 16)
	gx(r1:r2,Color,"Text")						- Graph from cell values (max 16)

	Note:
		Bad graph definitions will burn CPU or crash application. 
		Even single space more in Grp syntax will do that, and you will have to kill the AutoHotKey.exe using task manager.	
 */

/* Group: Examples

 First Sample:

(start code)
#Singleinstance, force
	Gui, +LastFound +ToolWindow
	hwnd := WinExist()

	hCtrl := SS_Add(hwnd, 0, 0, 300, 400, "VSCROLL  GRIDMODE CELLEDIT ROWSIZE COLSIZE ROWSELECT")
	SS_SetRowHeight(hCtrl)

	SS_SetColCount(hCtrl, 2)
	SS_SetRowCount(hCtrl, 8)

	SS_SetColWidth(hCtrl, 1, 148)
	SS_SetColWidth(hCtrl, 2, 145)

	SS_SetGlobalFields(hCtrl, "cell_txtal", "CENTER MIDDLE")

	hCombo := SS_CreateCombo(hCtrl, "item1|item2|item3|item4")

	SS_SetCell(hCtrl, 1, 1, "type=TEXT", "txt=Caption", "bg=0xFF", "fg=0xFFFFFF")
	SS_SetCell(hCtrl, 2, 1, "type=FORCETEXT")

	SS_SetCell(hCtrl, 1, 2, "type=TEXT", "txt=Style", "bg=0xFF", "fg=0xFFFFFF")
	SS_SetCell(hCtrl, 2, 2, "type=COMBOBOX", "txt=" hCombo, "data=1", "imgal=RIGHT",  "txtal=CENTER")	;select 2nd item
	
	SS_SetCell(hCtrl, 1, 3, "type=TEXT", "txt=Anchor", "bg=0xFF", "fg=0xFFFFFF")
	SS_SetCell(hCtrl, 2, 3, "type=BUTTON TEXT", "txt=w0.5 h", "imgal=RIGHT", "txtal=CENTER")

	SS_SetCell(hCtrl, 1, 4, "type=TEXT", "txt=Visible", "bg=0xFF", "fg=0xFFFFFF")
	SS_SetCell(hCtrl, 2, 4, "type=CHECKBOX", "data=1", "imgal=CENTER")

	SS_SetCell(hCtrl, 1, 6, "type=TEXT", "txt=Help", "bg=0xFFFF", "fg=-1")
	SS_SetCell(hCtrl, 2, 6, "type=HYPERLINK", "txt=www.autohotkey.com", "txtal=CENTER")

	SS_SetCell(hCtrl, 1, 8, "type=WIDEBUTTON TEXT", "Txt=Wide &Button", "txtal=CENTER")

	Gui, Show, w300 h150
return
(end code)

Get Cell Information:
(start code)
      SS_GetCellArray(hCtrl, "cell")	;"cell" name of pseudo array holding the data, use selected cell
      msg = 
      (LTrim 
         Text	= %cell_txt% 
         Data	= %cell_data% 
         State	= %cell_hState% 
                        
         bg		= %cell_bg% 
         fg		= %cell_fg% 
         txtal	= %cell_htxtal% 
         imgal	= %cell_himgal% 
         fnt	= %cell_fnt% 
         type	= %cell_Type% 
      ) 
    
      msgbox %msg%
(end code)

 Set All Global Data:
(start code)

   ;header and cell defaults    
   h_bg := c_bg   := 0xAAAAAA 
   h_txtal := c_txtal := "CENTER MIDDLE" 
   h_fg := 0xFF0000 
   h_fnt := 2 
    
   g_ncols     := 100			;number of  columngs
   g_nrows     := 100			;number of rows

   g_colhdrbtn := 0				;button sytle col hdr 
   g_rowhdrbtn := 0				;button style row hdr 
   g_winhdrbtn := 0				;button style win hdr 
   g_lockcol   := 0xAAAAAA      ;Back color of locked cell              
   g_hdrgrdcol := 0xFF00FF      ;Header grid color                      
   g_grdcol    := 0xFFFFFF      ;Cell grid color                        
   g_bcknfcol  := 0xCCCCCC      ;Back color of active cell, lost focus  
   g_txtnfcol  := 1				;Text color of active cell, lost focus  
   g_bckfocol  := 0xFFFF		;Back color of active cell, has focus    
   g_txtfocol  := 0				;Text color of active cell, has focus    

   g_ghdrwt    := 25			;header width 
   g_ghdrht    := 25			;header height 
   g_gcellw    := 50			;cell width 
   g_gcellht   := 50			;cell height 

   SS_SetGlobal(hCtrl, "g", "c", "h", "h", "h") 
 (end code)

 Formula Example:
(start code)
;formula 
	Gui, +LastFound
	hwnd := WinExist()

	hCtrl := SS_Add(hwnd, 0, 25, 552, 477, "CELLEDIT STATUS")
	
	SS_SetCell(hCTrl, 1, 1, "txt= x  =", "type=TEXT", "txtal=CENTER", "fnt=1") 
	SS_SetCell(hCTrl, 1, 2, "txt= y  =", "type=TEXT", "txtal=CENTER", "fnt=1") 
	SS_SetCell(hCTrl, 1, 3, "txt=x+y =", "type=TEXT", "txtal=CENTER", "fnt=1") 

	SS_SetCell(hCtrl, 2, 1, "type=INTEGER", "txt=90", "fnt=1", "txtal=LEFT") 
	SS_SetCell(hCtrl, 2, 2, "type=INTEGER", "txt=20", "fnt=1", "txtal=LEFT" ) 
	SS_SetCell(hCtrl, 2, 3, "type=FORMULA", "txt=AB1+AB2", "txtal=LEFT") 
	SS_ReCalc(hCtrl)

	Gui, Show, w550 h500, SpreadSheet
return

(end code)

  Graph Example:
(start code)
	Gui, +LastFound
	hwnd := WinExist()

	hCtrl := SS_Add(hwnd, 0, 25, 552, 477)

	graph =
	(LTrim Join
		Grp(
			T(-1,0,0,Rgb(0,0,0),"Graph Demo"),
			X(0,PI()*4,0,1,Rgb(0,0,255),"x-axi),
			Y(-1.1,1.1,0,0.5,Rgb(255,0,0),"y-axs"is"),
			gx(AJ1:AJ13,Rgb(0,0,0),"Cell values"),
			fx(Sin(x()),0.1,Rgb(255,0,255),"Sin(x)"),
			fx(x()^3-x()^2-x(),0.1,Rgb(0,128,0),"x^3-x^2-x"))
	)
	
	SS_SetCell(hCtrl, 1, 1, "type=GRAPH", "txt=" graph, "bg=0x0D0FFFF") 
	SS_ExpandCell(hCtrl, 1, 1, 6, 15) 

	Gui, Show, w550 h500, SpreadSheet
return
(end code)

*/

/* Group: Known Bugs
	o Cell cursor disapears in expanded cells.
	o Multiselect scrolling by mouse is too fast.
	o Scroll-locked area does not work well with splitts.
	o Float to ascii does not work on numbers > 1e000 or < 1e-4000
*/

/* Group: About
	o SpreadSheet control version: 0.0.2.1 by KetilO <http://www.masm32.com/board/index.php?topic=6913.0>
	o AHK module ver 0.0.2.1-3 by majkinetor.
	o Licensed under BSD <http://creativecommons.org/licenses/BSD/>.

 */

;HexView & S Structure
;[ITEM:|flag D|col D|row D|expx B|expy B|state B|dummy B|fmt.bckcol D|fmt.txtcol D|fmt.txtal B|fmt.imgal B|fmt.fnt B|fmt.tpe B|wt D|ht D|lpdta D
;ITEM: flag col row expx=.1 expy=.1 state=.1 dummy=.1 bckcol txtcol txtal=.1 imgal=.1 fnt=.1 type=.1 w h lpdta
