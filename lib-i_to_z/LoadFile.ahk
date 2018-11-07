/*
LoadFile(Path [, EXE])
Loads a script file as a child process and returns an object
which can be used to call functions or get/set global vars.
Path:
The path of the script.
EXE:
The path of the AutoHotkey executable (defaults to A_AhkPath).
Requirements:
- AutoHotkey v1.1.17+ http://ahkscript.org/download/
- ObjRegisterActive http://goo.gl/wZsFLP
- CreateGUID http://goo.gl/obfmDc
Version: 1.0
*/
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
LoadFile(path, exe:="", exception_level:=-1) {
ObjRegisterActive(client := {}, guid := CreateGUID())
code =
(LTrim
LoadFile.Serve("%guid%")
#include %A_LineFile%
#include %path%
)
try {
exe := """" (exe="" ? A_AhkPath : exe) """"
exec := ComObjCreate("WScript.Shell").Exec(exe " /ErrorStdOut *")
exec.StdIn.Write(code)
exec.StdIn.Close()
while exec.Status = 0 && !client._proxy
Sleep 10
if exec.Status != 0 {
err := exec.StdErr.ReadAll()
ex := Exception("Failed to load file", exception_level)
if RegExMatch(err, "Os)(.*?) \((\d+)\) : ==> (.*?)(?:\s*Specifically: (.*?))?\R?$", m)
ex.Message .= "`n`nReason:`t" m[3] "`nLine text:`t" m[4] "`nFile:`t" m[1] "`nLine:`t" m[2]
throw ex
}
}
finally
ObjRegisterActive(client, "")
return client._proxy
}

CreateGUID() {
VarSetCapacity(pguid, 16, 0)
if !(DllCall("ole32.dll\CoCreateGuid", "ptr", &pguid)) {
size := VarSetCapacity(sguid, (38 << !!A_IsUnicode) + 1, 0)
if (DllCall("ole32.dll\StringFromGUID2", "ptr", &pguid, "ptr", &sguid, "int", size))
return StrGet(&sguid)
}
return ""
}

class LoadFile {
Serve(guid) {
try {
client := ComObjActive(guid)
client._proxy := new this.Proxy
client := ""
}
catch ex {
stderr := FileOpen("**", "w")
stderr.Write(format("{} ({}) : ==> {}`n Specifically: {}"
, ex.File, ex.Line, ex.Message, ex.Extra))
stderr.Close() ; Flush write buffer.
ExitApp
}
; Rather than sleeping in a loop, make the script persistent
; and then return so that the #included file is auto-executed.
Hotkey IfWinActive, %guid%
Hotkey vk07, #Persistent, Off
#Persistent:
}
class Proxy {
__call(name, args*) {
if (name != "G")
return %name%(args*)
}
G[name] { ; x.G[name] because x[name] via COM invokes __call.
get {
global
return ( %name% )
}
set {
global
return ( %name% := value )
}
}
__delete() {
ExitApp
}
}
}