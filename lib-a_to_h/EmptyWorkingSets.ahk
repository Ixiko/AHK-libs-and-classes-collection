EmptyWorkingSets(pids*){
	if !pid
		WinGetPidList,pids
	for k,pid in pids
			DllCall("SetProcessWorkingSetSize", "UInt", hProc:=DllCall("OpenProcess","UInt",0x001F0FFF,"Int",0,"Int",pid,"PTR"), "Int", -1, "Int", -1)
			,DllCall("CloseHandle", "Int", hProc)
}