JEE_StrRept(vText, vNum) {
	if (vNum <= 0)
		return
	return StrReplace(Format("{:" vNum "}", ""), " ", vText)
	;return StrReplace(Format("{:0" vNum "}", 0), 0, vText)
}
JEE_AccGetTextAll(hWnd:=0, vSep:="`n", vIndent:="`t", vOpt:="") {
	file := FileOpen( "d:\ahk.txt", "a" )
	if !IsObject(file)
	{
	MsgBox Can't open "%FileName%" for writing.
	return
	}

	str := "ERSTER:"
	file.Write(str)

	vLimN := 20, vLimV := 20
	Loop, Parse, vOpt, % " "
	{
		vTemp := A_LoopField
		if (SubStr(vTemp, 1, 1) = "n")
			vLimN := SubStr(vTemp, 2)
		else if (SubStr(vTemp, 1, 1) = "v")
			vLimV := SubStr(vTemp, 2)
	}

	oMem := {}, oPos := {}
	;OBJID_WINDOW := 0x0
	oMem[1, 1] := Acc_ObjectFromWindow(hWnd, 0x0)
	oPos[1] := 1, vLevel := 1
	VarSetCapacity(vOutput, 1000000*2)

	Loop
	{
		if !vLevel
			break
		if !oMem[vLevel].HasKey(oPos[vLevel])
		{
			oMem.Delete(vLevel)
			oPos.Delete(vLevel)
			vLevelLast := vLevel, vLevel -= 1
			oPos[vLevel]++
			continue
		}
		oKey := oMem[vLevel, oPos[vLevel]]

		vName := "", vValue := ""
		if IsObject(oKey)
		{
			vRoleText := Acc_GetRoleText(oKey.accRole(0))
			try vName := oKey.accName(0)
			try vValue := oKey.accValue(0)
		}
		else
		{
			oParent := oMem[vLevel-1,oPos[vLevel-1]]
			vChildId := IsObject(oKey) ? 0 : oPos[vLevel]
			vRoleText := Acc_GetRoleText(oParent.accRole(vChildID))
			try vName := oParent.accName(vChildID)
			try vValue := oParent.accValue(vChildID)
		}
		if (StrLen(vName) > vLimN)
			vName := SubStr(vName, 1, vLimN) "..."
		if (StrLen(vValue) > vLimV)
			vValue := SubStr(vValue, 1, vLimV) "..."
		vName := RegExReplace(vName, "[`r`n]", " ")
		vValue := RegExReplace(vValue, "[`r`n]", " ")

		vAccPath := ""
		if IsObject(oKey)
		{
			Loop, % oPos.Length() - 1
				vAccPath .= (A_Index=1?"":".") oPos[A_Index+1]
		}
		else
		{
			Loop, % oPos.Length() - 2
				vAccPath .= (A_Index=1?"":".") oPos[A_Index+1]
			vAccPath .= " c" oPos[oPos.Length()]
		}

		vOutput .= vAccPath "`t" JEE_StrRept(vIndent, vLevel-1) vRoleText " [" vName "][" vValue "]" vSep

		oChildren := Acc_Children(oKey)
		if !oChildren.Length()
			oPos[vLevel]++
		else
		{
			vLevelLast := vLevel, vLevel += 1
			oMem[vLevel] := oChildren
			oPos[vLevel] := 1
		}

		file.Write(vOutput)
	}
	file.Close()
	return SubStr(vOutput, 1, -StrLen(vSep))
}
;==================================================
/*
q::
WinGet, hWnd, ID, A
MsgBox, % Clipboard := JEE_AccGetTextAll(hWnd, "`r`n")
return
*/
; ;e.g.
; q::
; ControlGet, hCtl, Hwnd,, Edit1, A
; MsgBox, % Clipboard := JEE_AccGetTextAll(hCtl, "`r`n")
; return

; ;e.g.
; q::
; ControlGetFocus, vCtlClassNN, A
; ControlGet, hCtl, Hwnd,, % vCtlClassNN, A
; MsgBox, % Clipboard := JEE_AccGetTextAll(hCtl, "`r`n")
; return

;vOpt: space-separated list
;vOpt: n#: e.g. n20 ;limit retrieve name to first 20 characters
;vOpt: v#: e.g. v20 ;limit retrieve value to first 20 characters

