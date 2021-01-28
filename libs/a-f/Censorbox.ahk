; Link:   	
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

; =================================================================================================================================
; Name:           CENSOR BOX 
; Description:    Hide parts of the screen with a colored box
; credits:        Speedmaster, Lexikos
; Topic:          https://www.autohotkey.com/boards/viewtopic.php?f=6&t=78160
; Sript version:  1.0
; AHK Version:    1.1.24.03 (A32/U32/U64)
; Tested on:      Win 7 
; shortcuts::     f1 add a new box
;                 f2 color the box with the top left pixel
;                 f3 freeze/unfreeze all boxes
;                 all boxes are resizable with the mouse

#SingleInstance force

OnMessage(0x201, "WM_LBUTTONDOWN")
OnMessage(0x84, "WM_NCHITTEST")
OnMessage(0x83, "WM_NCCALCSIZE")
OnMessage(0x86, "WM_NCACTIVATE")
CoordMode,pixel, screen

if !count
    goto newbox
return


F1::
newbox:
count++
 Gui box_%count%: -caption  +AlwaysOnTop +resize  ;+LabelGui +AlwaysOnTop    +LastFound +resize -caption
Gui box_%count%: show, w100 h100 , box_%count%
Gui box_%count%: color, black
return

f2::
WinGetPos,px,py,,, %currentgui%
PixelGetColor, outcolor, % px-1, % py-1, RGB
gui %currentgui%: color, % outcolor
return

f3::
freeze:=!freeze
if freeze
    loop, % count
        gui box_%a_index%: -resize
else
    loop, % count
        gui box_%a_index%: +resize
return


WM_LBUTTONDOWN() {
    global currentgui, freeze
    MouseGetPos, xpos, ypos 
    (A_Gui) && currentgui:=a_gui
	(A_Gui) && (!freeze)  && move()
}

move() { 
	PostMessage, 0xA1, 2 ; WM_NCLBUTTONDOWN
}

; thx Lexikos
; https://autohotkey.com/board/topic/23969-resizable-window-border/
; Sizes the client area to fill the entire window.
WM_NCCALCSIZE()
{
    if A_Gui
        return 0
}

; Prevents a border from being drawn when the window is activated.
WM_NCACTIVATE()
{
    if A_Gui
        return 1
}

; Redefine where the sizing borders are.  This is necessary since
; returning 0 for WM_NCCALCSIZE effectively gives borders zero size.
WM_NCHITTEST(wParam, lParam)
{
    static border_size = 6
    
    if !A_Gui
        return
    
    WinGetPos, gX, gY, gW, gH
    
    x := lParam<<48>>48, y := lParam<<32>>48
    
    hit_left    := x <  gX+border_size
    hit_right   := x >= gX+gW-border_size
    hit_top     := y <  gY+border_size
    hit_bottom  := y >= gY+gH-border_size
    
    if hit_top
    {
        if hit_left
            return 0xD
        else if hit_right
            return 0xE
        else
            return 0xC
    }
    else if hit_bottom
    {
        if hit_left
            return 0x10
        else if hit_right
            return 0x11
        else
            return 0xF
    }
    else if hit_left
        return 0xA
    else if hit_right
        return 0xB
    
    ; else let default hit-testing be done
}


return
guiclose:
~esc::
exitapp

