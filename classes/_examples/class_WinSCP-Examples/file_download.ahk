;~ ---------------------------------------------------
;~ Download File
;~ ---------------------------------------------------

; Include lib
#Include ..\WinSCP.ahk

;create instance
FTPSession := new WinSCP
try
{
	;Open Conenction
	FTPSession.OpenConnection("ftp://myserver.com","username","password")
	
	;File Name
	fName := "Windows10_InsiderPreview_x64_EN-US_10074.iso"
	;File Path on local computer
	lPath := "C:\temp"
	;File Path on the server
	rPath := "/Win10beta/"
	
	;Check if File exists on server
	if (FTPSession.FileExists(rPath "/" fName))
		;Download File
		FTPSession.GetFiles(rPath "/" fName, lPath)
} catch e
	;Catch Exeptions
	msgbox % "Oops. . . Something went wrong``n" e.Message
