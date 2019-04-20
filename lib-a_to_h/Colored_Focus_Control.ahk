; GLOBAL SETTINGS ===============================================================================================================
/*
;#Warn
#NoEnv
#SingleInstance Force
SetBatchLines -1

; ===============================================================================================================================

OnExit, ExitProcess

if !(DllCall("GetModuleHandle", "Str", "gdiplus", "Ptr"))
    hModule := DllCall("LoadLibrary", "Str", "gdiplus.dll", "Ptr")
VarSetCapacity(SI, 24, 0), NumPut(1, SI, 0, "UInt")
DllCall("gdiplus.dll\GdiplusStartup", "UPtr*", pToken, "Ptr", &SI, "Ptr", 0)
if !(pToken)
{
    MsgBox % "GDIPlus could not be started!`nCheck the availability of GDIPlus on your system, please!"
    ExitApp
}

OnMessage(0x0112, "WindowState")
OnMessage(0x0111, "DrawBorder")

; GUI ===========================================================================================================================

Gui, +LastFound
WinId := WinExist()
Gui, Font, s9 cBlack, Trebuchet MS
Gui, Add, GroupBox, x7 y5 w312 h114 Section, Account Data
Gui, Font, s8 cBlack, Trebuchet MS
Gui, Add, Edit, xs+11 ys+21 w238 r1 vEmail Section
Gui, Add, Text, x+3 ys+4 w30, Email
Gui, Add, Edit, x18 y+9 w100 r1 vFirst Section
Gui, Add, Text, x+3 ys+4 w20, First
Gui, Add, Edit, x+11 ys w100 r1 vLast Section
Gui, Add, Text, x+3 ys+4 w30, Last
Gui, Add, Radio, x18 y+14 w15 h15 vMale Section Checked1
Gui, Add, Text, x+3 ys-2 w25, Male
Gui, Add, Radio, x+2 ys w15 h15 vFemale Section
Gui, Add, Text, x+2 ys-2 w30, Female
Gui, Add, DropDownList, x+16 ys-5 w126 r6 vQuestion Section, Option A||Option B|Option C|Option D
Gui, Add, Text, x+3 ys+4 w30, Option
Gui, Show,, Focused Control Border
return
*/
; FUNCTIONS =====================================================================================================================

DrawBorder(wParam, lParam, msg, hWnd) {
    global WinId
    global Last
    static Width := 1024, Height := 768, clr := 0xFF87CEFF
    if (lParam = Last)
        return
    WinSet, Redraw,, % "ahk_id " WinId
    sleep 20
    Last := lParam

    ControlGetPos, CX, CY, CW, CH,, % "ahk_id " lParam
    WinGetPos, wx, wy,,, % "ahk_id " WinId
    VarSetCapacity(POINT, 8), NumPut(CX + wx, POINT, 0, "Int"), NumPut(CY + wy, POINT, 4, "Int")
    , DllCall("user32.dll\ScreenToClient", "Ptr", hWnd, "Ptr", &POINT)
    , CX := NumGet(POINT, 0, "Int"), CY := NumGet(POINT, 4, "Int")
    , CX -= 1, CY -= 1, CW += 1, CH += 1

    , hdc := DllCall("user32.dll\GetDC", "Ptr", 0, "Ptr")
    , VarSetCapacity(BI, 40, 0)
    , NumPut(40, BI, 0, "UInt"), NumPut(Width, BI, 4, "UInt"), NumPut(Height, BI, 8, "UInt")
    , NumPut(1, BI, 12, "UShort"), NumPut(32, BI, 14, "UShort"), NumPut(0, BI, 16, "UInt")
    , hbm := DllCall("gdi32.dll\CreateDIBSection", "Ptr", hdc, "UPtr", &BI, "UInt", 0, "UPtr*", 0, "Ptr", 0, "UInt", 0, "Ptr")
    , DllCall("user32.dll\ReleaseDC", "Ptr", hWnd, "Ptr", hdc)

    , hdc := DllCall("user32.dll\GetDC", "Ptr", WinId, "Ptr")
    , obm := DllCall("gdi32.dll\SelectObject", "Ptr", hdc, "Ptr", hbm)
    , DllCall("gdiplus.dll\GdipCreateFromHDC", "Ptr", hdc, "UPtr*", pGraphics)
    , DllCall("gdiplus.dll\GdipSetSmoothingMode", "UPtr", pGraphics, "Int", 4)
    , DllCall("gdiplus.dll\GdipCreatePen1", "UInt", clr, "Float", 1, "Int", 2, "UPtr*", pPen)
    , DllCall("gdiplus.dll\GdipDrawRectangle", "UPtr", pGraphics, "UPtr", pPen, "Float", CX, "Float", CY, "Float", CW, "Float", CH)
    , DllCall("gdiplus.dll\GdipDeletePen", "UPtr", pPen)
    , DllCall("user32.dll\UpdateWindow", "Ptr", WinId)
    , DllCall("gdi32.dll\SelectObject", "Ptr", hdc, "Ptr", obm)
    , DllCall("gdi32.dll\DeleteObject", "Ptr", hbm)
    , DllCall("gdi32.dll\DeleteDC", "Ptr", hdc)
    , DllCall("gdiplus.dll\GdipDeleteGraphics", "UPtr", pGraphics)
    return True
}

WindowState(wParam, lParam, msg, hWnd)
{
    global Last
    if (lparam = 0)
        Last := ""
}

; EXIT ==========================================================================================================================

GuiClose:
ExitProcess:
if !(pToken)
    DllCall("gdiplus.dll\GdiplusShutdown", "UPtr", pToken)
if (hModule)
    DllCall("FreeLibrary", "Ptr", hModule)
ExitApp