#SingleInstance Force

WinGetClientPos( winTitle, ByRef x, ByRef y, ByRef w, ByRef h ){
    WinGet, hwnd, ID, %winTitle%
    if hwnd =
    {
        return false
    }

	VarSetCapacity( size, 16, 0 )
	DllCall( "GetClientRect", UInt, hwnd, Ptr, &size )
	DllCall( "ClientToScreen", UInt, hwnd, Ptr, &size )
	x := NumGet(size, 0, "Int")
	y := NumGet(size, 4, "Int")
	w := NumGet( size, 8, "Int" )
	h := NumGet( size, 12, "Int" )
    return true
}

SetWindow(windowTitle){
    global g_windowTitle
    g_windowTitle := windowTitle
}

RecordClientArea(b){
    global g_recordClientArea
    g_recordClientArea := b
}

Record(fileOut=""){
    global g_windowTitle, g_recordClientArea

    if (g_windowTitle == "")
    {
        MsgBox g_windowTitle is not set
        ExitApp
    }

	WinActivate %g_windowTitle%
    WinWaitActive %g_windowTitle%, , 2
    if (ErrorLevel = 1)
    {
        MsgBox, 16, ERROR, Cannot find window: "%g_windowTitle%"
        ExitApp
    }

    if g_recordClientArea
    {
        if not WinGetClientPos(g_windowTitle, x, y, w, h)
        {
            MsgBox, 16, ERROR, Fail to get client geometry: %g_windowTitle%
            ExitApp
        }
    }
    else
    {
        WinGet, hwnd, ID, %winTitle%
        if hwnd =
        {
            MsgBox, 16, ERROR, Fail to get window geometry: %g_windowTitle%
            ExitApp
        }
        WinGetPosEx(hwnd, x, y, w, h)
    }

	; Start VLC
    StartRecordFFmpeg(x, y, w, h)
}

Stop(){
    StopRecordFFmpeg()
}

Exit(){
    Stop()
    ExitApp
}

StartRecordVLC(x, y, w, h, fileOut=""){
    WinClose ahk_exe vlc.exe
	if ( fileOut = "" )
	{
        FormatTime, now, R, yyyyMMdd_hhmmss
	    fileOut = %A_Desktop%\Record_%now%.mp4
    }
	commandLine = "C:\Program Files\VideoLAN\VLC\vlc.exe" --qt-start-minimized screen:// :sout=#transcode{vcodec=mp4v,acodec=mp4a}:file{dst=%fileOut%} :screen-fps=60 :screen-left=%x% :screen-top=%y% :screen-width=%w% :screen-height=%h%
    Run, %commandLine%
}

StopRecordVLC(){
    DetectHiddenWindows On
    WinClose ahk_exe vlc.exe
    DetectHiddenWindows Off
}

StartRecordFFmpeg(x, y, w, h){
    ; Make sure w and h are divisible by 2
    if ( Mod(w, 2) = 1 )
        w -= 1
    if ( Mod(h, 2) = 1 )
        h -= 1

    SetWorkingDir % A_Desktop

    FormatTime, now, R, yyyyMMdd_hhmmss
    fileOut = Record_%now%.mp4

    sizeParams = -offset_x %x% -offset_y %y% -video_size %w%x%h% -draw_mouse 0
    Run, ffmpeg -y -f gdigrab -framerate 60 %sizeParams% -i desktop -f dshow -i audio="virtual-audio-capturer" -c:v libx264 -crf 0 -preset ultrafast %fileOut%,, Min
}

StopRecordFFmpeg(){
    ControlSend, ahk_parent, q, ahk_exe ffmpeg.exe
}

WinGetPosEx(hWindow, ByRef X = "", ByRef Y = "", ByRef Width = "", ByRef Height = "", ByRef Offset_X = "", ByRef Offset_Y = ""){
    Static Dummy5693, RECTPlus, S_OK := 0x0, DWMWA_EXTENDED_FRAME_BOUNDS := 9

    ;-- Workaround for AutoHotkey Basic
    PtrType := (A_PtrSize=8) ? "Ptr" : "UInt"

    ;-- Get the window's dimensions
    ;     Note: Only the first 16 bytes of the RECTPlus structure are used by the
    ;     DwmGetWindowAttribute and GetWindowRect functions.
    VarSetCapacity(RECTPlus, 24,0)
    DWMRC := DllCall("dwmapi\DwmGetWindowAttribute"
            ,PtrType,hWindow                                                                ;-- hwnd
            ,"UInt",DWMWA_EXTENDED_FRAME_BOUNDS                         ;-- dwAttribute
            ,PtrType,&RECTPlus                                                            ;-- pvAttribute
            ,"UInt",16)                                                                         ;-- cbAttribute

    If (DWMRC <> S_OK) {
        If ErrorLevel in -3, -4     ;-- Dll or function not found (older than Vista)
        {
            ;-- Do nothing else (for now)
        } Else
            outputdebug,
                (LTrim Join`s
                 Function: %A_ThisFunc% -
                 Unknown error calling "dwmapi\DwmGetWindowAttribute".
                 RC = %DWMRC%,
                 ErrorLevel = %ErrorLevel%,
                 A_LastError = %A_LastError%.
                 "GetWindowRect" used instead.
                )

        ;-- Collect the position and size from "GetWindowRect"
        DllCall("GetWindowRect", PtrType, hWindow, PtrType, &RECTPlus)
    }

    ;-- Populate the output variables
    X := Left := NumGet(RECTPlus, 0, "Int")
    Y := Top  := NumGet(RECTPlus, 4, "Int")
    Right     := NumGet(RECTPlus, 8, "Int")
    Bottom    := NumGet(RECTPlus, 12, "Int")
    Width     := Right-Left
    Height    := Bottom-Top
    OffSet_X  := 0
    OffSet_Y  := 0

    ;-- If DWM is not used (older than Vista or DWM not enabled), we're done
    If (DWMRC <> S_OK)
        Return &RECTPlus

    ;-- Collect dimensions via GetWindowRect
    VarSetCapacity(RECT, 16, 0)
    DllCall("GetWindowRect", PtrType, hWindow, PtrType, &RECT)
    GWR_Width := NumGet(RECT, 8, "Int") - NumGet(RECT, 0, "Int")        ;-- Right minus Left
    GWR_Height := NumGet(RECT, 12, "Int") - NumGet(RECT, 4, "Int")    ;-- Bottom minus Top

    ;-- Calculate offsets and update output variables
    NumPut(Offset_X := (Width    - GWR_Width)    // 2, RECTPlus, 16, "Int")
    NumPut(Offset_Y := (Height - GWR_Height) // 2, RECTPlus, 20, "Int")
    Return &RECTPlus
}

g_recordClientArea := True
SetKeyDelay, 10, 10
SetWorkingDir % A_Desktop
Hotkey, Esc, Exit