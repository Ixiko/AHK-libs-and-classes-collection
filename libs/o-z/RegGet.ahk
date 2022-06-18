; Link:
; Author:
; Date:
; for:     	AHK_L

/* example

	q:: ;registry - list keys
	vKey := "HKEY_LOCAL_MACHINE"
	vKey := "HKEY_LOCAL_MACHINE\HARDWARE"

	oMem := {}, oPos := {}
	vLevel := 1, vOutput := ""
	vPfx := "[", vSfx := "]"
	vBitness := 64
	VarSetCapacity(vOutput, 1000000*2)
	vOutput .= vPfx vKey vSfx "`r`n"
	Loop
	{
		if !vLevel
			break
		if !oMem[vLevel].HasKey(0) ;a key we haven't seen before
		{
			oMem[vLevel] := JEE_RegGetSubKeys(vKey, vBitness)
			oPos[vLevel] := 1
		}
		if oMem[vLevel].HasKey(oPos[vLevel])
		{
			vKey := oMem[vLevel, 0] "\" oMem[vLevel, oPos[vLevel]]
			vLevel++
			vOutput .= vPfx vKey vSfx "`r`n"
		}
		else
		{
			oMem.Delete(vLevel)
			vLevel--
			oPos[vLevel]++
			vKey := oMem[vLevel, 0]
		}
	}
	MsgBox, % Clipboard := vOutput
	return

	;==================================================

	w:: ;registry - list values
	vKey := "HKEY_CURRENT_USER\Software\Microsoft\Notepad"
	vBitness := 64
	oList := JEE_RegGetValues(vKey, vBitness)
	vOutput := ""
	Loop, % oList.Length()
		vOutput .= Format("{}`t{}`t{}`r`n", oList[A_Index].1, oList[A_Index].2,  oList[A_Index].3)
	Clipboard := vOutput
	MsgBox, % vOutput
	return

	;==================================================

	e:: ;registry - regedit - export key to reg file
	vKey := "HKEY_LOCAL_MACHINE"
	vKey := "HKEY_LOCAL_MACHINE\HARDWARE"
	vKey2 := StrReplace(vKey, "\", "-")
	vPath = %A_Desktop%\%vKey2% %A_Now%.hiv
	vTarget = %ComSpec% /c regedit /e "%vPath%" "%vKey%"
	MsgBox, % vTarget
	RunWait, % vTarget,, Hide
	return

	;==================================================

	r:: ;registry - reg file get keys
	vPath = %A_Desktop%\HKEY_LOCAL_MACHINE 20171011220137.hiv
	FileRead, vText, % vPath
	vOutput := ""
	VarSetCapacity(vOutput, StrLen(vText)*2)
	Loop, Parse, vText, `n, `r
	{
		vTemp := A_LoopField
		if (SubStr(vTemp, 1, 1) = "[")
			vOutput .= vTemp "`r`n"
	}
	Clipboard := vOutput
	MsgBox, % "done"
	return


*/


