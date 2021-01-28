; #Include WatchDirectory.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
#Persistent

OnExit,Exit
WatchDirectory("C:\Windows",1)
SetTimer,WatchFolder,100
Return

WatchFolder:
    WatchDirectory("RegisterChanges")
Return

RegisterChanges(action,folder,file){
    static
    #1:="New File", #2:="Deleted", #3:="Modified", #4:="Renamed From", #5:="Renamed To"
    ToolTip % #%Action% "`n" folder . (SubStr(folder,0)="\" ? "" : "\") . file
}   

Exit:
    WatchDirectory()
ExitApp
