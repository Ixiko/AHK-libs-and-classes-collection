; #Include ini.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

; ----- User Configuration -----
ConfigFilePath := "settings.ini"


; ----- Main -----
IfNotExist, %ConfigFilePath%
    createConfigFile(ConfigFilePath)

FileRead, ini, %ConfigFilePath%
value := ini_getValue(ini, "Config", "Started")
value++
ini_replaceValue(ini, "Config", "Started", value)
updateConfigFile(ConfigFilePath, ini)

FileRead, ini, %ConfigFilePath%
value := ini_getValue(ini, "Config", "Started")
MsgBox This script was started %value% time/s.


RETURN ; End of AutoExec-section


createConfigFile(Path)
{
    Template =
    (LTrim
    [Config]
    Started=0
    )
    FileAppend, %Template%, %Path%
    Return
}


updateConfigFile(Path, ByRef Content)
{
    FileDelete, %Path%
    FileAppend, %Content%, %Path%
    Return
}