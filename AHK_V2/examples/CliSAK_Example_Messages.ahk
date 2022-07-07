Global Example1msg, Example2msg, Example3msg, Example4msg, Example5msg
Global Example6msg, Example7msg, Example8msg

Example1msg := "
(
This example shows the most basic usage.  Default mode when not specified is "w" (wait mode).  This mode is the most logical when the command you run is expected to return in a reasonable amount of time.

    c := new cli("cmd dir"), output := c.stdout

This one-liner will collect the data in the var `%output`%.  Keep in mind that the function will pause until the run process exits.  If you find the function is hanging more than expected, you might want to try mode "s" or "m".
=============================
The CLI session does not remain active in thie example.
)"
; ======================================================================================================
; ======================================================================================================
Example2msg := "
(
This example uses the mode "w" as well, but will result in a slight delay due to more data being returned.

    c:= new cli("cmd /C dir C:\Windows\System32"), output := c.stdout

This command is more well suited to using stream mode, especially when instant feedback is desired.  Check the next example (#3) for streaming mode.
=============================
The CLI session does not remain active in thie example.
)"
; ======================================================================================================
; ======================================================================================================
Example3msg := "
(
This example uses the stdOutCallback() function.  Mode "s" for "streaming", which also monitors StdOut constantly.  Mode "o" is for using the StdOutCallback() function.  Without mode "o", the output from StdOut is stored in the object:

    o.stdout

You can retrieve data from the object like this:

	myVar := o.stdout
	
... however you will not have any notification that the data has changed without mode "o" (or mode "i" shown later).  You will have to cycle through checking it yourself.  That's why mode "o" is more useful in many cases.

Any data that shows up in the buffer is immediately passed to the callback function.  Specifying an ID is optional, but if you are trying to use multiple instance of CLI commands at the same time, it's very helpful to specify an ID to separate the data streams.

Scroll down below the Example() functions to find the callback functions.

    c := new cli("cmd /C dir C:\windows\System32","mode:so|ID:Console")
	
    stdOutCallback(data,ID) {
        If (ID = "Console") {
            AppendText(CmdOutputHwnd,data) ; <== we are using this code
        } Else If (ID = "modeM") {
            GuiControl, , `%CmdOutputHwnd`%, `%data`% ; <-- not this code
        }
    }
	
This callback function is the default callback for StdOut.  Example #7 shows how to define your own callback functions.
=============================
The CLI session does not remain active in thie example.
)"
; ======================================================================================================
; ======================================================================================================
Example4msg := "
(
This is mode "b", aka "batch" mode.  A multi-line variable is being passed as the cmd.  This is NOT a means to run a true batch environment without a saved .BAT file, but it is equivelant to opening the CLI with cmd.exe, and running a few consecutive commands.  Some elements like "@ECHO OFF" will work if used in this context:

    batch := "cmd /Q /K``r``n"      ; <== start the CLI instance with @ECHO OFF
           . "more commands..."
	
... but other elements like "GOTO" and other multi-line statements won't function as desired.  Every command you pass must be self-contained in one line.  You can concatenate commands with "&&", but of course if you concatenate too many then your script can get more difficult to read, and you may backup the input buffer.  That's why mode "b" was made.

You can dynamically generate a multi-line batch of commands and pass that var as the cmd.  The object will wait for the prompt to return (C:\dir\dir>) before issuing the next command.  Even in "@ECHO OFF" mode the prompt will be displayed.  If you don't want the prompt in your output, append mode "p".

    batch := "cmd /Q /K ECHO. && dir C:\Windows\System32``r``n"
           . "ECHO. && cd..``r``n" ; ECHO. addes a new blank line
           . "ECHO. && dir``r``n"  ; before executing the command.
           . "ECHO. && ping 127.0.0.1``r``n"
           . "ECHO. && echo --== custom commands COMPLETE ==--"

    ; remove mode "p" below to see the prompt in data
    c:= new cli(batch,"mode:bop|ID:Console")

---=== IMPORTANT NOTE ===---

If the output happens to mimic a prmopt, specifically:

    C:\dir\dir>

... then you may encounter issues with synchronization when using mode "b".  An erroneous match is difficult however, because the output data in the buffer must actually end with a string that mimics the prompt.  So such an instance would be rare.
=============================
The CLI session does not remain active in thie example.
)"
; ======================================================================================================
; ======================================================================================================
Example5msg := "
(
This example shows CTRL+C and CTRL+Break.
 
In this example, two consecutive ping commands are run with 127.0.0.1 as the destination address.

    cmd := "cmd /K ping 127.0.0.1 && ping 127.0.0.1" ; mode "o" uses the StdOut callback function
    c := new cli(cmd,"mode:so|ID:Console")          ; mode "s" is streaming, so constant data collection

CTRL+C will stop the command.  CTRL+Break will interrupt the command and show the current stats (quickly) and then contunue running.  Press CTRL+C and CTRL+Break while this command is executing to see a demonstration.  You can assign a hotkey, button, or timer to issue the CTRL signal commands:

    c.CtrlBreak()    or    c.CtrlC()

---=== IMPORTANT NOTE ===---

In some instances, if you attempt to use the close() method to halt the CLI instance the process will continue to run.  This could be for a variety of reasons such as:

    1) you used "cmd /K"
    2) the CLI is busy running a command
    3) you issued command that will never return (intentional or not)

An idle CLI session with "cmd /K" will respond to the close() method, so issuing "EXIT" is not necessary:

    c.close()

This script's GuiClose() label contains c.close(), so all of the CLI sessions in the examples should close when you close the Example Script GUI.

Normally, if the CLI is busy, and you execute the close() method, the command will continue until complete and the process will exit.  Some commands, like real-time debug monitors, will never exit until you press CTRL+C or CTRL+Break, or some other key combination to terminate.  Check the documentation of the command you are using to figure out how to properly terminate.

If you need to send a custom key sequence to the CLI, use the KeySequence() method:

    c.KeySequence("^d")

The above would send CTRL+D to the hidden console.  The syntax is exactly the same as the AHK ControlSend command.  Note this is NOT suitable for sending text to StdIn.  This is meant for CTRL signals only.
=============================
The CLI session will remain active in thie example.  Use the bottom edit box to issue more commands.
)"
; ======================================================================================================
; ======================================================================================================
Example6msg := "
(
This example demonstrates separating StdErr with mode "x":

    c := new cli("cmd /C dir poof","mode:x") ; <=== mode "w" implied

    stdOut := "===========================``r``n"
            . "StdOut:``r``n"
            . c.stdout "``r``n"
            . "===========================``r``n"
    stdErr := "===========================``r``n"
            . "StdErr:``r``n"
            . c.stderr "``r``n"
            . "===========================``r``n"
    AppendText(CmdOutputHwnd,stdOut stdErr)
	
NOTES:
    c.stdout <= this contains StdOut data
    c.stderr  <= with mode "x" this contains StdErr data

Since mode "w" is implied, becuase no other primary modes are specified, we can check c.stdout and c.stderr immediately after the new instance of c, which runs the command and waits until command completion before continuing the script.

This function DOES NOT use StdOut and StdErr callback functions.  If you want to use the callback functions, append "o" for StdOut and append "e" for StdErr in the modes.
=============================
The CLI session does not remain active in thie example.
)"
; ======================================================================================================
; ======================================================================================================
Example7msg := "
(
This example shows a short example of an interactive console using mode "i" with mode "s".
T=====================================================

c := new cli("cmd","mode:sipf|ID:Console")

=====================================================
This sets up an interactive CLI session with the cliPromptCallback() active using mode "i".  Mode "p" simply prunes the prompt.  Mode "f" removes control codes, so you can use plink to connect to an SSH session in this example if you like.  Just put plink.exe in the same folder as the script to keep it easy (assuming you can simply use password login).

Note that cliObj.stdout is being cleared in the cliPromptCallback() function after it is printed to the GUI.  This is necessary for this example otherwise the data in cliObj.stdout would continue to accumulate.

)"
; ======================================================================================================
; ======================================================================================================
Example8msg := "
(
This uses mode "m(100,5)o".  With these parameters, the console width is 100 columns, and height is 5 rows.  Mode "o" specifies to use the stdOut callback function.

Usage:
    m(col,row[,modes])
    * col and row are explained above
    * modes are switches for cmd.exe, default if unspecified is "/C"
        Ex: m(100,5,/Q /K)   =>   this will start cmd.exe with ECHO off, and won't
                                  close cmd.exe after the command finishes.

If the command you run has an animated incrementing percent to completion, or an animated progress bar like this ...

    [=======>      ]

... then you can capture these animations using mode "m".  The hidden console, when launched, is automatically (temporarily) set to the dimensions specified with mode "m".

When using mode "m", if you want 1 row, then use 2.  If you want 4 rows, then use 5.  Always n+1.  When the command exits, the final line will almost always be blank.  Simply handle the data passed into the callback and extract only the number of lines you need.  You may have to experiment with the number of lines to capture in order to isolate the text or animation you are looking for.  Every command can be different, so you might not be able to use the same method across different commands.

Processes launched in mode "m" can recieve CTRL signals such as c.CtrlC() or c.CtrlBreak().

Using mode "m" with cmd.exe switch "/K" can be a little dicey.  This is not the same as reading the StdOut buffer.  Actually, if you need reliable complete data, do NOT use mode "m".  This is meant to capture things you otherwise can't capture in StdOut.  With mode "m" you are reading a block of text that is col*row in size and parsing all of it with every call in the callback function.  This ability to pass any switch to cmd.exe in mode "m" is added for flexiblity, but this feature hasn't been thuroughly tested yet.  Recommended usage is the default "/C", which doesn't need to be specified.

Check the code in Example #8 for directions on how to see an example using wget.exe, a command-line download program that shows an animated progress bar on the command line.
=============================
The CLI session does not remain active in thie example.
)"