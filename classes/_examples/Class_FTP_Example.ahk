;; FTP Class Example - http://www.autohotkey.com/forum/viewtopic.php?t=73544
;; Synchronous mode example

;;== USER SETTINGS ===============
Server     := "ftp.autohotkey.net"
UserName   := "my_username"
Password   := "my_password"
UploadFile := "D:\Temp\Test.zip"
;;== END USER SETTINGS ===========


#Include FTP.ahk

ftp1 := new FTP()
ftp1 ? TTip("InternetOpen Success") : Quit("Could not load module/InternetOpen")

; connect to FTP server
ftp1.Open(Server, UserName, Password) ? TTip("Connected to FTP") : Quit(ftp1.LastError)

; get current directory
sOrgPath := ftp1.GetCurrentDirectory()
sOrgPath ? TTip("GetCurrentDirectory : " sOrgPath) : Msg(ftp1.LastError)
  
; create a new directory 'testing'
ftp1.CreateDirectory("testing") ? TTip("Created Directory ""testing""") : Msg(ftp1.LastError)

; set the current directory to 'root/testing'
ftp1.SetCurrentDirectory("testing") ? TTip("SetCurrentDirectory ""testing""") : Msg(ftp1.LastError)

; upload this script file
ftp1.PutFile(A_ScriptFullPath, A_ScriptName) ? TTip("PutFile success!") : Msg(ftp1.LastError)

; rename script to 'mytestscript.ahk'
ftp1.RenameFile(A_ScriptName, "MyTestScript.ahk") ? TTip("RenameFile success!") : Msg(ftp1.LastError)

; enumerate the file list from the current directory ('root/testing')
TTip("Enumerating files in directory ""/testing/""")
item := ftp1.FindFirstFile("/testing/*")
MsgBox % "Name : " . item.Name
 . "`nCreationTime : " . item.CreationTime
 . "`nLastAccessTime : " . item.LastAccessTime
 . "`nLastWriteTime : " . item.LastWriteTime
 . "`nSize : " . item.Size
 . "`nAttribs : " . item.Attribs
Loop
{
  if !(item := ftp1.FindNextFile())
    break
  MsgBox % "Name : " . item.Name
   . "`nCreationTime : " . item.CreationTime
   . "`nLastAccessTime : " . item.LastAccessTime
   . "`nLastWriteTime : " . item.LastWriteTime
   . "`nSize : " . item.Size
   . "`nAttribs : " . item.Attribs
}

; retrieve the file from the FTP server
ftp1.GetFile("MyTestScript.ahk", A_ScriptDir . "\MyTestScript.ahk", 0) ? TTip("GetFile success!") : Msg(ftp1.LastError)

; delete the file from the FTP server
ftp1.DeleteFile("MyTestScript.ahk") ? TTip("DeleteFile success!") : Msg(ftp1.LastError)

; upload a file with progress
ftp1.InternetWriteFile( UploadFile ) ? TTip("InternetWriteFile success!") : Msg(ftp1.LastError)

; download a file with progress
SplitPath,UploadFile,fName,,fExt
ftp1.InternetReadFile( fName , "delete_me." fExt) ? TTip("InternetReadFile success!") : Msg(ftp1.LastError)

; delete the file
ftp1.DeleteFile( fName )  ? TTip("DeleteFile success!") : Msg(ftp1.LastError)

; set the current directory back to the root
ftp1.SetCurrentDirectory(sOrgPath) ? TTip("SetCurrentDirectory to original path: success!") : Msg(ftp1.LastError)

; remove the direcrtory 'testing'
ftp1.RemoveDirectory("testing") ? TTip("RemoveDirectory ""\testing\"" success!") : Msg(ftp1.LastError)

; close the FTP connection, free library
ftp1 := ""    ;__Delete called
MsgBox, 64, Success, Tests successfully completed!, 3
ExitApp


Quit(Message="") {
	if Message
		MsgBox, 16, Error!, %Message%, 5
	ExitApp
}

Msg(Message="") {
	MsgBox, 64, , %Message%, 5
}

TTip(Message="") {
	ToolTip %Message%
}


