class CFlyout
{
	/*
	----------------------------------------------------------------------------------------------------------------------------------
	public:
	----------------------------------------------------------------------------------------------------------------------------------
	*/
	; Shows the flyout.
	 Show()
	{
		this.EnsureCorrectDefaultGUI()
		GUI, Show

		WinGetPos, iX,,,, % "ahk_id" this.m_hFlyout
		if (iX <= -32768)
			WinMove, % "ahk_id" this.m_hFlyout,, this.m_iX

		this.m_bIsHidden := false
		return
	}

	; Hides the flyout and sets the ListBox selection to 1 (if needed).
	Hide()
	{
		this.EnsureCorrectDefaultGUI()
		GUI, Hide

		this.m_bIsHidden := true

		return
	}

	; Wrapper for OnMessage. All window messages that need monitoring should be sent through this function instead of directly sent to native OnMessage
		; 1.Msgs is a comma-delimited list of Window Messages. All messages are initially directed towards CFlyout_OnMessage.
	; Class-specific functionality, such as WM_LBUTTONDOWN messages, are handled in this function.
		; 2.sCallback is the function name of a callback for CFlyout_OnMessage. sCallback must be a function that takes two parameters: a CFlyout object and a msg.
	OnMessage(msgs, sCallback="")
	{
		static WM_LBUTTONDOWN:=513, WM_KEYDOWN:=256

		Loop, Parse, msgs, `,
		{
			if (A_LoopField = "ArrowDown")
			{
				; TODO: VK_KeyDown?
				Hotkey, IfWinActive, % "ahk_id" this.m_hFlyout
					Hotkey, Down, CFlyout_OnArrowDown
			}
			else if (A_LoopField = "ArrowUp")
			{
				Hotkey, IfWinActive, % "ahk_id" this.m_hFlyout
					Hotkey, Up, CFlyout_OnArrowUp
			}
			else if (A_LoopField = "Copy")
			{
				Hotkey, IfWinActive, % "ahk_id" this.m_hFlyout
					Hotkey, ^C, CFlyout_OnCopy
			}
			else OnMessage(A_LoopField, "CFlyout_OnMessage")

			if (%A_LoopField% == WM_LBUTTONDOWN)
				this.m_bHandleClick := false
		}

		if (this.m_bHandleClick)
			OnMessage(WM_LBUTTONDOWN, "CFlyout_OnMessage")

		this.m_sCallbackFunc := sCallback
		return
	}

	; 1. Currently iW is simply set to m_iW. Sometime in the future, iW will be automatically assigned based on a m_iMaxWidth variable.
	; 2. Sets iH to what CalcHeight() returns.
	GetWidthAndHeight(ByRef riW, ByRef riH)
	{
		; The two lines below ensure that these are out params (as opposed to in/out).
		riH := riW :=

		if (this.m_bAutoSizeW)
		{
			while (A_Index <= this.m_iMaxRows
				&& A_Index + this.m_vTLB.TopIndex < this.m_asItems.MaxIndex())
			{
				sTmp := this.m_asItems[A_Index + this.m_vTLB.TopIndex + 1]

				iTmpW := Str_MeasureText(sTmp == "" ? "a" : sTmp, this.m_hFont).right
				if (iTmpW < this.m_iW && iTmpW > riW)
					riW := iTmpW
				; Msgbox % st_concat("`n", sTmp, iTmpW, this.m_iW)

				; Transparent LB doesn't support word wrap.
				;~ Str_Wrap(sTmp == "" ? "a" : sTmp, this.m_iW, this.m_hFont, true, iTmpH)
				riH += this.m_vTLB.ItemHeight
			}

