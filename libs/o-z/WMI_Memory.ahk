; Title:   	WMI Memory
; Link:     	https://www.autohotkey.com/boards/viewtopic.php?t=49531
; Author:	jNizm
; Date:   	2018-05-27
; for:     	AHK_L

; ===================================================================================
; AHK Version ...: AHK_L 1.1.13.00 x64 Unicode
; Win Version ...: Windows 7 Professional x64 SP1
; Description ...: Memory
; : Total, Free & Used Memory, Clear Memory
; Version .......: 2013.10.04-1456
; Author ........: jNizM
; License .......: WTFPL
; License URL ...: http://www.wtfpl.net/txt/copying/
; ===================================================================================
;@Ahk2Exe-SetName Memory
;@Ahk2Exe-SetDescription Memory
;@Ahk2Exe-SetVersion 2013.10.04-1456
;@Ahk2Exe-SetCopyright Copyright (c) 2013`, jNizM
;@Ahk2Exe-SetOrigFilename Memory.ahk

/*

; GLOBAL SETTINGS ===================================================================

#Warn
#NoEnv
#SingleInstance Force

; SCRIPT ============================================================================

love := chr(9829)

Gui, Margin, 10, 10
Gui, Font, s9, Courier New
Gui, Add, Text, xm ym w110 h23 0x200, Total Memory:
Gui, Add, Text, xm+115 ym w100 h23 0x202 vTMemory,
Gui, Add, Text, xm ym+25 w110 h23 0x200, Free Memory:
Gui, Add, Text, xm+115 ym+25 w100 h23 0x202 vFMemory,
Gui, Add, Progress, xm+220 ym+26 h20 r0-10 0x01 BackgroundC9C9C9 c5BB75E vPFMemory,
Gui, Add, Text, xm ym+50 w110 h23 0x200, Used Memory:
Gui, Add, Text, xm+115 ym+50 w100 h23 0x202 vUMemory,
Gui, Add, Progress, xm+220 ym+51 h20 r0-10 0x01 BackgroundC9C9C9 cDA4F49 vPUMemory,
Gui, Add, Text, xm ym+80 w358 0x10
Gui, Add, Text, xm ym+90 w110 h23 0x200, Cleared Memory:
Gui, Add, Text, xm+115 ym+90 w100 h23 0x202 vCMemory,
Gui, Add, Button, xm+255 ym+90 w100 h23 -Theme 0x8000 gClearMem, Clear Memory
Gui, Font, cSilver,
Gui, Add, Text, xm ym+120 w250 h21 0x200, made with %love% and AHK 2013, jNizM
Gui, Show, AutoSize, MemoryInfo v0.1

SetTimer, GetMemory, 1000
return

GetMemory:
TVMemory := Round(WMI_MEMORY(1), 2)
FPMemory := Round(WMI_MEMORY(2), 2)
UPMemory := Round(WMI_MEMORY(3), 2)

GuiControl,, TMemory, % TVMemory . " MB"
GuiControl,, FMemory, % FPMemory . " MB"
GuiControl,, UMemory, % UPMemory . " MB"

GuiControl +Range0-%TVMemory%, PFMemory
GuiControl,, PFMemory, % FPMemory
Free := % Round(FPMemory / TVMemory * 100)
if Free between 0 and 19
GuiControl, +cDA4F49, PFMemory
else if Free between 20 and 39
GuiControl, +cDA9849, PFMemory
else if Free between 40 and 69
GuiControl, +cE3E789, PFMemory
else if Free between 70 and 100
GuiControl, +c5BB75E, PFMemory

GuiControl +Range0-%TVMemory%, PUMemory
GuiControl,, PUMemory, % UPMemory
Used := % Round(UPMemory / TVMemory * 100)
if Used between 0 and 30
GuiControl, +c5BB75E, PUMemory
else if Used between 31 and 50
GuiControl, +cE3E789, PUMemory
else if Used between 51 and 80
GuiControl, +cDA9849, PUMemory
else if Used between 81 and 100
GuiControl, +cDA4F49, PUMemory
return

ClearMem:
FPMemoryA := Round(WMI_MEMORY(2), 2)
ClearMemory()
FreeMemory()
FPMemoryB := Round(WMI_MEMORY(2), 2)
GuiControl,, CMemory, % Round(FPMemoryB - FPMemoryA, 2) . " MB"
return

GuiClose:
GuiEscape:
ExitApp

*/

WMI_Memory(mem) {
	objWMIService := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")
	colItems := objWMIService.ExecQuery("Select * from Win32_OperatingSystem")._NewEnum
	while colItems[objItem] {
		return, % (mem = "1") 	? objItem.TotalVisibleMemorySize / 1024
											: (mem = "2") ? objItem.FreePhysicalMemory / 1024
											: (mem = "3") ? (objItem.TotalVisibleMemorySize - objItem.FreePhysicalMemory) / 1024
											: "FAIL"
		}
}

ClearMemory() {
	for process in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process") {
		handle := DllCall("OpenProcess", "UInt", 0x001F0FFF, "Int", 0, "Int", process.ProcessID)
	DllCall("SetProcessWorkingSetSize", "UInt", handle, "Int", -1, "Int", -1)
	DllCall("CloseHandle", "Int", handle)
	}
return
}

FreeMemory() {
return, DllCall("psapi.dll\EmptyWorkingSet", "UInt", -1)
}

