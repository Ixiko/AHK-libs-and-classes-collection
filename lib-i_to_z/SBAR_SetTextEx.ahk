;------------------------------
;
; Function: SBAR_SetTextEx
;
; Description:
;
;   Set the text in the specified part of a status bar with additional options
;       to delay setting the text, automatically clear the text, or flash the
;       text.
;
; Type:
;
;   Add-on function to the SBAR library.
;
; Parameters:
;
;   hSB - The handle to the status bar control.
;
;   p_Text - The text to set.
;
;   p_PartNumber - 1-based index of the part to set. [Optional]  The default is
;       1.  Set to 256 to set the text on a simple mode status bar.  See
;       <Simple Mode> for more information.
;
;   p_Style - The type of the drawing operation. [Optional]  The default is 0.
;       See the function's static variables for a list of possible values.  See
;       <Visual Styles> for more information.
;
;   p_Options - Options.  [Optional]  See the *Options* section for more
;       information.
;
; Options:
;
;   The p_Options parameter allows the developer to include advanced options to
;   control the display of status bar text.  The following options are
;   supported:
;
;   Clear={Seconds} - The amount of time, in seconds, to wait before
;       automatically clearing the text from the status bar.  Ex: 12.25.  The
;       default is 0 (don't clear).
;
;   Delay={Seconds} - The amount of time, in seconds, to wait before setting
;       the text on the status bar.  Ex: 0.25.  The default is 0 (don't delay
;       setting the text).
;
;   FlashCount={NumberOfTimes} - The number of times to flash the text.  Ex: 5.
;       The default is 0 (don't flash the text).
; 
;   FlashHide={Milliseconds} - The amount of time, in milliseconds, to hide the
;       text while flashing.  The default is the value in the s_DefaultFlashHide
;       static variable.
;
;   FlashShow={Milliseconds} - The amount of time, in milliseconds, to show the
;       text while flashing.  The default is the value in the s_DefaultFlashShow
;       static variable.
;
;   Stop - Stop any active or pending activity for the specified
;       hSB/part number.  Specifically, it will force complete any Flash
;       activity and it will turn off any active Clear or Delay timers.  If this
;       option is included, all other options (if any) are ignored and no other
;       actions are performed (i.e. text is not set).
;
;   TextAddress={Address} - Address of text to be set.  This option is only
;       needed if the status bar control is on a window that is not running in
;       the current process.  Note: If this option is set, the p_Text parameter
;       is ignored.
;
;   Additional stuff...
;
;   To use more than one option, include a space between each option.  For
;   example: "FlashCount=2 Clear=12"
;
; Remarks:
;
;   This function uses up to 36 timers (9 sets of 4) to clear, delay, hide, and
;   set the text on one or more status bars.  Although the function returns
;   immediately, the timers continue to run until all operations have completed.
;   If the function is called before a previous request with the same hSB and
;   part number has completed, all operations from the previous request are
;   forced complete (Flash) or the timers are turned off (Clear and Delay)
;   before the new new request is processed.  If all 9 timers sets are in use
;   (should be very rare), the function will reject all new (unique hSB/part
;   number combination) requests until at least one of the timer sets has
;   completed.
;
;   Changes made to the status bar text by other programs/commands
;   (Ex: <SB_SetText at
;   https://autohotkey.com/docs/commands/GuiControls.htm#SB_SetText>) may be
;   lost while the Clear or Flash timers initiated by this function are still
;   running.  In the case of a Delay timer, this function may overwrite text set
;   by other programs/commands.  Hint: If this function is used to delay, clear,
;   or flash text at any time, it should also be used when setting plain text.
;
; Observations:
;
;   When flashing, the shorter the text, the better.  Short text can easily be
;   read while flashing.  Long(er) text, not so much.  Although the FlashShow
;   time can be increased to improve readability, the flashing animation can
;   look clunky.
;
;-------------------------------------------------------------------------------
SBAR_SetTextEx(hSB,p_Text,p_PartNumber:=1,p_Style:=0,p_Options:="")
    {
    Static Dummy23698519

          ;-- General static variables
          ,s_ClearTime  :=[0,0,0,0,0,0,0,0,0]
          ,s_DelayTime  :=[0,0,0,0,0,0,0,0,0]
          ,s_FlashCount :=[0,0,0,0,0,0,0,0,0]
          ,s_FlashHide  :=[0,0,0,0,0,0,0,0,0]
          ,s_FlashShow  :=[0,0,0,0,0,0,0,0,0]
          ,s_hSB        :=[0,0,0,0,0,0,0,0,0]
          ,s_PartNumber :=[0,0,0,0,0,0,0,0,0]
          ,s_Style      :=[0,0,0,0,0,0,0,0,0]
          ,s_Text       :=["","","","","","","","",""]
          ,s_TextAddress:=[0,0,0,0,0,0,0,0,0]

          ;-- Defaults
          ,s_DefaultFlashShow:=700
          ,s_DefaultFlashHide:=500

          ;-- Status bar styles
          ,SBT_DEFAULT:=0x0
                ;-- The text is drawn with a border to appear lower than the
                ;   plane of the window.  This is the default.

          ,SBT_NOBORDERS:=0x100
                ;-- The text is drawn without borders.

          ,SBT_POPOUT:=0x200
                ;-- The text is drawn with a border to appear higher than the
                ;   plane of the window.

          ,SBT_RTLREADING:=0x400
                ;-- The text will be displayed in the opposite direction to the
                ;   text in the parent window

          ,SBT_NOTABPARSING:=0x800
                ;-- Tab characters are ignored.

          ,SBT_OWNERDRAW:=0x1000
                ;-- The text is drawn by the parent window.

          ;-- Messages
          ,SB_SETTEXTA:=0x401                           ;-- WM_USER + 1
          ,SB_SETTEXTW:=0x40B                           ;-- WM+USER + 11

    ;****************
    ;*              *
    ;*    Search    *
    ;*              *
    ;****************
    ;-- Find empty entry or matching elements (hSB and part number)
    ThisIndex:=0
    For l_Index,l_hSB in s_hSB
        {
        ;-- Unassigned element?
        if not l_hSB
            {
            ;-- Assign hSB and part number values
            s_hSB[l_Index]       :=hSB
            s_PartNumber[l_Index]:=p_PartNumber

            ;-- Set ThisIndex
            ThisIndex:=l_Index
            Break
            }

        ;-- Matching hSB and part number
        if (hSB=l_hSB and p_PartNumber=s_PartNumber[l_Index])
            {
            ;-- Set ThisIndex
            ThisIndex:=l_Index
            Break
            }
        }

    ;-- Arrays full?  If so, use the oldest entry that has no active timer(s)
    if not ThisIndex
        {
        Loop 9
            {
            if (s_ClearTime[A_Index]=0 and s_DelayTime[A_Index]=0 and s_FlashCount[A_Index]=0)
                {
                ;-- Assign new hSB and part number values
                s_hSB[A_Index]       :=hSB
                s_PartNumber[A_Index]:=p_PartNumber

                ;-- Set ThisIndex
                ThisIndex:=A_Index
                Break
                }
            }
        }

    ;-- All timers in use? (very rare)
    if not ThisIndex
        {
        outputdebug,
           (ltrim join`s
            Function: %A_ThisFunc% - All timers are in use.  Request rejected.
           )

        return
        }

    ;**************************
    ;*                        *
    ;*    Pending actions?    *
    ;*                        *
    ;**************************
    ;-- Clear?  Turn off timer.
    if s_ClearTime[ThisIndex]
        {
        SetTimer SBAR_SetTextEx_Clear%ThisIndex%,Off
        s_ClearTime[ThisIndex]:=0
        }

    ;-- Delay?  Turn off timer.
    if s_DelayTime[ThisIndex]
        {
        SetTimer SBAR_SetTextEx_Delay%ThisIndex%,Off
        s_DelayTime[ThisIndex]:=0
        }

    ;-- Flash?  Force complete.
    if s_FlashCount[ThisIndex]
        {
        s_FlashCount[ThisIndex]:=0
        gosub SBAR_SetTextEx_Show%ThisIndex%
            ;-- Note: These steps will stop the text from flashing by showing
            ;   the status bar text and turning off the Show and Hide timers.
        }

    ;***************
    ;*             *
    ;*    Stop?    *
    ;*             *
    ;***************
    if RegExMatch(p_Options,"i)\bStop\b")
        return

    ;********************
    ;*                  *
    ;*    Parameters    *
    ;*                  *
    ;********************
    s_Style[ThisIndex]:=p_Style
    s_Text[ThisIndex] :=p_Text

    ;[===========]
    ;[  Options  ]
    ;[===========]
    ;-- Set defaults
    s_ClearTime[ThisIndex]  :=0
    s_DelayTime[ThisIndex]  :=0
    s_FlashCount[ThisIndex] :=0
    s_FlashHide[ThisIndex]  :=s_DefaultFlashHide
    s_FlashShow[ThisIndex]  :=s_DefaultFlashShow
    s_TextAddress[ThisIndex]:=0

    ;-- Extract option values
    Loop Parse,p_Options,%A_Space%
        {
        if A_LoopField is Space
            Continue

        ;-- Skip if no assignment operator
        l_AssignPos:=InStr(A_LoopField,"=")
        if (l_AssignPos<2 or l_AssignPos=StrLen(A_LoopField))
            Continue

        ;-- Extract
        if InStr(A_LoopField,"Clear")  ;-- String "Clear" anywhere in the name
            s_ClearTime[ThisIndex]:=SubStr(A_LoopField,l_AssignPos+1)

        if (InStr(A_LoopField,"Delay")=1)
            s_DelayTime[ThisIndex]:=SubStr(A_LoopField,l_AssignPos+1)

        if (InStr(A_LoopField,"FlashCount")=1)
            s_FlashCount[ThisIndex]:=SubStr(A_LoopField,l_AssignPos+1)

        if (InStr(A_LoopField,"FlashHide")=1)
            s_FlashHide[ThisIndex]:=SubStr(A_LoopField,l_AssignPos+1)

        if (InStr(A_LoopField,"FlashShow")=1)
            s_FlashShow[ThisIndex]:=SubStr(A_LoopField,l_AssignPos+1)

        if (InStr(A_LoopField,"TextAddress")=1)
            s_TextAddress[ThisIndex]:=SubStr(A_LoopField,l_AssignPos+1)
        }

    ;*****************
    ;*               *
    ;*    Process    *
    ;*               *
    ;*****************
    ;-- If requested, start Clear timer
    if s_ClearTime[ThisIndex]
        SetTimer SBAR_SetTextEx_Clear%ThisIndex%,% s_ClearTime[ThisIndex]*1000

    ;-- If requested, start Flash timer
    if s_FlashCount[ThisIndex]
        SetTimer SBAR_SetTextEx_Show%ThisIndex%,% s_FlashShow[ThisIndex]+s_FlashHide[ThisIndex]

    ;-- If requested, start Delay timer and bounce
    if s_DelayTime[ThisIndex]
        {
        SetTimer SBAR_SetTextEx_Delay%ThisIndex%,% s_DelayTime[ThisIndex]*1000
        return
        }

    ;-- Set text
    gosub SBAR_SetTextEx_Show%ThisIndex%
    return  ;-- End of function


    ;**************************
    ;*                        *
    ;*       Subroutines      *
    ;*    (SBAR_SetTextEx)    *
    ;*                        *
    ;**************************
    SBAR_SetTextEx_Clear1:
    SBAR_SetTextEx_Clear2:
    SBAR_SetTextEx_Clear3:
    SBAR_SetTextEx_Clear4:
    SBAR_SetTextEx_Clear5:
    SBAR_SetTextEx_Clear6:
    SBAR_SetTextEx_Clear7:
    SBAR_SetTextEx_Clear8:
    SBAR_SetTextEx_Clear9:
    SetTimer %A_ThisLabel%,Off
    This:=SubStr(A_ThisLabel,0)
    s_ClearTime[This]:=0
        ;-- Note: Element set to 0 to indicate that the Clear timer is no longer
        ;   running for the hSB and part number.

    ;-- Clear (set to null) the status bar text
    SendMessage
        ,A_IsUnicode ? SB_SETTEXTW:SB_SETTEXTA
        ,s_Style[This]|s_PartNumber[This]-1
        ,0
        ,,% "ahk_id " . s_hSB[This]

    return


    SBAR_SetTextEx_Delay1:
    SBAR_SetTextEx_Delay2:
    SBAR_SetTextEx_Delay3:
    SBAR_SetTextEx_Delay4:
    SBAR_SetTextEx_Delay5:
    SBAR_SetTextEx_Delay6:
    SBAR_SetTextEx_Delay7:
    SBAR_SetTextEx_Delay8:
    SBAR_SetTextEx_Delay9:
    SetTimer %A_ThisLabel%,Off
    This:=SubStr(A_ThisLabel,0)
    s_DelayTime[This]:=0
        ;-- Note: Element set to 0 to indicate that the Delay timer is no longer
        ;   running for the hSB and part number.

    gosub SBAR_SetTextEx_Show%This%
    return


    SBAR_SetTextEx_Hide1:
    SBAR_SetTextEx_Hide2:
    SBAR_SetTextEx_Hide3:
    SBAR_SetTextEx_Hide4:
    SBAR_SetTextEx_Hide5:
    SBAR_SetTextEx_Hide6:
    SBAR_SetTextEx_Hide7:
    SBAR_SetTextEx_Hide8:
    SBAR_SetTextEx_Hide9:
    SetTimer %A_ThisLabel%,Off
    This:=SubStr(A_ThisLabel,0)

    ;-- Hide (set to null) the status bar text
    SendMessage
        ,A_IsUnicode ? SB_SETTEXTW:SB_SETTEXTA
        ,s_Style[This]|s_PartNumber[This]-1
        ,0
        ,,% "ahk_id " . s_hSB[This]

    return


    SBAR_SetTextEx_Show1:
    SBAR_SetTextEx_Show2:
    SBAR_SetTextEx_Show3:
    SBAR_SetTextEx_Show4:
    SBAR_SetTextEx_Show5:
    SBAR_SetTextEx_Show6:
    SBAR_SetTextEx_Show7:
    SBAR_SetTextEx_Show8:
    SBAR_SetTextEx_Show9:
    This:=SubStr(A_ThisLabel,0)

    ;-- Show (set) status bar text
    l_Text       :=s_Text[This]
    l_TextAddress:=s_TextAddress[This] ? s_TextAddress[This]:&l_Text

    SendMessage
        ,A_IsUnicode ? SB_SETTEXTW:SB_SETTEXTA
        ,s_Style[This]|s_PartNumber[This]-1             ;-- wParam (Style|Part)
        ,l_TextAddress                                  ;-- lParam (Pointer to string)
        ,,% "ahk_id " . s_hSB[This]

    ;-- Are we done?
    if (s_FlashCount[This]<1)
        {
        ;-- Turn off Show and Hide timers
        SetTimer %A_ThisLabel%,Off
        SetTimer SBAR_SetTextEx_Hide%This%,Off
        return
        }

    ;-- Set the Hide timer
    SetTimer SBAR_SetTextEx_Hide%This%,% s_FlashShow[This]
    s_FlashCount[This]:=s_FlashCount[This]-1
    return  ;-- End of function's subroutines
    }
