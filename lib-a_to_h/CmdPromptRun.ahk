; https://autohotkey.com/docs/commands/Run.htm
CmdPromptRun(fnCommands)
{
	; run multiple commands in one go and retrieve their output
	; MsgBox fnCommands: %fnCommands%


	; declare local, global, static variables


	Try
	{
		; set default return value
		; ReturnValue := 0 ; success


		; validate parameters
		; If !fnCommands
			; Throw, Exception("xErrorMessagex")


		; initialise variables
		shell := ComObjCreate("WScript.Shell")        ; WshShell object: http://msdn.microsoft.com/en-us/library/aew9yb99
		
		
		; Execute a single command via cmd.exe
		; exec := shell.Exec(ComSpec " /C " command)


		; Execute a command script via cmd.exe
		exec := shell.Exec(ComSpec " /Q /K echo off") ; Open cmd.exe with echoing of commands disabled
		exec.StdIn.WriteLine(fnCommands "`nexit")       ; Send the commands to execute, separated by newline ; Always exit at the end!
	
	
	}
	Catch, ThrownValue
	{
		ReturnValue := !ReturnValue
		CatchHandler(ThrownValue.Message,ThrownValue.What,ThrownValue.Extra,ThrownValue.File,ThrownValue.Line,0,0,0)
	}
	Finally
	{
	}

	; return
	return exec.StdOut.ReadAll() ; Read and return the output of all commands
}


/* ; testing
BatchScript := "
(
echo Put your commands here,
echo each one will be run,
echo and you'll get the output.
)"

; BatchScript := ""

ReturnValue := CmdPromptRun(BatchScript)
MsgBox, CmdPromptRun`n`nReturnValue: %ReturnValue%
*/