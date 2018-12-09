/* Function: ExecScript
 *     Run/execute AutoHotkey script[file, through named pipe(s) or from stdin]
 *     Mod of/inspired by HotKeyIt's DynaRun()
 * License:
 *     WTFPL [http://wtfpl.net/]
 * Syntax:
 *     exec := ExecScript( code [ , args, kwargs* ] )
 * Parameter(s)/Return Value:
 *     exec           [retval] - a WshScriptExec object [http://goo.gl/GlEzk5]
 *                               if WshShell.Exec() method is used else 0 for
 *                               WshShell.Run()
 *     script             [in] - AHK script(file) or code(string) to run/execute.
 *                               When running from stdin(*), if code contains
 *                               unicode characters, WshShell will raise an
 *                               exception.
 *     args          [in, opt] - array of command line arguments to pass to the
 *                               script. Quotes(") are automatically escaped(\").
 *     kwargs*  [in, variadic] - string in the following format: 'option=value',
 *                               where 'option' is one or more of the following
 *                               listed in the next section.
 * Options(kwargs* parameter):
 *     ahk   - path to the AutoHotkey executable to use which is relative to
 *             A_WorkingDir if an absolute path isn't specified.
 *     name  - when running through named pipes, 'name' specifies the pipe name.
 *             If omitted, a random value is generated. Otherwise, specify an
 *             asterisk(*) to run from stdin. This option is ignored when a file
 *             is specified for the 'script' parameter.
 *     dir   - working directory which is assumed to be relative to A_WorkingDir
 *             if an absolute path isn't specified.
 *     cp    - codepage [UTF-8, UTF-16, CPnnn], default is 'CP0'. 'CP' may be
 *             omitted when passing in 'CPnnn' format. Omit or use 'CP0' when
 *             running code from stdin(*).
 *     child - if 1(true), WshShell.Exec() method is used, otherwise .Run().
 *             Default is 1. Value is ignored and .Exec() is always used when
 *             running code from stdin.
 * Example:
 *     exec := ExecScript("MsgBox", ["arg"], "name=some_name", "dir=C:\Users")
 * Credits:
 *     - Lexikos for his demonstration [http://goo.gl/5IkP5R]
 *     - HotKeyIt for DynaRun() [http://goo.gl/92BBMr]
 */
ExecScript(script, args:="", kwargs*)
{
	;// Set default values for options first
	child  := true ;// use WshShell.Exec(), otherwise .Run()
	, name := "AHK_" . A_TickCount
	, dir  := ""
	, ahk  := A_AhkPath
	, cp   := 0

	for i, kwarg in kwargs
		if ( option := SubStr(kwarg, 1, (i := InStr(kwarg, "="))-1) )
		; the RegEx check is not really needed but is done anyways to avoid
		; accidental override of internal local var(s)
		&& ( option ~= "i)^child|name|dir|ahk|cp$" )
			%option% := SubStr(kwarg, i+1)

	pipe := (run_file := FileExist(script)) || (name == "*") ? 0 : []
	Loop % pipe ? 2 : 0
	{
		;// Create named pipe(s), throw exception on failure
		if (( pipe[A_Index] := DllCall(
		(Join, Q C
			"CreateNamedPipe"            ; http://goo.gl/3aJQg7
			"Str",  "\\.\pipe\" . name   ; lpName
			"UInt", 2                    ; dwOpenMode = PIPE_ACCESS_OUTBOUND
			"UInt", 0                    ; dwPipeMode = PIPE_TYPE_BYTE
			"UInt", 255                  ; nMaxInstances
			"UInt", 0                    ; nOutBufferSize
			"UInt", 0                    ; nInBufferSize
			"Ptr",  0                    ; nDefaultTimeOut
			"Ptr",  0                    ; lpSecurityAttributes
		)) ) == -1) ; INVALID_HANDLE_VALUE
			throw A_ThisFunc . "() - Failed to create named pipe.`nA_LastError: " . A_LastError
	}

	static fso := ComObjCreate("Scripting.FileSystemObject")
	static q := Chr(34) ;// double quote("), for v1.1 and v2.0-a compatibility
	; AutoHotkey.exe
	cmd := q . fso.GetAbsolutePathName(ahk) . q . " /ErrorStdOut /"
	; /CPn switch
	    .  ( cp ~= "i)^(CP)?\d+$" ? (Abs(cp) != "" ? "CP" . cp : cp)
	       : cp =  "UTF-8"        ? "CP65001"
	       : cp =  "UTF-16"       ? "CP1200"
	       : cp := "CP0" ) . " "
	; Target = pipe|script file|stdin(*)
	    .  q . (pipe ? "\\.\pipe\" . name : (run_file ? script : "*")) . q
	; Parameters to pass to the script
	for each, arg in args
	{
		i := 0
		while (i := InStr(arg, q,, i+1)) ;// escape '"' with '\'
			if (SubStr(arg, i-1, 1) != "\")
				arg := SubStr(arg, 1, i-1) . "\" . SubStr(arg, i++)
		cmd .= " " . (InStr(arg, " ") ? q . arg . q : arg)
	}

	if cwd := (dir != "" ? A_WorkingDir : "") ;// change working directory if needed
		SetWorkingDir %dir%

	static WshShell := ComObjCreate("WScript.Shell")
	exec := (child || name == "*") ? WshShell.Exec(cmd) : WshShell.Run(cmd)
	
	if cwd ;// restore working directory if altered above
		SetWorkingDir %cwd%
	
	if !pipe ;// file or stdin(*)
	{
		if !run_file ;// run stdin
			exec.StdIn.WriteLine(script), exec.StdIn.Close()
		return exec
	}

	DllCall("ConnectNamedPipe", "Ptr", pipe[1], "Ptr", 0) ;// http://goo.gl/pwTnxj
	DllCall("CloseHandle", "Ptr", pipe[1])
	DllCall("ConnectNamedPipe", "Ptr", pipe[2], "Ptr", 0)

	if !(f := FileOpen(pipe[2], "h", cp))
		return A_LastError
	f.Write(script) ;// write dynamic code into pipe
	f.Close(), DllCall("CloseHandle", "Ptr", pipe[2]) ;// close pipe

	return exec
}