/*
    v2.0.x release notes

    Possible script breaker
    -----------------------
    * Fnt_HardWordBreak moved out of the main library into a separate add-on
        function.  Function has been enhanced to support additional
        parameter values.  Also, the return value has changed.  See the function
        documentation for more information.
*/

/*
Title: Fnt Library v2.0.1

Group: Introduction

    Fonts are logical objects that instruct the computer how to draw text on a
    device (display, printers, plotters, etc.).  This library provides a means
    of managing some of the aspects of fonts used in AutoHotkey.

Group: AutoHotkey Compatibility

    This library was designed to run on all versions of AutoHotkey v1.1+: ANSI,
    Unicode, and Unicode 64-bit.

Group: Issues and Considerations

    The *<DPIScale at https://autohotkey.com/docs/commands/Gui.htm#DPIScale>*
    feature introduced in AutoHotkey v1.1.11 can produce unexpected results when
    the Fnt library is used to determine the size and/or position of anything
    GUI.  The DPIScale feature is enabled by default so if necessary, it must be
    manually disabled for each GUI by adding a "gui -DPIScale" command.
    Important: Conflicts with the DPIScale feature do not occur when using the
    default DPI setting, i.e. 96 DPI.  Errors only occur if using the large
    (120 DPI), larger (144 DPI), or a custom DPI setting.

Group: Links

    Font and Text Reference
    - <https://msdn.microsoft.com/en-us/library/windows/desktop/dd144824%28v=vs.85%29.aspx>

Group: Credit

 *  Some of the code in this library and in the example scripts was extracted
    from the AutoHotkey source.  Thanks to authors of *AutoHotkey*.

 *  The <Fnt_ChooseFont> function was originally adapted from the Dlg library
    which was published by *majkinetor*.

 *  The <Fnt_GetListOfFonts> function was inspired by an example published by
    *Sean*.

Group: Functions
*/

;------------------------------
;
; Function: Fnt_AddFontFile
;
; Description:
;
;   Add one or more fonts from a font file (Ex: "MySpecialFont.ttf") to the
;   system font table.
;
; Type:
;
;   Experimental.  Subject to change.
;
; Parameters:
;
;   p_File - The full path and name of the font file.
;
;   p_Private - If set to TRUE, only the process that called this function can
;       use the added font(s).
;
;   p_Hidden - If set to TRUE, the added font(s) cannot be enumerated, i.e. not
;       included when any program requests a list of fonts from the OS.
;
; Returns:
;
;   The number of the fonts added if successful, otherwise FALSE.
;
; Remarks:
;
;   All fonts added using this function are temporary.  If the p_Private
;   parameter is set to TRUE, the added font(s) are automatically removed when
;   the process that added the font(s) ends.  If p_Private is FALSE, the font(s)
;   are only available for the current session.  When the system restarts, the
;   font(s) will not be present.  If desired, use <Fnt_RemoveFontFile> to remove
;   the font(s) added by this function.
;
;   A complete list of the font file types that can be loaded as well as
;   additional considerations can be found <here at http://tinyurl.com/j3nrbw2>.
;
;-------------------------------------------------------------------------------
Fnt_AddFontFile(p_File,p_Private,p_Hidden=False)
    {
    Static Dummy0661

          ;-- Font Resource flags
          ,FR_PRIVATE :=0x10
          ,FR_NOT_ENUM:=0x20

          ;-- Messages and flags
          ,WM_FONTCHANGE :=0x1D
          ,HWND_BROADCAST:=0xFFFF

    ;-- Build flags
    l_Flags:=0
    if p_Private
        l_Flags|=FR_PRIVATE

    if p_Hidden
        l_Flags|=FR_NOT_ENUM

    ;-- Add font
    RC:=DllCall("AddFontResourceEx","Str",p_File,"UInt",l_Flags,"UInt",0)

    ;-- If one or more fonts were added, notify all top-level windows that the
    ;   pool of font resources has changed.
    if RC
        SendMessage WM_FONTCHANGE,0,0,,ahk_id %HWND_BROADCAST%,,,,1000
            ;-- Wait up to (but no longer than) 1000 ms for all windows to
            ;   respond to the message.

    Return RC
    }


;------------------------------
;
; Function: Fnt_ChooseFont
;
; Description:
;
;   Creates a Font dialog box that enables the user to choose attributes for a
;   logical font.
;
; Parameters:
;
;   hOwner - A handle to the window that owns the dialog box.  This parameter
;       can be any valid window handle or it can be set to 0 or null if the
;       dialog box has no owner.
;
;   r_Name - Typeface name. [Input/Output] On input, this variable can contain
;       contain the default typeface name.  On output, this variable will
;       contain the selected typeface name.
;
;   r_Options - Font options. [Input/Output] See the *Options* section for the
;       details.
;
;   p_Effects - If set to TRUE (the default), the dialog box will display the
;       controls that allow the user to specify strikeout, underline, and
;       text color options.
;
;   p_Flags - [Advanced Feature] Additional ChooseFont flags. [Optional]  The
;       default is 0 (no additional flags).  See the *Flags* section for more
;       information.
;
; Options:
;
;   On input, the r_Options parameter contains the default font options.  On
;   output, r_Options will contain the selected font options.  The following
;   space-delimited options (in alphabetical order) are available:
;
;   bold - On input, this option will preselect the "Bold" font style.  On
;       output, this option will be returned if a bold font was selected.
;
;   c{color} - Text color.  {color} is one of 16 color names (see the AutoHotkey
;       documentation for a list of supported color names) or a 6-digit hex RGB
;       color value.  Example values: Blue or FF00FA.  On input, this option
;       will attempt to pre-select the text color.  On output, this option is
;       returned with the selected text color.  Notes and exceptions: 1) The
;       default text color is pre-selected if a color option is not specified or
;       if the "Default" color is specified.  2) Color names (Ex: "Blue") are
;       only accepted on input.  A 6-digit hex RGB color value is set on output
;       (Ex: 0000FF).  Exception: If the default text color is selected, the
;       color name "Default" is set.  3) If p_Effects is FALSE, this option is
;       ignored on input and is not returned.
;
;   italic - On input, this option will preselect the "italic" font style.  On
;       output, this option will be returned if an italic font was selected.
;       Exception: If p_Effects is FALSE, this option is ignored on input and is
;       not returned.
;
;   s{SizeInPoints} -  Font size (in points).  For example: s12.  On input,
;       this option will load the font size and if on the dialog's "Size" list,
;       will preselect the font size.  On output, the font size that was
;       entered/selected is returned.
;
;   SizeMax{MaxPointSize} -  [Input only] The maximum point size the user can
;       enter/select.  For example: SizeMax72.  If this option is specified
;       without also specifying the SizeMin option, the SizeMin value is
;       automatically set to 1.
;
;   SizeMin{MinPointSize} - [Input only] The minimum point size the user can
;       enter/select.  For example: SizeMin10.  If this option is specified
;       without also specifying the SizeMax option, the SizeMax value is
;       automatically set to 0xBFFF (49151).
;
;   strike - On input, this option will check the "Strikeout" option.  On
;       output, this option will be returned if the "Strikeout" option was
;       checked.  Exception: If p_Effects is FALSE, this option is ignored on
;       input and is not returned.
;
;   underline -  On input, this option will check the "Underline" option.  On
;       output, this option will be returned if the "Underline" option was
;       checked.  Exception: If p_Effects is FALSE, this option is ignored on
;       input and is not returned.
;
;   w{FontWeight} - Font weight (thickness or boldness), which is an integer
;       between 1 and 1000.  For example, 400 is Normal and 700 is Bold.  On
;       input, this option will preselect the font style that most closely
;       matches the weight specified.  If not specified, the default weight for
;       the font is selected.  On output, this option is only returned if the
;       font weight is not Normal (400) and not Bold (700).
;
;   To specify more than one option, include a space between each.  For
;   example: s12 cFF0000 bold.  On output, the selected options are defined
;   in the same format.
;
; Returns:
;
;   TRUE if a font was selected, otherwise FALSE is returned if the dialog was
;   canceled or if an error occurred.
;
; Calls To Other Functions:
;
; * <Fnt_ColorName2RGB>
; * <Fnt_GetWindowTextColor>
;
; Flags:
;
;   Flexibility in the operation of the Font dialog box is available via a large
;   number of ChooseFont flags.  For this function, the flags are determined by
;   constants, options in the r_Options parameter, and the value of the
;   p_Effects parameter.  Although the flags set by these conditions will handle
;   the needs of the majority of developers, there are a few ChooseFont flags
;   that could provide additional value.  The p_Flags parameter is used to _add_
;   additional ChooseFont flags to control the operation of the Font dialog box.
;   See the function's static variables for a list of possible flag values.
;
;   This is an advanced feature.  Including invalid or conflicting flags may
;   produce unexpected results.  Be sure to test throroughly.  With that said,
;   many of the flags can be used to limit or exclude fonts.  This is a simple
;   but powerful feature to only show the fonts that are needed for a
;   particular task.
;
; Remarks:
;
;   The ChooseFont dialog box supports the selection of text color.  Although
;   text color is an attribute of many common controls, please note that it is
;   not a font attribute.
;
;   Although the font weight can be any number between 1 and 1000, most fonts
;   only support 400 (Normal/Regular) and 700 (Bold).  A very small number of
;   fonts support additional font weights.  At this writing, the ChooseFont
;   dialog does not display the font weight as a number.  Instead, the font
;   weight is displayed as font styles like Regular, ExtraLight, Black, etc. See
;   the <CreateFont at http://tinyurl.com/n2qe72w> documentation for a list of
;   common font weight names and their associated font weight values.
;
;   The SizeMin and SizeMax options (r_Options parameter) not only affect the
;   list of fonts sizes that are shown in the Font Size selection list box in
;   the Font dialog box, they affect the font size that can be manually entered
;   in the Font Size combo box.  If a font size that is outside the boundaries
;   set by the SizeMin and SizeMax options, a MsgBox dialog is shown and the
;   user is not allowed to continue until a valid font size is entered/selected.
;   Warning: If the value of the SizeMin option is greater than the SizeMax
;   option, the "ChooseFont" API function will generate a CFERR_MAXLESSTHANMIN
;   error and will return without showing the Font dialog box.
;
;-------------------------------------------------------------------------------
Fnt_ChooseFont(hOwner=0,ByRef r_Name="",ByRef r_Options="",p_Effects=True,p_Flags=0)
    {
    Static Dummy3155

          ;-- ChooseFont flags
          ,CF_SCREENFONTS:=0x1
                ;-- List only the screen fonts supported by the system.  This
                ;   flag is automatically set.

          ,CF_PRINTERFONTS:=0x2
                ;-- List only printer fonts.  Not supported by this libary.  Do
                ;   not use.

          ,CF_SHOWHELP:=0x4
                ;-- Causes the dialog box to display the Help button.  Not
                ;   supported by this library.  Do not use.

          ,CF_ENABLEHOOK:=0x8
                ;-- Enables the hook procedure specified in the lpfnHook member
                ;   of this structure.  Not supported by this library.  Do not
                ;   use.

          ,CF_ENABLETEMPLATE:=0x10
                ;-- Indicates that the hInstance and lpTemplateName members
                ;   specify a dialog box template to use in place of the default
                ;   template.  Not supported by this library.  Do not use.

          ,CF_ENABLETEMPLATEHANDLE:=0x20
                ;-- Indicates that the hInstance member identifies a data block
                ;   that contains a preloaded dialog box template.  The system
                ;   ignores the lpTemplateName member if this flag is specified.
                ;   Not supported by this library.  Do not use.

          ,CF_INITTOLOGFONTSTRUCT:=0x40
                ;-- Use the structure pointed to by the lpLogFont member to
                ;   initialize the dialog box controls.  This flag is
                ;   automatically set.

          ,CF_USESTYLE:=0x80
                ;-- Not supported by this library.  Do not use.

          ,CF_EFFECTS:=0x100
                ;-- Causes the dialog box to display the controls that allow
                ;   the user to specify strikeout, underline, and text color
                ;   options.  This flag is automatically set if the p_Effects
                ;   parameter is set to TRUE.

          ,CF_APPLY:=0x200
                ;-- Causes the dialog box to display the Apply button.  Not
                ;   supported by this library.  Do not use.

          ,CF_SCRIPTSONLY:=0x400
                ;-- Prevent the dialog box from displaying or selecting OEM or
                ;   Symbol fonts.

          ,CF_NOOEMFONTS:=0x800
                ;-- Prevent the dialog box from displaying or selecting OEM
                ;   fonts.  Note: The CF_NOVECTORFONTS constant (not used here)
                ;   is set to the same value as this constant.

          ,CF_NOSIMULATIONS:=0x1000
                ;-- Prevent the dialog box from displaying or selecting font
                ;   simulations.

          ,CF_LIMITSIZE:=0x2000
                ;-- Select only font sizes within the range specified by the
                ;   nSizeMin and nSizeMax members.  This flag is automatically
                ;   added if the SizeMin and/or the SizeMax options (p_Options
                ;   parameter) are used.

          ,CF_FIXEDPITCHONLY:=0x4000
                ;-- Show and allow selection of only fixed-pitch fonts.

          ,CF_WYSIWYG:=0x8000
                ;-- Obsolete.  ChooseFont ignores this flag.

          ,CF_FORCEFONTEXIST:=0x10000
                ;-- Display an error message if the user attempts to select a
                ;   font or style that is not listed in the dialog box.

          ,CF_SCALABLEONLY:=0x20000
                ;-- Show and allow selection of only scalable fonts.

          ,CF_TTONLY:=0x40000
                ;-- Show and allow the selection of only TrueType fonts.

          ,CF_NOFACESEL:=0x80000
                ;-- Prevent the dialog box from displaying an initial selection
                ;   for the font name combo box.

          ,CF_NOSTYLESEL:=0x100000
                ;-- Prevent the dialog box from displaying an initial selection
                ;   for the Font Style combo box.

          ,CF_NOSIZESEL:=0x200000
                ;-- Prevent the dialog box from displaying an initial selection
                ;   for the Font Size combo box.

          ,CF_SELECTSCRIPT:=0x400000
                ;-- When specified on input, only fonts with the character set
                ;   identified in the lfCharSet member of the LOGFONT structure
                ;   are displayed.  The user will not be allowed to change the
                ;   character set specified in the Scripts combo box.  Not
                ;   supported by this library.  Do not use.

          ,CF_NOSCRIPTSEL:=0x800000
                ;-- Disables the Script combo box.

          ,CF_NOVERTFONTS:=0x1000000
                ;-- Display only horizontally oriented fonts.

          ,CF_INACTIVEFONTS:=0x2000000
                ;-- ChooseFont should additionally display fonts that are set to
                ;   Hide in Fonts Control Panel.  Windows 7+.

          ;-- Device constants
          ,LOGPIXELSY:=90

          ;-- Misc. font constants
          ,CFERR_MAXLESSTHANMIN:=0x2002
          ,FW_NORMAL           :=400
          ,FW_BOLD             :=700
          ,LF_FACESIZE         :=32     ;-- In TCHARS

    ;--------------
    ;-- Initialize
    ;--------------
    ;-- Collect the number of pixels per logical inch along the screen height
    hDC:=DllCall("CreateDC","Str","DISPLAY","Ptr",0,"Ptr",0,"Ptr",0)
    l_LogPixelsY:=DllCall("GetDeviceCaps","Ptr",hDC,"Int",LOGPIXELSY)
    DllCall("DeleteDC","Ptr",hDC)

    ;-- Default window text color
    l_WindowTextColor:=Fnt_GetWindowTextColor()

    ;--------------
    ;-- Parameters
    ;--------------
    r_Name:=Trim(r_Name," `f`n`r`t`v")
        ;-- Remove all leading/trailing white space

    ;-- p_Flags
    if p_Flags is not Integer
        p_Flags:=0x0

    p_Flags|=CF_SCREENFONTS|CF_INITTOLOGFONTSTRUCT
    if p_Effects
        p_Flags|=CF_EFFECTS

    ;-----------
    ;-- Options
    ;-----------
    ;-- Initialize
    o_Color    :=l_WindowTextColor
    o_Height   :=13
    o_Italic   :=False
    o_Size     :=""     ;-- Undefined
    o_SizeMin  :=""     ;-- Undefined
    o_SizeMax  :=""     ;-- Undefined
    o_Strikeout:=False
    o_Underline:=False
    o_Weight   :=""     ;-- Undefined

    ;-- Extract options (if any) from r_Options
    Loop Parse,r_Options,%A_Space%
        {
        if (InStr(A_LoopField,"bold")=1)
            o_Weight:=FW_BOLD
        else if (InStr(A_LoopField,"italic")=1)
            o_Italic:=True
        else if (InStr(A_LoopField,"sizemin")=1)
            {
            o_SizeMin:=SubStr(A_LoopField,8)
            if o_SizeMin is not Integer
                o_SizeMin:=1
            }
        else if (InStr(A_LoopField,"sizemax")=1)
            {
            o_SizeMax:=SubStr(A_LoopField,8)
            if o_SizeMax is not Integer
                o_SizeMax:=0xBFFF
            }
        else if (InStr(A_LoopField,"strike")=1)
            o_Strikeout:=True
        else if (InStr(A_LoopField,"underline")=1)
            o_Underline:=True
        else if (InStr(A_LoopField,"c")=1 and StrLen(A_Loopfield)>1)
            {
            ;-- Initial value
            l_Color:=o_Color:=SubStr(A_LoopField,2)

            ;-- If not set already, prepend hex prefix
            if not InStr(SubStr(o_Color,1,2),"0x")
                o_Color:="0x" . o_Color

            ;-- If not a valid hex value, convert color name to hex value
            ;   Note: All color names have 2 or more non-hex digit values
            if o_Color is not xDigit
                o_Color:=Fnt_ColorName2RGB(l_Color)
            }
        else if (InStr(A_LoopField,"s")=1)
            o_Size:=SubStr(A_LoopField,2)
        else if (InStr(A_LoopField,"w")=1)
            o_Weight:=SubStr(A_LoopField,2)
        }

    ;-- If needed, reset Effects options to defaults
    if not p_Flags & CF_EFFECTS
        {
        o_Color    :=l_WindowTextColor
        o_Strikeout:=False
        o_Underline:=False
        }

    ;--------------------------
    ;-- Convert or fix invalid
    ;-- or unspecified options
    ;--------------------------
    if o_Color is Space  ;-- No color options
        o_Color:=l_WindowTextColor

    ;-- Convert color to BRG
    o_Color:=((o_Color&0xFF)<<16)+(o_Color&0xFF00)+((o_Color>>16)&0xFF)

    if o_SizeMin is Integer
        if o_SizeMax is Space
            o_SizeMax:=0xBFFF

    if o_SizeMax is Integer
        if o_SizeMin is Space
            o_SizeMin:=1

    if o_Weight is not Integer
        o_Weight:=FW_NORMAL

    ;-- If needed, convert point size to height, in logical units
    if o_Size is Integer
        o_Height:=Round(o_Size*l_LogPixelsY/72)*-1

    ;-- Update flags
    if o_SizeMin or o_SizeMax
        p_Flags|=CF_LIMITSIZE

    ;-----------------------
    ;-- Populate structures
    ;-----------------------
    ;-- Create, initialize, and populate LOGFONT structure
    VarSetCapacity(LOGFONT,A_IsUnicode ? 92:60,0)
    NumPut(o_Height,   LOGFONT,0,"Int")                 ;-- lfHeight
    NumPut(o_Weight,   LOGFONT,16,"Int")                ;-- lfWeight
    NumPut(o_Italic,   LOGFONT,20,"UChar")              ;-- lfItalic
    NumPut(o_Underline,LOGFONT,21,"UChar")              ;-- lfUnderline
    NumPut(o_Strikeout,LOGFONT,22,"UChar")              ;-- lfStrikeOut

    if StrLen(r_Name)
        StrPut(SubStr(r_Name,1,31),&LOGFONT+28,LF_FACESIZE)
            ;-- lfFaceName

    ;-- Create, initialize, and populate CHOOSEFONT structure
    CFSize:=VarSetCapacity(CHOOSEFONT,(A_PtrSize=8) ? 104:60,0)

    NumPut(CFSize,CHOOSEFONT,0,"UInt")
        ;-- lStructSize
    NumPut(hOwner,CHOOSEFONT,(A_PtrSize=8) ? 8:4,"Ptr")
        ;-- hwndOwner
    NumPut(&LOGFONT,CHOOSEFONT,(A_PtrSize=8) ? 24:12,"Ptr")
        ;-- lpLogFont
    NumPut(p_Flags,CHOOSEFONT,(A_PtrSize=8) ? 36:20,"UInt")
        ;-- Flags
    NumPut(o_Color,CHOOSEFONT,(A_PtrSize=8) ? 40:24,"UInt")
        ;-- rgbColors

    if o_SizeMin
        NumPut(o_SizeMin,CHOOSEFONT,(A_PtrSize=8) ? 92:52,"Int")
            ;-- nSizeMin

    if o_SizeMax
        NumPut(o_SizeMax,CHOOSEFONT,(A_PtrSize=8) ? 96:56,"Int")
            ;-- nSizeMax

    ;---------------
    ;-- Choose font
    ;---------------
    if not DllCall("comdlg32\ChooseFont" . (A_IsUnicode ? "W":"A"),"Ptr",&CHOOSEFONT)
        {
        if CDERR:=DllCall("comdlg32\CommDlgExtendedError")
            {
            if (CDERR=CFERR_MAXLESSTHANMIN)
                outputdebug,
                   (ltrim join`s
                    Function: %A_ThisFunc% Error -
                    The size specified in the SizeMax option is less than the
                    size specified in the SizeMin option.
                   )
             else
                outputdebug,
                   (ltrim join`s
                    Function: %A_ThisFunc% Error -
                    Unknown error returned from the "ChooseFont" API. Error
                    code: %CDERR%.
                   )
            }

        Return False
        }

    ;------------------
    ;-- Rebuild output
    ;------------------
    ;-- Typeface name
    r_Name:=StrGet(&LOGFONT+28,LF_FACESIZE)

    ;-- r_Options
    r_Options:="s" . Floor(NumGet(CHOOSEFONT,(A_PtrSize=8) ? 32:16,"Int")/10)
        ;-- iPointSize

    if p_Flags & CF_EFFECTS
        {
        l_Color:=NumGet(CHOOSEFONT,(A_PtrSize=8) ? 40:24,"UInt")
            ;-- rgbColors

        ;-- Convert to RGB
        l_Color:=((l_Color&0xFF)<<16)+(l_Color&0xFF00)+((l_Color>>16)&0xFF)

        ;-- Append to r_Options in 6-digit hex format
        if (l_Color=l_WindowTextColor)  ;-- i.e. the default
            r_Options.=A_Space . "cDefault"
         else
            r_Options.=A_Space . "c" . Format("{:06X}",l_Color)
        }

    l_Weight:=NumGet(LOGFONT,16,"Int")
    if (l_Weight<>FW_NORMAL)
        if (l_Weight=FW_BOLD)
            r_Options.=A_Space . "bold"
         else
            r_Options.=A_Space . "w" . l_Weight

    if NumGet(LOGFONT,20,"UChar")
        r_Options.=A_Space . "italic"

    if NumGet(LOGFONT,21,"UChar")
        r_Options.=A_Space . "underline"

    if NumGet(LOGFONT,22,"UChar")
        r_Options.=A_Space . "strike"

    Return True
    }


