; http://the-automator.com/download/dmp.ahk
; dmp Version 1.25
; By ObiWanKenobi
; Visit guresicpark.de for dmp updates
; May 8, 2015
;~ http://guresicpark.de/autohotkey/dmp

dmp(pVar*) {
    static _iCallCount := 0

    ; set x as basic variable name
    aVarnames := ["x"]

    ; now search variable name
	sLines := _dmpListLines()
    aLines := StrSplit(sLines, "`n", "`r")
    iLinesLength := aLines.Length()
    for deltaLines, LinesItem in aLines
    {
        sCurrentLine := aLines[(aLines.Length()+1)-deltaLines]
        if RegExMatch(sCurrentLine, "i)dmp\s*\(.*\)", match)
        {
            RegExMatch(sCurrentLine, "^(\d+)\:", match)
            iLineNumber := match1 + 0
            aVarnames := _dmpGetVarnames(sCurrentLine)
            break
        }
    }

    ; start dump
    _iCallCount++
    for deltaVar, VarItem in pVar
    {
        global gliRowCount := 0
        global glsRet=
        _dmp(VarItem, aVarnames[deltaVar])
        glsRet := LTrim(glsRet, "`r`n")
        glsRet := StrReplace(glsRet, "%", "``%")
        if (sDmpOutput!="")
            sDmpOutput .= "`r`n`r`n`r`n`r`n"
        sDmpOutput .= ">>>>> " . aVarnames[deltaVar]
        sDmpOutput .= "`r`n`r`n"
        sDmpOutput .= glsRet
        sDmpOutput .= "`r`n`r`n"
        if (gliRowCount > 1)
            sDmpOutput .= gliRowCount . " elements for " . aVarnames[deltaVar] . " "
        sDmpOutput .= "<<<<<"
    }

    pidCurrent := DllCall("GetCurrentProcessId")

    sScriptPopup =
    (ltrim join`r`n
        #NoEnv

        sDmpOutput=
        `(join``r``n
            %sDmpOutput%
        `)

        OnMessage(0x0111, "On_EN_SETFOCUS")
        OnMessage(0x100, "OnKeyDown")

        Gui +AlwaysOnTop +ToolWindow +Resize +MinSize400x300
        Gui, Add, Edit, +Readonly w780 h570 vedit, `% sDmpOutput
        Gui, Add, Button, xm w100 y+10 gButtonContinue vButtonContinue, Continue
        Gui, Add, Button, xp+120 yp+0 w100 gButtonReload vButtonReload, Reload script
        Gui, Add, Button, xp+120 yp+0 w100 gButtonKill vButtonKill, Kill script

        gosub Guisize

        Gui, Show, Center w800 h600, call #%_iCallCount% in line %iLineNumber% - dmp 1.25
        Return

        Guisize:
            glsEditWidth := "w" . A_GuiWidth - 20
            glsEditHeight := "h" . A_GuiHeight - 50
            GuiControl, Move, edit, `% glsEditWidth . " " . glsEditHeight
            GuiControl, Move, ButtonContinue, `%  "y" . (A_GuiHeight - 30)
            GuiControl, Move, ButtonReload, `%  "y" . (A_GuiHeight - 30)
            GuiControl, Move, ButtonKill, `%  "y" . (A_GuiHeight - 30)
        return

        ButtonReload:
            process, close, `% %pidCurrent%
            Sleep, 120
            Run, %A_ScriptFullPath%
            ExitApp
        return

        ButtonKill:
            process, close, `% %pidCurrent%
        GUIEscape:
        GuiClose:
        ButtonContinue:
        ExitApp

        On_EN_SETFOCUS(wParam, lParam) {
           Static EM_SETSEL   := 0x00B1
           Static EN_SETFOCUS := 0x0100
           Critical
           If ((wParam >> 16) = EN_SETFOCUS) {
              DllCall("User32.dll\HideCaret", "Ptr", lParam)
              PostMessage, `%EM_SETSEL`%, -1, 0, , ahk_id `%lParam`%
           }
        }

        OnKeyDown(wParam)
        {
            if (wParam = 13)
                ExitApp
        }
    )

    pidScriptPopup := _dmpDynaRun(sScriptPopup)
    Process, WaitClose, %pidScriptPopup%
}

_dmp(pVar, _psPrefix, _piLevel:=0) {
    global gliRowCount
    global glsRet

    if (IsObject(pVar))
    {
        if (_dmpArrayEmpty(pVar))
        {
            gliRowCount++
            glsRet .= "`r`n" . _psPrefix . " := []"
        }
        else
        {
            for deltaVar, VarItem in pVar
            {
                _dmp(VarItem, _psPrefix . "[" . _dmpGetQuotes(deltaVar) . "]", _piLevel + 1)
            }
        }
    }
    else
    {
        gliRowCount++
        glsRet .= "`r`n" . _psPrefix . " := " . _dmpGetQuotes(pVar)
    }
}

_dmpArrayEmpty(paArray) {
    for deltaArray, ArrayItem in paArray
        return false
    return true
}

_dmpGetQuotes(pVar) {
    sRet=
    if !IsObject(pVar)
    {
        if (ObjGetCapacity([pVar], 1) != "")
        {
            if (RegExMatch(pVar, "^\d+\.\d+$"))
                sRet := pVar
            else
            {
                if (StrSplit(pVar, "`n", "`r").Length() > 1)
                    sRet := "`n"
                sRet .= """" . pVar . """"
            }
        }
        else
        {
            if !pVar
                sRet := "0"
            else
                sRet := pVar
        }
    }
    return sRet
}

