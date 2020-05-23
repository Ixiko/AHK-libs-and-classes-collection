GetHotkeyList(fnShowFullModifierKeys)
{
	; function description
	; MsgBox fnShowFullModifierKeys: %fnShowFullModifierKeys%


	; declare local, global, static variables
	Global ApplicationName


	Try
	{
		; set default return value
		ReturnValue := 0 ; success


		; validate parameters


		; initialise variables
		ListFilepath        := A_Temp "\" ApplicationName "HotkeyList.txt"
		HotKeyList          := ""
		HotStringList       := ""
		LastFileName        := ""
		Indent              := ""
		IndentString        := "" ;A_Tab
		ScriptFileList      := ""


		; remove existing file
		IfExist, %ListFilepath%
			FileDelete, %ListFilepath%
		
		
		; create a list of script files
		Loop, Files, %A_ScriptDir%\*%ApplicationName%*.ahk, F ; for each file in the app directory containing the app name
		{
			If A_LoopFileName in ahk_DivineDev_AutoFormatKeywords_Generic.ahk ; exclude formatting hotstrings
				continue
			ScriptFileList .= "`r`n" A_LoopFileLongPath
		}
		ScriptFileList := SubStr(ScriptFileList,3)
		Sort, ScriptFileList, U
		
		
		; create list of hotkeys
		Loop, Parse, ScriptFileList, `n, `r
		{
			HotKeyListThisFile  := ""
			HotKeyCountThisFile := 0
			HotStringListThisFile  := ""
			HotStringCountThisFile := 0
			
			ThisFilePath := A_LoopField ;A_LoopFileLongPath
			
			SplitPath, ThisFilePath, ThisFileName
			ThisFileName := SubStr(ThisFileName,1,-4) ; strip the extension
			ThisFileName := StrReplace(ThisFileName,"ahk_") ; strip the filename prefix
			ThisFileName := StrReplace(ThisFileName,ApplicationName "_Hotkeys_Conditional_") ; strip the filename prefix
			
			
			If (ThisFileName != LastFileName) ; if it's a new file
				HotKeyListThisFile .= (LastFileName ? "`n" Indent : "") "[" ThisFileName "]`n"
			
			FileRead, ThisFileContents, %ThisFilePath%
			Loop, Parse, ThisFileContents, `n, `r
			{
				ThisLine := Trim(A_LoopField)
				
				If ThisLine not contains ::,:*:,:o: ;,#If ; look at only hotkeys and conditional modifiers
					Continue
				
				If (SubStr(ThisLine,1,1) = ";") ; skip commented lines
					Continue
				
				If (SubStr(ThisLine,1,1) = "~") ; strip tilde prefixes
					ThisLine := SubStr(ThisLine,2)
				
				; If ThisLine contains #If ; conditional hotkeys 
				; {
					; If ThisLine contains #IfWin
					; {
						; LastFileName := ThisFileName
						; ThisFileName := SubStr(ThisLine,InStr(ThisLine," ",,1,1)+1)
						; Indent := IndentString
						; HotKeyListThisFile .= Indent "[" ThisFileName "]`n"
					; }
					; Else
					; {
						; Indent := ""
						; HotKeyListThisFile .= "`n"
					; }
					; Continue
				; }
				
				StringReplace, ThisLine, ThisLine, :o:, ::, All
				StringReplace, ThisLine, ThisLine, :*:, ::, All
				StringReplace, ThisLine, ThisLine, :: , ::, UseErrorLevel
				CountOfDoubleColons := ErrorLevel
				
				If (CountOfDoubleColons = 1) ; hotkey
				{
					StringReplace, ThisLine, ThisLine, :: ,, All
					StringSplit, LineHalf, ThisLine, `;, %A_Space%%A_Tab%
					If fnShowFullModifierKeys
					{
						LineHalf1 := RegExReplace(LineHalf1,"([^a-zA-Z]+)([a-z])","$1$u2")
						StringReplace, LineHalf1, LineHalf1, +        , {+}
						StringReplace, LineHalf1, LineHalf1, #        , Win+
						StringReplace, LineHalf1, LineHalf1, !        , Alt+
						StringReplace, LineHalf1, LineHalf1, ^        , Ctrl+
						StringReplace, LineHalf1, LineHalf1, {+}      , Shift+
						StringReplace, LineHalf1, LineHalf1, &        , +
						StringReplace, LineHalf1, LineHalf1, <        , L
						StringReplace, LineHalf1, LineHalf1, >        , R
						StringReplace, LineHalf1, LineHalf1, <^>!     , AltGr+
						StringReplace, LineHalf1, LineHalf1, *        ,
						StringReplace, LineHalf1, LineHalf1, ~        ,
						StringReplace, LineHalf1, LineHalf1, $        ,
						StringReplace, LineHalf1, LineHalf1, CtrlBreak, Break
						StringReplace, LineHalf1, LineHalf1, Break    , PauseBreak
					}
					StringReplace, LineHalf1, LineHalf1, "",
					LineHalf1 := LineHalf1 StrReplicate(" ",(fnShowFullModifierKeys ? 30 : 20)-StrLen(LineHalf1))
					LineHalf2 := "- " LineHalf2
					HotKeyListThisFile .= Indent LineHalf1 LineHalf2 "`n"
					HotKeyCountThisFile++
				}
				
				
				If (CountOfDoubleColons = 2) ; hotstring
				{
					StringSplit, LinePart, ThisLine, :, %A_Space%%A_Tab%
					; MsgBox %ThisFilePath%`n`n%ThisLine%`n`n1: %LinePart1%`n2: %LinePart2%`n3: %LinePart3%`n4: %LinePart4%`n5: %LinePart5%
					ReplicateCount := (fnShowFullModifierKeys ? 30 : 20)-StrLen(LinePart3)
					ReplicateCount := ReplicateCount < 0 ? 1 : ReplicateCount
					LinePart3 := LinePart3 StrReplicate(" ",ReplicateCount)
					LinePart5 := "- " LinePart5
					; MsgBox %ThisLine%`n`n3: %LinePart3%`n5: %LinePart5%
					HotStringListThisFile .= Indent LinePart3 LinePart5 "`n"
					HotStringCountThisFile++		
				}
				
			}
			
			If HotKeyCountThisFile
				HotKeyList .= HotKeyListThisFile
			If HotStringCountThisFile
				HotStringList .= HotStringListThisFile
			
			LastFileName := ThisFileName
			ThisFileName := ""
		}
		Sort, HotStringList
		; HotKeyList := RegExReplace(HotKeyList,"iS)([a-zA-Z0-9]\R)(\s\[)","$1`r`n$2") ; insert line breaks for [strings]
		FileAppend, %HotKeyList%, %ListFilepath%
		FileAppend, `n[Hotstrings]`n, %ListFilepath%
		FileAppend, %HotStringList%, %ListFilepath%
		Run, %ListFilepath%

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
ApplicationName := "DivineDev"
ShowFullModifierKeys = 1
ReturnValue := GetHotkeyList(ShowFullModifierKeys)
; MsgBox, GetHotkeyList`n`nReturnValue: %ReturnValue%
*/