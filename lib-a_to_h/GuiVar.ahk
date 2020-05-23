;{ GuiVar
; Fanatic Guru
; 2014 11 06
; Version: 1.1
;
; LIBRARY that uses hidden Gui windows to pass information between scripts.
;
;---------------------------------------------------------------------------------
; GuiVar_Set				Set text content of a hidden Gui window
; GuiVar_Get				Get text content of a hidden Gui window
; GuiVar_List				Get name and text content of all hidden Gui window used by GuiVar
; GuiVar_Destroy			Destroy hidden Gui window used by GuiVar
; GuiVar_DestroySetTimer	Use SetTimer to check hidden Gui windows to destroy
;}

; FUNCTIONS
;{-----------------------------------------------
;

; GuiVar_Set
;
; Method:
;   GuiVar_Set(Variable Name, Value)
;
; Parameters:
;   1) {Variable Name} 	name base of Gui window in which to store Value
;   2) {Value}			text to store in Gui window
;
; Example:
;   GuiVar_Set("Customer","Fanatic Guru")
;}

GuiVar_Set(Var,Value) {
	DetectHiddenWindows, % (Setting_A_DetectHiddenWindows := A_DetectHiddenWindows) ? "On" :
	if WinExist("GuiVar_" Var)
		ControlSetText,, %Value%, GuiVar_%Var%
	else
	{
		Gui, GuiVar_%Var%_GuiVar:Add, Text,, %Value%
		Gui, GuiVar_%Var%_GuiVar:Show, Hide, GuiVar_%Var%_GuiVar
	}
	DetectHiddenWindows, %Setting_A_DetectHiddenWindows%
	return
}

; GuiVar_Get
;
; Method:
;   GuiVar_Get(Variable Name)
;
; Parameters:
;   1) {Variable Name} name base of Gui window from which to get text
;
; Returns:
;   Text from Gui window
;
; Example:
;   Current_Customer := GuiVar_Get("Customer")
;
GuiVar_Get(Var) {
	DetectHiddenWindows, % (Setting_A_DetectHiddenWindows := A_DetectHiddenWindows) ? "On" :
	ControlGetText, Value,, GuiVar_%Var%_GuiVar
	DetectHiddenWindows, %Setting_A_DetectHiddenWindows%
return Value
}

; GuiVar_List
;
; Method:
;   GuiVar_List(ByRef Array)
;
; Parameters:
;   1) {Array} 	variable in which to store Gui window data array
;
; Returns:
;   number of elements in data array
;
; ByRef:
;   Populates {Array} passed as parameter with Gui window data
;
GuiVar_List(ByRef Array) {
	DetectHiddenWindows, % (Setting_A_DetectHiddenWindows := A_DetectHiddenWindows) ? "On" :
	Array := {}
	WinGet, WinList, List, GuiVar_
	Loop, %WinList%
	{
		Hwnd := WinList%A_Index%
		WinGetTitle, WinTitle, ahk_id %Hwnd%
		ControlGetText, Value,, ahk_id %Hwnd%
		WinTitle := SubStr(WinTitle, 8, StrLen(WinTitle)-14)
		Array[WinTitle] := Value
	}
	DetectHiddenWindows, %Setting_A_DetectHiddenWindows%
return WinList
}

; GuiVar_Destroy
;
; Method:
;   GuiVar_Get(Variable Name)
;
; Parameters:
;   1) {Variable Name} 	name base of Gui window to destroy
;		default = "" 	destroys all Gui windows used by GuiVar
;
; Returns:
;   Number of Gui windows destroyed
;
; Example:
;   GuiVar_Destroy("Customer")
;
; Note:	Only the script that first created a Gui can destroy that Gui
;
GuiVar_Destroy(Var := "") {
	DetectHiddenWindows, % (Setting_A_DetectHiddenWindows := A_DetectHiddenWindows) ? "On" :
	if Var
	{
		WinGet, WinList, ID, GuiVar_%Var%_GuiVar
		WinList ? WinList := 1 : WinList := 0
		Gui, GuiVar_%Var%_GuiVar:Destroy
	}
	else
	{
		WinGet, WinList, List, GuiVar_
		Loop, %WinList%
		{
			Hwnd := WinList%A_Index%
			WinGetTitle, WinTitle, ahk_id %Hwnd%
			Gui, %WinTitle%:Destroy
		}
	}
	DetectHiddenWindows, %Setting_A_DetectHiddenWindows%
	return WinList
}

; GuiVar_DestroySetTimer
;
; Method:
;   GuiVar_Get(Time, Value)
;
; Parameters:
;   1) 	{Time} 		time in ms to poll for Gui windows to destroy
;			default = 1000
;	2)	{Value}		destroy all Gui windows with this value
;			default = ""
;
; Returns:
;   None
;
; Global:
;   Creates a global variable named Value@GuiVar_DestroySetTimer
;
; Dependencies:
;	GuiVar_List, GuiVar_Destroy
;
; Example:
;   GuiVar_DestroySetTimer(10000, "Done") ; every 10 seconds destroy any GuiVar that equals "Done"
;
; Note:	Only the script that first created a Gui can destroy that Gui
;
GuiVar_DestroySetTimer(Time := 1000, Value := "") {
	global Value@GuiVar_DestroySetTimer := Value
	SetTimer, GuiVar_DestroySetTimer, %Time%
	return

	GuiVar_DestroySetTimer:
	GuiVar_List(List)
	for var, value in List
		if (value = Value@GuiVar_DestroySetTimer)
			GuiVar_Destroy(Var)
	return
}