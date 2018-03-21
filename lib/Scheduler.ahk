/* 
	Function:	Create	
				Creates new scheduled task.

	Parameters:
		Name	 -	Specifies a name for the task
		Run		 -	Specifies the program or command that the task runs. 
		Args	 -  Arguments of the program that the task runs.
		Type	 -	MINUTE, HOURLY, DAILY, WEEKLY, MONTHLY,     ONCE, ONSTART, ONLOGON, ONIDLE.  By default, ONCE.
		Mod		 -  Modifier, number, Specifies how often the task runs within its schedule type (defaults to 1). See bellow.	 

		Day		 -  Specifies a day of the week or a day of a month. Valid only with a WEEKLY or MONTHLY schedule.
					For WEEKLY type, valid values are MON-SUN and * (every day). MON is the default.
					A value of MON-SUN is required when the FIRST, SECOND, THIRD, FOURTH, or LAST modifier is used.
					A value of 1-31 is optional and is valid only with no modifier or a modifier of the 1-12 type.

		Month	 -  Specifies a month of the year. Valid values are JAN - DEC and *  The parameter is valid only with a MONTHLY schedule. 
					It is required when the LASTDAY modifier is used. Otherwise, it is optional and the default value is * (every month).
		IdleTime -  A whole number from 1 to 999. Specifies how many minutes the computer is idle before the task starts. This parameter is valid only with an ONIDLE schedule, and then it is required.
		Time	  - Specifies the time of day that the task starts in HH:MM:SS 24-hour format. The default value is the current local time when the command completes. \
					Valid with MINUTE, HOURLY, DAILY, WEEKLY, MONTHLY, and ONCE schedules. It is required with a ONCE schedule.
		EndTime	  - A value that specifies the end time to run the task. The time format is HH:mm (24-hour time). For example, 14:50 specifies 2:50PM. This is not applicable for the following schedule types: ONSTART, ONLOGON, ONIDLE, and ONEVENT.
		Duration  - A value that specifies the duration to run the task. The time format is HH:mm (24-hour time). For example, 14:50 specifies 2:50PM. This is not applicable with /ET and for the following schedule types: ONSTART, ONLOGON, ONIDLE, and ONEVENT. For /V1 tasks (Task Scheduler 1.0 tasks), if /RI is specified, then the duration default is one hour.
		StartDate - Specifies the date that the task starts in MM/DD/YYYY format. The default value is the current date. Valid with all schedules, and is required for a ONCE schedule.
		EndDate	  - Specifies the last date that the task is scheduled to run. This parameter is optional. It is not valid in a ONCE, ONSTART, ONLOGON, or ONIDLE schedule. By default, schedules have no ending date.
		Computer  - Specifies the name or IP address of a remote computer (with or without backslashes). The default is the local computer.
		User	  - Runs the command with the permissions of the specified user account. By default, the command runs with the permissions of the user logged on to the computer running SchTasks.
		Password  - Specifies the password of the user account specified in the _User_ parameter (required with it)
		Flags	  - See bellow.

	Flags:
		K		  - A value that terminates the task at the end time or duration time. This is not applicable for the following schedule types: ONSTART, ONLOGON, ONIDLE, and ONEVENT. Either EndTime or Duration must be specified.
		Z         - A value that marks the task to be deleted after its final run.
	
	Modifiers:
		MINUTE  - (1 - 1439) The task runs every n minutes.
		HOURLY  - (1 - 23)	 The task runs every n hours.
		DAILY	- (1 - 365)	 The task runs every n days.
		WEEKLY  - (1 - 52)	 The task runs every n weeks.
		MONTHLY - (1 - 12)	 The task runs every n months. LASTDAY - The task runs on the last day of the month. FIRST, SECOND, THIRD, FOURTH, LAST  Use with the /d day parameter to run a task on a particular week and day. For example, on the third Wednesday of the month.

 */
