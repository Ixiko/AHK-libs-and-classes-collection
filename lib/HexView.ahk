;-------------------------------------------------------------------------
; Function: HexView
;
; Overview:
;			o Hexa, asci & struct display of input data
;			o Synchronized scrolling
;			o Customizable GUI appeareance
;			o More then 1000 Win API structures included and you can define your own
;			o Reverse interpretation of structures using - in front of structure name
;			o Status bar containing offset and number of bytes of selection
;			o Grab string out of struct field address using double right click on struct member
;			o Copy struct field using left double click on struct member
;
; Parameters:
;			pAdr		- Address of the input data
;			pByteNo		- Number of bytes to show
;			pActiveTab	- Optional tab name to activate upon startup. This overrides saved registry
;						  setting.
;
; Remarks:
;			o HexView comes with *Structures.str* file which contains list of Win SDK structure definitions
;			  to be used in struct view. This file is first searched in the scripts folder then in Lib folder. 
;			  You can also set struct definitions manually by filling *HexView_structList* variable. 
;			  Each struct definition must end with `r`n. See Structures.str for the format of structure definition.
;
; Examples:
;>			s := "0123456789ABCDEF"
;>			HexView(&s, 32)
;>			
;>			VarSetCapacity(s, 32)
;>			NumPut(11, s, 0), 	NumPut(12, s, 4)
;>			NumPut(13, s, 8), 	NumPut(14, s, 12)
;>
;>			HexView_structList = [SIZE:|x D|y D`n[RECT:|a1 D|a2 D|a3 D|a4 D		;don't load Structures.str file
;>			HexView(&s, 132, "struct") 
;>
;
; Dependencies:
;			<Mem>, <Dlg>, <Attach>
;
;	About:
;			- v3.11 by majkinetor. See http://www.autohotkey.com/forum/topic17858.html
;			- Licenced under GNU GPL <http://creativecommons.org/licenses/GPL/2.0/>.
;
HexView( pAdr, pByteNo="", pActiveTab=""){
	local dump, byteNo, hexa, asci, timer

	HexView_Gui		  := "93"
	HexView_title	  := "HexView"
	HexView_ver		  := "3.11"
	timer			  := 200

	HexView_optionNo  := 6							;all options are named OptionN for the sake of automatic setup
	
	HexView_ConfigLoad()	
	if (pActiveTab = "")
		pActiveTab := HexView_pTab


 ;save the arguments in arg1 and arg2
	HexView_arg1 := pAdr,  HexView_arg2 := pByteNo

 ;check if pByteNo is skipped
	byteNo := pByteNo="" ? StrLen(pAdr) : pByteNo

	dump := Mem_Dump(pAdr, byteNo, true)			;get the dump

 ;convert the dump to appropriate format
	hexa := RegExReplace( dump, "`nm)^.[^:]+: ([^-]+)(.+)$", "$1")
	hexa := RegExReplace( hexa, "`nm)[ ]$")
	asci := RegExReplace( dump, "`nm)^[^-]*- ", "")

	StringTrimRight hexa, hexa, 1					;remove trailing new line
	StringTrimRight asci, asci, 1					;remove trailing new line

	StringReplace, hexa, hexa, |,%A_SPACE%, A	    ;replace | in hexa with spaces

	HexView_Create(hexa, asci, pActiveTab)			;create gui
}

;--------------------------------------------------------------------------------------