			riW += 9
			; TODO: Dynamic scrollbar stuff.
			if (this.m_asItems.MaxIndex() > this.m_iMaxRows) ; Scrollbar is 18px wide.
				riW += 17
			riH += 4 ; Why do I have this?
		}
		else
		{
			riW := this.m_iW

			iRows := this.m_asItems.MaxIndex()
			if (iRows > this.m_iMaxRows)
				iRows := this.m_iMaxRows
			riH := this.m_vTLB.ItemHeight * iRows
			riH += 4 ; For some reason the entire height is short by 5px, no matter how many items (I think). It is concerning that it is necessary.
		}

		if (!riW)
			iW := this.m_iW
		if (!riH)
			riH := Str_MeasureText("a", this.m_hFont).bottom ; Str_Wrap("a", this.m_iW, this.m_hFont, true, riH)

		return
	}

	; Calculates height of flyout based on the widest string in m_asItems. Height will be no greater than m_iH.
	CalcHeight()
	{
		while (A_Index <= this.m_iMaxRows)
		{
			sTmp := this.m_asItems[A_Index + this.m_vTLB.TopIndex]

			if (A_Index + this.m_vTLB.TopIndex > this.m_asItems.MaxIndex())
				break

			iTmpW := Str_MeasureText(sTmp == "" ? "a" : sTmp, this.m_hFont).right
			if (iTmpW < this.m_iW && iTmpW > riW)
				riW := iTmpW

			; Transparent LB doesn't support.
			;~ Str_Wrap(sTmp == "" ? "a" : sTmp, this.m_iW, this.m_hFont, true, iTmpH).
			riH += this.m_vTLB.ItemHeight
		}

		if (riW == A_Blank)
			iW := this.m_iW
		if (riH == A_Blank)
			;~ Str_Wrap("a", this.m_iW, this.m_hFont, true, riH).
			riH := this.m_vTLB.ItemHeight

		riW += 9
		if (this.m_asItems.MaxIndex() > this.m_iMaxRows) ; Scrollbar is 18px wide.
			riW += 18
		riH += 5

		return
	}

	; Calculates height from TopIndex (topmost item being display) to item number iTo. Used in CFlyoutMenuHandler.
	CalcHeightTo(iTo)
	{
		VarSetCapacity(RECT, 16, 0)
		SendMessage, %LB_GETITEMRECT%, iTo, % &RECT, , % "ahk_id" this.m_hListBox
		return NumGet(RECT, 12, "Int")
		;~ This.ItemHeight := NumGet(RECT, 12, "Int") - NumGet(RECT, 4, "Int")

		while (A_Index <= iTo)
		{
			sTmp := this.m_asItems[A_Index + this.m_vTLB.TopIndex]

			if (A_Index + this.m_vTLB.TopIndex > this.m_asItems.MaxIndex())
				break

			Str_Wrap(sTmp, this.m_iW, this.m_hFont, true, iTmpH)
			iH += iTmpH
		}

		if (iH == A_Blank)
			Str_Wrap("a", this.m_iW, this.m_hFont, true, iH)

		return iH
	}

	; Returns currently selected item in flyout.
	GetCurSel()
	{
		ControlGet, sCurSel, Choice, ,, % "ahk_id" this.m_hListBox
		return sCurSel
	}

	; Returns index of currently selected item in flyout.
	GetCurSelNdx()
	{
		return this.m_vTLB.CurSel
	}

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	/*
		Author: just Verdlin
		Function: SetItem
			Purpose: To change a single item
		Parameters
			sData: New string
			iAt: Which string to replace
	*/
	SetItem(sData, iAt)
	{
		this.m_asItems[iAt] := sData
		this.m_vTLB.Items[iAt] := sData
		this.m_vTLB.RedrawItem(iAt-1)

		return
	}
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	; Finds the string and returns the index.
	FindString(sString)
	{
		ControlGet, iString, FindString, %sString%,, % "ahk_id" this.m_hListBox
		return iString
	}

	Move(bUp)
	{
		static LB_SETCURSEL:=390

		iSel := bUp ? this.m_vTLB.CurSel - 1: this.m_vTLB.CurSel + 1
		if (iSel > this.m_vTLB.ItemCount - 1) ; Wrap to top
			SendMessage, LB_SETCURSEL, 0, 0, , % "ahk_id" this.m_hListBox
		else if (iSel < 0) ; Wrap to bottom
			SendMessage, LB_SETCURSEL, % this.m_vTLB.ItemCount - 1, 0, , % "ahk_id" this.m_hListBox
		else SendMessage, LB_SETCURSEL, % iSel, 0, , % "ahk_id" this.m_hListBox ; Move Up/Down

		return
	}

	MoveTo(iTo)
	{
		static LB_SETCURSEL:=390
		SendMessage, LB_SETCURSEL, iTo-1, 0,, % "ahk_id" this.m_hListBox
		return
	}

	MovePage(bUp)
	{
		if (bUp)
			ControlSend,,{PgUp}, % "ahk_id" this.m_hListBox
		else ControlSend,,{PgDn}, % "ahk_id" this.m_hListBox

		return
	}

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	/*
		Author: Verdlin
		Function: Click
			Purpose:
		Parameters
			iClickY: Where to click
	*/
	Click(iClickY)
	{
		ControlClick,, % "ahk_id " this.m_hListBox,,,, y%iClickY%
		return
	}
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	/*
		Author: Verdlin
		Function: GetRowPosForClick
			Purpose: For external scripts to simulate clicks from a position.
		Parameters
			iClickY
	*/
	GetRowPosForClick(iClickY)
	{
		iLoop := (this.m_asItems.MaxIndex() < this.m_iMaxRows ? this.m_asItems.MaxIndex() : this.m_iMaxRows)
		Loop %iLoop% ; the flyout should never be larger than the height of this.m_iMaxRows
		{
			iTop := iBottom ? iBottom : 0
			iBottom += this.m_vTLB.ItemHeight

			if (iClickY < iBottom && iClickY >= iY)
				return A_Index
		}

		return
	}
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	/*
		Author: Verdlin
		Function: Scroll
			Purpose:
		Parameters
			bUp: Scroll up or down
	*/
	Scroll(bUp)
	{
		static WM_VSCROLL:=0x0115
		PostMessage, WM_VSCROLL, % !bUp, 0,, % "ahk_id " this.m_hListBox
		return
	}
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	/*
		Author: Verdlin
		Function: RemoveItem
			Purpose:
		Parameters
			iItem: Index of item to remove
	*/
	RemoveItem(iItem)
	{
		Control, Delete, %iItem%,, % "ahk_id " this.m_hListBox
		this.m_asItems.Remove(iItem)
		this.RedrawControls()
		return
	}
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	; Updates flyout with new items specified in aStringList; aStringList is assigned to m_asItems	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	/*
		Author: Verdlin
		Function: UpdateFlyout
			Purpose: Update flyout with new items
		Parameters
			aStringList = 0
				If aStringList is 0, then the flyout is redrawn using m_asItems which may or may not be unchanged.
				If aStringList is non-zero, then potential changes in the flyout include changes in Height,
				and changes in X and Y positioning (depending on m_iAnchorAt, m_bDrawBelowAnchor and m_bFollowMouse).
	*/
	UpdateFlyout(aStringList = 0)
	{
		this.EnsureCorrectDefaultGUI()

		if (aStringList == 0)
			aStringList := this.m_asItems
		else this.m_asItems := aStringList ; Set up new cmd list for display.

		; List box. Note: Redrawing will happen in RedrawControls().
		;this.m_vTLB.Items := this.m_asItems
		GUIControl,, m_vLB, % "|" this.GetCmdListForListBox() ; First | replaces all the LB contents
		;GUIControl, Choose, m_vLB, 1 ; Choose the first entry in the list.

		if (this.m_bIsHidden)
			this.Show()

		; Redraw and resize GUI controls, if needed.
		this.RedrawControls()

		return
	}
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	; GUI interface for editing Flyout_Config.ini. May be callable without initializing any CFlyout object like so, “CFlyout.GUIEditSettings()”
		; 1. hParent is for parentage GUI. If nonzero, then the parent window will be deactivated until the GUI is closed.
		; 2. sGUI is used to determine whether or not GUIEditSettings should be a standalone GUI with its own window
			; or simply added to an existing GUI. i.e. (GUIEditSettings(hGUI1, “1”))
		; 3. bReloadOnExit : if true, Reload will be executed when the GUI is closed.
			; This is useful if you are using multiple flyouts in one script and want them all to be updated with your latest changes.
	GUIEditSettings(hParent=0, sGUI="", bReloadOnExit=false)
	{
		global

		LV_Colors()

		; http://msdn.microsoft.com/en-us/library/windows/desktop/aa511453.aspx#sizing
		local iMSDNStdBtnW := 75
		local iMSDNStdBtnH := 23
		local iMSDNStdBtnSpacing := 6
		;~ GUI, Margin, %iMSDNStdBtnSpacing%, %iMSDNStdBtnSpacing%

		; Load settings from Flyout_config.ini
		this.LoadDefaultSettings()

		; If we are editing from an existing flyout, use the current background (b/c it may have been overridden from the constructor).
		local vExistingFlyout := Object(CFlyout.FromHwnd[WinExist("A")])
		local sBkgdParm := "Background=" this.m_sBackground
		if (IsObject(vExistingFlyout))
			sBkgdParm := "Background=" vExistingFlyout.m_sBackground
		g_vTmpFlyout := new CFlyout(["This is a preview", "1", "2", "3"], "ShowOnCreate=True", sBkgdParm)
		g_vConfigIni := class_EasyIni(A_WorkingDir "\Flyout_config.ini")
		g_bReloadOnExit := bReloadOnExit

		if (sGUI == "")
			GUI GUIFlyoutEdit: New, hwndg_hFlyoutEdit Resize MinSize, Flyout Settings
		else GUI %sGUI%:Default

		GUI, Add, ListView, xm y5 w450 r20 AltSubmit hwndhLV vvGUIFlyoutEditLV gGUIFlyoutEditLVProc, Option|Value
		LV_Colors.OnMessage()
		LV_Colors.Attach(hLV)

		GUIControlGet, iLV_, Pos, vGUIFlyoutEditLV
		GUI, Add, Button, % "xp yp+" iLV_H+iMSDNStdBtnSpacing " w450 h" iMSDNStdBtnH " vvGUIFlyoutEditSettings gGUIFlyoutEditSettings", &Edit

		if (sGUI == "")
		{
			GUI, Add, Button, % "xp+" 450-(iMSDNStdBtnW*2)-iMSDNStdBtnSpacing " yp+" iMSDNStdBtnH+iMSDNStdBtnSpacing " w" iMSDNStdBtnW " hp vvGUIFlyoutEditGUIOK gGUIFlyoutEditGUIOK", &OK
			GUI, Add, Button, % "xp+" iMSDNStdBtnW+iMSDNStdBtnSpacing " yp wp hp vvGUIFlyoutEditGUIClose gGUIFlyoutEditGUIClose", &Cancel
		}

		local key, val, iColorRowNum
		GUIControl, -Redraw, %hLV%
		for key, val in this.m_vConfigIni.Flyout
		{
			LV_Add("", key, val)
			if (key = "FontColor" || key = "HighlightColor")
				LV_Colors.Cell(hLV, A_Index, 2, val)
		}
		LV_ModifyCol()
		GUIControl, +Redraw, %hLV%

		g_hOwner := sGUI == "" ? hParent : g_hFlyoutEdit
		if (g_hOwner)
		{
			GUI +Owner%g_hOwner%
			WinSet, Disable,, ahk_id %g_hOwner%
		}

		if (sGUI == "")
		{
			GUI Show, x-32768 AutoSize
			this.CenterWndOnOwner(g_hFlyoutEdit, g_hOwner)
		}
		else WinActivate, ahk_id %g_hOwner% ; Owner was de-activated through creation of g_vTmpFlyout.

		GUIControl, Focus, vGUIFlyoutEditLV
		LV_Modify(1, "Select")
		LV_Modify(1, "Focus")

	; Wait for dialog to be dismissed
	while (sGUI == "" && WinExist("ahk_id" g_hFlyoutEdit))
	{
		if (g_hOwner && !WinExist("ahk_id" g_hOwner))
			break ; If the owner was closed somehow, then this dialog should also be closed.
		continue
	}

		return

		GUIFlyoutEditLVProc:
		{
			if (A_GUIEvent = "DoubleClick" || A_EventInfo == 113) ; 113 = F2
			{
				gosub GUIFlyoutEditSettings
				return
			}
			else if (GetKeyState("Ctrl"), GetKeyState("c"))
				clipboard := LV_GetSelText(2)

			return
		}

		GUIFlyoutEditSettings:
		{
			GUI +OwnDialogs

			sCurRowCol1 := LV_GetSelText()
			sCurRowCol2 := LV_GetSelText(2)

			if (sCurRowCol1 = "Background")
			{
				FileSelectFile, sVal
				if (!sVal) ; User cancelled
					return
			}
			else if (sCurRowCol1 = "Font")
			{
				sFontName := SubStr(sCurRowCol2, 1, InStr(sCurRowCol2, ",") - 1)
				sFont := SubStr(sCurRowCol2, InStr(sCurRowCol2, ",") + 1)

				; Basically, we want to hide to color option in this font dialog so as not to confuse users.
				; It is inferior to the actual color picker dlg from Dlg_Color because it does not allow you to
				; choose/define custom colors
				SetTimer, GUIFlyout_HideColorOption, 100
				if (Fnt_ChooseFont(g_hFlyoutEdit, sFontName, sFont))
				{
					sVal := sFontName ", " sFont
					StringReplace, sVal, sVal, c000000,, All
					LV_Modify(LV_GetSel(), "", sCurRowCol1, sVal)

					g_vConfigIni.Flyout.Font := sVal
					gosub GUIFlyoutUpdateTmpFlyout
					return
				}

				gosub GUIFlyoutUpdateTmpFlyout
				return
			}
			else if (sCurRowCol1 = "FontColor" || sCurRowCol1 = "HighlightColor")
			{
				sTmpColor := g_vConfigIni.Flyout[sCurRowCol1]
				sColor := Dlg_Color(sTmpColor, g_hFlyoutEdit)
				sVal := RGB(sColor)

				GUIControl, -Redraw, %hLV%
				LV_Colors.Cell(hLV, LV_GetSel(), 2, sVal)
				GUIControl, +Redraw, %hLV%
			}
			else
			{
				InputBox, sVal,, %sCurRowCol1%`n`n%sAdditional%,,325,175,,,,,%sCurRowCol2%

				if (ErrorLevel)
					return
			}

			LV_Modify(LV_GetSel(), "", sCurRowCol1, sVal)
			g_vConfigIni.Flyout[sCurRowCol1] := sVal

			gosub GUIFlyoutUpdateTmpFlyout
			return
		}

		GUIFlyout_HideColorOption:
		{
			IfWinNotActive, Font ahk_class #32770
				return

			Control, Hide,, Static4, Font ahk_class #32770
			Control, Hide,, ComboBox4, Font ahk_class #32770

			ControlGet, bHidden, Visible,, ComboBox4, Font ahk_class #32770
			if (!bHidden)
				SetTimer, GUIFlyout_HideColorOption, Off
			return
		}

		GUIFlyoutUpdateTmpFlyout:
		{
			g_vTmpFlyout :=

			aKeysValsCopy := {}
			for key, val in g_vConfigIni.Flyout
			{
				if (InStr(val, "Expr:"))
					aKeysValsCopy.Insert(key, DynaExpr_EvalToVar(SubStr(val, InStr(val, "Expr:") + 5)))
				else aKeysValsCopy.Insert(key, val)
			}

			g_vTmpFlyout := new CFlyout(["This is a preview", "1", "2", "3"]
				, "ReadOnly=" aKeysValsCopy.ReadOnly, "ShowInTaskbar=" aKeysValsCopy.ShowInTaskbar
				, "ShowOnCreate=" aKeysValsCopy.ShowOnCreate, "AutoSizeW=" aKeysValsCopy.AutoSizeW
				, "X="aKeysValsCopy.X, "Y="aKeysValsCopy.Y, "W="aKeysValsCopy.W
				, "R="aKeysValsCopy.MaxRows, "AnchorAt="aKeysValsCopy.AnchorAt
				, "DrawBelowAnchor="aKeysValsCopy.DrawBelowAnchor, "Background="aKeysValsCopy.Background
				, "Font="aKeysValsCopy.Font " c" aKeysValsCopy.FontColor
				, "AlwaysOnTop="aKeysValsCopy.AlwaysOnTop, "ExitOnEsc="aKeysValsCopy.ExitOnEsc
				, "Highlight=t" aKeysValsCopy.HighlightTrans " c" aKeysValsCopy.HighlightColor)

			WinActivate, ahk_id %g_hFlyoutEdit%
			return
		}

		GUIFlyoutEditGUISize:
		{
			Critical

			if (g_hFlyoutEdit)
			{
				Anchor2("GUIFlyoutEdit:vGUIFlyoutEditLV", "xwyh", "0, 1, 0, 1")
				Anchor2("GUIFlyoutEdit:vGUIFlyoutEditSettings", "xwyh", "0, 1, 1, 0")
				Anchor2("GUIFlyoutEdit:vGUIFlyoutEditGUIOK", "xwyh", "1, 0, 1, 0")
				Anchor2("GUIFlyoutEdit:vGUIFlyoutEditGUIClose", "xwyh", "1, 0, 1, 0")

				; ControlGetPos because GUIControlGet is not working here
				ControlGetPos, iLVX, iLVY, iLVW, iLVH,, ahk_id %hLV%
				iResize := iLVW / 4
				LV_ModifyCol(1, iResize)
				LV_ModifyCol(2, iLVW - iResize - 5)
			}
			return
		}
		GUIFlyoutEditGUIEscape:
		GUIFlyoutEditGUIOK:
		{
			; Save settings
			g_vConfigIni.Save()
			g_vConfigIni:=
		} ; Fall through
		GUIFlyoutEditGUIClose:
		{
			if (g_hOwner)
				WinSet, Enable,, ahk_id %g_hOwner%

			if (g_bReloadOnExit)
				Reload

			GUI, Destroy
			g_vTmpFlyout :=
			return
		}
	}

	/*
	----------------------------------------------------------------------------------------------------------------------------------
	private:
	----------------------------------------------------------------------------------------------------------------------------------
	*/
	; Note, hParent and asTextToDisplay excluded, any parameter that is set to 0 will instead be set via their
	; corresponding key/value pair in Flyout_config.ini. If a value still cannot be set, creation will likely fail.
		; 1. hParent = 0. If nonzero, must be a valid handle to a window; when set, the CFlyout will become the child of hParent.
		; 2. asTextToDisplay = 0. AHK [] linear array of strings. These will be displayed on the GUI.
			; Each element of the array will be separated by a newline. If any element of the array is too wide,
				; the text will be wrapped accordingly.
		; 3. bReadOnly = 0. When true, the GUI is non-clickable, and no selection box is shown.
		; 4. bShowInTaskbar = 0. Typically used when CFlyout is used like a control instead of a window –
			; you wouldn’t want your “control” showing up in the taskbar. 
		; 5. iX = 0. X coordinate. When iX AND iY are less than -32768, CFlyout will follow your mouse like a Tooltip;
			; it wouldn’t make sense to make CFlyout non-readonly and also set it to follow your mouse, but you can anyway.
			; See DictLookup for an example of how/why you would do this.
		; 6. iY = 0. Y coordinate. Also needs to be set to be to less than -32768 in order for CFlyout to follow the mouse.
		; 7. iW = 0. Width of the Flyout, in pixels. Text will be wrapped based on this number.
		; 8. iMaxRows = 10. Determines the maximum height of the Flyout. Height is dynamically set based on the number
			; of elements in asTextToDisplay. If iMaxRows is set to 10 and there are 11 elements in asTextToDisplay,
			; then the 11th element will not show up on the Flyout; instead, it will can be scrolled down to
			; and will be located beneath the 10th element, naturally.
		; 9. iAnchorAt = -99999. Y Coordinates to “anchor” Flyout GUI to. When set to a number less than -32768,
			; this is effectively telling CFlyout to not anchor to any point. When blank, it loads the setting from CFlyout_Config.ini
		; 10. bDrawBelowAnchor = true. Completely ignored if iAnchorAt < -32768; when true, subsequent Flyout
			; redraws/resizes will place the Top of the Flyout below the specified point; when false,
			; it will place the Bottom of the Flyout above the specified point.
		; 11. sBackground = 0. Background picture for Flyout. If 0 or an invalid file, then the background will be all Black.
		; 12. sFont = 0. Font options in native AHK format sans color. For example, “Arial, s15 Bold”
		; 13. sFontColor = 0. Font color in native AHK format (so it can be hex code or plain color like “Blue”)
		; 14. bFollowMouse=True
	__New(asTextToDisplay, aParms*)
	{
		; TODO: Fix bug where if not text is passed on, we don't select the first item upon init.
		global
		local iLocX, iLocY, iLocW, iLocH, iLocScreenH, sLocPreventFocus, sLocShowInTaskbar, sLocNoActivate

		; Settings important to CFlyout.
		SetWinDelay, -1
		CoordMode, Mouse ; Defaults to Screen.

		; Load settings from Flyout_config.ini
		this.LoadDefaultSettings()

		; Make sure we at least have a blank list of items.
		if (!asTextToDisplay.MaxIndex())
			asTextToDisplay := [""]
		this.m_asItems := asTextToDisplay

		; Override default settings by parsing function parms.
		this.ParseParms(aParms)

		; Naming convention is GUI_FlyoutN. If, for example, 2 CFlyouts already exists, name this flyout GUI_Flyout3.
		Loop ; until we find an unused CFlyout.
		{
			GUI, GUI_Flyout%A_Index%:+LastFoundExist
			IfWinExist
				continue

			iFlyoutNum := A_Index
			break
		}

		this.m_iFlyoutNum := iFlyoutNum
		if (this.m_sTitle == "")
			this.m_sTitle := "GUI_Flyout" + this.m_iFlyoutNum
		GUI, GUI_Flyout%iFlyoutNum%: New, +Hwndg_hFlyout, % this.m_sTitle
		this.m_hFlyout := g_hFlyout
		CFlyout.FromHwnd[g_hFlyout] := &this ; for OnMessage handlers.

		Hotkey, IfWinActive, ahk_id %g_hFlyout%
		{
			if (this.m_bExitOnEsc)
				Hotkey, Esc, CFlyout_GUIEscape
		}

		; Font and color settings
		GUI, Font, s10, Verdana  ; Set 10-point Verdana.
		GUI, Font, % SubStr(this.m_sFont, InStr(this.m_sFont, ",") + 1) " " this.m_sFontColor, % SubStr(this.m_sFont, 1, InStr(this.m_sFont, ",") - 1) ; c000080 ; c83B2F7 ; EEAA99
		GUI, Color, Black ; a black background helps reduce the eye's natural reaction to the blinking effect.

		; Add picture
		; Not specifying width and height so that image does not get morphed.
		GUI, Add, Picture, +0x4 AltSubmit X0 Y0 hwndg_hPic vm_vPic, % this.m_sBackground

		; Add ListBox but don't populate it until we make it transparent.
		sLocShowBorder := (this.m_bShowBorder ? "" : "-E0x200")
		GUI, Add, ListBox, % "x0 y0 r" (this.m_asItems.MaxIndex() > this.m_iMaxRows ? this.m_iMaxRows : this.m_asItems.MaxIndex()) " Choose1 vm_vLB HWNDg_hListBox 0x80 " sLocShowBorder, % this.GetCmdListForListBox() ; 0x80 allows tabs.
		this.m_hListBox := g_hListBox
		this.m_hFont := Fnt_GetFont(this.m_hListBox)
		this.m_vTLB := new TransparentListBox(g_hListBox, g_hPic ; Handles
			, SubStr(this.m_sFontColor, 2), SubStr(this.m_sFontColor, 2) ; Font
			, this.m_sHighlightColor, this.m_sHighlightTrans) ; Highlight
		; Drawing
		this.RedrawControls()
		GUIControl, Choose, m_vLB, 1 ; Choose the first entry in the list.

		this.GetWidthAndHeight(iLocW, iLocH)

		; End controls init. Begin GUI init
		if (this.m_hParent)
		{
			GUI, % "+Owner" this.m_hParent
			if (this.m_bReadOnly)
				WinSet, Disable,, ahk_id %g_hFlyout%
		}

		iLocX := this.m_iX
		iLocY := this.m_iY
		if (this.m_iAnchorAt != "" && this.m_iAnchorAt > -99999)
		{
			iLocScreenH := GetMonitorRectAt(iLocX, iLocY).bottom
			iLocY := iLocScreenH - iLocH - this.m_iAnchorAt
			if (this.m_bDrawBelowAnchor)
				iLocY := iLocScreenH - this.m_iAnchorAt
		}

		if (this.m_bFollowMouse)
		{
			GetRectForTooltip(iLocX, iLocY, iLocW, iLocH)
			g_hMouseHook := DllCall("SetWindowsHookEx", "int", WH_MOUSE_LL:=14 , "uint", RegisterCallback("CFlyout_MouseProc"), "uint", 0, "uint", 0)
		}

		; See http://www.autohotkey.com/board/topic/21449-how-to-prevent-the-parent-window-from-losing-focus/
		sLocPreventFocus := this.m_bReadOnly ? "+0x40000000 -0x80000000" : ""
		sLocShowInTaskbar := this.m_bShowInTaskbar ? "" : "+ToolWindow"
		sLocAlwaysOnTop := this.m_bAlwaysOnTop ? "AlwaysOnTop" : ""
		GUI, +LastFound -Caption %sLocAlwaysOnTop% %sLocPreventFocus% %sLocShowInTaskbar%

		sLocNoActivate := this.m_bReadOnly ? "NoActivate" : ""
		if (this.m_asItems.MaxIndex() && this.m_bShowOnCreate) ; If we have text to display and should show it on creation, do it now.
			GUI, Show, X%iLocX% Y%iLocY% W%iLocW% H%iLocH% %sLocNoActivate%
		else ; create the GUI but keep it hidden.
		{
			GUI, Show, X-32768 Y%iLocY% W%iLocW% H%iLocH% %sLocNoActivate%
			this.Hide()
			WinMove, % "ahk_id" this.m_hFlyout,, %iLocX%
		}

		; TODO: Allow it to optionally be calculated up-front?
		; Perform time-consuming operations after display.
		this.CalcSeparator()

		return this


		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		;;;;;;;;;;;;;;
		CFlyout_GUIEscape:
		{
			Object(CFlyout.FromHwnd[WinExist("A")]).__Delete()
			return
		}
		;;;;;;;;;;;;;;
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		;;;;;;;;;;;;;;
		CFlyout_OnArrowDown:
		{
			vFlyout := Object(CFlyout.FromHwnd[WinExist("A")])
			vFlyout.Move(false)
			return Func(vFlyout.m_sCallbackFunc).(vFlyout, VK_DOWN:=40)
		}
		;;;;;;;;;;;;;;
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		;;;;;;;;;;;;;;
		CFlyout_OnArrowUp:
		{
			vFlyout := Object(CFlyout.FromHwnd[WinExist("A")])
			vFlyout.Move(true)
			return Func(vFlyout.m_sCallbackFunc).(vFlyout, VK_UP:=38)
		}
		;;;;;;;;;;;;;;
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		;;;;;;;;;;;;;;
		CFlyout_OnCopy:
		{
			vFlyout := Object(CFlyout.FromHwnd[WinExist("A")])

			; If there's a callback, let the callback do what it wants.
			if (IsFunc(vFlyout.m_sCallbackFunc))
				return Func(vFlyout.m_sCallbackFunc).(vFlyout, "Copy")
			; else just copy m_sCurSel to clipboard.
			clipboard := vFlyout.m_sCurSel

			return
		}
		;;;;;;;;;;;;;;
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	}

	; Handles safe destruction of all objects CFlyout is responsible for. It is very important to note that,
	; since CFlyout.FromHwnd stores references to CFlyout classes, any object that is assigned a Flyout
	; (i.e. vFlyout := Object(CFlyout.FromHwnd[WinExist(“A”)])) must be released (i.e. vFlyout :=)
	; in order for __Delete to automatically be called upon removal of original Flyout object
	; assigned via vFlyout := new CFlyout(…))
	; Any special destructor handling should go in here.
	__Delete()
	{
		global CFlyout, g_hMouseHook
		this.EnsureCorrectDefaultGUI()

		if (this.m_bFollowMouse)
			DllCall("UnhookWindowsHookEx", "ptr", g_hMouseHook)

		GUI, Destroy
		CFlyout.FromHwnd.Remove(this.m_hFlyout)
		this:=g_hMouseHook:=

		return
	}

	; aName permutations are: GetFlyoutX, GetFlyoutY, GetFlyoutW, GetFlyoutH. These options are wrappers for WinGetPos of the flyout window.
	__Get(aName)
	{
		WinGetPos, iX, iY, iW, iH, % "ahk_id" this.m_hFlyout
		if (aName = "GetFlyoutX")
			return iX
		if (aName = "GetFlyoutY")
			return iY
		if (aName = "GetFlyoutW")
			return iW
		if (aName = "GetFlyoutH")
			return iH
		if (aName = "m_sCurSel")
			return this.GetCurSel()
		if (aName = "m_iCurSel")
			return this.GetCurSelNdx()
		if (aName = "m_bExists")
			return this.Exists()

		return
	}

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	/*
		Author: Verdlin
		Function: ParseParms
			Purpose: Parse parms in aParms and set appropriate member variables
		Parameters
			aParms
	*/
	ParseParms(aParms)
	{
		static s_asKeysMap := { X: "iX", Y: "iY", W: "iW", R: "iMaxRows", AnchorAt: "iAnchorAt", AutoSizeW: "bAutoSizeW"
		, FollowMouse: "bFollowMouse", DrawBelowAnchor: "bDrawBelowAnchor", ShowOnCreate: "bShowOnCreate"
		, ExitOnEsc: "bExitOnEsc", ReadOnly: "bReadOnly", ShowInTaskbar: "bShowInTaskbar"
		, AlwaysOnTop: "bAlwaysOnTop", Parent: "hParent", Background: "sBackground"
		, Font: "sFont", Highlight: "sHighlightColor", Separator: "sSeparator", ShowBorder: "bShowBorder"
		, Title: "sTitle"}

		for iParm, sParm in aParms
		{
			sParm := Trim(sParm) ; Spaces can mess things up.

			iPosOfEquals := InStr(sParm, "=")
			sKey := SubStr(sParm, 1, iPosOfEquals-1)
			sVal := SubStr(sParm, iPosOfEquals+1)

			; Build string list of errors.
			bValidKey := true
			if (!s_asKeysMap.HasKey(sKey))
			{
				bValidKey := false
				sErrors .= (sErrors ? "`n" : "") "Invalid key:`t" sKey "=" sVal
			}

			if (sKey = "Font")
			{
				; Add keys first or else weird crashes can happen.
				this.m_sFont := this.m_sFontColor := ""

				; Format is native GUI format: Consolas, s16 c0xFF
				iCommaPos := InStr(sVal, ",")
				if (iCommaPos)
				{
					sFontOpts := SubStr(sVal, iCommaPos+1)
					StringSplit, aFontOpts, sFontOpts, %A_Space%
					; Find font color c0xFF.
					Loop %aFontOpts0%
					{
						sFontOpt := Trim(aFontOpts%A_Index%) ; Spaces seriously mess things up.
						if (SubStr(sFontOpt, 1, 1) = "c")
						{
							this.m_sFontColor := sFontOpt
							; Now set m_sFont.
							StringReplace, sNewFont, sVal, %sFontOpt%
							this.m_sFont := sNewFont
							break
						}
					}
					; If no font color was specified, m_sFont is simply the val
					if (!this.m_sFont)
						this.m_sFont := sVal
				}
			}
			else if (sKey = "Highlight")
			{
				; Add keys first or else weird crashes can happen.
				this.m_sHighlightTrans := this.m_sHighlightColor :=

				; Format is t200 c0x0
				iCommaPos := InStr(sVal, ",")
				sOpts := SubStr(sVal, iCommaPos+1)
				StringSplit, aOpts, sOpts, %A_Space%
				; Find font color c0xFF.
				Loop %aOpts0%
				{
					sOpt := Trim(aOpts%A_Index%) ; Spaces seriously mess things up.
					sSubKey := SubStr(sOpt, 1, 1)
					sSubVal := SubStr(sOpt, 2)

					if (sSubKey = "t")
						this.m_sHighlightTrans := sSubVal
					else if (sSubKey = "c")
						this.m_sHighlightColor := sSubVal
				}
			}
			else
			{
				sClassKey := s_asKeysMap[sKey]

				; Is this a bool?
				if (SubStr(sClassKey, 1, 1) = "b")
					sVal := (sVal == true || sVal = "true")

				; Dynamically set key/val pair!
				this["m_" sClassKey] := sVal
			}
		}

		; Display list of errors for non-compiled scripts.
		if (sErrors && !A_IsCompiled)
			Msgbox 8256,, %sErrors%

		return
	}
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	; Loads settings for flyout from Flyout_Config.ini. If any options are not specified,
	; the default options specified in GetDefaultConfigIni will be used. If any unknown keys are in the inis, they are simply ignored.
	; You can override default settings in __New
	LoadDefaultSettings()
	{
		vDefaultConfigIni := class_EasyIni("", this.GetDefaultConfigIni())
		this.m_vConfigIni := class_EasyIni(A_WorkingDir "\Flyout_config.ini")
		; Merge allows new sections/keys to be added without any compatibility issues
		; Invalid keys/sections will be removed since bRemoveNonMatching (by default) is set to true
		this.m_vConfigIni.Merge(vDefaultConfigIni)
		this.m_vConfigIni.Save() ; So the old ini gets the new data.

		for key, val in this.m_vConfigIni.Flyout
		{
			if (InStr(val, "Expr:"))
				val := DynaExpr_EvalToVar(SubStr(val, InStr(val, "Expr:") + 5))

			if (key = "X")
				this.m_iX := val
			else if (key = "Y")
				this.m_iY := val
			else if (key = "W")
				this.m_iW := val
			else if (key = "AutoSizeW")
				this.m_bAutoSizeW := (val == true || val = "true")
			else if (key = "Title")
				this.m_sTitle := val
			else if (key = "MaxRows")
				this.m_iMaxRows := val
			else if (key = "AnchorAt")
				this.m_iAnchorAt := val
			else if (key = "DrawBelowAnchor")
				this.m_bDrawBelowAnchor := (val == true || val = "true")
			else if (key = "Background")
				this.m_sBackground := val
			else if (key = "ReadOnly")
				this.m_bReadOnly := (val == true || val = "true")
			else if (key = "ShowInTaskbar")
				this.m_bShowInTaskbar := (val == true || val = "true")
			else if (key = "ShowOnCreate")
				this.m_bShowOnCreate := (val == true || val = "true")
			else if (key = "ExitOnEsc")
				this.m_bExitOnEsc := (val == true || val = "true")
			else if (key = "AlwaysOnTop")
				this.m_bAlwaysOnTop := (val == true || val = "true")
			else if (key = "Font")
			{
				; This is probably only an issue for me, but it's nice to fix it for me.
				StringReplace, val, val, c000000,, All
				this.m_sFont := val
			}
			else if (key = "FontColor")
				this.m_sFontColor := "c" val
			else if (key = "HighlightColor")
				this.m_sHighlightColor := val
			else if (key = "HighlightTrans")
				this.m_sHighlightTrans := val
			else if (key = "ShowBorder")
				this.m_bShowBorder := (val == true || val = "true")
			; else Errors here cause a crash. It's weird, and I think it has to do with DynaExpr.
			; but is erroring even a good idea? What if it's just a deprecated key?
			; For now, let's just ignore it.
		}

		return true
	}

	; Redraw any controls that need redrawing
	; Called from UpdateFlyout. To update the flyout with new text, call UpdateFlyout instead.
	RedrawControls()
	{
		this.EnsureCorrectDefaultGUI()

		; If the cmd list has been updated, then this will use the new dimensions needed for the GUI;
		; otherwise, it uses the dimensions that the GUI is already using.
		this.GetWidthAndHeight(iWidth, iHeight)

		iX := this.GetFlyoutX
		iY := this.GetFlyoutY
		if (iX < -32768 || iX == A_Blank)
			iX := this.m_iX
		if (iY < -32768 || iY == A_Blank)
			iY := this.m_iY

		if (this.m_iAnchorAt >= -32768)
		{
			iScreenH := GetMonitorRectAt(iX, iY).bottom
			if (this.m_bDrawBelowAnchor)
				iY := iScreenH - this.m_iAnchorAt
			else iY := iScreenH - iHeight - this.m_iAnchorAt
		}
		else if (this.m_bFollowMouse)
			GetRectForTooltip(iX, iY, iWidth, iHeight)

		WinMove, % "ahk_id" this.m_hFlyout,, iX, iY, iWidth, iHeight

		; Update TLB.
		GUIControl, Move, m_vLB, X0 Y0 W%iWidth% H%iHeight%
		this.m_vTLB.Update()

		GUIControl, Move, m_vPic, X0 Y0

		return
	}

	GetCmdListForDisplay(iStartAt = 0)
	{
		asCmdListForDisplay := []
		while (A_Index <= this.m_iMaxRows)
		{
			if (iStartAt+A_Index > this.m_asItems.MaxIndex())
				break

			asCmdListForDisplay.Insert(this.m_asItems[iStartAt+A_Index])
		}

		return st_glue(asCmdListForDisplay)
	}

	; Formats items for display on ListBox control.
	GetCmdListForListBox()
	{
		return st_glue(this.m_asItems, "|")
	}

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	/*
		Author: Verdlin
		Function: CalcSeparator
			Purpose: To calc separator and set m_sSeparatorLine
		Parameters
			
	*/
	CalcSeparator()
	{
		; This avoids infinite recursion in Str_GetMaxCharsForFont.
		if (this.m_sSeparator = "")
			this.m_sSeparator := "-"

		iMaxChars := Str_GetMaxCharsForFont(this.m_sSeparator, this.m_iW, this.m_hFont)

		this.m_sSeparatorLine :=
		Loop % iMaxChars
			this.m_sSeparatorLine .= "-"

		return
	}
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	/*
		Author: Verdlin
		Function: Clear
			Purpose: Clear the flyout
		Parameters
			bUpdate: Update flyout after clearing?
	*/
	Clear(bUpdate = false)
	{
		this.m_asItems := []
		if (bUpdate)
			this.UpdateFlyout()

		return
	}
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	/*
		Author: Verdlin
		Function: Exists
			Purpose: Returns true if the win exists. Used by callers to keep their code stationary while the flyout exists.
				Common use case: Flyout as dialog, while (vFlyout.Exists()) continue; then destory flyout.
		Parameters
			
	*/
	Exists()
	{
		return WinExist("ahk_id" this.m_hFlyout)
	}
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	/*
		Author: Verdlin
		Function: AddLine
			Purpose: To add a separator line
		Parameters
			iAt: Where to insert the separator. Inserted at bottom, if blank.
			bUpdate: Update flyout after adding line?
	*/
	AddLine(iAt="", bUpdate=false)
	{
		if (iAt)
			this.m_asItems.InsertAt(iAt, this.m_sSeparatorLine)
		else this.m_asItems.Insert(this.m_sSeparatorLine)

		if (bUpdate)
			this.UpdateFlyout()

		return
	}
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	/*
		Author: Verdlin
		Function: AddText
			Purpose: To add text
		Parameters
			iAt: Where to insert the text. Inserted at bottom, if blank.
			bUpdate: Update flyout after adding text?
	*/
	AddText(sText, iAt="", bUpdate=false)
	{
		if (iAt)
			this.m_asItems.InsertAt(iAt, sText)
		else this.m_asItems.Insert(sText)

		if (bUpdate)
			this.UpdateFlyout()

		return
	}
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	; Safety function to ensure that all GUI commands used by the class are directed towards the right GUI.
	EnsureCorrectDefaultGUI()
	{
		iFlyoutNum := this.m_iFlyoutNum
		GUI, GUI_Flyout%iFlyoutNum%:Default
		return
	}

	; Default ini for Flyout_Config.ini. Function is used is used for class_EasyIni object to provide
	; a safe way to push new sections and keys to Flyout_Config.ini without changing any existing settings in Flyout_Config.ini.
	GetDefaultConfigIni()
	{
		return "
			(LTrim
				[Flyout]
				AnchorAt=-99999
				Background=Default.jpg
				Font=Arial, s15
				FontColor=White
				HighlightColor=0x6AEFF
				HighlightTrans=85
				MaxRows=10
				AlwaysOnTop=false
				ReadOnly=false
				ShowInTaskbar=false
				ShowOnCreate=true
				ExitOnEsc=true
				X=0
				Y=0
				W=400
				AutoSizeW=false
				ShowBorder=true
				Title=
			)"
	}

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	/*
		Author: Verdlin
		Function: CenterWndOnOwner
			Purpose:
		Parameters
			hWnd: Window to center.
			hOwner=0: Owner of hWnd with which to center hWnd upon. If 0 or WinGetPos fails,
				window is centered on primary monitor.
	*/
	CenterWndOnOwner(hWnd, hOwner=0)
	{
		WinGetPos,,, iW, iH, ahk_id %hWnd%

		WinGetPos, iOwnerX, iOwnerY, iOwnerW, iOwnerH, ahk_id %hOwner%
		if (iOwnerX == A_Blank)
		{
			iOwnerX := 0
			iOwnerY := 0
			iOwnerW := A_ScreenWidth
			iOwnerH := A_ScreenHeight
		}

		iXPct := (100 - ((iW * 100) / (iOwnerW)))*0.5
		iYPct := (100 - ((iH * 100) / (iOwnerH)))*0.5

		iX := Round((iXPct / 100) * iOwnerW + iOwnerX)
		iY := Round((iYPct / 100) * iOwnerH + iOwnerY)

		WinMove, ahk_id %hWnd%, , iX, iY

		return
	}
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	; Member Variables

	; public:
		; [Flyout] in Flyout_config.ini. All may also be set from __New
		m_iX :=
		m_iY :=
		m_iW :=
		m_iMaxRows :=
		m_iAnchorAt :=
		m_bDrawBelowAnchor :=
		m_bReadOnly :=
		m_bShowInTaskbar :=
		m_bAlwaysOnTop :=

		m_sBackground :=

		; Font Dlg
		m_sFont :=
		m_sFontColor :=
		m_sHighlightColor :=
		m_sHighlightTrans :=
		; End Flyout_config.ini section.

	; private:
		m_vConfigIni := {}

		m_bFollowMouse := false ; Set to true when m_iX and m_iY are less than -32768
		static m_iMouseOffset := 16 ; Static pixel offset used to separate mouse pointer from Flyout when m_bFollowMouse is true

		m_sSeparator := ; The idea is to fill a completely empty line a specified separator such as "-"
		m_sSeparatorLine :=

		m_bIsHidden := ; True when Hide() is called. False when Show() is called.

		; Handles
		m_hFlyout := ; Handle to main GUI
		m_hListBox :=
		m_hFont := ; Handle to logical font for Text control
		m_hParent := ; Handle to parent assigned from hParent in __New

		; Control IDs
		m_vLB :=

		m_iFlyoutNum := ; Needed to multiple CFlyouts
		m_asItems := [] ; Formatted for Text control display purposes

		; OnMessage callback
		m_sCallbackFunc := ; Function name for optional OnMessage callbacks
		m_bHandleClick := true ; Internally handle clicks by moving selection.
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;; Message handler for all messages specified through CFlyout.OnMessage.
;;;;;;;;;;;;;; Class-specific functionality, such as WM_LBUTTONDOWN messages, are handled in this function.
CFlyout_OnMessage(wParam, lParam, msg, hWnd)
{
	Critical

	; hWnd isn't always the flyout, so we can't use that.
	; A_GUIControl is reliably the ListBox from the Flyout,
	; so getting the parent of that will give us the correct flyout.
	GUIControlGet, hGUICtrl, hWnd, %A_GUIControl%
	hFlyout := DllCall("GetParent", uint, hGUICtrl)
	vFlyout := Object(CFlyout.FromHwnd[hFlyout])

	if (this.m_bHandleClick && msg == WM_LBUTTONDOWN:=513)
	{
		CoordMode, Mouse, Relative
		MouseGetPos,, iClickY
		vFlyout.Click(iClickY)
	}

	if (IsFunc(vFlyout.m_sCallbackFunc))
		bRet := Func(vFlyout.m_sCallbackFunc).(vFlyout, msg)

	vFlyout :=
	return bRet
}
;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;; Callback specified in CFlyout.__New when this.m_bFollowMouse is true.
CFlyout_MouseProc(nCode, wParam, lParam, msg)
{
	Critical, 5000
	global g_hMouseHook, g_hFlyout

	vFlyout := Object(CFlyout.FromHwnd[g_hFlyout])

	vFlyout.GetWidthAndHeight(iWidth, iHeight)
	GetRectForTooltip(iX, iY, iWidth, iHeight)
	WinMove, % "ahk_id" vFlyout.m_hFlyout,, %iX%, %iY%, %iWidth%, %iHeight%

	vFlyout :=
	return DllCall("CallNextHookEx", "uint", g_hMouseHook, "int", nCode, "uint", wParam, "uint", lParam)
}
;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;; Called only when m_bFollowMouse is true. A reliable function to keep the flyout off of the mouse by 16 pixels,
	;;;;;;;;;;;;;;; like how Tooltip works. It also keeps the flyout rect from spanning two or more monitors.
	;;;;;;;;;;;;;; riWndX is the desired X coordinate. It will always be incremented by 16 pixels. It will further be adjusted only if needed.
	;;;;;;;;;;;;;; riWndY is the desired Y coordinate. It will always be incremented by 16 pixels. It will further be adjusted only if needed.
	;;;;;;;;;;;;;; iWndW is the width of the flyout. WinGetPos is not called to retrieve the width instead because,
	;;;;;;;;;;;;;;; when this function is called, the flyout may (in the future) be set to a different width than the current width.
	;;;;;;;;;;;;;;iWndH is the width of the flyout. WinGetPos is not called to retrieve the height instead because, when this function is called,
	;;;;;;;;;;;;;; the flyout may be set to a different height than the current height.
