; --- demo 2 ---
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance,Force
SetWorkingDir,%A_ScriptDir%  ; Ensures a consistent starting directory.

#Include C:\dev\autohotkey_libs\Class_Console.ahk
 
Class_Console("VariableList",100,100,400,600,"Variable List")
VariableList.log("Variable List:This is working")
VariableList.show()
VariableList.log(VariableList.debug("vars"))
Class_Console("b",511,100,400,600,"Example")
b.show()
b.log(a.pull() "`n`nB:This is also")
Sleep,3000
C:="*** THIS VAR IS NEW!!!!!!!!!!!!!!!!!! ***"
a.update("lines")
Sleep,5000
a:=""
return
Esc::
    critical
    exitapp
return