HexView_Create(pHexa, pAsci, pActiveTab) {
	local footer, hexW, asciW, guiW, dummy, j, selS, selE
	local iX, iY, tmp, hdr

	iY := HexView_pGuiH + 30		

  ;calc edit width
	hexW  := HexView_GetTextSize(pHexa, HexView_pStyle , HexView_pFont) + 10
	asciW := HexView_GetTextSize(pAsci, HexView_pStyle, HexView_pFont ) + 10

  ;dummy contains just new lines for each asci line, so to keep v scroll bar the same size as of asci and hexa
  ;the purpose of dummy edit is to keep scroll bar, as if you desable scrollbar for both hexa and asci, sync scroll doesn't work
	loop, parse, pAsci, `n
		dummy .= "`n"						

  ;put limitation on how small edits can be
	if asciW < 180 
		asciW := 180
	if hexW < 250
		hexW := 250

	guiW := hexW + asciW + 10 + 20

  ;--------- MAIN SCREEN ---------------
	footer := 25					;how much space to reserve at the bottom of the GUI
   	
	Gui, %HexView_Gui%:+LabelHexView_ +Resize +Minsize +MinSizex250 +LastFound
	Gui, %HexView_Gui%:Margin, 0, 0
	Gui, %HexView_Gui%:Color, %HexView_pGuiBack%, %HexView_pBack%
	HexView_hwnd := WinExist()


	iY  := HexView_pGuiH - footer	;height of the edits
	iX  := hexW - 5					;width of the status
	tmp := HexView_pGuiH + 30		;height of the tab (it starts on -30 cuz of display bug, so I adjust it here)

	Gui, %HexView_Gui%:Add, Edit,	x0		y0	  w%hexW%  h%iY%	vHexView_hexa HWNDHexView_eHexa 0x100 -VScroll section, %pHexa%
	Gui, %HexView_Gui%:Add, Text,	xs+5	y+5	  w%iX%				vHexView_status HWNDHexView_hstatus,
	HexView_Subclass(HexView_eHexa, "HexView_wndProc", "F")

	iX+=3	;tab control starts after status
	Gui, %HexView_GUI%:Add, Tab,	x%iX%	y-30  w%asciW% h%tmp%   0x100 +0x8 HWNDHexView_htab vHexView_tab g_HexView_TabChange -Wrap, ascii|struct|skin|opt|?


	;slider and dummy edit
	Gui, %HexView_GUI%:Tab,
	Gui, %HexView_Gui%:Add, Slider, x+3 ys h%iY% w20    HWNDHexView_hslider vHexView_slider g_HexView_OnSlider  AltSubmit NoTicks Page3 Vertical
	Gui, %HexView_Gui%:Add, Edit,   x-100  h%iX% w0		HWNDHexView_eDummy -TabStop, %dummy%

	;add tab buttons
	iY+=5
	Gui, %HexView_GUI%:Font, bold 
	Gui, %HexView_Gui%:Add, Text,	0x8000 x%hexW% y%iY% h20 HWNDHexView_htab1 vHexView_tab1  g_HexView_OnTabButtonClick section, ascii
	Gui, %HexView_Gui%:Add, Text,	0x8000 x+10 ys h20	 HWNDHexView_htab2 vHexView_tab2  g_HexView_OnTabButtonClick, struct%A_Space%
	Gui, %HexView_Gui%:Add, Text,	0x8000 x+45 ys h20	 HWNDHexView_htab3 vHexView_tab3  g_HexView_OnTabButtonClick, skin
	Gui, %HexView_Gui%:Add, Text,	0x8000 x+10 ys h20	 HWNDHexView_htab4 vHexView_tab4  g_HexView_OnTabButtonClick, opt
	Gui, %HexView_Gui%:Add, Text,	0x8000 x+10 ys h20	 HWNDHexView_htab5 vHexView_tab5  g_HexView_OnTabButtonClick, ?
	Gui, %HexView_GUI%:Font, norm

 ;------------ TABS --------------
 	Gui, %HexView_Gui%:Add, GroupBox,	x%hexW%	y0 h0 section	;for synchronisation


 ;TAB ASCII
	iY-=5
   	Gui, %HexView_Gui%:Tab, 1
	Gui, %HexView_Gui%:Add, Edit,	h%iY% w%asciW% ys xs HWNDHexView_eAsci vHexView_asci 0x100 -VScroll, %pAsci% 
	HexView_Subclass(HexView_eAsci, "HexView_wndProc", "F")

  


  	Gui, %HexView_Gui%:Tab, 2

  	iX := hexW
	iY -= 21
	tmp := asciw - 15
	hdr := HexView_pOption4 ? "hdr" : "-hdr"
		
	Gui, %HexView_Gui%:Add, ComboBox,	xs ys	w%asciw%		HWNDHexView_hcbStructs g_HexView_OnStructChange vHexView_cbStructs,	 ;%HexView_lastStruct%||
	Gui, %HexView_Gui%:Add, ListView,	xs y+0	w%asciw% h%iY%	HWNDHexView_hlvMembers vHexView_lvMembers g_HexView_OnListView	 ReadOnly %hdr% 0x1 +LV0x100 -Multi,	Value|Name
	Gui, %HexView_Gui%:Default
	LV_ModifyCol(2, "70"), LV_ModifyCol(1, "60")


 ;TAB SKIN
	Gui, %HexView_Gui%:Tab, 3
	Gui, %HexView_Gui%:Font, norm bold


	Gui, %HexView_Gui%:Add, Text,		xs+15	ys+10				vHexView_txt2	, Gui Back
	Gui, %HexView_Gui%:Add, Text,		xs+15	y+2		w50  h20	vHexView_pGuiBack g_HexView_OnTxtClick border 	, ggggggggggggggg

	Gui, %HexView_Gui%:Add, Text,		xs+100  ys+10				vHexView_txt3	, Gui Front
	Gui, %HexView_Gui%:Add, Text,		xs+100  y+2		w50  h20	vHexView_pGuiFront g_HexView_OnTxtClick	border  , ggggggggggggggg

	Gui, %HexView_Gui%:Add, Text,		xs+15	ys+60				vHexView_txt4	, Ctrl Back
	Gui, %HexView_Gui%:Add, Text,		xs+15	y+2		w50  h20	vHexView_pBack g_HexView_OnTxtClick	border 		, ggggggggggggggg

	Gui, %HexView_Gui%:Add, Text,		xs+100  ys+60				vHexView_txt5	, Ctrl Front
	Gui, %HexView_Gui%:Add, Text,		xs+100	y+2		w50  h20	vHexView_pFront g_HexView_OnTxtClick border  	, ggggggggggggggg

   ;font
	Gui, %HexView_Gui%:Add, Text,		xs+15	yp+40				vHexView_txt6	, Font
	Gui, %HexView_Gui%:Add, Text,				y+2		w150 h60	vHexView_pFont	g_HexView_OnTxtClick border center -VScroll,


 ;TAB OPTIONS
  	Gui, %HexView_Gui%:Font, norm
	Gui, %HexView_Gui%:Tab, 4

	Gui, %HexView_Gui%:Add, CheckBox, 	xs+5 ys+10	w170 vHexView_pOption1 g_HexView_Option_Toggle	, Show struct tooltip
	Gui, %HexView_Gui%:Add, CheckBox, 	y+20 w170		 vHexView_pOption2 g_HexView_Option_Toggle	, Offset in hex format
	Gui, %HexView_Gui%:Add, CheckBox, 	y+5  w170		 vHexView_pOption3 g_HexView_Option_Toggle	, Struct fields in hex format
	Gui, %HexView_Gui%:Add, CheckBox, 	y+20 w170		 vHexView_pOption4 g_HexView_Option_Toggle	, Show struct header (*)
	Gui, %HexView_Gui%:Add, CheckBox, 	y+5  w170 		 vHexView_pOption5 g_HexView_Option_Toggle	, Copy only value on dblclick


 ;TAB ?
	Gui, %HexView_Gui%:Tab, 5
	Gui, %HexView_Gui%:Add, Text,		xs ys+15 w%asciw% h30 vHexView_txtTitle center,	%HexView_title% %HexView_ver%
	Gui, %HexView_Gui%:Add, Text,		xs y+20  w%asciw% vHexView_txt8 center,		% HexView_About()


;fix hexa selection on startup, somehow it always selects all text
;	DllCall("SendMessage", "uint", HexView_eHexa, "uint", 0xB1, "uint", 0, "uint", 0) ;EM_SETSEL


 ;set the tab
	GuiControl  %HexView_Gui%:Choose, HexView_tab, %pActiveTab%
	gosub _HexView_TabChange					;makes slider focused also
  
	HexView_OnTabButtonClick( pActiveTab )		;underline active tab
	HexView_Struct_Translate()					;just load the struct list in combo box.

	GuiControl, %HexView_Gui%:ChooseString, HexView_cbStructs, %HexView_lastStruct%
	HexView_lastStruct :=


 ;set previous selection
	if (HexView_pSelection != "")
	{
		j := InStr(HexView_pSelection, A_Space)
		selS := SubStr(HexView_pSelection, 1, j-1)
		selE := SubStr(HexView_pSelection, j+1, 8)
		DllCall("SendMessage", "uint", HexView_ehexa, "uint", 0xB1, "uint", selS, "uint", selE) ;EM_SETSEL
	;	GuiControl, %HexView_Gui%:Focus, HexView_ehexa		;this didn't work so I had to use "force" param in OnSelection
		HexView_OnSelection(true)
	}

 ;SET COLORS
	HexView_Skin_SetGui(), 	HexView_Skin_SetCtrl()

 ;Set Attach

 	 Attach(HexView_eAsci,		"h w")
	 Attach(HexView_eHexa,		"h" )
	 Attach(HexView_hstatus,	"y" )
	 Attach(HexView_htab,		"h" )
	 Attach(HexView_hslider,	"x h")
	 Attach(HexView_hlvMembers, "w h")
	 Attach(HexView_hcbStructs, "w")

	Attach(HexView_htab1, "y")
	Attach(HexView_htab2, "y")
	Attach(HexView_htab3, "y")
	Attach(HexView_htab4, "y")
	Attach(HexView_htab5, "y")

	
 ;SHOW THE WINDOW 
	Gui, %HexView_Gui%:Show, %HexView_pGuiPos% w%GuiW% h%HexView_pGuiH%, %HexView_title% %HexView_ver%
	WinWaitActive,  ahk_id %HexView_hwnd%
	WinMove, ahk_id %HexView_hwnd%,,,,%HexView_pGuiW%  ;if window was resized to the right, return size 
}

