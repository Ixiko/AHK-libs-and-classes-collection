; ================================================================
; === cli class, easy one-time and streaming output that collects stdOut and stdErr, and allows writing to stdIn.
; === huge thanks to:
; ===    user: segalion ; https://autohotkey.com/board/topic/82732-class-command-line-interface/#entry526882
; === ... who posted his version of this on 20 July 2012 - 08:43 AM.
; === his code was so clean even I could understand it, and I'm new to classes!
; === another huge thanks to:
; ===    user(s): Sweeet, sean, and maraksan_user ; https://autohotkey.com/board/topic/15455-stdouttovar/page-7#entry486617
; === ... for thier work with StdoutToVar() which inspired me, and thanks to SKAN, HotKeyIt, Sean, maz_1 for
; === StdOutStream() ; https://autohotkey.com/board/topic/96903-simplified-versions-of-seans-stdouttovar/page-2
; === ... which was another very important part of the road map to making this function work.
; === And thanks go "just me" who taught me how to understand structures, pointers, and alignment
; === of elements in a structure on a level where I can finally do this kind of code.
; === Finally, thanks to Lexikos for all the advice he gave to the above users that allowed the creation of these
; === amazing milestones.
; ===
; === Also, thanks to TheGood for coming up with a super easy and elegant way of appending large amounts of text in an
; === edit control, which pertains directly to how some code like this would be used with a GUI.
; ===
; === Thanks to @joedf for LibCon.  That library helped me understand how to read console output and was integral
; === to me being able to create mode "m" to capture console animations.
; ===
; === Thanks to Lexikos for his old ConsoleSend() function.  https://autohotkey.com/board/topic/25446-consolesend/
; === This function provided one of the final bits of functionality I needed to finalize this library.
; ===
; === This class basically combines StdoutToVar() and StdOutStream() into one package, and has several other features for a 
; === very dynamic CLI management.  I am NOT throwing shade at StdoutToVar(), StdOutStream(), or the people who created
; === them.  Those functions were amazing milestones.  Without those functions, this version, and other implementations like
; === LibCon would likely not have been possible.

