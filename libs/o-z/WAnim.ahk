SetWinDelay, -1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;; Slide a window in/out of view.
WAnim_SlideIn(sFrom, iX, iY, hWnd, sGUI="", iInc=20)
{
	return WAnim_SlideInOutFrom(true, sFrom, iX, iY, hWnd, sGUI, iInc, false)
}
WAnim_SlideOut(sFrom, hWnd, sGUI="", iInc=20, bDestroy=true)
{
	WinGetPos, iX, iY,,, ahk_id %hWnd%
	return WAnim_SlideInOutFrom(false, sFrom, iX, iY, hWnd, sGUI, iInc, bDestroy)
}

WAnim_SlideInOutFrom(bSlideIn, sFrom, iX, iY, hWnd, sGUIName, iInc, bDestroy)
{
	global
	g_bSlideIn := bSlideIn
	g_sFrom := sFrom
	WAnim_g_iX := iX
	WAnim_g_iY := iY
	WinGetPos,,, WAnim_g_iW, WAnim_g_iH, ahk_id %hWnd%
	WAnim_g_hWnd := hWnd
	WAnim_g_sGUI := sGUIName
	g_iInc := iInc
	g_bDestroy := bDestroy
	g_iNdx := 1

	SetTimer, WAnim_Slide, 1
	return
}

WAnim_Slide:
{
	if (g_sFrom = "Left")
	{
		iX := g_bSlideIn ? g_iNdx-WAnim_g_iW : WAnim_g_iW+g_iNdx
		if (g_bSlideIn)
			iX := iX > WAnim_g_iX ? WAnim_g_iX : iX
		iY := WAnim_g_iY
	}
	else if (g_sFrom = "Right")
	{
		iX := g_bSlideIn ? A_ScreenWidth-g_iNdx : A_ScreenWidth-WAnim_g_iW+g_iNdx
		if (g_bSlideIn)
			iX := iX < WAnim_g_iX ? WAnim_g_iX : iX
		iY := WAnim_g_iY
	}
	else if (g_sFrom = "Top")
	{
		if (g_bSlideIn)
		{
			iY := (-WAnim_g_iH+(g_iInc*g_iNdx))
			if (iY > WAnim_g_iY)
				iY := WAnim_g_iY
		}
		else
		{
			iY := WAnim_g_iY-(g_iInc*g_iNdx)
			if (iY < -WAnim_g_iH)
				iY := -WAnim_g_iH
		}

		iX := WAnim_g_iX
	}
	else if (g_sFrom = "Bottom")
	{
		if (g_bSlideIn)
		{
			iY := g_iInc*g_iNdx
			if (iY > WAnim_g_iY)
				iY := WAnim_g_iY
		}
		else
		{
			iY := WAnim_g_iY+(g_iInc*g_iNdx)
			if (iY > A_ScreenHeight)
				iY := A_ScreenHeight
		}

		iX := WAnim_g_iX
	}

	; Are we past the corner?
	iTargetForTopY := (g_bSlideIn ? WAnim_g_iY : -WAnim_g_iH)
	iTargetForBottomY := (g_bSlideIn ? WAnim_g_iY : A_ScreenHeight)
	if (((g_sFrom = "Left" || g_sFrom = "Right") && iX == WAnim_g_iX)
		|| (g_sFrom = "Top" 		&& iY == iTargetForTopY)
		|| (g_sFrom = "Bottom"	&& iY == iTargetForBottomY))
	{
		if (WAnim_g_sGUI && !g_bSlideIn)
		{
			if (g_bDestroy)
			{
				GUI, %WAnim_g_sGUI%: Destroy
				WinKill, ahk_id %WAnim_g_hWnd%
			}
			else GUI, %WAnim_g_sGUI%: Hide
		}
		SetTimer, WAnim_Slide, Off
	}

	WinMove, ahk_id %WAnim_g_hWnd%,, iX, iY, WAnim_g_iW, WAnim_g_iH
	g_iNdx++

	return
}
;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;
WAnim_FoldOrUnfold(bUnfold, iW, hWnd="A", sGUI=1, iInc=15, bDestroy=true)
{
	global
	WAnim_g_bUnfold := bUnfold

	if (hWnd = "A")
		WAnim_g_hWnd := hWnd := WinExist("A")
	else WAnim_g_hWnd := hWnd

	WAnim_g_iW := iW
	WAnim_g_sGUI := sGUI
	WAnim_g_iInc := iInc
	WAnim_g_bDestroy := bDestroy
	WAnim_g_iNdx := 1

	if (WAnim_g_bDestroy)
		WinGetPos,,, WAnim_g_iW,, ahk_id %WAnim_g_hWnd%

	SetTimer, FoldOrUnfold, 1
	return
}

