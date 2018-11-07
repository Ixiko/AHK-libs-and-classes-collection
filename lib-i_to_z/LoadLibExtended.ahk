LoadLib(name, libs="", exe:="") {
	; a function by lexikos
	; https://autohotkey.com/boards/viewtopic.php?t=6194
	
	if (exe = "")
		exe := A_AhkPath
	libs := [A_ScriptDir "\Lib\", A_MyDocuments "\AutoHotkey\Lib\", exe "\..\Lib\"]
	if !(libs = "")
		libs :=  [libs "\", A_ScriptDir "\Lib\", A_MyDocuments "\AutoHotkey\Lib\", exe "\..\Lib\"]
	
	for i, lib in libs {
		if FileExist(lib name ".ahk")
	return LoadFile(lib name ".ahk", exe, -2)
}
}