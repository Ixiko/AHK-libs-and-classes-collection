;-- v1.0
;         + small documentation clarification by iPhilip (2010-06-19)
;         + small changes to make into library by Rapte_Of_Suzaku (2010-11-03)
;-- Important: If you #Include this script, you should do so AFTER the 
;   Auto-Execute section of a script. (Because this code includes a subroutine)
;
;*******************
;*                 *
;*    Splash On    *
;*                 *
;*******************
;
;   Description
;   ===========
;   This function generates a borderless text Splash window and is used in
;   conjunction with the Splash_Off, Splash_Preserve, and Splash_Off_Timer
;   functions/subroutines.
;
;
;
;   Parameters
;   ==========
;
;       Name                    Description
;       ----                    -----------
;       p_MainText              Main text. [Optional]  The default is null.
;
;       p_SubText               Sub text. [Optional]  The default is null.
;
;
;       p_MinimumSplashTime     Minimum time (in seconds) the splash window is
;                               to be displayed UNLESS another SplashOn call is made,
;                               in which case the current splash window is turned off.
;                               [Optional] The default is 0.85 seconds.
;
;                               If p_MinimumSplashTime is a negative value
;                               (Ex: -3), this function will automatically call
;                               the SplashOff function using the absolute value
;                               value of this parameter as the minimum splash
;                               time.  This feature is useful when you know
;                               exactly how long you want the splash window to
;                               display.  It also removes the need for a
;                               separate call to the SplashOff function.
;                               If negative, p_MinimumSplashTime represents the
;                               maximum time the spash window is to be displayed
;                               UNLESS another SplashOn call is made, in which case
;                               the current splash window is turned off.
;
;       p_Font                  Font Name.  [Optional]  The default is null (the
;                               system default font is used).
;
;                               This font is used for both the MainText (top
;                               line(s)) and SubText (bottom line(s)).
;                               
;
;       p_Options               See the "Splash Options" section for more
;                               information.
;
;
;
;   Global Variables
;   ================
;
;       Name                    Description
;       ----                    -----------
;       $Splash_StartTime       This variable contains the time (A_TickCount)
;                               that the splash window was created.
;
;       $Splash_MinimumTime     This variable contains minimum time
;                               (developer-defined or default) that the splash
;                               window should be displayed.
;
;
;
;   Splash Options
;   ==============
;   The p_Options parameter is used to set any SplashImage options that are not
;   set by default.  If more than one option is defined, separate each option by
;   a space.  For example:
;
;       "CWBlack CTYellow"
;
;   For a complete list of SplashImage options, see the  AutoHotkey
;   documentation (keyword: SplashImage).
;
;
;   The following SplashImage options are automatically included by default:
;
;       Name                    Description
;       ----                    -----------
;       b2                      No title bar, dialog style border
;
;       W{Function determined}  Splash window width.  The size doesn't include
;                               border.
;
;
;   If not explicitly defined, the following SplashImage options/values are
;   included:
;
;       Name                    Description/Value
;       ----                    -----------------
;       FM10                    Font size for MainText - 10
;       FS12                    Font size for SubText - 12
;       WM600                   Font weight for MainText - 600 (Bold)
;       WS400                   Font weight for SubText - 400 (Normal)
;
;
;   In addition to the standard X/Y options, the following options are
;   available to position the Splash window on the screen:
;
;       Name                    Description/Value
;       ----                    -----------------
;       XL or XLeft             Left side of the screen.  Not necessarily the
;                               same as X0.
;
;       XM or XMiddle           Horizontally centered on the screen.  This is
;                               SplashImage default.
;
;       XR or XRight            Right side of the screen.
;
;       YT or YTop              Top of the screen.  Not necessarily the same as
;                               Y0.
;
;       YM or YMiddle           Vertically centered on the screen.  This is
;                               SplashImage default.
;
;       YB or YBottom           Bottom of the screen.
;
;
;   The preceding X/Y options are calculated based on the work area for the
;   primary monitor.  The work area excludes the taskbar and other registered
;   desktop toolbars.
;   
;
;
;   Calls To Other Functions
;   ========================
;   Splash_Off
;
;
;
;   Calls To Subroutines
;   ====================
;   Splash_Off_Timer
;
;
;
;   Programming Notes
;   =================
;   o   This function creates a temporary GUI window to ascertain the width of
;       the SplashImage window.  The function uses the first GUI window that is
;       available in the 71 to 99 range. If an available window cannot be found,
;       an error message is displayed.
;
;   o   So as not to interfere with any other SplashImage windows, an
;       arbitrarily selected SplashImage window number (8) is used.  Change if
;       needed.  See the AutoHotkey documentation (keyword: SplashImage) for
;       more information.
;
;
;-------------------------------------------------------------------------------
Splash(p_MainText="" ,p_SubText="" ,p_MinimumSplashTime="" ,p_Font="" ,p_Options="")
{
    global $Splash_StartTime, $Splash_MinimumTime
	
    ;[==============]
    ;[  Initialize  ]
    ;[==============]
    l_DetectHiddenWindows:=A_DetectHiddenWindows
    DetectHiddenWindows On

    l_MainTextFontSize=10
    l_MainTextFontWeight=600
    l_SubTextFontSize=12
    l_SubTextFontWeight=400


    ;[==============]
    ;[  Parameters  ]
    ;[==============]
    ;-- p_MinimumSplashTime
    if p_MinimumSplashTime is not Number
        p_MinimumSplashTime=0


    ;-- p_Font
    p_Font=%p_Font%  ;-- AutoTrim


    ;[=======================]
    ;[  Extract font values  ]
    ;[  from p_Options       ]
    ;[=======================]
    loop parse,p_Options,%A_Space%
        {
        if A_LoopField is Space
            continue

        ;-- MainText options
        if instr(A_LoopField,"FM")=1
            if SubStr(A_LoopField,3) is Number
                StringTrimLeft l_MainTextFontSize,A_LoopField,2

        if instr(A_LoopField,"WM")=1
            if SubStr(A_LoopField,3) is Number
                StringTrimLeft l_MainTextFontWeight,A_LoopField,2


        ;-- SubText options
        if instr(A_LoopField,"FS")=1
            if SubStr(A_LoopField,3) is Number
                StringTrimLeft l_SubTextFontSize,A_LoopField,2

        if instr(A_LoopField,"WS")=1
            if SubStr(A_LoopField,3) is Number
                StringTrimLeft l_SubTextFontWeight,A_LoopField,2
        }


    ;[=============]
    ;[  p_Options  ]
    ;[=============]
    p_Options=%p_Options%  ;-- AutoTrim
    p_Options:="b2 " . p_Options

    ;-- If not explicitly defined, load font size just in case defaults don't
    ;   match system default
    ;
    if instr(p_Options," FM")=0
        p_Options:=p_Options . " FM" . l_MainTextFontSize

    if instr(p_Options," FS")=0
        p_Options:=p_Options . " FS" . l_SubTextFontSize


    ;-- Update/Simplify X/Y options
    StringReplace p_Options,p_Options,%A_Space%XLeft,%A_Space%XL,All
    StringReplace p_Options,p_Options,%A_Space%XMiddle,,All
    StringReplace p_Options,p_Options,%A_Space%XM,,All
    StringReplace p_Options,p_Options,%A_Space%XRight,%A_Space%XR,All
   
    StringReplace p_Options,p_Options,%A_Space%YTop,%A_Space%YT,All
    StringReplace p_Options,p_Options,%A_Space%YMiddle,,All
    StringReplace p_Options,p_Options,%A_Space%YM,,All
    StringReplace p_Options,p_Options,%A_Space%YBottom,%A_Space%YB,All


    ;[=====================]
    ;[  Preliminary stuff  ]
    ;[=====================]
    ;-- 1st run?
    if $Splash_MinimumTime is Space
        {
        $Splash_MinimumTime=850  ;-- Default in milliseconds.  Adjust if desired
        $Splash_StartTime=0
        }


    ;-- Turn off the Splash_Off timer
    SetTimer Splash_Off_Timer,off


    ;-- Minimum splash time defined?
    if p_MinimumSplashTime
        {
        $Splash_MinimumTime:=p_MinimumSplashTime*1000
        $Splash_StartTime=0
        }


    ;-- Reset start time?
    if not $Splash_StartTime
        $Splash_StartTime:=A_TickCount


    ;[=========================]
    ;[  Find available window  ]
    ;[   (Starting with 71)    ]
    ;[=========================]
    l_GUI=71
    loop
        {
        ;-- Window available?
        gui %l_GUI%:+LastFoundExist
        IfWinNotExist
            break

        ;-- Nothing available?
        if l_GUI=99
            {
            msgbox,262160,Splash Error,
               (ltrim
                Unable to create Splash temporary GUI.  %A_Space%
                GUI windows 71 to 99 are already in use.
               )

            return
            }

        ;-- Increment window
        l_GUI++
        }


    ;[==========================]
    ;[  Determine splash width  ]
    ;[==========================]
    ;-- Build temporary window to determine maximum width
    gui %l_GUI%:Margin,0,0
    gui %l_GUI%:Font,s%l_MainTextFontSize% w%l_MainTextFontWeight%,%p_Font%
    gui %l_GUI%:Add,Text,,%p_MainText%
    gui %l_GUI%:Font,s%l_SubTextFontSize% w%l_SubTextFontWeigth%
    gui %l_GUI%:Add,Text,,%p_SubText%
    gui %l_GUI%:Show,Hide  ;-- Render but don't show


    ;-- How wide is it?
    gui %l_GUI%:+LastFound
    WinGetPos ,,,l_SplashImageWidth,,% "ahk_id " . WinExist()
    gui %l_GUI%:Destroy


    ;-- Add some breathing room
    l_SplashImageWidth:=l_SplashImageWidth+60


    ;-- Too wide?
    l_MaxSplashImageWidth:=round(A_ScreenWidth*0.95)
    if (l_SplashImageWidth>l_MaxSplashImageWidth)
        l_SplashImageWidth:=l_MaxSplashImageWidth
   

    ;[==============]
    ;[  Splash it!  ]
    ;[==============]
    l_BreakLoop:=false
    loop 2
        {
        ;-- Create working copy of p_Options
        l_Options:=p_Options


        ;-- Function-specific X/Y options?
        if (instr(p_Options,A_Space . "XL")
        or  instr(p_Options,A_Space . "XR")
        or  instr(p_Options,A_Space . "YT")
        or  instr(p_Options,A_Space . "YB"))
            {
            StringReplace l_Options,l_Options,%A_Space%XL,,All
            StringReplace l_Options,l_Options,%A_Space%XR,,All
            StringReplace l_Options,l_Options,%A_Space%YT,,All
            StringReplace l_Options,l_Options,%A_Space%YB,,All
            l_Options:=l_Options . " Hide"
            }
         else
            l_BreakLoop:=true


        ;-- Splash using working copy of p_Options
        SplashImage 8:,W%l_SplashImageWidth% %l_Options%
            ,%p_SubText%
            ,%p_MainText%
            ,SplashWindow
            ,%p_Font%


        ;-- Are we done yet?
        if l_BreakLoop
            break


        ;-- Collect splash window width and height
        WinGetPos ,,,l_SplashWindowWidth,l_SplashWindowHeight,SplashWindow


        ;-- Collect work area dimensions for primary monitor
        SysGet l_MonitorWorkArea,MonitorWorkArea


        ;-- Update X/Y positions
        StringReplace p_Options
            ,p_Options
            ,%A_Space%XL
            ,% " X" . l_MonitorWorkAreaLeft
            ,All
       
        StringReplace p_Options
            ,p_Options
            ,%A_Space%XR
            ,% " X" . l_MonitorWorkAreaRight-l_SplashWindowWidth
            ,All
       
        StringReplace p_Options
            ,p_Options
            ,%A_Space%YT
            ,% " Y" . l_MonitorWorkAreaTop
            ,All

        StringReplace p_Options
            ,p_Options
            ,%A_Space%YB
            ,% " Y" . l_MonitorWorkAreaBottom-l_SplashWindowHeight
            ,All
        }


    ;-- Minor delay to give the window a chance to render
    sleep 1


    ;[===================]
    ;[  Auto Splash_Off?  ]
    ;[===================]
    if $Splash_MinimumTime<0
        {
        $Splash_MinimumTime:=abs($Splash_MinimumTime)
        Splash_Off()
        }


    ;[================]
    ;[  Housekeeping  ]
    ;[================]
    DetectHiddenWindows %l_DetectHiddenWindows%


    ;-- Return to sender
    return
    }



