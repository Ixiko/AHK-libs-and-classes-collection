; Form Filler


; Returns True if successful
; @formInfo:
;   Each line is in the form "ClassNN = VariableName"
;   To skip "blank check", use "ClassNN *= VariableName"
;   Example:
;		formInfo =
;		(ltrim comments
;		    txtFilename = MyFilename
;			txtTitle = MyTitle
;		)

FillForm(winTitle, formInfo, GetOrPost = "GET") {
	global
	local form, formClass, formVariable, formEq

	If GetOrPost = POST 
	{	; Before we POST, we must check to see if everything is blank:
		blankResult := FillForm(winTitle, formInfo, "TESTBLANK")
		If (blankResult != true)
		{	Gui +OwnDialogs
			MsgBox The information cannot be sent to the form because the following fields are not blank:`n%blankResult%
			Return false
		}
	}
	
	
	
	blankResult =
	Loop, parse, formInfo, `n
	{
		If A_LoopField =
			continue

		If Not RegexMatch(A_LoopField, "(?<Class>\S+)\s*(?<Eq>\*?\=)\s*(?<Variable>\S+)", form)
			Msgbox Invalid line: %A_LoopField%
			
		If A_Index = 1
			FirstControl := formClass


		
		If GetOrPost = GET
			ControlGetText %formVariable%, %formClass%, %winTitle%
		Else If GetOrPost = POST
		{	formVariable := %formVariable%
		
			ControlFocus %formClass%, %winTitle% ; focus and de-focus the control
			;ControlSendRaw %formClass%, %formVariable%, %winTitle%
			Control EditPaste, %formVariable%, %formClass%, %winTitle%
		}
		Else If GetOrPost = TESTBLANK
		{	If formEq = *= ; If there is a "*=" in the equals sign, then skip this blank check
				continue 
				
			ControlGetText Temp%formVariable%, %formClass%, %winTitle%
			If Not (Temp%formVariable% = "" OR Temp%formVariable% = %formVariable% OR Temp%formVariable% = "0.00") {
				If blankResult !=
					blankResult .= ", "
				blankResult .= formVariable . " (""" . Temp%formVariable% . """)"
			}
		}
		Else If GetOrPost = TESTSHOW
		{	tooltipindex := mod(A_Index - 1, 20) + 1
			WinGetPos wX, wY, , , %winTitle%
			ControlGetPos cX, cY, , , %formClass%, %winTitle%
			
			CoordMode, ToolTip, Screen
			ToolTip, %formVariable%, % wX + cX, % wY + cY, %tooltipindex%
			SetTimer HideAllTooltips, -10000
		}
		Else
		{	MsgBox GetOrPost is invalid: %GetOrPost%
			break
		}
	}
	
	ControlFocus %FirstControl%, %winTitle% ; Always end focus on the last control
		
	
	If blankResult !=
		Return blankResult
	
	Return true
}

HideAllTooltips:
	Loop, 20
		ToolTip, , , , %A_Index%
Return
