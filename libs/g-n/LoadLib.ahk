LoadLib(name, exe:="") {
    if (exe = "")
        exe := A_AhkPath
    libs := [A_ScriptDir "\Lib\", A_MyDocuments "\AutoHotkey\Lib\", exe "\..\Lib\"]
    for i, lib in libs {
        if FileExist(lib name ".ahk")
            return LoadFile(lib name ".ahk", exe, -2)
    }
}