;********************
;*                  *
;*    Splash Off    *
;*                  *
;********************
;
;
;   Description
;   ===========
;   This function performs one of the following tasks:
;
;    1) If Splash_Preserve is TRUE (explicitly or by default), turn off
;       the Splash_Off timer.  Do nothing else.
;
;    2) If the minimum splash time has elapsed, turn off (destroy) the splash
;       window created by the Splash function.
;
;    3) If the minimum splash time has NOT elapsed, set a timer to turn off
;       (destroy) the splash window created by the Splash function.
;
;
;
;   Parameters
;   ==========
;
;       Name                    Description
;       ----                    -----------
;       p_Splash_Preserve  Preserve Splash Window.  [Boolean, Optional]
;                               The default is FALSE or the value it was set to
;                               last.
;
;
;
;   Calls To Other Functions
;   ========================
;   Splash_Preserve
;
;
;
;   Calls To Subroutines
;   ====================
;   Splash_Off_Timer
;
;
;-------------------------------------------------------------------------------
Splash_Off(p_Splash_Preserve="")   {
    global $Splash_MinimumTime, $Splash_StartTime


    ;-- Turn off Splash_Off timer
    SetTimer Splash_Off_Timer,off
   

    ;-- Preserve splash?
    if Splash_Preserve(p_Splash_Preserve)
        return

   
    ;-- Compute elapsed time.  Set timer if necessary
    l_SplashTimeElapsed:=A_TickCount-$Splash_StartTime
    if (l_SplashTimeElapsed<$Splash_MinimumTime)
        {
        l_Splash_OffTimer:=$Splash_MinimumTime-l_SplashTimeElapsed
        SetTimer Splash_Off_Timer,%l_Splash_OffTimer%
        }
      else
         ;-- Destroy splash window
         SplashImage 8:Off
   

    ;-- Reset to defaults
    $Splash_MinimumTime=850  ;-- Default in milliseconds.  Adjust if desired
    $Splash_StartTime=0
   

    ;-- Return to sender
    return
    }



