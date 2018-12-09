class LLMouse {
	static MOUSEEVENTF_MOVE := 0x1
	static MOUSEEVENTF_WHEEL := 0x800
	; ======================= Functions for the user to call ============================
	; Move the mouse
	; All values are Signed Integers (Whole numbers, Positive or Negative)
	; x		- How much to move in the x axis. + is right, - is left
	; y		- How much to move in the y axis. + is down, - is up
	Move(x, y, times := 1, rate := 1){
		this._MouseEvent(times, rate, this.MOUSEEVENTF_MOVE, x, y)
	}
	
	; Move the wheel
	; dir	- Which direction to move the wheel. 1 is up, -1 is down
	Wheel(dir, times := 1, rate := 10){
		static WHEEL_DELTA := 120
		this._MouseEvent(times, rate, this.MOUSEEVENTF_WHEEL, , , dir * WHEEL_DELTA)
	}
	
	; ============ Internal functions not intended to be called by end-users ============
	_MouseEvent(times, rate, dwFlags := 0, dx := 0, dy := 0, dwData := 0){
		res:=LLMouse.getTimerResolution() ; Calling this every event since it may be changed by other applications, as far as I understand.
		Loop % times {
			dt:=0
			DllCall("mouse_event", uint, dwFlags, int, dx ,int, dy, uint, dwData, int, 0)
			if (A_Index != times && rate)	; Do not delay after last send, or if rate is 0
				LLMouse.accurateSleep(rate,res)
		}
	}
	accurateSleep(t,res)
	{
		static F := LLMouse.getQPF()
		Critical
		dt:=0
		if (t > res){
			DllCall("QueryPerformanceCounter", "Int64P", sT1)
			DllCall("Sleep", "Int", t-res)
			DllCall("QueryPerformanceCounter", "Int64P", sT2)
			dt:=(sT2-sT1)*1000/F
		}
		t-=dt
		DllCall( "QueryPerformanceCounter", Int64P,pTick ), cTick := pTick
		While( pTick-cTick <t*F/1000 ) {
			DllCall( "QueryPerformanceCounter", Int64P,pTick )
			Sleep -1 ; Not sure about this one.
		}
		Return 
	}
	
	getTimerResolution()
	{
		DllCall("ntdll.dll\NtQueryTimerResolution", "UPtr*", MinimumResolution, "UPtr*", MaximumResolution, "UPtr*", CurrentResolution)
		return Ceil(CurrentResolution/10000) ; Resolutions are reported as 100-nanoseconds
	}
	
	getQPF()
	{
		DllCall( "QueryPerformanceFrequency", Int64P,F)
		return F
	}
	
}