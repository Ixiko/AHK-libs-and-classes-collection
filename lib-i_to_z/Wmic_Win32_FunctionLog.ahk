
wmic_Win32_Group()
wmic_Win32_GroupUser()

wmic_Win32_Group()
{
global

wmic_logname = SystemLog-Win32_Group.txt
SetTimer,StopPullingLogs_11, 10000 ; try to pull logs for at least 10 seconds and then stop
sleep,15000 ;added for testing timer - should force it to go to label
namespace=\root\CIMV2
Class=Win32_Group

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
vOutput := ""
For Item in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Group") {
    For Key in ComObjGet("winmgmts:\\.\root\CIMV2:Win32_Group").Properties_ {
        vOutput .= Key.Name . "=" . Item[Key.Name] . "`r`n"
    }
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	FileAppend,%vOutput%`n,%wmic_logname%.txt

SetTimer,StopPullingLogs_11, Off
return

StopPullingLogs_11:
FileAppend,%wmic_logname%`n, ERROR.txt
SetTimer,StopPullingLogs_11, Off
return
}

wmic_Win32_GroupUser()
{
global

wmic_logname = SystemLog-Win32_GroupUser.txt
SetTimer,StopPullingLogs_12, 15000 ; try to pull logs for at least 10 seconds and then stop
sleep,15000 ;added for testing timer  - should force it to go to label
namespace=\root\CIMV2
Class=Win32_GroupUser

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
vOutput := ""
For Item in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_GroupUser") {
    For Key in ComObjGet("winmgmts:\\.\root\CIMV2:Win32_GroupUser").Properties_ {
        vOutput .= Key.Name . "=" . Item[Key.Name] . "`r`n"
    }
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	FileAppend,%vOutput%`n,%wmic_logname%.txt

SetTimer,StopPullingLogs_12, Off
return

StopPullingLogs_12:
FileAppend,%wmic_logname%`n, ERROR.txt
SetTimer,StopPullingLogs_12, Off
return
}
