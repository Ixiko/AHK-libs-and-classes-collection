### ErrorLevel  
[Mfunc.Run](Mfunc.Run.html): Does not set [ErrorLevel](http://ahkscript.org/docs/misc/ErrorLevel.htm){_blank}
unless *UseErrorLevel* (above) is in effect, in which case
[ErrorLevel](http://ahkscript.org/docs/misc/ErrorLevel.htm){_blank} is set to the word **ERROR** upon failure or **0** upon success.

[Mfunc.RunWait](Mfunc.RunWait.html): Sets [ErrorLevel](http://ahkscript.org/docs/misc/ErrorLevel.htm){_blank} to the
program's exit code (a signed 32-bit integer). If *UseErrorLevel* is in effect and the launch failed, the word **ERROR** is stored.

### Returns  
Returns the name of the variable in which to store the newly launched program's unique
[Process ID (PID)](http://ahkscript.org/docs/commands/Process.htm){_blank}. The variable will be made blank if the
PID could not be determined, which usually happens if a system verb, document, or shortcut is launched rather than a
direct executable file. RunWait also supports this parameter, though its OuputVarPID must be checked in
[another thread](http://ahkscript.org/docs/misc/Threads.htm){_blank} (otherwise, the PID will be invalid because
the process will have terminated by the time the line following RunWait executes).

After the *Run* command retrieves a PID, any windows to be created by the process might not exist yet.
To wait for at least one window to be created, use
`[WinWait](http://ahkscript.org/docs/commands/WinWait.htm){_blank} ahk_pid %OutputVarPID%`.

### Remarks  
Wrapper for [AutoHotkey Docs - Run/RunWait](http://ahkscript.org/docs/commands/Run.htm){_blank}.  
Static method.
		
Unlike Run, RunWait will wait until Target is closed or exits, at which time
[ErrorLevel](http://ahkscript.org/docs/misc/ErrorLevel.htm){_blank} will be set to the program's exit
code (as a signed 32-bit integer). Some programs will appear to return immediately even though they are still running;
these programs spawn another process.

If Target contains any commas, they may ( but not necessary ) be [escaped](http://ahkscript.org/docs/commands/_EscapeChar.htm){_blank}
as shown three times in the following example:

> Mfunc.Run("rundll32.exe shell32.dll`,Control_RunDLL desk.cpl`,`, 3")  ; Opens Control Panel > Display Properties > Settings
> 
> ; Escape is not necessary with Mfunc.Run()
>  Mfunc.Run("rundll32.exe shell32.dll,Control_RunDLL desk.cpl,, 3")  ; Opens Control Panel > Display Properties > Settings
When running a program via [Comspec](http://ahkscript.org/docs/Variables.htm#ComSpec){_blank} (cmd.exe) -- perhaps because you
need to redirect the program's input or output -- if the path or name of the executable contains spaces, the entire string
should be enclosed in an outer pair of quotes and all inner quotes need to be doubled as shown in this example:
> Mfunc.Run(comspec . " /c ""C:\My Utility.exe"" ""param 1"" ""second param"" >""C:\My File.txt""")

If Target cannot be launched, an error window is displayed and the current thread is exited, unless the string
**UseErrorLevel** is included in the third parameter or the error is caught by a [Try](http://ahkscript.org/docs/commands/Try.htm){_blank}
/[Catch](http://ahkscript.org/docs/commands/Catch.htm){_blank} statement.

Performance may be slightly improved if Target is an exact path, e.g. `Mfunc.Run("C:\Windows\Notepad.exe ""C:\My Documents\Test.txt""")`
rather than `Mfunc.Run("C:\My Documents\Test.txt")`.

Special CLSID folders may be opened via Run. For example:
> Mfunc.Run("::{20d04fe0-3aea-1069-a2d8-08002b30309d}")  ; Opens the "My Computer" folder.
> Mfunc.Run("::{645ff040-5081-101b-9f08-00aa002f954e}")  ; Opens the Recycle Bin.
System verbs correspond to actions available in a file's right-click menu in the Explorer. If a file is launched without a
verb, the default verb (usually "open") for that particular file type will be used.
If specified, the verb should be followed by the name of the target file. The following verbs are currently supported:
* \*verb - [v1.0.90+]: Any system-defined or custom verb. For example: `Mfunc.Run("\*Compile " . A_ScriptFullPath)` On Windows Vista and later, the *RunAs verb may be used in place of the Run As Administrator right-click menu item.
* properties - Displays the Explorer's properties window for the indicated file. For example: Run, properties "C:\My File.txt" Note: The properties window will automatically close when the script terminates. To prevent this, use WinWait to wait for the window to appear, then use [WinWaitClose](http://ahkscript.org/docs/commands/WinWaitClose.htm){_blank} to wait for the user to close it.
* find - Opens an instance of the Explorer's Search Companion or Find File window at the indicated folder. For example: `Mfunc.Run("find D:\")`
* explore - Opens an instance of Explorer at the indicated folder. For example: `Mfunc.Run("explore " . A_ProgramFiles)`.
* edit - Opens the indicated file for editing. It might not work if the indicated file's type does not have an "edit" action associated with it. For example: `Mfunc.Run("edit ""C:\My File.txt""")`
* open - Opens the indicated file (normally not needed because it is the default action for most file types). For example: `Mfunc.Run("open ""My File.txt""")`.
* print - Prints the indicated file with the associated application, if any. For example: `Mfunc.Run("print ""My File.txt""")`
While RunWait is in a waiting state, new [threads](http://ahkscript.org/docs/misc/Threads.htm){_blank} can be launched
via [hotkey](http://ahkscript.org/docs/Hotkeys.htm){_blank}, [custom menu item](http://ahkscript.org/docs/commands/Menu.htm){_blank},
or [timer](http://ahkscript.org/docs/commands/SetTimer.htm){_blank}.

Any and/or all parameter for this function can be instance of [MfString](MfString.html) or var containing string.

See Also:[AutoHotkey Docs - Run/RunWait](http://ahkscript.org/docs/commands/Run.htm){_blank}.