;Converts .REG files into VBScript code

#NoEnv
SetBatchLines, -1
Version := 1.1
QWordErrors := 0

If (!A_IsUnicode){
	MsgBox This script requires AHK _L unicode to function correctly.`nIt also requires the .REG files be unicode.
	ExitApp
}

Loop
{
	FileSelectFile, RegFile, , %A_ScriptDir%, Select the .REG file to convert (mustbe unicode formated)., *.REG
	
	If (RegFile = "")
		ExitApp
	Else If (FileExist(RegFile))
		Break
}

Convert_REG(RegFile)

If (QWordErrors)
	MsgBox Some (%QWordErrors%) of the QWord registry entires where over the maximum allowed in VBS (922337203685477).`n`nThe entries where set to the maximum allowed.
ExitApp

Convert_REG(_SourceFile)
{
	FileRead, REG, %_SourceFile%
	
	While (InStr(REG, "\`r`n  "))
		StringReplace, REG, REG, \`r`n%A_Space%%A_Space%, , A
	
	Loop, Parse, REG, `r, `n
	{
		If (A_LoopField = "Windows Registry Editor Version 5.00" Or A_LoopField = "")
			Continue
		
		If (SubStr(A_LoopField, 1, 1) = "["){
			If (Key)
				All_Statements .= "`r`n"
			
			Key := SubStr(A_LoopField, 2, StrLen(A_LoopField) - 2)
			
			, Container := SubStr(Key, 1, InStr(Key, "\") - 1)
			, Container := Compile_Container(Container)
			, Key := SubStr(Key, InStr(Key, "\") + 1)
			, Key := Compile_Key(Key)
			
			, Key := "Key = " Key
			, Statement := Compile_CreateKey(Container, "Key")
			, All_Statements .= Key "`r`n" Statement
		} Else {
			If (SubStr(A_LoopField, 1, 2) = "@="){
				Value_Name := """(Default)"""
				, Value_Type := "REG_SZ"
				, Value_Value := SubStr(A_LoopField, 4, StrLen(A_LoopField) - 4)
				, Value_Value := Compile_Value(Value_Value, Value_Type)
				
;				MsgBox % Value_Name "`n" Value_Type "`n" Value_Value
				
				All_Statements .= "oReg.SetStringValue " Container ", Key, " Value_Name ", " Value_Value "`r`n"
			} Else {
				Value_Name := Extract_Name(A_LoopField)
				Value_Value := SubStr(A_LoopField, StrLen(Value_Name) + 2)
				Value_Name := Parse_Name(Value_Name)
				
				If (SubStr(Value_Value, 1, 1) = """")
					Value_Type := "REG_SZ", Value_Value := SubStr(Value_Value, 2, StrLen(Value_Value) - 2)
				Else If (SubStr(Value_Value, 1, 4) = "hex:")
					Value_Type := "REG_BINARY", Value_Value := SubStr(Value_Value, 5, StrLen(Value_Value) - 4)
				Else If (SubStr(Value_Value, 1, 6) = "dword:")
					Value_Type := "REG_DWORD", Value_Value := SubStr(Value_Value, 7, StrLen(Value_Value) - 6)
				Else If (SubStr(Value_Value, 1, 7) = "hex(b):")
					Value_Type := "REG_QWORD", Value_Value := SubStr(Value_Value, 8, StrLen(Value_Value) - 7)
				Else If (SubStr(Value_Value, 1, 7) = "hex(7):")
					Value_Type := "REG_MULTI_SZ", Value_Value := SubStr(Value_Value, 8, StrLen(Value_Value) - 7)
				Else If (SubStr(Value_Value, 1, 7) = "hex(2):")
					Value_Type := "REG_EXPAND_SZ", Value_Value := SubStr(Value_Value, 8, StrLen(Value_Value) - 7)
				Else
					Value_Type := "UNKNOWN"
				
;				MsgBox % "Before parsing:`n`n" Value_Name "`n" Value_Type "`n" Value_Value
				
				Value_Name := Compile_Name(Value_Name)
				
				Value_Value := Compile_Value(Value_Value, Value_Type)
				
;				MsgBox % "After parsing:`n`n" Value_Name "`n" Value_Type "`n" Value_Value
				
				Statement := Compile_Statement(Container, "Key", Value_Name, Value_Type, Value_Value)
				
;				MsgBox % "After statement compile:`n`n" Statement
				
				All_Statements .= Statement
			}
		}
	}
	
	VBS_File_Start =
	(LTrim Join`r`n
		const HKCR = &H80000000
		const HKCU = &H80000001
		const HKLM = &H80000002
		const HKU = &H80000003
		const HKCC = &H80000005
		
		strComputer = "."
		Set oReg = GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & strComputer & "\root\default:StdRegProv")
		
		
	)
	
	VBS_File_End := "`r`nSet oReg = Nothing`r`n"
	
	If (InStr(All_Statements, "aBinary"))
		VBS_File_End .= "erase aBinary`r`n"
	If (InStr(All_Statements, "aStrMultiStr"))
		VBS_File_End .= "erase aStrMultiStr`r`n"
	
	SplitPath, _SourceFile, , FDir, ,FName
	
	FileDelete, %FDir%\%FName%.vbs
	FileAppend, % VBS_File_Start All_Statements VBS_File_End, %FDir%\%FName%.vbs, UTF-8-RAW
}

Compile_Key(_Key)
{
	StringReplace, _Key, _Key, `", `"`", A
	
	Return """" _Key """"
}

Compile_Container(_Container)
{
	If (_Container = "HKEY_CLASSES_ROOT")
		Return "HKCR"
	Else If (_Container = "HKEY_CURRENT_USER")
		Return "HKCU"
	Else If (_Container = "HKEY_LOCAL_MACHINE")
		Return "HKLM"
	Else If (_Container = "HKEY_USERS")
		Return "HKU"
	Else If (_Container = "HKEY_CURRENT_CONFIG")
		Return "HKCC"
}

Compile_CreateKey(_HKEY, _Key)
{
	Return "oReg.CreateKey " _HKEY ", " _Key "`r`n"
}

Extract_Name(_String)
{
	Loop, Parse, _String
	{
		If (Skip)
			Skip := False
		Else If (A_LoopField = "\")
			Skip := True
		Else If (A_LoopField = "=" And Last = """")
			Return SubStr(_String, 1, A_Index - 1)
		Else
			Last := A_LoopField
	}
}

Parse_Name(_String)
{
	_String := SubStr(_String, 2, StrLen(_String) - 2)
	
	Loop, Parse, _String
	{
		If (A_LoopField = "\" And !Skip)
			Skip := True
		Else
			Parsed_Name .= A_LoopField, Skip := False
	}
	
	Return Parsed_Name
}

Compile_Name(_Name)
{
	StringReplace, _Name, _Name, `", `"`", A
	
	Return """" _Name """"
}

Compile_Value(_Value, _Type)
{
	Global QWordErrors
	
	If (_Type = "REG_SZ"){
		If (StrLen(_Value) = 0) ;The string is blank
			Return """"""
		
		Loop, Parse, _Value
		{
			If (A_LoopField = "\" And !Skip)
				Skip := True
			Else
				Parsed_Value .= A_LoopField, Skip := False
		}
		
		StringReplace, _Value, Parsed_Value, `", `"`", A
		
		Return """" _Value """"
	} Else If (_Type = "REG_BINARY"){
		VarSetCapacity(N, 1, 0)
		
		Loop, Parse, _Value, CSV
		{
			NumPut("0x" A_LoopField, N, 0, "UChar")
			, N := NumGet(N, 0, "UChar")
			, New_Value .= New_Value = "" ? N : ", " N
		}
		
		Return "aBinary = Array(" New_Value ")"
	} Else If (_Type = "REG_DWORD"){
		VarSetCapacity(N, 4, 0)
		, NumPut("0x" _Value, N, 0, "UInt")
		
		Return NumGet(N, 0, "UInt")
	} Else If (_Type = "REG_QWORD"){
		VarSetCapacity(QWord, 8, 0)
		
		Loop, Parse, _Value, CSV
			NumPut("0x" A_LoopField, QWord, A_Index - 1, "Char")
		
		N := NumGet(QWord, 0, "Int64")
		
		If (N < 0){
			QWordErrors ++
			Return 922337203685477
		} Else
			Return N
	} Else If (_Type = "REG_MULTI_SZ" Or _Type = "REG_EXPAND_SZ"){
		If (StrLen(_Value) = 5){ ;The string is blank
			If (_Type = "REG_MULTI_SZ")
				Return "aStrMultiStr = Array()"
			Else
				Return """"""
		}
		
		VarSetCapacity(Data, (Ceil(StrLen(_Value) / 3) // 2) * 2, 0)
		
		Loop, Parse, _Value, CSV
			NumPut("0x" A_LoopField, Data, A_Index - 1, "Char")
		
		If (_Type = "REG_EXPAND_SZ"){
			VarSetCapacity(Data, -1)
			Return "" . Data . ""
		}
		
		I := (Ceil(StrLen(_Value) / 3) // 2) - 1
		
		String := """"
		
		Loop, % I
		{
			Value := NumGet(Data, (A_Index - 1) * 2, "UShort")
			
			If (Value)
				String .= Chr(Value)
			Else If (A_Index < I)
				String .= """, """
		}
		
		Return "aStrMultiStr = Array(" String """)"
	}
}

Compile_Statement(_HKEY, _Key, _Name, _Type, _Value)
{
	If (_Type = "REG_SZ"){
		Statement := "oReg.SetStringValue " _HKEY ", " _Key ", " _Name ", " _Value "`r`n"
	} Else If (_Type = "REG_BINARY"){
		Statement := _Value "`r`n"
		Statement .= "oReg.SetBinaryValue " _HKey ", " _Key ", " _Name ", aBinary`r`n"
	} Else If (_Type = "REG_DWORD"){
		Statement := "oReg.SetDWORDValue " _HKEY ", " _Key ", " _Name ", " _Value "`r`n"
	} Else If (_Type = "REG_QWORD"){
		Statement := "oReg.SetQWORDValue " _HKEY ", " _Key ", " _Name ", " _Value "`r`n"
	} Else If (_Type = "REG_MULTI_SZ"){
		Statement := _Value "`r`n"
		Statement .= "oReg.SetMultiStringValue " _HKEY ", " _Key ", " _Name ", aStrMultiStr`r`n"
	} Else If (_Type = "REG_EXPAND_SZ"){
		Statement .= "oReg.SetExpandedStringValue " _HKEY ", " _Key ", " _Name ", " _Value "`r`n"
	}
	
	Return Statement
}