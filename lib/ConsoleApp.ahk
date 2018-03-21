;
; ConsoleApps V2
;
; AutoHotkey Version: 1.x
; Language:       English
; Platform:       Win9x/NT
; Author:         Marcus Cortes <macortes84@yahoo.com>
;
; Script Function:
;   Provides a set of functions to redirect and capture
;   the standard input and output of other programs.
;
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.

;;; <summary>
;;;     Runs an application and retrieves its standard output.
;;; </summary>
;;; <param="CmdLine">
;;;     The executable file to run including any path information and arguments.
;;; </param>
;;; <param="WorkingDir">
;;;     The startup directory for the program.
;;; </param>
;;; <param="PID">
;;;     Specifies a variable to receive the ProcessID of the program. This parameter is optional.
;;; </param>
;;; <param="ExitCode">
;;;     When the function returns, this parameter is set to the exit code of the program.
;;; </param>
;;; <returns>
;;;     Returns the StdOut of the program.
;;; </returns>
;;; <remarks>
;;;     The output of programs that are explicity redirected or "piped" in their command-lines will
;;;     not be captured by this function (e.g. "cmd.exe /C echo Hello World > test.txt").
;;; </remarks>
;;; <example>
;;;     MsgBox, % ConsoleApp_RunWait("cmd.exe /c echo Hello World.")
;;; </example>
ConsoleApp_RunWait(CmdLine, WorkingDir="", byref ExitCode="")
{
   global
   local ConsoleAppHandle, ConsoleAppStillRunning, StdOut, BytesAppended, FirstWin32Error

   ConsoleApps_Initialize()

   ; Create the process
   ConsoleAppHandle := ConsoleApp_Run(CmdLine, WorkingDir)
   ; In reality, this function will never return with a ConsoleAppHandle value of 0, but
   ; it is good to check for this possibility in case future versions do return a value of
   ; 0 for failure.
   if (ConsoleAppHandle == 0)
      CONSOLEAPPS_PRIVATE_throw(ERROR_GENERIC_ERROR, "Unable to run console application.")
   /* Continuously retrieve the process's output and write it to the edit control 
    * in a loop as it arrives.
    */
   Loop
   {
      ; Append the ConsoleApps standard output to StdOut.
      ConsoleAppStillRunning := ConsoleApp_GetStdOut(ConsoleAppHandle, StdOut, BytesAppended, ExitCode)
      ; If the ConsoleApp is no longer running, then stop checking for output.
      if (!ConsoleAppStillRunning)
         break
      ; Give up remainder of time-slice to give the child process a chance to generate more output
      ; before checking again.
      sleep 0
   }
   ; This function must be called when the ConsoleAppHandle is no longer needed.
   ConsoleApp_CloseHandle(ConsoleAppHandle)
   return StdOut
}
;;; <summary>
;;;     Runs an application and redirects its standard input/output handles such that they can be accessed
;;;     from the script using the ConsoleApp_GetStdOut() function.
;;; </summary>
;;; <param="CmdLine">
;;;     The executable file to run including any path information and arguments.
;;; </param>
;;; <param="WorkingDir">
;;;     The startup directory for the program.
;;; </param>
;;; <param="Reserved">
;;;     This parameter is reserved for future use and should be a null string ("") or should be omitted.
;;; </param>
;;; <param="PID">
;;;     Specifies a variable to receive the ProcessID of the program. This parameter is optional.
;;; </param>
;;; <returns>
;;;     Returns a proprietary handle to the ConsoleApp for use in calls to ConsoleApp_GetStdOut() and 
;;;     ConsoleApp_CloseHandle(). This handle cannot be specified in any Win32 API functions to identify 
;;;     a process.
;;; </returns>
;;; <remarks>
;;;     If this function completes successfully, the handle returned by this function must be closed 
;;;     when no longer needed using the ConsoleApp_CloseHandle() function.
;;;     The output of programs that are explicity redirected or "piped" in their command-lines will
;;;     not be captured in calls to ConsoleApp_GetStdOut (e.g. "cmd.exe /C echo Hello World > test.txt").
;;; </remarks>
;;; <example>
;;;     ConsoleAppHandle := ConsoleApp_Run("cmd.exe /c echo Hello World.")
;;;     if (ConsoleAppHandle == 0)
;;;         MsgBox, Unable to start cmd.exe
;;;     else
;;;         ConsoleApp_CloseHandle(ConsoleAppHandle)
;;; </example>
ConsoleApp_Run(CmdLine, WorkingDir="", Reserved="", byref PID="")
{
   global
   local sa, pi, si, lpCurrentDirectory
   local hStdoutRead, hStdoutWrite
;   local hStdinRead, hStdinWrite
   local FirstWin32Error
   local hHeap, lpCAPI
   static RedProcNextHandle := 1

   ConsoleApps_Initialize()

   CONSOLEAPPS_PRIVATE_calloc(pi, 16, 0) ;PROCESS_INFORMATION
   CONSOLEAPPS_PRIVATE_calloc(si, 4*18, 0) ;STARTUP_INFO
   NumPut(4*18,  si, 0, "uint") ;STARTUP_INFO {HANDLE cbSize}
   NumPut(0x100 | 0x1, si, 4*11, "uint") ;STARTUP_INFO {dwFlags = STARTF_USESTDHANDLES | STARTF_USESHOWWINDOW}
   ;NumPut(0x0, si, 4*12, "ushort") ;STARTUP_INFO {wShowWindow = SW_HIDE}
   
   ;ALLOC HANDLES
   CONSOLEAPPS_PRIVATE_malloc(hStdoutRead, 4)
   CONSOLEAPPS_PRIVATE_malloc(hStdoutWrite, 4)
   CONSOLEAPPS_PRIVATE_malloc(hStdinRead, 4)
   CONSOLEAPPS_PRIVATE_malloc(hStdinWrite, 4)
   
   ;ALLOC AND INIT SECURITY_ATTRIBUTES STRUC
   CONSOLEAPPS_PRIVATE_calloc(sa, 12, 0) ;security attributes
   NumPut(12,  sa, 0, "uint")
   NumPut(0, sa, 4, "uint")
   NumPut(true, sa, 8, "int")
   
   ;CREATE PIPE FOR STDOUT
   if (!DllCall("CreatePipe", "uint", &hStdoutRead, "uint", &hStdoutWrite, "uint", &sa, "uint", 0))
      CONSOLEAPPS_PRIVATE_throw(CONSOLEAPPS_PRIVATE_ERROR_WIN32_ERROR, "Unable to create stdout pipe: ")
   hStdoutRead := NumGet(hStdoutRead, 0, "uint")
   hStdoutWrite := NumGet(hStdoutWrite, 0, "uint")
   if (!DllCall("SetHandleInformation", "uint", hStdoutRead, "uint", 1, "uint", 0, "int"))
   {
      FirstWin32Error := A_LastError
      DllCall("CloseHandle", "uint", hStdoutRead) ;HANDLE hThread
      DllCall("CloseHandle", "uint", hStdoutWrite) ;HANDLE hThread
      CONSOLEAPPS_PRIVATE_throw(CONSOLEAPPS_PRIVATE_ERROR_WIN32_ERROR, "Unable to set handle information: ", "", FirstWin32Error)
   }
   
   /*
   ;CREATE PIPE FOR STDIN
   if (!DllCall("CreatePipe", "uint", &hStdinRead, "uint", &hStdinWrite, "uint", &sa, "uint", 0))
   {
      FirstWin32Error := A_LastError
      DllCall("CloseHandle", "uint", hStdoutRead) ;HANDLE hThread
      DllCall("CloseHandle", "uint", hStdoutWrite) ;HANDLE hThread
      CONSOLEAPPS_PRIVATE_throw(CONSOLEAPPS_PRIVATE_ERROR_WIN32_ERROR, "Unable to create stdin pipe: ", "", FirstWin32Error)
   }
   hStdinRead := NumGet(hStdinRead, 0, "uint")
   hStdinWrite := NumGet(hStdinWrite, 0, "uint")
   if (!DllCall("SetHandleInformation", "uint", hStdinWrite, "uint", 1, "uint", 0, "int"))
   {
      FirstWin32Error := A_LastError
      DllCall("CloseHandle", "uint", hStdoutRead) ;HANDLE hThread
      DllCall("CloseHandle", "uint", hStdoutWrite) ;HANDLE hThread
      DllCall("CloseHandle", "uint", hStdinRead) ;HANDLE hThread
      DllCall("CloseHandle", "uint", hStdinWrite) ;HANDLE hThread
      CONSOLEAPPS_PRIVATE_throw(CONSOLEAPPS_PRIVATE_ERROR_WIN32_ERROR, "Unable to set handle information: ", "", FirstWin32Error)
   }
   */
   ;USE PIPE HANDLES FOR STDIO
;   NumPut(hStdinRead, si, 4*14, "uint") ;STARTUP_INFO {HANDLE hStdInput}
   NumPut(hStdoutWrite, si, 4*15, "uint") ;STARTUP_INFO {HANDLE hStdOutput}
   NumPut(hStdoutWrite, si, 4*16, "uint") ;STARTUP_INFO {HANDLE hStdError}
   
   if (StrLen(WorkingDir) == 0)
      lpCurrentDirectory := 0
   else
      lpCurrentDirectory := &WorkingDir
   if (!DllCall("CreateProcess", "uint", 0
                               , "uint", &CmdLine
                               , "uint", 0
                               , "uint", 0
                               , "int", true
                               , "uint", 0
                               , "uint", 0
                               , "uint", lpCurrentDirectory
                               , "uint", &si
                               , "uint", &pi))
   {
      FirstWin32Error := A_LastError
      DllCall("CloseHandle", "uint", hStdoutRead) ;HANDLE hThread
      DllCall("CloseHandle", "uint", hStdoutWrite) ;HANDLE hThread
;      DllCall("CloseHandle", "uint", hStdinRead) ;HANDLE hThread
;      DllCall("CloseHandle", "uint", hStdinWrite) ;HANDLE hThread
      CONSOLEAPPS_PRIVATE_throw(CONSOLEAPPS_PRIVATE_ERROR_WIN32_ERROR, "Unable to run process: ", "", FirstWin32Error)
   }
   hProcess := NumGet(pi, 0, "uint")
   hThread := NumGet(pi, 4, "uint")
   PID := NumGet(pi, 8, "uint") ;DWORD dwProcessId
   DllCall("CloseHandle", "uint", hThread) ;HANDLE hThread
   
   ;    struct ConsoleAppsProcessInfo
   ;    {
   ;        int hProcess;
   ;        int hStdoutRead;
   ;        int hStdoutWrite;
   ;        //int hStdinRead;
   ;        //int hStdinWrite;
   ;    }
   hHeap := DllCall("GetProcessHeap", "uint")
   lpCAPI := DllCall("HeapAlloc", "uint", hHeap, "uint", 0, "uint", 0xC, "uint")
   
   NumPut(hProcess, lpCAPI + 0x0)
   NumPut(hStdoutRead, lpCAPI + 0x4)
   NumPut(hStdoutWrite, lpCAPI + 0x8)
;   NumPut(hStdinRead, lpCAPI + 0xC)
;   NumPut(hStdinWrite, lpCAPI + 0x10)

   return lpCAPI
}

