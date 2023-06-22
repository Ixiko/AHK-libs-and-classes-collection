; ===========================================================================================================================================================================

/*
	AutoHotkey wrapper for NVIDIA NVML API Example

	Author ....: jNizM
	Released ..: 2021-09-03
	Modified ..: 2021-10-11
	License ...: MIT
	GitHub ....: https://github.com/jNizM/NVIDIA_NVML
	Forum .....: https://www.autohotkey.com/boards/viewtopic.php?t=95175
*/

; SCRIPT DIRECTIVES =========================================================================================================================================================

#Requires AutoHotkey v2.0-


; GUI =======================================================================================================================================================================

OnMessage 0x0111, EN_SETFOCUS

Main := Gui()
Main.MarginX := 10
Main.MarginY := 10

Main.SetFont("s16 w700", "Segoe UI")
Main.AddText("xm ym w505 0x201", DEVICE.GetName())
Main.SetFont("s10 w400", "Segoe UI")

Main.AddText("xm y+10 w250 h25 0x200", "DEVICE.GetBrand")
Main.AddEdit("x+5 yp w300 0x800", DEVICE.GetBrand())
Main.AddText("xm y+2 w250 h25 0x200", "DEVICE.GetCount")
Main.AddEdit("x+5 yp w300 0x800", DEVICE.GetCount())
Main.AddText("xm y+2 w250 h25 0x200", "DEVICE.GetFanSpeed")
Main.AddEdit("x+5 yp w300 0x800", DEVICE.GetFanSpeed())
Main.AddText("xm y+2 w250 h25 0x200", "DEVICE.GetInforomImageVersion")
Main.AddEdit("x+5 yp w300 0x800", DEVICE.GetInforomImageVersion())
Main.AddText("xm y+2 w250 h25 0x200", "DEVICE.GetMemoryInfo - Total")
Main.AddEdit("x+5 yp w300 0x800", DEVICE.GetMemoryInfo()["Total"] / 1024**2 " GB")
Main.AddText("xm y+2 w250 h25 0x200", "DEVICE.GetMemoryInfo - Free")
Main.AddEdit("x+5 yp w300 0x800", DEVICE.GetMemoryInfo()["Free"] / 1024**2 " GB")
Main.AddText("xm y+2 w250 h25 0x200", "DEVICE.GetMemoryInfo - Used")
Main.AddEdit("x+5 yp w300 0x800", DEVICE.GetMemoryInfo()["Used"] / 1024**2 " GB")
Main.AddText("xm y+2 w250 h25 0x200", "DEVICE.GetMinorNumber")
Main.AddEdit("x+5 yp w300 0x800", DEVICE.GetMinorNumber())
Main.AddText("xm y+2 w250 h25 0x200", "DEVICE.GetPowerUsage")
Main.AddEdit("x+5 yp w300 0x800", DEVICE.GetPowerUsage())
Main.AddText("xm y+2 w250 h25 0x200", "DEVICE.GetTemperature")
Main.AddEdit("x+5 yp w300 0x800", DEVICE.GetTemperature() " °C")
Main.AddText("xm y+2 w250 h25 0x200", "DEVICE.GetUUID")
Main.AddEdit("x+5 yp w300 0x800", DEVICE.GetUUID())
Main.AddText("xm y+2 w250 h25 0x200", "DEVICE.GetUtilizationRates - GPU")
Main.AddEdit("x+5 yp w300 0x800", DEVICE.GetUtilizationRates()["GPU"] " %")
Main.AddText("xm y+2 w250 h25 0x200", "DEVICE.GetUtilizationRates - MEMORY")
Main.AddEdit("x+5 yp w300 0x800", DEVICE.GetUtilizationRates()["MEMORY"] " %")
Main.AddText("xm y+2 w250 h25 0x200", "SYSTEM.GetDriverVersion")
Main.AddEdit("x+5 yp w300 0x800", SYSTEM.GetDriverVersion())
Main.AddText("xm y+2 w250 h25 0x200", "SYSTEM.GetNVMLVersion")
Main.AddEdit("x+5 yp w300 0x800", SYSTEM.GetNVMLVersion())

Main.Show()


; FUNCTIONS =================================================================================================================================================================

EN_SETFOCUS(wParam, lParam, *)
{
	static EM_SETSEL   := 0x00B1
	static EN_SETFOCUS := 0x0100
	if ((wParam >> 16) = EN_SETFOCUS)
	{
		DllCall("user32\HideCaret", "Ptr", lParam)
		PostMessage EM_SETSEL, -1, 0,, "ahk_id " lParam
	}
}


; INCLUDES ==================================================================================================================================================================

#Include Class_NVML.ahk


; ===========================================================================================================================================================================