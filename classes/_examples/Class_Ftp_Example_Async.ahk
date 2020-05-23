;; FTP Class Example - http://www.autohotkey.com/forum/viewtopic.php?t=73544
;; Asynchronous Mode example

;; 1. PLEASE READ ASYNCHRONOUS MODE NOTES IN THE DOCUMENTATION FIRST!
;; 2. All output is logged to the stdout, can be only seen if debugger attached
;;    or you run it with Scite4Autohotkey
;; 3. The script can do any other work while waiting for AsyncRequestComplete notification

;;== USER SETTINGS ===============
Server     := "ftp.autohotkey.net"
UserName   := "my_username"
Password   := "my_password"
UploadFile := "D:\Temp\Test.zip"
;;== END USER SETTINGS ===========

; initialize and get reference to FTP object
ftp1 := new FTP(1) ; 1 = Async mode, use default callback function
ftp1 ? TTip("InternetOpen Success") : Quit("Could not load module/InternetOpen")

OnExit, Cleanup


; connect to FTP server
ftp1.Open(Server, UserName, Password) ? TTip("Connected to FTP") : Quit(ftp1.LastError)

; create a new directory 'testing'
ftp1.CreateDirectory("testing")
SleepWhile() ? TTip("Created Directory ""testing""") : Msg("Create Directory Failed")

; set the current directory to 'root/testing'
ftp1.SetCurrentDirectory("testing")
SleepWhile() ? TTip("SetCurrentDirectory ""testing""") : Msg("SetCurrentDirectory failed!")

; upload this script file
SplitPath,UploadFile,RemoteFile,,fExt
ftp1.PutFile(UploadFile, RemoteFile)
SleepWhile() ? TTip("PutFile success!") : Msg("PutFile failed!")

; rename script to 'testscript.ahk'
ftp1.RenameFile(RemoteFile, (NewLocalFile := "Delete_Me." . fExt))
SleepWhile() ? TTip("RenameFile success!") : Msg("RenameFile failed!")

IfExist, % NewLocalFile
  FileDelete, % NewLocalFile

; retrieve the file from the FTP server
ftp1.GetFile(NewLocalFile,A_ScriptDir . "\" . NewLocalFile, 0)
SleepWhile() ? TTip("GetFile success!") : Msg("GetFile failed!")

; delete the file from the FTP server
ftp1.DeleteFile(NewLocalFile)
SleepWhile() ? TTip("DeleteFile success!") : Msg("DeleteFile failed!")

; set the current directory back to the root
ftp1.SetCurrentDirectory("/") 
SleepWhile() ? TTip("SetCurrentDirectory to original path: success!") : Msg("SetCurrentDirectory failed")

; remove the directory 'testing'
ftp1.RemoveDirectory("testing")
SleepWhile() ? TTip("RemoveDirectory ""\testing\"" success!") : Msg("RemoveDirectory failed")
ExitApp

Cleanup:
; close the FTP connection, free library
ftp1 := ""  ; __Delete Called

sleep 1000 ;The request complete will not be triggered, as the last message recieved is 70 = INTERNET_STATUS_HANDLE_CLOSING
MsgBox done!
exitapp


SleepWhile() {
  global FTP
  While !FTP.AsyncRequestComplete
    sleep 50
  return (FTP.AsyncRequestComplete = 1) ? 1 : 0 ; -1 means request complete but failed, only 1 is success
}

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

#Include FTP.ahk