;------------------------------
;
; Function: Fnt_ColorName2RGB
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
;   A 6-digit hexadecimal RGB value.  Ex: 0xFF00FF.  If an invalid color name is
;   specified or if the "Default" color name is specified, the value from
;   <Fnt_GetWindowTextColor> is returned.
;
; Calls To Other Functions:
;
; * <Fnt_GetWindowTextColor>
;
;-------------------------------------------------------------------------------
Fnt_ColorName2RGB(p_ColorName)
    {
    Static Dummy3054

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

    ;-- Set to the default (covers the "Default" color name)
    l_Color:=Fnt_GetWindowTextColor()

    ;-- Convert if supported color name (not case sensitive)
    if Color_%p_ColorName% is not Space
        l_Color:=Color_%p_ColorName%

    Return l_Color
    }

;------------------------------
;
; Function: Fnt_CompactPath
;
; Description:
;
;   Shortens a file path to fit within a given pixel width by replacing path
;   components with ellipses.
;
; Parameters:
;
;   hFont - Handle to a logical font. Set to 0 to use the default GUI font.
;
;   p_Path - A file path to shorten.  Ex: "C:\MyFiles\A long file name.txt"
;
;   p_MaxW - The maximum width for the return path, in pixels.
;
;   p_Strict - If set to TRUE, the function will return null if the minimum
;       path value is longer (measured in pixels) than p_MaxW.  The default is
;       FALSE.  See the *Remarks* section for more information.
;
; Returns:
;
;   The compacted path.
;
; Remarks:
;
;   By default, the PathCompactPath function will not compact the path beyond
;   a minimum value which is usually a base file name preceded by ellipses.  If
;   the value of p_MaxW is too small (relative to the specified font), the
;   width of the minimum path value (measured in pixels) may be larger than
;   p_MaxW.  If the p_Strict parameter is set to TRUE, the return value will be
;   set to null if the compacted path is wider than p_MaxW.  If p_Strict is set
;   to FALSE (the default), the function will return whatever value is returned
;   from the PathCompactPath function.
;
;-------------------------------------------------------------------------------
Fnt_CompactPath(hFont,p_Path,p_MaxW,p_Strict=False)
    {
    Static Dummy6513
          ,DEFAULT_GUI_FONT:=17
          ,HWND_DESKTOP    :=0
          ,MAX_PATH        :=260

    ;-- If needed, get the handle to the default GUI font
    if not hFont
        hFont:=DllCall("GetStockObject","Int",DEFAULT_GUI_FONT)

    ;-- Select the font into the device context for the desktop
    hDC      :=DllCall("GetDC","Ptr",HWND_DESKTOP)
    old_hFont:=DllCall("SelectObject","Ptr",hDC,"Ptr",hFont)

    ;-- Compact path
    VarSetCapacity(l_Path,MAX_PATH*(A_IsUnicode ? 2:1),0)
    l_Path:=p_Path
    RC:=DllCall("shlwapi\PathCompactPath" . (A_IsUnicode ? "W":"A")
        ,"Ptr",hDC          ;-- hDC,
        ,"Str",l_Path       ;-- lpszPath
        ,"UInt",p_MaxW)     ;-- dx

    ;-- Release the objects needed by the PathCompactPath function
    DllCall("SelectObject","Ptr",hDC,"Ptr",old_hFont)
        ;-- Necessary to avoid memory leak

    DllCall("ReleaseDC","Ptr",HWND_DESKTOP,"Ptr",hDC)

    ;-- Strict?
    if p_Strict
        if (Fnt_GetStringWidth(hFont,l_Path)>p_MaxW)
            l_Path:=""

    ;-- Return to sender
    Return l_Path
    }


;------------------------------
;
; Function: Fnt_CreateFont
;
; Description:
;
;   Creates a logical font.
;
; Parameters:
;
;   p_Name - Typeface name of the font. [Optional]  If null (the default), the
;       default GUI font name is used.
;
;   p_Options - Font options. [Optional] See the *Options* section for more
;       information.
;
; Options:
;
;   The following options can be used in the p_Options parameter.
;
;   bold -  Set the font weight to bold (700).
;
;   italic - Create an italic font.
;
;   q{quality} - Text rendering quality. For example: q3.  See the function's
;       static variables for a list of possible quality values. AutoHotkey
;       v1.0.90+.
;
;   s{SizeInPoints} - Font size (in points).  For example: s12
;
;   strike - Create a strikeout font.
;
;   underline - Create an underlined font.
;
;   w{FontWeight} - Font weight (thickness or boldness), which is an integer
;       between 1 and 1000 (400 is normal and 700 is bold).  For example: w600
;
;   To specify more than one option, include a space between each.  For
;   example: s12 bold
;
; Returns:
;
;   A handle to a logical font.
;
; Calls To Other Functions:
;
; * <Fnt_GetFontName>
; * <Fnt_GetFontSize>
;
; Remarks:
;
;   When no longer needed, call <Fnt_DeleteFont> to delete the font.
;
;-------------------------------------------------------------------------------
Fnt_CreateFont(p_Name="",p_Options="")
    {
    Static Dummy3436

          ;-- Device constants
          ,LOGPIXELSY:=90

          ;-- Font quality
          ,DEFAULT_QUALITY       :=0
          ,DRAFT_QUALITY         :=1
          ,PROOF_QUALITY         :=2  ;-- AutoHotkey default
          ,NONANTIALIASED_QUALITY:=3
          ,ANTIALIASED_QUALITY   :=4
          ,CLEARTYPE_QUALITY     :=5

          ;-- Misc. font constants
          ,CLIP_DEFAULT_PRECIS:=0
          ,DEFAULT_CHARSET    :=1
          ,FF_DONTCARE        :=0
          ,FW_NORMAL          :=400
          ,FW_BOLD            :=700
          ,OUT_TT_PRECIS      :=4

    ;-- Parameters
    p_Name:=Trim(p_Name," `f`n`r`t`v")
        ;-- Remove all leading/trailing white space

    ;-- Initialize options
    o_Italic   :=False
    o_Quality  :=PROOF_QUALITY
    o_Size     :=""         ;-- Undefined
    o_Strikeout:=False
    o_Underline:=False
    o_Weight   :=""         ;-- Undefined

    ;-- Extract options (if any) from p_Options
    Loop Parse,p_Options,%A_Space%
        {
        if (InStr(A_LoopField,"bold")=1)
            o_Weight:=FW_BOLD
        else if (InStr(A_LoopField,"italic")=1)
            o_Italic:=True
        else if (InStr(A_LoopField,"strike")=1)
            o_Strikeout:=True
        else if (InStr(A_LoopField,"underline")=1)
            o_Underline:=True
        else if (InStr(A_LoopField,"q")=1)
            o_Quality:=SubStr(A_LoopField,2)
        else if (InStr(A_LoopField,"s")=1)
            o_Size:=SubStr(A_LoopField,2)
        else if (InStr(A_LoopField,"w")=1)
            o_Weight:=SubStr(A_LoopField,2)
        }

    ;-- Fix invalid or unspecified parameters/options
    if p_Name is Space
        p_Name:=Fnt_GetFontName()   ;-- Typeface name of default GUI font

    if o_Quality is not Integer
        o_Quality:=PROOF_QUALITY

    if o_Size is not Integer
        o_Size:=Fnt_GetFontSize()   ;-- Font size of default GUI font

    if o_Weight is not Integer
        o_Weight:=FW_NORMAL

    ;-- Convert point size to height, in logical units
    hDC:=DllCall("CreateDC","Str","DISPLAY","Ptr",0,"Ptr",0,"Ptr",0)
    o_Height:=Round(o_Size*DllCall("GetDeviceCaps","Ptr",hDC,"Int",LOGPIXELSY)/72)*-1
    DllCall("DeleteDC","Ptr",hDC)

    ;-- Create font
    hFont:=DllCall("CreateFont"
        ,"Int",o_Height                                 ;-- nHeight
        ,"Int",0                                        ;-- nWidth
        ,"Int",0                                        ;-- nEscapement (0=normal horizontal)
        ,"Int",0                                        ;-- nOrientation
        ,"Int",o_Weight                                 ;-- fnWeight
        ,"UInt",o_Italic                                ;-- fdwItalic
        ,"UInt",o_Underline                             ;-- fdwUnderline
        ,"UInt",o_Strikeout                             ;-- fdwStrikeOut
        ,"UInt",DEFAULT_CHARSET                         ;-- fdwCharSet
        ,"UInt",OUT_TT_PRECIS                           ;-- fdwOutputPrecision
        ,"UInt",CLIP_DEFAULT_PRECIS                     ;-- fdwClipPrecision
        ,"UInt",o_Quality                               ;-- fdwQuality
        ,"UInt",FF_DONTCARE                             ;-- fdwPitchAndFamily
        ,"Str",p_Name)                                  ;-- lpszFace

    Return hFont
    }


;------------------------------
;
; Function: Fnt_CreateCaptionFont
;
; Description:
;
;   Creates a logical font with the same attributes as the caption font.
;
; Returns:
;
;   A handle to a logical font.
;
; Calls To Other Functions:
;
; * <Fnt_GetNonClientMetrics>
;
; Remarks:
;
;   When no longer needed, call <Fnt_DeleteFont> to delete the font.
;
;-------------------------------------------------------------------------------
Fnt_CreateCaptionFont()
    {
    Return DllCall("CreateFontIndirect","Ptr",Fnt_GetNonClientMetrics()+24)
    }


;------------------------------
;
; Function: Fnt_CreateMenuFont
;
; Description:
;
;   Creates a logical font with the same attributes as the font used in menu
;   bars.
;
; Returns:
;
;   A handle to a logical font.
;
; Calls To Other Functions:
;
; * <Fnt_GetNonClientMetrics>
;
; Remarks:
;
;   When no longer needed, call <Fnt_DeleteFont> to delete the font.
;
;-------------------------------------------------------------------------------
Fnt_CreateMenuFont()
    {
    Return DllCall("CreateFontIndirect","Ptr",Fnt_GetNonClientMetrics()+(A_IsUnicode ? 224:160))
    }


;------------------------------
;
; Function: Fnt_CreateMessageFont
;
; Description:
;
;   Creates a logical font with the same attributes as the font used in message
;   boxes.
;
; Returns:
;
;   A handle to a logical font.
;
; Calls To Other Functions:
;
; * <Fnt_GetNonClientMetrics>
;
; Remarks:
;
;   When no longer needed, call <Fnt_DeleteFont> to delete the font.
;
;-------------------------------------------------------------------------------
Fnt_CreateMessageFont()
    {
    Return DllCall("CreateFontIndirect","Ptr",Fnt_GetNonClientMetrics()+(A_IsUnicode ? 408:280))
    }


;------------------------------
;
; Function: Fnt_CreateSmCaptionFont
;
; Description:
;
;   Creates a logical font with the same attributes as the small caption font.
;
; Returns:
;
;   A handle to a logical font.
;
; Calls To Other Functions:
;
; * <Fnt_GetNonClientMetrics>
;
; Remarks:
;
;   When no longer needed, call <Fnt_DeleteFont> to delete the font.
;
;-------------------------------------------------------------------------------
Fnt_CreateSmCaptionFont()
    {
    Return DllCall("CreateFontIndirect","Ptr",Fnt_GetNonClientMetrics()+(A_IsUnicode ? 124:92))
    }


;------------------------------
;
; Function: Fnt_CreateStatusFont
;
; Description:
;
;   Creates a logical font with the same attributes as the font used in status
;   bars and tooltips.
;
; Returns:
;
;   A handle to a logical font.
;
; Calls To Other Functions:
;
; * <Fnt_GetNonClientMetrics>
;
; Remarks:
;
;   When no longer needed, call <Fnt_DeleteFont> to delete the font.
;
;-------------------------------------------------------------------------------
Fnt_CreateStatusFont()
    {
    Return DllCall("CreateFontIndirect","Ptr",Fnt_GetNonClientMetrics()+(A_IsUnicode ? 316:220))
    }


