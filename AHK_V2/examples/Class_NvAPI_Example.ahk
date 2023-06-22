; ===========================================================================================================================================================================

/*
	AutoHotkey wrapper for NVIDIA NvAPI (Example Script)

	Author ....: jNizM
	Released ..: 2014-12-29
	Modified ..: 2020-09-30
	License ...: MIT
	GitHub ....: https://github.com/jNizM/AHK_NVIDIA_NvAPI
	Forum .....: https://www.autohotkey.com/boards/viewtopic.php?t=95112
*/

; SCRIPT DIRECTIVES =========================================================================================================================================================

#Requires AutoHotkey v2.0-


; GUI =======================================================================================================================================================================

OnMessage 0x0111, EN_SETFOCUS

Main := Gui()
Main.MarginX := 10
Main.MarginY := 10

Main.SetFont("s16 w700", "Segoe UI")
Main.AddText("xm ym w270 0x201", StrReplace(GPU.GetFullName(), "NVIDIA "))
Main.SetFont("s10 w400", "Segoe UI")


Main.AddGroupBox("xm y+10 w270 h121 Section", "Clocks")
Main.AddText("xs+10 ys+25 w148 h25 0x202", "GPU Core")
MainEdt01 := Main.AddEdit("x+4 yp w60 0x802")
Main.AddText("x+4 yp w40 h25 0x200", "MHz")
Main.AddText("xs+10 y+5 w148 h25 0x202", "GPU Memory")
MainEdt02 := Main.AddEdit("x+4 yp w60 0x802")
Main.AddText("x+4 yp w40 h25 0x200", "MHz")
Main.AddText("xs+10 y+5 w148 h25 0x202", "GPU Shader")
MainEdt03 := Main.AddEdit("x+4 yp w60 0x802")
Main.AddText("x+4 yp w40 h25 0x200", "MHz")


Main.AddGroupBox("xs+0 y+20 w270 h151 Section", "Load")
Main.AddText("xs+10 ys+25 w148 h25 0x202", "GPU Core")
MainEdt04 := Main.AddEdit("x+4 yp w60 0x802")
Main.AddText("x+4 yp w40 h25 0x200", "%")
Main.AddText("xs+10 y+5 w148 h25 0x202", "GPU Memory Controller")
MainEdt05 := Main.AddEdit("x+4 yp w60 0x802")
Main.AddText("x+4 yp w40 h25 0x200", "%")
Main.AddText("xs+10 y+5 w148 h25 0x202", "GPU Video Engine")
MainEdt06 := Main.AddEdit("x+4 yp w60 0x802")
Main.AddText("x+4 yp w40 h25 0x200", "%")
Main.AddText("xs+10 y+5 w148 h25 0x202", "GPU Memory")
MainEdt07 := Main.AddEdit("x+4 yp w60 0x802")
Main.AddText("x+4 yp w40 h25 0x200", "%")


Main.AddGroupBox("xs+0 y+20 w270 h91 Section", "Fans")
Main.AddText("xs+10 ys+25 w148 h25 0x202", "GPU Fan")
MainEdt08 := Main.AddEdit("x+4 yp w60 0x802")
Main.AddText("x+4 yp w40 h25 0x200", "RPM")
Main.AddText("xs+10 y+5 w148 h25 0x202", "GPU Fan")
MainEdt09 := Main.AddEdit("x+4 yp w60 0x802")
Main.AddText("x+4 yp w40 h25 0x200", "%")


Main.AddGroupBox("xs+0 y+20 w270 h61 Section", "Temperature")
Main.AddText("xs+10 ys+25 w148 h25 0x202", "GPU Core")
MainEdt10 := Main.AddEdit("x+4 yp w60 0x802")
Main.AddText("x+4 yp w40 h25 0x200", "°C")


Main.Show()
SetTimer NVIDIA, -1000


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


NVIDIA()
{
	ClockFrequencies := GPU.GetAllClockFrequencies()
	MainEdt01.Text   := Round(ClockFrequencies["GRAPHICS"]["frequency"] / 1000, 0)
	MainEdt02.Text   := Round(ClockFrequencies["MEMORY"]["frequency"] / 1000, 0)
	MainEdt03.Text   := Round(ClockFrequencies["PROCESSOR"]["frequency"] / 1000, 0)
	PstatesInfoEx    := GPU.GetDynamicPstatesInfoEx()
	MainEdt04.Text   := PstatesInfoEx["GPU"]["percentage"]
	MainEdt05.Text   := PstatesInfoEx["FB"]["percentage"]
	MainEdt06.Text   := PstatesInfoEx["VID"]["percentage"]
	MemoryInfo       := GPU.GetMemoryInfo()
	MainEdt07.Text   := Round((MemoryInfo["dedicatedVideoMemory"] - MemoryInfo["curAvailableDedicatedVideoMemory"]) / MemoryInfo["dedicatedVideoMemory"] * 100, 2)
	MainEdt08.Text   := GPU.GetTachReading()
	MainEdt10.Text   := GPU.GetCoolerSettings()[1]["currentLevel"]
	MainEdt10.Text   := GPU.GetThermalSettings()[1]["currentTemp"]
}


; INCLUDES ==================================================================================================================================================================

#Include Class_NvAPI.ahk


; ===========================================================================================================================================================================