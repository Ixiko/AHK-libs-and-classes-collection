;'AutoHotkey Basic Unicode'
;Unicode functions for AutoHotkey Basic / AutoHotkey x32 ANSI
;Unicode functions for AHK v1.0 / v1.1 ANSI by jeeswg

;==================================================

JEE_AhkBasicWinGetTitleUtf8(hWnd)
{
	vDHW := A_DetectHiddenWindows
	DetectHiddenWindows, On
	vChars := DllCall("GetWindowTextLengthW", Int,hWnd)+1
	VarSetCapacity(vTextUtf16, vChars*2, 0)
	DllCall("GetWindowTextW", Int,hWnd, Int,&vTextUtf16, Int,vChars)
	vSize := DllCall("WideCharToMultiByte", UInt,65001, UInt,0, Int,&vTextUtf16, Int,vChars, Int,0, Int,0, Int,0, Int,0)
	VarSetCapacity(vWinTitle, vSize, 0)
	DllCall("WideCharToMultiByte", UInt,65001, UInt,0, Int,&vTextUtf16, Int,vChars, Str,vWinTitle, Int,vSize, Int,0, Int,0)
	DetectHiddenWindows, % vDHW
	return vWinTitle
}

;==================================================

JEE_AhkBasicClipboardGetTextUtf8()
{
	Transform, vText, Unicode
	return vText
}

;==================================================

;alternative method (that does not retrieve file paths, see JEE_AhkBasicClipboardGetPathsUtf8 instead)
JEE_AhkBasicClipboardGetTextUtf8Alt()
{
	;CF_LOCALE := 0x10 ;CF_UNICODETEXT := 0xD
	;CF_OEMTEXT := 0x7 ;CF_TEXT := 0x1
	if !DllCall("IsClipboardFormatAvailable", UInt,0xD)
		if DllCall("IsClipboardFormatAvailable", UInt,0x1)
			return Clipboard
		else
			return ""
	if !DllCall("OpenClipboard", Int,0)
		return ""
	if !hBuf := DllCall("GetClipboardData", UInt,0xD)
	{
		DllCall("CloseClipboard")
		return ""
	}

	pBuf := DllCall("GlobalLock", Int,hBuf, Int)
	vSize := DllCall("GlobalSize", Int,hBuf)
	VarSetCapacity(vOutputUtf16, vSize, 0)
	DllCall("kernel32\RtlMoveMemory", Int,&vOutputUtf16, Int,pBuf, UInt,vSize)

	vChars := vSize/2
	vSize := DllCall("WideCharToMultiByte", UInt,65001, UInt,0, Int,&vOutputUtf16, Int,vChars, Int,0, Int,0, Int,0, Int,0)
	VarSetCapacity(vOutput, vSize, 0)
	DllCall("WideCharToMultiByte", UInt,65001, UInt,0, Int,&vOutputUtf16, Int,vChars, Str,vOutput, Int,vSize, Int,0, Int,0)

	DllCall("GlobalUnlock", Int,hBuf)
	DllCall("CloseClipboard")
	return vOutput
}

;==================================================

JEE_AhkBasicClipboardGetPathsUtf8(vSep="`n")
{
	;CF_HDROP := 0xF
	if !DllCall("IsClipboardFormatAvailable", UInt,0xF)
		return ""
	if !DllCall("OpenClipboard", Int,0)
		return ""
	if !hDrop := DllCall("GetClipboardData", UInt,0xF)
	{
		DllCall("CloseClipboard")
		return ""
	}

	;==============================
	;based on JEE_DropGetPaths:
	vOutput := ""
	vCount := DllCall("shell32\DragQueryFileW", Int,hDrop, UInt,-1, Int,0, UInt,0, UInt)
	Loop, % vCount
	{
		vChars := DllCall("shell32\DragQueryFileW", Int,hDrop, UInt,A_Index-1, Int,0, UInt,0, UInt) + 1
		VarSetCapacity(vPathUtf16, vChars*2, 0)
		DllCall("shell32\DragQueryFileW", Int,hDrop, UInt,A_Index-1, Int,&vPathUtf16, UInt,vChars, UInt)

		vSize := DllCall("WideCharToMultiByte", UInt,65001, UInt,0, Int,&vPathUtf16, Int,vChars, Int,0, Int,0, Int,0, Int,0)
		VarSetCapacity(vPath, vSize, 0)
		DllCall("WideCharToMultiByte", UInt,65001, UInt,0, Int,&vPathUtf16, Int,vChars, Str,vPath, Int,vSize, Int,0, Int,0)
		vOutput .= vPath vSep
	}
	DllCall("shell32\DragFinish", Int,hDrop)
	;==============================

	DllCall("CloseClipboard")
	return SubStr(vOutput, 1, -StrLen(vSep))
}

