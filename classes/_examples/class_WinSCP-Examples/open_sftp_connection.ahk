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
	FTPSession.Hostname		:= "ec2-54-93-105-213.eu-central-1.compute.amazonaws.com"
	FTPSession.Protocol 	:= WinSCPEnum.FtpProtocol.Sftp
	FTPSession.Secure 		:= WinSCPEnum.FtpSecure.ExplicitSsl
	FTPSession.User			:= "MyUserName"
	FTPSession.Password		:= "P@ssw0rd"
	FTPSession.Fingerprint  := "xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx" ;set to false to ignore server certificate
	;Open Conenction
	FTPSession.OpenConnection()
} catch e
	;Catch Exeptions
	msgbox % "Oops. . . Something went wrong``n" e.Message
