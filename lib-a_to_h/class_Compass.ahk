/*  Class_Compass
 *  By kon - ahkscript.org/boards/viewtopic.php?t=7225
 *  Translation to stand-alone Gdip thanks to jNizM - ahkscript.org/boards/viewtopic.php?&t=7225&p=45589#p45570
 *  Updated May 18, 2015
 *      Measure angles and scale distances with your mouse. Press the hotkeys and drag your mouse between two points.
 *  Note:
 *      *If you change the Measure/SetScale hotkeys, also change the keys GetKeyState monitors in the while-loop.
 *      **If you have multiple monitors, adjust the static variables w and h to match your resolution.
 *  Methods:
 *      Measure         Measure angles and scale distances with your mouse.
 *      SetScale        Sets the scale factor to use for subsequent measurements.
 *      ToggleSnap      Toggle snap to horizontal/vertical when within +/-3 degrees.
 *  Methods (Internal):
 *      SetScaleGui     Displays a GUI which prompts the user for the distance measured.
 *      pxDist          Returns the distance between two points in pixels.
 *      DecFtToArch     Converts decimal feet to architectural.
 *      gcd             Euclidean GCD.
  */

/*	 EXAMPLE
*
*	^!LButton::Compass.Measure(1)           ; Ctrl+Alt+LButton
*	^#LButton::Compass.Measure(2)           ; Ctrl+Win+LButton
*
*	;Measure a known distance. Sets the scale factor for measuring subsequent distances.
*	^!RButton::Compass.SetScale(1, 1)       ; Ctrl+Alt+RButton
*
*	; Clear the scale factor. Distance will not be calculated for subsequent measurements.
*	^#RButton::Compass.SetScale(1, 2)       ; Ctrl+Win+RButton
*
*	; Toggle snap to horizontal/vertical when within +/-3 degrees.
*	^F12::Compass.ToggleSnap()              ; Ctrl+F12
*
*
*/

class Compass {
    static Color1 := 0x55000000, Color2 := 0x990066ff, Lineweight1 := 3
    , ScaleFactor := "", Units := "ft", Snap := false
    , w := A_ScreenWidth    ;**The area in which this script is displayed, which should be your full resolution.
    , h := A_ScreenHeight

