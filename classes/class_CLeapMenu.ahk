#Include %A_ScriptDir%\CFlyoutMenuHandler.ahk

class CLeapMenu
{
	__New(ByRef rFlyoutMenuHandler_c, ByRef rLeap_c)
	{
		If (!Gdip_Startup())
		{
			MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
			return
		}

		; Remember: assigning an object in this way internally results in a new pointer to the objects memory.
		; This class keep a "const" pointer to the origian memory because
		; it needs to keep up with the menu handler object but should not modify it.
		this.m_rMH_c := rFlyoutMenuHandler_c
		this.m_rLeap_c := rLeap_c

		; References m_rMH_c.
		this.CircleGUI_Init()

		this.m_rMH_c.m_hCallbackHack := Func("CLeapMenu_ExitProc")

		CLeapMenu.1 := &this
		return this
	}

	MenuProc(ByRef rLeapData)
	{
		static s_iLastFocMenu := 0, s_iLastFocRow := 0, s_iHoverLimit := 1000

		if (this.m_bCircleHidden)
			this.ShowCircle()

		iVelocityXFactor := this.m_rLeap_c.CalcVelocityFactor(abs(rLeapData.Finger1.VelocityX), 40)
		iVelocityYFactor := this.m_rLeap_c.CalcVelocityFactor(abs(rLeapData.Finger1.VelocityY), 60)

	; Don't move too sluggishly.
	bSmallXDelta := abs(rLeapData.Finger1.DeltaX) < 0.25
	bSmallYDelta := abs(rLeapData.Finger1.DeltaY) < 0.25
	if (bSmallXDelta)
		iVelocityXFactor := 1
	if (bSmallYDelta)
		iVelocityYFactor := 1

		WinGetPos, iX, iY,,, % "ahk_id" this.m_hCircleGUI
		; Avoid shaky movement.
		if (bSmallXDelta)
			iNewX := iX
		else iNewX := iX + (rLeapData.Finger1.DeltaX*iVelocityXFactor)
		; Avoid shaky movement.
		if (bSmallYDelta)
			iNewY := iY
		else iNewY := iY - (rLeapData.Finger1.DeltaY*iVelocityYFactor)

		this.MoveCircle(iNewX, iNewY)

		iFocRow := this.m_rMH_c.GetRowFromPos(this.m_hCircleGUI, iFocMenu)
		vFocMenu := this.m_rMH_c.GetMenu_Ref(iFocMenu)
		iLastCall := this.TimeSinceLastCall()

		if (iFocMenu == s_iLastFocMenu && iFocRow == s_iLastFocRow)
		{
			; Inc hovering time.
			this.m_iHoveringFor += iLastCall

			; When we reach the hover limit, submit/escape/whatever.
			if (this.m_iHoveringFor >= s_iHoverLimit)
			{
				if (iFocMenu == -1) ; exit all menus...
				{
					; ... but give a little grace period.
					if (this.m_iHoveringFor >= (s_iHoverLimit * 2.5))
					{
						this.m_rMH_c.ExitAllMenus()
						this.EndMenuProc(false)
						return
					}
				}
				else ; submit selection under appropriate menu.
				{
					; If we are hovering over a non-topmost menu, see if we should select something.
					if (this.m_rMH_c.m_vTopmostMenu.m_iFlyoutNum != iFocMenu)
					{
						; If we are hovering over a menu item that is already selected, do nothing.
						if (iFocRow == vFocMenu.m_FromCLM_iLastSubmitted)
						{
							s_iLastFocRow := iFocRow
							s_iLastFocMenu := iFocMenu
							this.m_iHoveringFor := 0
							return
						}
					}

					; Exit to the hovered menu, if needed.
					while (this.m_rMH_c.m_iNumMenus > iFocMenu)
						this.m_rMH_c.ExitTopmost()
					; Now launch the menu item focused.
					this.m_sLastSubmitted := this.m_rMH_c.Submit(iFocRow, bMainMenuExist)
					vFocMenu.m_FromCLM_iLastSubmitted := vFocMenu.GetCurSelNdx() + 1

					; Note: this never has been encountered...there are strange issues with bMainMenuExist
					; I think it has to do with ahkPostFunction somewhere, where basically this
					; scripts resumes execution before the menu handler has been exited.
					if (!bMainMenuExist)
					{
						this.EndMenuProc(true)
						; Activate this window because it was the last active window.
						WinActivate, % "ahk_id" this.m_rMH_c.m_hActiveWndBeforeMenu
						return
					}

					this.m_iHoveringFor := 0
				}
			}
		}
		else
		{
			vFocMenu.MoveTo(iFocRow)
			this.m_iHoveringFor := 0
		}

		s_iLastFocRow := iFocRow
		s_iLastFocMenu := iFocMenu
		return
	}

	__Delete()
	{
		CLeapMenu.1 :=
		return
	}

