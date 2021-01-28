#NoEnv
#Include %A_ScriptDir%\Function_DictionaryDatabase.ahk
SetBatchLines,-1
DDBD() ;initialize DDBD

DDBD(@MyDB:="@MyDB","create",ErrorLevel:=1)

%@MyDB%(1,"Hello")
MsgBox % %@MyDB%(1)
ThreadID:=Thread("Thread:ThreadEnd")
WinWaitActive, ahk_class #32770
WinWaitClose

%@MyDB%(1,"New Value")
Thread("ShowData","ahkLabel",ThreadID)
WinWaitActive, ahk_class #32770
WinWaitClose

DDBD() ;terminate usage of DDB()
ExitApp

Thread:
@MyDB=@MyDB
DDBD()
ShowData:
MsgBox % %@MyDB%(1)
Return
ThreadEnd:
Return