GetRectForTooltip(ByRef riWndX, ByRef riWndY, iWndW, iWndH)
{
	CoordMode, Mouse ; Defaults to Screen
	MouseGetPos, iX, iY
	rect := GetMonitorRectAt(iX, iY)
	MonMouseIsOnLeft := rect.left
	MonMouseIsOnRight := rect.right
	MonMouseIsOnBottom := rect.bottom
	MonMouseIsOnTop := rect.top

	iX += 16
	iY += 16

	riWndX := iX
	riWndY := iY

	bCheck := true
	bWidthExceedsMonSpace := riWndX + iWndW > MonMouseIsOnRight
	if (bWidthExceedsMonSpace && iY - 16 >= MonMouseIsOnBottom - iWndH)
		riWndX := MonMouseIsOnRight - iWndW
	else if (bWidthExceedsMonSpace)
	{
		riWndX := MonMouseIsOnRight - iWndW
		bCheck := false
	}

	if (riWndY + iWndH > MonMouseIsOnBottom)
		riWndY := MonMouseIsOnBottom - iWndH

	if (bCheck && (iX - 16 >= riWndX && (riWndY - 16 <= MonMouseIsOnBottom)))
		riWndX := iX - iWndW - 16

	;~ Tooltip % "MonLeft:`t`t"MonMouseIsOnLeft "`nMonRight:`t`t" MonMouseIsOnRight "`nMonBot:`t`t`t" MonMouseIsOnBottom "`nMonTop:`t`t" MonMouseIsOnTop "`nriWndX:`t`t`t" riWndX "`nriWndY:`t`t`t" riWndY "`niWndW:`t`t`t" iWndW "`niWndH:`t`t`t" iWndH "`nbCheck:`t`t`t" bCheck

	return
}
;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;
/*
===============================================================================
Function:   wp_GetMonitorAt (Modified by Verdlin to return monitor rect)
    Get the index of the monitor containing the specified x and y coordinates.

Parameters:
    x,y - Coordinates
    default - Default monitor
  
Returns:
   array of monitor coordinates

Author(s):
    Original - Lexikos - http://www.autohotkey.com/forum/topic21703.html
===============================================================================
*/
GetMonitorRectAt(x, y, default=1)
{
	SysGet, m, MonitorCount
	; Iterate through all monitors.
	Loop, %m%
	{ ; Check if the window is on this monitor.
		SysGet, Mon%A_Index%, MonitorWorkArea, %A_Index%
		if (x >= Mon%A_Index%Left && x <= Mon%A_Index%Right && y >= Mon%A_Index%Top && y <= Mon%A_Index%Bottom)
			return {left: Mon%A_Index%Left, right: Mon%A_Index%Right, top: Mon%A_Index%Top, bottom: Mon%A_Index%Bottom}
	}

	return {left: Mon%default%Left, right: Mon%default%Right, top: Mon%default%Top, bottom: Mon%default%Bottom}
}
;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;; My (Verdlin) modification of Titan?s/Polythene?s anchor function: https://raw.github.com/polyethene/AutoHotkey-Scripts/master/Anchor.ahk
;;;;;;;;;;;;;; Using this one instead of Attach or Titan’s/Polythene’s Anchor v4 because this function,
;;;;;;;;;;;;;; although the parameter syntax is downright atrocious, actually works in Windows 7 and 8.
Anchor2(ctrl, a, d = false) {
static pos
sGUI := SubStr(ctrl, 1, InStr(ctrl, ":")-1)
GUI, %sGUI%:Default
ctrl := SubStr(ctrl, InStr(ctrl, ":")+1)
sig = `n%ctrl%=

If (d = 1){
draw = Draw
d=1,1,1,1
}Else If (d = 0)
d=1,1,1,1
StringSplit, q, d, `,

If !InStr(pos, sig) {
GUIControlGet, p, Pos, %ctrl%
pos := pos . sig . px - A_GUIWidth * q1 . "/" . pw - A_GUIWidth * q2 . "/"
. py - A_GUIHeight * q3 . "/" . ph - A_GUIHeight * q4 . "/"
}
StringTrimLeft, p, pos, InStr(pos, sig) - 1 + StrLen(sig)
StringSplit, p, p, /

s = xwyh
Loop, Parse, s
If InStr(a, A_LoopField) {
If A_Index < 3
e := p%A_Index% + A_GUIWidth * q%A_Index%
Else e := p%A_Index% + A_GUIHeight * q%A_Index%
d%A_LoopField% := e
m = %m%%A_LoopField%%e%
}
GUIControlGet, i, hwnd, %ctrl%
ControlGetPos, cx, cy, cw, ch, , ahk_id %i%

DllCall("SetWindowPos", "UInt", i, "Int", 0, "Int", dx, "Int", dy, "Int", InStr(a, "w") ? dw : cw, "Int", InStr(a, "h") ? dh : ch, "Int", 4)
DllCall("RedrawWindow", "UInt", i, "UInt", 0, "UInt", 0, "UInt", 0x0101) ; RDW_UPDATENOW | RDW_INVALIDATE
return
}