;--------------------------------------------------------------------------------------
;subclass both edits with the same window procedure
HexView_Subclass(hEdit, func, mode="") {
	static newProcAddr=0

	if (!newProcAddr) {
		old := DllCall("GetWindowLong", "uint", hEdit, "int", -4)
		newProcAddr := RegisterCallback(func, mode, 4, old)
	}
	
	return DllCall("SetWindowLong", "UInt", hEdit, "Int", -4, "Int", newProcAddr, "UInt")
}

HexView_wndProc(hwnd, uMsg, wParam, lParam){ 
	global ComboX_Active
	
	res := DllCall("CallWindowProcA", "UInt", A_EventInfo, "UInt", hwnd, "UInt", uMsg, "UInt", wParam, "UInt", lParam)
	if (uMsg=0x200 and wparam=1) or (uMsg=0x202) 		;WM_MOUSEMOVE, MK_LBUTTON
		HexView_OnSelection()
			
	return res 
}
;--------------------------------------------------------------------------------------
HexView_OnTxtClick( ctrl ) {
	local x, y, clr

	if ctrl in HexView_pGuiBack,HexView_pGuiFront,HexView_pBack,HexView_pFront
	{
		clr := %A_GuiControl%
		if !Dlg_Color(clr, HexView_hwnd)
			return

		%A_GuiControl% := clr
	
		Gui, %HexView_Gui%:Color, %HexView_pGuiBack%, %HexView_pBack%
		gosub _HexView_TabChange	;call change for setup to set colors again

		HexView_Skin_SetGui(), 	HexView_Skin_SetCtrl()

		return
	}

	if ctrl = HexView_pFont
	{
		x := HexView_pFont, y := HexView_pStyle
		if !Dlg_Font(x, y, clr, HexView_hwnd)
			return

		HexView_pFont := x, HexView_pStyle := y

		;restart GUI so the edit widths are recalced and new settings are saved
		gosub HexView_Close
		HexView(HexView_arg1, HexView_arg2, 3)
	}
}

