screen_get_virtual_size(ByRef x, ByRef y, ByRef w, ByRef h) {
    ; Get width of all screens combined.
    ; NOTE: Single screens may have different vertical resolutions so some parts of
    ; the area returned here might not belong to any screens!
    SysGet, x, 76
    SysGet, y, 77
    SysGet, w, 78
    SysGet, h, 79
}

screen_get_index(hwnd) {
    ; Return the MonitorID where the specified window is located on
    ; @author shnywong
    ; @docu
    ;     https://autohotkey.com/board/topic/69464-how-to-determine-a-window-is-in-which-monitor/#entry440355
    ; @sample
    ;     screen_get_index(WinExist("A"))
    ; @param   HWND     hwnd     Handler of the window to be found
    ; @return  integer
    ; Starts with 1.
    monitorIndex := 1

    VarSetCapacity(monitorInfo, 40)
    NumPut(40, monitorInfo)

    if (monitorHandle := DllCall("MonitorFromWindow", "uint", hwnd, "uint", 0x2))
        && DllCall("GetMonitorInfo", "uint", monitorHandle, "uint", &monitorInfo)
    {
        monitorLeft := NumGet(monitorInfo, 4, "Int")
        monitorTop := NumGet(monitorInfo, 8, "Int")
        monitorRight := NumGet(monitorInfo, 12, "Int")
        monitorBottom := NumGet(monitorInfo, 16, "Int")

        SysGet, monitorCount, MonitorCount

        Loop, %monitorCount%
        {
            SysGet, tempMon, Monitor, %A_Index%

            ; Compare location to determine the monitor index.
            if ((monitorLeft = tempMonLeft) and (monitorTop = tempMonTop)
                and (monitorRight = tempMonRight) and (monitorBottom = tempMonBottom))
            {
                monitorIndex := A_Index
                break
            }
        }
    }

    return %monitorIndex%
}

class Screen_Workarea {
    __new(index=1) {
        SysGet, WorkArea, MonitorWorkArea, %index%
        this.left := WorkAreaLeft
        this.x := this.left
        this.right := WorkAreaRight
        this.x2 := this.right

        this.top := WorkAreaTop
        this.y := this.top
        this.bottom	:= WorkAreaBottom
        this.y2 := this.bottom

        this.width := WorkAreaRight - WorkAreaLeft
        this.w := this.width
        this.height := WorkAreaBottom - WorkAreaTop
        this.h := this.height
    }
}

screen_get_work_area(monitor_index := -1) {
    ; Get a Screen_Workarea object of the currently active (where the active window is)
    ; or from the monitor with the given number.
    if (monitor_index == -1) {
        monitor_index := screen_get_index(WinExist("A"))
    }
    area := new Screen_WorkArea(monitor_index)
    return area
}
