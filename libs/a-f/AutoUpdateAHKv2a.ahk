autoUpdateAHK(path:="", dl:=True, install:=True, openCLog:=False){
    if A_IsCompiled
        return -2
    RegexMatch(download_toVar("https://autohotkey.com/download/2.0/version.txt"),"^2.0-a.+$",v)
    if !(v:=v.value())
        return -1
    else if v<=A_AhkVersion {
        if install AND FileExist("ahk.zip") { ;Last run was an update
            Critical()
           ,updatePath:=path(A_AhkPath).Dir, installPath:=path(updatePath).Dir, exe:=path(A_AhkPath).FileName
           ,path:=FileExist(path)?path: A_ScriptDir "\..\.." ;If path doesnt exist, go back 2 directories of the scriptdir (.../AHK/Scripts/This_Script -> .../AHK)

           ,A_DetectHiddenWindows:=True
            if winExist("ahk_exe " installPath "\" exe)
                Msgbox("Please close all other scripts for updating AHK",, 0x1040)
            if winExist("ahk_exe " installPath "\" exe) {
                return 2
            }
            FileMove("ahk.zip", path "\AutoHotkey_" v "_setup.zip", True)
           ,FilesAndFolders_Move(updatePath "\*", installPath, True)
           ,FilesAndFolders_Copy(updatePath "\*", installPath, True)
           ,Toast.show({title:{text:"AHK Updated"}, life:(openHelp?500:0)})

            if openCLog {
                SplitPath(A_AhkPath,, path)
               ,Run("C:\Windows\hh.exe mk:@MSITStore:" installPath "\AutoHotkey.chm::/docs/ChangeLog.htm")
            }
            Run("*RunAs `"" installPath "\" exe "`" `"" A_ScriptFullPath "`"")
            ExitApp
            return 3
        }
        else return 0
    }

    Toast.show({title:{text:"AHK v" v " Available"}, life:dl?500:0})
    if dl {
        download_toFile("https://autohotkey.com/download/2.0/AutoHotkey_" v ".zip","ahk.zip")
       ,Toast.show({title:{text:"AHK v" v " Downloaded"}, life:install?500:0})
        if install {
            suspend()
            Critical()
            zip_unzip("ahk.zip", path(A_AhkPath).Dir "\update\") ; Run("*RunAs ahk.exe /s /r /IsHostApp") ;installer
            Run("*RunAs `"" path(A_AhkPath).Dir "\update\" path(A_AhkPath).FileName  "`" `"" A_ScriptFullPath "`"")
            ExitApp
        }
    }

    return 1
}