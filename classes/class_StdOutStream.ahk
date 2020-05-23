/*  Usage
StdOut := new StdOutStream("ShowTT", 100)
cmd = %A_AHKPath% /ErrorStdOut "%File%"
StdOut.Run( cmd )

ShowTT(Line){
  static t
  t .= Line
  CoordMode, ToolTip, Client 
  ToolTip, Callback:`n%t%, 0 , 0, 1
}
*/
 
Class StdOutStream {

  __New(CallbackFunction, Period:=500) {
    If Isfunc( CallbackFunction ) < 2
      throw Exception("Callback: """ CallbackFunction """ is not a function with one parameter.")
    this.Callback := CallbackFunction
    this.Period := Period
  }

  Run(sCmd, sDir := 0, encoding := "CP0"){
    static HANDLE_FLAG_INHERIT := 0x00000001, flags := HANDLE_FLAG_INHERIT
         , STARTF_USESTDHANDLES := 0x100, CREATE_NO_WINDOW := 0x08000000

    DllCall("CreatePipe", "PtrP", hPipeRead, "PtrP", hPipeWrite, "Ptr", 0, "UInt", 0)
    , DllCall("SetHandleInformation", "Ptr", hPipeWrite, "UInt", flags, "UInt", HANDLE_FLAG_INHERIT)

    , VarSetCapacity(STARTUPINFO , siSize :=    A_PtrSize*4 + 4*8 + A_PtrSize*5, 0)
    , NumPut(siSize              , STARTUPINFO)
    , NumPut(STARTF_USESTDHANDLES, STARTUPINFO, A_PtrSize*4 + 4*7)               ; dwFlags
    , NumPut(hPipeWrite          , STARTUPINFO, A_PtrSize*4 + 4*8 + A_PtrSize*3) ; hStdOutput
    , NumPut(hPipeWrite          , STARTUPINFO, A_PtrSize*4 + 4*8 + A_PtrSize*4) ; hStdError

    , VarSetCapacity(PROCESS_INFORMATION, A_PtrSize*2 + 4*2, 0)

    if !DllCall("CreateProcess", "UInt", 0, "Ptr", &sCmd, "UInt", 0, "UInt", 0, "Int", true, "UInt", CREATE_NO_WINDOW
                               , "UInt", 0, "UInt", &sDir, "Ptr", &STARTUPINFO, "Ptr", &PROCESS_INFORMATION){
      DllCall("CloseHandle", "Ptr", hPipeRead)
      , DllCall("CloseHandle", "Ptr", hPipeWrite)
      throw Exception("CreateProcess failed", A_ThisFunc)
    }
    DllCall("CloseHandle", "Ptr", hPipeWrite)
    , this.hPipeRead := hPipeRead
    , this.hProcess := NumGet(PROCESS_INFORMATION, "UInt")
    , this.hThread := NumGet(PROCESS_INFORMATION, A_PtrSize, "UInt")
    , this.PID := NumGet(PROCESS_INFORMATION, A_PtrSize*2, "UInt")
    , this.encoding := encoding
    
    , timer := ObjBindMethod(this, "ReadStdOut")
    SetTimer, % timer, % this.Period
  }
  
  Exists(){
    Return this.PID
  }
  
  Kill(){
    Process, Close, % this.PID
  }
  
  ReadStdOut(){
    Callback := this.Callback
    ; Before reading, we check if the pipe has been written to, to avoid freezings.
    If DllCall( "PeekNamedPipe", "Ptr",this.hPipeRead, "Ptr",0, "UInt",0, "Ptr",0, "UIntP",nTot, "Ptr",0 ){
      If !nTot  ; If the pipe buffer is empty, do nothing now
        Return
      ; Pipe buffer is not empty, so we can read it.
      VarSetCapacity(sTemp, nTot+1)
      , DllCall( "ReadFile", "Ptr",this.hPipeRead, "Ptr",&sTemp, "UInt",nTot, "PtrP",nSize, "Ptr",0 )
      , %Callback%(StrGet(&sTemp, nSize, this.encoding))
    }Else{
      SetTimer, , Off
      this.PID := ""
      , DllCall("GetExitCodeProcess", "Ptr",this.hProcess, "UIntP",ExitCode )
      , DllCall("CloseHandle",   "Ptr", this.hProcess)
      , DllCall("CloseHandle",   "Ptr", this.hThread)
      , DllCall("CloseHandle",   "Ptr", this.hPipeRead)
      , this.hPipeRead := this.hProcess := this.hThread := this.encoding := ""
      , %Callback%("ExitCode: " ExitCode "`n")
    }
  }
}
