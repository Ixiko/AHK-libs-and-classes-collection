; returns elapsed time in ms - very accurate
; Can keep track of multiple events
; doesn't use any resources (cpu time) between function calls

; Start a timer:
;	timerID := stopwatch() ; call function with no parameters to get a timer ID
;	
; Retrieve elapsed time: 
; 	time := stopwatch(timerID, mode)
; 		mode = 1 ; remove timer
; 		mode = -1 ; reset timer to 0
; 		mode = 0 ; do not alter timer (leave it 'running' and just get the the time elapsed)


stopwatch(itemId := 0, mode := 1)
{
;	static F := DllCall("QueryPerformanceFrequency", "Int64P", F) * F , aTicks := [], runID := 0
	static F := DllCall("QueryPerformanceFrequency", "Int64P", F) * F , runID := 0

	if (itemId = 0) ; = 0 so if user accidentally passes an empty or invalid ID-variable function returns -1	
		return ++runID, DllCall("QueryPerformanceCounter", "Int64P", S), aTicks[runID] := S

	if aTicks.hasKey(itemId)
	{
		DllCall("QueryPerformanceCounter", "Int64P", now)
		timeElapsed := (now - aTicks[itemId]) / F * 1000

		if (mode > 0)
			aTicks.remove(itemId, "")
		else if (mode < 0)
			DllCall("QueryPerformanceCounter", "Int64P", S), aTicks[itemId] := S
		return timeElapsed
	}
	else ; a blank variable or non-existent ID was passed
		return -1	

}








/*
; returns elapsed time in ms 
; Can keep track of multiple events
stopwatch(itemId := 0, removeUsedItem := True)
{
	static F := DllCall("QueryPerformanceFrequency", "Int64P", F) * F , aTicks := [], runID := 0

	if (itemId = 0) ; so if user accidentally passes an empty ID variable function returns -1
	{
		DllCall("QueryPerformanceCounter", "Int64P", S), aTicks[++runID] := S
		return runID
	}
	else 
	{
		if aTicks.hasKey(itemId)
		{
			DllCall("QueryPerformanceCounter", "Int64P", End)
			return (End - aTicks[itemId]) / F * 1000, removeUsedItem ? aTicks.remove(itemId, "") : ""
		}
		else return -1
	}
}

*/