/* Function: Include
 *     Dynamically #Include file(s) OR a string containing AHK code
 * License:
 *     WTFPL [http://wtfpl.net/]
 * Syntax:
 *     Include( incl [ , args* ] )
 * Parameter(s):
 *     incl              [in] - File pattern (accepts wildcards) OR a string
 *                              containing AHK code.
 *     args*   [in, variadic] - Command line argument(s) to pass to the
 *                              script when reloaded/re-ran by this function.
 *                              The caller can use this to determine if a
 *                              specific Include() has been performed.
 * Return value:
 *     Not relevant - I guess, since the script will be reloaded.
 * Remark(s):
 *     - Subsequent call(s) will not include previously Include()-ed file(s)
 *     OR code. It's up to the caller to keep track and re-Include() them.
 *     - The /restart switch is used when the script is reloaded.
 */
Include(incl, args*) {
	
	if FileExist(incl) {
		´
		fspec := incl, incl := ""
		if (A_AhkVersion < "2")
			Loop %fspec%, 0, 0
				incl .= "`n#Include " . A_LoopFileLongPath
		else
			Loop Files, %fspec%, % "F" ;// force expression to avoid v1.1 error
				incl .= "`n#Include " . A_LoopFileFullPath
	}

	;// Create named pipes
	pipe := []
	Loop 2
	{
		if (( pipe[A_Index] := DllCall(
		(Join Q C
			"CreateNamedPipe",                                       ; http://goo.gl/3aJQg7
			"Str",  "\\.\pipe\f8e5a38f-24fe-4962-9f13-6c9d7fc32197", ; lpName
			"UInt", 2,                                               ; dwOpenMode = PIPE_ACCESS_OUTBOUND
			"UInt", 0,                                               ; dwPipeMode = PIPE_TYPE_BYTE
			"UInt", 255,                                             ; nMaxInstances
			"UInt", 0,                                               ; nOutBufferSize
			"UInt", 0,                                               ; nInBufferSize
			"Ptr",  0,                                               ; nDefaultTimeOut
			"Ptr",  0                                                ; lpSecurityAttributes
		)) ) == -1) ; INVALID_HANDLE_VALUE = -1
			throw A_ThisFunc . "() - Failed to create named pipe.`nGetLastError: " . A_LastError
	}

	;// Process command line argument(s)
	q := Chr(34) ;// double quote for v1.1 and v2.0-a compatibility
	params := ""
	for each, arg in args
	{
		i := 0
		while (i := InStr(arg, q,, i+1)) ;// escape '"' with '\'
			if (SubStr(arg, i-1, 1) != "\")
				arg := SubStr(arg, 1, i-1) . "\" . SubStr(arg, i++)
		params .= (A_Index > 1 ? " " : "") . (InStr(arg, " ") ? q . arg . q : arg)
	}
	
	;// Reload script passing args(if any)
	Run "%A_AhkPath%" /restart "%A_ScriptFullPath%" %params%

	DllCall("ConnectNamedPipe", "Ptr", pipe[1], "Ptr", 0) ;// http://goo.gl/pwTnxj
	DllCall("CloseHandle", "Ptr", pipe[1])
	DllCall("ConnectNamedPipe", "Ptr", pipe[2], "Ptr", 0)

	;// Write dynamic code into pipe
	if !(f := FileOpen(pipe[2], "h", "UTF-8")) ;// works on both Unicode and ANSI
		return A_LastError
	f.Write(incl)
	f.Close(), DllCall("CloseHandle", "Ptr", pipe[2]) ;// close pipe handle
}
;// pipe, do not remove. UUID generated using Python's uuid.uuid4()
#Include *i \\.\pipe\f8e5a38f-24fe-4962-9f13-6c9d7fc32197