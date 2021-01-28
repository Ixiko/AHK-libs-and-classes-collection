/*
Title: SBAR Library v0.0.1 (Preview)

Group: Introduction

    The status bar was first introduced as a standard OS control as part of the
    Windows 95 common control library.  A few features have been added over the
    years but the functionality hasn't changed much.  This library was created
    to help exploit the capabilities of the status bar control.

Group: AutoHotkey Compatibility

    This library is designed to run on all versions of AutoHotkey v1.1+: ANSI,
    Unicode, and Unicode 64-bit.

Group: Common Parameters

    Common function parameters of note.

    *hSB*

    This input parameter should contain the handle to the status bar.

    hSB is the de facto first parameter for most of the library functions.  It
    is critical to the success of the library.  So much so, that it's value is
    never tested.  If the hSB parameter contains an invalid value, most of the
    library functions will fail.  Most status bar messages that use an invalid
    hSB value will set ErrorLevel to FAIL.

    *p_PartNumber*

    This input parameter should contain the 1-based index of the status bar
    part.  For most (but not all) functions, the default value for this
    parameter is 1.

Group: Issues and Considerations

    Miscellaneous issues and considerations.

    Topic: Documentation vs. Observation

        Some of the information in the document is based on the information
        gleaned from the AutoHotkey and Microsoft documentation.  Unfortunately,
        the Microsoft documentation on this topic is limited and some of it is
        outdated.  As a result, some of the information in this document is
        based on observation and testing.  If any of this information is
        incorrect, please make a noise!

    Topic: DPI-Aware

        The functions in this library are not DPI-aware.  Specified position and
        size values are used as-is and the values returned from library
        functions are not adjusted to reflect a non-standard screen DPI.

        Starting with AutoHotkey v1.1.11, a "DPIScale" option was added for
        AutoHotkey GUIs which makes most "gui" commands DPI-aware.  Although the
        AutoHotkey "gui" commands will not interfere with with any of the
        library commands (and vice versa), the size and position used by each
        may be incompatible when used on a computer that is using a non-standard
        DPI.  The DPIScale feature is enabled by default so if necessary, it
        must be manually disabled for each GUI by adding a "gui -DPIScale"
        command.

        The native <SB_SetParts at
        https://autohotkey.com/docs/commands/GuiControls.htm#SB_SetParts> and
        <SB_SetIcon at
        https://autohotkey.com/docs/commands/GuiControls.htm#SB_SetIcon>
        functions are DPI-aware.  However, only the SB_SetParts function
        responds correctly to changes to the DPIScale option.  The SB_SetIcon
        function effectively ignores the DPIScale option.

    Topic: Font

        When the AutoHotkey "gui Add,StatusBar" command is used to create the
        status bar (the default method), AutoHotkey sets the status bar font to
        last font defined before the command is performed.  If no specific font
        was set, the default GUI font is used.  To use a unique font for the
        text in the status bar, set the font immediately before performing the
        "gui Add,StatusBar" command.  For example:

            (start code)
            gui Font,s10,Arial
            gui Add,StatusBar,hWndhSB
            gui Font  ;-- Reset to the default GUI font
            (end)

        Changing the font after the status bar has been created can be done by
        sending the WM_SETFONT message.  See <SBAR_SetFont> for more
        information.

        See the example scripts for an example on how to use the Fnt library to
        set the system non-client font for the status bar.

    Topic: Height

        In general, the height of the status bar is considered static.  The
        Microsoft documentation states that the height of the status bar is
        determined by the font but in reality, there are other factors.

        If the status bar is created with visual styles enabled (the default for
        most computers), a fixed-height status bar is created.  The status bar
        font does not change anything but the screen DPI is taken into
        consideration.  If visual styles are disabled or are disabled after the
        status bar has been created, changes to the font will automatically
        increase or decrease the height of the status bar.

        <SBAR_SetMinHeight> can be used to force the status bar to accommodate
        the status bar font and/or the height of the desired entity -- animation
        clip, icon, image (Ex: bitmap), whatever -- but there is always the
        danger that increasing the status bar height will take up too much
        screen real estate or will make the status bar look clunky.

    Topic: Icons

        When used with <SBAR_ExtractIcon>, the <SBAR_SetIcon> and
        <SBAR_SetSimpleIcon> functions duplicate much of the functionality of
        the native <SB_SetIcon at
        https://autohotkey.com/docs/commands/GuiControls.htm#SB_SetIcon>
        function.  The difference is that the SBAR_ExtractIcon function requires
        a specific icon size rather than letting the program determine the icon
        size.  Although it can introduce some additional code, it allows the
        developers to choose the optimal icon size rather than taking the chance
        that the icon might be scaled to fit.  Although scaled icons are
        acceptable in many cases, they never look as good as icons shown at
        their optimal size.

    Topic: Remote Status Bars

        This library is designed to be used on status bars that are created in
        the same process that the script is running.  Yes, some of the messages
        will work on a remote status bar in certain conditions but most will
        not.  The exception is the <SBAR_SetTextEx> add-on.  See the function
        documentation for more information.

    Topic: Simple Mode

        Preface: Unfortunately, the simple mode status bar is a hodgepodge
        feature that was implemented without clear forethought and planning.  It
        certainly can provide value but any use of the simple mode status bar
        requires a clear understanding of the limitations and the extra
        programming that may be necessary to accomodate for it's use.

        The status bar offers two modes: Simple and nonsimple (the default). The
        simple mode is a single-part status bar and the nonsimple mode is a
        multi-part status bar with up to 255 parts.  Microsoft uses part 255
        (256 for a 1-based index) to contain the text for the simple mode.  This
        design ensures that changes to the status bar text that are made while
        in simple mode do not interfere with the text set in the nonsimple mode.
        Use <SBAR_SetSimple> to toggle between simple and nonsimple mode.

        Many status bar messages work regardless of the current status bar mode.
        For example, the SB_SETTEXT message always works.  This is useful
        because it allows threads that are updating the status bar in the
        background to continue to operate regardless of the status bar mode.

        Some library functions only work correctly if the status bar is in
        simple mode.  For example, <SBAR_GetSimpleText> and
        <SBAR_GetSimpleTextStyle> only work if the status bar is in simple mode.

        Some status bar messages only work correctly if the status bar is in
        nonsimple mode.  For example, the SB_GETRECT message only works if the
        status bar is in nonsimple mode.  This can be a problem if this message
        is used in combination with the SB_SETTEXT message.

        Although not recommended for all situations, one possible workaround to
        messages or library functions that only work in a particular mode is to
        to  1) temporarily change the status bar to desired mode, i.e. simple or
        nonsimple, 2) call the previously-incompatible function, and then 3)
        revert back to previous mode.  Observation: There does not appear to be
        any flickering when this is done.

        Simple and nonsimple message idiosyncrasies have been documented in the
        affected functions.  Unfortunately, there are quite a few functions with
        these type of restrictions so be sure to check each function before
        using.

    Topic: Visual Styles

        Some status bar features don't work if visual styles are enabled.  For
        Windows themes that utilize a visual style, messages that change the
        visual characteristics of the status bar are effectively ignored.  The
        only way to get these messages to work as intended is to disable the
        visual styles.  Messages of note include SB_SETTEXT (when setting some
        text styles) and SB_SETBKCOLOR.

        For the WM_SETFONT message, the status bar responds differently
        depending or whether or not visual styles are enabled.  See
        <SBAR_SetFont> for more information.

        If needed, use the gui "-Theme" option when creating the status bar (Ex :
        "gui Add,StatusBar,-Theme") to set the status bar to the default visual
        style, i.e. the Windows Classic theme.  Alternatively,
        <SBAR_VisualStyles> can be used to disable the visual styles of the
        status bar as needed.

        Hint: Most computer users use a theme that employs visual styles by
        default.  Although visual styles can be disabled in some cases, the look
        and operation of the status bar is changed from what has become the
        norm.  In most cases, it's best to design an application with the
        assumption that visual styles will be used.

Group: Links

    Status Bar Reference at MSDN :
    * <https://msdn.microsoft.com/en-us/library/windows/desktop/ff486038(v=vs.85).aspx>

Group: Functions
*/
;------------------------------
;
; Function: SBAR_ColorName2RGB
;
; Description:
;
;   Convert a color name to it's 6-digit hexadecimal RGB value.
;
; Type:
;
;   Internal function.  Subject to change.  Do not use.
;
; Parameters:
;
;   p_ColorName - A color name (Ex: "Fuchsia").  See the function's static
;       variables for a list of supported names.
;
; Returns:
;
;   A 6-digit hexadecimal RGB value.  Ex: 0xFF00FF.  If an invalid/unsupported
;   color name is specified, the original p_ColorName value is is returned.
;
; Remarks:
;
;   Only the 16 primary HTML color names are supported at this time.
;
;-------------------------------------------------------------------------------
SBAR_ColorName2RGB(p_ColorName)
    {
    Static Dummy27829226

          ;-- Supported color names
          ,Color_Aqua   :=0x00FFFF
          ,Color_Black  :=0x000000
          ,Color_Blue   :=0x0000FF
          ,Color_Fuchsia:=0xFF00FF
          ,Color_Gray   :=0x808080
          ,Color_Green  :=0x008000
          ,Color_Lime   :=0x00FF00
          ,Color_Maroon :=0x800000
          ,Color_Navy   :=0x000080
          ,Color_Olive  :=0x808000
          ,Color_Purple :=0x800080
          ,Color_Red    :=0xFF0000
          ,Color_Silver :=0xC0C0C0
          ,Color_Teal   :=0x008080
          ,Color_White  :=0xFFFFFF
          ,Color_Yellow :=0xFFFF00

    ;-- Convert if supported color name (not case sensitive)
    l_Color:=p_ColorName
    if Color_%p_ColorName% is not Space
        l_Color:=Color_%p_ColorName%

    Return l_Color
    }

