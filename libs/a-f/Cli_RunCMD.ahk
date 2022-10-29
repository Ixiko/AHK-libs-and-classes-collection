; Title:   	(41) RunCMD() v0.94 : Capture stdout to variable. Non-blocking version. Pre-process/omit individual lines.
; Link:     	https://www.autohotkey.com/boards/viewtopic.php?f=6&t=74647&start=200
; Author:	robodesign
; Date:   	05 Aug 2022
; for:     	AHK_L

/*


*/

Cli_RunCMD(CmdLine, WorkingDir:="", Codepage:="CP850", Fn:="RunCMD_Output", maxDelay:=15250) {
; modified by Marius Șucan
  Local         ; RunCMD v0.94 by SKAN on D34E/D37C @ https://www.autohotkey.com/boards/viewtopic.php?t=74647
  Global A_Args ; Based on StdOutToVar.ahk by Sean @ https://www.autohotkey.com/board/topic/15455-stdouttovar

  Fn := IsFunc(Fn) ? Func(Fn) : 0
  r := DllCall("CreatePipe", "UPtr*",hPipeR:=0, "UPtr*",hPipeW:=0, "UPtr",0, "Int",0)
  If (r=0 || r="")
     Return

  DllCall("SetHandleInformation", "UPtr",hPipeW, "Int",1, "Int",1)
  DllCall("SetNamedPipeHandleState","UPtr",hPipeR, "UInt*",PIPE_NOWAIT:=1, "UPtr",0, "UPtr",0)

  P8 := (A_PtrSize=8) ? 1 : 0
  VarSetCapacity(SI, P8 ? 104 : 68, 0)                          ; STARTUPINFO structure
  NumPut(P8 ? 104 : 68, SI)                                     ; size of STARTUPINFO
  NumPut(STARTF_USESTDHANDLES:=0x100, SI, P8 ? 60 : 44,"UInt")  ; dwFlags
  NumPut(hPipeW, SI, P8 ? 88 : 60)                              ; hStdOutput
  NumPut(hPipeW, SI, P8 ? 96 : 64)                              ; hStdError
  VarSetCapacity(PI, P8 ? 24 : 16)                              ; PROCESS_INFORMATION structure
  g := DllCall("GetPriorityClass", "UPtr",-1, "UInt")
  r := DllCall("CreateProcess", "UPtr",0, "Str",CmdLine, "UPtr",0, "Int",0, "Int",1
            ,"Int",0x08000000 | g, "Int",0
            ,"UPtr",WorkingDir ? &WorkingDir : 0, "UPtr",&SI, "UPtr",&PI)

  If (r=0 || r="")
  {
     z := ErrorLevel "|" A_LastError
     DllCall("CloseHandle", "UPtr",hPipeW)
     DllCall("CloseHandle", "UPtr",hPipeR)
     Return ; z
  }

  DllCall("CloseHandle", "UPtr",hPipeW)
  PIDu := NumGet(PI, P8? 16 : 8, "UInt")
  A_Args.RunCMD := {"PID": PIDu}
  FileObj := FileOpen(hPipeR, "h", Codepage)
  startTime := A_TickCount
  LineNum := 1,  sOutput := ""
  timeOut := 0
  While ((A_Args.RunCMD.PID + DllCall("Sleep", "Int",0)) && DllCall("PeekNamedPipe", "UPtr",hPipeR, "UPtr",0, "Int",0, "UPtr",0, "UPtr",0, "UPtr",0))
  {
       If (A_TickCount - startTime>maxDelay)
       {
          timeOut := 1
          Break
       }
       While (A_Args.RunCMD.PID and (Line := FileObj.ReadLine()))
       {
            sOutput .= Fn ? Fn.Call(Line, LineNum++) : Line
            If (A_TickCount - startTime>maxDelay)
            {
               timeOut := 1
               Break
            }
       }
  }

  If (timeOut=1)
  {
     SoundBeep 300, 100
     Process, Close, % PIDu
  }

  A_Args.RunCMD.PID := 0
  hProcess := NumGet(PI, 0)
  hThread  := NumGet(PI, A_PtrSize)

  DllCall("GetExitCodeProcess", "UPtr",hProcess, "UPtr*",ExitCode:=0)
  DllCall("CloseHandle", "UPtr",hProcess)
  DllCall("CloseHandle", "UPtr",hThread)
  DllCall("CloseHandle", "UPtr",hPipeR)
  FileObj.Close()
  ErrorLevel := ExitCode
  Return sOutput
}
