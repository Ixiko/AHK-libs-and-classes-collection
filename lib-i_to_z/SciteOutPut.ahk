SciTEOutput(Text, Clear:=0, LineBreak:=1, Exit:=0) {

		try
			SciObj := ComObjActive("SciTE4AHK.Application")           	;get pointer to active SciTE window
		catch
			return                                                                            	;if not return

		If Clear
			SendMessage, SciObj.Message(0x111, 420)                   	;If clear=1 Clear output window
		If LineBreak
			Text .= "`r`n"                                                                	;If LineBreak=1 append text with `r`n

		SciObj.Output(Text)                                                           	;send text to SciTE output pane

		If (Exit=1) 	{
			MsgBox, 36, Exit App?, Exit Application?                         	;If Exit=1 ask if want to exit application
			IfMsgBox,Yes, ExitApp                                                       	;If Msgbox=yes then Exit the appliciation
		}

}
