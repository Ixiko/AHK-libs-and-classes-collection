; #Include USBD.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

; You may use a drive letter
USBD_SafelyRemove( "H:" )

; call DeviceEject() directly with a DeviceID
;USBD_DeviceEject( "USB\VID_058F&PID_6387\GDLL4HW4" )