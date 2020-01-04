; https://www.autohotkey.com/boards/viewtopic.php?f=76&t=41598

;WakeTime += 1, hour
;FormatTime, WakeTime, % time, HH:mm
; MsgBox, % WakeTime


; You could put your computer in sleep or hibernation mode like this:
; SleepMode := false   ; true—hibernation, false—sleep
; DllCall("PowrProf\SetSuspendState", UInt, SleepMode, UInt, 0, UInt, 0)

AlarmClock(wakeTime)  {
   RegExMatch(wakeTime, "^(?<H>\d{1,2}):(?<M>\d{2})$", t)
   if (tH = "" || tM = "")  {
      MsgBox, Wrong wakeTime format!
      Return
   }
   secondToWake := CalcSecondsToWake(tH*3600 + tM*60)
   hTimer := DllCall("CreateWaitableTimer", Ptr, 0, UInt, 0, Str, "MyTimer", Ptr)
   DllCall("SetWaitableTimer", Ptr, hTimer, Int64P, -secondToWake*10000000, UInt, 0, Ptr, 0, Ptr, 0, UInt, 1)
   DllCall("WaitForSingleObject", Ptr, hTimer, UInt, INFINITE := 0xFFFFFFFF)
   DllCall("CloseHandle", Ptr, hTimer)
}

CalcSecondsToWake(wakeTime)  {
   nowTime := A_Hour*3600 + A_Min*60 + A_Sec
   ts1 := ts2 := 1601
   if (wakeTime < nowTime)
      ts1 += 1, d
   ts1 += wakeTime, s
   ts2 += nowTime, s
   ts1 -= ts2, s
   Return ts1
}