;;; <summary>
;;;     Retrieves the standard output of a ConsoleApp that was run using ConsoleApp_Run().
;;; </summary>
;;; <param="ConsoleAppHandle">
;;;     A handle to a ConsoleApp that was created in a call to ConsoleApp_Run.
;;; </param>
;;; <param="Stdout">
;;;     A variable that is to be appended with the standard output of the ConsoleApp. The
;;;     variable is appended with all of the standard output of the program since the last
;;;     call to ConsoleApp_GetStdOut.
;;; </param>
;;; <param="BytesAppended">
;;;     A variable that is to receive the number of bytes that were appended to the Stdout
;;;     parameter.
;;; </param>
;;; <returns>
;;;     Returns true if the ConsoleApp is still running.
;;;     Returns false if the ConsoleApp is no longer running.
;;; </returns>
;;; <remarks>
;;;     The output of programs that are explicity redirected or "piped" in their command-lines will
;;;     not be captured by this function (e.g. "cmd.exe /C echo Hello World > test.txt").
;;; </remarks>
;;; <example>
;;;     ; To run this example perform the following steps:
;;;     ;   1. Create a folder named ConsoleApps
;;;     ;   2. Copy "ConsoleApps.ahk" to the folder
;;;     ;   3. Create 2 new files in the folder named "ConsoleApps_Test.ahk" and "ConsoleApps_TestFile.bat"
;;;     ;   4. Paste the following text (without the comments) into "ConsoleApps_TestFile.bat":
;;;             @ECHO OFF
;;;             ECHO Processing %2 1 of 3
;;;             ping 127.0.0.1 -n 2 -w 1000 > nul
;;;             ping 127.0.0.1 -n 1 -w 1000 > nul
;;;             ECHO Processing %2 2 of 3
;;;             ping 127.0.0.1 -n 2 -w 1000 > nul
;;;             ping 127.0.0.1 -n 1 -w 1000 > nul
;;;             ECHO Processing %2 3 of 3
;;;             ping 127.0.0.1 -n 2 -w 1000 > nul
;;;             ping 127.0.0.1 -n 1 -w 1000 > nul
;;;             ECHO Processing Complete;;;     ;   
;;;     ;   5. Paste the following text (without the comments) into "ConsoleApps_Test.ahk", and then run "ConsoleApps_Test.ahk"
;;;             #NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
;;;             #Include ConsoleApps.ahk
;;;             
;;;             ;Create GUI window with an edit control to print the output.
;;;             Gui, Add, Edit, x15 y15 w460 h300 -Wrap ReadOnly hscroll vtxtStdout,
;;;             Gui, Show, w490 h330, Standard Input/Output Redirection Example
;;;             
;;;             ; Create the process
;;;             ConsoleAppHandle := ConsoleApp_Run("ConsoleApps_TestFile.bat -p nothing", A_ScriptDir)
;;;             ; In reality, this function will never return with a ConsoleAppHandle value of 0, but
;;;             ; it is good to check for this possibility in case future versions do return a value of
;;;             ; 0 for failure.
;;;             if (ConsoleAppHandle == 0)
;;;             {
;;;                 MsgBox, Error running cmd.exe
;;;                 ExitApp
;;;             }
;;;             
;;;             /* Continuously retrieve the process's output and write it to the edit control 
;;;              * in a loop as it arrives.
;;;              */
;;;             Loop
;;;             {
;;;                 ; Append the ConsoleApps standard output to StdOut.
;;;                 ConsoleAppStillRunning := ConsoleApp_GetStdOut(ConsoleAppHandle, StdOut, BytesAppended, ExitCode)
;;;                 ; If StdOut was appended with new text, write it to the GUI window.
;;;                 if (BytesAppended)
;;;                    GuiControl, , txtStdOut, %StdOut%  ; write the output to the edit control.
;;;                 ; If the ConsoleApp is no longer running, then stop checking for output.
;;;                 if (!ConsoleAppStillRunning)
;;;                    break
;;;                 ; Give up remainder of time-slice to give the child process a chance to generate more output
;;;                 ; before checking again.
;;;                 sleep 0
;;;             }
;;;             ; This function must be called when the ConsoleAppHandle is no longer needed.
;;;             ConsoleApp_CloseHandle(ConsoleAppHandle)
;;;             if (!ExitCode)
;;;                 MsgBox, The program has completed successfully.
;;;             else
;;;                 MsgBox, The program has exitted with an error code of %ExitCode%.
;;;             return
;;;             
;;;             ; The following label is receives control when the user closes the GUI window.
;;;             GuiClose:
;;;             ExitApp
;;; </example>
ConsoleApp_GetStdOut(ConsoleAppHandle, byref Stdout, byref BytesAppended = 0, byref ExitCode="")
{
   global
   local hProcess, hStdoutRead, buf, ec, cb, FirstWin32Error
   
   ConsoleApps_Initialize()

   hProcess := NumGet(ConsoleAppHandle + 0x0)
   hStdoutRead := NumGet(ConsoleAppHandle + 0x4)
;   hStdoutWrite := NumGet(ConsoleAppHandle + 0x8)
;   hStdinRead := NumGet(ConsoleAppHandle + 0xC)
;   hStdinWrite := NumGet(ConsoleAppHandle + 0x10)
   
   CONSOLEAPPS_PRIVATE_malloc(cb, 4)
   BytesAppended := 0
   Loop
   {
      DllCall("PeekNamedPipe", "uint", hStdoutRead, "uint", 0, "uint", 0, "uint", 0, "uint", &cb, "uint", 0)
      if (!NumGet(cb, 0, "uint"))
         break
      if (!CONSOLEAPPS_PRIVATE_ReadFile(hStdoutRead, buf, cb, 1024))
      {
         FirstWin32Error := A_LastError
         ConsoleApp_CloseHandle(ConsoleAppHandle)
         CONSOLEAPPS_PRIVATE_throw(CONSOLEAPPS_PRIVATE_ERROR_WIN32_ERROR, "Error reading process stdout: ", "", FirstWin32Error)
      }
      stdout := stdout . buf
      BytesAppended += NumGet(cb, 0, "uint")
   }
   
   CONSOLEAPPS_PRIVATE_malloc(ec, 4)
   if (!DllCall("GetExitCodeProcess", uint, hProcess, uint, &ec))
   {
      FirstWin32Error := A_LastError
      ConsoleApp_CloseHandle(ConsoleAppHandle)
      CONSOLEAPPS_PRIVATE_throw(CONSOLEAPPS_PRIVATE_ERROR_WIN32_ERROR, "Error getting process exit code: ", "", FirstWin32Error)
   }
   ExitCode := NumGet(ec)
   
   ; If the exit code of the process is STILL_ACTIVE (0x103) then the process is still running
   if (ExitCode == 0x103)
      return true
   return false
}

