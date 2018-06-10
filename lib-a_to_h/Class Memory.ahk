Class Memory
{
	__New(program)
	{
		;this.pointer := this.getModuleBaseAddress(program)
		this.pointer := this.getProcessBaseAddress(program)
		WinGet, pid, PID, % program
		this.hProcess := DllCall("OpenProcess", "UInt", 24, "Int", False, "UInt", pid, "Ptr") 
	}

	__Delete()
	{
		DllCall("CloseHandle", "Ptr", this.hProcess)
	}

	; Reads the value stored at the final address of a pointer array, e.g. array := [0xDEADBEEF, 0xC, 0x4]
	; will also read a single memory address that doesnt contain any offsets e.g. array := [0xDEADBEEF]
	Read(offsets*)
	{
	    ; Remove the base address from the passed values.
	    ; Now the offsets array ONLY contains offsets!
	    base := offsets.Remove(1)
	    ; If the pointer only has one offset, then we can read the address pointed via the base and then add the offset
	    ; to find the final memory address 
	    If offsets.maxIndex() = 1
	        pointer := offsets[1] + this._Read(base) 
	    ; otherwise you need to loop and read the pointed address at each level of the pointer  
	    Else For index, offset in offsets
	    {
	        ; On the first loop we need to read the next level of the pointer - this is done by 
	        ; reading [offset + [base]] i.e. read the address pointed via base, add the offet to this value, and then read the resulting address
	        If (A_Index = 1) 
	            pointer := this._Read(offset + this._Read(base))
	        ; When the final offset is reached, we need to add this offset to the previously found (on the last loop) pointer address
	        ; to get the final memory address
	        Else If (index = offsets.MaxIndex())
	            pointer += offset
	        ; otherwise we just read the address [pointer + currentOffset]
	        Else pointer := this._Read(pointer + offset)
	    }
	    ; read the final address   
	    Return this._Read(offsets.maxIndex() ? pointer : base) ; 'offsets.maxIndex() ? pointer : base' simply determines if an actual pointer was passed to the function - i.e. it can read a memory address without offsets as well as a real pointer
	; ** If you want the function to simply return the final address (rather than reading the value) use the below commented line 
	; return offsets.maxIndex() ? pointer : base
	}

	_Read(address)
	{
	    DllCall("ReadProcessMemory", "Ptr", this.hProcess, "Ptr", address, "Ptr*", result, "Ptr", 4, "Ptr",0) ;originally UINT*
	    Return result
	}

	getProcessBaseAddress(WindowTitle, windowMatchMode := "3")    ;WindowTitle can be anything ahk_exe ahk_class etc
	{
	    if (windowMatchMode && A_TitleMatchMode != windowMatchMode)
	    {
	        mode := A_TitleMatchMode ; This is a string and will not contain the 0x prefix
	        StringReplace, windowMatchMode, windowMatchMode, 0x ; remove hex prefix as SetTitleMatchMode will throw a run time error. This will occur if integer mode is set to hex and matchmode param is passed as an number not a string.
	        SetTitleMatchMode, %windowMatchMode%    ;mode 3 is an exact match
	    }
	    WinGet, hWnd, ID, %WindowTitle%
	    if mode
	        SetTitleMatchMode, %mode%    ; In case executed in autoexec
	    if !hWnd
	        return ; return blank failed to find window
	    return DllCall(A_PtrSize = 4     ; If DLL call fails, returned value will = 0
	        ? "GetWindowLong"
	        : "GetWindowLongPtr"
	        , "Ptr", hWnd, "Int", -6, A_Is64bitOS ? "Int64" : "UInt")  
	        ; For the returned value when the OS is 64 bit use Int64 to prevent negative overflow when AHK is 32 bit and target process is 64bit 
	        ; however if the OS is 32 bit, must use UInt, otherwise the number will be huge (however it will still work as the lower 4 bytes are correct)      
	        ; Note - it's the OS bitness which matters here, not the scripts/AHKs
	}   

	getModuleBaseAddress(program, module := "")
	{
	    WinGet, pid, pid, %program%
	    if pid                              ; PROCESS_QUERY_INFORMATION + PROCESS_VM_READ 
	        hProc := DllCall("OpenProcess", "UInt", 0x0400 | 0x0010 , "Int", 0, "UInt", pid)
	    else return -2
	    if !hProc
	        return -3
	    if (A_PtrSize = 4) ; AHK 32bit
	    {
	        DllCall("IsWow64Process", "Ptr", hProc, "Int*", result)
	        if !result 
	            return -5, DllCall("CloseHandle","Ptr",hProc)  ; AHK is 32bit and target process is 64 bit, this function wont work 
	    }
	    if (module = "")
	    {        
	        VarSetCapacity(mainExeNameBuffer, 2048 * (A_IsUnicode ? 2 : 1))
	        DllCall("psapi\GetModuleFileNameEx", "Ptr", hProc, "UInt", 0
	                    , "Ptr", &mainExeNameBuffer, "UInt", 2048 / (A_IsUnicode ? 2 : 1))
	        mainExeFullPath := StrGet(&mainExeNameBuffer)
	        ; mainExeName = main executable module of the process (will include full directory path)
	    }
	    size := VarSetCapacity(lphModule, 4)
	    loop 
	    {
	        DllCall("psapi\EnumProcessModules", "Ptr", hProc, "Ptr", &lphModule
	                , "UInt", size, "UInt*", reqSize)
	        if ErrorLevel
	            return -4, DllCall("CloseHandle","Ptr",hProc) 
	        else if (size >= reqSize)
	            break
	        else 
	            size := VarSetCapacity(lphModule, reqSize)    
	    }
	    VarSetCapacity(lpFilename, 2048 * (A_IsUnicode ? 2 : 1))
	    loop % reqSize / A_PtrSize ; sizeof(HMODULE) - enumerate the array of HMODULEs
	    {
	        DllCall("psapi\GetModuleFileNameEx", "Ptr", hProc, "Ptr", numget(lphModule, (A_index - 1) * A_PtrSize)
	                , "Ptr", &lpFilename, "UInt", 2048 / (A_IsUnicode ? 2 : 1))
	        ; module will contain directory path as well e.g C:\Windows\syswow65\GDI32.dll
	        moduleFullPath := StrGet(&lpFilename) 
	        SplitPath, moduleFullPath, fileName ; strips the path so = GDI32.dll
	        if (module = "" && mainExeFullPath = moduleFullPath) || (module != "" && module = filename)
	        {
	            VarSetCapacity(MODULEINFO, A_PtrSize = 4 ? 12 : 24)
	            DllCall("psapi\GetModuleInformation", "Ptr", hProc, "Ptr", numget(lphModule, (A_index - 1) * A_PtrSize)
	                , "Ptr", &MODULEINFO, "UInt", A_PtrSize = 4 ? 12 : 24)
	            return numget(MODULEINFO, 0, "Ptr"), DllCall("CloseHandle","Ptr",hProc)
	        }
	    }
	    return -1, DllCall("CloseHandle","Ptr",hProc) ; not found
	}
}