;------------------------------
;
; Function: SBAR_DisableVisualStyles
;
; Description:
;
;   Disable (remove) the visual styles for a status bar control.
;
; Calls To Other Functions:
;
; * <SBAR_VisualStyles>
;
;-------------------------------------------------------------------------------
SBAR_DisableVisualStyles(hSB)
    {
    SBAR_VisualStyles(hSB,False)
    }

;------------------------------
;
; Function: SBAR_EnableVisualStyles
;
; Description:
;
;   Enable visual styles for a status bar control.
;
; Calls To Other Functions:
;
; * <SBAR_VisualStyles>
;
;-------------------------------------------------------------------------------
SBAR_EnableVisualStyles(hSB)
    {
    SBAR_VisualStyles(hSB,True)
    }

;------------------------------
;
; Function: SBAR_ExtractIcon
;
; Description:
;
;   Extract an icon or other image from a file.
;
; Parameters:
;
;   p_File - The file that has one or more images.  See the *Remarks* section
;       for more information.
;
;   p_IconIndex - The 1-based icon index of the icon to extract.  Set to 1 to
;       extract the first icon, 2 for the second icon, and so on.  If there is
;       only one icon, set to 1.
;
;   xIcon, yIcon - The size of the icons to extract, in pixels.  If the yIcon
;       parameter is not specified, it is set to the value of xIcon.
;
; Returns:
;
;   The handle of the extracted icon or FALSE if there was a problem.
;
; Calls To Other Functions:
;
; * <SBAR_SystemMessage>
;
; Credit:
;
;   Some code for this function extracted from the MI_ExtractIcon function.
;   Author: lexikos
;
; Remarks:
;
;   This function extracts images from executable (.exe), DLL (.dll), icon
;   (.ico), cursor (.cur), animated cursor (.ani), and bitmap (.bmp) files.
;   Extractions from Windows 3.x 16-bit executables (.exe or .dll) are also
;   supported.
;
;   The PrivateExtractIcons system function will search the path for the file so
;   specifying the full path is only necessary if the file is not in the path.
;   So, setting p_File to "shell32.dll" is the same as setting it to
;   "C:\Windows\System32\shell32.dll" or whatever the full path for this file
;   is.
;
;   All icons extracted by this function should be destroyed by calling the
;   DestroyIcon system function.
;
;-------------------------------------------------------------------------------
SBAR_ExtractIcon(p_File,p_IconIndex,xIcon,yIcon:="")
    {
    Static LR_DEFAULTCOLOR:=0x0

    ;-- Parameters
    if not yIcon  ;-- null/blank or 0
        yIcon:=xIcon

    ;-- Extract icon
    ;   Note: The return type is set to Int because -1 is one of the possible
    ;   return values.
    RC:=DllCall("PrivateExtractIcons"
        ,"Str",p_File                                   ;-- lpszFile
        ,"Int",p_IconIndex-1                            ;-- nIconIndex
        ,"Int",xIcon                                    ;-- cxIcon
        ,"Int",yIcon                                    ;-- cyIcon
        ,"Ptr*",hIcon                                   ;-- *phicon
        ,"Ptr*",0                                       ;-- *piconid
        ,"UInt",1                                       ;-- nIcons
        ,"UInt",LR_DEFAULTCOLOR                         ;-- flags
        ,"Int")                                         ;-- Return type

    if (RC=-1) or ErrorLevel
        {
        l_Message:=""
        if (RC=-1)
            l_Message.="Return=" . RC

        if ErrorLevel
            l_Message.=(StrLen(l_Message) ? ", ":"")
                . "ErrorLevel=" . ErrorLevel

        if A_LastError
            l_Message.=", "
                . "A_LastError=" . A_LastError . " - "
                . SBAR_SystemMessage(A_LastError)

        outputdebug,
           (ltrim join`s
            Function: %A_ThisFunc% - PrivateExtractIcons failure. %l_Message%
           )

        Return False
        }

    ;-- Return the handle to the icon
    Return hIcon
    }

;------------------------------
;
; Function: SBAR_GetBorders
;
; Description:
;
;   Get the current widths of the horizontal and vertical borders of the status
;   bar.
;
; Parameters:
;
;   r_HorzW - [Output, Optional] Variable that contains the width of the
;       horizontal border.
;
;   r_VertW - [Output, Optional] Variable that contains the width of the
;       vertical border.
;
;   r_RectW - [Output, Optional] Variable that contains the width of the
;       border between rectangles.
;
; Returns:
;
;   If successful, the output variables are updated with their respective border
;   values and TRUE is returned.  If not successful, all of the output variables
;   are set to 0 and FALSE is returned.
;
;-------------------------------------------------------------------------------
SBAR_GetBorders(hSB,ByRef r_HorzW:="",ByRef r_VertW:="",ByRef r_RectW:="")
    {
    Static SB_GETBORDERS:=0x407                         ;-- WM_USER + 7

    ;-- Initialize
    VarSetCapacity(l_BorderArray,12,0)
        ;-- Enough space for 3 integers

    ;-- Get borders
    SendMessage SB_GETBORDERS,0,&l_BorderArray,,ahk_id %hSB%
    if not ErrorLevel
        {
        r_HorzW:=r_VertW:=r_RectW:=0
        Return False
        }

    ;-- Update the output variables
    r_HorzW:=NumGet(l_BorderArray,0,"Int")
    r_VertW:=NumGet(l_BorderArray,4,"Int")
    r_RectW:=NumGet(l_BorderArray,8,"Int")
    Return True
    }

;------------------------------
;
; Function: SBAR_GetFont
;
; Description:
;
;   Get the font with which the status bar is currently drawing its text.
;
; Returns:
;
;   The handle to the font used by the status bar or 0 if the using the system
;   font.
;
;-------------------------------------------------------------------------------
SBAR_GetFont(hSB)
    {
    Static WM_GETFONT:=0x31
    SendMessage WM_GETFONT,0,0,,ahk_id %hSB%
    Return ErrorLevel
    }

;------------------------------
;
; Function: SBAR_GetIcon
;
; Description:
;
;   Get the icon for a status bar part.
;
; Parameters:
;
;   See <Common Parameters> for more information.
;
; Returns:
;
;   The handle to the icon (tests as TRUE) if successful, otherwise 0 (FALSE).
;
; Remarks:
;
;   Use <SBAR_GetSimpleIcon> to get the icon for a simple mode status bar.
;
;-------------------------------------------------------------------------------
SBAR_GetIcon(hSB,p_PartNumber:=1)
    {
    Static SB_GETICON:=0x414                            ;-- WM_USER + 20
    SendMessage SB_GETICON,p_PartNumber-1,0,,ahk_id %hSB%
    Return ErrorLevel
    }

;------------------------------
;
; Function: SBAR_GetIconSize
;
; Description:
;
;   Get the icon size from the specified part of a status bar.
;
; Parameters:
;
;   See <Common Parameters> for more information.
;
;   r_Width, r_Height - [Output, Optional] If defined, these variables are set
;       to the width and height of the status bar icon.  If the status bar does
;       not have an icon or if there was an error, these variables are set to 0.
;
; Returns:
;
;   The address to a SIZE structure (tests as TRUE) if successful, otherwise
;   FALSE.
;
; Calls To Other Functions:
;
; * <SBAR_GetIcon>
;
;-------------------------------------------------------------------------------
SBAR_GetIconSize(hSB,p_PartNumber:=1,ByRef r_Width:="",ByRef r_Height:="")
    {
    Static SIZE

    ;-- Initialize
    VarSetCapacity(SIZE,8,0)
    r_Width:=r_Height:=0

    ;-- Get the handle to the icon.  Bounce if there is no icon.
    if not hIcon:=SBAR_GetIcon(hSB,p_PartNumber)
        Return False

    ;-- Get icon info.  Bounce if the icon is not found.
    VarSetCapacity(ICONINFO,A_PtrSize=8 ? 32:24,0)
    if not DllCall("GetIconInfo","Ptr",hIcon,"Ptr",&ICONINFO)
        Return False

    hbmMask :=NumGet(ICONINFO,A_PtrSize=8 ? 16:12,"Ptr")
    hbmColor:=NumGet(ICONINFO,A_PtrSize=8 ? 24:16,"Ptr")

    ;-- Get bitmap info
    VarSetCapacity(BITMAP,A_PtrSize=8 ? 32:24,0)
    RC:=DllCall("GetObject","Ptr",hbmMask,"Int",A_PtrSize=8 ? 32:24,"Ptr",&BITMAP)
    DllCall("DeleteObject","Ptr",hbmColor)
    DllCall("DeleteObject","Ptr",hbmMask)
    if not RC
        Return False

    ;-- Update the output variables
    r_Width :=NumGet(BITMAP,4,"Int")                    ;-- bmWidth
    bmHeight:=NumGet(BITMAP,8,"Int")                    ;-- bmHeight
    r_Height:=hbmColor ? bmHeight:bmHeight/2

    ;-- Populate the SIZE structure and return
    NumPut(r_Width, SIZE,0,"Int")                       ;-- cx
    NumPut(r_Height,SIZE,4,"Int")                       ;-- cy
    Return &SIZE
    }

;------------------------------
;
; Function: SBAR_GetMaxTextWidth
;
; Description:
;
;   Returns the maximum width of a status bar part, in pixels, that can be
;   used to display text.
;
; Type:
;
;   Preview/Experimental.  Subject to change.
;
; Parameters:
;
;   See <Common Parameters> for more information.
;
; Calls To Other Functions:
;
; * <SBAR_GetBorders>
; * <SBAR_GetIconSize>
; * <SBAR_GetPartWidth>
;
; Remarks:
;
;   This function only works correctly when the status bar is in nonsimple (i.e.
;   standard) mode.  If used while in simple mode, invalid values may be
;   returned.  If necessary, use <SBAR_IsSimple> to check the status bar mode
;   before calling this function.
;
;   Any change to the status bar part can change the amount of space that is
;   available for text.  This includes changing the part size, adding an icon,
;   changing the icon (if a different icon size), or removing the icon.
;
; Experimental:
;
;   At this writing, the function is returning what appears to be the correct
;   width in all cases.  Unfortunately, the function is using system values
;   (Ex: vertical border width and rectangle border width) that have nothing to
;   do with the spacing gaps that are found when text is displayed in a status
;   bar part.  These system values just happen to match the gaps but there is
;   absolutely no documentation on what values Microsoft uses when setting the
;   status bar text.  Effectively, the function is using a best-guest
;   calculation.  This function will be marked as "Experimental" until this
;   information can be found or until this function has been tested by a number
;   of developers on a number of different environments.
;
;-------------------------------------------------------------------------------
SBAR_GetMaxTextWidth(hSB,p_PartNumber:=1)
    {
    SBAR_GetBorders(hSB,,l_VertBorderW,l_RectBorderW)
    l_MaxTextW:=SBAR_GetPartWidth(hSB,p_PartNumber)
    l_MaxTextW-=l_VertBorderW+l_RectBorderW

    ;-- Experimental
    l_MaxTextW+=1

    ;-- Adjust if the part has an icon
    if SBAR_GetIconSize(hSB,p_PartNumber,l_IconW)
        l_MaxTextW-=l_IconW+l_VertBorderW+l_RectBorderW

    Return l_MaxTextW
    }

;------------------------------
;
; Function: SBAR_GetPartHeight
;
; Description:
;
;   Get the height of a status bar part.
;
; Parameters:
;
;   See <Common Parameters> for more information.
;
; Returns:
;
;   The height of the bounding rectangle of the requested part.  Note: This is
;   not the same as the height of the status bar control.
;
; Remarks:
;
;   This function only works correctly when the status bar is in nonsimple (i.e.
;   standard) mode.  If used while in simple mode, the SB_GETRECT message fails
;   (returns FALSE (0)).  If necessary, use <SBAR_IsSimple> to check the status
;   bar mode before calling this function.
;
;-------------------------------------------------------------------------------
SBAR_GetPartHeight(hSB,p_PartNumber:=1)
    {
    Static SB_GETRECT:=0x40A                            ;-- WM_USER + 10
    VarSetCapacity(RECT,16,0)
    SendMessage SB_GETRECT,p_PartNumber-1,&RECT,,ahk_id %hSB%
    Return ErrorLevel ? NumGet(RECT,12,"Int")-NumGet(RECT,4,"Int"):0
        ;-- Right - Left
    }

;------------------------------
;
; Function: SBAR_GetPartRect
;
; Description:
;
;   Get the bounding rectangle of a status bar part.
;
; Parameters:
;
;   See <Common Parameters> for more information.
;
;   r_Left..r_Bottom - [Output, Optional]
;
; Returns:
;
;   The address to a RECT structure (tests as TRUE) is returned in all cases.
;   If successful, the RECT structure contains the bounding rectangle of the
;   specified status bar part.  In addition, the output variables
;   (r_Left...r_Bottom) are updated with the associated values.  If not
;   successful, all members of the RECT structure are set to 0 and all output
;   variables are set to 0.
;
; Remarks:
;
;   This function only works correctly when the status bar is in nonsimple (i.e.
;   standard) mode.  If used while in simple mode, the SB_GETRECT message fails
;   (returns FALSE (0)).  If necessary, use <SBAR_IsSimple> to check the status
;   bar mode before calling this function.
;
;-------------------------------------------------------------------------------
SBAR_GetPartRect(hSB,p_PartNumber:=1,ByRef r_Left:="",ByRef r_Top:="",ByRef r_Right:="",ByRef r_Bottom:="")
    {
    Static Dummy71709663
          ,RECT

          ;-- Messages
          ,SB_GETRECT:=0x40A                            ;-- WM_USER + 10

    ;-- Get the bounding rectangle of a part
    VarSetCapacity(RECT,16,0)
    SendMessage SB_GETRECT,p_PartNumber-1,&RECT,,ahk_id %hSB%
    if not ErrorLevel
        {
        r_Left:=r_Top:=r_Right:=r_Bottom:=0
        Return &RECT
        }

    ;-- Populate the output variables
    r_Left  :=NumGet(RECT,0,"Int")
    r_Top   :=NumGet(RECT,4,"Int")
    r_Right :=NumGet(RECT,8,"Int")
    r_Bottom:=NumGet(RECT,12,"Int")
    Return &RECT
    }

;------------------------------
;
; Function: SBAR_GetPartWidth
;
; Description:
;
;   Get the width of a status bar part.
;
; Parameters:
;
;   See <Common Parameters> for more information.
;
; Returns:
;
;   The width of the bounding rectangle of the requested part if successful,
;   otherwise FALSE (0).
;
; Remarks:
;
;   This function only works correctly when the status bar is in nonsimple (i.e.
;   standard) mode.  If used while in simple mode, the SB_GETRECT message fails
;   (returns FALSE (0)).  If necessary, use <SBAR_IsSimple> to check the status
;   bar mode before calling this function.
;
;-------------------------------------------------------------------------------
SBAR_GetPartWidth(hSB,p_PartNumber:=1)
    {
    Static SB_GETRECT:=0x40A                            ;-- WM_USER + 10
    VarSetCapacity(RECT,16,0)
    SendMessage SB_GETRECT,p_PartNumber-1,&RECT,,ahk_id %hSB%
    Return ErrorLevel ? NumGet(RECT,8,"Int")-NumGet(RECT,0,"Int"):0
        ;-- Right - Left
    }

;------------------------------
;
; Function: SBAR_GetParts
;
; Description:
;
;   Get the coordinate of the right edge of the status bar parts.
;
; Parameters:
;
;   r_Parts - [Output] Variable that contains a simple linear array that has the
;       same number of elements as the number of status bar parts.  Each element
;       in the array contains the client coordinate of the right edge of the
;       corresponding part.  If an element is set to -1, the position of the
;       right edge for that part extends to the right edge of the status bar.
;
; Returns:
;
;   The number of parts in the status bar.
;
;-------------------------------------------------------------------------------
SBAR_GetParts(hSB,byRef r_Parts)
    {
    Static SB_GETPARTS:=0x406                           ;-- WM_USER+6

    ;-- Initialize
    r_Parts:=[]

    ;-- Get the number of status bar parts
    SendMessage SB_GETPARTS,0,0,,ahk_id %hSB%
    if (ErrorLevel="FAIL")  ;-- Invalid hSB
        Return 0

    l_NumberOfParts:=ErrorLevel

    ;-- Collect part coordinates
    VarSetCapacity(l_PartsArray,4*l_NumberOfParts,0)
    SendMessage SB_GETPARTS,l_NumberOfParts,&l_PartsArray,,ahk_id %hSB%

    ;-- Load data from integer array to the output AutoHotkey array
    Loop %l_NumberOfParts%
        r_Parts.Push(NumGet(&l_PartsArray,(A_Index-1)*4,"Int"))

    Return l_NumberOfParts
    }

;------------------------------
;
; Function: SBAR_GetPartsCount
;
; Description:
;
;   Returns the number of parts in the status bar.
;
; Remarks:
;
;   The SB_GETPARTS message returns the number of parts for the nonsimple status
;   bar even if the status bar is currently in simple mode.
;
; Programming Notes:
;
;   This is one of the few functions that checks for the return code of "FAIL"
;   which indicates that the hSB parameter is invalid.  This allows the function
;   to always return an integer value and allows the return value to be tested
;   as TRUE for FALSE since all status bars have at least 1 part.
;
;-------------------------------------------------------------------------------
SBAR_GetPartsCount(hSB)
    {
    Static SB_GETPARTS:=0x406                           ;-- WM_USER+6
    SendMessage SB_GETPARTS,0,0,,ahk_id %hSB%
    Return (ErrorLevel="FAIL" ? 0:ErrorLevel)
    }

;------------------------------
;
; Function: SBAR_GetPos
;
; Description:
;
;   Get the position and size of the status bar control.  See the *Remarks*
;   section for more information.
;
; Parameters:
;
;   X, Y, W, H - [Output, Optional] If defined, these variables contain the
;       coordinates of the status bar relative to the client-area of the parent
;       window (X and Y), and the width and height of the status bar (W and H).
;
; Remarks:
;
;   This function returns values similar to the AutoHotkey
;   *GUIControlGet,OutputVar,Pos* command.  The coordinates values (i.e. X and
;   Y) are relative to the parent window's client area.  However, this function
;   is not DPI-aware and so the returned values are actual values, not
;   calculated values based on the current screen DPI.  This function will
;   return the same values as the *GUIControlGet,OutputVar,Pos* command if the
;   "-DPIScale" option was specified when the GUI was created or if the computer
;   is currently using the default DPI setting, i.e. 96 DPI.  This function
;   works on all status bars whereas the <GUIControlGet at
;   https://autohotkey.com/docs/commands/GuiControlGet.htm> command only works
;   on status bars created using the AutoHotkey "gui Add" command.
;
;   If the status bar was created using the AutoHotkey "gui Add" command and the
;   "-DPIScale" option is specified, the *GUIControlGet* command can be used
;   instead.  The <ControlGetPos at
;   https://autohotkey.com/docs/commands/ControlGetPos.htm> and <WinGetPos at
;   https://autohotkey.com/docs/commands/WinGetPos.htm> commands are not
;   DPI-aware and so if only interested in the width and/or height values, these
;   commands can be used on all status bar controls.  Hint: The native
;   AutoHotkey commands are more efficient and should be used whenever possible.
;
;-------------------------------------------------------------------------------
SBAR_GetPos(hSB,ByRef X:="",ByRef Y:="",ByRef W:="",ByRef H:="")
    {
    ;-- Initialize
    VarSetCapacity(RECT,16,0)

    ;-- Get the dimensions of the bounding rectangle of the status bar
    DllCall("GetWindowRect","Ptr",hSB,"Ptr",&RECT)
    W:=NumGet(RECT,8,"Int")-NumGet(RECT,0,"Int")        ;-- W=right-left
    H:=NumGet(RECT,12,"Int")-NumGet(RECT,4,"Int")       ;-- H=bottom-top

    ;-- Convert the screen coordinates of the status bar to client-area
    ;   coordinates.  Note: The API reads and updates the first 8-bytes of the
    ;   RECT structure.
    DllCall("ScreenToClient"
        ,"Ptr",DllCall("GetParent","Ptr",hSB,"Ptr")
        ,"Ptr",&RECT)

    X:=NumGet(RECT,0,"Int")                             ;-- left
    Y:=NumGet(RECT,4,"Int")                             ;-- top
    }

;------------------------------
;
; Function: SBAR_GetHeight
;
; Description:
;
;   Get the height of a status bar.
;
;-------------------------------------------------------------------------------
SBAR_GetHeight(hSB)
    {
    ControlGetPos,,,,l_SBH,,ahk_id %hSB%
    Return l_SBH
    }

;------------------------------
;
; Function: SBAR_GetSimpleIcon
;
; Description:
;
;   Get the icon from the simple mode status bar.
;
; Returns:
;
;   The handle to the icon (tests as TRUE) if successful, otherwise 0 (FALSE).
;
;-------------------------------------------------------------------------------
SBAR_GetSimpleIcon(hSB)
    {
    Static SB_GETICON:=0x414                            ;-- WM_USER + 20
    SendMessage SB_GETICON,-1,0,,ahk_id %hSB%
    Return ErrorLevel
    }

;------------------------------
;
; Function: SBAR_GetSimpleIconSize
;
; Description:
;
;   Get the icon size of the simple mode status bar icon.
;
; Parameters:
;
;   See <Common Parameters> for more information.
;
;   r_Width, r_Height - [Output, Optional]  If defined, these variables contain
;       the width and height of the simple mode status bar icon.  These
;       variables will be set to zero if there is no icon or if there was an
;       error.
;
; Returns:
;
;   The address to a SIZE structure (tests as TRUE) if successful, otherwise
;   FALSE.
;
; Calls To Other Functions:
;
; * <SBAR_GetIconSize>
;
;-------------------------------------------------------------------------------
SBAR_GetSimpleIconSize(hSB,ByRef r_Width:="",ByRef r_Height:="")
    {
    Return SBAR_GetIconSize(hSB,0,r_Width,r_Height)
    }

;------------------------------
;
; Function: SBAR_GetSimpleText
;
; Description:
;
;   Returns the text from a simple mode status bar.
;
; Remarks:
;
;   This function only works correctly if the status bar is in simple mode.  If
;   used while in nonsimple mode, invalid information is returned.  Use
;   <SBAR_IsSimple> to check the status bar mode before calling this function.
;
; Programming Notes:
;
;   While the status bar is in simple mode, SB_GETTEXTLENGTH or SB_GETTEXT
;   messages only return information for the simple mode status bar.  Oddly, the
;   wParam parameter must contain a valid zero-index part number (it is set to
;   0) but it is otherwise ignored.  This idiosyncrasy is not documented.
;
;-------------------------------------------------------------------------------
SBAR_GetSimpleText(hSB)
    {
    Static Dummy41938447

          ;-- Messages
          ,SB_GETTEXTA      :=0x402                     ;-- WM_USER + 2
          ,SB_GETTEXTW      :=0x40D                     ;-- WM_USER + 13
          ,SB_GETTEXTLENGTHA:=0x403                     ;-- WM_USER + 3
          ,SB_GETTEXTLENGTHW:=0x40C                     ;-- WM_USER + 12

    ;-- Get text length
    SendMessage
        ,A_IsUnicode ? SB_GETTEXTLENGTHW:SB_GETTEXTLENGTHA
        ,0                                              ;-- wParam
        ,0                                              ;-- lParam
        ,,ahk_id %hSB%

    if not l_TextLength:=ErrorLevel&0xFFFF
        Return ""  ;-- Null

    ;-- Get text
    VarSetCapacity(l_Text,l_TextLength*(A_IsUnicode ? 2:1),0)
    SendMessage
        ,A_IsUnicode ? SB_GETTEXTW:SB_GETTEXTA
        ,0                                              ;-- wParam
        ,&l_Text                                        ;-- lParam
        ,,ahk_id %hSB%

    VarSetCapacity(l_Text,-1)
    Return l_Text
    }

;------------------------------
;
; Function: SBAR_GetSimpleTextStyle
;
; Description:
;
;   Returns the text style from a simple mode status bar.
;
; Remarks:
;
;   This function only works correctly if the status bar is in simple mode.  If
;   used while in nonsimple mode, invalid information is returned.  Use
;   <SBAR_IsSimple> to check the status bar mode before calling this function.
;
; Programming Notes:
;
;   While the status bar is in simple mode, SB_GETTEXTLENGTH or SB_GETTEXT
;   messages only return information for the simple mode status bar.  Oddly, the
;   wParam parameter must contain a valid zero-index part number (it is set to
;   0) but it is otherwise ignored.  This idiosyncrasy is not documented.
;
;-------------------------------------------------------------------------------
SBAR_GetSimpleTextStyle(hSB)
    {
    Static Dummy93595056

          ;-- Possible return values
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

          ,SBT_OWNERDRAW:=0x1000
                ;-- The text is drawn by the parent window.

          ;-- Messages
          ,SB_GETTEXTA      :=0x402                     ;-- WM_USER + 2
          ,SB_GETTEXTW      :=0x40D                     ;-- WM_USER + 13
          ,SB_GETTEXTLENGTHA:=0x403                     ;-- WM_USER + 3
          ,SB_GETTEXTLENGTHW:=0x40C                     ;-- WM_USER + 12

    ;-- Get text length
    SendMessage
        ,A_IsUnicode ? SB_GETTEXTLENGTHW:SB_GETTEXTLENGTHA
        ,0                                              ;-- wParam
        ,0                                              ;-- lParam
        ,,ahk_id %hSB%

    Return (ErrorLevel>>16)&0xFFFF
    }

;------------------------------
;
; Function: SBAR_GetSimpleTipText
;
; Description:
;
;   Returns the tooltip text for a simple status bar.
;
; Warning:
;
;   There is no mechanism to identify the length of the tooltip text for a
;   status bar part so this function is forced to create a fixed-size buffer to
;   accommodate the text for all possible status bar tooltips.  At this writing,
;   the buffer can accommodate a maximum of 8,192 characters (8K for ANSI, 16K
;   for Unicode).  If the function attempts to get the text for a status bar
;   tooltip that is larger than the buffer, the request could cause a buffer
;   overflow which will cause AutoHotkey to crash.
;
;-------------------------------------------------------------------------------
SBAR_GetSimpleTipText(hSB)
    {
    Static Dummy49660862
          ,MaxTCHARs:=0x2000
          ,SB_SIMPLEID:=0xFF

          ;-- Messages
          ,SB_GETTIPTEXTA:=0x412                        ;-- WM_USER + 18
          ,SB_GETTIPTEXTW:=0x413                        ;-- WM_USER + 19

    ;-- Get tip text
    VarSetCapacity(l_Text,MaxTCHARs*(A_IsUnicode ? 2:1),0)
    SendMessage
        ,A_IsUnicode ? SB_GETTIPTEXTW:SB_GETTIPTEXTA
        ,MaxTCHARs<<16|SB_SIMPLEID                      ;-- wParam
        ,&l_Text                                        ;-- lParam
        ,,ahk_id %hSB%

    VarSetCapacity(l_Text,-1)
    Return l_Text
    }

;------------------------------
;
; Function: SBAR_GetText
;
; Description:
;
;   Get the text from the specified part of a status bar.
;
; Parameters:
;
;   See <Common Parameters> for more information.
;
; Returns:
;
;   The text from the specified part.
;
; Remarks:
;
;   This function only works correctly when the status bar is in nonsimple (i.e.
;   standard) mode.  If used while in simple mode, invalid text will be
;   returned.  If the simple status bar mode is possible, use <SBAR_IsSimple> to
;   check the status bar mode before calling this function.
;
;-------------------------------------------------------------------------------
SBAR_GetText(hSB,p_PartNumber:=1)
    {
    Static Dummy41938447

          ;-- Messages
          ,SB_GETTEXTA      :=0x402                     ;-- WM_USER + 2
          ,SB_GETTEXTW      :=0x40D                     ;-- WM_USER + 13
          ,SB_GETTEXTLENGTHA:=0x403                     ;-- WM_USER + 3
          ,SB_GETTEXTLENGTHW:=0x40C                     ;-- WM_USER + 12

    ;-- Get text length
    SendMessage
        ,A_IsUnicode ? SB_GETTEXTLENGTHW:SB_GETTEXTLENGTHA
        ,p_PartNumber-1                                 ;-- wParam
        ,0                                              ;-- lParam
        ,,ahk_id %hSB%

    if not l_TextLength:=ErrorLevel&0xFFFF
        Return ""  ;-- Null

    ;-- Get text
    VarSetCapacity(l_Text,l_TextLength*(A_IsUnicode ? 2:1),0)
    SendMessage
        ,A_IsUnicode ? SB_GETTEXTW:SB_GETTEXTA
        ,p_PartNumber-1                                 ;-- wParam
        ,&l_Text                                        ;-- lParam
        ,,ahk_id %hSB%

    VarSetCapacity(l_Text,-1)
    Return l_Text
    }

;------------------------------
;
; Function: SBAR_GetTextStyle
;
; Description:
;
;   Returns the text style from the specified part of a status bar.
;
; Parameters:
;
;   See <Common Parameters> for more information.
;
; Remarks:
;
;   This function only works correctly when the status bar is in nonsimple (i.e.
;   standard) mode.  If used while in simple mode, invalid information will be
;   returned.  If the simple status bar mode is possible, use <SBAR_IsSimple> to
;   check the status bar mode before calling this function.
;
;-------------------------------------------------------------------------------
SBAR_GetTextStyle(hSB,p_PartNumber:=1)
    {
    Static Dummy71773837

          ;-- Possible return values
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

          ,SBT_OWNERDRAW:=0x1000
                ;-- The text is drawn by the parent window.

          ;-- Messages
          ,SB_GETTEXTA      :=0x402                     ;-- WM_USER + 2
          ,SB_GETTEXTW      :=0x40D                     ;-- WM_USER + 13
          ,SB_GETTEXTLENGTHA:=0x403                     ;-- WM_USER + 3
          ,SB_GETTEXTLENGTHW:=0x40C                     ;-- WM_USER + 12

    ;-- Get text length
    SendMessage
        ,A_IsUnicode ? SB_GETTEXTLENGTHW:SB_GETTEXTLENGTHA
        ,p_PartNumber-1                                 ;-- wParam
        ,0                                              ;-- lParam
        ,,ahk_id %hSB%

    Return ErrorLevel>>16&0xFFFF
    }

;------------------------------
;
; Function: SBAR_GetTipText
;
; Description:
;
;   Get the tooltip text for a status bar part.
;
; Parameters:
;
;   See <Common Parameters> for more information.
;
; Returns:
;
;   The tooltip text for the specified part.
;
; Warning:
;
;   There is no mechanism to identify the length of the tooltip text for a
;   status bar part so this function is forced to create a fixed-size buffer to
;   accommodate the text for all possible status bar tooltips.  At this writing,
;   the buffer can accommodate a maximum of 8,192 characters (8K for ANSI, 16K
;   for Unicode).  If the function attempts to get the text for a status bar
;   tooltip that is larger than the buffer, the request could cause a buffer
;   overflow which will cause AutoHotkey to crash.
;
;-------------------------------------------------------------------------------
SBAR_GetTipText(hSB,p_PartNumber:=1)
    {
    Static Dummy49660862
          ,MaxTCHARs:=0x2000

          ;-- Messages
          ,SB_GETTIPTEXTA:=0x412                        ;-- WM_USER + 18
          ,SB_GETTIPTEXTW:=0x413                        ;-- WM_USER + 19

    ;-- Get tip text
    VarSetCapacity(l_Text,MaxTCHARs*(A_IsUnicode ? 2:1),0)
    SendMessage
        ,A_IsUnicode ? SB_GETTIPTEXTW:SB_GETTIPTEXTA
        ,MaxTCHARs<<16|p_PartNumber-1                   ;-- wParam
        ,&l_Text                                        ;-- lParam
        ,,ahk_id %hSB%

    VarSetCapacity(l_Text,-1)
    Return l_Text
    }

;------------------------------
;
; Function: SBAR_Hide
;
; Description:
;
;   Hide a status bar control.
;
; Returns:
;
;   TRUE if successful, otherwise FALSE.
;
;-------------------------------------------------------------------------------
SBAR_Hide(hSB)
    {
    Control Hide,,,ahk_id %hSB%
    Return ErrorLevel ? False:True
    }

;------------------------------
;
; Function: SBAR_IsSimple
;
; Description:
;
;   Determines if the status bar control is in simple mode.
;
; Returns:
;
;   TRUE if the status bar control is in simple mode, otherwise FALSE.
;
;-------------------------------------------------------------------------------
SBAR_IsSimple(hSB)
    {
    Static SB_ISSIMPLE:=0x40E                           ;-- WM_USER + 14
    SendMessage SB_ISSIMPLE,0,0,,ahk_id %hSB%
    Return ErrorLevel ? True:False
    }

;------------------------------
;
; Function: SBAR_SetBKColor
;
; Description:
;
;   Set the background color in a status bar.
;
; Parameters:
;
;   p_Color - The new background color in RGB format or CLR_DEFAULT to set the
;       background color to the default color.  Alternatively, set to one of the
;       16 supported color names.  Ex: Blue.  See <SBAR_ColorName2RGB> for a
;       list of supported color names.
;
; Returns:
;
;   The previous background color in RGB format or CLR_DEFAULT if the previous
;   background color was the default color.
;
; Calls To Other Functions:
;
; * <SBAR_ColorName2RGB>
;
; Remarks:
;
;   See <Visual Styles> for more information.
;
;-------------------------------------------------------------------------------
SBAR_SetBKColor(hSB,p_Color)
    {
    Static Dummy53515339
          ,CLR_DEFAULT:=0xFF000000

          ;-- Message
          ,SB_SETBKCOLOR:=0x2001                        ;-- CCMFirst + 1

    ;-- Convert color name to RGB
    if p_Color is not Integer
        p_Color:=SBAR_ColorName2RGB(p_Color)

    ;-- Convert to BGR if needed
    if (p_Color<=0xFFFFFF)
        p_Color:=(p_Color&0xFF)<<16|p_Color&0xFF00|(p_Color>>16)&0xFF

    ;-- Set background color
    ;   The return value is the previous background color
    SendMessage SB_SETBKCOLOR,0,p_Color,,ahk_id %hSB%
    l_Color:=ErrorLevel

    ;-- Convert to RGB if needed
    if (l_Color<=0xFFFFFF)
        l_Color:=(l_Color&0xFF)<<16|l_Color&0xFF00|(l_Color>>16)&0xFF

    Return l_Color
    }

;------------------------------
;
; Function: SBAR_SetFont
;
; Description:
;
;   Set the font that the status bar is to use when drawing text.
;
; Parameters:
;
;   hFont - Handle to a logical font.  Set to 0 to use the default GUI font.
;
;   p_Redraw - Specifies whether the status bar should be redrawn immediately
;       upon setting the font.  If set to TRUE (the default), the status bar
;       redraws itself.  Exception: This  parameter is effectively ignored when
;       visual styles are disabled.
;
; Visual Styles:
;
;   If visual styles are enabled (the default for most computers), the height of
;   the status bar does not change as a result of receiving this message.
;   Dramatic changes to the font can cause the text to be clipped or to look
;   odd.  If needed, use <SBAR_SetMinHeight> to change the height of the status
;   bar.  Hint: Setting the minimum height to the height of the status bar font
;   is usually a good start.
;
;   If visual styles are disabled, changes to the font are immediate and the
;   height of the status bar is adjusted to reflect the new font.
;
;-------------------------------------------------------------------------------
SBAR_SetFont(hSB,hFont,p_Redraw:=True)
    {
    Static Dummy59476288
          ,DEFAULT_GUI_FONT:=17

          ;-- Messages
          ,WM_SETFONT:=0x30

    ;-- If needed, get the handle to the default GUI font
    if not hFont
        hFont:=DllCall("GetStockObject","Int",DEFAULT_GUI_FONT)

    ;-- Set font
    SendMessage WM_SETFONT,hFont,p_Redraw,,ahk_id %hSB%
    }

;------------------------------
;
; Function: SBAR_SetIcon
;
; Description:
;
;   Set the icon for a status bar part.
;
; Parameters:
;
;   hIcon - Handle to the icon to be set.  Set to 0 to remove the icon.
;
;   p_PartNumber - The 1-based index of the part that will receive the icon.
;       The default is 1.
;
;   p_DestroyPrevIcon - Set to TRUE (the default) to destroy the icon that was
;       replaced by this request (if any).  Set to FALSE to preserve the old
;       icon.  Preserving the icon may be required if the icon is used in
;       multiple locations or by other objects (menus, toolbars, etc.)
;
; Returns:
;
;   TRUE if successful, otherwise FALSE.
;
; Calls To Other Functions:
;
; * <SBAR_GetIcon>
; * <SBAR_SystemMessage>
;
; Remarks:
;
;   Use <SBAR_SetSimpleIcon> to set/remove the icon for the simple mode status
;   bar.
;
;   Unlike the native <SB_SetIcon at
;   https://autohotkey.com/docs/commands/GuiControls.htm#SB_SetIcon> function
;   that sets the icon for a status bar part from a specified file, this
;   function only sets the icon for a status bar part.  If needed, use
;   <SBAR_ExtractIcon> to extract an icon from a file.
;
;-------------------------------------------------------------------------------
SBAR_SetIcon(hSB,hIcon,p_PartNumber:=1,p_DestroyPrevIcon:=True)
    {
    Static SB_SETICON:=0x40F                            ;-- WM_USER + 15
    hIcon_old:=SBAR_GetIcon(hSB,p_PartNumber)
    SendMessage SB_SETICON,p_PartNumber-1,hIcon,,ahk_id %hSB%
    l_SetIconRC:=ErrorLevel
    if p_DestroyPrevIcon and hIcon_old
        if not DllCall("DestroyIcon","Ptr",hIcon_old)
            {
            l_SystemMessage:=SBAR_SystemMessage(A_LastError)
            outputdebug,
               (ltrim join`s
                Function: %A_ThisFunc% -
                Unexpected error from the "DestroyIcon" function.
                A_LastError: %A_LastError% - %l_SystemMessage%
               )
            }

    Return l_SetIconRC ? True:False
    }