    /*  Measure
     *      Measure angles and scale distances with your mouse.
     *  Parameters:
     *      Orientation     1       Up=90, Down=-90, Left=180, Right=0
     *                      2       Up=0,  Down=180, Left=270, Right=90
     *  Returns:            The distance, in pixels, between the two points. (Used internally by the SetScale method.)
     */
    Measure(Orientation:=1) {
        Conv := 180 / (4 * ATan(1)) * (Orientation = 1 ? -1 : 1)
        if !(DllCall("kernel32.dll\GetModuleHandle", "Str", "gdiplus", "Ptr"))
            hGDIPLUS := DllCall("kernel32.dll\LoadLibrary", "Str", "gdiplus.dll", "Ptr")
        VarSetCapacity(SI, 24, 0), NumPut(1, SI, 0, "UInt")
        DllCall("gdiplus.dll\GdiplusStartup", "UPtrP", pToken, "Ptr", &SI, "Ptr", 0)
        if !(pToken) {
            MsgBox, GDIPlus could not be started.`nCheck the availability of GDIPlus on your system.
            return
        }
        CoordMode, Mouse, Screen
        MouseGetPos, StartX, StartY
        Gui, Compass: -Caption +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs
        Gui, Compass: Show, NA
        hWnd := WinExist()
        , VarSetCapacity(BI, 40, 0), NumPut(this.w, BI, 4, "UInt"), NumPut(this.h, BI, 8, "UInt"), NumPut(40, BI, 0, "UInt")
        , NumPut(1, BI, 12, "UShort"), NumPut(0, BI, 16, "UInt"), NumPut(32, BI, 14, "UShort")
        , hbm := DllCall("gdi32.dll\CreateDIBSection", "Ptr", hdc := DllCall("user32.dll\GetDC", "Ptr", 0, "Ptr"), "UPtr", &BI, "UInt", 0, "UPtr*", 0, "Ptr", 0, "UInt", 0, "Ptr")
        , DllCall("user32.dll\ReleaseDC", "Ptr", hWnd, "Ptr", hdc)
        , hdc := DllCall("gdi32.dll\CreateCompatibleDC", "Ptr", 0, "Ptr")
        , obm := DllCall("gdi32.dll\SelectObject", "Ptr", hdc, "Ptr", hbm)
        , DllCall("gdiplus.dll\GdipCreateFromHDC", "Ptr", hdc, "PtrP", G)
        , DllCall("gdiplus.dll\GdipSetSmoothingMode", "Ptr", G, "Int", 4)
        , DllCall("gdiplus.dll\GdipCreatePen1", "UInt", this.Color1, "Float", this.Lineweight1, "Int", 2, "PtrP", pPen)
        , DllCall("gdiplus.dll\GdipCreateSolidFill", "Int", this.Color2, "PtrP", pBrush)
        , MouseKey := SubStr(A_ThisHotkey, 3), PrevX := "", PrevY := ""
        , hMSVCRT := DllCall("kernel32.dll\LoadLibrary", "Str", "msvcrt.dll", "Ptr")
        while (GetKeyState("Ctrl", "P") && GetKeyState(MouseKey, "P")) {    ; *Loop until Ctrl or L/RButton is released.
            MouseGetPos, CurrentX, CurrentY
            if (PrevX != CurrentX) || (PrevY != CurrentY) {
                PrevX := CurrentX, PrevY := CurrentY
                if (this.Snap) {
                    if ((ADiff := Abs(CurrentY - StartY) / Abs(CurrentX - StartX))  < 0.052407 && ADiff)
                        CurrentY := StartY
                    else if (ADiff > 19.081136)
                        CurrentX := StartX
                }
                DllCall("gdiplus.dll\GdipDrawLine", "Ptr", G, "Ptr", pPen, "Float", StartX, "Float", StartY, "Float", CurrentX, "Float", CurrentY)
                , DllCall("gdiplus.dll\GdipFillEllipse", "Ptr", G, "Ptr", pBrush, "Float", StartX - 3, "Float", StartY - 3, "Float", 7, "Float", 7)
                , DllCall("gdiplus.dll\GdipFillEllipse", "Ptr", G, "Ptr", pBrush, "Float", CurrentX - 3, "Float", CurrentY - 3, "Float", 7, "Float", 7)
                , VarSetCapacity(PT, 8), NumPut(0, PT, 0, "UInt"), NumPut(0, PT, 4, "UInt")
                , DllCall("user32.dll\UpdateLayeredWindow", "Ptr", hWnd, "Ptr", 0, "UPtr", &PT, "Int64*", this.w | this.h << 32, "Ptr", hdc, "Int64*", 0, "UInt", 0, "UInt*", 0x1FF0000, "UInt", 2)
                , DllCall("gdiplus.dll\GdipGraphicsClear", "Ptr", G, "UInt", 0x00FFFFFF)
                , Angle := DllCall("msvcrt.dll\atan2", "Double", CurrentY - StartY, "Double", CurrentX - StartX, "CDECL Double") * Conv
                if (Orientation = 2)
                    Angle += Angle < -90 ? 450 : 90
                if (this.ScaleFactor) {
                    Dist := Format("{1:0.3f}", this.pxDist(CurrentX, StartX, CurrentY, StartY) * this.ScaleFactor)
                    if (this.Units = "ft")
                        Dist .= " ft (" . this.DecFtToArch(Dist) . ")"
                    else
                        Dist .= " " . this.Units
                }
                ToolTip, % Format("{1:0.3f}", Angle) . "°" . (Dist ? "`n" Dist : "")
            }
        }
        DllCall("kernel32.dll\FreeLibrary", "Ptr", hMSVCRT)
        , DllCall("gdiplus.dll\GdipDeletePen", "Ptr", pPen)
        , DllCall("gdiplus.dll\GdipDeleteBrush", "Ptr", pBrush)
        , DllCall("gdi32.dll\SelectObject", "Ptr", hdc, "Ptr", obm)
        , DllCall("gdi32.dll\DeleteObject", "Ptr", hbm)
        , DllCall("gdi32.dll\DeleteDC", "Ptr", hdc)
        , DllCall("gdiplus.dll\GdipDeleteGraphics", "Ptr", G)
        , DllCall("gdiplus.dll\GdiplusShutdown", "UPtr", pToken)
        , DllCall("kernel32.dll\FreeLibrary", "Ptr", hGDIPLUS)
        ToolTip
        Gui, Compass: Destroy
        return this.pxDist(CurrentX, StartX, CurrentY, StartY)
    }

    /*  SetScale
     *      Enter the known distance measured to set the scale factor to be used with all subsequent calls to Measure.
     *  Parameters:
     *      Orientation     1       Up=90, Down=-90, Left=180, Right=0
     *                      2       Up=0,  Down=180, Left=270, Right=90
     *      Action          1       The user will be prompted to enter the real world dimension corresponding to the
     *                              current measurement. Distance will be calculated for any subsequent measurements.
     *                      2       Clear the scale factor. Distance will not be calculated for subsequent measurements.
     */
    SetScale(Orientation:=1, Action:=1) {
        if (Action = 2)
            this.ScaleFactor := ""
        pxDist := this.Measure(Orientation)
        if (Action = 1)
            this.SetScaleGui(pxDist)
        return
    }

    /*  ToggleSnap
     *      Toggle snap to horizontal/vertical when within +/-3 degrees.
     */
    ToggleSnap() {
        this.Snap := !this.Snap
        TrayTip, Compass, % "Snap: " (this.Snap ? "On" : "Off")
    }

    SetScaleGui(pxLen) {
        static Text1, Text2, Text3, Edit1, Edit2, Button1
        Gui, SetScale: -Caption +Owner +LastFound
        WinID := WinExist()
        Gui, SetScale: Add, Text, vText1 x10 y10, Length
        Gui, SetScale: Add, Text, vText2 x110 y10, Units
        Gui, SetScale: Add, Edit, vEdit1 x10 y+10 w90
        GuiControlGet, Edit1, SetScale:pos, Edit1
        Gui, SetScale: Add, Edit, vEdit2 x+10 w90 y%Edit1Y%, % this.Units
        Gui, SetScale: Add, Text, vText3 x10 y+10, Enter the length of this measurement.
        Gui, SetScale: Add, Button, vButton1 x10 y+10 w190 gSetScaleOK Default, Ok
        Gui, SetScale: Show,, Set Scale
        WinSet AlwaysOnTop
        GuiControl, Focus, Edit1
        WinWaitNotActive, ahk_id %WinID%
        SetScaleGuiEscape:
        Gui, SetScale: Destroy
        return

        SetScaleOK:
        Gui, SetScale: Submit
        if Edit1 is number
            this.ScaleFactor := Edit1 / pxLen
        if (Edit2)
            this.Units := Edit2
        return
    }

    pxDist(x1, x2, y1, y2) {
        DiffX := x1 - x2, DiffY := y1 - y2
        return Sqrt(DiffX * DiffX + DiffY * DiffY)
    }

    DecFtToArch(DecFt, Precision:=16) {
        Ft := Floor(DecFt), In := 12 * Mod(DecFt, 1)
        , UpperLimit := 1 - (HalfPrecision := 0.5 / Precision)
        , Fraction := Mod(In, 1), In := Floor(In)
        if (Fraction >= UpperLimit) {
            In++, Fraction := ""
            if (In = 12)
                In := 0, Ft++
        }
        else if (Fraction < HalfPrecision)
            Fraction := ""
        else {
            Step := 1 / Precision
            loop % Precision - 1 {
                if (Fraction >= UpperLimit - (A_Index * Step)) {
                    gcd := this.gcd(Precision, n := Precision - A_Index)
                    , Fraction := " " n // gcd "/" Precision // gcd
                    break
                }
            }
        }
        return LTrim((Ft ? Ft "'-" : "") In Fraction """", " 0")
    }

    gcd(a, b) {
        while (b)
            b := Mod(a | 0x0, a := b)
        return a
    }
}