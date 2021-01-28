MultiTap(CmdListCSV="", Delay=400, DisplayFunc="") ;http://www.autohotkey.com/forum/viewtopic.php?p=478447
{
	Static Cache
	If (CmdListCSV <> "") {
		StringReplace, TempCSV, CmdListCSV, ", "", All
		If (@ := InStr(Cache, TempCSV ""","))
			Cache := SubStr(Cache, 1, @ - 13) ($ := SubStr("00000" A_TickCount + Delay, -9) SubStr("0" (n := SubStr(Cache, @ - 2, 2) + 1), -1) TempCSV) SubStr(Cache, @ + StrLen(TempCSV))
		Else
			Cache .= """" ($ := SubStr("00000" A_TickCount + Delay, -9) "01" TempCSV) """,", n := 1
		Loop, Parse, CmdListCSV, CSV
			If (A_Index = n) {
				Found := True
				If RegExMatch(A_LoopField, "^\s*:\K(?:[^:]|::)*(?=:)", Text)
					StringReplace, Text, Text, ::, :, All
				Else
					Text := A_LoopField
				If (DisplayFunc <> "") and IsFunc(Display)
					%DisplayFunc%(Text)
				Else
					ToolTip, %Text%
				Break
			}
	}
	If !Found {
		If (DisplayFunc <> "") and IsFunc(DisplayFunc)
			%DisplayFunc%()
		Else
			ToolTip
		If (CmdListCSV <> "")
			StringReplace, Cache, Cache, "%$%"`,
		n := 0
	}
	If (CmdListCSV = "") {
		Loop, Parse, Cache, CSV
			If (A_LoopField <> "") and ((ThisTime > @ := SubStr(A_LoopField, 1, 10)) or (ThisTime = ""))
				ThisTime := @, ThisNum := SubStr(A_LoopField, 11, 2), ThisCmd := SubStr(A_LoopField, 13)
		Loop, Parse, ThisCmd, CSV
			If (A_Index = ThisNum)
				If (A_LoopField <> "") {
					RegExMatch(A_LoopField, "s)^\s*(?::(?:[^:]|::)*: ?)?\K(?P<Name>\w*)(?:\((?P<Func>.*?)\)|,? ?(?P<Input>.*))$", Cmd)
					If (CmdFunc <> "") { ; Will attempt to use a function if you used function notation, i.e. Command(Input1,Input2,Input3)
						If IsFunc(CmdName) {
							Loop, Parse, CmdFunc, CSV
								CmdFunc%A_Index% := A_LoopField
							%CmdName%(CmdFunc1, CmdFunc2, CmdFunc3, CmdFunc4, CmdFunc5, CmdFunc6)
						} Else
							MsgBox, 262160, %A_ScriptName% - %A_ThisFunc%(): Error, Invalid command!`n"%Cmd%"
					} Else If (CmdName = "Run")
						Run, %CmdInput%, , UseErrorLevel
					Else If (CmdName = "Send")
						Send, %CmdInput%
					Else If (CmdName = "SendInput")
						SendInput, %CmdInput%
;	If you like, follow the example of the previous 2 lines to add more commands to MultiTap(). %CmdName% will contain the name of the command and %CmdInput% will contain the additional string that is passed as a parameter. Below gives an example of adding message box functionality.
;					Else If (CmdName = "MsgBox")
;						MsgBox, %CmdInput%
					Else If (CmdName = "Goto") or (CmdName = "Gosub")
						SetTimer, %CmdInput%, -1
					Else If IsLabel(RegExReplace(Cmd, "\s"))
						SetTimer, % RegExReplace(Cmd, "\s"), -1
					Else If IsFunc(CmdName)
						%CmdName%(CmdInput)
					Else {
						Run, %Cmd%, , UseErrorLevel
						If ErrorLevel
							MsgBox, 262160, %A_ScriptName% - %A_ThisFunc%(): Error, Invalid command!`n"%Cmd%"
					}
					Break
				}
		StringReplace, ThisCmd, ThisCmd, ", "", All
		StringReplace, Cache, Cache, "%ThisTime%%ThisNum%%ThisCmd%"`,
	}
	Loop, Parse, Cache, CSV
		If (A_LoopField <> "") and ((NextTime > @ := SubStr(A_LoopField, 1, 10)) or (NextTime = ""))
			NextTime := @
	If NextTime
		SetTimer, MultiTap, % 0 > (@ := A_TickCount - NextTime) ? @ : -1
	Return n
	MultiTap:
	Return MultiTap()
}