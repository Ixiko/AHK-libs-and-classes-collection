;~ ---------------------------------------------------
;~ Upload File
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
	fPath := "C:\temp"
	;File Path on the server
	tPath := "/Win10beta/"
	
	;Check if Path on server exists
	if (!FTPSession.FileExists(tPath))
		;Create Path on server
		FTPSession.CreateDirectory(tPath)
	;Upload file
	FTPSession.PutFiles(fPath "\" fName, tPath)
} catch e
	;Catch Exeptions
	msgbox % "Oops. . . Something went wrong``n" e.Message