GetUTCFiletime(Year, Month, Day, Hour, Min) { ;Converts "System Time" (readable time format) to "UTC File Time" (number of 100-nanosecond intervals since January 1, 1601 in  Coordinated Universal Time UTC)

	DayOfWeek=0
    Second=00
    Millisecond=00

    ;Converts System Time to Local File Time:
    VarSetCapacity(MyFiletime  , 64, 0)
    VarSetCapacity(MySystemtime, 32, 0)

    InsertInteger(Year,       MySystemtime,0)
    InsertInteger(Month,      MySystemtime,2)
    InsertInteger(DayOfWeek,  MySystemtime,4)
    InsertInteger(Day,        MySystemtime,6)
    InsertInteger(Hour,       MySystemtime,8)
    InsertInteger(Min,        MySystemtime,10)
    InsertInteger(Second,     MySystemtime,12)
    InsertInteger(Millisecond,MySystemtime,14)

    DllCall("SystemTimeToFileTime", Str, MySystemtime, UInt, &MyFiletime)
    LocalFiletime := ExtractInteger(MyFiletime, 0, false, 8)

    ;Converts local file time to a file time based on the Coordinated Universal Time (UTC):
    VarSetCapacity(MyUTCFiletime  , 64, 0)
    DllCall("LocalFileTimeToFileTime", Str, MyFiletime, UInt, &MyUTCFiletime)
    UTCFiletime := ExtractInteger(MyUTCFiletime, 0, false, 8)

    Return UTCFileTime
}
