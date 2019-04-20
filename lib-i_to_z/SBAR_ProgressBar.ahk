;------------------------------
;
; Function: SBAR_ProgressBar
;
; Description:
;
;   Create and manage a progress bar for a status bar part.
;
; Type:
;
;   Add-on function to the SBAR library.
;
; Parameters:
;
;   hSB - The handle to the status bar
;
;   p_ProgressPos - Progress position.  If set to an integer value, the current
;       position of the progress bar is updated based on the value.  For
;       example, if the default range of 0-100 is used, set to 50 to move the
;       progress indicator to the middle of the progress bar.  Set to null to
;       avoid updating the progress indicator bar.
;
;   p_PartNumber - 1-based index of the status bar part that will contain the
;       progress bar.
;
;   p_Options - See the *Options* section for more information.
;
; Returns:
;
;   The handle to the progress bar if successful, otherwise FALSE.
;
; Calls To Other Functions:
;
; * <SBAR_ColorName2RGB>
; * <SBAR_GetPartRect>
; * <SBAR_GetPartsCount>
;
; Options:
;
;   The p_Options parameter contains commands and options for the progress bar.
;   The following options are supported:
;
;   Background{color} - Color of the background in the progress bar.  {color} is
;       one of 16 color names (see the AutoHotkey documentation for a list of
;       supported color names) or a 6-digit hex RGB color value.  Example color
;       values: Blue or FF00FA.  Important: Changing the background color is not
;       supported  when visual styles are enabled.  If needed, include the
;       -Theme option to disable visual styles for the progress control so that
;       the background color can be set.
;
;   [+-]Border - Add or remove a border to/from the progress bar control.  See
;       the *Border* section for more information.
;
;   c{color} - Color of the progress indicator bar.  {color} is one of 16 color
;       names (see the AutoHotkey documentation for a list of supported color
;       names) or a 6-digit hex RGB color value.  Example color values: Blue or
;       FF00FA.  Important: Changing the color of the progress indicator bar is
;       not supported  when visual styles are enabled.  If needed, include the
;       -Theme option to disable visual styles for the progress control so that
;       the color of the progress bar indicator can be set.
;
;   Error - Set the progress bar to the Error state.  This will change the color
;       of the progress indicator bar to red.
;
;   Hide - Hide the progress bar.
;
;   [+-]Marquee - Add or remove the PBS_MARQUEE style to/from the progress
;       bar control.  See the *Marquee* section for more information.
;
;   MarqueeStart{UpdateTime} - Start or restart the marquee animation which will
;       continue until the the MarqueeStop command is received.  {UpdateTime}
;       (optional) is the time, in milliseconds, between marquee animation
;       updates.  If set to 0 or if not defined, the marquee animation will
;       update every 30 milliseconds.  This option is sometimes used in
;       combination with the Marquee option.  Ex: +Marquee MarqueeStart.
;
;   MarqueeStop - Stop the marquee animation.  Note: The animation stops
;       exactly where it was when this command is executed.  For this reason,
;       this option can used to show that the task/event/whatever has been
;       paused.  Use the MarqueeStart option to restart the animation.
;
;   Normal - Set the progress bar to the Normal state.  This will revert the
;       color of the progress indicator bar back to the original or default
;       color.  Note: Normal is the default state.  This option can be used to
;       return the progress bar from the Pause or Error state.
;
;   Pause - Set the progress bar to the Pause state.  This will change the color
;       of the progress indicator bar to yellow.  Note: Pause is just a progress
;       bar state.  It does not stop changes to the progress bar indicator.
;
;   Range - Set the range to be something other than 0 to 100.  After the word
;       Range, specify the minimum, a dash, and maximum. For example,
;       Range0-1000 would allow a numbers between 0 and 1000; Range-50-50 would
;       allow numbers between -50 and 50; and Range-10--5 would allow numbers
;       between -10 and -5.
;
;   Show - Show the progress bar if it was previously hidden.
;
;   [+-]Theme - Enable or disable the progress bar control's visual styles.
;       Note: Changing the visual styles may not always work as expected in all
;       situations or on all versions of Windows.  Be sure to test thoroughly.
;
;   A few notes...
;
;   If more than one command/option is used, use a space to delimit each option.
;   Ex: "-Theme cBlue Hide".
;
;   The options are processed in the order they appear.  Although rare, it's
;   possible that changing the order of the options can affect what changes are
;   made.  Be sure to test thoroughly.
;
; Border:
;
;   Preface: This information is based primarily on observation.  The Microsoft
;   documentation on this topic is limited.
;
;   If the progress bar uses visual styles, changes to the progress bar are
;   consistent when adding or removing the WS_BORDER style.  IMHO, the progress
;   bar looks better without a border if visual styles are used.
;
;   For a progress bar without visual styles, the appearance of progress bar may
;   look different depending on when the WS_BORDER style is added or removed.
;   If the WS_BORDER style is added when the progress bar is created, the
;   progress bar will contain a thin border.  This look may be desired because
;   without it, the progress bar may be indistinguishable from the background.
;   If the WS_BORDER style is added after the progress bar control has been
;   created, the progress bar will contain a thick border.  In most cases, the
;   thick border strongly separates the progress bar from the surrounding
;   window.  This look may be desirable for a progress bar that is displayed
;   within a status bar part.  Removing the WB_BORDER style can be a bit tricky.
;   If the progress bar contains a thin border, removing the WB_BORDER style is
;   effectively ignored, i.e. the thin border will remain.  If the progress bar
;   contains a thick border, removing the WB_BORDER style will convert the
;   progress bar to show a thin border instead.
;
;   These observations were made on one computer running Windows 7.  Your
;   results may vary.
;
; Marquee:
;
;   When the PBS_MARQUEE style is added to the progress bar control, the
;   progress bar is changed to "marquee" mode.  Use the +Marquee option
;   (p_Options parameter) to add the PBS_MARQUEE style.  In marquee mode, the
;   progress indicator does not grow in size but instead moves repeatedly along
;   the length of the bar, indicating activity without specifying what
;   proportion of the progress is complete.
;
;   Starting and stopping the marquee animation can be accomplished with the
;   MarqueeStart and MarqueeStop options (p_Options parameter).
;
;   An alternative to the MaqueeStart/MarqueeStop options is to periodically set
;   the progress position (p_ProgressPos parameter) to any value.  Every update
;   to the progress position will move the marquee animation one segment.  This
;   method requires a significant number of calls to the function and should be
;   avoided unless it provides significant value.
;
;   In most cases, the progress bar remains in marquee mode for the life of the
;   program.  However, the progress bar can be converted back to "normal" mode
;   by removing PBS_MARQUEE style.  Use the -Marquee option (p_Options
;   parameter) to remove the PBS_MARQUEE style.  This option can be useful if
;   the progress bar is used as both a standard progress bar and a marquee
;   progress bar.  Note: Although the progress bar can be used normally after
;   the -Marquee option is used, the previous progress bar indicator position
;   (if any) is not retained.  If needed, set the p_ProgressPos parameter to set
;   the progress bar indicator to the correct position.
;
; Position and Size:
;
;   The position (screen coordinates) and size (width and height) of the
;   progress bar is determined when the control is created.  The size of
;   the progress bar is updated (if needed) every time the function is
;   called.
;
;   The width of the progress bar is set to width of the bounding rectangle of
;   the status bar part.  With the exception of the right-most (or only) part,
;   the progress bar will cover the part's right border.  The height of progress
;   bar is set to the height of the bounding rectangle of the status bar part.
;
; Remarks:
;
;   The progress bar is visible by default.  Use the "Hide" option (p_Options
;   parameter) to initially hide the control.
;
;   Although this function creates the progress bar controls used by this
;   function, they are never destroyed by this function.  Ownership of the
;   progress bars are assigned to the specified status bars.  They are
;   automatically destroyed when the status bar is destroyed which occurs when
;   the parent window is destroyed.  Failing that, they are automatically
;   destroyed when the script ends.
;
; Observations:
;
;   Removing the visual styles for the progress bar and then turning the marquee
;   mode on appears to work correctly.  However, restoring the visual styles and
;   then trying to enable the marquee mode again does not work as expected.  For
;   some reason (at least on my PC), the progress bar will revert back to the
;   non-themed style.
;
; Credit:
;
;   This function is a reboot of the SB_SetProgress function by *DerRaphael*.
;   Although much of the function has been rewritten and many new features have
;   been added, much of the original core design and functionally remains.
;   Sincere thanks to DerRaphael for sharing his/her code.
;
;   Original post :
;   * https://autohotkey.com/board/topic/34593-stdlib-sb-setprogress/
;
;-------------------------------------------------------------------------------
SBAR_ProgressBar(hSB,p_ProgressPos,p_PartNumber,p_Options:="")
    {
    Static Dummy44679574
          ,s_PBTable
                ;-- Container for all used hSB:p_PartNumber:hProgress values

          ;-- Progress bar styles
          ,PBS_SMOOTH :=0x1
          ,PBS_MARQUEE:=0x8

          ;-- Progress bar state flags
          ,PBST_NORMAL:=0x1
          ,PBST_ERROR :=0x2
          ,PBST_PAUSE :=0x3

          ;-- Window styles
          ,WS_BORDER :=0x800000
          ,WS_VISIBLE:=0x10000000
          ,WS_CHILD  :=0x40000000

          ;-- Messages
          ,PBM_SETPOS     :=0x402                       ;-- WM_USER + 2
          ,PBM_SETRANGE32 :=0x406                       ;-- WM_USER + 6
          ,PBM_GETPOS     :=0x408                       ;-- WM_USER + 8
          ,PBM_SETBARCOLOR:=0x409                       ;-- WM_USER + 9
          ,PBM_SETMARQUEE :=0x40A                       ;-- WM_USER + 10
          ,PBM_SETSTATE   :=0x410                       ;-- WM_USER + 16
          ,PBM_SETBKCOLOR :=0x2001                      ;-- CCM_First + 1

    ;-- Get the number of parts
    ;   Note: This also verifies hSB, i.e. the handle to the status bar
    if not l_NumberOfParts:=SBAR_GetPartsCount(hSB)
        {
        outputdebug,
           (ltrim join`s
            Function: %A_ThisFunc% -
            Number of parts not found.  Processing stopped.
           )

        Return False
        }

    if (p_PartNumber>l_NumberOfParts)
        {
        outputdebug,
           (ltrim join`s
            Function: %A_ThisFunc% -
            Specified part number (%p_PartNumber%) is greater than the number of
            of parts (%l_NumberOfParts%). Processing stopped.
           )

        Return False
        }

    ;-- Get the bounding rectangle of the part
    SBAR_GetPartRect(hSB,p_PartNumber,l_RECTLeft,l_RECTTop,l_RECTRight,l_RECTBottom)

    ;-- Collect the handle to the progress bar or create the progress bar
    if InStr(s_PBTable,hSB . ":" . p_PartNumber . ":")
        {
        hProgress:=(RegExMatch(s_PBTable,hSB . "\:" . p_PartNumber . "\:(?P<hWnd>([^,]+|.+))",p)) ? phWnd:

        ;-- Adjust the size of the progress bar
        ;   Only the width and height are updated (for now)
        ControlMove,,,,l_RECTRight-l_RECTLeft,l_RECTBottom-l_RECTTop,ahk_id %hProgress%
        }
      else
        {
        ;-- Default styles
        l_Style:=WS_CHILD|WS_VISIBLE|PBS_SMOOTH

        ;-- Process style options in order (from left to right)
        Loop Parse,p_Options,%A_Space%
            {
            if A_LoopField is Space
                Continue

            ;-- Break it down
            l_Option      :=A_LoopField
            l_OptionPrefix:="+"
            if (SubStr(A_LoopField,1,1)="+" or SubStr(A_LoopField,1,1)="-")
                {
                l_OptionPrefix:=SubStr(A_LoopField,1,1)
                StringTrimLeft l_Option,l_Option,1
                }

            ;-- Border
            if (l_Option="Border")
                {
                if (l_OptionPrefix="+")
                    l_Style|=WS_BORDER
                  else
                    l_Style^=WS_BORDER

                Continue
                }

            ;-- Hide
            if (l_Option="Hide")
                {
                l_Style^=WS_VISIBLE
                Continue
                }

            ;-- Show
            if (l_Option="Show")
                {
                l_Style|=WS_VISIBLE
                Continue
                }
            }

        ;-- Remove all style options from p_Options
        p_Options:=RegExReplace(A_Space . p_Options,"i)\s[+-]?Border\b",A_Space)
        p_Options:=RegExReplace(A_Space . p_Options,"i)\s[+-]?Hide\b",A_Space)
        p_Options:=RegExReplace(A_Space . p_Options,"i)\s[+-]?Show\b",A_Space)
        p_Options:=Trim(p_Options)

        ;-- Create progress control
        hProgress:=DllCall("CreateWindowEx"
            ,"UInt",0                               ;-- dwExStyle
            ,"Str","msctls_progress32"              ;-- lpClassName
            ,"Ptr",0                                ;-- lpWindowName
            ,"UInt",l_Style                         ;-- dwStyle
            ,"Int",l_RECTLeft                       ;-- x
            ,"Int",l_RECTTop                        ;-- y
            ,"Int",l_RECTRight-l_RECTLeft           ;-- nWidth
            ,"Int",l_RECTBottom-l_RECTTop           ;-- nHeight
            ,"Ptr",hSB                              ;-- hWndParent
            ,"UInt",0                               ;-- hMenu
            ,"UInt",0                               ;-- hInstance
            ,"UInt",0)                              ;-- lpParam

        ;-- Add to s_PBTable
        s_PBTable.=(StrLen(s_PBTable) ? ",":"") . hSB . ":" . p_PartNumber . ":" . hProgress
        }

    ;-- Process options in order (from left to right)
    Loop Parse,p_Options,%A_Space%
        {
        if A_LoopField is Space
            Continue

        ;-- Break it down
        l_Option      :=A_LoopField
        l_OptionPrefix:="+"
        if (SubStr(A_LoopField,1,1)="+" or SubStr(A_LoopField,1,1)="-")
            {
            l_OptionPrefix:=SubStr(A_LoopField,1,1)
            StringTrimLeft l_Option,l_Option,1
            }

        ;-- Background color
        if (SubStr(l_Option,1,10)="Background")
            {
            l_BKColor:=SubStr(l_Option,11)
            if (StrLen(l_BKColor)=6 and RegExMatch(l_BKColor,"i)([0-9a-f]{6})"))
                l_BKColor:="0x" . l_BKColor
             else if l_BKColor is Alpha
                {
                ;-- Convert if supported color name (not case sensitive)
                l_BKColor:=SBAR_ColorName2RGB(l_BKColor)
                }

            if (l_BKColor+0<>"")
                {
                ;-- Convert color to BGR
                l_BKColor:=(l_BKColor&0xFF)<<16|((l_BKColor>>8)&0xFF)<<8|l_BKColor>>16

                ;-- Set the background color
                SendMessage PBM_SETBKCOLOR,0,l_BKColor,,ahk_id %hProgress%
                Continue
                }
            }

        ;-- Border
        if (l_Option="Border")
            {
            ;-- Get the current position of the progress bar
            SendMessage PBM_GETPOS,0,0,,ahk_id %hProgress%
            l_CurrentPos:=ErrorLevel<<32>>32  ;-- Convert UInt to Int

            ;-- Add or remove border
            WinSet Style,%l_OptionPrefix%%WS_BORDER%,ahk_id %hProgress%
            if p_ProgressPos is not Integer
                p_ProgressPos:=l_CurrentPos

            Continue
            }

        ;-- Bar color
        if (SubStr(l_Option,1,1)="c")
            {
            l_BarColor:=SubStr(l_Option,2)
            if (StrLen(l_BarColor)=6 and RegExMatch(l_BarColor,"i)[0-9a-f]{6}"))
                l_BarColor:="0x" . l_BarColor
             else if l_BarColor is Alpha
                {
                ;-- Convert if supported color name (not case sensitive)
                l_BarColor:=SBAR_ColorName2RGB(l_BarColor)
                }

            if (l_BarColor+0<>"")
                {
                ;-- Convert color to BGR
                l_BarColor:=(l_BarColor&0xFF)<<16|((l_BarColor>>8)&0xFF)<<8|l_BarColor>>16

                ;-- Set background color
                SendMessage PBM_SETBARCOLOR,0,l_BarColor,,ahk_id %hProgress%
                Continue
                }
            }

        ;-- Commands
        if (l_Option="Error")
            {
            SendMessage PBM_SETSTATE,PBST_ERROR,0,,ahk_id %hProgress%
            Continue
            }

        if (l_Option="Hide")
            {
            Control Hide,,,ahk_id %hProgress%
            Continue
            }

        if (l_Option="Marquee")
            {
            WinSet Style,%l_OptionPrefix%%PBS_MARQUEE%,ahk_id %hProgress%
            Continue
            }


        if (SubStr(l_Option,1,12)="MarqueeStart")
            {
            l_MarqueeTime:=0
            t_MarqueeTime:=SubStr(l_Option,13)
            if t_MarqueeTime is Integer
                l_MarqueeTime:=t_MarqueeTime+0

            SendMessage PBM_SETMARQUEE,True,l_MarqueeTime,,ahk_id %hProgress%
            Continue
            }

        if (l_Option="MarqueeStop")
            {
            SendMessage PBM_SETMARQUEE,False,0,,ahk_id %hProgress%
            Continue
            }

        if (l_Option="Normal")
            {
            SendMessage PBM_SETSTATE,PBST_NORMAL,0,,ahk_id %hProgress%
            Continue
            }

        if (l_Option="Pause")
            {
            SendMessage PBM_SETSTATE,PBST_PAUSE,0,,ahk_id %hProgress%
            Continue
            }

        if (SubStr(l_Option,1,5)="Range")
            {
            RegExMatch(l_Option,"[+-]*[0-9]+",l_LoRange,6)
            RegExMatch(l_Option,"[+-]*[0-9]+",l_HiRange,6+StrLen(l_LoRange)+1)
            if (l_OptionPrefix<>"-" and l_HiRange>l_LoRange)
                SendMessage PBM_SETRANGE32,l_LoRange,l_HiRange,,ahk_id %hProgress%
             else  ;-- Reset to default range
                SendMessage PBM_SETRANGE32,0,100,,ahk_id %hProgress%
           }

        if (l_Option="Show")
            {
            Control Show,,,ahk_id %hProgress%
            Continue
            }

        if (l_Option="Theme")
            {
            if (l_OptionPrefix="+")
                DllCall("uxtheme\SetWindowTheme","Ptr",hProgress,"Str","","Ptr",0)
             else
                DllCall("uxtheme\SetWindowTheme","Ptr",hProgress,"Ptr",0,"Str","")

            Continue
            }
        }

    ;-- Update the progress position
    ;   Programming note: The progress position is updated last because some
    ;   options (p_Options parameter) can cause the p_ProgressPos value to
    ;   change.
    if p_ProgressPos is Integer
        SendMessage PBM_SETPOS,p_ProgressPos,0,,ahk_id %hProgress%

    Return hProgress
    }
