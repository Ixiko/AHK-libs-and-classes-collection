; FileExtract / FileExtract_ToMem (counterpart of FileInstall) by Lexikos
; http://www.autohotkey.com/forum/viewtopic.php?t=30088

/*
    Function: FileExtract
 
    Extracts a file from this compiled script by using a dynamic FileInstall.
 
    Syntax:
        FileExtract( Source, Dest [, Flag ] )
 
    Parameters:
        Source  - The source string used in the original FileInstall.
        Dest    - The name of the file to be created.
        Flag    - Specify 1 to overwrite existing files, otherwise omit.
 
    Remarks:
        Unlike FileInstall, FileExtract() allows variables and expressions for Source,
        and does not cause Ahk2Exe to include a file into the executable.
*/
FileExtract(Source, Dest, Flag=0) {
    static init
    if !init
        cb := RegisterCallback("FileExtract_")
        ; cb->func->mJumpToLine->mActionType := ACT_FILEINSTALL
        , NumPut(A_AhkVersion>="1.0.48" ? 160:159, NumGet(NumGet(cb+28)+4), 0, "UChar") ; Fixed for AutoHotkey v1.0.48: ACT_FILEINSTALL has changed to 160.
        , DllCall("GlobalFree", "uint", cb)
    return FileExtract_(Source, Dest, Flag)
}
FileExtract_(Source, Dest, Flag) {
    FileCopy, %Source%, %Dest%, %Flag%
    return !ErrorLevel
}
 
