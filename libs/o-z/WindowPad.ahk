
WindowPad_Init(WINDOWPAD_INI_PATH)

; WindowPad v1.52
;
; Credits:
;   Concept based on HiRes Screen Splitter by JOnGliko.
;   Written from scratch by Lexikos to support multiple monitors.
;   NumpadDot key functionality suggested by bobbo.
;
; Built with AutoHotkey v1.0.47
;
WindowPad_Init(IniPath="")
{
    global WINDOWPAD_INI_PATH
;     if A_IsCompiled  ; Load icons from my custom WindowPad.exe.
;     {
;         ; Default icon is 32x32, so doesn't look good in the tray.
;         Menu, TRAY, Icon, %A_ScriptFullPath%, 11
;     }
;     else
    if (A_LineFile = A_ScriptFullPath)
    {   ; Set the tray icon, but only if not included in some other script.
        WindowPad_SetTrayIcon(true)
        ; Use OnMessage to catch "Suspend Hotkeys" or "Pause Script"
        ; so the "disabled" icon can be used.
        OnMessage(0x111, "WM_COMMAND")
    }
    
    if IniPath =
        IniPath = %A_LineFile%\..\WindowPad.ini
        ;IniPath = %A_ScriptDir%\WindowPad.ini
	

	WINDOWPAD_INI_PATH := IniPath
    WindowPad_LoadSettings(IniPath)
}

WindowPad_LoadSettings(ininame)
{
    local v
    
    ; Misc Options
    IniRead, v, %ininame%, Options, TitleMatchMode, %A_TitleMatchMode%
    SetTitleMatchMode, %v%
    
    ; Hotkeys: Exclude Windows
    v := WindowPad_INI_GetList(ininame, "Exclude Windows", "Window")
    Loop, Parse, v, `n
        GroupAdd, HotkeyExclude, %A_LoopField%
    
    ; Read the Hotkeys section in.
    v := WindowPad_INI_ReadSection(ininame, "Hotkeys")
    ; Replace the first = with ::.
    ; ('=' is required for WritePrivateProfileSection to work properly.)
    v := RegExReplace(v, "m`a)^(.*?)=", "$1::")
    Hotkey, IfWinNotActive, ahk_group HotkeyExclude
    Hotkey_Params(v)
    
    ; Gather: Exclude Windows
    v := WindowPad_INI_GetList(ininame, "Gather: Exclude Windows", "Window")
    Loop, Parse, v, `n
        GroupAdd, GatherExclude, %A_LoopField%

    ; Gather: Exclude Processes
    ProcessGatherExcludeList := WindowPad_INI_GetList(ininame
        , "Gather: Exclude Processes", "Process", ",")
}

WindowPad_INI_GetList(ininame, Section, Key, Delim="`n")
{
    v := WindowPad_INI_ReadSection(ininame, Section)
    Loop, Parse, v, `n
    {
        pos := InStr(A_LoopField, "=")
        if (pos && SubStr(A_LoopField,1,pos-1) = Key)
            list .= (list ? Delim : "") . SubStr(A_LoopField, pos+1)
    }
    return list
}

WindowPad_INI_ReadSection(Filename, Section)
{
    ; Expand relative paths, since GetPrivateProfileSection only searches %A_WinDir%.
    Loop, %Filename%, 0
        Filename := A_LoopFileLongPath
    
    VarSetCapacity(text, 0x7FFF, 0)

    len := DllCall("GetPrivateProfileSection"
        , "str", Section, "str", text, "uint", 0x7FFF, "str", Filename)
    
    ; Each line within the section is terminated with a null character.
    ; Replace each delimiting null char with a newline:
    Loop, % len-1						;%;%
        if (NumGet(text, A_Index-1, "UChar") = 0)
            NumPut(10, text, A_Index-1, "UChar")  ; \0 -> \n

    ; Windows Me/98/95:
    ;   The returned string includes comments.
    ;
    ; This removes comments. Also, I'm not sure if leading/trailing space is
    ; automatically removed on Win9x, so the regex removes that too.
    if A_OSVersion in WIN_ME,WIN_98,WIN_95
        text := RegExReplace(text, "m`n)^[ `t]*(?:;.*`n?|`n)|^[ `t]+|[ `t]+$")
    
    return text
}


WindowPadMove(P)
{
    StringSplit, P, P, `,, %A_Space%%A_Tab%
    ; Params: 1:dirX, 2:dirY, 3:widthFactor, 4:heightFactor, 5:window

    ; dirX and dirY are required.    
    if P1 is not number
        return
    if P2 is not number
        return
    
    WindowPad_WinExist(P5)

    if !WinExist()
        return

    ; Determine width/height factors.
    if (P1 or P2) {     ; to a side
        widthFactor  := P3+0 ? P3 : (P1 ? 0.5 : 1.0)
        heightFactor := P4+0 ? P4 : (P2 ? 0.5 : 1.0)
    } else {            ; to center
        widthFactor  := P3+0 ? P3 : 1.0
        heightFactor := P4+0 ? P4 : 1.0
    }
    
    ; Move the window!
    MoveWindowInDirection(P1, P2, widthFactor, heightFactor)
}
return

