; ===============================================================================================================================
; Title .........: NvAPI GUI Classic
; AHK Version ...: 1.1.22.09 x64 Unicode
; Win Version ...: Windows 7 Ultimate 64-bit SP1
; Description ...: NvAPI GUI Classic
; Version .......: v1.02
; Modified ......: 2015.12.01-2037
; Author(s) .....: jNizM
; ===============================================================================================================================
;@Ahk2Exe-SetName NvAPI GUI Classic
;@Ahk2Exe-SetDescription NvAPI GUI Classic
;@Ahk2Exe-SetVersion v1.02
;@Ahk2Exe-SetCopyright Copyright (c) 2014-2015`, jNizM
;@Ahk2Exe-SetOrigFilename Class_NvAPI_GUI_Classic.ahk
; ===============================================================================================================================

; GLOBAL SETTINGS ===============================================================================================================

;#Warn
#NoEnv
#SingleInstance Force
SetBatchLines -1

#Include Class_NvAPI.ahk

; GUI ===========================================================================================================================

OnMessage(0x0111, "ON_EN_SETFOCUS")    ; WM_COMMAND := 0x0111
Gui, Margin, 4, 4

Gui, Font, s16 w800 q4, MS Shell Dlg 2
Gui, Add, Text, xm ym w240 0x201, % NvAPI.GPU_GetFullName()

Gui, Font, s9 w400 q1 c000000, MS Shell Dlg 2
Gui, Add, GroupBox, xm y+8 w241 h100, % "Clocks"
Gui, Add, GroupBox, xm y+5  w241 h123, % "Load"
Gui, Add, GroupBox, xm y+5  w241 h77, % "Fans"
Gui, Add, GroupBox, xm y+5  w241 h51, % "Temperature"


Gui, Add, Text, xm+4 ym+53 w130 h20 0x0202, % "GPU Core"
Gui, Add, Edit, x+5  yp    w60  h20 0x0A02 vNvC1
Gui, Add, Text, x+3  yp    w30  h20 0x0200, % "MHz"

Gui, Add, Text, xm+4 y+4 w130 h20 0x0202, % "GPU Memory"
Gui, Add, Edit, x+5  yp  w60  h20 0x0A02 vNvC2
Gui, Add, Text, x+3  yp  w30  h20 0x0200, % "MHz"

Gui, Add, Text, xm+4 y+4 w130 h20 0x0202, % "GPU Shader"
Gui, Add, Edit, x+5  yp  w60  h20 0x0A02 vNvC3
Gui, Add, Text, x+3  yp  w30  h20 0x0200, % "MHz"


Gui, Add, Text, xm+4 y+37 w130 h20 0x0202, % "GPU Core"
Gui, Add, Edit, x+5  yp   w60  h20 0x0A02 vNvL1
Gui, Add, Text, x+3  yp   w30  h20 0x0200, % "%"

Gui, Add, Text, xm+4 y+4 w130 h20 0x0202, % "GPU Memory Controller"
Gui, Add, Edit, x+5  yp  w60  h20 0x0A02 vNvL2
Gui, Add, Text, x+3  yp  w30  h20 0x0200, % "%"

Gui, Add, Text, xm+4 y+4 w130 h20 0x0202, % "GPU Video Engine"
Gui, Add, Edit, x+5  yp  w60  h20 0x0A02 vNvL3
Gui, Add, Text, x+3  yp  w30  h20 0x0200, % "%"

Gui, Add, Text, xm+4 y+4 w130 h20 0x0202, % "GPU Memory"
Gui, Add, Edit, x+5  yp  w60  h20 0x0A02 vNvL4
Gui, Add, Text, x+3  yp  w30  h20 0x0200, % "%"


Gui, Add, Text, xm+4 y+37 w130 h20 0x0202, % "GPU Fan"
Gui, Add, Edit, x+5  yp   w60  h20 0x0A02 vNvF1
Gui, Add, Text, x+3  yp   w30  h20 0x0200, % "RPM"

Gui, Add, Text, xm+4 y+4 w130 h20 0x0202, % "GPU Fan"
Gui, Add, Edit, x+5  yp  w60  h20 0x0A02 vNvF2
Gui, Add, Text, x+3  yp  w30  h20 0x0200, % "%"


Gui, Add, Text, xm+4 y+37 w130 h20 0x0202, % "GPU Core"
Gui, Add, Edit, x+5  yp   w60  h20 0x0A02 vNvT1
Gui, Add, Text, x+3  yp   w30  h20 0x0200, % "°C"

Gui, Show, AutoSize
SetTimer, NvAPI_NEW, 2000
return

; UPDATE ========================================================================================================================

NvAPI_NEW:
    GuiControl,, NvC1, % Round(NvAPI.GPU_GetAllClockFrequencies().GRAPHICS.frequency / 1000, 0)
    GuiControl,, NvC2, % Round(NvAPI.GPU_GetAllClockFrequencies().MEMORY.frequency / 1000, 0)
    GuiControl,, NvC3, % Round(NvAPI.GPU_GetAllClockFrequencies().PROCESSOR.frequency / 1000, 0)

    GuiControl,, NvL1, % NvAPI.GPU_GetDynamicPstatesInfoEx().GPU.percentage
    GuiControl,, NvL2, % NvAPI.GPU_GetDynamicPstatesInfoEx().FB.percentage
    GuiControl,, NvL3, % NvAPI.GPU_GetDynamicPstatesInfoEx().VID.percentage
    GuiControl,, NvL4, % Round((NvAPI.GPU_GetMemoryInfo().dedicatedVideoMemory - NvAPI.GPU_GetMemoryInfo().curAvailableDedicatedVideoMemory) / NvAPI.GPU_GetMemoryInfo().dedicatedVideoMemory * 100, 2)

    GuiControl,, NvF1, % NvAPI.GPU_GetTachReading()
    GuiControl,, NvF2, % NvAPI.GPU_GetCoolerSettings().1.currentLevel

    GuiControl,, NvT1, % NvAPI.GPU_GetThermalSettings().1.currentTemp
return

; FUNCTIONS =====================================================================================================================

ON_EN_SETFOCUS(wParam, lParam)
{
    static EM_SETSEL   := 0x00B1
    static EN_SETFOCUS := 0x0100
    Critical
    if ((wParam >> 16) = EN_SETFOCUS)
    {
        DllCall("user32.dll\HideCaret", "Ptr", lParam)
        DllCall("user32.dll\PostMessage", "Ptr", lParam, "UInt", EM_SETSEL, "Ptr", -1, "Ptr" , 0)
    }
}

; EXIT ==========================================================================================================================

GuiClose:
GuiEscape:
ExitApp