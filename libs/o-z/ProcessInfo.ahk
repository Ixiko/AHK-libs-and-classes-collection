GetCurrentProcessID()	{
		Return DllCall("GetCurrentProcessId")  ; http://msdn2.microsoft.com/ms683180.aspx
	}

GetCurrentParentProcessID()	{
		Return GetParentProcessID(GetCurrentProcessID())
	}

GetProcessName(ProcessID)	{
		Return GetProcessInformation(ProcessID, "Str", 260 * (A_IsUnicode ? 2 : 1), 32 + A_PtrSize)  ; TCHAR szExeFile[MAX_PATH]
	}

GetParentProcessID(ProcessID)	{
		Return GetProcessInformation(ProcessID, "UInt *", 8, 20 + A_PtrSize)  ; DWORD th32ParentProcessID
	}

GetProcessThreadCount(ProcessID)	{
		Return GetProcessInformation(ProcessID, "UInt *", 8, 16 + A_PtrSize)  ; DWORD cntThreads
	}

GetProcessInformation(ProcessID, CallVariableType, VariableCapacity, DataOffset)	{
		static PE32_size := 8 * 4 + A_PtrSize + 260 * (A_IsUnicode ? 2 : 1)
		hSnapshot := DLLCall("CreateToolhelp32Snapshot", "UInt", 2, "UInt", 0)  ; TH32CS_SNAPPROCESS = 2
  If (hSnapshot >= 0)
  {
	
	VarSetCapacity(PE32, PE32_size, 0)  ; PROCESSENTRY32 structure -> http://msdn2.microsoft.com/ms684839.aspx
	DllCall("ntdll.dll\RtlFillMemoryUlong", "Ptr", &PE32, "UInt", 4, "UInt", PE32_size)  ; Set dwSize
	VarSetCapacity(th32ProcessID, 4, 0)
	DllCall("Process32First" (A_IsUnicode ? "W" : ""), "Ptr", hSnapshot, "Ptr", &PE32)
	If (DllCall("Kernel32.dll\Process32First" (A_IsUnicode ? "W" : ""), "Ptr", hSnapshot, "Ptr", &PE32))  ; http://msdn2.microsoft.com/ms684834.aspx
	  Loop
	  {
		DllCall("RtlMoveMemory", "Ptr*", th32ProcessID, "Ptr", &PE32 + 8, "UInt", 4)  ; http://msdn2.microsoft.com/ms803004.aspx
		If (ProcessID = th32ProcessID)
		{
		  VarSetCapacity(th32DataEntry, VariableCapacity, 0)
		  
		  DllCall("RtlMoveMemory", CallVariableType, th32DataEntry, "Ptr", &PE32 + DataOffset, "UInt", VariableCapacity)
		  DllCall("CloseHandle", "Ptr", hSnapshot)  ; http://msdn2.microsoft.com/ms724211.aspx
		  Return th32DataEntry  ; Process data found
		}
		If not DllCall("Process32Next" (A_IsUnicode ? "W" : ""), "Ptr", hSnapshot, "Ptr", &PE32)  ; http://msdn2.microsoft.com/ms684836.aspx
		  Break
	  }
	DllCall("CloseHandle", "Ptr", hSnapshot)
  }
  Return  ; Cannot find process
	}

GetModuleFileNameEx(ProcessID)  {; modIfied version of shimanov's function	
	DetectHiddenWindows, On
  If A_OSVersion in WIN_95, WIN_98, WIN_ME
    Return GetProcessName(ProcessID)
 
  ; #define PROCESS_VM_READ           (0x0010)
  ; #define PROCESS_QUERY_INFORMATION (0x0400)
  hProcess := DllCall( "OpenProcess", "UInt", 0x10|0x400, "Int", False, "UInt", ProcessID)
  If (ErrorLevel or hProcess = 0)
    Return
  FileNameSize := 260 * (A_IsUnicode ? 2 : 1)
  VarSetCapacity(ModuleFileName, FileNameSize, 0)
  CallResult := DllCall("Psapi.dll\GetModuleFileNameEx", "Ptr", hProcess, "Ptr", 0, "Str", ModuleFileName, "UInt", FileNameSize)
  DllCall("CloseHandle", "Ptr", hProcess)
  Return ModuleFileName
	}