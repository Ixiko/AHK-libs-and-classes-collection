;~ ---------------------------------------------------
;~ Open Connection using plain FTP
;~ ---------------------------------------------------

; Include lib
#Include ..\WinSCP.ahk

;create instance
FTPSession := new WinSCP
try
	;Open Conenction
	FTPSession.OpenConnection("ftp://myserver.com","username","password")
catch e
	;Catch Exeptions
	msgbox % "Oops. . . Something went wrong``n" e.Message