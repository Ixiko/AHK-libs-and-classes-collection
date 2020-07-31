;
; AutoHotkey Version: 1.0.47.06
; Platform:       WinXP
; Author:         Yonken <yonken@163.com>
;
; Wrappers of Windows Apis Reside In Kernel32.dll

; Do NOT modify following variables!

PROCESS_TERMINATE				:= 0x0001
PROCESS_CREATE_THREAD		:= 0x0002
PROCESS_SET_SESSIONID			:= 0x0004
PROCESS_VM_OPERATION			:= 0x0008
PROCESS_VM_READ					:= 0x0010
PROCESS_VM_WRITE				:= 0x0020
PROCESS_DUP_HANDLE				:= 0x0040
PROCESS_CREATE_PROCESS		:= 0x0080
PROCESS_SET_QUOTA				:= 0x0100
PROCESS_SET_INFORMATION		:= 0x0200
PROCESS_QUERY_INFORMATION	:= 0x0400
PROCESS_SUSPEND_RESUME		:= 0x0800
PROCESS_ALL_ACCESS				:= (STANDARD_RIGHTS_REQUIRED | SYNCHRONIZE |  0xFFF)

PAGE_NOACCESS						:= 0x01     
PAGE_READONLY						:= 0x02     
PAGE_READWRITE					:= 0x04     
PAGE_WRITECOPY					:= 0x08     
PAGE_EXECUTE						:= 0x10     
PAGE_EXECUTE_READ				:= 0x20     
PAGE_EXECUTE_READWRITE		:= 0x40     
PAGE_EXECUTE_WRITECOPY		:= 0x80     
PAGE_GUARD							:= 0x100     
PAGE_NOCACHE						:= 0x200     
PAGE_WRITECOMBINE				:= 0x400     
MEM_COMMIT							:= 0x1000     
MEM_RESERVE							:= 0x2000     
MEM_DECOMMIT						:= 0x4000     
MEM_RELEASE							:= 0x8000     
MEM_FREE								:= 0x10000     
MEM_PRIVATE							:= 0x20000     
MEM_MAPPED							:= 0x40000     
MEM_RESET							:= 0x80000     
MEM_TOP_DOWN						:= 0x100000     
MEM_WRITE_WATCH				:= 0x200000     
MEM_PHYSICAL						:= 0x400000     
MEM_LARGE_PAGES					:= 0x20000000     
MEM_4MB_PAGES						:= 0x80000000  

CP_ACP 									:= 0           ; default to ANSI code page
CP_OEMCP 								:= 1           ; default to OEM  code page
CP_MACCP 								:= 2           ; default to MAC  code page
CP_THREAD_ACP 						:= 3           ; current thread's ANSI code page
CP_SYMBOL 							:= 42          ; SYMBOL translations

CP_UTF7								:= 65000       ; UTF-7 translation
CP_UTF8								:= 65001       ; UTF-8 translation

; HANDLE OpenProcess(
;   DWORD dwDesiredAccess,
;   BOOL bInheritHandle,
;   DWORD dwProcessId
; );

OpenProcess(dwDesiredAccess, bInheritHandle, dwProcessId)
{
	return DllCall("OpenProcess", "UInt", dwDesiredAccess, "Int", bInheritHandle, "UInt", dwProcessId)
}

; LPVOID VirtualAllocEx(
;   HANDLE hProcess,
;   LPVOID lpAddress,
;   SIZE_T dwSize,
;   DWORD flAllocationType,
;   DWORD flProtect
; );

VirtualAllocEx(hProcess, lpAddress, dwSize, flAllocationType, flProtect)
{
	return DllCall("VirtualAllocEx", "UInt", hProcess, "UInt", lpAddress, "UInt", dwSize, "UInt", flAllocationType, "UInt", flProtect)
}

; BOOL VirtualFreeEx(
;   HANDLE hProcess,
;   LPVOID lpAddress,
;   SIZE_T dwSize,
;   DWORD dwFreeType
; );

VirtualFreeEx(hProcess, lpAddress, dwSize, dwFreeTyp)
{
	return DllCall("VirtualFreeEx", "UInt", hProcess, "UInt", lpAddress, "UInt", dwSize, "UInt", dwFreeTyp)
}

; BOOL CloseHandle(
; 	 HANDLE hObject
; );

CloseHandle(hObject)
{
	return DllCall("CloseHandle", "UInt", hObject)
}

; BOOL ReadProcessMemory(
; 	 HANDLE hProcess,
; 	 LPCVOID lpBaseAddress,
; 	 LPVOID lpBuffer,
; 	 SIZE_T nSize,
; 	 SIZE_T* lpNumberOfBytesRead
; );

ReadProcessMemory(hProcess, lpBaseAddress, lpBuffer, nSize, lpNumberOfBytesRead)
{
	return DllCall("ReadProcessMemory", "UInt", hProcess, "UInt", lpBaseAddress, "UInt", lpBuffer, "UInt", nSize, "UInt", lpNumberOfBytesRead)
}

; BOOL WriteProcessMemory(
; 	 HANDLE hProcess,
; 	 LPVOID lpBaseAddress,
; 	 LPCVOID lpBuffer,
; 	 SIZE_T nSize,
; 	 SIZE_T* lpNumberOfBytesWritten
; );

WriteProcessMemory(hProcess, lpBaseAddress, lpBuffer, nSize, lpNumberOfBytesWritten)
{
	return DllCall("WriteProcessMemory", "UInt", hProcess, "UInt", lpBaseAddress, "UInt", lpBuffer, "UInt", nSize, "UInt", lpNumberOfBytesWritten)
}

; DWORD GetLastError(void);

GetLastError()
{
	return DllCall("GetLastError")
}

; int WideCharToMultiByte(
;   UINT CodePage,            // code page
;   DWORD dwFlags,            // performance and mapping flags
;   LPCWSTR lpWideCharStr,    // wide-character string
;   int cchWideChar,          // number of chars in string.
;   LPSTR lpMultiByteStr,     // buffer for new string
;   int cbMultiByte,          // size of buffer
;   LPCSTR lpDefaultChar,     // default for unmappable chars
;   LPBOOL lpUsedDefaultChar  // set when default char used
; );

WideCharToMultiByte(CodePage, dwFlags, lpWideCharStr, cchWideChar, lpMultiByteStr, cbMultiByte, lpDefaultChar, lpUsedDefaultChar)
{
	return DllCall("WideCharToMultiByte", "UInt", CodePage, "UInt", dwFlags, "UInt", lpWideCharStr, "Int", cchWideChar, "UInt", lpMultiByteStr, "Int", cbMultiByte, "UInt", lpDefaultChar, "UInt", lpUsedDefaultChar)
}

; int MultiByteToWideChar(
;   UINT CodePage,         // code page
;   DWORD dwFlags,         // character-type options
;   LPCSTR lpMultiByteStr, // string to map
;   int cbMultiByte,       // number of bytes in string
;   LPWSTR lpWideCharStr,  // wide-character buffer
;   int cchWideChar        // size of buffer
; );

MultiByteToWideChar(CodePage, dwFlags, lpMultiByteStr, cbMultiByte, lpWideCharStr, cchWideChar)
{
	return DllCall("MultiByteToWideChar", "UInt", CodePage, "UInt", dwFlags, "UInt", lpMultiByteStr, "Int", cbMultiByte, "UInt", lpWideCharStr, "Int", cchWideChar)
}