_HexView_OnTxtClick:
	HexView_OnTxtClick(A_GuiControl)
return

;----------------------------------------------------------------------------------------

HexView_InitTab_Options(){
	local opt

	loop, %HexView_optionNo% {
		opt := HexView_pOption%A_Index%
		GuiControl, %HexView_Gui%:, HexView_pOption%A_Index%, %opt%
	}
}

HexView_InitTab_Struct() {
	global

	if (HexView_pOption1)	;Option1 = pTooltip
		Tooltip   
}

HexView_InitTab_Color() {
	global

	Gui, %HexView_Gui%:Font, norm c%HexView_pGuiBack% s32 bold, Webdings
	GuiControl,%HexView_Gui%:Font, HexView_pGuiBack

	Gui, %HexView_Gui%:Font, c%HexView_pGuiFront%
	GuiControl,%HexView_Gui%:Font, HexView_pGuiFront

	Gui, %HexView_Gui%:Font, c%HexView_pFront%
	GuiControl,%HexView_Gui%:Font, HexView_pFront

	Gui, %HexView_Gui%:Font, c%HexView_pBack%
	GuiControl,%HexView_Gui%:Font, HexView_pBack

	Gui, %HexView_Gui%:Font, norm s12 c%HexView_pGuiFront%, %HexView_pFont%
	GuiControl,%HexView_Gui%:Font, HexView_pFont
	GuiControl,%HexView_Gui%:, HexView_pFont, %HexView_pFont%`n%HexView_pStyle%
}

_HexView_TabChange:
	
	GuiControlGet, HexView_tab, %HexView_Gui%:, HexView_tab			;get active tab
	GuiControl %HexView_Gui%:Focus, HexView_slider					;select slider	

	
	if (HexView_tab="struct")
		HexView_InitTab_Struct()

	if (HexView_tab="skin")
		HexView_InitTab_Color()

	if (HexView_tab="opt")
		HexView_InitTab_Options()
return 

;--------------------------------------------------------------------------------------------------------
; Function to handle tab button simulation
;
HexView_OnTabButtonClick(ctrl){
	local num
	static lastTab

	;There is a problem when asci edit is selected and tab is switched - it will select all data in hexa
	;Fix this by removing focus of asci control when tab is switched
	if (lastTab = "HexView_tab1")
	  	GuiControl %HexView_Gui%:Focus, HexView_slider					;select slider	

	StringReplace, num, ctrl, HexView_tab
	GuiControl %HexView_Gui%:Choose, HexView_tab, %num%
	gosub _HexView_TabChange

	;visuals
	Gui, %HexView_Gui%:Font, norm bold s9, Arial
	GuiControl,%HexView_Gui%:Font, %lastTab%

	Gui, %HexView_Gui%:Font, underline bold s9, Arial
	GuiControl,%HexView_Gui%:Font, %ctrl%
	lastTab := ctrl
}

_HexView_OnTabButtonClick:
	HexView_OnTabButtonClick(A_GuiControl)
return


_HexView_Option_Toggle:
	if A_GuiControl = HexView_pOption1
		if (HexView_pOption1)
			 Tooltip
		else Tooltip %HexView_tooltip%

	GuiControlGet, %A_GuiControl%, %HexView_Gui%:, %A_GuiControl%
return

;----------------------------------------------------------------------------------------

HexView_OnListView(pEvent, pInfo) {
	local TextAtAdr, txt1, txt2, len, h, info
	
	;copy clicked row to clipboard
	if pEvent = DoubleClick
	{
		LV_GetText(txt1, pInfo)
		if !HexView_pOption5
			LV_GetText(txt2, info, 2), txt2 := " " txt2

		clipboard := txt1 txt2

		Tooltip, Text copied to clipboard:`n`n%clipboard%,,,19
		SetTimer, HexView_CloseInfoTooltip, -1200
	}	

	;get text
	if pEvent = R
	{
		LV_GetText(txt1, pInfo)
		TextAtAdr := Mem_StrAtAdr(txt1)
		h := Mem_FormatHexNum(txt1)
		Tooltip, Text At Address %h%:     `n`n%TextAtAdr%,,,19
		SetTimer, HexView_CloseInfoTooltip, -3000
	}
}

_HexView_OnListView:
	HexView_OnListView(A_GuiEvent, A_EventInfo)
return

HexView_CloseInfoTooltip:
	Tooltip,,,,19
return

;----------------------------------------------------------------------------------------

HexView_OnSlider(){
	local pos, min, max, wparam
	static SB_THUMBPOSITION :=4,  SB_VERT := 1,  WM_VSCROLL	:= 0x115


	DllCall("GetScrollRange", "uint", HexView_eDummy, "int", SB_VERT, "int*", min, "int*", max) 
	pos := Ceil(HexView_slider*max/100) 

	wparam := (pos<<16) + SB_THUMBPOSITION
   
	SendMessage, WM_VSCROLL, wparam, , , ahk_id %HexView_eAsci% 
	SendMessage, WM_VSCROLL, wparam, , , ahk_id %HexView_eHexa%        
}

_HexView_OnSlider:
	HexView_OnSlider()
return

;------------------------------------------------------------------------------------------------------------
; Function :	DoSelection
; Determines if something is selected in hexa and asci if the selection is the same as before, etc...
;
; Parameters :
;				pByteSel	- Number of bytes selected. Cursor alone is counted as 1 byte selection
;							  so the only way to know if there is no selection or 1 byte selection is to
;							  check out third parameter, pCursorMove
;				pOffset		- Offset of start of the selection (or cursor as it counts as 1 byte is selected)
;				pCursorMove - True if there is no selection but cursor is moved via arrows or mouse
;							  pByteSel will be set to 1 as this is identical to the next byte after cursor
;							  being selected
;				force		- This one is used to force selection update on startup as slider remains selected 
;							  and for some reason GuiControl, Focus doesn't fails when called for eHexa on startup
;
; Returns :
;				True if there is a new selection or false if the selection is the same as on last run
;
HexView_DoSelection(ByRef pByteSel, ByRef pOffset, ByRef pCursorMove, force=false){
	local start, end, #start, #end, focused, focusedHWND, r, delta := 0
	static s, e

   	GuiControlGet, focused, %HexView_Gui%:Focus
	ControlGet focusedHWND, Hwnd, , %focused%, ahk_id %HexView_hwnd%
	GuiControlGet, focused, %HexView_Gui%:FocusV
	
	if (force) 
		focusedHWND := HexView_eHexa, focused := "HexView_hexa"


	r := DllCall("SendMessage", "uint", focusedHWND, "uint", 0xB0, "uintP", start, "uintP", end)	;EM_GETSEL
	if !r	;cursor is at 0
		start:=0, end:=0

	pCursorMove := start = end

	if ( s=start AND e=end )
		return false
	else s := start, e := end

 ;calculate
	if (focused = "HexView_hexa")
	{
		#start := HexView_F(start+1)-1
		#end   := HexView_F(end)
		if (#end=#start)					;cursor is moved
			#end++		 

		DllCall("SendMessage", "uint", HexView_eAsci, "uint", 0xB1, "uint", #start, "uint", #end) ;EM_SETSEL

		pByteSel :=  (#end - 2*(#end//18)) - (#start - 2*(#start//18))
		pOffset	 :=  #start - 2*(#start//18)
	}
	else if (focused = "HexView_asci") 
	{
		if ! Mod(start+2, 18) 			 ;if cursor is position at end of the line ($), select last byte before it
			 delta := -1					

		#start := HexView_Fi(start+1+delta)
		#end   := HexView_Fi(end+1+delta)
		if (#end=#start)					;cursor is moved
			#end+=3

		DllCall("SendMessage", "uint", HexView_eHexa, "uint", 0xB1, "uint", #start, "uint", #end) ;EM_SETSEL

		pOffset	 :=  start+delta - 2*((start+delta)//18)
		pByteSel :=  end+delta - 2*((end+delta)//18) - pOffset

		;ToolTip, %start% %end%`n%#start% %#end%`n%delta%
	} 
	else return false


	return true
}

