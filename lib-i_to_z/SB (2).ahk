; Various DllCall and Sendmessage to control Standard Scrollbars
; It will not work on Customized scrollbars (IE/FireFox etc)
;
; - Parameters
; hwnd = Unique ID(hwnd) of the control where Scrollbar belongs to, not window
; Which = "V"(vertical) or "H"(horizontal), can be 1(V) or 0(H)
;
; - Basic Functions
; SB_GetPos(hwnd, Which="V")
; SB_SetPos(hwnd, Which="V", To="0")    ;it does not scroll pages actually
; SB_GetRange(hwnd, Which="V")          ;eg) Min,Max
; SB_Show(hwnd, Which="V")              ;Use carefully
; SB_Hide(hwnd, Which="V")              ;Use carefully
;
; - Functions To scroll the page actually
; SB_LineUP(hwnd, Which="V")
; SB_LineDown(hwnd, Which="V")
; SB_PageUp(hwnd, Which="V")
; SB_PageDown(hwnd, Which="V")
; SB_Top(hwnd, Which="V")
; SB_Bottom(hwnd, Which="V")
;
; - When interact with horizontal scrollbar
;   'UP' means 'Left' and 'Down' means 'Right' for horizontal scrollbar


SB_GetPos(hwnd, Which="V"){
    Which := (Which="V" || Which=1) ? 1 : (Which="H" || Which=0) ? 0 : 1
    Return DllCall("GetScrollPos", "UInt", Hwnd, "Int", Which)                
}

SB_SetPos(hwnd, Which="V", To="0"){
    Which := (Which="V" || Which=1) ? 1 : (Which="H" || Which=0) ? 0 : 1
    Return DllCall("SetScrollPos", "UInt", Hwnd, "Int", Which, "Int", To, "UInt", 1)
}

SB_GetRange(hwnd, Which="V"){
    Which := (Which="V" || Which=1) ? 1 : (Which="H" || Which=0) ? 0 : 1
    Dllcall("GetScrollRange", "uInt", hwnd, "int", Which, "uInt *", Min, "uInt *", Max)
    Return Min "," Max    
}

SB_Show(hwnd, Which="V"){
    Which := (Which="V" || Which=1) ? 1 : (Which="H" || Which=0) ? 0 : 1
    Return DllCall("ShowScrollBar", "uInt", Hwnd, "Int", Which, "Int", 1)
}

SB_Hide(hwnd, Which="V"){
    Which := (Which="V" || Which=1) ? 1 : (Which="H" || Which=0) ? 0 : 1
    Return DllCall("ShowScrollBar", "uInt", Hwnd, "Int", Which, "Int", 0)
}

SB_LineUP(hwnd, Which="V"){
    Which := (Which="V" || Which=1) ? 0x115 : (Which="H" || Which=0) ? 0x114 : 0x115
    SendMessage, %Which%, 0,,,ahk_id %hwnd%
    Return Errorlevel
}

SB_LineDown(hwnd, Which="V"){
    Which := (Which="V" || Which=1) ? 0x115 : (Which="H" || Which=0) ? 0x114 : 0x115
    SendMessage, %Which%, 1,,,ahk_id %hwnd%
    Return Errorlevel
}

SB_PageUp(hwnd, Which="V"){
    Which := (Which="V" || Which=1) ? 0x115 : (Which="H" || Which=0) ? 0x114 : 0x115
    SendMessage, %Which%, 2,,,ahk_id %hwnd%
    Return Errorlevel
}

SB_PageDown(hwnd, Which="V"){
    Which := (Which="V" || Which=1) ? 0x115 : (Which="H" || Which=0) ? 0x114 : 0x115
    SendMessage, %Which%, 3,,,ahk_id %hwnd%
    Return Errorlevel
}

SB_Top(hwnd, Which="V"){
    Which := (Which="V" || Which=1) ? 0x115 : (Which="H" || Which=0) ? 0x114 : 0x115
    SendMessage, %Which%, 6,,,ahk_id %hwnd%
    Return Errorlevel
}

SB_Bottom(hwnd, Which="V"){
    Which := (Which="V" || Which=1) ? 0x115 : (Which="H" || Which=0) ? 0x114 : 0x115
    SendMessage, %Which%, 7,,,ahk_id %hwnd%
    Return Errorlevel
}