; ========================================================================================================
; CliData(inCommand)
; ========================================================================================================
;
;   Usage:   var := CliData("your_command here")
;
;       Using this library, this function is the easiest way to "just run a command and collect the data".
;
; ========================================================================================================
;   new cli(sCmd:="", options:="", env:="cmd", params:="/Q")
; ========================================================================================================
;   Parameters:
;
;       sCmd        (required)
;
;           Single-line command or multi-line batch command.  Different modes will provide different
;           functionality.  See "Options" below.
;
;       options    (optional)
;           Zero or more of the options below, separated by a pipe (|):
;
;       env
;           Specify the environment.  The default environment is "cmd".  Other possibilities include:
;           > "powershell"
;           > "ansicon" --> Use your own CLi shell, like ANSICON.
;
;           This can be any EXE that loads a command line environment that allows redirecting StdIn,
;           StdOut, and/or StdErr.  The PATH environment var will be checked to find the full path to the
;           EXE.  If the environment you want to use is not in PATH, then specify the full path in this
;           parameter.
;
;       params
;           The default param is /Q to set ECHO OFF.  This prevents your commands from displaying in the
;           CLI session.  However, CliObj.lastCmd contains your last command so you can reconstruct a
;           normal-looking CLI session if you desire.
;
;           Other Examples:
;           > "/K" -- for env:="cmd", this will omit the shell version text when the CLi session starts,
;             thus only displaying the prompt.
;
;           Check the help docs for your CLI shell to know what the options are and how to use them.
; ========================================================================================================
; Options
; ========================================================================================================
;
;   ID:MyID
;       User defined string to identify CLI sessions.  This is used to identify a CLI instance in
;       callback functions.  If you manage multiple CLI sessions simultaneously you may want to use this
;       option to tell which session is which within your callback functions.
;
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
;   Modes define how the CLI instance is launched and handled.
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
;       This library now operates in only streaming mode.  Use CliData() wrapper function for single
;       command output.
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
;       IMPORTANT NOTES ABOUT THIS LIBRARY:
;           Except when using the CliData() wrapper function, the user MUST call obj.Close() to
;           terminate the CLI session and open handles after properly exiting the programs called during
;           the CLI session.  "Properly exiting the program" means the CLI session is still active, but
;           idle.  If you don't properly exit the program you may see the following processes remaining
;           in Task Manager:
;                1) cmd.exe
;                2) the program you ran on the command line
;                3) conhost.exe (you will see more than usual - I usually see 3 of these on my system)
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
;   mode:[modes]  -  Primary Modes
;
;       The default mode is streaming (previously mode "s"), which generally means constant data
;       collection from StdOut.  There is no need to specify mode "s" as this is now the default mode.
;
;       mode "m" (Monitoring mode) This allows the user to record text as actually seen on a typical
;           console.  Best if used with the StdOutCallback() and PromptCallback() functions.  Useful
;           for capturing animations like incrementing percent, or a progress bar... ie. [90%]{======> }
;
;           A typical console buffer consists of approx 80-120 COLS (columns) and several thousand rows.
;           So mode "m" comes with the ability to resize the console buffer to use considerably less CPU
;           when reading the console buffer.  Currently only CMD has been tested with this, but
;           development is planned for PowerShell.
;
;               Usage: m(width, height)
;               - width : number of columns (of characters)
;               - height: number of rows of text
;
;               Note: A smaller area captured performs better than capturing a larger area.  Be sure
;               to use at least 2 rows.  A single row will usually be generally unusable.  If you do not
;               specify height/width when using mode "m", then 100 COLS and 10 LINES are used.
;
;           The size of the console buffer is important to take into account.  The buffer size can affect
;           the display of the output you are trying to capture.  If you notice "graphical anomalies"
;           then try a wider buffer size.
;
;           You can call mode "x" with mode "m", but there are a few instances when this is not beneficial.
;           Some commands may hang if StdErr is not piped to the console buffer.  In general, if you have
;           seemingly random or unexplained issues using mode "x" with mode "m", stop using mode "x" and
;           see if the issues continue.
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
;    mode:[modes]  -  Secondary Modes
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
;       *** Append these modes as needed to further modify/refine CLI behavior ***
;
;       mode "c" = Delay sCmd execution.  Execute with obj.RunCmd()  Optionally set more options before
;            execution by specifying:    CLIobj.option := value
;
;       mode "x" = Extract StdErr in a separate pipe for each command.  The full StdErr stream for the
;           session is still stored in CLIobj.stderr.  This is best used with PromptCallback(). Generally,
;           you should clear .stdout and .stderr after processing in PromptCallback() to keep the
;           correlation between the command, stdout, and stderr clear.
;
;       mode "r" = Prune mode, remove prompt from StdOut data.  This only functions as expected when the
;           prompt is the final line of output.  So, in mode "m", the final prompt will be omitted, but
;           pervious prompts will be displayed.
;
;       mode "f" = Filter control codes.  This mostly pertains to Linux environments such as SSH or ADB.
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
;    More Options
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
;   workingDir:c:\myDir
;       Set working directory.  Defaults to A_ScriptDir.  Commands that generate files will put those
;       files here, unless otherwise specified in the command parameters.
;
;   codepage:CP###
;       Codepage (UTF-8 = CP65001 / Windows Console = CP437 / etc...)
;
;   StdOutCallback:Give_It_A_Name
;       Defines the stdOutCallback function name.  If the callback exists, it will fire on this event.
;       > Default callback: StdOutCallback(data,ID,CLIobj)
;
;   PromptCallback:Give_It_A_Name
;       Defines the PromptCallback function.  If the callback exists, it will fire on this event.
;       > Default callback: PromptCallback(prompt,ID,CLIobj)
;
;   QuitCallback:Give_It_A_Name
;       Defines the QuitCallback function.  If the callback exists, it will fire on this event.
;       > Default callback: QuitCallback(quitString,ID,CLIobj)
;       > The QuitString option must be set in order to use the QuitCallback.
;
;   QuitString:Your_Quit_Msg_Here
;       If you define this option, and if the QuitCallback function exists, then the specified string
;       will be searched while the output is streaming.  If this string is found at the end of a StdOut
;       packet (usually right before a prompt event as a command finishes) then data collection will
;       halt and the QuitCallback will be triggered, then the process will be terminated.  Usually you
;       will have your QuitString defined as the last line of your batch, ie. "ECHO My Quit String", or
;       your QuitString will be a known message output by one of your programs run within the CLI session.
;
;   showWindow:#
;       Specify 0 or 1.  Default = 0 to hide.  1 will show.
;       Normally the CLI window will always be blank, except in mode "m".  The CLI window exists so that
;       control signals (CTRL+C / CTRL+Break / etc.) can be sent to the window.  See the Methods section
;       below.  Ultimately this is only provided as a convenience but isn't all that useful.
;
;   waitTimeout:###   (ms)
;       The waitTimeout is an internal correction.  There is a slight pause after sCmd execution before
;       the buffer is filled with data.  This class will check the buffer every 10 ms (up to a max
;       specified by waitTimeout, default: 300 ms).  Usually, it doesn't take that long for the buffer to
;       have data after executing a command.  If your command takes longer than 300ms to return data, then
;       you may need to increase this value for proper functionality.
;
;   width:#
;       Sets the number of columns for the console to use.  Only works with mode "m".
;
;   height:#
;       Sets the number of rows for the console to use.  Only works with mode "m".
;
;   NOTE: Height and Width can also be set with mode "m" --> "mode:m(h,w)".  See above.
;
; ========================================================================================================
; CLI class Methods and properties (also CLIobj parameter for callback functions).
; ========================================================================================================
;   Methods:
; ========================================================================================================
;
;   CLIobj.runCmd()
;       Runs the command specified in sCmd parameter.  This is meant to be used with mode "c" when
;       delayed execution is desired.
;
;   CLIobj.close()
;       Closes all open handles and tries to end the session.  Ending sessions like this usually only
;       succeeds when the CLI prompt is idle.  If you need to force termination then send a CTRL+C or
;       CTRL+Break signal first.  Read more below.
;
;   CLIobj.KeySequence("string")
;       Sends a key sequence, ie. CTRL+Key.  DO NOT use this like the .write() method because this method
;       is not accurate.  Only use this to send control signals like CTRL+C / CTRL+Break.
;
;   CLIobj.GetLastLine(str)
;       Returns last line of "str".  This is useful in callback functions.
;
; ========================================================================================================
;    Properties (useful with CLIobj in callback functions):
; ========================================================================================================
;
;   CLIobj.[option]
;       All options above are also properties that can be checked or set.
;
;   CLIobj.cmdHistory
;       This is a text list (delimited by `r`n) of commands executed so far during your CLI session. The
;       last command in the list is the same as the lastCmd property.
;
;   CLIobj.hProc, CLIobj.hThread
;       Get the handle to the process/thread of the CLI session.
;
;   CLIobj.lastCmd
;       This is the last command that was run during your CLI session.  When using the PromptCallback(),
;       the .stdout and .stderr properties contain output data as a result of the last command run.
;
;   CLIobj.pID, CLIobj.tID
;       Get the process/thread ID of the CLI session.
;
;   Cliobj.ready
;       This is set to FALSE until after the first prompt event has happened, then it is set to TRUE.
;       This is most useful for filtering out the first prmopt event when using the prompt callback
;       function.
;
;   Cliobj.batchProgress
;       Contains the iteration count of completed commands.
;
;   Cliobj.batchCommands
;       Contains the total number of commands (lines) passed into the .write() method.
;
;   CLIobj.stderr
;       This is the full output of StdErr during the session.  You can check or clear this value.
;
;   CLIobj.stdout
;       This is the full output of StdOut during the session.  You can check or clear this value.
;
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
; The following options are included as a convenience for power users.  Use with caution.
; Most CLI functionality can be handled without using the below methods / properties directly.
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
;
;   CLIobj.write(sInput)
;       Write to StdIn and send commands.  CRLF (`r`n) is appended automatically.  This method will
;       automatically use the appropriate command whether in normal streaming mode, or mode "m".
;
;   CLIobj.fStdOut - file object (stream) - contains all methods and properties of an AHK File Object.
;       Note this member is NOT a file object when using mode "m" (it is only a handle).
;
;   CLIobj.fStdErr - same as CLIobj.fStdOut, but for StdErr (only when using mode "x").
;
; ========================================================================================================
; KNOWN ISSUES
; ========================================================================================================
;   * When typing an incomplete command in PowerShell (ie.  >> echo "test  <<) you will get a ">>" prompt
;     with the option to complete the command.  In a normal PowerShell window, you can complete the above
;     command by typing double quotes (") and get back to the prompt.
;
;       It should also be possible to press CTRL+C to abort the incomplete command.  This is also not
;     happening when trying to use CliObj.KeySequence("^c").
;
;     Both of these issues currently apply to PowerShell, or PowerShell through CMD (ie. "cmd /K
;     powershell").  I'm still trying to figure out what causes this.  Other than these issues, Powershell
;     still appears to function properly when commands don't spawn a ">>" prompt.
; ========================================================================================================

CliData(inCommand:="") {
    If (!inCommand)
        return ""
    Else {
        cli_session := cli.New(inCommand,"mode:r","cmd","/Q /K")  ; run command, prune prompt
        result := ""
        
        While !cli_session.batchProgress
            Sleep cli_session.delay
        
        result := cli_session.stdout                ; get the data
        cli_session.close(), cli_session := ""      ; clean up
        return Trim(result,"`r`n`t")                ; return result
    }
}

class cli {
    Static CtlKeyState := {CAPSLOCK:0x80, ENHANCED_KEY:0x100, LALT:0x2, LCTRL:0x8, NUMLOCK:0x20, RALT:0x1, RCTRL:0x4, SCROLLLOCK:0x40, SHIFT:0x10}
    
    StdOutCallback:="stdOutCallback", PromptCallback:="PromptCallback", QuitCallback:="QuitCallback", QuitString:=""
    delay:=10, waitTimeout:=300, showWindow:=0, codepage:="CP0", workingDir:=A_WorkingDir, shell:="windows", ready:=false, run:=false
    ID:="", mode:="", hStdIn:=0, hStdOut:=0, hStdErr:=0, stdout:="", stdoutRaw:="", stderr:="", cmdHistory:="", conWidth:=100, conHeight:=10
    lastCmd:="", cmdCmd:="", cmdSwitches:="", cmdProg:="", useAltShell := "", reason:="", command:=""
    batchCmdLines:=0, batchProgress:=0, batchCmd:="", terminateBatch := false
    fStdErr:={AtEOF:1, Handle:0}, fStdOut:={AtEOF:1, Handle:0}
    
    __New(sCmd, options:="", env:="cmd", params:="/Q") {
        this.env := (!FileExist(env)) ? this.check_exe(env) : env
        this.params := params
        
        this.batchCmdLines := this.shellCmdLines(sCmd,firstCmd,batchCmd)        ; ByRef firstCmd / ByRef batchCmd ; isolate 1st line command
        this.sCmd := sCmd, q := Chr(34), optGrp := StrSplit(options,"|")        ; next load specified properties (options param)
        For i, curItem in optGrp
            optItem := StrSplit(curItem,":"), this.%optItem[1]% := optItem[2]   ; write options to "this"
        
        this.batchCmd := sCmd
        this.stream := ObjBindMethod(this,"sGet") ; register function Obj for timer (stream)
        
        If (!InStr(this.mode,"c"))
            this.runCmd()
    }
    check_exe(sInput) {
        sInput := (!RegExMatch(sInput,"\.exe$")) ? sInput ".exe" : sInput
        path := EnvGet("PATH")
        Loop Parse path, ";"
            If FileExist(A_LoopField "\" sInput)
                return RegExReplace(A_LoopFIeld "\" sInput,"[\\]{2,}","\")
        return ""
    }
    __Delete() {
        this.close() ; close all handles / objects
    }
    runCmd() {
        p := A_PtrSize, this.run := true, this.m := !!InStr(this.mode,"m")
        
        If (InStr(this.mode,"(") And InStr(this.mode,")") And this.m) { ; mode "m" !!
            s1 := InStr(this.mode,"("), e1 := InStr(this.mode,")"), mParam := SubStr(this.mode,s1+1,e1-s1-1), dParam := StrSplit(mParam,",")
            conWidth := dParam[1], conHeight := dParam[2], this.conWidth := conWidth, this.conHeight := conHeight
        }
        
        If (this.m) {
            params_addon := " /K MODE CON: COLS=" this.conWidth " LINES=" this.conHeight
            (this.params) ? this.params .= params_addon : this.params := Trim(params_addon)
        }
        ; implement this for PowerShell
        ; powershell -noexit -command "[console]::WindowWidth=100; [console]::WindowHeight=50; [console]::BufferWidth=[console]::WindowWidth"
        
        hStdInRd := 0, hStdInWr := 0, hStdOutRd := 0, hStdOutWr := 0, hStdErrRd := 0, hStdErrWr := 0 ; init handles
        
        r1 := DllCall("CreatePipe","Ptr*",hStdInRd,"Ptr*",hStdInWr,"Uint",0,"Uint",0) ; get handle - stdIn (R/W)
        r2 := DllCall("SetHandleInformation","Ptr",hStdInRd,"Uint",1,"Uint",1)            ; set flags inherit - stdIn
        this.hStdIn := hStdInWr, this.hStdOut := 0
        
        If (!this.m) {
            r1 := DllCall("CreatePipe","Ptr*",hStdOutRd,"Ptr*",hStdOutWr,"Uint",0,"Uint",0) ; get handle - stdOut (R/W)
            r2 := DllCall("SetHandleInformation","Ptr",hStdOutWr,"Uint",1,"Uint",1)            ; set flags inherit - stdOut ;ZZZ
            this.hStdOut := hStdOutRd
        }
        
        If (InStr(this.mode,"x")) {
            r1 := DllCall("CreatePipe","Ptr*",hStdErrRd,"Ptr*",hStdErrWr,"Uint",0,"Uint",0) ; stdErr pipe on mode "x"
            r2 := DllCall("SetHandleInformation","Ptr",hStdErrWr,"Uint",1,"Uint",1)
        }
        this.hStdErr := InStr(this.mode,"x") ? hStdErrRd : hStdOutRd
        
        pi := BufferAlloc((p=4)?16:24, 0)                               ; PROCESS_INFORMATION structure
        si := BufferAlloc(siSize:=(p=4)?68:104,0)                       ; STARTUPINFO Structure
        NumPut("UInt", siSize, si, 0)                                   ; cb > structure size
        NumPut("UInt", 0x100|0x1, si, (p=4)?44:60)                      ; STARTF_USESTDHANDLES (0x100) | STARTF_USESHOWWINDOW (0x1)
        NumPut("UShort", this.showWindow ? 0x1 : 0x0, si, (p=4)?48:64)  ; wShowWindow / 0x1 = show
        
        NumPut("Ptr", hStdInRd , si, (p=4)?56:80)                       ; stdIn handle
        (!this.m) ? NumPut("Ptr", hStdOutWr, si, (p=4)?60:88) : ""      ; stdOut handle
        NumPut("Ptr", InStr(this.mode,"x") ? hStdErrWr : hStdOutWr, si, (p=4)?64:96)    ; stdErr handle (only on mode "x", otherwise use stdout handle)
        
        s := "i)^((.*)?adb(.exe)?([ ].*)?[ ]shell)$"
        If (r := RegExMatch(this.env,s))
            this.shell := "android"
        
        r := DllCall("CreateProcess"
            , "Str", this.env, "Str", this.params
            , "Uint", 0, "Uint", 0          ; process/thread attributes
            , "Int", true                   ; always inherit handles to keep StdIn secure
            , "Uint", 0x10                  ; 0x10 (CREATE_NEW_CONSOLE), 0x200 (CREATE_NEW_PROCESS_GROUP)
            , "Uint", 0                     ; environment
            , "Str", this.workingDir        ; working Directory pointer
            , "Ptr", si.ptr                 ; startup info structure - contains stdIn/Out handles
            , "Ptr", pi.ptr)                ; process info sttructure - contains proc/thread handles/IDs
        
        if (r) {
            this.pID := NumGet(pi, p * 2, "UInt"), this.tID := NumGet(pi, p * 2+4, "UInt")    ; get Process ID and Thread ID
            this.hProc := NumGet(pi,0,"UPtr"), this.hThread := NumGet(pi,p,"UPtr")            ; get Process handle and Thread handle
            
            while (result := !DllCall("AttachConsole", "UInt", this.pID) And ProcessExist(this.pID))    ; retry attach console until success
                Sleep 10                                                                               ; if PID exists - cmd may have returned already
            
            r1 := DllCall("CloseHandle","Ptr",hStdInRd) ; handles not needed, inherited by the process
            If (!this.m) {
                r2 := DllCall("CloseHandle","Ptr",hStdOutWr)
                this.fStdOut := FileOpen(this.hStdOut, "h", this.codepage)  ; open StdOut stream object
            } Else
                hStdOut := DllCall("GetStdHandle", "Int", -11, "ptr"), this.hStdOut := hStdOut
            
            If (InStr(this.mode,"x")) {
                DllCall("CloseHandle","Ptr",hStdErrWr)
                this.fStdErr := FileOpen(this.hStdErr, "h", this.codepage)
            }
            
            If (this.shell = "android" And !this.m) ; specific CLI shell fixes
                this.uWrite(this.checkShell())
            
            stream := this.stream, delay := this.delay, this.wait() ; wait for buffer to have data, default = 300 ms
            
            SetTimer stream, delay         ; data collection timer / default loop delay = 10 ms
        } Else {
            this.pid := 0, this.tid := 0, this.hProc := 0, this.hThread := 0
            this.stdout .= (this.stdout) ? "`r`nINVALID COMMAND" : "INVALID COMMAND"
            this.close()
            MsgBox "Last Error: " A_LastError
        }
    }
    close() { ; closes handles and may/may not kill process instance
        stream := this.stream
        SetTimer stream, 0                  ; disable streaming timer
        
        (ProcessClose(this.pID)) ? this.write("exit") : "" ; send "exit" if process still exists
        
        If (!this.m And this.fStdOut.Handle)
            this.fStdOut.Close()            ; close fileObj stdout handle
        
        DllCall("CloseHandle","Ptr",this.hStdIn), DllCall("CloseHandle","Ptr",this.hStdOut)     ; close stdIn/stdOut handle
        DllCall("CloseHandle","Ptr",this.hProc),  DllCall("CloseHandle","Ptr",this.hThread)     ; close process/thread handle
        
        If (InStr(this.mode,"x") And this.fStdErr.Handle)
            this.fStdErr.Close(), DllCall("CloseHandle","Ptr",this.hStdErr)     ; close stdErr handles
        
        DllCall("FreeConsole")                  ; detach console from script
        (this.m) ? ProcessClose(this.pID) : ""  ; close process if mode "m"
    }
    wait() {
        mode := this.mode, delay := this.delay, waitTimeout := this.waitTimeout, ticks := A_TickCount
        Loop {          ; wait for Stdout buffer to have content
            Sleep delay ; default delay = 10 ms
            SoEof := this.fStdOut.AtEOF, SeEof := this.fStdErr.AtEOF, exist := ProcessExist(this.pID), timer := A_TickCount - ticks
            If (!SoEof Or !exist) Or (InStr(mode,"x") And !SeEof) Or (timer >= waitTimeout)
                Break
        }
    }
    mGet() { ; capture console grid output (from console buffer - not StdOut stream from the process)
        Static enc := StrLen(Chr(0xFFFF)) ? "UTF-16" : "UTF-8"
        otherStr := "", curPos := 1
        If (exist := ProcessExist(this.pID)) {
            lpCharacter := BufferAlloc(this.conWidth * this.conHeight * 2,0)  ; console buffer size to collect
            dwBufferCoord := BufferAlloc(4,0)                                 ; top-left start point for collection
            
            result := DllCall("ReadConsoleOutputCharacter"
                             ,"UInt",this.hStdOut   ; console buffer handle
                             ,"Ptr",lpCharacter.ptr ; str buffer
                             ,"UInt",this.conWidth * this.conHeight ; define console dimensions
                             ,"uint",NumGet(dwBufferCoord,"UInt") ; start point >> 0,0
                             ,"UInt*",lpNumberOfCharsRead:=0,"Int")
            chunk := StrGet(lpCharacter,enc)
            
            While (curLine := SubStr(chunk,curPos,this.conWidth))
                otherStr .= RTrim(curLine) "`r`n", curPos += this.conWidth
        }
        
        return Trim(otherStr,"`r`n")
    }
    sGet() { ; stream-Get (timer) - collects until process exits AND buffer is empty
        batchCmd := Trim(this.batchCmd," `r`n`t"), prompt := "", stream := this.stream
        SOcb := this.StdOutCallback, QuitCallback := this.QuitCallback
        
        buffer := (!this.m) ? this.fStdOut.read() : this.mGet() ; check StdOut buffer
        this.getStdErr()                                        ; check StdErr buffer
        
        fullEOF := (!this.m) ? this.fStdOut.AtEOF : 1 ; check EOF, in mode "m" this is always 1 (because StdOut is grid, not a stream)
        if (InStr(this.mode,"x"))
            (this.fStdOut.AtEOF And this.fStdErr.AtEOF) ? fullEOF := true : fullEOF := false
        
        If (buffer) {
            If (!this.m) Or (this.m And this.stdoutRaw != buffer) { ; normal collection - when there's a buffer
                this.stdoutRaw := buffer, buffer := this.clean_lines(buffer)                                ; RTrim() spaces from buffer with .clean_lines()
                InStr(this.mode,"f") ? (buffer := this.filterCtlCodes(buffer)) : ""                         ; remove control codes (SSH, older ADB)
                prompt := this.getPrompt(buffer,true), buffer := this.removePrompt(buffer,prompt)           ; isolate prompt from buffer
                buffer := RegExReplace(buffer,"^\Q" this.lastCmd "\E","")
                
                If (this.QuitString And RegExMatch(Trim(buffer,"`r`n`t"),"\Q" this.QuitString "\E$") And IsFunc(QuitCallback)) {
                    %QuitCallback%(this.QuitString,this.ID,this) ; check for QuitString before prompt is added
                    this.close()
                    return
                }
                
                (!this.m) ? this.stdout .= "`r`n" buffer : this.stdout := buffer ; write/append buffer to .stdout
                
                (IsFunc(SOcb)) ? %SOcb%(buffer,this.ID,this) : ""  ; trigger StdOut callback
                (prompt) ? this.promptEvent(prompt) : ""           ; trigger prompt casllback
            } 
        }
        
        If (!ProcessExist(this.pID) And fullEOF) {  ; if process exits AND buffer is empty
            this.batchProgress += 1
            SetTimer stream, 0                      ; stop data collection timer
        }
    }
    clean_lines(sInput) {
        result := ""
        Loop Parse sInput, "`n", "`r"
            result .= RTrim(A_LoopField,"`t ") "`r`n"
        return RTrim(result,"`r`n`t")
    }
    getStdErr() {
        If (InStr(this.mode,"x") And !this.m) { ; StdErr in separate stream
            stdErr := RTrim(Trim(this.fStdErr.read(),"`r`n"))
            If (stdErr != "")
                (this.stdErr="") ? this.stderr := stderr : this.stderr .= "`r`n" stderr
        }
    }
    promptEvent(prompt) {
        PromptCallback := this.PromptCallback
        (this.ready) ? this.batchProgress += 1 : "" ; increment batchProgress / when this is 1, the first command has been completed.
        this.stdout := Trim(this.stdout,"`r`n")
        (IsFunc(PromptCallback)) ? %PromptCallback%(prompt,this.ID,this) : ""   ; trigger callback function
        
        (!this.ready) ? (this.ready := true) : ""           ; set ready after first prompt
        (this.batchCmd) ? this.write(this.batchCmd) : ""    ; write next command in batch, if any
    }
    write(sInput:="") {
        If !this.run {
            Msgbox "The command has not been run yet.  You must call:`r`n`r`n     cliObj.runCmd()"
            return
        }
        
        sInput := Trim(sInput,OmitChars:="`r`n")
        If (sInput = "") Or this.terminateBatch {
            this.lastCmd := "", this.batchCmd := "", this.terminateBatch := false, this.batchProgress := 0, this.batchCmdLines := 0
            Return
        }
        
        delay := this.delay
        While !this.ready
            Sleep this.delay ; Ensure commands are not sent until initial prompt is complete, indicating CLI session is ready.
        
        cmdLines := this.shellCmdLines(sInput,firstCmd,batchCmd) ; ByRef firstCmd / ByRef batchCmd
        this.lastCmd := firstCmd, this.batchCmd := batchCmd, this.cmdHistory .= firstCmd "`r`n" ; this.firstCmd := firstCmd
        
        androidRegEx := "i)^((.*[ ])?adb (-a |-d |-e |-s [a-zA-Z0-9]*|-t [0-9]+|-H |-P |-L [a-z0-9:_]*)?[ ]?shell)$"
        If (RegExMatch(firstCmd,androidRegEx)) ; check shell change on-the-fly for ADB
            this.shell := "android"
        Else If (RegExMatch(firstCmd,"i)[ ]*exit[ ]*")) ; change back to windows on EXIT command
            this.shell := "windows"
        
        f := FileOpen(this.hStdIn, "h", this.codepage), f.Write(firstCmd "`r`n"), f.close(), f := "" ; send cmd
        
        If (this.shell = "android" And !this.m) ; check shell
            this.uWrite(this.checkShell()) ; ADB - appends missing prompt after data complete
    }
    uWrite(sInput:="") { ; INTERNAL, don't use - this prevents .write() from triggering itself
        sInput := Trim(sInput,"`r`n")
        If (sInput != "")
            f := FileOpen(this.hStdIn, "h", this.codepage), f.Write(sInput "`r`n"), f.close(), f := "" ; send cmd
    }
    KeySequence(sInput) {
        curSet := A_DetectHiddenWindows
        DetectHiddenWindows true
        If (WinExist("ahk_pid " this.pid)) {
            
            If (this.m)
                DllCall("CloseHandle","Ptr",this.hStdOut) ; close handle before free console on mode "m"
            
            DllCall("FreeConsole")
            SetTimer this.stream, 0
            ControlSend sInput,, "ahk_pid " this.pid

            result := this.ReattachConsole()
        }
        DetectHiddenWindows curSet
    }
    ReattachConsole() {
        If (ProcessExist(this.pID)) {
            result := DllCall("AttachConsole", "uint", this.pID)
            
            If (this.m)
                hStdOut := DllCall("GetStdHandle", "int", -11, "ptr"), this.hStdOut := hStdOut
            
            delay := this.delay, stream := this.stream
            SetTimer stream, delay
        }
    }
    getPrompt(str,chEnv:=false) { ; catching shell prompt
        result := "", this.shellMatch := ""
        If (!str)
            return ""
        
        winRegEx     := "[\r\n]*((PS )?[A-Z]\:\\[^/?<>:*|" Chr(34) "]*>)$" ; orig: "[\n]?([A-Z]\:\\[^/?<>:*|``]*>)$"
        netshRegEx   := "[\r\n]*(netsh[ a-z0-9]*\>)$"
        telnetRegEx  := "[\r\n]*(\QMicrosoft Telnet>\E)$"
        androidRegEx := "[\r\n]*([\d]*\|?[\-_a-z0-9]+\:[^\r\n]+ (\#|\$)[ ]?)$"
        sshRegEx     := "[\r\n]*([a-z][a-z0-9_\-]+\@?[\w_\-\.]*\:[^`r`n]*?[\#\$][ `t]*)$"
        
        If (this.shell = "windows" And RegExMatch(str,"\r\n>>$")) {
            result := ">>"
        } Else If (RegExMatch(str,netshRegEx,match)) {
            result := match.Count() ? match.Value(1) : ""
            If (chEnv)
                this.shell := "netsh", this.shellMatch := match.Value(1)
        } Else If (RegExMatch(str,telnetRegEx,match)) {
            result := match.Count() ? match.Value(1) : ""
            If (chEnv)
                this.shell := "telnet"
        } Else If (RegExMatch(str,winRegEx,match)) {
            result := match.Count() ? match.Value(1) : ""
            If (chEnv)
                this.shell := "windows", this.shellMatch := match.Value(1)
        } Else If (RegExMatch(str,androidRegEx,match)) {
            result := match.Count() ? match.Value(1) : ""
            If (chEnv)
                this.shell := "android", this.shellMatch := match.Value(1)
        } Else If (RegExMatch(str,sshRegEx,match)) {
            result := match.Count() ? match.Value(1) : ""
            If (chEnv)
                this.shell := "ssh", this.shellMatch := match.Value(1)
        }
        
        return result
    }
    GetLastLine(sInput:="") { ; get last line from any data chunk
        sInput := sInput, lastLine := ""
        Loop Parse sInput, "`n", "`r"
            lastLine := A_LoopField
        return lastLine
    }
    removePrompt(buffer,lastLine) {
        If (lastLine = "")
            return buffer
        Else {
            buffer := RTrim(buffer,"`r`n ")
            nextLine := this.GetLastLine(buffer)
            While (nextLine = lastLine) {
                buffer := RegExReplace(buffer,"\Q" lastLine "\E$","")
                nextLine := this.GetLastLine(buffer)
            }
            
            return Trim(buffer,"`r`n")
        }
    }
    checkShell() {
        If (this.shell = "android")
            return "echo $HOSTNAME:$PWD ${PS1: -2}"
        Else
            return ""
    }
    shellCmdLines(str, ByRef firstCmd, ByRef batchCmd) {
        firstCmd := "", batchCmd := "", str := Trim(str," `t`r`n"), i := 0
        Loop Parse str, "`n", "`r"
        {
            If (A_LoopField != "")
                i++, ((A_Index = 1) ? (firstCmd := A_LoopField) : (batchCmd .= A_LoopField "`r`n"))
        }
        batchCmd := Trim(batchCmd," `r`n`t")
        return i
    }
    filterCtlCodes(buffer) {
        buffer := RegExReplace(buffer,"\x1B\[\d+\;\d+H","`r`n")
        buffer := RegExReplace(buffer,"`r`n`n","`r`n")
        
        r1 := "\x1B\[(m|J|K|X|L|M|P|\@|b|A|B|C|D|g|I|Z|k|e|a|j|E|F|G|\x60|d|H|f|s|u|r|S|T|c)"
        r2 := "\x1B\[\d+(m|J|K|X|L|M|P|\@|b|A|B|C|D|g|I|Z|k|e|a|j|E|F|G|\x60|d|H|f|r|S|T|c|n|t)"
        r3 := "\x1B(D|E|M|H|7|8|c)"
        r4 := "\x1B\((0|B)"
        r5 := "\x1B\[\??[\d]+\+?(h|l)|\x1B\[\!p"
        r6 := "\x1B\[\d+\;\d+(m|r|f)"
        r7 := "\x1B\[\?5(W|\;\d+W)"
        r8 := "\x1B\]0\;[\w_\-\.\@ \:\~]+?\x07"
        
        allR := r1 "|" r2 "|" r3 "|" r4 "|" r5 "|" r6 "|" r7 "|" r8
        buffer := RegExReplace(buffer,allR,"")
        
        buffer := StrReplace(buffer,"`r","")
        buffer := StrReplace(buffer,"`n","`r`n")
        return buffer
    }
}
