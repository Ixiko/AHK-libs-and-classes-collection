WakeUp(Year, Month, Day, Hour, Minute, Hibernate, Resume, Name) {

	;BOSKNOP's CODE
	;http://www.autohotkey.com/forum/topic11620.html
	;Awaits duetime, then returns to the caller (like some sort of "sleep until duetime").
	;If the computer is in hibernate or suspend mode
	;at duetime, it will be reactivated (hardware support provided)
	;Parameters: Year, Month, Day, Hour, Minute together produce duetime
	;Hibernate: If Hibernate=1, the function hibernates the computer. If Hibernate=2 the computer is set to
	;         suspend-mode
	;Resume: If Resume=1, the system is restored from power save mode at due time
	;Name: Arbitrary name for the timer

    duetime:=GetUTCFileTime(Year, Month, Day, Hour, Minute)

    Handle:=DLLCall("CreateWaitableTimer","char *", 0,"Int",0,"Str",name, "UInt")

    DLLCall("CancelWaitableTimer","UInt",handle)

    DLLCall("SetWaitableTimer"
          ,"Uint", handle
          ,"Int64*", duetime        ;duetime must be in UTC-file-time format!
          ,"Int", 1000
          ,"uint",0
          ,"uint",0
          ,"int",resume)


    ;Hibernates the computer, depending on variable "Hibernate":
    If Hibernate=1       ;Hibernate
        {
        DllCall("PowrProf\SetSuspendState", "int", 1, "int", 0, "int", 0)
        }

    If Hibernate=2      ;Suspend
       {
       DllCall("PowrProf\SetSuspendState", "int", 0, "int", 0, "int", 0)
       }
    Signal:=DLLCall("WaitForSingleObject"
            ,"Uint", handle
            ,"Uint",-1)

    DllCall("CloseHandle", uint, Handle)   ;Closes the handle

}
