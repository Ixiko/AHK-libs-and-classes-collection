printfile(printpath,Copies,FileName){
 	Copies += 0
	MsgBox, 36, % "Printing Labels", % "You have selected to print " NumCopies " of " FileName " `n`nIf it is not your wish to print these labels, Press [NO]. `n`nIf you do want to print these labels, make sure you have " NumCopies " sheets of labels in the printer."
	IfMsgBox, Yes
		return
	else{
		oWord := ComObjCreate("Word.Application"),oFile := oWord.Documents.Open(path)
		oWord.DisplayAlerts := 0 ; turns off alerts to avoid warnings like "margins too small" etc.
		oFile.PrintOut(0,,,,,,,Copies); PrintInBackground:=0 if it prints in the background, could interfere with attempting to close the app
		oWord.DisplayAlerts := -1
		oFile.Close
		oWord.Quit
	}
}