;------------------------------
;
; Function: Fnt_DeleteFont
;
; Description:
;
;   Deletes a logical font.
;
; Parameters:
;
;   hFont - Handle to a logical font.
;
; Returns:
;
;   TRUE if the font was successfully deleted or if no font was specified,
;   otherwise FALSE.
;
; Remarks:
;
;   It is not necessary (but it is not harmful) to delete stock objects.
;
;-------------------------------------------------------------------------------
Fnt_DeleteFont(hFont)
    {
    if not hFont  ;-- Zero or null
        Return True

    Return DllCall("DeleteObject","Ptr",hFont) ? True:False
    }


;------------------------------
;
; Function: Fnt_DialogTemplateUnits2Pixels
;
; Description:
;
;   Converts dialog template units to pixels for a font.
;
; Parameters:
;
;   hFont - Handle to a logical font.  Set to 0 to use the default GUI font.
;
;   p_HorzDTUs - Horizontal dialog template units.
;
;   p_VertDTUs - Vertical dialog template units.
;
;   r_Width, r_Height - Output variables. [Optional] These variables are
;       loaded with the width and height conversions of the values from the
;       p_HorzDTUs and p_VertDTUs parameters.
;
; Returns:
;
;   Address to a SIZE structure.
;
; Calls To Other Functions:
;
; * <Fnt_GetDialogBaseUnits>
;
;-------------------------------------------------------------------------------
Fnt_DialogTemplateUnits2Pixels(hFont,p_HorzDTUs,p_VertDTUs=0,ByRef r_Width="",ByRef r_Height="")
    {
    Static Dummy0741
          ,SIZE
          ,s_hFont:=-1
          ,s_HorzDBUs
          ,s_VertDBUs

    ;-- If needed, initialize and get Dialog Base Units
    if (hFont<>s_hFont)
        {
        s_hFont:=hFont
        VarSetCapacity(SIZE,8,0)
        Fnt_GetDialogBaseUnits(hFont,s_HorzDBUs,s_VertDBUs)
        }

    ;-- Convert DTUs to w/h, in pixels
    NumPut(r_Width :=Round(p_HorzDTUs*s_HorzDBUs/4),SIZE,0,"Int")
    NumPut(r_Height:=Round(p_VertDTUs*s_VertDBUs/8),SIZE,4,"Int")
    Return &SIZE
    }


;------------------------------
;
; Function: Fnt_EnumFontFamExProc
;
; Description:
;
;   The default EnumFontFamiliesEx callback function for the Fnt library.
;
; Type:
;
;   Internal callback function.  Do not call directly.
;
; Parameters:
;
;   lpelfe - A pointer to an LOGFONT structure that contains information about
;       the logical attributes of the font.  To obtain additional information
;       about the font, you can cast the result as an ENUMLOGFONTEX or
;       ENUMLOGFONTEXDV structure.
;
;   lpntme - A pointer to a structure that contains information about the
;       physical attributes of a font.  The function uses the NEWTEXTMETRICEX
;       structure for TrueType fonts; and the TEXTMETRIC structure for other
;       fonts. This can be an ENUMTEXTMETRIC structure.
;
;   FontType - The type of the font. This parameter can be a combination of
;       DEVICE_FONTTYPE, RASTER_FONTTYPE, or TRUETYPE_FONTTYPE.
;
;   p_Flags (i.e. lParam) - The application-defined data passed by the
;       EnumFontFamiliesEx function.
;
; Returns:
;
;   TRUE.
;
; Remarks:
;
;   This function uses a global variable (Fnt_EnumFontFamExProc_List) to build
;   the list of typeface names.  Since this function is called many times for
;   every request, the typeface name is always appended to this variable.  Be
;   sure to set the Fnt_EnumFontFamExProc_List variable to null before every
;   request.
;
;-------------------------------------------------------------------------------
Fnt_EnumFontFamExProc(lpelfe,lpntme,FontType,p_Flags)
    {
    Global Fnt_EnumFontFamExProc_List
    Static Dummy6247

          ;-- Character sets
          ,ANSI_CHARSET       :=0
          ,DEFAULT_CHARSET    :=1
          ,SYMBOL_CHARSET     :=2
          ,MAC_CHARSET        :=77
          ,SHIFTJIS_CHARSET   :=128
          ,HANGUL_CHARSET     :=129
          ,JOHAB_CHARSET      :=130
          ,GB2312_CHARSET     :=134
          ,CHINESEBIG5_CHARSET:=136
          ,GREEK_CHARSET      :=161
          ,TURKISH_CHARSET    :=162
          ,VIETNAMESE_CHARSET :=163
          ,HEBREW_CHARSET     :=177
          ,ARABIC_CHARSET     :=178
          ,BALTIC_CHARSET     :=186
          ,RUSSIAN_CHARSET    :=204
          ,THAI_CHARSET       :=222
          ,EASTEUROPE_CHARSET :=238
          ,OEM_CHARSET        :=255

          ;-- ChooseFont flags
          ,CF_SCRIPTSONLY:=0x400
                ;-- Exclude OEM and Symbol fonts.

          ,CF_NOOEMFONTS:=0x800
                ;-- Exclude OEM fonts.  Ex: Terminal

          ,CF_NOSIMULATIONS:=0x1000
                ;-- [Future] Exclude font simulations.

          ,CF_FIXEDPITCHONLY:=0x4000
                ;-- Include fixed-pitch fonts only.

          ,CF_SCALABLEONLY:=0x20000
                ;-- Include scalable fonts only.  Scalable fonts include vector
                ;   fonts, scalable printer fonts, TrueType fonts, and fonts
                ;   scaled by other technologies.

          ,CF_TTONLY:=0x40000
                ;-- Include TrueType fonts only.

          ,CF_NOVERTFONTS:=0x1000000
                ;-- Exclude vertical fonts.

;;;;;          ,CF_INACTIVEFONTS:=0x2000000
;;;;;                ;-- [Future] Include fonts that are set to Hide in Fonts Control
;;;;;                ;   Panel.  Windows 7+.
;;;;;
          ,CF_NOSYMBOLFONTS:=0x10000000
                ;-- [Custom Flag]  Exclude symbol fonts.

          ,CF_VARIABLEPITCHONLY:=0x20000000
                ;-- [Custom Flag]  Include variable pitch fonts only.

          ,CF_FUTURE:=0x40000000
                ;-- [Custom Flag]  Future.

          ,CF_FULLNAME:=0x80000000
                ;-- [Custom Flag, Advanced Feature]  If specified, returns the
                ;   full name of the font.  For example, ABC Font Company
                ;   TrueType Bold Italic Sans Serif.

          ;-- LOGFONT constants
          ,LF_FACESIZE      :=32     ;-- In TCHARS
          ,LF_FULLFACESIZE  :=64

          ;-- Font types
          ,RASTER_FONTTYPE  :=0x1
          ,DEVICE_FONTTYPE  :=0x2
          ,TRUETYPE_FONTTYPE:=0x4

          ;-- TEXTMETRIC flags
          ,TMPF_FIXED_PITCH:=0x1
                ;-- If this bit is set, the font is a variable pitch font.  If
                ;   this bit is clear, the font is a fixed pitch font.  Note
                ;   very carefully that those meanings are the opposite of what
                ;   the constant name implies.
          ,TMPF_VECTOR     :=0x2
          ,TMPF_TRUETYPE   :=0x4
          ,TMPF_DEVICE     :=0x8

    ;-- Name
    l_FaceName:=StrGet(lpelfe+28,LF_FACESIZE)
    l_FullName:=StrGet(lpelfe+(A_IsUnicode ? 92:60),LF_FULLFACESIZE)

    ;-- Pitch and Family
    l_PitchAndFamily:=NumGet(lpntme+0,A_IsUnicode ? 55:51,"UChar")

    ;-- Character set
    l_CharSet:=NumGet(lpntme+0,A_IsUnicode ? 56:52,"UChar")

    ;-- Check p_Flags to exclude requested fonts
    if p_Flags & (CF_SCRIPTSONLY|CF_NOOEMFONTS)
        if (l_CharSet=OEM_CHARSET)
            Return True  ;-- Continue enumeration

    if p_Flags & (CF_SCRIPTSONLY|CF_NOSYMBOLFONTS)
        if (l_CharSet=SYMBOL_CHARSET)
            Return True  ;-- Continue enumeration

    if p_Flags & CF_FIXEDPITCHONLY
        if l_PitchAndFamily & TMPF_FIXED_PITCH  ;-- i.e. variable pitch
            Return True  ;-- Continue enumeration

    if p_Flags & CF_SCALABLEONLY
        if not (l_PitchAndFamily & (TMPF_VECTOR|TMPF_TRUETYPE))
            Return True  ;-- Continue enumeration

    if p_Flags & CF_TTONLY
        if not (FontType & TRUETYPE_FONTTYPE)
            Return True  ;-- Continue enumeration

    if p_Flags & CF_NOVERTFONTS
        if (SubStr(l_FaceName,1,1)="@")
            Return True  ;-- Continue enumeration

    if p_Flags & CF_VARIABLEPITCHONLY
        if not (l_PitchAndFamily & TMPF_FIXED_PITCH)
            Return True  ;-- Continue enumeration

    ;-- Append font name to the list
    Fnt_EnumFontFamExProc_List.=(StrLen(Fnt_EnumFontFamExProc_List) ? "`n":"")
        . (p_Flags & CF_FULLNAME ? l_FullName:l_FaceName)

    Return True  ;-- Continue enumeration
    }


;------------------------------
;
; Function: Fnt_FontExists
;
; Description:
;
;   Determines if a font exists.
;
; Type:
;
;   Experimental/Preview.  Subject to change.
;
; Parameters:
;
;   p_Name* - Zero or more parameters containing a typeface font name (Ex:
;       "Arial"), an AutoHotkey object with an array of typeface font names (Ex:
;       ["Consolas","KaiTi","Courier"]), a comma-delimited list of typeface font
;       names (Ex: "Arial,Verdana,Helvetica"), or any combination of these
;       types.  See the *Remarks* section for more information.
;
; Returns:
;
;   The first typeface font name that exists from the p_Name parameter(s) (also
;       tests as TRUE) if successful, otherwise null (also tests as FALSE).
;
; Calls To Other Functions:
;
; * <Fnt_CreateFont>
; * <Fnt_DeleteFont>
; * <Fnt_GetFontName>
;
; Remarks:
;
; * Although not case sensitive, the exact font name must be specified.
;
; * The font name is returned (i.e. successful) if the name is a valid font
;   substitute.  Ex: "Helv", "Times", "MS Shell Dlg", etc.
;
; * Leading and trailing white space, single quote, and double quote characters
;   are ignored.  For example, "Arial,Segoe UI,Verdana" is the same as "Arial,
;   'Segoe UI', Verdana"
;
;-------------------------------------------------------------------------------
Fnt_FontExists(p_Name*)
    {
    ;-- Initialize
    FontNames:=[]

    ;-- Extract font names from parameter(s).  Load to FontNames
    For l_ParamIndex,l_ParamString in p_Name
        {
        if IsObject(l_ParamString)
            {
            For l_Key,l_String in l_ParamString
                Loop Parse,l_String,`,
                    {
                    l_Name:=Trim(A_LoopField," `f`n`r`t`v'""")
                        ;-- Remove all leading/trailing white spaces, single
                        ;   quote, or double quote chars

                    if l_Name  ;-- Ignore blank/null strings
                        FontNames.Push(l_Name)
                    }
            }
        else  ;-- not an object
            {
            Loop Parse,l_ParamString,`,
                {
                l_Name:=Trim(A_LoopField," `f`n`r`t`v'""")
                    ;-- Remove all leading/trailing white spaces, single quote,
                    ;   and double quote chars

                if l_Name  ;-- Ignore blank/null strings
                    FontNames.Push(l_Name)
                }
            }
        }

    For l_Index,l_Name in FontNames
        {
        ;-- Create a temporary font, collect the typeface name, and delete
        hFont:=Fnt_CreateFont(l_Name)
        l_CreatedName:=Fnt_GetFontName(hFont)
        Fnt_DeleteFont(hFont)

        ;-- Return name if it matches the supplied name
        if (SubStr(l_Name,1,31)=l_CreatedName)
            Return l_Name
        }

    ;-- Return null if nothing found
    Return
    }


;------------------------------
;
; Function: Fnt_FontSizeToFit
;
; Description:
;
;   Determines the largest font size that can be used to fit a string within
;   a specified width.
;
; Type:
;
;   Experimental/Preview.  Subject to change.
;
; Parameters:
;
;   hFont - Handle to a logical font.  Set to 0 to use the default GUI font.
;
;   p_String - Any string.  If this parameter is null, the current (or default)
;       font size is returned.
;
;   p_Width - The width to fit the string, in pixels.
;
; Returns:
;
;   The font size (in points) needed to fit the specified string within the
;   specified size.
;
; Calls To Other Functions:
;
; * <Fnt_CreateFont>
; * <Fnt_DeleteFont>
; * <Fnt_FOGetSize>
; * <Fnt_GetFontName>
; * <Fnt_GetFontOptions>
; * <Fnt_GetFontSize>
; * <Fnt_GetStringSize>
;
; Remarks:
;
; * This function uses a brute-force method to determine the font size needed.
;   The current font (from the hFont parameter) is checked first and then
;   the size is incremented or decremented by one until the desired size is
;   found.  Although this method is crude and can be resource intensive if
;   there is large difference between the initial and final font size, it
;   appears to be accurate for all fonts and all strings.  The function works
;   best if the developer starts with a font that is as close to desired size as
;   possible.  If possible, this methodology will be improved in the future.
;
; * If the string cannot fit into the specified width, the smallest font size
;   available is returned.  For scalable fonts, this size will always be 1.
;   For non-scalable fonts, the size will be whatever is the lowest font size
;   is available.
;
; * This function calculates the point size of a font that is needed for a
;   specified width.  However, the current version of the function does not take
;   into consideration the height of the font.  If the value returned by this
;   function is used to set the font of a GUI control, the program may need to
;   also set/correct the height of the control to avoid clipping or gaps.
;
; * The amount of space necessary to fit text within a fixed-size GUI control is
;   usually a bit more than the size of the text itself.  Calculating the amount
;   of dead/filler space required by the control for a specific font size is not
;   too difficult.  However, identifying how must filler is needed when the font
;   size is not known is a bit more difficult, if not impossible.  Artificially
;   increasing the length of the string (p_String parameter) by one or more
;   characters or artificially reducing the width (p_Width parameter) by a small
;   amount will increase the accuracy (and usefulness) of the font size returned
;   by this function if the value is used on a control that requires dead/filler
;   space.  See the example script for an example of this technique.
;
; * The resources used by this function are very reasonable if the font size
;   change is relatively small (<50 point size change).  However, if the change
;   is large (>250 point size change) or very large (>500 point size change),
;   the response time can range anywhere from noticeable to significant (>1
;   second).  If there is possibility of a large font size change in the script,
;   performance can be significantly improved by setting *SetBatchLines* to a
;   higher value before calling this function.  For example:
;
;       (start code)
;       SetBatchLines 50ms
;       FontSize:=Fnt_FontSizeToFit(hFont,...)
;       SetBatchLines 10ms  ;-- This is the system default
;       (end)
;
;-------------------------------------------------------------------------------
Fnt_FontSizeToFit(hFont,p_String,p_Width)
    {
    Static s_MaxFontSize:=1500

    ;-- Collect font name and font options
    l_Font       :=Fnt_GetFontName(hFont)
    l_FontOptions:=Fnt_GetFontOptions(hFont)

    ;-- Extract size from the options
    l_Size:=Fnt_FOGetSize(l_FontOptions,10)  ;-- 10 is the fail-safe default

    ;-- Bounce if p_String is null
    if not StrLen(p_String)
        Return l_Size

    ;-- Get the width of the string with the current font
    Fnt_GetStringSize(hFont,p_String,l_Width)

    ;-- We're done if it's an exact match
    if (l_Width=p_Width)
        Return l_Size

    ;-- Set l_LastValidSize
    ;   Note: The initial value of this variable determines whether the font
    ;   size needs be to increased or decreased.
    l_LastValidSize:=(l_Width<p_Width) ? l_Size:0

    ;-- Initialize for the loop
    l_ActualSize       :=l_Size
    l_LastActualSize   :=l_Size
    l_NoSizeChangeCount:=0

    ;-- Find the largest font size for the string
    Loop
        {
        if not l_LastValidSize  ;-- Size will be less than the starting size
            {
            ;-- Break if too small
            if (l_Size<2)
                {
                l_LastValidSize:=l_ActualSize
                Break
                }

            ;-- Decrement size
            l_Size--
            }
         else  ;-- Size will be larger than the starting size
            {
            ;-- Increment size
            l_Size++

            ;-- Break if too large
            if (l_Size>s_MaxFontSize)
                Break
            }

        ;-- Create a temporary font with the new size
        hFontTemp:=Fnt_CreateFont(l_Font,l_FontOptions . " s" . l_Size)

        ;-- Collect the width of the string with the temporary font
        Fnt_GetStringSize(hFontTemp,p_String,l_Width)

        ;-- Collect the actual size of the new font
        ;   Note: For non-scalable fonts, the actual size may be different than
        ;   the requested size.
        l_ActualSize:=Fnt_GetFontSize(hFontTemp)

        ;-- Delete the temporary font
        Fnt_DeleteFont(hFontTemp)

        ;-- Update l_NoSizeChangeCount
        if (l_ActualSize=l_LastActualSize)
            l_NoSizeChangeCount++
         else
            l_NoSizeChangeCount:=0

        ;-- Reset l_LastActualSize
        l_LastActualSize:=l_ActualSize

        ;-- Are we done?
        if not l_LastValidSize  ;-- Size will be less than the starting size
            {
            if (l_Width<=p_Width)
                {
                l_LastValidSize:=l_ActualSize
                Break
                }
            }
         else  ;-- Size will be larger than the starting size
            {
            if (l_Width>=p_Width)
                Break

            ;-- Update l_LastValidSize
            l_LastValidSize:=l_ActualSize
            }

        ;-- Break if the actual size has not changed in 10 iterations
        ;   Note: This can occur if using a non-scalable font
        if (l_NoSizeChangeCount>=10)
            {
            l_LastValidSize:=l_ActualSize
            Break
            }
        }

    ;-- Return to sender
    Return l_LastValidSize
    }