MaximizeToggle(P)
{
    WindowPad_WinExist(P)
    
    WinGet, state, MinMax
    if state
        WinRestore
    else
        WinMaximize
}

; Does the grunt work of the script.
MoveWindowInDirection(sideX, sideY, widthFactor, heightFactor)
{
    WinGetPos, x, y, w, h
    
    ; Determine which monitor contains the center of the window.
    m := GetMonitorAt(x+w/2, y+h/2)
    
    ; Get work area of active monitor.
    gosub CalcMonitorStats
    ; Calculate possible new position for window.
    gosub CalcNewPosition

    ; If the window is already there,
    if (newx "," newy "," neww "," newh) = (x "," y "," w "," h)
    {   ; ..move to the next monitor along instead.
    
        if (sideX or sideY)
        {   ; Move in the direction of sideX or sideY.
            SysGet, monB, Monitor, %m% ; get bounds of entire monitor (vs. work area)
            x := (sideX=0) ? (x+w/2) : (sideX>0 ? monBRight : monBLeft) + sideX
            y := (sideY=0) ? (y+h/2) : (sideY>0 ? monBBottom : monBTop) + sideY
            newm := GetMonitorAt(x, y, m)
        }
        else
        {   ; Move to center (Numpad5)
            newm := m+1
            SysGet, mon, MonitorCount
            if (newm > mon)
                newm := 1
        }
    
        if (newm != m)
        {   m := newm
            ; Move to opposite side of monitor (left of a monitor is another monitor's right edge)
            sideX *= -1
            sideY *= -1
            ; Get new monitor's work area.
            gosub CalcMonitorStats
        }
        ; Calculate new position for window.
        gosub CalcNewPosition
    }

    ; Restore before resizing...
    WinGet, state, MinMax
    if state
        WinRestore

    ; Finally, move the window!
    SetWinDelay, 0
    WinMove,,, newx, newy, neww, newh
    
    return

CalcNewPosition:
    ; Calculate new size.
    if (IsResizable()) {
        neww := Round(monWidth * widthFactor)
        newh := Round(monHeight * heightFactor)
    } else {
        neww := w
        newh := h
    }
    ; Calculate new position.
    newx := Round(monLeft + (sideX+1) * (monWidth  - neww)/2)
    newy := Round(monTop  + (sideY+1) * (monHeight - newh)/2)
    return

CalcMonitorStats:
    ; Get work area (excludes taskbar-reserved space.)
    SysGet, mon, MonitorWorkArea, %m%
    monWidth  := monRight - monLeft
    monHeight := monBottom - monTop
    return
}

; Get the index of the monitor containing the specified x and y co-ordinates.
GetMonitorAt(x, y, default=1)
{
    SysGet, m, MonitorCount
    ; Iterate through all monitors.
    Loop, %m%
    {   ; Check if the window is on this monitor.
        SysGet, Mon, Monitor, %A_Index%
        if (x >= MonLeft && x <= MonRight && y >= MonTop && y <= MonBottom)
            return A_Index
    }

    return default
}

IsResizable()
{
    WinGet, Style, Style
    return (Style & 0x40000) ; WS_SIZEBOX
}

WindowPad_WinExist(WinTitle)
{
    if WinTitle = P
        return WinPreviouslyActive()
    if WinTitle = M
    {
        MouseGetPos,,, win
        return WinExist("ahk_id " win)
    }
    return WinExist(WinTitle!="" ? WinTitle : "A")
}

; Note: This may not work properly with always-on-top windows. (Needs testing)
WinPreviouslyActive()
{
    active := WinActive("A")
    WinGet, win, List

    ; Find the active window.
    ; (Might not be win1 if there are always-on-top windows?)
    Loop, %win%
        if (win%A_Index% = active)
        {
            if (A_Index < win)
                N := A_Index+1
            
            ; hack for PSPad: +1 seems to get the document (child!) window, so do +2
            ifWinActive, ahk_class TfPSPad
                N += 1
            
            break
        }

    ; Use WinExist to set Last Found Window (for consistency with WinActive())
    return WinExist("ahk_id " . win%N%)
}


;
; Switch without moving/resizing (relative to screen)
;
WindowScreenMove(P)
{
    SetWinDelay, 0
    
    StringSplit, P, P, `,, %A_Space%%A_Tab%
    ; 1:Next|Prev|Num, 2:Window
    
    WindowPad_WinExist(P2)

    WinGet, state, MinMax
    if state = 1
        WinRestore

    WinGetPos, x, y, w, h
    
    ; Determine which monitor contains the center of the window.
    ms := GetMonitorAt(x+w/2, y+h/2)
    
    SysGet, mc, MonitorCount

    ; Determine which monitor to move to.
    if P1 in ,N,Next
    {
        md := ms+1
        if (md > mc)
            md := 1
    }
    else if P1 in P,Prev,Previous
    {
        md := ms-1
        if (md < 1)
            md := mc
    }
    else if P1 is integer
        md := P1
    
    if (md=ms or (md+0)="" or md<1 or md>mc)
        return
    
    ; Get source and destination work areas (excludes taskbar-reserved space.)
    SysGet, ms, MonitorWorkArea, %ms%
    SysGet, md, MonitorWorkArea, %md%
    msw := msRight - msLeft, msh := msBottom - msTop
    mdw := mdRight - mdLeft, mdh := mdBottom - mdTop
    
    ; Calculate new size.
    if (IsResizable()) {
        w *= (mdw/msw)
        h *= (mdh/msh)
    }
    
    ; Move window, using resolution difference to scale co-ordinates.
    WinMove,,, mdLeft + (x-msLeft)*(mdw/msw), mdTop + (y-msTop)*(mdh/msh), w, h

    if state = 1
        WinMaximize
}


;
; "Gather" windows on a specific screen.
;
GatherWindows(md=1)
{
    global ProcessGatherExcludeList
    
    SetWinDelay, 0
    
    ; List all visible windows.
    WinGet, win, List
    
    ; Copy bounds of all monitors to an array.
    SysGet, mc, MonitorCount
    Loop, %mc%
        SysGet, mon%A_Index%, MonitorWorkArea, %A_Index%
    
    if md = M
    {   ; Special exception for 'M', since the desktop window
        ; spreads across all screens.
        CoordMode, Mouse, Screen
        MouseGetPos, x, y
        md := GetMonitorAt(x, y, 0)
    }
    else if md is not integer
    {   ; Support A, P and WinTitle.
        ; (Gather at screen containing specified window.)
        WindowPad_WinExist(md)
        WinGetPos, x, y, w, h
        md := GetMonitorAt(x+w/2, y+h/2, 0)
    }
    if (md<1 or md>mc)
        return
    
    ; Destination monitor
    mdx := mon%md%Left
    mdy := mon%md%Top
    mdw := mon%md%Right - mdx
    mdh := mon%md%Bottom - mdy
    
    Loop, %win%
    {
        ; If this window matches the GatherExclude group, don't touch it.
        if (WinExist("ahk_group GatherExclude ahk_id " . win%A_Index%))
            continue
        
        ; Set Last Found Window.
        if (!WinExist("ahk_id " . win%A_Index%))
            continue

        WinGet, procname, ProcessName
        ; Check process (program) exclusion list.
        if procname in %ProcessGatherExcludeList%
            continue
        
        WinGetPos, x, y, w, h
        
        ; Determine which monitor this window is on.
        xc := x+w/2, yc := y+h/2
        ms := 0
        Loop, %mc%
            if (xc >= mon%A_Index%Left && xc <= mon%A_Index%Right
                && yc >= mon%A_Index%Top && yc <= mon%A_Index%Bottom)
            {
                ms := A_Index
                break
            }
        ; If already on destination monitor, skip this window.
        if (ms = md)
            continue
        
        WinGet, state, MinMax
        if (state = 1) {
            WinRestore
            WinGetPos, x, y, w, h
        }
    
        if ms
        {
            ; Source monitor
            msx := mon%ms%Left
            msy := mon%ms%Top
            msw := mon%ms%Right - msx
            msh := mon%ms%Bottom - msy
            
            ; If the window is resizable, scale it by the monitors' resolution difference.
            if (IsResizable()) {
                w *= (mdw/msw)
                h *= (mdh/msh)
            }
        
            ; Move window, using resolution difference to scale co-ordinates.
            WinMove,,, mdx + (x-msx)*(mdw/msw), mdy + (y-msy)*(mdh/msh), w, h
        }
        else
        {   ; Window not on any monitor, move it to center.
            WinMove,,, mdx + (mdw-w)/2, mdy + (mdh-h)/2
        }

        if state = 1
            WinMaximize
    }
}


Hotkeys(P)
{
    local this_hotkey, P0, P1, P2, SectionVar, hotkeys, wait_for_keyup, m, m1, pos, k
    static key_regex = "^(?:.* & )?[#!^+&<>*~$]*(.+)"
    
    this_hotkey := A_ThisHotkey
    
    StringSplit, P, P, `,, %A_Space%%A_Tab%
    ; 1:Section, 2:Options
    
    if !P1
        goto HC_SendThisHotkeyAndReturn
    
    pos := RegExMatch(P2, "i)(?<=\bD)\d*\.?\d*", m)
    if pos
    {
        P2 := SubStr(P2, 1, pos-2) . SubStr(P2, pos+StrLen(m))
        if (m+0 = "")
            m := 0.1
        Input, k, L1 T%m%
        if ErrorLevel != Timeout
        {
            gosub HC_SendThisHotkey
            Send %k%
            return
        }
    }
    
    SectionVar := RegExReplace(P1, "[^\w#@$?\[\]]", "_")
    hotkeys := Hotkeys_%SectionVar%
    
    if hotkeys =
    {
        ; Load each hotkeys section on first use. Since the ini file may be
        ; edited between enabling and disabling the hotkeys, loading them
        ; each and every time would be hazardous.
        hotkeys := WindowPad_INI_ReadSection(WINDOWPAD_INI_PATH, "Hotkeys: " P1)
        if hotkeys =
            goto HC_SendThisHotkeyAndReturn
        
        ; key=command  ->  key::command
        hotkeys := RegExReplace(hotkeys, "m`a)^(.*?)=", "$1::")
        
        Hotkeys_%SectionVar% := hotkeys
    }
        
    ; If Options were omitted and this is a key-down hotkey,
    ; automatically disable the hotkeys when the key is released.
    if (wait_for_keyup := (P2="" && SubStr(this_hotkey,-2) != " up"))
        P2 = On ; Explicit "on" in case hotkey exists but is disabled.
    
    Hotkey, IfWinNotActive, ahk_group HotkeyExclude
    Hotkey_Params(hotkeys, P2)
    
    if (wait_for_keyup)
    {
        if (!RegExMatch(this_hotkey, key_regex, m) || GetKeyState(m1)="") {
            MsgBox, % "Error retrieving primary key of hotkey in Hotkeys().`n" 			;%;%
                    . "`tHotkey: " this_hotkey "`n"
                    . "`tResult: " m1
                    . "`nPlease inform Lexikos. Tip: Press Ctrl+C to copy this message."
            return
        }
        
        KeyWait, %m1%
        
        Hotkey_Params(hotkeys, "Off")

        ; A_ThisHotkey: "The key name of the *most recently executed* hotkey"
        ;if(some other hotkey was executed during KeyWait)
        if (this_hotkey = A_ThisHotkey)
            goto HC_SendThisHotkeyAndReturn
    }
    return

HC_SendThisHotkey:
HC_SendThisHotkeyAndReturn:
    if ! InStr(this_hotkey, "~")
        if (RegExMatch(this_hotkey, key_regex, m) && GetKeyState(m1)!="") {
            Hotkey, %this_hotkey%, Off
            Send {Blind}{%m1%}
            Hotkey, %this_hotkey%, On
        }
    return
}


; Hotkey_Params( line [, Options ] )
;   Associates a hotkey with a parameter string.
;
; Expects a newline(`n)-delimited list of hotkeys in the form:
;   Hotkey:: LabelName, Params
;
; Note:
;   - Spaces are optional.
;   - As with hotkey labels, there should be no space between 'Hotkey' and '::'.
;   - Unlike the Hotkey command, LabelName MUST NOT be omitted.
;   - Params MUST NOT contain a newline character (`n).
;   - Params may contain zero or more commas.
;   - , (comma) is supported as a hotkey.
;   - Unlike the Hotkey command, 'Toggle' should be specified in the Options, not as a label.
;
; Returns the number of hotkeys successfully enabled/disabled.
;
Hotkey_Params(line, Options="")
{
    static List ; List of hotkeys and associated labels + parameters.
    
    count = 0
    
    ; Note: The parsing loop operates on a temporary copy of 'line',
    ;       so 'line' can be (and is) reused within the loop.
    
    Loop, Parse, line, `n, %A_Space%%A_Tab%
    {
        ; Clear ErrorLevel in case UseErrorLevel is (not) specified.
        ErrorLevel =

        if ! RegExMatch(A_LoopField, "^\s*(?<Hotkey>.+?)::\s*(?<Label>.+?)(?:,\s*(?<Params>.*?))?\s*$", line)
            continue
        
        if (!IsLabel(lineLabel))
            continue
        
        if Options = Toggle ; Not supported as an option (must be Label.)
        {
            ; Toggle hotkey.  If it doesn't exist, the next line will enable it.
            Hotkey, %lineHotkey%, Toggle, UseErrorLevel
            ; Ensure the hotkey will execute the correct label.
            Hotkey, %lineHotkey%, ExecuteHotkeyWithParams, UseErrorLevel
        } else
            Hotkey, %lineHotkey%, ExecuteHotkeyWithParams, %Options%
        
        ; Check ErrorLevel in case UseErrorLevel was specified.
        if ErrorLevel
            continue
        
        ; Rebuild line to remove whitespace.
        line := lineHotkey "::" lineLabel "," lineParams
        
        ; Update an existing hotkey's label + params,
        temp := RegExReplace(List, "m`n)^\Q" lineHotkey "\E::.*$", line, repl, 1)
        if (repl > 0)
            List := temp
        else    ; or add a new hotkey to the list.
            List .= (List ? "`n" : "") . line

        count += 1
    }
    return count