;;; <summary>
;;;     Closes a ConsoleApp handle returned by ConsoleApp_Run()
;;; </summary>
;;; <param="ConsoleAppHandle">
;;;     Handle to close.
;;; </param>
;;; <returns>
;;;     This function does not return a value.
;;; </returns>
;;; <remarks>
;;;     Every handle returned by a successful call to ConsoleApp_Run() must be closed
;;;     with this function.
;;; </remarks>
ConsoleApp_CloseHandle(ConsoleAppHandle)
{
   global
   local hProcess, hStdoutRead, hStdOutWrite

   ConsoleApps_Initialize()

   hProcess := NumGet(ConsoleAppHandle + 0x0)
   hStdoutRead := NumGet(ConsoleAppHandle + 0x4)
   hStdoutWrite := NumGet(ConsoleAppHandle + 0x8)
;   hStdinRead := NumGet(ConsoleAppHandle + 0xC)
;   hStdinWrite := NumGet(ConsoleAppHandle + 0x10)
   ; If any of the following functions fail, then the ConsoleAppProcessInfo structure must
   ; not be valid, or has already been closed. In this case we raise an error to alert the
   ; user of a possible mis-handling of the handle and prevent further corruption and memory 
   ; leaks.
   if (!DllCall("CloseHandle", "uint", hProcess)) ;HANDLE hThread
      CONSOLEAPPS_PRIVATE_throw(ERROR_GENERIC_ERROR, "Error ConsoleAppHandle is corrupt or has already been closed.")
   if (!DllCall("CloseHandle", "uint", hStdoutRead)) ;HANDLE hThread
      CONSOLEAPPS_PRIVATE_throw(ERROR_GENERIC_ERROR, "Error ConsoleAppHandle is corrupt or has already been closed.")
   if (!DllCall("CloseHandle", "uint", hStdoutWrite)) ;HANDLE hThread
      CONSOLEAPPS_PRIVATE_throw(ERROR_GENERIC_ERROR, "Error ConsoleAppHandle is corrupt or has already been closed.")
   /*
   if (!DllCall("CloseHandle", "uint", hStdinRead)) ;HANDLE hThread
      CONSOLEAPPS_PRIVATE_throw(ERROR_GENERIC_ERROR, "Error ConsoleAppHandle is corrupt or has already been closed.")
   if (!DllCall("CloseHandle", "uint", hStdinWrite)) ;HANDLE hThread
      CONSOLEAPPS_PRIVATE_throw(ERROR_GENERIC_ERROR, "Error ConsoleAppHandle is corrupt or has already been closed.")
   */
   hHeap := DllCall("GetProcessHeap", "uint")
   if (!DllCall("HeapFree", "uint", hHeap, "uint", 0, "uint", ConsoleAppHandle))
      CONSOLEAPPS_PRIVATE_throw(CONSOLEAPPS_PRIVATE_ERROR_WIN32_ERROR, "Error deallocating heap. This is a serious error which can cause heap corruption. This program will now close. Specifically: ")
}


