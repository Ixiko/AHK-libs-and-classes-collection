class Subprocess    ; thanks to cocobelgica : https://github.com/cocobelgica/AutoHotkey-Util/blob/master/Subprocess.ahk
{
    ; ===================================================================================================================
    ; CONSTRUCTOR
    ; ===================================================================================================================
    __New(Command, WorkingDir := "", CreationFlags := 0x8000000)
    {
        ; CreatePipe function
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/aa365152(v=vs.85).aspx
        Local stdin_read := 0, stdin_write := 0
        DllCall("Kernel32.dll\CreatePipe", "PtrP", stdin_read, "PtrP", stdin_write, "UPtr", 0, "UInt", 0)
        ; SetHandleInformation function
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms724935(v=vs.85).aspx
        DllCall("Kernel32.dll\SetHandleInformation", "Ptr", stdin_read, "UInt", 1, "UInt", 1) ; HANDLE_FLAG_INHERIT = 1

        Local stdout_read := 0, stdout_write := 0
        DllCall("Kernel32.dll\CreatePipe", "PtrP", stdout_read, "PtrP", stdout_write, "UPtr", 0, "UInt", 0)
        DllCall("Kernel32.dll\SetHandleInformation", "Ptr", stdout_write, "UInt", 1, "UInt", 1)

        Local stderr_read := 0, stderr_write := 0
        DllCall("Kernel32.dll\CreatePipe", "PtrP", stderr_read, "PtrP", stderr_write, "UPtr", 0, "UInt", 0)
        DllCall("Kernel32.dll\SetHandleInformation", "Ptr", stderr_write, "UInt", 1, "UInt", 1)

        ; STARTUPINFO structure
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms686331(v=vs.85).aspx
        Local STARTUPINFO := ""
        NumPut(VarSetCapacity(STARTUPINFO, A_PtrSize == 8 ? 104 : 68, 0), &STARTUPINFO, "UInt")
        NumPut(0x100, &STARTUPINFO + (A_PtrSize == 8 ? 60 : 44), "UInt")    ; dwFlags STARTF_USESTDHANDLES
        NumPut(stderr_write, NumPut(stdout_write, NumPut(stdin_read, &STARTUPINFO + (A_PtrSize == 8 ? 80 : 56), "Ptr"), "Ptr"), "Ptr")

        ; PROCESS_INFORMATION structure
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms684873(v=vs.85).aspx
        Local PROCESS_INFORMATION := ""
        VarSetCapacity(PROCESS_INFORMATION, 8 + 2*A_PtrSize)
        
        ; CreateProcess function
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms682425(v=vs.85).aspx
        If !DllCall("Kernel32.dll\CreateProcessW", "UPtr", 0          ; lpApplicationName
                                                 , "UPtr", &Command   ; lpCommandLine
                                                 , "UPtr", 0          ; lpProcessAttributes
                                                 , "UPtr", 0          ; lpThreadAttributes
                                                 ,  "Int", TRUE       ; bInheritHandles
                                                 , "UInt", CreationFlags   ; dwCreationFlags
                                                 , "UPtr", 0          ; lpEnvironment
                                                 , "UPtr", DirExist(WorkingDir) ? &WorkingDir : &A_WorkingDir    ; lpCurrentDirectory
                                                 , "UPtr", &STARTUPINFO             ; lpStartupInfo
                                                 , "UPtr", &PROCESS_INFORMATION)    ; lpProcessInformation
            Return FALSE

        this.hProcess  := NumGet(&PROCESS_INFORMATION, "Ptr")                     ; PROCESS_INFORMATION.hProcess
        this.hThread   := NumGet(&PROCESS_INFORMATION + A_PtrSize, "Ptr")         ; PROCESS_INFORMATION.hThread
        this.ProcessId := NumGet(&PROCESS_INFORMATION + 2*A_PtrSize, "UInt")      ; PROCESS_INFORMATION.dwProcessId
        this.ThreadId  := NumGet(&PROCESS_INFORMATION + 2*A_PtrSize + 4, "UInt")  ; PROCESS_INFORMATION.dwThreadId

        this.StdIn  := new Subprocess.StreamWriter(stdin_write)
        this.StdOut := new Subprocess.StreamReader(stdout_read)
        this.StdErr := new Subprocess.StreamReader(stderr_read)

        DllCall("Kernel32.dll\CloseHandle", "Ptr", stdin_read)
        DllCall("Kernel32.dll\CloseHandle", "Ptr", stdout_write)
        DllCall("Kernel32.dll\CloseHandle", "Ptr", stderr_write)
    }


    ; ===================================================================================================================
    ; DESTRUCTOR
    ; ===================================================================================================================
    __Delete()
    {
        this.StdIn := this.StdOut := this.StdErr := ""
        DllCall("Kernel32.dll\CloseHandle", "Ptr", this.hProcess)
        DllCall("Kernel32.dll\CloseHandle", "Ptr", this.hThread)
    }


    ; ===================================================================================================================
    ; PUBLIC METHODS
    ; ===================================================================================================================
    GetExitCode()    ; STILL_ACTIVE = 259
    {
        ; GetExitCodeProcess function
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms683189(v=vs.85).aspx
        Local ExitCode := 0
        Return DllCall("Kernel32.dll\GetExitCodeProcess", "Ptr", this.hProcess, "UIntP", ExitCode) ? ExitCode : -1
    }

    Terminate(ExitCode := 0)
    {
        ; TerminateProcess function
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms686714(v=vs.85).aspx
        Return DllCall("Kernel32.dll\TerminateProcess", "Ptr", this.hProcess, "UInt", ExitCode)
    }


    ; ===================================================================================================================
    ; NESTED CLASSES
    ; ===================================================================================================================
    class Pipe
    {
        __New(Handle)
        {
            this.Handle := Handle
            this.oStream := 0
        }

        __Delete()
        {
            this.Close()
        }

        Close()
        {
            If (this.oStream)
                this.oStream.Close(), this.oStream := 0
            DllCall("Kernel32.dll\CloseHandle", "Ptr", this.Handle)
        }

        Stream[]
        {
            get
            {
                If (!this.oStream)
                    this.oStream := FileOpen(this.Handle, "h")
                Return this.oStream
            }
        }

        Encoding[]
        {
            get {
                Return this.Stream.Encoding
            }

            set {
                Return this.Stream.Encoding := value
            }
        }
    }

    class StreamReader extends Subprocess.Pipe
    {
        Read(Characters := "")
        {
            Return Characters == "" ? this.Stream.Read() : this.Stream.Read(Characters)
        }

        ReadLine()
        {
            Return this.Stream.ReadLine()
        }

        ReadAll()
        {
            Local Str := "", Buffer := "", Bytes := 0
            VarSetCapacity(Buffer, 4096 + 2)
            While (Bytes := this.Stream.RawRead(&Buffer, 4096))
                NumPut(0, &Buffer+Bytes, "UShort"), Str .= StrGet(&Buffer, -Bytes, this.Encoding)
            Return Str
        }

        RawRead(Address, Bytes)
        {
            Return this.Stream.RawRead(Address, Bytes)
        }

        Peek(ByRef Data := "", Bytes := 4096, ByRef BytesRead := 0, ByRef TotalBytesAvail := 0, ByRef BytesLeftThisMessage := 0)
        {
            ; PeekNamedPipe function
            ; https://msdn.microsoft.com/en-us/library/windows/desktop/aa365779(v=vs.85).aspx
            VarSetCapacity(Data, Bytes)
            Return DllCall("Kernel32.dll\PeekNamedPipe", "Ptr", this.hProcess, "UPtr", &Data, "UInt", bytes, "UIntP", BytesRead, "UIntP", TotalBytesAvail, "UIntP", BytesLeftThisMessage)
        }
    }

    class StreamWriter extends Subprocess.Pipe
    {
        Write(String)
        {
            Return this.Stream.Write(String)
        }

        WriteLine(String)
        {
            Return this.Stream.WriteLine(String)
        }

        RawWrite(Address, Bytes)
        {
            Return this.Stream.RawWrite(Address, Bytes)
        }
    }
}
