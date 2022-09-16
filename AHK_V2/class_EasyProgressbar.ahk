; Ahk V2
; https://www.autohotkey.com/boards/viewtopic.php?f=83&t=76150
; The Arkive from 19.05.2020
; ============================================================================================
; Progress bar window contains a MainText element (above the progress bar), a SubText element
; (below the progress bar), the progress bar itself, and an optional title bar.
;
; Here are the defaults:
;	Font                  = Verdana
;	Font Size (subText)   = 8
;	Font Size (mainText)  = subTextSize + 2
;   Main/SubText value    = blank unless specified
;	display coords        = primary monitor
;	default range         = 0-100
;
; ============================================================================================
; Create Progress Bar
;	obj := progress2.New(rangeStart := 0, rangeEnd := 100, sOptions := "")
;		> specify start and end range
;		> specify options to initialize certain values on creation (optional)
;
; Methods:
;	obj.Update(value := "", mainText := "", subText := "")
;		> value = numeric within the specified range
;		> mainText / subText: update the text above / below the progress bar
;		> if you want to clear the mainText or subText pass a space, ie. " "
;		> to leave mainText / SubText unchanged, pass a zero-length string, ie. ""
;
;	obj.Close()
;		> closes the progress bar
;
; ============================================================================================
; Options on create.  Comma separated string including zero or more of the below options.
; MainText / SubText are the text above / below the progress bar.
;
;	fontFace:font_str
;		> set the font for MainText / SubText
;
;	fontSize:###
;		> set font size for MainText / SubText (MainText is 2 pts larger than SubText)
;
;	mainText:text_str
;		> creates the Progress Bar with specified mainText (above the progress bar)
;
;	mainTextAlign:left/right/center
;		> specifies alignment of mainText element.
;
;	mainTextSize:#
;		> sets custom size for mainText element.
;
;	modal:Hwnd
;		> same as parent, but also disables the parent window while progressbar is active
;
;	parent:Hwnd
;		> defines the parent GUI window, and prevents a taskbar icon from appearing
;
;	start:#
;		> defines the starting numeric withing the specified range on creation
;
;	subText:text_str
;		> creates the Pogress Bar with specified subText (below the progress bar)
;
;	subTextAlign:left/right/center
;		> specifies alignment of subText element.
;
;	title:title_str
;		> Defines a title and ensures there is a title bar.  This allows normal moving of the
;		  progress bar by click-dragging the title bar.  No title hides the title bar and
;		  prevents the window from being moved by the mouse (by normal means).
;
;	w:###
;		> sets a specific pixel width for the progress bar
;
;	x:###  And  y:###  (specify both and separate by comma in options string)
;		> sets custom x/y coords to display the progress bar window.  Specify both or none.
;
; ============================================================================================

; ============================================================================================
; Example
; ============================================================================================
; gui := GuiCreate()
; gui.AddText("w600 h300","Test GUI")
; gui.show("x200 y200")

; F10:: ; press F10 to show dialog, press again to increment and close
	; If (!IsObject(prog)) {
		; options := "mainText:Test Main Text,subText:Test Sub Text,title:test title,"
		; options .= "start:25,modal:" gui.hwnd
		; prog := progress2.New(0,100,options)
	; } Else {
		; prog.Update(50," ","Test 3")
		; Sleep 2000
		; prog.Close()
	; }
; return

; F12::ExitApp

