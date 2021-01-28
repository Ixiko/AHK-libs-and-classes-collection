; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=42&t=66232&hilit=nested+class
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

/*
    Retrieves information about the process that has the specified file open.
    Parameters:
        FileName:
            The full path name of the target file.
    Return value:
        If the function succeeds and the file is opened by a process, the return value is an array of associative objects (Map) with the following keys:
            FileName    A string with the file name.
            FileType    The file type: "Directory" or "Disk".
            Item        Contains the associative object of included function ProcessEnumHandles.
        If the function fails, the return value is zero. To get extended error information, check A_LastError (NTSTATUS).
    Remarks:
        Depending on the process, Administrator rights and the SeDebugPrivilege privilege may be required.
*/
ProcessInfoFromFilename(FileName)
{
    local

    if !( SysHandleList := ProcessEnumHandles() )
        return 0

    RetValue  := [ ]
    Buffer    := BufferAlloc(0xF4240)
    FileTypes := {0: "Unknown", 1:"Disk", 2:"Char", 3:"Pipe", 0x8000:"Remote"}
    for Each, Item in SysHandleList
    {
        if Process := ProcessOpen(Item.ProcessId, 0x00000040)  ; PROCESS_DUP_HANDLE.
        {
            if hObject := ObjectDuplicate(-1, Process, Item)
            {
                if ObjectQuery(hObject, 2, Buffer)
                {
                    ObjType := StrGet(NumGet(Buffer,A_PtrSize), NumGet(Buffer,"UShort")//2)
                    Length  := 0
                    if (ObjType == "File")
                    {
                        FileType := DllCall("Kernel32.dll\GetFileType", "Ptr", hObject, "UInt")
                        if (A_LastError == 0x00000000)  ; NO_ERROR.
                            if (FileType !== 0x000003)  ; Pipe.
                                Length := DllCall("Kernel32.dll\GetFinalPathNameByHandleW", "Ptr", hObject, "Ptr", Buffer, "UInt", Buffer.Size, "UInt", 0)
                    }
                    else if (ObjType == "Directory")
                        Length := DllCall("Kernel32.dll\GetFinalPathNameByHandleW", "Ptr", hObject, "Ptr", Buffer, "UInt", Buffer.Size, "UInt", 0)
                    if (Length)
                    {
                        CurrFileName := StrGet(Buffer, Length, "UTF-16")
                        if !StrCompare(RegExReplace(CurrFileName,"^\\\\(\?|\.)\\"), FileName)
                            RetValue.Push( { Item    : Item
                                           , FileType: ObjType == "Directory" ? "Directory" : FileTypes[FileType]
                                           , FileName: CurrFileName } )
                    }
                }
                HandleClose(hObject)
            }
        }
    }

    return RetValue.Length() ? RetValue : 0
}