; ================================================================================
; by: TheArkive
; MsgBox2(sMsg,title="Notification",options="")
;	Replaces MsgBox function and allows using MsgBox2() inline as a function returning
;	a value seleccted by the user.  The value returned is either ESC if user presses
;	the ESC key, or return value is the clicked button text by default.  Specify "btnID"
;	to return the ClassNN name of the button instead of the button text.
;
; ================================================================================================
; ================================================================================================
; Options:
; ================================================================================================
; ================================================================================================
;	Zero or more of the below strings - comma (,) separated.  Use concatenation to
;	construct your Options string.
;
;	If Options is blank, the following defaults are used:
;		fontFace := Veranda
;		fontSize := 8
;		opt:0    (only display an OK button)
;
;	  w:### OR MaxWidth:### - defines max pixel width for sMsg.
;							  default: = 350 pixels or for 3+ buttons 450 pixels
;
;			Ex:    w300 / MaxWidth300
;			> This example sets text max width to 300 pixels.
;
;	  opt:0-6 - sets predefined display buttons, same as AHK "MsgBox" command
;
;			Ex:    opt1
;			> Displays (OK / Cancel) buttons
;
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
; -= START Icon options =-
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
;	  icon:error/warning/info/question - specifies one of the 4 default icons just like in the AHK
;										 MsgBox command.
;
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
; --== OR use icon: like this ==--
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
;
;	  icon:file[/#] - Specify a file/IconIndex.  The IconIndex must be a number that would be accepted by
;					AHK in any other context when specifying an icon index within an EXE, DLL, or other
;					resource file.  Note that IconIndex is NOT the same as a "resource number".
;
;					You can also just specify a file, and it will automatically be resized to width = 32.
;					This potentially allows for loading an image that is taller than 32 pixels, if the
;					loaded image does not have the same height/width.
;
;			Ex:    icon:imageres.dll/55
;			> This would show the icon at index #55 in imageres.dll
;
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
; --== OR use icon: like this ==--
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
;
;	  icon:[HICON|HBITMAP]:handle - Specify "HICON:handle" or "HBITMAP:handle", where "handle" is the
;									address of the loaded image file.  To use this method, check
;									LoadPicture() in the AHK help docs.  LoadPicture() will need to
;									be used prior to MsgBox2() so that the resulting handle can be
;									passed as an option.
;
;			Ex:    "icon:HICON:" var
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
; -= END icon options =-
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
;
;	  selectable: - Uses an edit box with no border so that user can select sMsg
;
;	  modal:??? - Specify only "modal:" to use the GUI that launched the thread as the owner, otherwise
;				  you can use the handle or a GUI name to specify the GUI that "owns" the MsgBox2 dialog.
;				  When "owned", the MsgBox2 dialog will stay on top of the specified GUI.  The "modal:"
;				  option will also disable the specified GUI to prevent input like a true modal dialog
;				  window.  The user will be required to hit ESC, or press a button to continue.
;
;				  If you specify "modal:" and no GUI launched the thread (meaning A_Gui is blank), then
;				  the script default Gui (A_DefaultGui) is used instead.
;
;	  owner:??? - Just like "modal:" except the specified window will NOT be disabled.  To use the Gui
;				  that launched the thread, just specify "owner:".
;
;			   NOTE:  If "modal:" and "owner:" are used, then only "modal:" will take effect.  If using
;			   MsgBox2 as part of a background process, or without a GUI, it is recommended to NOT specify
;			   "owner:" or "modal:".
;
;	  buttons:???|???[d]|??? - Pipe (|) delimited list of user defined buttons.  Use [d] at the end of a
;							   button caption to specify that button as the default to get focus.  If no
;							   [d] is specified, then the first button is the default button.  The default
;							   button can be triggered by simply pressing ENTER, unless the input focus is
;							   changed, usually by using TAB, arrow keys, or the mouse.  If you specify
;							   "btnList:" this is the same as "opt:0".
;
;		Ex:    btnList:OK|Cancel[d]
;		> This example defines OK and Cancel buttons, and sets the Cancel button as default.
;
;	  fontFace:???? / fontSize:## - Dont need to be used together.  Specifies font face/size.
;
;		Ex: fontFace:Times New Roman,fontSize:12
;
;	  btnID: - Specifies to return the ClassNN of a button instead of the button caption text.
;			   By default, the button caption text is returned when clicked in a MsgBox2 dialog.
;			   This is useful if you (for some reason) want to specify multiple buttons with the same
;			   caption/label but still want to know which button was clicked/selected.
;
;			   Return values usually look like "Button1", "Button2", etc...
;
;	  help:[???] - Specify help:[MyHelpText] to have a help button with specified text.  If
;				   you specify only "help:" then the default help button text is a question mark (?).
;				   A "help" button is not constrained to the default button width.  The Help button
;				   dimensions will conform to the amount of text in the help button.
;
;				   The default button width is set to the widest value of all specified buttons, except
;				   the help button.
;
;	  x:# / y:# - Specify x/y coordinates to display the MsgBox2 dialog.  BOTH x:/y: must be specified.
;				  Specify "x:" or "y:" to auto center the x/y position.  Specify "x:+100" to move the
;				  dialog 100 pixels right from center.  Specify "x:-100" to move the dialog 100 pixels
;				  left from center.  Specify "y:+100" to move the dialog 100 pixels down from center.
;				  Specify "y:-100" to move the dialog 100 pixels up from center.
;
;				  Or, specify "x:250,y:250" to set the top left corner of the dialog to x=250, y=250
;				  on the desktop.  "x:0,y:0" sets the top left of the dialog to the far top/left of
;				  the screen.
;
;	  txtColor:c# - Specify color of msg text.  Same format as common AHK control style with "c" as prefix.
;
;			Ex:    txtColor:cRed ... OR ... txtColor:cFF0000
;			A blank value after the colon in "txtColor:" uses the default system txt color.
;
;	  bgColor:# - Specify color of dialog background.  Same format as Gui, Color command.
;
;			Ex:    bgColor:Blue ... OR ... bgColor:0000FF
;			A blank value after the colon in "bgColor:" uses the default system background color.
; ================================================================================================
; ================================================================================================
; End Options
; ================================================================================================
; ================================================================================================
; Thanks to [just me] for creating TaskDialog that gave me ideas and inspiration.
; https://github.com/AHK-just-me/TaskDialog/blob/master/Sources/TaskDialog.ahk
; ================================================================================

Global MsgBox2InputHook

MsgBox2(sMsg,title:="Notification",options:="") {
	oCritic := A_IsCritical ; thanks to robodesign for this
	Critical "off"

	fontSize := 8, fontFace := "Veranda"

	optArr := StrSplit(options,",")

	maxW := 350		; init default values
	selectable := false
	ownerID := 0
	txtColor := "cDefault"
	bgColor := "Default"
	dX := "calc", dY := "calc"

	Loop optArr.Length { ; AHK v1 "Loop % curLoop1" / AHK v2 "Loop curLoop"
		curOpt := optArr[A_Index], curOpt := Trim(curOpt)
		If (InStr(curOpt,"w:") = 1 Or InStr(curOpt,"MaxWidth:") = 1)
			maxW := StrReplace(curOpt,"MaxWidth:",""), maxW := StrReplace(maxW,"w:","")
		Else if (InStr(curOpt,"h:") = 1 Or InStr(curOpt,"MaxHeight:") = 1)
			maxH := StrReplace(curOpt,"MaxHeight:",""), maxH := StrReplace(maxH,"h:","")
		Else If (InStr(curOpt,"selectable:") = 1)
			selectable := true
		Else If (InStr(curOpt,"opt") = 1)
			option := StrReplace(curOpt,"opt:","")
		Else If (InStr(curOpt,"icon:") = 1)
			icon := SubStr(curOpt,6)
		Else If (InStr(curOpt,"buttons:") = 1 Or InStr(curOpt,"btnList:") = 1)
			btnList := SubStr(curOpt,9)
		Else If (InStr(curOpt,"modal:") = 1)
			modal := true, modalID := (StrLen(curOpt)>6)?SubStr(curOpt,7):0
		Else If (InStr(curOpt,"fontFace:") = 1)
			fontFace := StrReplace(curOpt,"fontFace:","")
		Else if (InStr(curOpt,"fontSize:") = 1)
			fontSize := StrReplace(curOpt,"fontSize:","")
		Else If (InStr(curOpt,"btnID:") = 1)
			btnID := true
		Else If (InStr(curOpt,"help:") = 1)
			help := SubStr(curOpt,6), help := help?help:"?"
		Else If (InStr(curOpt,"owner:") = 1)
			owner := true, ownerID := StrReplace(curOpt,"owner:",""), ownerID := (!ownerID)?0:ownerID
		Else If (InStr(curOpt,"x:") = 1)
			dX := SubStr(curOpt,3), dX := dX?dX:"calc"
		Else If (InStr(curOpt,"y:") = 1)
			dY := SubStr(curOpt,3), dY := dY?dY:"calc"
		Else If (InStr(curOpt,"txtColor:") = 1)
			txtColor := SubStr(curOpt,10), txtColor := txtColor?txtColor:"cDefault"
		Else If (InStr(curOpt,"bgColor:") = 1)
			bgColor := SubStr(curOpt,9), bgColor := bgColor?bgColor:"Default"
	}
	dX := !dX?"calc":dX, dY := !dY?"calc":dY	; init dX, dY

	If (modal Or owner) {								; init cHwnd, modal, owner
		If ((modal And owner) Or (modal And !owner))
			cHwnd := modalID
		Else If (owner)
			cHwnd := ownerID

		cHwnd := WinExist("ahk_id " cHwnd)
		If (!cHwnd) {
			msg := "Parent window not found.`r`nHWND: " cHwnd
			MsgBox msg
			return
		} Else
			parent := " +Owner" cHwnd
	} Else
		cHwnd := 0

	retVal := GetMsgDimensions("Try Again",fontFace,fontSize)		; default btn width / height
	bH := retVal.h, bW := retVal.w, bW+=20, bH+=15, retVal := ""	; btn min width / height

	maxHtemp := SysGet(79)
	If (!maxH) ; init maxH
		maxH := maxHtemp-(bW*3)
	If (StrLen(sMsg) > 65535)
		forceSelectable := true

	If (help) {				; set help btn text dim
		helpDim := GetMsgDimensions(help,fontFace,fontSize)
		helpW := helpDim.w, helpH := helpDim.h, helpW+=20, helpH+=15, helpDim := ""
	}

	btnCount := 0, btnDefault := 0, bMW := 0 ; initialize btnCount, btnDefault (excludes help button)
	If (btnList) {
		Loop Parse btnList, "|"
		{
			btnDefault := (!btnDefault And InStr(A_LoopField,"[d]")) ? A_Index : btnDefault
			btnText := A_LoopField, newBtnList .= StrReplace(btnText,"[d]","") "|"
			btnTextProp := InStr(A_LoopField,"["), btnText := btnTextProp?SubStr(btnText,1,btnTextProp-1):btnText
			btnDim := GetMsgDimensions(btnText,fontFace,fontSize), btnCount++
			If (btnDim.w > bW)
				bW := btnDim.w, bH := btnDim.h
		}
		btnList := Trim(newBtnList,OmitChars:="|"), bW+=20, bMW := btnCount*bW, btnDim := "" ; bH+=15       set button group width
	} Else If (!option) {	; default config = OK btn only
		option := 0, btnCount := 1, btnList := "OK", bW+=20, bMW := btnCount*bW ; , bH+=15
	} Else If (option = "" Or option > 6) { ; invalid option specified
		errMsg := "Invalid Option`r`n`r`n"
				. "opt:0 >  OK`r`n"
				. "opt:1 >  OK / Cancel`r`n"
				. "opt:2 >  Abort / Retry / Ignore`r`n"
				. "opt:3 >  Yes / No / Cancel`r`n"
				. "opt:4 >  Yes / No`r`n"
				. "opt:5 >  Retry / Cancel`r`n"
				. "opt:6 >  Cancel / Try Again / Continue"

		MsgBox errMsg
		return
	} Else { ; btn config using pre-defined option
		If (option = 1 Or option = 4 Or option = 5) {
			btnCount := 2, bW+=20, bMW := btnCount*bW ; , bH+=15
			If (option = 1)
				btnList := "OK|Cancel"
			Else If (option = 4)
				btnList := "Yes|No"
			Else If (topion = 5)
				btnList := "Retry|Cancel"
		} Else If (option = 2 Or option = 3 Or option = 6) {
			btnCount := 3, bW+=20, bMW := btnCount*bW ; , bH+=15
			If (option = 2)
				btnList := "Abort|Retry|Ignore"
			Else If (option = 3)
				btnList := "Yes|No|Cancel"
			Else If (option = 6)
				btnList := "Cancel|Try Again|Continue"
		}
	}
	btnDefault := !btnDefault?1:btnDefault
	bMW += help?helpW:0
	msg := GetMsgDimensions(sMsg,fontFace,fontSize,maxW) ; get msg dimensions and line height (txtH)

	maxW := (msg.w>maxW) ? msg.w : maxW
	txtW := msg.w, txtH := msg.lineHeight
	forceSelectable := false		; init txtW, txtH, forceSelectable
	If (msg.h < maxH)		; adjust maxH if msg.h is smaller
		maxH := msg.h

	If (icon) {
		If (icon = "error")
			iconFile := "imageres.dll", iconNum := 94
		Else If (icon = "question")
			iconFile := "imageres.dll", iconNum := 95
		Else If (icon = "warning")
			iconFile := "imageres.dll", iconNum := 80
		Else If (icon = "info")
			iconFile := "imageres.dll", iconNum := 77
		Else If (!InStr(icon,"HBITMAP:") And !InStr(icon,"HICON:")) {
			iconArr := StrSplit(icon,"/"), iconFile := iconArr[1], iconNum := iconArr[2], iconArr := ""
		} Else {
			iconFile := icon, iconHandle := true
		}
	}

	If (txtW < bMW) ; if txtW is smaller, set message width to bMW (bMW = button group width)
		maxW := bMW
	If (bMW > maxW) ; adjust message width to "button group width" if "button group width" is larger
		maxW := bMW

	maxW := !maxW ? 0 : maxW
	maxW := (maxW<150)?150:maxW ; maxW := msg.w

	tempMaxW := SysGet(78)
	maxW := (maxW>tempMaxW?tempMaxW-150:maxW)

	If (msg.h>maxH)
		vScroll := "", forceSelectable := true
	Else
		vScroll := "-VScroll"


	mb2gui := GuiCreate("-SysMenu ",title), MsgBox2hwnd := mb2gui.Hwnd
	; mb2gui.OnEvent("Escape","MsgBox2Escape")
	If (bgColor)
		mb2gui.BackColor := bgColor
	mb2gui.SetFont("s" fontSize,fontFace)
	If (iconFile) {
		If (iconHandle)
			picCtl := mb2gui.Add("Picture","w32 h-1",iconFile)
		Else If (iconNum)
			picCtl := mb2gui.Add("Picture","Icon" iconNum " w32 h-1",iconFile)
		Else
			picCtl := mb2gui.Add("Picture","w32 h-1",iconFile)

		icon := picCtl.Pos
		spacerH := icon.x, newX := "x" (spacerH*2)+32 " yp" ; define some dimensions
	} Else
		spacerH := msg.x, newX := "" ; define some dimensions

	ctl := iconFile?"Static2":"Static1", ctl := selectable?"Edit1":ctl ; define ctl with msg in it

	If (forceSelectable) ; force use edit becuase too large to load at control creation
		selectable := true

	If (!selectable) {
		msgCtl := mb2gui.Add("Text",newX " w" maxW " h" maxH " " txtColor,sMsg) ; sMsg
		msg := msgCtl.Pos
	} Else {
		vScrollW := SysGet(2) ; vertical scroll bar width
		newW := maxW + vScrollW + 5

		r := maxH / txtH ; compensate for no VScroll / get rows of text
		msgCtl := mb2gui.Add("Edit",newX " w" newW " r" r " " vScroll " ReadOnly -Tabstop -E0x200 +Background" bgColor " " txtColor,"") ; sMsg
		msg := msgCtl.Pos

		msgCtl.value := sMsg ; lazy load when using large chunks of text
	}

	i := iconFile?3:2, w := iconFile?32:0, w += msg.w+(spacerH*i), w := (w<bMW)?bMW+(spacerH*i):w

	If (IsObject(icon)) {
		If (msg.h < icon.h) { ; adjust text if icon and certain txt dimensions
			newY := (icon.h/2)+icon.y-(msg.h/2), h := icon.h+(icon.y*2)+20+bH
			msgCtl.Move("y" newY)
		} Else If (msg.h >= icon.h) {
			newY := icon.y - 4, h := msg.h+(msg.y*2)+20+bH
			msgCtl.Move("y" newY)
		}
		nX := (w/2)-(bMW/2), nY := (msg.h<icon.h)?(icon.y+icon.h+20):(msg.y+msg.h+20)
	} Else {
		newY := msg.y, h := msg.h+(msg.y*2)+20+bH
		nX := (w/2)-(bMW/2), nY := msg.y+msg.h+20
	}

	If (nY+bH > h)
		nY := h - (bH*1.5)

	Loop Parse btnList, "|" ; list specified buttons
	{
		If (A_LoopField) { ; make sure button exists, helpful on zero-length string
			def := ""
			btnText := A_LoopField, btnTextProp := InStr(A_LoopField,"[")
			btnProp := btnTextProp?SubStr(btnText,btnTextProp+1):"", btnProp := StrReplace(btnProp,"]","")
			btnText := btnTextProp?SubStr(btnText,1,btnTextProp-1):btnText

			If (A_Index = btnDefault)
				def := " +Default"

			If (A_Index = 1) {
				newBtn := mb2gui.Add("Button","x" nX " y" nY " w" bW " h" bH " +BackgroundTrans" def,btnText)
				newBtn.OnEvent("Click","MsgBox2Event")
				If (def)
					newBtn.Focus()
			} Else {
				newBtn := mb2gui.Add("Button","x+0 w" bW " h" bH " " btnProp def,btnText)
				newBtn.OnEvent("Click","MsgBox2Event")
				if (def)
					newBtn.Focus()
			}
		}
	}
	If (help) ; add help button if specified
		mb2gui.Add("Button","x+0 w" helpW " h" helpH,help).OnEvent("Click","MsgBox2Event")

	If (cHwnd) { ; modal/owner has already been determined/consolidated to "cHwnd"
		mb2gui.Opt("+Owner" cHwnd)
		If (modal)
			WinSetEnabled 0, "ahk_id " cHwnd
	}

	If (dX And dY) {
		yBorder := SysGet(7)
		xBorder := SysGet(8)
		captionHeight := SysGet(4)

		If (dX = "calc")
			dX := "Center"
		If (dY = "calc")
			dY := "Center"
		If (InStr(dX,"-") = 1 Or InStr(dX,"+") = 1)
			dX := (A_ScreenWidth/2) - (w/2) - xBorder + dX
		If (InStr(dY,"-") = 1 Or InStr(dY,"+") = 1)
			dY := (A_ScreenHeight/2) - (h/2) - (captionHeight/2) - yBorder + dY

		mb2gui.Show("w" w " h" h " x" dX " y" dY)
	} Else
		mb2gui.Show("w" w " h" h) ; specify h?

	MsgBox2InputHook := InputHook("V") ; "V" for not blocking input
	MsgBox2InputHook.KeyOpt("{Escape}","N")
	MsgBox2InputHook.OnKeyDown := Func("MsgBox2InputHookKeyDown")
	MsgBox2InputHook.Start(), MsgBox2InputHook.Wait()

	MsgBox2Result := MsgBox2InputHook.UserSelection ; get selection

	colPos := InStr(MsgBox2Result,":")
	value := colPos?SubStr(MsgBox2Result,1,colPos-1):MsgBox2Result, value := (value="ESC")?"":value
	ClassNN := colPos?SubStr(MsgBox2Result,colPos+1):""
	If (!btnID)
		MsgBox2Result := value
	Else
		MsgBox2Result := ClassNN

	If (cHwnd and modal)
		WinSetEnabled 1, "ahk_id " cHwnd

	mb2gui.Destroy(), mb2gui := ""

	Critical oCritic

	return MsgBox2Result
}

MsgBox2event(ctl,*) {
	btnClassNN := ctl.ClassNN, btnText := ctl.Text
	MsgBox2InputHook.UserSelection := btnText ":" btnClassNN
	MsgBox2InputHook.Stop()
}

MsgBox2InputHookKeyDown(iHook, VK, SC) {
	MsgBox2InputHook.UserSelection := "ESC"
	MsgBox2InputHook.Stop()
}

GetMsgDimensions(sString,sFaceName,nHeight,maxW := 0) {
	returnWidth := 0
	Loop Parse sString, "`n", "`r"
	{
		line1 := A_LoopField
		break
	}

	;;;;;;; ==================================================== get line height
	guiObj := GuiCreate(), guiObj.SetFont("s" nHeight,sFaceName)
	curCtl := guiObj.add("Text","",line1)
	ctlSize := curCtl.Pos
	lineH := ctlSize.h
	guiObj.Destroy()
	;;;;;;; ====================================================

	maxH := 0 ; maxW is already set
	fullLen := StrLen(sString)
	curPos := 1, len := 65535

	While (curPos <= fullLen) {
		tinyStr := SubStr(sString,curPos,len)

		guiObj := GuiCreate(), guiObj.SetFont("s" nHeight,sFaceName)
		curCtl := guiObj.add("Text","",tinyStr)
		ctlSize := curCtl.Pos

		returnWidth := (ctlSize.w > returnWidth) ? ctlSize.w : returnWidth
		If (maxW And returnWidth > maxW) {
			returnWidth := maxW
			guiObj.Destroy()
			guiObj := GuiCreate(), guiObj.SetFont("s" nHeight,sFaceName)
			curCtl := guiObj.add("Text","w" maxW,tinyStr)

			ctlSize := curCtl.Pos
		}

		maxH += ctlSize.h
		guiObj.Destroy()

		curPos += len
	}

	retVal := {}
	retVal.w := returnWidth, retVal.h := maxH, retVal.lineHeight := lineH, retVal.x := ctlSize.x, retVal.y := ctlSize.y

	guiObj := "", curCtl := "", ctlSize := ""
	return retVal
}