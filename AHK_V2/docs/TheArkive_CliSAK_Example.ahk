; AHK v2
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode "Input"  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir A_ScriptDir  ; Ensures a consistent starting directory.

#INCLUDE TheArkive_CliSAK.ahk

Global oGui, c:="", CmdOutput, CmdPrompt, CmdInput, cli_session
Global done := "__Batch Complete__"


CmdGui()

CmdGui() {
    Global oGui
    oGui := Gui("+Resize","Console")
    oGui.OnEvent("Close",CmdClose)
    oGui.OnEvent("Size",CmdSize)
    oGui.SetFont("s8","Courier New")
    
    oGui.Add("button","","Ex #1").OnEvent("Click",Example1)
    oGui.Add("button","x+0","Ex #2").OnEvent("Click",Example2)
    oGui.Add("button","x+0","Ex #3").OnEvent("Click",Example3)
    oGui.Add("button","x+0","Ex #4").OnEvent("Click",Example4)
    oGui.Add("button","x+0","Ex #5").OnEvent("Click",Example5)
    oGui.Add("button","x+0","Ex #6").OnEvent("Click",Example6)
    oGui.Add("button","x+0","Ex #7").OnEvent("Click",Example7)
    oGui.Add("button","x+0","Ex #8").OnEvent("Click",Example8)
    
    oGui.Add("Button","x+20","Show Window").OnEvent("Click",ShowWindow)
    oGui.Add("Button","x+0","Hide Window").OnEvent("Click",HideWindow)
    oGui.Add("Button","x+0","Copy Selection").OnEvent("Click",copy)
    
    ctl := oGui.Add("Edit","vCmdOutput xm w800 h400 ReadOnly")
    ctl := oGui.Add("Text","vCmdPrompt w800 y+0","Prompt>")
    ctl := oGui.Add("Edit","vCmdInput w800 y+0 r3")
        
    oGui.Show()
    oGui["CmdInput"].Focus()
}


ShowWindow(oCtl,Info) {
    Global c
    WinShow "ahk_pid " c.pid
}

HideWindow(oCtl,Info) {
    Global c
    WinHide "ahk_pid " c.pid
}

copy(oCtl,info) {
    A_Clipboard := EditGetSelectedText(oCtl.gui["CmdOutput"].hwnd)
    Msgbox "Selected text copied."
}

CmdSize(o, MinMax, Width, Height) {
    h1 := Height - 10 - 103, w1 := Width - 20
    o["CmdOutput"].Move(,,w1,h1)
    
    y2 := Height - 75, w2 := Width - 20
    o["CmdPrompt"].Move(,y2,w2)
    
    y3 := Height - 55, w3 := Width - 20
    o["CmdInput"].Move(,y3,w3)
}

CmdClose(o) {
    Global c
    If (IsObject(c))
        c.close()
    ExitApp
}
; ============================================================================
; ============================================================================
; ============================================================================
Example1(oCtl,Info) { ; simple example
    Global oGui, c
    If (IsObject(c))
        c.close(), c:=""
    oGui["CmdOutput"].Value := ""
    
    output := CliData("dir") ; CliData() easy wrapper, no fuss, no muss
    
    AppendText(oGui["CmdOutput"].hwnd,output)
}
; ============================================================================
; ============================================================================
; ============================================================================
Example2(oCtl,Info) { ; simple example, short delay
    Global oGui, c
    If (IsObject(c))
        c.close(), c:=""
    oGui["CmdOutput"].Value := ""
    
    output := CliData("dir " Chr(34) A_WinDir "\System32" Chr(34))
    
    AppendText(oGui["CmdOutput"].hwnd,output)
    MsgBox "There was a delay because there was lots of data.`r`n`r`n"
         . "The GUI also stopped responding for a short time.  This is normal when using the wrapper function.`r`n`r`n"
         . "It is best to only use the CliData() wrapper function when the expected command duration is short."
}
; ============================================================================
; ============================================================================
; ============================================================================
Example3(oCtl,Info) { ; streaming example
    Global oGui, c
    If (IsObject(c))
        c.close(), c := ""
    oGui["CmdOutput"].Value := ""
    
    cmd := "dir C:\Windows\System32`r`n"
         . "ECHO. & ECHO This is similar to Example #2, except the output was streaming in realtime.`r`n"
         . "ECHO. & ECHO This session is just spitting out everything it sees from stdout.`r`n"
         . "ECHO. & ECHO This session is still active."
    
    c := cli(cmd,"ID:Console_Simple|StdoutCallback:stdout_cb","cmd")
}
; ============================================================================
; ============================================================================
; ============================================================================
Example4(oCtl,Info) { ; batch example, pass multi-line var for batch commands
    Global oGui, c
    If (IsObject(c))                ; To take full advantage of this example you will
        c.close(), c:=""            ; need access to an ssh server, and/or an ADB setup
    oGui["CmdOutput"].Value := ""   ; and an android phone.
    
    batch := "ECHO This is an interactive prompt using streaming mode, like Example #3.`r`n"
           . "ECHO. & ECHO But in this example, you can experiment with SSH (plink in particular) and ADB (Android Debug Bridge).`r`n"
    
    c := cli(batch,"ID:Console_Streaming|mode:f|StdoutCallback:stdout_cb") ; mode f = filter control codes from SSH and older ADB shell sessions.
}

