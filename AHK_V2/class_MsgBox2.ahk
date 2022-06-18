; ================================================================================================
; by: TheArkive
; ================================================================================================
; obj := MsgBox2.New(sMsg,title="",sOptions="")
; ================================================================================================
;    Replaces the MsgBox command and InputBox commands.  MsgBox2 can be used pseudo-inline like
;    a function returning a value selected by the user.  The script thread using Msgbox2 will be
;    halted until the user gives input, as expected from the Msgbox/InputBox commands.  You can
;    also add a CheckBox, EditBox, DropDownList, ComboBox, or ListBox (or any combo of these) to
;    get more input from the user.  Also, the user can right click on the msg and copy the
;    message if desired.
;
;    The default font is the same as the AHK MsgBox command:  Verdana, 8 pt.
;
;    MsgBox2() lets you change MANY aspects about how the dialog is displayed, such as font,
;    font size, dialog margin, button margins, and others.  See the options list below for all
;    the ways you can customize it.
;
;    The automatic sizing of MsgBox2 is based on the following criteria:
;
;        1) Width of message text is automatically sized up to 350 px limit.
;        2) Width of 350 is automatically overridden if certain control text is wider.
;            > Use "`r`n" to add a line break if needed, for example a long label for a checkbox.
;        3) Width limit can be changed with MaxWidth: option.
;        4) Width can be forced to a specific value with Width: option.
;        5) Height is automatically adjusted based on dialog contents.
;        6) Height is limited to 95% of screen height, or by Height: option.
;
;    With a large list of options, it's easy to specify one global string to standardize the dialog
;    style you want, such as font, font size, and certain other options, then just add on specific
;    options when called.  Or you can modify the default options in the class (near the top, check
;    comments) to set the defaults you want to use.
;
; ================================================================================================
; User interaction and accessibility:
; ================================================================================================
;    User can use arrow keys and {Tab} button to navigate the Msgbox2 GUI.  Pressing ESC, ALT+F4,
;    or CTL+F4 closes the dialog and populates the .button and .ClassNN properties with "".
;    Pressing enter will trigger the default button.
;
; ================================================================================================
; Usage / Return Value 
; ================================================================================================
;    Call Msgbox2 as follows:    mb2Var := Msgbox2.New(sMsg,title:="",options:="")
;
;    Once called, the script/thread will be delayed by an InputHook (only used for this delay).
;    When the user interacts with the dialog, or closes it, then the following properties are
;    populated:
;
;        mb2Var.list             row number selected in ListBox
;        mb2Var.listText         text of row number selected in Listbox
;        mb2Var.dropList         row number selected in DropDownList
;        mb2Var.dropListText     text of row number selected in DropDownList
;        mb2Var.combo            row number selected in ComboBox
;        mb2Var.comboText        text of row number selected in ComboBox
;        mb2Var.check            value of Checkbox (1 or 0 / true or false)
;        mb2Var.button           text of the button clicked
;        mb2Var.ClassNN          ClassNN of the button clicked
;
;        NOTE: If user presses a hotkey to close the dialog (ESC, ALT+F4, CTRL+F4) or uses the close
;        button in the top-right, .button and .ClassNN are blank.
;
; ================================================================================================
; Defaults
; ================================================================================================
;    The defaults, if options are not specified, are as follows:
;        Font               = Tahoma
;        Font size          = 8
;        Dialog width       = 350 px (or the width of sMsg)
;        Button width       = widest button
;        Buttons shown      = OK
;        Default button     = 1st created button
;        button alignment   = right
;        Sys close button   = dialog has a close button, top-right
;
;        Not other controls are added by default.
; ================================================================================================
; Options:
; ================================================================================================
; Specify zero or more of the options below - comma (,) separated.
;
;    bgColor:####
;        Specify color of dialog background.  Same format as Gui, Color command.  A blank value
;        after the colon in "bgColor:" uses the default system background color.
;
;        Ex:  bgColor:Blue  OR  bgColor:0000FF  OR  bgColor:0x0000FF
;        > Sets the background to Blue.
;
;    btnAlign:left   OR   btnAlign:center
;        If this option is NOT specified, buttons are right aligned.
;
;    btnList:Num_or_list
;        Use a number (1 thru 6) the same as the Msgbox command to load those buttons, or specify
;        your own list of buttons as a pipe delimited string.  Use &BtnText to allow using ALT as
;        a shortcut.  See GUI, Add, Button help for more info.
;
;        Ex:  btnList:1
;        > Displays (OK / Cancel) buttons.  Number 0-6.  See Msgbox command help for more info.
;
;        Ex:  btnList:OK|&Cancel[d]
;        > Specifies OK and Cancel buttons, and sets the "Cancel" button as the default.  Also, in
;        this example, ALT+C would trigger the Cancel button becuse of using "&".
;
;    btnMarX:#
;        Sets horzintal margin value for buttons.  This is both left and right margins added together.
;        Default is 3 x [avg char width].  Buttons using fixed-width font may benefit from a smaller
;        X margin than the default.  Avg char width is based on font and font size.
;
;        Ex:  btnMarX:25
;        > Sets horizontal button margin total to 25, thus adding 25 px to button text width.
;
;    btnMarY:#
;        Sets vertical margin value for buttons.  This is both top and bottom margins added together.
;        Default is 1 x [avg char height].  Avg char height is based on font and font size.
;
;        Ex:  btnMarY:10
;        > Sets vertical button margin total to 10, thus adding 10 to button text height.
;
;    btnTextW:1
;        If specified, the buttons listed in btnList will be as wide as their display text + button
;        margins (see btnMarX/btnMarY above).  Default button width is the width of the string
;        "Try Again" at the specified font + button margins, OR the widest button text specified.
;
;    check:checkbox_caption:value
;        Specify a checkbox and caption text.  By default, the checkbox will be unchecked.  To change
;        this, specify 1 for the value.
;
;        EX:  check:Don't show again.:1
;        > Adds a checkbox to the dialog with the caption "Don't show again." and will be checked.
;
;    dropList:item|item|item:value
;        Creates a DropDownList with specified options.  Specify "value" as the row number to be
;        pre-selected in the DropDownList.
;
;    edit:edit_string
;        Adds an edit control to the dialog and fills it with optional specified text.
;
;        Ex:  edit:old file name.txt
;        > Adds an edit control and fills it with "old file name.txt"
;
;        NOTE: If you want to add a blank edit box, pass the following:
;           edit:''
;
;    fontFace:font_name_str
;        Sets font face/name.
;
;        Ex:  fontFace:Times New Roman
;
;    fontSize:#
;        Specify a font size.
;
;        Ex:  fontSize:20
;        > Sets font size to 20 for all controls.
;
;    Height:###
;        Defines max pixel height for the sMsg control.  Default height is the natural height of
;        sMsg when wrapped at 350 px (by default) or wrapped at user specified width.  Generally
;        this option is best used when trying to display a LOT of text, such as a log that is
;        meant to be scrolled in an edit box.  Defining Height will also automatically define
;        "Selectable:1" (see below).
;
;        Ex:  Height:500
;        > Sets the Height of sMsg to 500 pixels.
;
;    help:help_btn_text:callback
;        Specify a help button with custom text.  Help button width is set by the help_btn_text
;        specified and will not conform to the default button width.  Clicking a help button will
;        close the dialog and return the help button text in the .button return property, unless
;        a callback function is also specified (and exists).  No parameters are passed to the
;        callback function.  This is just a way to assign a custom action to the help button,
;        such as opening a web page/help document.
;       
;        Ex:  help:Help
;        > This will specify a help button with the text "Help".  Returns "Help" if clicked.
;
;    icon:icon_str
;        Specifies using an icon.  There are a few different ways to use this option:
;
;        Ex:  icon:error   OR   icon:warning   OR   icon:info   OR   icon:question
;        > Specify one of the 4 common icons featured in the Msgbox command.
;
;        Ex:  icon:file.png  OR  icon:file.dll/2
;        > Specify a picture file, or a file and icon index.  Use forward slash (/) as separator.
;
;        EX:  HICON:[handle]  OR  HBITMAP:[handle]
;        > See LoadPicture() for more info on HICON and HBITMAP handles.
;
;    list:item|item|item:value:rowsHeight
;        Creates a ListBox with specified options.  Specify "value" as the row number to be
;        pre-selected in the ListBox.  Specify "rowsHeight" to limit the height of the Listbox.
;        Specifying "value" or "rowsHeight" is optional.
;
;    margin:#
;        Set the number of pixels to use as a margin around the dialog for placing controls.
;        Default value is 10.
;
;    MaxWidth:###
;        Defines max pixel width for the dialog.  Default = 350 px wide or the width of sMsg if sMsg
;        is smaller.
;
;        Ex:  MaxWidth:300
;        > Sets text max width to 300 pixels.  If sMsg is less than 300 px wide, then the width of
;        sMsg will be used instead.
;
;    modal:Hwnd
;        Same effect as parent:Hwnd but also disables the parent window so that the user must click
;        a button close the dialog to continue.  If Modal: is specified then don't specify Parent:.
;
;        Ex:  options := "modal:" HwndVar
;
;    noCloseBtn:1
;        Specify this option to remove the close button in the top right of the dialog.
;
;    parent:Hwnd
;        Specify parent window of msgbox.  Doing so will prevent a taskbar button and keep the
;        dialog on top of the specified parent.  Normally you will pass "Hwnd" as a var.
;
;        Ex:  options := "parent:" HwndVar
;
;    selectable:1
;        Specify this to use a read-only edit control, instead of the default text control.
;
;    txtColor:color_str
;        Specify color of msg text.  Same format as common AHK control style.
;
;        Ex:  txtColor:Red  OR  txtColor:FF0000  OR  txtColor:0xFF0000
;        > Sets the text message color to Red.  A blank value after the colon in "txtColor:" uses
;        the default system txt color.
;
;    width:#
;        Force a specified width of sMsg.  Note that if other specified controls are wider than
;        width:#, then this value will be overridden and the resulting dialog will be wider in 
;        order to be able to display all controls
;
;    x:#, y:#
;        Specify the x,y (top left corner) of the dialog manually.  Both must be specified.
;        By default the dialog is placed centered in front of the parent window if specified.
;        See Modal: and Parent: above for more info.
;
; ================================================================================================
; End Options
; ================================================================================================
; Thanks to robodesign for LOTS of collaboration, ideas, and testing.
;
; Thanks to [just me] for creating TaskDialog that gave me ideas and inspiration.
; https://github.com/AHK-just-me/TaskDialog/blob/master/Sources/TaskDialog.ahk
; ================================================================================================

