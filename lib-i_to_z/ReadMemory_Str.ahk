; Automatically closes handle when a new (or null) program is indicated
; Otherwise, keeps the process handle open between calls that specify the
; same program. When finished reading memory, call this function with no
; parameters to close the process handle i.e: "Closed := ReadMemory_Str()"

; the lengths probably depend on the encoding style, but for my needs they are always 1

;//function ReadMemory_Str 
ReadMemory_Str(MADDRESS=0, PROGRAM = "", length = 0 , terminator = "")  ; "" = Null
{ 
    Static OLDPROC, ProcessHandle

   If (PROGRAM != OLDPROC)
   {
        if ProcessHandle
        {
            closed := DllCall("CloseHandle", "UInt", ProcessHandle)
            ProcessHandle := 0, OLDPROC := ""
            if !PROGRAM
                return closed
        }
        if PROGRAM
        {
            WinGet, pid, pid, % OLDPROC := PROGRAM
            if !pid 
               return "Process Doesn't Exist", OLDPROC := "" ;blank OLDPROC so subsequent calls will work if process does exist
            ProcessHandle := DllCall("OpenProcess", "Int", 16, "Int", 0, "UInt", pid)   
        }
   }
    ; length depends on the encoding too
    VarSetCapacity(Output, length ? length : 1, 0)
    If !length ; read until terminator found or something goes wrong/error
	{
        Loop
        { 
            success := DllCall("ReadProcessMemory", "UInt", ProcessHandle, "UInt", MADDRESS++, "str", Output, "Uint", 1, "Uint *", 0) 
            if (ErrorLevel or !success || Output = terminator) 
                break
            teststr .= Output 
		} 
	}		
	Else ; will read X length
	{
        DllCall("ReadProcessMemory", "UInt", ProcessHandle, "UInt", MADDRESS, "str", Output, "Uint", length, "Uint *", 0) 
        ;  Loop % length
        ;     teststr .= chr(NumGet(Output, A_Index-1, "Char"))      
        teststr := StrGet(&Output, length, "UTF-8")
	}
	return teststr 	 
}