; ============================================================================
; ============================================================================
; ============================================================================
Example5(oCtl,Info) { ; CTRL+C and CTRL+Break examples ; if you need to copy, disable CTRL+C (^c) hotkey below
    Global oGui, c
    If (IsObject(c))
        c.close(), c:=""
    oGui["CmdOutput"].Value := ""
    
    MsgBox "Use CTRL+B for CTRL+Break and CTRL+C during this batch to interrupt the running commands.`r`n`r`n"
         . "CTRL+Break and CTRL+C will do different things depending on each command."
    
    cmd := "ping 127.0.0.1`r`n"
         . "ping 127.0.0.1`r`n"
         . "ECHO. & ECHO The session is still active."
    c := cli(cmd,"ID:Console_Streaming|StdoutCallback:stdout_cb")
}
; ============================================================================
; ============================================================================
; ============================================================================
Example6(oCtl,Info) { ; stderr example
    Global oGui, c                          ; It is best to check .stderr in the PromptCallback()
    If (IsObject(c))                        ; function.  PromptCallback() fires after each command
        c.close(), c:=""                    ; completes, so it is easy to check errors in
    oGui["CmdOutput"].Value := ""           ; conjunction with the output of each command.
    
    c := cli("dir poof","mode:x|ID:error|StdoutCallback:stdout_cb|PromptCallback:prompt_cb")  ; Mode "x" separates StdErr from StdOut.
    
    ; This example uses the PromptCallback function.  See prompt_cb() below.
}
; ============================================================================
; ============================================================================
; ============================================================================
Example7(oCtl,Info) {
    Global oGui, c
    If (IsObject(c))
        c.close(), c:="" ; delete object and clear previous instance
    oGui["CmdOutput"].Value := ""
    
    cmd := "ECHO 'This is an interactive PowerShell console.'`r`n"
         . "ECHO ''`r`n"
         . "ECHO 'If you try to use the >> prompt to enter a multi-line statement then you need to end by sending a space as a separate command to get the prompt to return.'`r`n"
         . "ECHO ''`r`n"
         . "ECHO 'Try the following sequence:'`r`n"
         . "ECHO '-> 5+ {ENTER}'`r`n"
         . "ECHO '-> 5  {ENTER}'`r`n"
         . "ECHO '-> {SPACE} {ENTER}'`r`n"
         . "ECHO '   You should see the result 10 afterward.'"
    
    c := cli(cmd,"ID:PowerShell|StdoutCallback:stdout_cb|PromptCallback:prompt_cb","powershell")
    
    ; Mode "f" filters control codes, such as when logged into an SSH server hosted on a linux machine.
    ;          Use mode "f" with plink (from the pUTTY suite) in this example.
    ;              Putty: https://putty.org/
    ;          This example also works well with Android Debug Bridge (ADB - for android phones).
    ;              ADB SDK: https://developer.android.com/studio/#command-tools
    ;              Platform-Tools (extra small): https://developer.android.com/studio/releases/platform-tools
    
    oGui["CmdInput"].Focus()
}
; ============================================================================
; ============================================================================
; ============================================================================
Example8(oCtl,Info) { ; mode "m" example
    Global oGui, c
    If (IsObject(c))
        c.close(), c:="" ; close previous instance first.
    
    If !FileExist("wget.exe") {
        Msgbox "This example requires wget.  Please see the comments in example 8."
        return
    }
    
    ; ========================================================================================
    ; wget.exe example:
    ; ========================================================================================
    ; 1) download wget.exe from https://eternallybored.org/misc/wget/
    ; 2) unzip it in the same folder as this script
    ; ========================================================================================
    ; The file downloaded in this example is the Windows Android SDK (the medium version).
    ; Home Page:   https://developer.android.com/studio/releases/platform-tools
    ;
    ; In this wget.exe example, you can isolate the incrementing percent and incorporate the
    ; text animation as part of your GUI.
    ;
    ; You will want to use the StdOutCallback function to capture the animation in realtime,
    ; and then you will want to use the PromptCallback function to detect when the operation
    ; is complete.  Or use the QuitCallback/QuitString to detect the end of the operation.
    ; ========================================================================================
    
    cmd := "wget https://dl.google.com/android/repository/commandlinetools-win-6609375_latest.zip" ; big version
    ; cmd := "wget https://dl.google.com/android/repository/platform-tools-latest-windows.zip" ; small version
    
    ; ========================================================================================
    ; Using 1 row may have unwanted side effects.  The last printed line may overwrite the
    ; previous line. If the previous line is longer than the last line, then you may see
    ; the remenants of the previous line.  Use at least 2 rows.
    ; ========================================================================================
    
    ; cmd := "" ; uncomment this to try an interactive session with mode "m"
    c := cli(cmd,"mode:m(150,10)|ID:mode_M|StdoutCallback:stdout_cb|QuitCallback:quit_cb") ; console size = 150 columns / 10 rows
    
    ; For the size of the console, smaller is better.  Just make sure it is big enough to be able
    ; to capture what you want.  You may have to experiment with the console size a bit until you
    ; get the output displayed the way you want.
    ;
    ; Please be aware that this is for captureing animations only.  Mode "m" is NOT good for
    ; accurate and complete data collection.  Test your command to see if it already spits
    ; out the data you want to stdout.  If it does, then you would usually be better off not
    ; using mode "m", and just parsing stdout in the StdoutCallback function.
}