; +----------------------+
; | PRIVATE DECLARATIONS |
; +----------------------+

ConsoleApps_Initialize()
{
   global
   
   if (ConsoleApps_Initialized)
      Return
   ConsoleApps_Initialized := True
   
   CONSOLEAPPS_PRIVATE_EXIT_FAILURE := 1
   CONSOLEAPPS_PRIVATE_MAXIMUM_INTEGER := 0x7FFFFFFF  ; 2147483647
   CONSOLEAPPS_PRIVATE_MAXIMUM_UNSIGNED_INTEGER := 0xFFFFFFFF  ; 4294967295

   CONSOLEAPPS_PRIVATE_ERROR_NOT_ENOUGH_MEMORY := 0x8
   CONSOLEAPPS_PRIVATE_ERROR_INVALID_PARAMETER	:= 0x57
   CONSOLEAPPS_PRIVATE_ERROR_WIN32_ERROR := CONSOLEAPPS_PRIVATE_MAXIMUM_UNSIGNED_INTEGER + 1

   CONSOLEAPPS_PRIVATE_STD_ERROR_CODES[%CONSOLEAPPS_PRIVATE_ERROR_NOT_ENOUGH_MEMORY%] := "Not enough storage is available to process this command."
   CONSOLEAPPS_PRIVATE_STD_ERROR_CODES[%CONSOLEAPPS_PRIVATE_ERROR_INVALID_PARAMETER%] := "Invalid parameter value."
   CONSOLEAPPS_PRIVATE_STD_ERROR_CODES[%CONSOLEAPPS_PRIVATE_ERROR_WIN32_ERROR%] := "Unspecified exception."
}

