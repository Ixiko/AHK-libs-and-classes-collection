EventIsDue(fnScheduleType,fnScheduleList,fnDueHour := 0,fnValidDuration := 0,ByRef fnEventIsDue := 0,ByRef fnTriggeringScheduleEntry := "")
{
	; determines whether the current time falls within a scheduled event window
	; when fnScheduleType is Daily/D, fnValidDuration is in minutes, otherwise in hours
	; MsgBox fnScheduleType: %fnScheduleType%`nfnScheduleList: %fnScheduleList%`nfnDueHour: %fnDueHour%`nfnValidDuration: %fnValidDuration%


	; declare local, global, static variables


	Try
	{
		; set default return value
		ReturnValue := 0 ; success


		; validate parameters
		If fnScheduleType not in Daily,D,Weekly,W,Monthly,M
			Throw, Exception("fnScheduleType was not valid")
		fnScheduleType := SubStr(fnScheduleType,1,1) ; trim to only first letter
		
		If fnScheduleType in D
		{
			Loop, Parse, fnScheduleList, CSV
			{
				ScheduleTime := "19000101" A_LoopField
				If ScheduleTime is not time
					Throw, Exception("fnScheduleList contains an invalid time")
			}
		}
		
		ScheduleList := ""
		If fnScheduleType in W
		{
			Loop, Parse, fnScheduleList, CSV
			{
				If A_LoopField not in Sun,Mon,Tue,Wed,Thu,Fri,Sat,Sunday,Monday,Tuesday,Wednesday,Thursday,Friday,Saturday
					Throw, Exception("fnScheduleList contains an invalid weekday")
				ScheduleList .= (ScheduleList ? "," : "") SubStr(A_LoopField,1,3) ; recompile list in three letter format
			}
			fnScheduleList := ScheduleList
		}
		
		If fnScheduleType in M
		{
			Loop, Parse, fnScheduleList, CSV
			{
				If A_LoopField is not integer
					Throw, Exception("fnScheduleList contains an non-integer value")
				If !(A_LoopField > 0 && A_LoopField < 32)
					Throw, Exception("fnScheduleList contains an out-of-range value")
				ScheduleList .= (ScheduleList ? "," : "") Abs(A_LoopField) ; recompile list in integer format
			}
			fnScheduleList := ScheduleList
		}
		
		fnDueHour := fnDueHour ? Abs(Mod(fnDueHour,24)) : 0 ; becomes integer
		If fnDueHour not in 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23
			Throw, Exception("fnDueHour contains an out-of-range value")
		
		fnValidDuration := Abs(fnValidDuration) ; convert to integer
		If fnValidDuration is not number
			Throw, Exception("fnValidDuration is an invalid value")


		; initialise variables
		Now := A_Now ; for consistent comparisons
		fnEventIsDue := 0
		ScheduleList := ""


		; create a list of schedule times in reverse chronological order
		If fnScheduleType in D
		{
			Loop, Parse, fnScheduleList, CSV
			{
				ThisScheduleTimeToday     := A_YYYY A_MM A_DD   SubStr(A_LoopField "000000",1,6)
				ThisScheduleTimeYesterday := A_YYYY A_MM A_DD-1 SubStr(A_LoopField "000000",1,6)
				ThisScheduleTime := ThisScheduleTimeToday
				If (ThisScheduleTime > Now)
					ThisScheduleTime := ThisScheduleTimeYesterday
				ScheduleList .= ThisScheduleTime "`n"
			}
		}
		
		If fnScheduleType in W,M
		{
			FormatTime, ThisTimeStamp, %Now%, yyyyMMddHH'0000'
			Loop, % 7*24*(fnScheduleType = "W" ? 1 : 31)
			{
				FormatTime, ThisTimeStampsHour   , %ThisTimeStamp%, H
				FormatTime, ThisTimeStampsWeekday, %ThisTimeStamp%, % (fnScheduleType = "W" ? "ddd" : "d")
				
				If ThisTimeStampsWeekday in %fnScheduleList%
					If (ThisTimeStampsHour = fnDueHour)
						ScheduleList .= ThisTimeStamp "`n"
				ThisTimeStamp := DateAdd(-1,"HH",ThisTimeStamp)
			}
		}
		
		StringTrimRight, ScheduleList, ScheduleList, 1 ; remove trailing delimiter
		Sort, ScheduleList, D`nNRU
		
		
		; for each time, determine if Now is within the valid duration
		TimeUnits := "HH"
		If fnScheduleType in D
			TimeUnits := "MI"
		Loop, Parse, ScheduleList, `n, `r
		{
			ThisScheduleTime := A_LoopField
			FormatTime, ThisListItem , %ThisScheduleTime%, % (fnScheduleType = "D" ? "HHmm" : fnScheduleType = "W" ? "ddd" : "MM")
			TimeDifference := DateDiff(TimeUnits,ThisScheduleTime,Now)
			If (TimeDifference < fnValidDuration)
			{
				fnEventIsDue := 1
				fnTriggeringScheduleEntry := fnScheduleType " " ThisListItem
				Break
			}
		}

	}
	Catch, ThrownValue
	{
		ReturnValue := !ReturnValue
		CatchHandler(A_ThisFunc,ThrownValue.Message,ThrownValue.What,ThrownValue.Extra,ThrownValue.File,ThrownValue.Line,0,0,0)
	}
	Finally
	{
	}

	; return
	Return ReturnValue
}


/* ; testing
; SomeScheduleType  := "Daily" ; Daily,D,Weekly,W,Monthly,M
; SomeScheduleList  := "0002,0208,0120,1012,1736,0900,2330" ; Sun,Mon,Tue,Wed,Thu,Fri,Sat,Sunday,Monday,Tuesday,Wednesday,Thursday,Friday,Saturday
; SomeValidDuration := "120"

; SomeScheduleType  := "Weekly" ; Daily,D,Weekly,W,Monthly,M
; SomeScheduleList  := "Mon,Tue,Wed,Saturday" ; Sun,Mon,Tue,Wed,Thu,Fri,Sat,Sunday,Monday,Tuesday,Wednesday,Thursday,Friday,Saturday
; SomeDueHour       := "01"
; SomeValidDuration := "2"

; SomeScheduleType  := "Monthly" ; Daily,D,Weekly,W,Monthly,M
; SomeScheduleList  := "05,10,15,20,25,30" ; Sun,Mon,Tue,Wed,Thu,Fri,Sat,Sunday,Monday,Tuesday,Wednesday,Thursday,Friday,Saturday
; SomeDueHour       := "02"
; SomeValidDuration := "2"

EventIsDue := 0
TriggeringScheduleEntry := ""
ReturnValue := EventIsDue(SomeScheduleType,SomeScheduleList,SomeDueHour,SomeValidDuration,EventIsDue,TriggeringScheduleEntry)
; ReturnValue := EventIsDue("Daily","0200",,120,TimesheetEntryDue)
MsgBox, EventIsDue`n`nReturnValue: %ReturnValue%`n`nEventIsDue: %EventIsDue%`nTriggeringScheduleEntry: %TriggeringScheduleEntry%
*/