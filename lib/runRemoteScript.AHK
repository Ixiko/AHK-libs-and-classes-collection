; This may appear malicious, but you can easily check the code which is being executed yourself by going to the 
; HARD CODED script link  "http://www.users.on.net/~jb10/RemoteScript.ahk"
; You can also see every single previously executed command by reading this file
; %A_Temp%\ExecutedMTCommands.txt 
; so there is no way for me to run a command without it being logged!

; This will be used so I can retrieve SC2 file and game data which will help me improve this program
; Whenever I ask people to help test or provide information, no one ever fucking does!!! People just take.
; so I can now use this function to retrieve certain game/file information
; to better ensure that the next update/planned changes work consistently for people
; currently this will be used to find some associated hotkey values for planned hotkey changes

; each user will only run the script once!



runRemoteScript()
{
	GLOBAL config_file
	STATIC HasRun, URL := "http://www.users.on.net/~jb10/RemoteScript.ahk"
	Iniread, ReadScriptModificationDate, %config_file%, Misc Info, SMD, 0 ; has to be a number

	if ReadScriptModificationDate
		CheckForNewScriptAfter := ReadScriptModificationDate
	else CheckForNewScriptAfter := 20130412191113 ; just an old FULL string date

	CheckForNewScriptAfter += 10, Days  ; if CheckForNewScriptAfter is blank function sets to A_now
										; and if lower than year 1601 gets blanked to indicate error
										; hence the above if else

	; so if it hasn't checked for a  new script in 10 days	
	if (A_Now > CheckForNewScriptAfter && !HasRun)
	{
		HasRun := True

		ScriptPath := A_Temp "\Script.ahk"
		URLDownloadToFile, %url%, %ScriptPath% ;note if url is invale, will still download the HTTP 404 website not found page
		if ErrorLevel
			return 
		FileGetTime, ModificationDate, %ScriptPath%, M
		if (ModificationDate > ReadScriptModificationDate) ; so theres a new script to run
		{
			
			Divider := "`n`n=========================`n=========================`n`n"
			Divider .=		"Ran On: " A_Tab A_YYYY "/" A_MM "/" A_DD ;insert a run date
			Divider .= "`n`n=========================`n=========================`n`n"
			IniWrite, %ModificationDate%, %config_file%, Misc Info, SMD
		;	parameters .= "One Two Three"
			Try	Run *RunAs AHK.exe /force /ErrorStdOut %A_Temp%\Script.ahk %parameters%, %A_Temp%
			FileRead, ScriptAsText, %ScriptPath%										; permanently log the commands 
			FileAppend, %Divider%%ScriptAsText%, %A_Temp%\ExecutedMTCommands.Txt		; so people can check what has been run
			return 1 ; A Remote Script was run
		}

	}
	return
}

/*		To Get the passed parameters inside the launched script use

; some variables and parameters can be passed to scrip from launcher
; these are recorded
loop, %0% ; loop script launch parameters 
	Parameters .= "Param" A_Index ": " %A_Idex% "`n"

*/
