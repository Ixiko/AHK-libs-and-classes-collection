#SingleInstance, force
#NoEnv
#include ..\..\include\ahk\overlay.ahk

text_overlay :=- 1

; Set the overlay's parameters
SetParam("use_window", "1")
SetParam("window", "GTA:SA:MP")

; Create GUI
Gui, Add, Text, x12 y10 w200 h30 , Health Overlay powered by`nhttp://www.overlay-api.net/
Gui, Show, w237 h52, Health-Overlay

SetTimer, Timer, 50
return

; Delete the overlay if the application will be closed by the user
GuiClose:
if(text_overlay != -1)
	TextDestroy(text_overlay)
ExitApp

; Timer callback
Timer:
if(text_overlay == -1)
	text_overlay := TextCreate("Arial", 6, false, false, 720, 91, 0xFFFFFFFF, "100", true, true)

if(text_overlay == -1)
	return

Obj := ReadDword(0xB6F5F0, "GTA:SA:MP", success)
if(!success)
	return

health := ReadFloat(Obj + 0x540, "GTA:SA:MP", success)
if(!success)
	return

StringTrimRight, health, health, 7

if(TextSetString(text_overlay, health) == 0)
{
	TextDestroy(text_overlay)
	text_overlay := -1
}
return

ReadDword(dwAddr, szProcess, ByRef bSuccess)
{
	bSuccess := false

	VarSetCapacity(dwValue, 4, 0)
	
	WinGet, pid, pid, %szProcess%

	hHandle := DllCall("OpenProcess" ,"Int",2035711,"Int",0,"UInt",pid)
	if(hHandle <= 0)
		return 0

	if(!DllCall("ReadProcessMemory", "UInt", hHandle, "UInt", dwAddr, "UInt", &dwValue, "UInt", 4, "UInt *", 0))
		return 0

	DllCall("CloseHandle", "UInt", hHandle)
	bSuccess := true

	Loop 4
	result += *(&dwValue + A_Index-1) << 8*(A_Index-1)
	
	return result
}

ReadFloat(dwAddr, szProcess, byref bSuccess)
{	
	bSuccess := false
	
	VarSetCapacity(fValue,4,0)

	WinGet, pid, pid, %szProcess%
	  
	hHandle := DllCall("OpenProcess" ,"Int",2035711,"Int",0,"UInt",pid)
	if(hHandle <= 0)
		return 0

	if(!DllCall("ReadProcessMemory", "UInt", hHandle, "UInt", dwAddr, "Str", fValue, "UInt", 4, "UInt *", 0))
		return 0
	
   fValue := *(&fValue+3)<<24 | *(&fValue+2)<<16 | *(&fValue+1)<<8 | *(&fValue)
   
   DllCall("CloseHandle", "UInt", hHandle)
   bSuccess := true
   
   return (1-2*(fValue>>31)) * (2**((fValue>>23 & 255)-127)) * (1+(fValue & 8388607)/8388608)
}