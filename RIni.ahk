;Robert's INI library
;Version 1.7
#noenv	;Increases the speed of the library due to the large amount of dynamic variables.
SetBatchLines -1	;Increases the overall speed of the script.
;-1 : Error, INI format is wrong
;-2 : Error, Sec not found
;-3 : Error, Key not found
;-4 : Error, Invalid optional paramater
;-5 : Error, Sec already exists
;-6 : Error, Key already exists
;-9 : Error, Reference number is already set
;-10 : Error, Reference number is invalid
;-11 : Error, Unable to read ini file
;-12 : Error, Unable to write ini file
;-13 : Error, Unable to delete existing ini file
;-14 : Error, Unable to rename temp ini file
;-15 : Error, Ini already exists
;Full function list at bottom

RIni_Read(1, A_ScriptDir "\test.ini")
RIni_Write(1, A_ScriptDir "\out test.ini")


RIni_Create(RVar, Correct_Errors=1)
{
	Global

	If (RVar = "")
		Return -10
	If (RIni_%RVar%_Is_Set != "")
		Return -9
	If (Correct_Errors = 1)
		RIni_%RVar%_Fix_Errors := 1
	Else If (Correct_Errors != 0)
		Return -4
	RIni_%RVar%_Is_Set := 1
	, RIni_Unicode_Modifier := A_IsUnicode ? 2 : 1
	, RIni_%RVar%_Section_Number := 1
}


RIni_Shutdown(RVar)
{
	Global
	Local Sec

	If (RIni_%RVar%_Is_Set = "")
		Return -10
	If %RVar%_First_Comments
		VarSetCapacity(%RVar%_First_Comments, 0)
	Loop, % RIni_%RVar%_Section_Number
	{
		If (RIni_%RVar%_%A_Index% != ""){
			Sec := RIni_CalcMD5(RIni_%RVar%_%A_Index%)
			, VarSetCapacity(RIni_%RVar%_%A_Index%, 0)
			, VarSetCapacity(RIni_%RVar%_%Sec%_Number, 0)
			, VarSetCapacity(RIni_%RVar%_%Sec%_Is_Set, 0)
			If %RVar%_%Sec%_Lone_Line_Comments
				VarSetCapacity(%RVar%_%Sec%_Lone_Line_Comments, 0)
			If %RVar%_%Sec%_Comment
				VarSetCapacity(%RVar%_%Sec%_Comment, 0)
			If (%RVar%_All_%Sec%_Keys){
				Loop, Parse, %RVar%_All_%Sec%_Keys, `n
				{
					If A_Loopfield =
						Continue
					If (%RVar%_%Sec%_%A_LoopField%_Name != "")
						VarSetCapacity(%RVar%_%Sec%_%A_LoopField%_Name, 0)
					If (%RVar%_%Sec%_%A_LoopField%_Value != "")
						VarSetCapacity(%RVar%_%Sec%_%A_LoopField%_Value, 0)
					If %RVar%_%Sec%_%A_LoopField%_Comment
						VarSetCapacity(%RVar%_%Sec%_%A_LoopField%_Comment, 0)
				}
				VarSetCapacity(%RVar%_All_%Sec%_Keys, 0)
			}
		}
	}

	If RIni_%RVar%_Fix_Errors
		VarSetCapacity(RIni_%RVar%_Fix_Errors, 0)
	VarSetCapacity(RIni_%RVar%_Is_Set, 0)
	, VarSetCapacity(RIni_%RVar%_Section_Number, 0)
}


RIni_Read(RVar, File, Correct_Errors=1, Remove_Inline_Key_Comments=0, Remove_Lone_Line_Comments=0, Remove_Inline_Section_Comments=0, Treat_Duplicate_Sections=1, Treat_Duplicate_Keys=1, Read_Blank_Sections=1, Read_Blank_Keys=1, Trim_Spaces_From_Values=0, ByRef RIni_Read_Var = "")
{
	;Treat_Duplicate_Sections
	;1 - Skip
	;2 - Append
	;3 - Replace
	;4 - Add new keys
	;Treat_Duplicate_Keys
	;1 - Skip
	;2 - Append
	;3 - Replace
	Global
	Local Has_Equal, Sec, Key, P_1, P_2, Section_Skip, C_Pos, Section_Append, T_Sections, T_Section, E, T_LoopField, Errored_Lines, T_Value
	Local T_Section_Number, TSec, TKey, T_Section_Name

	If (RVar = "")
		Return -10
	If (RIni_%RVar%_Is_Set != "")
		Return -9

	If (RIni_Read_Var = "")
	{
		FileRead, RIni_Read_Var, %File%
		If Errorlevel
			Return -11
	}
	If (Correct_Errors = 1)
		RIni_%RVar%_Fix_Errors := 1
	Else If (Correct_Errors != 0)
		Return -4
	RIni_Unicode_Modifier := A_IsUnicode ? 2 : 1
	, RIni_%RVar%_Is_Set := 1
	, RIni_%RVar%_Section_Number := 1

	Loop, Parse, RIni_Read_Var, `n, `r
	{
		If A_LoopField =
			Continue
		T_LoopField = %A_LoopField%
		If (SubStr(T_Loopfield, 1, 1) = ";"){
			If !Section_Skip
			{
				If !Remove_Lone_Line_Comments
				{
					If Sec
						%RVar%_%Sec%_Lone_Line_Comments .= A_LoopField "`n"
					Else
						%RVar%_First_Comments .= A_LoopField "`n"
				}
			}
			Continue
		}
		Has_Equal := InStr(A_Loopfield, "=")
		If (!Has_Equal and InStr(A_LoopField, "[") and InStr(A_LoopField, "]")){
			Section_Skip := 0
			, Section_Append := 0
			, P_1 := InStr(A_LoopField, "[")
			, P_2 := Instr(A_LoopField, "]")
			, T_Section := Sec
			, T_Section_Name := TSec
			, TSec := SubStr(A_LoopField, P_1+1, P_2-P_1-1)
			, Sec := RIni_CalcMD5(TSec)

			If (T_Section)
				If (T_Section != Sec)
					If (!Read_Blank_Sections and !%RVar%_%T_Section%_Lone_Line_Comments and !%RVar%_%T_Section%_Comment and !%RVar%_All_%T_Section%_Keys)
						RIni_DeleteSection(RVar, T_Section_Name)

			If (RIni_%RVar%_%Sec%_Is_Set){
				If (Treat_Duplicate_Sections = 1)
					Section_Skip := 1
				Else If (Treat_Duplicate_Sections = 2){
					Section_Append := 1
					If InStr(A_LoopField, ";")
						If !Remove_Inline_Section_Comments
							%RVar%_%Sec%_Comment .= SubStr(A_Loopfield, P_2+1)
				} Else If (Treat_Duplicate_Sections = 3){
					If (E := RIni_DeleteSection(RVar, TSec))
						Return E
					RIni_AddSection(RVar, TSec)
					If InStr(A_LoopField, ";")
						If !Remove_Inline_Section_Comments
							%RVar%_%Sec%_Comment := SubStr(A_Loopfield, P_2+1)
				} Else If (Treat_Duplicate_Sections = 4)
					Section_Append := 2

				Continue
			} Else {
				If InStr(A_LoopField, ";")
					If !Remove_Inline_Section_Comments
						%RVar%_%Sec%_Comment := SubStr(A_Loopfield, P_2+1)

				RIni_AddSection(RVar, TSec)
			}
			Continue
		}
		If Has_Equal
		{
			If (!Sec)
			{
				If (RIni_%RVar%_Fix_Errors)
				{
					Errored_Lines .= (Errored_Lines = "" ? "" : ",") A_Index

					Continue
				}
				VarSetCapacity(RIni_%RVar%_Fix_Errors, 0)
				, VarSetCapacity(RIni_Unicode_Modifier, 0)
				, VarSetCapacity(RIni_%RVar%_Is_Set, 0)

				Return -1
			}
			If Section_Skip
				Continue
			TKey := SubStr(A_LoopField, 1, Has_Equal-1)
			, Key := RIni_CalcMD5(TKey)

			If (InStr("`n" %RVar%_All_%Sec%_Keys, "`n" Key "`n"))
			{
				If (Section_Append = 2)
					Continue
				Else If (Section_Append = 1){
					C_Pos := InStr(A_LoopField, ";")
					If (C_Pos){
						If !Remove_Inline_Key_Comments
							%RVar%_%Sec%_%Key%_Comment .= SubStr(A_LoopField, C_Pos)
						%RVar%_%Sec%_%Key%_Value .= SubStr(A_LoopField, Has_Equal+1, C_Pos-Has_Equal-1)
					} Else
						%RVar%_%Sec%_%Key%_Value .= SubStr(A_Loopfield, Has_Equal+1)
				} Else If (Treat_Duplicate_Keys = 1)
					Continue
				Else If (Treat_Duplicate_Keys = 2){
					C_Pos := InStr(A_LoopField, ";")
					If (C_Pos){
						If !Remove_Inline_Key_Comments
							%RVar%_%Sec%_%Key%_Comment .= SubStr(A_LoopField, C_Pos)
						%RVar%_%Sec%_%Key%_Value .= SubStr(A_LoopField, Has_Equal+1, C_Pos-Has_Equal-1)
					} Else
						%RVar%_%Sec%_%Key%_Value .= SubStr(A_Loopfield, Has_Equal+1)
				} Else If (Treat_Duplicate_Keys = 3){
					RIni_DeleteKey(RVar, TSec, TKey)
					, %RVar%_All_%Sec%_Keys .= Key "`n"
					, C_Pos := InStr(A_LoopField, ";")
					If (C_Pos){
						If !Remove_Inline_Key_Comments
							%RVar%_%Sec%_%Key%_Comment := SubStr(A_LoopField, C_Pos)
						%RVar%_%Sec%_%Key%_Value := SubStr(A_LoopField, Has_Equal+1, C_Pos-Has_Equal-1)
					} Else
						%RVar%_%Sec%_%Key%_Value := SubStr(A_Loopfield, Has_Equal+1)

					%RVar%_%Sec%_%Key%_Name := TKey
				}
				If (Trim_Spaces_From_Values)
					T_Value := %RVar%_%Sec%_%Key%_Value
					, %RVar%_%Sec%_%Key%_Value = %T_Value%
			} Else {
				C_Pos := InStr(A_LoopField, ";")
				If (C_Pos){
					If !Remove_Inline_Key_Comments
						%RVar%_%Sec%_%Key%_Comment := SubStr(A_LoopField, C_Pos)
					%RVar%_%Sec%_%Key%_Value := SubStr(A_LoopField, Has_Equal+1, C_Pos-Has_Equal-1)
				} Else {
					%RVar%_%Sec%_%Key%_Value := SubStr(A_Loopfield, Has_Equal+1)
					If (!Read_Blank_Keys and %RVar%_%Sec%_%Key%_Value != "")
						Continue
				}
				If (Trim_Spaces_From_Values)
					T_Value := %RVar%_%Sec%_%Key%_Value
					, %RVar%_%Sec%_%Key%_Value = %T_Value%

				%RVar%_All_%Sec%_Keys .= Key "`n"
				, %RVar%_%Sec%_%Key%_Name := TKey
			}
			Continue
		}
		If (RIni_%RVar%_Fix_Errors)
			Errored_Lines .= (Errored_Lines = "" ? "" : ",") A_Index
	}
	VarSetCapacity(RIni_Read_Var, 0)
	If Errored_Lines
		Return Errored_Lines
}


