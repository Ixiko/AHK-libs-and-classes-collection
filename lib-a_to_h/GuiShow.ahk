; Link:   	
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

; GuiShow("w400 h400 Monitor2")
GuiShow(Options := "", Title := "", GuiName := 1)
{
	SysGet, mCount, MonitorCount
	SysGet, mPrimary, MonitorPrimary

	if RegExMatch(Options, "i)Monitor\K\d+", mNumber)
		Options := StrReplace(Options, "Monitor" mNumber)

	if !mNumber || (mCount = 1) || (mNumber = mPrimary) {
		Gui, %GuiName%:Show, % Options, % Title
		Return
	}
	
	SysGet, m, MonitorWorkArea, %mNumber%

	if optX := RegExMatch(Options, "i)\bx\K\d+\b", x)
		Options := RegExReplace(Options, "\bx\K\d+\b", x+mLeft)
	if !(optY := RegExMatch(Options, "i)\by\d+\b")) || !optX
	{
		Gui, %GuiName%:+HWNDhWnd
		Gui, %GuiName%:Show, %Options% Hide NA

		dhw := A_DetectHiddenWindows
		DetectHiddenWindows, On
		WinGetPos,,, guiW, guiH, ahk_id %hwnd%
		DetectHiddenWindows, %dhw%

		if !optX
			Options .= " x" Round(mLeft + (mRight-mLeft)/2 - guiW/2)
		if !optY
			Options .= " y" Round(mTop + (mBottom-mTop)/2 - guiH/2)
	}

	Gui, %GuiName%:Show, % Options, % Title
}