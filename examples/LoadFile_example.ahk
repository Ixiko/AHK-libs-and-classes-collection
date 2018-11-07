#NoEnv
SetBatchLines, -1
#include %A_ScriptDir%\..\LoadFile.ahk


;lib := LoadLib("GUID_and_UUID")
;MsgBox % lib.CreateGUID_Unicode()
;MsgBox % lib.G["A_WorkingDir"]

lib := LoadLib("ProcessInfo")
MsgBox % lib.GetCurrentProcessID()
Process, Exist, opera.exe
ProcessID:= ErrorLevel
MsgBox % ProcessID "`n" lib.GetProcessThreadCount(ProcessID)
;MsgBox % lib.G["A_WorkingDir"]