LongOperationUpdateForSendKeys(ByRef msg,ByRef tick_now){
    static g_script:=ScriptStruct(),g:=GlobalStruct(),PM_NOREMOVE:=0
	tick_now := A_TickCount
	if tick_now - g_script.mLastPeekTime > g.PeekFrequency{
		if PeekMessage(msg[], NULL, 0, 0, PM_NOREMOVE)
			SleepWithoutInterruption(-1)
		g_script.mLastPeekTime := tick_now := A_TickCount
	}
}