RIni_Write(RVar, File, Newline="`r`n", Write_Blank_Sections=1, Write_Blank_Keys=1, Space_Sections=1, Space_Keys=0, Remove_Valuewlines=1, Overwrite_If_Exists=1, Addwline_At_End=0)
{
	Global
	Local Write_Ini, Sec, Length, Temp_Write_Ini, T_Time, T_Section, T_Key, T_Value, T_Size, E, T_Write_Section

	If !RIni_%RVar%_Is_Set
		Return -10
	If (Newline != "`n" and Newline != "`r" and Newline != "`r`n" and Newline != "`n`r")
		Return -4

	T_Size := RIni_GetTotalSize(RVar, Newline)
	If (T_Size < 0)
		Return T_Size
	If Space_Sections
		T_Size += 1*1024*1024
	If Space_Keys
		T_Size += 1*1024*1024
	VarSetCapacity(Write_Ini, T_Size)
	If (%RVar%_First_Comments){
		Loop, parse, %RVar%_First_Comments, `n, `r
		{
			If A_LoopField =
				Continue
			Write_Ini .= A_LoopField Newline
		}
	}

	Loop, % RIni_%RVar%_Section_Number
	{
		If (RIni_%RVar%_%A_Index% != ""){
			If (T_Write_Section != ""){
				If Space_Sections
					Write_Ini .= Newline
			}
			T_Write_Section := RIni_%RVar%_%A_Index%
			T_Section := RIni_CalcMD5(T_Write_Section)

			If %RVar%_%T_Section%_Comment
				Write_Ini .= "[" T_Write_Section "]" %RVar%_%T_Section%_Comment Newline
			Else {
				If (!Write_Blank_Sections and !%RVar%_All_%T_Section%_Keys and !%RVar%_%T_Section%_Lone_Line_Comments)
					Continue
				Write_Ini .= "[" T_Write_Section "]" Newline
			}
			If (%RVar%_All_%T_Section%_Keys){
				Loop, Parse, %RVar%_All_%T_Section%_Keys, `n
				{
					If A_LoopField =
						Continue
					If (T_Key){
						If Space_Keys
							Write_Ini .= Newline
					}
					T_Key := %RVar%_%T_Section%_%A_LoopField%_Name
					T_Value := %RVar%_%T_Section%_%A_LoopField%_Value
					If (Remove_Valuewlines){
						If InStr(T_Value, "`n")
							StringReplace, T_Value, T_Value, `n, ,A
						If InStr(T_Value, "`r")
							StringReplace, T_Value, T_Value, `r, ,A
					}
					If %RVar%_%T_Section%_%A_LoopField%_Comment
						Write_Ini .= T_Key "=" T_Value %RVar%_%T_Section%_%A_LoopField%_Comment Newline
					Else {
						If (!Write_Blank_Keys and T_Value = "")
							Continue
						Write_Ini .= T_Key "=" T_Value Newline
					}
				}
			}
			If (%RVar%_%T_Section%_Lone_Line_Comments){
				Loop, parse, %RVar%_%T_Section%_Lone_Line_Comments, `n, `r
				{
					If A_LoopField =
						Continue
					Write_Ini .= A_LoopField Newline
				}
			}
		}
	}
	If (!Addwline_At_End and StrLen(Write_Ini) < (63 * 1024 * 1024))
		Write_Ini := SubStr(Write_Ini, 1, StrLen(Write_Ini)-StrLen(Newline))
	IfExist, %File%
	{
		If !Overwrite_If_Exists
			Return -15
		T_Time := A_Now
		If A_IsUnicode
			FileAppend, %Write_Ini%, %A_Temp%\%T_Time%.ini, UTF-8
		Else
			FileAppend, %Write_Ini%, %A_Temp%\%T_Time%.ini
		If ErrorLevel
			Return -12
		FileDelete, %File%
		If ErrorLevel
			Return -13
		FileMove, %A_Temp%\%T_Time%.ini, %File%
		If ErrorLevel
			Return -14
	} Else {
		If A_IsUnicode
			FileAppend, %Write_Ini%, %File%, UTF-8
		Else
			FileAppend, %Write_Ini%, %File%
		If ErrorLevel
			Return -12
	}
	Write_Ini := ""
}


RIni_AddSection(RVar, Sec)
{
	Global
	Local T_Section_Number, TSec

	If !RIni_%RVar%_Is_Set
		Return -10

	TSec := RIni_CalcMD5(Sec)
	If RIni_%RVar%_%TSec%_Is_Set
		Return -5
	RIni_%RVar%_%TSec%_Is_Set := 1
	T_Section_Number := RIni_%RVar%_Section_Number
	RIni_%RVar%_%TSec%_Number := T_Section_Number
	RIni_%RVar%_%T_Section_Number% := Sec
	RIni_%RVar%_Section_Number ++
}


RIni_AddKey(RVar, Sec, Key)
{
	Global
	Local E, TKey, TSec

	If !RIni_%RVar%_Is_Set
		Return -10
	TSec := Sec
	Sec := RIni_CalcMD5(TSec)
	If (!RIni_%RVar%_%Sec%_Is_Set){
		If !RIni_%RVar%_Fix_Errors
			Return -2
		RIni_AddSection(RVar, TSec)
	}
	TKey := Key
	Key := RIni_CalcMD5(TKey)
	If (InStr("`n" %RVar%_All_%Sec%_Keys, "`n" Key "`n"))
		Return -6
	%RVar%_All_%Sec%_Keys .= Key "`n"
	%RVar%_%Sec%_%Key%_Name := TKey
}


RIni_AppendValue(RVar, Sec, Key, Value, Trim_Spaces_From_Value=0, Removewlines=1)
{
	Global
	Static TSec, TKey, MD5Sec, MD5Key
	Local E

	If !RIni_%RVar%_Is_Set
		Return -10
	If (TSec != Sec)
		TSec := Sec
		, MD5Sec := RIni_CalcMD5(TSec)
	If (!RIni_%RVar%_%MD5Sec%_Is_Set){
		If !RIni_%RVar%_Fix_Errors
			Return -2
		RIni_AddSection(RVar, TSec)
	}
	If (TKey != Key)
		TKey := Key
		, MD5Key := RIni_CalcMD5(TKey)
	If (!InStr("`n" %RVar%_All_%MD5Sec%_Keys, "`n" MD5Key "`n")){
		If !RIni_%RVar%_Fix_Errors
			Return -3
		%RVar%_All_%MD5Sec%_Keys .= MD5Key "`n"
		%RVar%_%MD5Sec%_%MD5Key%_Name := TKey
	}
	If (Removewlines){
		If InStr(Value, "`n")
			StringReplace, Value, Value, `n, ,A
		If InStr(Value, "`r")
			StringReplace, Value, Value, `r, ,A
	}
	If Trim_Spaces_From_Value
		Value = %Value%
	%RVar%_%MD5Sec%_%MD5Key%_Value .= Value
}


RIni_ExpandSectionKeys(RVar, Sec, Amount=1)
{
	Global
	Local Temp_All_Section_Keys, Length, E, TSec

	If !RIni_%RVar%_Is_Set
		Return -10
	TSec := Sec
	Sec := RIni_CalcMD5(TSec)

	If (!RIni_%RVar%_%Sec%_Is_Set){
		If !RIni_%RVar%_Fix_Errors
			Return -2
		RIni_AddSection(RVar, TSec)
	}
	Length := StrLen(%RVar%_All_%Sec%_Keys)
	VarSetCapacity(Temp_All_Section_Keys, RIni_Unicode_Modifier*Length)
	Temp_All_Section_Keys .= %RVar%_All_%Sec%_Keys
	VarSetCapacity(%RVar%_All_%Sec%_Keys, Round(RIni_Unicode_Modifier*(Length+Amount*(1*1024*1024))))
	%RVar%_All_%Sec%_Keys .= Temp_All_Section_Keys
}


RIni_ContractSectionKeys(RVar, Sec)
{
	Global
	Local Temp_All_Section_Keys, Length

	Sec := RIni_CalcMD5(Sec)
	Length := StrLen(%RVar%_All_%Sec%_Keys)
	VarSetCapacity(Temp_All_Section_Keys, RIni_Unicode_Modifier*Length)
	Temp_All_Section_Keys .= %RVar%_All_%Sec%_Keys
	VarSetCapacity(%RVar%_All_%Sec%_Keys, 0)
	VarSetCapacity(%RVar%_All_%Sec%_Keys, RIni_Unicode_Modifier*Length)
	%RVar%_All_%Sec%_Keys .= Temp_All_Section_Keys
}


RIni_ExpandKeyValue(RVar, Sec, Key, Amount=1)
{
	Global
	Local Temp_Key_value, Length, E, TSec, TKey

	If !RIni_%RVar%_Is_Set
		Return -10
	TSec := Sec
	Sec := RIni_CalcMD5(TSec)

	If (!RIni_%RVar%_%Sec%_Is_Set){
		If !RIni_%RVar%_Fix_Errors
			Return -2
		RIni_AddSection(RVar, Sec)
	}
	TKey := Key
	Key := RIni_CalcMD5(TKey)

	If (!InStr("`n" %RVar%_All_%Sec%_Keys, "`n" Key "`n")){
		If !RIni_%RVar%_Fix_Errors
			Return -3
		%RVar%_All_%Sec%_Keys .= Key "`n"
		%RVar%_%Sec%_%Key%_Name := TKey
	}
	If (%RVar%_%Sec%_%Key%_Value = "")
		VarSetCapacity(%RVar%_%Sec%_%Key%_Value, Round(RIni_Unicode_Modifier*Amount*(1*1024*1024)))
	Else {
		Length := StrLen(%RVar%_%Sec%_%Key%_Value)
		VarSetCapacity(Temp_Key_value, RIni_Unicode_Modifier*Length)
		Temp_Key_value .= %RVar%_%Sec%_%Key%_Value
		varSetCapacity(%RVar%_%Sec%_%Key%_Value, Round(RIni_Unicode_Modifier*(Length+Amount*(1*1024*1024))))
		%RVar%_%Sec%_%Key%_Value .= Temp_Key_value
	}
}


RIni_ContractKeyValue(RVar, Sec, Key)
{
	Global
	Local Temp_Key_value, Length, TSec, TKey

	TSec := Sec
	Sec := RIni_CalcMD5(TSec)

	TKey := Key
	Key := RIni_CalcMD5(TKey)

	If (%RVar%_%Sec%_%Key%_Value = "")
		VarSetCapacity(%RVar%_%Sec%_%Key%_Value, 0)
	Else {
		Length := StrLen(%RVar%_%Sec%_%Key%_Value)
		VarSetCapacity(Temp_Key_value, RIni_Unicode_Modifier*Length)
		Temp_Key_value .= %RVar%_%Sec%_%Key%_Value
		VarSetCapacity(%RVar%_%Sec%_%Key%_Value, 0)
		varSetCapacity(%RVar%_%Sec%_%Key%_Value, RIni_Unicode_Modifier*Length)
		%RVar%_%Sec%_%Key%_Value .= Temp_Key_value
	}
}


RIni_SetKeyValue(RVar, Sec, Key, Value, Trim_Spaces_From_Value=0, Removewlines=1)
{
	Global
	Local E, TSec, TKey

	If !RIni_%RVar%_Is_Set
		Return -10
	TSec := Sec
	Sec := RIni_CalcMD5(TSec)

	If (!RIni_%RVar%_%Sec%_Is_Set){
		If !RIni_%RVar%_Fix_Errors
			Return -2
		RIni_AddSection(RVar, TSec)
	}
	TKey := Key
	Key := RIni_CalcMD5(TKey)

	If (!InStr("`n" %RVar%_All_%Sec%_Keys, "`n" Key "`n")){
		If !RIni_%RVar%_Fix_Errors
			Return -3
		%RVar%_All_%Sec%_Keys .= Key "`n"
		%RVar%_%Sec%_%Key%_Name := TKey
	}
	If (Removewlines){
		If InStr(Value, "`n")
			StringReplace, Value, Value, `n, ,A
		If InStr(Value, "`r")
			StringReplace, Value, Value, `r, ,A
	}
	If Trim_Spaces_From_Value
		Value = %Value%
	%RVar%_%Sec%_%Key%_Value := Value
}


RIni_DeleteSection(RVar, Sec)
{
	Global
	Local Position, T_Section_Number

	If !RIni_%RVar%_Is_Set
		Return -10
	Sec := RIni_CalcMD5(Sec)

	If (RIni_%RVar%_%Sec%_Is_Set){
		T_Section_Number := RIni_%RVar%_%Sec%_Number
		VarSetCapacity(RIni_%RVar%_%T_Section_Number%, 0)
		VarSetCapacity(RIni_%RVar%_%Sec%_Is_Set, 0)
		VarSetCapacity(RIni_%RVar%_%Sec%_Number, 0)
		If (%RVar%_All_%Sec%_Keys){
			Loop, Parse, %RVar%_All_%Sec%_Keys, `n
			{
				If A_LoopField =
					Continue
				VarSetCapacity(%RVar%_%Sec%_%A_LoopField%_Name, 0)
				If (%RVar%_%Sec%_%A_LoopField%_Value != "")
					VarSetCapacity(%RVar%_%Sec%_%A_LoopField%_Value, 0)
				If %RVar%_%Sec%_%A_LoopField%_Comment
					VarSetCapacity(%RVar%_%Sec%_%A_LoopField%_Comment, 0)
			}
			VarSetCapacity(%RVar%_All_%Sec%_Keys, 0)
		}
		If %RVar%_%Sec%_Comment
			VarSetCapacity(%RVar%_%Sec%_Comment, 0)
		If %RVar%_%Sec%_Lone_Line_Comments
			VarSetCapacity(%RVar%_%Sec%_Lone_Line_Comments, 0)
	} Else
		Return -2
}


RIni_DeleteKey(RVar, Sec, Key)
{
	Global
	Local Position, TSec, TKey

	If !RIni_%RVar%_Is_Set
		Return -10
	TSec := Sec
	Sec := RIni_CalcMD5(TSec)

	If !RIni_%RVar%_%Sec%_Is_Set
		Return -2
	TKey := Key
	Key := RIni_CalcMD5(TKey)

	If (%RVar%_All_%Sec%_Keys){
		If (Key = SubStr(%RVar%_All_%Sec%_Keys, 1, Instr(%RVar%_All_%Sec%_Keys, "`n")-1)){
			%RVar%_All_%Sec%_Keys := SubStr(%RVar%_All_%Sec%_Keys, InStr(%RVar%_All_%Sec%_Keys, "`n")+1)
		} Else {
			Position := InStr(%RVar%_All_%Sec%_Keys, "`n" Key "`n")
			If !Position
				Return -3
			%RVar%_All_%Sec%_Keys := SubStr(%RVar%_All_%Sec%_Keys, 1, Position) SubStr(%RVar%_All_%Sec%_Keys, Position+2+StrLen(Key))
			If Errorlevel
				Return -3
		}
		VarSetCapacity(%RVar%_%Sec%_%Key%_Name, 0)
		If (%RVar%_%Sec%_%Key%_Value != "")
			VarSetCapacity(%RVar%_%Sec%_%Key%_Value, 0)
		If %RVar%_%Sec%_%Key%_Comment
			VarSetCapacity(%RVar%_%Sec%_%Key%_Comment, 0)
	} Else
		Return -3
}



RIni_GetSections(RVar, Delimiter=",")
{
	Global
	Local T_Sections

	If !RIni_%RVar%_Is_Set
		Return -10
	Loop, % RIni_%RVar%_Section_Number
	{
		If (RIni_%RVar%_%A_Index%){
			If T_Sections
				T_Sections .= Delimiter RIni_%RVar%_%A_Index%
			Else
				T_Sections := RIni_%RVar%_%A_Index%
		}
	}
	Return T_Sections
}


RIni_GetSectionKeys(RVar, Sec, Delimiter=",")
{
	Global
	Local T_Section_Keys

	If !RIni_%RVar%_Is_Set
		Return -10
	Sec := RIni_CalcMD5(Sec)

	If !RIni_%RVar%_%Sec%_Is_Set
		Return -2
	If (%RVar%_All_%Sec%_Keys){
		Loop, Parse, %RVar%_All_%Sec%_Keys, `n
		{
			If A_LoopField =
				Continue
			T_Section_Keys .= (A_Index = 1 ? "" : Delimiter) %RVar%_%Sec%_%A_LoopField%_Name
		}

		Return T_Section_Keys
	}
}


RIni_GetKeyValue(RVar, Sec, Key, Default_Return="")
{
	Global

	If (!RIni_%RVar%_Is_Set)
		Return Default_Return = "" ? -10 : Default_Return
	Sec := RIni_CalcMD5(Sec)

	If !RIni_%RVar%_%Sec%_Is_Set
		Return Default_Return = "" ? -2 : Default_Return
	Key := RIni_CalcMD5(Key)

	If (%RVar%_All_%Sec%_Keys){
		If (!InStr("`n" %RVar%_All_%Sec%_Keys, "`n" Key "`n"))
			Return Default_Return = "" ? -3 : Default_Return
		If (%RVar%_%Sec%_%Key%_Value != "")
			Return %RVar%_%Sec%_%Key%_Value
		Else
			Return Default_Return
	} Else
		Return Default_Return = "" ? -3 : Default_Return
}


RIni_CopyKeys(From_RVar, To_RVar, From_Section, To_Section, Treat_Duplicate_Keys=2, Copy_Key_Values=1, Copy_Key_Comments=1, Copy_Blank_Keys=1)
{
	;Treat_Duplicate_? = 1 : Skip
	;Treat_Duplicate_? = 2 : Append
	;Treat_Duplicate_? = 3 : Replace
	Global
	Local E, TTo_Section

	If (From_RVar = "" Or !RIni_%From_RVar%_Is_Set)
		Return -10

	If (To_RVar = "")
		Return -10
	If (!RIni_%To_RVar%_Is_Set){
		If !RIni_%From_RVar%_Fix_Errors
			Return -10
		RIni_Create(To_RVar)
	}
	If (Treat_Duplicate_Keys != 1 and Treat_Duplicate_Keys != 2 and Treat_Duplicate_Keys != 3)
		Return -4
	From_Section := RIni_CalcMD5(From_Section)

	TTo_Section := To_Section
	To_Section := RIni_CalcMD5(TTo_Section)

	If !RIni_%From_RVar%_%From_Section%_Is_Set
		Return -2

	If (!RIni_%To_RVar%_%To_Section%_Is_Set){
		If !RIni_%To_RVar%_Fix_Errors
			Return -2
		RIni_AddSection(To_RVar, TTo_Section)
	}

	If (%From_RVar%_All_%From_Section%_Keys){
		Loop, Parse, %From_RVar%_All_%From_Section%_Keys, `n
		{
			If A_Loopfield =
				Continue
			If (!Copy_Blank_Keys and %From_RVar%_%From_Section%_%A_Loopfield%_Value != 0 and !%From_RVar%_%From_Section%_%A_Loopfield%_Value and !%From_RVar%_%From_Section%_%A_Loopfield%_Comment)
				Continue
			If (!InStr("`n" %To_RVar%_All_%To_Section%_Keys, "`n" A_LoopField "`n")){
				%To_RVar%_All_%To_Section%_Keys .= A_LoopField "`n"
				%To_RVar%_%To_Section%_%A_LoopField%_Name := %From_RVar%_%From_Section%_%A_LoopField%_Name
				If (%From_RVar%_%From_Section%_%A_Loopfield%_Value != "" and Copy_Key_Values)
					%To_RVar%_%To_Section%_%A_Loopfield%_Value := %From_RVar%_%From_Section%_%A_Loopfield%_Value
				If (%From_RVar%_%From_Section%_%A_Loopfield%_Comment and Copy_Key_Comments)
					%To_RVar%_%To_Section%_%A_Loopfield%_Comment := %From_RVar%_%From_Section%_%A_Loopfield%_Comment
			} Else {
				If (Treat_Duplicate_Keys = 1)
					Continue
				If (Treat_Duplicate_Keys = 2){
					If (%From_RVar%_%From_Section%_%A_Loopfield%_Value != "" and Copy_Key_Values)
						%To_RVar%_%To_Section%_%A_Loopfield%_Value .= %From_RVar%_%From_Section%_%A_Loopfield%_Value
					If (%From_RVar%_%From_Section%_%A_Loopfield%_Comment and Copy_Key_Comments)
						%To_RVar%_%To_Section%_%A_Loopfield%_Comment .= %From_RVar%_%From_Section%_%A_Loopfield%_Comment
				}
				If (Treat_Duplicate_Keys = 3){
					If (%From_RVar%_%From_Section%_%A_Loopfield%_Value != "" and Copy_Key_Values)
						%To_RVar%_%To_Section%_%A_Loopfield%_Value := %From_RVar%_%From_Section%_%A_Loopfield%_Value
					If (%From_RVar%_%From_Section%_%A_Loopfield%_Comment and Copy_Key_Comments)
						%To_RVar%_%To_Section%_%A_Loopfield%_Comment := %From_RVar%_%From_Section%_%A_Loopfield%_Comment
				}
			}
		}
	}
}