;------------------------------
;
; Function: SBAR_SetMinHeight
;
; Description:
;
;   Set the minimum height of a status bar's drawing area.
;
; Parameters:
;
;   p_MinHeight - The minimum height, in pixels.  The minimum height is the sum
;       of p_MinHeight and twice the width, in pixels, of the vertical border of
;       the status bar.
;
;   p_AutoSize - Set to TRUE (the default) to automatically adjust the height
;       of the status bar to reflect the minimum height.  If set to FALSE, the
;       height will be adjusted the next time the status bar receives a WM_SIZE
;       message.
;
;-------------------------------------------------------------------------------
SBAR_SetMinHeight(hSB,p_MinHeight,p_AutoSize:=True)
    {
    Static Dummy92112798

           ;-- Messages
          ,SB_SETMINHEIGHT:=0x408                       ;-- WM_USER + 8
          ,WM_SIZE:=0x5

    ;-- Set minimum height
    SendMessage SB_SETMINHEIGHT,p_MinHeight,0,,ahk_id %hSB%
    if p_AutoSize
        SendMessage WM_SIZE,0,0,,ahk_id %hSB%
    }

;------------------------------
;
; Function: SBAR_SetParts
;
; Description:
;
;   Set the parts in a status bar.
;
; Parameters:
;
;   p_Width* - See the *Standard Syntax*, *Extended Syntax*, and *Usable Width*
;       sections for more information.
;
; Returns:
;
;   TRUE if successful, otherwise FALSE.
;
; Calls To Other Functions:
;
; * <SBAR_GetPartRect>
; * <SBAR_GetPartsCount>
;
; Standard Syntax:
;
;   The p_Width parameter should contain the width for every status bar part
;   except the last.  The last part will fill the remaining space of the status
;   bar.
;
;   If the parameter value is a simple integer (Ex: 100), the width is assumed
;   to be in pixels.
;
;   If the parameter value ends with a "%" character, the width is assumed to be
;   a percentage of the usable width of the status bar.  Ex: "25%" which is
;   calculated to be 25% of the usable width of the status bar.  This option
;   should only be used after the width of the status bar has been established.
;
;   If the parameter contains a "/" character, the width is assumed to be a
;   fraction of the usable width of the status bar.  Ex: "1/3" which is
;   calculated to be one third of the usable width of the status bar.  This
;   option should only be used after the width of the status bar has been
;   established.
;
;   If the part width values all contain integer values, the values are used by
;   the SB_SETPARTS message as is.  If any of the part width values contain a
;   percentage (Ex: 25%) or fraction (Ex: 1/3) values, these value are converted
;   to integer values before they are used by the SB_SETPARTs message.  For
;   example, if the p_Width parameter is set to 25%, and 100, the values sent to
;   the SB_SETPART message might be 150, 100, -1.
;
; Extended Syntax:
;
;   When the standard syntax for the p_Width parameter is used, the width of the
;   final (right-most) part is not entered because it's width is implied to be
;   whatever space is leftover after the other parts have been allocated. The
;   function uses -1 in place of the final part as an instruction to the
;   SB_SETPARTS message to create a part using whatever space is left over.  If
;   size of the window is changed, the right-most part will automatically
;   increase in size when the window width is increased, and decrease in size
;   with the window width is reduced.
;
;   When the extended syntax is used, the developer can set the width of one of
;   the parts to -1 as an instruction to automatically calculate the space
;   needed for the part based upon whatever usable space is left over.  For
;   example, if the p_Width parameter is set to 100, -1, and 100, three parts
;   are created. The 1st and 3rd parts will have a fixed width of 100 pixels.
;   The second part will have whatever space is left over.  When this syntax is
;   used, the size for all parts must be specified since there is no longer an
;   implied final (right-most) part.  Also, -1 can only used for one of the part
;   sizes.
;
;   As with the standard syntax, the part width values entered when using the
;   extended syntax are converted to integer values to use with the SB_SETPARTS
;   message.  For example, if the p_Width parameter is set to 25%, -1, and 100,
;   the values sent to the SB_SETPART message might be 150, 350, -1.
;
;   Note that the right-most part will not retain the size specified by this
;   function when the window is resized.  The part will increase in size when
;   the window size is increased and will be the first part to be reduced in
;   size when the window size is decreased.  One workaround is to create an
;   extra no-width (0 pixels) part after the last part so that the part will
;   retain it's size when the window size is increased.  A better solution is to
;   reset the part sizes when window size is changed.  See the example scripts
;   for an example.
;
; Usable Width:
;
;   The term "usable width" refers to the portion of the status bar that can be
;   used by status bar parts.  If the status bar includes a sizing grip (usually
;   included when the window is resizable), the usable width is reduced by the
;   width of the sizing grip.  Otherwise, the usable width is the same as the
;   actual width of the status bar.
;
;   Important: The usable width may not be calculated correctly if the status
;   bar is in simple mode.  If the window is resizable and a simple mode status
;   bar is possible, check the status bar mode before using a p_Width value that
;   calculates the width based on the usable width of the status bar.
;
; Remarks:
;
;   The SB_SETPARTS message establishes the number of parts and the potential
;   width of the parts.  The width of the parent window determines the actual
;   width of the parts.
;
;   This function can generate results that are different than the native
;   <SB_SetParts at
;   https://autohotkey.com/docs/commands/GuiControls.htm#SB_SetParts> function.
;   See the <DPI-Aware> topic for more information.
;
;   Design Limitation:
;
;   The width of the sizing grip is calculated by subtracting the
;   the right boundary position of the right-most (or only) part from the
;   current width of the status bar.  This works if no parts have been set or
;   if this function or the native SB_SetParts function set the parts for the
;   status bar.  In these cases, the part size for the right-most (or only) part
;   is always set to -1 indicating that the part will use whatever space is left
;   in the status bar.  However, if another program/routine sets the right-most
;   part to anything other than -1, the boundary of the right-most part will not
;   reflect the widest possible width of the part and therefore the calculation
;   may (read: will probably) be invalid.
;
;   The fix is the find another way to determine the width of the sizing grip.
;   A lot of internet searching but so far, nothing.
;
;-------------------------------------------------------------------------------
SBAR_SetParts(hSB,p_Width*)
    {
    Static Dummy74289707

          ;-- Status bar styles
          ,SBARS_SIZEGRIP:=0x100

          ;-- Messages
          ,SB_SETPARTS:=0x404                           ;-- WM_USER + 4

    ;-- Pop any trailing -1 parameters
    Loop
        {
        if not l_MaxIndex:=p_Width.MaxIndex()
            Break

        if (p_Width[l_MaxIndex]<>-1)
            Break

        p_Width.Pop()
        }

    ;-- Get the current width of the status bar
    ControlGetPos,,,l_StatusBarW,,,ahk_id %hSB%
    l_UsableSBW:=l_StatusBarW

    ;-- Status bar contains a sizing grip?
    WinGet l_Style,Style,ahk_id %hSB%
    if l_Style&SBARS_SIZEGRIP
        {
        ;-- Subtract the sizing grip width (if any) from l_UsableSBW
        ;   Note: The SBAR_GetPartRect request will fail if the status bar is in
        ;   simple mode.  If the request fails, the adjustment to l_UsableSBW
        ;   will not be made.
        if SBAR_GetPartRect(hSB,SBAR_GetPartsCount(hSB),,,l_Right)
            l_UsableSBW-=l_StatusBarW-l_Right
        }

    ;-- If needed, convert parameter values to pixels
    For l_Key,l_Width in p_Width
        {
        if l_Width is Integer
            Continue

        ;-- Remove any leading/trailing spaces
        l_Width:=Trim(l_Width)

        ;-- Width as a percentage
        if (SubStr(l_Width,0)="%")
            {
            l_Percent:=SubStr(l_Width,1,-1)
            if l_Percent is Number
                {
                p_Width[l_Key]:=Round(l_UsableSBW*(l_Percent/100))
                Continue
                }
            }

        ;-- Width as a fraction
        if (l_DivPos:=InStr(l_Width,"/"))
            {
            l_Fraction:=SubStr(l_Width,1,l_DivPos-1)/SubStr(l_Width,l_DivPos+1)
            if l_Fraction is Number
                {
                p_Width[l_Key]:=Round(l_UsableSBW*l_Fraction)
                Continue
                }
            }

        ;-- Bounce if invalid l_Width value
        outputdebug,
           (ltrim join`s
            Function: %A_ThisFunc% - Invalid width value: %l_Width%
           )

        Return False
        }

    ;-- Create and populate integer array
    l_LeftoverW  :=l_UsableSBW
    l_PartNumber :=0
    l_RECoord    :=0
    l_Recalculate:=False
    VarSetCapacity(l_IntegerArray,256*4,0)
    For l_Key,l_Width in p_Width
        {
        l_PartNumber++

        ;-- Request to recalculate?
        if (l_Width=-1)
            {
            l_Recalculate:=True
            Continue
            }

        ;-- Add to integer array
        l_RECoord+=l_Width
        NumPut(l_RECoord,l_IntegerArray,(l_PartNumber-1)*4,"Int")

        ;-- Subtract width from l_LeftoverW
        l_LeftoverW-=l_Width
        }

    ;-- Add the implied last part
    l_PartNumber++
    NumPut(-1,l_IntegerArray,(l_PartNumber-1)*4,"Int")

    ;-- Recalculate?
    ;   Note: If the recalculate flag is set, i.e. the developer set one of the
    ;   width values to -1, the widths for _all_ of the status bar parts
    ;   (including the last) has been defined.
    if l_Recalculate
        {
        l_PartNumber:=0
        l_RECoord   :=0

        ;-- Reload integer array
        For l_Key,l_Width in p_Width
            {
            l_PartNumber++
            if (l_Width=-1)
                l_Width:=(l_LeftoverW<0) ? 0:l_LeftoverW

            ;-- Add to integer array
            l_RECoord+=l_Width
            NumPut(l_RECoord,l_IntegerArray,(l_PartNumber-1)*4,"Int")
            }

        ;-- Replace the last array value with -1
        NumPut(-1,l_IntegerArray,(l_PartNumber-1)*4,"Int")
        }

    ;-- Set parts
    SendMessage SB_SETPARTS,l_PartNumber,&l_IntegerArray,,ahk_id %hSB%
    Return ErrorLevel
    }

;------------------------------
;
; Function: SBAR_SetSimple
;
; Description:
;
;   Specifies whether a status bar displays simple text or displays all parts as
;   set by a previous SB_SETPARTS message.
;
; Parameters:
;
;   p_Simple - Set to TRUE (the default) to change the status bar to simple
;       mode.  Set to FALSE to restore the status bar to the nonsimple (default)
;       mode where all parts are shown.
;
; Remarks:
;
;   See the <Simple Mode> topic for more information.
;
;-------------------------------------------------------------------------------
SBAR_SetSimple(hSB,p_Simple:=True)
    {
    Static SB_SIMPLE:=0x409                             ;-- WM_USER + 9
    SendMessage SB_SIMPLE,p_Simple,0,,ahk_id %hSB%
    }

;------------------------------
;
; Function: SBAR_SetSimpleIcon
;
; Description:
;
;   Set the icon for a simple mode status bar.
;
; Parameters:
;
;   hIcon - Handle to the icon to be set.  Set to 0 to remove the icon.
;
;   p_DestroyPrevIcon - Set to TRUE (the default) to destroy the icon that was
;       replaced by this request (if any).  Set to FALSE to retain the old icon.
;       This option is useful if the icon is used in multiple locations or by
;       other objects (menus, toolbars, etc.)
;
; Returns:
;
;   TRUE if successful, otherwise FALSE.
;
; Calls To Other Functions:
;
; * <SBAR_GetSimpleIcon>
; * <SBAR_SystemMessage>
;
;-------------------------------------------------------------------------------
SBAR_SetSimpleIcon(hSB,hIcon,p_DestroyPrevIcon:=True)
    {
    Static SB_SETICON:=0x40F                            ;-- WM_USER + 15
    hIcon_old:=SBAR_GetSimpleIcon(hSB)
    SendMessage SB_SETICON,-1,hIcon,,ahk_id %hSB%
    l_SetIconRC:=ErrorLevel
    if p_DestroyPrevIcon and hIcon_old
        if not DllCall("DestroyIcon","Ptr",hIcon_old)
            {
            l_SystemMessage:=SBAR_SystemMessage(A_LastError)
            outputdebug,
               (ltrim join`s
                Unexpected error from the "DestroyIcon" function.
                A_LastError: %A_LastError% - %l_SystemMessage%
               )
            }

    Return l_SetIconRC ? True:False
    }

