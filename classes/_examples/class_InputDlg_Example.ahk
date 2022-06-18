#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


Whatever := New InputDlg("Menu","Okay","Text_Order " . A_TickCount, "Text_Hot or Cold:", "Radio_Hot", "Radio_Cold", "Text_Noodle Type:"
						, "Radio_Soba", "Radio_Udon", "Text_Extras:","Checkbox_Pork","Checkbox_Egg","Checkbox_Nori", "Text_Order Notes: ", "90Edit_Notes")
WinWaitClose, % "ahk_id " Whatever 
ExitApp


Okay(GuiHwnd, SubmitHWND, Title) {
Global 
GUI, Submit, Nohide
	if (Title = "Menu") {
		
		(Checkbox_Pork = 1 ? ListofChecks .= "Pork`n" : "")
		(Checkbox_Egg = 1 ? ListofChecks .= "Egg`n" : "")
		(Checkbox_Nori = 1 ? ListofChecks .= "Nori`n" : "")
		MsgBox % Edit_Name "Order for Raman:`n`nNoodle Type: `n" (Radio_Sorba = 1 ? "Sorba" : "Udon") "`n`nBroth: `n" (Radio_Hot = 1 ? "Hot" : "Cold") "`n`nExtras: `n" ListofChecks "`n`nOrder Notes:`n" 90Edit_Notes
								
		Gui %GuiHwnd%:Destroy
		ListofChecks := 
	}
}



;------------------------------------------------------------------------------------------------------------------
;                                         InputDlg Function                                                       ;
;										  by Casper Harkin                                                        ;
;	InputDlg(Title, FunctionOut, Options*)                                                                        ;
;		Title:			Title of the GUI                                                                          ;
;		FunctionOut:	The Function Called when you hit Okay                                                     ;
;		Options:		Text_ = Create Text Corntrol - The text of the control is specified after the _.          ;
;						Edit_ = Create Edit Control - The variable name of the control is the whole string.       ;
;						Radio_ = Create Radio Control - The text of the control is specified after the _.         ;
;						Checkbox_ = Create Checkbox Control - The text of the control is specified after the _.   ;
;------------------------------------------------------------------------------------------------------------------


Class InputDlg
{
	__New(Title, FunctionOut, Options*)
		{
			Global
			Static Count := 0
			Gui, %Title%:New
			Gui +Hwndh%Title%
			for index, Options in Options 
				{
					if (InStr(Options, "Text_") = "1")
						{
							Gui, Add, Text,, % Options := StrReplace(Options, "Text_")
						}

					if (InStr(Options, "Edit") = "1" ) or (InStr(Options, "Edit") = "2") or (InStr(Options, "Edit") = "3")
						{
								x := SubStr(Options, 1 , 2)
							 	if (x != "Ed") 
									Gui, Add, Edit, % "v" Options " h" x,
								else
									Gui, Add, Edit, % "v" Options,
						}
		
					if (InStr(Options, "Radio") = "1")
						{
							Gui, Add, Radio, % "v" Options, % a := StrReplace(Options, "Radio_")
						}
		
					if (InStr(Options, "Checkbox") = "1")
						{
							Gui, Add, Checkbox, % "v" Options, % Options := StrReplace(Options, "Checkbox_")
						}
				}
		Gui, Add, Button, wp y+5 HwndSubmitHWND +default, Okay
		fn_1 := Func(FunctionOut).bind(h%Title%,SubmitHWND, Title)
		GuiControl, +g, % SubmitHWND, % fn_1
		This.Show(Title)
		Return h%Title%
	}
	
	Show(Title) {
		Gui %Title%:Show 
	}
	
}


