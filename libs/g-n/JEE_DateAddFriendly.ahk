; Link:   	https://www.autohotkey.com/boards/viewtopic.php?t=59825
; Author:
; Date:
; for:     	AHK_L

/*


*/

;q:: ;test DateAdd/DateDiff 'friendly' format functions
Loop, 100000
{
	;vSec1 := Random(0, 2147483647) ;2147483647 / (86400*365.25) ;around 68.04965 years
	;vSec2 := Random(0, 2147483647)
	Random, vSec1, 0, 2147483647 ;2147483647 / (86400*365.25) ;around 68.04965 years
	Random, vSec2, 0, 2147483647
	vDate1 := DateAdd(2000, vSec1, "S")
	vDate2 := DateAdd(2000, vSec1+vSec2, "S")
	vDiff := JEE_DateDiffFriendly(vDate1, vDate2)
	vDiffX := JEE_DateDiffFriendly(vDate1, vDate2, "ymd")
	vDate2X := JEE_DateAddFriendly(vDate1, vDiff)

	vDate1 := RegExReplace(vDate1, "(?<=..)..(?=.)", "$0 ")
	vDate2 := RegExReplace(vDate2, "(?<=..)..(?=.)", "$0 ")
	vDate2X := RegExReplace(vDate2X, "(?<=..)..(?=.)", "$0 ")

	;if !(vDate2 = vDate2X) ;use this to show any date pairs where diff then add doesn't return original date
	;	MsgBox, % "ERROR at A_Index:`r`n" A_Index "`r`n" vDate1 "`r`n" vDate2 "`r`n" vDate2X "`r`n" vDiff ;"`r`n" vDiffX
	MsgBox, % vDate1 "`r`n" vDate2 "`r`n" vDiff ;"`r`n" vDiffX
}
SoundBeep
ExitApp

;==================================================

;e.g. MsgBox, % JEE_DateAddFriendly(20010101, "3y")					;20040101000000
;e.g. MsgBox, % JEE_DateAddFriendly(20010101, "3y 3m 3d")			;20040404000000
;e.g. MsgBox, % JEE_DateAddFriendly(20010101, "3y 3m 3d 8h 8m 8s")	;20040404080808

;vDiff expects 1 to 6 space-separated digit sequences (any non-spaces/non-digits are ignored)
JEE_DateAddFriendly(vDate, vDiff){

	local
	static date := "date"
	vDate := FormatTime(vDate, "yyyyMMddHHmmss")
	vTemp := RegExReplace(vDiff, "[^\d ]") " 0 0 0 0 0"
	oTemp := StrSplit(vTemp, " ")
	vMonth := SubStr(vDate, 5, 2)
	if (vMonth+oTemp.2 > 12)
		vDate += (oTemp.2-12) * 100000000 + (oTemp.1+1) * 10000000000
	else
		vDate += oTemp.2 * 100000000 + oTemp.1 * 10000000000
	Loop, 3
		;if JEE_StrIsType(vDate, "date")
		if vDate is %date%
			break
		else
			vDate -= 1000000
	return DateAdd(vDate, oTemp.3*86400+oTemp.4*3600+oTemp.5*60+oTemp.6, "S")
}

;==================================================

;e.g. MsgBox, % JEE_DateDiffFriendly(20060131, 20060220)		;0y 0m 20d 0h 0m 0s
;e.g. MsgBox, % JEE_DateDiffFriendly(20060201, 20060220)		;0y 0m 19d 0h 0m 0s
;e.g. MsgBox, % JEE_DateDiffFriendly(20060504, 20070707)		;1y 2m 3d 0h 0m 0s
;e.g. MsgBox, % JEE_DateDiffFriendly(20060504, 20070707, "y")	;1y
;e.g. MsgBox, % JEE_DateDiffFriendly(20060504, 20070707, "ym")	;1y 2m
;e.g. MsgBox, % JEE_DateDiffFriendly(20060504, 20070707, "ymd")	;1y 2m 3d

;note: vFormat expects 1 to 6 characters
JEE_DateDiffFriendly(vDateA, vDateB, vFormat:="ymdhms", ByRef vIsFirstBiggerOrEqual:=1){
	local
	static date := "date"
	vDateA := FormatTime(vDateA, "yyyyMMddHHmmss")
	vDateB := FormatTime(vDateB, "yyyyMMddHHmmss")
	if !(StrLen(vDateA) = 14) || !(StrLen(vDateB) = 14)
		return
	vSec := DateDiff(vDateA, vDateB, "S")
	vIsFirstBiggerOrEqual := (vSec >= 0)
	if !vIsFirstBiggerOrEqual
		vTemp := vDateA, vDateA := vDateB, vDateB := vTemp ;swap variables
		, vSec := Abs(vSec)
	oDateA := StrSplit(RegExReplace(vDateA, "(?<=..)..(?=.)", "$0|"), "|") ;add splits: e.g. 20060504030201 -> 2006|05|04|03|02|01
	oDateB := StrSplit(RegExReplace(vDateB, "(?<=..)..(?=.)", "$0|"), "|")
	;get year difference
	vDiffYear := oDateA.1 - oDateB.1
	if (SubStr(vDateA, 5) < SubStr(vDateB, 5))
		vDiffYear--
	;get month difference
	vDiffMonth := oDateA.2 - oDateB.2
	if (vDiffMonth < 0)
		vDiffMonth += 12
	if (SubStr(vDateA, 7) < SubStr(vDateB, 7))
		if (vDiffMonth = 0)
			vDiffMonth := 11
		else
			vDiffMonth--
	;get day/hour/minute/second differences
	vDateB += vDiffYear*10000000000
	if (oDateB.2 + vDiffMonth <= 12)
		vDateB += vDiffMonth*100000000
	else
		vDateB += (vDiffMonth-12)*100000000 + 10000000000
	Loop, 3
		;if JEE_StrIsType(vDateB, "date")
		if vDateB is %date%
			break
		else
			vDateB -= 1000000
	vSec := DateDiff(vDateA, vDateB, "S")
	vDiffDay := vSec // 86400
	vDiffHour := Mod(vSec, 86400) // 3600
	vDiffMin := Mod(vSec, 3600) // 60
	vDiffSec := Mod(vSec, 60)
	vFormat := "{}" RegExReplace(vFormat, ".(?=.)", "$0 {}") ;e.g. 'ymdhms' -> '{}y {}m {}d {}h {}m {}s'
		return Format(vFormat, vDiffYear, vDiffMonth, vDiffDay, vDiffHour, vDiffMin, vDiffSec)
}

;==================================================

;/*
;commands as functions (AHK v2 functions for AHK v1) - AutoHotkey Community
;https://autohotkey.com/boards/viewtopic.php?f=37&t=29689

DateAdd(DateTime, Time, TimeUnits){
	EnvAdd DateTime, %Time%, %TimeUnits%
	return DateTime
}
DateDiff(DateTime1, DateTime2, TimeUnits){
	EnvSub DateTime1, %DateTime2%, %TimeUnits%
	return DateTime1
}
FormatTime(YYYYMMDDHH24MISS:="", Format:=""){
	local OutputVar
	FormatTime OutputVar, %YYYYMMDDHH24MISS%, %Format%
	return OutputVar
}
;*/