RIni_Merge(From_RVar, To_RVar, Treat_Duplicate_Sections=1, Treat_Duplicate_Keys=2, Merge_Blank_Sections=1, Merge_Blank_Keys=1)
{
	;Treat_Duplicate_? = 1 : Skip
	;Treat_Duplicate_? = 2 : Append
	;Treat_Duplicate_? = 3 : Replace
	Global
	Local From_Section, E, T_Section_Number, TFrom_Section

	If (From_RVar = "" Or !RIni_%From_RVar%_Is_Set)
		Return -10

	If (To_RVar = "")
		Return -10
	If (!RIni_%To_RVar%_Is_Set){
		If !RIni_%From_RVar%_Fix_Errors
			Return -10
		RIni_Create(To_RVar)
	}
	If (Treat_Duplicate_Sections != 1 and Treat_Duplicate_Sections != 2 and Treat_Duplicate_Sections != 3)
		Return -4
	If (Treat_Duplicate_Keys != 1 and Treat_Duplicate_Keys != 2 and Treat_Duplicate_Keys != 3)
		Return -4
	If %From_RVar%_First_Comments
		%To_RVar%_First_Comments .= %From_RVar%_First_Comments

	Loop, % RIni_%From_RVar%_Section_Number
	{
		If (RIni_%From_RVar%_%A_Index% != ""){
			TFrom_Section := RIni_%From_RVar%_%A_Index%
			From_Section := RIni_CalcMD5(TFrom_Section)

			If (!Merge_Blank_Sections and !%From_RVar%_%From_Section%_Lone_Line_Comments and !%From_RVar%_%From_Section%_Comment and !%From_RVar%_All_%From_Section%_Keys)
				Continue
			If (!RIni_%To_RVar%_%From_Section%_Is_Set){
				RIni_AddSection(To_RVar, TFrom_Section)

				If %From_RVar%_%From_Section%_Comment
					%To_RVar%_%From_Section%_Comment := %From_RVar%_%From_Section%_Comment
					If %From_RVar%_%From_Section%_Lone_Line_Comments
						%To_RVar%_%From_Section%_Lone_Line_Comments := %From_RVar%_%From_Section%_Lone_Line_Comments
				If (%From_RVar%_All_%From_Section%_Keys){
					Loop, Parse, %From_RVar%_All_%From_Section%_Keys, `n
					{
						If A_Loopfield =
							Continue

						If (!Merge_Blank_Keys and %From_RVar%_%From_Section%_%A_Loopfield%_Value = "" !%From_RVar%_%From_Section%_%A_LoopField%_Comment)
							Continue
						If (!InStr("`n" %To_RVar%_All_%From_Section%_Keys, "`n" A_LoopField "`n")){
							%To_RVar%_All_%From_Section%_Keys .= A_LoopField "`n"
							%To_RVar%_%From_Section%_%A_LoopField%_Name := %From_RVar%_%From_Section%_%A_Loopfield%_Name
							If (%From_RVar%_%From_Section%_%A_Loopfield%_Value != "")
								%To_RVar%_%From_Section%_%A_Loopfield%_Value := %From_RVar%_%From_Section%_%A_Loopfield%_Value
							If %From_RVar%_%From_Section%_%A_LoopField%_Comment
								%To_RVar%_%From_Section%_%A_LoopField%_Comment := %From_RVar%_%From_Section%_%A_LoopField%_Comment
						} Else {
							If (Treat_Duplicate_Keys = 1)
								Continue
							If (Treat_Duplicate_Keys = 2){
								If (%From_RVar%_%From_Section%_%A_Loopfield%_Value != "")
									%To_RVar%_%From_Section%_%A_Loopfield%_Value .= %From_RVar%_%From_Section%_%A_Loopfield%_Value
								If %From_RVar%_%From_Section%_%A_LoopField%_Comment
									%To_RVar%_%From_Section%_%A_LoopField%_Comment .= %From_RVar%_%From_Section%_%A_LoopField%_Comment
							}
							If (Treat_Duplicate_Keys = 3){
								If (%From_RVar%_%From_Section%_%A_Loopfield%_Value != "")
									%To_RVar%_%From_Section%_%A_Loopfield%_Value := %From_RVar%_%From_Section%_%A_Loopfield%_Value
								If %From_RVar%_%From_Section%_%A_LoopField%_Comment
									%To_RVar%_%From_Section%_%A_LoopField%_Comment := %From_RVar%_%From_Section%_%A_LoopField%_Comment
							}
						}
					}
				}
			} Else {
				If (Treat_Duplicate_Sections = 1)
						Continue
				If (Treat_Duplicate_Sections = 2){
					If %From_RVar%_%From_Section%_Comment
						%To_RVar%_%From_Section%_Comment .= %From_RVar%_%From_Section%_Comment
					If %From_RVar%_%From_Section%_Lone_Line_Comments
						%To_RVar%_%From_Section%_Lone_Line_Comments .= %From_RVar%_%From_Section%_Lone_Line_Comments
					If (%From_RVar%_All_%From_Section%_Keys){
						Loop, Parse, %From_RVar%_All_%From_Section%_Keys, `n
						{
							If A_Loopfield =
								Continue
							If (!Merge_Blank_Keys and %From_RVar%_%From_Section%_%A_Loopfield%_Value != 0 and !%From_RVar%_%From_Section%_%A_Loopfield%_Value and !%From_RVar%_%From_Section%_%A_LoopField%_Comment)
								Continue
							If (!InStr("`n" %To_RVar%_All_%From_Section%_Keys, "`n" A_LoopField "`n")){
								%To_RVar%_All_%From_Section%_Keys .= A_LoopField "`n"
								%To_RVar%_%From_Section%_%A_LoopField%_Name := %From_RVar%_%From_Section%_%A_Loopfield%_Name
								If (%From_RVar%_%From_Section%_%A_Loopfield%_Value != "")
									%To_RVar%_%From_Section%_%A_Loopfield%_Value := %From_RVar%_%From_Section%_%A_Loopfield%_Value
								If %From_RVar%_%From_Section%_%A_LoopField%_Comment
									%To_RVar%_%From_Section%_%A_LoopField%_Comment := %From_RVar%_%From_Section%_%A_LoopField%_Comment
							} Else {
								If (Treat_Duplicate_Keys = 1)
									Continue
								If (Treat_Duplicate_Keys = 2){
									If (%From_RVar%_%From_Section%_%A_Loopfield%_Value != "")
										%To_RVar%_%From_Section%_%A_Loopfield%_Value .= %From_RVar%_%From_Section%_%A_Loopfield%_Value
									If %From_RVar%_%From_Section%_%A_LoopField%_Comment
										%To_RVar%_%From_Section%_%A_LoopField%_Comment .= %From_RVar%_%From_Section%_%A_LoopField%_Comment
								}
								If (Treat_Duplicate_Keys = 3){
									If (%From_RVar%_%From_Section%_%A_Loopfield%_Value != "")
										%To_RVar%_%From_Section%_%A_Loopfield%_Value := %From_RVar%_%From_Section%_%A_Loopfield%_Value
									If %From_RVar%_%From_Section%_%A_LoopField%_Comment
										%To_RVar%_%From_Section%_%A_LoopField%_Comment := %From_RVar%_%From_Section%_%A_LoopField%_Comment
								}
							}
						}
					}
				}
				If (Treat_Duplicate_Sections = 3){
					If (E := RIni_DeleteSection(To_RVar, TFrom_Section))
						Return E
					RIni_AddSection(To_RVar, TFrom_Section)
					If %From_RVar%_%From_Section%_Comment
						%To_RVar%_%From_Section%_Comment := %From_RVar%_%From_Section%_Comment
					If %From_RVar%_%From_Section%_Lone_Line_Comments
						%To_RVar%_%From_Section%_Lone_Line_Comments := %From_RVar%_%From_Section%_Lone_Line_Comments
					If (%From_RVar%_All_%From_Section%_Keys){
						%To_RVar%_All_%From_Section%_Keys := %From_RVar%_All_%From_Section%_Keys
						Loop, Parse, %From_RVar%_All_%From_Section%_Keys, `n
						{
							If A_Loopfield =
								Continue
							If (!Merge_Blank_Keys and %From_RVar%_%From_Section%_%A_Loopfield%_Value = "" !%From_RVar%_%From_Section%_%A_LoopField%_Comment)
								Continue
							%To_RVar%_%From_Section%_%A_LoopField%_Name := %From_RVar%_%From_Section%_%A_Loopfield%_Name
							If (%From_RVar%_%From_Section%_%A_Loopfield%_Value != "")
								%To_RVar%_%From_Section%_%A_Loopfield%_Value := %From_RVar%_%From_Section%_%A_Loopfield%_Value
							If %From_RVar%_%From_Section%_%A_LoopField%_Comment
								%To_RVar%_%From_Section%_%A_LoopField%_Comment := %From_RVar%_%From_Section%_%A_LoopField%_Comment
						}
					}
				}
			}
		}
	}
}


RIni_ToVariable(RVar, ByRef Variable, Newline="`r`n", Add_Blank_Sections=1, Add_Blank_Keys=1, Space_Sections=0, Space_Keys=0, Remove_Valuewlines=1)
{
	Global
	Local Sec, Length, Key, Value, T_Section, TKey, T_Value

	If (!RIni_%RVar%_Is_Set)
		Return -10

	If (Newline != "`n" and Newline != "`r" and Newline != "`r`n" and Newline != "`n`r")
		Return -4
	If (%RVar%_First_Comments){
		Loop, parse, %RVar%_First_Comments, `n, `r
		{
			If A_LoopField =
				Continue
			Variable .= A_LoopField Newline
		}
	}

	Loop, % RIni_%RVar%_Section_Number
	{
		If (RIni_%RVar%_%A_Index% != ""){
			If (Sec){
				If Space_Sections
					Variable .= Newline
			}

			T_Section := RIni_%RVar%_%A_Index%
			Sec := RIni_CalcMD5(T_Section)

			If (%RVar%_%Sec%_Comment)
				Variable .= "[" T_Section "]" %RVar%_%Sec%_Comment Newline
			Else {
				If (!Add_Blank_Sections And !%RVar%_All_%Sec%_Keys And !%RVar%_%Sec%_Lone_Line_Comments)
					Continue
				Variable .= "[" T_Section "]" Newline
			}

			Loop, Parse, %RVar%_All_%Sec%_Keys, `n
			{
				If A_LoopField =
					Continue
				If (TKey){
					If Space_Keys
						Variable .= Newline
				}
				TKey := %RVar%_%Sec%_%A_LoopField%_Name

				T_Value := ""
				If (%RVar%_%Sec%_%A_LoopField%_Value != ""){
					T_Value := %RVar%_%Sec%_%A_LoopField%_Value
					If (Remove_Valuewlines){
						If InStr(T_Value, "`n")
							StringReplace, T_Value, T_Value, `n, ,A
						If InStr(T_Value, "`r")
							StringReplace, T_Value, T_Value, `r, ,A
					}
				}
				If %RVar%_%Sec%_%A_LoopField%_Comment
					Variable .= TKey "=" T_Value %RVar%_%Sec%_%A_LoopField%_Comment Newline
				Else {
					If (!Add_Blank_Keys and T_Value != "")
						Continue
					Variable .= TKey "=" T_Value Newline
				}
			}
			If (%RVar%_%Sec%_Lone_Line_Comments){
				Loop, parse, %RVar%_%Sec%_Lone_Line_Comments, `n, `r
				{
					If A_LoopField =
						Continue
					Variable .= A_LoopField Newline
				}
			}
		}
	}

	If StrLen(Variable) < (63 * 1024 * 1024)
		Variable := SubStr(Variable, 1, StrLen(Variable)-StrLen(Newline))
}


RIni_GetKeysValues(RVar, ByRef Values, Key, Delimiter=",", Default_Return="")
{
	Global
	Local T_Section

	If (!RIni_%RVar%_Is_Set)
		Return Default_Return = "" ? -10 : Default_Return
	Key := RIni_CalcMD5(Key)

	Loop, % RIni_%RVar%_Section_Number
	{
		If (RIni_%RVar%_%A_Index% != ""){
			T_Section := RIni_CalcMD5(RIni_%RVar%_%A_Index%)
			If (%RVar%_%T_Section%_%Key%_Value != "")
				Values .= (Values = "" ? "" : Delimiter) %RVar%_%T_Section%_%Key%_Value
		}
	}

	Return Values = "" ? Default_Return : Values
}


RIni_AppendTopComments(RVar, Comments)
{
	Global

	If (!RIni_%RVar%_Is_Set)
		Return -10
	If (InStr(Comments, "`n") or InStr(Comments, "`r")){
		Loop, parse, Comments, `n, `r
		{
			If A_LoopField =
				Continue
			%RVar%_First_Comments .= ";" A_LoopField "`n"
		}
	} Else
		%RVar%_First_Comments .= ";" Comments "`n"
}


RIni_SetTopComments(RVar, Comments)
{
	Global

	If (!RIni_%RVar%_Is_Set)
		Return -10
	If (InStr(Comments, "`n") or InStr(Comments, "`r")){
		%RVar%_First_Comments := ""
		Loop, parse, Comments, `n, `r
		{
			If A_LoopField =
				Continue
			%RVar%_First_Comments .= ";" A_LoopField "`n"
		}
	} Else
		%RVar%_First_Comments := ";" Comments "`n"
}


RIni_AppendSectionComment(RVar, Sec, Comment)
{
	Global
	Local TSec

	If (!RIni_%RVar%_Is_Set)
		Return -10
	TSec := Sec
	Sec := RIni_CalcMD5(TSec)

	If (!RIni_%RVar%_%Sec%_Is_Set){
		If !RIni_%RVar%_Fix_Errors
			Return -2
		RIni_AddSection(RVar, TSec)
	}
	If (InStr(Comment, "`n") or InStr(Comment, "`r")){
		Loop, parse, Comment, `n, `r
		{
			If A_LoopField =
				Continue
			If %RVar%_%Sec%_Comment
				%RVar%_%Sec%_Comment .= A_LoopField
			Else
				%RVar%_%Sec%_Comment .= ";" A_LoopField
		}
	} Else {
		If %RVar%_%Sec%_Comment
			%RVar%_%Sec%_Comment .= Comment
		Else
			%RVar%_%Sec%_Comment .= ";" Comment
	}
}


RIni_SetSectionComment(RVar, Sec, Comment)
{
	Global
	Local TSec

	If (!RIni_%RVar%_Is_Set)
		Return -10
	TSec := Sec
	Sec := RIni_CalcMD5(TSec)

	If (!RIni_%RVar%_%Sec%_Is_Set){
		If !RIni_%RVar%_Fix_Errors
			Return -2
		RIni_AddSection(RVar, TSec)
	}
	If (InStr(Comment, "`n") or InStr(Comment, "`r")){
		%RVar%_%Sec%_Comment := ""
		Loop, parse, Comment, `n, `r
		{
			If A_LoopField =
				Continue
			If %RVar%_%Sec%_Comment
				%RVar%_%Sec%_Comment .= A_LoopField
			Else
				%RVar%_%Sec%_Comment .= ";" A_LoopField
		}
	} Else
		%RVar%_%Sec%_Comment := ";" Comment
}


RIni_AppendSectionLLComments(RVar, Sec, Comments)
{
	Global
	Local TSec

	If (!RIni_%RVar%_Is_Set)
		Return -10
	TSec := Sec
	Sec := RIni_CalcMD5(TSec)

	If (!RIni_%RVar%_%Sec%_Is_Set){
		If !RIni_%RVar%_Fix_Errors
			Return -2
		RIni_AddSection(RVar, TSec)
	}
	If (InStr(Comments, "`n") or InStr(Comments, "`r")){
		Loop, parse, Comments, `n, `r
		{
			If A_LoopField =
				Continue
			If %RVar%_%Sec%_Lone_Line_Comments
				%RVar%_%Sec%_Lone_Line_Comments .= A_LoopField "`n"
			Else
				%RVar%_%Sec%_Lone_Line_Comments .= ";" A_LoopField "`n"
		}
	} Else {
		If %RVar%_%Sec%_Lone_Line_Comments
			%RVar%_%Sec%_Lone_Line_Comments .= Comments "`n"
		Else
			%RVar%_%Sec%_Lone_Line_Comments .= ";" Comments "`n"
	}
}


RIni_SetSectionLLComments(RVar, Sec, Comments)
{
	Global
	Local TSec

	If (!RIni_%RVar%_Is_Set)
		Return -10
	TSec := Sec
	Sec := RIni_CalcMD5(Sec)

	If (!RIni_%RVar%_%Sec%_Is_Set){
		If !RIni_%RVar%_Fix_Errors
			Return -2
		RIni_AddSection(RVar, TSec)
	}
	If (InStr(Comments, "`n") or InStr(Comments, "`r")){
		%RVar%_%Sec%_Lone_Line_Comments := ""
		Loop, parse, Comments, `n, `r
		{
			If A_LoopField =
				Continue
			If %RVar%_%Sec%_Lone_Line_Comments
				%RVar%_%Sec%_Lone_Line_Comments .= A_LoopField "`n"
			Else
				%RVar%_%Sec%_Lone_Line_Comments .= ";" A_LoopField "`n"
		}
	} Else
		%RVar%_%Sec%_Lone_Line_Comments := ";" Comments "`n"
}


RIni_AppendKeyComment(RVar, Sec, Key, Comment)
{
	Global
	Local TSec, TKey

	If (!RIni_%RVar%_Is_Set)
		Return -10
	TSec := Sec
	Sec := RIni_CalcMD5(Sec)

	If (!RIni_%RVar%_%Sec%_Is_Set){
		If !RIni_%RVar%_Fix_Errors
			Return -2
		RIni_AddSection(RVar, TSec)
	}
	TKey := Key
	Key := RIni_CalcMD5(TKey)

	If (!InStr("`n" %RVar%_All_%Sec%_Keys, "`n" Key "`n")){
		If !RIni_%RVar%_Fix_Errors
			Return -3
		%RVar%_All_%Sec%_Keys .= Key "`n"
		%RVar%_%Sec%_%Key%_Name := TKey
	}
	If (InStr(Comment, "`n") or InStr(Comment, "`r")){
		Loop, parse, Comment, `n, `r
		{
			If A_LoopField =
				Continue
			If %RVar%_%Sec%_%Key%_Comment
				%RVar%_%Sec%_%Key%_Comment .= A_LoopField
			Else
				%RVar%_%Sec%_%Key%_Comment .= ";" A_LoopField
		}
	} Else {
		If %RVar%_%Sec%_%Key%_Comment
			%RVar%_%Sec%_%Key%_Comment .= Comment
		Else
			%RVar%_%Sec%_%Key%_Comment .= ";" Comment
	}
}


RIni_SetKeyComment(RVar, Sec, Key, Comment)
{
	Global
	Local TSec, TKey
	If (!RIni_%RVar%_Is_Set)
		Return -10
	TSec := Sec
	Sec := RIni_CalcMD5(TSec)

	If (!RIni_%RVar%_%Sec%_Is_Set){
		If !RIni_%RVar%_Fix_Errors
			Return -2
		RIni_AddSection(RVar, TSec)
	}
	TKey := Key
	Key := RIni_CalcMD5(TKey)

	If (!InStr("`n" %RVar%_All_%Sec%_Keys, "`n" Key "`n")){
		If !RIni_%RVar%_Fix_Errors
			Return -3
		%RVar%_All_%Sec%_Keys .= Key "`n"
		%RVar%_%Sec%_%Key%_Name := TKey
	}
	If (InStr(Comment, "`n") or InStr(Comment, "`r")){
		%RVar%_%Sec%_%Key%_Comment := ""
		Loop, parse, Comment, `n, `r
		{
			If A_LoopField =
				Continue
			If %RVar%_%Sec%_%Key%_Comment
				%RVar%_%Sec%_%Key%_Comment .= A_LoopField
			Else
				%RVar%_%Sec%_%Key%_Comment .= ";" A_LoopField
		}
	} Else
		%RVar%_%Sec%_%Key%_Comment := ";" Comment
}


RIni_GetTopComments(RVar, Delimiter="`r`n", Default_Return="")
{
	Global
	Local To_Return

	If (!RIni_%RVar%_Is_Set)
		Return Default_Return = "" ? -10 : Default_Return
	If (%RVar%_First_Comments){
		Loop, parse, %RVar%_First_Comments, `n, `r
		{
			If A_Loopfield =
				Continue
			If To_Return
				To_Return .= Delimiter A_LoopField
			Else
				To_Return := A_LoopField
		}
		Return To_Return = "" ? Default_Return : To_Return
	}
}


RIni_GetSectionComment(RVar, Sec, Default_Return="")
{
	Global

	If (!RIni_%RVar%_Is_Set)
		Return Default_Return = "" ? -10 : Default_Return
	Sec := RIni_CalcMD5(Sec)

	If !RIni_%RVar%_%Sec%_Is_Set
		Return Default_Return = "" ? -2 : Default_Return
	If %RVar%_%Sec%_Comment
		Return %RVar%_%Sec%_Comment
	Else
		Return Default_Return
}


RIni_GetSectionLLComments(RVar, Sec, Delimiter="`r`n", Default_Return="")
{
	Global
	Local To_Return

	If (!RIni_%RVar%_Is_Set)
		Return Default_Return = "" ? -10 : Default_Return
	Sec := RIni_CalcMD5(Sec)

	If !RIni_%RVar%_%Sec%_Is_Set
		Return Default_Return = "" ? -2 : Default_Return
	If (%RVar%_%Sec%_Lone_Line_Comments){
		Loop, parse, %RVar%_%Sec%_Lone_Line_Comments, `n, `r
		{
			If A_Loopfield =
				Continue
			If To_Return
				To_Return .= Delimiter A_LoopField
			Else
				To_Return := A_LoopField
		}
		Return Default_Return = "" ? To_Return : Default_Return
	} Else
		Return Default_Return
}


RIni_GetKeyComment(RVar, Sec, Key, Default_Return="")
{
	Global

	If (!RIni_%RVar%_Is_Set)
		Return Default_Return = "" ? -10 : Default_Return
	Sec := RIni_CalcMD5(Sec)

	If !RIni_%RVar%_%Sec%_Is_Set
		Return Default_Return = "" ? -2 : Default_Return
	Key := RIni_CalcMD5(Key)

	If (%RVar%_All_%Sec%_Keys){
		If (!InStr("`n" %RVar%_All_%Sec%_Keys, "`n" Key "`n"))
			Return Default_Return = "" ? -3 : Default_Return
		If %RVar%_%Sec%_%Key%_Comment
			Return %RVar%_%Sec%_%Key%_Comment
		Else
			Return Default_Return
	} Else
		Return Default_Return = "" ? -3 : Default_Return
}


RIni_GetTotalSize(RVar, Newline="`r`n", Default_Return="")
{
	Global
	Local Total_Size = 0, Sec, T_Section, T_Key, Newline_Length

	If (!RIni_%RVar%_Is_Set)
		Return Default_Return = "" ? -10 : Default_Return
	Newline_Length := StrLen(Newline)
	If (%RVar%_First_Comments){
		Loop, parse, %RVar%_First_Comments, `n, `r
		{
			If A_LoopField =
				Continue
			Total_Size += StrLen(A_LoopField) + Newline_Length
		}
	}

	Loop, % RIni_%RVar%_Section_Number
	{
		If (RIni_%RVar%_%A_Index% != ""){
			T_Section := RIni_%RVar%_%A_Index%
			Sec := RIni_CalcMD5(T_Section)

			If %RVar%_%Sec%_Comment
				Total_Size += 2 + StrLen(T_Section) + StrLen(%RVar%_%Sec%_Comment) + Newline_Length
			Else
				Total_Size += 2 + StrLen(T_Section) + Newline_Length

			If (%RVar%_All_%Sec%_Keys){
				Loop, Parse, %RVar%_All_%Sec%_Keys, `n
				{
					If A_LoopField =
						Continue

					Total_Size += StrLen(%RVar%_%Sec%_%A_LoopField%_Name) + 1 + Newline_Length
					If (%RVar%_%Sec%_%A_LoopField%_Value != "")
						Total_Size += StrLen(%RVar%_%Sec%_%A_LoopField%_Value)
					If %RVar%_%Sec%_%A_LoopField%_Comment
						Total_Size += StrLen(%RVar%_%Sec%_%A_LoopField%_Comment)
				}
			}
			If (%RVar%_%A_LoopField%_Lone_Line_Comments){
				Loop, parse, %RVar%_%A_LoopField%_Lone_Line_Comments, `n, `r
				{
					If A_LoopField =
						Continue
					Total_Size += StrLen(A_LoopField) + Newline_Length
				}
			}
		}
	}

	If (Total_Size = "")
		Total_Size = 0
	Return RIni_Unicode_Modifier * Total_Size
}


RIni_GetSectionSize(RVar, Sec, Newline="`r`n", Default_Return="")
{
	Global
	Local Total_Size = 0, TSec, T_Key, Newline_Length

	If (!RIni_%RVar%_Is_Set)
		Return Default_Return = "" ? -10 : Default_Return
	Newline_Length := StrLen(Newline)
	TSec := Sec
	Sec := RIni_CalcMD5(Sec)

	If !RIni_%RVar%_%Sec%_Is_Set
		Return Default_Return = "" ? -2 : Default_Return

	If %RVar%_%Sec%_Comment
		Total_Size += 2 + StrLen(TSec) + StrLen(%RVar%_%Sec%_Comment) + Newline_Length
	Else
		Total_Size += 2 + StrLen(TSec) + Newline_Length
	If (%RVar%_All_%Sec%_Keys){
		Loop, Parse, %RVar%_All_%Sec%_Keys, `n
		{
			If A_LoopField =
				Continue

			Total_Size += StrLen(%RVar%_%Sec%_%A_LoopField%_Name) + 1 + Newline_Length
			If (%RVar%_%Sec%_%A_LoopField%_Value != "")
				Total_Size += StrLen(%RVar%_%Sec%_%A_LoopField%_Value)
			If %RVar%_%Sec%_%A_LoopField%_Comment
				Total_Size += StrLen(%RVar%_%Sec%_%A_LoopField%_Comment)
		}
	}
	If (%RVar%_%Sec%_Lone_Line_Comments){
		Loop, parse, %RVar%_%Sec%_Lone_Line_Comments, `n, `r
		{
			If A_LoopField =
				Continue
			Total_Size += StrLen(A_LoopField) + Newline_Length
		}
	}
	If (Total_Size = "")
		Total_Size = 0
	Return RIni_Unicode_Modifier * Total_Size
}


RIni_GetKeySize(RVar, Sec, Key, Newline="`r`n", Default_Return="")
{
	Global
	Local Total_Size, TKey, Newline_Length, TSec
	RVar = %RVar%
	If (!RIni_%RVar%_Is_Set)
		Return Default_Return = "" ? -10 : Default_Return
	Newline_Length := StrLen(Newline)
	TSec := Sec
	Sec := RIni_CalcMD5(Sec)

	If !RIni_%RVar%_%Sec%_Is_Set
		Return Default_Return = "" ? -2 : Default_Return

	If (%RVar%_All_%Sec%_Keys){
		TKey := Key
		Key := RIni_CalcMD5(TKey)

		If (!InStr("`n" %RVar%_All_%Sec%_Keys, "`n" Key "`n"))
			Return Default_Return = "" ? -3 : Default_Return

		Total_Size += StrLen(TKey) + 1 + Newline_Length
		If (%RVar%_%Sec%_%Key%_Value != "")
			Total_Size += StrLen(%RVar%_%Sec%_%Key%_Value)
		If %RVar%_%Sec%_%Key%_Comment
			Total_Size += StrLen(%RVar%_%Sec%_%Key%_Comment)
		Return RIni_Unicode_Modifier * Total_Size
	} Else
		Return Default_Return = "" ? -3 : Default_Return
}


RIni_VariableToRIni(RVar, ByRef Variable, Correct_Errors=1, Remove_Inline_Key_Comments=0, Remove_Lone_Line_Comments=0, Remove_Inline_Section_Comments=0, Treat_Duplicate_Sections=1, Treat_Duplicate_Keys=1, Read_Blank_Sections=1, Read_Blank_Keys=1, Trim_Spaces_From_Values=0)
{
	Return RIni_Read(RVar, File, Correct_Errors, Remove_Inline_Key_Comments, Remove_Lone_Line_Comments, Remove_Inline_Section_Comments, Treat_Duplicate_Sections, Treat_Duplicate_Keys, Read_Blank_Sections, Read_Blank_Keys, Trim_Spaces_From_Values, Variable)
}


RIni_CopySectionNames(From_RVar, To_RVar, Treat_Duplicate_Sections=1, CopySection_Comments=1, Copy_Blank_Sections=1)
{
	;Treat_Duplicate_Sections
	;1 - Skip
	;2 - Replace
	Global
	Local E, TSec, Sec

	If (From_RVar = "" Or !RIni_%From_RVar%_Is_Set)
		Return -10

	If (To_RVar = "")
		Return -10
	If (!RIni_%To_RVar%_Is_Set){
		If !RIni_%From_RVar%_Fix_Errors
			Return -10
		RIni_Create(To_RVar)
	}

	Loop, % RIni_%From_RVar%_Section_Number
	{
		If (RIni_%From_RVar%_%A_Index% != ""){
			TSec := RIni_%From_RVar%_%A_Index%
			Sec := RIni_CalcMD5(TSec)

			If (!Copy_Blank_Sections and !%From_RVar%_%Sec%_Lone_Line_Comments and !%From_RVar%_%Sec%_Comment and !%From_RVar%_All_%Sec%_Keys)
				Continue
			If (RIni_%To_RVar%_%Sec%_Is_Set){
				If (Treat_Duplicate_Sections = 1)
					Continue
				Else If (Treat_Duplicate_Sections = 2) {
					If (E := RIni_DeleteSection(To_RVar, TSec))
						Return E

					RIni_AddSection(To_RVar, TSec)
					If (CopySection_Comments){
						If %From_RVar%_%Sec%_Lone_Line_Comments
							%To_RVar%_%Sec%_Lone_Line_Comments := %From_RVar%_%Sec%_Lone_Line_Comments
						If %From_RVar%_%Sec%_Comment
							%To_RVar%_%Sec%_Comment := %From_RVar%_%Sec%_Comment
					}
				}
			} Else {
				RIni_AddSection(To_RVar, TSec)
				If (CopySection_Comments){
					If %From_RVar%_%Sec%_Lone_Line_Comments
						%To_RVar%_%Sec%_Lone_Line_Comments := %From_RVar%_%Sec%_Lone_Line_Comments
					If %From_RVar%_%Sec%_Comment
						%To_RVar%_%Sec%_Comment := %From_RVar%_%Sec%_Comment
				}
			}
		}
	}
}


RIni_CopySection(From_RVar, To_RVar, From_Section, To_Section, Copy_Lone_Line_Comments=1, CopySection_Comment=1, Copy_Key_Values=1, Copy_Key_Comments=1, Copy_Blank_Keys=1)
{
	;Treat_Duplicate_? = 1 : Skip
	;Treat_Duplicate_? = 2 : Append
	;Treat_Duplicate_? = 3 : Replace
	Global
	Local TSec, Sec, TFrom_Section, TTo_Section

	If (From_RVar = "" Or !RIni_%From_RVar%_Is_Set)
		Return -10

	If (To_RVar = "")
		Return -10
	If (!RIni_%To_RVar%_Is_Set){
		If !RIni_%From_RVar%_Fix_Errors
			Return -10
		RIni_Create(To_RVar)
	}
	TFrom_Section := From_Section
	From_Section := RIni_CalcMD5(TFrom_Section)

	TTo_Section := To_Section
	To_Section := RIni_CalcMD5(TTo_Section)

	If !RIni_%From_RVar%_%From_Section%_Is_Set
		Return -2

	If !RIni_%To_RVar%_%To_Section%_Is_Set
		RIni_AddSection(To_RVar, TTo_Section)
	Else
		Return -5

	If (Copy_Lone_Line_Comments and %From_RVar%_%From_Section%_Lone_Line_Comments)
		%From_RVar%_%To_Section%_Lone_Line_Comments := %From_RVar%_%From_Section%_Lone_Line_Comments
	If (CopySection_Comment and %From_RVar%_%From_Section%_Comment)
		%From_RVar%_%To_Section%_Comment := %From_RVar%_%From_Section%_Comment

	If (%From_RVar%_All_%From_Section%_Keys){
		Loop, Parse, %From_RVar%_All_%From_Section%_Keys, `n
		{
			If A_Loopfield =
				Continue
			If (!Copy_Blank_Keys and %From_RVar%_%From_Section%_%A_Loopfield%_Value = "" and !%From_RVar%_%From_Section%_%A_Loopfield%_Comment)
				Continue
			If (%From_RVar%_%From_Section%_%A_Loopfield%_Value != "" and Copy_Key_Values)
				%To_RVar%_%To_Section%_%A_Loopfield%_Value := %From_RVar%_%From_Section%_%A_Loopfield%_Value
			If (%From_RVar%_%From_Section%_%A_Loopfield%_Comment and Copy_Key_Comments)
				%To_RVar%_%To_Section%_%A_Loopfield%_Comment := %From_RVar%_%From_Section%_%A_Loopfield%_Comment
			%To_RVar%_All_%To_Section%_Keys .= A_Loopfield "`n"
			%To_RVar%_%To_Section%_%A_LoopField%_Name := %From_RVar%_%From_Section%_%A_LoopField%_Name
		}
	}
}


RIni_CloneKey(From_RVar, To_RVar, From_Section, To_Section, From_Key, To_Key)
{
	Global
	Local TTo_Section

	If (From_RVar = "" Or !RIni_%From_RVar%_Is_Set)
		Return -10

	If (To_RVar = "")
		Return -10
	If (!RIni_%To_RVar%_Is_Set){
		If !RIni_%From_RVar%_Fix_Errors
			Return -10
		RIni_Create(To_RVar)
	}
	From_Section := RIni_CalcMD5(From_Section)

	If !RIni_%From_RVar%_%From_Section%_Is_Set
		Return -2
	From_Key := RIni_CalcMD5(From_Key)

	If (!InStr("`n" %From_RVar%_All_%From_Section%_Keys, "`n" From_Key "`n"))
		Return -3

	TTo_Section := To_Section
	To_Section := RIni_CalcMD5(TTo_Section)

	If (!RIni_%To_RVar%_%To_Section%_Is_Set){
		If !RIni_%To_RVar%_Fix_Errors
			Return -2
		RIni_AddSection(To_RVar, TTo_Section)
	}

	To_Key := RIni_CalcMD5(To_Key)

	If (InStr("`n" %To_RVar%_All_%To_section%_Keys, "`n" To_Key "`n"))
		Return -6
	%To_RVar%_All_%To_section%_Keys .= To_Key "`n"
	%To_RVar%_%To_Section%_%To_Key%_Name := %From_RVar%_%From_Section%_%From_Key%_Name
	If (%From_RVar%_%From_Section%_%From_Key%_Value != ""){
		%To_RVar%_%To_Section%_%To_Key%_Value := %From_RVar%_%From_Section%_%From_Key%_Value
	}
	If (%From_RVar%_%From_Section%_%From_Key%_Comment){
		%To_RVar%_%To_Section%_%To_Key%_Comment := %From_RVar%_%From_Section%_%From_Key%_Comment
	}
}


RIni_RenameSection(RVar, From_Section, To_Section)
{
	Global
	Local E, TFrom_Section, TTo_Section

	If !RIni_%RVar%_Is_Set
		Return -10
	TFrom_Section := From_Section
	, From_Section := RIni_CalcMD5(TFrom_Section)

	If !RIni_%RVar%_%From_Section%_Is_Set
		Return -2

	TTo_Section := To_Section
	, To_Section := RIni_CalcMD5(TTo_Section)

	If RIni_%RVar%_%To_Section%_Is_Set
		Return -5
	RIni_AddSection(RVar, TTo_section)
	If %RVar%_%From_Section%_Comment
		%RVar%_%to_Section%_Comment := %RVar%_%From_Section%_Comment
	If %RVar%_%From_Section%_Lone_Line_Comments
		%RVar%_%to_Section%_Lone_Line_Comments := %RVar%_%From_Section%_Lone_Line_Comments
	If (%RVar%_All_%From_Section%_Keys){
		Loop, Parse, %RVar%_All_%From_Section%_Keys, `n
		{
			%RVar%_All_%To_section%_Keys .= A_LoopField "`n"
			%RVar%_%To_Section%_%A_LoopField%_Name := %RVar%_%From_Section%_%A_LoopField%_Name
			If (%RVar%_%From_Section%_%A_LoopField%_Value != "")
				%RVar%_%To_Section%_%A_LoopField%_Value := %RVar%_%From_Section%_%A_LoopField%_Value
			If %RVar%_%From_Section%_%A_LoopField%_Comment
				%RVar%_%To_Section%_%A_LoopField%_Comment := %RVar%_%From_Section%_%A_LoopField%_Comment
		}
	}
	If (E := RIni_DeleteSection(RVar, TFrom_Section))
		Return E
}


RIni_RenameKey(RVar, Sec, From_Key, To_Key)
{
	Global
	Local E, TSec, TFrom_Key

	If !RIni_%RVar%_Is_Set
		Return -10
	TSec := Sec
	, Sec := RIni_CalcMD5(TSec)

	If !RIni_%RVar%_%Sec%_Is_Set
		Return -2
	TFrom_Key := From_Key
	, From_Key := RIni_CalcMD5(TFrom_Key)

	If (!InStr("`n" %RVar%_All_%Sec%_Keys, "`n" From_Key "`n"))
		Return -3

	To_Key := RIni_CalcMD5(To_Key)

	If (InStr("`n" %RVar%_All_%Sec%_Keys, "`n" To_Key "`n"))
		Return -6
	%RVar%_All_%Sec%_Keys .= To_Key "`n"
	, %RVar%_%Sec%_%To_Key%_Name := %RVar%_%Sec%_%From_Key%_Name
	If (%RVar%_%Sec%_%From_Key%_Value != "")
		%RVar%_%Sec%_%To_Key%_Value := %RVar%_%Sec%_%From_Key%_Value
	If %RVar%_%Sec%_%From_Key%_Comment
		%RVar%_%Sec%_%To_Key%_Comment := %RVar%_%Sec%_%From_Key%_Comment
	If (E := RIni_DeleteKey(RVar, TSec, TFrom_Key))
		Return E
}


RIni_SortSections(RVar, Sort_Type="")
{
	Global
	Local T_Sections, T_Section_Number, Sec

	If !RIni_%RVar%_Is_Set
		Return -10
	VarSetCapacity(T_Sections, RIni_Unicode_Modifier*32*1024*1024)
	Loop, % RIni_%RVar%_Section_Number
	{
		If (RIni_%RVar%_%A_Index% != ""){
			T_Section_Number := RIni_%RVar%_%A_Index%
			, Sec := RIni_CalcMD5(RIni_%RVar%_%A_Index%)
			, T_Sections .= T_Section_Number "`n"
			, VarSetCapacity(RIni_%RVar%_%A_Index%, 0)
			, VarSetCapacity(RIni_%RVar%_%Sec%_Is_Set, 0)
			, VarSetCapacity(RIni_%RVar%_%Sec%_Number, 0)
		}
	}
	If (T_Sections){
		RIni_%RVar%_Section_Number := 1
		Sort, T_Sections, % Sort_Type
		Loop, Parse, T_Sections, `n
		{
			If A_LoopField =
				Continue
			Sec := RIni_CalcMD5(A_LoopField)
			, RIni_%RVar%_%Sec%_Is_Set := 1
			, T_Section_Number := RIni_%RVar%_Section_Number
			, RIni_%RVar%_%Sec%_Number := T_Section_Number
			, RIni_%RVar%_%T_Section_Number% := A_LoopField
			, RIni_%RVar%_Section_Number ++
		}
	}
}

RIni_SortKeys(RVar, Sec, Sort_Type="")
{
	Global

	If !RIni_%RVar%_Is_Set
		Return -10
	Sec := RIni_CalcMD5(Sec)

	If !%RVar%_All_%Sec%_Keys
		Return -2
	Sort, %RVar%_All_%Sec%_Keys, % Sort_Type
}


RIni_AddSectionsAsKeys(RVar, To_Section, Include_To_Section=0, Convert_Comments=1, Treat_Duplicate_Keys=1, Blank_Key_Values_On_Replace=1)
{
	;Treat_Duplicate_Keys
	;1 - Skip
	;2 - Append
	;3 - Replace
	Global
	Local T_Section, TTo_Section

	If !RIni_%RVar%_Is_Set
		Return -10
	TTo_Section := To_Section
	To_Section := RIni_CalcMD5(TTo_Section)

	If (!RIni_%RVar%_%To_Section%_Is_Set){
		If !RIni_%RVar%_Fix_Errors
			Return -2
		RIni_AddSection(RVar, TTo_Section)
	}

	Loop, % RIni_%RVar%_Section_Number
	{
		If (RIni_%RVar%_%A_Index% != ""){
			T_Section := RIni_CalcMD5(RIni_%RVar%_%A_Index%)
			If (!Include_To_Section and T_Section = To_Section)
				Continue
			If (InStr("`n" %RVar%_All_%To_Section%_Keys, "`n" T_Section "`n")){
				If (Treat_Duplicate_Keys = 1){
					Continue
				} Else If (Treat_duplicate_Keys = 2){
					If (Convert_Comments and %RVar%_%T_Section%_Comment)
						%RVar%_%To_Section%_%T_Section%_Comment .= %RVar%_%T_Section%_Comment
				} Else if (Treat_duplicate_Keys = 3){
					If (Convert_Comments){
						If %RVar%_%T_Section%_Comment
							%RVar%_%To_Section%_%T_Section%_Comment := %RVar%_%T_Section%_Comment
						Else if %RVar%_%To_Section%_%T_Section%_Comment
							%RVar%_%To_Section%_%T_Section%_Comment := ""
					}
					If (Blank_Key_Values_On_Replace and %RVar%_%To_Section%_%T_Section%_Value != "")
						%RVar%_%To_Section%_%T_Section%_Value := ""
				}
			} Else {
				%RVar%_All_%To_Section%_Keys .= T_Section "`n"
				%RVar%_%To_Section%_%T_Section%_Name := RIni_%RVar%_%A_Index%
				If %RVar%_%T_Section%_Comment
					%RVar%_%To_Section%_%T_Section%_Comment := %RVar%_%T_Section%_Comment
			}
		}
	}
}


