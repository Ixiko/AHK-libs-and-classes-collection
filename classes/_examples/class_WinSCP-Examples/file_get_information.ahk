;~ ---------------------------------------------------
;~ Get File Information
;~ ---------------------------------------------------

; Include lib
#Include ..\WinSCP.ahk

;create instance
FTPSession := new WinSCP
try
{
	;Open Conenction
	FTPSession.OpenConnection("ftp://myserver.com","username","password")

	;Retrieve File Collection
	FileCollection := FTPSession.ListDirectory("/")
	;Walk trough File Collection
	for file in FileCollection.Files {
		;Skip '.' and '..'
		if (file.Name != "." && file.Name != "..")
			;Display Data
			msgbox % "Name: " file.Name "``nPermission: " file.FilePermissions.Octal
							. "``nIsDir: " file.IsDirectory "``nFileType: " file.FileType "``nGroup: " file.Group
							. "``nLastWriteTime: " file.LastWriteTime "``nLength: " file.Length "``nLength32: " file.Length32 "``nOwner: " file.Owner
} catch e
	;Catch Exeptions
	msgbox % "Oops. . . Something went wrong``n" e.Message