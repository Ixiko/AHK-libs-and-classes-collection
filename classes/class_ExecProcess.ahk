Class ExecProcess {  ; By dbgba    Thank FeiYue
    ; ProcessVar := New ExecProcess("LabelName")
    ; Create a new associated process, and restart it by repeating the new process variable. Up to 8 sets of parameters can be passed
    __New(LabelOrFunc, Arg1:="", Arg2:="", Arg3:="", Arg4:="", Arg5:="", Arg6:="", Arg7:="", Arg8:="") {
        if (A_Args[9]!="")
            Return
        ParentPID := DllCall("GetCurrentProcessId")
        if A_IsCompiled
            Run "%A_ScriptFullPath%" /f "%Arg1%" "%Arg2%" "%Arg3%" "%Arg4%" "%Arg5%" "%Arg6%" "%Arg7%" "%Arg8%" "%ParentPID%" "%LabelOrFunc%",,, pid
         else
            Run "%A_AhkPath%" /f "%A_ScriptFullPath%" "%Arg1%" "%Arg2%" "%Arg3%" "%Arg4%" "%Arg5%" "%Arg6%" "%Arg7%" "%Arg8%" "%ParentPID%" "%LabelOrFunc%",,, pid
        this.pid := pid
    }

    ; ProcessVar := ""   Clear this "process variable" to close the corresponding process
    __Delete() {
        DetectHiddenWindows On   ; Logging Out Script
        PostMessage, 0x111, 65307,,, % A_ScriptFullPath " ahk_pid " this.pid
        Process Close, % this.pid
    }

    ; Exit synchronously with the new process and use asynchronous wait for the main process to finish callback
    _CallBack() {
        ExitApp
    }

    _ScriptStart() {
        Static init:=ExecProcess._ScriptStart()
        #NoTrayIcon
        SetBatchLines % ("-1", Bch:=A_BatchLines)
        OnMessage(0x4a, "_ExecProcessReceive_WM_COPYDATA")
        Gui _ExecProcess_Label%A_ScriptHwnd%: Add, Button, g_ExecProcessGuiHideLabelGoto
        if (A_Args[9]="") {
            DetectHiddenWindows % ("On", DHW:=A_DetectHiddenWindows)
            PostMessage, 0x111, 65307,,, <<ExecProcessParent>> ahk_class AutoHotkeyGUI
            DetectHiddenWindows %DHW%
            Menu Tray, Icon
            Gui _ExecProcess_Label%A_ScriptHwnd%: Show, Hide, <<ExecProcessParent>>
            SetBatchLines %Bch%
            Return
        }
        _ := DllCall("OpenProcess", "Uint", 0x100000, "int", False, "Uint", A_Args[9], "Ptr")
        Gui _ExecProcess_Label%A_ScriptHwnd%: Show, Hide, % "<<ExecProcess" A_Args[10] ">>"
        Suspend On  ; Block hotkeys for new processes to avoid conflicts
        DllCall("RegisterWaitForSingleObject", "Ptr*", 0, "Ptr", _, "Ptr", RegisterCallback("ExecProcess._CallBack", "F"), "Ptr", 0, "Uint", -1, "Uint", 8)
        SetBatchLines %Bch%
    }

    Send(StringToSend, Label:="Parent", wParam:=0) {
        SetBatchLines % ("-1", Bch:=A_BatchLines)
        VarSetCapacity(CopyDataStruct, 3*A_PtrSize, 0)
        , NumPut((StrLen(StringToSend) + 1) * (A_IsUnicode ? 2 : 1), CopyDataStruct, A_PtrSize)
        , NumPut(&StringToSend, CopyDataStruct, 2*A_PtrSize)
        DetectHiddenWindows % ("On", DHW:=A_DetectHiddenWindows)
        WinGet, NewPID, PID, <<ExecProcess%Label%>> ahk_class AutoHotkeyGUI
        SendMessage, 0x4a, wParam, &CopyDataStruct,, ahk_pid %NewPID% ahk_class AutoHotkey
        DetectHiddenWindows %DHW%
        SetBatchLines %Bch%
        Return ErrorLevel
    }

} ; // Class End

; ================= Internal calls to private functions and labels =================

