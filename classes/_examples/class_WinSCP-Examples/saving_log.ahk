;~ ---------------------------------------------------
;~ Open Connection saving log
;~ ---------------------------------------------------

; Include lib
#Include ..\WinSCP.ahk

;create instance
FTPSession := new WinSCP
try
{
	;Define Log File
	FTPSession.LogPath       := "c:\temp\FTPSessionLog.log"
	;Open Conenction
	FTPSession.OpenConnection("ftp://myserver.com","username","password")
} catch e
	;Catch Exeptions
	msgbox % "Oops. . . Something went wrong``n" e.Message