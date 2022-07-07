; AHK v1 
; =================================================
; =================================================
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#INCLUDE %A_ScriptDir%
#INCLUDE TheArkive_CliSAK.ahk

Global c, CmdOutputHwnd, CmdPromptHwnd, CmdInputHwnd, CmdOutput, CmdPrompt, CmdInput
Global done := "__Batch Complete__"

CmdGui()

CmdGui() {
	Gui, Cmd:New, +LabelCmd +HwndCmdHwnd +Resize, Console
	Gui, Font, s8, Courier New
	Gui, Add, Button, gExample1, Ex #1
	Gui, Add, Button, gExample2 x+0, Ex #2
	Gui, Add, Button, gExample3 x+0, Ex #3
	Gui, Add, Button, gExample4 x+0, Ex #4
	Gui, Add, Button, gExample5 x+0, Ex #5
	Gui, Add, Button, gExample6 x+0, Ex #6
	Gui, Add, Button, gExample7 x+0, Ex #7
	Gui, Add, Button, gExample8 x+0, Ex #8
	
	Gui, Add, Button, gShowWindow x+20, Show Window
	Gui, Add, Button, gHideWindow x+0, Hide Window
	
	Gui, Add, Edit, vCmdOutput +HwndCmdOutputHwnd xm w800 h400 ReadOnly
	Gui, Add, Text, vCmdPrompt +HwndCmdPromptHwnd w800 y+0, Prompt>
	Gui, Add, Edit, vCmdInput +HwndCmdInputHwnd w800 y+0 r3
	Gui, Show
	
	GuiControl, Focus, CmdInput
}

ShowWindow() {
    ; InputBox, pid
    ; WinShow, % "ahk_pid " pid
	WinShow, % "ahk_pid " c.pid
}

HideWindow() {
	WinHide, % "ahk_pid " c.pid
}

CmdSize(GuiHwnd, EventInfo, Width, Height) {
	h1 := Height - 10 - 103, w1 := Width - 20
	GuiControl, Move, CmdOutput, h%h1% w%w1%
	y2 := Height - 75, w2 := Width - 20
	GuiControl, Move, CmdPrompt, y%y2% w%w2%
	y3 := Height - 55, w3 := Width - 20
	GuiControl, Move, CmdInput, y%y3% w%w3%
}

