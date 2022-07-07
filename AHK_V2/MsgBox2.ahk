; ================================================================================================
; by: TheArkive
; ================================================================================================
; MsgBox2(sMsg,title="",sOptions="")
; ================================================================================================
;	Replaces the MsgBox command and InputBox commands.  MsgBox2() can be used inline as a function
;	returning a value selected by the user.  The script thread using Msgbox2() will be halted
;	until the user gives input, as expected from the Msgbox/InputBox commands.  You can also add a
;	CheckBox, EditBox, DropDownList, ComboBox, or ListBox (or any combo of these) to get more
;	input from the user.  Also, the user can right click on the msg and copy it if desired.
;
;	The default font is the same as the AHK MsgBox command:  Verdana, 8 pt.
;
;	MsgBox2() lets you change MANY aspects about how the dialog is displayed, such as font and
;	font size.  See the options list below for all the ways you can customize it.
;
;	The automatic sizing of MsgBox2() is based on the following criteria:
;
;		1) Width of message text is automatically sized up to 350 px limit.
;		2) Width of 350 is automatically overridden if CheckBox, ListBox, etc. control text is
;          wider.
;			> Use "`r`n" to line break a CheckBox or display message if desired.
;		3) Width limit can be changed with MaxWidth: option.
;		4) Width can be set to a static value with SetWidth: option.
;			> The only way the dialog will extend beyond the horizontal limits of the screen is
;			  if the user sets it that way, with options or long CheckBox / DropDownList text.
;		5) Height is automatically adjusted based on dialog contents.
;		6) Height is limited to 95% of screen height, or by MaxHeight: option.
;
;	Lastly, by default, Msgbox2() uses a text control to display the desired message.  This can
;	be changed to a read-only Edit control if displaying long scrolling text.
;
;	With a large list of options, it's easy to specify one global string to standardize the dialog
;	style you want, such as font, font size, etc., and just add on specific options when called.
;	Or you can modify the default options in the class (near the top, check comments) to set the
;	defaults you want to use.
;
; ================================================================================================
; User interaction and accessibility:
; ================================================================================================
;	User can use arrow keys and {Tab} button to navigate the Msgbox2() GUI.  Pressing ESC, ALT+F4,
;	or CTL+F4 returns "" as the "button pressed".  Pressing enter will trigger the default button.
;
; ================================================================================================
; Usage / Return Value 
; ================================================================================================
;	Call Msgbox2 as follows:    mb2Var := New Msgbox2(sMsg,title:="",options:="")
;
;	Once called, the script/thread will be delayed by an InputHook (only used for this delay).
;	When the user interacts with the dialog, or closes it, then the following propertiesd are
;	populated:
;
;		mb2Var.list             row number selected in ListBox
;		mb2Var.listText         text of row number selected in Listbox
;		mb2Var.dropList         row number selected in DropDownList
;		mb2Var.dropListText     text of row number selected in DropDownList
;		mb2Var.combo            row number selected in ComboBox
;		mb2Var.comboText        text of row number selected in ComboBox
;		mb2Var.check            value of Checkbox (1 or 0 / true or false)
;		mb2Var.button           text of the button clicked
;		mb2Var.ClassNN          ClassNN of the button clicked
;
;		NOTE: If user presses a hotkey to close the dialog (ESC, ALT+F4, CTRL+F4) or uses the close
;		button in the top-right, .button and .ClassNN are blank.
;
;	To save memory, free the reference when done:     mb2Var := ""
;
; ================================================================================================
; Defaults
; ================================================================================================
;	The defaults, if options are not specified, are as follows:
;		Font               = Tahoma
;		Font size          = 8
;		Dialog width       = 350 px (or the width of sMsg)
;		Button width       = widest button
;		Buttons shown      = OK
;		Default button     = 1st created button
;		button alignment   = right
;		Sys close button   = dialog has a close button, top-right
;
;		no icons, no CheckBox, no DropDownList, no Edit box, no ListBox, no ComboBox
; ================================================================================================
; Options:
; ================================================================================================
; Specify zero or more of the options below - comma (,) separated.
;
;	bgColor:####
;		Specify color of dialog background.  Same format as Gui, Color command.  A blank value
;		after the colon in "bgColor:" uses the default system background color.
;
;		Ex:  bgColor:Blue  OR  bgColor:0000FF  OR  bgColor:0x0000FF
;		> Sets the background to Blue.
;
;	btnAlign:left   OR   btnAlign:right
;		If this option is NOT specified, buttons are centered.  Otherwise user can specify to align
;		the buttons to the right or left of the dialog.
;
;   btnList:Num_or_list
;		Use a number the same as the Msgbox command to load those buttons, or specify your own list
;		of buttons as a pipe delimited string.  Use &BtnText to allow using ALT as a shortcut.  See
;		GUI, Add, Button help for more info.
;
;		Ex:  btnList:1
;		> Displays (OK / Cancel) buttons.  Number 0-6.  See Msgbox command help for more info.
;
;		Ex:  btnList:OK|&Cancel[d]
;		> Specifies OK and Cancel buttons, and sets the "Cancel" button as the default.  Also, in
;		this example, ALT+C would trigger the Cancel button becuse of using "&".
;
;	btnMarX:#
;		Sets horzintal margin value for buttons.  This is both left and right margins added together.
;		Default is 20 px.  Buttons using fixed-width text may benefit from a smaller X margin than
;		the default.
;
;		Ex:  btnMarX:25
;		> Sets horizontal button margin total to 25, thus adding 25 to button text width, so this
;		affects the button width.
;
;	btnMarY:#
;		Sets vertical margin value for buttons.  This is both top and bottom margins added together.
;		Default is 15 px.
;
;		Ex:  btnMarY:10
;		> Sets vertical button margin total to 10, thus adding 10 to button text height, so this
;		affects the button height.
;
;	btnTextW
;		If specified, the buttons specified in btnList will be as wide as their display text + button
;		margins (defaults:  btnMarX := 20).  Default button width is the width of the string
;		"Try Again" at the specified font + button margins.
;
;	check:checkbox_caption:value
;		Specify a checkbox and caption text.  By default, the checkbox will be unchecked.  To change
;		this, specify 1 for the value.
;
;		EX:  check:Don't show again.:1
;		> Adds a checkbox to the dialog with the caption "Don't show again." and will be checked.
;
;	dropList:item|item|item:value
;		Creates a DropDownList with specified options.  Specify "value" as the row number to be
;		pre-selected in the DropDownList.
;
;	edit:edit_string
;		Adds an edit control to the dialog and fills it with optional specified text.
;
;		Ex:  edit:old file name.txt
;		> Adds an edit control and fills it with "old file name.txt"
;
;	fontFace:font_name_str
;		Sets font face/name.
;
;		Ex:  fontFace:Times New Roman
;
;	fontSize:#
;		Specify a font size.
;
;		Ex:  fontSize:20
;		> Sets font size to 20 for all controls.
;
;	help:help_btn_text
;		Specify a help button with custom text.  Help button width is set by the help_btn_text
;		specified.  A help button is treated the same as all other buttons in regards to the
;		return value.  The clicked "button text" will be returned.
;
;		Ex:  help:
;		> This will use a "?" as the help button text.  Returns "?" if clicked.
;
;		Ex:  help:Help
;		> This will specify a help button with the text "Help".  Returns "Help" if clicked.
;
;	icon:icon_str
;		Specifies using an icon.  There are a few different ways to use this option:
;
;		Ex:  icon:error   OR   icon:warning   OR   icon:info   OR   icon:question
;		> Specify one of the 4 common icons featured in the Msgbox command.
;
;		Ex:  icon:file.jpg  OR  icon:file.dll/2
;		> Specify a picture file, or a file and icon index.  Use forward slash (/) as separator.
;
;		EX:  HICON:[handle]  OR  HBITMAP:[handle]
;		> See LoadPicture() for more info on HICON and HBITMAP handles.
;
;	list:item|item|item:value:rowsHeight
;		Creates a ListBox with specified options.  Specify "value" as the row number to be
;		pre-selected in the ListBox.  Specify "rowsHeight" to limit the height of the Listbox.
;		Specifying "value" or "rowsHeight" is optional.
;
;	MaxHeight:###
;		Defines max pixel height for the sMsg control.  Default height is the height of sMsg.
;		Generally the screen height is used to try and limit the dialog height, but adding controls,
;		like edit, makes this a bit more sketchy.  If displaying a large sMsg, or a long scrolling
;		sMsg, it is usually best to specify the MaxHeight.
;
;		Ex:  MaxHeight:500
;		> Sets the MaxHeight to 500 pixels, or if sMsg is smaller, the height of sMsg.
;
;	MaxWidth:###
;		Defines max pixel width for the dialog.  Default = 350 px wide or the width of sMsg if sMsg
;		is smaller.
;
;		Ex:  MaxWidth:300
;		> Sets text max width to 300 pixels.  If sMsg is less than 300 px wide, then the width of
;		sMsg will be used instead.
;
;	modal:Hwnd
;		Same effect as parent:Hwnd but also disables the parent window so that the user must click
;		a button or press ESC to continue.  If "modal:xxx" is specified then don't specify "parent:xxx".
;
;		Ex:  options := "modal:" HwndVar
;
;	noCloseBtn
;		Specify this option to remove the close button in the top right of the dialog.
;
;	parent:Hwnd
;		Specify parent window of msgbox.  Doing so will prevent a taskbar button and keep the
;		dialog on top of the specified parent.  Normally you will pass "Hwnd" as a var.
;
;		Ex:  options := "parent:" HwndVar
;		>   In this example, the parent window is specified by the window handle value stored in
;		HwndVar.  This makes that window the parent, and also prevents a taskbar icon from showing.
;		This example is more specific to show how to properly use it in a script.
;
;	SetWidth:###
;		Specifies a width to force the dialog to use.  The width of sMsg has no effect if this
;		option is specified.
;
;		Ex:  SetWidth:400
;		> Sets the dialog width to 400 px.
;
;	txtColor:color_str
;		Specify color of msg text.  Same format as common AHK control style.
;
;		Ex:  txtColor:Red  OR  txtColor:FF0000  OR  txtColor:0xFF0000
;		> Sets the text message color to Red.  A blank value after the colon in "txtColor:" uses
;		the default system txt color.
;
;	selectable
;		Specify this to use a read-only edit control, instead of the default text control.  Note
;		that using this mode limits the text displayed to only about 65,535 characters.  Also,
;		the system vScroll width is not automatically added to the message width, which helps text
;		to NOT prematurely wrap when using an edit control.
;
; ================================================================================================
; End Options
; ================================================================================================
; Thanks to robodesign for LOTS of collaboration, ideas, and testing.
;
; Thanks to [just me] for creating TaskDialog that gave me ideas and inspiration.
; https://github.com/AHK-just-me/TaskDialog/blob/master/Sources/TaskDialog.ahk
; ================================================================================================

