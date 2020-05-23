File = %A_ScriptDir%\test.ahk
Script =
(%
Loop, 10
{
  Sleep 2000
  OutputDebug, OutputDebug %A_Index%``n
  FileAppend, StdOut %A_Index%``n, *
  FileAppend, StdErr %A_Index%``n, **
}
)
FileDelete, %File%
FileAppend, %script%, %File%

cmd = %A_AHKPath% /ErrorStdOut "%File%"
TimerFuncObj := StdOutStream( cmd, "StdOutStream_Callback" )
SetTimer, %TimerFuncObj%, 4000

Loop, 20 {
  StdOutStream_Callback("Loop " A_Index "`n")
  Sleep, 2000
}

StdOutStream_Callback(Line){
  static t
  t .= Line
  CoordMode, ToolTip, Client 
  ToolTip, Callback:`nPress F2 to kill StdOutStream`nPress ESC to exit`n%t%, 0 , 0, 1
}

F2:: StdOutStream_Kill()
Esc:: ExitApp

;######### Below are the 3 functions 

StdOutStream_Kill(hPID:=""){
  static sPID
  If hPID
    sPID := hPID
  Else If sPID
    Process, Close, %sPID%
}

StdOutStream(sCmd, callBack, encoding := "CP0"){
  static HANDLE_FLAG_INHERIT := 0x00000001, flags := HANDLE_FLAG_INHERIT
       , STARTF_USESTDHANDLES := 0x100, CREATE_NO_WINDOW := 0x08000000

  If Isfunc( Callback ) < 2
    throw Exception("Callback: """ Callback """ is not a function with one parameter.", A_ThisFunc)
    
  DllCall("CreatePipe", PtrP, hPipeRead, PtrP, hPipeWrite, Ptr, 0, UInt, 0)
  , DllCall("SetHandleInformation", Ptr, hPipeWrite, UInt, flags, UInt, HANDLE_FLAG_INHERIT)

  , VarSetCapacity(STARTUPINFO , siSize :=    A_PtrSize*4 + 4*8 + A_PtrSize*5, 0)
  , NumPut(siSize              , STARTUPINFO)
  , NumPut(STARTF_USESTDHANDLES, STARTUPINFO, A_PtrSize*4 + 4*7)               ; dwFlags
  , NumPut(hPipeWrite          , STARTUPINFO, A_PtrSize*4 + 4*8 + A_PtrSize*3) ; hStdOutput
  , NumPut(hPipeWrite          , STARTUPINFO, A_PtrSize*4 + 4*8 + A_PtrSize*4) ; hStdError

  , VarSetCapacity(PROCESS_INFORMATION, A_PtrSize*2 + 4*2, 0)

  if !DllCall("CreateProcess", UInt, 0, Ptr, &sCmd, UInt, 0, UInt, 0, Int, true, UInt, CREATE_NO_WINDOW
                             , UInt, 0, UInt, 0, Ptr, &STARTUPINFO, Ptr, &PROCESS_INFORMATION){
    DllCall("CloseHandle", Ptr, hPipeRead)
    , DllCall("CloseHandle", Ptr, hPipeWrite)
    , throw Exception("CreateProcess failed", A_ThisFunc)
  }
  PID := NumGet(PROCESS_INFORMATION, A_PtrSize*2, "UInt")
  , StdOutStream_Kill(PID)
  , DllCall("CloseHandle", Ptr, hPipeWrite)
   
  Return Func("StdOutStream_Read").Bind(hPipeRead, PROCESS_INFORMATION, encoding, Callback)
}

StdOutStream_Read(hPipeRead, PROCESS_INFORMATION, encoding, Callback){
  ; Before reading, we check if the pipe has been written to, to avoid freezings.
  If DllCall( "PeekNamedPipe", Ptr,hPipeRead, Ptr,0, UInt,0, Ptr,0, UIntP,nTot, Ptr,0 ){
    If !nTot  ; If the pipe buffer is empty, do nothing now
      Return
   ; Pipe buffer is not empty, so we can read it.
    VarSetCapacity(sTemp, nTot+1)
    , DllCall( "ReadFile", Ptr,hPipeRead, Ptr,&sTemp, UInt,nTot, PtrP,nSize, Ptr,0 )
    , %Callback%(StrGet(&sTemp, nSize, encoding))
  }Else{
    SetTimer,, off
    DllCall("GetExitCodeProcess", Ptr,NumGet(PROCESS_INFORMATION), UIntP,ExitCode )
    , DllCall("CloseHandle",   Ptr, NumGet(PROCESS_INFORMATION))
    , DllCall("CloseHandle",   Ptr, NumGet(PROCESS_INFORMATION, A_PtrSize))
    , DllCall("CloseHandle",   Ptr, hPipeRead)
    , %Callback%( "ExitCode: " ExitCode "`n")
  }
}

