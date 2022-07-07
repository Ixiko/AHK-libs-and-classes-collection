ProgFileExists(sInput) {
	bResult := False
	
	If (FileExist(sInput)) {
		bResult := True
	}
	
	isX86 := InStr(sInput,"C:\Program Files\")
	isX64 := InStr(sInput,"C:\Program Files (x86)\")
	
	if (isX86 = 0) {
		X86 := StrReplace(sInput,"C:\Program Files\","C:\Program Files (x86)\")
		If (FileExist(X86)) {
			bResult := True
		}
	}
	
	if (isX64 = 0) {
		X86 := StrReplace(sInput,"C:\Program Files (x86)\","C:\Program Files\")
		If (FileExist(X64)) {
			bResult := True
		}
	}
	
	Return bResult
}

;Test
;RegToggle("HKEY_CLASSES_ROOT\Directory\shellex\ContextMenuHandlers\7-Zip","",False)

RegToggle(sRegKey,sRegValueName,bToggle) {
	; bToggle = False (means to disable the key/value)
	; bToggle = True (means to enable the key/value)

	;MsgBox % "sRegKey: " . sRegKey
	
	sRootKey := GetTok(sRegKey,"\",1)
	sSubKey := GetTok(sRegKey,"\","2-")
	
	If (sRegValueName = "") {
		RegRead, sRegValue, %sRootKey%, %sSubKey%
	} Else {
		RegRead, sRegValue, %sRootKey%, %sSubKey%, %sRegValueName%
	}
	
	nValueLen := StrLen(sRegValue) - 1
	
	;MsgBox % "sRootKey: " . sRootKey . nl() . "sSubKey: " . sSubKey . nl() . "nValueLen: " . nValueLen
	
	; check if value is blank
	If StrLen(sRegValue) = 0 {
		bBlank := True
	} Else {
		bBlank := False
	}
	
	; check to see if key value status is enabled or disabled
	If (Left(sRegValue,1) = Chr(59)) {
		bStatus := True
		sPureValue := SubStr(sRegValue,2,nValueLen)
	} Else {
		bStatus := False
		sPureValue := sRegValue
	}
	
	sDisValue := Chr(59) . sPureValue
	
	;MsgBox % "sDisValue: " . sDisValue . nl() . "sPureValue: " . sPureValue
	;MsgBox % "bToggle: " . bToggle . nl() . "bBlank: " . bBlank . nl() . "bStatus: " . bStatus
	
	; bToggle = True (means to disable the key/value)
	; bToggle = False (means to enable the key/value)
	If (bToggle = False) {
		If (bBlank = False) And (bStatus = False) {
			;MsgBox disabling now
			RegWrite, REG_SZ, %sRootKey%, %sSubKey%, %sRegValueName%, %sDisValue%
		}
	}
	Else {
		If (bBlank = False) And (bStatus = True) {
			;MsgBox enabling Now
			RegWrite, REG_SZ, %sRootKey%, %sSubKey%, %sRegValueName%, %sPureValue%
		}
	}
}

RegMod(sRegKey,sRegValueName,sRegValue,sRegType,bToggle) {
	;sRegType = REG_SZ, REG_EXPAND_SZ, REG_MULTI_SZ, REG_DWORD, or REG_BINARY
	; bToggle = True means write / False means delete
	sRootKey := GetTok(sRegKey,"\",1)
	sSubKey := GetTok(sRegKey,"\","2-")
	
	;MsgBox % "sRootKey: " . sRootKey . nl() . "sSubKey: " . sSubKey
	
	If (bToggle = True) {
		RegWrite, %sRegType%, %sRootKey%, %sSubKey%, %sRegValueName%, %sRegValue%
	} Else {
		If (sRegValueName = "") {
			RegDelete, %sRootKey%, %sSubKey%
		} Else {
			RegDelete, %sRootKey%, %sSubKey%, %sRegValueName%
		}
	}
}

RegMerge(sFileName) {
	MergeFile := JcRoot . "\Merge\" . sFileName . ".reg"
	RunWait, "C:\Windows\regedit.exe" /s "%MergeFile%"
}