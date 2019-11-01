; AddClearBtnToEdit.ahk
; http://ahkscript.org/boards/viewtopic.php?f=6&t=6788
/*
	Function: AddClearBtnToEdit
		Add a 'clear text' button over an edit control

	Version:
		1.21 (2015-3-21)
			- Fixed a bug: Create a resizable GUI and edit control with some initialized text, resize the GUI around, the clear text button is not there, or disappears.
		1.20 (2015-3-21)
			- Added .ShowHideBtn() to show/hide the "Clear Btn".
				A single-line edit's changing can now be detected when you using GuiContrl or ControlSetText.
				But if it is a multi-line edit control, you have to call .ShowHideBtn(HEDIT), after using GuiContrl or ControlSetText.
		1.10 (2015-3-21)
			- Added 'OnClick' option
			- Added '.AutoMove()' to move button when Edit's width changed
		1.00 (2015-3-19)

	Usage:
		AddClearBtnToEdit(HEDIT, obj_options="")

	Parameters:
		HEDIT       - The hwnd of the Edit control

		obj_options
			w          - Width
			h          - Height
			c          - Text color
			cBG        - Background color
			border     - Display border (True or False)
			round      - Round the corners (value can be number, word "w" or "h")

			left       - 
			top        -

			tooltip    - Tooltip text on hover
			OnClick    - Call function on button click

			** On hover **
			w_hot      -
			h_hot      -
			c_hot      -
			cBG_hot    -
			border_hot -
			round_hot  -

	Methods:
		AddClearBtnToEdit.AutoMove(arr_hwnd*)
			If your edit control has auto width changing
			, call 'AutoMove' method in the GuiSize lable.

		AddClearBtnToEdit.ShowHideBtn(HEDIT)
			If it is a multi-line edit control, and you have changed the text via GuiContrl or ControlSetText,
			you should call this method to show/hide the 'clear button'.

	Thanks: 
		Example code from 
			just me  (http://www.autohotkey.com/board/topic/80789-one-gui-control-always-on-top-of-another-gui-control/?p=513666)
			Serenity (http://www.autohotkey.com/board/topic/31688-gui-edit-control-inside-left-margin-sp2-vs-98/)
*/

