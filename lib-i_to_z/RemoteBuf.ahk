/*
 Title: RemoteBuf Library v2.99.1 (Pre v3.0 release)

 Group: Functions
*/
;------------------------------
;
; Function: RemoteBuf_Close
;
; Description:
;
;   Release the memory allocated to the remote buffer and close the connection.
;
; Parameters:
;
;   H - Variable that contains the remote buffer information.
;
; Returns:
;
;   TRUE if successful, otherwise FALSE.  If FALSE is returned, a
;   developer-friendly message is dumped to the debugger.
;
; Calls To Other Functions:
;
; * <RemoteBuf_SystemMessage>
;
;-------------------------------------------------------------------------------
RemoteBuf_Close(ByRef H)
    {
    Static Dummy83552158

          ;-- Memory free operation
          ,MEM_RELEASE:=0x8000

    hProcess  :=NumGet(H,0,"Ptr")
    BufAddress:=NumGet(H,8,"Ptr")
    if not hProcess
        {
        outputdebug Function: %A_ThisFunc% - Invalid remote buffer handle
        Return False
        }

    RC:=DllCall("VirtualFreeEx"
        ,"Ptr",hProcess                                 ;-- hProcess
        ,"Ptr",BufAddress                               ;-- lpAddress
        ,"UPtr",0                                       ;-- dwSize
        ,"UInt",MEM_RELEASE)                            ;-- dwFreeType

    if not RC
        {
        l_SystemMessage:=RemoteBuf_SystemMessage(A_LastError)
        outputdebug,
           (ltrim join`s
            Function: %A_ThisFunc% - Error from "VirtualFreeEx" function.
            A_LastError: %A_LastError% - %l_SystemMessage%
           )

        Return False
        }

    DllCall("CloseHandle","Ptr",hProcess)
    VarSetCapacity(H,24,0)  ;-- Set all values to 0
    Return True
    }

;------------------------------
;
; Function: RemoteBuf_Get
;
; Description:
;
;   Retrieve the address or size of the remote buffer.
;
; Parameters:
;
;   H - Variable that contains the remote buffer information.
;
;   p_Query - Set to "adr" to get the address of the buffer (default).  Set to
;       "size" to get the buffer size.  Set to "handle" to get the Windows
;       API handle of the remote buffer.
;
; Returns:
;
;   The return value depends on the query value (p_Query parameter).
;
;-------------------------------------------------------------------------------
RemoteBuf_Get(ByRef H,p_Query:="adr")
    {
    StringLower p_Query,p_Query  ;-- Just in case StringCaseSense is On
    if p_Query in adr,address,bufaddress
        Return NumGet(H,8,"Ptr")

    if p_Query in size,bufsize
        Return NumGet(H,16,"UPtr")

    ;-- Everything else
    Return NumGet(H,0,"Ptr")
    }

;------------------------------
;
; Function: RemoteBuf_Open
;
; Description:
;
;   Establish a connection to a remote buffer.
;
; Parameters:
;
;   H - Variable that is loaded with the current buffer information.
;
;   hWindow - Handle of the window in a remote process.
;
;   BufSize - Size of the buffer, in bytes.
;
; Returns:
;
;   TRUE if successful, otherwise FALSE.  If FALSE is returned, a
;   developer-friendly message is dumped to the debugger.
;
; Calls To Other Functions:
;
; * <RemoteBuf_SystemMessage>
;
; Remarks:
;
;   This function establishes the connection to the remote buffer.  Most of
;   the library functions depend on the success of this call.  Be sure to check
;   for a successful return value before calling any other library function.
;
;   Use <RemoteBuf_Close> to close the connection.
;
;-------------------------------------------------------------------------------
RemoteBuf_Open(ByRef H,hWindow,BufSize)
    {
    Static Dummy38208481

          ;-- Process access rights
          ,PROCESS_VM_OPERATION:=0x8
          ,PROCESS_VM_READ     :=0x10
          ,PROCESS_VM_WRITE    :=0x20

          ;-- Memory allocation type
          ,MEM_COMMIT:=0x1000

          ;-- Memory protection types
          ,PAGE_READWRITE:=4

          ;-- Desired access
          ,dwDesiredAccess:=PROCESS_VM_OPERATION|PROCESS_VM_READ|PROCESS_VM_WRITE

    WinGet pid,PID,ahk_id %hWindow%
    hProcess:=DllCall("OpenProcess"
        ,"UInt",dwDesiredAccess                         ;-- dwDesiredAccess
        ,"Int",0                                        ;-- bInheritHandle
        ,"UInt",pid)                                    ;-- dwProcessId

    if not hProcess
        {
        l_SystemMessage:=RemoteBuf_SystemMessage(A_LastError)
        outputdebug,
           (ltrim join`s
            Function: %A_ThisFunc% - Error from "OpenProcess" function.
            A_LastError: %A_LastError% - %l_SystemMessage%
           )

        Return False
        }

    BufAddress:=DllCall("VirtualAllocEx"
        ,"Ptr",hProcess                                 ;-- hProcess
        ,"Ptr",0                                        ;-- lpAddress
        ,"UPtr",BufSize                                 ;-- dwSize
        ,"UInt",MEM_COMMIT                              ;-- flAllocationType
        ,"UInt",PAGE_READWRITE)                         ;-- flProtect

    if not BufAddress
        {
        l_SystemMessage:=RemoteBuf_SystemMessage(A_LastError)
        outputdebug,
           (ltrim join`s
            Function: %A_ThisFunc% - Error from "VirtualAllocEx" function.
            A_LastError: %A_LastError% - %l_SystemMessage%
           )

        Return False
        }

    ;-- H structure
    ;    @0: hProcess (Ptr)
    ;    @8: buffer address (Ptr)
    ;   @16: buffer size (UPtr)
    VarSetCapacity(H,24,0)
    NumPut(hProcess  		, H, 0	, "Ptr")
    NumPut(BufAddress	, H, 8	, "Ptr")
    NumPut(BufSize			, H, 16	, "UPtr")
    Return True
    }

;------------------------------
;
; Function: RemoteBuf_Read
;
; Description:
;
;   Read from the remote buffer into a local buffer.
;
; Parameters:
;
;   H - Variable that contains the remote buffer information.
;
;   r_Local - [Output] Variable that contains the local buffer.
;
;   p_LocalSize - The size of the local buffer and the number of bytes to
;       read from the remote buffer.
;
;   p_Offset - [Optional] The offset of the remote buffer address.  The default
;       is 0.
;
; Returns:
;
;   TRUE if successful, otherwise FALSE.  If FALSE is returned, a
;   developer-friendly message is dumped to the debugger.
;
; Calls To Other Functions:
;
; * <RemoteBuf_SystemMessage>
;
;-------------------------------------------------------------------------------
RemoteBuf_Read(ByRef H,ByRef r_Local,p_LocalSize,p_Offset:=0)
    {
    hProcess  :=NumGet(H,0,"Ptr")
    BufAddress:=NumGet(H,8,"Ptr")
    BufSize   :=NumGet(H,16,"UPtr")
    if not hProcess
        {
        outputdebug Function: %A_ThisFunc% - Invalid remote buffer handle
        Return False
        }

    if ((BufSize-p_Offset)<p_LocalSize)
        {
        outputdebug,
           (ltrim join`s
            Function: %A_ThisFunc% -
            Local size is larger than BufferSize-Offset
           )

        Return False
        }

    VarSetCapacity(r_Local,p_LocalSize,0)
    RC:=DllCall("ReadProcessMemory"
        ,"Ptr",hProcess                                 ;-- hProcess
        ,"Ptr",BufAddress+p_Offset                      ;-- lpBaseAddress
        ,"Ptr",&r_Local                                 ;-- lpBuffer
        ,"UPtr",p_LocalSize                             ;-- nSize
        ,"UPtr",0)                                      ;-- *lpNumberOfBytesRead

    if not RC
        {
        l_SystemMessage:=RemoteBuf_SystemMessage(A_LastError)
        outputdebug,
           (ltrim join`s
            Function: %A_ThisFunc% - Error from "ReadProcessMemory" function.
            A_LastError: %A_LastError% - %l_SystemMessage%
           )

        Return False
        }

    VarSetCapacity(r_Local,-1)
    Return True
    }

;------------------------------
;
; Function: RemoteBuf_SystemMessage
;
; Description:
;
;   Converts a system message number into a readable message.
;
; Type:
;
;   Internal function.  Subject to change.
;
;-------------------------------------------------------------------------------
RemoteBuf_SystemMessage(p_MessageNbr)
    {
    Static FORMAT_MESSAGE_FROM_SYSTEM:=0x1000

    ;-- Convert system message number into a readable message
    VarSetCapacity(l_Message,1024*(A_IsUnicode ? 2:1),0)
    DllCall("FormatMessage"
           ,"UInt",FORMAT_MESSAGE_FROM_SYSTEM           ;-- dwFlags
           ,"Ptr",0                                     ;-- lpSource
           ,"UInt",p_MessageNbr                         ;-- dwMessageId
           ,"UInt",0                                    ;-- dwLanguageId
           ,"Str",l_Message                             ;-- lpBuffer
           ,"UInt",1024                                 ;-- nSize (in TCHARS)
           ,"Ptr",0)                                    ;-- *Arguments

    ;-- Remove trailing CR+LF, if defined
    if (SubStr(l_Message,-1)="`r`n")
        StringTrimRight l_Message,l_Message,2

    ;-- Return system message
    Return l_Message
    }

;------------------------------
;
; Function: RemoteBuf_Write
;
; Description:
;
;   Write to the remote buffer from a local buffer.
;
; Parameters:
;
;   H - Variable that contains the remote buffer information.
;
;   r_Local - [Input] Variable that contains the local buffer.
;
;   p_LocalSize - The number of bytes to copy from the local buffer to the
;       remote buffer.
;
;   p_Offset - [Optional] The offset of the remote buffer address.  The default
;       is 0.
;
; Returns:
;
;   TRUE if successful, otherwise FALSE.  If FALSE is returned, a
;   developer-friendly message is dumped to the debugger.
;
; Calls To Other Functions:
;
; * <RemoteBuf_SystemMessage>
;
;-------------------------------------------------------------------------------
RemoteBuf_Write(Byref H,ByRef r_Local,p_LocalSize,p_Offset:=0)
    {
    hProcess  :=NumGet(H,0,"Ptr")
    BufAddress:=NumGet(H,8,"Ptr")
    BufSize   :=NumGet(H,16,"UPtr")
    if not hProcess
        {
        outputdebug Function: %A_ThisFunc% - Invalid remote buffer handle
        Return False
        }

    if ((BufSize-p_Offset)<p_LocalSize)
        {
        outputdebug,
           (ltrim join`s
            Function: %A_ThisFunc% -
            Local size is larger than BufferSize-Offset
           )

        Return False
        }

    RC:=DllCall("WriteProcessMemory"
        ,"Ptr",hProcess                                 ;-- hProcess
        ,"Ptr",BufAddress+p_Offset                      ;-- lpBaseAddress
        ,"Ptr",&r_Local                                 ;-- lpBuffer
        ,"UPtr",p_LocalSize                             ;-- nSize
        ,"UPtr",0)                                      ;-- *lpNumberOfBytesWritten

    if not RC
        {
        l_SystemMessage:=RemoteBuf_SystemMessage(A_LastError)
        outputdebug,
           (ltrim join`s
            Function: %A_ThisFunc% - Error from "WriteProcessMemory" function.
            A_LastError: %A_LastError% - %l_SystemMessage%
           )
        }

    Return RC ? True:False
    }
/*
 Group: Example

    (start code)
    ;-- Get the handle of the Explorer window
    ;   Note: Change "CabinetWClass" to whatever class is needed
    WinGet hExplorer,ID,ahk_class CabinetWClass

    ;-- Open two buffers
    RC1:=RemoteBuf_Open(hBuf1,hExplorer,128*(A_IsUnicode ? 2:1))
    RC2:=RemoteBuf_Open(hBuf2,hExplorer,10*(A_IsUnicode ? 2:1))

    ;-- Always check the return value of the RemoteBuf_Open function
    if (RC1=False or RC2=False)
        {
        MsgBox Error opening remote buffers

        ;-- Do NOT continue
        return
        }

    ;-- Write to the remote buffers
    String   :="1234"
    LocalSize:=StrLen(String)*(A_IsUnicode ? 2:1)
    RemoteBuf_Write(hBuf1,String,LocalSize)

    String   :="_5678"
    LocalSize:=StrLen(String)*(A_IsUnicode ? 2:1)
    Offset   :=4*(A_IsUnicode ? 2:1)
    RemoteBuf_Write(hBuf1,String,LocalSize,Offset)

    String   :="_testing"
    LocalSize:=StrLen(String)*(A_IsUnicode ? 2:1)
    RemoteBuf_Write(hBuf2,String,LocalSize)

    ;-- Read from the remote buffers
    LocalSize:=10*(A_IsUnicode ? 2:1)
    RemoteBuf_Read(hBuf1,String,LocalSize)
    out:=String
    RemoteBuf_Read(hBuf2,String,LocalSize)
    out.=String  ;-- Append to the previous value

    MsgBox %out%

    ;-- Close the remote buffers
    RemoteBuf_Close(hBuf1)
    RemoteBuf_Close(hBuf2)
    return
    (end code)

 Group: About

    o Ver 3.x by jballi (based on v2.0 by majkinator)
    o Updates to support x64.  Bug fixes.  Updated example.
    o ---
    o Ver 2.0 by majkinetor. See http://www.autohotkey.com/forum/topic12251.html
    o Code updates by infogulch
*/