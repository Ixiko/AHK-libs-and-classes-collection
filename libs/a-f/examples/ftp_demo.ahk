; #Include ftp.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

; General settings
server = www.autohotkey.net
port = 21
username = 0
password = 0

file_to_upload = %A_ScriptName%
file_remote_path = %A_ScriptName%

file_to_download = lib/path.ahk
file_local_path = path.ahk

; Start the processes
GoSub, Upload
GoSub, Download
Return

Upload:
hConnect:=FTP_Open(Server, Port, Username, Password)
FTP_PutFile(hConnect,file_to_upload, file_remote_path)
FTP_CloseSocket(hConnect)
FTP_Close()
MsgBox Upload completed.
Return

Download:
NewFile = path.ahk
RemoteFile = lib/path.ahk
hConnect:=FTP_Open(Server, Port, Username, Password)
FTP_GetFile(hConnect,file_to_download, file_local_path)
FTP_CloseSocket(hConnect)
FTP_Close()
MsgBox Download completed.
Return