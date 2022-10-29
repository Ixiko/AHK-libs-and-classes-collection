#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
	
	#Persistent
	SetTimer, DisplayCheck, 200
	Exit
	
	DisplayCheck() {
	WinGetActiveTitle, vTitle
	If (vTitle = "Untitled - Notepad" or vTitle = "Calculator ‎- Calculator")
		DisplayBrightness(0)
	Else
		DisplayBrightness(100)
	}
	
	DisplayBrightness(Level) 
	{	
		h := DllCall("User32.dll\MonitorFromWindow", "Ptr", 0, "UInt", 0x02, "UPtr")
		DllCall("Dxva2.dll\GetNumberOfPhysicalMonitorsFromHMONITOR", "Ptr", h, "UIntP", PhysMons, "UInt")
		VarSetCapacity(PHYS_MONITORS, (A_PtrSize + 256) * PhysMons, 0) ; PHYSICAL_MONITORS
		DllCall("Dxva2.dll\GetPhysicalMonitorsFromHMONITOR", "Ptr", h, "UInt", PhysMons, "Ptr", &PHYS_MONITORS, "UInt")
		phy := NumGet(PHYS_MONITORS, 0, "UPtr")
		DllCall("Dxva2.dll\SetMonitorBrightness", "Ptr", phy, "UInt", Level, "UInt")
		DllCall("Dxva2.dll\DestroyPhysicalMonitors", "Ptr", h, "UInt", PhysMons, "Ptr", &PHYSICAL_MONITORS, "UInt")
	} 