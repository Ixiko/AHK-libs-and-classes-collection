; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=42&t=66232&hilit=nested+class
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

/*
    Retrieves extended basic information of the specified process.
    Parameters:
        Process:
            A handle to the process.
            The handle must have the PROCESS_QUERY_LIMITED_INFORMATION and PROCESS_VM_READ access rights.
    Return value:
        If the function succeeds, the return value is an associative object (Map) with the following keys:
            ProcessId          The process identifier that uniquely identifies the process.
            ParentProcessId    The identifier of the process that created this process (its parent process).
            BasePriority       The base priority of the process, which is the starting priority for threads created within the associated process.
            PebBaseAddress     A pointer to a PEB structure containing process information.
            AffinityMask       The process affinity mask for the specified process.
            ExitStatus         The termination status of the specified process. STILL_ACTIVE = 259.
            Flags              Bit flags. Read: https://stackoverflow.com/questions/47300622/meaning-of-flags-in-process-extended-basic-information-struct.
                0x001  IsProtectedProcess    System protected process: other processes can't read/write its VM or inject a remote thread into it.
                0x002  IsWow64Process        WOW64 process, or 32-bit process running on a 64-bit Windows.
                0x004  IsProcessDeleting     Process was terminated, but there're open handles to it.
                0x008  IsCrossSessionCreate  Process was created across terminal sessions. Ex. CreateProcessAsUser.
                0x010  IsFrozen              Immersive process is suspended (applies only to UWP processes).
                0x020  IsBackground          Immersive process is in the Background task mode. UWP process may temporarily switch into performing a background task.
                0x040  IsStronglyNamed       UWP Strongly named process. The UWP package is digitally signed. Any modifications to files inside the package can be tracked. This usually means that if the package signature is broken the UWP app will not start.
                0x080  IsSecureProcess       Isolated User Mode process (new security mode in Windows 10), with more stringent restrictions on what can "tap" into this process.
                0x100  IsSubsystemProcess    Set when the type of the process subsystem is other than Win32 (like *NIX, such as Ubuntu.).
        If the function fails, the return value is zero. To get extended error information, check A_LastError (NTSTATUS).
*/
ProcessGetBasicInfo(Process) {
    local PROCESS_EXTENDED_BASIC_INFORMATION := BufferAlloc(A_PtrSize==4?32:64)  ; https://stackoverflow.com/questions/47300622/meaning-of-flags-in-process-extended-basic-information-struct.
    NumPut("UInt", PROCESS_EXTENDED_BASIC_INFORMATION.Size, PROCESS_EXTENDED_BASIC_INFORMATION)
    local NtStatus := DllCall("Ntdll.dll\NtQueryInformationProcess", "UPtr", IsObject(Process) ? Process.Handle : Process
                                                                   ,  "Int", 0  ; ProcessBasicInformation.
                                                                   , "UPtr", PROCESS_EXTENDED_BASIC_INFORMATION.Ptr
                                                                   , "UInt", PROCESS_EXTENDED_BASIC_INFORMATION.Size
                                                                   , "UPtr", 0
                                                                   , "UInt")

    if (NtStatus == 0)  ; STATUS_SUCCESS.
    {
        local ProcessInfo := { ExitStatus     : NumGet(PROCESS_EXTENDED_BASIC_INFORMATION,   A_PtrSize, "UInt")    ; NTSTATUS  ExitStatus.
                             , PebBaseAddress : NumGet(PROCESS_EXTENDED_BASIC_INFORMATION, 2*A_PtrSize, "UPtr")    ; PPEB      PebBaseAddress.
                             , AffinityMask   : NumGet(PROCESS_EXTENDED_BASIC_INFORMATION, 3*A_PtrSize, "UPtr")    ; ULONG_PTR AffinityMask.
                             , BasePriority   : NumGet(PROCESS_EXTENDED_BASIC_INFORMATION, 4*A_PtrSize, "UInt")    ; KPRIORITY BasePriority.
                             , ProcessId      : NumGet(PROCESS_EXTENDED_BASIC_INFORMATION, 5*A_PtrSize, "UPtr")    ; HANDLE    UniqueProcessId.
                             , ParentProcessId: NumGet(PROCESS_EXTENDED_BASIC_INFORMATION, 6*A_PtrSize, "UPtr")    ; HANDLE    InheritedFromUniqueProcessId.
                             , Flags          : NumGet(PROCESS_EXTENDED_BASIC_INFORMATION, 7*A_PtrSize, "UInt") }  ; ULONG     Flags.

    }

    return (A_LastError := NtStatus) ? 0 : ProcessInfo
}