; The received string is saved in a variable named "CopyOfData" for calling
_ExecProcessReceive_WM_COPYDATA(wParam, lParam) {
    CopyOfData := StrGet(NumGet(lParam + 2*A_PtrSize))
    Switch wParam
    {    ; wParam is the internal communication number of the Process library
      Case 1 : _ExecProcessPostFunction(CopyOfData)
      Case 2 : _ExecProcessPostFunction(CopyOfData,1)
      Case 3 :
        LabelName := StrReplace(SubStr(CopyOfData, 1, 50), " ")
        if !IsLabel(LabelName)
            Return False
        Gosub %LabelName%
      Case 4 :
        LabelName := StrReplace(SubStr(CopyOfData, 1, 50), " ")
        if !IsLabel(LabelName)
            Return False
        Global _ExecProcessVarNameRtn := "_ExecProcessVarGetvarValue"
        Gosub _ExecProcessVarGetvarRtn
        _ExecProcessVarGetvarValue := LabelName
        DetectHiddenWindows On
        Control, Check, , Button1, % "<<ExecProcess" (A_Args[10]="" ? "Parent" : A_Args[10]) ">> ahk_class AutoHotkeyGUI"
      Case 5 : ExecProcessvarName := StrReplace(SubStr(CopyOfData, 1, 50), " "), %ExecProcessvarName% := SubStr(CopyOfData, 51)
      Case 6 : Global _ExecProcessVarGetvarRtnVar := CopyOfData
      Case 7 :
        Global _ExecProcessVarNameRtn := StrReplace(SubStr(CopyOfData, 1, 50), " ")
        Gosub _ExecProcessVarGetvarRtn
        ExecProcess.Send(_ExecProcessVarGetvarValue, , 6)
      Case 8 : ExecProcess.Send(A_IsPaused, , 6)
      Case 9 :
        SetBatchLines % ("-1", Bch:=A_BatchLines)
        Critical
        Suspend Off
        s:="||Home|End|Ins|Del|PgUp|PgDn|Left|Right|Up|Down|NumpadEnter|"
        Loop 254
            k:=GetKeyName(Format("VK{:X}",A_Index)), s.=InStr(s,"|" k "|") ? "" : k "|"
        For k,v in { Escape:"Esc", Control:"Ctrl", Backspace:"BS" }
            s:=StrReplace(s, k, v)
        s:=Trim(RegExReplace(s,"\|+","|"), "|")
        Loop, Parse, s, |
        {  ; Ability to disable most hotkeys and combinations
            Hotkey %A_LoopField%, Off, UseErrorLevel
            Hotkey ~%A_LoopField%, Off, UseErrorLevel
            Hotkey ^%A_LoopField%, Off, UseErrorLevel
            Hotkey #%A_LoopField%, Off, UseErrorLevel
            Hotkey !%A_LoopField%, Off, UseErrorLevel
            Hotkey +%A_LoopField%, Off, UseErrorLevel
            Hotkey ^!%A_LoopField%, Off, UseErrorLevel
            Hotkey ^+%A_LoopField%, Off, UseErrorLevel
            Hotkey ^#%A_LoopField%, Off, UseErrorLevel
        }
        For _,v in StrSplit(CopyOfData, "|")
            Hotkey %v%, On
        Critical Off
        SetBatchLines %Bch%
    }
    Return True
}

_ExecProcessPostFunction(CopyOfData, Synchronous:=0) {
    Global _ExecProcessFunctionName := StrReplace(SubStr(CopyOfData, 1, 50), " "), _ExecProcessFunctionArgs := []
    Loop 10
        _ExecProcessFunctionArgs[A_Index] := RegExReplace(CopyOfData, "(^.+ExecProcessFuncNameLabelArg" A_Index+10 ")(.*)(ExecProcessFuncNameLabelArg" A_Index+30 ".+)", "$2")
    if !IsFunc(_ExecProcessFunctionName)
        Return
    if Synchronous
        SetTimer _ProcessPostFunctionSetTimer, -1
      else
        Gosub _ProcessPostFunctionSetTimer
    Return

    _ProcessPostFunctionSetTimer:
    %_ExecProcessFunctionName%(_ExecProcessFunctionArgs*)
    Return
}

Goto _ExecProcessLabelSkip

_ExecProcessGuiHideLabelGoto:
    Goto %_ExecProcessVarGetvarValue%
Return

