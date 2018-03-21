Affinity_Set( CPU=1, PID=0x0 ) { ; CPU0=1 CPU1=2 | to use both, CPU should be 3
  Process, Exist, %PID%
  IfEqual,ErrorLevel,0,  SetEnv,PID,% DllCall( "GetCurrentProcessId" )
  hPr := DllCall( "OpenProcess",Int,1536,Int,0,Int,PID )  
  DllCall( "GetProcessAffinityMask", Int,hPr, IntP,PAM, IntP,SAM )
  If ( CPU>0 && CPU<=SAM )
     Res := DllCall( "SetProcessAffinityMask", Int,hPr, Int,CPU )
  DllCall( "CloseHandle", Int,hPr )
Return ( Res="" ) ? 0 : Res
}

/*
MSDN Links:

SetProcessAffinityMask : http://msdn.microsoft.com/en-us/library/ms686223(VS.85).aspx 
GetProcessAffinityMask : http://msdn.microsoft.com/en-us/library/ms683213(VS.85).aspx

MSDN DOC Follows :

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -- 
SetProcessAffinityMask Function
Sets a processor affinity mask for the threads of the specified process.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --

Syntax
BOOL WINAPI SetProcessAffinityMask(
  __in  HANDLE hProcess,
  __in  DWORD_PTR dwProcessAffinityMask
);

Parameters :

hProcess [in] : A handle to the process whose affinity mask is to be set. This handle must
                have the PROCESS_SET_INFORMATION access right. For more information, 
                see Process Security and Access Rights.

dwProcessAffinityMask [in] 
                The affinity mask for the threads of the process.

Return Value  : If the function succeeds, the return value is nonzero.  
                If the function fails, the return value is zero. To get extended error 
                information, call GetLastError.

Remarks       : A process affinity mask is a bit vector in which each bit represents the 
                processor on which the threads of the process are allowed to run.

                The value of the process affinity mask must be a subset of the system 
                affinity mask values obtained by the GetProcessAffinityMask function.

                Do not call SetProcessAffinityMask in a DLL that may be called by 
                processes other than your own.

                Process affinity is inherited by any child process or newly instantiated 
                local process.

Requirements  : Client Requires Windows Vista, Windows XP, or Windows 2000 Professional. 
                Server Requires Windows Server 2008, Windows Server 2003, or Windows 2000 
                Server. 

                DLL Requires Kernel32.dll.
 
 
 
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -- 
GetProcessAffinityMask Function
Retrieves the process affinity mask for the specified process and the system affinity mask
for the system.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --

Syntax
BOOL WINAPI GetProcessAffinityMask(
  __in   HANDLE hProcess,
  __out  PDWORD_PTR lpProcessAffinityMask,
  __out  PDWORD_PTR lpSystemAffinityMask
);

Parameters

hProcess [in] : A handle to the process whose affinity mask is desired. 
                This handle must have the PROCESS_QUERY_INFORMATION or 
                PROCESS_QUERY_LIMITED_INFORMATION access right. For more information, 
                see Process Security and Access Rights.

                Windows Server 2003 and Windows XP/2000:  The handle must have the 
                PROCESS_QUERY_INFORMATION access right.

lpProcessAffinityMask [out] 

                A pointer to a variable that receives the affinity mask for the specified 
                process.

lpSystemAffinityMask [out] 
                A pointer to a variable that receives the affinity mask for the system.

Return Value : If the function succeeds, the return value is nonzero and the function sets
               the variables pointed to by lpProcessAffinityMask and lpSystemAffinityMask 
               to the appropriate affinity masks.

               If the function fails, the return value is zero, and the values of the 
               variables pointed to by lpProcessAffinityMask and lpSystemAffinityMask are 
               undefined. To get extended error information, call GetLastError.

Remarks     :  A process affinity mask is a bit vector in which each bit represents the 
               processors that a process is allowed to run on. A system affinity mask is a 
               bit vector in which each bit represents the processors that are configured 
               into a system.

               A process affinity mask is a subset of the system affinity mask. A process 
               is only allowed to run on the processors configured into a system.

Requirement :  Client Requires Windows Vista, Windows XP, or Windows 2000 Professional. 
              Server Requires Windows Server 2008, Windows Server 2003, or Windows 2000 
              Server.
               
              DLL Requires Kernel32.dll.
 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -