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
;   CliData(inCommand)  -  Function wrapper for easy use.
; ========================================================================================================
;
;   Usage:   var := CliData("your_command here")
;
;       Using this library, this function is the easiest way to "just run a command and collect the data".
;       The commands passed to CliData() must be single line commands.  You can concatenate commands.
;       For best usage, make sure that the command you pass to CliData() is intended to return to a
;       windows prompt.  Otherwise you should use the cli() class below.
;
; ========================================================================================================
;   CLIobj := cli(sCmd:="", options:="", env:="cmd", params:="/Q /K")
; ========================================================================================================
;
;   ------------------------------------------- OVERVIEW -------------------------------------------
;
;       This class allows you to create CLI session as an object with the environment of your choice.  The
;       most common environments are "cmd" and "powershell", but you can use alternate console programs,
;       like ANSICON (https://github.com/adoxa/ansicon).  Environments are treated as live CLI sessions,
;       as if you had a CLI window, but of course, there is no window (except the hidden window which is
;       needed to receive CTRL events like CTLR+C and CTRL+Break.
;
;       The main driving force in this class is the "CLI prompt", and the PromptCallback function which is
;       triggered every time a prompt is detected in stdout.  This is what allows you to effortlessly pass
;       a multi-line batch of commands as the "sCmd" parameter and then collect the output.
;
;       All output is aggregated into the CLIobj.stdout property by default.  If you use mode "x", then
;       stderr is collected in CLIobj.stderr separately.
;
;       After a prompt callback event, stdout and stderr are cleared for the next command.
;
;       If you want to capture streaming output, then use the StdoutCallback funciton.
;
;       You can run multiple CLI sessions concurrently.  If you experience performance lag, then you may
;       want to slow down the timer that checks stdout.  See the "delay" property below.
;
;   Parameters:
;
;       sCmd    (required)
;
;           Single-line command or multi-line batch command.  Different modes will provide different
;           functionality.  See "Options" below.
;
;       options (optional)
;           Zero or more of the options below, separated by a pipe (|):
;
;       env     (optional)
;           Specify the environment.  This is the actual exe name of the CLI host you want to start.  You
;           do not need to specify ".exe" at the end, and you do not need to specify the full path as
;           long as your specified CLI host can be found via your system PATH environment variable.  For
;           "cmd" and "powershell" this is of course not a problem.
;
;           The default environment is "cmd".  Other possibilities include:
;           > "powershell"
;           > "ansicon" --> https://github.com/adoxa/ansicon (a 3rd party CLI console program)
;           
;           NOTE: If you specify "powershell" for env param, the default "params" is "-NoLogo".
;
;           NOTE about Android Debug Bridge (ADB):
;           
;               When running ADB commands like so:
;               
;                   adb shell ls -la
;
;               ... these types of commands run and immediately exit the adb shell, and then return a
;               windows prompt.  Because of this, these types of commands are still treated as windows
;               commands.
;
;               To start an interactive ADB session, the first command in your batch must be a variant of:
;
;                   adb [switches] shell
;
;                   NOTE: If the directory where adb.exe exists is NOT in your system PATH then this command
;                         must contain the full path to adb.exe
;
;               This first command in your batch will be used to load the shell environment, after your
;               chosen CLI host has loaded.
;
;               This class relies on the prompt mechanism in order to function.  Some ADB environments do
;               not return a prompt.  Because of this, the only way I'm currently willing to support ADB
;               sessions is if you start your batch passed into the "sCmd" parameter with a variant of
;               "adb [switches] shell".  This allows the class to check and see if a prompt is returned,
;               and if not, a fake prompt is automatically created and used.
;
;               I do plan to research this further and try to find a way to more easily detect shell changes
;               including instances when the prompt needs to be manually displayed.
;
;               In case you are wondering, "adb logcat" is treated as a windows command.  The only proper
;               way to terminate "adb logcat" is to send CTRL+C or CTRL+Break, then you will be back at
;               the windows prompt.
;
;       params
;           The default param for "cmd" environment is "/Q /K".  The /Q prevents your commands from
;           displaying in the CLI session.  Note that, CLIobj.lastCmd contains your last command so you
;           can reconstruct a normal-looking CLI session if you desire.  The /K prevents the typical
;           Microsoft logo from appearing in the CLI session.  If you want this text logo to appear,
;           then specify a value for params that does not include /K.
;
;           The "/Q /K" parameters are set as a default to simplify the usage of this class.
;
;           Check the help docs for your CLI shell to know what the options are and how to use them for
;           your specific task(s).
;
;           NOTE: If you specify "powershell" for env param, the default "params" is "-NoLogo -NoExit",
;                 which is effectively the same as "/Q /K".
; ========================================================================================================
; Options
; ========================================================================================================
;
;   ID:MyID
;       User defined string to identify CLI sessions.  This is used to identify a CLI instance within
;       callback functions.  If you manage multiple CLI sessions simultaneously you may want to use this
;       option to be able to distinguish one CLI session from another within your callback functions.
;
;   - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
;   Modes define how the CLI instance is launched and handled.
;   - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
;       The main purpose of this library is to stream CLI output, and/or to interact with the prompt.
;       It is suggested to use the CliData() wrapper function for collecting data from a single command.
;   - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
;       IMPORTANT NOTES ABOUT THIS LIBRARY:
;           Except when using the CliData() wrapper function, the user MUST call CLIobj.Close() to
;           terminate the CLI session AFTER "properly exiting" your program.
;
;           "Properly exiting" the program means the CLI session is still active, but idle, and therefore
;           ready to be terminated.  If you don't properly exit the program you may see the following
;           processes remaining in Task Manager:
;                1) cmd.exe
;                2) the program you ran on the command line
;                3) conhost.exe (you will see more than usual - I usually see 3 of these on my system)
;
;           In extreme cases, not properly exiting the program can cause system instability.
;   - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
;   mode:[modes]  -  Modes
;   - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
;       *** You can use these modes in any combination. ***
;
;       mode "m" = Scraping mode ("m" as in "monitoring")
;
;           Use this mode when you are trying to capture text printed to the console, but not to stdout.
;           This mode is commonly used when capturing things like progress bar animations or
;           incrementing percent.  It is ideal to try looking at the stdout stream first.  If the data
;           you need isn't there, then try mode "m".
;
;           This mode is NOT meant for complete or accurate data collection.  The entire grid of the
;           console is read on every cycle of the data collection timer (every 10 ms by default). A
;           default console is 100 x 9000 (100 columns x 9000 rows) characters.  For performance reasons,
;           the console must be resized.  If you do not specify a size then 100 x 10 is used by default.
;
;           Since the console must be resized, the result will only be a small snapshot of the full
;           output.  This is why it is not good for accurate or complete data collection.
;
;           Lastly, when using mode "m", you don't want to accumulate data as if you are streaming
;           stdout.  Since you are only getting a rectangular snapshot of the console output, you
;           need to treat each cycle of the StdoutCallback as "all the data there is".  Again, this
;           mode is not meant for complete and accurate collection of data.  You will likely be
;           missing data (like trying to do a complete "dir" listing of "C:\Windows\System32").
;
;       mode "c" = Delay sCmd execution.
;
;           Optionally set more options before execution by specifying:
;
;               CLIobj.option := value
;
;           When you are ready to start the CLI session, execute with CLIobj.RunCmd()
;
;           This is quite useful.  You can also attach an array as a property containing a list of
;           commands.  In this case you would use the prompt callback event as the trigger to check
;           the array and execute the next command.
;
;           You can also eaisly make use of a progress bar during your session.  Check the AutoHotkey v2
;           forums for the Progress2 library.
;
;           There are many ways you can construct your CLI environment.  Remember that the CLI object is
;           passed as a parameter in all callback functions, so you can attach anything you like and
;           still have access to it in the callback functions.  This allows the coder to reduce the
;           amount of global variables needed for complex operations.
;
;       mode "x" = Extract StdErr in a separate pipe for each command.
;
;           This is best used with PromptCallback(). Generally, you should clear cli.stdout and cli.stderr
;           after each PromptCallback() cycle to keep the correlation between the command, stdout, and
;           stderr clear.
;
;       mode "f" = Filter control codes.  This mostly pertains to Linux environments such as SSH or
;           old ADB sessions.
;   - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
;   More Options    NOTE: All options, including the ones above, are also properties that can be set
;                         prior to command execution when using Mode "c".  You can also change these
;                         properties on-the-fly within callback functions.
;   - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
;
;   AutoClean:1
;       This option attempts to automatically trim trailing spaces on lines of txt in stdout.  Depending
;       on the amount of text you capture, and how quickly, this may cost you an undesired performance
;       hit.  You may be better off analyzing the text you capture closely to determine the type of
;       treatment it should get.
;
;   codepage:CP###
;       Codepage (UTF-8 = CP65001 / Windows Console = CP437 / etc...)
;
;   Delay:###
;       Set the timer delay for checking stdout.  By default, it is every 10 milliseconds.  On my system
;       this usually causes intermittent CPU usage of 1% or less.  If you have a slower system, or if you
;       are trying to run multiple concurrent CLI sessions, then you may need to increase this value to
;       check stdout less often.
;
;   PromptCallback:Give_It_A_Name
;       Defines the PromptCallback function.  If the callback function exists, it will be called when the
;       CLI session encounters a recognized prompt.
;
;       Currently recognized prompts are:
;
;           Windows CMD
;           Windows Powershell
;           Android Debug Bridge (ADB)
;           netsh
;           SSH (particularly from plink, the CLI version of PuTTY)
;       
;       > Default callback: PromptCallback(prompt, ID, CLIobj)
;
;       The "ready" property during the first prompt is set to "false" (0):
;
;       PromptCallback(prompt, ID, c) {
;
;           MsgBox(CLIobj.ready)   ; Returns 0 on the first prompt callback event, otherwise 1.
;
;       }
;
;       This signifies that the CLi session is "loaded", and also means the first command in your
;       batch is about to be sent.  Depending on how you use this library and the callbacks, you
;       may or may not need to pay attention to the "ready" property.
;
;       The Prompt Callback is the underlying mechanism that makes this library sane.  It is
;       important to be familiar with how this callback works if you are going to get the most out
;       of this library.
;
;       Example:
;
;           PromptCallback(prompt, ID, CLIobj) {
;               If !(CLIobj.ready)      ; Skip the first prompt.
;                   return              ; Again, you may or may not need this...
;
;               ... other stuff, check stdout/stderr after each command
;           }
;
;   QuitCallback:Give_It_A_Name
;       Defines the QuitCallback function.  If the callback function exists, it will be called when the
;       CLI session encounters the defined QuitString (see below).
;   
;       > Default callback: QuitCallback(quitString, ID, CLIobj)
;       > The QuitString option must be set in order to use the QuitCallback.
;
;   QuitString:Your_Quit_Msg_Here
;       If you define this option, and if the QuitCallback function exists, then the specified string
;       will be searched while the output is streaming.  If this string is found at the end of a StdOut,
;       and on it's own line, then data collection will halt and the QuitCallback will be triggered.
;       Then the process will be terminated.
;
;       On tests with mode "m", because of the "/Q" parameter (omitting the command, and the subsequent
;       CRLF after the command) ECHO commands won't appear on the next line, so you will need to add an
;       additional echo like so:
;
;           ECHO. & ECHO My Quit Message
;
;       You can of course
;
;   showWindow:#
;       Specify 0 or 1.  Default = 0 to hide.  1 will show.
;       The console window will always be blank because stdout is redirected away from the console.  The
;       console window only exists so that control signals (CTRL+C / CTRL+Break / etc.) can be sent to
;       the window.  See the "KeySequence" method below.  This is only provided as a convenience for
;       curious coders, but usually isn't useful.
;
;   StdOutCallback:Give_It_A_Name
;       Defines the stdOutCallback function name.  If the callback exists, it will fire on this event.
;
;       > Default callback: StdOutCallback(data, ID, CLIobj)
;
;   waitTimeout:###   (ms)
;       The waitTimeout is an internal correction.  There is a slight pause between starting a CLI
;       session and getting data in the buffer (usually the first prompt).  If this timeout value
;       elapses and there is no data in stdout, then you will see a message saying:
;
;           Primary environment failed to load: [ cmd / powershell / other ]
;
;       The default delay to wait for the enviornment to load is 1000 milliseconds, but usually it doesn't
;       take that long to load.  As soon as there is data in stdout waiting to be read, this wait timeout
;       automatically halts.
;
;   width:#  /  height:#
;       Sets the number of columns/rows for the console to use.  These properties/options currently don't
;       do anything.  I plan to implement pseudo-console environments at some point, and in that case
;       these options will have a meaning.
;
;   workingDir:c:\myDir
;       Set working directory.  Defaults to A_ScriptDir.  Commands that generate or modify files will use
;       the specified working directory.  Relative paths are normally relative to the working directory.
;       Take care when specifying a working directory, especially when modifying files.
;
; ========================================================================================================
; CLI class Methods and properties
; ========================================================================================================
;   Methods:
; ========================================================================================================
;
;   CLIobj.clean_lines(sInput, sep := "`n")
;       Trims spaces at the end of each line.  When `n is specified for sep (which is the default) `r will
;       be omitted.  When `r is specified for sep, then `n will be omitted.  It is possible to get mixed
;       line endings in CLI output.  Running this method twice, once with `n as sep, and once with `r
;       as sep, will take care of trailing spaces on all lines when encountering mixed line-endings.
;
;       NOTE:  A line ending is commonly referred to as CR, LF, or CRLF.  In AutoHotkey:
;
;           CR = `r (character 13 - the CARRIAGE RETURN)
;           LF = `n (character 10 - the LINE FEED)
;
;       For native windows commands you will almost always get CRLF endings.  For linux commands ported
;       to windows, madness is likely to enuse.  It is not uncommon to get a mix of CR, LF, and CRLF
;       when using linux commands ported to windows.
;
;   CLIobj.close()
;       Closes all open handles and tries to end the session.  If you try this without "properly exiting"
;       your program, then your script may appear to hang or malfunciton.  If you need to force termination
;       of your program, then send a CTRL+C or CTRL+Break signal first.  Read more below.
;
;   CLIobj.GetLastLine(str)
;       Returns last line of "str".  This is useful in callback functions when reading stdout, but you
;       really need to understand the output you are working with to parse it correctly.
;
;   CLIobj.KeySequence("string")
;       Sends a key sequence, ie. CTRL+Key.  DO NOT use this like the .write() method because this method
;       is not accurate for sending commands.  Only use this to send control signals like CTRL+C or
;       CTRL+Break (or CTRL+D in ADB, which actually does the same as CTRL+C ;-).
;       
;       This is commonly used to "properly exit" a program that is still running, prior to calling
;       CLIobj.close() and terminating the CLI session.  There could be a different key combo other than
;       CTRL+C or CTRL+Break to properly interrupt your program.  Read the docs of your program to learn
;       how to properly interrupt it.
;
;   CLIobj.runCmd()
;       Runs the command(s) specified in sCmd parameter.  This is only meant to be used with mode "c" when
;       delayed execution is desired for specifying additional options, parameters, or properties.
;       When using Mode "c", you can also do something fancy, like attaching an array of commands as
;       a property to the CLi object, and then you can check stdout, and then run the next command in the
;       array with CLIobj.Write(text)
;
; ========================================================================================================
;    Properties (useful with CLIobj in callback functions):
; ========================================================================================================
;
;   CLIobj.[option]
;       All options above are also properties that can be checked or set.
;
;   CLIobj.batchProgress
;       Contains the number of completed commands.
;
;   CLIobj.batchCommands
;       Contains the total number of commands (lines) passed into the .write() method.
;
;   CLIobj.cmdHistory
;       This is a text list (delimited by `r`n) of commands executed so far during your CLI session. The
;       last command in the list is the same as the lastCmd property.
;
;   CLIobj.hProc   /   CLIobj.hThread
;       Get the handle to the process/thread of the CLI session.
;
;   CLIobj.lastCmd
;       This is the last command that was run during your CLI session.  When using the PromptCallback(),
;       the .stdout and .stderr properties contain output data as a result of the last command run.
;
;   CLIobj.pID   /   CLIobj.tID
;       Get the process/thread ID of the CLI session.
;
;   Cliobj.ready
;       This is set to FALSE on the first prompt event.  The first prompt event is simply the CLI
;       environment displaying the first prompt, indicating it is ready to receive commands.
;
;       After the first prompt event, then this property is set to TRUE.
;
;       This could be useful for filtering out the first prompt event when using the prompt callback
;       function.
;
;   CLIobj.shell
;       Returns the currently detected shell (so far as my regex can detect).  This is useful when
;       typing a command to load a shell within a shell, and trying to deal with certain quirks unique
;       to a specific shell environment.
;
;       Currently supported shell environments:
;           - Windows
;           - netsh
;           - ADB (Android Debug Bridge)
;           - SSH
;       
;       NOTE:  A new shell environment is only properly detected if this class recognizes the prompt.
;              Some ADB sessions do not return a prompt in stdout.  It depends on what version of 
;              platform-tools you use, and if you are using certain TWRP recovery shells.
;
;   CLIobj.stderr
;       This contains the stderr data output for a single command.  It is cleared after each command.
;
;   CLIobj.stdout
;       This contains the stdout data output for a single command.  It is cleared after each command.
;
;   CLIobj.use_check_shell
;       This property is false by default.  Currently this property is only used with ADB, but will
;       be used for other envionments that I find exhibit the same behavior as ADB.  Keep in mind
;       some ADB environments DO return a prompt.  This class is designed to auto-detect if the ADB
;       environment you are running returns a prompt or not, but this auto-detection only happens
;       when you create the CLIobj and specify "adb [switches] shell" as your first command in "sCmd".
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
;       automatically execute the specified command.
;
;   CLIobj.fStdOut - file object
;       This property contains all methods and properties of an AHK File Object.
;
;   CLIobj.fStdErr - file object
;       This property contains all methods and properties of an AHK File Object.  This property is only
;       valid when using mode "x".
;
; ========================================================================================================
; KNOWN ISSUES
; ========================================================================================================
;   * None at the moment!
; ========================================================================================================

CliData(inCommand:="") { ; Single line commands ONLY!
    If (!inCommand)
        return ""
    Else {
        ; cli_session := new cli(inCommand,"one_time:1")  ; AHK v1
        cli_session := cli(inCommand,"one_time:1")  ; run command, prune prompt
        result := cli_session.stdout                ; get the data
        cli_session.close(), cli_session := ""      ; clean up
        return Trim(result,"`r`n`t")                ; return result
    }
}

class cli {
    StdOutCallback:="stdOutCallback", PromptCallback:="PromptCallback", QuitCallback:="QuitCallback", QuitString:=""
    delay:=10, waitTimeout:=1000, showWindow:=0, codepage:="CP0", workingDir:=A_WorkingDir
    shell:="windows", ready:=false, run:=false
    ID:="", mode:="", hStdIn:=0, hStdOut:=0, hStdErr:=0, stdout:="", stderr:="", stdoutRaw:=""
    conWidth:=100, conHeight:=10, AutoClean := false
    batchCmdLines:=0, batchProgress:=0, batchCmd:="", terminateBatch := false, cmdHistory:="", lastCmd:=""
    fStdErr:={AtEOF:1, Handle:0}, fStdOut:={AtEOF:1, Handle:0}
    
    ver := SubStr(A_AhkVersion,1,1)
    androidRegEx := ((this.ver=1)?"O":"") "Si)^((.*?)?adb(?:\.exe)? +(\-a +|\-d +|\-e +|\-s +[\w]+ +|\-t +[\w]+ +|\-H +|\-P +|\-L +[\w:_]+ +)?shell)$"
    use_check_shell := false
    prompt_helper := "generic_prompt"
    ExitCmd := "exit"
    c := 0, x := 0, f := 0
    do_next_cmd := true
    one_time := false
    