_ExecProcessVarGetvarRtn:
    Global _ExecProcessVarGetvarValue := %_ExecProcessVarNameRtn%
    Gui _debug_%A_ScriptHwnd%: Add, Text,, % _ExecProcessVarGetvarValue %_ExecProcessVarNameRtn%
Return

_ExecProcessLabelSkip:
SetBatchLines %A_BatchLines%
; ============================================================

; Let the process call the function [wait until the function is executed before returning]
; ExecFunction("ExecLabelF2", "MyFunc", "Hello World!")
ExecFunction(ProcessLabel:="Parent", FuncName:="", Arg1:="", Arg2:="", Arg3:="", Arg4:="", Arg5:="", Arg6:="", Arg7:="", Arg8:="", Arg9:="", Arg10:="") {
    L := "ExecProcessFuncNameLabelArg", FuncNameArgs := Format("{:-50}", FuncName) . L "11" Arg1 L "31" L "12" Arg2 L "32" L "13" Arg3 L "33" L "14" Arg4 L "34" L "15" Arg5 L "35" L "16" Arg6 L "36" L "17" Arg7 L "37" L "18" Arg8 L "38" L "19" Arg9 L "39" L "20" Arg10 L "40End"
    Return ExecProcess.Send(FuncNameArgs, ProcessLabel, 1)
}

; Let the process call the function [without waiting for the function to finish executing and return]
; ExecPostFunction("ExecLabelF2", "MyFunc", "Hello World!")
ExecPostFunction(ProcessLabel:="Parent", FuncName:="", Arg1:="", Arg2:="", Arg3:="", Arg4:="", Arg5:="", Arg6:="", Arg7:="", Arg8:="", Arg9:="", Arg10:="") {
    L := "ExecProcessFuncNameLabelArg", FuncNameArgs := Format("{:-50}", FuncName) . L "11" Arg1 L "31" L "12" Arg2 L "32" L "13" Arg3 L "33" L "14" Arg4 L "34" L "15" Arg5 L "35" L "16" Arg6 L "36" L "17" Arg7 L "37" L "18" Arg8 L "38" L "19" Arg9 L "39" L "20" Arg10 L "40End"
    Return ExecProcess.Send(FuncNameArgs, ProcessLabel, 2)
}

; Only asynchronous execution tags are independent of variable scopes, so the default is to use asynchronous execution
; ExecLabel("ExecLabelF2", "MyLabel")  Make the process jump to the specified label
ExecLabel(ProcessLabel:="Parent", LabelName:="", DoNotWait:=0) {
    if DoNotWait
        Rtn := ExecProcess.Send(Format("{:-50}", LabelName), ProcessLabel, 3)  ; Synchronisation
      else
        Rtn := ExecProcess.Send(Format("{:-50}", LabelName), ProcessLabel, 4)  ; Asynchronous
    Return Rtn
}

; ExecAssign("ExecLabelF2", "var", "123456")  Assigning values to process variables
ExecAssign(ProcessLabel:="Parent", VarName:="", Value:="") {
    Return ExecProcess.Send(Format("{:-50}", VarName) . Value, ProcessLabel, 5)
}

; MsgBox % ExecGetvar("ExecLabelF2","var")  Returns the contents of a variable in the process
ExecGetvar(ProcessLabel:="Parent", VarName:="") {
    Global _ExecProcessVarGetvarRtnVar
    ExecProcess.Send(Format("{:-50}", VarName), ProcessLabel, 7)
    Return _ExecProcessVarGetvarRtnVar
}

; MsgBox % ExecReady("ExecLabelF2")  Checking the status of a new process
ExecReady(ProcessLabel) {
    DetectHiddenWindows On
    Return WinExist("<<ExecProcess" ProcessLabel ">> ahk_class AutoHotkeyGUI") ? 1 : 0
}

; ExecPause("ExecLabelF2", "Off")  Suspend the specified process
ExecPause(ProcessLabel, ahkPauseOnOff:="On") {
    Global _ExecProcessVarGetvarRtnVar
    ExecProcess.Send("", ProcessLabel, 8) ; Return _ExecProcessVarGetvarRtnVar
    DetectHiddenWindows On
    if (_ExecProcessVarGetvarRtnVar=1) && (ahkPauseOnOff="Off")
        PostMessage, 0x111, 65306,,, <<ExecProcess%ProcessLabel%>> ahk_class AutoHotkeyGUI
      else if (_ExecProcessVarGetvarRtnVar=0) && (ahkPauseOnOff="On")
        PostMessage, 0x111, 65306,,, <<ExecProcess%ProcessLabel%>> ahk_class AutoHotkeyGUI
}

