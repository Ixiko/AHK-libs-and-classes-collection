/*
Author: Fragman

Generic function that waits for an event to happen.

There are two main calling modes for this function:
1) It can be called to wait for an event by omitting the last parameter.
2) It can be called to mark the reception of an event by setting the last parameter to true.


Parameters:
	Parameter		- This function supports an arbitrary number of events which are indexed by this parameter. 
					  It can have any value and type, but must be the same for 1) and 2) calls belonging together.
					  References to instances of this function in the documentation are all related to the same Parameter value.
					  
	Timeout			- Time in ms until the wait is cancelled. Set to 0 for no timeout. Set to -1 to skip waiting - See next parameter.
	
	Incremental		- The amount of events that need to be received until the waiting function can return. 
	
					  If the wait is cancelled due to timeout the function returns immediately.
					  If this is the only waiting instance of the function, all expected events are cancelled.
					  If there are more waiting instances of this function, the number of events is decremented 
					  so multiple waits for independent events with different timeouts become possible.
					  
					  Leave this empty to set the number of expected events to 1 for all waiting instances. 
					  Using 1 or more will increase the current number of expected events by this value.
					  This means that the waiting function can be called multiple times and all will wait until all events are received.
					  
					  To simply add an expected event without waiting for it, use Timeout = -1.
					  
	FinishWaiting	- Leave empty to wait for an event, set to true to mark the reception of an event.
	
Returns:
Mode 1):
	1 if the wait was successful, 0 when a timeout occurs.
Mode 2):
	1 when there are instances of this function waiting for the event, 0 if no instance of this function was waiting for it.
*/
WaitForEvent(Parameter, Timeout = 0, Incremental = 0, FinishWaiting = false)
{
	static WaitQueue := {}
	static tooltip := 1
	t := ToolTip
	tooltip++
	;Mode 2): Simply set a flag that can be checked in instances of this function in mode 1).
	if(FinishWaiting)
	{
		if(!IsObject(WaitQueue[Parameter]))
			return 0
		WaitQueue[Parameter].EventCount--
		return 1
	}
	
	;Mode 1): Setup the event object for the queue
	
	;Number of events that need to be received until the function can stop waiting
	EventCount := Incremental > 0 ? (IsObject(WaitQueue[Parameter]) ? WaitQueue[Parameter].EventCount : 0) + Incremental : 1
	
	;Number of instances of this function waiting for this event.
	Waiters := IsObject(WaitQueue[Parameter]) ? WaitQueue[Parameter].Waiters : 0
	if(Timeout != -1) ;Only needs to be increased when we actually want to wait
		Waiters++
	
	WaitQueue.Insert(Parameter, {EventCount : EventCount, Waiters : Waiters})
	
	if(Timeout = -1) ;Timeout = -1: Skip waiting
		return
	
	Timeout := Timeout > 0 ? A_TickCount + Timeout : 0
	
	Loop
	{
		if(WaitQueue[Parameter].EventCount = 0) ;If no more expected events (may be caused by if above or by other instance of this function)
		{
			result := true
			break
		}
		if(Timeout && A_TickCount > Timeout)
		{
			;If this is the only instance waiting for the event, all expected events can be cancelled.
			;Otherwise just cancel the single event this instance was waiting for.
			if(WaitQueue[Parameter].Waiters != 1) 
				WaitQueue[Parameter].EventCount--
			result := false
			break
		}
		Sleep 10
	}
	WaitQueue[Parameter].Waiters--	
	if(WaitQueue[Parameter].Waiters = 0) ;When there are no more instances waiting for the event it can safely be removed
		WaitQueue.Remove(Parameter)
	return result
}

/*
Wrapper function for WaitForEvent() that raises an event.
*/
RaiseEvent(Parameter)
{
	return WaitForEvent(Parameter,"","",1)
}