RIni_AddKeysAsSections(RVar, From_Section, Include_From_Section=0, Treat_Duplicate_Sections=1, Convert_Comments=1, Blank_Sections_On_Replace=1)
{
	;Treat_Duplicate_Sections
	;1 - Skip
	;2 - Append
	;3 - Replace
	Global
	Local T_Section, TFrom_Section

	If !RIni_%RVar%_Is_Set
		Return -10
	TFrom_Section := From_Section
	From_Section := RIni_CalcMD5(TFrom_Section)

	If !RIni_%RVar%_%From_Section%_Is_Set
		Return -2
	If !%RVar%_All_%From_Section%_Keys
		Return -3
	Loop, Parse, %RVar%_All_%From_Section%_Keys, `n
	{
		If (A_LoopField = "" or A_LoopField = From_Section)
			Continue

		If (RIni_%RVar%_%A_LoopField%_Is_Set){
			If (Treat_Duplicate_Sections = 1)
				Continue
			Else If (Treat_Duplicate_Sections = 2){
				If (Convert_Comments and %RVar%_%From_Section%_%A_LoopField%_Comment)
					%RVar%_%A_LoopField%_Comment .= %RVar%_%From_Section%_%A_LoopField%_Comment
			} Else If (Treat_Duplicate_Sections = 3){
				If (Convert_Comments){
					If %RVar%_%From_Section%_%A_LoopField%_Comment
						%RVar%_%A_LoopField%_Comment := %RVar%_%From_Section%_%A_LoopField%_Comment
					Else If %RVar%_%A_LoopField%_Comment
						%RVar%_%A_LoopField%_Comment := ""
				}
				If (Blank_Sections_On_Replace and %RVar%_All_%A_LoopField%_Keys){
					T_Section := A_LoopField
					Loop, Parse, %RVar%_All_%T_Section%_Keys, `n
					{
						VarSetCapacity(%RVar%_%T_Section%_%A_LoopField%_Name, 0)
						If (%RVar%_%T_Section%_%A_LoopField%_Value != "")
							VarSetCapacity(%RVar%_%T_Section%_%A_LoopField%_Value, 0)
						If %RVar%_%T_Section%_%A_LoopField%_Comment
							VarSetCapacity(%RVar%_%T_Section%_%A_LoopField%_Comment, 0)
					}
					VarSetCapacity(%RVar%_All_%T_Section%_Keys, 0)
				}
			}
		} Else {
			RIni_AddSection(RVar, %RVar%_%From_Section%_%A_LoopField%_Name)
			If %RVar%_%From_Section%_%A_LoopField%_Comment
				%RVar%_%A_LoopField%_Comment := %RVar%_%From_Section%_%A_LoopField%_Comment
		}
	}
	If (Include_From_Section and InStr("`n" %RVar%_All_%From_Section%_Keys, "`n" From_Section "`n")){
		If (Treat_Duplicate_Sections = 1)
			Return
		Else If (Treat_Duplicate_Sections = 2){
			If %RVar%_%From_Section%_%From_Section%_Comment
				%RVar%_%From_Section%_Comment .= %RVar%_%From_Section%_%From_Section%_Comment
		} Else If (Treat_Duplicate_Sections = 3){
			If (Convert_Comments){
				If %RVar%_%From_Section%_%From_Section%_Comment
					%RVar%_%From_Section%_Comment := %RVar%_%From_Section%_%From_Section%_Comment
				Else If %RVar%_%From_Section%_Comment
					VarSetCapacity(%RVar%_%From_Section%_Comment, 0)
			}
			If (Blank_Sections_On_Replace){
				Loop, Parse, %RVar%_All_%From_Section%_Keys, `n
				{
					VarSetCapacity(%RVar%_%From_Section%_%A_LoopField%_Name, 0)
					If (%RVar%_%From_Section%_%A_LoopField%_Value != "")
						VarSetCapacity(%RVar%_%From_Section%_%A_LoopField%_Value, 0)
					If %RVar%_%From_Section%_%A_LoopField%_Comment
						VarSetCapacity(%RVar%_%From_Section%_%A_LoopField%_Comment, 0)
				}
				VarSetCapacity(%RVar%_All_%From_Section%_Keys, 0)
			}
		}
	}
}


RIni_AlterSectionKeys(RVar, Sec, Alter_How=1)
{
	;Alter_How
	;1 - Delete
	;2 - Erase values
	;3 - Erase comments
	;4 - Erase values and comments
	Global

	If !RIni_%RVar%_Is_Set
		Return -10

	Sec := RIni_CalcMD5(Sec)

	If !RIni_%RVar%_%Sec%_Is_Set
		Return -2
	If !%RVar%_All_%Sec%_Keys
		Return
	If (Alter_How = 1){
		Loop, Parse, %RVar%_All_%Sec%_Keys, `n
		{
			VarSetCapacity(%RVar%_%Sec%_%A_LoopField%_Name, 0)
			If (%RVar%_%Sec%_%A_LoopField%_Value != "")
				VarSetCapacity(%RVar%_%Sec%_%A_LoopField%_Value, 0)
			If %RVar%_%Sec%_%A_LoopField%_Comment
				VarSetCapacity(%RVar%_%Sec%_%A_LoopField%_Comment, 0)
		}
		VarSetCapacity(%RVar%_All_%Sec%_Keys, 0)
	} Else If (Alter_How = 2){
		Loop, Parse, %RVar%_All_%Sec%_Keys, `n
		{
			If (%RVar%_%Sec%_%A_LoopField%_Value != "")
				VarSetCapacity(%RVar%_%Sec%_%A_LoopField%_Value, 0)
		}
	} Else If (Alter_How = 3){
		Loop, Parse, %RVar%_All_%Sec%_Keys, `n
		{
			If %RVar%_%Sec%_%A_LoopField%_Comment
				VarSetCapacity(%RVar%_%Sec%_%A_LoopField%_Comment, 0)
		}
	} Else If (Alter_How = 4){
		Loop, Parse, %RVar%_All_%Sec%_Keys, `n
		{
			If (%RVar%_%Sec%_%A_LoopField%_Value != "")
				VarSetCapacity(%RVar%_%Sec%_%A_LoopField%_Value, 0)
			If %RVar%_%Sec%_%A_LoopField%_Comment
				VarSetCapacity(%RVar%_%Sec%_%A_LoopField%_Comment, 0)
		}
	}
}


RIni_CountSections(RVar)
{
	Global
	Local Number = 0
	Loop, % RIni_%RVar%_Section_Number
		If (RIni_%RVar%_%A_Index% != "")
			Number++

	Return Number
}

RIni_CountKeys(RVar, Sec="")
{
	Global
	Local Number = 0, T_Section

	If !RIni_%RVar%_Is_Set
		Return -10
	Sec := RIni_CalcMD5(Sec)

	If (Sec){
		Loop, % RIni_%RVar%_Section_Number
		{
			If (RIni_%RVar%_%A_Index% != ""){
				Sec := RIni_CalcMD5(RIni_%RVar%_%A_Index%)
				If (%RVar%_All_%Sec%_Keys){
					StringReplace, %RVar%_All_%Sec%_Keys, %RVar%_All_%Sec%_Keys, `n, `n, UseErrorLevel
					Number += ErrorLevel
				}
			}
		}
	} else {
		If (%RVar%_All_%Sec%_Keys){
			StringReplace, %RVar%_All_%Sec%_Keys, %RVar%_All_%Sec%_Keys, `n, `n, UseErrorLevel
			Number += ErrorLevel
		}
	}
	Return Number
}


RIni_AutoKeyList(RVar, Sec, List, List_Delimiter, Key_Prefix="Key", Returnw_Keys_List=1, New_Key_Delimiter=",", Trim_Spaces_From_Value=0)
{
	Global
	Static Number = 1, S_Section
	Local T_Value, New_Keys, TSec, TKey, Key

	If !RIni_%RVar%_Is_Set
		Return -10
	If (List_Delimiter != "`n" and List_Delimiter != "`r" and List_Delimiter != "`n`r" and List_Delimiter != "`r`n")
		Return -4
	TSec := Sec
	, Sec := RIni_CalcMD5(TSec)

	If (!RIni_%RVar%_%Sec%_Is_Set){
		If !RIni_%RVar%_Fix_Errors
			Return -2
		RIni_AddSection(RVar, TSec)
	}
	If Returnw_Keys_List
		VarSetCapacity(New_Keys, Ceil(StrLen(List) / StrLen(SubStr(List, 1, InStr(List, List_Delimiter))) * (StrLen(Key_Prefix)+2)) * RIni_Unicode_Modifier)
	If (S_Section != Sec)
		S_Section := Sec
		, Number = 1

	Loop, Parse, List, `n, `r
	{
		If A_LoopField =
			Continue
		Loop
		{
			TKey := Key_Prefix Number
			, Key := RIni_CalcMD5(TKey)

			If InStr("`n" %RVar%_All_%Sec%_Keys, "`n" Key "`n")
				Number ++
			Else
				Break
		}

		%RVar%_All_%Sec%_Keys .= Key "`n"
		, %RVar%_%Sec%_%Key%_Name := TKey
		If (Returnw_Keys_List)
			New_Keys .= New_Key_Delimiter TKey

		If (Trim_Spaces_From_Value)
			%RVar%_%Sec%_%Key%_Value = %A_LoopField%
		Else
			%RVar%_%Sec%_%Key%_Value := A_LoopField
	}

	Number++
	If Returnw_Keys_List
		Return New_Keys
}