/*
; F3 and F4 are compensating measures, after pressing F3, F2 goes to the new process and cannot be enabled, you need to press F4 to revert to the main process.

; Enabling the hotkeys of the associated process will block the corresponding hotkeys of the main process when enabled. After blocking, you need F4 to restore the hotkey for the main process
F3::ExecHotkey("ExecLabelF2","Esc|F2|F3") ; Add multiple hotkeys separated by a | sign

; ExecHotkey Only most of the daily hotkeys and key combinations can be blocked, and some key combinations may be omitted. If you don't know, it is not recommended to enable hotkeys for new processes.
F4::ExecRecoveryHotkey("ExecLabelF2") ; Restore master process hotkeys
*/

; ExecHotkey("ExecLabelF2","Esc|F2|^1")  Enable hotkeys for the specified process
ExecHotkey(ProcessLabel, ProcessHotkey) {
    if (ProcessLabel!="")
        For _,v in StrSplit(ProcessHotkey, "|")
            Hotkey, %v%, Off
    ExecRecoveryHotkey(ProcessLabel, ProcessHotkey)
    , ExecProcess.Send(ProcessHotkey, ProcessLabel, 9)
}

; ExecRecoveryHotkey("ExecLabelF2")  Record and restore master process hotkeys
ExecRecoveryHotkey(ProcessLabel, ProcessHotkey:="") {
    Static _Boolean
    if (A_Args[9]!="")
        Return
    if !_Boolean
        _Boolean:=[]
    if (ProcessHotkey="") {
        For _,v in StrSplit(_Boolean[ProcessLabel], "|")
            Hotkey %v%, On
        Return _Boolean[ProcessLabel]
    }
    Return _Boolean[ProcessLabel] := ProcessHotkey
}

; ProcessExec("Loop{`nSleep 80`nToolTip test-%A_Index%`n}")  Temporary new process [Dependent on AHK interpreter]
; ProcessExec("")  Ending temporary processes. [The second parameter with number can not repeat the new temporary process]
ProcessExec(NewCode:="", flag:="Default") {
    if A_AhkPath {
        SetBatchLines % ("-1", Bch:=A_BatchLines)
        Critical
        DetectHiddenWindows On
        WinGet, NewPID, PID, <<ExecNew%flag%>> ahk_class AutoHotkeyGUI
        Process Close, %NewPID%
        add=`nflag=<<ExecNew%flag%>>`n
        (%
        #NoTrayIcon
        Gui Gui_ExecFlag_Gui%A_ScriptHwnd%: Show, Hide, %flag%
        DllCall("RegisterShellHookWindow", "Ptr", A_ScriptHwnd)
        , OnMessage(DllCall("RegisterWindowMessage", "Str", "ShellHook"), "_ShellEvent")
        _ShellEvent() {
            DetectHiddenWindows On
            IfWinNotExist <<ExecProcessParent>> ahk_class AutoHotkeyGUI, , ExitApp
         }
        )
        NewCode:=add "`n" NewCode "`nExitApp"
        , exec := ComObjCreate("WScript.Shell").Exec(A_AhkPath " /ErrorStdOut /f *")
        , exec.StdIn.Write(NewCode)
        , exec.StdIn.Close()
        Critical Off
        SetBatchLines %Bch%
        WinWait, <<ExecNew%flag%>> ahk_class AutoHotkeyGUI, , 3
        WinGet, RtnID, ID, <<ExecNew%flag%>> ahk_class AutoHotkeyGUI
        if RtnID
            Return True
    }
    Return False
}

; Read ahk script to create a new temporary process [Dependent on AHK interpreter]
; ProcessExecFile("NewScript.ahk") [The second parameter with number can not repeat the new temporary process]
ProcessExecFile(FilePath:="", flag:="Default") {
    SplitPath, FilePath,,,,, drive
    if drive=
        FilePath=%A_ScriptDir%\%FilePath%
    FileRead, FileReadVar, %FilePath%
    if (FileReadVar!="")
        Rtn := ProcessExec(FileReadVar, flag)
    Return (Rtn="" ? False : Rtn)
}
