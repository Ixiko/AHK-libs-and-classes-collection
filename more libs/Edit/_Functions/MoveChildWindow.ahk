;-----------------------------
;
; Function: MoveChildWindow v0.2.2 (Preview)
;
; Description:
;
;   Moves a child or pop-up window relative to the parent window.  If needed,
;   the coordinates are adjusted so that the window will fit within the primary
;   monitor work area.
;
; Parameters:
;
;   p_Parent - Parent window.  On all versions of AutoHotkey, this parameter
;       can contain a GUI window number (1 thru 99) or a window handle (hWnd).
;       On AutoHotkey v1.1+, this parameter can also contain a GUI name.
;       Exception: If the "Mouse" or "x,y" options are used, this parameter is
;       ignored.
;
;   p_Child - Child window.  On all versions of AutoHotkey, this parameter
;       can contain a GUI window number (1 thru 99) or a window handle (hWnd).
;       On AutoHotkey v1.1+, this parameter can also contain a GUI name.
;
;   p_Options - Options that determine the position of the child window
;       relative to the parent.  See the *Options* section for the details.
;
; Options:
;
;   The p_Options parameter contains a combination of options that determine
;   how the child window is positioned and/or modified.  The following
;   position options are available.
;
;   Attach - If included, the child window is positioned outside of the parent
;       window as though it were "attached" to one of the borders. The order of
;       the positional parameters ("Left", "Top", etc.) becomes important if
;       selected.  For example if "Attach Right Top" is specified, the child
;       window is positioned on the right border of the parent at the top of the
;       window.  However, if "Attach Top Right" is specified, the child window
;       is positioned immediately above the parent window on the right side of
;       the window.
;
;   Bottom - Positions the child window relative to the bottom of the parent
;       window.  Often used with the "Left", "Center", or "Right options.
;
;   Center - Positions the child window relative to the center of the parent
;       window.  Often used with the "Top", "Bottom", "Left", or "Right"
;       options.  This option is the default positioning option and it has the
;       lowest precedence of all the positioning options.  If no positioning (or
;       competing) options are specified, "Center" is assumed.
;
;   Left - Positions the child window relative to the left side of the parent
;       window.  Often used with the "Top", "Center", or "Bottom" options.
;
;   Mouse - Positions the child window relative to the current cursor (i.e.
;       mouse) position.  If this option is specified, all other positioning
;       options are ignored.
;
;   Right - Positions the child window relative to the right side of the parent
;       windows.  Often used with the "Top", "Center", or "Bottom" options.
;
;   Top - Positions the child window relative to the top of the parent window.
;       Often used with the "Left" , "Center", or "Right" options. This option
;       takes precedence over the "Bottom" option.
;
;   x,y - Position the child window to specific X and/or Y coordinates.  For
;       example, "10,10" will position the dialog in the top left corner of the
;       monitor, 10 pixels in.  If either coordinate is omitted, the dialog will
;       be centered in that dimension.  However, the "," (comma character) must
;       always be specified.  Ex: "120," (X coordinate only) or ",90" (Y
;       coordinate only).  If this option is included, all other positional
;       options are ignored.
;
;   In addition, the following miscellaneous options are available.
;
;   NoMove - Calculates the new position but the child window is not moved.  The
;       coordinates of the child window can be collected via the function's
;       return value.
;
;   Show - Shows (unhides) the child window after it has been moved.  Note: This
;       option should only be specified if the child/pop-up window is hidden
;       _and_ the script doesn't already show (unhide) the window.
;
;   ShowNA - Same as the "Show" option except that the window is not activated
;       after it shown.  This option takes precedence over the "Show" option.
;
;   If more than one option is specified, it should be delimited by a space.
;   For example: "Attach Left Top".
;
; Returns:
;
;   If successful, the address to a <POINT at http://tinyurl.com/mfv6fpz>
;   structure which contains the new coordinates of the child window, otherwise
;   FALSE.
;
; Calls To Other Functions:
;
; * WinGetPosEx
;
; Remarks:
;
;   This version of the function will work on all versions of AutoHotkey but
;   when using AutoHotkey v1.1+, the function may generate a run-time error if
;   p_Parent or p_Child contains an invalid GUI number (1 thru 99) or GUI name.
;   Future versions of this function (when AutoHotkey Basic is no longer
;   supported) will include additional code to ensure that the function will not
;   generate run-time errors.
;
;   At this writing, the function only supports the primary monitor.  Support
;   for multiple monitors may be included in future versions.
;
;-------------------------------------------------------------------------------
MoveChildWindow(p_Parent,p_Child,p_Options="")
    {
    Static Dummy5202
          ,POINT
          ,SW_SHOWNA:=8

    ;[==============]
    ;[  Initialize  ]
    ;[==============]
    VarSetCapacity(POINT,8,0)

    ;-- Workaround for AutoHotkey Basic
    PtrType:=(A_PtrSize=8) ? "Ptr":"UInt"

    ;-- Environment
    l_DetectHiddenWindows:=A_DetectHiddenWindows
    DetectHiddenWindows On
    SysGet l_MonitorWorkArea,MonitorWorkArea
    StringUpper p_Options,p_Options,T   ;-- Just in case StringCaseSense is On

    ;[==============]
    ;[  Parameters  ]
    ;[==============]
    ;------------
    ;-- p_Parent
    ;------------
    ;-- Ignore the parent, i.e. allow invalid or no parent, if "Mouse" or 
    ;   coordinates (Ex: 100,400) options are specified
    if p_Options Contains ,,,Mouse  ;-- "," character or "Mouse"
        hParent:=0
     else
        {
        ;-- Not already a window handle?
        if ((hParent:=WinExist("ahk_id " . p_Parent))<100)
            {
            ;-- GUI number or GUI name
            gui %p_Parent%:+LastFoundExist
            IfWinExist
                {
                gui %p_Parent%:+LastFound
                hParent:=WinExist()
                }
            }

        ;-- Bounce if the parent window is not found
        if not hParent
            {
            outputdebug,
               (ltrim join`s
                Function: %A_ThisFunc% -
                Unable to find the parent window. Request aborted.
                p_Parent=%p_Parent%
               )

            ;-- Reset environment
            DetectHiddenWindows %l_DetectHiddenWindows%
            Return False
            }

        ;-- Collect window position/size
        WinGetPosEx(hParent,l_ParentX,l_ParentY,l_ParentW,l_ParentH)
        }

    ;-----------
    ;-- p_Child
    ;-----------
    ;-- Not already a window handle?
    if ((hChild:=WinExist("ahk_id " . p_Child))<100)
        {
        ;-- GUI number or GUI name
        gui %p_Child%:+LastFoundExist
        IfWinExist
            {
            gui %p_Child%:+LastFound
            hChild:=WinExist()
            }
        }

    ;-- Bounce if the child window is not found
    if not hChild
        {
        outputdebug,
           (ltrim join`s
            Function: %A_ThisFunc% - 
            Unable to find the child window. Request aborted.
            p_Child=%p_Child%
           )

        ;-- Reset environment
        DetectHiddenWindows %l_DetectHiddenWindows%
        Return False
        }

    ;-- Collect window position/size
    WinGetPosEx(hChild,l_ChildX,l_ChildY,l_ChildW,l_ChildH,l_ChildOffset_X,l_ChildOffset_Y)

    ;[=========================]
    ;[  Determine coordinates  ]
    ;[=========================]
    ;-- Mouse
    if p_Options Contains Mouse
        {
        DllCall("GetCursorPos",PtrType,&POINT)
        l_ChildX:=NumGet(POINT,0,"Int")+l_ChildOffset_X
        l_ChildY:=NumGet(POINT,4,"Int")+l_ChildOffset_Y
        }
     else
        {
        ;-- Specific X and/or Y coordinates
        if p_Options Contains ,,
            {
            ;-- Parse until the coordinates option is found
            l_Coords:=""
            Loop Parse,p_Options,%A_Space%
                if A_LoopField Contains ,,
                    {
                    l_Coords:=A_LoopField
                    Break
                    }

            ;-- Set defaults
            l_ChildX:=Round(((l_MonitorWorkAreaRight-l_MonitorWorkAreaLeft)/2)-(l_ChildW/2))+l_ChildOffset_X
            l_ChildY:=Round(((l_MonitorWorkAreaBottom-l_MonitorWorkAreaTop)/2)-(l_ChildH/2))+l_ChildOffset_Y

            ;-- Extract coordinates
            Loop Parse,l_Coords,`,
                {
                if (A_Index=1)
                    if A_LoopField is Integer
                        l_ChildX:=A_LoopField+l_ChildOffset_X

                if (A_Index=2)
                    if A_LoopField is Integer
                        l_ChildY:=A_LoopField+l_ChildOffset_Y
                }
            }
         else
            {
            ;-- Default if none of the associated positional options are included
            l_ChildX:=Round(l_ParentX+((l_ParentW-l_ChildW)/2))+l_ChildOffset_X
            l_ChildY:=Round(l_ParentY+((l_ParentH-l_ChildH)/2))+l_ChildOffset_Y

            ;-- Attach
            if p_Options Contains Attach
                {
                ;-- Initialize
                l_PosParmCount:=0

                ;-- Extract options from left to right
                Loop Parse,p_Options,%A_Space%
                    {
                    if A_LoopField not in Left,Top,Right,Bottom
                        Continue

                    l_PosParmCount++
                    if (l_PosParmCount=1)
                        {
                        if (A_LoopField="Left")
                            l_ChildX:=l_ParentX-l_ChildW+l_ChildOffset_X
                         else if (A_LoopField="Top")
                            l_ChildY:=l_ParentY-l_ChildH+l_ChildOffset_Y
                         else if (A_LoopField="Right")
                            l_ChildX:=l_ParentX+l_ParentW+l_ChildOffset_X
                         else if (A_LoopField="Bottom")
                            l_ChildY:=l_ParentY+l_ParentH+l_ChildOffset_Y
                        }
                     else  ;-- l_PosParmCount>1
                        {
                        if (A_LoopField="Left")
                            l_ChildX:=l_ParentX+l_ChildOffset_X
                         else if (A_LoopField="Top")
                            l_ChildY:=l_ParentY+l_ChildOffset_Y
                         else if (A_LoopField="Right")
                            l_ChildX:=l_ParentX+l_ParentW-l_ChildW+l_ChildOffset_X
                         else if (A_LoopField="Bottom")
                            l_ChildY:=l_ParentY+l_ParentH-l_ChildH+l_ChildOffset_Y
                        }
                    }
                }
             else
                {
                ;-- X
                if p_Options Contains Left
                    l_ChildX:=l_ParentX+l_ChildOffset_X
                 else
                    if p_Options Contains Right
                        l_ChildX:=l_ParentX+l_ParentW-l_ChildW+l_ChildOffset_X

                ;-- Y
                if p_Options Contains Top
                    l_ChildY:=l_ParentY+l_ChildOffset_Y
                 else
                    if p_Options Contains Bottom
                        l_ChildY:=l_ParentY+l_ParentH-l_ChildH+l_ChildOffset_Y
                }
            }
        }

    ;-- If needed, adjust so that the window fits within the monitor work area
    if (l_ChildX<l_MonitorWorkAreaLeft+l_ChildOffset_X)
        l_ChildX:=l_MonitorWorkAreaLeft+l_ChildOffset_X

    if (l_ChildY<l_MonitorWorkAreaTop+l_ChildOffset_Y)
        l_ChildY:=l_MonitorWorkAreaTop+l_ChildOffset_Y

    l_MaximumX:=l_MonitorWorkAreaRight-l_ChildW+l_ChildOffset_X
    if (l_ChildX>l_MaximumX)
        l_ChildX:=l_MaximumX

    l_MaximumY:=l_MonitorWorkAreaBottom-l_ChildH+l_ChildOffset_Y
    if (l_ChildY>l_MaximumY)
        l_ChildY:=l_MaximumY

    ;[========]
    ;[  Move  ]
    ;[========]
    if p_Options not Contains Nomove
        {
        ;-- Move to new position using the window's current width and height
        WinGetPos,,,l_Width,l_Height,ahk_id %hChild%
        if not DllCall("MoveWindow"
                ,PtrType,hChild
                ,"Int",l_ChildX
                ,"Int",l_ChildY
                ,"Int",l_Width
                ,"Int",l_Height
                ,"Int",True)
            {
            outputdebug,
               (ltrim join`s
                Function: %A_ThisFunc% - 
                Unable to move the child window. Request aborted.
               )
    
            ;-- Reset environment
            DetectHiddenWindows %l_DetectHiddenWindows%
            Return False
            }

        ;-- Yield the remainder of the script's timeslice to other processes
        ;   that need it, if any
        Sleep 0
        }

    ;[========]
    ;[  Show  ]
    ;[========]
    if p_Options Contains Showna
        DllCall("ShowWindow",PtrType,hChild,"Int",SW_SHOWNA)
     else
        if p_Options Contains Show
            WinShow ahk_id %hChild%

    ;[=======================]
    ;[  Housekeeping/Return  ]
    ;[=======================]
    ;-- Reset environment 
    DetectHiddenWindows %l_DetectHiddenWindows%

    ;-- Populate POINT structure
    NumPut(l_ChildX,POINT,0,"Int")
    NumPut(l_ChildY,Point,4,"Int")

    ;-- Return address of POINT structure
    Return &POINT
    }
