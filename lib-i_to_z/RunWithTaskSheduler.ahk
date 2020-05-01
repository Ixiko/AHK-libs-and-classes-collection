RunWithTaskSheduler(FileToRun, Arguments, TaskName := "", CP := "CP866")
{
	local
	BatFile := A_Temp . "\RunWithTaskSheduler.bat"
	TaskName := (TaskName = "") ? "Launch `%FileToRun`%" : TaskName
	CmdCommand =
	( LTrim RTrim Join`r`n
		@echo off

		call :isAdmin
		if `%ErrorLevel`% == 0 `(
		echo.Running with admin rights.
		echo.
		`) else `(
		echo.Error: You must run this script as an Administrator!
		echo.
		pause
		goto :theEnd
		`)

		set "apppath=%FileToRun%"
		set "arguments=%Arguments%"
		set "taskname=%TaskName%"
		
		schtasks /create /SC ONCE /ST 23:59 /TN "`%taskname`%" /TR "\"`%apppath`%\"`%arguments`%" /F
		
		schtasks /run /tn "`%taskname`%"
		schtasks /delete /tn "`%taskname`%" /F

		:theEnd
		TIMEOUT 30
		exit

		:isAdmin
		fsutil dirty query `%systemdrive`% >nul
		exit /b
	)
	FileDelete, %BatFile%
	FileAppend, %CmdCommand%, %BatFile%, %CP%
	RunWait, *RunAs %ComSpec% /k call "%BatFile%" ;,, Hide
	return
}