    rgxobj := (this.ver = 1) ? "O" : "" ; regex strings to only assign once
    inv_path      := "\/\?\<\>\:\*\|\" Chr(34) "\r\n\``" ; invalid path chars
    winRegEx      := this.rgxobj "S)((?:\r\n)?(?:PS )?[A-Z]\:\\[^" this.inv_path "]*> *)$"  ; orig: "[\n]?([A-Z]\:\\[^/?<>:*|``]*>)$"
    netshRegEx    := this.rgxobj "S)((?:\r\n)?netsh[ a-z0-9]*\>)$"
    adbRegEx      := this.rgxobj "mS)^((?:[a-z][a-z0-9_\-]*\:)?(?:/.*?|~) (?:\#|\$)[ ]?)$"
    sshRegEx      := this.rgxobj "S)((?:\n)?[a-z][a-z0-9_\-]+\@?[\w_\-\.]*\:[^`r`n]*?[\#\$][ `t]*)$"     ; "user@PC:~/Dir/Path$ "
    ps_part       := this.rgxobj "S)((?:\r\n)?>> *)$" ; PowerShell partial expression prompt
    
    __New(sCmd, options:="", _env:="cmd", params:="/K") {
        this.batchCmd := this.sCmd := sCmd
        this._env := _env ; save originally passed env for shorthand comparisons
        (_env = "adb") ? _env := "cmd" : ""
        this.env := (!FileExist(_env)) ? this.check_exe(_env) : _env
        this.params := (_env = "powershell" && params="/K") ? "-NoLogo -NoExit" : params
        
        this.batchCmdLines := (this.shellCmdLines(sCmd)).count
        
        optGrp := StrSplit(options,"|")        ; next load specified properties (options param)
        For i, curItem in optGrp
            optItem := SubStr(curItem, 1, (sep := InStr(curItem,":")) - 1)  ; do this with SubStr() otherwise setting WorkingDir won't work
          , this.%optItem% := SubStr(curItem, sep+1) ; AHK v2
          ; , this[optItem] := SubStr(curItem, sep+1) ; AHK v1
        
        ; dbg("one_time: " this.one_time)
        
        this.stream := ObjBindMethod(this,"sGet") ; register function Obj for timer (stream)
        
        this.c := InStr(this.mode,"c")
        this.x := InStr(this.mode,"x")
        this.f := InStr(this.mode,"f")
        this.m := InStr(this.mode,"m")
        
        If (!this.c)
            this.runCmd()
    }
    check_exe(sInput) {
        sInput := (!RegExMatch(sInput,"\.exe$")) ? sInput ".exe" : sInput
        path := EnvGet("PATH")
        
        ; Loop, Parse, % path, `; ; AHK v1
        Loop Parse path, ";" ; AHK v2
            If FileExist(A_LoopField "\" sInput)
                return RegExReplace(A_LoopField "\" sInput,"[\\]{2,}","\")
        return ""
    }
    __Delete() {
        this.close() ; close all handles / objects
    }
    runCmd() {
        ; dbg("   runCmd() start")
        Static p := A_PtrSize
        this.run := true
        
        If (InStr(this.mode,"(") And InStr(this.mode,")") And this.m) ; mode "m" !!
            s1 := InStr(this.mode,"("), e1 := InStr(this.mode,")"), mParam := SubStr(this.mode,s1+1,e1-s1-1), dParam := StrSplit(mParam,",")
          , conWidth := dParam[1], conHeight := dParam[2], this.conWidth := conWidth, this.conHeight := conHeight
        (this.m) && (this._env = "powershell") ? (this.params .= " -Command") : ""
        (this.m) ? this.params .= " MODE CON: COLS=" this.conWidth " LINES=" this.conHeight : ""
        
        
        ; r1 := DllCall("CreatePipe","UPtr*",hStdInRd,"UPtr*",hStdInWr,"Uint",0,"Uint",0) ; AHK v1
        r1 := DllCall("CreatePipe","UPtr*",&hStdInRd:=0,"UPtr*",&hStdInWr:=0,"Uint",0,"Uint",0)   ; get handle - stdIn (R/W)
        r2 := DllCall("SetHandleInformation","UPtr",hStdInRd,"Uint",1,"Uint",1)                  ; set flags inherit - stdIn
        this.hStdIn := hStdInWr
        
        If (!this.m) { ; AHK v1 needs no "&" on all DllCall()s
            ; r1 := DllCall("CreatePipe","UPtr*",hStdOutRd,"UPtr*",hStdOutWr,"Uint",0,"Uint",0) ; AHK v1
            r1 := DllCall("CreatePipe","UPtr*",&hStdOutRd:=0,"UPtr*",&hStdOutWr:=0,"Uint",0,"Uint",0) ; get handle - stdOut (R/W)
            r2 := DllCall("SetHandleInformation","UPtr",hStdOutWr,"Uint",1,"Uint",1)                 ; set flags inherit - stdOut
            this.hStdOut := hStdOutRd
        } Else hStdOutRd := 0, hStdOutWr := 0
        
        If (this.x)
            ; r1 := DllCall("CreatePipe","UPtr*",hStdErrRd,"UPtr*",hStdErrWr,"Uint",0,"Uint",0) ; AHK v1
            r1 := DllCall("CreatePipe","UPtr*",&hStdErrRd:=0,"UPtr*",&hStdErrWr:=0,"Uint",0,"Uint",0) ; stdErr pipe on mode "x"
          , r2 := DllCall("SetHandleInformation","UPtr",hStdErrWr,"Uint",1,"Uint",1)
        this.hStdErr := (this.x) ? hStdErrRd : hStdOutRd
        
        ; VarSetCapacity(pi, (p=4)?16:24, 0)                                     ; AHK v1
        ; VarSetCapacity(si, siSize:=(p=4)?68:104,0)                             ; AHK v1
        pi := Buffer((p=4)?16:24, 0)                                     ; PROCESS_INFORMATION structure
        si := Buffer(siSize:=(p=4)?68:104,0)                             ; STARTUPINFO Structure
        
        ; NumPut(siSize, si, 0, "UInt")                                    ; AHK v1
        ; NumPut(0x100|0x1, si, (p=4)?44:60, "UInt")                       ; AHK v1
        ; NumPut(this.showWindow ? 0x1 : 0x0, si, (p=4)?48:64, "UShort")   ; AHK v1
        NumPut("UInt", siSize, si, 0)                                    ; cb > structure size
        NumPut("UInt", 0x100|0x1, si, (p=4)?44:60)                       ; STARTF_USESTDHANDLES (0x100) | STARTF_USESHOWWINDOW (0x1)
        NumPut("UShort", this.showWindow ? 0x1 : 0x0, si, (p=4)?48:64)   ; wShowWindow / 0x1 = show
        
        ; NumPut(hStdInRd, si, (p=4)?56:80, "UPtr")                        ; AHK v1
        NumPut("UPtr", hStdInRd, si, (p=4)?56:80)                        ; stdIn handle
        If (!this.m)
            ; NumPut(hStdOutWr, si, (p=4)?60:88, "UPtr")                          ; AHK v1
          ; , NumPut((this.x ? hStdErrWr : hStdOutWr), si, (p=4)?64:96, "UPtr")   ; AHK v1
            NumPut("UPtr", hStdOutWr, si, (p=4)?60:88) ; stdOut handle
          , NumPut("UPtr", (this.x ? hStdErrWr : hStdOutWr), si, (p=4)?64:96) ; stdErr handle (on mode "x", otherwise use stdout handle)
        Else If (this.x) ; using mode "m" and "x" ... tricky!
            ; NumPut(hStdErrWr, si, (p=4)?64:96, "UPtr") ; AHK v1
            NumPut("UPtr", hStdErrWr, si, (p=4)?64:96)
        
        r := DllCall("CreateProcess"
            , "Str", this.env, "Str", this.params
            , "Uint", 0, "Uint", 0          ; process/thread attributes
            , "Int", true                   ; always inherit handles to keep StdIn secure
            , "Uint", 0x10                  ; 0x10 (CREATE_NEW_CONSOLE), 0x200 (CREATE_NEW_PROCESS_GROUP)
            , "Uint", 0                     ; environment
            , "Str", this.workingDir        ; working Directory pointer
            ; , "UPtr", &si       ; AHK v1
            ; , "UPtr", &pi)      ; AHK v1
            , "UPtr", si.ptr                 ; startup info structure - contains stdIn/Out handles
            , "UPtr", pi.ptr)                ; process info sttructure - contains proc/thread handles/IDs
        
        ; dbg("env: " this.env " / params: " this.params)
        
        if (r) {
            this.pID := NumGet(pi, p * 2, "UInt")       ; get Process ID and Thread ID
            this.tID := NumGet(pi, p * 2+4, "UInt")
            this.hProc := NumGet(pi,0,"UPtr")           ; get Process handle and Thread handle
            this.hThread := NumGet(pi,p,"UPtr")
            
            ; dbg("pid: " this.pid " / " this.tid " / " this.hproc " / " this.hthread)
            
            while (result := !DllCall("AttachConsole", "UInt", this.pID) And ProcessExist(this.pID))    ; retry attach console until success
                Sleep(10)                                                                               ; if PID exists - cmd may have returned already
            
            If (!this.m) {
                r1 := DllCall("CloseHandle","UPtr",hStdInRd) ; closing unnecessary handles
                r2 := DllCall("CloseHandle","UPtr",hStdOutWr)
                this.fStdOut := FileOpen(this.hStdOut, "h", this.codepage)  ; open StdOut stream object
            } Else
                this.hStdOut := DllCall("GetStdHandle", "Int", -11, "UPtr")
            
            If this.x
                DllCall("CloseHandle","UPtr",hStdErrWr)
              , this.fStdErr := FileOpen(this.hStdErr, "h", this.codepage)
            
            If this.m {
                SetTimer(this.stream, this.delay)
                return
            } Else this.wait() ; wait if not mode "m"
            
            stdout := ""
            
            While !(prompt := this.getPrompt(stdout)) { ; actually wait for the initial prompt (usually cmd or powershell)
                Sleep(this.delay)
                If (_out := this.filterCtlCodes(this.fStdOut.Read())) ; prune esc sequences, just in case
                    stdout .= _out
            }
            
            If (this.one_time) {
                f := FileOpen(this.hStdIn, "h", this.codepage), f.Write(this.sCmd "`r`n"), f.close(), f := ""
                stdout := ""
                While !(prompt := this.getPrompt(stdout)) { ; actually wait for the initial prompt (usually cmd or powershell)
                    Sleep(this.delay)
                    ; dbg("wtf2")
                    If (_out := this.filterCtlCodes(this.fStdOut.Read())) ; prune esc sequences, just in case
                        stdout .= _out
                }
                
                this.stdout := this.removePrompt(stdout, prompt)
                this.stdout := RegExReplace(this.stdout,"m)^\Q" this.sCmd "\E[\r\n]*$","")
                return
            }
            
            ; dbg("one time??")
            
            If !prompt {
                MsgBox("Primary environment failed to load: " this.env)
                return
            }
            
            obj := this.shellCmdLines(this.batchCmd)
            
            ; dbg("   shell: " this.shell)
            (_prompt := this.tricky_shell_check(obj)) ? (prompt := _prompt) : ""
            ; dbg("   shell: " this.shell)
            
            SetTimer(this.stream, this.delay)   ; data collection timer / default loop delay = 10 ms
            this.promptEvent(prompt)
        } Else {
            this.stdout .= (this.stdout) ? "`r`nINVALID COMMAND" : "INVALID COMMAND"
            this.close()
            MsgBox("Last Error: " A_LastError)
        }
    }
    close() { ; closes handles and may/may not kill process instance
        this.write(this.ExitCmd)
        SetTimer(this.stream, 0)             ; disable streaming timer
        (!this.m And this.fStdOut.Handle) ? this.fStdOut.Close() : "" ; close fileObj stdout handle
        this.fStdOut := {AtEOF:1, Handle:0}
        
        DllCall("CloseHandle","UPtr",this.hStdIn), DllCall("CloseHandle","UPtr",this.hStdOut)     ; close stdIn/stdOut handle
        DllCall("CloseHandle","UPtr",this.hProc),  DllCall("CloseHandle","UPtr",this.hThread)     ; close process/thread handle
        
        If (this.x)
            this.fStdErr.Close()
          , this.fStdErr := {AtEOF:1, Handle:0}
          , DllCall("CloseHandle","UPtr",this.hStdErr)     ; close stdErr handles
        
        DllCall("FreeConsole")                  ; detach console from script
        this.pid := 0, this.tid := 0, this.hProc := 0, this.hThread := 0
        this.hStdOut := 0, this.hStdIn := 0, this.hStdErr := 0
    }
    wait() {
        ticks := A_TickCount
        Loop {                  ; wait for Stdout buffer to have data
            Sleep(this.delay)   ; default delay = 10 ms
            SoEof := this.fStdOut.AtEOF, SeEof := this.fStdErr.AtEOF
            exist := ProcessExist(this.pID)
            timer := A_TickCount - ticks
            If (!SoEof Or !exist) Or (this.x And !SeEof) Or (timer >= this.waitTimeout)
                Break
        }
        return timer
    }
    mGet() { ; capture console grid output (from console buffer - not StdOut stream from the process)
        Static enc := StrLen(Chr(0xFFFF)) ? "UTF-16" : "UTF-8"
        Static mult := StrLen(Chr(0xFFFF)) ? 2 : 1
        otherStr := "", curPos := 1
        If (exist := ProcessExist(this.pID)) {
            ; VarSetCapacity(lpCharacter, this.conWidth * this.conHeight * 2,0)  ; AHK v1
            lpCharacter := Buffer(this.conWidth * this.conHeight * 2,0)  ; console buffer size to collect
            dwBufferCoord := 0 ; top-left start point for collection
            ; dwBufferCoord := (1<<16)|1 ; this would be 1,1
            
            result := DllCall("ReadConsoleOutputCharacter"
                             ,"UPtr",this.hStdOut   ; console buffer handle
                             ; ,"UPtr",&lpCharacter ; AHK v1
                             ,"UPtr",lpCharacter.ptr ; str buffer
                             ,"UInt",this.conWidth * this.conHeight ; define console dimensions
                             ,"UInt",dwBufferCoord ; start point >> 0,0 ... 2 UShort values
                             ; ,"UInt*",lpNumberOfCharsRead,"Int") ; AHK v1
                             ,"UInt*",&lpNumberOfCharsRead:=0,"Int")
            ; chunk := StrGet(&lpCharacter,enc) ; AHK v1
            chunk := StrGet(lpCharacter,enc)
            
            While (curLine := SubStr(chunk,curPos,this.conWidth))
                otherStr .= RTrim(curLine) "`r`n", curPos += this.conWidth
        }
        
        return Trim(otherStr,"`r`n")
    }
    sGet() { ; stream-Get (timer) - collects until process exits AND buffer is empty
        cbStdOut := this.CheckCallback(this.StdOutCallback)
        cbQuit := this.CheckCallback(this.QuitCallback)
        
        buf := (!this.m) ? this.getStdOut() : this.mGet()
        this.getStdErr() ; check stdout/stderr buffer
        
        fullEOF := (!this.m) ? this.fStdOut.AtEOF : 1 ; check EOF, in mode "m" this is always 1 (because StdOut is grid, not a stream)
        (this.x && this.fStdOut.AtEOF && this.fStdErr.AtEOF) ? (fullEOF := true) : (fullEOF := false)
        
        ; dbg("checking buffer")
        
        If (!this.m && (buf || this.stderr)) || (this.m && (buf != this.stdoutRaw)) {
            this.stdoutRaw := buf
            (this.f) ? (buf := this.filterCtlCodes(buf)) : ""                               ; remove control codes (SSH, older ADB)
            
            buf := RegExReplace(buf,"^\Q" this.lastCmd "\E[\r\n]*","")                      ; Prune the command if it is there.
            If (this.shell = "android") && (RegExReplace(buf,"[\r\n]","") = this.lastCmd)   ; Same as above but truncated/wrapped at 80 chars.
                buf := ""                                                                   ;    ... semi-rare, but definitely happens
            
            prompt := this.getPrompt(buf,true)                                              ; isolate prompt
            buf := this.removePrompt(buf,prompt)                                            ; remove prompt from buffer
            
            If (this.QuitString And RegExMatch(Trim(buf,"`r`n`t"),"[\r\n]*\Q" this.QuitString "\E$") And cbQuit) {
                cbQuit.Call(this.QuitString,this.ID,this) ; check for QuitString before prompt is added
                this.batchCmd := "" ; erase remaining commands
                return
            }
            
            ; dbg("    buffer: " buf)
            
            this.stdout .= buf
            
            (cbStdOut) ? cbStdOut.Call(buf,this.ID,this) : ""   ; trigger stdout callback
            (prompt) ? this.promptEvent(prompt) : ""            ; trigger prompt callback
        }
        
        If (!ProcessExist(this.pID) And fullEOF) {  ; if process exits AND buffer is empty
            this.batchProgress += 1
            SetTimer(this.stream, 0)                ; stop data collection when process exits
        }
    }
    clean_lines(sInput, sep:="`n") {
        result := ""
        omit := (sep = "`n") ? "`r" : "`n"
        
        ; Loop, Parse, % sInput, % sep, % omit ; AHK v1
        Loop Parse sInput, sep, omit
            result .= ((A_Index>1)?"`r`n":"") RTrim(A_LoopField," `t")
        
        return result
    }
    getStdErr() {
        ; If (this.x && this.fStdErr.__Handle && !this.m) { ; AHK v1
        If (this.x && this.fStdErr.Handle && !this.m) {
            stdErr := RTrim(Trim(this.fStdErr.read(),"`r`n"))
            If (stdErr != "")
                (this.stdErr="") ? this.stderr := stderr : this.stderr .= "`r`n" stderr
        }
    }
    getStdOut(buf := "") {
        ; If this.fStdOut.__Handle ; AHK v1
        If this.fStdOut.Handle
            buf := this.fStdOut.Read()
        return buf
    }
    promptEvent(prompt) {
        prompt := StrReplace(StrReplace(prompt,"`r",""),"`n","")
        cbPrompt := this.CheckCallback(this.PromptCallback)
        
        ; dbg("cli() prompt event: ready: " this.ready " / prompt: " prompt)
        (this.ready) ? this.batchProgress += 1 : ""         ; increment batchProgress / when this is 1, the first command has been completed.
        
        If (this.AutoClean) {
            this.stdout := this.clean_lines(this.stdout)        ; sep by `n first, omit `r
            this.stdout := this.clean_lines(this.stdout, "`r")  ; sep by `r, omit `n (rare, but does happen)
        }                                                       ; ... sometimes you get `r line endings without `n
        
        (cbPrompt) ? cbPrompt.Call(prompt,this.ID,this) : ""    ; trigger callback function
        (!this.ready) ? (this.ready := true) : ""               ; set ready after first prompt
        
        this.stdout := "", this.stderr := ""                    ; clear stdout and stderr for next command
        (this.batchCmd && this.do_next_cmd) ? this.write(this.batchCmd) : ""        ; write next command in batch, if any
    }
    write(sInput:="") {
        If !this.run {
            Msgbox("The command has not been run yet.  You must call:`r`n`r`n     cliObj.runCmd()")
            return
        }
        
        sInput := Trim(sInput, "`r`n")
        If (sInput = "") Or this.terminateBatch {
            this.lastCmd := "", this.batchCmd := "", this.terminateBatch := false, this.batchProgress := 0, this.batchCmdLines := 0
            Return
        }
        
        obj := this.shellCmdLines(sInput)
        SetTimer(this.stream, 0)
        If (prompt := this.tricky_shell_check(obj)) { ; Check if this cmd is a tricky shell
            this.do_next_cmd := false     ; ... and if it is ...
            
            ; dbg("CLISAK oops...")
            
            this.promptEvent(prompt)      ; Throw a prompt, but don't execute next command
            this.do_next_cmd := true      ; ... that would cause an infinite loop.
            obj := this.shellCmdLines(obj.batch) ; Get next command after changing shells.
        }
        SetTimer(this.stream, this.delay)   ; data collection timer / default loop delay = 10 ms
        
        this.lastCmd := obj.first
        this.batchCmd := obj.batch
        this.cmdHistory .= (this.cmdHistory?"`r`n":"") obj.first
        
        ; dbg("   c.write(): " obj.first " / shell: " this.shell)
        f := FileOpen(this.hStdIn, "h", this.codepage), f.Write(obj.first "`r`n"), f.close(), f := "" ; send cmd
        
        If (this.use_check_shell && !this.m) ; check shell
            this.uWrite(this.fake_prompt()) ; appends prompt when not provided by the shell
    }
    uWrite(sInput:="") { ; INTERNAL, don't use - this prevents .write() from triggering itself
        sInput := Trim(sInput,"`r`n")
        If (sInput != "")
            f := FileOpen(this.hStdIn, "h", this.codepage), f.Write(sInput "`r`n"), f.close(), f := "" ; send cmd
    }
    KeySequence(sInput) {
        curSet := A_DetectHiddenWindows
        DetectHiddenWindows(true)
        If (WinExist("ahk_pid " this.pid)) {
            (this.m) ? DllCall("CloseHandle","UPtr",this.hStdOut) : "" ; close handle before free console on mode "m"
            DllCall("FreeConsole")
            SetTimer(this.stream, 0)
            ControlSend(sInput,, "ahk_pid " this.pid)
            result := this.ReattachConsole()
        }
        DetectHiddenWindows(curSet)
    }
    ReattachConsole() {
        If (ProcessExist(this.pID)) {
            result := DllCall("AttachConsole", "UInt", this.pID)
            (this.m) ? this.hStdOut := DllCall("GetStdHandle", "Int", -11, "UPtr") : ""
            SetTimer(this.stream, this.delay)
        }
    }
    getPrompt(str,chEnv:=false) { ; catching shell prompt
        result := "", this.shellMatch := ""
        If (!str)
            return ""
        
        ; If (this.shell = "windows" And RegExMatch(str,this.ps_part,match)) {    ; AHK v1
            ; result := match.Count() ? match[1] : ""                             ; AHK v1
        If (this.shell = "windows" And RegExMatch(str,this.ps_part,&match)) {
            result := match.Count ? match[1] : ""
        ; } Else If (RegExMatch(str,this.netshRegEx,match)) { ; AHK v1
            ; result := match.Count() ? match[1] : ""         ; AHK v1
        } Else If (RegExMatch(str,this.netshRegEx,&match)) {
            result := match.Count ? match[1] : ""
            If (chEnv)
                this.shell := "netsh", this.shellMatch := match[1]
              , this.use_check_shell := false
        ; } Else If (RegExMatch(str,this.winRegEx,match)) {   ; AHK v1
            ; result := match.Count() ? match[1] : ""         ; AHK v1
        } Else If (RegExMatch(str,this.winRegEx,&match)) {
            result := match.Count ? match[1] : ""
            If (chEnv)
                this.shell := "windows", this.shellMatch := match[1]
              , this.use_check_shell := false
        ; } Else If (RegExMatch(str,this.adbRegEx,match)) {   ; AHK v1
            ; result := match.Count() ? match[1] : ""         ; AHK v1
        } Else If (RegExMatch(str,this.adbRegEx,&match)) {
            result := match.Count ? match[1] : ""
            If (chEnv)
                this.shell := "android", this.shellMatch := match[1]
        ; } Else If (RegExMatch(str,this.sshRegEx,match)) {   ; AHK v1
            ; result := match.Count() ? match[1] : ""         ; AHK v1
        } Else If (RegExMatch(str,this.sshRegEx,&match)) {
            result := match.Count ? match[1] : ""
            If (chEnv)
                this.shell := "ssh", this.shellMatch := match[1]
              , this.use_check_shell := false
        }
        
        return result
    }
    GetLastLine(sInput:="") { ; get last line from any data chunk
        lastLine := ""
        ; Loop, Parse, % RTrim(sInput,"`r`n"), `n, `r ; AHK v1
        Loop Parse RTrim(sInput,"`r`n"), "`n", "`r"
            lastLine := A_LoopField
        return lastLine
    }
    removePrompt(buf,prompt) {
        Static obj := (this.ver = 1) ? "O)" : ""
        If (prompt = "")
            return buf
        Else {
            nextLine := this.GetLastLine(buf)
            While (Trim(nextLine,"`r`n") = Trim(prompt,"`r`n")) { ; below, "begin" captures any `r`n combo before prompt
                ; begin := ((RegExMatch(prompt,obj "O)^([\r\n]+)",match)) ? StrReplace(StrReplace(match[1],"`r","\r"),"`n","\n") : "") ; AHK v1
                begin := ((RegExMatch(prompt,obj "^([\r\n]+)",&match)) ? StrReplace(StrReplace(match[1],"`r","\r"),"`n","\n") : "")
                buf := RegExReplace(buf, begin "\Q" Trim(prompt,"`r`n") "\E[ \r\n]*$","")
                nextLine := this.GetLastLine(buf)
            }
            
            return buf
        }
    }
    fake_prompt() {
        Static q := Chr(34)
        p := this.prompt_helper
        
        If (this.shell = "android") {
            If !this.x {
                prompt := "echo " p ":$PWD $([ `whoami` == " q "root" q " ] && echo " q "#" q " || echo " q "$" q ") 1>&2"
                return prompt
            } Else {
                prompt := "echo " p ":$PWD $([ `whoami` == " q "root" q " ] && echo " q "#" q " || echo " q "$" q ")"
                return prompt
            }
        } Else
            return ""
    }
    shellCmdLines(str) {
        firstCmd := "", batchCmd := "", str := Trim(str," `t`r`n"), i := 0
        ; Loop, Parse, % str, `n, `r ; AHK v1
        Loop Parse str, "`n", "`r"
            If (A_LoopField != "")
                i++, ((A_Index = 1) ? (firstCmd := A_LoopField) : (batchCmd .= A_LoopField "`r`n"))
        
        batchCmd := Trim(batchCmd," `r`n`t")
        return {count:i, first:firstCmd, batch:batchCmd}
    }
    filterCtlCodes(buf) {
        buf := RegExReplace(buf,"\x1B\[\d+\;\d+H","`r`n")
        buf := RegExReplace(buf,"`r`n`n","`r`n")
        
        r1 := "\x1B\[(m|J|K|X|L|M|P|\@|b|A|B|C|D|g|I|Z|k|e|a|j|E|F|G|\x60|d|H|f|s|u|r|S|T|c)"
        r2 := "\x1B\[\d+(m|J|K|X|L|M|P|\@|b|A|B|C|D|g|I|Z|k|e|a|j|E|F|G|\x60|d|H|f|r|S|T|c|n|t)"
        r3 := "\x1B(D|E|M|H|7|8|c)"
        r4 := "\x1B\((0|B)"
        r5 := "\x1B\[\??[\d]+\+?(h|l)|\x1B\[\!p"
        r6 := "\x1B\[\d+\;\d+(m|r|f)"
        r7 := "\x1B\[\?5(W|\;\d+W)"
        r8 := "\x1B\]0\;[^\x07]+\x07"
        
        allR := r1 "|" r2 "|" r3 "|" r4 "|" r5 "|" r6 "|" r7 "|" r8
        buf := RegExReplace(buf,allR,"")
        
        buf := StrReplace(buf,"`r","")
        buf := StrReplace(buf,"`n","`r`n")
        return buf
    }
    CheckCallback(cb) {
        f := false
        If !cb
            return f
        
        t := Type(cb) ; AHK v2 only
        
        If (this.ver=2) {
            If (t = "String") {
                Try (f := %cb%)
            } Else If (t = "Func") || (t = "Closure") || (t = "BoundFunc")
                f := cb
        } Else {
            ; If IsFunc(cb)           ; AHK v1
                ; f := Func(cb)       ; AHK v1
        }
        return f
    }
    tricky_shell_check(obj) {
        result := false
        
        If this.one_time
            return
        Else If RegExMatch(obj.first,this.androidRegEx) {  ; check "known" tricky sub shells
            ; dbg("shell change")
            this.shell := "android"
        } Else {
            ; dbg("no shell change: " obj.first)
            return
        }
        
        stdout := prompt := ""      ; start with fresh stdout and prompt
        this.f := true              ; automatically add mode "f" for ADB
        this.batchCmd := obj.batch
        this.lastCmd := obj.first
        this.cmdHistory .= (this.cmdHistory?"`r`n":"") obj.first
        
        f := FileOpen(this.hStdIn, "h", this.codepage), f.Write(obj.first "`r`n"), f.close(), f := ""
        f := FileOpen(this.hStdIn, "h", this.codepage), f.Write("echo 'no prompt'`r`n"), f.close(), f := ""
        
        ; dbg(" >>> tricky prompt start")
        While !InStr(stdout,"no prompt") {
            If (_out := this.filterCtlCodes(this.fStdOut.Read()))
                stdout .= _out
              , prompt := this.getPrompt(stdout)
            Sleep(this.delay)
        }
        this.use_check_shell := false
        ; dbg(" >>> tricky prompt search")
        
        If (!prompt) { ; no prompt! so, get shell info in order to fabricate a prompt
            this.use_check_shell := result := true
            
            If (this.shell = "android") { ; shell-specific solutions to make a prompt
                f := FileOpen(this.hStdIn, "h", this.codepage), f.Write("getprop ro.hardware`r`n"), f.close(), f := ""
                this.wait()
                this.prompt_helper := Trim(this.fStdOut.Read()," `r`n`t") ; set as needed for creating fake promts
            }
            
            f := FileOpen(this.hStdIn, "h", this.codepage), f.Write(this.fake_prompt() "`r`n"), f.close(), f := ""
            this.wait()
            stdout := (stdout?"`r`n":"") this.filterCtlCodes(this.fStdOut.Read())
            prompt := this.getPrompt(stdout)
            
            ; dbg(" >>> tricky prompt end")
            
            If !prompt {
                Msgbox("Secondary environment failed to load, or prompt is not recognized.`r`n`r`n"
                     . "Use a debugger to check stdout.")
                this.close() ; abort everything
                return
            }
        }
        
        stdout := this.fStdOut.Read()       ; empty the buffer before continuing
        return prompt
    }
}

; ======================================================================
; AHK v1 compatibility wrapper functions
; ======================================================================

; ProcessExist(pid) { ; AHK v1 compatibility methods
    ; result := 0
    ; Process, Exist, %pid%
    ; result := ErrorLevel ? ErrorLevel : result
    ; return result
; }
; ProcessClose(pid) {
    ; result := 0
    ; Process, Close, %pid%
    ; result := ErrorLevel ? ErrorLevel : result
    ; return result
; }
; EnvGet(inVar) {
    ; EnvGet, outVar, % inVar
    ; return outVar
; }
; MsgBox(_msg) {
    ; Msgbox % _msg
; }
; Sleep(int) {
    ; Sleep, int
; }
; SetTimer(fnc, time) {
    ; time := (time=0) ? "Off" : time
    ; SetTimer, % fnc, % time
; }
; DetectHiddenWindows(val) {
    ; val := (val>0) ? "On" : "Off"
    ; DetectHiddenWindows, % val
; }
; ControlSend(keys, ctl:="", winTitle:="") {
    ; ControlSend,, % keys, % winTitle
; }

; ======================================================================
; ======================================================================




; dbg(_in) {
    ; Loop Parse _in, "`n", "`r" ; AHK v1 needs "Loop, Parse, ..."
        ; OutputDebug "AHK: " A_LoopField ; AHK v1 needs ---> OutputDebug, AHK: %A_LoopField%
; }

; StdIn(close:=false) {
    ; Static f := FileOpen("*", "r")
    
    ; If (close) {
        ; f.Close()
        ; return
    ; }
    
    ; return (!f.AtEOF) ? f.Read() : ""
; }