;------------------------------
;
; Function: SBAR_SetSimpleOff
;
; Description:
;
;   Set the status bar to the nonsimple mode in which all parts will display as
;   set by a previous SB_SETPARTS message.
;
; Remarks:
;
;   See <SBAR_SetSimple> for more information.
;
;-------------------------------------------------------------------------------
SBAR_SetSimpleOff(hSB)
    {
    SBAR_SetSimple(hSB,False)
    }

;------------------------------
;
; Function: SBAR_SetSimpleText
;
; Description:
;
;   Set the text for a simple mode status bar.
;
; Parameters:
;
;   hSB - The handle to the status bar control.
;
;   p_Text - The text to set.
;
;   p_Style - The type of the drawing operation. [Optional]  The default is 0.
;       See <Visual Styles> for more information.
;
; Remarks:
;
;   This function works while the status bar is in simple or nonsimple mode.
;   However, the text set by this function is only seen when the status bar is
;   in simple mode.  See <SBAR_SetSimple> for more information.
;
;-------------------------------------------------------------------------------
SBAR_SetSimpleText(hSB,p_Text,p_Style:=0)
    {
    Static Dummy72331385
          ,SB_SIMPLEID:=0xFF

          ;-- Messages
          ,SB_SETTEXTA:=0x401                           ;-- WM_USER+1
          ,SB_SETTEXTW:=0x40B                           ;-- WM+USER+11

    ;-- Set status bar text
    SendMessage
        ,A_IsUnicode ? SB_SETTEXTW:SB_SETTEXTA
        ,p_Style|SB_SIMPLEID                            ;-- wParam (Style|Part)
        ,&p_Text                                        ;-- lParam (&Text)
        ,,ahk_id %hSB%
    }

