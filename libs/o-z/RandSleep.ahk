SleepRand(min,max){
    ; Time Array used by for loop
    ; hr, min, sec, ms
    msTimeA := [3600000,60000,1000,1]

    ; Split fields up
    StringSplit, minTime, min, % ":"
    StringSplit, maxTime, max, % ":"

    ; Reset random min/max values
    finalMin    := 0
    finalMax    := 0

    ; Calculate seconds for min and max time
    for index, value in msTimeA
    {
        ; finalMin and finalMax are just "total milliseconds"
        ; Each field is multiplied by the correlating amount of ms in the msTimeA array
        ; Meaning first loop is hours. So it takes the number of hours times 3600000ms
        ; which is how many ms are in an hour and adds it to the total.
        ; It continues until all hrs, min, sec, and ms are all done.
        finalMin    += (minTime%A_Index% * value)
        finalMax    += (maxTime%A_Index% * value)
    }

    ; Randomize between min and max
    Random, rSleep, % finalMin, % finalMax

    ; MsgBox % "Sleep timer set for " (rSleep/1000) " seconds."

    ; Sleep for randomized time
    Sleep, % rSleep

    return
}