;------------------------------
;
; Function: Fnt_FontSizeToFitHeight
;
; Description:
;
;   Determines the largest font size that can be used to fit within a specified
;   height.
;
; Type:
;
;   Experimental/Preview.  Subject to change.
;
; Parameters:
;
;   hFont - Handle to a logical font.  Set to 0 to use the default GUI font.
;
;   p_Height - The height, in pixels, to fit the font.
;
; Returns:
;
;   The font size (in points) needed to fit within the specified height.
;
; Calls To Other Functions:
;
; * <Fnt_CreateFont>
; * <Fnt_DeleteFont>
; * <Fnt_FOGetSize>
; * <Fnt_GetFontHeight>
; * <Fnt_GetFontName>
; * <Fnt_GetFontOptions>
; * <Fnt_GetFontSize>
;
; Remarks:
;
;   If a logical font cannot fit into the specified height, the smallest font
;   size available is returned.  For scalable fonts, this size will always be 1.
;   For non-scalable fonts, the size will be whatever is the lowest font size
;   is available.
;
;-------------------------------------------------------------------------------
Fnt_FontSizeToFitHeight(hFont,p_Height)
    {
    Static Dummy3851
          ,s_MaxFontSize:=1500

          ;-- Device constants
          ,LOGPIXELSY:=90

    ;-- Collect the number of pixels per logical inch along the screen height
    hDC:=DllCall("CreateDC","Str","DISPLAY","Ptr",0,"Ptr",0,"Ptr",0)
    l_LogPixelsY:=DllCall("GetDeviceCaps","Ptr",hDC,"Int",LOGPIXELSY)
    DllCall("DeleteDC","Ptr",hDC)

    ;-- Use the height and internal leading value of the current font to
    ;   estimate the new height and font size.
    l_Height:=Fnt_GetFontHeight(hFont)
    l_FontInternalLeading:=Fnt_GetFontInternalLeading(hFont)
    l_EsimatedHeight     :=p_Height-(p_Height*(l_FontInternalLeading/l_Height))
    l_EstimatedSize      :=Floor(l_EsimatedHeight*72/l_LogPixelsY)
    if (l_EstimatedSize<1)
        l_EstimatedSize:=1

    ;-- Create a temporary font using the estimated new size
    hFontTemp:=Fnt_CreateFont(Fnt_GetFontName(hFont),Fnt_GetFontOptions(hFont) . " s" . l_EstimatedSize)

    ;-- Collect font information
    l_Font       :=Fnt_GetFontName(hFontTemp)
    l_FontOptions:=Fnt_GetFontOptions(hFontTemp)
    l_Height     :=Fnt_GetFontHeight(hFontTemp)

    ;-- Extract the size from the font options.  It may be different than the
    ;   requested size.
    l_Size:=Fnt_FOGetSize(l_FontOptions,10)  ;-- 10 is the fail-safe default

    ;-- Delete the temporary font
    Fnt_DeleteFont(hFontTemp)

    ;-- We're done if it's an exact match
    if (l_Height=p_Height)
        Return l_Size

    ;-- Set l_LastValidSize
    ;   Note: The initial value of this variable determines whether the font
    ;   size needs be to increased or decreased.
    l_LastValidSize:=(l_Height<p_Height) ? l_Size:0

    ;-- Initialize for the loop
    l_ActualSize       :=l_Size
    l_LastActualSize   :=l_Size
    l_NoSizeChangeCount:=0

    ;-- Find the largest font size for the requested height
    Loop
        {
        if not l_LastValidSize  ;-- Size will be less than the starting size
            {
            ;-- Break if too small
            if (l_Size<2)
                {
                l_LastValidSize:=l_ActualSize
                Break
                }

            ;-- Decrement size
            l_Size--
            }
         else  ;-- Size will be larger than the starting size
            {
            ;-- Increment size
            l_Size++

            ;-- Break if too large
            if (l_Size>s_MaxFontSize)
                Break
            }

        ;-- Create a temporary font with the new size
        hFontTemp:=Fnt_CreateFont(l_Font,l_FontOptions . " s" . l_Size)

        ;-- Collect the height of the temporary font
        l_Height:=Fnt_GetFontHeight(hFontTemp)

        ;-- Collect the actual size of the new font
        ;   Note: For non-scalable fonts, the actual size may be different than
        ;   the requested size.
        l_ActualSize:=Fnt_GetFontSize(hFontTemp)

        ;-- Delete the temporary font
        Fnt_DeleteFont(hFontTemp)

        ;-- Update l_NoSizeChangeCount
        if (l_ActualSize=l_LastActualSize)
            l_NoSizeChangeCount++
         else
            l_NoSizeChangeCount:=0

        ;-- Reset l_LastActualSize
        l_LastActualSize:=l_ActualSize

        ;-- Are we done?
        if not l_LastValidSize  ;-- Size will be less than the starting size
            {
            if (l_Height<=p_Height)
                {
                l_LastValidSize:=l_ActualSize
                Break
                }
            }
         else  ;-- Size will be larger than the starting size
            {
            if (l_Height>=p_Height)
                Break

            ;-- Update l_LastValidSize
            l_LastValidSize:=l_ActualSize
            }

        ;-- Break if the actual size has not changed in 10 iterations
        ;   Note: This can occur if using a non-scalable font
        if (l_NoSizeChangeCount>9)
            {
            l_LastValidSize:=l_ActualSize
            Break
            }
        }

    ;-- Return to sender
    Return l_LastValidSize
    }


;------------------------------
;
; Function: Fnt_FODecrementSize
;
; Description:
;
;   Decrements the value of the size option within a font options string.
;
; Type:
;
;   Helper function.
;
; Parameters:
;
;   r_FO - Variable that contains font options in the AutoHotkey format.
;
;   p_DecrementValue - Decrement value.  The default is 1.
;
;   p_MinSize - The minimize size.  The default is 1.
;
; Returns:
;
;   TRUE if successful, otherwise FALSE.  FALSE is returned if a "s"ize option
;   is not defined or if decrementing the size would set the value below the
;   p_MinSize value.
;
; Calls To Other Functions:
;
; * <Fnt_FOGetSize>
; * <Fnt_FOSetSize>
;
;-------------------------------------------------------------------------------
Fnt_FODecrementSize(ByRef r_FO,p_DecrementValue=1,p_MinSize=1)
    {
    if l_Size:=Fnt_FOGetSize(r_FO)
        if (l_Size-p_DecrementValue>=p_MinSize)
            {
            Fnt_FOSetSize(r_FO,l_Size-p_DecrementValue)
            Return True
            }

    Return False
    }

;------------------------------
;
; Function: Fnt_FOGetColor
;
; Description:
;
;   Gets the color name or RBG color value from the color option within a font
;   option string.
;
; Type:
;
;   Helper function.
;
; Parameters:
;
;   p_FO - A string that contains font options in the AutoHotkey format.
;
;   p_DefaultColor - The value returned if no color option has been specified.
;       Set to a color name (see the AutoHotkey documentation for a list of
;       supported color names), a 6-digit RGB value, the word "Default" to use
;       the system's default text color, or null (the default) to indicate no
;       default color.  Example values: "Red", "FF23AB", "Default".
;
;   p_ColorName2RGB - If set to TRUE and the color option (or p_DefaultColor
;       if no color options are found) contains a valid color name (Ex:
;       "Fuchsia"), the color name will be converted to a 6-digit RGB Hex value
;       (Ex: "FF00FF").
;
; Returns:
;
;   The color specified by the last "c"olor option if found, otherwise the value
;   specified in the p_DefaultColor parameter, if any.
;
; Remarks:
;
;   Since possible colors include 0x0 and "000000", testing the return value for
;   a TRUE/FALSE value will not always give the desired result.  Instead, check
;   for a null/not null value or check the length of the return value.
;
;-------------------------------------------------------------------------------
Fnt_FOGetColor(p_FO,p_DefaultColor="",p_ColorName2RGB=False)
    {
    l_Color   :=""
    l_FoundPos:=1
    Loop
        {
        if not l_FoundPos:=RegExMatch(A_Space . p_FO,"i) c[0-9|a-z]+",l_REOutput,l_FoundPos)
            Break

        l_Color:=SubStr(l_REOutput,3)
        l_FoundPos+=StrLen(l_REOutput)
        }

    l_Color:=StrLen(l_Color) ? l_Color:p_DefaultColor
    if StrLen(l_Color)
        if p_ColorName2RGB
            if l_Color is not xDigit
                l_Color:=SubStr(Fnt_ColorName2RGB(l_Color),3)

    Return l_Color
    }


;------------------------------
;
; Function: Fnt_FOGetSize
;
; Description:
;
;   Gets the size value of the last size option within a font options string.
;
; Type:
;
;   Helper function.
;
; Parameters:
;
;   p_FO - A string that contains font options in the AutoHotkey format.
;
;   p_DefaultSize - The value returned if no size option has been specified.
;       The default is FALSE (0).
;
; Returns:
;
;   The size specified by the last "s"ize option if found, otherwise the value
;   of the p_DefaultSize parameter which if not specified is FALSE (0).
;
;-------------------------------------------------------------------------------
Fnt_FOGetSize(p_FO,p_DefaultSize=0)
    {
    Static s_RegExPattern:="i) s[0-9]+ "
    l_Size    :=""
    l_FoundPos:=1
    Loop
        {
        if not l_FoundPos:=RegExMatch(A_Space . p_FO . A_Space,s_RegExPattern,l_REOutput,l_FoundPos)
            Break

        l_Size:=SubStr(l_REOutput,3,-1)
        l_FoundPos+=StrLen(l_REOutput)-1
        }

    Return StrLen(l_Size) ? l_Size:p_DefaultSize
    }


;------------------------------
;
; Function: Fnt_FOIncrementSize
;
; Description:
;
;   Increments the value of the size option within a font options string.
;
; Type:
;
;   Helper function.
;
; Parameters:
;
;   r_FO - Variable that contains font options in the AutoHotkey format.
;
;   p_IncrementValue - Increment value.  The default is 1.
;
;   p_MaxSize - The maximum size.  The default is 999.
;
; Returns:
;
;   TRUE if successful, otherwise FALSE.  FALSE is returned if a "s"ize option
;   is not defined or if incrementing the size would set the value above the
;   p_MinSize value.
;
; Calls To Other Functions:
;
; * <Fnt_FOGetSize>
; * <Fnt_FOSetSize>
;
;-------------------------------------------------------------------------------
Fnt_FOIncrementSize(ByRef r_FO,p_IncrementValue=1,p_MaxSize=999)
    {
    if l_Size:=Fnt_FOGetSize(r_FO)
        if (l_Size+p_IncrementValue<=p_MaxSize)
            {
            Fnt_FOSetSize(r_FO,l_Size+p_IncrementValue)
            Return True
            }

    Return False
    }


;------------------------------
;
; Function: Fnt_FORemoveColor
;
; Description:
;
;   Removes all color options from a font options string.
;
; Type:
;
;   Helper function.
;
; Parameters:
;
;   r_FO - Variable that contains font options in the AutoHotkey format.
;
; Returns:
;
;   TRUE if at least one color option was removed, otherwise FALSE.
;
; Calls To Other Functions:
;
; * <Fnt_FOGetColor>
;
;-------------------------------------------------------------------------------
Fnt_FORemoveColor(ByRef r_FO)
    {
    if StrLen(Fnt_FOGetColor(r_FO))
        {
        r_FO:=RegExReplace(A_Space . r_FO,"i) c[0-9|a-z]+","")
        StringTrimLeft r_FO,r_FO,1
        Return True
        }

    Return False
    }


;------------------------------
;
; Function: Fnt_FOSetColor
;
; Description:
;
;   Sets or replaces all color options within a font options string.
;
; Type:
;
;   Helper function.
;
; Parameters:
;
;   r_FO - Variable that contains font options in the AutoHotkey format.
;
;   p_Color - Color name or 6-digit RGB value.
;
; Calls To Other Functions:
;
; * <Fnt_FOGetColor>
;
;-------------------------------------------------------------------------------
Fnt_FOSetColor(ByRef r_FO,p_Color)
    {
    ;-- Bounce if p_Size is null/space(s)
    if p_Color is Space
        return

    ;-- Remove all leading/trailing white space
    p_Color:=Trim(p_Color," `f`n`r`t`v")

    ;-- Set color
    if StrLen(Fnt_FOGetColor(r_FO))
        {
        r_FO:=RegExReplace(A_Space . r_FO,"i) c[0-9|a-z]+",A_Space . "c" . p_Color)
        StringTrimLeft r_FO,r_FO,1
        }
     else
        r_FO.=(StrLen(r_FO) ? A_Space:"") . "c" . p_Color
    }


;------------------------------
;
; Function: Fnt_FOSetSize
;
; Description:
;
;   Sets or replaces all size options within a font options string.
;
; Type:
;
;   Helper function.
;
; Parameters:
;
;   r_FO - Variable that contains font options in the AutoHotkey format.
;
;   p_Size - Font size to set.
;
; Calls To Other Functions:
;
; * <Fnt_FOGetSize>
;
; Remarks:
;
;   No changes are made if p_Size does not contain an integer value.
;
;-------------------------------------------------------------------------------
Fnt_FOSetSize(ByRef r_FO,p_Size)
    {
    Static s_RegExPattern:="i) s[0-9]+ "

    ;-- Bounce if null/space(s) or non-integer
    p_Size:=Trim(p_Size," `f`n`r`t`v")
        ;-- Remove all leading/trailing white space

    if p_Size is Space
        return

    if p_Size is not Integer
        return

    ;-- If not currently defined, add "s"ize option to the end
    if not Fnt_FOGetSize(r_FO)
        {
        r_FO.=(StrLen(r_FO) ? A_Space:"") . "s" . p_Size
        return
        }

    ;-- Set all "s"ize font options
    l_StartPos:=1
    Loop
        {
        if not l_StartPos:=RegExMatch(A_Space . r_FO . A_Space,s_RegExPattern,l_REOutput,l_StartPos)
            Break

        ;-- Replace
        r_FO:=RegExReplace(A_Space . r_FO . A_Space,s_RegExPattern,A_Space . "s" . p_Size . A_Space,l_Count,1,l_StartPos)

        ;-- Remove leading and trailing spaces
        r_FO:=SubStr(r_FO,2,-1)

        ;-- Update start position
        l_StartPos+=StrLen(A_Space . "s" . p_Size)
        }
    }


;------------------------------
;
; Function: Fnt_GetCaptionFontName
;
; Description:
;
;   Returns the typeface name of the caption font.
;
; Calls To Other Functions:
;
; * <Fnt_GetNonClientMetrics>
;
; Remarks:
;
;   This function gets the typeface name of the caption font without creating
;   the font.
;
;-------------------------------------------------------------------------------
Fnt_GetCaptionFontName()
    {
    Static LF_FACESIZE:=32  ;-- In TCHARS
    Return StrGet(Fnt_GetNonClientMetrics()+24+28,LF_FACESIZE)
    }


;------------------------------
;
; Function: Fnt_GetCaptionFontSize
;
; Description:
;
;   Returns the point size of the caption font.
;
; Calls To Other Functions:
;
; * <Fnt_GetNonClientMetrics>
;
; Remarks:
;
;   This function calculates the point size of the caption font without creating
;   the font.
;
;-------------------------------------------------------------------------------
Fnt_GetCaptionFontSize()
    {
    Static LOGPIXELSY:=90

    ;-- Collect the number of pixels per logical inch along the screen height
    hDC:=DllCall("CreateDC","Str","DISPLAY","Ptr",0,"Ptr",0,"Ptr",0)
    l_LogPixelsY:=DllCall("GetDeviceCaps","Ptr",hDC,"Int",LOGPIXELSY)
    DllCall("DeleteDC","Ptr",hDC)

    ;-- Extract the height for the Message font (can be negative)
    l_Height:=Abs(NumGet(Fnt_GetNonClientMetrics()+24,0,"Int"))

    ;-- Convert height to point size
    ;   Note: Without the internal leading height value that is only available
    ;   after the font has been created, this calculation is just a best guess
    ;   of the font's point size.  However, this calculation is widely used and
    ;   will result in the correct font size if the Fnt_CreateFont function or
    ;   the AutoHotkey "gui Font" command is used to create the font.
    Return Round(l_Height*72/l_LogPixelsY)
    }