CmdClose() {
    c.CtrlBreak()
	c.close()
	ExitApp
}
; ============================================================================
; ============================================================================
; ============================================================================
Example1() { ; simple example
	If (IsObject(c))
		c.close(), c:=""
	GuiControl, , CmdOutput
    
    output := CliData("dir") ; CliData() easy wrapper, no fuss, no muss
    
	AppendText(CmdOutputHwnd,output)
}
; ============================================================================
; ============================================================================
; ============================================================================
Example2() { ; simple example, short delay
	If (IsObject(c))
		c.close(), c:=""
	GuiControl, , CmdOutput
	
    output := CliData("dir C:\Windows\System32") ; CliData() easy wrapper, no fuss, no muss
	AppendText(CmdOutputHwnd,output)
    MsgBox % "There was a delay because there was lots of data.`r`n`r`n"
         . "The GUI also stopped responding for a short time.  This is normal when using the wrapper function.`r`n`r`n"
         . "It is best to only use the CliData() wrapper function when the expected command duration is short."
}
; ============================================================================
; ============================================================================
; ============================================================================
Example3() { ; streaming example, with QuitString
	If (IsObject(c))
		c.close(), c:=""
	GuiControl, , CmdOutput
	
    cmd := "dir C:\Windows\System32`r`n"
         . "ECHO. & ECHO This is similar to Example #2, except the output was streaming in realtime.`r`n"
         . "ECHO. & ECHO This session is just spitting out everything it sees from stdout.`r`n"
         . "ECHO. & ECHO This session is still active."
    
    c := new cli(cmd,"ID:Console_Simple|StdoutCallback:stdout_cb","cmd")
}
; ============================================================================
; ============================================================================
; ============================================================================
Example4() { ; batch example, pass multi-line var for batch commands, and QuitString
	If (IsObject(c))
		c.close(), c:=""
	GuiControl, , CmdOutput
	
	batch := "ECHO This is an interactive prompt using streaming mode, like Example #3.`r`n"
           . "ECHO. & ECHO But in this example, you can experiment with SSH (plink in particular) and ADB (Android Debug Bridge).`r`n"
    
    c := new cli(batch,"ID:Console_Streaming|mode:f|StdoutCallback:stdout_cb") ; mode f = filter control codes from SSH and older ADB shell sessions.
}
; ============================================================================
; ============================================================================
; ============================================================================
Example5() { ; CTRL+C and CTRL+Break examples ; if you need to copy, disable CTRL+C hotkey below
	If (IsObject(c))
		c.close(), c:=""
	GuiControl, , CmdOutput
	
    MsgBox % "Use CTRL+B for CTRL+Break and CTRL+C during this batch to interrupt the running commands.`r`n`r`n"
         . "CTRL+Break and CTRL+C will do different things depending on each command."
    
    cmd := "ping 127.0.0.1`r`n"
         . "ping 127.0.0.1`r`n"
         . "ECHO. & ECHO The session is still active."
    c := new cli(cmd,"ID:Console_Streaming|StdoutCallback:stdout_cb")
}
; ============================================================================
; ============================================================================
; ============================================================================
Example6() { ; stderr example
	If (IsObject(c))
		c.close(), c:=""
	GuiControl, , CmdOutput
	
	c := new cli("dir poof","mode:x|ID:error|StdoutCallback:stdout_cb|PromptCallback:prompt_cb")  ; Mode "x" separates StdErr from StdOut.
    
    ; This example uses the PromptCallback function.  See prompt_cb() below.
}
; ============================================================================
; ============================================================================
; ============================================================================
Example7() { ; interactive session example
	If (IsObject(c))
		c.close(), c:="" ; delete object and clear previous instance
	GuiControl, , CmdOutput
	
    cmd := "ECHO 'This is an interactive PowerShell console.'`r`n"
         . "ECHO ''`r`n"
         . "ECHO 'If you try to use the >> prompt to enter a multi-line statement then you need to end by sending a space as a separate command to get the prompt to return.'`r`n"
         . "ECHO ''`r`n"
         . "ECHO 'Try the following sequence:'`r`n"
         . "ECHO '-> 5+ {ENTER}'`r`n"
         . "ECHO '-> 5  {ENTER}'`r`n"
         . "ECHO '-> {SPACE} {ENTER}'`r`n"
         . "ECHO '   You should see the result 10 afterward.'"
    
	c := new cli(cmd,"ID:PowerShell|StdoutCallback:stdout_cb|PromptCallback:prompt_cb","powershell")
    
	; Mode "f" filters control codes, such as when logged into an SSH server hosted on a linux machine.
    ;          Use mode "f" with plink (from the pUTTY suite) in this example if you can.
    ;              Putty: https://putty.org/
    ;          This example also works well with Android Debug Bridge (ADB - for android phones).
    ;              ADB SDK: https://developer.android.com/studio/#command-tools
    ;              Platform-Tools (extra small): https://developer.android.com/studio/releases/platform-tools
    
    Gui, Cmd:default
    GuiControl, Focus, CmdInput
}
; ============================================================================
; ============================================================================
; ============================================================================
Example8() { ; mode "m" example
	If (IsObject(c))
		c.close(), c:="" ; close previous instance first.
	
    If !FileExist("wget.exe") {
        Msgbox % "This example requires wget.  Please see the comments in example 8."
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
    c := new cli(cmd,"mode:m(150,10)|ID:mode_M|StdoutCallback:stdout_cb|QuitCallback:quit_cb") ; console size = 150 columns / 10 rows
    
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
quit_cb(quitStr,ID,cliObj) { ; stream until user-defined QuitString is encountered (optional).
    If (ID = "Mode_M")
        GuiControl, , %CmdOutputHwnd%, Download Complete.
    MsgBox % "QuitString encountered:`r`n`t" quitStr "`r`n`r`nWhatever you choose to do in this callback functions will be done."
}

stdout_cb(data,ID,cliObj) { ; Handle StdOut data as it streams (optional)
    dbg("    data: " data)
    
	If (ID = "Console_Streaming" Or ID = "Console_Simple") 
		AppendText(CmdOutputHwnd,data) ; append data to edit box
	Else If (ID = "mode_M") {
        dbg("mode_M")
        
        lastLine := cliObj.GetLastLine(data) ; capture last line containing progress bar and percent.
        a := StrSplit(lastLine,"["), p1 := a[1], a := StrSplit(p1," "), p2 := a[a.Length()]
        msg := "========================================================`r`n"
             . "This is the captured console grid.`r`n"
             . "========================================================`r`n"
             . data "`r`n`r`n"
             . "========================================================`r`n"
             . "wget.exe example:  (Check Ex #8 comments)`r`n"
             . "========================================================`r`n"
             . "Percent Complete: " p2
        
		GuiControl, , %CmdOutputHwnd%, %msg% ; write / overwrite data to edit box
    }
}

prompt_cb(prompt,ID,cliObj) { ; cliPrompt callback function --- default: cliPromptCallback()
	Gui, Cmd:Default ; need to set GUI as default if NOT using control HWND...
	GuiControl, , CmdPrompt, ========> new prompt =======> %prompt% ; set Text control to custom prompt
    
    If (ID = "error") {
        stdOut := ">>> StdOut:`r`n" RTrim(cliObj.stdout,"`r`n`t") "`r`n`r`n"
        stdErr := ">>> StdErr:`r`n" RTrim(cliObj.stderr,"`r`n`t") "`r`n`r`n"
        GuiControl, , %CmdOutputHwnd%, % stdOut stdErr ; write / overwrite data to edit box
        cliobj.stdOut := "", cliobj.stdErr := ""
    } Else If (ID = "PowerShell") {
        err := cliObj.stderr
        out := cliObj.clean_lines(cliObj.stdout)
        out .= (InStr(prompt,">>")?"`r`n>>":"") ; append >> to output edit when that prompt is used
        AppendText(CmdOutputHwnd, "`r`n" (err?err:"") out)
    }
}
; ============================================================================
; send command to CLI instance when user presses ENTER
; ============================================================================

OnMessage(0x0100,"WM_KEYDOWN") ; WM_KEYDOWN
WM_KEYDOWN(wParam, lParam, msg, hwnd) { ; wParam = keycode in decimal | 13 = Enter | 32 = space
    CtrlHwnd := "0x" Format("{:x}",hwnd) ; control hwnd formatted to match +HwndVarName
    If (CtrlHwnd = CmdInputHwnd And wParam = 13) ; ENTER in App List Filter
		SetTimer, SendCmd, -10 ; this ensures cmd is sent and control is cleared
}

SendCmd() { ; timer label from WM_KEYDOWN
	Gui, Cmd:Default ; give GUI the focus / required by timer(s) unless using hwnd in GuiControlGet / GuiControl commands
	GuiControlGet, CmdInput ; get cmd
	c.write(CmdInput) ; send cmd
	Gui, Cmd:Default
	GuiControl, , CmdInput ; clear control
	GuiControl, Focus, CmdInput ; put focus on control again
}

; ================================================================================
; ================================================================================
; support functions
; ================================================================================
; ================================================================================

AppendText(hEdit, sInput, loc="bottom") {
    ; ================================================================================
    ; AppendText(hEdit, ptrText)
    ; example: AppendText(ctlHwnd, &varText)
    ; Posted by TheGood:
    ; https://autohotkey.com/board/topic/52441-append-text-to-an-edit-control/#entry328342
    ; ================================================================================
    SendMessage, 0x000E, 0, 0,, ahk_id %hEdit%						;WM_GETTEXTLENGTH
	If (loc = "bottom")
		SendMessage, 0x00B1, ErrorLevel, ErrorLevel,, ahk_id %hEdit%	;EM_SETSEL
	Else If (loc = "top")
		SendMessage, 0x00B1, 0, 0,, ahk_id %hEdit%
    SendMessage, 0x00C2, False, &sInput,, ahk_id %hEdit%			;EM_REPLACESEL
}

dbg(_in) {
    Loop, Parse, % _in, `n, `r
        OutputDebug, AHK: %A_LoopField%
}

; ================================================================================
; hotkeys
; ================================================================================



#IfWinActive, ahk_class AutoHotkeyGUI
^c::c.KeySequence("^c")
^CtrlBreak::c.KeySequence("^{CtrlBreak}")
^b::c.KeySequence("^{CtrlBreak}")			; in case user doesn't have BREAK key
^x::c.close()				; closes active CLi instance if idle
^d::c.KeySequence("^d")