;~ Anchor2(hCtrl, sSpecs, d = false)
;~ {
	;~ static pos
	;~ sig := "`n" hCtrl "="

	;~ Loop, Parse, sSpecs, %A_Space%
	;~ {
		;~ sXYWH := SubStr(A_LoopField, 1, 1)
		;~ q%sXYWH% := SubStr(A_LoopField, 2)
	;~ }

	;~ If !InStr(pos, sig) {
	;~ ControlGetPos, px, py, pw, ph,, ahk_id %hCtrl%
	;~ pos := pos . sig . px - A_GUIWidth * (qx == A_Blank ? 1 : qx) . "/" . py - A_GUIHeight * (qy == A_Blank ? 1 : qy) . "/"
		;~ . pw - A_GUIWidth * (qw == A_Blank ? 1 : qw) . "/" . ph - A_GUIHeight * (qh == A_Blank ? 1 : qh) . "/"
	;~ }

	;~ StringTrimLeft, p, pos, InStr(pos, sig) - 1 + StrLen(sig)
	;~ StringSplit, p, p, /

	;~ if (qx != A_Blank)
		;~ dx := p1 + A_GUIWidth * qx
	;~ if (qy != A_Blank)
		;~ dy := p2 + A_GUIWidth * qy
	;~ if (qw != A_Blank)
		;~ dw := p3 + A_GUIHeight * qw
	;~ if (qh != A_Blank)
		;~ dh := p4 + A_GUIHeight * qh

	;~ ControlGetPos, cx, cy, cw, ch,, ahk_id %hCtrl%

	;~ DllCall("SetWindowPos", "UInt", hCtrl, "Int", 0, "Int", dx, "Int", dy, "Int", dw ? dw : cw, "Int", dh ? dh : ch, "Int", 4)
	;~ DllCall("RedrawWindow", "UInt", hCtrl, "UInt", 0, "UInt", 0, "UInt", 0x0101) ; RDW_UPDATENOW | RDW_INVALIDATE
	;~ return
;~ }
;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Arbeitsverzeichnis = "M:Praxis\Skripte\AutoHotKey-master\other_scripts\CFlyout"
SetWorkingDir, %Arbeitsverzeichnis%
;#Include <class_TransparentListBox>