FoldOrUnfold:
{
	if (WAnim_g_bUnfold)
	{
		iNextW := WAnim_g_iInc*WAnim_g_iNdx
		if (iNextW >= WAnim_g_iW)
		{
			GUI, %WAnim_g_sGUI%: Show, W%WAnim_g_iW% NoActivate
			SetTimer, FoldOrUnfold, Off
			return
		}

		GUI, %WAnim_g_sGUI%: Show, W%iNextW% NoActivate
	}
	else
	{
		iNextW := WAnim_g_iW-(WAnim_g_iInc*WAnim_g_iNdx)

		if (iNextW < 0)
		{
			if (WAnim_g_bDestroy)
				GUI, %WAnim_g_sGUI%: Destroy
			else GUI, %WAnim_g_sGUI%: Hide

			SetTimer, FoldOrUnfold, Off
			return
		}

		GUI, %WAnim_g_sGUI%: Show, W%iNextW% NoActivate
	}

	WAnim_g_iNdx++
	return
}
;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;; Fade a window in/out of view.
WAnim_FadeViewInOut(hwnd, iInc, bFadeIn, sGUIName="", bDestroy=true)
{
	global
	WAnim_g_hWnd := hwnd
	g_iInc := iInc
	g_bFadeIn := bFadeIn
	WAnim_g_sGUI := sGUIName
	g_bDestroy := bDestroy

	if (bFadeIn)
		WinSet, Transparent, 0, ahk_id %hwnd%
	g_iTrans := bFadeIn ? 0 : 255
	SetTimer, WAnim_Fade, 1
	return
}

WAnim_Fade:
{
	g_iTrans := g_bFadeIn ? g_iTrans + g_iInc : g_iTrans - g_iInc
	WinSet, Transparent, %g_iTrans%, ahk_id %WAnim_g_hWnd%
	if (g_iTrans > 255 || g_iTrans < 0)
	{
		if (WAnim_g_sGUI && !g_bFadeIn)
		{
			if (g_bDestroy)
			{
				GUI, %WAnim_g_sGUI%: Destroy
				WinKill, ahk_id %WAnim_g_hWnd%
			}
			else
			{
				WinSet, Transparent, Off, ahk_id %WAnim_g_hWnd%
				GUI, %WAnim_g_sGUI%: Hide
			}
		}
		SetTimer, WAnim_Fade, Off
	}

	return
}
;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;
WAnim_ShrinkExpand(bShrink, sDir, iX, iY, iW, iH, hwnd, iInc, sGUIName="")
{
	global
	g_iInc := iInc
	g_bShrink := bShrink
	g_sDir := sDir
	WAnim_g_iX := iX
	WAnim_g_iY := iY
	WAnim_g_iW := iW
	WAnim_g_iH := iH
	WAnim_g_hWnd := hwnd
	g_iNdx := 0
	WAnim_g_sGUI := sGUIName

	SetTimer, WAnim_ShrinkExpand, 1
	return
}

WAnim_ShrinkExpand:
{

	WinGetPos, iX, iY, iW, iH, ahk_id %WAnim_g_hWnd%
	if (iW >= WAnim_g_iW || iH >= WAnim_g_iH)
	{
			if (WAnim_g_iX + WAnim_g_iW >= A_ScreenWidth)
				iX := 62
			if (WAnim_g_iY + WAnim_g_iH >= A_ScreenHeight)
				iY := 0
		WinMove, ahk_id %WAnim_g_hWnd%, , WAnim_g_iX, WAnim_g_iY, WAnim_g_iW, WAnim_g_iH
		if (WAnim_g_sGUI && g_bShrink)
		{
			GUI, %WAnim_g_sGUI%: Destroy
			WinKill, ahk_id %WAnim_g_hWnd%
		}
		SetTimer, WAnim_ShrinkExpand, Off
		return
	}

	iX := WAnim_g_bShrink ? iX + (g_iInc * .5) : iX - (g_iInc * .5)
	iY := WAnim_g_bShrink ? iY + (g_iInc * .5) : iY - (g_iInc * .5)
	iW := WAnim_g_bShrink ? iW - g_iInc : iW + g_iInc
	iH := WAnim_g_bShrink ? iH - g_iInc : iH + g_iInc

	if (iX + iW >= A_ScreenWidth)
		iX := 0
	if (iY + iH >= A_ScreenHeight)
		iY := 0

	WinMove, ahk_id %WAnim_g_hWnd%, , iX, iY, iW, iH

	return
}
;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;