;BufferSize is including the terminating null character.
CONSOLEAPPS_PRIVATE_ReadFile(hFile, byref buf, byref BytesRead=0, BufferSize=4096)
{
   if (BufferSize <= 0)
      return false
   CONSOLEAPPS_PRIVATE_malloc(Buf, BufferSize)
   CONSOLEAPPS_PRIVATE_malloc(BytesRead, 4)
   if (!DllCall("ReadFile", "uint", hFile, "uint", &buf, "uint", BufferSize-1, "uint", &BytesRead, "uint", 0))
      return false
   BytesRead := NumGet(BytesRead, 0, "uint")
   NumPut(0, Buf, BytesRead, "uchar") ;terminate data read with a null
   VarSetCapacity(buf, -1)
   return true
}

CONSOLEAPPS_PRIVATE_abort()
{
	global
	Critical, %CONSOLEAPPS_PRIVATE_MAXIMUM_INTEGER%
	CONSOLEAPPS_PRIVATE_STD_Exiting := True
	OnExit
	BlockInput, MouseMoveOff
	BlockInput, Off
	ExitApp, %CONSOLEAPPS_PRIVATE_EXIT_FAILURE%
}

CONSOLEAPPS_PRIVATE_calloc(byref Var, size, fillbyte=0)
{
   global
   local cb
   if (cb := VarSetCapacity(Var, size, fillbyte) != size)
      CONSOLEAPPS_PRIVATE_throw(CONSOLEAPPS_PRIVATE_ERROR_NOT_ENOUGH_MEMORY)
   return cb
}