;==================================================

JEE_AhkBasicClipboardSetTextUtf8(vText)
{
	Transform, Clipboard, Unicode, % vText
}

;==================================================

;alternative method
JEE_AhkBasicClipboardSetTextUtf8Alt(vText)
{
	;GMEM_ZEROINIT := 0x40, GMEM_MOVEABLE := 0x2
	hBuf := DllCall("GlobalAlloc", UInt,0x42, UInt,(StrLen(vText)+2)*2, Int)
	pBuf := DllCall("GlobalLock", Int,hBuf, Int)

	vChars := DllCall("MultiByteToWideChar", UInt,65001, UInt,0, Str,vText, Int,-1, Int,0, Int,0)
	VarSetCapacity(vTextUtf16, vChars*2, 0)
	DllCall("MultiByteToWideChar", UInt,65001, UInt,0, Str,vText, Int,-1, Int,&vTextUtf16, Int,vChars*2)
	DllCall("kernel32\RtlMoveMemory", Int,pBuf, Int,&vTextUtf16, UInt,vChars*2)

	;CF_LOCALE := 0x10 ;CF_UNICODETEXT := 0xD
	;CF_OEMTEXT := 0x7 ;CF_TEXT := 0x1
	hWnd := A_ScriptHwnd ? A_ScriptHwnd : WinExist("ahk_pid " DllCall("GetCurrentProcessId", UInt))
	DllCall("GlobalUnlock", Int,hBuf)
	DllCall("OpenClipboard", Int,hWnd)
	DllCall("EmptyClipboard")
	DllCall("SetClipboardData", UInt,0xD, Int,hBuf)
	DllCall("CloseClipboard")
	return
}

;==================================================

JEE_AhkBasicCtlGetTextUtf8(hCtl)
{
	SendMessage, 0xE, 0, 0,, % "ahk_id " hCtl ;WM_GETTEXTLENGTH := 0xE
	vChars := ErrorLevel+1
	VarSetCapacity(vTextUtf16, vChars*2, 0)
	DllCall("SendMessageW", Int,hCtl, UInt,0xD, UInt,vChars, Int,&vTextUtf16) ;WM_GETTEXT := 0xD
	vSize := DllCall("WideCharToMultiByte", UInt,65001, UInt,0, Int,&vTextUtf16, Int,vChars, Int,0, Int,0, Int,0, Int,0)
	VarSetCapacity(vText, vSize, 0)
	DllCall("WideCharToMultiByte", UInt,65001, UInt,0, Int,&vTextUtf16, Int,vChars, Str,vText, Int,vSize, Int,0, Int,0)
	return vText
}

;==================================================

JEE_AhkBasicCtlGetSelTextUtf8(hCtl)
{
	VarSetCapacity(vPos1, 4, 0), VarSetCapacity(vPos2, 4, 0)
	SendMessage, 0xB0, % &vPos1, % &vPos2,, % "ahk_id " hCtl ;EM_GETSEL := 0xB0
	vPos1 := NumGet(&vPos1, 0, "UInt"), vPos2 := NumGet(&vPos2, 0, "UInt")
	if (vPos1 = vPos2)
		return
	vOffset := vPos1*2
	vCharsSel := vPos2-vPos1

	SendMessage, 0xE, 0, 0,, % "ahk_id " hCtl ;WM_GETTEXTLENGTH := 0xE
	vChars := ErrorLevel+1
	VarSetCapacity(vTextUtf16, vChars*2, 0)
	DllCall("SendMessageW", Int,hCtl, UInt,0xD, UInt,vChars, Int,&vTextUtf16) ;WM_GETTEXT := 0xD
	vSize := DllCall("WideCharToMultiByte", UInt,65001, UInt,0, Int,&vTextUtf16+vOffset, Int,vCharsSel, Int,0, Int,0, Int,0, Int,0)
	VarSetCapacity(vText, vSize, 0)
	DllCall("WideCharToMultiByte", UInt,65001, UInt,0, Int,&vTextUtf16+vOffset, Int,vCharsSel, Str,vText, Int,vSize, Int,0, Int,0)
	return vText
}

;==================================================

