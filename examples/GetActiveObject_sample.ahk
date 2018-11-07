#include %A_ScriptDir%\..\GetActiveObjects.ahk

;for name, obj in GetActiveObjects()
;list .= name " -- " ComObjType(obj, "Name") "`n"
;MsgBox %list%

for pid, dte in GetActiveObjects("Scite.Application")
list .= pid " -- " dte.Solution.FullName "`n"
MsgBox %list%