/*
    Function: FileExtract_ToMem
 
    Extracts a FileInstall'd file into memory.
 
    Syntax:
        FileExtract_ToMem( Source, pData, DataSize [, InitialBufferSize, InitialBuffer ] )
 
    Parameters:
        Source       [in] - The source string used in the original FileInstall.
        pData    [in/out] - A pointer to the buffer where file data is written. See remarks.
        DataSize     [in] - If pData is zero, this indicates the initial buffer size.
                    [out] - Receives the number of bytes written to the buffer.
 
    Remarks:
        pData must specify zero or a valid pointer to memory allocated with GlobalAlloc().
 
        If the caller specifies a non-zero pData, it is used as the initial data buffer.
        If the buffer is too small, the function will reallocate it and update pData.
        The function does not delete the buffer on failure unless the caller specified zero.
 
        Once the data is no longer needed, free it using GlobalFree:
 
            DllCall("GlobalFree","uint",pData)
 
        DataSize indicates the amount of data written, not the size of the buffer.
        To determine the actual size of the buffer, use GlobalSize:
 
            MemSize := DllCall("GlobalSize","uint",pData)
*/
FileExtract_ToMem(Source, ByRef pData, ByRef DataSize)
{
    static ReadPipe, ConnectNamedPipe, ReadFile, GlobalReAlloc
    if !VarSetCapacity(ReadPipe)
    {
        ; Initialize the machine code function for reading from the pipe.
        hex =
        ( LTrim Join
        558BEC81EC0004000053568B75085733FF397E080F848D000000397E040F848400000057
        FF36FF561057BB00040000EB5E8B46088B4D088BD02B560C3BD1732803C08946088B560C
        2BC23BC1730503D18956086A02FF7608FF7604FF561885C074458B4D088946048B460C03
        460433FF85C976168D9500FCFFFF2BD08A0C0288088B4D0847403BF972F2014E0C6A008D
        450850538D8500FCFFFF50FF36FF561485C0758D40EB0233C05F5E5BC9C20400
        )
        ;~ MCode() - http://www.autohotkey.com/forum/viewtopic.php?t=21172
        VarSetCapacity(ReadPipe,StrLen(hex)//2)
        Loop % StrLen(hex)//2
           NumPut("0x" . SubStr(hex,2*A_Index-1,2), ReadPipe, A_Index-1, "Char")
        ;~ end
 
        ; Resolve ReadPipe()'s dependencies for later.
        hKernel32 := DllCall("GetModuleHandle", "str", "kernel32.dll")
        astr := A_IsUnicode ? "astr" : "str"
        ConnectNamedPipe := DllCall("GetProcAddress", "uint", hKernel32, astr, "ConnectNamedPipe")
        ReadFile         := DllCall("GetProcAddress", "uint", hKernel32, astr, "ReadFile")
        GlobalReAlloc    := DllCall("GetProcAddress", "uint", hKernel32, astr, "GlobalReAlloc")
    }
 
    UserOwnsData := !!pData ; True if pData is not [blank or zero].
    if !pData
    {   ; If DataSize is non-numeric or < 1, default to 1024.
        if (DataSize+0 < 1)
            DataSize := 1024
        pData := DllCall("GlobalAlloc","uint",0,"uint",DataSize)
    }
    else
    {   ; Get the actual size of the memory block,
        DataSize := DllCall("GlobalSize","uint",pData)
    }
 
    VarSetCapacity(ReadPipeStruct, 28, 0) ; ReadPipeStruct
 
    ; Fill ReadPipeStruct with ReadPipe()'s dependencies.
    NumPut(ConnectNamedPipe, ReadPipeStruct, 16)
    NumPut(ReadFile, ReadPipeStruct, 20)
    NumPut(GlobalReAlloc, ReadPipeStruct, 24)
 
    Random, pipe_name
 
    ; Create a named pipe (with an unpredictable name) for writing the file into.
    hNamedPipe := DllCall("CreateNamedPipe", "str", "\\.\pipe\" pipe_name, "uint", 3
                    , "uint", 0, "uint", 255, "uint",0, "uint",0, "uint",0, "uint",0)
    ; Set the parameters for the pipe-reading thread.
    NumPut(hNamedPipe, ReadPipeStruct, 0)
    NumPut(pData, ReadPipeStruct, 4)
    NumPut(DataSize, ReadPipeStruct, 8)
 
    ; Create a thread to read from the pipe into memory.
    ; The thread will start immediately, but will wait for a pipe connection.
    hReadThread := DllCall("CreateThread", "uint", 0, "uint", 0, "uint", &ReadPipe
                            , "uint", &ReadPipeStruct, "uint", 0, "uint*", ReadThreadID)
 
    ; "Replace flag" *must* be specified since the pipe... exists.
    FileExtractResult := FileExtract(Source, "\\.\pipe\" pipe_name, 1)
 
    if !FileExtractResult
    {   ; Open and close a connection to the pipe to terminate the thread.
        FileAppend,, \\.\pipe\%pipe_name%
    }
 
    Loop {
        ; Wait for the thread to terminate, or any window message to be received.
        r := DllCall("MsgWaitForMultipleObjectsEx", "uint", 1, "uint*", hReadThread
                                            , "uint", -1, "uint", 0x4FF, "uint", 0x6)
        if (r = 0) || (r = -1) ; WAIT_OBJECT_0 or WAIT_FAILED
            break
        Sleep, 1 ; Allow AutoHotkey to dispatch messages.
    }
 
    DllCall("DisconnectNamedPipe", "uint", hNamedPipe)
    DllCall("CloseHandle", "uint", hNamedPipe)
    DllCall("CloseHandle", "uint", hReadThread)
 
    if FileExtractResult || UserOwnsData
    {
        ; Either it was a success and we are returning the extracted data,
        ; or it failed and we are returning the memory to the caller, since
        ; they may want to reuse it.
        pData := NumGet(ReadPipeStruct,4)
        DataSize := NumGet(ReadPipeStruct,12)
    }
    else
    {
        ; If ReadPipe() fails because of low memory, pData may have been reallocated,
        ; so always use the value in the structure.
        DllCall("GlobalFree", "uint", NumGet(ReadPipeStruct,4))
        pData := DataSize := 0
    }
    return FileExtractResult
}