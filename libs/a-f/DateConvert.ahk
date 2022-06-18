; Title:
; Link:   	https://raw.githubusercontent.com/tdalon/ahk/4c605a85098b38d6fd59744df76c75124194003b/Lib/DateConv.ahk
; Author:
; Date:
; for:     	AHK_L

/*
   RegTimeZones := GetTimeZones()


*/


DateConvZ(sDate){
global RegTimeZones
; Convert ConNext Event date to standard Format 2020-01-31T23:30:00.000Z -> 2020-01-31 23:00:00

; Convert Zulu date to Date format
sUTCDate := RegExReplace(sDate,"\.000.*","") ; independent of time zone
sUTCDate := StrReplace(sUTCDate,"T"," ")
Chars := A_Space . "-:"
Loop, Parse, % Chars
   sUTCDate := StrReplace(sUTCDate,A_LoopField,"")

sSysDate := ConvertTime(sUTCDate,"UTC","*Local Time*",RegTimeZones)
FormatTime sSysDate, %sSysDate%, yyyy-MM-dd HH:mm:ss
;MsgBox %sDate% -> %sSysDate%

;FormatTime sSysDate, %sSysDate%, yyyy-MM-dd HH:mm:ss

return sSysDate
}

; https://autohotkey.com/board/topic/68856-sample-dealing-with-time-zones-ahk-l/
; ----------------------------------------------------------------------------------------------------------------------
GetTimeZones() {
   ; Get the "Time Zones" entries from registry
   RegRoot := "HKEY_LOCAL_MACHINE"
   RegKey  := "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Time Zones"
   RegTimeZones := {}
   Loop, %RegRoot%, %RegKey%, 2
   {
      RegRead, DSP, %RegRoot%, %RegKey%\%A_LoopRegName%, Display
      RegRead, TZI, %RegRoot%, %RegKey%\%A_LoopRegName%, TZI
      RegTimeZones[A_LoopRegName] := [DSP, TZI]
   }
   Return RegTimeZones
}
; ----------------------------------------------------------------------------------------------------------------------
ConvertTime(TimeStamp, TimeZoneFrom, TimeZoneTo, ByRef TimeZones) {
   ;MsgBox %TimeZoneFrom% %TimeZoneTo%
   TimeStamp += 0, S
   VarSetCapacity(LOCTIME, 16, 0)    ; SYSTEMTIME (local)
   VarSetCapacity(SYSTIME, 16, 0)    ; SYSTEMTIME (system\UTC)
   NumPut(SubStr(TimeStamp,  1, 4), LOCTIME,  0, "UShort")
   NumPut(SubStr(TimeStamp,  5, 2), LOCTIME,  2, "UShort")
   NumPut(SubStr(TimeStamp,  7, 2), LOCTIME,  6, "UShort")
   NumPut(SubStr(TimeStamp,  9, 2), LOCTIME,  8, "UShort")
   NumPut(SubStr(TimeStamp, 11, 2), LOCTIME, 10, "UShort")
   NumPut(SubStr(TimeStamp, 13, 2), LOCTIME, 12, "UShort")
   PTZIF := 0
   PTZIT := 0
   If (TimeZoneFrom <> "*Local Time*") {
      TZIF := ""
      TZI2TIMEZONEINFORMATION(TimeZones[TimeZoneFrom][2], TZIF)
      PTZIF := &TZIF
   }
   If (TimeZoneTo <> "*Local Time*") {
      TZIT := ""
      TZI2TIMEZONEINFORMATION(TimeZones[TimeZoneTo][2], TZIT)
      PTZIT := &TZIT
   }
   DllCall("Kernel32\TzSpecificLocalTimeToSystemTime", "Ptr", PTZIF, "Ptr", &LOCTIME, "Ptr", &SYSTIME)
   DllCall("Kernel32\SystemTimeToTzSpecificLocalTime", "Ptr", PTZIT, "Ptr", &SYSTIME, "Ptr", &LOCTIME)
   Year  := SubStr("000" . NumGet(LOCTIME, 0, "Short"), -3)
   Month := SubStr("0" . NumGet(LOCTIME, 2, "Short"), -1)
   Day   := SubStr("0" . NumGet(LOCTIME, 6, "Short"), -1)
   Hour  := SubStr("0" . NumGet(LOCTIME, 8, "Short"), -1)
   Min   := SubStr("0" . NumGet(LOCTIME, 10, "Short"), -1)
   Sec   := SubStr("0" . NumGet(LOCTIME, 12, "Short"), -1)
   Return Year . Month . Day . Hour . Min . Sec
}
; ----------------------------------------------------------------------------------------------------------------------
TZI2TIMEZONEINFORMATION(TZI, ByRef TIMEZONEINFORMATION) {
   ; Convert registry TZI values into TIMEZONEINFORMATION struct
   Bias := 0      ; Bias
   StdD := 68     ; StandardDate
   StdB := 84     ; StandardBias
   DltD := 152    ; DaylightDate
   DltB := 168    ; DaylightBias
   VarSetCapacity(TIMEZONEINFORMATION, 172, 0)
   IR := 1
   IT := Bias     ; Bias ------------------------------------------------
   Loop, 4 {
      NumPut("0x" . SubStr(TZI, IR, 2), TIMEZONEINFORMATION, IT, "UChar")
      IR += 2
      IT++
   }
   IT := StdB     ; StandardBias ----------------------------------------
   Loop, 4 {
      NumPut("0x" . SubStr(TZI, IR, 2), TIMEZONEINFORMATION, IT, "UChar")
      IR += 2
      IT++
   }
   IT := DltB     ; DaylightBias ----------------------------------------
   Loop, 4 {
      NumPut("0x" . SubStr(TZI, IR, 2), TIMEZONEINFORMATION, IT, "UChar")
      IR += 2
      IT++
   }
   IT := StdD     ; StandardDate ----------------------------------------
   Loop, 16 {
      NumPut("0x" . SubStr(TZI, IR, 2), TIMEZONEINFORMATION, IT, "UChar")
      IR += 2
      IT++
   }
   IT := DltD     ; DaylightDate ----------------------------------------
   Loop, 16 {
      NumPut("0x" . SubStr(TZI, IR, 2), TIMEZONEINFORMATION, IT, "UChar")
      IR += 2
      IT++
   }
}