	__Get(aName)
	{
		global

		if (aName = "m_hCircleGUI")
			return g_hCircleGUI

		WinGetPos, iX, iY, iW, iH, ahk_id %g_hCircleGUI%
		if (aName = "m_iCircleX")
			return iX
		if (aName = "m_iCircleY")
			return iY
		if (aName = "m_iCircleW")
			return iW
		if (aName = "m_iCircleH")
			return iH

		return
	}

	EndMenuProc(bSubmitted)
	{
		; If the user simply cancelled, then we don't want to show anything.
		if (bSubmitted || this.m_iHoveringFor < 1000) ; If we passed the hover limit, trust that nothing was submitted over bSubmitted.
			this.m_rLeap_c.OSD_PostMsg(this.m_sLastSubmitted)
		else this.m_rLeap_c.OSD_PostMsg("Exit Menu")

		this.HideCircle()
		this.m_iHoveringFor := 0
		this.m_sLastSubmitted :=
		return
	}

	CircleGUI_Init()
	{
		global

		; Make circle exactly the height of one row.
		this.m_iCircleRad := this.m_rMH_c.m_iDefH

		; Create a layered window (+E0x80000) that is always on top (+AlwaysOnTop), has no taskbar entry or caption
		GUI, CircleGUI_: +Hwndg_hCircleGUI LastFound OwnDialogs Owner AlwaysOnTop ToolWindow -Caption E0x80000 E0x20
		; Create a gdi bitmap with width and height of the work area
		hbm := CreateDIBSection(this.m_iCircleRad, this.m_iCircleRad)

		; Get a device context compatible with the screen
		hdc := CreateCompatibleDC()

		; Select the bitmap into the device context
		obm := SelectObject(hdc, hbm)

		; Get a pointer to the graphics of the bitmap, for use with drawing functions
		G := Gdip_GraphicsFromHDC(hdc)

		; Set the smoothing mode to antialias = 4 to make shapes appear smother (only used for vector drawing and filling)
		Gdip_SetSmoothingMode(G, 4)

		; Get a colour for the background and foreground of hatch style used to fill the ellipse,
		; as well as random brush style, x and y coordinates and width/height
		RandBackColour := 654800120.00
		RandForeColour := 3290788387.00
		RandBrush := 7
		RandElipseWidth := this.m_iCircleRad
		RandElipseHeight := this.m_iCircleRad

		; Create the random brush
		pBrush := Gdip_BrushCreateHatch(RandBackColour, RandForeColour, RandBrush)

		; Fill the graphics of the bitmap with an ellipse using the brush created
		Gdip_FillEllipse(G, pBrush, RandElipsexPos, RandElipseyPos, RandElipseWidth, RandElipseHeight)

		; Update the specified window
		UpdateLayeredWindow(g_hCircleGUI, hdc, (A_ScreenWidth-this.m_iCircleRad)/2, (A_ScreenHeight-this.m_iCircleRad)/2, this.m_iCircleRad, this.m_iCircleRad)

		; Delete the brush as it is no longer needed and wastes memory
		Gdip_DeleteBrush(pBrush)

		return

		CircleGUI_GUIClose:
		{
			; I don't like disallowing an exit, but
			; if the class is working correctly, the circle will be hidden when it needs to be.
			return
		}
	}

	MoveCircle(iX, iY, iW="", iH="")
	{
		vNewCoord := WndMove(iX, iY, "", "", this.m_hCircleGUI, true, false, false) ; TODO: Un-link dependency on Windows Master.ahk
		GUI, CircleGUI_: Show, % "X" vNewCoord.iX " Y" vNewCoord.iY " W" this.m_iCircleRad " H" this.m_iCircleRad " NoActivate"
		GUI, CircleGUI_:+AlwaysOnTop ; Causes a flash, but this is a necessary evil because new CFlyouts will be on top otherwise.
		return
	}

	ShowCircle()
	{
		GUI, CircleGUI_: Show, % "X0 Y0 W" this.m_iCircleRad " H" this.m_iCircleRad " NoActivate"
		GUI, CircleGUI_:+AlwaysOnTop
		this.m_bCircleHidden := false
		return
	}

	HideCircle()
	{
		GUI, CircleGUI_: Hide
		this.m_bCircleHidden := true
		return
	}

	TimeSinceLastCall(id=1, reset=0)
	{
		static arr:=array()
		if (reset=1)
		{
			((id=0) ? arr:=[] : (arr[id, 0]:=arr[id, 1]:="", arr[id, 2]:=0))
			return
		}
		arr[id, 2]:=!arr[id, 2]
		arr[id, arr[id, 2]]:=A_TickCount
		return abs(arr[id,1]-arr[id,0])
	}

	m_bCircleHidden := true ; We initialize with it hidden.
	m_iCircleRad := 38
	m_iHoveringFor := 0
	m_sLastSubmitted  :=
	m_rMH_c :=
	m_rLeap_c :=
}

CLeapMenu_ExitProc()
{
	Object(CLeapMenu.1).EndMenuProc(false)
	return 
}