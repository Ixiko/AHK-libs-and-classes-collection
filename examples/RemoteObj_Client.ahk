#NoEnv
SetBatchLines, -1

#Include <Socket>
#Include <Jxon>
#Include ..\RemoteObj.ahk

Remote := new RemoteObjClient(["127.0.0.1", 1337])

if !Remote.Index
	Remote.Index := 1

Remote.AddButton(Remote.Index++ ". Run Notepad", "Run", "notepad")
Remote.AddButton(Remote.Index++ ". Show MsgBox", "MsgBox", "Hello!")
ExitApp
return


