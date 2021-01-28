; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=6&t=65474
; Author:	just me
; Date:		17.06.2019
; for:     	AHK_L

/*

	#NoEnv
	Now := A_Now
	MsgBox, 0, Metric Time, % Now . " -> " MetricTime(Now)
	ExitApp

*/


MetricTime(DateTime) { ; YYYYMMDDHH24MISS time stamp

   Seconds	:= DateTime
   Seconds	-= % (Date := SubStr(DateTime, 1, 8)), S
   Seconds	:= Round(Seconds * 100000 / 86400)
   HH      	:= Seconds // 10000
   Seconds	-= HH * 10000
   MM    	:= Seconds // 100
   Seconds	-= MM * 100
   SS      	:= Seconds

Return Format(Date . "{:02}{:02}{:02}", HH, MM, SS)
}