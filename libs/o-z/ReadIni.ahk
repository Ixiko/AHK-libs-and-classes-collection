ReadIni(fnSectionName := "",fnVarName := "",fnSkipEmptyValues := 1,fnIniFilePath := "", fnVariablePrefix := "")
{
	; reads values from an entire file, a section or a single line in a .ini file, setting a variable equal to the value in the line
	; an empty value for fnVarName will read all values in that section
	; MsgBox fnSectionName: %fnSectionName%`nfnVarName: %fnVarName%`nfnSkipEmptyValues: %fnSkipEmptyValues%`nfnIniFilePath: %fnIniFilePath%


	; declare local, global, static variables
	Global
	Local ReturnValue, SectionName, VarName, IniFilePath, SectionFirstChar, SectionLastChar, IniFileContents, FoundVar, FoundSection, ThisLine, LineLength, LinePart0, LinePart1, LinePart2, ThisLineFirstChar, ThisLineLastChar, ThisLineIsSectionHeader


	Try
	{
		; set default return value
		ReturnValue := 0 ; success


		; validate parameters


		; initialise variables
		SectionName := fnSectionName
		VarName     := fnVarName
		IniFilePath := fnIniFilePath ? fnIniFilePath : StrReplace(StrReplace(A_ScriptFullPath,".ahk",".ini"),".exe",".ini")
		If SectionName
			If !(SubStr(SectionName,1,1) = "[" && SubStr(StrReverse(SectionName),1,1) = "]")
				SectionName := "[" fnSectionName "]"


		; read the ini file
		FileRead, IniFileContents, %IniFilePath%
		If ErrorLevel
			Throw, Exception("Unable to read contents of " IniFilePath)
		
				
		; concatenate lines
		IniFileContents := RegExReplace(IniFileContents,"iS)\s*(;.*?)?\r\n\s*,",",")
		
				
		; replace system variables
		ReplaceSystemVariables(IniFileContents)


		; parse the required values
		FoundSection := 0
		Loop, Parse, IniFileContents, `n, `r
		{
			ThisLine := A_LoopField
			
			; remove trailing comments
			LineLength := InStr(ThisLine,A_Space ";") ? InStr(ThisLine,A_Space ";")-1 : StrLen(ThisLine)
			ThisLine := SubStr(ThisLine,1,LineLength)
			
			; trim leading and trailing white space
			ThisLine := Trim(ThisLine," `t")
			
			; whole line comments
			ThisLine := SubStr(ThisLine,1,1) = ";" ? "" : ThisLine
			
			; skip empty lines
			If !ThisLine
				Continue


			; identify section headers
			StringLeft, ThisLineFirstChar, ThisLine, 1
			StringRight, ThisLineLastChar , ThisLine, 1
			ThisLineIsSectionHeader := (ThisLineFirstChar = "[" && ThisLineLastChar = "]") ? 1 : 0
		
		
			; find the right place in the file
			If (ThisLineIsSectionHeader && SectionName && SectionName = ThisLine) ; turn on assignment for required section
				FoundSection := 1
			If (ThisLineIsSectionHeader && SectionName && SectionName != ThisLine) ; turn off assignment for required section
				FoundSection := 0
			If !SectionName ; if no section specified, find all
				FoundSection := 1


			; assign values to variables
			LinePart1 := ""
			LinePart2 := ""
			FoundVar := 0
			If (!ThisLineIsSectionHeader && FoundSection)
			{
				StringReplace, ThisLine, ThisLine, ``=, ¢, UseErrorLevel ; escaped equals sign
				StringSplit, LinePart, ThisLine, =, %A_Space%%A_Tab%
				StringReplace, LinePart2, LinePart2, ¢, =, All
				
				; skip empty values
				If (fnSkipEmptyValues && !LinePart2)
					Continue
				
				StringReplace, LinePart2, LinePart2, xCompanyNamex, %CompanyName%, All ; only works where CompanyName is defined in .ini file before xCompanyNamex is used
				StringReplace, LinePart2, LinePart2, `%A_Space`%  , %A_Space%    , All
				StringReplace, LinePart2, LinePart2, `%A_Tab`%    , %A_Tab%      , All
				StringReplace, LinePart2, LinePart2, ``r          , `r           , All
				StringReplace, LinePart2, LinePart2, ``n          , `n           , All
				StringReplace, LinePart2, LinePart2, ``t          , `t           , All
				
				If (VarName && VarName = LinePart1) ; turn on assignment for required variables
					FoundVar := 1
				If (VarName && VarName != LinePart1) ; turn off assignment for required variable
					FoundVar := 0
				If !VarName ; if no variable specified, find all
					FoundVar := 1
			
				; assign the value to the variable
				If FoundVar
					%fnVariablePrefix%%LinePart1% := LinePart2
			}
		}

	}
	Catch, ThrownValue
	{
		ReturnValue := !ReturnValue
		CatchHandler(A_ThisFunc,ThrownValue.Message,ThrownValue.What,ThrownValue.Extra,ThrownValue.File,ThrownValue.Line,0,0,0)
	}
	Finally
	{
	}

	; return
	Return ReturnValue
}


/* ; testing
SomeSectionName := ""
; SectionName := "[last section]"
; SectionName := "next section"
SomeVarName := ""
; VarName := "abc"
SomeVarNameReturnValue := ReadIni(SomeSectionName,SomeVarName)
MsgBox, ReadIni`n`nSomeVarNameReturnValue: %SomeVarNameReturnValue%
ListVars
Pause
; */