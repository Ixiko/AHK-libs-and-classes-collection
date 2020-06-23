;~ #Include C:\dev\autohotkey_libs\Class_Console.ahk

Class_Console("a",100,100,400,435,"STDout Test")
a.show()
a.Cmd("ipconfig.exe")
Sleep,3000
a.clear()
Sleep,3000
a.CmdWait()
return
