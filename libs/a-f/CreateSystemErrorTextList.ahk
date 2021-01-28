SystemErrorFile := FileOpen(A_MyDocuments "\AutoHotkey\Lib\SystemErrorCodes.csv","r") ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms681381(v=vs.85).aspx

IsAtEOF := 0
While !IsAtEOF
{
	FileLine := SystemErrorFile.ReadLine()
	StringSplit, LineItem, FileLine, `,, `r`n
	SystemErrorText%LineItem1% := LineItem2
	IsAtEOF := SystemErrorFile.AtEOF
}

SystemErrorFile.Close()