;------------------------------
;
; Function: Fnt_GetDefaultGUIMargins
;
; Description:
;
;   Calculates the default margins for an AutoHotkey GUI.
;
; Parameters:
;
;   hFont - Handle to a logical font. [Optional] Set to 0 (the default) to use
;       the default GUI font.
;
;   r_MarginX, r_MarginY - Output variables. [Optional] These variables are
;       loaded with the default margins (in pixels) for an AutoHotkey GUI.
;
;   p_DPIScale - Factor in the current display DPI into the default margin
;       calculations.  Set to TRUE to enable, FALSE to disable, or "A" (the
;       default) to automatically determine if the current display DPI should be
;       factored into the calculation or not.  See the *Remarks* section for
;       more information.
;
; Returns:
;
;   Address to a POINT structure.
;
; Calls To Other Functions:
;
; * <Fnt_GetFontSize>
;
; Remarks:
;
; * AutoHotkey documentation for GUI margins...
;   <https://autohotkey.com/docs/commands/Gui.htm#DPIScale>
;
; * Important: On rare occasion, the margins returned from this function may not
;   match the actual GUI margins because the calculations are based on the
;   actual font size of control, not the requested font size.  For example, if
;   the developer uses the "gui Font" command to create a 24 point Courier (not
;   "Courier New") font, AutoHotkey will calculate margins based on this
;   font/size.  However, when the font is actually created, the 24 point size is
;   not available and so a Courier 15 point font is created instead.  So... the
;   actual margins (based on the _requested_ font/size) will not match the
;   calculated margins (based on the actual font/size).
;
; * Starting with AutoHotkey v1.1.11, the formula to calculate the default GUI
;   margins was changed to always factor in the current display DPI.  The "gui
;   -DPIScale" command has no effect on this change.  The p_DPIScale parameter
;   instructs the function whether or not to factor in the current display DPI.
;   If set to TRUE, the current display DPI is always factored into the
;   calculation.  If set to FALSE, the current display DPI is never factored
;   into the calculation.  If set to "A" (the default), the function will
;   automatically determine whether or not to factor in the current display DPI
;   (TRUE if running on AutoHotkey v1.1.11+, otherwise FALSE).
;
;-------------------------------------------------------------------------------
Fnt_GetDefaultGUIMargins(hFont=0,ByRef r_MarginX="",ByRef r_MarginY="",p_DPIScale="A")
    {
    Static Dummy9104
          ,POINT

          ;-- Device constants
          ,LOGPIXELSX:=88
          ,LOGPIXELSY:=90

    ;-- Initialize
    VarSetCapacity(POINT,8,0)
    l_LogPixelsX:=96
        ;-- The default number of horizontal pixels per logical inch
    l_LogPixelsY:=96
        ;-- The default number of vertical pixels per logical inch
    StringUpper p_DPIScale,p_DPIScale
        ;-- Just in case StringCaseSense is On

    ;-- if p_DPIScale is "A" (Automatic), reset to either TRUE or FALSE
    if (p_DPIScale="A")  ;-- Automatic
        if A_ScreenDPI   ;-- AutoHotkey v1.1.11+
            p_DPIScale:=(A_ScreenDPI=96) ? False:True
         else
            p_DPIScale:=False

    ;-- If needed, collect the current horizontal and vertical display DPI
    if p_DPIScale
        {
        hDC:=DllCall("CreateDC","Str","DISPLAY","Ptr",0,"Ptr",0,"Ptr",0)
        l_LogPixelsX:=DllCall("GetDeviceCaps","Ptr",hDC,"Int",LOGPIXELSX)
        l_LogPixelsY:=DllCall("GetDeviceCaps","Ptr",hDC,"Int",LOGPIXELSY)
        DllCall("DeleteDC","Ptr",hDC)
        }

    ;-- Calculate the default margins
    l_Size:=Fnt_GetFontSize(hFont)
    NumPut(r_MarginX:=Round(Floor(l_Size*1.25)*(l_LogPixelsX/96)),POINT,0,"Int") ;-- x
    NumPut(r_MarginY:=Round(Floor(l_Size*0.75)*(l_LogPixelsY/96)),POINT,4,"Int") ;-- y
    Return &POINT
    }


;------------------------------
;
; Function: Fnt_GetDialogBackgroundColor
;
; Description:
;
;   Retrieves the current dialog background color.
;
; Type:
;
;   Internal function.  Subject to change.  Do not use.
;
;-------------------------------------------------------------------------------
Fnt_GetDialogBackgroundColor()
    {
    Static COLOR_3DFACE:=15
    Return Fnt_GetSysColor(COLOR_3DFACE)
    }


;------------------------------
;
; Function: Fnt_GetDialogBaseUnits
;
; Description:
;
;   Calculates the dialog base units, which are the average width and height
;   (in pixels) of characters of a font.
;
; Parameters:
;
;   hFont - Handle to a logical font. [Optional] Set to 0 (the default) to use
;       the default GUI font.
;
;   r_HorzDBUs, r_VertDBUs - Output variables. [Optional] These variables are
;       loaded with the horizontal and vertical base units for the font.
;
; Returns:
;
;   Address to a SIZE structure.  The cx member of the SIZE structure contains
;   the horizontal dialog base units for the font.  The cy member contains the
;   vertical dialog base units.
;
; Calls To Other Functions:
;
; * <Fnt_GetStringSize>
;
; Remarks:
;
;   Unlike <Fnt_GetFontAvgCharWidth> which returns the average character width
;   as defined by the font's designer (usually the width of the letter "x"),
;   this function uses a formula created by Microsoft which generates an
;   accurate and consistent result regardless of the font.
;
;-------------------------------------------------------------------------------
Fnt_GetDialogBaseUnits(hFont=0,ByRef r_HorzDBUs="",ByRef r_VertDBUs="")
    {
    Static SIZE
    VarSetCapacity(SIZE,8,0)

    ;-- Calculate the dialog base units for the font
    Fnt_GetStringSize(hFont,"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz",l_StringW,r_VertDBUs)
    NumPut(r_HorzDBUs:=Floor((l_StringW/26+1)/2),SIZE,0,"Int")
    NumPut(r_VertDBUs,SIZE,4,"Int")
    Return &SIZE
    }


;------------------------------
;
; Function: Fnt_GetListOfFonts
;
; Description:
;
;   Generate a list of uniquely-named typeface font names.
;
; Parameters:
;
;   p_CharSet - Character set. [Optional].  If blank/null (the default), the
;       DEFAULT_CHARSET character set is used which will generate fonts from all
;       character sets.  See the function's static variables for a list of
;       possible values for this parameter.
;
;   p_Name - Typeface name of a font. [Optional]  If blank/null (the default),
;       one item for every unique typeface name is generated.  If set to a
;       typeface name, that name is returned if valid.  Note: If specified, the
;       typeface name must be exact (not case sensitive).  A partial name will
;       return nothing.
;
;   p_Flags - Flags to filters the fonts that are returned. [Optional]  See the
;       function's static variables for a list of possible flag values.
;
; Returns:
;
;   A list of uniquely-named typeface font names that match the font
;   characteristics specified by the parameters if successful, otherwise null.
;   Font names are delimited by the LF (Line Feed) character.
;
; Calls To Other Functions:
;
; * <Fnt_EnumFontFamExProc> (via callback)
;
;-------------------------------------------------------------------------------
Fnt_GetListOfFonts(p_CharSet="",p_Name="",p_Flags=0)
    {
    Global Fnt_EnumFontFamExProc_List
    Static Dummy6561

          ;-- Character sets
          ,ANSI_CHARSET       :=0
          ,DEFAULT_CHARSET    :=1
          ,SYMBOL_CHARSET     :=2
          ,MAC_CHARSET        :=77
          ,SHIFTJIS_CHARSET   :=128
          ,HANGUL_CHARSET     :=129
          ,JOHAB_CHARSET      :=130
          ,GB2312_CHARSET     :=134
          ,CHINESEBIG5_CHARSET:=136
          ,GREEK_CHARSET      :=161
          ,TURKISH_CHARSET    :=162
          ,VIETNAMESE_CHARSET :=163
          ,HEBREW_CHARSET     :=177
          ,ARABIC_CHARSET     :=178
          ,BALTIC_CHARSET     :=186
          ,RUSSIAN_CHARSET    :=204
          ,THAI_CHARSET       :=222
          ,EASTEUROPE_CHARSET :=238
          ,OEM_CHARSET        :=255

          ;-- ChooseFont flags
          ,CF_SCRIPTSONLY:=0x400
                ;-- Exclude OEM and Symbol fonts.

          ,CF_NOOEMFONTS:=0x800
                ;-- Exclude OEM fonts.

          ,CF_NOSIMULATIONS:=0x1000
                ;-- [Future] Exlclude font simulations.

          ,CF_FIXEDPITCHONLY:=0x4000
                ;-- Include fixed-pitch fonts only.

          ,CF_SCALABLEONLY:=0x20000
                ;-- Include scalable fonts only.

          ,CF_TTONLY:=0x40000
                ;-- Include TrueType fonts only.

          ,CF_NOVERTFONTS:=0x1000000
                ;-- Exclude vertical fonts.

;;;;;          ,CF_INACTIVEFONTS:=0x2000000
;;;;;                ;-- [Future] Include fonts that are set to Hide in
;;;;;                ;   Fonts Control Panel.  Windows 7+.

          ,CF_NOSYMBOLFONTS:=0x10000000
                ;-- [Custom Flag]  Exclude symbol fonts.

          ,CF_VARIABLEPITCHONLY:=0x20000000
                ;-- [Custom Flag]  Include variable pitch fonts only.

          ,CF_FUTURE:=0x40000000
                ;-- [Custom Flag]  Future.

          ,CF_FULLNAME:=0x80000000
                ;-- [Custom Flag, Advanced Feature]  If specified, returns the
                ;   full unique name of the font.  For example, ABC Font Company
                ;   TrueType Bold Italic Sans Serif.

          ;-- Device constants
          ,HWND_DESKTOP:=0

          ;-- LOGFONT constants
          ,LF_FACESIZE:=32  ;-- In TCHARS

    ;-- Initialize
    Fnt_EnumFontFamExProc_List:=""

    ;-- Parameters
    p_CharSet:=Trim(p_CharSet," `f`n`r`t`v")
        ;-- Remove all leading/trailing white space

    if p_CharSet is Space
        p_CharSet:=DEFAULT_CHARSET

    p_Name:=Trim(p_Name," `f`n`r`t`v")
        ;-- Remove all leading/trailing white space

    ;-- Create, initialize, and populate LOGFONT structure
    VarSetCapacity(LOGFONT,A_IsUnicode ? 92:60,0)
    NumPut(p_CharSet,LOGFONT,23,"UChar")                ;-- lfCharSet

    if StrLen(p_Name)
        StrPut(SubStr(p_Name,1,31),&LOGFONT+28,LF_FACESIZE)
            ;-- lfFaceName

    ;-- Enumerate fonts
    hDC:=DllCall("GetDC","Ptr",HWND_DESKTOP)
    DllCall("EnumFontFamiliesEx"
        ,"Ptr",hDC                                      ;-- hdc
        ,"Ptr",&LOGFONT                                 ;-- lpLogfont
        ,"Ptr",RegisterCallback("Fnt_EnumFontFamExProc","Fast")
            ;-- lpEnumFontFamExProc
        ,"Ptr",p_Flags                                  ;-- lParam
        ,"UInt",0)                                      ;-- dwFlags

    DllCall("ReleaseDC","Ptr",HWND_DESKTOP,"Ptr",hDC)

    ;-- Sort, remove duplicates, and return
    Sort Fnt_EnumFontFamExProc_List,U
    Return Fnt_EnumFontFamExProc_List
    }


;------------------------------
;
; Function: Fnt_GetLongestString
;
; Description:
;
;   Determines the longest string (measured in pixels) from a list of strings.
;
; Parameters:
;
;   hFont - Handle to a logical font.  Set to 0 to use the default GUI font.
;
;   p_String* - Zero or more parameters containing a string, an array of
;       strings, a list of string delimited by end-of-line character(s) (see
;       the *End-Of-Line Character(s)* section for more information), or any
;       combination of these types.
;
; Returns:
;
;   The longest string found which can be null.  If more than one string is
;   the same length as the longest string, the first one found is returned.
;   ErrorLevel is set to the length of the longest string (in pixels) which can
;   be 0.
;
; End-Of-Line Character(s):
;
;   Multiple strings can be represented as a single parameter value by inserting
;   an end-of-line (EOL) delimiter between each string.  For example, "Label
;   1`nLongLabel 2`nLabel 3".  The EOL character(s) in the string must be in a
;   DOS/Windows (EOL=CR+LF), Unix (EOL=LF), or DOS/Unix mix format.   A
;   multi-line string in any other format must be converted to a DOS/Windows or
;   Unix format before calling this function.
;
;-------------------------------------------------------------------------------
Fnt_GetLongestString(hFont,p_String*)
    {
    Static Dummy0378
          ,DEFAULT_GUI_FONT:=17
          ,HWND_DESKTOP    :=0
          ,SIZE

    ;-- Initialize
    l_LongestString :=""
    l_LongestStringW:=0
    ArrayOfStrings  :=[]
    VarSetCapacity(SIZE,8,0)

    ;-- Extract string(s) from parameter(s).  Load to ArrayOfStrings
    For l_Index,l_ParamString in p_String
        {
        if IsObject(l_ParamString)
            {
            For l_Key,l_StringFromObject in l_ParamString
                Loop Parse,l_StringFromObject,`n,`r
                    if StrLen(A_LoopField)  ;-- Ignore null strings
                        ArrayOfStrings.Push(A_LoopField)
            }
        else  ;-- not an object
            {
            Loop Parse,l_ParamString,`n,`r
                if StrLen(A_LoopField)  ;-- Ignore null strings
                    ArrayOfStrings.Push(A_LoopField)
            }
        }

    ;-- If needed, get the handle to the default GUI font
    if not hFont
        hFont:=DllCall("GetStockObject","Int",DEFAULT_GUI_FONT)

    ;-- Select the font into the device context for the desktop
    hDC      :=DllCall("GetDC","Ptr",HWND_DESKTOP)
    old_hFont:=DllCall("SelectObject","Ptr",hDC,"Ptr",hFont)

    ;-- Determine the longest string
    For l_Index,l_String in ArrayOfStrings
        {
        DllCall("GetTextExtentPoint32"
            ,"Ptr",hDC                                  ;-- hDC
            ,"Str",l_String                             ;-- lpString
            ,"Int",StrLen(l_String)                     ;-- c (string length)
            ,"Ptr",&SIZE)                               ;-- lpSize

        l_Width:=NumGet(SIZE,0,"Int")
        if (l_Width>l_LongestStringW)
            {
            l_LongestString :=l_String
            l_LongestStringW:=l_Width
            }
        }

    ;-- Release the objects needed by the "GetTextExtentPoint32" function
    DllCall("SelectObject","Ptr",hDC,"Ptr",old_hFont)
        ;-- Necessary to avoid memory leak

    DllCall("ReleaseDC","Ptr",HWND_DESKTOP,"Ptr",hDC)

    ;-- Return to sender
    ErrorLevel:=l_LongestStringW
    Return l_LongestString
    }


;------------------------------
;
; Function: Fnt_GetFont
;
; Description:
;
;   Retrieves the font with which a control is currently drawing its text.
;
; Parameters:
;
;   hControl - Handle to a control.
;
; Returns:
;
;   The handle to the font used by the control or 0 if the using the system
;   font.
;
;-------------------------------------------------------------------------------
Fnt_GetFont(hControl)
    {
    Static WM_GETFONT:=0x31
    SendMessage WM_GETFONT,0,0,,ahk_id %hControl%
    Return ErrorLevel
    }


;------------------------------
;
; Function: Fnt_GetFontAvgCharWidth
;
; Description:
;
;   Retrieves the average width of characters in a font (generally defined as
;   the width of the letter x).  This value does not include the overhang
;   required for bold or italic characters.
;
; Parameters:
;
;   hFont - Handle to a logical font. [Optional] Set to 0 (the default) to use
;       the default GUI font.
;
; Returns:
;
;   The average width of characters in the font, in pixels.
;
; Calls To Other Functions:
;
; * <Fnt_GetFontMetrics>
;
;-------------------------------------------------------------------------------
Fnt_GetFontAvgCharWidth(hFont=0)
    {
    Return NumGet(Fnt_GetFontMetrics(hFont),20,"Int")
    }


;------------------------------
;
; Function: Fnt_GetFontExternalLeading
;
; Description:
;
;   Retrieves the amount of extra leading space (if any) that the application
;   adds between rows.
;
; Parameters:
;
;   hFont - Handle to a logical font. [Optional] Set to 0 (the default) to use
;       the default GUI font.
;
; Returns:
;
;   The external leading space of the font.
;
; Calls To Other Functions:
;
; * <Fnt_GetFontMetrics>
;
;-------------------------------------------------------------------------------
Fnt_GetFontExternalLeading(hFont=0)
    {
    Return NumGet(Fnt_GetFontMetrics(hFont),16,"Int")
    }


;------------------------------
;
; Function: Fnt_GetFontHeight
;
; Description:
;
;   Retrieves the height (ascent + descent) of characters in a font.
;
; Parameters:
;
;   hFont - Handle to a logical font. [Optional] Set to 0 (the default) to use
;       the default GUI font.
;
; Returns:
;
;   The height of characters in the font.
;
; Calls To Other Functions:
;
; * <Fnt_GetFontMetrics>
;
;-------------------------------------------------------------------------------
Fnt_GetFontHeight(hFont=0)
    {
    Return NumGet(Fnt_GetFontMetrics(hFont),0,"Int")
    }


;------------------------------
;
; Function: Fnt_GetFontInternalLeading
;
; Description:
;
;   Retrieves the amount of leading space (if any) inside the bounds set by the
;   tmHeight member.
;
; Parameters:
;
;   hFont - Handle to a logical font. [Optional] Set to 0 (the default) to use
;       the default GUI font.
;
; Returns:
;
;   The internal leading space of the font.
;
; Calls To Other Functions:
;
; * <Fnt_GetFontMetrics>
;
; Remarks:
;
;   Accent marks and other diacritical characters may occur in the internal
;   leading area.
;
;-------------------------------------------------------------------------------
Fnt_GetFontInternalLeading(hFont=0)
    {
    Return NumGet(Fnt_GetFontMetrics(hFont),12,"Int")
    }