Scheduler_Create( v, bForce=false ) {
	static arguments="Type Mod Day Month IdleTime Time EndDate Computer User Password StartDate EndTime Duration Repeat"
	static Type="/sc", Mod="/mo", Day="/d", Month="/m", IdleTime="/i", Time="/st", EndDate="/ed", Computer="/s", User="/u", Password="/p", StartDate="/sd", EndTime="/et", Duration="/du", Repeat="/ri"

	Name := %v%_Name,  Run := %v%_Run,  Args := %v%_Args

   ;errors
	if (Name = "") 
		return "ERROR: No value specified for 'Name' option."
	if (Run = "")
		return "ERROR: No value specified for 'Run' option."

   ;defaults 
	if ( %v%_Type = "" )
		%v%_Type := "ONCE"

	if (%v%_Computer = "")
		%v%_Computer := "localhost"
	
   ;check for 2.0
	if A_OSVersion not in WIN_VISTA
	{
		if (%v%_EndTime != "")
			return A_ThisFunc "> Your OS doesn't support this feature: EndTime"
		if (%v%_Duration != "")
			return A_ThisFunc "> Your OS doesn't support this feature: Duration"
		if (%v%_Flags != "")
			return A_ThisFunc "> Your OS doesn't support this feature: Flags"
	}
	
   ;generate cmd line
	cmd = /create /tn "%Name%" /tr "\"%Run%\" %Args%"
	loop, parse, arguments, %A_Space%
	{
		c := %A_LoopField%,   
		val := %v%_%A_LoopField%
		StringReplace, val, val, `",, A
		if val !=					
			cmd = %cmd% %c% %val%
	}

	;add flags
	loop, parse, %v%_Flags
		cmd .= " /" A_LoopField
	
	;in vista it can be done with /F but this works too...
	if Scheduler_Exists(Name)
	{
		if !bForce
		{
			Msgbox, 36, %A_ThisFunc%, Scheduled task '%Name%' already exists.`n`nDo you want to overwrite ?
			IfMsgBox No
				return "Operation canceled."
		}
		Scheduler_Delete( %v%_Name, true)
	}
	res := Scheduler_run("Schtasks " cmd)
	StringReplace, res, res, `r`nType "SCHTASKS /CREATE /?" for usage.`r`n
	return res
}

/*	Function:	ClearVar
				Clears the global array.
	
 */
Scheduler_ClearVar(v){
	static args="Computer,Name,NextRun,LastRun,User,Run,State,Time,Type,StartDate,EndDate,LastResult,Mod"
	loop, parse, args, `,
		%v%_%A_LoopField% := ""
}

/* 
	Function: Delete	
			  Delete specified scheduled task

	Parameters:
		Name   - Specifies the name of task to be deleted. Use "*" to delete all tasks.
		bForce - Surpess confimration message, false by default.		

 */
Scheduler_Delete( Name, bForce=false, User="", Password="", Computer="")
{
	StringReplace, Name, Name, `", ,A
	if (!bForce) {
		Msgbox, 36, %A_ThisFunc%, Are you sure you want to delete task "%Name%" ? 
		IfMsgBox No, return
	}
	
	cmd = /delete /f /tn "%Name%" %A_Space%
	cmd .= User != "" ? "/u" User : ""
	cmd .= Password != "" ? "/p" Password : ""
	cmd .= Computer != "" ? "/s" Computer : ""

	res := Scheduler_run("Schtasks " cmd)
	return res
}
/* 
	Function: Query
			  Query specified scheduled task or all tasks.

	Parameters:
		Name   - Specifies the name of task. Use empty string to return all tasks.
		var	   - If non empty, variable prefix for task parameters extraction.

 */
Scheduler_Query(Name="", var=""){
	global
	static args="Computer,Name,NextRun,LastRun,User,Run,State,Time,Type,StartDate,EndDate,LastResult,Mod"
	static 1="Computer",2="Name",3="NextRun",6="LastRun",7="LastResult",8="User",9="Run",12="State",20="Time",21="StartDate",22="EndDate",23="Day",24="Month",25="Mod"

	local cmd, res, p, out, out1

	if A_OSVersion in WIN_VISTA
	{
		StringReplace, Name, Name, `", ,A
		cmd := "Schtasks /query /fo CSV /v " (Name != "" ? "/tn """ Name """"  : "")
		res := Scheduler_run(cmd)
		if InStr(res, "ERROR: The system cannot find the file specified")
			res := ""
		
		;remove header, /NH has a bug : Schtasks /query /fo CSV /v /NH /tn "ISPP Konzola StanjaPodracunaISPP" ---> reports that LIST ouptut is active ....
		res := SubStr(res, InStr(res, "`n")+1)
	} else {
		cmd := "/query /fo CSV /v"
		res := Scheduler_run("Schtasks " cmd)
	}
	
	if (var != ""){
		Scheduler_ClearVar( var )
		loop, parse, res, CSV
		{
			ifEqual, A_Index, 26, break
			f := %A_Index%			
			ifEqual, f, ,continue
			%var%_%f% := Scheduler_fixData(f, A_LoopField)
		}
	}
	return res
}

/* Function:	Exists
				Check if task exists.
	
   Parameter: 
				Name	- Name of the task.
 */
Scheduler_Exists(Name) {

	if A_OsVersion in WIN_VISTA
		return Scheduler_Query(Name) != ""
	else if InStr("`n" Scheduler_Run("schtasks /query /fo CSV /NH"), """" Name """")
			return true
}


/* Function:	Exists
				Check if task exists.
	
   Parameter: 
				Name	- Name of the task.
 */
Scheduler_Enable( Name, Value ) {
	if A_OsVersion not in WIN_VISTA
		return A_ThisFunc "> Your OS doesn't support this feature"
	
	Scheduler_Run("schtasks /change /TN """ Name """ /" Value ? "ENABLE" : "DISABLE")
}

/*	Function:	Open
				Opens or activates the Task Scheduler.

	Returns:
				PID of Task Scheduler process.
 */
Scheduler_Open() {
	static PID

	if WinExist("ahk_pid " PID)	{
		WinActivate, ahk_pid %PID%
		return
	}

	if A_OSVersion in WIN_VISTA
		 Run, %A_WinDir%\system32\mmc.exe %A_WinDir%\system32\taskschd.msc,,,PID
	else Run, %A_WinDir%\explorer.exe ::{20D04FE0-3AEA-1069-A2D8-08002B30309D}\::{21EC2020-3AEA-1069-A2DD-08002B30309D}\::{D6277990-4C6A-11CF-8D87-00AA0060F5BF},,,PID

	return PID
}

;fix garbadge data reported by schtasks app.
Scheduler_fixData( Field, Value ) {
	if (Field = "Mod")
		if RegExMatch( Value, "S)(\d+)\D+(\d+)", m)		;1 Hour(s), 10 Minute(s)
			return m1*60 + m2

	return Value
}

;v1.2   
Scheduler_run(Cmd, Dir = "", Skip=0, Input = "", Stream = "")
{
	DllCall("CreatePipe", "UintP", hStdInRd , "UintP", hStdInWr , "Uint", 0, "Uint", 0)
	DllCall("CreatePipe", "UintP", hStdOutRd, "UintP", hStdOutWr, "Uint", 0, "Uint", 0)
	DllCall("SetHandleInformation", "Uint", hStdInRd , "Uint", 1, "Uint", 1)
	DllCall("SetHandleInformation", "Uint", hStdOutWr, "Uint", 1, "Uint", 1)

	VarSetCapacity(pi, 16, 0) 
	NumPut(VarSetCapacity(si, 68, 0), si)	; size of si
	 ,NumPut(0x100,		si, 44)		; STARTF_USESTDHANDLES
	 ,NumPut(hStdInRd,	si, 56)		; hStdInput
	 ,NumPut(hStdOutWr, si, 60)		; hStdOutput
	 ,NumPut(hStdOutWr, si, 64)		; hStdError
	If !DllCall("CreateProcess", "Uint", 0, "Uint", &Cmd, "Uint", 0, "Uint", 0, "int", True, "Uint", 0x08000000, "Uint", 0, "Uint", Dir ? &Dir : 0, "Uint", &si, "Uint", &pi)	; bInheritHandles and CREATE_NO_WINDOW
		return A_ThisFunc "> Can't create process:`n" Cmd 
	
	hProcess := NumGet(pi,0)
    DllCall("CloseHandle", "Uint", NumGet(pi,4)),  DllCall("CloseHandle", "Uint", hStdOutWr),  DllCall("CloseHandle", "Uint", hStdInRd)

	If Input !=
		DllCall("WriteFile", "Uint", hStdInWr, "Uint", &Input, "Uint", StrLen(Input), "UintP", nSize, "Uint", 0)
	DllCall("CloseHandle", "Uint", hStdInWr)

	if (Stream+0)
		bAlloc := DllCall("AllocConsole") ,hCon:=DllCall("CreateFile","str","CON","Uint",0x40000000,"Uint", bAlloc ? 0 : 3, "Uint",0, "Uint",3, "Uint",0, "Uint",0)

	VarSetCapacity(sTemp, nTemp:=Stream ? 64-nTrim:=1 : 4095)
	loop
		If	DllCall("ReadFile", "Uint", hStdOutRd, "Uint", &sTemp, "Uint", nTemp, "UintP", nSize:=0, "Uint", 0) && nSize
		{
			NumPut(0,sTemp,nSize,"Uchar"), VarSetCapacity(sTemp,-1),  sOutput .= sTemp
			if Stream
				loop
					if RegExMatch(sOutput, "S)[^\n]*\n", sTrim, nTrim)
						 Stream+0 ? DllCall("WriteFile", "Uint", hCon, "Uint", &sTrim, "Uint", StrLen(sTrim), "UintP", 0, "Uint", 0) : %Stream%(sTrim), nTrim += StrLen(sTrim)
					else break
		}
		else break

	DllCall("CloseHandle", "Uint", hStdOutRd)
	Stream+0 ? (DllCall("Sleep", "Uint", 1000), hCon+1 ? DllCall("CloseHandle","Uint", hCon) : "", bAlloc ? DllCall("FreeConsole") : "" ) : ""
	DllCall("GetExitCodeProcess", "uint", hProcess, "intP", ExitCode), DllCall("CloseHandle", "Uint", hProcess)

	if (Skip != ""){
		StringSplit, s, Skip, ., 
		StringReplace, sOutput, sOutput, `n, `n, A UseErrorLevel
		s2 := ErrorLevel - (s2 ? s2 : 0) + 1, 	s1++
		loop, parse, sOutput,`n,`r
			if A_Index between %s1% and %s2%
				s .= A_LoopField "`r`n"
		StringTrimRight, sOutput, s, 2
	}

	ErrorLevel := ExitCode
	return	sOutput
}

/* 
 Group: About 
 	o v0.94 by majkinetor.
	o Schtasks at MSDN: http://www.microsoft.com/resources/documentation/windows/xp/all/proddocs/en-us/schtasks.mspx?mfr=true
	o Licenced under GNU GPL <http://creativecommons.org/licenses/GPL/2.0/>
 */

