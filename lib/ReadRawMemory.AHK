ReadRawMemory(MADDRESS=0,PROGRAM="", byref Buffer="", BYTES=4)
{
   Static OLDPROC, ProcessHandle

   VarSetCapacity(Buffer, BYTES)

   If (PROGRAM != OLDPROC)
   {
        if ProcessHandle
          closed := DllCall("CloseHandle", "UInt", ProcessHandle), ProcessHandle := 0,  OLDPROC := ""
        if PROGRAM
        {
            WinGet, pid, pid, % OLDPROC := PROGRAM
            if !pid 
               return "Process Doesn't Exist", OLDPROC := "" ;blank OLDPROC so subsequent calls will work if process does exist
            ProcessHandle := DllCall("OpenProcess", "Int", 16, "Int", 0, "UInt", pid)   
        }
   }
    If (ProcessHandle && DllCall("ReadProcessMemory","UInt",ProcessHandle,"UInt",MADDRESS,"Ptr",&Buffer,"UInt",BYTES,"Ptr*",bytesread))
        return bytesread
    return !ProcessHandle ? "Handle Closed:" closed : "Fail"
}