class msgbox2 {
    maxWidth := 350, width := 0, Height := 0, x := "", y := ""          ; ===== user-adjustable properties
    fontSize := 8, fontFace := "Verdana", txtColor := "Default", bgColor := "Default", btnMarXr := 3, btnMarYr := 1
    btnList := 0, btnTextW := false, btnAlign := "right", help := "", helpText := "",  btnMarx := 0, btnMarY := 0
    parent := 0, modal := 0, selectable := false, noCloseBtn := false, icon := "", margin := 0
    
    criticalValue := A_IsCritical ; thanks to robodesign for this       ; ===== support properties
    minWidth := 150, btnCount := 0, btnDefault := 1, bMWd := 0, bMWc := 0, bMW := 0, scale := A_ScreenDPI / 96
    
    edit:="", editMsg:="", editBox:=false, editText:="",                ; ==== default control settings
    check:="", checkMsg:="", checkMsgVal:=0, checkValue:="",   dropList:="", dropListMsg:="", dropListMsgVal:=1, dropListText:=""
    combo:="", comboMsg:="", comboMsgVal:=1, comboText:="",    list:="", listText:="", listMsg:="", listVal:=1, listRows:=0, ClassNN := ""
    
    helpDims := {}, btnDims := {}, btnListW := [], curMon := 0, pDims := {} ; ==== suggested NO modificatin
    totalWidth := 0, totalHeight := 0, ctlWidth := 0, adjHeight := 0, adjWidth := 0, sPadR := 1.25
    charList := "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ", avg := "", testDlg := ""
    helpCallback := ""
    