JEE_AhkBasicMsgBoxUtf8(vText, vWinTitle, vType=0)
{
	vChars := DllCall("MultiByteToWideChar", UInt,65001, UInt,0, Str,vText, Int,-1, Int,0, Int,0)
	VarSetCapacity(vTextUtf16, vChars*2, 0)
	DllCall("MultiByteToWideChar", UInt,65001, UInt,0, Str,vText, Int,-1, Int,&vTextUtf16, Int,vChars*2)

	vChars := DllCall("MultiByteToWideChar", UInt,65001, UInt,0, Str,vWinTitle, Int,-1, Int,0, Int,0)
	VarSetCapacity(vWinTitleUtf16, vChars*2, 0)
	DllCall("MultiByteToWideChar", UInt,65001, UInt,0, Str,vWinTitle, Int,-1, Int,&vWinTitleUtf16, Int,vChars*2)
	return DllCall("MessageBoxW", Int,0, Int,&vTextUtf16, Int,&vWinTitleUtf16, UInt,vType)
}

;==================================================

;get nth Unicode character
JEE_AhkBasicChrUtf8(vNum)
{
	VarSetCapacity(vTextUtf16, 4, 0)
	NumPut(vNum, &vTextUtf16+0, 0, "UShort")
	vSize := DllCall("WideCharToMultiByte", UInt,65001, UInt,0, Int,&vTextUtf16, Int,2, Int,0, Int,0, Int,0, Int,0)
	VarSetCapacity(vOutput, vSize, 0)
	DllCall("WideCharToMultiByte", UInt,65001, UInt,0, Int,&vTextUtf16, Int,2, Str,vOutput, Int,vSize, Int,0, Int,0)
	return vOutput
}

;==================================================

;get nth ANSI character
JEE_AhkBasicChrAUtf8(vNum)
{
	VarSetCapacity(vText, 2, 0)
	NumPut(vNum, &vText+0, 0, "UChar")
	VarSetCapacity(vTextUtf16, 4, 0)
	DllCall("MultiByteToWideChar", UInt,0, UInt,0, UInt,&vText, Int,-1, Int,&vTextUtf16, Int,4)

	vSize := DllCall("WideCharToMultiByte", UInt,65001, UInt,0, Int,&vTextUtf16, Int,2, Int,0, Int,0, Int,0, Int,0)
	VarSetCapacity(vOutput, vSize, 0)
	DllCall("WideCharToMultiByte", UInt,65001, UInt,0, Int,&vTextUtf16, Int,2, Str,vOutput, Int,vSize, Int,0, Int,0)
	return vOutput
}

;==================================================

JEE_AhkBasicSendCharsUtf8(vText, hWnd="")
{
	if (hWnd = "")
	{
		WinGet, hWnd, ID, A
		ControlGetFocus, vCtlClassNN, % "ahk_id " hWnd
		if !(vCtlClassNN = "")
			ControlGet, hWnd, Hwnd,, % vCtlClassNN, % "ahk_id " hWnd
	}
	vChars := DllCall("MultiByteToWideChar", UInt,65001, UInt,0, Str,vText, Int,-1, Int,0, Int,0)
	VarSetCapacity(vTextUtf16, vChars*2, 0)
	DllCall("MultiByteToWideChar", UInt,65001, UInt,0, Str,vText, Int,-1, Int,&vTextUtf16, Int,vChars*2)
	Loop, % vChars-1
	{
		vNum := NumGet(&vTextUtf16+0, A_Index*2-2, "UShort")
		DllCall("PostMessageW", Int,hWnd, UInt,0x102, UInt,vNum, Int,1) ;WM_CHAR := 0x102
	}
}

;==================================================

JEE_AhkBasicCtlSetTextUtf8(vText, hWnd="")
{
	vChars := DllCall("MultiByteToWideChar", UInt,65001, UInt,0, Str,vText, Int,-1, Int,0, Int,0)
	VarSetCapacity(vTextUtf16, vChars*2, 0)
	DllCall("MultiByteToWideChar", UInt,65001, UInt,0, Str,vText, Int,-1, Int,&vTextUtf16, Int,vChars*2)
	DllCall("SendMessageW", Int,hWnd, UInt,0xC, UInt,0, Int,&vTextUtf16) ;WM_SETTEXT := 0xC
}

;==================================================

