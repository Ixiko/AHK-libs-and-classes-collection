; #Include WinServ.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

;Start the Task Scheduler service by using its Service Name
MsgBox % WinServ("Schedule", True) ;Returns True if started successfully.

; More Examples:

;Start the Task Scheduler service by using its Service Name
;WinServ("Schedule", True) ;Returns True if started successfully.

;Stop the Task Scheduler service by using its Display Name
;WinServ("Task Scheduler", False) ;Returns True if stopped successfully.

;Start the Windows Time service silently
WinServ("Windows time", True, True) ;No popups

;Start the Task Scheduler service on remote computer name ZOMBIE
;WinServ("Schedule", True, False, "ZOMBIE") ;Returns True if started successfully.

;Check if the WebClient service is running
If WinServ("WebClient")
{   MsgBox, WebClient is up & running
   ;Do Something
}

;Toggle the DNS Client service
;WinServ("DNS Client", WinServ("DNS Client") ? False : True)


#include %A_ScriptDir%\..\WinServW.ahk