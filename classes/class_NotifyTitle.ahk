; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=6&t=39620
; Author:
; Date:
; for:     	AHK_V2

/*


*/

;Possible future enhancements
;  - NotifyTile.SetMonitor(<#>) - pick a different monitor than the default monitor for showing notifications
;  - NotifyTile.MultiMode(<mode>) - additional visual modes for showing 2+ tiles (e.g. cascade instead of stack)
;  - Add additional default styles?

Class NotifyTile {
    static _DefaultOps
    static _TileQueue := []

    SetOption(param1, param2 := "")
    {
        if this.HasKey("Hwnd") ;only allow calling this globally, not from a particular instance
            Throw "Calling the following methods from a NotifyTile instance is not supported: SetOption, SetModeTimeout, SetModeButton"
        NotifyTile._SetDefaultOptions()
        if !IsObject(param1)
            param1 := Object(param1, param2)
        for key, val in param1
            NotifyTile._DefaultOps[key] := val
        Return 1
    }

    SetModeTimeout(timeoutVal := 10)
    {
        this.SetOption("Time", timeoutVal)
        this.SetOption("HasButton", false)
    }

    SetModeButton(buttonTxt := "Dismiss")
    {
        this.SetOption("Time", "")
        this.SetOption("HasButton", true)
        this.SetOption("ButtonText", buttonTxt)
    }

    ModMessage(newMsg)
    {
        Return !this.MessageHwnd ? 0 : ModTextControl(this.MessageHwnd, newMsg, this.Options.FontStyle, this.Options.FontFamily)
    }

    ModTitle(newTitle)
    {
        Return !this.TitleHwnd ? 0 : ModTextControl(this.TitleHwnd, newTitle, this.Options.TitleFontStyle, this.Options.TitleFontFamily)
    }

    Discard(animate := 1)
    {
        if !this.Hwnd
            Return 0
        Critical("On")
        NotifyTile._ShiftTiles(this, 0, animate)
        Critical("Off")
        Sleep(1) ;Yield to other threads
        Return 1
    }

    GetActiveTile(idx)
    {
        if this.HasKey("Hwnd") ;only allow calling this globally, not from a particular instance
            Throw "Calling GetActiveTile from a NotifyTile instance is not supported."
        if this._TileQueue.HasKey(idx)
            Return this._TileQueue[idx]
        Return ""
    }

    DiscardAll(animate := 1) ;set animate to 0 for faster removal
    {
        if this.HasKey("Hwnd") ;only allow calling this globally, not from a particular instance
            Throw "Calling the DiscardAll method from a NotifyTile instance is not supported."
        while NotifyTile._TileQueue.HasKey(1)
            NotifyTile._TileQueue[1].Discard(animate)
        Return 1
    }

    __New(msg, title := "", options := "")
    {
        if Type(msg) != "String" || Type(title) != "String"
            Throw {"What": "NotifyTile.__New()", "Message": "Cannot create NotifyTile: msg and title parameters must be strings"}

        NotifyTile._SetDefaultOptions()

        Critical("On")

        this.Gui := GuiCreate("+AlwaysOnTop +LastFound")
        this.Hwnd := this.Gui.Hwnd
        this.WinTitle := "ahk_id " this.Gui.Hwnd

        ops := this.Options := IsObject(options) ? options.Clone() : {}
        ops.Message := msg
        this._ConfigureOptions() ;populate options and apply styles

        if ops.GuiStyle
            this.Gui.Options(ops.GuiStyle)
        this.Gui.BackColor := ops.Color
        txtAlignment := SubStr(ops.TextAlign, 1, 1) = "R" ? "Right" : SubStr(ops.TextAlign, 1, 1) = "L" ? "Left" : "Center"

        if title
        {
            this.Gui.SetFont(ops.TitleFontStyle, ops.TitleFontFamily)
            titleCtrl := this.Gui.AddText(txtAlignment " x14 y15 w" (ops.W-28) " +0x80", title)
            this.TitleHwnd := titleCtrl.Hwnd
        }

        ;calculate message height (varies if there is a Title or Button)
        msgH := ops.H - 15 - 15                      ;<win H> - <Y top margin> - <Y bottom margin>
        , msgH -= (ops.HasButton ? 25 + 10 : 0)      ; - <Bottom Button> - <Pad between Button & Msg>
        , msgH -= (title ? titleCtrl.Pos.H + 10 : 0) ; - <title H> - <pad between Title & Msg>

        if msgH < ops.MinMsgH ;expand height enough to always show at least one line of message text
            ops.H += (ops.MinMsgH - msgH), msgH := ops.MinMsgH

        msg := TrimAndEllipsizeText(msg, ops.FontStyle, ops.FontFamily, ops.W-28, msgH, trimmedH)
        txtCtrlY := (title ? "+" : "") . ((title ? 7 : 13) + (msgH - trimmedH) // 2) ;vertically center message text if there's extra room

        this.Gui.SetFont(ops.FontStyle, ops.FontFamily)
        msgCtrl := this.Gui.AddText(txtAlignment " x14 y" txtCtrlY " w" (ops.W-28) " h" msgH " +0x80", msg)
        this.MessageHwnd := msgCtrl.Hwnd

        if ops.HasButton
        {
            this.Gui.SetFont(ops.ButtonFontStyle, ops.ButtonFontFamily)
            btnCtrl := this.Gui.AddButton("x20 y" (ops.H-40) " w" (ops.W-40) " h25", ops.ButtonText)
            fn := ObjBindMethod(this, "_NotifyButton")
            btnCtrl.OnEvent("Click", fn)
            this.ButtonHwnd := btnCtrl.Hwnd
        }

        WinSetTransparent(0, this.WinTitle)
        this.Gui.Show("NA y-" (ops.H + 100)) ;show off (above) screen to avoid slight flicker where the window would appear by default.
        this.WindowShown := 1
        NotifyTile._Insert(this)
        this._ConfigureOptions() ;finish applying styles after Gui.Show
        WinHide(this.WinTitle)
        WinSetTransparent(ops.Transparency, this.WinTitle)

        this._AnimateTile(1) ;make window appear

        Critical("Off")
        Sleep(10) ;yield to other threads

        if ops.Time
        {
            fn := ObjBindMethod(this, "_NotifyTimer")
            SetTimer(fn, ops.Time * -1000)
        }
    }

    _SetDefaultOptions()
    {
        if IsObject(NotifyTile._DefaultOps)
            Return
        dOps := NotifyTile._DefaultOps := {}
        dOps.W := 350
        dOps.H := "R3"
        dOps.Color := "0xFFFFFF"
        dOps.TextAlign := "Center"
        dOps.Time := 10
        dOps.ButtonText := "Dismiss"
        dOps.FontStyle := "cBlack s10 normal"
        dOps.FontFamily := "Segoe UI"
        dOps.TitleFontStyle := "cBlack s13 bold"
        dOps.TitleFontFamily := "Segoe UI"
        dOps.MarginRight := 10
        dOps.MarginBottom := 10
        dOps.Transparency := "Off"
        dOps.AnimationOpen := "SlideRL"
        dOps.AnimationClose := "SlideLR"
        dOps.GuiStyle := "-SysMenu -Caption +Border"
    }

    _ConfigureOptions()
    {
        if !this.Hwnd
            Return 0

        ops := this.Options
        dOps := NotifyTile._DefaultOps

        if !this.WindowShown ;Preprocess
        {
            ops.Style := ops.HasKey("Style") ? ops.Style : dOps.HasKey("Style") ? dOps.Style : ""

            this._ConfigureStyle()
            ops.W                := ops.HasKey("W")                 ? ops.W
                                  : ops.HasKey("Width")             ? ops.Width             : dOps.W
            ops.H                := ops.HasKey("H")                 ? ops.H
                                  : ops.HasKey("Height")            ? ops.Height
                                  : ops.HasKey("Size")              ? ops.Size              : dOps.H
            ops.TextAlign        := ops.HasKey("TextAlign")         ? ops.TextAlign         : dOps.TextAlign
            ops.Time             := ops.HasKey("Time")              ? ops.Time              : dOps.Time
            ops.HasButton        := ops.HasKey("HasButton")         ? ops.HasButton
                                  : dOps.HasKey("HasButton")        ? dOps.HasButton        : ops.Time == ""
            ops.ButtonText       := ops.HasKey("ButtonText")        ? ops.ButtonText        : dOps.ButtonText
            ops.Color            := ops.HasKey("Color")             ? ops.Color             : dOps.Color
            ops.FontStyle        := ops.HasKey("FontStyle")         ? ops.FontStyle         : dOps.FontStyle
            ops.FontFamily       := ops.HasKey("FontFamily")        ? ops.FontFamily        : dOps.FontFamily
            ops.TitleFontStyle   := ops.HasKey("TitleFontStyle")    ? ops.TitleFontStyle    : dOps.TitleFontStyle
            ops.TitleFontFamily  := ops.HasKey("TitleFontFamily")   ? ops.TitleFontFamily   : dOps.TitleFontFamily
            ops.ButtonFontStyle  := ops.HasKey("ButtonFontStyle")   ? ops.ButtonFontStyle
                                  : dOps.HasKey("ButtonFontStyle")  ? dOps.ButtonFontStyle  : ops.FontStyle ;use FontStyle if not specified
            ops.ButtonFontFamily := ops.HasKey("ButtonFontFamily")  ? ops.ButtonFontFamily
                                  : dOps.HasKey("ButtonFontFamily") ? dOps.ButtonFontFamily : ops.FontFamily ;use FontFamily if not specified
            ops.MarginRight      := ops.HasKey("MarginRight")       ? ops.MarginRight       : dOps.MarginRight
            ops.MarginBottom     := ops.HasKey("MarginBottom")      ? ops.MarginBottom      : dOps.MarginBottom
            ops.Transparency     := ops.HasKey("Transparency")      ? ops.Transparency      : dOps.Transparency
            ops.AnimationOpen    := ops.HasKey("AnimationOpen")     ? ops.AnimationOpen     : dOps.AnimationOpen
            ops.AnimationClose   := ops.HasKey("AnimationClose")    ? ops.AnimationClose    : dOps.AnimationClose
            ops.GuiStyle         := ops.HasKey("GuiStyle")          ? ops.GuiStyle          : dOps.GuiStyle

            if (!ops.Time || ops.Time < 0) && !ops.HasButton
                Throw "Notification must have some method of being dismissed (either a button or a timeout value)"

            if ops.Message
            {
                ;allow user to specify rows (r) or lines (l) for notification height
                minLines := RegExMatch(ops.H, "^[RrLl](\d+)$", rlMatch) ? rlMatch[1] + 0 : 1
                ops.MinMsgH := GetGuiFontHeight(ops.FontStyle, ops.FontFamily, minLines)
                if ops.MinMsgH > (ops.H + 0)
                    ops.H := ops.MinMsgH ;ops.H is automatically expanded to accomodate MinMsgH + other controls during GUI generation
            }
            else
            {
                ops.H := ops.MinMsgH := 0
            }
        }
        else ;Postprocess
        {
            this._ConfigureStyle()
        }
    }

    _ConfigureStyle()
    {
        if !this.Hwnd
            Return 0
        ops := this.Options

        ;"Soft" is an example style. Other styles could be added to this function if desired.

        if !this.WindowShown
        {
            if ops.Style = "Soft" ;Example style
            {
                ops.Color := ops.HasKey("Color") ? ops.Color : "0x0288d9"
                ops.FontStyle := ops.HasKey("FontStyle") ? ops.FontStyle : "cWhite s10 normal"
                ops.TitleFontStyle := ops.HasKey("TitleFontStyle") ? ops.TitleFontStyle : "cWhite s13 bold"
                ops.GuiStyle := ops.HasKey("GuiStyle") ? ops.GuiStyle : "+ToolWindow -SysMenu -Caption"
                ops.AnimationOpen := ops.HasKey("AnimationOpen") ? ops.AnimationOpen : "Pop"
                ops.AnimationClose := ops.HasKey("AnimationClose") ? ops.AnimationClose : "Shrink"
                ops.Transparency := ops.HasKey("Transparency") ? ops.Transparency : 200
            }
        }
        else ;Postprocess (things we can only do after the GUI is finished being created
        {
            if ops.Style = "Soft"
            {
                ;the following hasn't been tested on non-standard DPIs
                WinSetRegion("0-0 w" ops.W " h" ops.H " R40-40", this.WinTitle)
            }
        }
    }

    _AnimateTile(appear := 1)
    {
        if !this.Hwnd
            Return 0
        anim := appear ? this.Options.AnimationOpen : this.Options.AnimationClose

        if SubStr(anim, 1, 5) = "Slide" ;SlideBT, SlideTB, SlideLR, or SlideRL
            Func("Win" (appear ? "Show" : "Hide") "Slide").Call(this.Hwnd, 100, SubStr(anim, 6))

        else if SubStr(anim, 1, 4) = "Roll" ;RollBT, RollTB, RollLR, or RollRL
            Func("Win" (appear ? "Show" : "Hide") "Roll").Call(this.Hwnd, 100, SubStr(anim, 5))

        else if (anim = "Pop" || anim = "Shrink")
            Func("Win" (appear ? "ShowPop" : "HideShrink")).Call(this.Hwnd)

        else ;Fade
            Func("Win" (appear ? "Show" : "Hide") "Fade").Call(this.Hwnd)
    }

    _Insert(targTile)
    {
        NotifyTile._TileQueue.Push(targTile)
        NotifyTile._ShiftTiles(targTile)
    }

    _ShiftTiles(targTile, insert := 1, animate := 1)
    {
        removePos := ""
        shouldShift := insert
        MonitorGetWorkArea("", "", "", xBoundary, yBoundary)

        oldWD := A_WinDelay
        SetWinDelay(-1) ;remove delay so that remaining tiles move downward simultaneously
        for idx, iTile in NotifyTile._TileQueue
        {
            if !shouldShift && (iTile.Hwnd == targTile.Hwnd)
            {
                shouldShift := 1
                removePos := idx
                if animate
                    iTile._AnimateTile(0)
                iTile.Gui.Destroy()
                iTile.Hwnd := iTile.Gui := iTile.TitleHwnd := iTile.MessageHwnd := iTile.ButtonHwnd := iTile.WindowShown := iTile.Options := ""
            }
            else
            {
                yPos := yBoundary - (iTile.Options.H + iTile.Options.MarginBottom)
                xPos := xBoundary - (iTile.Options.W + iTile.Options.MarginRight)
                if shouldShift
                    WinMove(xPos, yPos, iTile.Options.W, iTile.Options.H, iTile.WinTitle)
                yBoundary := yPos
            }
        }
        SetWinDelay(oldWD)
        if !insert && removePos
            NotifyTile._TileQueue.RemoveAt(removePos)
    }

    _NotifyTimer(){
        this.Discard()
    }

    _NotifyButton(){
        this.Discard()
    }
}

/* GetGuiFontHeight
|------------------
|  INPUT   Font options, style, and number of lines to measure
|  OUTPUT  The pixel height of a text control using the specified font
*/
GetGuiFontHeight(fontOps, fontStyle, numLines := 1)
{
    testText := "Test"
    Loop (numLines - 1)
        testText .= "`nTest"
    Return GetGuiCtrlSize(testText, fontOps, fontStyle, "H")
}

/* GetGuiCtrlSize
|----------------
|  INPUT   text, font options, font width, font style, and the dimension (usually "H" or "W") to retrieve
|  OUTPUT  dimension of a control with the specified parameters (only tested for Text controls)
*/
GetGuiCtrlSize(txt, fontOps, fontStyle, dimension, ctrlType := "Text", ctrlOps := "")
{
    testGui := GuiCreate()
    testGui.SetFont(fontOps, fontStyle)
    ctrlPos := testGui.Add(ctrlType, ctrlOps, txt).Pos
    ctrlDim := ctrlPos[dimension]
    testGui.Destroy()
    Return Ceil(ctrlDim * A_ScreenDPI / 96)
}

/* TrimAndEllipsizeText
|----------------------
|  Binary algorithm for trimming text to fit the Text control. (Divides string by spaces)
|
|  INPUT   text, font options, font style, Text control width, and max height to allow (most likely the target Text control's height)
|  OUTPUT  text trimmed only to what will fit in the text control, with ellipses added at the end if anything was trimmed from the end
*/
TrimAndEllipsizeText(txt, fontOps, fontStyle, ctrlW, maxH, ByRef trimH := "")
{
    trimH := GetGuiCtrlSize(txt, fontOps, fontStyle, "H", "Text", "w" ctrlW)
    StrReplace(txt, " ", " ", wdCt)
    wdCt++
    if wdCt < 2
        Return txt
    if trimH <= maxH
        Return txt

    fitString := SubStr(txt, 1, InStr(txt, " ", 1, 1) - 1) "..." ;default to only the first word (we'll always return at least this much)
    lower := 1
    upper := wdCt
    Loop
    {
        if lower >= upper
            Break
        pos := (lower + upper) // 2
        midStr := SubStr(txt, 1, InStr(txt, " ", 1, 1, pos) - 1) "..."
        h := GetGuiCtrlSize(midStr, fontOps, fontStyle, "H", "Text", "w" ctrlW)
        if h <= maxH
            lower := pos + 1, fitString := midStr, trimH := h
        else
            upper := pos - 1
    }
    Return fitString
}

/* ModTextControl
|----------------
|  Update text in a Gui Text control, ellipsizing it if it doesn't fit into the control
*/
ModTextControl(hwnd, newTxt, fontStyle, fontFamily)
{
    if !IsObject(guiCtrl := GuiCtrlFromHwnd(hwnd))
        Return 0
    guiCtrl.Text := TrimAndEllipsizeText(newTxt, fontStyle, fontFamily, guiCtrl.Pos.W, guiCtrl.Pos.H)
    Return 1
}

/* AnimateWindow Wrapper Functions
|---------------------------------
|  Fade, shrink, pop, or slide a window into or out of existence
|
|  INPUT   HWND and speed (ms) for animation
|  NOTES
|    more effects here: https://autohotkey.com/board/topic/68243-ahk-11-animatewindow-wrapper/
|    related MSDN info here: https://msdn.microsoft.com/en-us/library/windows/desktop/ms632669(v=vs.85).aspx
*/
WinShowFade(winId, speed := 200)
{
    DllCall("AnimateWindow", "UPtr", winID, "Int", speed, "UInt", 0x00080000)
}
WinHideFade(winID, speed := 200)
{
    DllCall("AnimateWindow", "UPtr", winID, "Int", speed, "UInt", 0x00080000|0x00010000)
}
WinShowPop(winID, speed := 100)
{
    DllCall("AnimateWindow", "UPtr", winID, "Int", speed, "UInt", 0x00000010)
}
WinHideShrink(winID, speed := 100)
{
    DllCall("AnimateWindow", "UPtr", winID, "Int", speed, "UInt", 0x00010000|0x00000010)
}
WinShowSlide(winId, speed := 200, dir := "LR")
{
    dirCode := dir = "RL" ? 0x00000002 : dir = "TB" ? 0x00000004 : dir = "BT" ? 0x00000008 : 0x00000001
    DllCall("AnimateWindow", "UPtr", winID, "Int", speed, "UInt", 0x00020000|0x00040000|dirCode)
}
WinHideSlide(winId, speed := 200, dir := "LR")
{
    dirCode := dir = "RL" ? 0x00000002 : dir = "TB" ? 0x00000004 : dir = "BT" ? 0x00000008 : 0x00000001
    DllCall("AnimateWindow", "UPtr", winID, "Int", speed, "UInt", 0x00010000|0x00040000|dirCode)
}
WinShowRoll(winId, speed := 200, dir := "LR")
{
    dirCode := dir = "RL" ? 0x00000002 : dir = "TB" ? 0x00000004 : dir = "BT" ? 0x00000008 : 0x00000001
    DllCall("AnimateWindow", "UPtr", winID, "Int", speed, "UInt", 0x00020000|dirCode)
}
WinHideRoll(winId, speed := 200, dir := "LR")
{
    dirCode := dir = "RL" ? 0x00000002 : dir = "TB" ? 0x00000004 : dir = "BT" ? 0x00000008 : 0x00000001
    DllCall("AnimateWindow", "UPtr", winID, "Int", speed, "UInt", 0x00010000|dirCode)
}