;------------------------------
;
; Function: Fnt_GetFontMaxCharWidth
;
; Description:
;
;   Retrieves the width of the widest character in a font.
;
; Parameters:
;
;   hFont - Handle to a logical font. [Optional] Set to 0 (the default) to use
;       the default GUI font.
;
; Returns:
;
;   The width of the widest character in the font, in pixels.
;
; Calls To Other Functions:
;
; * <Fnt_GetFontMetrics>
;
; Observations:
;
;   The value returned for this member can sometimes be unusually large.  For
;   one font, I found a MaxCharWidth value that was 6 times larger than the
;   AvgCharWidth.  For some fonts, a large discrepancy can be explained by the
;   unusual nature of the font (symbols, math, etc.) but for other fonts, a
;   very large discrepancy is harder to explain.  Note: These font values are
;   set by the font's designer.  They may be correct and/or intended (the most
;   likely reality) or they may be incorrect/unintended (read: bug).
;
;-------------------------------------------------------------------------------
Fnt_GetFontMaxCharWidth(hFont=0)
    {
    Return NumGet(Fnt_GetFontMetrics(hFont),24,"Int")
    }


;------------------------------
;
; Function: Fnt_GetFontMetrics
;
; Description:
;
;   Retrieves the text metrics for a font.
;
; Parameters:
;
;   hFont - Handle to a logical font. [Optional] Set to 0 (the default) to use
;       the default GUI font.
;
; Returns:
;
;   Address to a TEXTMETRIC structure.
;
;-------------------------------------------------------------------------------
Fnt_GetFontMetrics(hFont=0)
    {
    Static Dummy6596
          ,DEFAULT_GUI_FONT:=17
          ,HWND_DESKTOP    :=0
          ,TEXTMETRIC

    ;-- If needed, get the handle to the default GUI font
    if not hFont
        hFont:=DllCall("GetStockObject","Int",DEFAULT_GUI_FONT)

    ;-- Select the font into the device context for the desktop
    hDC      :=DllCall("GetDC","Ptr",HWND_DESKTOP)
    old_hFont:=DllCall("SelectObject","Ptr",hDC,"Ptr",hFont)

    ;-- Get the metrics for the font
    VarSetCapacity(TEXTMETRIC,A_IsUnicode ? 60:56,0)
    DllCall("GetTextMetrics","Ptr",hDC,"Ptr",&TEXTMETRIC)

    ;-- Release the objects needed by the "GetTextMetrics" function
    DllCall("SelectObject","Ptr",hDC,"Ptr",old_hFont)
        ;-- Necessary to avoid memory leak

    DllCall("ReleaseDC","Ptr",HWND_DESKTOP,"Ptr",hDC)

    ;-- Return to sender
    Return &TEXTMETRIC
    }


;------------------------------
;
; Function: Fnt_GetFontName
;
; Description:
;
;   Retrieves the typeface name of a font.
;
; Parameters:
;
;   hFont - Handle to a logical font. [Optional] Set to 0 (the default) to use
;       the default GUI font.
;
; Returns:
;
;   The typeface name of the font.
;
;-------------------------------------------------------------------------------
Fnt_GetFontName(hFont=0)
    {
    Static Dummy8789
          ,DEFAULT_GUI_FONT    :=17
          ,HWND_DESKTOP        :=0
          ,MAX_FONT_NAME_LENGTH:=32     ;-- In TCHARS

    ;-- If needed, get the handle to the default GUI font
    if not hFont
        hFont:=DllCall("GetStockObject","Int",DEFAULT_GUI_FONT)

    ;-- Select the font into the device context for the desktop
    hDC      :=DllCall("GetDC","Ptr",HWND_DESKTOP)
    old_hFont:=DllCall("SelectObject","Ptr",hDC,"Ptr",hFont)

    ;-- Get the font name
    VarSetCapacity(l_FontName,MAX_FONT_NAME_LENGTH*(A_IsUnicode ? 2:1))
    DllCall("GetTextFace","Ptr",hDC,"Int",MAX_FONT_NAME_LENGTH,"Str",l_FontName)

    ;-- Release the objects needed by the "GetTextFace" function
    DllCall("SelectObject","Ptr",hDC,"Ptr",old_hFont)
        ;-- Necessary to avoid memory leak

    DllCall("ReleaseDC","Ptr",HWND_DESKTOP,"Ptr",hDC)

    ;-- Return to sender
    Return l_FontName
    }


;------------------------------
;
; Function: Fnt_GetFontOptions
;
; Description:
;
;   Retrieves the characteristics of a logical font for use in other library
;   functions or by the AutoHotkey
;   <gui Font at https://autohotkey.com/docs/commands/Gui.htm#Font> command.
;
; Parameters:
;
;   hFont - Handle to a logical font. [Optional] Set to 0 (the default) to use
;       the default GUI font.
;
; Returns:
;
;   Font options in the AutoHotkey "gui Font" format.  See the *Options* section
;   for more information.
;
; Calls To Other Functions:
;
; * <Fnt_GetFontMetrics>
;
; Options:
;
;   Font options returned by this function may include the following.
;
;   bold - Font weight is 700, i.e. bold.
;
;   italic - Italic font.
;
;   s{size in points} - Font size (in points).  For example: s12
;
;   strike - Strikeout font.
;
;   underline - Underlined font.
;
;   w{font weight} - Font weight (thickness or boldness), which is an integer
;       between 1 and 1000 (400 is normal and 700 is bold).  For example: w600.
;       This option is only returned if the font weight is not normal (400) and
;       not bold (700).
;
;   If more than one option is included, it is delimited by a space.  For
;   example: s12 bold
;
; Remarks:
;
;   Library functions that use font options in this format include
;   <Fnt_CreateFont> and <Fnt_ChooseFont>.
;
;   Note: Color is an option of the AutoHotkey
;   <gui Font at https://autohotkey.com/docs/commands/Gui.htm#Font> command and
;   of the ChooseFont API and is included by these commands because text color
;   is often set with the font.  However, text color is a control attribute, not
;   a font attribute and so it is not (read: cannot be) collected/returned by
;   this function.  If text color is to be included as one of the options sent
;   to the AutoHotkey "gui Font" command or to the ChooseFont API, it must must
;   be collected and/or set independently.
;
;-------------------------------------------------------------------------------
Fnt_GetFontOptions(hFont=0)
    {
    Static Dummy8934

          ;-- Device constants
          ,LOGPIXELSY:=90

          ;-- Misc font constants
          ,FW_NORMAL :=400
          ,FW_BOLD   :=700

    ;-- Collect the number of pixels per logical inch along the screen height
    hDC:=DllCall("CreateDC","Str","DISPLAY","Ptr",0,"Ptr",0,"Ptr",0)
    l_LogPixelsY:=DllCall("GetDeviceCaps","Ptr",hDC,"Int",LOGPIXELSY)
    DllCall("DeleteDC","Ptr",hDC)

    ;-- Collect the metrics for the font
    pTM:=Fnt_GetFontMetrics(hFont)

    ;-- Size (first and always included)
    l_Options:="s"
        . Round((NumGet(pTM+0,0,"Int")-NumGet(pTM+0,12,"Int"))*72/l_LogPixelsY)
            ;-- (Height - Internal Leading) * 72 / LogPixelsY

    ;-- Weight
    l_Weight:=NumGet(pTM+0,28,"Int")
    if (l_Weight=FW_BOLD)
        l_Options.=A_Space . "bold"
     else
        if (l_Weight<>FW_NORMAL)
            l_Options.=A_Space . "w" . l_Weight

    ;-- Italic
    if NumGet(pTM+0,A_IsUnicode ? 52:48,"UChar")
        l_Options.=A_Space . "italic"

    ;-- Underline
    if NumGet(pTM+0,A_IsUnicode ? 53:49,"UChar")
        l_Options.=A_Space . "underline"

    ;-- Strikeout
    if NumGet(pTM+0,A_IsUnicode ? 54:50,"UChar")
        l_Options.=A_Space . "strike"

    Return l_Options
    }


;------------------------------
;
; Function: Fnt_GetFontSize
;
; Description:
;
;   Retrieves the point size of a font.
;
; Parameters:
;
;   hFont - Handle to a logical font. [Optional] Set to 0 (the default) to use
;       the default GUI font.
;
; Returns:
;
;   The point size of the font.
;
;-------------------------------------------------------------------------------
Fnt_GetFontSize(hFont=0)
    {
    Static Dummy6499

          ;-- Device constants
          ,HWND_DESKTOP    :=0
          ,LOGPIXELSY      :=90

          ;-- Misc. font constants
          ,DEFAULT_GUI_FONT:=17

    ;-- If needed, get the handle to the default GUI font
    if not hFont
        hFont:=DllCall("GetStockObject","Int",DEFAULT_GUI_FONT)

    ;-- Select the font into the device context for the desktop
    hDC      :=DllCall("GetDC","Ptr",HWND_DESKTOP)
    old_hFont:=DllCall("SelectObject","Ptr",hDC,"Ptr",hFont)

    ;-- Collect the number of pixels per logical inch along the screen height
    l_LogPixelsY:=DllCall("GetDeviceCaps","Ptr",hDC,"Int",LOGPIXELSY)

    ;-- Get text metrics for the font
    VarSetCapacity(TEXTMETRIC,A_IsUnicode ? 60:56,0)
    DllCall("GetTextMetrics","Ptr",hDC,"Ptr",&TEXTMETRIC)

    ;-- Convert height to point size
    l_Size:=Round((NumGet(TEXTMETRIC,0,"Int")-NumGet(TEXTMETRIC,12,"Int"))*72/l_LogPixelsY)
        ;-- (Height - Internal Leading) * 72 / LogPixelsY

    ;-- Release the objects needed by the "GetTextMetrics" function
    DllCall("SelectObject","Ptr",hDC,"Ptr",old_hFont)
        ;-- Necessary to avoid memory leak

    DllCall("ReleaseDC","Ptr",HWND_DESKTOP,"Ptr",hDC)

    ;-- Return to sender
    Return l_Size
    }


;------------------------------
;
; Function: Fnt_GetFontWeight
;
; Description:
;
;   Retrieves the weight (thickness or boldness) of a font.
;
; Parameters:
;
;   hFont - Handle to a logical font. [Optional] Set to 0 (the default) to use
;       the default GUI font.
;
; Returns:
;
;   The weight of the font.  Possible values are from 1 to 1000.
;
; Calls To Other Functions:
;
; * <Fnt_GetFontMetrics>
;
;-------------------------------------------------------------------------------
Fnt_GetFontWeight(hFont=0)
    {
    Return NumGet(Fnt_GetFontMetrics(hFont),28,"Int")
    }


;------------------------------
;
; Function: Fnt_GetMenuFontName
;
; Description:
;
;   Returns the typeface name of the font used in menu bars.
;
; Calls To Other Functions:
;
; * <Fnt_GetNonClientMetrics>
;
; Remarks:
;
;   This function gets the typeface name of the font used in menu bars without
;   creating the font.
;
;-------------------------------------------------------------------------------
Fnt_GetMenuFontName()
    {
    Static LF_FACESIZE:=32  ;-- In TCHARS
    Return StrGet(Fnt_GetNonClientMetrics()+(A_IsUnicode ? 224:160)+28,LF_FACESIZE)
    }


;------------------------------
;
; Function: Fnt_GetMenuFontSize
;
; Description:
;
;   Returns the point size of the font that is used in menu bars.
;
; Calls To Other Functions:
;
; * <Fnt_GetNonClientMetrics>
;
; Remarks:
;
;   This function calculates the point size of the font used in menu bars
;   without creating the font.
;
;-------------------------------------------------------------------------------
Fnt_GetMenuFontSize()
    {
    Static LOGPIXELSY:=90

    ;-- Collect the number of pixels per logical inch along the screen height
    hDC:=DllCall("CreateDC","Str","DISPLAY","Ptr",0,"Ptr",0,"Ptr",0)
    l_LogPixelsY:=DllCall("GetDeviceCaps","Ptr",hDC,"Int",LOGPIXELSY)
    DllCall("DeleteDC","Ptr",hDC)

    ;-- Extract the height for the Message font (can be negative)
    l_Height:=Abs(NumGet(Fnt_GetNonClientMetrics()+(A_IsUnicode ? 224:160),0,"Int"))

    ;-- Convert height to point size
    ;   Note: Without the internal leading height value that is only available
    ;   after the font has been created, this calculation is just a best guess
    ;   of the font's point size.  However, this calculation is widely used and
    ;   will result in the correct font size if the Fnt_CreateFont function or
    ;   the AutoHotkey "gui Font" command is used to create the font.
    Return Round(l_Height*72/l_LogPixelsY)
    }


;------------------------------
;
; Function: Fnt_GetMessageFontName
;
; Description:
;
;   Returns the typeface name of the font that is used in message boxes.
;
; Calls To Other Functions:
;
; * <Fnt_GetNonClientMetrics>
;
; Remarks:
;
;   This function gets the typeface name of the font used in message boxes
;   without creating the font.
;
;-------------------------------------------------------------------------------
Fnt_GetMessageFontName()
    {
    Static LF_FACESIZE:=32  ;-- In TCHARS
    Return StrGet(Fnt_GetNonClientMetrics()+(A_IsUnicode ? 408:280)+28,LF_FACESIZE)
    }


;------------------------------
;
; Function: Fnt_GetMessageFontSize
;
; Description:
;
;   Returns the point size of the font that is used in message boxes.
;
; Calls To Other Functions:
;
; * <Fnt_GetNonClientMetrics>
;
; Remarks:
;
;   This function calculates the point size of the font used in message boxes
;   without creating the font.
;
;-------------------------------------------------------------------------------
Fnt_GetMessageFontSize()
    {
    Static LOGPIXELSY:=90

    ;-- Collect the number of pixels per logical inch along the screen height
    hDC:=DllCall("CreateDC","Str","DISPLAY","Ptr",0,"Ptr",0,"Ptr",0)
    l_LogPixelsY:=DllCall("GetDeviceCaps","Ptr",hDC,"Int",LOGPIXELSY)
    DllCall("DeleteDC","Ptr",hDC)

    ;-- Extract the height for the Message font (can be negative)
    l_Height:=Abs(NumGet(Fnt_GetNonClientMetrics()+(A_IsUnicode ? 408:280),0,"Int"))

    ;-- Convert height to point size
    ;   Note: Without the internal leading height value that is only available
    ;   after the font has been created, this calculation is just a best guess
    ;   of the font's point size.  However, this calculation is widely used and
    ;   will result in the correct font size if the Fnt_CreateFont function or
    ;   the AutoHotkey "gui Font" command is used to create the font.
    Return Round(l_Height*72/l_LogPixelsY)
    }


;------------------------------
;
; Function: Fnt_GetMultilineStringSize
;
; Description:
;
;   Calculates the size of a multiline string for a font.  See the *Remarks*
;   section for more information.
;
; Parameters:
;
;   hFont - Handle to a logical font.  Set to 0 to use the default GUI font.
;
;   p_String - The multiline string to be measured.  See the
;       *End-Of-Line Character(s)* section for more information.
;
;   r_Width, r_Height, r_LineCount - Output variables. [Optional] These
;       variables are loaded with the width and height of the string and with
;       the number of lines of text.  Note: r_LineCount is set to 0 if p_String
;       is null, otherwise 1 or more.
;
; Returns:
;
;   Address to a SIZE structure if successful, otherwise FALSE.
;
; Calls To Other Functions:
;
; * <Fnt_GetFontExternalLeading>
; * <Fnt_GetFontHeight>
;
; End-Of-Line Character(s):
;
;   This function uses the LF (Line Feed) and/or CR+LF (Carriage Return and Line
;   Feed) characters in the string as delimiters to logically break the string
;   into multiple lines of text.  The end-of-line (EOL) character(s) in the text
;   must be in a DOS/Windows (EOL=CR+LF), Unix (EOL=LF), or DOS/Unix mix format.
;   A string in any other format must be converted to a DOS/Windows or Unix
;   format before calling this function.
;
; Remarks:
;
;   This is a specialty function to determine the size of a multiline string.
;   The width of the widest line and the combined height of all of the lines is
;   returned.  This information can be used to determine how much space the
;   string will use when attached to a GUI control that supports multiple lines
;   of text.
;
; Observations:
;
;   The width of the tab character is usually determined by the control, not by
;   the font, so including tab characters in the string will not produce the
;   desired results.
;
;-------------------------------------------------------------------------------
Fnt_GetMultilineStringSize(hFont,p_String,ByRef r_Width="",ByRef r_Height="",ByRef r_LineCount="")
    {
    Static Dummy4723
          ,DEFAULT_GUI_FONT:=17
          ,HWND_DESKTOP    :=0
          ,SIZE  

    ;-- Initialize
    r_Width:=r_Height:=r_LineCount:=0
    VarSetCapacity(SIZE,8,0)
        ;-- Note: This structure is used by the "GetTextExtentPoint32"
        ;   function _and_ is used to store the width and height return values
        ;   of the function.

    ;-- Bounce if p_String is null.  All output values are zero.
    if not StrLen(p_String)
        Return &SIZE

    ;-- If needed, get the handle to the default GUI font
    if not hFont
        hFont:=DllCall("GetStockObject","Int",DEFAULT_GUI_FONT)

    ;-- Select the font into the device context for the desktop
    hDC      :=DllCall("GetDC","Ptr",HWND_DESKTOP)
    old_hFont:=DllCall("SelectObject","Ptr",hDC,"Ptr",hFont)

    ;-- Determine the number of lines
    StringReplace p_String,p_String,`n,`n,UseErrorLevel
    r_LineCount:=ErrorLevel+1

    ;-- Determine the maximum width of the text
    Loop Parse,p_String,`n,`r
        {
        DllCall("GetTextExtentPoint32"
            ,"Ptr",hDC                                  ;-- hDC
            ,"Str",A_LoopField                          ;-- lpString
            ,"Int",StrLen(A_LoopField)                  ;-- c (string length)
            ,"Ptr",&SIZE)                               ;-- lpSize

        l_Width:=NumGet(SIZE,0,"Int")
        if (l_Width>r_Width)
            r_Width:=l_Width
        }

    ;-- Release the objects needed by the "GetTextExtentPoint32" function
    DllCall("SelectObject","Ptr",hDC,"Ptr",old_hFont)
        ;-- Necessary to avoid memory leak

    DllCall("ReleaseDC","Ptr",HWND_DESKTOP,"Ptr",hDC)

    ;-- Calculate the height by adding up the font height for each line and
    ;   the space between lines (ExternalLeading) if there is morethan one line.
    r_Height:=(Fnt_GetFontHeight(hFont)*r_LineCount)+(Fnt_GetFontExternalLeading(hFont)*(r_LineCount-1))

    ;-- Populate the SIZE structure for return
    NumPut(r_Width, SIZE,0,"Int")
    NumPut(r_Height,SIZE,4,"Int")
    Return &SIZE
    }



