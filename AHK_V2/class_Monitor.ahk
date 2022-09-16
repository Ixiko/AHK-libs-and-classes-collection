class Monitor {

	static SetBrightness(value:="+0") {
		isOffset := RegExMatch(value, "^[\+\-]")
		hMonitor := this.MonitorFromWindow(WinExist("A")), PHYSICAL_MONITOR := 0
		PhysicalMonitors := this.GetNumberOfPhysicalMonitorsFromHMONITOR(hMonitor)
		hPhysicalMonitor := this.GetPhysicalMonitorsFromHMONITOR(hMonitor, PhysicalMonitors, &PHYSICAL_MONITOR)
		GetBrightness    := this.GetMonitorBrightness(hPhysicalMonitor)
		Brightness := Max(Min(GetBrightness["Current"] * isOffset + value, GetBrightness["Maximum"]), GetBrightness["Minimum"])
		this.SetMonitorBrightness(hPhysicalMonitor, Brightness)
		this.DestroyPhysicalMonitors(PhysicalMonitors, &PHYSICAL_MONITOR)
		return Map("Minimum", GetBrightness["Minimum"], "Current", Brightness, "Maximum", GetBrightness["Maximum"])
	}

	static SetContrast(value:="+0") {
		isOffset := RegExMatch(value, "^[\+\-]")
		hMonitor := this.MonitorFromWindow(WinExist("A")), PHYSICAL_MONITOR := 0
		PhysicalMonitors := this.GetNumberOfPhysicalMonitorsFromHMONITOR(hMonitor)
		hPhysicalMonitor := this.GetPhysicalMonitorsFromHMONITOR(hMonitor, PhysicalMonitors, &PHYSICAL_MONITOR)
		GetContrast      := this.GetMonitorContrast(hPhysicalMonitor)
		Contrast := Max(Min(GetContrast["Current"] * isOffset + value, GetContrast["Maximum"]), GetContrast["Minimum"])
		this.SetMonitorContrast(hPhysicalMonitor, Contrast)
		this.DestroyPhysicalMonitors(PhysicalMonitors, &PHYSICAL_MONITOR)
		return Map("Minimum", GetContrast["Minimum"], "Current", Contrast, "Maximum", GetContrast["Maximum"])
	}

	static GetNumberOfPhysicalMonitorsFromHMONITOR(hMonitor) {
		NumberOfPhysicalMonitors := 0
		DllCall("dxva2\GetNumberOfPhysicalMonitorsFromHMONITOR", "ptr", hMonitor, "uint*", &NumberOfPhysicalMonitors)
		return NumberOfPhysicalMonitors
	}

	static GetPhysicalMonitorsFromHMONITOR(hMonitor, PhysicalMonitors, &PHYSICAL_MONITOR) {
		PHYSICAL_MONITOR := Buffer((A_PtrSize + 256) * PhysicalMonitors, 0)
		DllCall("dxva2\GetPhysicalMonitorsFromHMONITOR", "Ptr", hMonitor, "UInt", PhysicalMonitors, "Ptr", PHYSICAL_MONITOR.Ptr)
		return NumGet(PHYSICAL_MONITOR, 0, "Ptr")
	}

	static GetMonitorBrightness(hPhysicalMonitor) {
		Minimum := Current := Maximum := 0
		DllCall("dxva2\GetMonitorBrightness", "Ptr", hPhysicalMonitor, "UInt*", &Minimum, "UInt*", &Current, "UInt*", &Maximum)
		return Map("Minimum", Minimum, "Current", Current, "Maximum", Maximum)
	}

	static GetMonitorContrast(hPhysicalMonitor) {
		Minimum := Current := Maximum := 0
		DllCall("dxva2\GetMonitorContrast", "Ptr", hPhysicalMonitor, "UInt*", &Minimum, "UInt*", &Current, "UInt*", &Maximum)
		return Map("Minimum", Minimum, "Current", Current, "Maximum", Maximum)
	}

	static MonitorFromWindow(hWindow:=0)								=> DllCall("user32\MonitorFromWindow", "Ptr", hWindow, "UInt", 1)

	static SetMonitorBrightness(hPhysicalMonitor, Brightness)			=> DllCall("dxva2\SetMonitorBrightness", "Ptr", hPhysicalMonitor, "UInt", Brightness)

	static SetMonitorContrast(hPhysicalMonitor, Contrast)				=> DllCall("dxva2\SetMonitorContrast", "Ptr", hPhysicalMonitor, "UInt", Contrast)

	static DestroyPhysicalMonitors(PhysicalMonitors, &PHYSICAL_MONITOR)	=> DllCall("dxva2\DestroyPhysicalMonitors", "UInt", PhysicalMonitors, "Ptr", PHYSICAL_MONITOR.Ptr)

}