;------------------------------
;
; Function: SBAR_SetSimpleTextWithTip
;
; Description:
;
;   Set the text and the tooltip text for a simple mode status bar.
;
; Parameters:
;
;   The same as <SBAR_SetSimpleText>.
;
; Calls To Other Functions:
;
; * <SBAR_SetSimpleText>
; * <SBAR_SetSimpleTipText>
;
;-------------------------------------------------------------------------------
SBAR_SetSimpleTextWithTip(hSB,p_Text,p_Style:=0)
    {
    SBAR_SetSimpleText(hSB,p_Text,p_Style)
    SBAR_SetSimpleTipText(hSB,p_Text)
    }

;------------------------------
;
; Function: SBAR_SetSimpleTipText
;
; Description:
;
;   Set the tooltip text for a status bar part.
;
; Parameters:
;
;   See <Common Parameters> for more information.
;
; Returns:
;
;   TRUE if successful, otherwise FALSE.
;
; Remarks:
;
;   The status bar needs the SBARS_TOOLTIPS style in order for this to work.
;   AutoHotkey includes this style by default when the status bar is created.
;
;-------------------------------------------------------------------------------
SBAR_SetSimpleTipText(hSB,p_Text)
    {
    Static Dummy37727485
          ,SB_SIMPLEID:=0xFF

          ;-- Status bar styles
          ,SBARS_TOOLTIPS:=0x800

          ;-- Messages
          ,SB_SETTIPTEXTA:=0x410                        ;-- WM_USER+16
          ,SB_SETTIPTEXTW:=0x411                        ;-- WM_USER+17

    ;-- Set tooltip text
    SendMessage
        ,A_IsUnicode ? SB_SETTIPTEXTW:SB_SETTIPTEXTA
        ,SB_SIMPLEID
        ,&p_Text
        ,,ahk_id %hSB%

    Return ErrorLevel
    }