ExecuteHotkeyWithParams:
    ; Local variables can't be used from the subroutine, so use a function.
    Hotkey_Params_Execute(A_ThisHotkey, List)
return
}

Hotkey_Params_Execute(Hotkey, ByRef List)
{
    global Params ; Parameters of hotkey currently executing.
    
    if (RegExMatch(List, "m`n)^\Q" Hotkey "\E::(?<Label>.+?),(?<Params>.*?)$", a))
    {
        Params := aParams
        gosub %aLabel%
    }
}


;
; Tray Icon Override
;

WM_COMMAND(wParam, lParam)
{
    static IsPaused, IsSuspended
    Critical
    id := wParam & 0xFFFF
    if id in 65305,65404,65306,65403
    {  ; "Suspend Hotkeys" or "Pause Script"
        if id in 65306,65403  ; pause
            IsPaused := ! IsPaused
        else  ; at this point, A_IsSuspended has not yet been toggled.
            IsSuspended := ! A_IsSuspended
        WindowPad_SetTrayIcon(!(IsPaused or IsSuspended))
    }
}

WindowPad_SetTrayIcon(is_enabled)
{
    icon := is_enabled ? "tray.ico" : "disabled.ico"
    ;icon = %A_LineFile%\icons\%icon%
    icon = %A_ScriptDir%\icons\%icon%

    ; avoid an error message if the icon doesn't exist
    IfExist, %icon%
        Menu, TRAY, Icon, %icon%,, 1
}


GetLastMinimizedWindow()
{
    WinGet, w, List

    Loop %w%
    {
        wi := w%A_Index%
        WinGet, m, MinMax, ahk_id %wi%
        if m = -1 ; minimized
        {
            lastFound := wi
            break
        }
    }

    return "ahk_id " . (lastFound ? lastFound : 0)
}



;
; Commands usable in WindowPad.ini
;
SwitchScreensUnderMouse:
	WindowScreenMove("Next,M")
Return
SwitchScreens:
	WindowScreenMove("Next")
return

GatherWindows:
    GatherWindows(Params)
    return
WindowPadMove:
    WindowPadMove(Params)
    return
WindowScreenMove:
    WindowScreenMove(Params)
    return
MaximizeToggle:
    MaximizeToggle(Params)
    return
Hotkeys:
    Hotkeys(Params)
    return
Send:
    Send, %Params%
    return
Minimize:
    if WindowPad_WinExist(Params)
        PostMessage, 0x112, 0xF020  ; WM_SYSCOMMAND, SC_MINIMIZE
    return
Unminimize:
    if WinExist(GetLastMinimizedWindow())
        WinRestore
    return
Restore:
    if WindowPad_WinExist(Params)
        WinRestore
    return
	