    __New(sMsg,title:="",options:="") {
        Critical "off"
        this.sMsg := sMsg, this.options := options, this.title := title, iconHt := 32 * this.scale
        
        mRightClick := ObjBindMethod(this,"RightClick") ; binding methods/events
        OnMessage(0x204,mRightClick)
        mCloseWin := ObjBindMethod(this,"CloseWin")
        OnMessage(0x0112,mCloseWin)
        this.mContextMenu := ObjBindMethod(this,"ContextMenu"), this.mButtonPress := ObjBindMethod(this,"ButtonPress")
        
        errMsg := "Invalid Option`r`n`r`nbtnList:0 >  OK`r`nbtnList:1 >  OK / Cancel`r`nbtnList:2 >  Abort / Retry / Ignore`r`n"
        . "btnList:3 >  Yes / No / Cancel`r`nbtnList:4 >  Yes / No`r`nbtnList:5 >  Retry / Cancel`r`nbtnList:6 >  Cancel / Try Again / Continue`r`n`r`n"
        . "Or`r`n`r`nbtnList:button text|button text|..."
        
        optArr := StrSplit(options,",")         ; parse user options and store
        Loop optArr.Length {
            If ((o := optArr[A_Index])="")
                Continue
            curOpt := SubStr(o,1,(sep:=InStr(o,":"))-1)
            curVal := SubStr(o,sep+1)
            this.%curOpt% := Trim(curVal,":")
        }
        
        this.ProcControls() ; process user specified controls: edit, check, list, dropList, combo
        
        this.parent := this.modal ? this.modal : this.parent
        this.avg := this.txtDims("Testing 1 2 3","avgDims")
        this.btnMarX := this.btnMarX ? this.btnMarX : this.avg.w * this.btnMarXr
        this.btnMarY := this.btnMarY ? this.btnMarY : this.avg.h * this.btnMarYr
        
        this.icon := this.PickIcon(this.icon), this.icon.h := iconHt, this.icon.w := iconHt
        sPad := this.fontSize * this.sPadR, this.sPad := sPad   ; element spacing controlled ; w1.25 / h0.75
        this.dlgMargin := (this.margin ? this.margin : 10)
        this.selectable := this.height ? true : this.selectable
        
        pX := "", pY := "", pW := 0, pH := 0
        If WinExist("ahk_id " this.parent)
            WinGetPos &pX, &pY, &pW, &pH, "ahk_id " this.parent
        this.curMon  := this.MonitorFromPoint(pX,pY), this.pDims := {Cx:(pX+(pW//2)), Cy:(pY+(pH//2))} ; use parent x/y/w/h to determine center point
        this.btnDims := this.txtDims("Try Again","btnDims") ; default button dims / no padding
        
        this.btnList := this.ProcBtnList(this.btnList) ; === button list processing
        If (this.btnList = "") { ; error, display msg and return
            this.__Delete(errMsg)
            return
        }
        
        bMW := 0
        Loop Parse this.btnList, "|" ; initial parsing of btnList
        {
            If (A_LoopField = "")
                Continue
            
            btnText := RegExReplace(A_LoopField,"\[[\w]+\]$","")
            btnProp := RegExReplace(A_LoopField,"^[^\[]+|\[|\]","")
            this.btnDefault := (btnProp = "d") ? A_Index : this.btnDefault
            btnDims := this.txtDims(btnText,"btn" A_Index)
            
            this.btnDims := (btnDims.w > this.btnDims.w) ? btnDims : this.btnDims ; record widest button
            bMW += btnDims.w + this.btnMarX
            this.btnListW.InsertAt(A_Index,btnDims.w)
            
            this.btnCount := A_Index, btnDims := ""
        }
        
        this.bMWd := this.btnCount * (this.btnDims.w + this.btnMarX)    ; bMW default (all btns same width)
        this.bMWc := bMW                                                ; bMW custom (btnTextW)
        
        this.helpDims := this.txtDims(this.helpText,"help"), hDims := this.helpDims.w + this.btnMarX ; add help btn dimensions
        this.bMWd += (this.helpDims.w ? hDims : 0), this.bMWc += (this.helpDims.w ? hDims : 0)
        this.bMW := this.btnTextW ? bMW : this.bMWd                     ; set final bMW
        
        this.MakeGui(1)
    }
    txtDims(str,ctlName,width:=0) {
        If (str="")
            return {x:0,y:0,w:0,h:0}
        width := width ? " w" width : ""
        If (this.testDlg = "" And ctlName = "avgDims") { ; get avg char w/h or add element to get dims
            this.testDlg := Gui(), this.testDlg.SetFont("s" this.fontSize,this.fontFace) ; create dummy GUI, set font
            this.testDlg.Add("text","xm vavgDims",this.charList), this.testDlg["avgDims"].GetPos(&x,&y,&w,&h) ; avg char w/h
        } Else this.testDlg.Add("Text","xm v" ctlName width,str), this.testDlg[ctlName].GetPos(&x,&y,&w,&h) ; add element for x/y/w/h
        return (ctlName = "avgDims") ? {h:h, w:(w//52)} : {x:x, y:y, w:w, h:h}
    }
    __Delete(msg := "") {
        msg ? MsgBox(msg) : "" ; display msgbox if msg/error
        this.gui := "", this.IH := "", this := "" ; release input hook, destroy GUI, etc...
    }
    ProcControls() { ; process user-specified controls
        If this.check
            a := StrSplit(this.check,":"), this.checkMsg := a[1], this.checkMsgVal := (a.Has(2) ? a[2] : 0), this.check := ""
        If this.dropList
            a := StrSplit(this.dropList,":"), this.dropListMsg := a[1], this.dropListMsgVal := (a.Has(2) ? a[2] : 0), this.dropList := ""
        If this.edit
            this.editMsg := ((this.edit="''") ? "" : this.edit), this.editBox := true, this.edit := ""
        If this.combo
            a := StrSplit(this.combo,":"), this.comboMsg := a[1], this.comboMsgVal := (a.Has(2) ? a[2] : 0), this.combo := ""
        If this.list
            a := StrSplit(this.list,":"), this.listMsg := a[1], this.listMsgVal := (a.Has(2) ? a[2] : 0), this.listRows := (a.Has(3) ? a[3] : 0)
        If this.help
            h := StrSplit(this.help,":"), this.helpCallback := (h.Has(2) ? h[2] : ""), this.helpText := h[1], h := ""
    }
    ProcBtnList(b) { ; process btnList as int (0-6) or as "text|text|text..."
        If (Type(b) = "String") And StrLen(b)
            return b
        Else If IsInteger(b) And (b >= 0) And (b <= 6) {
            btnList := (b=0) ? "OK" : (b=1) ? "OK|Cancel" : (b=4) ? "Yes|No" : (b=5) ? "Retry|Cancel" : ""
            btnList := (b=2) ? "Abort|Retry|Ignore" : (b=3) ? "Yes|No|Cancel" : (b=6) ? "Cancel|Try Again|Continue" : ""
        } Else If IsInteger(b) And ((b<0) Or (b>6))
            btnList := ""
        return btnList ; return of "" indicates error
    }
    PickIcon(iconFile) {
        f := "imageres.dll/", t := iconFile ; f = file / t = icon type
        r := (t = "error") ? "e" : (t = "question") ? "q" : (t = "warning") ? "w" : (t = "info") ? "i" : ""
        iconFile := (r="e") ? f "94" : (r="q") ? f "95" : (r="w") ? f "80" : (r="i") ? f "77" : iconFile ; default icons
        
        iArr := StrSplit(iconFile,"/"), iconObj := {}
        iconObj.file := iArr.Has(1) ? iArr[1] : ""
        iconObj.num := iArr.Has(2) ? iArr[2] : "", iArr := ""
        return iconObj
    }
    MakeGui(ver) {
        edit:={hwnd:0}, dropList:={hwnd:0}, check:={hwnd:0}, msg:={hwnd:0}, combo:={hwnd:0}, list:={hwnd:0}
        vScrollW := SysGet(2)
        
        If !this.width {
            msg  := this.txtDims(this.sMsg,"msg",this.maxWidth), msg2 := this.txtDims(this.sMsg,"msg2")
            msg := (msg.w > msg2.w) ? msg2 : msg        ; take the narrowest one - auto-sizing
        } Else msg := this.txtDims(this.sMsg,"msg",this.width)  ; user specified width
        this.ctlWidth := msg.w                                  ; set initial control width
        
        g := Gui("-DPIScale" (this.noCloseBtn ? " -SysMenu" : " -MaximizeBox -MinimizeBox"),this.title)
        g.MarginX := this.dlgMargin, g.MarginY := this.dlgMargin, this.hwnd := g.Hwnd
        g.BackColor := this.bgColor, g.SetFont("s" this.fontSize,this.fontFace)
        
        If (this.icon.file) { ; this.dlgMargin for x and y = orig
            iconOptions := "vicon xm ym h" this.icon.h " w-1" (this.icon.num ? " Icon" this.icon.num : "")
            picCtl := g.Add("Picture",iconOptions,this.icon.file)
            picCtl.GetPos(&x,&y,&w,&h), this.icon := {x:x,y:y,w:w,h:h,hwnd:picCtl.hwnd,num:this.icon.num,file:this.icon.file}
        } ; x:=0 ??? for all?
        
        mX := (this.icon.file) ? "xm+" (this.icon.w + this.sPad) : "xm"     ; adjust x/y/w/h for sMsg
        mY := (this.icon.file And msg.h < this.icon.h) ? " ym+" ((this.icon.h/2) - (msg.h/2)) : " ym"
        mH := (!this.height) ? msg.h : this.height
        mW := msg.w, mW += (this.selectable ? this.avg.w * 4 : 0)
        this.ctlWidth := (this.ctlWidth > mW) ? this.ctlWidth : mW ; msg.w or (msg.w + vScrollW estimate)
        
        selOps := mX mY " h" mH " w" this.ctlWidth " +Background" this.bgColor " c" this.txtColor (this.selectable ? " ReadOnly" : "")
        
        If (this.selectable)
            msgCtl := g.Add("Edit",selOps " vmsgEdit",""), msgCtl.Value := this.sMsg ; necessary when StrLen(sMsg) > 65535
        Else msgCtl := g.Add("Text",selOps " vmsg",this.sMsg)
        
        msgCtl.GetPos(&x,&y,&w,&h), msg := {x:x,y:y,w:w,h:h,hwnd:msgCtl.hwnd} ; redefine msg dims
        newY := (msg.h > this.icon.h) ? (this.dlgMargin + msg.h + this.sPad) : (this.dlgMargin + this.icon.h + this.sPad)
        
        if (this.listMsg) {
            listDims := this.txtDims(StrReplace(this.listMsg,"|","`r`n"),"list"), listArr := StrSplit(this.listMsg,"|")
            this.ctlWidth := ((addW:=listDims.w+(vScrollw*1.5)) > this.ctlWidth) ? addW : this.ctlWidth
            
            listRows := (listArr.Length > 10 And !this.listRows) ? 10 : this.listRows
            listCtl := g.Add("Listbox","xp y" newY " w" this.ctlWidth " Choose" this.listMsgVal " r" listRows " vlist",listArr)
            listCtl.GetPos(&x,&y,&w,&h), list := {x:x,y:y,w:w,h:h,hwnd:listCtl.hwnd}
            newY += list.h + this.sPad, listCtl := ""
        }
        
        if (this.editBox) {
            editDims := this.txtDims(this.editMsg,"edit")
            this.ctlWidth := ((addW:=editDims.w+vScrollW) > this.ctlWidth) ? addW : this.ctlWidth
            
            editCtl := g.Add("Edit","xp y" newY " w" this.ctlWidth " r1 vedit",this.editMsg)
            editCtl.GetPos(&x,&y,&w,&h), edit := {x:x,y:y,w:w,h:h,hwnd:editCtl.hwnd}
            newY += edit.h + this.sPad, editCtl := ""
        }
        
        If (this.dropListMsg) {
            dropListDims := this.txtDims(StrReplace(this.dropListMsg,"|","`r`n"),"dropList"), dropListArr := StrSplit(this.dropListMsg,"|")
            this.ctlWidth := ((addW:=dropListDims.w+(vScrollw*1.5)) > this.ctlWidth) ? addW : this.ctlWidth
            
            dropListCtl := g.Add("DropDownList","xp y" newY " w" this.ctlWidth " Choose" this.dropListMsgVal " vdroplist",dropListArr)
            dropListCtl.GetPos(&x,&y,&w,&h), dropList := {x:x,y:y,w:w,h:h,hwnd:dropListCtl.hwnd}
            newY += dropList.h + this.sPad, dropListCtl := ""
        }
        
        if (this.comboMsg) {
            comboDims := this.txtDims(StrReplace(this.comboMsg,"|","`r`n"),"combo"), comboArr := StrSplit(this.comboMsg,"|")
            this.ctlWidth := ((addW:=comboDims.w+(vScrollw*1.5)) > this.ctlWidth) ? addW : this.ctlWidth
            
            comboCtl := g.Add("ComboBox","xp y" newY " w" this.ctlWidth " Choose" this.comboMsgVal "vcombo",comboArr)
            comboCtl.GetPos(&x,&y,&w,&h), combo := {x:x,y:y,w:w,h:h,hwnd:comboCtl.hwnd}
            newY += combo.h + this.sPad, comboCtl := ""
        }
        
        If (this.checkMsg) {
            chkCtl := g.Add("Checkbox","xp y" newY " vcheck",this.checkMsg), chkCtl.Value := this.checkMsgVal
            c := chkCtl.GetPos(&x,&y,&w,&h), check := {x:x,y:y,w:w,h:h,hwnd:chkCtl.hwnd}
            
            this.ctlWidth := (check.w > this.ctlWidth) ? check.w : this.ctlWidth
            newY += check.h + this.sPad, chkCtl := ""
        }
        
        widthTest := this.ctlWidth + (this.icon.file ? this.icon.w + this.sPad : 0) ; widest control + icon if enabled
        this.ctlWidth := ((this.bMW > widthTest) ? (this.bMW - (this.icon.file ? this.icon.w + this.sPad : 0)) : this.ctlWidth) ; adjust for buttons if needed
        
        For ctlName, o in g
            If (o.Name And o.Name != "msg" And o.Name != "icon") ; adjust control widths
                o.Move(,,this.ctlWidth)
        
        this.totalWidth := this.ctlWidth + (this.dlgMargin*2) + (this.icon.file ? (this.icon.w + this.sPad) : 0)
        this.ctrls := {msg:msg, edit:edit, dropList:dropList, check:check, combo:combo, list:list}
        
        If (this.btnAlign = "center")
            btnX := (this.totalWidth) ? (this.totalWidth/2) - (this.bMW/2) : 0
        Else If (this.btnAlign = "right")
            btnX := (this.totalWidth) ? this.totalWidth - this.bMW - this.dlgMargin : 0
        Else if (this.btnAlign = "left")
            btnX := (this.totalWidth) ? this.dlgMargin : 0
        
        Loop Parse this.btnList, "|" ; list specified buttons
        {
            If (A_LoopField) { ; make sure button exists, helpful on zero-length string
                btnText := RegExReplace(A_LoopField,"\[[\w]+\]$","") ; , btnProp := RegExReplace(A_LoopField,"^[^\[]+|\[|\]","")
                
                xy := (A_Index = 1) ? "x" (!IsSet(btnX) ? "m" : btnX) " y" newY : "x+0"
                bWS := this.btnTextW ? " w" (this.btnListW[A_Index] + this.btnMarX) : " w" (this.btnDims.w + this.btnMarX)
                def := (A_Index = this.btnDefault) ? " +Default" : ""
                curOpts := xy bWS " h" (this.btnDims.h + this.btnMarY) def
                
                btnCtl := g.Add("Button",curOpts,btnText), btnCtl.GetPos(&x,&y,&w,&h), b := {x:x,y:y,w:w,h:h}
                btnCtl.OnEvent("Click",this.mButtonPress)
                def ? btnCtl.Focus() : ""
            }
        }
        
        If (this.helpText) ; add help button if specified
            g.Add("Button","x+0 w" (this.helpDims.w + this.btnMarX) " h" (this.helpDims.h + this.btnMarY) " vhelp",this.helpText).OnEvent("Click",this.mButtonPress)
        
        If (this.parent) {
            g.Opt("+Owner" this.parent)
            If (this.modal)
                WinSetEnabled 0, "ahk_id " this.parent
        }
        g.Show("hide"), this.gui := g, opt := ""
        If this.parent
            g.GetPos(&x,&y,&w,&h), d := {x:x, y:y, w:w, h:h}, x := this.pDims.Cx - (d.w//2), y := this.pDims.Cy - (d.h//2), opt := "x" x " y" y
        g.Show((this.x and this.y) ? "x" this.x " y" this.y : opt)
        
        this.IH := InputHook("V") ; "V" for not blocking input
        this.IH.KeyOpt("{BackSpace}{Escape}{Enter}{Space}{NumpadEnter}{F4}","N") ; not using all these keys, but we might later
        this.IH.OnKeyDown := ObjBindMethod(this,"IHKeyDown")
        this.testDlg.Destroy(), this.testDlg := "", this.IH.Start(), this.IH.Wait()
    }
    RightClick(wParam, lParam, msg, hwnd) {
        If (hwnd = this.hwnd) {
            x := lParam & 0xff, y := (lParam >> (A_PtrSize * 2)) & 0xff
            cMenu := Menu.New(), cMenu.Add("Copy Message",this.mContextMenu), cMenu.Show()
        }
    }
    CloseWin(wParam, lParam, msg, hwnd) {
        If (hwnd = this.hwnd And wParam = 0xF060)
            this.procResult(), this.hwnd := 0
    }
    ContextMenu(ItemName, ItemPos, Menu) {
        clipboard := this.sMsg
    }
    ButtonPress(oCtl, info) {
        If (oCtl.Name = "help" And (Type(this.helpCallback)!="String"))
            cb := this.helpCallback, cb() ; help callback
        Else
            ctlClassNN := oCtl.ClassNN, ctlText := oCtl.Text, bR := [ctlText,ctlClassNN], this.procResult(bR) ; exit with btn clicked
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
    procResult(bR:="") {
        bR := !bR ? ["",""] : bR, this.comboText := "", this.dropListText := ""
        this.combo := 0, this.dropList := 0, this.editText := "", this.checkValue := 0
        
        If (this.ctrls.edit.hwnd)
            ctl := GuiCtrlFromHwnd(this.ctrls.edit.hwnd),     this.editText := ctl.Value
        If (this.ctrls.dropList.hwnd)
            ctl := GuiCtrlFromHwnd(this.ctrls.dropList.hwnd), this.dropList := ctl.Value, this.dropListText := ctl.Text
        If (this.ctrls.combo.hwnd)
            ctl := GuiCtrlFromHwnd(this.ctrls.combo.hwnd),    this.combo := ctl.Value, this.comboText := ctl.Text
        If (this.ctrls.check.hwnd)
            ctl := GuiCtrlFromHwnd(this.ctrls.check.hwnd),    this.checkValue := ctl.Value
        If (this.ctrls.list.hwnd)
            ctl := GuiCtrlFromHwnd(this.ctrls.list.hwnd),     this.list := ctl.Value, this.listText := ctl.Text
        this.buttonText := bR[1],   this.ClassNN := bR[2],    this.IH.Stop()
        
        If this.parent
            WinActivate("ahk_id " this.parent) ; ALT+F4 seems to send parent to background
        If this.modal
            WinSetEnabled(1, "ahk_id " this.modal) ; re-enable parent if modal was used
        
        this.gui.Destroy()
        Critical this.criticalValue
    }
    MonitorFromPoint(ix:="", iy:="") {
        mcm := A_CoordModeMouse, selected := 0 ; save current mouse CoordMode, and init selected
        CoordMode("Mouse", "Screen"), MouseGetPos(&x, &y), CoordMode("Mouse", mcm)
        x := IsInteger(ix) ? ix : x, y := IsInteger(iy) ? iy : y
        Loop MonitorGetCount() {
            MonitorGet(A_Index,&mLeft,&mTop,&mRight,&mBottom)
            selected := ((x >= mLeft) And (x <= mRight) And (y >= mTop) And (y <= mBottom)) ? A_Index : 0
            If selected
                break
        }
        return selected
    }
}
