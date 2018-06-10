/*

Plugin            : DumpHistory()
Purpose           : Export history to plain text file
Version           : 1.0
CL3 version       : 1.32
*/

DumpHistory:
DumpHistoryOutput:=""
Gui, Search:Submit, Destroy
for k, v in history
	{
	 If CBProgram
	 	DumpHistoryOutput .= v.icon "`n"
	 If CBText
	 	DumpHistoryOutput .= v.text "`n`n-------------------------------------`n`n"
	 FileDelete, % DumpFileName
	 FileAppend, % DumpHistoryOutput, % DumpFileName
	}
Return

DumpHistory()	{
	Gui, Search:Destroy
	Gui, Search:+AlwaysOnTop
	Gui, Search:Add, Checkbox, vCBText checked, Export Text
	Gui, Search:Add, Checkbox, vCBProgram, Export Source (program)
	Gui, Search:Add, Edit, vDumpFileName w200, history%A_Now%.txt
	Gui, Search:Add, Button, gDumpHistory default, Export
	Gui, Search:Show,Center, Export CL3 Clipboard History
	}
	
