#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance, force
    SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

currentDir:=A_Args[1]
A_Args.RemoveAt(1)
for k, v in A_Args {
        try {
            bytes := ComObjCreate("Scripting.FileSystemObject").GetFolder(currentDir "\" v).Size
        } catch e {
            bytes:=FolderSize(currentDir "\" v)
        }
        formattedBytes:=autoByteFormat(bytes)

        send_string(v "|" formattedBytes "|" bytes, 2)
}
send_string(v "|" formattedBytes "|" bytes, 3)
    
ExitApp

send_string(stringToSend, number)  {
    stringToSend .= "|" number
    VarSetCapacity(message, size := StrPut(stringToSend, "UTF-16")*2, 0)
    StrPut(stringToSend, &message, "UTF-16")
    VarSetCapacity(COPYDATASTRUCT, A_PtrSize*3)
    NumPut(size, COPYDATASTRUCT, A_PtrSize, "UInt")
    NumPut(&message, COPYDATASTRUCT, A_PtrSize*2)
    DetectHiddenWindows, On
    SetTitleMatchMode, 2
    SendMessage, WM_COPYDATA := 0x4A,, &COPYDATASTRUCT,, ahk_explorer.ahk ahk_class AutoHotkey
}
autoByteFormat(size, decimalPlaces = 2)
{
    static sizes :=["KB", "MB", "GB", "TB"]
    
    sizeIndex := 0
    
    while (size >= 1024)
    {
        sizeIndex++
        size /= 1024.0
        
        if (sizeIndex = sizes.Length())
            break
    }
    
    return (sizeIndex = 0) ? size " B"
    : round(size, decimalPlaces) . " " . sizes[sizeIndex]
}
FolderSize(folder) { ;gwarble 2020 - any faster method to get folder size?
Loop, Parse, % RunCMD("robocopy /l /nfl /ndl """ folder """ . /r:0 /w:0 /e /bytes"), `n, `r
 If InStr(A_LoopField,"Bytes :") ;thanks SKAN for RunCMD()
  For each, z in StrSplit(RegExReplace(A_LoopField, "\s+", " "), " ")
   If (A_Index = 4) ;probably much better ways to parse result
    Return z
}

RunCMD(CmdLine, WorkingDir:="", Codepage:="CP0", Fn:="RunCMD_Output") {  ;         RunCMD v0.94        
Local         ; RunCMD v0.94 by SKAN on D34E/D37C @ autohotkey.com/boards/viewtopic.php?t=74647                                                             
Global A_Args ; Based on StdOutToVar.ahk by Sean @ autohotkey.com/board/topic/15455-stdouttovar

  Fn := IsFunc(Fn) ? Func(Fn) : 0
, DllCall("CreatePipe", "PtrP",hPipeR:=0, "PtrP",hPipeW:=0, "Ptr",0, "Int",0)
, DllCall("SetHandleInformation", "Ptr",hPipeW, "Int",1, "Int",1)
, DllCall("SetNamedPipeHandleState","Ptr",hPipeR, "UIntP",PIPE_NOWAIT:=1, "Ptr",0, "Ptr",0)

, P8 := (A_PtrSize=8)
, VarSetCapacity(SI, P8 ? 104 : 68, 0)                          ; STARTUPINFO structure      
, NumPut(P8 ? 104 : 68, SI)                                     ; size of STARTUPINFO
, NumPut(STARTF_USESTDHANDLES:=0x100, SI, P8 ? 60 : 44,"UInt")  ; dwFlags
, NumPut(hPipeW, SI, P8 ? 88 : 60)                              ; hStdOutput
, NumPut(hPipeW, SI, P8 ? 96 : 64)                              ; hStdError
, VarSetCapacity(PI, P8 ? 24 : 16)                              ; PROCESS_INFORMATION structure

  If not DllCall("CreateProcess", "Ptr",0, "Str",CmdLine, "Ptr",0, "Int",0, "Int",True
                ,"Int",0x08000000 | DllCall("GetPriorityClass", "Ptr",-1, "UInt"), "Int",0
                ,"Ptr",WorkingDir ? &WorkingDir : 0, "Ptr",&SI, "Ptr",&PI)  
     Return Format("{1:}", "", ErrorLevel := -1
                   ,DllCall("CloseHandle", "Ptr",hPipeW), DllCall("CloseHandle", "Ptr",hPipeR))

  DllCall("CloseHandle", "Ptr",hPipeW)
, A_Args.RunCMD := { "PID": NumGet(PI, P8? 16 : 8, "UInt") }      
, File := FileOpen(hPipeR, "h", Codepage)

, LineNum := 1,  sOutput := ""
  While (A_Args.RunCMD.PID + DllCall("Sleep", "Int",0))
    and DllCall("PeekNamedPipe", "Ptr",hPipeR, "Ptr",0, "Int",0, "Ptr",0, "Ptr",0, "Ptr",0)
        While A_Args.RunCMD.PID and (Line := File.ReadLine())
          sOutput .= Fn ? Fn.Call(Line, LineNum++) : Line

  A_Args.RunCMD.PID := 0
, hProcess := NumGet(PI, 0)
, hThread  := NumGet(PI, A_PtrSize)

, DllCall("GetExitCodeProcess", "Ptr",hProcess, "PtrP",ExitCode:=0)
, DllCall("CloseHandle", "Ptr",hProcess)
, DllCall("CloseHandle", "Ptr",hThread)
, DllCall("CloseHandle", "Ptr",hPipeR)

, ErrorLevel := ExitCode

Return sOutput  
}

f3::Exitapp
