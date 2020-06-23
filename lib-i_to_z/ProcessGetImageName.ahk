; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=42&t=66232&hilit=nested+class
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

/*
    Retrieves the full name of the executable image for the specified process.
    Parameters:
        Process:
            A handle to the process.
            The handle must have the PROCESS_QUERY_INFORMATION or PROCESS_QUERY_LIMITED_INFORMATION access right.
        Flags:
            This parameter can be one of the following values.
            0x00000000     The name should use the Win32 path format.
            0x00000001     The name should use the native system path format.
    Return value:
        If the function succeeds, the return value is a string with the full name of the executable image.
        If the function fails, the return value is zero. To get extended error information, check A_LastError (WIN32).
*/
ProcessGetImageName(Process, Flags := 0x00000000)
{
    local Buffer := BufferAlloc(2*32767+2)
    local Size   := Buffer.Size // 2

    return DllCall("Kernel32.dll\QueryFullProcessImageNameW",  "UPtr", IsObject(Process) ? Process.Handle : Process
                                                            ,  "UInt", Flags
                                                            ,  "UPtr", Buffer.Ptr
                                                            , "UIntP", Size)
         ? StrGet(Buffer, Size, "UTF-16")
         : 0
} ; https://docs.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-queryfullprocessimagenamea