; ============================================================================
; Callback Functions
; ============================================================================
quit_cb(quitStr,ID,cliObj) { ; no example showing this for now...
    Global oGui
    If (ID = "ModeM")
        oGui["CmdOutput"].Value := "Download Complete"
    
    MsgBox "QuitString encountered:`r`n`t" quitStr "`r`n`r`nWhatever you choose to do in this callback functions will be done.`r`n`r`n"
         . "This could be used to terminate a batch before completion if desired."
}

stdout_cb(data,ID,cliObj) { ; Handle StdOut data as it streams (optional)
    Global oGui
    If (ID = "Console_Streaming" Or ID = "Console_Simple") {
        AppendText(oGui["CmdOutput"].hwnd, data)
    } Else If (ID = "mode_M") {                                 ; >>> mode "m" example capturing incrementing percent
        lastLine := cliObj.GetLastLine(data)
        b1 := InStr(lastLine,"["), b2 := InStr(lastLine,"]") ; brackets surrounding the progress bar
        
        lastLine_ := RegExReplace(Trim(lastLine),"[ ]{2,}"," ")
        a := StrSplit(lastLine_," ")
        
        file_disp := "", percent := "", prog_bar := "", rate := "", eta := "", trans := ""
        
        If (b1 and b2 and a.Length) { ; extracting elements of last line
            file_disp := a[1]
            percent := SubStr(lastLine,b1-4,4)
            prog_bar := SubStr(lastLine,b1+1,b2-b1-1)
            trans := (a[a.Length-1] = "eta") ? a[a.Length-3] : a[a.Length-1]
            rate := (a[a.Length-1] = "eta") ? a[a.Length-2] : a[a.Length]
            eta := (a[a.Length-1] = "eta") ? "eta " a[a.Length] : ""
        }
        
        oGui["CmdOutput"].Value := "File: " file_disp "`r`n`r`n"
                                 . "Percent Complete: " percent "`r`n`r`n"
                                 . "Progress Bar: [" prog_bar "]`r`n`r`n"
                                 . "Transfered: " trans "`r`n`r`n"
                                 . "Bandwidth: " rate "`r`n`r`n"
                                 . "ETA: " eta
    }
}

