; Title:   	xy_mouse - confine mouse horizontally or vertically with a hotkey
; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=6&t=88469
; Author:	william_ahk
; Date:   	23.03.2021
; for:     	AHK_L

/*
    Usage:
    Simple:
    Code: Select all - Toggle Line numbers

    xy_m := new xy_mouse({hotkey: "~LAlt"})
    xy_m.enable_hotkey()
    Active only on a specific window:
    Code: Select all - Toggle Line numbers

    xy_m := new xy_mouse({hotkey: "~LAlt", wintitle: ""})
    xy_m.enable_hotkey()
    Active only on certain windows:
    Code: Select all - Toggle Line numbers

    xy_m := new xy_mouse({hotkey: "~LAlt", wintitle: ["ahk_exe mspaint.exe", "ahk_exe CorelDRW.exe"]})
    xy_m.enable_hotkey()
    Custom moving direction threshold:
    Code: Select all - Toggle Line numbers

    xy_m := new xy_mouse({hotkey: "~LAlt", moving_direction_threshold: 10})
    xy_m.enable_hotkey()
    Enable / Disable hotkey
    Code: Select all - Toggle Line numbers

    xy_m := new xy_mouse({hotkey: "~LAlt"})
    return

    F1::
    _switch := !_switch
    _switch ? xy_m.enable_hotkey() : xy_m.disable_hotkey()
    return
    Credits:
    ClipCursor() was borrowed from: https://autohotkey.com/board/topic/61753-confining-mouse-to-a-window

*/

class xy_mouse {
    __new(options) {
        CoordMode, Mouse, Screen
        this.hotkey := options.hotkey
        this.hotkey_name := RegExReplace(options.hotkey, "^[*~!#^+]")
        this.wintitle := options.wintitle
        this.moving_direction_threshold := options.moving_direction_threshold > 1 ? options.moving_direction_threshold : 5
    }

    enable_hotkey() {
        fn_obj := this["main"].bind(this)
        if (this.wintitle != "") {
            if (IsObject(this.wintitle)) {
                for index, wintitle in this.wintitle {
                    GroupAdd, target_wingroup, % wintitle
                    msgbox % wintitle
                }
                Hotkey, IfWinActive, ahk_group target_wingroup
            } else {
                Hotkey, IfWinActive, % this.wintitle
            }

        }
        Hotkey, % this.hotkey, % fn_obj, On
    }

    disable_hotkey() {
        Hotkey, % this.hotkey, Off
    }

    main() {
        ;Get the moving direction of the mouse
        MouseGetPos, initial_m_x, initial_m_y
        while (GetKeyState(this.hotkey_name, "P")) {
            MouseGetPos, m_x, m_y
            if (Abs(m_x - initial_m_x) > this.moving_direction_threshold) {
                m_axis := "x"
                break
            } else if (Abs(m_y - initial_m_y) > this.moving_direction_threshold) {
                m_axis := "y"
                break
            }
        }

        ;Confine cursor depending on the mouse moving axis
        switch m_axis
        {
        case "x":
            while (GetKeyState(this.hotkey_name, "P")) {
                this.ClipCursor(true, 0, initial_m_y, A_ScreenWidth, initial_m_y + 1)
            }
            this.ClipCursor(false)
            return
        case "y":
            while (GetKeyState(this.hotkey_name, "P")) {
                this.ClipCursor(true, initial_m_x, 0, initial_m_x + 1, A_ScreenHeight)
            }
            this.ClipCursor(false)
            return
        }
    }

    ClipCursor(confine=true, x1=0, y1=0, x2=1, y2=1) {
        VarSetCapacity(R, 16, 0)
        NumPut(x1, &R+0), NumPut(y1, &R+4)
        NumPut(x2, &R+8), NumPut(y2, &R+12)
        return confine ? DllCall("ClipCursor", UInt, &R) : DllCall("ClipCursor")
    }
}