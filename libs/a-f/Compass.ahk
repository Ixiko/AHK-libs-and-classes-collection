^!LButton::Compass(1)   ; Ctrl+Alt+LButton
^+LButton::Compass(2)   ; Ctrl+Shift+LButton


/*  Compass
 *  by kon - http://ahkscript.org/boards/viewtopic.php?f=6&t=7225
 *      Measure angles with your mouse. Press the hotkeys and drag your mouse between two points.
 *      If you change the hotkeys, also change the keys GetKeyState monitors in the while-loop.
 *      If you have multiple monitors, adjust the static variables w and h to match your resolution.
 *  Parameters
 *      Orientation     1       Up=90, Down=-90, Left=180, Right=0
 *                      2       Up=0,  Down=180, Left=270, Right=90
 *  Requires
 *      Gdip.ahk        In your Lib folder or #Included. Thanks to tic (Tariq Porter) for his GDI+ Library
 *                      ahkscript.org/boards/viewtopic.php?t=6517
 */
Compass(Orientation:=1) {
    static Color1 := 0x55000000, Color2 := 0x990066ff, Lineweight1 := 3
    , w := A_ScreenWidth, h := A_ScreenHeight
    Conv := 180 / (4 * ATan(1)) * (Orientation = 1 ? -1 : 1)
    if (!pToken := Gdip_Startup()) {
        MsgBox, 48, Gdiplus error!, Gdiplus failed to start. Please ensure you have Gdiplus on your system.
        return
    }
    CoordMode, Mouse, Screen
    SetFormat, FloatFast, 0.3
    Gui, Compass: -Caption +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs
    Gui, Compass: Show, NA
    hwnd1 := WinExist(), hbm := CreateDIBSection(w, h)
    hdc := CreateCompatibleDC(), obm := SelectObject(hdc, hbm)
    G1 := Gdip_GraphicsFromHDC(hdc), Gdip_SetSmoothingMode(G1, 4)
    pPen1 := Gdip_CreatePen(Color1, Lineweight1)
    pBrush1 := Gdip_BrushCreateSolid(Color2)
    MouseGetPos, StartX, StartY
    PrevX := "", PrevY := ""
    hModule := DllCall("LoadLibrary", "Str", "msvcrt.dll", "Ptr")  
    while (GetKeyState("Ctrl", "P") && GetKeyState("LButton", "P")) {   ; Loop until Ctrl or LButton is released.
        MouseGetPos, CurrentX, CurrentY
        if (PrevX != CurrentX || PrevY != CurrentY) {
            PrevX := CurrentX, PrevY := CurrentY
            Gdip_DrawLine(G1, pPen1, StartX, StartY, CurrentX, CurrentY)
            Gdip_FillEllipse(G1, pBrush1, StartX-3, StartY-3, 6, 6)
            Gdip_FillEllipse(G1, pBrush1, CurrentX-3, CurrentY-3, 6, 6)
            UpdateLayeredWindow(hwnd1, hdc, 0, 0, w, h)
            Gdip_GraphicsClear(G1)
            Angle := DllCall("msvcrt\atan2", "Double",CurrentY-StartY, "Double",CurrentX-StartX, "CDECL Double") * Conv
            if (Orientation = 2)
                Angle += Angle < -90 ? 450 : 90
            ToolTip, % Angle
        }
    }
    DllCall("FreeLibrary", "Ptr", hModule)
    UpdateLayeredWindow(hwnd1, hdc, 0, 0, w, h)
    Gdip_DeletePen(pPen1), Gdip_DeleteBrush(pBrush1)
    SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc)
    Gdip_DeleteGraphics(G1), Gdip_Shutdown(pToken)
    ToolTip
    Gui, Compass: Destroy
    return
}