/* WinServ.ahk
Version			: 1.0
Author			: Hardeep Singh <http://swankyleo.googlepages.com>
Forum Topic	: http://www.autohotkey.com/forum/viewtopic.php?t=21975
License			: You may use this code freely and without any restriction. If you find it useful, do post your feedback at the
					  above mentioned forum topic.
===============================================================================
Function			: WinServ
Description	: This function can be used to start, stop or query(running status) a windows service on local or a remote
					  computer. Dialogs provide visual feedback when starting/stopping a service or when an error occurs.

~PARAMETERS~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ServiceName	: Specify either the Service Name or the Display Name of the service.

Task				: (Optional) Specify one of the following:
					  True - Starts the service (Returns True if service is started successfully).
					  False - Stops the service (Returns True if service is stopped successfully).
					  NULL(Default) - Query service status (Returns True if service is running).

Silent			: (Optional) Specify one of the following:
					  False(Default) - Show popup dialog for the task being performed or when an error occurs.
					  True - Suppress all popup dialogs including error messages.

Computer		: (Optional) Connect to the service control manager on the specified computer.
					  NULL(Default) - Connect to the service control manager on the local computer.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Return Value	: Returns TRUE or FALSE depending on the task performed.
Notes			: Starting a service which is dependent on other services will also start those services, if not already running.
					  Stopping a service which is dependent on other services will not stop those services.
===============================================================================
*/

WinServ(ServiceName, Task="", Silent=False, Computer="") {

Global schSCManager, schService
	Static SERVICE_QUERY_STATUS=0x4, SERVICE_START=0x10, SERVICE_STOP=0x20, SC_STATUS_PROCESS_INFO=0, SERVICE_CONTROL_STOP=0x1
	Static SERVICE_STOPPED=0x1, SERVICE_START_PENDING=0x2, SERVICE_STOP_PENDING=0x3, SERVICE_RUNNING=0x4
	VarSetCapacity(@SSP, 36), VarSetCapacity(BytesNeeded, 4), VarSetCapacity(SvcName ,256)

	If Task not in ,0,1
		Return WinServ_ErrMsg("Parameters", ServiceName, Task, False, ErrorLevel:="Invalid Task specified!")
	If !schSCManager := DllCall("Advapi32\OpenSCManagerA", "Str", Computer, "Uint", 0, "Uint", 0)
		Return WinServ_ErrMsg("OpenSCManager", ServiceName, Task, Silent)
	ServiceName := DllCall("Advapi32\GetServiceKeyNameA", "Uint", schSCManager, "Uint", &ServiceName, "Str", SvcName, "UintP", 256) ? SvcName : ServiceName
	If ErrorLevel
		Return WinServ_ErrMsg("GetServiceKeyName", ServiceName, Task, Silent)
	If !schService := DllCall("Advapi32\OpenServiceA", "Uint", schSCManager, "Uint", &ServiceName, "Uint", SERVICE_QUERY_STATUS|SERVICE_START|SERVICE_STOP)
		Return WinServ_ErrMsg("OpenService", ServiceName, Task, Silent)
	ServiceName := DllCall("Advapi32\GetServiceDisplayNameA", "Uint", schSCManager, "Uint", &ServiceName, "Str", SvcName, "UintP", 256) ? SvcName : ServiceName
	Progress, % Task = "" || Silent ? "10:Off" : "10:ZH0 FM10 FS10 B2 H65 W200 ZX2 ZY5", %ServiceName%, % Task ? "Starting service..." : "Stopping service..."
	If (Task = True)
	{	If !DllCall("Advapi32\StartServiceA", "Uint", schService, "Uint", 0, "Uint", 0)
			Return WinServ_ErrMsg("StartService", ServiceName, Task, Silent)
	}	else
	If (Task = False)
	{	If !DllCall("Advapi32\ControlService", "Uint", schService, "Uint", SERVICE_CONTROL_STOP, "Uint", &@SSP)
			Return WinServ_ErrMsg("StopService", ServiceName, Task, Silent)
	}
	If !DllCall("Advapi32\QueryServiceStatusEx", "Uint", schService, "Uint", SC_STATUS_PROCESS_INFO, "Uint", &@SSP, "Uint", 36, "Uint", &BytesNeeded)
		Return WinServ_ErrMsg("QueryService", ServiceName, Task, Silent)
	If Task =
		Return WinServ_ErrMsg(0,0,0,True)+(NumGet(@SSP, 4) = SERVICE_RUNNING)
	StartTickCount := A_TickCount
	OldCheckPoint := NumGet(@SSP, 20)
	Loop
	{	If (NumGet(@SSP, 4) != (Task ? SERVICE_START_PENDING : SERVICE_STOP_PENDING))
			Break
		WaitTime := NumGet(@SSP, 24)/10
		Sleep % WaitTime := WaitTime < 1000 ? 1000 : WaitTime > 10000 ? 10000 : WaitTime
		If !DllCall("Advapi32\QueryServiceStatusEx", "Uint", schService, "Uint", SC_STATUS_PROCESS_INFO, "Uint", &@SSP, "Uint", 36, "Uint", &BytesNeeded)
			Return WinServ_ErrMsg("QueryService", ServiceName, Task, Silent)
		If (NumGet(@SSP, 20) > OldCheckPoint)
		{	StartTickCount := A_TickCount
			OldCheckPoint := NumGet(@SSP, 20)
		}	else
		If (A_TickCount-StartTickCount > NumGet(@SSP, 24))
			Break
	}
	If (NumGet(@SSP, 4) != (Task ? SERVICE_RUNNING : SERVICE_STOPPED))
		Return WinServ_ErrMsg(Task ? "StartService" : "StopService", ServiceName, Task, Silent, DllCall("SetLastError", "Uint", NumGet(@SSP, 12)))
	Return WinServ_ErrMsg(0,0,0,True)+1
}

;===============================================================================
;Function		: WinServ_ErrMsg
;Description	: This function is used internally by WinServ function.
;===============================================================================
WinServ_ErrMsg(Title, ServiceName, Task="", Silent=False, Dummy="") {
	Global schSCManager, schService
	Progress, 10:Off
	If !Silent
	{	If !ErrorLevel
			VarSetCapacity(LastErrMsg, 1024), DllCall("FormatMessage", "Uint", 0x1000, "Uint", 0, "Uint", LastErrNum:=A_LastError != 123 ? A_LastError : 1060, "Uint", 0, "Str", LastErrMsg, "Uint", 1024, "Uint", 0) ;FORMAT_MESSAGE_FROM_SYSTEM=0x1000
		MsgBox, 262160, WinServ.%Title%: %ServiceName%, % "Could not " (Task = True ? "start {" : Task = False ? "stop {" : "query {") ServiceName "} service.`n`n" (!ErrorLevel ? "Error " LastErrNum ": " LastErrMsg : "Error: " ErrorLevel)
	}	DllCall("Advapi32\CloseServiceHandle", "Uint", schService), DllCall("Advapi32\CloseServiceHandle", "Uint", schSCManager)
	Return False
}