CONSOLEAPPS_PRIVATE_free(byref Var)
{
   VarSetCapacity(Var, 0)
}

CONSOLEAPPS_PRIVATE_WIN32_MAKELANGID(p, s)
{
   return (s << 10) | p
}

CONSOLEAPPS_PRIVATE_malloc(byref var, size)
{
   global
   if (cb := VarSetCapacity(var, size) != size)
      CONSOLEAPPS_PRIVATE_throw(CONSOLEAPPS_PRIVATE_ERROR_NOT_ENOUGH_MEMORY)
   return cb
}

;;; <summary>
;;;     Returns the C string at the address in lpStr
;;; </summary>
;;; <param="lpStr">
;;;     The address of a string in memory. lpStr is an AutoHotkey integer numeric.
;;;     NOT a 4-byte dword value.
;;; </param>
CONSOLEAPPS_PRIVATE_PtrToStr(lpStr)
{
   return DllCall("MSVCRT\memcpy", UINT, lpStr, UINT, 0, UINT, 0, "str")  ; Doesn't copy data, only returns string
}

; ParamName is only valid if ErrorCode is CONSOLEAPPS_PRIVATE_ERROR_INVALID_PARAMETER
; LastWin32Error is only necessary if ErrorCode is CONSOLEAPPS_PRIVATE_ERROR_WIN32_ERROR
; and the A_LastError built-in variable is no longer valid.
CONSOLEAPPS_PRIVATE_throw(ErrorCode, ErrorMessage="", ParamName="", LastWin32Error="")
{
   global
   local lpMsg
   Critical, %CONSOLEAPPS_PRIVATE_MAXIMUM_INTEGER%
   if (ErrorCode == CONSOLEAPPS_PRIVATE_ERROR_INVALID_PARAMETER)
   {
      if (StrLen(ErrorMessage) == 0)
         ErrorMessage := CONSOLEAPPS_PRIVATE_STD_ERROR_CODES[%ErrorCode%]
      if (StrLen(ParamName) != 0)
         ErrorMessage .= "\nParameter: " . ParamName
   }
   else if (ErrorCode == CONSOLEAPPS_PRIVATE_ERROR_WIN32_ERROR)
   {
      if (StrLen(ErrorMessage) == 0)
         ErrorMessage := CONSOLEAPPS_PRIVATE_STD_ERROR_CODES[%ErrorCode%]
      if (StrLen(LastWin32Error) == 0)
         LastWin32Error := A_LastError
      CONSOLEAPPS_PRIVATE_malloc(lpMsg, 4)
      /* DWORD TCharsCopied = FormatMessage(FORMAT_MESSAGE_ALLOCATE_BUFFER|FORMAT_MESSAGE_FROM_SYSTEM|FORMAT_MESSAGE_IGNORE_INSERTS,
       *                                    0,
       *                                    LastWin32Error,
       *                                    MAKELANGID(LANG_NEUTRAL,SUBLANG_DEFAULT),
       *                                    (LPTSTR)&lpMsg,
       *                                    0,
       *                                    NULL)
       */
      if (t := DllCall("FormatMessageA"
                , "uint", 0x1300
                , "uint", 0
                , "uint", LastWin32Error
                , "uint", CONSOLEAPPS_PRIVATE_WIN32_MAKELANGID(0x0, 0x1)
                , "uint", &lpMsg
                , "uint", 0
                , "uint", 0, "uint") == 0)
      {
         ErrorMessage .= CONSOLEAPPS_PRIVATE_STD_ERROR_CODES[%CONSOLEAPPS_PRIVATE_ERROR_WIN32_ERROR%]
      }
      else
      {
         ErrorMessage .= CONSOLEAPPS_PRIVATE_PtrToStr(NumGet(lpMsg))
         DllCall("LocalFree", "uint", lpMsg)
         CONSOLEAPPS_PRIVATE_free(lpMsg)
      }
   }
   else
   {
      if (StrLen(ErrorMessage) == 0)
         ErrorMessage := CONSOLEAPPS_PRIVATE_STD_ERROR_CODES[%ErrorCode%]
   }
   MsgBox, 0x1010, %A_ScriptName%, %ErrorMessage%
   CONSOLEAPPS_PRIVATE_abort()
}
