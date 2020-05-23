/*  
Reduces the memory consumption of a process
Author          : heresy (Thanks!)
Link            : http://www.autohotkey.com/forum/viewtopic.php?t=71966
Original post   : http://www.autohotkey.com/forum/topic32876.html
*/

EmptyMem(PID=0){
	If not PID									; If there is no PID,
		PID := DllCall("GetCurrentProcessId")	;	get the pid of the script
	h := DllCall("OpenProcess", "UInt", 0x001F0FFF, "Int", 0, "Int", PID)
	DllCall("SetProcessWorkingSetSize", "UInt", h, "Int", -1, "Int", -1)
	DllCall("CloseHandle", "Int", h)
}