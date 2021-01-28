ShortcutCreate()
{
	; creates a shortcut for the link
	; MsgBox params: %params%


	; declare local, global, static variables
	Global ApplicationName


	Try
	{
		; set default return value
		ReturnValue := 0 ; success


		; validate parameters


		; initialise variables


		; do something
		fnStartTime := A_TickCount
		fnElapsedTime := A_TickCount - fnStartTime ; measure elapsed time
		While (ShortcutExists() = 0 && fnElapsedTime < 10000) ; try for up to 10 secs, while the file does not exist
		{
			FileCreateShortcut, %A_ScriptFullPath%, %A_Startup%\%ApplicationName%.lnk ; create it
			fnElapsedTime := A_TickCount - fnStartTime ; measure elapsed time
		}

	}
	Catch, ThrownValue
	{
		ReturnValue := !ReturnValue
		CatchHandler(A_ThisFunc,ThrownValue.Message,ThrownValue.What,ThrownValue.Extra,ThrownValue.File,ThrownValue.Line,0,0,0)
	}
	Finally
	{
	}

	; return
	Return ReturnValue
}


/* ; testing
params := xxx
ReturnValue := ShortcutCreate(params)
MsgBox, ShortcutCreate`n`nReturnValue: %ReturnValue%
*/