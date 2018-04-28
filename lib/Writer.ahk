;Dependecies: Form, Panel, Attach, Align, Toolbar, RichEdit
Writer_Add(hParent, X, Y, W, H, Style="", Text="", Font="") {
	global 

	ifEqual, Font,,SetEnv,Font,s10 -bold,Tahoma
  ;create layout
	pnlMain	:= Panel_Add(hParent, X, Y, W, H)
	pnlTool	:= Panel_Add(pnlMain, 0, 0, W, 60)
	hRE		:= RichEdit_Add(pnlMain, "", "", "", "", "NOHIDESEL MULTILINE SELECTIONBAR VSCROLL", Text), RichEdit_FixKeys(hRE)
	ControlFocus,,ahk_id %hRe% 
	
	Align(pnlTool, "T"), Align(hRE, "F")

	hIL := IL_Create(10)
	loop, btns\*.png
		IL_Add(hIL, A_LoopFileFullPath)
	
	;populate toolbars
	btns =
	 (LTrim
		Bold,,,check
		Italic,,,check 
		Underline,,,check 
		Strikeout,,,check 
		-
		Left,,,
		Center,,,
		Right,,,
		-
		Ident,,,
		Dedent,,,
		Bullet,,,DROPDOWN 
		Back Color,,,
		Text Color,,,
	 )

	cbFont   := Form_Add(pnlTool, "ComboBox", Writer_enumFonts(), "sort gWriter_OnTool y6 x0 w180")
	cbSize   := Form_Add(pnlTool, "ComboBox", "8|9|10||11|12|14|16|18|20|22|24|26|28|36|48|72", "gWriter_OnTool x+5 w50")
	hToolbar := Form_Add(pnlTool,"Toolbar", btns, "gWriter_OnToolbar y30 style='flat list nodivider tooltips' il" hIL)
	Toolbar_AutoSize(hToolbar)
  	Form_AutoSize(pnlTool, .2)
	Align(pnlMain)	;realign

	StringSplit, Font, Font, `,, %A_SPACE%
	Control, ChooseString, %Font2%,,ahk_id %cbFont%

	RichEdit_SetCharFormat(hRE, Font2, Font1, "", "", "DEFAULT")
	RichEdit_AutoUrlDetect(hRE, true ) 
	RichEdit_SetEvents(hRE, "Writer_onRichEdit", "SELCHANGE LINK")

	Attach(hRE, "w h")
	Attach(pnlTool, "w")

	return pnlMain
}

Writer_add2Form(hParent, Txt, Opt){
	Form_Parse(Opt, "x# y# w# h# style font", x, y, w, h, style, font)
	hCtrl := Writer_Add(hParent, x, y, w, h, style, Txt, font)
	return hCtrl
}

Writer_onRichEdit(hCtrl, Event, p1, p2, p3 ) {
	static _sp1, _sp2

	if Event = SELCHANGE
	{		
		if (_sp1 = p1) && (_sp2 = p2)
			return
		_sp1 := p1, _sp2 := p2				

		SetTimer, Writer_SetUI, -100		; don't spam while typing...
		return
	}

	if Event = Link
		Run, % RichEdit_GetText(hCtrl, p2, p3)

	return

 Writer_SetUI:
	Writer_SetUI()
 return
}


Writer_setUI() {
	global hRE, hToolbar,cbFont, cbSize, Writer_cbFont, Writer_cbSize

	static bold=1, italic=2, underline=3, strikeout=4, btns="bold,italic,underline,strikeout"

	RichEdit_GetCharFormat(hRE, font, style, fg, bg)
	StringSplit, style, style, %A_Space%

	ControlSetText, ,%Font%, ahk_id %cbFont%

	loop, %style0%
	{
		s := style%A_Index%
		if s in %btns%
			Toolbar_SetButton(hToolbar, %s%, "checked"), _%s% := 1
		else if (SubStr(s,1,1)="s") && (size := SubStr(s,2))
			ControlSetText,,%size%,ahk_id %cbSize%	
	}
	
	loop, parse, btns, `,
		if !_%A_LoopField%
			Toolbar_SetButton(hToolbar, %A_LoopField%, "-checked")
}

Writer_onToolbar(Hwnd, Event, Txt) {
	global hRE

	ifEqual, event, hot, return

	if !Hwnd
	{	
		if Txt is not integer
			 font := Txt
		else style := "s" Txt
		return RichEdit_SetCharFormat(hRE, font, style )
	}

	if Txt in Bold,Italic,Underline,Strikeout
		return RichEdit_GetCharFormat(hRE, _, style), RichEdit_SetCharFormat( hRE, "", Instr(style, Txt) ? "-" Txt : Txt )
	
	if Txt in left,right,center
		return RichEdit_SetParaFormat(hRE, "Align=" Txt)
	
	if Txt in ident,dedent
		return RichEdit_SetParaFormat(hRE, "Ident=" (Txt="dedent" ? -1:1)*500)


	if Txt in Back Color,Text Color
	{
		 b := Txt="Back Color"
		 RichEdit_GetCharFormat(hRE, _, _, fg, bg)
		 clr := b ? bg : fg
		 if Dlg_Color(clr, hRE) 
			return RichEdit_SetCharFormat(hRE, "", "", b ? "" : clr, b ? clr : ""  )		
	}

	If Txt in Number,Bullet,None
		if event=menu
			  return ShowMenu("[Writer_Bullet]`nBullet`nNumber`nNone")
		else  RichEdit_SetParaFormat(hRE,"Num=" (Txt = "None" ? " " : (Event="rclick" || Txt="Number" ? "DECIMAL" : "BULLET") ",1,D"))
	
}

Writer_bullet:
	Writer_OnToolbar(1, "click", A_ThisMenuItem)
return

Writer_onTool:
	Writer_OnToolbar(0, "", A_GuiControl)
return

Writer_enumFonts() {

	hDC := DllCall("GetDC", "Uint", 0) 
	DllCall("EnumFonts", "Uint", hDC, "Uint", 0, "Uint", RegisterCallback("Writer_enumFontsProc", "F"), "Uint", 0) 
	DllCall("ReleaseDC", "Uint", 0, "Uint", hDC)
	
	return Writer_enumFontsProc(0, 0, 0, 0)
}

Writer_enumFontsProc(lplf, lptm, dwType, lpData) {
	static s
	
	ifEqual, lplf, 0, return s

	s .= DllCall("MulDiv", "Int", lplf+28, "Int",1, "Int", 1, "str") "|"
	return 1
}


#include *i _Forms.ahk