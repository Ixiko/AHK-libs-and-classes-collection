;------------------------------
;
; Function: SBAR_AVI
;
; Description:
;
;   Create and manage an animation control for a status bar part.
;
; Type:
;
;   Add-on function to the SBAR library.
;
; Parameters:
;
;   hSB - The handle to the status bar.
;
;   p_PartNumber - 1-based index of the status bar part that will contain the
;       animation control.
;
;   p_Options - See the *Options* section for more information.
;
;   p_aviFile - Path to an AVI file (Ex: "MyAnimation.avi") or to a resource
;       that contains an AVI animation (Ex: "shell32.dll").  Defining a value
;       for this parameter is only necessary if the Open option (p_Options
;       parameter) is specified.  Defining a value for this parameter is
;       optional when the Close option is specified.  See <SBAR_AVI_Close> for
;       more information.
;
;   p_aviRef - AVI resource identifier. [Optional] If p_aviFile contains a
;       DLL file (Ex: "wiadefui.dll"), set to the identifier of the desired
;       animation (Ex: 1253), otherwise do not specify or set to null (the
;       default).  Do not set to 0 (zero) unless it is the desired identifier.
;
; Returns:
;
;   The handle to the animation control if successful, otherwise FALSE.
;
; Calls To Other Functions:
;
; * <SBAR_ColorName2RGB>
; * <SBAR_GetPartRect>
; * <SBAR_GetPartsCount>
;
; Options:
;
;   The p_Options parameter contains commands and options for the animation
;   control.  The following options are supported:
;
;   [+-]AutoPlay - Add or remove the ACS_AUTOPLAY style to/from the animation
;       control.  See the *Styles* section for more information.
;
;   [+-]Border - Add or remove the WS_BORDER border style to/from the animation
;       control.
;
;   [+-]Center - Add or remove the ACS_CENTER style to/from the animation
;       control.  See the *Styles* section for more information.
;
;   Close - Close the AVI file that was previously opened for the animation
;       control, if any.  Note: This command is unnecessary in many cases.  See
;       <SBAR_AVI_Close> for more information.
;
;   Destroy - [Debug/Testing] Destroy the animation control that was created for
;       the status bar part.  Note: This command is available for debug/testing.
;       It not needed in a production environment because the control is
;       automatically destroyed when the parent window is destroyed.
;
;   Hide - Hide the animation control.
;
;   Open - Open the AVI clip and display the first frame.  The p_aviFile
;       parameter must contain a valid file.  See <SBAR_AVI_Open> for more
;       information.
;
;   Pause - Stop playback if playing.
;
;   PauseResume - Stop playback if playing, otherwise start or resume
;       playback.
;
;   Play - Play the clip from the beginning.
;
;   Resume - Resume playback if stopped.
;
;   Show - Show the animation control if it was previously hidden.
;
;   Stop - Stop playback.
;
;   [+-]Transparent - Add or remove the ACS_TRANSPARENT style to/from the
;       animation control.  See the *Styles* section for more information.
;
;   A few notes...
;
;   If more than one command/option is used, use a space to delimit each option.
;   Ex: "Open -AutoPlay Hide".
;
;   If the animation control for the status bar part does not exist, style
;   options are processed first in the order they appear (i.e. from left to
;   right) and then everything else is processed in the order they appear.
;   Otherwise (i.e. the animation control for the status bar part already
;   exists), the options are processed in the order they appear.  Changing the
;   order of the options can affect what changes are made.  Be sure to test
;   thoroughly.
;
; Position and Size:
;
;   The position (screen coordinates) and size (width and height) of the
;   animation control is determined when the control is created.  The size of
;   the animation control is updated (if needed) every time the function is
;   called.
;
;   The width of the animation control is set to width of the bounding rectangle
;   of the status bar part minus the width of the border between rectangles.
;   The exception is the right-most (or only part) where the width of the
;   animation control is set to width of the bounding rectangle of the part.
;   These calculation will ensure that the control will not cover the part's
;   right border.
;
;   To determine the part width needed for a particular animation clip, first
;   determine the width of the clip frame.  For all parts except for the
;   right-most part, the part width should be a least the width of the clip
;   frame plus the width of the border between rectangles.  For the right-most
;   (or only) part the width should be at least the width of the clip frame. The
;   part width can be determined by calling <SBAR_GetPartWidth> and the width of
;   the border between rectangles can be determined by calling
;   <SBAR_GetBorders>.  If space is at a premium, check the animation clip
;   carefully.  Sometimes a clip may have unused (i.e. blank/transparent) space
;   on the left and/or right side of the clip.  If this is the case, the width
;   of the part can be reduced by the wasted space.
;
;   The height of the animation control is limited to the height of the status
;   part height.  This can be a major stumbling block for using many
;   out-of-the-box animation clips because most are taller than most status
;   bars.  <SBAR_SetMinHeight> can be used to force the status bar to
;   accommodate the status bar font and/or the height of the desired animation
;   clip but there is always the danger that increasing the status bar height
;   will take up too much screen real estate and will make the status bar look
;   clunky.  The best approach is to limit the animation clips to the ones that
;   fit into a standard status bar or the ones that are acceptable when they are
;   shown clipped.  Another alternative is to create custom animation clips for
;   the application.
;
; Styles:
;
;   There are three window styles specific to the animation control.  The
;   ACS_AUTOPLAY style will start playing the AVI clip as soon as it is opened,
;   the ACS_CENTER style will center the clip within the animation control, and
;   the ACS_TRANSPARENT style will match an animation's background color to that
;   of the underlying window, creating a "transparent" background.  All three of
;   these styles are added by default by this function.  Use the -AutoPlay,
;   -Center, and/or -Transparent options (p_Options parameter) to override one
;   or more of these defaults.
;
;   These styles can be added or removed at any time.  However, adding or
;   removing the ACS_AUTOPLAY or ACS_CENTER styles has no effect on the
;   animation control if an AVI clip is open.  If needed, close and reopen the
;   clip to see the effects of the style change.
;
; Remarks:
;
;   The animation control is visible by default.  Use the "Hide" option
;   (p_Options parameter) to initially hide the control.
;
;   Although this function creates the animation controls used by this function,
;   they are (usually) not destroyed by this function.  Ownership of the
;   animation controls are assigned to the specified status bars.  They are
;   automatically destroyed when the status bar is destroyed which occurs when
;   the parent window is destroyed.  Failing that, they are automatically
;   destroyed when the script ends.
;
; Credit:
;
;   The code for this add-on originated from code posted by *daonlyfreez* and
;   *PhiLho*.  daonlyfreez's post can be found <here at
;   http://www.autohotkey.com/board/topic/12418-add-an-avi-to-your-ahk-gui-createwindow-aviahk-lib/>.
;   PhiLho's Control_AVI library post can be found <here at
;   http://www.autohotkey.com/board/topic/12418-add-an-avi-to-your-ahk-gui-createwindow-aviahk-lib/page-4#entry84181>.
;   This add-on includes a number of enhancements, bug fixes, and customizations
;   for the status bar but would not have been possible without these
;   contributors.
;
;-------------------------------------------------------------------------------
SBAR_AVI(hSB,p_PartNumber,p_Options:="",p_aviFile:="",p_aviRef:="")
    {
    Static Dummy25513702
          ,s_AVITable
                ;-- Container for all used hSB:p_PartNumber:hAVI

          ;-- Animation control styles
          ,ACS_CENTER:=0x1
                ;-- Centers the animation in the animation control's window.

          ,ACS_TRANSPARENT:=0x2
                ;-- Allows the animation's background color to match the
                ;   underlying window.

          ,ACS_AUTOPLAY:=0x4
                ;-- Starts playing the animation as soon as the AVI clip is
                ;   opened.

          ;-- Window styles
          ,WS_BORDER :=0x800000
          ,WS_VISIBLE:=0x10000000
          ,WS_CHILD  :=0x40000000

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

    ;-- Get the status bar borders
    SBAR_GetBorders(hSB,l_HorzBorderW,l_VertBorderW,l_RectBorderW)

    ;-- Collect the handle to the animation control or create the control
    if InStr(s_AVITable,hSB . ":" . p_PartNumber . ":")
        {
        hAVI:=(RegExMatch(s_AVITable,hSB . "\:" . p_PartNumber . "\:(?P<hWnd>([^,]+|.+))",p)) ? phWnd:

        ;-- Adjust the size of the animation control
        ;   Only the width and height are updated (for now)
        l_Width:=l_RECTRight-l_RECTLeft
        if (p_PartNumber<l_NumberOfParts)
            l_Width-=l_RectBorderW

        ControlMove,,,,l_Width,l_RECTBottom-l_RECTTop,ahk_id %hAVI%
        }
      else
        {
        ;-- Default styles
        l_Style:=WS_CHILD|WS_VISIBLE|ACS_TRANSPARENT|ACS_CENTER|ACS_AUTOPLAY

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

            ;-- Autoplay
            if (l_Option="Autoplay")
                {
                if (l_OptionPrefix="+")
                    l_Style|=ACS_AUTOPLAY
                  else
                    l_Style^=ACS_AUTOPLAY

                Continue
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

            ;-- Center
            if (l_Option="Center")
                {
                if (l_OptionPrefix="+")
                    l_Style|=ACS_CENTER
                  else
                    l_Style^=ACS_CENTER

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

            ;-- Transparent
            if (l_Option="Transparent")
                {
                if (l_OptionPrefix="+")
                    l_Style|=ACS_TRANSPARENT
                  else
                    l_Style^=ACS_TRANSPARENT

                Continue
                }
            }

        ;-- Remove all style options from p_Options
        p_Options:=RegExReplace(A_Space . p_Options,"i)\s[+-]?Autoplay\b",A_Space)
        p_Options:=RegExReplace(A_Space . p_Options,"i)\s[+-]?Border\b",A_Space)
        p_Options:=RegExReplace(A_Space . p_Options,"i)\s[+-]?Center\b",A_Space)
        p_Options:=RegExReplace(A_Space . p_Options,"i)\s[+-]?Hide\b",A_Space)
        p_Options:=RegExReplace(A_Space . p_Options,"i)\s[+-]?Show\b",A_Space)
        p_Options:=RegExReplace(A_Space . p_Options,"i)\s[+-]?Transparent\b",A_Space)
        p_Options:=Trim(p_Options)

        ;-- Determine the width
        l_Width:=l_RECTRight-l_RECTLeft
        if (p_PartNumber<l_NumberOfParts)
            l_Width-=l_RectBorderW

        ;-- Create the animation control
        hAVI:=DllCall("CreateWindowEx"
            ,"UInt",0                               ;-- dwExStyle
            ,"Str","SysAnimate32"                   ;-- lpClassName
            ,"Ptr",0                                ;-- lpWindowName
            ,"UInt",l_Style                         ;-- dwStyle
            ,"Int",l_RECTLeft                       ;-- x
            ,"Int",l_RECTTop                        ;-- y
            ,"Int",l_Width                          ;-- nWidth
            ,"Int",l_RECTBottom-l_RECTTop           ;-- nHeight
            ,"Ptr",hSB                              ;-- hWndParent
            ,"UInt",0                               ;-- hMenu
            ,"UInt",0                               ;-- hInstance
            ,"UInt",0)                              ;-- lpParam

        ;-- Add to s_AVITable
        s_AVITable.=(StrLen(s_AVITable) ? ",":"") . hSB . ":" . p_PartNumber . ":" . hAVI
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

        ;-- Commands
        if (l_Option="AutoPlay")
            {
            WinSet Style,%l_OptionPrefix%%ACS_AUTOPLAY%,ahk_id %hAVI%
            Continue
            }

        if (l_Option="Border")
            {
            WinSet Style,%l_OptionPrefix%%WS_BORDER%,ahk_id %hAVI%
            Continue
            }

        if (l_Option="Center")
            {
            WinSet Style,%l_OptionPrefix%%ACS_CENTER%,ahk_id %hAVI%
            Continue
            }

        if (l_Option="Close")
            {
            SBAR_AVI_Close(hAVI,p_aviFile)
                ;-- Note: The return value is not tested here.  If an error
                ;   occurs, the function will dump an error message to the
                ;   debugger.

            Continue
            }

        if (l_Option="Destroy")  ;-- Debug/Test option
            {
            RC:=DllCall("DestroyWindow","Ptr",hAVI)
        	if (RC=0 or ErrorLevel)
                {
                outputdebug,
                   (ltrim join`s
                    Function: %A_ThisFunc% -
                    Unable to destroy the specified animation control.
                    ErrorLevel=%ErrorLevel%, A_LastError=%A_LastError%
                   )

                return
                }

            ;-- Remove entry from s_AVITable
            s_AVITable:=RegExReplace(s_AVITable,hSB . "\:" . p_PartNumber . "\:\-?[0-9]+,?","")
            if (SubStr(s_AVITable,0)=",")
                StringTrimRight s_AVITable,s_AVITable,1

            return  ;-- Ignores all other options
            }

        if (l_Option="Hide")
            {
            Control Hide,,,ahk_id %hAVI%
            Continue
            }

        if (l_Option="Open")
            {
            SBAR_AVI_Open(hAVI,p_aviFile,p_aviRef)
                ;-- Note: The return value is not tested here.  If an error
                ;   occurs, the function will dump an error message to the
                ;   debugger.

            Continue
            }

        if (l_Option="PauseResume")
            {
            if SBAR_AVI_IsPlaying(hAVI)
                SBAR_AVI_Stop(hAVI)
             else
                SBAR_AVI_Play(hAVI,-1,-1)

            Continue
            }

        if (l_Option="Pause")
            {
            if SBAR_AVI_IsPlaying(hAVI)
                SBAR_AVI_Stop(hAVI)

            Continue
            }

        if (l_Option="Play")
            {
            SBAR_AVI_Play(hAVI)
                ;-- Uses the default (play from the beginning)

            Continue
            }

        if (l_Option="Resume")
            {
            if not SBAR_AVI_IsPlaying(hAVI)
                SBAR_AVI_Play(hAVI,-1,-1)

            Continue
            }

        if (l_Option="Show")
            {
            Control Show,,,ahk_id %hAVI%
            Continue
            }

        if (l_Option="Stop")
            {
            SBAR_AVI_Stop(hAVI)
            Continue
            }

        if (l_Option="Transparent")
            {
            WinSet Style,%l_OptionPrefix%%ACS_TRANSPARENT%,ahk_id %hAVI%
            Continue
            }
        }

    Return hAVI
    }

;------------------------------
;
; Function: SBAR_AVI_Close
;
; Description:
;
;   Closes the AVI file that was previously opened for the specified animation
;   control, if any.
;
; Type:
;
;   Used by the <SBAR_AVI> add-on.  Do not call directly.
;
; Parameters:
;
;   hAVI - Handle to the animation control.
;
;   p_aviFile - Path to an AVI file (Ex: "MyAnimation.avi") or to a resource
;       that contains an AVI animation (Ex: "wmploc.dll").  Alternatively, the
;       handle to DLL resource can be specified. [Optional]  See the *Remarks*
;       section for more information.
;
; Returns:
;
;   TRUE if successful, otherwise FALSE.
;
; Remarks:
;
;   This function was created as a counterpart to <SBAR_AVI_Open>.  Although
;   closing an AVI file provides very little functional value (the AVI file does
;   not need to be closed), the function can release resources if used
;   correctly.  If used, this function should be called once for every call to
;   <SBAR_AVI_Open>. The same file that was used to open the AVI file should be
;   specified in p_aviFile parameter.
;
;   If the p_aviFile parameter contains a DLL file (Ex: "wmploc.dll") or a
;   handle to a DLL resource, the function (via the "FreeLibrary") function will
;   decrement the reference count for the modules (every call to the
;   "LoadLibrary" function for these modules increments the reference count).
;   When the reference count for a module reaches zero, the module is unloaded
;   from the address space of the calling process and the handle is no longer
;   valid.  Warning: Calling this function without an associated call to
;   <SBAR_AVI_Open> may unload a DLL resource module before an animation control
;   is done using it .  If this occurs, the script may (read: will) crash.
;
;-------------------------------------------------------------------------------
SBAR_AVI_Close(hAVI,p_aviFile:="")
    {
    Static Dummy94915233

          ;-- Messages
          ,ACM_OPENA:=0x464  ;-- WM_USER + 100
          ,ACM_OPENW:=0x467  ;-- WM_USER + 103

    ;-- Close the AVI file
    ;   Programming note:  Other than "FAIL", the return value from the ACM_OPEN
    ;   message when used to close an AVI clip does not provide any value
    ;   because it is always FALSE (0).
    ;
    SendMessage A_IsUnicode ? ACM_OPENW:ACM_OPENA,0,0,,ahk_id %hAVI%
	if (ErrorLevel="FAIL")
        {
        outputdebug,
           (ltrim join`s
            Function: %A_ThisFunc% -
            Unable to close the AVI clip.
            ErrorLevel=%ErrorLevel%, A_LastError=%A_LastError%
           )

        Return False
        }

    ;-- If loaded, free the loaded dynamic-link library (DLL) module
    if p_aviFile  ;-- Not null/blank or zero (0)
        {
        if p_aviFile is Integer  ;-- Handle to the DLL module
            RC:=DllCall("FreeLibrary","Ptr",p_aviFile)
         else
            ;-- Programming note: The "GetModuleHandle" function will only
            ;   return a valid handle if p_aviFile exists, is a DLL, _and_
            ;   is already loaded into the address space of the current process.
            if hModule:=DllCall("GetModuleHandle","Str",p_aviFile,"Ptr")
                RC:=DllCall("FreeLibrary","Ptr",hModule)

    	if (RC=0 or ErrorLevel)
            {
            outputdebug,
               (ltrim join`s
                Function: %A_ThisFunc% -
                Unable to free the "%p_aviFile%" module.
                ErrorLevel=%ErrorLevel%, A_LastError=%A_LastError%
               )

            Return False
            }
        }

    Return True
    }

;------------------------------
;
; Function: SBAR_AVI_IsPlaying
;
; Description:
;
;   Determines if an AVI clip is playing or not.
;
; Type:
;
;   Used by the <SBAR_AVI> add-on.  Do not call directly.
;
; Parameters:
;
;   hAVI - Handle to the animation control.
;
; Returns:
;
;   TRUE if the AVI clip is playing, otherwise FALSE.
;
;-------------------------------------------------------------------------------
SBAR_AVI_IsPlaying(hAVI)
    {
    Static ACM_ISPLAYING:=0x468  ;-- WM_USER + 104
    SendMessage ACM_ISPLAYING,0,0,,ahk_id %hAVI%
    Return ErrorLevel
    }

;------------------------------
;
; Function: SBAR_AVI_Open
;
; Description:
;
;   Opens the AVI clip and displays the first frame.
;
; Type:
;
;   Used by the <SBAR_AVI> add-on.  Do not call directly.
;
; Parameters:
;
;   hAVI - Handle to the animation control.
;
;   p_aviFile - Path to an AVI file (Ex: "MyAnimation.avi") or to a resource
;       that contains an AVI animation (Ex: "shell32.dll").
;
;   p_aviRef - AVI resource identifier. [Optional] If p_aviFile contains a
;       DLL file (Ex: "wiadefui.dll"), set to the identifier of desired
;       animation (Ex: 1253), otherwise set to null/blank (the default) or do
;       not specify.  Do not set to 0 (zero) unless it is the desired
;       identifier.
;
; Returns:
;
;   If successful, if p_aviFile contains a DLL file (Ex: "wmploc.dll"), the
;   handle to the module is returned, otherwise TRUE is returned.  Note: Both
;   of these conditions will test as TRUE.  If not successful, FALSE is
;   returned.
;
; Remarks:
;
;   If the Autoplay style was used to create the animation control, the clip
;   will automatically begin to play after it has been opened.
;
;   FALSE is returned if the function is unable find/load the AVI resource file
;   or open the animation.  If this occurs, a developer-friendly message is
;   dumped to the debugger with more information.  Use a debugger to view these
;   messages.
;
;-------------------------------------------------------------------------------
SBAR_AVI_Open(hAVI,p_aviFile,p_aviRef:="")
    {
    Static Dummy5560551

          ;-- Messages
          ,ACM_OPENA:=0x464  ;-- WM_USER + 100
          ,ACM_OPENW:=0x467  ;-- WM_USER + 103

    ;-- DLL file specified?
	if p_aviRef is not Space
        {
        ;-- Collect the handle to the DLL library module
        ;   Programming note: The return type must be specified for x64
        if not hModule:=DllCall("LoadLibrary","Str",p_aviFile,"Ptr")
            {
            outputdebug,
               (ltrim join`s
                Function: %A_ThisFunc% -
                Unable to find/load the resource file.
                p_aviFile: "%p_aviFile%". p_aviRef: "%p_aviRef%"
                ErrorLevel=%ErrorLevel%, A_LastError=%A_LastError%
               )

            Return False
            }
        }

    ;-- Open the AVI clip and display the first frame.
	if p_aviRef is not Space
		SendMessage A_IsUnicode ? ACM_OPENW:ACM_OPENA,hModule,p_aviRef,,ahk_id %hAVI%
     else
		SendMessage A_IsUnicode ? ACM_OPENW:ACM_OPENA,0,&p_aviFile,,ahk_id %hAVI%

	if (ErrorLevel=0 or ErrorLevel="FAIL")
        {
        outputdebug,
           (ltrim join`s
            Function: %A_ThisFunc% -
            Unable to open the AVI clip.
            p_aviFile: "%p_aviFile%". p_aviRef: "%p_aviRef%"
            ErrorLevel=%ErrorLevel%, A_LastError=%A_LastError%
           )

        Return False
        }

    Return hModule ? hModule:True
    }

;------------------------------
;
; Function: SBAR_AVI_Play
;
; Description:
;
;   Starts or restart playing an AVI clip in an animation control.
;
; Type:
;
;   Used by the <SBAR_AVI> add-on.  Do not call directly.
;
; Parameters:
;
;   hAVI - Handle to the animation control.
;
;   p_Start - The zero-based index of the frame where playing begins. The value
;       must be less than 65,536.  A value of 0 (the default) means begin with
;       the first frame in the AVI clip.  Set to -1 to resume playing (does
;       nothing if already playing) or start playing if never started.
;
;   p_End - The zero-based index of the frame where playing ends.  The value
;       must be less than 65,536.  A value of 65,535 (the default) means end
;       with the last frame in the AVI clip.
;
;   p_PlayCount - The number of times to play the AVI clip.  A value of -1 (the
;       default) means replay the clip indefinitely.
;
; Returns:
;
;   TRUE if successful, otherwise FALSE.
;
;-------------------------------------------------------------------------------
SBAR_AVI_Play(hAVI,p_Start:=0,p_End:=0xFFFF,p_PlayCount:=-1)
    {
    Static ACM_Play:=0x465  ;-- WM_USER + 101
    SendMessage ACM_Play,p_PlayCount,(p_End<<16)|p_Start,,ahk_id %hAVI%
    Return ErrorLevel
    }

;------------------------------
;
; Function: SBAR_AVI_Stop
;
; Description:
;
;   Stops (i.e. pauses) playing an AVI clip in an animation control.
;
; Type:
;
;   Used by the <SBAR_AVI> add-on.  Do not call directly.
;
; Parameters:
;
;   hAVI - Handle to the animation control.
;
; Returns:
;
;   TRUE if successful, otherwise FALSE.
;
;-------------------------------------------------------------------------------
SBAR_AVI_Stop(hAVI)
    {
    Static ACM_STOP:=0x466  ;-- WM_USER + 102
    SendMessage ACM_STOP,0,0,,ahk_id %hAVI%
    Return ErrorLevel
    }
