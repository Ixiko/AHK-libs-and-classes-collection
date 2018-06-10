;--V1.1   Written by AmA-- 
;--V1.1.1 Written by Maupa
;~ 		ReadMemoryPointer
;~ 		WriteMemoryPointer

OpenMemoryfromProcess(process,right=0x1F0FFF)
{
Process,Exist,%process%
PID = %ErrorLevel%
HWND := DllCall("OpenProcess","Uint",right,"int",0,"int",PID)
return HWND
}

OpenMemoryfromTitle(title,right=0x1F0FFF)
{
WinGet,PID,PID,%title%
HWND := DllCall("OpenProcess","Uint",right,"int",0,"int",PID)
return HWND
}

CloseMemory(hwnd)
{
return DllCall("CloseHandle", "int", hwnd)
}

WriteMemory(hwnd,address,writevalue,datatype="int",length=4,offset=0)
{
VarSetCapacity(finalvalue,length, 0)
NumPut(writevalue,finalvalue,0,datatype)
return DllCall("WriteProcessMemory","Uint",hwnd,"Uint",address+offset,"Uint",&finalvalue,"Uint",length,"Uint",0)
}

ReadMemory(hwnd,address,datatype="int",length=4,offset=0)
{
VarSetCapacity(readvalue,length, 0)
DllCall("ReadProcessMemory","Uint",hwnd,"Uint",address+offset,"Str",readvalue,"Uint",length,"Uint *",0)
finalvalue := NumGet(readvalue,0,datatype)
return finalvalue
}

ReadMemoryPointer(hProcess, baseAddress, dataTyp="int", length=4, offsets*) {
    for i, offset in offsets
		baseAddress := ReadMemory(hProcess, baseAddress, "ptr", 8) + offset
	return ReadMemory(hProcess, baseAddress, dataTyp, length)
}

WriteMemoryPointer(hProcess, baseAddress, writeValue=0, dataTyp="int", length=4, offsets*) {
    for i, offset in offsets
		baseAddress := ReadMemory(hProcess, baseAddress, "ptr", 8) + offset
	return WriteMemory(hProcess, baseAddress, writeValue, dataTyp, length)
}

SetPrivileg(privileg = "SeDebugPrivilege")
{
success := DllCall("advapi32.dll\LookupPrivilegeValueA","uint",0,"str",privileg,"int64*",luid_SeDebugPrivilege)
if (success = 1) && (ErrorLevel = 0)
{
returnval = 0
}
else
{
returnval = %ErrorLevel%
}
return %returnval%
}

Suspendprocess(hwnd)
{
return DllCall("ntdll\NtSuspendProcess","uint",hwnd)
}

Resumeprocess(hwnd)
{
return DllCall("ntdll\NtResumeProcess","uint",hwnd)
}