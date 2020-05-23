;{ GuiVar
; Fanatic Guru
; 2017 11 16
; Version: 1.0
;
; CLASS that uses hidden Gui windows to pass information between scripts.
;
;---------------------------------------------------------------------------------
; 	Methods:
;		__New						Create new instance of Class
;
;		__Delete					Delete instance of Class and  Gui if possible
;
;		List							Get name and text content of all Gui windows used by GuiVar
; 											Parameters:
;												1) {Array} 	byref variable in which to store Gui window data array
;											Returns:
;   											number of elements in data array
;											Example:
;												Count := GuiVar.List(Arr)
;
;		Destroy					Destroy Gui 
;											Parameters:
;												1) {Variable Name} 		name base of Gui window to destroy
;													default = "" 	destroys all Gui windows used by GuiVar
;											Returns:
;												number of Gui windows destroyed 
;											Example:
;												GuiVar.Destroy("Customer")
;											Note:	Only the script that first created a Gui can destroy that Gui
;
;
;		Destroy_SetTimer		Use SetTimer to check hidden Gui windows to destroy
;											Parameters:
;												1) {Time}		time in ms to check for Gui windows to destroy
;													default = 1000 
;												2)	{Value}		destroy all Gui windows with this value
;													default = ""
;											Returns:
;												None 
;											Global:
;												Creates a global variable named Value@GuiVar_Destroy_SetTimer
;											Dependencies:
;												GuiVar.List, GuiVar.Destroy
;											Example:
; 												GuiVar.Destroy_SetTimer(10000, "Done") ; every 10 seconds destroy any GuiVar that equals "Done"
; 											Note:	Only the script that first created a Gui can destroy that Gui
;
;	Properties:
;		Value						Text content of Gui
;											Example:
;												X := new GuiVar("SomeName")
;												X.Value := "Apple"
;												MsgBox % X.Value ; will display "Apple"
;
;		Name						Name used to title hidden Gui
;											Example:
;												MsgBox % X.Name ; from above example will display "SomeName"
;												X.Name := "AnotherName"
;												MsgBox % X.Name ; will display "SomeName"
;
;	Example Code:
;		Script1.ahk
; 			X := new GuiVar("Tree")
;			X.Value := "Apple
;		Script2.ahk
;			Y := new GuiVar("Tree") ; "Tree" must be same name used in script1.ahk to link GuiVar
;			MsgBox % Y.Value	; will display "Apple"
;}
class GuiVar
{
	__New(Var) 
	{
		this.Var := Var
	}
	__Delete() 
	{
		Var := this.Var
		DetectHiddenWindows, % (Setting_A_DetectHiddenWindows := A_DetectHiddenWindows) ? "On" :
		WinGet, WinList, ID, GuiVar_%Var%_GuiVar
		WinList ? WinList := 1 : WinList := 0
		ControlSetText,,, % "GuiVar_"  this.Var
		try
			Gui, GuiVar_%Var%_GuiVar:Destroy
		DetectHiddenWindows, %Setting_A_DetectHiddenWindows%
	}
	List(ByRef Array)
	{
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
	Destroy(Var := "")
	{
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
	Destroy_SetTimer(Time := 1000, Value := "")
	{
		global Value@GuiVar_Destroy_SetTimer := Value
		SetTimer, GuiVar_Destroy_SetTimer, %Time%
		return
		
		GuiVar_Destroy_SetTimer:
		GuiVar.List(List)
		for var, value in List
			if (value = Value@GuiVar_Destroy_SetTimer)
				GuiVar.Destroy(Var)
		return
	}
	Value
	{
		Get
		{
			DetectHiddenWindows, % (Setting_A_DetectHiddenWindows := A_DetectHiddenWindows) ? "On" :
			ControlGetText, Value,, % "GuiVar_" this.Var "_GuiVar"
			DetectHiddenWindows, %Setting_A_DetectHiddenWindows%
			return Value
		}
		Set
		{
			DetectHiddenWindows, % (Setting_A_DetectHiddenWindows := A_DetectHiddenWindows) ? "On" :
			if WinExist("GuiVar_" this.Var)
				ControlSetText,, %Value%, % "GuiVar_"  this.Var
			else
			{
				Gui, % "GuiVar_" this.Var "_GuiVar:Add", Text,, %Value%
				Gui, % "GuiVar_" this.Var "_GuiVar:Show", Hide, % "GuiVar_" this.Var "_GuiVar"
			}
			DetectHiddenWindows, %Setting_A_DetectHiddenWindows%
			return
		}
	}
	Name
	{
		Get
		{
			return this.Var
		}
		Set
		{
			DetectHiddenWindows, % (Setting_A_DetectHiddenWindows := A_DetectHiddenWindows) ? "On" :
			WinSetTitle, % "GuiVar_" this.Var "_GuiVar",, % "GuiVar_" Value "_GuiVar" 
			DetectHiddenWindows, %Setting_A_DetectHiddenWindows%
			this.Var := Value
		}
	}
}