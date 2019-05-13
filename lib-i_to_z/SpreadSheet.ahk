;For control version : 0.0.1.4
;
;HexView Structure
;[ITEM:|flag D|col D|row D|expx B|expy B|state B|dummy B|fmt.bckcol D|fmt.txtcol D|fmt.txtal B|fmt.imgal B|fmt.fnt B|fmt.tpe B|wt D|ht D|lpdta D


SS_ScrollCell(hCtrl) {
	static SPRM_SCROLLCELL=0x492		;Scrolls current cell into view
	SendMessage,SPRM_SCROLLCELL,,,, ahk_id %hCtrl%
	return ERRORLEVEL
}


SS_SetHandler( func ){
	static WM_NOTIFY=0x4E
	OnMessage(WM_NOTIFY, func)
}

;----------------------------------------------------------------------------------------------
; not the same as GetCellData internaly by control
SS_GetCellData(hCtrl, col, row) {
	static SPRM_GETCELLDATA=0x482, SPRIF_DATA=0x200

	VarSetCapacity(ITEM, 40, 0)								;SPR_ITEM struct
	InsertInteger(SPRIF_DATA,	ITEM) 						
	InsertInteger(col,			ITEM, 4)					;	col				dd ? 4
	InsertInteger(row,			ITEM, 8)					;	row				dd ? 8

	SendMessage,SPRM_GETCELLDATA,,&ITEM,, ahk_id %hCtrl%
    res := ErrorLevel
	
	return ExtractIntegerAtAddr( ExtractInteger(ITEM, 36) )
}

;fast version for GetCell but only for string
SS_GetCellString(hCtrl, col, row){
	static SPRM_GETCELLDATA=0x482, SPRIF_DATA=0x200

	VarSetCapacity(ITEM, 40, 0)								;SPR_ITEM struct
	InsertInteger(SPRIF_DATA,	ITEM, 0) 
	InsertInteger(col,			ITEM, 4)					;	col				dd ? 4
	InsertInteger(row,			ITEM, 8)					;	row				dd ? 8

	SendMessage,SPRM_GETCELLDATA,,&ITEM,, ahk_id %hCtrl%
    res := ErrorLevel

  ;copy text 
	pTxt := ExtractInteger(ITEM, 36)
	len := DllCall("lstrlenA", "uint", pTxt)
	VarSetCapacity(txt, len+1)
	DllCall("lstrcpynA", "str", txt, "uint", pTxt, "uint", len+1)

	return txt
}

;----------------------------------------------------------------------------------------------

SS_GetCell(hCtrl, col, row, i){
	local ITEM, flag, res, N, pTxt, len, htype, txt
	static SPRM_GETCELLDATA=0x482				;Get cell data. wParam=0, lParam=Pointer to SPR_ITEM struct

	static EMPTY=0x000, COLHDR=0x001, ROWHDR=0x002, WINHDR=0x003, TEXT=0x004, TEXTMULTILINE=0x005, INTEGER=0x006, FLOAT=0x007, FORMULA=0x008, GRAPH=0x009, HYPERLINK=0x00A, CHECKBOX=0x00B, COMBOBOX=0x00C, EXPANDED=0x00F, BUTTON=0x010, WIDEBUTTON=0x020, FORCETEXT=0x044	;types
	static SPRIF_TYPE=0x40,SPRIF_DATA=0x200,SPRIF_WIDTH=0x80,SPRIF_BACKCOLOR=1,SPRIF_TEXTCOLOR=2,SPRIF_TEXTALIGN=4,SPRIF_HEIGHT=0x100,SPRIF_STATE=0x20,SPRIF_FONT=0x10,SPRIF_IMAGEALIGN=8,SPRIF_COMPILE=0x80000000
	static LEFT=0x10, CENTER=0x20, RIGHT=0x30, MIDDLE=0x40, BOTTOM=0x80, GLOBAL=0xF0, MASK=0xF0, XMASK=0x30, YMASK=0xC0					;formats
	static LOCKED=0x01, HIDDEN=0x02, REDRAW=0x08, ERROR=0x10, DIV0=0x20, UNDERFLOW=0x30, OVERFLOW=0x40, RECALC=0x80, ERRMASK=0xF0		;states

	flag := SPRIF_BACKCOLOR | SPRIF_TEXTCOLOR | SPRIF_TEXTALIGN | SPRIF_IMAGEALIGN | SPRIF_FONT | SPRIF_TYPE | SPRIF_STATE | SPRIF_DATA
	VarSetCapacity(ITEM, 40, 0)						;SPR_ITEM struct
	InsertInteger(flag, ITEM, 0) 
	InsertInteger(col,  ITEM, 4)					;	col				dd ? 4
	InsertInteger(row,  ITEM, 8)					;	row				dd ? 8

	SendMessage,SPRM_GETCELLDATA,,&ITEM,, ahk_id %hCtrl%
    res := ErrorLevel


  ;copy text 
	pTxt := ExtractInteger(ITEM, 36)
	len := DllCall("lstrlenA", "uint", pTxt)
	VarSetCapacity(txt, len+1)
	DllCall("lstrcpynA", "str", txt, "uint", pTxt, "uint", len+1)

	%i%_txt		:= txt	
	%i%_hState	:= ExtractInteger(ITEM, 14,0,1)	;	state			db ? 14
    
  ;FORMAT struct									;FORMAT struct                                                                                  
	N := 16
	%i%_bg		:= ExtractInteger(ITEM, N+0)		;	bckcol			dd ? 0 	15				;Back color                                         
	%i%_fg		:= ExtractInteger(ITEM, N+4)		;	txtcol			dd ? 4	19				;Text color                                         
	%i%_htxtal	:= ExtractInteger(ITEM, N+8, 0, 1)	;	txtal			db ? 8	23				;Text alignment and decimals                        
	%i%_himgal	:= ExtractInteger(ITEM, N+9, 0, 1)	;	imgal			db ? 9	24				;Image alignment and imagelist/control index        
	%i%_fnt		:= ExtractInteger(ITEM, N+10,0, 1)	;	fnt				db ? 10	25				;Font index (0-15)                                  
	%i%_hType	:= ExtractInteger(ITEM, N+11,0, 1)	;	tpe				db ? 11	26				;Cell type                                          


;	extract here Data/Text for checkbox, combo, integers etc...
	%i%_data := "",   htype := %i%_hType
	if (htype = CHECKBOX) or (htype=COMBOBOX) {
		%i%_data:= ExtractIntegerAtAddr(pTxt)
		%i%_txt	:= 
	}

	if (htype = INTEGER)
		%i%_txt	:= ExtractIntegerAtAddr(pTxt)

	return res
}

SS_GetCellRect(hCtrl, ByRef top, ByRef left, ByRef right, ByRef bottom){
	static SPRM_GETCELLRECT=0x469		;Get the current cells rect in active splitt. wParam=0, lParam=pointer to RECT struct. Returns handle of active splitt window.
	
	VarSetCapacity(RECT, 16)
	SendMessage,SPRM_GETCELLRECT,0,&RECT,, ahk_id %hCtrl%
	left	:= ExtractInteger(RECT, 0)
	top		:= ExtractInteger(RECT, 4)
	right	:= ExtractInteger(RECT, 8)
	bottom	:= ExtractInteger(RECT, 12)
	return ERRORLEVEL
}


SS_GetLockCol(hCtrl){
	static SPRM_GETLOCKCOL=0x46A	;Get lock cols in active splitt. wParam=0, lParam=0
	SendMessage,SPRM_GETLOCKCOL,,,, ahk_id %hCtrl%
	return ERRORLEVEL
}

SS_GetLockRow(hCtrl){
	static SPRM_GETLOCKROW=0x46C	;Get lock cols in active splitt. wParam=0, lParam=0
	SendMessage,SPRM_GETLOCKROW,,,, ahk_id %hCtrl%
	return ERRORLEVEL
}

SS_SetLockRow(hCtrl, rows) {
	static SPRM_SETLOCKROW = 0x46D	;Lock rows in active splitt. wParam=0, lParam=rows
	SendMessage,SPRM_SETLOCKROW,0,rows,, ahk_id %hCtrl%
	return ERRORLEVEL
}

SS_SetLockCol(hCtrl, cols) {
	static SPRM_SETLOCKCOL = 0x46B	;Lock rows in active splitt. wParam=0, lParam=cols
	SendMessage,SPRM_SETLOCKCOL,0,cols,, ahk_id %hCtrl%
	return ERRORLEVEL
}

SS_SetGlobal(hCtrl, g, cell="", colhdr="", rowhdr="", winhdr="") {
	local p, N, s, params, himgal, htxtal
	static SPRM_SETGLOBAL=0x489		;Set global. wParam=0, lParam=pointer to GLOBAL struct.
	static LEFT=0x10, CENTER=0x20, RIGHT=0x30, MIDDLE=0x40, BOTTOM=0x80, GLOBAL=0xF0, MASK=0xF0, XMASK=0x30, YMASK=0xC0					;formats


	VarSetCapacity(GLOBAL, 108, 0)											;GLOBAL struct                                                                                                 	
    
	if %g%_ncols =
		%g%_ncols := 255
	
	if %g%_nrows =
		%g%_nrows := 255

	InsertInteger(%g%_colhdrbtn   ,GLOBAL,  0)                              ;   colhdrbtn   dd ?                                                                           
	InsertInteger(%g%_rowhdrbtn   ,GLOBAL,  4)                              ;   rowhdrbtn   dd ?                                                                           
	InsertInteger(%g%_winhdrbtn   ,GLOBAL,  8)                              ;   winhdrbtn   dd ?                                                                           
	InsertInteger(%g%_lockcol     ,GLOBAL,  12)                             ;   lockcol     dd ?                    ;Back color of locked cell             
	InsertInteger(%g%_hdrgrdcol   ,GLOBAL,  16)                             ;   hdrgrdcol   dd ?                    ;Header grid color                     
	InsertInteger(%g%_grdcol      ,GLOBAL,  20)                             ;   grdcol      dd ?					;Cell grid color                       
	InsertInteger(%g%_bcknfcol    ,GLOBAL,  24)                             ;   bcknfcol	dd ?						;Back color of active cell, lost focus 
	InsertInteger(%g%_txtnfcol    ,GLOBAL,  28)                             ;   txtnfcol	dd ?						;Text color of active cell, lost focus 
	InsertInteger(%g%_bckfocol    ,GLOBAL,  32)                             ;   bckfocol	dd ?						;Back color of active cell, has focus  
	InsertInteger(%g%_txtfocol    ,GLOBAL,  36)                             ;   txtfocol	dd ?						;Text color of active cell, has focus  
	InsertInteger(%g%_ncols       ,GLOBAL,  40)                             ;   ncols		dd ?                                                                           
	InsertInteger(%g%_nrows       ,GLOBAL,  44)                             ;   nrows      dd ?                                                                           
	InsertInteger(%g%_ghdrwt      ,GLOBAL,  48)                             ;   ghdrwt     dd ?                                                                           
	InsertInteger(%g%_ghdrht      ,GLOBAL,  52)                             ;   ghdrht     dd ?                                                                           
	InsertInteger(%g%_gcellw      ,GLOBAL,  56)                             ;   gcellwt    dd ?                                                                           
	InsertInteger(%g%_gcellht     ,GLOBAL,  60)                             ;   gcellht    dd ?                                                                           
	
		
	;InsertInteger(%g%_colhdr      ,GLOBAL,   0)                             ;   colhdr    64  FORMAT <?>				;Column header formatting              
	;InsertInteger(%g%_rowhdr      ,GLOBAL,   0)                             ;   rowhdr        FORMAT <12>              ;Row header formatting                 
	;InsertInteger(%g%_winhdr      ,GLOBAL,   0)                             ;   winhdr        FORMAT <12>              ;Window header formatting              
	;InsertInteger(%g%_cell		   ,GLOBAL,   0)						     ;   cell		   FORMAT <12>				;Cell formatting                       

	params = colhdr|rowhdr|winhdr|cell
	N := 52
	loop, parse, params, |
	{
		N+=12
		p := %A_LoopField%
		if p =
			continue

		s := %p%_txtal
		htxtal := 0
		loop, parse, s, %A_Tab%%A_Space%	
				htxtal |= %A_LOOPFIELD%

		s := %p%_imgal
		himgal := 0
		loop, parse, s, %A_Tab%%A_Space%	
				himgal |= %A_LOOPFIELD%

		InsertInteger( %p%_bg	, GLOBAL, N+0 )
		InsertInteger( %p%_fg	, GLOBAL, N+4 )
		InsertInteger( htxtal, GLOBAL, N+8 )	
		InsertInteger( himgal, GLOBAL, N+9 )	
		InsertInteger( %p%_fnt	, GLOBAL, N+10 )	
		InsertInteger( %p%_tpe	, GLOBAL, N+11 )	
	}

;	HexView(GLOBAL, 108)
;	msgbox

	SendMessage,SPRM_SETGLOBAL,0,&GLOBAL,, ahk_id %hCtrl%
	return ERRORLEVEL
}

SS_GetMultiSel(hCtrl, ByRef top, ByRef left, ByRef right, ByRef bottom){
	static SPRM_GETMULTISEL=0x484		;Get multiselection. wParam=0, lParam=pointer to a RECT struct. Returns handle of active split window
	VarSetCapacity(RECT, 16)
	SendMessage,SPRM_GETMULTISEL,0,&RECT,, ahk_id %hCtrl%

	left	:= ExtractInteger(RECT, 0)
	top		:= ExtractInteger(RECT, 4)
	right	:= ExtractInteger(RECT, 8)
	bottom	:= ExtractInteger(RECT, 12)
	
	return ERRORLEVEL
}

SS_SetMultiSel(hCtrl, left, top, right, bottom ){
	static SPRM_SETMULTISEL=0x485		;Set multiselection. wParam=0, lParam=pointer to a RECT struct. Returns handle of active split window

	VarSetCapacity(RECT, 16)
	InsertInteger(left,  RECT, 0)
	InsertInteger(top,   RECT, 4)
	InsertInteger(right, RECT, 8)
	InsertInteger(bottom,RECT, 12)
	SendMessage,SPRM_SETMULTISEL,0,&RECT,, ahk_id %hCtrl%
	return ERRORLEVEL
}

SS_GetCurrentWin(hCtrl){
	static SPRM_GETCURRENTWIN=0x478			;Get active splitt window. wParam=0, lParam=0
	SendMessage,SPRM_GETCURRENTWIN,,,, ahk_id %hCtrl%
	return ERRORLEVEL
}

SS_SetCurrentWin(hCtrl, nWin){
	static	SPRM_SETCURRENTWIN=0x479		;Set active splitt window. wParam=0, lParam=nWin (0-7)
	SendMessage,SPRM_SETCURRENTWIN,,nWin,, ahk_id %hCtrl%
	return ERRORLEVEL
}


SS_ExpandCell(hCtrl, left, top, right, bottom ){
	static SPRM_EXPANDCELL=0x48E		;Expand a cell to cover more than one cell. wParam=0, lParam=pointer to RECT struct

	VarSetCapacity(RECT, 16)
	InsertInteger(left,  RECT, 0)
	InsertInteger(top,   RECT, 4)
	InsertInteger(right, RECT, 8)
	InsertInteger(bottom,RECT, 12)

	SendMessage,SPRM_EXPANDCELL,0,&RECT,, ahk_id %hCtrl%
	return ERRORLEVEL
}

SS_ReCalc(hCtrl){
	static SPRM_RECALC=0x476		;Recalculates the sheet
	SendMessage,SPRM_RECALC,,,, ahk_id %hCtrl%
	return ERRORLEVEL
}

SS_ImportLine(hCtrl, dataLine, sepChar=";") {
	static SPRM_IMPORTLINE=0x48A ;Import a line of data. wParam=SepChar, lParam=pointer to data line.
	SendMessage,SPRM_IMPORTLINE,asc(sepChar),&dataLine,, ahk_id %hCtrl%
	return ERRORLEVEL
}

SS_LoadFile(hCtrl, file) {
	static SPRM_LOADFILE=0x48B	;Load a file. wParam=0, lParam=pointer to filename
	SendMessage,SPRM_LOADFILE,,&file,, ahk_id %hCtrl%
	return ERRORLEVEL
}
SS_SaveFile(hCtrl, file){
	static SPRM_SAVEFILE=0x48C	;Save a file. wParam=0, lParam=pointer to filename
	SendMessage,SPRM_SAVEFILE,,&file,, ahk_id %hCtrl%
	return ERRORLEVEL
}

SS_SplittHor(hCtrl) {
	static SPRM_SPLITTHOR=0x464		;Create horizontal splitt in current splitt at current row. wParam=0, lParam=0
	SendMessage,SPRM_SPLITTHOR,,,, ahk_id %hCtrl%
	return ERRORLEVEL
}

SS_SplittVer(hCtrl) {
	static SPRM_SPLITTVER=0x465		;Create vertical splitt in current splitt at current col. wParam=0, lParam=0
	SendMessage,SPRM_SPLITTVER,,,, ahk_id %hCtrl%
	return ERRORLEVEL
}

SS_SplittClose(hCtrl) {
	static SPRM_SPLITTCLOSE=0x466	;Close the current splitt. wParam=0, lParam=0
	SendMessage,SPRM_SPLITTCLOSE,,,, ahk_id %hCtrl%
	return ERRORLEVEL
}

SS_SplittSync(hCtrl, flag=1 ) {	;Syncronizez a splitt window with it's parent. wParam=0, lParam=TRUE/FALSE
	static SPRM_SPLITTSYNC=0x467	
	SendMessage,SPRM_SPLITTSYNC,,flag,, ahk_id %hCtrl%
	return ERRORLEVEL
}


SS_GetColWidth(hCtrl, col){
	static SPRM_GETCOLWIDTH=0x47E		;Get column width. wParam=col, lParam=0. Returns column width.
	SendMessage,SPRM_GETCOLWIDTH,col,,, ahk_id %hCtrl%
	return ERRORLEVEL
}

SS_SetColWidth(hCtrl, col, width){
	static SPRM_SETCOLWIDTH=0x47F	
	SendMessage,SPRM_SETCOLWIDTH,col,width,, ahk_id %hCtrl%
	return ERRORLEVEL
}

SS_SetCellString(hCtrl, txt){
	static SPRM_SETCELLSTRING=0x47D		;Set content of current cell. wParam=type, lParam=pointer to string.

	SS_GetCurrentCell(hCtrl, cCol, cRow) 
	type := SS_GetCellType(hCtrl, cCol, cRow) 
	SendMessage,SPRM_SETCELLSTRING,type,&txt,, ahk_id %hCtrl%
	return ERRORLEVEL
}

SS_NewSheet(hCtrl) {
	static SPRM_NEWSHEET=0x48D		;Clears the sheet. wParam=0, lParam=0
	SendMessage,SPRM_NEWSHEET,,,, ahk_id %hCtrl%
	return ErrorLevel 	
}

SS_SetFont(hCtrl, idx, pFont) {
	static SPRM_SETFONT=0x487		;Set font. wParam=index(0-15), lParam=pointer to FONT struct. Returns font handle
	
 ;parse font 
    italic      := InStr(pFont, "italic")    ?  1 : 0 
    underline   := InStr(pFont, "underline") ?  1 : 0 
    strikeout   := InStr(pFont, "strikeout") ?  1 : 0 
    bold		   := InStr(pFont, "bold")      ?  1 : 0

 ;height 
    RegExMatch(pFont, "(?<=[S|s])(\d{1,2})(?=[ ,])", height) 
    if (height = "") 
       height := 0 
    RegRead, LogPixels, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows NT\CurrentVersion\FontDPI, LogPixels 
    height := -DllCall("MulDiv", "int", Height, "int", LogPixels, "int", 72) 

 ;face 
    RegExMatch(pFont, "(?<=,).+", face)    
    if (face != "") 
        face := RegExReplace( face, "(^\s*)|(\s*$)")      ;trim 

	VarSetCapacity(FONT,48,0 )			;FONT struct       
	DllCall("RtlMoveMemory", "uint", &FONT+4, "str", face, "uint", StrLen(face))

	InsertInteger(height,	 FONT, 40)			;	ht			40	dd ?					;Height       
	InsertInteger(bold,		 FONT, 44,1)		;	bold		44	db ?					;Bold   
	InsertInteger(italic,	 FONT, 45,1)		;	italic		45	db ?					;Italics 
	InsertInteger(underline, FONT, 46,1)		;	underline	46	db ?					;Underline    
	InsertInteger(strikeout, FONT, 47,1)		;	strikeout	47	db ?					;Strikeout    

	SendMessage,SPRM_SETFONT,idx,&FONT,, ahk_id %hCtrl%
	return ErrorLevel 	
}


SS_GetCurrentCell(hCtrl, ByRef col, ByRef row) {
	static SPRM_GETCURRENTCELL=0x47A		;Get current col/row in active window. wParam=0, lParam=0. Returns Hiword=row, Loword=col
	SendMessage,SPRM_GETCURRENTCELL,,,, ahk_id %hCtrl%

	VarSetCapacity(s, 4)
	InsertInteger(ERRORLEVEL, s)

	col := ExtractInteger(s, 0, 0, 2)
	row := ExtractInteger(s, 2, 0, 2)

	return ErrorLevel 
}

SS_GetCurrentRow(hCtrl) {
	static SPRM_GETCURRENTCELL=0x47A		;Get current col/row in active window. wParam=0, lParam=0. Returns Hiword=row, Loword=col
	SendMessage,SPRM_GETCURRENTCELL,,,, ahk_id %hCtrl%

	VarSetCapacity(s, 4)
	InsertInteger(ERRORLEVEL, s)
	return ExtractInteger(s, 2, 0, 2)
}


SS_GetCurrentCol(hCtrl) {
 	static SPRM_GETCURRENTCELL=0x47A		;Get current col/row in active window. wParam=0, lParam=0. Returns Hiword=row, Loword=col
	SendMessage,SPRM_GETCURRENTCELL,,,, ahk_id %hCtrl%

	VarSetCapacity(s, 4)
	InsertInteger(ERRORLEVEL, s)
	return ExtractInteger(s, 0, 0, 2)
}

SS_SetCurrentCell(hCtrl, col, row) {
	static SPRM_SETCURRENTCELL=0x47B		;Set current col/row in active window. wParam=col, lParam=row
	SendMessage,SPRM_SETCURRENTCELL,col,row,, ahk_id %hCtrl%
	return ErrorLevel 
}


SS_BlankCell(hCtrl, col, row) {
	static SPRM_BLANKCELL=0x477		;Blank a cell. wParam=col, lParam=row
	SendMessage,SPRM_BLANKCELL,col,row,, ahk_id %hCtrl%
	return ErrorLevel 
}

SS_DeleteCol(hCtrl, col) {
	static SPRM_DELETECOL=0x46E	;Delete col. wParam=col, lParam=0
	SendMessage,SPRM_DELETECOL,col,,, ahk_id %hCtrl%
	return ErrorLevel 
}

SS_InsertCol(hCtrl, col=-1) {
	static SPRM_INSERTCOL=0x46F		;Insert col. wParam=col, lParam=0

	if col=-1
		col := SS_GetColCount(hCtrl)+1

	SendMessage,SPRM_INSERTCOL,col,,, ahk_id %hCtrl%
	return ErrorLevel 
}


SS_DeleteRow(hCtrl, row) {
	static SPRM_DELETEROW=0x470	;Delete row. wParam=row, lParam=0
	SendMessage,SPRM_DELETEROW,row,,, ahk_id %hCtrl%
	return ErrorLevel 
}

SS_InsertRow(hCtrl, row=-1) {
	static SPRM_INSERTROW=0x471	;Insert row. wParam=row, lParam=0

	if row=-1
		row := SS_GetRowCount(hCtrl)+1

	SendMessage,SPRM_INSERTROW,row,,, ahk_id %hCtrl%
	return ErrorLevel 
}

SS_GetRowHeight(hCtrl, row) {
	static SPRM_GETROWHEIGHT=0x480		;Get row height. wParam=row, lParam=0. Returns row height.
	SendMessage,SPRM_GETROWHEIGHT,row,,, ahk_id %hCtrl%
	return ErrorLevel 
}

SS_SetRowHeight(hCtrl, row, height) {
	static SPRM_SETROWHEIGHT=0x481		;Set row height. wParam=row, lParam=height.
	SendMessage,SPRM_SETROWHEIGHT,row,height,, ahk_id %hCtrl%
	return ErrorLevel 
}

;returns number, not text
SS_GetCellType(hCtrl, col, row) {
	static SPRM_GETCELLTYPE=0x48F		;Get cell data type. wParam=col, lParam=row. Returns cell type.

	SendMessage,SPRM_GETCELLTYPE,col,row,, ahk_id %hCtrl%
	return ErrorLevel 
}

;------------------------------------------------------------------------------------------------------
; INTEGER:	 txt = int
; COMBOBOX:  data = index, txt = hCombo			data,txt
; CHECKBOX:  data = 1|0							data,txt
; FORMULA:	 txt = formula
; FLOAT :	 not implemented
; GRAPH :	 txt = graph definition
;
SS_SetCell(hCtrl, col, row, o1="", o2="", o3="", o4="", o5="", o6="", o7="", o8="", o9="", o10=""){
	static SPRM_SETCELLDATA=0x483
	static EMPTY=0, COLHDR=1, ROWHDR=2, WINHDR=3, TEXT=4, TEXTMULTILINE=5, INTEGER=6, FLOAT=7, FORMULA=8, GRAPH=9, HYPERLINK=10, CHECKBOX=11, COMBOBOX=12, EXPANDED=15, BUTTON=16, WIDEBUTTON=0x20, FORCETEXT=0x44, FORCETYPE=0x40, FIXEDSIZE=0x80	;types
	static SPRIF_TYPE=0x40,SPRIF_DATA=0x200,SPRIF_WIDTH=0x80,SPRIF_BACKCOLOR=1,SPRIF_TEXTCOLOR=2,SPRIF_TEXTALIGN=4,SPRIF_HEIGHT=0x100,SPRIF_STATE=0x20,SPRIF_FONT=0x10,SPRIF_IMAGEALIGN=8,SPRIF_COMPILE=0x80000000
	static LEFT=0x10, CENTER=0x20, RIGHT=0x30, MIDDLE=0x40, BOTTOM=0x80, GLOBAL=0xF0, MASK=0xF0, XMASK=0x30, YMASK=0xC0					;formats
	static LOCKED=1, HIDDEN=2, REDRAW=8, ERROR=0x10, DIV0=0x20, UNDERFLOW=0x30, OVERFLOW=0x40, RECALC=0x80, ERRMASK=0xF0		;states

;named parameters
;	local txt, data, w, h, bg, fg, type, state, txtal, imgal, fnt

	loop, 10 {
		if !o%A_index%
			continue

		j := InStr( o%A_index%, "=" )
		prop := SubStr(	o%A_index%, 1, j-1 )
		%prop% := SubStr( o%A_index%, j+1, StrLen(o%A_Index%))
		;evaluate text to constants									;	hType := 0                                
		if prop in type,state,imgal,txtal							;	loop, parse, type, %A_Tab%%A_Space%       
		{															;		hType |= %A_LOOPFIELD%                
			p := "h" prop											;                                             
			s := %prop%												;	hState := 0                               
			%p% := 0												;	loop, parse, state, %A_Tab%%A_Space%      

			loop, parse, s, %A_Tab%%A_Space%						;		hState |= %A_LOOPFIELD%               
				%p% |= %A_LOOPFIELD%									;                                             
		}															;   ....
	}		

	flag := 0
	flag |= (data != "" || txt != "") ? SPRIF_DATA : 0
	flag |= (type != "")	? SPRIF_TYPE : 0
	flag |= (w != "")		? SPRIF_WIDTH : 0
	flag |= (h != "")		? SPRIF_HEIGHT : 0
	flag |= (bg!= "")		? SPRIF_BACKCOLOR : 0
	flag |= (fg!= "")		? SPRIF_TEXTCOLOR : 0
	flag |= (state !="")	? SPRIF_STATE : 0
	flag |= (txtal != "")	? SPRIF_TEXTALIGN : 0
	flag |= (imgal != "")	? SPRIF_IMAGEALIGN : 0
	flag |= (fnt != "")		? SPRIF_FONT : 0
	flag |= (type="FORMULA") or (type="GRAPH") ? SPRIF_COMPILE : 0

	if type contains ComboBox,Integer			;combobox keeps combo handle in txt.
		InsertInteger(txt,txt)
	
	if (type = "ComboBox") and (data = "")		;select 1st item, if user didn't
		data = 0

	if (data != "") {							;data for now keep indices only, so it is byte before text
		txt := "1234" txt						;make the room for data
		InsertInteger(data, txt, 0, 4)
	}

	
	VarSetCapacity(ITEM, 40, 0)					;SPR_ITEM struct                                         
	InsertInteger(flag,  ITEM, 0)				;	flag			dd ? 0                               
	InsertInteger(col,	 ITEM, 4)				;	col				dd ? 4                               
	InsertInteger(row,	 ITEM, 8)				;	row				dd ? 8                               
												;	expx			db ? 12				;Expanded columns
												;	expy			db ? 13				;Expanded rows   
	InsertInteger(hState,ITEM, 14)				;	state			db ? 14       
												;	dummy db ?		db ? 15				; added to make it dword aligned									

	;FORMAT struct								;	fmt				FORMAT <?> 15                                                                                                    
	InsertInteger(bg,	 ITEM, 16)				;	bckcol			dd ? 0 				;Back color                                         
	InsertInteger(fg,	 ITEM, 20)				;	txtcol			dd ? 4				;Text color                                         
	InsertInteger(htxtal,ITEM, 24,1)			;	txtal			db ? 8				;Text alignment and decimals                        
	InsertInteger(himgal,ITEM, 25,1)			;	imgal			db ? 9				;Image alignment and imagelist/control index        
	InsertInteger(fnt,	 ITEM, 26,1)			;	fnt				db ? 10				;Font index (0-15)                                  
	InsertInteger(hType, ITEM, 27,1)			;	tpe				db ? 11				;Cell type                                          

	InsertInteger(w,	 ITEM, 28) ;width		;	wt				dd ? 27                              
	InsertInteger(h,	 ITEM, 32) ;height		;	ht				dd ? 31                              
	InsertInteger(&txt,	 ITEM, 36) 				;	lpdta			dd ? 35

	;HexView(&txt, 8)
	;msgbox

	SendMessage,SPRM_SETCELLDATA,0, &ITEM,, ahk_id %hCtrl% 
	return ErrorLevel 
}

SS_Add(hwnd,x=0,y=0,w=200,h=100,style="VSCROLL HSCROLL"){
	static WS_CLIPCHILDREN=0x2000000, WS_VISIBLE=0x10000000, WS_CHILD=0x40000000
	static VSCROLL=0x0001, HSCROLL=0x0002, STATUS=0x0004, GRIDLINES=0x0008, ROWSELECT=0x0010, CELLEDIT=0x0020, GRIDMODE=0x0040, COLSIZE=0x0080, ROWSIZE=0x0100, WINSIZE=0x0200, MULTISELECT=0x0400

	hStyle := 0
	loop, parse, style, %A_Tab%%A_Space%
		hStyle |= %A_LOOPFIELD%

	hModule := DllCall("LoadLibrary", "str", "dll\SprSht.dll")	
	hCtrl := DllCall("CreateWindowEx"
      , "Uint", 0x200           ; WS_EX_CLIENTEDGE
      , "str",  "SPREAD_SHEET"  ; ClassName
      , "str",  szAppName       ; WindowName
      , "Uint", WS_CLIPCHILDREN | WS_CHILD | WS_VISIBLE | hStyle
      , "int",  x				; Left
      , "int",  y				; Top
      , "int",  w				; Width
      , "int",  h				; Height
      , "Uint", hwnd			; hWndParent
      , "Uint", 0				; hMenu
      , "Uint", 0				; hInstance
      , "Uint", 0)

	return hCtrl
}

SS_GetColCount(hCtrl){
	static SPRM_GETCOLCOUNT=0x472
	SendMessage,SPRM_GETCOLCOUNT,0,0,, ahk_id %hCtrl% 
	return ErrorLevel 
}

SS_SetColCount(hCtrl, nCols){
	static SPRM_SETCOLCOUNT=0x473
	SendMessage,SPRM_SETCOLCOUNT,nCols,0,, ahk_id %hCtrl% 
	return ErrorLevel 
}

SS_GetRowCount(hCtrl){
	static SPRM_GETROWCOUNT=0x474
	SendMessage,SPRM_GETROWCOUNT,0,0,, ahk_id %hCtrl% 
	return ErrorLevel 
}

SS_SetRowCount(hCtrl, nRows){
	static SPRM_SETROWCOUNT=0x475
	SendMessage,SPRM_SETROWCOUNT,nRows,0,, ahk_id %hCtrl% 
	return ErrorLevel 
}


SS_CreateCombo(hCtrl, string="") {
	static SPRM_CREATECOMBO=0x491

	SendMessage,SPRM_CREATECOMBO,0,0,,ahk_id %hCtrl% 
	hListBox := ErrorLevel 

	loop, parse, string, |
		Control, Add, %A_LoopField%,, ahk_id %hListBox%

	return hListBox
}