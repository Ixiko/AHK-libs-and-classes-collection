OpenFileLocation(fnFilePath)
{
	; Open a window view with the specified folder, file or application selected.
	; http://ss64.com/nt/explorer.html
	; MsgBox fnFilePath: %fnFilePath%
	CmdString = Explorer.exe /select,"%fnFilePath%"
	Run, %ComSpec% /c "%CmdString%",, Hide ; /c to close cmd window, /k to keep open
}


/* ; testing
SomeFilePath := A_MyDocuments "\Test.txt"
ReturnValue := OpenFileLocation(SomeFilePath)
; MsgBox, OpenFileLocation`n`nReturnValue: %ReturnValue%
*/