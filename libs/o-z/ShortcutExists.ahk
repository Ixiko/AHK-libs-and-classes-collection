ShortcutExists()
{
	; determines if a shortcut for the script exists
	; MsgBox params: %params%


	; declare local, global, static variables
	Global ShortcutName


	Try
	{
		; set default return value
		fnShortcutExists := 0 ; initialise flag to assume shortcut not present


		; validate parameters


		; initialise variables


		; find shortcut
		ShortcutName := ""
		Loop, Files, %A_Startup%\*.lnk, F ; loop through all shortcut files in Startup folder
		{
			FileGetShortcut, %A_LoopFileLongPath%, fnTargetFile ; get the name of the file that the shortcut points to
			fnShortcutExists := % fnTargetFile = A_ScriptFullPath ? 1 : fnShortcutExists ; set fnShortcutExists to 1 if any shortcut file points to DAKS
			If fnShortcutExists
			{
				ShortcutName := A_LoopFileLongPath
				Break
			}
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
	Return fnShortcutExists
}


/* ; testing
params := xxx
ReturnValue := ShortcutExists(params)
MsgBox, ShortcutExists`n`nReturnValue: %ReturnValue%
*/