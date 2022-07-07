; by Drugwash 2011-2015
; AHK screws up certain bytes when saving a variable to file
; this is a replacement for AHK's built-in function FileAppend
; var is a variable (buffer) name or a buffer's address

FileCreate(name, ByRef var="", off="0", sz="")
{
Global Ptr, PtrP
;hFile := DllCall("CreateFile", "Str", name, "UInt", 0x40000000, "UInt", 0, "UInt", 0, "UInt", 2, "UInt", 0, "UInt", 0)
hFile := DllCall("CreateFile", "Str", name, "UInt", 0x40000000, "UInt", 1, "UInt", 0, "UInt", 4, "UInt", 0, "UInt", 0)
if var is integer
	{
	if i := DllCall("lstrlenA", Ptr, var) != j := DllCall("lstrlenW", Ptr, var)
		i := j*2
	DllCall("WriteFile", Ptr, hFile, Ptr, var, "UInt", (sz ? sz : i), PtrP, realLen, "UInt", 0)
	}
else if (VarSetCapacity(var) <> "")
	DllCall("WriteFile", Ptr, hFile, Ptr, &var+off, "UInt", (sz ? sz : VarSetCapacity(var)), PtrP, realLen, "UInt", 0)
else msgbox, blank variable!
DllCall("CloseHandle", Ptr, hFile)
return (sz==realLen)
}