class msgbox2 { ; show
	__New(sMsg,title:="",options:="") { ; show
		Critical "off"
		
		this.mRightClick := ObjBindMethod(this,"RightClick")
		mRightClick := this.mRightClick
		OnMessage(0x204,mRightClick)
		
		this.mCloseWin := ObjBindMethod(this,"CloseWin")
		mCloseWin := this.mCloseWin
		OnMessage(0x0112,mCloseWin)
		
		this.mContextMenu := ObjBindMethod(this,"ContextMenu")
		this.mButtonPress := ObjBindMethod(this,"ButtonPress")
		
		this.criticalValue := A_IsCritical ; thanks to robodesign for this
		this.sMsg := sMsg, this.options := options ; hide
		
		iconScale := A_ScreenDPI / 96
		; ================================================
		; == default user options - set as desired =======
		; ================================================
		this.title := title ? title : this.title
		this.fontSize := 8, this.fontFace := "Verdana"
		sPadR := 1.25 ; sPadR is ratio to sPad ... sPad = fontSize * sParR / used for element spacing
		dlgMargin := 2 ; dlgMargin is multiplier of sPad / this.dlgMargin = sPad * dlgMargin
		
		this.btnMarXr := 3 ; button X margin multiplier / [text width] + ([avg char width] * btnMarXr)
		this.btnMarYr := 1 ; button Y margin multiplier / [text width] + ([avg char height] * btnMarYr)
		
		this.txtColor := "Default", this.bgColor := "Default"
		this.maxW := 350, this.minW := 150, this.forceW := false, this.maxH := 0
		this.icon := this.PickIcon(""), iconHt := 32 * iconScale
		
		this.btnTextW := false ; false = by default all buttons will be as wide as widest button
		this.selectable := false ; false = by default sMsg will be a text control, not an edit control
		this.noCloseBtn := false
		this.btnAlign := "right"
		
		; ================================================
		; ==== default control settings ==================
		; ================================================
		this.checkMsg := "", this.checkMsgVal := 0
		this.dropListMsg := "", this.dropListMsgVal := 1
		this.editMsg := "", this.editBox := false
		this.comboMsg := "", this.comboMsgVal := 1
		this.listMsg := "", this.listVal := 1, this.listRows := 0 ; displayed rows will be automatic up to 10
		this.helpText := ""
		
		; ================================================
		; ==== suggested to NOT modify these defaults ====
		; ================================================
		this.btnList := 0, this.btnCount := 0, this.btnDefault := 1, this.bMWd := 0, this.bMWc := 0
		
		this.helpDims := {}, this.btnDims := {}, this.btnListW := Array(), this.curMon := {}
		this.adjHeight := 0, this.adjWidth := 0
		this.totalWidth := 0, this.totalHeight := 0, this.ctlWidth := 0
		
		this.hParent := 0, this.modal := false
		this.parentX := "", this.parentY := "", this.parentW := "", this.parentH := ""
		; ================================================
		; ================================================
		
		errMsg := "Invalid Option`r`n`r`nopt:0 >  OK`r`nopt:1 >  OK / Cancel`r`nopt:2 >  Abort / Retry / Ignore`r`n"
		. "opt:3 >  Yes / No / Cancel`r`nopt:4 >  Yes / No`r`nopt:5 >  Retry / Cancel`r`nopt:6 >  Cancel / Try Again / Continue"
		
		optArr := StrSplit(options,",")
		Loop optArr.Length { ; AHK v1 "Loop % curLoop1" / AHK v2 "Loop curLoop"
			curOptArr := StrSplit(optArr[A_Index],":")
			curOpt := curOptArr.Has(1) ? Trim(curOptArr[1]) : ""
			curVal := curOptArr.Has(2) ? Trim(curOptArr[2]) : ""
			If !curOpt
				Continue
			
			If (curOpt = "MaxWidth")
				this.maxW := curVal ? curVal : this.maxW
			Else if (curOpt = "MaxHeight")
				this.maxH := curVal ? curVal : this.maxH
			Else If (curOpt = "icon")
				this.icon := curVal ? this.PickIcon(curVal) : this.PickIcon("")
			Else If (curOpt = "btnList")
				this.btnList := curVal
			Else If (curOpt = "parent")
				this.hParent := WinExist("ahk_id " curVal)
			Else If (curOpt = "modal")
				this.hParent := WinExist("ahk_id " curVal), this.modal := true
			Else If (curOpt = "fontFace")
				this.fontFace := curVal ? curVal : this.fontFace
			Else if (curOpt = "fontSize")
				this.fontSize := curVal ? curVal : this.fontSize
			Else If (curOpt = "ClassNN")
				this.btnClassNN := true
			Else If (curOpt = "help")
				this.helpText := curVal ? curVal : "?"
			Else If (curOpt = "txtColor")
				this.txtColor := curVal ? curVal : this.txtColor
			Else If (curOpt = "bgColor")
				this.bgColor := curVal ? curVal : this.bgColor
			Else If (curOpt = "check") {
				this.checkMsg := curVal
				this.checkMsgVal := curOptArr.Has(3) ? curOptArr[3] : this.checkMsgVal
			} Else If (curOpt = "dropList") {
				this.dropListMsg := curVal
				this.dropListMsgVal := curOptArr.Has(3) ? curOptArr[3] : this.dropListMsgVal
			} Else If (curOpt = "edit")
				this.editMsg := curVal, this.editBox := true
			Else If (curOpt = "setWidth") {
				this.maxW := curVal ? curVal : this.maxW
				this.forceW := true
			} Else If (curOpt = "selectable") ; --------------- check docs for these options below
				this.selectable := true
			Else If (curOpt = "btnTextW")
				this.btnTextW := true
			Else If (curOpt = "btnMarXr")
				this.btnMarXr := curVal ? curVal : this.btnMarXr
			Else If (curOpt = "btnMarYr")
				this.btnMarYr := curVal ? curVal : this.btnMarYr
			Else If (curOpt = "iconHeight")
				iconHt := curVal ? curVal : iconHt
			Else If (curOpt = "combo")
				this.comboMsg := curVal, this.comboMsgVal := curOptArr.Has(3) ? curOptArr[3] : this.comboMsgVal
			Else If (curOpt = "list") {
				this.listMsg := curVal
				this.listMsgVal := curOptArr.Has(3) ? curOptArr[3] : this.listMsgVal
				this.listRows := curOptArr.Has(4) ? curOptArr[4] : this.listRows
			} Else If (curOpt = "sPadR")
				sPadR := curVal ? curVal : sPadR
			Else if (curOpt = "dlgMargin")
				dlgMargin := curVal ? curVal : dlgMargin
			Else If (curOpt = "noCloseBtn")
				this.noCloseBtn := true
			Else If (curOpt = "btnAlign")
				this.btnAlign := (curVal = "left" or curVal = "right") ? curVal : ""
		}
		
		testDims := this.GetTextDims("Testing 1 2 3",this.fontFace,this.fontSize)
		
		this.btnMarX := testDims.avgW * this.btnMarXr
		this.btnMarY := testDims.avgH * this.btnMarYr
		
		this.icon.h := iconHt, this.icon.w := iconHt
		sPad := this.fontSize * sPadR, this.sPad := sPad ; element spacing controlled ; w1.25 / h0.75
		this.dlgMargin := sPad * dlgMargin ; dialog margin
		
		If (this.hParent) {
			WinGetPos parentX, parentY, parentW, parentH, "ahk_id " this.hParent
			this.parentX := parentX, this.parentY := parentY, this.parentW := parentW, this.parentH := parentH
		}
		this.curMon := this.GetMonitorData(parentX,parentY) ; props: left, right, top, bottom, x, y, Cx, Cy, w, h
		
		this.btnDims := this.GetTextDims("Try Again",this.fontFace,this.fontSize) ; default button dims / no padding
		
		btnList := this.btnList ; === button list processing =============================
		Try btnList := Integer(this.btnList)
		If (Type(btnList) = "Integer" And btnList >= 0 And btnList <= 6) { ; btn config using pre-defined option
			b := btnList, btnList := (b=0) ? "OK" : ""
			btnList := (b=1) ? "OK|Cancel" : (b=4) ? "Yes|No" : (b=5) ? "Retry|Cancel" : btnList
			btnList := (b=2) ? "Abort|Retry|Ignore" : (b=3) ? "Yes|No|Cancel" : (b=6) ? "Cancel|Try Again|Continue" : btnList
			this.btnList := btnList
		} Else If (Type(btnList) = "Integer" And (btnList < 0 Or btnList > 6)) { ; invalid option specified
			MsgBox errMsg
			this.__Delete()
			return
		}
		
		bW := this.btnDims.w, bH := this.btnDims.h, bMW := 0, btnListW := Array()
		Loop Parse btnList, "|" ; initial parsing of btnList
		{
			If (A_LoopField = "")
				Continue
			
			btnText := RegExReplace(A_LoopField,"\[[\w]+\]$","")
			btnProp := RegExReplace(A_LoopField,"^[^\[]+|\[|\]","")
			this.btnDefault := (btnProp = "d") ? A_Index : this.btnDefault
			btnDims := this.GetTextDims(btnText,this.fontFace,this.fontSize)
			
			this.btnDims := (btnDims.w > this.btnDims.w) ? btnDims : this.btnDims
			bMW += btnDims.w + this.btnMarX
			btnListW.InsertAt(A_Index,btnDims.w)
			
			btnCount := A_Index, btnDims := ""
		}
		this.btnCount := btnCount
		this.btnListW := btnListW ; list of custom button widths / no padding
		
		this.bMWd := btnCount * (this.btnDims.w + this.btnMarX)	; bMW default (all btns same width)
		this.bMWc := bMW						; bMW custom (btnTextW)
		
		If (this.helpText) {
			this.helpDims := this.GetTextDims(this.helpText,this.fontFace,this.fontSize)
			this.bMWd += this.helpDims.w + this.btnMarX
			this.bMWc += this.helpDims.w + this.btnMarX
		}
		
		this.sMsg := sMsg
		; msgbox this.sMsg
		
		this.MakeGui(1)
	} ; end __New()
	__Delete() {
		this.gui := "" ; release input hook, destroy GUI, etc...
		this.IH := ""
		this := ""
	} ; end __Delete()
	PickIcon(iconFile) {
		f := "imageres.dll/", t := iconFile ; f = file / t = icon type
		r := (t = "error") ? "e" : (t = "question") ? "q" : (t = "warning") ? "w" : (t = "info") ? "i" : ""
		iconFile := (r="e") ? f "94" : (r="q") ? f "95" : (r="w") ? f "80" : (r="i") ? f "77" : iconFile ; default icons
		
		iArr := StrSplit(iconFile,"/"), iconObj := {}
		iconObj.file := iArr.Has(1) ? iArr[1] : ""
		iconObj.num := iArr.Has(2) ? iArr[2] : "", iArr := ""
		; this.icon := iconObj
		
		return iconObj
	}
	MakeGui(ver) {
		icon := this.icon, sMsg := this.sMsg
		edit := {}, dropList := {}, check := {}, msg := {}, combo := {}, list := {}
		edit.hwnd := 0, dropList.hwnd := 0, check.hwnd := 0, msg.hwnd := 0, combo.hwnd := 0, list.hwnd := 0
		vScrollW := SysGet(2)
		hCaption := SysGet(4)
		winFrame := SysGet(8)
		sPad := this.sPad
		ctlWidth := this.ctlWidth
		totalWidth := this.totalWidth, totalHeight := this.totalHeight
		dMar := this.dlgMargin
		
		If (!ctlWidth) {
			msg := this.GetTextDims(this.sMsg,this.fontFace,this.fontSize,this.maxW)
			ctlWidth := msg.w
		} Else
			msg := this.GetTextDims(this.sMsg,this.fontFace,this.fontSize,ctlWidth)
		
		adjHeight := this.adjHeight, adjWidth := this.adjWidth
		noClose := this.noCloseBtn ? " -SysMenu" : " -MaximizeBox -MinimizeBox"
		g := GuiCreate("-DPIScale" noClose,this.title)
		g.MarginX := dMar, g.MarginY := dMar
		this.hwnd := g.Hwnd
		g.BackColor := this.bgColor
		g.SetFont("s" this.fontSize,this.fontFace)
		
		If (icon.file) { ; dMar for x and y = orig
			iconOptions := "xm ym h" icon.h " w-1" (icon.num ? " Icon" icon.num : "")
			picCtl := g.Add("Picture",iconOptions,icon.file)
			icon.hwnd := picCtl.hwnd
			i := picCtl.Pos
			icon.h := i.h, icon.w := i.w, icon.x := i.x, icon.y := i.y, this.icon := icon, i := ""
		}
		
		mX := (icon.file) ? "xm+" (icon.w + sPad) : "xm" ; icon.w + sPad = orig
		mY := (icon.file And msg.h < icon.h) ? " ym+" ((icon.h/2) - (msg.h/2)) : " ym" ; dMar
		mH := (!this.selectable) ? (msg.h - adjHeight) : (msg.h - adjHeight) + 8 ; ???
		
		mW := (!this.selectable) ? msg.w - (adjWidth + dMar*2) : msg.w - (adjWidth + dMar*2) + (msg.avgW * 4)
		
		ctlWidth := (ctlWidth > mW) ? ctlWidth : mW
		
		selOps := mX mY " h" mH " w" ctlWidth " +Background" this.bgColor " c" this.txtColor (this.selectable ? " ReadOnly" : "")
		
		If (this.selectable) {
			msgCtl := g.AddEdit(selOps,"")
			msgCtl.Value := sMsg ; necessary when StrLen(sMsg) > 65535
		} Else
			msgCtl := g.AddText(selOps,sMsg)
		
		m := msgCtl.Pos ; redefine msg dims after placing the sMsg control (edit or text)
		msg.x := m.x, msg.y := m.y, msg.h := m.h, msg.w := m.w, msg.hwnd := msgCtl.hwnd
		newY := (msg.h > icon.h) ? (dMar + msg.h + sPad) : (dMar + icon.h + sPad)
		
		if (this.listMsg) {
			listMsg := this.listMsg
			listArr := StrSplit(this.listMsg,"|")
			Loop Parse listMsg, "|"
			{
				listDims := this.GetTextDims(A_LoopField,this.fontFace,this.fontSize,0)
				ctlWidth := (listDims.w + (vScrollw * 1.5) > ctlWidth) ? listDims.w + (vScrollW * 1.5) : ctlWidth
			}
			
			listRows := (listArr.Length > 10 And !this.listRows) ? 10 : this.listRows, listArr := ""
			listCtl := g.AddListbox("xp y" newY " w" ctlWidth " Choose" this.listMsgVal " r" listRows,this.listMsg)
			L := listCtl.Pos
			list.x := L.x, list.y := L.y, list.w := L.w, list.h := L.h, list.hwnd := listCtl.hwnd
			newY += list.h + sPad
			listCtl := "", L := ""
		}
		
		if (this.editBox) {
			editDims := this.GetTextDims(this.editMsg,this.fontFace,this.fontSize,0)
			ctlWidth := (editDims.w + vScrollW > ctlWidth) ? editDims.w + vScrollW : ctlWidth
			
			editCtl := g.AddEdit("xp y" newY " w" ctlWidth " r1",this.editMsg)
			e := editCtl.Pos
			edit.x := e.x, edit.y := e.y, edit.w := e.w, edit.h := e.h, edit.hwnd := editCtl.hwnd
			newY += edit.h + sPad
			editCtl := "", e := ""
		}
		
		If (this.dropListMsg) {
			dropListMsg := this.dropListMsg
			Loop Parse dropListMsg, "|"
			{
				dropListDims := this.GetTextDims(A_LoopField,this.fontFace,this.fontSize,0)
				ctlWidth := (dropListDims.w + (vScrollw * 1.5) > ctlWidth) ? dropListDims.w + (vScrollW * 1.5) : ctlWidth
			}
			
			dropListCtl := g.AddDropDownList("xp y" newY " w" ctlWidth " Choose" this.dropListMsgVal,this.dropListMsg)
			dL := dropListCtl.Pos
			dropList.x := dL.x, dropList.y := dL.y, dropList.w := dL.w, dropList.h := dL.h, dropList.hwnd := dropListCtl.hwnd
			newY += dropList.h + sPad
			dropListCtl := "", dL := ""
		}
		
		if (this.comboMsg) {
			comboMsg := this.comboMsg
			Loop Parse comboMsg, "|"
			{
				comboDims := this.GetTextDims(A_LoopField,this.fontFace,this.fontSize,0)
				ctlWidth := (comboDims.w + (vScrollw * 1.5) > ctlWidth) ? comboDims.w + (vScrollW * 1.5) : ctlWidth
			}
			
			comboCtl := g.AddComboBox("xp y" newY " w" ctlWidth " Choose" this.comboMsgVal,this.comboMsg)
			co := comboCtl.Pos
			combo.x := co.x, combo.y := co.y, combo.w := co.w, combo.h := co.h, combo.hwnd := comboCtl.hwnd
			newY += combo.h + sPad
			comboCtl := "", co := ""
		}
		
		If (this.checkMsg) {
			chkCtl := g.AddCheckbox("xp y" newY,this.checkMsg)
			
			chkCtl.Value := this.checkMsgVal
			c := chkCtl.pos
			check.x := c.x, check.y := c.y, check.w := c.w, check.h := c.h, check.hwnd := chkCtl.hwnd
			chkCtl := "", c := ""
			
			ctlWidth := (check.w > ctlWidth) ? check.w : ctlWidth
			newY += check.h + sPad
		}
		
		this.ctrls := {}
		this.ctrls.msg := msg, this.ctrls.edit := edit, this.ctrls.dropList := dropList
		this.ctrls.check := check, this.ctrls.combo := combo, this.ctrls.list := list
		
		bMW := (this.btnTextW) ? this.bMWc : this.bMWd
		
		If (this.btnAlign = "center")
			btnX := (totalWidth) ? (totalWidth/2) - (bMW/2) : 0
		Else If (this.btnAlign = "right")
			btnX := (totalWidth) ? totalWidth - bMW - dMar : 0
		Else if (this.btnAlign = "left")
			btnX := (totalWidth) ? dMar : 0
		
		btnList := this.btnList, btnDefault := this.btnDefault
		btnListW := this.btnListW, btnDims := this.btnDims
		bMX := this.btnMarX, bMY := this.btnMarY
		
		mButtonPress := this.mButtonPress
		Loop Parse btnList, "|" ; list specified buttons
		{
			If (A_LoopField) { ; make sure button exists, helpful on zero-length string
				btnText := RegExReplace(A_LoopField,"\[[\w]+\]$","") ; , btnProp := RegExReplace(A_LoopField,"^[^\[]+|\[|\]","")
				
				xy := (A_Index = 1) ? "x" (!btnX ? "m" : btnX) " y" newY : "x+0"
				bWS := this.btnTextW ? " w" (btnListW[A_Index] + bMX) : " w" (btnDims.w + bMX)
				def := (A_Index = btnDefault) ? " +Default" : ""
				curOpts := xy bWS " h" (btnDims.h + bMY) def
				
				btnCtl := g.AddButton(curOpts,btnText) ; def
				b := btnCtl.Pos
				btnCtl.OnEvent("Click",mButtonPress)
				If (def)
					btnCtl.Focus()
			}
		}
		
		this.ctlWidth := ctlWidth
		helpDims := this.helpDims, helpText := this.helpText
		If (helpText) { ; add help button if specified
			h := g.AddButton("x+0 w" (helpDims.w + bMX) " h" (helpDims.h + bMY),helpText)
			h.OnEvent("Click",mButtonPress)
		}
		
		If (ver = 1) {
			g.Show("h" (b.y + b.h + sPad) " Hide") ; " Hide"
			
			tempMaxW := this.curMon.w * 0.95, tempMaxH := this.curMon.h * 0.95 ; max dialog h/w ratio
			this.maxH := (!this.maxH) ? tempMaxH : (this.maxH > tempMaxH) ? tempMaxH : this.maxH
			this.maxW := (!this.maxW) ? tempMaxW : (this.maxW > tempMaxW) ? tempMaxW : this.maxW
			minW := this.minW, maxW := this.maxW, maxH := this.maxH
			
			totalWidth := (g.ClientPos.w > maxW) ? maxW : (g.ClientPos.w < minW) ? minW : g.ClientPos.w
			totalWidth := (bMW > totalWidth) ? bMW + dMar : totalWidth ; (dMar*2) orig
			
			; ctlWidthAdj := (icon.file) ? (dMar*2 + sPad*2) + (icon.w*2) : (dMar*2)
			ctlWidthAdj := (icon.file) ? (dMar*2 + sPad) + (icon.w) : (dMar*2) ; <----- primary sizing based on controls
			totalWidth := (ctlWidth + ctlWidthAdj > totalWidth) ? ctlWidth + ctlWidthAdj : totalWidth ; no dMar orig
			totalHeight := (g.ClientPos.h > maxH And maxH) ? maxH : g.ClientPos.h
			
			ctlWidthAdj := (icon.file) ? sPad + icon.w : 0 ; no dMar orig
			ctlWidth := (bMW - ctlWidthAdj > ctlWidth) ? bMW - ctlWidthAdj : ctlWidth
			
			If (ctlWidth > tempMaxW Or (ctlWidth + ctlWidthAdj + sPad*2) > tempMaxW) {
				ctlWidth := tempMaxW - ctlWidthAdj ; - dMar*2
				totalWidth := tempMaxW
			}
			
			adjWidth  := (g.ClientPos.w - totalWidth < 0)  ? 0 : g.ClientPos.w - totalWidth
			adjHeight := (g.ClientPos.h - totalHeight < 0) ? 0 : g.ClientPos.h - totalHeight
			
			this.totalWidth := totalWidth, this.totalHeight := totalHeight
			this.adjWidth := adjWidth, this.adjHeight := adjHeight, this.ctlWidth := ctlWidth
			
			g.Destroy(), g := ""
			this.MakeGui(++ver)
		} Else {
			curMon := this.curMon ; props: left, right, top, bottom, x, y, Cx, Cy, w, h
			w := this.totalWidth, h := this.totalHeight ; - dMar
			
			x := curMon.Cx - (w/2), y := curMon.Cy - (h/2)
			g.Show("x" x " y" y " w" w " Hide") ; " h" h " w" w
			
			h := g.pos.h ; -(dMar*2.25)
			w := g.pos.w
			x := curMon.Cx - (w/2), y := curMon.Cy - (h/2)
			
			If (this.hParent) {
				g.Opt("+Owner" this.hParent)
				If (this.modal)
					WinSetEnabled 0, "ahk_id " this.hParent
			}
			
			this.hwnd := g.hwnd
			g.Show("x" x " y" y ) ; " h" h
			this.gui := g
			
			this.mIHKeyDown := ObjBindMethod(this,"IHKeyDown"), mIHKeyDown := this.mIHKeyDown
			this.mIHKeyUp   := ObjBindMethod(this,"IHKeyUp"), mIHKeyUp := this.mIHKeyUp
			
			this.IH := InputHook("V") ; "V" for not blocking input
			this.IH.KeyOpt("{BackSpace}{Escape}{Enter}{Space}{NumpadEnter}{F4}","N")
			this.IH.OnKeyDown := mIHKeyDown
			this.IH.OnKeyUp := mIHKeyUp
			this.IH.Start(), this.IH.Wait()
		}
	}
	RightClick(wParam, lParam, msg, hwnd) {
		If (hwnd = this.hwnd) {
			x := lParam & 0xff
			y := (lParam >> (A_PtrSize * 2)) & 0xff
			
			mContextMenu := this.mContextMenu
			cMenu := MenuCreate()
			cMenu.Add("Copy Message",mContextMenu)
			cMenu.Show()
		}
	}
	CloseWin(wParam, lParam, msg, hwnd) {
		If (hwnd = this.hwnd And wParam = 0xF060) {
			this.procResult()
			this.hwnd := 0
		}
	}
	ContextMenu(ItemName, ItemPos, Menu) {
		clipboard := this.sMsg
	}
	ButtonPress(oCtl, info) {
		ctlClassNN := oCtl.ClassNN
		ctlText := oCtl.Text
		bR := Array(ctlText,ctlClassNN)
		this.procResult(bR)
	}
	IHKeyDown(iHook, VK, SC) {
		curKey := Format("{:X}",VK)
		If (WinActive("ahk_id " this.hwnd)) {
			If (curKey = 73 And (GetKeyState("Alt") Or GetKeyState("Ctrl"))) ; ALT/CTL+F4
				this.procResult()
			Else If (VK = 27) ; ESC
				this.procResult()
		}
	}
	IHKeyUp(iHook, VK, SC) {
		curKey := Format("{:X}",VK)
		If (WinActive("ahk_id " this.hwnd)) {
			; ctl := this.gui.FocusedCtrl
			; ctlName := ctl.Name
			; ctlClassNN := ctl.ClassNN
			
			; msgbox ctlName " / " ctlClassNN
			; If ((curKey = "20") And (ctlName != "editVal"))
				; this.gui["Button1"].Focus()
			; Else If (curKey = "D" And !InStr(ctlClassNN,"Button"))
				; this.gui["Button1"].Focus()
		}
	}
	procResult(bR:="") {
		bR := !bR ? ["",""] : bR
		this.combo := 0,      this.dropList := 0, this.editText := "", this.checkValue := 0
		this.comboText := "", this.dropListText := ""
		
		If (this.ctrls.edit.hwnd) {
			ctl := GuiCtrlFromHwnd(this.ctrls.edit.hwnd)
			this.editText := ctl.Value ; show
		}
		If (this.ctrls.dropList.hwnd) {
			ctl := GuiCtrlFromHwnd(this.ctrls.dropList.hwnd)
			this.dropList := ctl.Value
			this.dropListText := ctl.Text ; show
		}
		If (this.ctrls.combo.hwnd) {
			ctl := GuiCtrlFromHwnd(this.ctrls.combo.hwnd)
			this.combo := ctl.Value
			this.comboText := ctl.Text ; show
		}
		If (this.ctrls.check.hwnd) {
			ctl := GuiCtrlFromHwnd(this.ctrls.check.hwnd)
			this.checkValue := ctl.Value ; show
		}
		If (this.ctrls.list.hwnd) {
			ctl := GuiCtrlFromHwnd(this.ctrls.list.hwnd)
			this.list := ctl.Value
			this.listText := ctl.Text ; show
		}
		
		this.buttonText := bR[1]
		this.ClassNN := bR[2]
		
		this.IH.Stop() ; ???
		
		If this.hParent
			WinActivate "ahk_id " this.hParent ; ALT+F4 seems to send hParent to background
		If (this.hParent and this.modal)
			WinSetEnabled 1, "ahk_id " this.hParent ; re-enable parent if modal was used
		
		this.gui.Destroy()
		
		Critical this.criticalValue
	}
	GetMonitorData(x:="", y:="") {
		; ===========================================================================
		; created by TheArkive
		; Usage: Specify X/Y coords to get info on which monitor that point is on,
		;        and the bounds of that monitor.  If no X/Y is specified then the
		;        current mouse X/Y coords are used.
		; ===========================================================================
		saveCoordModeMouse := A_CoordModeMouse
		CoordMode "Mouse", "Screen" ; CoordMode Mouse, Screen ; AHK v1
		If (x = "" Or y = "")
			MouseGetPos x, y
		actMon := 0
		
		monCount := MonitorGetCount() ; SysGet, monCount, MonitorCount ; AHK v1
		Loop monCount { ; Loop % monCount { ; AHK v1
			MonitorGet(A_Index,mLeft,mTop,mRight,mBottom) ; SysGet, m, Monitor, A_Index ; AHK v1
			
			If (mLeft = "" And mTop = "" And mRight = "" And mBottom = "")
				Continue
			
			If (x >= (mLeft) And x <= (mRight-1) And y >= mTop And y <= (mBottom-1)) {
				curMon := {}, curMon.left := mLeft, curMon.right := mRight
				curMon.top := mTop, curMon.bottom := mBottom, curMon.active := A_Index
				curMon.x := x, curMon.y := y
				curMon.Cx := ((mRight - mLeft) / 2) + mLeft
				curMon.Cy := ((mBottom - mTop) / 2) + mTop
				curMon.w := mRight - mLeft, curMon.h := mBottom - mTop
				Break
			}
		}
		
		CoordMode "Mouse", saveCoordModeMouse
		return curMon
	}
	GetTextDims(r_Text, sFaceName, nHeight,maxWidth:=0) {
		; ======================================================================
		; modified from Fnt_Library v3 posted by jballi
		; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=4379
		; original function(s) = Fnt_CalculateSize() / Fnt_GetAverageCharWidth()
		; ======================================================================
		Static Dummy57788508, DEFAULT_GUI_FONT:=17, HWND_DESKTOP:=0, MAXINT:=0x7FFFFFFF, OBJ_FONT:=6, SIZE
		
		hDC := DllCall("GetDC", "Ptr", HWND_DESKTOP) ; "UInt" or "Ptr" ?
		devCaps := DllCall("GetDeviceCaps", "Uint", hDC, "int", 90)
		nHeight := -DllCall("MulDiv", "int", nHeight, "int", devCaps, "int", 72)
		
		bBold := False, bItalic := False, bUnderline := False, bStrikeOut := False, nCharSet := 0
		
		hFont := DllCall("CreateFont", "int", nHeight, "int", 0, "int", 0, "int", 0, "int", 400 + 300 * bBold
					   , "Uint", bItalic, "Uint", bUnderline, "Uint", bStrikeOut, "Uint", nCharSet, "Uint", 0, "Uint"
					   , 0, "Uint", 0, "Uint", 0, "str", sFaceName)
		
		hFont := !hFont ? DllCall("GetStockObject","Int",DEFAULT_GUI_FONT) : hFont ; load default font if invalid
		
		l_LeftMargin:=0, l_RightMargin:=0, l_TabLength:=0, r_Width:=0, r_Height:=0
		l_Width := (!maxWidth) ? MAXINT : maxWidth
		l_DTFormat := 0x400|0x10 ; DT_CALCRECT (0x400) / DT_WORDBREAK (0x10)
		
		DRAWTEXTPARAMS := BufferAlloc(20,0) ;-- Create and populate DRAWTEXTPARAMS structure
		NumPut "UInt", 20, "Int", l_TabLength, "Int", l_LeftMargin, "Int", l_RightMargin, DRAWTEXTPARAMS
		
		RECT := BufferAlloc(16,0)
		NumPut "Int", l_Width, RECT, 8 ;-- right
		
		old_hFont := DllCall("SelectObject","Ptr",hDC,"Ptr",hFont)
		
		SIZE := BufferAlloc(8,0) ;-- Initialize
		testW := "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz" ; taken from Fnt_GetAverageCharWidth()
		RC := DllCall("GetTextExtentPoint32","Ptr",hDC,"Str",testW,"Int",StrLen(testW),"Ptr",SIZE.Ptr)
		RC := RC ? NumGet(SIZE,0,"Int") : 0
		avgCharWidth := Floor((RC/26+1)/2), avgCharHeight := NumGet(SIZE,4,"Int")
		
		strBufSize := StrPut(r_Text), l_Text := BufferAlloc(strBufSize+16,0)
		StrPut r_Text, l_Text ; , (l_Text.Size+1) ; not specifying size
		
		DllCall("DrawTextEx","Ptr",hDC,"Ptr",l_Text.Ptr,"Int",-1,"Ptr",RECT.Ptr,"UInt",l_DTFormat,"Ptr",DRAWTEXTPARAMS.Ptr)
		DllCall("SelectObject","Ptr",hDC,"Ptr",old_hFont)
		DllCall("ReleaseDC","Ptr",HWND_DESKTOP,"Ptr",hDC) ; avoid memory leak
		
		r_Width := NumGet(RECT,8,"Int"), r_Height := NumGet(RECT,12,"Int")
		NumPut "Int", r_Width, "Int", r_Height, SIZE ; write H/W to SIZE rect structure
		
		retVal := {}, retVal.h := r_Height, retVal.w := r_Width
		retVal.avgW := avgCharWidth, retVal.avgH := avgCharHeight, retVal.addr := SIZE.Ptr
		
		return retVal
	}
}


