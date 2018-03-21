; ===============================================================================================================================
; Create a mini dump file of a process
; ===============================================================================================================================

MiniDump(ProcessID, FileName, DumpType := 0)
{
    if !(hProc := DllCall("OpenProcess", "uint", 0x0450, "int", 0, "uint", ProcessID, "ptr"))
        throw Exception("OpenProcess failure", -1)
    if !(hFile := DllCall("CreateFile", "str", FileName, "uint", 0xC0000000, "uint", 3, "ptr", 0, "uint", 2, "uint", 0, "ptr", 0, "ptr"))
        throw Exception("Failed to create a file", -1)
    if !(DllCall("dbghelp.dll\MiniDumpWriteDump", "ptr", hProc, "uint", ProcessID, "ptr", hFile, "int", DumpType, "ptr", 0, "ptr", 0, "ptr", 0))
        throw Exception("Failed to create a mini dump", -1)
    return 1, DllCall("CloseHandle", "ptr", hFile) && DllCall("CloseHandle", "ptr", hProc)
}

; ===============================================================================================================================

OwnPID   := DllCall("GetCurrentProcessId")
FileName := A_Hour "_" A_Min "_" A_Sec "-Dumped.dmp"

MiniDump(OwnPID, FileName)