prompt_cb(prompt,ID,cliObj) { ; cliPrompt callback function --- default: PromptCallback()
    Global oGui
    oGui["CmdPrompt"].Text := prompt                            ; echo prompt to text control in GUI
    
    If (ID = "error" And cliObj.Ready) {
        stdOut := ">>> StdOut:`r`n" RTrim(cliObj.stdout,"`r`n`t") "`r`n`r`n"
        stdErr := ">>> StdErr:`r`n" RTrim(cliObj.stderr,"`r`n`t") "`r`n`r`n"
        oGui["CmdOutput"].Value := stdOut stdErr
    } Else If (ID = "PowerShell") {                             ; >>> more complex interactive console example
        err := cliObj.stderr
        out := cliObj.clean_lines(cliObj.stdout)
        out .= (InStr(prompt,">>")?"`r`n>>":"") ; append >> to output edit when that prompt is used
        AppendText(oGui["CmdOutput"].hwnd, "`r`n" (err?err:"") out)
        
    } Else If (ID = "mode_M")                                   ; >>> mode "m" example capturing incrementing percent
        oGui["CmdOutput"].Value := "Download complete."
}
; ============================================================================
; send command to CLI instance when user presses ENTER
; ============================================================================

OnMessage(0x0100,WM_KEYDOWN) ; WM_KEYDOWN
WM_KEYDOWN(wParam, lParam, msg, hwnd) { ; wParam = keycode in decimal | 13 = Enter | 32 = space
    Global oGui
    CtrlHwnd := "0x" Format("{:x}",hwnd) ; control hwnd formatted to match +HwndVarName
    If (CtrlHwnd = oGui["CmdInput"].hwnd And wParam = 13) ; ENTER in App List Filter
        SetTimer SendCmd, -10 ; this ensures cmd is sent and control is cleared
}

SendCmd() { ; timer label from WM_KEYDOWN    
    Global oGui, c
    CmdInput := oGui["CmdInput"].Value
    
    c.write(CmdInput)
    
    oGui["CmdInput"].Value := ""
    oGui["CmdInput"].Focus()
}

; ================================================================================
; ================================================================================
; support functions
; ================================================================================
; ================================================================================

dbg(_in) {
    Loop Parse _in, "`n", "`r"
        OutputDebug "AHK: " A_LoopField
}

; ================================================================================
; AppendText(hEdit, ptrText)
; example: AppendText(ctlHwnd, &varText)
; Posted by TheGood:
; https://autohotkey.com/board/topic/52441-append-text-to-an-edit-control/#entry328342
; ================================================================================
AppendText(hEdit, sInput, loc:="bottom") {
    txtLen := SendMessage(0x000E, 0, 0,, "ahk_id " hEdit)        ;WM_GETTEXTLENGTH
    If (loc = "bottom")
        SendMessage 0x00B1, txtLen, txtLen,, "ahk_id " hEdit    ;EM_SETSEL
    Else If (loc = "top")
        SendMessage 0x00B1, 0, 0,, "ahk_id " hEdit
    SendMessage 0x00C2, False, StrPtr(sInput),, "ahk_id " hEdit        ;EM_REPLACESEL
}

; ================================================================================
; hotkeys
; ================================================================================

#HotIf WinActive("ahk_id " oGui.hwnd)
^c::c.KeySequence("^c")
^CtrlBreak::c.KeySequence("^{CtrlBreak}")
^b::c.KeySequence("^{CtrlBreak}")   ; in case user doesn't have BREAK key
^x::{
    Global c
    c.close()                        ; closes active CLi instance if idle
}
^d::c.KeySequence("^d")