class progress2 {
	__New(rangeStart := 0, rangeEnd := 100, sOptions := "") {
		; ====================================================
		; default options
		; ====================================================
		this.rangeStart := rangeStart, this.rangeEnd := rangeEnd

		this.fontFace := "Verdana", this.fontSize := 8
		this.mainTextSize := this.fontSize + 2
		this.mainTextAlign := "left", this.subTextAlign := "left"

		this.mainText := " ", this.subText := " ", this.title := ""

		this.start := 0
		this.modal := false, this.hParent := 0

		this.width := 300
		this.x := "", this.y := ""

		this.mainTextHwnd := 0, this.subTextHwnd := 0

		; ====================================================
		; read user defined options
		; ====================================================
		optArr := StrSplit(sOptions,Chr(44))
		Loop optArr.Length {
			valArr := StrSplit(optArr[A_Index],":")
			curOpt := valArr[1], curVal := valArr[2]

			If (curOpt = "fontFace")
				this.fontFace := curVal ? curVal : fontFace
			Else If (curOpt = "fontSize")
				this.fontSize := curVal ? curVal : fontSize
			Else If (curOpt = "mainText")
				this.mainText := curVal
			Else If (curOpt = "subText")
				this.subText := curVal
			Else If (curOpt = "start")
				this.start := curVal ? curVal : start
			Else if (curOpt = "title")
				this.title := curVal
			Else If (curOpt = "parent")
				this.hParent := curVal ? curVal : 0
			Else If (curOpt = "modal")
				this.hParent := curVal ? curVal : 0, this.modal := curVal ? true : false
			Else if (curOpt = "w")
				this.width := curVal ? curVal : 300
			Else If (curOpt = "mainTextSize")
				this.mainTextSize := curVal ? curVal : this.mainTextSize
			Else If (curOpt = "mainTextAlign")
				this.mainTextAlign := curVal ? curVal : this.mainTextAlign
			Else if (curOpt = "subTextAlign")
				this.subTextAlign := curVal ? curVal : this.subTextAlign
			Else If (curOpt = "x")
				this.x := curVal ? curVal : ""
			Else If (curOpt = "y")
				this.y := curVal ? curVal : ""
		}

		this.ShowProgress()
	}
	ShowProgress() {
		showTitle := this.title ? "" : " -Caption +0x40000" ; 0x40000 = thick border
		range := this.rangeStart "-" this.rangeEnd
		g := GuiCreate("AlwaysOnTop -DPIScale -SysMenu" showTitle,this.title)
		g.SetFont("s" this.fontSize,this.fontFace)

		align := this.mainTextAlign
		mT := g.AddText("vMainText " align " w" this.width,this.mainText)
		this.mainTextHwnd := mT.hwnd
		mT.SetFont("s" this.mainTextSize)

		prog := g.AddProgress("vProgBar y+m xp w" this.width " Range" range,this.start)
		this.progHwnd := prog.hwnd

		align := this.subTextAlign
		sT := g.AddText("vSubText " align " w" this.width,this.subText)
		this.subTextHwnd := sT.hwnd

		If (this.hParent) {
			WinGetPos pX, pY, pW, pH, "ahk_id " this.hParent
			Cx := pX + (pW/2), Cy := pY + (pH/2)

			borderW := SysGet(32)
			captionH := SysGet(4)
			captionH := this.title ? captionH : 0
			borderH := SysGet(7)

			w := prog.pos.w + (g.MarginX * 2) + (borderW * 2)
			h := g.pos.h + captionH + (borderH * 2) + mT.pos.h + sT.pos.h + (g.MarginY * 4)
			x := Cx - (w/2), y := Cy - (h/2)
			g.Opt("+Owner" this.hParent)

			If (this.modal)
				WinSetEnabled 0, "ahk_id " this.hParent
		}
		If (this.x != "" And this.y != "")
			x := this.x, y := this.y

		coords := ""
		If (x And y)
			coords := "x" x " y" y

		g.Show(coords)
		this.guiHwnd := g.hwnd
		this.gui := g
	}
	Update(value := "", mainText := "", subText := "") {
		If (value != "")
			this.gui["ProgBar"].Value := value
		If (this.mainTextHwnd And mainText)
			this.gui["MainText"].Text := mainText
		If (this.subTextHwnd And subText)
			this.gui["SubText"].Text := subText
	}
	Close() {
		If (IsObject(this.gui))
			this.gui.Destroy()

		If (this.modal)
			WinSetEnabled 0, "ahk_id " hParent
		If (this.hParent)
			WinActivate "ahk_id " hParent

		this.__Delete()
	}
	__Delete() {
		this.gui := ""
		this := ""
	}
}