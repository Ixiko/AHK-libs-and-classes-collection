; Show a ToolTip with a message for a specific duration while following the mouse
;
; How it works:
; Function Tippy acts as a launcher for the "show-tip" and "hide-tip-after-duration" functions
; A global variable is used which saves The text to be showed in the tooltip
; Function TippyOn is called on a timer every 10 ms to update the tooltip position (that function also calls itself)
; To hide the tooltip the function TippyOff is called after %Duration% time which turns off the timer for TippyOn so everything is clean
;
; How to use:
; - At the top of your script include this second script:
;           #include Tippy.ahk
; - Then just call Tippy() with the text and duration you want.
;           You have an example at the end of the script!
; The tooltip is beautifully shown using ToolTipFM (a fancier tooltip -- read it's own comments).
Tippy(Text = "", Duration = 1000) {
    global TippyText := Text

    SetTimer, TippyOff, %Duration%
    SetTimer, TippyOn, 10
}

TippyOn() {
    SetTimer, TippyOn, 10
    global TippyText
    ToolTipFM(TippyText)
}

TippyOff() {
    ToolTipFM()
    SetTimer, Tippy, Off
    SetTimer, TippyOn, Off
    SetTimer, TippyOff, Off
    global TippyText := ""
}



; ToolTip which follows the mouse without flickering
; It uses MoveWindow dll call instead of recreating the ToolTip!
;
; Ref: https://autohotkey.com/board/topic/63640-tooltip-which-follows-the-mouse-is-flickering/#entry409383
ToolTipFM(Text="", WhichToolTip=16, xOffset=16, yOffset=16) { ; ToolTip which Follows the Mouse
    static LastText, hwnd, VirtualScreenWidth, VirtualScreenHeight ; http://www.autohotkey.com/forum/post-430240.html#430240

    if (VirtualScreenWidth = "" or VirtualScreenHeight = "")
    {
        SysGet, VirtualScreenWidth, 78
        SysGet, VirtualScreenHeight, 79
    }

    if (Text = "") ; destroy tooltip
    {
        ToolTip,,,, % WhichToolTip
        LastText := "", hwnd := ""
        return
    }
    else ; move or recreate tooltip
    {
        CoordMode, Mouse, Screen
        MouseGetPos, x,y
        x += xOffset, y += yOffset
        WinGetPos,,,w,h, ahk_id %hwnd%

        ; if necessary, adjust Tooltip position
        if ((x+w) > VirtualScreenWidth)
        AdjustX := 1
        if ((y+h) > VirtualScreenHeight)
        AdjustY := 1

        if (AdjustX and AdjustY)
        x := x - xOffset*2 - w, y := y - yOffset*2 - h
        else if AdjustX
        x := VirtualScreenWidth - w
        else if AdjustY
        y := VirtualScreenHeight - h

        if (Text = LastText) ; move tooltip
        DllCall("MoveWindow", A_PtrSize ? "UPTR" : "UInt",hwnd,"Int",x,"Int",y,"Int",w,"Int",h,"Int",0)
        else ; recreate tooltip
        {
            ; Perfect solution would be to update tooltip text (TTM_UPDATETIPTEXT), but must be compatible with all versions of AHK_L and AHK Basic.
            ; My Ask For Help link: http://www.autohotkey.com/forum/post-421841.html#421841
            CoordMode, ToolTip, Screen
            ToolTip,,,, % WhichToolTip ; destroy old
            ToolTip, % Text, x, y, % WhichToolTip ; show new
            hwnd := WinExist("ahk_class tooltips_class32 ahk_pid " DllCall("GetCurrentProcessId")), LastText := Text
            %A_ThisFunc%(Text, WhichToolTip, xOffset, yOffset) ; move new
        }
        Winset, AlwaysOnTop, on, ahk_id %hwnd%
    }
}