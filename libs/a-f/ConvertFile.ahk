/*
SetBatchLines -1
#NoEnv

Loop
{
	FileSelectFile, From_File,,, Select file to convert.

	IfNotExist, %From_File%
	{
		MsgBox, 1,, Error! invalid file.
		IfMsgBox Ok
		{
			From_File := ""
			Continue
		}
		IfMsgBox Cancel
			ExitApp
	} else
		Break
}

InputBox, T_Function_Name, Please enter a name for the recreate function.
If (T_Function_Name = "")
	ExitApp
Extract_%T_Function_Name% = If you see this you entered a invalid function name.

E := Convert_File(From_File, T_Function_Name)

If (E)
	MsgBox Error converting file: %E%
*/

Convert_File(_From_File, _Function_Name, _SplitLength = 16000) {
	ST1 := A_TickCount
	, Ptr := A_IsUnicode ? "Ptr" : "UInt"
	, H := DllCall("CreateFile", Ptr, &_From_File, "UInt", 0x80000000, "UInt", 3, "UInt", 0, "UInt", 3, "UInt", 0, "UInt", 0)
	, VarSetCapacity(FileSize, 8, 0)
	, DllCall("GetFileSizeEx", Ptr, H, "Int64*", FileSize)
	, DllCall("CloseHandle", Ptr, H)
	, FileSize := FileSize = -1 ? 0 : FileSize

	If (!FileSize)
		Return -1
	If (_SplitLength < 65)
		_SplitLength := 65

	SplitPath, _From_File, F_Name, F_Directory, F_Extension

	Needed_Capacity := Ceil((FileSize * 1.38) + (((FileSize * 1.38) / _SplitLength) * 15) + (5 * 1024))
	, VarSetCapacity(Bin_D, A_IsUnicode ? Needed_Capacity * 2 : Needed_Capacity)

	, Bin_D .= _Function_Name "_Get(_What)`r`n"
	, Bin_D .= "{`r`n"
	, Bin_D .= A_Tab "Static Size = " FileSize ", Name = """ F_Name """, Extension = """ F_Extension """, Directory = """ F_Directory """`r`n"
	, Bin_D .= A_Tab ", Options = ""Size,Name,Extension,Directory""`r`n"
	, Bin_D .= A_Tab ";This function returns the size(in bytes), name, filename, extension or directory of the file stored depending on what you ask for.`r`n"
	, Bin_D .= A_Tab "If (InStr("","" Options "","", "","" _What "",""))`r`n"
	, Bin_D .= A_Tab A_Tab "Return %_What%`r`n}`r`n"
	, Bin_D .= "`r`n"
	, Bin_D .= "Extract_" _Function_Name "(_Filename, _DumpData = 0)`r`n"
	, Bin_D .= "{`r`n"

	, H := DllCall("CreateFile", Ptr, &_From_File, "UInt", 0x80000000, "UInt", 3, "UInt", 0, "UInt", 3, "UInt", 0, "UInt", 0)
	, VarSetCapacity(InData, FileSize, 0)
	, DllCall("ReadFile", Ptr, H, Ptr, &InData, "UInt", FileSize, "UInt*", 0, "UInt", 0)
	, DllCall("Crypt32.dll\CryptBinaryToString" (A_IsUnicode ? "W" : "A"), Ptr, &InData, UInt, FileSize, UInt, 1, UInt, 0, UIntP, Bytes, "CDECL Int")
	, VarSetCapacity(OutData, Bytes *= (A_IsUnicode ? 2 : 1))
	, DllCall("Crypt32.dll\CryptBinaryToString" (A_IsUnicode ? "W" : "A"), Ptr, &InData, UInt, FileSize, UInt, 1, Str, OutData, UIntP, Bytes, "CDECL Int")
	, ET1 := A_TickCount
	, NumPut(0, OutData, VarSetCapacity(OutData) - (A_IsUnicode ? 6 : 4), (A_IsUnicode ? "UShort" : "UChar")) ;Removes the final "`r`n" that gets auto added to the string
	, VarSetCapacity(InData, FileSize, 0)
	, VarSetCapacity(InData, 0)

	, Bin_D .= A_Tab ";This function ""extracts"" the file to the location+name you pass to it.`r`n"
	, Bin_D .= A_Tab "Static HasData = 1, Out_Data, Ptr`r`n"
	, N := 1, I := 0
	, Bin_D .= A_Tab "Static " N "`r`n"
	, Bin_D .= A_Tab N ++ " := """

	Loop, Parse, OutData, `n, `r
		If (I + 64 > _SplitLength)
			Bin_D .= """`r`n	Static " N "`r`n " A_Tab N ++ " := """, I := 0
			, Bin_D .= A_LoopField, I += 64
		Else
			Bin_D .= A_LoopField, I += 64

	If (I != 0)
		Bin_D .= """`r`n"
	If (N != 1)
		N --

	Bin_D .= A_Tab "`r`n"
	, Bin_D .= A_Tab "If (!HasData)`r`n"
	, Bin_D .= A_Tab A_Tab "Return -1`r`n"
	, Bin_D .= A_Tab "`r`n"
	, Bin_D .= A_Tab "If (!Out_Data){`r`n"
	, Bin_D .= A_Tab A_Tab "Ptr := A_IsUnicode ? ""Ptr"" : ""UInt""`r`n"
	, Bin_D .= A_Tab A_Tab ", VarSetCapacity(TD, " Ceil(FileSize * 1.37) " * (A_IsUnicode ? 2 : 1))`r`n"
	, Bin_D .= A_Tab A_Tab "`r`n"
	, Bin_D .= A_Tab A_Tab "Loop, " N "`r`n"
	, Bin_D .= A_Tab A_Tab A_Tab "TD .= %A_Index%, "
	If (_SplitLength < 4096)
		Bin_D .= "VarSetCapacity(%A_Index%, 0)`r`n"
	Else
		Bin_D .= "%A_Index% := """"`r`n"
	, Bin_D .= A_Tab A_Tab "`r`n"
	, Bin_D .= A_Tab A_Tab "VarSetCapacity(Out_Data, Bytes := " FileSize ", 0)`r`n"
	, Bin_D .= A_Tab A_Tab ", DllCall(""Crypt32.dll\CryptStringToBinary"" (A_IsUnicode ? ""W"" : ""A""), Ptr, &TD, ""UInt"", 0, ""UInt"", 1, Ptr, &Out_Data, A_IsUnicode ? ""UIntP"" : ""UInt*"", Bytes, ""Int"", 0, ""Int"", 0, ""CDECL Int"")`r`n"
	, Bin_D .= A_Tab A_Tab ", TD := """"`r`n"
	, Bin_D .= A_Tab "}`r`n"
	, Bin_D .= A_Tab "`r`n"
	, Bin_D .= A_Tab "IfExist, %_Filename%`r`n"
	, Bin_D .= A_Tab A_Tab "FileDelete, %_Filename%`r`n"
	, Bin_D .= A_Tab "`r`n"
	, Bin_D .= A_Tab "h := DllCall(""CreateFile"", Ptr, &_Filename, ""Uint"", 0x40000000, ""Uint"", 0, ""UInt"", 0, ""UInt"", 4, ""Uint"", 0, ""UInt"", 0)`r`n"
	, Bin_D .= A_Tab ", DllCall(""WriteFile"", Ptr, h, Ptr, &Out_Data, ""UInt"", " FileSize ", ""UInt"", 0, ""UInt"", 0)`r`n"
	, Bin_D .= A_Tab ", DllCall(""CloseHandle"", Ptr, h)`r`n"
	, Bin_D .= A_Tab "`r`n"
	, Bin_D .= A_Tab "If (_DumpData)`r`n"
	, Bin_D .= A_Tab A_Tab "VarSetCapacity(Out_Data, " FileSize ", 0)`r`n"
	, Bin_D .= A_Tab A_Tab ", VarSetCapacity(Out_Data, 0)`r`n"
	, Bin_D .= A_Tab A_Tab ", HasData := 0`r`n"
	, Bin_D .= "}`r`n"
	, ET2 := A_TickCount

	MsgBox, 0x4, Conversion Finished, % "Conversion Finished.`n`nTook " Round((ET1 - ST1)/1000, 3) " seconds to convert the file and " Round((ET2 - ET1)/1000, 3) " seconds to format the functions.`n`nWould you like to save the functions as " Function_Name ".ahk in the scripts current directory?"
	IfMsgBox, Yes
	{
		IfExist, %A_ScriptDir%\%_Function_Name%.ahk
		{
			FileExists := 1
			Msgbox, 0x4, File Already Exists,Error! %A_ScriptDir%\%_Function_Name%.ahk`n`nFile already exists. Do you want to overwrite it?
			IfMsgBox, Yes
			{
				FileDelete, %A_ScriptDir%\%_Function_Name%.ahk
				FileExists := 0
			}
		}

		If (!FileExists)
		{
			If A_IsUnicode
				FileAppend, %Bin_D%, *%A_ScriptDir%\%_Function_Name%.ahk, UTF-8
			Else
				FileAppend, %Bin_D%, *%A_ScriptDir%\%_Function_Name%.ahk
		}
	}
	MsgBox, 0x4, Conversion Finished, % "Conversion Finished.`n`nTook " Round((ET1 - ST1)/1000, 3) " seconds to convert the file and " Round((ET2 - ET1)/1000, 3) " seconds to format the function.`n`nWould you like to copy the functions to the clipboard?"
	IfMsgBox, Yes
		Clipboard := Bin_D
}