_dmpRecursiveBracketNeutralizer(ByRef psText, paBracket, piStartLevel:=0, piStartPos:=1, _piLevel:=0) {
	iPos := piStartPos
	while (iPos <= StrLen(psText))
	{
		if (SubStr(psText, iPos, StrLen(paBracket[1]))==paBracket[1])
		{
			iPos := _dmpRecursiveBracketNeutralizer(psText, paBracket, piStartLevel, iPos+1, _piLevel+1)
		}
		else if (SubStr(psText, iPos, StrLen(paBracket[2]))==paBracket[2])
		{
			if (piStartLevel<_piLevel)
			{
				; do replacement
				iDiff:=iPos+StrLen(paBracket[2])-piStartPos
				sReplacement=
				loop, % (iDiff+1)
					sReplacement .= "*"
				psText:=_dmpReplaceSE(psText, piStartPos-1, (iPos-1)+StrLen(paBracket[2]), sReplacement)

				; calculate difference between old found string and replacement for iPos reset
				iPos+=(StrLen(sReplacement)-iDiff)
			}
			return iPos++
		}
		else
			iPos++
	}
}

; *** string functions

_dmpStringSplitPositions(psText, psNeedle, piStartPos:=1) {
	aRet := []
	if (psText != "")
	{
		iStartPos := piStartPos
		while (iPos := InStr(psText, psNeedle, false, iStartPos))
		{
			aEl := []
			aEl["iStartPos"] := iStartPos
			aEl["iEndPos"] := iPos-1
			aRet.Push(aEl)
			iStartPos := iPos + StrLen(psNeedle)
		}
		aEl := []
		aEl["iStartPos"] := iStartPos
		aEl["iEndPos"] := StrLen(psText)
		aRet.Push(aEl)
	}
	return aRet
}

_dmpReplaceSE(psText, piPosStart, piPosEnd:="", psReplacement:="") {
	if (psText!="")
	{
		piPosEnd := piPosEnd != "" ? piPosEnd : StrLen(psText)
		sBefore := SubStr(psText, 1, piPosStart-1)
		sAfter := SubStr(psText, piPosEnd+1, StrLen(psText))
		return sBefore . psReplacement . sAfter
	}
	else
	{
		return psReplacement
	}
}

_dmpExtractSE(psText, piPosStart, piPosEnd:="") {
	if (psText != "")
	{
		piPosEnd := piPosEnd != "" ? piPosEnd : StrLen(psText)
		return SubStr(psText, piPosStart, piPosEnd-(piPosStart-1))
	}
}

_dmpGetVarContent(psText) {
	sRet=
	if RegExMatch(psText, "i)dmp\s*\((.*)\)", match)
	{
		sRet := match1
	}
	return sRet
}

_dmpGetVarnames(psText) {
	aRet := []
	if (psText!="")
	{
		sTextSaved := psText

		_dmpRecursiveBracketNeutralizer(psText, ["{", "}"])
		_dmpRecursiveBracketNeutralizer(psText, ["[", "]"])
		_dmpRecursiveBracketNeutralizer(psText, ["(", ")"], 1)

		sVarContent := _dmpGetVarContent(psText)
		aVarContentPositions := _dmpStringSplitPositions(sVarContent, ",")
		sVarContentSaved := _dmpGetVarContent(sTextSaved)
		for deltaVarContentPositions, VarContentPositionsItem in aVarContentPositions
		{
			sFound := _dmpExtractSE(sVarContentSaved, VarContentPositionsItem["iStartPos"], VarContentPositionsItem["iEndPos"])
			sFound=%sFound%
			aRet.Push(sFound)
		}
	}
	return aRet
}