;----------------------------------------------------------------------------------------
; Periodicaly check selection
;
HexView_OnSelection(force=false){
	local byteSel, offset, word, cursorMove

	if !HexView_DoSelection(byteSel, offset, cursorMove, force)
		return

 ;close the tooltip if there is no selection
 	if (cursorMove) & HexView_pOption1
		Tooltip
	
 ;set status
	word :=  byteSel=1 ? "byte" : "bytes"
 
	if (HexView_pOption2)	;HexView_pHexOffset
		offset := "0x" Mem_FormatHexNum(offset)
	
	GuiControl, %HexView_Gui%:,	HexView_status, %byteSel% %word% selected      Offset: %offset%


 ;translate struct
	HexView_Struct_Translate()
}

;---------------------------------------------------------------------------------
; Get the text string from containing struct definition from the struct list
; Returns empty str if struct can not be found in the list
;
; Struct can contain - in front of its name
;
HexView_Struct_GetDef( sName ) {
	local j, k, sInfo, type, len

	StringReplace, sName, sName, -, 	

	;find it in the structs list
	StringGetPos, j,  HexView_structList, [%sName%:
	if j=-1
		return ""

	StringGetPos, k,  HexView_structList, `n, , j
    len := k=-1 ? 512 : k-j-StrLen(sName)-4
	StringMid, sInfo, HexView_structList, j+StrLen(sName)+4, %len%

	;parse members into array aMember
	loop, parse, sInfo, |, `n
	{
		
		HexView_aMember_%A_Index%_name := SubStr(A_LoopField, 1, StrLen(A_LoopFiled)-2)
		type := SubStr(A_LoopField, -0, 2)

		if (type = "D")
			 HexView_aMember_%A_Index%_byteNo := 4
		else if (type ="W") 
				HexView_aMember_%A_Index%_byteNo := 2
			 else if (type="B")
					HexView_aMember_%A_Index%_byteNo := 1

		HexView_aMember_0 := A_Index
	}

	return sInfo
}

;-------------------------------------------------------------------------------------------
; Interpretate struct as union of memebers. aMember holds details about struct members
;
HexView_Struct_Translate() {
	local sInfo, sName, res, value, delta=1, byteNo, sel
	static firstRun=true, slPath

 ;if struct list is not builded, make it and fill the combo; user can override the structList
	if (HexView_structList="") or (firstRun && HexView_structList != "")	
	{
		StringReplace slPath, A_AhkPath, AutoHotkey.exe
		slPath := FileExist("structures.str") ? "structures.str" : slPath "\Lib\structures.str"
		if HexView_structList =
				FileRead, HexView_structList, %slPath%
		else  	StringReplace  HexView_structList, HexView_structList, `n, `r`n
		
		sel := RegExReplace(HexView_structList, "`nm)^\[(.+?):(.+)$", "$1|")
		StringReplace, sel, sel, `n, , A
		GuiControl, %HexView_Gui%:, HexView_cbStructs, %sel%

		firstRun := false
	}
	
	Gui, %HexView_Gui%:Default			;!!!

 ;get the struct name
	GuiControlGet, sName, %HexView_Gui%:, HexView_cbStructs
	if (sName = "") {
	   	LV_Delete(), LV_Add("","select struct"), LV_ModifyCol(1, "AutoHdr"),  LV_ModifyCol(2, "0")
		return
	}


 ;get selection
	ControlGet, sel, Selected,,, ahk_id %HexView_eHexa%
	if (sel = "") {			  
		LV_Delete(), LV_Add("","no selection"),	LV_ModifyCol(1, "AutoHdr"),  LV_ModifyCol(2, "0")
		return
	}
	
 ;check for reverse char
	if chr(*&sName) = "-"
		sel := HexView_StrReverse( sel )
		

	if (sName != HexView_lastStruct){
	 	sInfo := HexView_Struct_GetDef( HexView_lastStruct := sName )
		if (sInfo = "") {
			HexView_lastStruct := ""
			LV_Delete(), LV_Add("","struct not found"), LV_ModifyCol(1, "AutoHdr"),  LV_ModifyCol(2, "0")
			return
		}
	}

  	StringReplace, sel, sel, `r`n,,A				;remove new lines
	StringReplace, sel, sel, %A_SPACE%,,A			;remove spaces


 ;calculate members
	LV_Delete(), HexView_tooltip := ""
	GuiControl, %HexView_Gui%:-Redraw, HexView_lvMembers 
	loop, %HexView_aMember_0%
	{
		byteNo := HexView_aMember_%A_Index%_byteNo
		value := SubStr(sel, delta, byteNo*2),	delta += byteNo*2,  Mem_Hex2Bin(value, value, byteNo),  value := NumGet(value)

		if (HexView_pOption3)		;HexView_pHexMembers
			value := "0x" Mem_FormatHexNum(value)

		LV_Add("", value, HexView_aMember_%A_Index%_name)
		HexView_tooltip .= 	HexView_aMember_%A_Index%_name " = " value "`n"
	}

	StringTrimRight, HexView_tooltip, HexView_tooltip, 1
	if (HexView_pOption1) and !(HexView_tab="struct")	;Option1 = pTooltip
		Tooltip %HexView_tooltip%

	LV_ModifyCol(1, "AutoHdr"),  LV_ModifyCol(2, "AutoHdr")
	GuiControl, %HexView_Gui%:+Redraw, HexView_lvMembers 
}

;-------------------------------------------------------------------------------
; Function that transforms [a,b] -> [c,d]  (hexa->asci)
;    [a,b] is selection in hexa edit control, a and b are part of selection
;    [c,d] is adequate selection in asci edit.
;
;
;	  xs(x)	:=	2*((x-1)//14)			
;														   1, x>0
;				+--	 xs//3 + P(xs//3)			, P(x) = <				P is sign(x)
;	 F'(xs)	:=	|--  F(xs-1), when x=13*N				   0, x=0
;				|--  F(xs-2), when x=14*N
;				+--  F(xs+1), when x=56*N
;
;     G(F)	:=	F + 2*((F-1)//16))
;  
;       F	:=  G  o  F' o  xs
;
; Note : Function takes into account `r`n invisible chars, which is the reason for XS(x) and G(f) 
;
HexView_F(x) {
	if Mod(x,56)=0		;new line is every 56 chars
		x+=1

	if Mod(x+1,14)=0
		x-=1

	if Mod(x,14)=0
		x-=2

	x -= 2*((x-1)//14)
	
	if Mod(x,3) > 0
		 sx := 1
	else sx := 0


	F :=  x//3 + sx
	
	return F + 2*((F-1)//16)
}
;-------------------------------------------------------------------------------
; Function that transforms [c,d] -> [a,b]  (asci->hexa)
;
;
;	  xs(x)	:=	2*((x-1)//18)		
;
;     Fi(xs) :=
HexView_Fi(x) {

	row := (x-1)//18
	b := x - 2*row

	Fi := (b-1) * 3 + 2*((b-1)//4)
	return, Fi 
}

_HexView_OnStructChange:
	HexView_Struct_Translate()
return

;---------------------------------------------------------------------------------------

HexView_GetTextSize(pStr, pStyle, pFont="", pHeight=false) { 
	global	HexView_Gui

	Gui %HexView_Gui%:Font, bold %pStyle%, %pFont% 
	Gui %HexView_Gui%:Add, Text, R1, %pStr% 
	GuiControlGet T, %HexView_Gui%:Pos, Static1 
	Gui %HexView_Gui%:Destroy
	Return pHeight ? "W" TW "," "H" TH : TW 
}

----------------------------------------------------------------------------------------

HexView_ConfigSave(){
	local sRect, x,y,w,h, max, opt, sels, sele, sel

	RegWrite, REG_SZ,HKCU, Software\Miodrag Milic\HexView, Font		 ,  %HexView_pFont%	
	RegWrite, REG_SZ,HKCU, Software\Miodrag Milic\HexView, Style	 ,  %HexView_pStyle%
	RegWrite, REG_SZ,HKCU, Software\Miodrag Milic\HexView, GuiBack	 ,  %HexView_pGuiBack%
	RegWrite, REG_SZ,HKCU, Software\Miodrag Milic\HexView, GuiFront	 ,  %HexView_pGuiFront%
	RegWrite, REG_SZ,HKCU, Software\Miodrag Milic\HexView, Front	 ,  %HexView_pFront%
	RegWrite, REG_SZ,HKCU, Software\Miodrag Milic\HexView, Back		 ,  %HexView_pBack%

	loop, %HexView_optionNo% {
		opt := HexView_pOption%A_Index%
		RegWrite, REG_SZ,HKCU, Software\Miodrag Milic\HexView, Option%A_Index%,  %opt%
	}

	DllCall("SendMessage", "uint", HexView_eHexa, "uint", 0xB0, "uintP", selS, "uintP", selE)	;EM_GETSEL
	sel := selS != selE ? selS " " selE : ""

	RegWrite, REG_SZ,HKCU, Software\Miodrag Milic\HexView, Selection, %sel%
	

 ;save the window position and size (if not maximized)
	VarSetCapacity(sRect, 16)
	DllCall("GetClientRect", "uint", HexView_hwnd, "uint", &sRect) 	
	w := NumGet(sRect, 8), 	h := NumGet(sRect, 12)

	WinGetPos, x, y,,,ahk_id %HexView_hwnd%
	WinGet, max, MinMax, ahk_id %HexView_hwnd%
    if !max {
		RegWrite, REG_SZ,HKCU, Software\Miodrag Milic\HexView, GuiW      ,  %w%
		RegWrite, REG_SZ,HKCU, Software\Miodrag Milic\HexView, GuiH      ,  %h%
		RegWrite, REG_SZ,HKCU, Software\Miodrag Milic\HexView, GuiPos    ,  x%x% y%y%
	}


	if 	HexView_lastStruct !=
		RegWrite, REG_SZ,HKCU, Software\Miodrag Milic\HexView, LastStruct,	%HexView_lastStruct%

 ;save last tab
	GuiControlGet, HexView_tab, %HexView_Gui%:, HexView_tab			
	RegWrite, REG_SZ,HKCU, Software\Miodrag Milic\HexView, Tab, %HexView_tab%
}


HexView_ConfigLoad(){
	local opt

	RegRead, HexView_pGuiW		,HKCU, Software\Miodrag Milic\HexView, GuiW
	RegRead, HexView_pGuiH		,HKCU, Software\Miodrag Milic\HexView, GuiH        
	RegRead, HexView_pGuiPos	,HKCU, Software\Miodrag Milic\HexView, GuiPos
	RegRead, HexView_pFont		,HKCU, Software\Miodrag Milic\HexView, Font		  
	RegRead, HexView_pStyle		,HKCU, Software\Miodrag Milic\HexView, Style		
	RegRead, HexView_pGuiBack	,HKCU, Software\Miodrag Milic\HexView, GuiBack	  
	RegRead, HexView_pGuiFront	,HKCU, Software\Miodrag Milic\HexView, GuiFront	  
	RegRead, HexView_pFront		,HKCU, Software\Miodrag Milic\HexView, Front		  
	RegRead, HexView_pBack		,HKCU, Software\Miodrag Milic\HexView, Back		
	RegRead, HexView_pTab		,HKCU, Software\Miodrag Milic\HexView, Tab
	RegRead, HexView_pSelection	,HKCU, Software\Miodrag Milic\HexView, Selection

	
	;load options 
	loop, %HexView_optionNo% {
		RegRead, opt ,HKCU, Software\Miodrag Milic\HexView, Option%A_Index%
		HexView_pOption%A_Index% := opt = "" ? 0 : opt
	}

	RegRead, HexView_lastStruct ,HKCU, Software\Miodrag Milic\HexView, LastStruct		  	

	;set defaults
	HexView_pFont		.= HexView_pFont	  = "" ? "Courier New" :
	HexView_pStyle		.= HexView_pStyle	  = "" ? "s12" :
	HexView_pGuiH		.= HexView_pGuiH	  = "" ? 250 :
	HexView_pGuiBack	.= HexView_pGuiBack	  = "" ? 0xAAAAAA  :
	HexView_pGuiFront	.= HexView_pGuiFront  = "" ? 0x000040 :
	HexView_pFront      .= HexView_pFront     = "" ? 0x00ffff  : 
	HexView_pBack       .= HexView_pBack      = "" ? 0x000040  :
}

;----------------------------------------------------------------------------------------

HexView_Skin_SetGui(){
	global

	Gui, %HexView_Gui%:Color, ,  %HexView_pBack%
	Gui, %HexView_Gui%:Font, norm %HexView_pStyle% c%HexView_pFront%,%HexView_pFont%
	GuiControl %HexView_Gui%:Font, HexView_hexa
	GuiControl %HexView_Gui%:Font, HexView_asci

	Gui, %HexView_Gui%:Font, norm %HexView_pStyle% s10 c%HexView_pFront%,%HexView_pFont%
	GuiControl %HexView_Gui%:Font, HexView_lvMembers
}

HexView_Skin_SetCtrl(){
	global
	
	Gui, %HexView_Gui%:Color, %HexView_pGuiBack%

	Gui, %HexView_Gui%:Font,  s9 norm c%HexView_pGuiFront%, Arial
	GuiControl,  %HexView_Gui%:Font, HexView_tab

; statics and combo boxes (txtN and pOptionN)
	loop, 10 {
		GuiControl,  %HexView_Gui%:Font, HexView_txt%A_Index%
		GuiControl,  %HexView_Gui%:Font, HexView_pOption%A_Index%
	}
	

	;font preview is larger
	Gui, %HexView_Gui%:Font, s12 c%HexView_pGuiFront%, %HexView_pFont%
	GuiControl,  %HexView_Gui%:Font, HexView_pFont

	;status and tabs are bold
	Gui, %HexView_Gui%:Font,  s9 norm bold c%HexView_pGuiFront%, Arial
	GuiControl,  %HexView_Gui%:Font, HexView_status
	Loop, 10
		GuiControl,  %HexView_Gui%:Font, HexView_tab%A_Index%

	;about title is larger
	Gui, %HexView_Gui%:Font, s12
	GuiControl,  %HexView_Gui%:Font, HexView_txtTitle
}


;----------------------------------------------------------------------------------------

HexView_Escape:
HexView_Close:

 ;save config
	HexView_ConfigSave()
 
 ;destroy window
	Gui, %HexView_Gui%:Destroy
	if (HexView_pOption1)	;Option1 = pTooltip
		Tooltip

 ;clean
	HexView_Gui   := HexView_eAsci  := HexView_eDummy   := HexView_eHexa := HexView_pCorrection := ""
	HexView_pFont := HexView_pStyle := HexView_status   := HexView_tab   := HexView_lvMembers := HexView_hwnd := ""
	HexView_pBack := HexView_pFront := HexView_pGuiBack := HexView_pGuiFront := HexView_pGuiH := HexView_pGuiPos := ""
	HexView_structList := HexView_lastStruct := HexView_ver := HexView_title := HexView_tooltip := HexView_pTab := ""

	loop %HexView_OptionNo%
		 HexView_pOption%A_Index% :=

	HexView_OptionNo :=

	gosub HexView_CloseInfoTooltip
return

;----------------------------------------------------------------------------------------

HexView_StrReverse( pString ){
	len := StrLen(pString)
	Loop, %len%
	{ 
	   StringMid, char, pString, %len%, 1 
	   len--, res .= char
	}
	return res
}

;----------------------------------------------------------------------------------------

HexView_About() {
	msg := "By majkinetor`n"
		 . "miodrag.milic@gmail.com`n`n"
		 . "2007`nBelgrade`n`n"
	
	return msg
}