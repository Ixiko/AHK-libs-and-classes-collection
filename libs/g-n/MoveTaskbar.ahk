; Move the taskbar
; dspNumber:    number.  device number (primary display is 1, secondary display is 2...)
; edge:         string.  Top, Right, Bottom, or Left
MoveTaskbar(dspNumber, edge)
{
    Critical 
    OutputDebug MoveTaskbar - called to move taskbar to display #%dspNumber% ("%edge%" edge)

    ; absolute coordinate system
    CoordMode, Mouse, Screen

    ; error checking for dspNumber
    SysGet, numMonitors, MonitorCount
    if (numMonitors<dspNumber)
    {
        OutputDebug MoveTaskbar - [ERROR] target monitor does not exist (dspNumber = "%dspNumber%")
        return
    }

    ; get screen position for target monitor
    SysGet, target, Monitor, %dspNumber%

    oX := 7
    oY := 7

    ; get coordinates for where to move the taskbar
    if (edge = "Top")
    {
        oX := (targetRight-targetLeft)/2
        trgX := oX+targetLeft
        trgY := targetTop+15
    }
    else if (edge = "Right")
    {
        oY := -(targetBottom-targetTop)/2
        trgX := targetRight-15
        trgY := -oY + targetTop
    }
    else if (edge = "Bottom")
    {
        oX := -(targetRight-targetLeft)/2
        trgX := -oX+targetLeft
        trgY := targetBottom-15
    }
    else if (edge = "Left")
    {
        oY := (targetBottom-targetTop)/2
        trgX := targetLeft+15
        trgY := oY+targetTop
    }
    else
    {
        OutputDebug MoveTaskbar - [ERROR] target edge was improperly specified (edge = "%edge%")
        return
    }
    trgX := round(trgX)
    trgY := round(trgY)
    oX := round(oX)
    oY := round(oY)

    OutputDebug MoveTaskbar - target location is (%trgX%,%trgY%)
    MouseGetPos, startX, startY
    OutputDebug MoveTaskbar - mouse is currently at (%startX%,%startY%)

    ; request the move mode (via context menu)
    SendInput #b
    SendInput !+{Space}
    SendInput m

    ; wait for the move mode to be ready
    Loop 
    {
        if A_Cursor = SizeAll
            break
    }
    OutputDebug MoveTaskbar - move mode is ready

    ; start the move mode
    SendInput {Right}   

    ; wait for the move mode to become active for mouse control
    Loop 
    {
        if A_Cursor = Arrow
            break
    }
    OutputDebug MoveTaskbar - move mode is active for mouse control

    ; move taskbar (and making sure it actually does move)
    offset := 7
    count := 0
    Loop
    {
        ; move the taskbar to the desired location
        OutputDebug MoveTaskbar - attempting to move mouse to (%trgX%,%trgY%)
        MouseMove, %trgX%, %trgY%, 0
        MouseGetPos, mX, mY, win_id
        WinGetClass, win_class, ahk_id %win_id%

        count += 1

        ; if the mouse didn't get where it was supposed to, try again
        If ((mX != trgX) or (mY != trgY))
        {
            OutputDebug MoveTaskbar - mouse didn't get to its destination (currently at (%mX%,%mY%)).  Trying the move again...
            continue
        }

        ; if the taskbar hasn't followed yet, wiggle the mouse!
        if (win_class != "Shell_TrayWnd")
        {
            OutputDebug MoveTaskbar - window with class "%win_class%" is under the mouse... wiggling the mouse until the taskbar gets over here

            ;offset := - offset
            trgX -= round(oX/2)
            trgY -= round(oY/2)
            oX := -oX
            oY := -oY
            if count = 50
            {
                OutputDebug, MoveTaskbar - wiggling isn't working, so I'm giving up.
                return
            }
        }
        else
            break
    }

    OutputDebug MoveTaskbar - taskbar successfully moved
    SendInput {Enter}
}