;------------------------------
;
; Function: Fnt_GetNonClientMetrics
;
; Description:
;
;   Retrieves the metrics associated with the nonclient area of nonminimized
;   windows.
;
; Returns:
;
;   Address to a NONCLIENTMETRICS structure if successful, otherwise FALSE.
;
;-------------------------------------------------------------------------------
Fnt_GetNonClientMetrics()
    {
    Static Dummy1510
          ,SPI_GETNONCLIENTMETRICS:=0x29
          ,NONCLIENTMETRICS

    ;-- Set the size of NONCLIENTMETRICS structure
    cbSize:=A_IsUnicode ? 500:340
    if (((GV:=DllCall("GetVersion"))&0xFF . "." . GV>>8&0xFF)>=6.0)  ;-- Vista+
        cbSize+=4

    ;-- Create and initialize NONCLIENTMETRICS structure
    VarSetCapacity(NONCLIENTMETRICS,cbSize,0)
    NumPut(cbSize,NONCLIENTMETRICS,0,"UInt")

    ;-- Get nonclient metrics parameter
    if !DllCall("SystemParametersInfo"
        ,"UInt",SPI_GETNONCLIENTMETRICS
        ,"UInt",cbSize
        ,"Ptr",&NONCLIENTMETRICS
        ,"UInt",0)
        Return False

    ;-- Return to sender
    Return &NONCLIENTMETRICS
    }


;------------------------------
;
; Function: Fnt_GetPos
;
; Description:
;
;   Gets the position and size of a GUI control.  See the *Remarks* section
;   for more information.
;
; Parameters:
;
;   hControl - Handle to a control.
;
;   X, Y, Width, Height - Output variables. [Optional]  If defined, these
;       variables contain the coordinates of the control relative to
;       the client-area of the parent window (X and Y), and the width and height
;       of the control (Width and Height).
;
; Remarks:
;
; * If using a DPI setting that is smaller or larger than the default/standard
;   (Ex: 120 DPI, 144 DPI, or custom) _and_ if using the DPIScale feature
;   (AutoHotkey v1.1.11+, enabled by default), the values returned from the
;   *GUIControlGet,OutputVar,Pos* command will reflect the calculations that
;   were used by the DPIScale feature to create the control. For example, if a
;   control were created with the "x20 y20 w500 h200" options and if using 120
;   DPI, the actual position and size of the control will be "x25 y25 w625
;   h250".  When the *GUIControlGet,OutputVar,Pos* command is used on this
;   control, it returns values that reflect the original "x20 y20 w500 h200"
;   options.  This function returns the _actual_ position and/or size of the
;   control regardless of the current display DPI.  It can be useful if the
;   current display DPI is unknown and/or the disposition of the DPIScale
;   feature is unknown.
;
; * If only interested in the Width and/or Height values, the AutoHotkey
;   *<ControlGetPos at http://www.autohotkey.com/docs/commands/ControlGetPos.htm>*
;   or
;   *<WinGetPos at http://www.autohotkey.com/docs/commands/WinGetPos.htm>*
;   commands can be used instead.  Hint: These commands are more efficient and
;   should be used whenever possible.
;
;-------------------------------------------------------------------------------
Fnt_GetPos(hControl,ByRef X="",ByRef Y="",ByRef Width="",ByRef Height="")
    {
    ;-- Initialize
    VarSetCapacity(RECT,16,0)

    ;-- Get the dimensions of the bounding rectangle of the control.
    ;   Note: The values returned are in screen coordinates.
    DllCall("GetWindowRect","Ptr",hControl,"Ptr",&RECT)
    Width :=NumGet(RECT,8,"Int")-NumGet(RECT,0,"Int")   ;-- Width=right-left
    Height:=NumGet(RECT,12,"Int")-NumGet(RECT,4,"Int")  ;-- Height=bottom-top

    ;-- Convert the screen coordinates to client-area coordinates.  Note: The
    ;   API reads and updates the first 8-bytes of the RECT structure.
    DllCall("ScreenToClient"
        ,"Ptr",DllCall("GetParent","Ptr",hControl,"Ptr")
        ,"Ptr",&RECT)

    ;-- Update the output variables
    X:=NumGet(RECT,0,"Int")                             ;-- left
    Y:=NumGet(RECT,4,"Int")                             ;-- top
    }


;------------------------------
;
; Function: Fnt_GetSmCaptionFontName
;
; Description:
;
;   Returns the typeface name of the small caption font.
;
; Calls To Other Functions:
;
; * <Fnt_GetNonClientMetrics>
;
; Remarks:
;
;   This function gets the typeface name of the small caption font without
;   creating the font.
;
;-------------------------------------------------------------------------------
Fnt_GetSmCaptionFontName()
    {
    Static LF_FACESIZE:=32  ;-- In TCHARS
    Return StrGet(Fnt_GetNonClientMetrics()+(A_IsUnicode ? 124:92)+28,LF_FACESIZE)
    }


;------------------------------
;
; Function: Fnt_GetSmCaptionFontSize
;
; Description:
;
;   Returns the point size of the small caption font.
;
; Calls To Other Functions:
;
; * <Fnt_GetNonClientMetrics>
;
; Remarks:
;
;   This function calculates the point size of the small caption font without
;   creating the font.
;
;-------------------------------------------------------------------------------
Fnt_GetSmCaptionFontSize()
    {
    Static LOGPIXELSY:=90

    ;-- Collect the number of pixels per logical inch along the screen height
    hDC:=DllCall("CreateDC","Str","DISPLAY","Ptr",0,"Ptr",0,"Ptr",0)
    l_LogPixelsY:=DllCall("GetDeviceCaps","Ptr",hDC,"Int",LOGPIXELSY)
    DllCall("DeleteDC","Ptr",hDC)

    ;-- Extract the height for the Message font (can be negative)
    l_Height:=Abs(NumGet(Fnt_GetNonClientMetrics()+(A_IsUnicode ? 124:92),0,"Int"))

    ;-- Convert height to point size
    ;   Note: Without the internal leading height value that is only available
    ;   after the font has been created, this calculation is just a best guess
    ;   of the font's point size.  However, this calculation is widely used and
    ;   will result in the correct font size if the Fnt_CreateFont function or
    ;   the AutoHotkey "gui Font" command is used to create the font.
    Return Round(l_Height*72/l_LogPixelsY)
    }


;------------------------------
;
; Function: Fnt_GetStatusFontName
;
; Description:
;
;   Returns the typeface name of the font used in status bars and tooltips.
;
; Calls To Other Functions:
;
; * <Fnt_GetNonClientMetrics>
;
; Remarks:
;
;   This function gets the typeface name of the font used in status bars and
;   tooltips without creating the font.
;
;-------------------------------------------------------------------------------
Fnt_GetStatusFontName()
    {
    Static LF_FACESIZE:=32  ;-- In TCHARS
    Return StrGet(Fnt_GetNonClientMetrics()+(A_IsUnicode ? 316:220)+28,LF_FACESIZE)
    }


;------------------------------
;
; Function: Fnt_GetStatusFontSize
;
; Description:
;
;   Returns the point size of the font that is used in status bars and tooltips.
;
; Calls To Other Functions:
;
; * <Fnt_GetNonClientMetrics>
;
; Remarks:
;
;   This function calculates the point size of the font used in status bars and
;   tooltips without creating the font.
;
;-------------------------------------------------------------------------------
Fnt_GetStatusFontSize()
    {
    Static LOGPIXELSY:=90

    ;-- Collect the number of pixels per logical inch along the screen height
    hDC:=DllCall("CreateDC","Str","DISPLAY","Ptr",0,"Ptr",0,"Ptr",0)
    l_LogPixelsY:=DllCall("GetDeviceCaps","Ptr",hDC,"Int",LOGPIXELSY)
    DllCall("DeleteDC","Ptr",hDC)

    ;-- Extract the height for the Message font (can be negative)
    l_Height:=Abs(NumGet(Fnt_GetNonClientMetrics()+(A_IsUnicode ? 316:220),0,"Int"))

    ;-- Convert height to point size
    ;   Note: Without the internal leading height value that is only available
    ;   after the font has been created, this calculation is just a best guess
    ;   of the font's point size.  However, this calculation is widely used and
    ;   will result in the correct font size if the Fnt_CreateFont function or
    ;   the AutoHotkey "gui Font" command is used to create the font.
    Return Round(l_Height*72/l_LogPixelsY)
    }


;------------------------------
;
; Function: Fnt_GetStringSize
;
; Description:
;
;   Calculates the width and height (in pixels) of a string of text.
;
; Parameters:
;
;   hFont - Handle to a logical font.  Set to 0 to use the default GUI font.
;
;   p_String - The string to be measured.
;
;   r_Width, r_Height - Output variables. [Optional] These variables are loaded
;       with the width and height of the string.
;
; Returns:
;
;   Address to a SIZE structure if successful, otherwise FALSE.
;
; Remarks:
;
;   LF (Line Feed) and/or CR+LF (Carriage Return and Line Feed) characters are
;   not considered when calculating the height of the string.
;
; Observations:
;
;   The width of the tab character is usually determined by the control, not by
;   the font, so including tab characters in the string may not produce the
;   desired results.
;
;-------------------------------------------------------------------------------
Fnt_GetStringSize(hFont,p_String,ByRef r_Width="",ByRef r_Height="")
    {
    Static Dummy6596
          ,DEFAULT_GUI_FONT:=17
          ,HWND_DESKTOP    :=0
          ,SIZE

    ;-- If needed, get the handle to the default GUI font
    if not hFont
        hFont:=DllCall("GetStockObject","Int",DEFAULT_GUI_FONT)

    ;-- Select the font into the device context for the desktop
    hDC      :=DllCall("GetDC","Ptr",HWND_DESKTOP)
    old_hFont:=DllCall("SelectObject","Ptr",hDC,"Ptr",hFont)

    ;-- Get string size
    VarSetCapacity(SIZE,8,0)
    RC:=DllCall("GetTextExtentPoint32"
        ,"Ptr",hDC                                      ;-- hDC
        ,"Str",p_String                                 ;-- lpString
        ,"Int",StrLen(p_String)                         ;-- c (string length)
        ,"Ptr",&SIZE)                                   ;-- lpSize

    ;-- Release the objects needed by the "GetTextExtentPoint32" function
    DllCall("SelectObject","Ptr",hDC,"Ptr",old_hFont)
        ;-- Necessary to avoid memory leak

    DllCall("ReleaseDC","Ptr",HWND_DESKTOP,"Ptr",hDC)

    ;-- Return to sender
    if RC
        {
        r_Width :=NumGet(SIZE,0,"Int")
        r_Height:=NumGet(SIZE,4,"Int")
        Return &SIZE
        }
     else
        Return False
    }


;------------------------------
;
; Function: Fnt_GetStringWidth
;
; Description:
;
;   Calculates the width of a string of text.
;
; Returns:
;
;   The width of the string of text if successful, otherwise -1.
;
; Calls To Other Functions:
;
; * <Fnt_GetStringSize>
;
; Remarks:
;
;   This function is just a call to <Fnt_GetStringSize> to get the width of a
;   string.  Note that there is no associated "GetStringHeight"  function
;   because the height of a string is the same as the font height.  In addition
;   to <Fnt_GetStringSize>, the height can collected from <Fnt_GetFontHeight>.
;
;-------------------------------------------------------------------------------
Fnt_GetStringWidth(hFont,p_String)
    {
    Return (pSIZE:=Fnt_GetStringSize(hFont,p_String)) ? NumGet(pSIZE+0,0,"Int"):-1
    }


;------------------------------
;
; Function: Fnt_GetSysColor
;
; Description:
;
;   Retrieves the current color of the specified display element.  Display
;   elements are the parts of a window and the display that appear on the system
;   display screen.
;
; Parameters:
;
;   p_DisplayElement - Display element. A complete list of display elements can
;       be found <here at
;       https://msdn.microsoft.com/en-us/library/windows/desktop/ms724371%28v=vs.85%29.aspx>.
;
; Type:
;
;   Internal function.  Subject to change.  Do not use.
;
; Returns:
;
;   The display element color in an AutoHotkey hexidecimal value.  Ex: 0x12FF7B.
;
; Remarks:
;
;   The return value always contains 6 hexadecimal digits.  Ex: 0x00FF00.  To
;   convert to a 6-digit RGB color value, simply delete the leading "0x"
;   characters.
;
;-------------------------------------------------------------------------------
Fnt_GetSysColor(p_DisplayElement)
    {
    ;-- Collect color (returns BGR value)
    l_Color:=DllCall("GetSysColor","Int",p_DisplayElement)

    ;-- Convert to RGB
    l_Color:=((l_Color&0xFF)<<16)+(l_Color&0xFF00)+((l_Color>>16)&0xFF)

    ;-- Convert/format to a 6-digit AutoHotkey hexadecimal value
    Return Format("0x{:06X}",l_Color)
    }


;------------------------------
;
; Function: Fnt_GetTotalRowHeight
;
; Description:
;
;   Calculates the height of a given number of rows of text for a font.
;
; Parameters:
;
;   hFont - Handle to a logical font.  Set to 0 to use the default GUI font.
;
;   p_NbrOfRows - Rows of text.  Ex: 12.  Partial rows can be specified.  Ex:
;       5.25.
;
; Returns:
;
;   The height of the rows of text, in pixels.
;
; Calls To Other Functions:
;
; * <Fnt_GetFontExternalLeading>
; * <Fnt_GetFontHeight>
;
; Remarks:
;
;   This function calculates the total height by adding up the font height for
;   each row, including the space between each row (ExternalLeading) if there is
;   more than one row.  This calculation was originally extracted from the
;   AutoHotkey source and is the same or similar calculation used by AutoHotkey
;   when the r{NumberOfRows} option is used.
;
;   Important: This calculation does not include any extra space that a GUI
;   control may need in order to correctly display the text in the control.  Ex:
;   Edit control.
;
;-------------------------------------------------------------------------------
Fnt_GetTotalRowHeight(hFont,p_NbrOfRows)
    {
    Return Floor((Fnt_GetFontHeight(hFont)*p_NbrOfRows)+(Fnt_GetFontExternalLeading(hFont)*(Floor(p_NbrOfRows+0.5)-1))+0.5)
    }


;------------------------------
;
; Function: Fnt_GetWindowColor
;
; Description:
;
;   Retrieves the current window (background) color.
;
; Type:
;
;   Internal function.  Subject to change.  Do not use.
;
;-------------------------------------------------------------------------------
Fnt_GetWindowColor()
    {
    Static COLOR_WINDOW:=5  ;-- Window background
    Return Fnt_GetSysColor(COLOR_WINDOW)
    }


;------------------------------
;
; Function: Fnt_GetWindowTextColor
;
; Description:
;
;   Retrieves the current window text color.
;
; Type:
;
;   Internal function.  Subject to change.  Do not use.
;
;-------------------------------------------------------------------------------
Fnt_GetWindowTextColor()
    {
    Static COLOR_WINDOWTEXT:=8
    Return Fnt_GetSysColor(COLOR_WINDOWTEXT)
    }


;------------------------------
;
; Function: Fnt_HorzDTUs2Pixels
;
; Description:
;
;   Converts horizontal dialog template units to pixels for a font.
;
; Returns:
;
;   The width of the specified horizontal dialog template units, in pixels.
;
; Calls To Other Functions:
;
; * <Fnt_DialogTemplateUnits2Pixels>
;
; Remarks:
;
;   This function is just a call to <Fnt_DialogTemplateUnits2Pixels> to only
;   convert horizontal dialog template units.
;
;-------------------------------------------------------------------------------
Fnt_HorzDTUs2Pixels(hFont,p_HorzDTUs)
    {
    Fnt_DialogTemplateUnits2Pixels(hFont,p_HorzDTUs,0,l_Width)
    Return l_Width
    }