;------------------------------
;
; Function: SBAR_SetText
;
; Description:
;
;   Set the text in the specified part of a status bar.
;
; Parameters:
;
;   hSB - The handle to the status bar control.
;
;   p_Text - The text to set.
;
;   p_PartNumber - 1-based index of the part to set. [Optional]  The default is
;       1.
;
;   p_Style - The type of the drawing operation. [Optional]  The default is 0.
;       See the function's static variables for a list of possible values.  See
;       <Visual Styles> for more information.
;
; Remarks:
;
;   Use <SBAR_SetSimpleText> to set the text for a simple mode status bar.
;
; Programming Notes:
; 
;   Both the part number and the style flags values are loaded to the low-order
;   word (16-bit) of the wParam parameter of the SendMessage command. The
;   high-order word of wParam is ignored.  This only works because the part
;   number only uses the low-byte of the low-order word because the possible
;   values are from 0 to 255 and all flag values only use the high-order bits of
;   a 16-bit value.  So... when the two values are combined, they only use a
;   single 16-bit value.  Efficient design perhaps but it is certainly unusual.
;   Note that other status bar messages that return the part number/flag values
;   (Ex: SB_GETTEXTLENGTH) load these values into separate 16-bit word values.
;
;-------------------------------------------------------------------------------
SBAR_SetText(hSB,p_Text,p_PartNumber:=1,p_Style:=0)
    {
    Static Dummy11152103

          ;-- Drawing operation types
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
          ,SB_SETTEXTA :=0x401                          ;-- WM_USER+1
          ,SB_SETTEXTW :=0x40B                          ;-- WM+USER+11

    ;-- Set status bar text
    SendMessage
        ,A_IsUnicode ? SB_SETTEXTW:SB_SETTEXTA
        ,p_Style|p_PartNumber-1                         ;-- wParam (Style|Part)
        ,&p_Text                                        ;-- lParam (&Text)
        ,,ahk_id %hSB%
    }

