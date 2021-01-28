SleepWithoutInterruption(aSleepTime){
	static g_MainThreadID,g_AllowInterruption
	if !g_MainThreadID
    g_MainThreadID:=Struct("bool",A_MemoryModule?MemoryGetProcAddress(A_MemoryModule,"g_MainThreadID"):GetProcAddress(A_ModuleHandle,"g_MainThreadID"))
		,g_AllowInterruption:=Struct("UInt",A_MemoryModule?MemoryGetProcAddress(A_MemoryModule,"g_AllowInterruption"):GetProcAddress(A_ModuleHandle,"g_AllowInterruption"))
	g_AllowInterruption.1:=false
	if g_MainThreadID.1 = GetCurrentThreadId()
		Sleep(aSleepTime)
	else
		Sleep_(aSleepTime)
	g_AllowInterruption.1:=true
}