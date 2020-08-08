; More stable rewrite
class CFlyoutMenuHandler
{
	__New(iX="", iY="", iW="", iMaxRows="", sIni="", sSlideFrom="Left")
	{
		global g_iLastClassID := 1
		this.m_iClassID := g_iLastClassID

		sOldWorkingDir := A_WorkingDir
		SetWorkingDir, %A_ScriptDir%

		; INIs
		FileDelete, MenuHelper.ini
		this.m_vMenuHelperIni := class_EasyIni("MenuHelper.ini")
		this.m_sIni := sIni
		this.EnsureIniLoaded()

		; Create tmp CFlyout for font-sensitive vars and default options.
		vTmpFlyout := new CFlyout(["a"], "ShowOnCreate=false")

		this.m_iX := vTmpFlyout.m_iX
		this.m_iY := vTmpFlyout.m_iY
		this.m_iW := vTmpFlyout.m_iW
		this.m_iMaxRows := vTmpFlyout.m_iMaxRows

		this.m_bRightJustify := true

		; Set default height, then delete tmp CFlyout.
		Str_Wrap("a", this.m_iW, vTmpFlyout.m_hFont, true, iH)
		this.m_iDefH := iH
		vTmpFlyout :=
		; End tmp CFlyout.

		; ---Menu objects---
		this.m_aFlyouts := []
		this.m_aiMapMenuNumsToLabels := []
		; Handle for active window before main menu activation.
		this.m_hActiveWndBeforeMenu := 0 ; Set in FlyoutMenuHandler_MainMenu.

		; Set up ini
		; Now create wrapper-labels for every function within this menu
		this.m_vActionData := new EasyIni()
		for sSec in this.m_vMenuConfigIni
		{
			sVals := this.m_vMenuConfigIni.GetVals(sSec)
			Loop, Parse, sVals, `n, `r
			{
				iFuncPos := InStr(A_LoopField, "Func:")
				iLabelPos := InStr(A_LoopField, "Label:")
				if (!iFuncPos && !iLabelPos && !InStr(A_LoopField, "Internal:"))
					continue

				aPostFuncParms := """[Data]``n"
				if (iFuncPos)
				{
					StringReplace, sFunc, A_LoopField, Func:,, All
					sFunc := Trim(sFunc, A_Space)
					; TODO: Verify this really is a function or label. If it isn't, fail.
					iPosOfFirstParen := InStr(sFunc, "(") + 1
					; Passed in parameters may contain quotations, so using StrLen instead of InStr ensures we get the closing quotations.
					iPosOfLastParen := StrLen(sFunc)
					sParms := SubStr(sFunc, iPosOfFirstParen, iPosOfLastParen - iPosOfFirstParen)
					; Escape single quotes with double quotes.
					;StringReplace, sParms, sParms, `", `"`", All
					sFuncName  := SubStr(sFunc, 1, InStr(sFunc, "(")-1)
					aPostFuncParms .= "Func=" sFuncName "``nParms=" sParms """"
					this.m_vActionData[sFuncName, "Func"] := sParms
				}
				else if (iLabelPos)
				{
					StringReplace, sLabel, A_LoopField, Label:,, All
					aPostFuncParms .= "Label=" Trim(sLabel, A_Space) """"
					this.m_vActionData[sLabel, "Label"] :=  sLabel
				}
				else ; this is an "internal" function, that is, used within the thread instead of the parent.
				{
					StringReplace, sLabel, A_LoopField, Internal:,, All
					; For now, the only use I can think of is exiting, so I'm just implementing hard-code functionality unless the need for internal functions becomes greater.
					if (sLabel = "ExitAllMenus")
						continue ; This is already created.
					aPostFuncParms := ; Add more internal functions here.
				}
			}
		}

		SetWorkingDir, %sOldWorkingDir%
		CFlyoutMenuHandler[g_iLastClassID++] := &this ; for multiple menu handlers
		return this
	}

	__Get(aName)
	{
		if (aName = "m_vTopmostMenu")
			return this.m_aFlyouts[this.m_aFlyouts.MaxIndex()]
		if (aName = "m_vMainMenu")
			return this.m_aFlyouts.1
		if (aName = "m_iNumMenus")
			return this.m_aFlyouts.MaxIndex()

		return
	}

	__Delete()
	{
		CFlyoutMenuHandler.Remove(this.m_iClassID)
		return
	}

	GetMenu_Ref(iMenuNum)
	{
		; If this were C++, this function would be returning a const pointer.
		; Instead we are returning the actual object, and I really don't like that.
		return this.m_aFlyouts[iMenuNum]
	}

	MainMenuExist()
	{
		; Not ideal to simply match on title, but it is tricky triyng to use g_aFlyouts.
		return WinExist("ahk_id" this.m_vMainMenu.m_hFlyout)
	}

	ShowMenu()
	{
		hActiveMenu := "ahk_id" this.m_vTopmostMenu.m_hFlyout

		; If the main menu is not active, activate it.
		If (WinExist(hActiveMenu))
		{
			; If the menu exists but is not active, set the previsouly active window here.
			if (!WinActive(hActiveMenu))
				this.m_hActiveWndBeforeMenu := WinExist("A")

			WinActivate, %hActiveMenu%
			return
		}
		else this.m_hActiveWndBeforeMenu := WinExist("A")

		; Reset this var since we are starting the menu.
		this.m_bCalledFromClick := false

		; Can't act upon Program Manager, so get the next window.
		WinGetActiveTitle, sTitle
		if (sTitle = "Program Manager")
			this.m_hActiveWndBeforeMenu := DllCall("GetWindow", uint, this.m_hActiveWndBeforeMenu, uint, 2)

		this.CreateFlyoutMenu("MainMenu", 0)

		;~ WAnim_SlideIn("Left", g_iX, g_iY, g_vTopmostFlyout.m_hFlyout, "GUI_Flyout1", 50)
		WinMove, % "ahk_id" this.m_vMainMenu.m_hFlyout,, this.m_iX, this.m_iY
		WinActivate

		return
	}

	MoveUp()
	{
		this.m_vTopmostMenu.Move(true)
		return
	}
	MoveDown()
	{
		this.m_vTopmostMenu.Move(false)
		return
	}

	SubmitSelected(ByRef rbMainMenuExists=false) ; Defaulted in case callers don't care about this.
	{
		return this.Submit(this.m_vTopmostMenu.GetCurSelNdx() + 1, rbMainMenuExists)
	}

	Submit(iRow, ByRef rbMainMenuExists=false) ; Defaulted in case callers don't care about this.
	{
		; When used through thread callbacks, it is unnecessary to move
		; however, when used externally, it is necessary to move.
		if (this.m_vTopmostMenu.GetCurSelNdx() + 1 != iRow)
			this.m_vTopmostMenu.MoveTo(iRow + this.m_vTopmostMenu.m_iDrawnAtNdx) ; TODO: MoveTo should handle m_iDrawnAtNdx

		sSubmitted := this.m_vTopmostMenu.GetCurSel()
		vAction := this.m_vTopmostMenu.m_aMapRowToAction[iRow]

		this.DoMenuAction(vAction)

		rbMainMenuExists := this.MainMenuExist()
		return sSubmitted
	}

	OnClick(vFlyout, msg="")
	{
		this.m_bCalledFromClick := true

		if (vFlyout.m_hFlyout != this.m_vTopmostMenu.m_hFlyout)
		{
			
		}

		; Exit to the hovered menu, if needed.
		while (this.m_iNumMenus > vFlyout.m_iFlyoutNum)
			this.ExitTopmost()

		if (msg = WM_LBUTTONDOWN:=513)
		{
			CoordMode, Mouse, Relative
			MouseGetPos,, iClickY
			vFlyout.Click(iClickY)
		}

		iRow := vFlyout.GetCurSelNdx() + 1
		vAction := vFlyout.m_aMapRowToAction[iRow]
		this.DoMenuAction(vAction)

		return true
	}

	OnKeyDown(vFlyout, wParam, lParam, msg)
	{
		static VK_ESCAPE:=27, VK_LEFT:=37, VK_RIGHT:=39, VK_UP:=38, VK_DOWN:=40, VK_Enter:=0x0D

		if (wParam = VK_ESCAPE || wParam = VK_LEFT)
			return this.ExitTopmost()
		else if (wParam = VK_Enter || wParam = VK_RIGHT)
			return this.SubmitSelected()
		else if (wParam = VK_UP)
			return this.MoveUp()
		else if (wParam = VK_DOWN)
			return this.MoveDown()

		return true
	}

	DoMenuAction(vAction)
	{
		; class func call?
		if (vAction.ClassFunc)
		{
			this[vAction.ClassFunc]()
			; Don't exit all menus twice!
			if (vAction.ClassFunc != "ExitAllMenus")
				this.ExitAllMenus()
		}
		; func call?
		else if (vAction.Func)
		{
			vAction.Func(vAction.Parms*)
			this.ExitAllMenus()
		}
		; label call?
		else if (vAction.Label)
		{
			AhkSelf().ahkLabel[vAction.Label]
			this.ExitAllMenus()
		}
		; else launch a new menu.
		else if (vAction.SubMenu)
			this.MenuProc("Enter", vAction.SubMenu)
	}

	ExitTopmost(ByRef rbMainMenuExists=false)
	{
		if (this.m_vMainMenu.m_hFlyout == this.m_vTopmostMenu.m_hFlyout)
		{
			this.ExitAllMenus()

			; This hack is used by CLeapMenu
			; It is used to determine whether or not an item was actually submitted.
			if (this.m_hCallbackHack)
				this.m_hCallbackHack.()

			return
		}

		hParent := this.m_vTopmostMenu.m_hParent
		if (hParent != 0)
			WinActivate, % "ahk_id" hParent

		this.m_aFlyouts.Remove()
		rbMainMenuExists := this.MainMenuExist()

		return
	}

	ExitAllMenus(bFromExitTimer=false)
	{
		; To avoid crashes from infinite recursion, only reload when needed.
		if (this.m_aFlyouts.MaxIndex() == A_Blank)
			return

		this.m_aFlyouts := []

		; See comment in ExitTopmost()
		if (bFromExitTimer && this.m_hCallbackHack)
			this.m_hCallbackHack.()

		this.m_bRightJustify := true
		return
	}

	MenuProc(sThisHotkey, sMenuID)
	{
		; Create a new flyout menu based on sMenuID.
		; But before doing so, move selection on current flyout to proper menu item.
		if (!(sThisHotkey = "Enter"
			|| sThisHotkey = "NumpadEnter"
			|| sThisHotkey = "Right"
			|| sThisHotkey = "MButton"
			|| this.m_bCalledFromClick))
		{
			iMoveTo := 1
			for sHK in this.m_vMenuHelperIni[this.m_vTopmostMenu.m_hFlyout]
			{
				if (sHK = sThisHotkey)
				{
					iMoveTo := A_Index
					break
				}
			}
			this.m_vTopmostMenu.MoveTo(iMoveTo)
		}
		; Reset m_bCalledFromClick because we are creating a new flyout.
		this.m_bCalledFromClick := false

		if (this.m_vTopmostMenu.GetCurSelNdx() == 0)
			iYOffset := 0
		else iYOffset := this.m_vTopmostMenu.CalcHeightTo(this.m_vTopmostMenu.GetCurSelNdx() - this.m_vTopmostMenu.m_iDrawnAtNdx) - 1
			; Note: not sure why we need to -1, but it works. Maybe it has to do with aligning with the selection vs. the menu window itself?

		this.CreateFlyoutMenu(sMenuID, this.m_vTopmostMenu.m_hFlyout)
		; Note: m_vTopmostMenu is now the newly created menu ( See __Get() ).
		this.GetRectForMenu(this.m_vTopmostMenu, iX, iY, iYOffset)
		WinMove, % "ahk_id" this.m_vTopmostMenu.m_hFlyout,, iX, iY
		WinActivate, % "ahk_id" this.m_vTopmostMenu.m_hFlyout

		return
	}

	; Each flyout menu is ~18MB! This comes from loading the entire picture into the GUI...
	; (regardless of whether the picture spans outside the GUI).
	CreateFlyoutMenu(sMenuSec, hParent)
	{
		aMenuItems := []
		for sMenuItem, v in this.m_vMenuConfigIni[sMenuSec]
		{
			StringReplace, sMenuItem, sMenuItem, ``&,, All
			aMenuItems.Insert(sMenuItem)
		}

		vFlyout := new CFlyout(aMenuItems, "Parent=" hParent, "ReadOnly="false
			, "ShowInTaskbar="false, "ShowOnCreate=true", "ExitOnEsc=False"
			, "Title=CFMH_" (sMenuSec = "MainMenu" ? sMenuSec : "Submenu"))

		; New design: within this CFlyout, leverage CFlyout to actually map the particular menu item to the func/label it was mapped to.
		this.m_vMenuHelperIni.AddSection(vFlyout.m_hFlyout)
		vFlyout.m_aMapRowToAction := []
		aiMapMenuNumsToLabels := []
		for sMenuItem, sMenuLabel in this.m_vMenuConfigIni[sMenuSec]
		{
			iPosOfHK := InStr(sMenuItem, "&")
			if (iPosOfHK < 0)
				iPosOfHK := 0
			sHK := SubStr(sMenuItem, iPosOfHK + 1, 1)

			this.m_vMenuHelperIni.AddKey(vFlyout.m_hFlyout, sHK) ; TODO: Remove &s?
			aiMapMenuNumsToLabels.Insert(sMenuLabel)

			Hotkey, IfWinActive, % "ahk_id" vFlyout.m_hFlyout
				Hotkey, %sHK%, FlyoutMenuHandler_HotkeyProc

			iPosOfFunc := InStr(sMenuLabel, "Func:")
			iPosOfLabel := InStr(sMenuLabel, "Label:")
			iPosOfInt := InStr(sMenuLabel, "Internal:")
			if (iPosOfFunc)
			{
				; Remove Func:
				StringReplace, sFunc, sMenuLabel, Func:,, All

				sFunc := Trim(sFunc, A_Space)
				; TODO: Verify this really is a function. If it isn't, fail.
				iPosOfFirstParen := InStr(sFunc, "(") + 1
				; Passed in parameters may contain quotations, so using StrLen instead of InStr ensures we get the closing quotations.
				iPosOfLastParen := StrLen(sFunc)
				; Get function parms.
				sParms := SubStr(sFunc, iPosOfFirstParen, iPosOfLastParen - iPosOfFirstParen)
				; Get functon name.
				sFuncName  := SubStr(sFunc, 1, InStr(sFunc, "(")-1)

			aParms := st_split(sParms, ",")
			for, iNdx, val in aParms
			{
				; Resolve dynamic class variables.
				sClassVar := Trim(val) ; Trim, just in case, but don't trim actual val beacuse some function may want tabs, spaces, etc.
				if (this.HasKey(sClassVar))
					aParms[iNdx] := this[sClassVar]
				else
				{
					; Unescape double-quotes with single quotes.
					StringReplace, val, val, `",, All ; TODO: Just remove first and last quotes...
					aParms[iNdx] := val
				}
			}

				vFlyout.m_aMapRowToAction.InsertAt(A_Index, {Func: sFuncName, Parms: aParms})
			}
			else if (iPosOfLabel)
			{
				; Remove Label:
				StringReplace, sLabel, sMenuLabel, Label:,, All
				; TODO: Verify this really is a label. If it isn't, fail.
				vFlyout.m_aMapRowToAction.InsertAt(A_Index, {Label: sLabel})
			}
			else if (iPosOfInt) ; internal is always a function.
			{
				; Remove Internal:
				StringReplace, sFunc, sMenuLabel, Internal:,, All
				vFlyout.m_aMapRowToAction.InsertAt(A_Index, {ClassFunc: sFunc})
			}
			else ; this points to a submenu.
				vFlyout.m_aMapRowToAction.InsertAt(A_Index, {Submenu: sMenuLabel})
		}

		this.m_aiMapMenuNumsToLabels.Insert(vFlyout.m_iFlyoutNum, aiMapMenuNumsToLabels)

		static WM_LBUTTONDOWN:=513
		static WM_KEYDOWN:=256
		vFlyout.OnMessage(WM_LBUTTONDOWN, "FlyoutMenuHandler_OnClick")
		OnMessage(WM_KEYDOWN, "FlyoutMenuHandler_OnKeyDown")

		; Tack on class ID so we can map hotkeys and clicks back up to the appropriate CFMH class.
		; Note: See FlyoutMenuHandler_OnClick.
		vFlyout.m_iCFMH_ClassID := this.m_iClassID
		this.m_aFlyouts.Insert(vFlyout)

		return
	}

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	/*
		Author: Verdlin
		Function: GetRowFromPos
			Purpose: Useful in order to determine which menu item an object is hovering over.
				Note: when ahkGetVar is pinged too often, we crash.
				This is why the class stores menu positions instead.
		Parameters
			hWnd="": if blank, uses hWnd under mouse.
			bUseCenterPos=false: if true, clicks on the flyout in centralized coordinates (makes sense with a circle GUI, as used in CLeapMenu)
			riFlyoutNum=1: Which flyout number the mouse or hWnd is under.
			rbIsUnderTopmost=false: If topmost flyout is under mouse or hWnd
	*/
	GetRowFromPos(hWnd="", ByRef riFlyoutNum=1, ByRef rbIsUnderTopmost=false)
	{
		; Get the current wnd under the mouse;
		MouseGetPos,, iPosY, hMouseWnd
		bUseMouse := (hWnd == A_Blank)
		if (bUseMouse)
			iClickY := iPosY
		else
		{
			WinGetPos, iPosX, iPosY, iPosW, iPosH, ahk_id %hWnd%
			iClickX += iPosX+(iPosW*0.5)
			iClickY += iPosY+(iPosH*0.5)
		}

		; See if wnd matches any of our flyout menus...
		for iFlyout, vFlyout in this.m_aFlyouts
		{
			if (bUseMouse)
			{
				if (hMouseWnd != vFlyout.m_hFlyout)
					continue
			}
			else ; match on hWnd X/Y coord.
			{
				; Determine whether the center of the hWnd is on this flyout.

				;~ if (A_Index == 3)
					;~ Msgbox % st_concat("`n", A_ThisFunc "()", "iPosX`t" iPosX, "iPosY`t" iPosY, "iPosW`t"iPosW, "iPosH`t" iPosH
						;~ , "FX:`t" vFlyout.GetFlyoutX, "FY:`t"vFlyout.GetFlyoutY, "FW:`t" vFlyout.GetFlyoutW, "FH:`t" vFlyout.GetFlyoutH, "FN:`t"vFlyout.m_iFlyoutNum "`n"
						;~ , "b1:`t" (iClickX >= vFlyout.GetFlyoutX)
						;~ , "b2:`t" (iClickX <= (vFlyout.GetFlyoutW + vFlyout.GetFlyoutX))
						;~ , "b3:`t" (iClickY >= vFlyout.GetFlyoutY)
						;~ , "b4:`t" (iClickY <= (vFlyout.GetFlyoutH + vFlyout.GetFlyoutY)))

				 if (!(iClickX >= vFlyout.GetFlyoutX && iClickX <= (vFlyout.GetFlyoutW + vFlyout.GetFlyoutX)
					&& iClickY >= vFlyout.GetFlyoutY && iClickY <= (vFlyout.GetFlyoutH + vFlyout.GetFlyoutY)))
				{
					continue
				}
			}

			riFlyoutNum := vFlyout.m_iFlyoutNum
			rbIsUnderTopmost := vFlyout.m_hFlyout = this.m_vTopmostMenu.m_hFlyout

			; Note: Click function takes coordinates relative to the window, so we need to eliminate the Y
			return vFlyout.GetRowPosForClick(iClickY-vFlyout.GetFlyoutY) ; match, return row under mouse.
		}

		riFlyoutNum := -1 ; Not under any CFlyout.
		return ; no match found, return blank.
	}
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	EnsureIniLoaded()
	{
		if (IsObject(this.m_vMenuConfigIni))
			return

		if (this.m_sIni)
			this.m_vMenuConfigIni := class_EasyIni("MenuConfig", this.m_sIni)
		else this.m_vMenuConfigIni := class_EasyIni("MenuConfig")

		return
	}

	AddMenu(sMenu)
	{
		Msgbox In AddMenu`n%sMenu%
		this.EnsureIniLoaded()

		return true
	}

	AddSubMenu(sParentMenu, sSubMenu)
	{
		Msgbox In AddSubMenu`nAdd %sSubMenu% to %sParentMenu%
		this.EnsureIniLoaded()

		return true
	}

	RemoveIllegalLabelChars(ByRef sLabel)
	{
		StringReplace, sLabel, sLabel, %A_Space%, |A_Space|,, All
		StringReplace, sLabel, sLabel, `", |A_DoubleQuote|,, All
		StringReplace, sLabel, sLabel, `', |A_SingleQuote|,, All
		StringReplace, sLabel, sLabel, `(, |A_OpenParen|,, All
		StringReplace, sLabel, sLabel, `), |A_CloseParen|,, All
		StringReplace, sLabel, sLabel, `,, |A_Comma|,, All
		StringReplace, sLabel, sLabel, `:, |A_Colon|,, All
		return
	}

	GUIEditSettings(hParent=0, sGUI="", bReloadOnExit=false)
	{
		return CFlyout.GUIEditSettings(hParent, sGUI, bReloadOnExit)
	}

	GetRectForMenu(vFlyout, ByRef iTargetX, ByRef iTargetY, iYOffset)
	{
		iTargetX := iTargetY := 0

		WinGetPos, iWndX, iWndY, iParentW,, % "ahk_id" vFlyout.m_hParent
		WinGetPos,,, iWndW, iWndH, % "ahk_id" vFlyout.m_hFlyout

		rect := FlyoutMenuHandler_GetMonitorRectAt(iWndX, iWndY)
		iMonWndIsOnLeft := rect.left
		iMonWndIsOnRight := rect.right
		iMonWndIsOnTop := rect.top
		iMonWndIsOnBottom := rect.bottom

		; Offsets for menus.
		this.m_iXOffset := iParentW - 5 ; Pixels

		if (iWndX + this.m_iXOffset + (iParentW + iWndW - (this.m_iXOffset)) > iMonWndIsOnRight)
			this.m_bRightJustify := false

		if (this.m_bRightJustify)
			iTargetX := iWndX + this.m_iXOffset
		else iTargetX := iWndW - this.m_iXOffset

		if (iTargetX + iWndW > iMonWndIsOnRight)
		{
			iTargetX := iWndX - iWndW
			this.m_bRightJustify := false
		}
		if (iTargetX < iMonWndIsOnLeft)
		{
			iTargetX := iMonWndIsOnLeft
			this.m_bRightJustify := true
		}

		iTargetX := iWndX + this.m_iXOffset ; TODO: Fix L/R justification code
		iTargetY := iWndY + iYOffset

		if (iTargetY + iWndH > iMonWndIsOnBottom)
			iTargetY := iWndY - iWndH + iYOffset

		return
	}
}

FlyoutMenuHandler_HotkeyProc:
{
	vMH := _CFlyoutMenuHandler(1)

	for sHK in vMH.m_vMenuHelperIni[vMH.m_vTopmostMenu.m_hFlyout]
	{
		if (A_ThisHotkey = sHK)
		{
			iRow := A_Index
			break
		}
	}

	if (!iRow)
		return

	vMH.m_vTopmostMenu.MoveTo(iRow)
	vAction := vMH.m_vTopmostMenu.m_aMapRowToAction[iRow]
	vMH.DoMenuAction(vAction)

	return
}

FlyoutMenuHandler_ThreadCallback(sIniParms, iClassID)
{
	vMH := _CFlyoutMenuHandler(iClassID)
	return vMH.ThreadCallback(sIniParms)
}

FlyoutMenuHandler_MoveDown(iClassID)
{
	vMH := _CFlyoutMenuHandler(iClassID)
	return vMH.MoveDown()
}

FlyoutMenuHandler_MoveUp(iClassID)
{
	vMH := _CFlyoutMenuHandler(iClassID)
	return vMH.MoveUp()
}

FlyoutMenuHandler_SubmitSelected(iClassID)
{
	vMH := _CFlyoutMenuHandler(iClassID)
	return vMH.SubmitSelected()
}

FlyoutMenuHandler_ExitTopmost(iClassID)
{
	vMH := _CFlyoutMenuHandler(iClassID)
	return vMH.ExitTopmost()
}

FlyoutMenuHandler_ExitAllMenus(iClassID)
{
	vMH := _CFlyoutMenuHandler(iClassID)
	return vMH.ExitAllMenus()
}

FlyoutMenuHandler_ExitAllMenus_OnFocusLost(iClassID)
{
	vMH := _CFlyoutMenuHandler(iClassID)
	return vMH.ExitAllMenus(true)
}

FlyoutMenuHandler_OnClick(vFlyout, msg)
{
	vMH := _CFlyoutMenuHandler(vFlyout.m_iCFMH_ClassID)
	return vMH.OnClick(vFlyout, msg)
}

FlyoutMenuHandler_OnKeyDown(wParam, lParam, msg, vFlyout2)
{
	Critical

	; hWnd isn't always the flyout, so we can't use that.
	; A_GUIControl is reliably the ListBox from the Flyout,
	; so getting the parent of that will give us the correct flyout.
	GUIControlGet, hGUICtrl, hWnd, %A_GUIControl%
	hFlyout := DllCall("GetParent", uint, hGUICtrl)
	vFlyout := Object(CFlyout.FromHwnd[hFlyout])
	if (!IsObject(vFlyout))
	{
		vFlyout := Object(CFlyout.FromHwnd[WinExist("A")])
		if (!IsObject(vFlyout))
		{
			WinGetActiveTitle, sTitle
			if (InStr(sTitle, "CFMH_"))
			{
				vMH := _CFlyoutMenuHandler(vFlyout.m_iCFMH_ClassID)
				vFlyout := vMH.m_vTopmostMenu
			}
		}
	}

	if (IsObject(vFlyout))
	{
		vMH := _CFlyoutMenuHandler(vFlyout.m_iCFMH_ClassID)
		return vMH.OnKeyDown(vFlyout, wParam, lParam, msg)
	}

	return
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/*
	Author: Verdlin
	Function: _CFlyoutMenuHandler
		Purpose: To retrieve appropriate CFlyoutMenuHandler class object
			IMPORTANT: Caller *must* delete object when finished with it.
	Parameters
		iClassID: Used to get the appropriate CFlyoutMenuHandler class.
*/
_CFlyoutMenuHandler(iClassID="")
{
	global g_hCFlyoutMenuHandlerThread

	if (iClassID = "")
		iClassID := 1

	vMH := Object(CFlyoutMenuHandler[iClassID])
	if (!IsObject(vMH))
	{
		Msgbox 8192,, Error: Could not map class ID (%iClassID%) to menu handler class object.
		g_hCFlyoutMenuHandlerThread := ; Kill the menu
		return Object(CFlyoutMenuHandler[1]) ; Failsafe.
	}
	return vMH
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

/*
===============================================================================
Function:   wp_GetMonitorAt (Modified by Verdlin to return monitor rect)
	Get the index of the monitor containing the specified x and y coordinates.

Parameters:
	x,y - Coordinates
	default - Default monitor
  
Returns:
   Index of the monitor at specified coordinates

Author(s):
	Original - Lexikos - http://www.autohotkey.com/forum/topic21703.html
===============================================================================
*/
FlyoutMenuHandler_GetMonitorRectAt(x, y, default=1)
{
	; Temp workarounds until I can patiently wrap my head around the bug in this functions that returns
	; the monitor to the LEFT of the primary monitor whenever x == 02
	if (x == 0)
		x++
	if (y == 0)
		y++

	SysGet, m, MonitorCount
	; Iterate through all monitors.
	Loop, %m%
	{ ; Check if the window is on this monitor.
		SysGet, Mon%A_Index%, Monitor, %A_Index%
		if (x >= Mon%A_Index%Left && x <= Mon%A_Index%Right && y >= Mon%A_Index%Top && y <= Mon%A_Index%Bottom)
		{
			return {left: Mon%A_Index%Left, right: Mon%A_Index%Right, top: Mon%A_Index%Top, bottom: Mon%A_Index%Bottom}
		}
	}

	return {left: Mon%default%Left, right: Mon%default%Right, top: Mon%default%Top, bottom: Mon%default%Bottom}
}
/*
===============================================================================
*/

#Include %A_ScriptDir%\CFlyout.ahk