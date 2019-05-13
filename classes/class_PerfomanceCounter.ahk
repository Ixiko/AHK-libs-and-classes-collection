
class PerformanceCounter{
	;This class implements an object oriented interface to the system's performance counter.
	
	;Get the frequency of the system's performance counter and store it in a class variable to 
	;eliminate .dll call overhead.
	static __frequency := PerformanceCounter.__initialiaze_frequency()
	__initialiaze_frequency(){
		DllCall("QueryPerformanceFrequency", "Int64*", frequency)
		return frequency
	}
	
	query(){
		;Returns the current count of the performance counter.
		
		DllCall("QueryPerformanceCounter", "Int64*", count)
		return count
	}

	frequency[]{
		get{
			;The frequency, in hertz, of the performance counter.
			
			return this.__frequency
		}
	}
}

class PerformanceTimer{
	;This class implements a timer based on the system's performance counter.  Depending on the
	;system it has a precision on the order of microseconds.
	
	__started := false
	__paused := false
	__elapsed_counts := 0
	
	start(){
		;Starts the timer.  Also unpauses the timer if it has been paused.
		
		;Make sure that the timer has not already been started, or is paused.
		if (this.__started and not this.__paused){
			return
		}
		this.__started := true
		this.__paused := false
		
		this.__start_count := PerformanceCounter.query()
	}
	
	pause(){
		;Pauses the timer without resetting it.  Call start() to restart the timer.
		
		elapsed_counts := PerformanceCounter.query() - this.__start_count
		
		;Make sure that the timer is not already paused.
		if (this.__paused){
			return
		}
		this.__paused := true
		
		this.__elapsed_counts += elapsed_counts
	}
	
	reset(){
		;Stops the timer and resets the elapsed time to 0.
		
		this.__started := false
		this.__paused := false
		this.__elapsed_counts := 0
	}
	
	elapsed[]{
		get{
			elapsed_counts := PerformanceCounter.query() - this.__start_count
			
			;If the timer has started, and is not paused, add the number of counts elapsed since
			;start() was last called.
			if (this.__started and not this.__paused){
				this.__elapsed_counts += elapsed_counts
			}
			
			;Convert the elapsed counts to microseconds.  Parenthesis enforce the order of
			;operations that will result in the least loss of precision.  See:
			;https://msdn.microsoft.com/en-us/library/windows/desktop/dn553408%28v=vs.85%29.aspx#examples_for_acquiring_time_stamps
			return ((this.__elapsed_counts * 1000000) // PerformanceCounter.frequency)
		}
	}
}
