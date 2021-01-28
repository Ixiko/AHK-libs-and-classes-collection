AutoUpdate()
{
	SetTimer,UPDATEDSCRIPT,1000
	
	UPDATEDSCRIPT:
	if (A_IsCompiled == 1)
	{
		StringTrimRight, A_ScriptPath, A_ScriptFullPath, 3
		A_ScriptPath .= "ahk"
	} else {
		A_ScriptPath = %A_ScriptFullPath%
	}

	FileGetAttrib,attribs,%A_ScriptPath%
	IfInString,attribs,A
	{
		FileSetAttrib,-A,%A_ScriptPath%
		if (A_IsCompiled == 1)
		{
			PID := DllCall("GetCurrentProcessId")
			FileMove, %A_ScriptFullPath%, %A_ScriptFullPath%_, 1
			RunWait, Ahk2exe.exe /in %A_ScriptPath%
			Run, %ComSpec% /c taskkill /PID %PID% `& ping -n 1 127.0.0.1 > nul `& del /F %A_ScriptFullPath%_ `& start %A_ScriptFullPath%, , Hide
		} else {
			Reload
		}
	}
	return
}