;==================================================
JEE_BinDataToHex(vAddr, vSize) {
	;CRYPT_STRING_HEX := 0x4 ;to return space/CRLF-separated text
	;CRYPT_STRING_HEXRAW := 0xC ;to return raw hex (not supported by Windows XP)
	DllCall("crypt32\CryptBinaryToString", Ptr,vAddr, UInt,vSize, UInt,0x4, Ptr,0, UIntP,vChars)
	VarSetCapacity(vHex, vChars*2, 0)
	DllCall("crypt32\CryptBinaryToString", Ptr,vAddr, UInt,vSize, UInt,0x4, Str,vHex, UIntP,vChars)
	vHex := StrReplace(vHex, "`r`n")
	vHex := StrReplace(vHex, " ")
	return vHex
}
;==================================================
JEE_RegGetSubKeys(vRegKey, vBitness:="") {

	static oArray := {HKEY_CLASSES_ROOT:0x80000000,HKEY_CURRENT_USER:0x80000001,HKEY_LOCAL_MACHINE:0x80000002,HKEY_USERS:0x80000003,HKEY_CURRENT_CONFIG:0x80000005,HKEY_DYN_DATA:0x80000006,HKCR:0x80000000,HKCU:0x80000001,HKLM:0x80000002,HKU:0x80000003,HKCC:0x80000005}
	if (vRegKey = "")
		return {0:vRegKey}
	if vPos := InStr(vRegKey, "\")
		vRootKey := SubStr(vRegKey, 1, vPos-1), vSubKey := SubStr(vRegKey, vPos+1)
	else
		vRootKey := vRegKey, vSubKey := ""
	hRootKey := oArray[vRootKey]

	;KEY_WOW64_32KEY := 0x200
	;KEY_WOW64_64KEY := 0x100
	;KEY_ENUMERATE_SUB_KEYS := 0x8
	if (vBitness = "")
		vFlags := 0x8
	else if (vBitness = 64)
		vFlags := 0x108
	else if (vBitness = 32)
		vFlags := 0x208
	vRet := DllCall("advapi32\RegOpenKeyEx", Ptr,hRootKey, Str,vSubKey, UInt,0, UInt,vFlags, PtrP,hKey)
	if (vRet = 0x5) ;ERROR_ACCESS_DENIED := 0x5
		return {0:vRegKey}

	(oArray2 := {}).SetCapacity(1000)
	Loop 	{
		vChars := 255 ;reset vChars each time to avoid ERROR_MORE_DATA
		VarSetCapacity(vKeyName, vChars*2+2)
		;ERROR_NO_MORE_ITEMS := 0x103 ;ERROR_MORE_DATA := 0xEA ;ERROR_SUCCESS := 0x0
		if vRet := (DllCall("advapi32\RegEnumKeyEx", Ptr,hKey, UInt,A_Index-1, Str,vKeyName, UIntP,vChars, Ptr,0, Ptr,0, Ptr,0, Ptr,0) = 0x103)
			break
		if (vKeyName = "")
			break
		oArray2.Push(vKeyName)
	}
	DllCall("advapi32\RegCloseKey", Ptr,hKey)
	oArray2.0 := vRegKey
	return oArray2
}
;==================================================
JEE_RegGetValues(vRegKey, vBitness:="") {
	static oArray := {HKEY_CLASSES_ROOT:0x80000000,HKEY_CURRENT_USER:0x80000001,HKEY_LOCAL_MACHINE:0x80000002,HKEY_USERS:0x80000003,HKEY_CURRENT_CONFIG:0x80000005,HKEY_DYN_DATA:0x80000006,HKCR:0x80000000,HKCU:0x80000001,HKLM:0x80000002,HKU:0x80000003,HKCC:0x80000005}
	if (vRegKey = "")
		return {0:vRegKey}
	if vPos := InStr(vRegKey, "\")
		vRootKey := SubStr(vRegKey, 1, vPos-1), vSubKey := SubStr(vRegKey, vPos+1)
	else
		vRootKey := vRegKey, vSubKey := ""
	hRootKey := oArray[vRootKey]

	;KEY_WOW64_32KEY := 0x200
	;KEY_WOW64_64KEY := 0x100
	;KEY_QUERY_VALUE := 0x1
	if (vBitness = "")
		vFlags := 0x1
	else if (vBitness = 64)
		vFlags := 0x101
	else if (vBitness = 32)
		vFlags := 0x201
	vRet := DllCall("advapi32\RegOpenKeyEx", Ptr,hRootKey, Str,vSubKey, UInt,0, UInt,vFlags, PtrP,hKey)
	if (vRet = 0x5) ;ERROR_ACCESS_DENIED := 0x5
		return {0:vRegKey}

	;list from winnt.h
	;REG_NONE := 0
	;REG_SZ := 1
	;REG_EXPAND_SZ := 2
	;REG_BINARY := 3
	;REG_DWORD := 4
	;REG_DWORD_LITTLE_ENDIAN := 4
	;REG_DWORD_BIG_ENDIAN := 5
	;REG_LINK := 6
	;REG_MULTI_SZ := 7
	;REG_RESOURCE_LIST := 8
	;REG_FULL_RESOURCE_DESCRIPTOR := 9
	;REG_RESOURCE_REQUIREMENTS_LIST := 10
	;REG_QWORD := 11
	;REG_QWORD_LITTLE_ENDIAN := 11

	(oArray2 := {}).SetCapacity(1000)
	Loop
	{
		vChars := 16383 ;reset vChars each time to avoid ERROR_MORE_DATA
		VarSetCapacity(vValueName, vChars*2+2, 0)
		;ERROR_NO_MORE_ITEMS := 0x103 ;ERROR_MORE_DATA := 0xEA ;ERROR_SUCCESS := 0x0
		if vRet := (DllCall("advapi32\RegEnumValue", Ptr,hKey, UInt,A_Index-1, Str,vValueName, UIntP,vChars, Ptr,0, UIntP,vType, Ptr,0, UIntP,vSize) = 0x103)
			break
		if (vType = 4897272)
			break
		vChars := 16383 ;reset vChars each time to avoid ERROR_MORE_DATA
		VarSetCapacity(vData, vSize+2, 0)
		if (vType ~= "^(1|2|7)$")
			DllCall("advapi32\RegEnumValue", Ptr,hKey, UInt,A_Index-1, Str,vValueName, UIntP,vChars, Ptr,0, Ptr,0, Str,vData, UIntP,vSize)
		else
		{
			DllCall("advapi32\RegEnumValue", Ptr,hKey, UInt,A_Index-1, Str,vValueName, UIntP,vChars, Ptr,0, Ptr,0, Ptr,&vData, UIntP,vSize)
			vData := JEE_BinDataToHex(&vData, vSize)
		}
		oArray2.Push([vValueName,vType,vData])
	}
	DllCall("advapi32\RegCloseKey", Ptr,hKey)
	oArray2.0 := vRegKey
	return oArray2
}
;==================================================