RIni_SwapSections(RVar, Section_1, Section_2)
{
	Global
	Local T_Section, N, E, TSection_1, TSection_2, TT_Section

	If !RIni_%RVar%_Is_Set
		Return -10

	TSection_1 := Section_1
	, Section_1 := RIni_CalcMD5(TSection_1)
	If !RIni_%RVar%_%Section_1%_Is_Set
			Return -2

	TSection_2 := Section_2
	, Section_2 := RIni_CalcMD5(TSection_2)
	If !RIni_%RVar%_%Section_2%_Is_Set
			Return -2

	Loop
	{
		TT_Section := A_Now A_MSec
		, T_Section := RIni_CalcMD5(TT_Section)
		If !RIni_%RVar%_%T_Section%_Is_Set
			Break
		Else
			Sleep 1
	}

	If (E := RIni_RenameSection(RVar, TSection_1, TT_Section))
		Return E
	If (E := RIni_RenameSection(RVar, TSection_2, TSection_1))
		Return E
	If (E := RIni_RenameSection(RVar, TT_Section, TSection_2))
		Return E
}


RIni_ExportKeysToGlobals(RVar, Sec, Replace_If_Exists=0, Replace_Spaces_with="_")
{
	Global
	Local TKey

	If !RIni_%RVar%_Is_Set
		Return -10
	Sec := RIni_CalcMD5(Sec)
	If !RIni_%RVar%_%Sec%_Is_Set
		Return -2
	If !%RVar%_All_%Sec%_Keys
		Return -3
	Loop, Parse, %RVar%_All_%Sec%_Keys, `n
	{
		If A_LoopField =
			continue
		TKey := %RVar%_%Sec%_%A_Loopfield%_Name
		If (InStr(TKey, A_Space))
			StringReplace, TKey, TKey, %A_Space%, %Replace_Spaces_with%, A
		If (!Replace_If_Exists And %TKey% != "")
			Continue
		%TKey% := %RVar%_%Sec%_%A_LoopField%_Value
	}
}


RIni_SectionExists(RVar, Sec)
{
	Global

	If !RIni_%RVar%_Is_Set
		Return 0
	Sec := RIni_CalcMD5(Sec)
	Return RIni_%RVar%_%Sec%_Is_Set ? 1 : 0
}


RIni_KeyExists(RVar, Sec, Key)
{
	Global

	If !RIni_%RVar%_Is_Set
		Return -10
	Sec := RIni_CalcMD5(Sec)
	If !RIni_%RVar%_%Sec%_Is_Set
		Return 0
	Key := RIni_CalcMD5(Key)
	Return InStr("`n" %RVar%_All_%Sec%_Keys, "`n" Key "`n") ? 1 : 0
}


