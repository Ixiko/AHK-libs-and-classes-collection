;~ ---------------------------------------------------
;~ Open Connection using FTP with explicit SSL
;~ ---------------------------------------------------

; Include lib
#Include ..\WinSCP.ahk

;create instance
FTPSession := new WinSCP
try
{
	;Define Connection Data
	FTPSession.Hostname	:= "ftp://myserver.com"
	FTPSession.Protocol     	:= WinSCPEnum.FtpProtocol.Ftp
	FTPSession.Secure 		:= WinSCPEnum.FtpSecure.ExplicitSsl
	FTPSession.User			:= "MyUserName"
	FTPSession.Password		:= "P@ssw0rd"
	FTPSession.Fingerprint  := "xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx" ;set to false to ignore server certificate
	;Open Conenction
	FTPSession.OpenConnection()
} catch e
	;Catch Exeptions
	msgbox % "Oops. . . Something went wrong``n" e.Message
