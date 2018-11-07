If not A_IsAdmin {
   Run *RunAs "%A_AhkPath%" "%A_ScriptFullPath%" "%1%"
   ExitApp
}

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

RamDrivePath() {
	MyFunctionsScriptPath = %A_LineFile%
	SplitPath, MyFunctionsScriptPath, , MyFunctionsPath, , ,
	Return MyFunctionsPath
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;; RamDrive Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;******************************************************** # CreateRamDrive()
; Creates a RamDrive (X:/Y:/Z: whichever is availabe) as a RemovableDisk and assigns "RamDisk" as label
CreateRamDrive() {
	fpath := RamDrivePath()
	IfExist, C:\Windows\System32\imdisk.exe
	{
		MsgBox, Found true installation of "ImDisk Virtual Disk Driver". `nYou can directly run the ImDisk. `nProgram ends here
		Return
	}
	RunWait, sc create AWEAlloc binPath= "%fpath%\ImDisk_Portable\awealloc.sys" DisplayName= "AWE Memory Allocation Driver" Type= kernel Start= demand,, Hide
	RunWait, sc create ImDisk binPath= "%fpath%\ImDisk_Portable\imdisk.sys" DisplayName= "ImDisk Virtual Disk Driver" Type= kernel Start= demand,, Hide
	RunWait, sc create ImDskSvc binPath= "%fpath%\ImDisk_Portable\imdsksvc.exe" DisplayName= "ImDisk Virtual Disk Driver Helper" Type= own Start= demand,, Hide
	RunWait, sc description AWEAlloc "Driver for physical memory allocation through AWE",, Hide
	RunWait, sc description ImDisk "Disk emulation driver",, Hide
	RunWait, sc description imdsksvc "Helper service for ImDisk Virtual Disk Driver.",, Hide
	RunWait, net start ImDskSvc,, Hide
	RunWait, net start AWEAlloc,, Hide
	RunWait, net start ImDisk,, Hide
	NewDriveArray := ["E:","F:","G:", "H:", "I:", "J:", "K:", "L:", "M:", "N:", "O:", "P:", "Q:"]
	Loop, 13
	{
		tdrive := NewDriveArray[A_Index]
		DriveGet, status, Status, %tdrive%
		If (status = "Invalid")
		{
			Run, "%fpath%\ImDisk_Portable\imdisk.exe" -a -s 32M -m %tdrive% -o rem -p "/fs:ntfs /v:RamDisk /A:512 /q /c /y",, Hide
			Loop
				DriveGet, status2, Status, %tdrive%
			Until status2 = "Ready"
			Break
		}
	}
	temp:="RamDrive"
	expression:=(%temp%:=tdrive) ;create global variable
	Return, tdrive

}

;******************************************************** # RemoveRamDrive()
; Removes the RamDrive with "RamDisk" as label
RemoveRamDrive() {
	fpath :=RamDrivePath()
	RamDrv := GetRamDriveLetter()
	If (RamDrv != "")
		RunWait, "%fpath%\ImDisk_Portable\imdisk.exe" -D -m %RamDrv%,, Hide
	Sleep, 100
	RunWait, sc delete ImDskSvc,, Hide
	RunWait, sc delete AWEAlloc,, Hide
	RunWait, sc delete ImDisk,, Hide
	Run, taskkill /f /IM "imdisk.exe",, Hide
	Run, taskkill /f /IM "imdsksvc.exe",, Hide
	RunWait, sc delete ImDskSvc,, Hide
	RegDelete, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\ImDskSvc /f
	RunWait, sc delete AWEAlloc,, Hide
	RegDelete, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\AWEAlloc /f
	RunWait, sc delete ImDisk,, Hide
	RegDelete, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\ImDisk /f
}

;******************************************************** # GetRamDriveLetter()
;Removes the RamDrive with "RamDisk" as label and return the drive letter
GetRamDriveLetter() {
	DriveGet TempText, List, REMOVABLE
	Loop, Parse, TempText
	{
		DriveGet TempText, Label, %A_LoopField%:
		If (TempText = "RamDisk")
			Drv := % A_LoopField ":"
	}
	Return Drv
}	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;; CMD Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;******************************************************** # CMDReturn()
; Make sure to include quotes for both the command to run and parameters
CMDReturn(CommandtoRun, params) {
	RamDrv := GetRamDriveLetter()
	FileTemp = %RamDrv%\CMDoutput.txt
	If (RamDrv = "")
		RamDrv = %A_Temp%\CMDoutput.txt
	If Not (params = "")
		RunWait, %comspec% /c %CommandtoRun% "%params%" >%FileTemp%,, Hide
	If (params = "")
		RunWait, %comspec% /c %CommandtoRun% >%FileTemp%,, Hide
	FileRead, cmdReturn, %FileTemp%
	FileDelete, %FileTemp%
	Return, cmdReturn
}