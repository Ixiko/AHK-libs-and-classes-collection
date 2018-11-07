#Include %A_ScriptDir%\RamDrive.ahk

; If there are few commands. there is no need for RAMDISK. you can simply call the function

;MsgBox, % CMDReturn("Dir /B", "C:\")


; If there are multiple commands. use CreateRamDrive() & RemoveRamDrive() functions. Its a 3 step process. Dont forget to call RemoveRamDrive() function before the script exits

ImDiskPath:= RamDrivePath()

RamDisk:= CreateRamDrive()

MsgBox, % RamDisk

RemoveRamDrive()


ExitApp