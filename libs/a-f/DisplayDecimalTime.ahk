; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=6&t=65474
; Author:	jeeswg
; Date:
; for:     	AHK_L

/*

	#Persistent
	ListLines, Off

	;display decimal time ('metric time') and 24-hour time
	;options for Progress command:
	vOptProgress := "zh0 b1 c0 fs18 x1000 y100 w150" ;border + left-aligned text
	vOpt := "DT"
	;vOpt := "DTU"
	;vOpt := "TD"
	;vOpt := "TDU"
	oFunc := Func("DisplayDecimalTime").Bind(vOptProgress, vOpt)
	SetTimer, % oFunc, 10
	return

*/

;==================================================

;display decimal time ('metric time') and 24-hour time

;Decimal time - Wikipedia
;https://en.wikipedia.org/wiki/Decimal_time
;Decimal time is the representation of the time of day using units which are decimally related.
;This term is often used specifically to refer to the time system used in France for a few years beginning in 1792 during the French Revolution,
;which divided the day into 10 decimal hours, each decimal hour into 100 decimal minutes and each decimal minute into 100 decimal seconds,
;as opposed to the more familiar UTC time standard, which divides the day into 24 hours, each hour into 60 minutes and each minute into 60 seconds.

;Metric time - Wikipedia
;https://en.wikipedia.org/wiki/Metric_time
;Metric time is the measure of time intervals using the metric system.
;The modern SI system defines the second as the base unit of time, and forms multiples and submultiples with metric prefixes such as kiloseconds and milliseconds.
;Other units of time: minute, hour, and day, are accepted for use with SI, but are not part of it.
;Metric time is a measure of time intervals, while decimal time is a means of recording time of day.

;[clip from The Simpsons: They Saved Lisa's Brain]
;['decimal time' rather than 'metric time']
;Metric time - YouTube
;https://www.youtube.com/watch?v=rP3nZ13AULs

;n seconds = n * (125/108) decimal seconds
;1 day = 86400 seconds = 100000 decimal seconds
;1 hour = 3600 seconds = 4166.666667 decimal seconds
;1 minute = 60 seconds = 69.444444 decimal seconds
;1 second = 1.157407 decimal seconds

;n decimal seconds = n * 0.864 seconds
;1 day = 100000 decimal seconds = 86400 seconds
;1 decimal hour = 10000 decimal seconds = 8640 seconds = 2.4 hours = 2 hours 24 minutes
;1 decimal minute = 100 decimal seconds = 86.4 seconds = 1.44 minutes = 1 minute 26.4 seconds
;1 decimal second = 0.864 seconds

;==================================================


;==================================================

;vOpt: (blank): local time
;vOpt: U: UTC time
;vOpt: D: display decimal time
;vOpt: T: display 24-hour time
;note: the order of D/T will be reflected in the display
DisplayDecimalTime(vOptProgress, vOpt:="DT") {

	local
	static vIsInit := 0, hCtl := 0, vTextLast := ""
	static vScriptPID := DllCall("kernel32\GetCurrentProcessId", "UInt")
	vText := ""
	Loop Parse, vOpt
	{
		if (A_LoopField = "D")		{
			vTemp := InStr(vOpt, "U") ? "U" : ""
			vText .= DecimalTimeNow(vTemp) "`r`n"
		}

		if (A_LoopField = "T")		{
			vDate := InStr(vOpt, "U") ? A_NowUTC : A_Now
			FormatTime, vDate, % vDate, HH:mm:ss
			vText .= vDate "`r`n"
		}
	}
	vText := RTrim(vText, "`r`n")
	if !vIsInit	{
		Progress, % vOptProgress, % vText
		vIsInit := 1
		vTextLast := vText
		return
	}
	if !hCtl
		ControlGet, hCtl, Hwnd,, Static1, % "ahk_class AutoHotkey2 ahk_pid " vScriptPID
	if !(vTextLast = vText)
		ControlSetText,, % vText, % "ahk_id " hCtl
	vTextLast := vText
}

;==================================================

DecimalTimeNow(vOpt:=""){
	local
	VarSetCapacity(SYSTEMTIME, 16, 0)
	if InStr(vOpt, "U") ;UTC
		DllCall("kernel32\GetSystemTime", "Ptr",&SYSTEMTIME)
	else ;local
		DllCall("kernel32\GetLocalTime", "Ptr",&SYSTEMTIME)
	vIntervals := 0
	DllCall("kernel32\SystemTimeToFileTime", "Ptr",&SYSTEMTIME, "Int64*",vIntervals)

	vMSec := Floor(vIntervals/10000) ;milliseconds since the year 1601
	vMSec := Mod(vMSec, 86400000) ;milliseconds so far today
	;vDecimalSec := Floor((vMSec/86400000) * 100000) ;equivalent to line below
	vDecimalSec := Floor(vMSec/864)
	vDecimalSec := Format("{:06}", vDecimalSec)
	return SubStr(vDecimalSec, 1, 2) ":" SubStr(vDecimalSec, 3, 2) ":" SubStr(vDecimalSec, 5, 2)
}

;==================================================