;------------------------------
;
; Function: SBAR_SetTextWithTip
;
; Description:
;
;   Set the text and the tooltip text for a status bar part.
;
; Parameters:
;
;   The same as <SBAR_SetText>.
;
; Calls To Other Functions:
;
; * <SBAR_SetText>
; * <SBAR_SetTipText>
;
; Credit:
;
; Idea of combining the two functions from *TheDewd*
; * https://autohotkey.com/boards/viewtopic.php?p=134818#p134818
;
;-------------------------------------------------------------------------------
SBAR_SetTextWithTip(hSB,p_Text,p_PartNumber:=1,p_Style:=0)
    {
    SBAR_SetText(hSB,p_Text,p_PartNumber,p_Style)
    SBAR_SetTipText(hSB,p_Text,p_PartNumber)
    }

;------------------------------
;
; Function: SBAR_SetTipText
;
; Description:
;
;   Set the tooltip text for a status bar part.
;
; Parameters:
;
;   p_Text - The tooltip text.
;
;   p_PartNumber - 1-based index of the part to set. [Optional]  The default is
;       1.
;
; Returns:
;
;   TRUE if successful, otherwise FALSE.
;
; Remarks:
;
;   The status bar needs the SBARS_TOOLTIPS style in order for this to work.
;   AutoHotkey includes this style by default when the status bar is created.
;
;-------------------------------------------------------------------------------
SBAR_SetTipText(hSB,p_Text,p_PartNumber:=1)
    {
    Static Dummy64553884

          ;-- Status bar styles
          ,SBARS_TOOLTIPS:=0x800

          ;-- Messages
          ,SB_SETTIPTEXTA:=0x410                        ;-- WM_USER+16
          ,SB_SETTIPTEXTW:=0x411                        ;-- WM_USER+17

    ;-- Set tooltip text
    SendMessage
        ,A_IsUnicode ? SB_SETTIPTEXTW:SB_SETTIPTEXTA
        ,p_PartNumber-1
        ,&p_Text
        ,,ahk_id %hSB%

    Return ErrorLevel
    }