JEE_AhkBasicEditPasteUtf8(vText, hWnd="", vCanUndo=1)
{
	vChars := DllCall("MultiByteToWideChar", UInt,65001, UInt,0, Str,vText, Int,-1, Int,0, Int,0)
	VarSetCapacity(vTextUtf16, vChars*2, 0)
	DllCall("MultiByteToWideChar", UInt,65001, UInt,0, Str,vText, Int,-1, Int,&vTextUtf16, Int,vChars*2)
	DllCall("SendMessageW", Int,hWnd, UInt,0xC2, UInt,vCanUndo, Int,&vTextUtf16) ;EM_REPLACESEL := 0xC2
}

;==================================================

JEE_AhkBasicAnsiToUtf8(vText)
{
	vChars := DllCall("MultiByteToWideChar", UInt,65001, UInt,0, Str,vText, Int,-1, Int,0, Int,0)
	VarSetCapacity(vTextUtf16, vChars*2, 0)
	DllCall("MultiByteToWideChar", UInt,0, UInt,0, Str,vText, Int,-1, Int,&vTextUtf16, Int,vChars*2)

	vSize := DllCall("WideCharToMultiByte", UInt,65001, UInt,0, Int,&vTextUtf16, Int,vChars, Int,0, Int,0, Int,0, Int,0)
	VarSetCapacity(vOutput, vSize, 0)
	DllCall("WideCharToMultiByte", UInt,65001, UInt,0, Int,&vTextUtf16, Int,vChars, Str,vOutput, Int,vSize, Int,0, Int,0)
	return vOutput
}

;==================================================

;note: best-fit characters (replace Unicode chars with lookalike chars if available, otherwise '?')
JEE_AhkBasicUtf8ToAnsi(vText, vBFC=0)
{
	;WC_NO_BEST_FIT_CHARS := 0x400
	vFlags := vBFC ? 0 : 0x400

	vChars := DllCall("MultiByteToWideChar", UInt,65001, UInt,0, Str,vText, Int,-1, Int,0, Int,0)
	VarSetCapacity(vTextUtf16, vChars*2, 0)
	DllCall("MultiByteToWideChar", UInt,65001, UInt,0, Str,vText, Int,-1, Int,&vTextUtf16, Int,vChars*2)

	vSize := DllCall("WideCharToMultiByte", UInt,65001, UInt,0, Int,&vTextUtf16, Int,vChars, Int,0, Int,0, Int,0, Int,0)
	VarSetCapacity(vOutput, vSize, 0)
	DllCall("WideCharToMultiByte", UInt,0, UInt,vFlags, Int,&vTextUtf16, Int,vChars, Str,vOutput, Int,vSize, Int,0, Int,0)
	return vOutput
}

;==================================================

;JEE_AhkBasicAscUtf8(vText)

;==================================================

;JEE_AhkBasicAscAUtf8(vText)

;==================================================

;JEE_AhkBasicOrdUtf8(vText, vAscMode=0)

;==================================================

;JEE_AhkBasicOrdAUtf8(vText, vAscMode=0)

;==================================================

;JEE_AhkBasicStrLenUtf8(vText)

;==================================================

;note: uses same parameters as AHK v2's SubStr
;JEE_AhkBasicSubStrUtf8(vText, vPos, vLen)

;==================================================

;note: unlike NumGet, vAddrDest/vAddrSource must be numbers
;JEE_AhkBasicMemMove(vAddrDest, vAddrSource, vSize)

;==================================================

;note: unlike NumGet, vAddr must be a number
;JEE_AhkBasicHexGet(vAddr, vSize)

;==================================================

;note: unlike NumPut, vAddr must be an address
;JEE_AhkBasicHexPut(vHex, vAddr)

;==================================================

;JEE_AhkBasicFileGetEnc(vPath, vOpt="", ByRef vIsEmpty="")

;==================================================

;JEE_AhkBasicFileEmpty(vPath)

;==================================================

;from file: ANSI/UTF-8/UTF-16/UTF-16 BE
;to var: ANSI/UTF-8/hex
;JEE_AhkBasicFileRead(vPath, vEnc, vOffset=0, vSize=-1)

;==================================================

;from var: ANSI/UTF-8/hex
;to file: ANSI/UTF-8/UTF-16/UTF-16 BE
;JEE_AhkBasicFileAppend(vText, vPath, vEnc, vOffset=0, vSize=-1)

;==================================================

;JEE_AhkBasicFileReadBin(vPath, vOffset=0, vSize=-1)

;==================================================

;JEE_AhkBasicFileAppendBin(vText, vPath, vOffset=0, vSize=-1)

;==================================================
