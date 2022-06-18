
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