;**************************
;*                        *
;*    Splash Off Timer    *
;*                        *
;**************************
Splash_Off_Timer:
SetTimer Splash_Off_Timer,Off
SplashImage 8:Off
return



;********************************
;*                              *
;*    Preserve Splash Window    *
;*                              *
;********************************
;
;
;   Description
;   ===========
;   This function sets and/or returns the current boolean value of
;   s_Splash_Preserve.
;
;   This function is called independently to set s_Splash_Preserve and is
;   used by the Splash_Off function to determine if the splash window should be
;   preserved or not.
;
;
;
;   Parameters
;   ==========
;
;       Name                    Description
;       ----                    -----------
;       p_Splash_Preserve  Determines whether the splash window is
;                               preserved or not.  [Optional]  The default is
;                               FALSE or whatever it was set to last.
;
;                               Set to TRUE to preserve the splash window.  Set
;                               to FALSE to no longer preserve the splash
;                               window.
;
;
;   Calls To Other Functions
;   ========================
;   (None)
;
;
;-------------------------------------------------------------------------------
Splash_Preserve(p_Splash_Preserve="")     {
    static s_Splash_Preserve

    ;-- Parameter?
    if p_Splash_Preserve is not Space
        s_Splash_Preserve:=p_Splash_Preserve


    ;-- Return to sender
    if s_Splash_Preserve
        return true
     else
        return false
    }