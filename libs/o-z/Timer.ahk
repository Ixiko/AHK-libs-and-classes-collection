;{ Timer
; Fanatic Guru
; 2014 04 10
;
; FUNCTION to Create and Manage Timers
;
;------------------------------------------------
;
; Method:
;   Timer(Name of Timer, Options)
;   All times are in milliseconds and use A_TickCount which is milliseconds since computer boot up
;
;   Parameters:
;   1) {Name of Timer} A Unique Name for Timer to Create or Get Information About
;   2) {Option = {Number}} Set Period of Timer, creates or resets existing timer to period
;      {Option = R or RESET} Reset existing timer
;      {Option = U or UNSET} Unset existing timer ie. remove from Timer array
;      {Option = D or DONE} Return true or false if timer is done and period has passed
;      {Option = S or START} Return start time of timer
;      {Option = F or FINISH} Return finish time of timer
;      {Option = L or LEFT} Return time left of timer, will return a negative number if timer is done
;      {Option = N or NOW} Return time now
;      {Option = P or PERIOD} Return period of timer ie. duration, span, length
;      {Option = E or ELAPSE} Return elapse time since timer started
;      Optional, Default = "D"
;
; Returns:
;   Creates or Returns Information About Timer Based on Options
;   Timer() refreshes all timers which updates the information in the Timer array
;
; Global:
;   Timer.{Timer Name}.Start|Finish|Period|Done|Left|Now|Elapse
;     Creates a global array called Timer that contains all the timer information at the time of last function call
;	  To use a variable to retrieve Timer information use [] array syntax
;     Timer[Variable_Name,"Left"]
;   Timer_Count = number of Timers created
;	  Variables contain the information the last time function was called
;	  To obtain current information either call the Timer specifically by Name of Timer or use Timer() to update all variables
;
; Examples:
;   Timer("Cooldown",8000)		; <-- Creates a Timer named Cooldown with an 8 second period
;   Timer("Cooldown")			; <-- Returns True if Timer is Done, False if not Done
;   Timer("Cooldown,"L")		; <-- Returns updated time Left on Timer
;   Timer(VariableName,30000)		; <-- Creates A Timer named the contents of VariableName with a 30 second period
;
;   When Name of Timer = Cooldown
;   Timer.Cooldown.Period		; <-- Variable created by Function that contains Period (Duration) of Timer named Cooldown
;   Timer.Cooldown.Start		; <-- Variable created by Function that contains internal clock time when Timer Started
;   Timer.Cooldown.Finish		; <-- Variable created by Function that contains internal clock time when Timer will Finish
;   Timer.Cooldown.Now			; <-- Variable created by Function that contains internal clock time last time function was called
;   Timer.Cooldown.Done			; <-- Variable created by Function that contains Done status last time function was called
;   Timer.Cooldown.Left			; <-- Variable created by Function that contains time Left last time function was called
;   Timer.Cooldown.Elapse		; <-- Variable created by Function that contains Elapse time since start of timer and last time function was called
;   Timer["Cooldown","Period"]		; <-- Equivalent to above . array syntax but works better if using Variable to replace literal strings
;
;   For index, element in Timer		; <-- Useful for accessing information for all timers stored in the array Timer 
;
;	It is important to understand that () are used to call the function and [] are used to access global variables created by function
;	The function can be used for many applications without ever accessing the variable information
;	I find it useful to have access to these variables outside the function so made them Global but they could probably be made Static
;
Timer(Timer_Name := "", Timer_Opt := "D")
{
	static
	global Timer, Timer_Count
	if !Timer
		Timer := {}
	if (Timer_Opt = "U" or Timer_Opt = "Unset")
		if IsObject(Timer[Timer_Name])
		{
			Timer.Remove(Timer_Name)
			Timer_Count --=
			return true
		}
		else
			return false
	if RegExMatch(Timer_Opt,"(\d+)",Timer_Match)
	{
		if !(Timer[Timer_Name,"Start"])
			Timer_Count += 1
		Timer[Timer_Name,"Start"] := A_TickCount
		Timer[Timer_Name,"Finish"] := A_TickCount + Timer_Match1
		Timer[Timer_Name,"Period"] := Timer_Match1
	}
	if RegExMatch(Timer_Opt,"(\D+)",Timer_Match)
		Timer_Opt := Timer_Match1
	else
		Timer_Opt := "D"
	if (Timer_Name = "")
	{
		for index, element in Timer
			Timer(index)
		return
	}
	if (Timer_Opt = "R" or Timer_Opt = "Reset")
	{
		Timer[Timer_Name,"Start"] := A_TickCount
		Timer[Timer_Name,"Finish"] := A_TickCount + Timer[Timer_Name,"Period"]
	}
	Timer[Timer_Name,"Now"] := A_TickCount
	Timer[Timer_Name,"Left"] := Timer[Timer_Name,"Finish"] - Timer[Timer_Name,"Now"]
	Timer[Timer_Name,"Elapse"] := Timer[Timer_Name,"Now"] - Timer[Timer_Name,"Start"]
	Timer[Timer_Name,"Done"] := true
	if (Timer[Timer_Name,"Left"] > 0)
		Timer[Timer_Name,"Done"] := false
	if (Timer_Opt = "D" or Timer_Opt = "Done")
		return Timer[Timer_Name,"Done"]
	if (Timer_Opt = "S" or Timer_Opt = "Start")
		return Timer[Timer_Name,"Start"]
	if (Timer_Opt = "F" or Timer_Opt = "Finish")
		return Timer[Timer_Name,"Finish"]
	if (Timer_Opt = "L" or Timer_Opt = "Left")
		return Timer[Timer_Name,"Left"]
	if (Timer_Opt = "N" or Timer_Opt = "Now")
		return Timer[Timer_Name,"Now"]
	if (Timer_Opt = "P" or Timer_Opt = "Period")
		return Timer[Timer_Name,"Period"]
	if (Timer_Opt = "E" or Timer_Opt = "Elapse")
		return Timer[Timer_Name,"Elapse"]
}
;}