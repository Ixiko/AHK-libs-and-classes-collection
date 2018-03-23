; searchNames comma separated list. If these processes exist, then 
; they will be retrieved in the array
getProcesses(ignoreSelf := True, searchNames := "")
{
	s := 100096  ; 100 KB will surely be HEAPS

	array := []
	PID := DllCall("GetCurrentProcessId")
	; Get the handle of this script with PROCESS_QUERY_INFORMATION (0x0400)
	h := DllCall("OpenProcess", "UInt", 0x0400, "Int", false, "UInt", PID, "Ptr")
	; Open an adjustable access token with this process (TOKEN_ADJUST_PRIVILEGES = 32)
	DllCall("Advapi32.dll\OpenProcessToken", "Ptr", h, "UInt", 32, "PtrP", t)
	VarSetCapacity(ti, 16, 0)  ; structure of privileges
	NumPut(1, ti, 0, "UInt")  ; one entry in the privileges array...
	; Retrieves the locally unique identifier of the debug privilege:
	DllCall("Advapi32.dll\LookupPrivilegeValue", "Ptr", 0, "Str", "SeDebugPrivilege", "Int64P", luid)
	NumPut(luid, ti, 4, "Int64")
	NumPut(2, ti, 12, "UInt")  ; enable this privilege: SE_PRIVILEGE_ENABLED = 2
	; Update the privileges of this process with the new access token:
	r := DllCall("Advapi32.dll\AdjustTokenPrivileges", "Ptr", t, "Int", false, "Ptr", &ti, "UInt", 0, "Ptr", 0, "Ptr", 0)
	DllCall("CloseHandle", "Ptr", t)  ; close this access token handle to save memory
	DllCall("CloseHandle", "Ptr", h)  ; close this process handle to save memory

	hModule := DllCall("LoadLibrary", "Str", "Psapi.dll")  ; increase performance by preloading the library
	s := VarSetCapacity(a, s)  ; an array that receives the list of process identifiers:
	DllCall("Psapi.dll\EnumProcesses", "Ptr", &a, "UInt", s, "UIntP", r)
	Loop, % r // 4  ; parse array for identifiers as DWORDs (32 bits):
	{
	   currentPID := NumGet(a, A_Index * 4, "UInt")
	   if (ignoreSelf && currentPID = PID)
			continue ; this is own script
	   ; Open process with: PROCESS_VM_READ (0x0010) | PROCESS_QUERY_INFORMATION (0x0400)
	   h := DllCall("OpenProcess", "UInt", 0x0010 | 0x0400, "Int", false, "UInt", currentPID, "Ptr")
	   if !h
	      continue
	   VarSetCapacity(n, s, 0)  ; a buffer that receives the base name of the module:
	   e := DllCall("Psapi.dll\GetModuleBaseName", "Ptr", h, "Ptr", 0, "Str", n, "UInt", A_IsUnicode ? s//2 : s)
	   if !e    ; fall-back method for 64-bit processes when in 32-bit mode:
	      if e := DllCall("Psapi.dll\GetProcessImageFileName", "Ptr", h, "Str", n, "UInt", A_IsUnicode ? s//2 : s)
	         SplitPath n, n
	   DllCall("CloseHandle", "Ptr", h)  ; close process handle to save memory
	  	if searchNames
	  	{
			  if n not in %searchNames%
			  	continue	  		
	  	}
	   if (n && e)  ; if image is not null add to list:
	   		array.insert({"Name": n, "PID": currentPID})
	}
	DllCall("FreeLibrary", "Ptr", hModule)  ; unload the library to free memory
	return array
}