;------------------------------
;
; Function: Fnt_IsFixedPitchFont
;
; Description:
;
;   Determines if a font is a fixed pitch font.
;
; Parameters:
;
;   hFont - Handle to a logical font.
;
; Returns:
;
;   TRUE if the font is a fixed pitch font, otherwise FALSE.
;
; Calls To Other Functions:
;
; * <Fnt_GetFontMetrics>
;
;-------------------------------------------------------------------------------
Fnt_IsFixedPitchFont(hFont)
    {
    Static TMPF_FIXED_PITCH:=0x1
        ;-- If this bit is set, the font is a variable pitch font.  If
        ;   this bit is clear, the font is a fixed pitch font.  Note very
        ;   carefully that those meanings are the opposite of what the constant
        ;   name implies.

    Return NumGet(Fnt_GetFontMetrics(hFont),A_IsUnicode ? 55:51,"UChar") & TMPF_FIXED_PITCH ? False:True
    }


;------------------------------
;
; Function: Fnt_IsTrueTypeFont
;
; Description:
;
;   Determines if a font is a TrueType font.
;
; Parameters:
;
;   hFont - Handle to a logical font.
;
; Returns:
;
;   TRUE if the font is a TrueType font, otherwise FALSE.
;
; Calls To Other Functions:
;
; * <Fnt_GetFontMetrics>
;
;-------------------------------------------------------------------------------
Fnt_IsTrueTypeFont(hFont)
    {
    Static TMPF_TRUETYPE:=0x4
    Return NumGet(Fnt_GetFontMetrics(hFont),A_IsUnicode ? 55:51,"UChar") & TMPF_TRUETYPE ? True:False
    }


;------------------------------
;
; Function: Fnt_Pixels2DialogTemplateUnits
;
; Description:
;
;   Converts pixels to dialog template units for a font.
;
; Parameters:
;
;   hFont - Handle to a logical font.  Set to 0 to use the default GUI font.
;
;   p_Width - Width, in pixel.
;
;   p_Height - Height, in pixels.
;
;   r_HorzDTUs, r_VertDTUs - Output variables. [Optional] These variables are
;       loaded with the horizontal and vertical dialog template units for the
;       specified width and height.
;
; Returns:
;
;   Address to a SIZE structure.  The cx member of the SIZE structure contains
;   the horizontal dialog template units for the specified width.  The cy member
;   contains the vertical dialog template units for the specified height.
;
; Calls To Other Functions:
;
; * <Fnt_GetDialogBaseUnits>
;
;-------------------------------------------------------------------------------
Fnt_Pixels2DialogTemplateUnits(hFont,p_Width,p_Height=0,ByRef r_HorzDTUs="",ByRef r_VertDTUs="")
    {
    Static Dummy1461
          ,SIZE
          ,s_hFont:=-1
          ,s_HorzDBUs
          ,s_VertDBUs

    ;-- If needed, initialize and get Dialog Base Units
    if (hFont<>s_hFont)
        {
        s_hFont:=hFont
        VarSetCapacity(SIZE,8,0)
        Fnt_GetDialogBaseUnits(hFont,s_HorzDBUs,s_VertDBUs)
        }

    ;-- Convert width and height (in pixels) to DTUs
    NumPut(r_HorzDTUs:=Round(p_Width*4/s_HorzDBUs),SIZE,0,"Int")
    NumPut(r_VertDTUs:=Round(p_Height*8/s_VertDBUs),SIZE,4,"Int")
    Return &SIZE
    }


;------------------------------
;
; Function: Fnt_RemoveFontFile
;
; Description:
;
;   Remove the font(s) added with <Fnt_AddFontFile>.
;
; Type:
;
;   Experimental.  Subject to change.
;
; Parameters:
;
;   Same parameters as <Fnt_AddFontFile>.  Use the same parameter values that
;   were used to add the font(s).
;
; Returns:
;
;   The number of the fonts removed if successful, otherwise FALSE.
;
; Remarks:
;
;   See the *Remarks* section of <Fnt_AddFontFile> for more information.
;
;-------------------------------------------------------------------------------
Fnt_RemoveFontFile(p_File,p_Private,p_Hidden=False)
    {
    Static Dummy0661

          ;-- Font Resource flags
          ,FR_PRIVATE :=0x10
          ,FR_NOT_ENUM:=0x20

          ;-- Messages and flags
          ,WM_FONTCHANGE :=0x1D
          ,HWND_BROADCAST:=0xFFFF

    ;-- Build flags
    l_Flags:=0
    if p_Private
        l_Flags|=FR_PRIVATE

    if p_Hidden
        l_Flags|=FR_NOT_ENUM

    ;-- Remove font
    RC:=DllCall("RemoveFontResourceEx","Str",p_File,"UInt",l_Flags,"UInt",0)

    ;-- If one or more fonts were removed, notify all top-level windows that the
    ;   pool of font resources has changed.
    if RC
        SendMessage WM_FONTCHANGE,0,0,,ahk_id %HWND_BROADCAST%,,,,1000
            ;-- Wait up to 1000 ms for all windows to respond to the message

    Return RC
    }


;------------------------------
;
; Function: Fnt_SetFont
;
; Description:
;
;   Sets the font that the control is to use when drawing text.
;
; Parameters:
;
;   hControl - Handle to the control.
;
;   hFont - Handle to a logical font.  Set to 0 to use the default GUI font.
;
;   p_Redraw - Specifies whether the control should be redrawn immediately upon
;       setting the font.  If set to TRUE, the control redraws itself.
;
; Remarks:
;
;   The size of the control does not change as a result of receiving this
;   message.  To avoid clipping text that does not fit within the boundaries of
;   the control, the program should set/correct the size of the control window
;   before the font is set.
;
;   Update 20150615: A recent update of Windows 7 (it appears to be other
;   versions of Windows as well) has changed how the tooltip control responds to
;   certain messages. The tooltip may no longer automatically redraw when the
;   WM_SETFONT message is sent.  Worse yet, if the p_Redraw parameter is set to
;   TRUE, the WM_SETFONT message may deactivate the tooltip.  One workaround is
;   to send the WM_SETFONT message (this function) with p_Redraw set to FALSE
;   (the default) and then send the TTM_UPDATE message (call
;   <Fnt_UpdateTooltip>) immediately afterwards.  When used together, these
;   functions will set the font of the tooltip control and redraw the tooltip
;   control without deactivating the tooltip.
;
;-------------------------------------------------------------------------------
Fnt_SetFont(hControl,hFont=0,p_Redraw=False)
    {
    Static Dummy3005
          ,DEFAULT_GUI_FONT:=17
          ,WM_SETFONT:=0x30

    ;-- If needed, get the handle to the default GUI font
    if not hFont
        hFont:=DllCall("GetStockObject","Int",DEFAULT_GUI_FONT)

    ;-- Set font
    l_DetectHiddenWindows:=A_DetectHiddenWindows
    DetectHiddenWindows On
    SendMessage WM_SETFONT,hFont,p_Redraw,,ahk_id %hControl%
    DetectHiddenWindows %l_DetectHiddenWindows%
    }


;------------------------------
;
; Function: Fnt_String2DialogTemplateUnits
;
; Description:
;
;   Converts a string to dialog template units for a font.
;
; Parameters:
;
;   hFont - Handle to a logical font.  Set to 0 to use the default GUI font.
;
;   p_String - The string to be measured.
;
;   r_HorzDTUs, r_VertDTUs - Output variables. [Optional] These variables are
;       loaded with the horizontal and vertical dialog template units for the
;       specified string.
;
; Returns:
;
;   Address to a SIZE structure.  The cx member of the SIZE structure contains
;   the horizontal dialog template units for the specified string.  The cy
;   member contains the vertical dialog template units.
;
; Calls To Other Functions:
;
; * <Fnt_GetDialogBaseUnits>
; * <Fnt_GetStringSize>
;
;-------------------------------------------------------------------------------
Fnt_String2DialogTemplateUnits(hFont,p_String,ByRef r_HorzDTUs="",ByRef r_VertDTUs="")
    {
    Static Dummy5021
          ,SIZE
          ,s_hFont:=-1
          ,s_HorzDBUs
          ,s_VertDBUs

    ;-- If needed, initialize and get Dialog Base Units
    if (hFont<>s_hFont)
        {
        s_hFont:=hFont
        VarSetCapacity(SIZE,8,0)
        Fnt_GetDialogBaseUnits(hFont,s_HorzDBUs,s_VertDBUs)
        }

    ;-- Convert string to DTUs
    Fnt_GetStringSize(hFont,p_String,l_StringW,l_StringH)
    NumPut(r_HorzDTUs:=Round(l_StringW*4/s_HorzDBUs),SIZE,0,"Int")
    NumPut(r_VertDTUs:=Round(l_StringH*8/s_VertDBUs),SIZE,4,"Int")
    Return &SIZE
    }


;------------------------------
;
; Function: Fnt_TruncateStringToFit
;
; Description:
;
;    Returns a string, truncated if necessary, that is less than or equal to a
;    specified width, in pixels.
;
; Parameters:
;
;   hFont - Handle to a logical font.  Set to 0 to use the default GUI font.
;
;   p_String - The string to process.
;
;   p_MaxStringW - The maximum width for the return string, in pixels.
;
; Returns:
;
;   A string with a width (measured in pixels) that is less than or equal to the
;   value in p_MaxStringW.
;
; Calls To Other Functions:
;
; * <Fnt_GetFontMaxCharWidth>
;
; Remarks:
;
;   If the value of p_MaxStringW is less than the width of the first character
;   in the string, null is returned.
;
;-------------------------------------------------------------------------------
Fnt_TruncateStringToFit(hFont,p_String,p_MaxStringW)
    {
    Static Dummy9426
          ,DEFAULT_GUI_FONT:=17
          ,HWND_DESKTOP    :=0

    ;[======================]
    ;[      Parameters      ]
    ;[  (Bounce if needed)  ]
    ;[======================]
    if not StrLen(p_String)
        Return p_String

    if p_MaxStringW is not Integer
        Return p_String
     else if (p_MaxStringW<1)  ;-- Zero or negative
        Return ""

    ;[==============]
    ;[  Initialize  ]
    ;[==============]
    VarSetCapacity(SIZE,8,0)

    ;-- If needed, get the handle to the default GUI font
    if not hFont
        hFont:=DllCall("GetStockObject","Int",DEFAULT_GUI_FONT)

    ;-- Select the font into the device context for the desktop
    hDC      :=DllCall("GetDC","Ptr",HWND_DESKTOP)
    old_hFont:=DllCall("SelectObject","Ptr",hDC,"Ptr",hFont)

    ;-- Misc.
    l_FontMaxCharWidth:=Fnt_GetFontMaxCharWidth(hFont)

    ;[===============]
    ;[  Pre-Process  ]
    ;[===============]
    ;-- Get the width of the original string, in pixels
    DllCall("GetTextExtentPoint32"
        ,"Ptr",hDC                                      ;-- hDC
        ,"Str",p_String                                 ;-- lpString
        ,"Int",StrLen(p_String)                         ;-- c (string length)
        ,"Ptr",&SIZE)                                   ;-- lpSize

    l_StringW:=NumGet(SIZE,0,"Int")

    ;-- Bounce if the string is already less than or equal to p_MaxStringW
    if (l_StringW<=p_MaxStringW)
        {
        ;-- Release the objects needed by the "GetTextExtentPoint32" function
        DllCall("SelectObject","Ptr",hDC,"Ptr",old_hFont)
            ;-- Necessary to avoid memory leak

        DllCall("ReleaseDC","Ptr",HWND_DESKTOP,"Ptr",hDC)

        ;-- Return unmolested string
        Return p_String
        }

    ;[===========]
    ;[  Process  ]
    ;[===========]
    ;-- Make an calculated guess on the starting position within the string
    if not l_StringPos:=Floor(StrLen(p_String)*(p_MaxStringW/l_StringW))
        l_StringPos:=1

    l_String:=SubStr(p_String,1,l_StringPos)

    ;-- Get the width of the calculated guess string, in pixels
    DllCall("GetTextExtentPoint32"
        ,"Ptr",hDC                                      ;-- hDC
        ,"Str",l_String                                 ;-- lpString
        ,"Int",StrLen(l_String)                         ;-- c (string length)
        ,"Ptr",&SIZE)                                   ;-- lpSize

    l_CurrentStringW:=NumGet(SIZE,0,"Int")

    ;-- Increment, decrement, or do nothing else (very rare but possible)
    if (l_CurrentStringW<p_MaxStringW)  ;-- Under?  Increment until the string is >= requested size
        {
        Loop
            {
            l_PrevString:=l_String

            ;-- Calculate the number of string positions to increment (usually 1)
            if not l_NbrOfPositions:=Floor((p_MaxStringW-l_CurrentStringW)/l_FontMaxCharWidth)
                l_NbrOfPositions:=1

            ;-- Increment and extract the next string to test
            l_StringPos+=l_NbrOfPositions
            l_String:=SubStr(p_String,1,l_StringPos)

            ;-- Get the width of the string, in pixels
            DllCall("GetTextExtentPoint32"
                ,"Ptr",hDC                              ;-- hDC
                ,"Str",l_String                         ;-- lpString
                ,"Int",StrLen(l_String)                 ;-- c (string length)
                ,"Ptr",&SIZE)                           ;-- lpSize

            l_CurrentStringW:=NumGet(SIZE,0,"Int")

            ;-- Exact hit? (rare but possible)
            if (l_CurrentStringW=p_MaxStringW)
                Break
             else
                ;-- Over? Use the previous string and break
                if (l_CurrentStringW>p_MaxStringW)
                    {
                    l_String:=l_PrevString
                    Break
                    }
            }
        }
     else if (l_CurrentStringW>p_MaxStringW)  ;-- Over?  Decrement until the string is <= requested size
        {
        Loop
            {
            ;-- Break if the next position will be too small
            if (l_StringPos<=1)
                {
                l_String:=""
                Break
                }

            ;-- Calculate the number of string positions to increment (usually 1)
            if not l_NbrOfPositions:=Floor((l_CurrentStringW-p_MaxStringW)/l_FontMaxCharWidth)
                l_NbrOfPositions:=1

            ;-- Decrement and extract the next string to test
            l_StringPos-=l_NbrOfPositions
            l_String:=SubStr(p_String,1,l_StringPos)

            ;-- Get the width of the string, in pixels
            DllCall("GetTextExtentPoint32"
                ,"Ptr",hDC                              ;-- hDC
                ,"Str",l_String                         ;-- lpString
                ,"Int",StrLen(l_String)                 ;-- c (string length)
                ,"Ptr",&SIZE)                           ;-- lpSize

            l_CurrentStringW:=NumGet(SIZE,0,"Int")

            ;-- Break if target is achieved
            if (l_CurrentStringW<=p_MaxStringW)
                Break
            }
        }

    ;[================]
    ;[  Housekeeping  ]
    ;[================]
    ;-- Release the objects needed by the "GetTextExtentPoint32" function
    DllCall("SelectObject","Ptr",hDC,"Ptr",old_hFont)
        ;-- Necessary to avoid memory leak

    DllCall("ReleaseDC","Ptr",HWND_DESKTOP,"Ptr",hDC)

    ;-- Return string
    Return l_String
    }


;------------------------------
;
; Function: Fnt_TwipsPerPixel
;
; Description:
;
;   Determines the number of twips (abbreviation of "twentieth of an inch
;   point") for every pixel on the screen.
;
; Parameters:
;
;   X, Y - Output variables. [Optional] These variables are loaded with the
;       number of twips for each pixel along the the screen width (X) and
;       height (Y).
;
; Returns:
;
;   Address to a SIZE structure.  The cx member of the SIZE structure contains
;   the number of twips for each pixel along the screen width.  The cy member
;   contains the number of twips for each pixel along the screen height.
;
;-------------------------------------------------------------------------------
Fnt_TwipsPerPixel(ByRef X="",ByRef Y="")
    {
    Static Dummy3871
          ,SIZE

          ;-- Device constants
          ,LOGPIXELSX:=88
          ,LOGPIXELSY:=90

    ;-- Initialize
    VarSetCapacity(SIZE,8,0)

    ;-- Convert the number of pixels per logical inch to twips
    hDC:=DllCall("CreateDC","Str","DISPLAY","Ptr",0,"Ptr",0,"Ptr",0)
    NumPut(X:=Round(1440/DllCall("GetDeviceCaps","Ptr",hDC,"Int",LOGPIXELSX)),SIZE,0,"Int")
    NumPut(Y:=Round(1440/DllCall("GetDeviceCaps","Ptr",hDC,"Int",LOGPIXELSY)),SIZE,4,"Int")
    DllCall("DeleteDC","Ptr",hDC)
    Return &SIZE
    }


;------------------------------
;
; Function: Fnt_UpdateTooltip
;
; Description:
;
;   Forces the tooltip to be redrawn.
;
; Parameters:
;
;   hTT - Handle to the tooltip control.
;
; Remarks:
;
;   See the *Remarks* section of <Fnt_SetFont> for more information.
;
;-------------------------------------------------------------------------------
Fnt_UpdateTooltip(hTT)
    {
    Static TTM_UPDATE:=0x41D                            ;-- WM_USER + 29
    SendMessage TTM_UPDATE,0,0,,ahk_id %hTT%
    }


;------------------------------
;
; Function: Fnt_VertDTUs2Pixels
;
; Description:
;
;   Converts vertical dialog template units to pixels for a font.
;
; Returns:
;
;   The height of the specified vertical dialog template units, in pixels.
;
; Calls To Other Functions:
;
; * <Fnt_DialogTemplateUnits2Pixels>
;
; Remarks:
;
;   This function is just a call to <Fnt_DialogTemplateUnits2Pixels> to only
;   convert vertical dialog template units.
;
;-------------------------------------------------------------------------------
Fnt_VertDTUs2Pixels(hFont,p_VertDTUs)
    {
    Fnt_DialogTemplateUnits2Pixels(hFont,0,p_VertDTUs,Dummy,l_Height)
    Return l_Height
    }