RIni_FindKey(RVar, Key)
{
	Global
	Local TSec, Sec

	If !RIni_%RVar%_Is_Set
		Return -10
	Key := RIni_CalcMD5(Key)
	Loop, % RIni_%RVar%_Section_Number
	{
		If (RIni_%RVar%_%A_Index% != ""){
			TSec := RIni_%RVar%_%A_Index%
			, Sec := RIni_CalcMD5(TSec)

			If (InStr("`n" %RVar%_All_%Sec%_Keys, "`n" Key "`n"))
				Return TSec
		}
	}
}


RIni_CalcMD5(_String)
{
	Global RIni_Unicode_Modifier
	Static MD5_CTX

	StringUpper, _String, _String

	Ptr := A_IsUnicode ? "UPtr" : "UInt"
	, VarSetCapacity(MD5_CTX, 104, 0)
	, DllCall("advapi32\MD5Init", Ptr, &MD5_CTX)
	, DllCall("advapi32\MD5Update", Ptr, &MD5_CTX, Ptr, &_String, "UInt", StrLen(_String) * RIni_Unicode_Modifier)
	, DllCall("advapi32\MD5Final", Ptr, &MD5_CTX)
	, MD5 .= NumGet(MD5_CTX, 88, "UChar")
	, MD5 .= NumGet(MD5_CTX, 89, "UChar")
	, MD5 .= NumGet(MD5_CTX, 90, "UChar")
	, MD5 .= NumGet(MD5_CTX, 91, "UChar")
	, MD5 .= NumGet(MD5_CTX, 92, "UChar")
	, MD5 .= NumGet(MD5_CTX, 93, "UChar")
	, MD5 .= NumGet(MD5_CTX, 94, "UChar")
	, MD5 .= NumGet(MD5_CTX, 95, "UChar")
	, MD5 .= NumGet(MD5_CTX, 96, "UChar")
	, MD5 .= NumGet(MD5_CTX, 97, "UChar")
	, MD5 .= NumGet(MD5_CTX, 98, "UChar")
	, MD5 .= NumGet(MD5_CTX, 99, "UChar")
	, MD5 .= NumGet(MD5_CTX, 100, "UChar")
	, MD5 .= NumGet(MD5_CTX, 101, "UChar")
	, MD5 .= NumGet(MD5_CTX, 102, "UChar")
	, MD5 .= NumGet(MD5_CTX, 103, "UChar")

	Return MD5
}



