#SingleInstance force
#include gestures.ahk

; Defining directions for ease of use
; Angles are measured in clockwise cycles starting from Right. Eg: Down = 90 deg = 1/4 (0.25) cycles
N:=U:=0.75, S:=D:=0.25, W:=L:=0.5, E:=R:=0
,NE:=UR:=0.875, SE:=DR:=0.125, NW:=UL:=0.625, SW:=DL:=.325
;===============================================================================================

r_gestures:=new gestures() ; These gestures will be activated by RButton
,r_gestures.add(L,func("send").bind("{Browser_Back}"))       ;Simple Right Stroke => Back
,r_gestures.add(R,func("send").bind("{Browser_Forward}"))    ;Simple Left Stroke  => Forward
,r_gestures.add(U,func("send").bind("#{Tab}"))    ;Simple Left Stroke  => Forward

;===============================================================================================

m_gestures:=new gestures() ; These gestures will be activated by MButton
,m_gestures.add([R,U],func("msgbox").bind("RU"))     ;Simple Chain Right->Up
,m_gestures.add([L,D,R],func("msgbox").bind("LDR"))  ;Simple Chain Left->Down->Right

,m_gestures.add([ ; Letter P = Up->Right->Down->Left, with Up being 1.5-3 times the size of other strokes
                {angle:U,size:[1.5,3]},{angle:R,size:1},{angle:D,size:1},{angle:L,size:1}   ]
               ,func("msgbox").bind("Letter P"))

; Letter R = Up->Right->Down->Left->Down_Right, with Up stroke being 1.5-5 times size of left/right strokes.
; Since Tolerance is only 45 deg (0.125 cycles) instead of 90 deg as in previous examples, some error has to be considered. Therefore, we allow Up_Left - Up_Right instead of Up, Right - Down_Right for Right, and Down_Left - Left for Left.
; Minimum size of Down stroke is set as -1 signifying that the down stroke could be completely ignored.
,m_gestures.add([    {angle:[UL,UR],size:[1.5,5]}, {angle:[R,DR],size:1}
                   ,{angle:D,size:[-1,1]}
                   ,{angle:[DL,L],size:1}, DR              ]
              ,func("msgbox").bind("Letter R"),{angle_tolerance:.125}       )

; Note: Put max size as 0 for infinity. 0/Infinity cannot be used for the first stroke sizes, since the first stroke size is used for scaling




;===============================================================================================
; Hotkey implementation
return

RButton::r_gestures.start()
RButton up::
if r_gestures.end()!=1 ; Returns 0 = No Gesture, 1 = Gesture Triggered, -1 = Unidentified Gesture
    send("{RButton}")
return

MButton::m_gestures.start()
MButton up::
if m_gestures.end()!=1
    send("{MButton}")
return