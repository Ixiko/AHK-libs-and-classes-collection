; These arent mine

MemoryOpenFromPID(PID, Privilege=0x1F0FFF)
{
	HWND := DllCall("OpenProcess", "Uint", Privilege, "int", 0, "int", PID)
	return HWND
}

MemoryOpenFromName(Name, Privilege=0x1F0FFF)
{
	Process, Exist, %Name%
	PID := ErrorLevel
	Return MemoryOpenFromPID(PID, Privilege)
}

MemoryOpenFromTitle(title, privilege=0x1F0FFF)
{
	WinGet, PID, PID, %title%
	Return MemoryOpenFromPID(PID, Privilege)
}

MemoryClose(hwnd)
{
	return DllCall("CloseHandle", "int", hwnd)
}

MemoryWrite(hwnd, address, writevalue, datatype="int", length=4, offset=0)
{
	VarSetCapacity(finalvalue, length, 0)
	NumPut(writevalue, finalvalue, 0, datatype)
	return DllCall("WriteProcessMemory", "Uint", hwnd, "Uint", address+offset, "Uint", &finalvalue, "Uint", length, "Uint", 0)
}

MemoryRead(hwnd, address, datatype="int", length=4, offset=0)
{
	VarSetCapacity(readvalue,length, 0)
	DllCall("ReadProcessMemory","Uint",hwnd,"Uint",address+offset,"Str",readvalue,"Uint",length,"Uint *",0)
	finalvalue := NumGet(readvalue,0,datatype)
	return finalvalue
}

MemoryWritePointer(hwnd, base, writevalue, datatype="int", length=4, offsets=0, offset_1=0, offset_2=0, offset_3=0, offset_4=0, offset_5=0, offset_6=0, offset_7=0, offset_8=0, offset_9=0)
{
	B_FormatInteger := A_FormatInteger 
	Loop, %offsets%
	{
		baseresult := MemoryRead(hwnd,base)
		Offset := Offset_%A_Index%
		SetFormat, integer, h
		base := baseresult + Offset
		SetFormat, integer, d
	}
	SetFormat, Integer, %B_FormatInteger%
	return MemoryWrite(hwnd,address,writevalue,datatype,length)
}

MemoryReadPointer(hwnd, base, datatype="int", length=4, offsets=0, offset_1=0, offset_2=0, offset_3=0, offset_4=0, offset_5=0, offset_6=0, offset_7=0, offset_8=0, offset_9=0)
{
	B_FormatInteger := A_FormatInteger 
	Loop, %offsets%
	{
		baseresult := MemoryRead(hwnd,base)
		Offset := Offset_%A_Index%
		SetFormat, integer, h
		base := baseresult + Offset
		SetFormat, integer, d
	}
	SetFormat, Integer, %B_FormatInteger%
	return MemoryRead(hwnd,base,datatyp,length)
}

MemoryGetAddrPID(PID, DllName)
{
    VarSetCapacity(me32, 548, 0)
    NumPut(548, me32)
    snapMod := DllCall("CreateToolhelp32Snapshot", "Uint", 0x00000008, "Uint", PID)
    If (snapMod = -1)
        Return 0
    If (DllCall("Module32First", "Uint", snapMod, "Uint", &me32))
	{
		Loop
       	{
            If (!DllCall("lstrcmpi", "Str", DllName, "UInt", &me32 + 32)) {
                DllCall("CloseHandle", "UInt", snapMod)
                Return NumGet(&me32 + 20)
            }
        }
		Until !DllCall("Module32Next", "Uint", snapMod, "UInt", &me32)
    }
    DllCall("CloseHandle", "Uint", snapMod)
    Return 0
}

MemoryGetAddrName(Name, DllName)
{
	Process, Exist, %Name%
	PID := ErrorLevel
	Return MemoryGetAddrPID(PID, DllName)
}

MemoryGetAddrTitle(Title, DllName)
{
	WinGet, PID, PID, %Title%
	Return MemoryGetAddrPID(PID, DllName)
}

SetPrivilege(privilege = "SeDebugPrivilege")
{
	success := DllCall("advapi32.dll\LookupPrivilegeValueA","uint",0,"str",privilege,"int64*",luid_SeDebugPrivilege)
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

SuspendProcess(hwnd)
{
	return DllCall("ntdll\NtSuspendProcess","uint",hwnd)
}

ResumeProcess(hwnd)
{
	return DllCall("ntdll\NtResumeProcess","uint",hwnd)
}