AddClearBtnToEdit(p*) {
	AddClearBtnToEdit.DoIt(p*)
}
Class AddClearBtnToEdit {

	static EM_SETMARGINS := 0x00D3, EC_RIGHTMARGIN := 0x0002
	static oList := {}, oHEDIT := {}, changedHWND
	static Init := AddClearBtnToEdit.Init()

	Init() {
		OnMessage(0x200, "AddClearBtnToEdit.OnMouseMove") ; WM_MOUSEMOVE
		OnMessage(0x202, "AddClearBtnToEdit.OnClick") ; WM_LBUTTONUP
		OnMessage(0x101, "AddClearBtnToEdit.OnKeyUp") ; WM_KEYUP
		OnMessage(0x111, "AddClearBtnToEdit.OnKeyUp") ; WM_COMMAND
		Return True
	}

	OnMouseMove(lParam, msg, hwnd) {
		this := AddClearBtnToEdit

		If this.oList.HasKey(hwnd) { ; mouse hover

			If (this.changedHWND = "") {
				this.changedHWND := hwnd, HGUI := hwnd

				color      := this.oList[HGUI].c_hot, 
				opt_border := this.oList[HGUI].border_hot
				opt_cBG    := this.oList[HGUI].cBG_hot
				opt_round  := this.oList[HGUI].round_hot

				If (this.oList[HGUI].tooltip != "")
					ToolTip, % this.oList[HGUI].tooltip

				SetTimer, __CheckIfMouseIsOutsideGui, 10
			}

		} Else If (this.changedHWND != "") { ; mouse leaved

			HGUI := this.changedHWND, this.changedHWND := ""

			color      := this.oList[HGUI].c
			opt_border := this.oList[HGUI].border
			opt_cBG    := this.oList[HGUI].cBG
			opt_round  := this.oList[HGUI].round

			If (this.oList[HGUI].tooltip != "")
				ToolTip
		}
		
		If (color = "")
			Return

		; change text color
		Gui, %HGUI%:Font, c%color%
		GuiControl, %HGUI%:Font, % this.oList[HGUI].ctrl

		; change background color
		If (this.oList[HGUI].cBG this.oList[HGUI].cBG_hot != "")
			Gui, %HGUI%:Color, % opt_cBG

		; add/remove border
		If (this.oList[HGUI].border this.oList[HGUI].border_hot)
			WinSet, Style, % opt_border ? "+0x800000" : "-0x800000", % "ahk_id " this.oList[HGUI].ctrl

		; round the GUI
		If (this.oList[HGUI].round this.oList[HGUI].round_hot)
			WinSet, Region, % opt_round, % "ahk_id " HGUI
		Return

		__CheckIfMouseIsOutsideGui:
			If !this.changedHwnd
				Return

			MouseGetPos,,, hWin
			If (hWin != this.oList[this.changedHwnd].parentHGUI)
			{
				SetTimer, %A_ThisLabel%, Off
				HGUI := this.ChangedHwnd, this.ChangedHwnd := ""

				Gui, %HGUI%:Font, % "c" this.oList[this.changedHwnd].c
				GuiControl, %HGUI%:Font, % this.oList[HGUI].ctrl
				If (this.oList[HGUI].tooltip != "")
					ToolTip
			}
		Return
	}

	OnKeyUp(lParam, msg, hwnd) {
		static WM_COMMAND := 0x111, EN_CHANGE := 0x0300

		If (msg = WM_COMMAND) && (this>>16 = EN_CHANGE)
			hwnd := lParam
		
		this := AddClearBtnToEdit

		If this.oHEDIT.HasKey(hwnd)
			this.ShowHideBtn(hwnd)
	}

	OnClick(lParam, msg, hwnd) {
		this := AddClearBtnToEdit

		If (hwnd = this.changedHWND) {
			ControlSetText,,, % "ahk_id " this.oList[hwnd].HEDIT
			WinHide, % "ahk_id " hwnd
			this.oList[hwnd].isHidden := True
		}

		this.oList[hwnd].onClick.(  this.oList[hwnd].HEDIT  )
	}

	DoIt(HEDIT, obj_options="") {
		; Button_Clear options
		; 
		static defaultOpt := { w: 18, h: 18
		                     , c    : "Gray", cBG    : "White", border    : False, round    : 0
		                     , c_hot: "Red" , cBG_hot: "White", border_hot: False, round_hot: 0
		                     , left: 0, top: 0, tooltip: "", onClick: "" }
		opt := {}
		For k, v in defaultOpt
			opt[k] := (obj_options[k] = "") ? v : obj_options[k]

		GuiControlGet, Edit, Pos, %HEDIT%
		If (EditH < opt.h)
			opt.h := EditH

		If (opt.border opt.border_hot)
			opt.h -= 4, opt.w -= 4
		If ( (EditH-opt.h) < 4 )
			opt.h := EditH - 4

		opt_str := "w" opt.w " h" opt.h " c" opt.c " " (opt.border ? "border" : "")

		; Create Button_Clear (child GUI)
		; 
		Gui, New, -Caption +Parent%HEDIT% +HwndHGUI +LabelAddClearBtnToEdit
		Gui, Margin, 0, 0
		fontSize := (opt.w < opt.h) ? opt.w//1.5 : opt.h//1.5
		Gui, Font, % "s" fontSize, Marlett
		Gui, Color, % opt.cBG
		Gui, Add, Text, %opt_str% 0x201 hwndHTEXT, r ; r is the close button 'X'

		x := EditW - opt.w - 4 + opt.left, y := opt.top
		ControlGetText, editText,, ahk_id %HEDIT%
		Gui, %HGUI%:Show, % "x" x " y" y (editText = "" ? " Hide" : " NA")

		; round_settings
		; 
		rw     := rh     := (opt.round     ? opt.round     : opt.w)
		rw_hot := rh_hot := (opt.round_hot ? opt.round_hot : opt.w)

		rw     := rh     := RegExReplace(rw,     "i)w", opt.w)
		rw     := rh     := RegExReplace(rw,     "i)h", opt.h)
		rw_hot := rh_hot := RegExReplace(rw_hot, "i)w", opt.w)
		rw_hot := rh_hot := RegExReplace(rw_hot, "i)h", opt.h)

		roundValues     := "0-0 w" opt.w " h" opt.h " r" rw     "-" rh
		roundValues_hot := "0-0 w" opt.w " h" opt.h " r" rw_hot "-" rh_hot
		If opt.round
			WinSet, Region, % roundValues, % "ahk_id " HGUI

		; 
		; 
		GuiHwnd := DllCall("GetParent", "UInt", HEDIT)
		Gui, %GuiHwnd%:Default

		; Modify edit control
		; 
		GuiControl, +0x02000000, %HEDIT% ; WS_CLIPCHILDREN := 0x02000000
		WinSet, Style, -0x200000, % "ahk_id " HEDIT ; Remove VScroll
		PostMessage, this.EM_SETMARGINS, this.EC_RIGHTMARGIN, % 65536*(opt.w-opt.left),, ahk_id %HEDIT%

		; ------------------------------------

		this.oList[HGUI] := { ctrl: HTEXT, parentHGUI: GuiHwnd, HEDIT: HEDIT, isHidden: (editText = "")
		               , c: opt.c, c_hot: opt.c_hot
		               , border: opt.border, border_hot: opt.border_hot
		               , cBG: opt.cBG, cBG_hot: opt.cBG_hot
		               , round: opt.round ? roundValues : "", round_hot: opt.round_hot ? roundValues_hot : ""
		               , tooltip: opt.tooltip, onClick: opt.onClick
		               , xPos: x, yPos: y }
		this.oHEDIT[HEDIT] := HGUI
	}

	; Auto move x postion of the 'clear button', when edit's width changing.
	; Note: This method should call in the GuiSize label.
	AutoMove(arr_hwnd*) {
		static Ori_GuiWidth

		If !Ori_GuiWidth
			Return Ori_GuiWidth := A_GuiWidth

		For i, HEDIT in arr_hwnd {
			HGUI := this.oHEDIT[HEDIT]
			x    := this.oList[HGUI].xPos + (A_GuiWidth - Ori_GuiWidth)
			y    := this.oList[HGUI].yPos
			hide := (this.oList[HGUI].isHidden ? "Hide" : "NA")
			Gui, %HGUI%:Show, x%x% y%y% %hide%
		}
	}

	; Show/Hide the 'clear button', by checking the edit's text is null or not.
	; Note: This method is only needed, when the edit is multiple line
	;       , and you have executed "ControlSetText" or "GuiControl" to change the edit text.
	ShowHideBtn(HEDIT) {
		ControlGetText, text,, % "ahk_id " HEDIT
		If (text = "") && !this.oList[ this.oHEDIT[HEDIT] ].isHidden {
			this.oList[ this.oHEDIT[HEDIT] ].isHidden := True
			WinHide, % "ahk_id " this.oHEDIT[HEDIT]
		}
		Else If (text != "") && this.oList[ this.oHEDIT[HEDIT] ].isHidden {
			this.oList[ this.oHEDIT[HEDIT] ].isHidden := False
			WinShow, % "ahk_id " this.oHEDIT[HEDIT]
		}
	}
}
