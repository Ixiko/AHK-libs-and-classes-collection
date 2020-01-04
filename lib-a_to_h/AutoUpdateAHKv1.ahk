autoUpdateAHK(path:="", dl:=True, install:=True, openCLog:=True){
    ; Doesnt actually work since it compares the running v2 with old v1 versions!
    if A_IsCompiled
        return -2
    RegexMatch(download_toVar("https://autohotkey.com/download/1.1/version.txt"),"^\d+\.\d+\.\d+(\.\d+)?$",v)
    if !v
        return -1
    else if v<=A_AhkVersion {
        if install AND FileExist("ahk.exe") { ;Last run was an update
            path:=FileExist(path)?path: A_ScriptDir "\..\.."  ;If path doesnt exist, go back 2 directories of the scriptdir (.../AHK/Scripts/This_Script -> .../AHK)
           ,FileMove("ahk.exe", path "\AutoHotkey_" v "_setup.exe", False) ;Dont replace
           ,FileDelete("ahk.exe") ;If exe still exists
           ,Toast.show({title:{text:"AHK Updated"}, life:(openHelp?500:0)})
            if openCLog {
                SplitPath(A_AhkPath,, path)
               ,Run("C:\Windows\hh.exe mk:@MSITStore:" path "\AutoHotkey.chm::/docs/AHKL_ChangeLog.htm")
            }
            return 2
        }
        else return 0
    }

    Toast.show({title:{text:"AHK v" v " Available"}, life:dl?500:0})
    if dl {
        download_toFile("https://autohotkey.com/download/ahk-install.exe","ahk.exe")
       ,Toast.show({title:{text:"AHK v" v " Downloaded"}, life:install?500:0})
        if install
            Run("*RunAs ahk.exe /s /r /IsHostApp")
    }

    return 1
}