;------------------------------
;
; Function: SBAR_Show
;
; Description:
;
;   Show (unhide) a status bar if it was previously hidden.
;
; Returns:
;
;   TRUE if successful, otherwise FALSE.
;
;-------------------------------------------------------------------------------
SBAR_Show(hSB)
    {
    Control Show,,,ahk_id %hSB%
    Return ErrorLevel ? False:True
    }

;------------------------------
;
; Function: SBAR_SystemMessage
;
; Description:
;
;   Converts a system message number into a readable message.
;
; Type:
;
;   Internal function.  Subject to change.
;
;-------------------------------------------------------------------------------
SBAR_SystemMessage(p_MessageNbr)
    {
    Static FORMAT_MESSAGE_FROM_SYSTEM:=0x1000

    ;-- Convert system message number into a readable message
    VarSetCapacity(l_Message,1024*(A_IsUnicode ? 2:1),0)
    DllCall("FormatMessage"
           ,"UInt",FORMAT_MESSAGE_FROM_SYSTEM           ;-- dwFlags
           ,"Ptr",0                                     ;-- lpSource
           ,"UInt",p_MessageNbr                         ;-- dwMessageId
           ,"UInt",0                                    ;-- dwLanguageId
           ,"Str",l_Message                             ;-- lpBuffer
           ,"UInt",1024                                 ;-- nSize (in TCHARS)
           ,"Ptr",0)                                    ;-- *Arguments

    ;-- Remove trailing CR+LF, if defined
    if (SubStr(l_Message,-1)="`r`n")
        StringTrimRight l_Message,l_Message,2

    ;-- Return system message
    Return l_Message
    }

;------------------------------
;
; Function: SBAR_VisualStyles
;
; Description:
;
;   Enable or disable visual styles for a status bar control.
;
; Parameters:
;
;   p_Enable - Set to TRUE (the default) to enable visual styles.  Set to FALSE
;       to disable visual styles.
;
; Remarks:
;
;   See <Visual Styles> for more information.
;
;-------------------------------------------------------------------------------
SBAR_VisualStyles(hSB,p_Enable:=True)
    {
    if p_Enable
        DllCall("uxtheme\SetWindowTheme","Ptr",hSB,"Str","","Ptr",0)
     else
        DllCall("uxtheme\SetWindowTheme","Ptr",hSB,"Ptr",0,"Str","")
    }