/*
RIni_Create(RVar, Correct_Errors=1)
RIni_Shutdown(RVar)
RIni_Read(RVar, File, Correct_Errors=1, Remove_Inline_Key_Comments=0, Remove_Lone_Line_Comments=0, Remove_Inline_Section_Comments=0, Treat_Duplicate_Sections=1, Treat_Duplicate_Keys=1, Read_Blank_Sections=1, Read_Blank_Keys=1, Trim_Spaces_From_Values=0)
RIni_Write(RVar, File, Newline="`r`n", Write_Blank_Sections=1, Write_Blank_Keys=1, Space_Sections=1, Space_Keys=0, Remove_Valuewlines=1, Overwrite_If_Exists=1, Addwline_At_End=0)
RIni_AddSection(RVar, Sec)
RIni_AddKey(RVar, Sec, Key)
RIni_AppendValue(RVar, Sec, Key, Value, Trim_Spaces_From_Value=0, Removewlines=1)
RIni_ExpandSectionKeys(RVar, Sec, Amount=1)
RIni_ContractSectionKeys(RVar, Sec)
RIni_ExpandKeyValue(RVar, Sec, Key, Amount=1)
RIni_ContractKeyValue(RVar, Sec, Key)
RIni_SetKeyValue(RVar, Sec, Key, Value, Trim_Spaces_From_Value=0, Removewlines=1)
RIni_DeleteSection(RVar, Sec)
RIni_DeleteKey(RVar, Sec, Key)
RIni_GetSections(RVar, Delimiter=",")
RIni_GetSectionKeys(RVar, Sec, Delimiter=",")
RIni_GetKeyValue(RVar, Sec, Key, Default_Return="")
RIni_CopyKeys(From_RVar, To_RVar, From_Section, To_Section, Treat_Duplicate_Keys=2, Copy_Key_Values=1, Copy_Key_Comments=1, Copy_Blank_Keys=1)
RIni_Merge(From_RVar, To_RVar, Treat_Duplicate_Sections=1, Treat_Duplicate_Keys=2, Merge_Blank_Sections=1, Merge_Blank_Keys=1)
RIni_ToVariable(RVar, ByRef Variable, Newline="`r`n", Add_Blank_Sections=1, Add_Blank_Keys=1, Space_Sections=0, Space_Keys=0, Remove_Valuewlines=1)
RIni_GetKeysValues(RVar, ByRef Values, Key, Delimiter=",", Default_Return="")
RIni_AppendTopComments(RVar, Comments)
RIni_SetTopComments(RVar, Comments)
RIni_AppendSectionComment(RVar, Sec, Comment)
RIni_SetSectionComment(RVar, Sec, Comment)
RIni_AppendSectionLLComments(RVar, Sec, Comments)
RIni_SetSectionLLComments(RVar, Sec, Comments)
RIni_AppendKeyComment(RVar, Sec, Key, Comment)
RIni_SetKeyComment(RVar, Sec, Key, Comment)
RIni_GetTopComments(RVar, Delimiter="`r`n", Default_Return="")
RIni_GetSectionComment(RVar, Sec, Default_Return="")
RIni_GetSectionLLComments(RVar, Sec, Delimiter="`r`n", Default_Return="")
RIni_GetKeyComment(RVar, Sec, Key, Default_Return="")
RIni_GetTotalSize(RVar, Newline="`r`n", Default_Return="")
RIni_GetSectionSize(RVar, Sec, Newline="`r`n", Default_Return="")
RIni_GetKeySize(RVar, Sec, Key, Newline="`r`n", Default_Return="")
RIni_VariableToRIni(RVar, ByRef Variable, Correct_Errors=1, Remove_Inline_Key_Comments=0, Remove_Lone_Line_Comments=0, Remove_Inline_Section_Comments=0, Treat_Duplicate_Sections=1, Treat_Duplicate_Keys=1, Read_Blank_Sections=1, Read_Blank_Keys=1, Trim_Spaces_From_Values=0)
RIni_CopySectionNames(From_RVar, To_RVar, Treat_Duplicate_Sections=1, CopySection_Comments=1, Copy_Blank_Sections=1)
RIni_CopySection(From_RVar, To_RVar, From_Section, To_Section, Copy_Lone_Line_Comments=1, CopySection_Comment=1, Copy_Key_Values=1, Copy_Key_Comments=1, Copy_Blank_Keys=1)
RIni_CloneKey(From_RVar, To_RVar, From_Section, To_Section, From_Key, To_Key)
RIni_RenameSection(RVar, From_Section, To_Section)
RIni_RenameKey(RVar, Sec, From_Key, To_Key)
RIni_SortSections(RVar, Sort_Type="")
RIni_SortKeys(RVar, Sec, Sort_Type="")
RIni_AddSectionsAsKeys(RVar, To_Section, Include_To_Section=0, Convert_Comments=1, Treat_Duplicate_Keys=1, Blank_Key_Values_On_Replace=1)
RIni_AddKeysAsSections(RVar, From_Section, Include_From_Section=0, Treat_Duplicate_Sections=1, Convert_Comments=1, Blank_Sections_On_Replace=1)
RIni_AlterSectionKeys(RVar, Sec, Alter_How=1)
RIni_CountSections(RVar)
RIni_CountKeys(RVar, Sec="")
RIni_AutoKeyList(RVar, Sec, List, List_Delimiter, Key_Prefix="Key", Returnw_Keys_List=1, New_Key_Delimiter=",", Trim_Spaces_From_Value=0)
RIni_SwapSections(RVar, Section_1, Section_2)
RIni_ExportKeysToGlobals(RVar, Sec, Replace_If_Exists=0, Replace_Spaces_with="_")
RIni_SectionExists(RVar, Sec)
RIni_KeyExists(RVar, Sec, Key)
RIni_FindKey(RVar, Key)
*/
