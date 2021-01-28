;; http://www.autohotkey.com/board/topic/77272-close-all-ahk-scripts-except-one/


/*
wbemFlagForwardOnly=0x20
wbemFlagBidirectional=0x0
wbemFlagReturnImmediately=0x10
wbemFlagReturnWhenComplete=0x0
wbemQueryFlagPrototype=0x2
wbemFlagUseAmendedQualifiers=0x2
 
KeepScript := ["Script 1.ahk", "Script 2.ahk"]
KeepScript.Insert(A_ScriptName)
 
Query := "Select ProcessId, CommandLine from Win32_Process where name = 'Autohotkey.exe'"
Flags := wbemFlagForwardOnly | wbemFlagReturnImmediately
 
for process in ComObjGet("winmgmts:").ExecQuery(Query, "WQL", Flags)
{
for index, script in KeepScript
if InStr(Process.CommandLine, script)
continue 2
process, close, % process.ProcessId
}

*/


/*
keepIT := "NameOfScriptToMantainActive.ahk"

for process in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process where name = 'Autohotkey.exe' and not CommandLine like '%" keepIT "%' ")

   process, close, % process.ProcessId
   
   
*/