; *** external functions

_dmpDynaRun(s, pn:="", pr:=""){ ; s=Script,pn=PipeName,n:=,pr=Parameters,p1+p2=hPipes,P=PID
   static AhkPath:="""" A_AhkPath """" (A_IsCompiled||(A_IsDll&&DllCall(A_AhkPath "\ahkgetvar","Str","A_IsCompiled"))?" /E":"") " """
   if (-1=p1 := DllCall("CreateNamedPipe","str",pf:="\\.\pipe\" (pn!=""?pn:"AHK" A_TickCount),"uint",2,"uint",0,"uint",255,"uint",0,"uint",0,"Ptr",0,"Ptr",0))
      || (-1=p2 := DllCall("CreateNamedPipe","str",pf,"uint",2,"uint",0,"uint",255,"uint",0,"uint",0,"Ptr",0,"Ptr",0))
      Return 0
   ; allow compiled executable to execute dynamic scripts. Requires AHK_H
   Run, % AhkPath pf """ " pr,,UseErrorLevel HIDE, P
   If ErrorLevel
      return 0,DllCall("CloseHandle","Ptr",p1),DllCall("CloseHandle","Ptr",p2)
   DllCall("ConnectNamedPipe","Ptr",p1,"Ptr",0),DllCall("CloseHandle","Ptr",p1),DllCall("ConnectNamedPipe","Ptr",p2,"Ptr",0)
   if !DllCall("WriteFile","Ptr",p2,"Wstr",s:=(A_IsUnicode?chr(0xfeff):"﻿") s,"UInt",StrLen(s)*(A_IsUnicode ? 2 : 1)+(A_IsUnicode?4:6),"uint*",0,"Ptr",0)
      P:=0
   DllCall("CloseHandle","Ptr",p2)
   Return P
}

_dmpListLines() {
    static hwndEdit, pSFW, pSW, bkpSFW, bkpSW
    ListLines Off

    if !hwndEdit
    {
        ; Retrieve the handle of our main window's Edit control:
        dhw := A_DetectHiddenWindows
        DetectHiddenWindows, On
        Process, Exist
        ControlGet, hwndEdit, Hwnd,, Edit1, ahk_class AutoHotkey ahk_pid %ErrorLevel%
        DetectHiddenWindows, %dhw%

        astr := A_IsUnicode ? "astr" : "str"
        hmod := DllCall("GetModuleHandle", "str", "user32.dll")
        ; Get addresses of these two functions:
        pSFW := DllCall("GetProcAddress", "uint", hmod, astr, "SetForegroundWindow")
        pSW := DllCall("GetProcAddress", "uint", hmod, astr, "ShowWindow")
        ; Make them writable:
        DllCall("VirtualProtect", "uint", pSFW, "uint", 8, "uint", 0x40, "uint*", 0)
        DllCall("VirtualProtect", "uint", pSW, "uint", 8, "uint", 0x40, "uint*", 0)
        ; Save initial values of the first 8 bytes:
        bkpSFW := NumGet(pSFW+0, 0, "int64")
        bkpSW := NumGet(pSW+0, 0, "int64")
    }

    ; Overwrite SetForegroundWindow() and ShowWindow() temporarily:
    NumPut(0x0004C200000001B8, pSFW+0, 0, "int64")  ; return TRUE
    NumPut(0x0008C200000001B8, pSW+0, 0, "int64")   ; return TRUE

    ; Dump ListLines into hidden AutoHotkey main window:
    ListLines

    ; Restore SetForegroundWindow() and ShowWindow():
    NumPut(bkpSFW, pSFW+0, 0, "int64")
    NumPut(bkpSW, pSW+0, 0, "int64")

    ; Retrieve ListLines text and strip out some unnecessary stuff:
    ControlGetText, ListLinesText,, ahk_id %hwndEdit%
    RegExMatch(ListLinesText, ".*`r`n`r`n\K[\s\S]*(?=`r`n`r`n.*$)", ListLinesText)
    StringReplace, ListLinesText, ListLinesText, `r`n, `n, All

    ListLines On
    return ListLinesText  ; This line appears in ListLines if we're called more than once.
}