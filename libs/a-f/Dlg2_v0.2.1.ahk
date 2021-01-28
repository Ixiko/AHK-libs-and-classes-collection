/*  Title: Dlg2 v0.2.1 (Preview)


Group: Overview

This is a library of functions to create and interact with many of the
Microsoft Windows common dialogs.  Use of the common dialogs gives the user a
consistent experience across different programs.

*Components*
============
In addition to standard functions, this library may contain Internal and Helper
functions.

As the name implies, _internal_ functions are used internally by this library.
They are either called by other library functions or are triggered by system
messages or registered callbacks.  Internal functions are subject to change and
should not be called directly.

_Helper_ functions are non-standard functions that are included to assist the
developer resolve unusual problems related to this library.  These functions
may or may not provide value to the developer.

All functions that are not labeled as "Internal" or "Helper" are _standard_
functions and can be called directly.

*History and Credit*
====================
This library is a offshoot of the Dlg library which was released by *majkinetor*
in 2007 and was included as part of the Forms Framework in 2010.  It has been
been rewritten to include new features, new dialogs, and to support x64.  All of
the function names have been changed so that there is no confusion with the
original Dlg library.  The library retains much of the core design of the
original library and would not exist without the research and hard work of
*majkinetor*.

*Requirements*
==============
The minimum supported operating system for this library is Windows 2000.
Exceptions, if any, are noted in the documentation written for each function.
This library can be used on all versions of AutoHotkey including AutoHotkey
Basic and AutoHotkey v1.1+ (ANSI and Unicode) (32 and 64 bit).

*Future Support*
================
Support for Print and Page Setup dialogs are not included in this version of the
library due to the lack of demand and the complex nature of these dialogs.  They
_may_ be included in a future release.


*Future Requirements*
=====================
The Dlg2 library (all versions) will mark the end of support for Windows 2000/XP
and AutoHotkey Basic.  Future iterations of the library (possibly identified as
Dlg3) will require Windows Vista+ and AutoHotkey v1.1+.


Group: Functions
*/
/*  v0.3 (or 0.2.1+) updates

 *  Fix: Dlg_ChooseFont updated to correctly return font weights other than
    normal (400) or bold (700).

 *  Fix/work-around: Dlg_OnHelpMsg function was not sending the handle to the
    dialog to the help handler when the Help button was pressed on the Open and
    Save dialog.  Problem occurs on Vista+.  Fixed by sending the handle to the
    active window if the handle to the dialog is not provided by the
    FINDMSGSTRING message.

 *  Update: Dlg_GetScriptDebugWindow returns the value of A_ScriptHwnd if using
    AutoHotkey v1.1.1+. *i*Note: The return value is the same.  The function is
    just a bit more efficient when running on AutoHotkey v1.1.1+.*i*

 *  Updated structures documentation.
*/

Dlg_ChooseColor(hOwner,ByRef r_Color,p_Flags=0,p_CustomColorsFile="",p_HelpHandler="") {
    
    ;{  Function: Dlg_ChooseColor
    ;
    ; Description:
    ;
    ;   Creates a Color dialog box that enables the user to select a color.
    ;   (see _Color.jpg)
    ;
    ; Parameters:
    ;
    ;   hOwner - A handle to the window that owns the dialog box.  This parameter
    ;       can be any valid window handle or it can be set to 0 or null if the
    ;       dialog box has no owner.  Note: A valid window handle must be specified
    ;       if the CC_SHOWHELP flag is included (explicitly or implicitly).
    ;
    ;   r_Color - Color in RGB format. [Input/Output] On input, this variable should
    ;       contain the default color, i.e. the color that is initially selected
    ;       when the Color dialog is displayed.  On output, this variable contains
    ;       the color selected in a 6-digit hexadecimal RGB format.  Ex: 0x00FF80.
    ;       If the function returns FALSE, i.e. the Color dialog was cancelled, the
    ;       value of this variable is not changed.
    ;
    ;   p_Flags - Flags used to initialize the Color dialog.  See the *Flags*
    ;       section for the details.
    ;
    ;   p_CustomColorsFile - Path to a file that contains the custom colors that
    ;       will be used by the application. [Optional]  See the *Remarks* section
    ;       for more information.
    ;
    ;   p_HelpHandler - Name of a developer-created function that is called when the
    ;       the user presses the Help button on the dialog. [Optional] See the *Help
    ;       Handler* section for the details.  Note: The CC_SHOWHELP flag is
    ;       automatically added if this parameter contains a valid function name.
    ;
    ; Flags:
    ;
    ;   The p_Flags parameter contains flags that are used to initialize and/or
    ;   determine the behavior of the dialog.  If set to zero (the default) or null,
    ;   the CC_FULLOPEN and CC_ANYCOLOR flags are used.  If p_Flags contains an
    ;   interger value, the parameter is assumed to contain bit flags.  See the
    ;   function's static variables for a list a valid bit flags.  Otherwise, the
    ;   following space-delimited text flags can be used.
    ;
    ;   AnyColor - Causes the dialog box to display all available colors in the set
    ;       of basic colors.
    ;
    ;   FullOpen - Causes the dialog box to display the additional controls that
    ;       allow the user to create custom colors.  If this flag is not set, the
    ;       user must click the Define Custom Colors button to display the custom
    ;       color controls.
    ;
    ;   PreventFullOpen - Disables the Define Custom Colors button.
    ;
    ;   ShowHelp - Causes the dialog box to display the Help button.
    ;
    ; Returns:
    ;
    ;   TRUE if a color was selected, otherwise FALSE which indicates that the
    ;   dialog was canceled.
    ;
    ; Calls To Other Functions:
    ;
    ; * <Dlg_Convert2Hex>
    ;
    ; Credit:
    ;
    ;   Some of the custom colors ideas and 64-bit mapping offsets were extracted
    ;   from a function published by *rbrtryn*.  Some custom color and file
    ;   formatting ideas were extracted from a function published by *maestrith*.
    ;   Thanks to these authors for publishing their work.
    ;
    ; Remarks:
    ;
    ; * On input, the color stored in the r_Color variable is expected to be in
    ;   in RGB format.  On output, the color selected by the user is stored in the
    ;   r_Color variable in RGB format.  To convert the color from BRG for input
    ;   or to BRG after the function returns, the following statement can used.
    ;
    ;       (start code)
    ;       ;-- Convert from BRG to RGB or vise versa
    ;       Color:=((Color&0xFF)<<16)+(Color&0xFF00)+((Color>>16)&0xFF)
    ;       (end)
    ;
    ; * Although the output value of r_Color is a hexadecimal number, it has been
    ;   formatted to always have 6 digits -- leading zero ("0") characters are
    ;   prepended to the value when needed.  Ex: 0x0000FF.  To use this value with
    ;   AutoHotkey commands that use a 6-digit RGB value, simply truncate the first
    ;   2 characters (i.e."0x") of variable.  For example:
    ;
    ;       (start code)
    ;       if Dlg_ChooseColor(hWindow,Color)
    ;           gui Font,% "c" . SubStr(Color,3)
    ;       (end)
    ;
    ; * If a file name is specified in the p_CustomColorsFile parameter, custom
    ;   colors are written to a standard windows configuration file, i.e. INI file,
    ;   in the "CustomColors" section.  Each custom color is stored is a sequential
    ;   numerical key staring with "1".  The first custom color is stored in key
    ;   "1", the second in key "2", and so on until key "16".  Each custom color is
    ;   stored as an integer in the BGR format.  For example:
    ;
    ;       (start code)
    ;       [CustomColors]
    ;       1=16764134
    ;       2=32768
    ;       ...
    ;       16=250
    ;       (end)
    ;
    ; * If the custom colors configuration file does not exist, it will be created
    ;   when the custom colors are saved.  If writing to an existing file, a
    ;   "CustomColors" section will be created if needed.
    ;
    ; * If a custom color file is not specified (p_CustomColorsFile parameter), the
    ;   function will still save additions and changes to the "Custom Colors"
    ;   section of the Color dialog in static memory so that they will be available
    ;   if the dialog is used multiple times.  However, all custom colors are lost
    ;   when the script ends.
    ;
    ; Help Handler:
    ;
    ;   The "Help Handler" is an optional developer-created function that is called
    ;   when the user presses the Help button on the dialog.
    ;
    ;   The handler function must have at least 2 parameters.  Additional parameters
    ;   are allowed but must be optional (defined with a default value).  The
    ;   required parameters are defined/used as follows, and in the following order:
    ;
    ;       hDialog - The handle to the dialog window.
    ;
    ;       lpInitStructure - A pointer to the initialization structure for the
    ;           common dialog box. For this handler, the pointer is to a CHOOSECOLOR
    ;           structure.
    ;
    ;   It's up to the developer to determine what commands are performed in this
    ;   function but displaying some sort of help message/document is what is
    ;   expected.
    ;
    ;   Note: The handler is triggered via a message sent by the dialog.  The API
    ;   will not return until the message has been processed.  The handler should
    ;   either 1) finish quickly or 2) any dialogs displayed via the handler should
    ;   be modal.  See the scripts included with this project for an example.
    ;}
    
    
    Static Dummy1243
          ,HELPMSGSTRING:="commdlg_help"
                ;-- Registered message string for the Help button on common
                ;   dialogs


                ;-- ##### Need all(??) structures here and all buffers whose
                ;   addresses are included in the static structures

          ,CHOOSECOLOR
                ;-- Static CHOOSECOLOR structure.  Also used by the help
                ;   message.

                ;-- NTS: In theory, static is not required because this function
                ;   does not end until the callback function (if any) has
                ;   completed
                ;
                ;   NTS, Part 2: Static still may be desired because the
                ;   callback function can trigger an independent thread which
                ;   will allow the callback function to complete.  Static
                ;   variables will allow the addresses to remain valid until the
                ;   next time this function is called.

          ,s_CustomColors
                ;-- Custom color array.  Also used by the help message via the
                ;   CHOOSECOLOR structure.

          ;-- ChooseColor flags
          ,CC_ANYCOLOR:=0x100
                ;-- Causes the dialog box to display all available colors in the
                ;   set of basic colors.

;;;;;          ,CC_ENABLEHOOK:=0x10
;;;;;          ,CC_ENABLETEMPLATE:=0x20
;;;;;          ,CC_ENABLETEMPLATEHANDLE:=0x40

          ,CC_FULLOPEN:=0x2
                ;-- Causes the dialog box to display the additional controls
                ;   that allow the user to create custom colors.  If this flag
                ;   is not set, the user must click the Define Custom Color
                ;   button to display the custom color controls.

          ,CC_PREVENTFULLOPEN:=0x4
                ;-- Disables the Define Custom Colors button.

          ,CC_RGBINIT:=0x1
                ;-- Causes the dialog box to use the color specified in the
                ;   rgbResult member as the initial color selection.  This flag
                ;   is included by default.

          ,CC_SHOWHELP:=0x8
                ;-- Causes the dialog box to display the Help button.  Note: The
                ;   Help button is not operational unless the p_HelpHandler
                ;   parameter contains a valid function name.

          ,CC_SOLIDCOLOR:=0x80
                ;-- Causes the dialog box to display only solid colors in the
                ;   set of basic colors.  Observation: This flags doesn't
                ;   appear to do anything.

    ;[==============]
    ;[  Initialize  ]
    ;[==============]
    ;-- Workaround for AutoHotkey Basic and x64
    PtrType:=(A_PtrSize=8) ? "Ptr":"UInt"

    ;-- If needed, initialize custom colors array
    if not VarSetCapacity(s_CustomColors)
        VarSetCapacity(s_CustomColors,64,0)
            ;-- All values are set to Black (0x0)

    ;[==============]
    ;[  Parameters  ]
    ;[==============]
    ;-- Color
    l_Color:=r_Color  ;-- Working copy of r_Color
    if l_Color is not Integer
        l_Color:=0x0  ;-- Black
     else
        ;-- Convert color to BGR
        l_Color:=((l_Color&0xFF)<<16)+(l_Color&0xFF00)+((l_Color>>16)&0xFF)

    ;-- Flags
    l_Flags:=CC_RGBINIT
    if not p_Flags  ;-- Zero, blank, or null
        l_Flags|=CC_FULLOPEN|CC_ANYCOLOR
     else
        ;-- Bit flags
        if p_Flags is Integer
            l_Flags|=p_Flags
         else
            ;-- Convert text flags into bit flags
            Loop Parse,p_Flags,%A_Tab%%A_Space%,%A_Tab%%A_Space%
                if A_LoopField is not Space
                    if CC_%A_LoopField% is Integer
                        l_Flags|=CC_%A_LoopField%

    if IsFunc(p_HelpHandler)
        l_Flags|=CC_SHOWHELP

    ;[==================]
    ;[  Pre-Processing  ]
    ;[==================]
    ;-- If requested, load custom colors from the custom colors file
    if StrLen(p_CustomColorsFile)
        Loop 16
            {
            IniRead t_Color,%p_CustomColorsFile%,CustomColors,%A_Index%,0
            NumPut(t_Color,s_CustomColors,(A_Index-1)*4,"UInt")
            }

    ;-- Create and populate CHOOSECOLOR structure
    lStructSize:=VarSetCapacity(CHOOSECOLOR,(A_PtrSize=8) ? 72:36,0)
    NumPut(lStructSize,CHOOSECOLOR,0,"UInt")            ;-- lStructSize
    NumPut(hOwner,CHOOSECOLOR,(A_PtrSize=8) ? 8:4,PtrType)
        ;-- hwndOwner
    NumPut(l_Color,CHOOSECOLOR,(A_PtrSize=8) ? 24:12,"UInt")
        ;-- rgbResult
    NumPut(&s_CustomColors,CHOOSECOLOR,(A_PtrSize=8) ? 32:16,PtrType)
        ;-- lpCustColors
    NumPut(l_Flags,CHOOSECOLOR,(A_PtrSize=8) ? 40:20,"UInt")
        ;-- Flags

    ;-- If requested and a handler has been specified, turn on help monitoring
    if (l_FLags & CC_SHOWHELP) and IsFunc(p_HelpHandler)
        {
        ;-- Register the Handler with the OnHelp function
        Dlg_OnHelpMsg("Register",p_HelpHandler,"","")

        ;-- Monitor the help message triggered by Help button
        OnMessage(l_HelpMsg:=DllCall("RegisterWindowMessage",PtrType,&HELPMSGSTRING),"Dlg_OnHelpMsg")
        }

    ;[===============]
    ;[  Show dialog  ]
    ;[===============]
    ;-- Show the Color dialog.  API returns TRUE if a color is selected,
    ;   otherwise FALSE is returned.  Note: The custom color array is updated
    ;   even if the Color dialog is canceled.
    RC:=DllCall("comdlg32\ChooseColor" . (A_IsUnicode ? "W":"A"),PtrType,&CHOOSECOLOR)

    ;[===================]
    ;[  Post-Processing  ]
    ;[===================]
    ;-- If requested, save custom colors
    if StrLen(p_CustomColorsFile)
        Loop 16
            IniWrite
                ,% NumGet(s_CustomColors,(A_Index-1)*4,"UInt")
                ,%p_CustomColorsFile%
                ,CustomColors
                ,%A_Index%

    ;-- If needed, turn off monitoring of help message
    if l_HelpMsg
        OnMessage(l_HelpMsg,"")

    ;-- Cancelled? (user pressed the "Cancel" button or closed the dialog)
    if (RC=0)
        Return False

    ;-- Collect the selected color
    l_Color:=NumGet(CHOOSECOLOR,(A_PtrSize=8) ? 24:12,"UInt")
        ;-- rgbResult

    ;-- Convert to RGB
    l_Color:=((l_Color&0xFF)<<16)+(l_Color&0xFF00)+((l_Color>>16)&0xFF)

    ;-- Update r_Color with the selected color
    r_Color:=Dlg_Convert2Hex(l_Color,6)
    Return True
    }

Dlg_ChooseFont(hOwner=0,ByRef r_Name="",ByRef r_Options="",p_Effects=True,p_Flags=0,p_HelpHandler="") {

    ;{ Function: Dlg_ChooseFont
    ;
    ; Description:
    ;
    ;   Creates a Font dialog box that enables the user to choose attributes for a
    ;   logical font.
    ;   (see _Font.jpg)
    ;
    ; Parameters:
    ;
    ;   hOwner - A handle to the window that owns the dialog box.  This parameter
    ;       can be any valid window handle or it can be set to 0 or null if the
    ;       dialog box has no owner.  Note: A valid window handle must be specified
    ;       if the CF_SHOWHELP flag is included (explicitly or implicitly).
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
    ;   p_Flags - [Advanced Feature] Additional ChooseFont bit flags. [Optional]
    ;       The default is 0 (no additional flags).  See the *Remarks* section for
    ;       more information.
    ;
    ;   p_HelpHandler - Name of a developer-created function that is called when the
    ;       the user presses the Help button on the dialog. [Optional] See the *Help
    ;       Handler* section for the details.  Note: The CF_SHOWHELP flag is
    ;       automatically added if this parameter contains a valid function name.
    ;
    ; Options:
    ;
    ;   On input, the r_Options parameter contains the default font options.  On
    ;   output, r_Options will contain the selected font options.  The following
    ;   space-delimited options (in alphabetical order) are available:
    ;
    ;   bold -  On input, this option will pre-select the "bold" font style.  On
    ;       output, this option will be returned if a bold font was selected.
    ;
    ;   c{color} - Text color.  "{color}" is one of 16 supported color names (see
    ;       See the function's static variables for a list of possible color names)
    ;       or a 6-digit hex RGB color value.  Example values: Blue or FF00FA.  On
    ;       input, this option will attempt to pre-select the text color.  On
    ;       output, this option is returned with the selected text color.  Notes and
    ;       exceptions:  1) The color Black (000000) is the default text color.  On
    ;       input, Black is pre-selected if this option is not defined.  2) Color
    ;       names (Ex: "Blue") are only accepted on input.  A 6-digit hex RGB color
    ;       value is always set on output (Ex: 0000FF).  3) If p_Effects is FALSE,
    ;       this option is ignored on input and is not returned.

    ;   italic - On input, this option will pre-select the "italic" font style.  On
    ;       output, this option will be returned if an italic font was selected.
    ;       Exception: If p_Effects is FALSE, this option is ignored on input and is
    ;       not returned.
    ;
    ;   s{size in points} -  Font size (in points).  For example: s12.  On input,
    ;       this option will load the font size and if on the font-size list, will
    ;       pre-select the font size.  On output, the font size that was
    ;       entered/selected is returned.
    ;
    ;   SizeMax{max point size} -  [Input only] The maximum point size the user can
    ;       enter/select.  For example: SizeMax72.  If this option is specified
    ;       without also specifying the SizeMin option, the SizeMin value is
    ;       automatically set to 1.
    ;
    ;   SizeMin{min point size} - [Input only] The minimum point size the user can
    ;       enter/select.  For example: SizeMin10.  If this option is specified
    ;       without also specifying the SizeMax option, the SizeMax value is
    ;       automatically set to 0xBFFF (49151).
    ;
    ;   strike -  On input, this option will check the "Strikeout" option.  On
    ;       output, this option will be returned if the "Strikeout" option was
    ;       checked.  Exception: If p_Effects is FALSE, this option is ignored on
    ;       input and is not returned.
    ;
    ;   underline -  On input, this option will check the "Underline" option.  On
    ;       output, this option will be returned if the "Underline" option was
    ;       checked.  Exception: If p_Effects is FALSE, this option is ignored on
    ;       input and is not returned.
    ;
    ;   w{font weight} - Font weight (thickness or boldness), which is an integer
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
    ; * <Dlg_Convert2Hex>
    ;
    ; Remarks:
    ;
    ; * Although the font weight can be any number between 1 and 1000, most fonts
    ;   only support 400 (Normal/Regular) and 700 (Bold).  A very small number of
    ;   fonts support additional font weights.  The ChooseFont dialog does not
    ;   display the font weight as a number.  Instead, the font weight is displayed
    ;   as font styles like Regular, ExtraLight, Black, etc.  See the <CreateFont
    ;   at http://tinyurl.com/n2qe72w> documentation for a list of common font
    ;   weight names and their associated font weight values.
    ;
    ; * The SizeMin and SizeMax options (r_Options parameter) not only affect the
    ;   list of fonts sizes that are shown in the Font Size selection list box in
    ;   the Font dialog box, they affect the font size that can be manually entered
    ;   in the Font Size combo box.  If a font size that is outside the boundaries
    ;   set by the SizeMin and SizeMax options, an MsgBox dialog is shown and the'
    ;   user is not allowed to continue until a valid font size is entered/selected.
    ;   Warning: If the value of the SizeMin option is greater than the SizeMax
    ;   option, the "ChooseFont" API function will generate a CFERR_MAXLESSTHANMIN
    ;   error and will return without showing the Font dialog box.
    ;
    ; * Flexibility in the operation of the ChooseFont dialog box is available via a
    ;   large number of ChooseFont flags.  For this function, the flags are
    ;   determined by constants, options in the r_Options parameter, and the value
    ;   of the p_Effects parameter.  Although the flags set by these conditions will
    ;   handle the needs of the majority of developers, there are a few ChooseFont
    ;   flags that could provide additional value.  The p_Flags parameter is used to
    ;   _add_ additional ChooseFont flags to control the operation of the Font
    ;   dialog box. See the function's static variables for a list of possible flag
    ;   values. Warning: This is an advanced feature.  Including invalid or
    ;   conflicting flags may produce unexpected results.  Be sure to test
    ;   throroughly.
    ;
    ; Help Handler:
    ;
    ;   The "Help Handler" is an optional developer-created function that is called
    ;   when the user presses the Help button on the dialog.
    ;
    ;   The handler function must have at least 2 parameters.  Additional parameters
    ;   are allowed but must be optional (defined with a default value).  The
    ;   required parameters are defined/used as follows, and in the following order:
    ;
    ;       hDialog - The handle to the dialog window.
    ;
    ;       lpInitStructure - A pointer to the initialization structure for the
    ;           common dialog box. For this handler, the pointer is to a CHOOSECOLOR
    ;           structure.
    ;
    ;   It's up to the developer to determine what commands are performed in this
    ;   function but displaying some sort of help message/document is what is
    ;   expected.
    ;
    ;   Note: The handler is triggered via a message sent by the dialog.  The API
    ;   will not return until the message has been processed.  The handler should
    ;   either 1) finish quickly or 2) any dialogs displayed via the handler should
    ;   be modal.  See the scripts included with this project for an example.
    ;}

    
    Static Dummy3155
          ,HELPMSGSTRING:="commdlg_help"
                ;-- Registered message string for the Help button on common
                ;   dialogs

                ;-- ##### Need all(??) structures here and all buffers whose
                ;   addresses are included in the static structures
                ;-- Static TBDTBDTBD structure.  Also used by the help message.

          ,CHOOSEFONT
                ;-- Static CHOOSEFONT structure.  Also used by the help message.

          ,LOGFONT
                ;-- Static LOGFONT structure.  Also used by the help message via
                ;   the CHOOSEFONT structure.

          ;-- ChooseFont flags
          ,CF_SCREENFONTS:=0x1
                ;-- List only the screen fonts supported by the system.  This
                ;   flag is automatically set.

          ,CF_SHOWHELP:=0x4
                ;-- Causes the dialog box to display the Help button.

          ,CF_INITTOLOGFONTSTRUCT:=0x40
                ;-- Use the structure pointed to by the lpLogFont member to
                ;   initialize the dialog box controls.  This flag is
                ;   automatically set.

          ,CF_EFFECTS:=0x100
                ;-- Causes the dialog box to display the controls that allow
                ;   the user to specify strikeout, underline, and text color
                ;   options.  This flag is automatically set if the p_Effects
                ;   parameter is set to TRUE.

          ,CF_SCRIPTSONLY:=0x400
                ;-- Allow selection of fonts for all non-OEM and Symbol
                ;   character sets, as well as the ANSI character set.

          ,CF_NOOEMFONTS:=0x800
                ;-- (Despite what the documentation states, this flag is used
                ;   to) prevent the dialog box from displaying and selecting OEM
                ;   fonts.  Ex: Terminal

          ,CF_NOSIMULATIONS:=0x1000
                ;-- Prevent the dialog box from displaying or selecting font
                ;   simulations.

          ,CF_LIMITSIZE:=0x2000
                ;-- Select only font sizes within the range specified by the
                ;   nSizeMin and nSizeMax members.  This flag is automatically
                ;   added if the SizeMin and/or the SizeMax options (r_Options
                ;   parameter) are used.

          ,CF_FIXEDPITCHONLY:=0x4000
                ;-- Show and allow selection of only fixed-pitch fonts.

          ,CF_FORCEFONTEXIST:=0x10000
                ;-- Display an error message if the user attempts to select a
                ;   font or style that is not listed in the dialog box.

          ,CF_SCALABLEONLY:=0x20000
                ;-- Show and allow selection of only scalable fonts.  Scalable
                ;   fonts include vector fonts, scalable printer fonts, TrueType
                ;   fonts, and fonts scaled by other technologies.

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

          ,CF_NOSCRIPTSEL:=0x800000
                ;-- Disables the Script combo box.

          ,CF_NOVERTFONTS:=0x1000000
                ;-- Display only horizontally oriented fonts.

          ;-- Device constants
          ,LOGPIXELSY:=90

          ;-- Misc. font constants
          ,CFERR_MAXLESSTHANMIN:=0x2002
          ,FW_NORMAL           :=400
          ,FW_BOLD             :=700
          ,LF_FACESIZE         :=32     ;-- In TCHARS

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

    ;[==============]
    ;[  Initialize  ]
    ;[==============]
    ;-- Workarounds and shortcuts for AutoHotkey Basic, x64, and Unicode
    PtrType  :=(A_PtrSize=8) ? "Ptr":"UInt"
    TCharSize:=A_IsUnicode ? 2:1

    ;-- Collect the number of pixels per logical inch along the screen height
    hDC:=DllCall("CreateDC","Str","DISPLAY",PtrType,0,PtrType,0,PtrType,0)
    l_LogPixelsY:=DllCall("GetDeviceCaps",PtrType,hDC,"Int",LOGPIXELSY)
    DllCall("DeleteDC",PtrType,hDC)

    ;[==============]
    ;[  Parameters  ]
    ;[==============]
    r_Name=%r_Name%     ;-- AutoTrim

    ;-- p_Flags
    if p_Flags is not Integer
        p_Flags:=0x0

    p_Flags|=CF_SCREENFONTS|CF_INITTOLOGFONTSTRUCT
    if p_Effects
        p_Flags|=CF_EFFECTS

    if IsFunc(p_HelpHandler)
        p_Flags|=CF_SHOWHELP

    ;-----------
    ;-- Options
    ;-----------
    ;-- Initialize options
    o_Color    :=0x0    ;-- Black
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
            o_Color:="0x" . SubStr(A_LoopField,2)   ;-- Default assignment
            if A_LoopField is Alpha                 ;-- Possible color name
                {
                t_ColorName:=SubStr(A_LoopField,2)
                if Color_%t_ColorName% is not Space
                    o_Color:=Color_%t_ColorName%
                }
            }
        else if (InStr(A_LoopField,"s")=1)
            o_Size:=SubStr(A_LoopField,2)
        else if (InStr(A_LoopField,"w")=1)
            o_Weight:=SubStr(A_LoopField,2)
        }

    ;-- If needed, reset Effects options to defaults
    if not p_Flags & CF_EFFECTS
        {
        o_Color    :=0x0    ;-- Black
        o_Strikeout:=False
        o_Underline:=False
        }

    ;-- Convert or fix invalid or unspecified options
    if o_Color is Space
        o_Color:=0x0        ;-- Black
     else
        if o_Color is not xdigit
            o_Color:=0x0    ;-- Black
         else
            ;-- Convert to BRG
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

    ;[==================]
    ;[  Pre-Processing  ]
    ;[==================]
    ;-- Create, initialize, and populate LOGFONT structure
    VarSetCapacity(LOGFONT,28+(TCharSize*LF_FACESIZE),0)
    NumPut(o_Height,   LOGFONT,0,"Int")                 ;-- lfHeight
    NumPut(o_Weight,   LOGFONT,16,"Int")                ;-- lfWeight
    NumPut(o_Italic,   LOGFONT,20,"UChar")              ;-- lfItalic
    NumPut(o_Underline,LOGFONT,21,"UChar")              ;-- lfUnderline
    NumPut(o_Strikeout,LOGFONT,22,"UChar")              ;-- lfStrikeOut

    if StrLen(r_Name)
        DllCall("lstrcpyn" . (A_IsUnicode ? "W":"A")
            ,PtrType,&LOGFONT+28                        ;-- lpString1 [out]
            ,"Str",r_Name                               ;-- lpString2 [in]
            ,"Int",StrLen(r_Name)+1)                    ;-- iMaxLength [in]

    ;-- Create, initialize, and populate CHOOSEFONT structure
    CFSize:=VarSetCapacity(CHOOSEFONT,(A_PtrSize=8) ? 104:60,0)
    NumPut(CFSize,CHOOSEFONT,0,"UInt")
        ;-- lStructSize
    NumPut(hOwner,CHOOSEFONT,(A_PtrSize=8) ? 8:4,PtrType)
        ;-- hwndOwner
    NumPut(&LOGFONT,CHOOSEFONT,(A_PtrSize=8) ? 24:12,PtrType)
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

    ;-- If requested and a handler has been specified, turn on help monitoring
    if (p_Flags & CF_SHOWHELP) and IsFunc(p_HelpHandler)
        {
        ;-- Register the Handler with the OnHelp function
        Dlg_OnHelpMsg("Register",p_HelpHandler,"","")

        ;-- Monitor the message triggered by Help button
        OnMessage(l_HelpMsg:=DllCall("RegisterWindowMessage",PtrType,&HELPMSGSTRING),"Dlg_OnHelpMsg")
        }

    ;[===============]
    ;[  Show dialog  ]
    ;[===============]
    RC:=DllCall("comdlg32\ChooseFont" . (A_IsUnicode ? "W":"A"),PtrType,&CHOOSEFONT)

    ;[===================]
    ;[  Post-Processing  ]
    ;[===================]
    ;-- If enabled, turn off help monitoring
    if l_HelpMsg
        OnMessage(l_HelpMsg,"")  ;-- Turn off monitoring

    ;-- Any errors?
    if (RC=0)
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
    ;-- Extract font typeface name to r_Name
    VarSetCapacity(r_Name,TCharSize*LF_FACESIZE)
    nSize:=DllCall("lstrlen" . (A_IsUnicode ? "W":"A"),PtrType,&LOGFONT+28)
        ;-- Length of string in characters.  Size does NOT includes terminating
        ;   null character.

    DllCall("lstrcpyn" . (A_IsUnicode ? "W":"A")
        ,"Str",r_Name                                   ;-- lpString1 [out]
        ,PtrType,&LOGFONT+28                            ;-- lpString2 [in]
        ,"Int",nSize+1)                                 ;-- iMaxLength [in]

    VarSetCapacity(r_Name,-1)

    ;-- Populate r_Options
    r_Options:=""
    r_Options.="s"
        . NumGet(CHOOSEFONT,(A_PtrSize=8) ? 32:16,"Int")//10
            ;-- iPointSize
        . A_Space

    if p_Flags & CF_EFFECTS
        {
        l_Color:=NumGet(CHOOSEFONT,(A_PtrSize=8) ? 40:24,"UInt")
            ;-- rgbColors

        ;-- Convert to RGB
        l_Color:=((l_Color&0xFF)<<16)+(l_Color&0xFF00)+((l_Color>>16)&0xFF)

        ;-- Append to r_Options in 6-digit hex format
        r_Options.="c" . SubStr(Dlg_Convert2Hex(l_Color,6),3) . A_Space
        }

    l_Weight:=NumGet(LOGFONT,16,"Int")
    if (l_Weight<>FW_NORMAL)
        if (l_Weight=FW_BOLD)
            r_Options.="bold "
         else
            r_Options.="w" . l_Weight . A_Space

    if NumGet(LOGFONT,20,"UChar")
        r_Options.="italic "

    if NumGet(LOGFONT,21,"UChar")
        r_Options.="underline "

    if NumGet(LOGFONT,22,"UChar")
        r_Options.="strike "

    ;-- Remove extraneous trailing space
    r_Options:=SubStr(r_Options,1,-1)

    ;-- Return to sender
    Return True
    }

Dlg_ChooseIcon(hOwner,ByRef r_IconPath,ByRef r_IconIndex) {
    
    ;{ Function: Dlg_ChooseIcon
    ;
    ; Description:
    ;
    ;   Creates a dialog box that allows the user to choose an icon from the
    ;   selection available embedded in a resource such as an executable or DLL
    ;   file.
    ;   (see _Icon.jpg)
    ;
    ; Parameters:
    ;
    ;   hOwner - A handle to the window that owns the dialog box.  This parameter
    ;       can be any valid window handle or it can be set to 0 or null if the
    ;       dialog box has no owner.
    ;
    ;   r_IconPath - Path to the icon resource file. [Input/Output] On input, set
    ;       this variable to desired icon resource file or set to null to use the
    ;       default resource file (usually "SHELL32.dll"),  On output, the full
    ;       path of the selected icon resource file is stored in this variable.  If
    ;       the dialog is canceled, this variable is not updated.
    ;
    ;   r_Index - 1-based index to the icon within the icon resource file.
    ;       [Input/Output].  On input, this variable should contain the 1-based
    ;       index to the icon within the icon resource specified in the r_IconPath
    ;       parameter.  If set to null or 0, the first icon will be selected.
    ;       On output, the variable is set to 1-based index of the icon selected.
    ;       If the dialog is canceled, this variable is not updated.
    ;
    ; Returns:
    ;
    ;   TRUE if successful or FALSE if the user canceled the dialog or if an error
    ;   occurred.
    ;
    ; Requirements:
    ;
    ;   Officially, this function is only supported on Windows XP and Windows Vista.
    ;   Unofficially, this function works on most versions of Windows from Windows
    ;   XP on.  Be sure to test thoroughly.
    ;}

    
    Static Dummy9731
          ,CP_ACP  :=0  ;-- The system default Windows ANSI code page.
          ,MAX_PATH:=260

    ;-- Workaround for AutoHotkey Basic
    PtrType:=(A_PtrSize=8) ? "Ptr":"UInt"

    ;-- Initialize
    VarSetCapacity(wIconPath,MAX_PATH*2,0)
    wIconPath:=r_IconPath       ;-- Working and Unicode copy of r_IconPath
    l_IconIndex:=r_IconIndex-1  ;-- Working copy of r_IconIndex

    ;-- If ANSI, convert r_IconPath to Unicode if needed
    if not A_IsUnicode
        if r_IconPath is not Space
            DllCall("MultiByteToWideChar"
                ,"UInt",CP_ACP
                ,"UInt",0
                ,"Str",r_IconPath
                ,"Int",StrLen(r_IconPath)
                ,"Str",wIconPath
                ,"Int",MAX_PATH)

    ;-- Show dialog
    if not DllCall("Shell32\PickIconDlg"
            ,PtrType,hOwner
                ;-- hwnd
            ,"Str",wIconPath
                ;-- pszIconPath [in,out]
            ,"UInt",MAX_PATH+1
                ;-- cchIconPath.  The number of characters in pszIconPath,
                ;   including the terminating NULL character.
            ,"IntP",l_IconIndex)
                ;-- piIconIndex [in,out,optional]
        Return False  ;-- User canceled

     ;-- Set output variables
    if A_IsUnicode
        r_IconPath:=wIconPath
     else
        {
        ;-- Convert from Unicode to ANSI
        nSize:=DllCall("lstrlenW",PtrType,&wIconPath)
            ;-- Size in characters, not including the terminating null.

        VarSetCapacity(r_IconPath,nSize,0)
        DllCall("WideCharToMultiByte"
            ,"UInt",CP_ACP
            ,"UInt",0
            ,"Str",wIconPath
            ,"Int",nSize
            ,"Str",r_IconPath
            ,"Int",nSize
            ,"UInt",0
            ,"UInt",0)
        }

    r_IconIndex:=l_IconIndex+1
    Return True
    }

Dlg_Convert2Hex(p_Integer,p_MinDigits=0)     {
        
    ;{ Function: Dlg_Convert2Hex
    ;
    ; Description:
    ;
    ;   Converts an integer to hexadecimal format.
    ;
    ; Type:
    ;
    ;   Internal function.  Subject to change.  Do not use.
    ;
    ; Parameters:
    ;
    ;   p_Integer - An integer in any format.
    ;
    ;   p_MinDigits - The minimum number of hexadecimal digits the return value
    ;       should have.  Set to 0 (the default) or 1 to use the smallest number of
    ;       digits needed.  See the *Remarks* section for more information.
    ;
    ; Returns:
    ;
    ;   An integer in hexadecimal format.
    ;
    ; Remarks:
    ;
    ; * This function converts an integer to hexadecimal format without using the
    ;   AutoHotkey
    ;   <SetFormat at http://www.autohotkey.com/docs/commands/SetFormat.htm>
    ;   command.
    ;
    ; * Only integer values that can be stored in a 64-bit signed integer are
    ;   supported.  Numbers smaller than -9223372036854775807 (-0x7FFFFFFFFFFFFFFF)
    ;   or larger than 9223372036854775807 (0x7FFFFFFFFFFFFFFF) will return
    ;   inconsistent results.
    ;
    ; * The p_MinDigits parameter can be used to set the return value to a fixed
    ;   number of hexadecimal digits.  For example, if p_MinDigits is to 0 (the
    ;   default), an integer value of 255 will be returned with the minimum number
    ;   of hexadecimal digits needed to represent this value, i.e. "0xFF".  If
    ;   p_MinDigits is set to 6, the same integer value of 255 will be returned with
    ;   6 hexadecimal digits, i.e. "0x0000FF".
    ;
    ;}
    
    ;-- Workaround for AutoHotkey Basic
    PtrType:=(A_PtrSize=8) ? "Ptr":"UInt"

    ;-- Negative?
    if (p_Integer<0)
        {
        l_NegativeChar:="-"
        p_Integer:=-p_Integer
        }

    ;-- Determine the width (in characters) of the output buffer
    l_Size:=(p_Integer=0) ? 1:Floor(Ln(p_Integer)/Ln(16))+1
    if (p_MinDigits>l_Size)
        l_Size:=p_MinDigits+0

    ;-- Build Format string
    l_Format:="`%0" . l_Size . "I64X"

    ;-- Create and populate l_Argument
    VarSetCapacity(l_Argument,8)
    NumPut(p_Integer,l_Argument,0,"Int64")

    ;-- Convert and format
    VarSetCapacity(l_Buffer,A_IsUnicode ? l_Size*2:l_Size,0)
    DllCall(A_IsUnicode ? "msvcrt\_vsnwprintf":"msvcrt\_vsnprintf"
        ,"Str",l_Buffer             ;-- Storage location for output
        ,"UInt",l_Size              ;-- Maximum number of characters to write
        ,"Str",l_Format             ;-- Format specification
        ,PtrType,&l_Argument)       ;-- Argument

    ;-- Assemble and return the final value
    Return l_NegativeChar . "0x" . l_Buffer
    }

Dlg_FindReplaceText(p_Type,hOwner,p_Flags,p_FindWhat,p_ReplaceWith,p_Handler,p_HelpHandler="") {
    
    ;{ Function: Dlg_FindReplaceText
    ;
    ; Description:
    ;
    ;   Internal function used by <Dlg_FindText> and <Dlg_ReplaceText> to create a
    ;   system-defined modeless Find or Replace dialog box.
    ;
    ; Type:
    ;
    ;   Internal function.  Subject to change.  Do not call directly.
    ;
    ; Parameters:
    ;
    ;   p_Type - [Internal function only] Set to "F" or "Find" to create a Find
    ;       dialog.  Set to "R" or "Replace" to create a Replace dialog.
    ;
    ;   hOwner - A handle to the window that owns the dialog box.  Note: This
    ;       parameter must always contain a valid window handle.  It cannot be set
    ;       to 0 or NULL.  See the *Remarks* section for more information.
    ;
    ;   p_Flags - Creation flags.  See the *Flags* section for the details.
    ;
    ;   p_FindWhat - Default text displayed in the "Find what:" edit field when the
    ;       dialog is displayed.
    ;
    ;   p_ReplaceWith - [Replace dialog only] Default text displayed in the "Replace
    ;       with:" edit field when the dialog is displayed.  This parameter is
    ;       ignored if p_Type is set to "F".
    ;
    ;   p_Handler - Event handler.  See the *Handler* section for more information.
    ;
    ;   p_HelpHandler - Name of a developer-created function that is called when the
    ;       the user presses the Help button on the dialog. [Optional] See the *Help
    ;       Handler* section for the details.  Note: The FR_SHOWHELP flag is
    ;       automatically added if this parameter contains a valid function name.
    ;
    ; Flags:
    ;
    ;   The p_Flags parameter contains flags that are used to initialize the dialog.
    ;   If p_Flags contains an interger value, the parameter is assumed to contain
    ;   bit flags.  See the function's static variables for a list a valid bit
    ;   flags.  Otherwise, the following space-delimited text flags can be used.
    ;
    ;   MatchCase - Match Case option selected.
    ;
    ;   NoMatchCase - Disable (gray out) the Match Case option.
    ;
    ;   HideMatchCase - Hide the Match Case option.
    ;
    ;   Down - [Find dialog only] Down radio button selected in the Direction group.
    ;       If not specified, the "Up" radio button is selected.
    ;
    ;   NoUpDown - [Find dialog only] Disable (gray out) the Up and Down radio
    ;       buttons.
    ;
    ;   HideUpDown - [Find dialog only] Hide the Up and Down radio buttons.
    ;
    ;   ShowHelp - Show Help button.  The p_HelpHandler parameter should contain a
    ;       valid function name.
    ;
    ;   WholeWord - Whole Word option selected.
    ;
    ;   NoWholeWord - Disable (gray out) the Whole Word option.
    ;
    ;   HideWholeWord - Hide the Whole Word option.
    ;
    ; Returns:
    ;
    ;   Handle of the dialog or FALSE if there is an error.
    ;
    ; Calls To Other Functions:
    ;
    ; * <Dlg_OnFindReplaceMsg>
    ; * <Dlg_OnHelpMsg>
    ;
    ; Remarks:
    ;
    ; * The dialog is modeless.  It remains open until the user manually closes the
    ;   dialog (Cancel button, Close button, or Escape key) or until it is closed
    ;   programmatically.
    ;
    ; * [Replace dialog only] The "Direction" group (contains the "Up" and "Down"
    ;   radio buttons) is never shown.  The "Down" direction option is always
    ;   assumed to be selected.  Consequently, the FR_DOWN (0x1) flag is always set
    ;   on the Find Next, Replace, and Replace All events.
    ;
    ; * The dialog must have an owner because the event messages are sent to a
    ;   parent window.  If a parent window is not readily/logically available, any
    ;   window can be used.  Use <Dlg_GetScriptDebugWindow> to use the script's
    ;   debug window.  See the function's documentation for more information.
    ;
    ; * The Find and Replace dialogs share a single interface and respond to a
    ;   single event message.  Therefore, only one dialog (Find or Replace) can be
    ;   open at a time.  To ensure singularity, this function returns FALSE if
    ;   a Find or Replace dialog is already open.
    ;
    ; Handler:
    ;
    ;   The "Handler" is a developer-created function used to process the events
    ;   of the dialog.
    ;
    ;   The handler function must have at least 5 parameters.  Additional parameters
    ;   are allowed but must be optional (defined with a default value).  The
    ;   required parameters are defined/used as follows and in the following order:
    ;
    ;       hDialog - The handle to the Find or Replace dialog.
    ;
    ;       Event - Event code.  This parameter should determine if/how the rest of
    ;           of the parameters should be processed.  The following event codes
    ;           can be sent.
    ;
    ;           (start code)
    ;           Code    Description
    ;           ----    -----------
    ;           C       A request to close the dialog has been submitted.
    ;           F       The "Find Next" button has been pressed.
    ;           R       The "Replace" button has been pressed.
    ;           A       The "Replace All" button has been pressed.
    ;           (end)
    ;
    ;       Flags - A combination of bit flags that indicate which dialog options
    ;           were selected when the event occurred.  The following flags can be
    ;           used.
    ;
    ;           (start code)
    ;           Flag                Description
    ;           ----                -----------
    ;           FR_DOWN (0x1)       Down direction selected.
    ;           FR_WHOLEWORD (0x2)  Whole word option selected.
    ;           FR_MATCHCASE (0x4)  Match case option selected.
    ;           (end)
    ;
    ;       FindWhat -  Current "find what" text.
    ;
    ;       ReplaceWith - Current "replace with" text.
    ;
    ;   The handler is responsible for *all* actions of the dialogs.  See the
    ;   example scripts for a Find/Replace handler example.
    ;
    ;   To avoid interference with the operation of the dialog, the handler should
    ;   either 1) finish quickly or 2) any dialogs displayed via the handler should
    ;   be modal.
    ;
    ;   Note: Unlike the other common dialogs, the Find/Replace dialogs are modeless
    ;   which means that the parent window is still accessible while the
    ;   Find/Replace dialog is showing.  If the handler displays a message box, it
    ;   may be necessary to disable the parent window while the message box is
    ;   displayed _if_ actions by the parent window can causes the the handler to be
    ;   triggered while the message box is displayed.
    ;
    ; Help Handler:
    ;
    ;   The "Help Handler" is an optional developer-created function that is called
    ;   when the user presses the Help button on the dialog.
    ;
    ;   The handler function must have at least 2 parameters.  Additional parameters
    ;   are allowed but must be optional (defined with a default value).  The
    ;   required parameters are defined/used as follows, and in the following order:
    ;
    ;       hDialog - The handle to the dialog window.
    ;
    ;       lpInitStructure - A pointer to the initialization structure for the
    ;           common dialog box. For this handler, the pointer is to a FINDREPLACE
    ;           structure.
    ;
    ;   It's up to the developer to determine what commands are performed in this
    ;   function but displaying some sort of help message/document is what is
    ;   expected.
    ;
    ;   To avoid interference with the operation of the dialog, the handler should
    ;   either 1) finish quickly or 2) any dialogs displayed via the handler should
    ;   be modal.  See the example script for an example.
    ;
    ;}

    Static Dummy3969
          ,HELPMSGSTRING:="commdlg_help"
                ;-- Registered message string for the Help button on common
                ;   dialogs

          ,FINDMSGSTRING:="commdlg_FindReplace"
                ;-- Registered message string for Find/Replace dialog

          ,FINDREPLACE
                ;-- Static FINDREPLACE structure.  Also used by the FindReplace
                ;   message.

          ,s_FindWhat
                ;-- Static buffer for the FindWhat string.  Also used by the
                ;   FindReplace message via the FINDREPLACE structure.

          ,s_ReplaceWith
                ;-- Static buffer for the ReplaceWith string.  Also used by the
                ;   FindReplace message via the FINDREPLACE structure.

          ,s_MaxFRLen:=512
                ;-- Maximum length of the FindWhat and ReplaceWith strings, in
                ;   bytes.

          ;-- FindReplace flags
          ,FR_DOWN         :=0x1
          ,FR_WHOLEWORD    :=0x2
          ,FR_MATCHCASE    :=0x4
          ,FR_SHOWHELP     :=0x80
          ,FR_NOUPDOWN     :=0x400
          ,FR_NOMATCHCASE  :=0x800
          ,FR_NOWHOLEWORD  :=0x1000
          ,FR_HIDEUPDOWN   :=0x4000
          ,FR_HIDEMATCHCASE:=0x8000
          ,FR_HIDEWHOLEWORD:=0x10000

    ;[==================]
    ;[  1st things 1st  ]
    ;[==================]
    ;-- Bounce if dialog is already open
    IfWinExist % "ahk_id " . Dlg_OnFindReplaceMsg("GetDialog","","","")
        {
        outputdebug,
           (ltrim join`s
            Function: %A_ThisFunc% -
            Find or Replace dialog is already open. Request aborted.
           )

        Return False
        }

    ;-- Bounce if handler is blank or invalid
    if not IsFunc(p_Handler)
        {
        outputdebug Function: %A_ThisFunc% - Invalid handler: %p_Hander%
        Return False
        }

    ;[==============]
    ;[  Initialize  ]
    ;[==============]
    ;-- Workarounds for AutoHotkey Basic, x64, and Unicode
    PtrType  :=(A_PtrSize=8) ? "Ptr":"UInt"
    MaxTChars:=(A_IsUnicode ? Floor(s_MaxFRLen/2):s_MaxFRLen)-1

    ;[==============]
    ;[  Parameters  ]
    ;[==============]
    ;-- Type
    p_Type:=SubStr(p_Type,1,1)
    StringUpper p_Type,p_Type
        ;-- Convert to uppercase to simplify processing

    if p_Type not in F,R
        p_Type:="F"

    ;-- Flags
    l_Flags:=0
    if p_Flags is Integer  ;-- Bit flags
        l_Flags|=p_Flags
     else
        ;-- Convert text flags into bit flags
        Loop Parse,p_Flags,%A_Tab%%A_Space%,%A_Tab%%A_Space%
            if A_LoopField is not Space
                if FR_%A_LoopField% is Integer
                    l_Flags|=FR_%A_LoopField%

    if IsFunc(p_HelpHandler)
        l_Flags|=FR_SHOWHELP

    ;[==================]
    ;[  Pre-Processing  ]
    ;[==================]
    ;-- Create, initialize, and populate FINDREPLACE structure
    lStructSize:=VarSetCapacity(FINDREPLACE,(A_PtrSize=8) ? 80:40,0)
    NumPut(lStructSize,FINDREPLACE,0,"UInt")
        ;-- lStructSize
    NumPut(hOwner,FINDREPLACE,(A_PtrSize=8) ? 8:4,PtrType)
        ;-- hwndOwner
    NumPut(l_Flags,FINDREPLACE,(A_PtrSize=8) ? 24:12,"UInt")
        ;-- Flags

    VarSetCapacity(s_FindWhat,s_MaxFRLen,0)
    if StrLen(p_FindWhat)
        s_FindWhat:=SubStr(p_FindWhat,1,MaxTChars)

    NumPut(&s_FindWhat,FINDREPLACE,(A_PtrSize=8) ? 32:16,PtrType)
        ;-- lpstrFindWhat

    if (p_Type="R")
        {
        VarSetCapacity(s_ReplaceWith,s_MaxFRLen,0)
        if StrLen(p_ReplaceWith)
            s_ReplaceWith:=SubStr(p_ReplaceWith,1,MaxTChars)

        NumPut(&s_ReplaceWith,FINDREPLACE,(A_PtrSize=8) ? 40:20,PtrType)
            ;-- lpstrReplaceWith
        }

    NumPut(s_MaxFRLen,FINDREPLACE,(A_PtrSize=8) ? 48:24,"UShort")
        ;-- wFindWhatLen

    if (p_Type="R")
        NumPut(s_MaxFRLen,FINDREPLACE,(A_PtrSize=8) ? 50:26,"UShort")
            ;-- wReplaceWithLen

    ;-- Register the Handler with the OnFindReplace function
    Dlg_OnFindReplaceMsg("RegisterHandler",p_Handler,"","")

    ;-- Monitor the FindReplace message triggered by the dialog
    OnMessage(DllCall("RegisterWindowMessage","Str",FINDMSGSTRING),"Dlg_OnFindReplaceMsg")

    ;-- If requested and a handler has been specified, turn on help monitoring
    if (l_FLags & FR_SHOWHELP) and IsFunc(p_HelpHandler)
        {
        ;-- Register the Handler with the OnHelp function
        Dlg_OnHelpMsg("Register",p_HelpHandler,"","")

        ;-- Monitor the help message triggered by Help button
        OnMessage(l_HelpMsg:=DllCall("RegisterWindowMessage",PtrType,&HELPMSGSTRING),"Dlg_OnHelpMsg")
        }

    ;[===============]
    ;[  Show dialog  ]
    ;[===============]
    if (p_Type="F")
        hDialog:=DllCall("comdlg32\FindText" . (A_IsUnicode ? "W":"A"),PtrType,&FINDREPLACE)
     else
        hDialog:=DllCall("comdlg32\ReplaceText" . (A_IsUnicode ? "W":"A"),PtrType,&FINDREPLACE)

    ;-- Register the dialog handle with the OnFindReplace function
    Dlg_OnFindReplaceMsg("RegisterDialog",hDialog,"","")

    ;-- Return dialog handle
    Return hDialog
    }

Dlg_FindText(hOwner,p_Flags,p_FindWhat,p_Handler,p_HelpHandler="") {
    
    ;{  Function: Dlg_FindText
    ;
    ; Description:
    ;
    ;   Creates a system-defined modeless Find dialog box that lets the user
    ;   specify a string to search for and options to use when searching for text
    ;   in a document or control.
    ;   (see _Find.jpg)
    ;
    ; Documentation:
    ;
    ;   All of the documentation for this function is included in the
    ;   <Dlg_FindReplaceText> function.
    ;}
    
    Return Dlg_FindReplaceText("F",hOwner,p_Flags,p_FindWhat,"",p_Handler,p_HelpHandler)
    }

Dlg_GetScriptDebugWindow() {
    
    ;{  Function: Dlg_GetScriptDebugWindow
    ;
    ; Description:
    ;
    ;   Returns the handle to the script's built-in debug window.
    ;
    ; Type:
    ;
    ;   Helper function.
    ;
    ; Remarks:
    ;
    ;   Every AutoHotkey script creates a debug window that is used to display
    ;   script variables, key history, etc.  This window can be assigned as the
    ;   parent window of a dialog in the rare instance when a parent window does not
    ;   exist and a parent window is required (Ex: event monitoring).  Since the
    ;   debug window is not destroyed until the script is terminated, there is no
    ;   danger that a dialog will be prematurely destroyed.
    ;}
    
    Static hScriptDebugWindow

    ;-- Return saved value if already found
    if hScriptDebugWindow
        Return hScriptDebugWindow

    ;-- Use system variable if available (AutoHotkey v1.1.1+)
    if A_ScriptHwnd
        {
        hScriptDebugWindow:=A_ScriptHwnd
        Return hScriptDebugWindow
        }

    ;-- Initialize
    l_DetectHiddenWindows:=A_DetectHiddenWindows
    DetectHiddenWindows On

    ;-- Get the process ID for the current (this) script
    ;   Note: The process ID is returned in ErrorLevel
    Process Exist

    ;-- Generate a list of windows attached to the PID and find the one
    ;   generated by AHK for this script.  Note: This method ensures that only
    ;   the built-in AutoHotkey window is identified.
    ;
    WinGet l_Instance,List,ahk_pid %ErrorLevel%
    Loop %l_Instance%
        {
        hScriptDebugWindow:=l_Instance%A_Index%
        WinGetTitle l_WinTitle,% "ahk_id " . hScriptDebugWindow
        if (Instr(l_WinTitle,A_ScriptFullPath)=1)
            Break
        }

    ;-- Reset DetectHiddenWindows
    DetectHiddenWindows %l_DetectHiddenWindows%

    ;-- Return to sender
    Return hScriptDebugWindow
    }

Dlg_MessageBox(hOwner=0,p_Type=0,p_Title="",p_Text="",p_Timeout=-1,p_HelpHandler="") {
    
    ;{  Function: Dlg_MessageBox
    ;
    ; Description:
    ;
    ;   Displays a modal dialog box that contains a system icon, a set of buttons,
    ;   and a brief application-specific message, such as status or error
    ;   information.
    ;   (see _MessageBox.jpg)
    ;
    ; Parameters:
    ;
    ;   hOwner - A handle to the window that owns the dialog box.  This parameter
    ;       can be any valid window handle or it can be set to 0 or null if the
    ;       dialog box has no owner.  Note: A valid window handle must be specified
    ;       if the MB_HELP flag is included (explicitly or implicitly).
    ;
    ;   p_Type - A combination of bit flags that determine the format and behavior
    ;       of the dialog.  See the function's static variables for a list of
    ;       possible flag values.
    ;
    ;   p_Title - The title of the message box window.  If omitted or blank, the
    ;       title is set to the name of the script (without the path).
    ;
    ;   p_Text - The message to be displayed.  If desired, the message can be
    ;       broken into multiple lines by including the newline (LF) escape
    ;       sequence.  Ex: First line`nSecond line`nThird line.
    ;
    ;   p_Timeout - The amount of time, in milliseconds, the dialog will wait before
    ;       automatically closing.  Set to -1 (the default) for no timeout.
    ;
    ;   p_HelpHandler - Name of a developer-created function that is called when the
    ;       the user presses the Help button on the dialog. [Optional] See the *Help
    ;       Handler* section for the details.  Note: The MB_HELP flag is
    ;       automatically added if this parameter contains a valid function name.
    ;
    ; Returns:
    ;
    ;   An integer value that is set based upon what button is pressed or what
    ;   action has occurred.  See the function's static variables for a list of
    ;   possible return values.  See the *Remarks* section for some exceptions.
    ;
    ; Calls To Other Functions:
    ;
    ; * <Dlg_OnHelpMsg>
    ;
    ; Remarks:
    ;
    ; * If a message box has a Cancel button, IDCANCEL (2) is returned if either the
    ;   Escape key is pressed or the Cancel button is pressed.  If the message box
    ;   has no Cancel button, pressing Escape has no effect.
    ;
    ; * When a message box with only an OK button (MB_OK flag) is used (the Help
    ;   button doesn't count in this case), IDOK (1) is returned from the MessageBox
    ;   API in all circumstances -- OK button pressed, Escape key, dialog window
    ;   closed, _and_ timeout.
    ;
    ; * When more than one message box dialog is displayed at a time, the requests
    ;   are processed in LIFO (last in, first out) order.  The dialogs can be closed
    ;   in any order, but the request for a particular dialog will not return until
    ;   _all_ requests that followed it are processed.  For example, if 3 message
    ;   box dialogs are showing at the same time (assume that the 1st dialog was
    ;   displayed first, the 2nd was displayed next, and so on...), the 2nd dialog
    ;   will not return until the 3rd dialog is closed.  Using the same logic, the
    ;   1st dialog will not return until the other 2 dialogs are closed.  This rule
    ;   applies to all message box dialogs per process, regardless if they are
    ;   displayed via this function, the AutoHotkey *MsgBox* command, or by calling
    ;   the "MessageBox" API directly.
    ;
    ; * Help, Part 1: Unlike other common dialogs, the message box dialog sends the
    ;   standard WM_HELP message when the user hits the F1 key or presses the Help
    ;   button while a message box dialog is showing.  If the script is monitoring
    ;   this message for other reasons, this function will temporarily override this
    ;   monitoring if the MB_HELP flag is specified _and_ a valid function has been
    ;   specified in the p_HelpHandler parameter.  Once the dialog has been
    ;   processed, WM_HELP monitoring is restored to what is was before.
    ;
    ; * Help, Part 2: If this function is monitoring the WM_HELP message (the
    ;   MB_HELP flag is specified and the p_HelpHandler parameter contains a valid
    ;   function name) _and_ more than one message box dialog with a Help button is
    ;   showing (assuming the same conditions), the help handler attached to the
    ;   message box that was displayed last determines what will happen if the Help
    ;   button is pressed.  When the message box that was displayed last is closed,
    ;   control is given to the dialog that was displayed next to last, and so on...
    ;
    ; * Help, Part 3: If your script is already monitoring the WM_HELP message for a
    ;   message box dialog, it is not necessary to convert the WM_HELP related code
    ;   into a help handler function just to use this function.  Simply specify the
    ;   MB_HELP flag but do not specify a function name in the p_HelpHandler
    ;   parameter.  When the message box is displayed, any requests for help will
    ;   continue to be processed by your script.
    ;
    ; Help Handler:
    ;
    ;   The "Help Handler" is an optional developer-created function that is called
    ;   when the user hits the F1 key or presses the Help button on the dialog.
    ;
    ;   The handler function must have at least 2 parameters.  Additional parameters
    ;   are allowed but must be optional (defined with a default value).  The
    ;   required parameters are defined/used as follows, and in the following order:
    ;
    ;       hDialog - The handle to the dialog window.
    ;
    ;       lpInitStructure - A pointer to the initialization structure for the
    ;           common dialog box. For this handler, the pointer is to a HELPINFO
    ;           structure which contains context-sensitive help information.
    ;
    ;   It's up to the developer to determine what commands are performed in this
    ;   function but displaying some sort of help message/document is what is
    ;   expected.
    ;
    ;   The handler is triggered by the WM_HELP message.  Processing is not
    ;   completed until the handler has finished processing.  The handler should
    ;   either 1) finish quickly or 2) any dialogs displayed via the handler should
    ;   be modal.  See the example script for an example.
    ;}    
    
    Static Dummy8158

          ;-- Message Box buttons
          ,MB_OK                  :=0x0
          ,MB_OKCANCEL            :=0x1
          ,MB_ABORTRETRYIGNORE    :=0x2
          ,MB_YESNOCANCEL         :=0x3
          ,MB_YESNO               :=0x4
          ,MB_RETRYCANCEL         :=0x5
          ,MB_CANCELTRYCONTINUE   :=0x6
          ,MB_HELP                :=0x4000

          ;-- Message Box icons
          ,MB_ICONHAND            :=0x10
          ,MB_ICONERROR           :=0x10                ;-- Alias of MB_ICONHAND
          ,MB_ICONSTOP            :=0x10                ;-- Alias of MB_ICONHAND
          ,MB_ICONQUESTION        :=0x20
          ,MB_ICONEXCLAMATION     :=0x30
          ,MB_ICONWARNING         :=0x30                ;-- Alias of MB_ICONEXCLAMATION
          ,MB_ICONASTERISK        :=0x40
          ,MB_ICONINFORMATION     :=0x40                ;-- Alias of MB_ICONASTERISK
          ,MB_ICONMASK            :=0xF0

          ;-- Message Box default button
          ,MB_DEFBUTTON1          :=0x0
          ,MB_DEFBUTTON2          :=0x100
          ,MB_DEFBUTTON3          :=0x200
          ,MB_DEFBUTTON4          :=0x300

          ;-- Message Box modality
          ,MB_APPLMODAL           :=0x0
          ,MB_SYSTEMMODAL         :=0x1000
          ,MB_TASKMODAL           :=0x2000

          ;-- Message Box - Misc options
          ,MB_SETFOREGROUND       :=0x10000
          ,MB_DEFAULT_DESKTOP_ONLY:=0x20000
          ,MB_TOPMOST             :=0x40000
          ,MB_RIGHT               :=0x80000
          ,MB_RTLREADING          :=0x100000
          ,MB_SERVICE_NOTIFICATION:=0x200000
                ;-- Only used by a service

          ;-- Message Box return values
          ,IDOK      :=1
          ,IDCANCEL  :=2
          ,IDABORT   :=3
          ,IDRETRY   :=4
          ,IDIGNORE  :=5
          ,IDYES     :=6
          ,IDNO      :=7
          ,IDTRYAGAIN:=10
          ,IDCONTINUE:=11
          ,IDTIMEOUT :=32000

          ;-- Messages
          ,WM_HELP:=0x53

    ;-- Parameters
    if not hOwner  ;-- Blank, null, or zero
        hOWner:=0
     else
        ;-- Check handle.  MessageBox function will fail if an invalid handle is
        ;   specified.
        if not ("IsWindow",(A_PtrSize=8) ? "Ptr":"UInt",hOwner)
            {
            outputdebug,
               (ltrim join`s
                Function: %A_ThisFunc% -
                Window for owner handle not found: %hOwner%. Handle set to 0
                (no handle).
               )

            hOwner:=0
            }

    if p_Type is not Integer
        p_Type:=0

;;;;;    p_Type|=MB_SETFOREGROUND  ;-- ##### Added by default

    if IsFunc(p_HelpHandler)
        p_Type|=MB_HELP

    if p_Title is Space
        {
        p_Title:=A_ScriptName
            ;-- Same default as AHK MsgBox

        if p_Text is Space
            p_Text:="Press OK to continue."
                ;-- Same default as AHK MsgBox
        }

    if p_Timeout is not Integer
        p_Timeout:=-1

    ;-- If requested and a handler has been specified, turn on help monitoring
    if (p_Type & MB_HELP) and IsFunc(p_HelpHandler)
        {
        ;-- Get the function that is currently attached to WM_HELP, if any
        l_PreviousHelpMonitor:=OnMessage(WM_HELP)

        ;-- Get the function that is current registered with Dlg_OnHelpMsg,
        ;   if any
        l_PreviousHelpHandler:=Dlg_OnHelpMsg("Get","","","")

        ;-- Register the current Help Handler with the OnHelp function
        Dlg_OnHelpMsg("Register",p_HelpHandler,"","")

        ;-- Monitor the WM_HELP message
        l_Monitor_WM_HELP:=True
        OnMessage(WM_HELP,"Dlg_OnHelpMsg")
        }

    ;-- Show dialog
    RC:=DllCall("MessageBoxTimeout"
        ,(A_PtrSize=8) ? "Ptr":"UInt",hOwner            ;-- hWnd
        ,"Str",p_Text                                   ;-- lpText
        ,"Str",p_Title                                  ;-- lpCaption
        ,"UInt",p_Type                                  ;-- uType
        ,"UShort",0                                     ;-- wLanguageId
        ,"Int",p_Timeout)                               ;-- dwMilliseconds

    ;-- Error?
    if (RC=0 or ErrorLevel)
        {
        outputdebug,
           (ltrim join`s
            Function: %A_ThisFunc% -
            Error returned from MessageBoxTimeout API function.
            ErrorLevel=%ErrorLevel%, A_LastError=%A_LastError%
           )

        ;-- Note: Continue processing, i.e. don't return here, just in case
        ;   help monitoring was enabled.
        }

    ;-- If needed, turn off or reset monitoring of WM_HELP message
    if l_Monitor_WM_HELP
        {
        OnMessage(WM_HELP,l_PreviousHelpMonitor)
            ;-- This request will either turn off monitoring of WM_HELP
            ;   (l_PreviousHelpMonitor is null) or it will return monitoring
            ;   back to the original function.

        ;-- Register the previous help handler (can be blank/null)
        Dlg_OnHelpMsg("Register",l_PreviousHelpHandler,"","")
        }

    Return RC
    }

Dlg_OFNHookCallback(hDlg,uiMsg,wParam,lParam)  {
    
    ;{ Function: Dlg_OFNHookCallback
    ;
    ; Description:
    ;
    ;   Receives and processes notification messages from the Open or Save dialog.
    ;
    ; Type:
    ;
    ;   Internal use only.  Do not use.
    ;
    ; Parameters:
    ;
    ;   hDlg - When processing notifications triggered by the dialog, this parameter
    ;       contains the handle to the child dialog box of the Open or Save dialog.
    ;       When processing an internal request, this parameter contains the request
    ;       command.  Valid values are "GetReadOnly" and "SetReadOnly".
    ;
    ;   uiMsg - When processing notifications triggered by dialog, this parameter
    ;       contains the identifier of the message being received. When processing
    ;       the "SetReadOnly" internal request, this parameter contains the value
    ;       (True or False) to set the "ReadOnly" variable.
    ;
    ;   wParam - When processing notifications triggered by the dialog, this
    ;       parameter contains additional information about the message.  The exact
    ;       meaning depends on the value of the uiMsg parameter.  When processing an
    ;       internal request, this parameter is null.
    ;
    ;   lParam - When processing notifications triggered by the dialog, this
    ;       parameter contains additional information about the message.  The exact
    ;       meaning depends on the value of the uiMsg parameter.  If the uiMsg
    ;       parameter indicates the WM_INITDIALOG message, lParam is a pointer to an
    ;       OPENFILENAME structure containing the values specified when the dialog
    ;       box was created.  When processing an internal request, this parameter is
    ;       null.
    ;
    ; Returns:
    ;
    ;   In it's current form, this function always returns 0 which indicates that
    ;   the default dialog box procedure processes the message.
    ;
    ; Remarks:
    ;
    ;   This function was written to work around a bug in Windows XP (may also occur
    ;   in other OS versions).  The bug: The wrong value for the "Read Only"
    ;   checkbox is sometimes returned if multiple files are selected.  The
    ;   workaround is to read directly from the "Read Only" checkbox object at the
    ;   time the user presses the "Open" or "Save" button.  The value of the
    ;   checkbox (True or False) is stored in a static variable and is retrieved by
    ;   the main function after the dialog is closed.
    ;}
    
    
    Static Dummy0581
          ,s_ReadOnly:=False

          ;-- Common dialog notification codes
          ,CDN_FIRST  :=-601
          ,CDN_FILEOK :=-606  ;-- CDN_First - 0x5

          ;-- Messages
          ,WM_NOTIFY  :=0x4E

    ;-- Workaround for AutoHotkey Basic
    PtrType:=(A_PtrSize=8) ? "Ptr":"UInt"

    ;-- Internal requests
    if lParam is Space
        {
        if (hDlg="GetReadOnly")
            Return s_ReadOnly

        if (hDlg="SetReadOnly")
            {
            s_ReadOnly:=uiMsg
            Return
            }

        ;-- Fail-safe
        return
        }

    ;-- WM_NOTIFY messages only (for now)
    if (uiMsg=WM_NOTIFY)
        {
        ;-- CDN_FILEOK notifications only (for now)
        if (NumGet(lParam+0,(A_PtrSize=8) ? 16:8,"Int")=CDN_FILEOK)
            {
            ;-- Set ReadOnly variable from the current status of the ReadOnly
            ;   checkbox on the dialog
            ControlGet
                ,s_ReadOnly
                ,Checked
                ,
                ,Button1
                ,% "ahk_id " . DllCall("GetParent",PtrType,hDlg)
            }
        }

    Return 0  ;-- The default dialog box procedure processes the message
    }

Dlg_OnFindReplaceMsg(wParam,lParam,Msg,hWnd) {
    
    ;{ Function: Dlg_OnFindReplaceMsg
    ;
    ; Description:
    ;
    ;   Processes the FINDMSGSTRING message from the dialogs created by
    ;   <Dlg_FindText> and <Dlg_ReplaceText>.
    ;
    ; Type:
    ;
    ;   Internal use only.  Do not use.
    ;
    ; Parameters:
    ;
    ;   wParam - When triggered by the FINDMSGSTRING message, this parameter
    ;       contains the handle to the dialog.  When processing an internal request,
    ;       this parameter contains the request command.  Valid commands are
    ;       "GetDialog", "GetHandler", "RegisterDialog", and "RegisterHandler".
    ;
    ;   lParam - When triggered by the FINDMSGSTRING message, this parameter
    ;       contains a pointer to a FINDREPLACE structure.  When processing an
    ;       internal request, the value of this parameter depends on the request
    ;       command. For the "RegisterDialog" command, this parameter contains the
    ;       dialog handle.  For the "RegisterHandler" command, this parameter
    ;       contains the handler function name.  For all other request commands,
    ;       this parameter is null.
    ;
    ;   Msg - When triggered by the FINDMSGSTRING message, this parameter will
    ;       contain the FINDMSGSTRING message.  When processing an internal request,
    ;       this parameter is null.
    ;
    ;   hWnd - When triggered by the FINDMSGSTRING message, this parameter contains
    ;       the parent window that was sent the message.  When processing an
    ;       internal request, this parameter is null.
    ;
    ; Returns:
    ;
    ;   When triggered by the FINDMSGSTRING message, the return value of the handler
    ;   is returned but this value is not currently evaluated.  When processing an
    ;   internal request, the return value depends on the request command.  For the
    ;   "GetDialog" command, the current dialog handle is returned.  For the
    ;   "GetHandler" command, the current handler function name is returned.  For
    ;   all other request command, nothing (null) is returned.
    ;
    ; Calls To Other Functions:
    ;
    ; * Developer-created handler
    ;
    ; Note to Developers:
    ;
    ;   There has been a design change from the original Dlg library.  In the past,
    ;   hidden options were also assumed to be unselected.  With the introduction of
    ;   flags to disable (gray out) options, this assumption is no longer logical.
    ;   The design has changed so that the selection status of an option will
    ;   generate the appropriate event flag regardless of whether the option is
    ;   hidden or disabled.  See the *Remarks* section of <Dlg_FindReplaceText> for
    ;   an exception with Replace dialog.
    ;}
    
    
    Static Dummy5289
          ,s_Handler
                ;-- Contains the name of the developer-created function that is
                ;   called when a Find/Replace event occurs.

          ,s_hDialog
                ;-- Contains the handle to the Find or Replace dialog.  This
                ;   value is sent as one of the parameters of the Handler
                ;   function.  It is also use to determine whether a Find or
                ;   Replace dialog is still open.

          ,HELPMSGSTRING:="commdlg_help"
                ;-- Registered message string for the Help button on common
                ;   dialogs

          ;-- FindReplace flags
          ,FR_DOWN         :=0x1
          ,FR_WHOLEWORD    :=0x2
          ,FR_MATCHCASE    :=0x4
          ,FR_FINDNEXT     :=0x8
          ,FR_REPLACE      :=0x10
          ,FR_REPLACEALL   :=0x20
          ,FR_DIALOGTERM   :=0x40
          ,FR_SHOWHELP     :=0x80
          ,FR_NOUPDOWN     :=0x400
          ,FR_NOMATCHCASE  :=0x800
          ,FR_NOWHOLEWORD  :=0x1000
          ,FR_HIDEUPDOWN   :=0x4000
          ,FR_HIDEMATCHCASE:=0x8000
          ,FR_HIDEWHOLEWORD:=0x10000

    ;-- Internal requests
    if hWnd is Space
        {
        if (wParam="GetDialog")
            Return s_hDialog

        if (wParam="GetHandler")
            Return s_Handler

        if (wParam="RegisterDialog")
            {
            s_hDialog:=lParam
            return
            }

        if (wParam="RegisterHandler")
            {
            s_Handler:=lParam
            return
            }

        ;-- Fail-safe
        return
        }

    ;-- Workaround for AutoHotkey Basic
    PtrType:=(A_PtrSize=8) ? "Ptr":"UInt"

    ;-- Collect flags from the FINDREPLACE structure
    l_Flags:=NumGet(lParam+0,(A_PtrSize=8) ? 24:12,"UInt")
        ;-- Flags

    ;-- Canceled?
    if (l_Flags & FR_DIALOGTERM)
        {
        ;-- If needed, turn off help monitoring
        if l_Flags & FR_SHOWHELP
            OnMessage(l_HelpMsg:=DllCall("RegisterWindowMessage",PtrType,&HELPMSGSTRING),"")

        ;-- Turn off monitoring
        OnMessage(Msg,"")

        ;-- Return to sender
        Return %s_Handler%(s_hDialog,"C","","","")
        }

    ;-- Build l_EventFlags
    l_EventFlags:=l_Flags & (FR_DOWN|FR_WHOLEWORD|FR_MATCHCASE)

    ;-- Collect FindWhat string (used in all events)
    lpstrFindWhat:=NumGet(lParam+0,(A_PtrSize=8) ? 32:16,PtrType)
        ;-- Address to the FindWhat string

    wFindWhatLen:=NumGet(lParam+0,(A_PtrSize=8) ? 48:24,"UShort")

    ;-- Copy FindWhat string (byte for byte) to local variable
    VarSetCapacity(l_FindWhat,wFindWhatLen,0)
    DllCall("RtlMoveMemory",PtrType,&l_FindWhat,PtrType,lpstrFindWhat,"UInt",wFindWhatLen)
    VarSetCapacity(l_FindWhat,-1)
        ;-- Update the internal length

    ;-- "Find Next" button
    if l_Flags & FR_FINDNEXT
        Return %s_Handler%(s_hDialog,"F",l_EventFlags,l_FindWhat,"")

    ;--------------------
    ; From this point on, the user pressed the "Replace" or "Replace All"
    ; button on the Replace dialog.
    ;--------------------

    ;-- Identify event
    l_Event:=(l_Flags & FR_REPLACEALL) ? "A":"R"

    ;-- Collect ReplaceWith string
    lpstrReplaceWith:=NumGet(lParam+0,(A_PtrSize=8) ? 40:20,PtrType)
        ;-- Address to the ReplaceWith string

    wReplaceWithLen:=NumGet(lParam+0,(A_PtrSize=8) ? 50:26,"UShort")

    ;-- Copy ReplaceWith string (byte for byte) to local variable
    VarSetCapacity(l_ReplaceWith,wReplaceWithLen,0)
    DllCall("RtlMoveMemory",PtrType,&l_ReplaceWith,PtrType,lpstrReplaceWith,"UInt",wReplaceWithLen)
    VarSetCapacity(l_ReplaceWith,-1)
        ;-- Update the internal length

    ;-- Call handler
    Return %s_Handler%(s_hDialog,l_Event,l_EventFlags,l_FindWhat,l_ReplaceWith)
    }

Dlg_OnHelpMsg(wParam,lParam,Msg,hWnd)  {
    
    ;{ Function: Dlg_OnHelpMsg
    ;
    ; Description:
    ;
    ;   Processes the HELPMSGSTRING or WM_HELP (message box dialog only) messages
    ;   from common dialogs when the Help button is pressed.
    ;
    ; Type:
    ;
    ;   Internal use only.  Do not use.
    ;
    ; Parameters:
    ;
    ;   wParam - When processing an internal request, this parameter contains the
    ;       command name.  Valid values are "Register" and "Get".  When triggered by
    ;       the help message, this parameter contains the handle to the common
    ;       dialog.  Exception: When triggered by the WM_HELP (message box dialog),
    ;       the parameter is not used (set to 0).
    ;
    ;   lParam - When processing an internal request, this parameter is used to pass
    ;       additional information.  For the "Register" command, this parameter
    ;       contains the name of a valid AutoHotkey function.  When triggered by the
    ;       help message, this parameter contains a pointer to the initialization
    ;       structure for the common dialog box.  This structure can be a
    ;       CHOOSECOLOR, CHOOSEFONT, FINDREPLACE, or OPENFILENAME structure.  For
    ;       the message box dialog, this parameter contains a pointer to a HELPINFO
    ;       structure which contains context-sensitive help information.
    ;
    ;   Msg - When processing an internal request, this parameter is null.  When
    ;       triggered by the help message, this parameter will contain the help
    ;       message.  For the message box dialog, this value will be WM_HELP.
    ;
    ;   hWnd - When processing an internal request, this parameter is null.  When
    ;       triggered by the help message, this parameter will contain the parent
    ;       window that was sent the message.
    ;
    ; Returns:
    ;
    ;   The return value depends on how the function is called.  When processing an
    ;   internal "Get" request, the currently registered help handler function name
    ;   is returned.  When triggered by the help message, the return value from
    ;   the help handler is returned (not used at this time).
    ;
    ; Calls To Other Functions:
    ;
    ; * Developer-created help handler
    ;}

    
    Static Dummy4412
          ,s_Handler

          ;-- HELPINFO flags
          ,HELPINFO_WINDOW   :=0x1
          ,HELPINFO_MENUITEM :=0x2

          ;-- Messages
          ,WM_HELP:=0x53

;;;;;          ,CDN_FIRST:=-601
;;;;;          ,CDN_HELP :=-605  ;-- CDN_FIRST - 0x4

;;;;;    outputdebug Function: %A_ThisFunc% - wParam=%wParam%, lParam=%lParam%, Msg=%Msg%, hWnd=%hWnd%

    ;-- Internal requests
    if hWnd is Space
        {
        if wParam in Get,GetHandler
            Return s_Handler

        if wParam in Register,RegisterHandler
            {
            s_Handler:=lParam
            Return
            }

        ;-- Fail-safe
        return
        }

    ;-- Workaround for AutoHotkey Basic
    PtrType:=(A_PtrSize=8) ? "Ptr":"UInt"

    ;-- Call help handler
    if (Msg=WM_HELP)  ;-- From the message box dialog
        {
        hItemHandle:=NumGet(lParam+0,(A_PtrSize=8) ? 16:12,PtrType)
        Return %s_Handler%(hItemHandle,lParam)
        }

    if wParam
        Return %s_Handler%(wParam,lParam)
     else
        {
        ;-- Workaround for a Vista+ bug that occurs when pressing the help
        ;   button from the Open/Save dialog.
        WinGet hDialog,ID,A
        Return %s_Handler%(hDialog,lParam)
        }
    }

Dlg_OpenFile(hOwner=0,p_Title="",p_Filter="",p_FilterIndex="",p_Root="",p_DfltExt="",ByRef r_Flags=0,p_HelpHandler="") {
    
    ;{ Function: Dlg_OpenFile
    ;
    ; Description:
    ;
    ;   Creates an Open dialog box that lets the user specify the drive, directory,
    ;   and the name of a file or set of files to be opened.
    ;   (see _Open.jpg)
    ;
    ; Documentation:
    ;
    ;   All of the documentation for this function is included in the
    ;   <Dlg_OpenSaveFile> function.
    ;}    
    
    Return Dlg_OpenSaveFile("O",hOwner,p_Title,p_Filter,p_FilterIndex,p_Root,p_DfltExt,r_Flags,p_HelpHandler)
}

Dlg_OpenSaveFile(p_Type,hOwner=0,p_Title="",p_Filter="",p_FilterIndex="",p_Root="",p_DfltExt="",ByRef r_Flags=0,p_HelpHandler="")  {
    
    ;{ Function: Dlg_OpenSaveFile
    ;
    ; Description:
    ;
    ;   Internal function used by <Dlg_OpenFile> and <Dlg_SaveFile> to create an
    ;   Open or Save dialog.
    ;
    ; Type:
    ;
    ;   Internal function.  Subject to change.  Do not call directly.
    ;
    ; Parameters:
    ;
    ;   p_Type - [Internal function only] Set to "O" or "Open" to create a Open
    ;       dialog.  Set to "S" or "Save" to create a Save dialog.
    ;
    ;   hOwner - A handle to the window that owns the dialog box.  This parameter
    ;       can be any valid window handle or it can be set to 0 or null if the
    ;       dialog box has no owner.  Note: A valid window handle must be specified
    ;       if the OFN_SHOWHELP flags is included (explicitly or implicitly).
    ;
    ;   p_Title - A string to be placed in the title bar of the dialog box.  If set
    ;       to null (the default), the system uses the default title (that is,
    ;       "Open" or "Save As").
    ;
    ;   p_Filter - One or more filter strings that determine which files are
    ;       displayed. [Optional] Each filter string is composed of two parts.
    ;       The first part describes the filter.  For example: "Text Files".  The
    ;       second part specifies the filter pattern and must be enclosed in
    ;       parenthesis.  For example "(*.txt)".  To specify multiple filter
    ;       patterns for a single display string, use a semicolon to separate the
    ;       patterns.  For example: "(*.txt;*.doc;*.bak)".  A pattern string can be
    ;       a combination of valid file name characters and the asterisk ("*")
    ;       wildcard character.  Do not include spaces in the pattern string.
    ;       Multiple filter strings are delimited by the "|" character.  For
    ;       example: "Text Files (*.txt)|Backup Files (*.bak)".
    ;
    ;   p_FilterIndex - 1-based filter index.  If set to null (the default), 1 is
    ;       used.  The index determines which filter string is pre-selected in the
    ;       "File Types" control.
    ;
    ;   p_Root - Root (startup) directory and/or default file name.  To specify a
    ;       root directory only, include the full path of the directory with a
    ;       trailing "\" character.  Ex: "C:\Program Files\".  To specify a startup
    ;       directory and a default file, include the full path of the default file.
    ;       Ex: "C:\My Stuff\My Program.html".  To specify a default file only,
    ;       include the file name without the path.  Ex: "My Program.html".  If a
    ;       default file name is included, the file name (sans the path) is shown in
    ;       the dialog's "File name:" edit field. If this parameter is set to null
    ;       (the default), the startup directory will be set using the OS default
    ;       for this dialog.  See the documentation for the OPENFILENAME structure
    ;       (lpstrInitialDir member) for more information.
    ;
    ;   p_DfltExt - Extension to append when none is given.  Ex: "txt".  The string
    ;       should not contain a period (".").  If this parameter is null (the
    ;       default) and the user fails to type an extension, no extension is
    ;       appended.
    ;
    ;   r_Flags - Flags used to initialize the dialog. [Optional, Input/Output] See
    ;       the *Flags* section for the details.
    ;
    ;   p_HelpHandler - Name of a developer-created function that is called when the
    ;       the user presses the Help button on the dialog. [Optional] See the *Help
    ;       Handler* section for the details.  Note: The OFN_SHOWHELP flag is
    ;       automatically added if this parameter contains a valid function name.
    ;
    ; Flags:
    ;
    ;   On input, the r_Flags parameter contains flags that are used to initialize
    ;   and/or determine the behavior of the dialog.  If set to 0 or null and
    ;   p_Type="O" (Open dialog), the OFN_FILEMUSTEXIST and OFN_HIDEREADONLY flags
    ;   are added automatically.  If r_Flag contains an interger value, the
    ;   parameter is assumed to contain bit flags.  See the function's static
    ;   variables for a list a valid bit flags.  Otherwise, text flags are assumed.
    ;   The following space-delimited text flags can be used.
    ;
    ;   AllowMultiSelect - Specifies that the File Name list box allows multiple
    ;       selections.
    ;
    ;   CreatePrompt - [Open dialog only] If the user specifies a file that does not
    ;       exist, this flag causes the dialog to prompt the user for permission to
    ;       create the file.
    ;
    ;   DontAddToRecent - Prevents the system from adding a link to the selected
    ;       file in the file system directory that contains the user's most recently
    ;       used documents.
    ;
    ;   Ex_NoPlacesBar - If specified, the places bar is not displayed.  If not
    ;       specified, Explorer-style dialog boxes include a places bar containing
    ;       icons for commonly-used folders, such as Favorites and Desktop.
    ;
    ;   FileMustExist - [Open dialog only (with implicit exceptions)] This flag
    ;       ensures that the user can only type names of existing files in the File
    ;       Name entry.  A message box is generated if an invalid file is entered.
    ;       Opinion: This flag should be specified in most circumstances.
    ;       IMPORTANT: If this flag is specified (explicitly or implicitly), the
    ;       PathMustExist flag is also used.  See the PathMustExist flag for the
    ;       rules that are enforced for both the Open and Save dialogs.
    ;
    ;   ForceShowHidden - Forces the showing of system and hidden files, thus
    ;       overriding the user setting to show or not show hidden files.  However,
    ;       a file that is marked both system and hidden is not shown.  Observation:
    ;       This flag does not work as expected on Windows XP (may also occur on
    ;       other (or all) versions of Windows).  When a directory that includes a
    ;       hidden file is first displayed (including the initial directory), hidden
    ;       files are not shown.  Clicking on the "Open" or "Save" button without
    ;       selecting a file will redisplay the list of files to include the hidden
    ;       file(s).
    ;
    ;   HideReadOnly - [Open dialog only] Hides the Read Only check box.  This flag
    ;       should be specified in most circumstances.
    ;
    ;   NoChangeDir - Restores the current directory to its original value if the
    ;       user changed the directory while searching for files.
    ;
    ;   NoDereferenceLinks - Directs the dialog box to return the path and file name
    ;       of the selected shortcut (.LNK) file.  If this value is not specified,
    ;       the dialog box returns the path and file name of the file referenced by
    ;       the shortcut.  Observation: For shortcuts to OS files, this works as
    ;       expected.  However, for other types of shortcuts, Ex: shortcuts to a web
    ;       site, the return value may not be what is expected.  Test thoroughly
    ;       before using.
    ;
    ;   NoReadOnlyReturn - [Save dialog only] Prevents the dialog from returning
    ;       names of existing files that have the read-only attribute.  If a
    ;       read-only file is selected, a message dialog is generated.  The dialog
    ;       will persist until the selection does not include a file with read-only
    ;       attribute.
    ;
    ;   NoTestFileCreate - By default, the dialog box creates a zero-length test
    ;       file to determine whether a new file can be created in the selected
    ;       directory.  Set this flag to prevent the creation of this test file.
    ;       This flag should be specified if the application saves the file on a
    ;       network drive with Create but no Modify privileges.
    ;       ##### Review.
    ;       ##### Not tested.  Need to create multiple accounts with limited
    ;       permissions in order to test.  Need to figure out how to test this
    ;       before releasing.
    ;       ##### Probably for the Save dialog only but since it wasn't tested...
    ;
    ;   NoValidate - Specifies that the common dialog boxes allow invalid characters
    ;       in the returned file name.
    ;
    ;   OverwritePrompt - [Save dialog only] Causes the dialog to generate a message
    ;       box if the selected file already exists.  The user must confirm whether
    ;       to overwrite the file.
    ;
    ;   PathMustExist - Specifies that the user can type only existing paths in the
    ;       File Name entry.  A message box is generated if an invalid path is
    ;       entered.  Note: This flag is automatically added if the FileMustExist
    ;       flag is used.
    ;
    ;   ReadOnly - [Open dialog only] Causes the Read Only check box to be selected
    ;       initially when the dialog box is created.
    ;
    ;   ShowHelp - Causes the dialog to display the Help button.
    ;
    ;   On output, the r_Flag parameter may contain bit flags that inform the
    ;   developer of conditions of the dialog at the time the dialog was closed.
    ;   The following bit flags can be set.
    ;
    ;   OFN_READONLY (0x1) - [Open dialog only] This flag is set if the Read Only
    ;       check box was checked when the dialog was closed.
    ;
    ;   OFN_EXTENSIONDIFFERENT (0x400) - This flag is set if the p_DfltExt parameter
    ;       is not null and the user selected or typed a file name extension that
    ;       differs from the p_DfltExt parameter.  Exception: This flag is not set
    ;       if multiple files are selected.
    ;
    ; Returns:
    ;
    ;   Selected file name(s) or null if cancelled.  If more then one file is
    ;   selected, each file is delimited by a new line ("`n") character.
    ;
    ; Calls To Other Functions:
    ;
    ; * <Dlg_OFNHookCallback>
    ; * <Dlg_OnHelpMsg>
    ;
    ; Remarks:
    ;
    ;   If the user changes the directory while using the Open or Save dialog, the
    ;   script's working directory will also be changed.  If desired, use the
    ;   "NoChangeDir" flag (r_Flags parameter) to prevent this from occurring or use
    ;   the *SetWorkingDir* command to restore the working directory after calling
    ;   this function.
    ;
    ; Help Handler:
    ;
    ;   The "Help Handler" is an optional developer-created function that is called
    ;   when the user presses the Help button on the dialog.
    ;
    ;   The handler function must have at least 2 parameters.  Additional parameters
    ;   are allowed but must be optional (defined with a default value).  The
    ;   required parameters are defined/used as follows, and in the following order:
    ;
    ;       hDialog - The handle to the dialog window.
    ;
    ;       lpInitStructure - A pointer to the initialization structure for the
    ;           common dialog box. For this handler, the pointer is to a
    ;           OPENFILENAME structure.
    ;
    ;   It's up to the developer to determine what commands are performed in this
    ;   function but displaying some sort of help message/document is what is
    ;   expected.
    ;
    ;   To avoid interference with the operation of the dialog, the handler should
    ;   either 1) finish quickly or 2) any dialogs displayed via the handler should
    ;   be modal.  See the scripts included with this project for an example.
    ;}

    Static Dummy1696
          ,s_strFileMaxSize:=32768
                ;-- This is the ANSI byte limit.  For consistency, this value
                ;   is also used to set the Unicode limit.

          ,HELPMSGSTRING:="commdlg_help"
                ;-- Registered message string for the Help button on common
                ;   dialogs

          ,OPENFILENAME
                ;-- Static OPENFILENAME structure.  Also used by the hook
                ;   callback and the help message.

          ;-- Open File Name flags
          ;-- ##### In alphabetical order, for now. Because of the large number
          ;   flags, it may make sense to keep it in this order.
          ,OFN_ALLOWMULTISELECT    :=0x200
          ,OFN_CREATEPROMPT        :=0x2000
          ,OFN_DONTADDTORECENT     :=0x2000000
          ,OFN_ENABLEHOOK          :=0x20

;;;;;          ,OFN_ENABLEINCLUDENOTIFY :=0x400000
;;;;;          ,OFN_ENABLESIZING        :=0x800000
;;;;;          ,OFN_ENABLETEMPLATE      :=0x40
;;;;;          ,OFN_ENABLETEMPLATEHANDLE:=0x80

          ,OFN_EXPLORER            :=0x80000
                ;-- This flag is set by default.  This function does not work
                ;   with the old-style dialog box.

          ,OFN_EXTENSIONDIFFERENT  :=0x400
                ;-- Output flag only.

          ,OFN_FILEMUSTEXIST       :=0x1000
          ,OFN_FORCESHOWHIDDEN     :=0x10000000
          ,OFN_HIDEREADONLY        :=0x4

;;;;;          ,OFN_LONGNAMES           :=0x200000
;;;;;                ;-- Only used on old-style dialogs

          ,OFN_NOCHANGEDIR         :=0x8
          ,OFN_NODEREFERENCELINKS  :=0x100000
;;;;;          ,OFN_NOLONGNAMES         :=0x40000
;;;;;                ;-- Only used on old-style dialogs
;;;;;
;;;;;          ,OFN_NONETWORKBUTTON     :=0x20000
;;;;;                ;-- The "Network" button is only shown on the old-style dialog
;;;;;                ;   box.

          ,OFN_NOREADONLYRETURN    :=0x8000
          ,OFN_NOTESTFILECREATE    :=0x10000
          ,OFN_NOVALIDATE          :=0x100
          ,OFN_OVERWRITEPROMPT     :=0x2
          ,OFN_PATHMUSTEXIST       :=0x800
          ,OFN_READONLY            :=0x1

;;;;;          ,OFN_SHAREAWARE          :=0x4000
;;;;;                ;-- Not implemented.  Not really useful unless using a hook
;;;;;                ;   procedure
;;;;;
;;;;;          ,OFN_SHAREFALLTHROUGH    :=2
;;;;;          ,OFN_SHARENOWARN         :=1
;;;;;          ,OFN_SHAREWARN           :=0
;;;;;                ;-- The 3 preceeding flags are used in conjunction with the
;;;;;                ;   OFN_SHAREAWARE flag.  They are not flags.  They are return
;;;;;                ;   values that can been sent to the hook procedure.

          ,OFN_SHOWHELP            :=0x10
;;;;;          ,OFN_USEMONIKERS         :=0x1000000
;;;;;                ;-- Not documented in the OPENFILENAME structure documentation.
;;;;;                ;   Requires the use the IMoniker COM interface.  Overkill for
;;;;;                ;   this library.  Not used.

          ;-- Open File Name extended flags
          ,OFN_EX_NOPLACESBAR      :=0x1
                ;-- Note: This flag is only available as a text flag, i.e.
                ;   "NoPlacesBar".

    ;[==============]
    ;[  Initialize  ]
    ;[==============]
    ;-- Shortcuts/Workarounds for AutoHotkey Basic and Unicode
    PtrType  :=(A_PtrSize=8) ? "Ptr":"UInt"
    TCharSize:=A_IsUnicode ? 2:1

    ;[==============]
    ;[  Parameters  ]
    ;[==============]
    ;-- Type
    p_Type:=SubStr(p_Type,1,1)
    StringUpper p_Type,p_Type
        ;-- Convert to uppercase to simplify processing

    if p_Type not in O,S
        p_Type:="O"

    ;-- Filter
    if p_Filter is Space
        p_Filter:="All Files (*.*)"

;;;;;    ;-- Flags
;;;;;    if r_Flags is Space  ;-- Only possible for the Open dialog  ##### This is not TRUE anymore.
;;;;;        r_Flags:="FileMustExist HideReadOnly"

;;;;;    ;-- Extract standard and extended flags from r_Flags
;;;;;    l_Flags  :=OFN_EXPLORER
;;;;;    l_FlagsEx:=0
;;;;;    Loop Parse,r_Flags,%A_Tab%%A_Space%,%A_Tab%%A_Space%
;;;;;        if A_LoopField is not Space
;;;;;            if OFN_%A_LoopField% is Integer
;;;;;                if InStr(A_LoopField,"ex_")
;;;;;                    l_FlagsEx|=OFN_%A_LoopField%
;;;;;                 else
;;;;;                    l_Flags|=OFN_%A_LoopField%

    ;-- Flags
    l_Flags  :=OFN_EXPLORER
    l_FlagsEx:=0
    if not r_Flags  ;-- Zero, blank, or null
        {
        if (p_Type="O")  ;-- Open dialog only
            l_Flags|=OFN_FILEMUSTEXIST|OFN_HIDEREADONLY
        }
     else
        ;-- Bit flags
        if r_Flags is Integer
            l_Flags|=r_Flags
         else
            ;-- Convert text flags into bit flags
            Loop Parse,r_Flags,%A_Tab%%A_Space%,%A_Tab%%A_Space%
                if A_LoopField is not Space
                    if OFN_%A_LoopField% is Integer
                        if InStr(A_LoopField,"ex_")
                            l_FlagsEx|=OFN_%A_LoopField%
                         else
                            l_Flags|=OFN_%A_LoopField%

    if IsFunc(p_HelpHandler)
        l_Flags|=OFN_SHOWHELP

    if (p_Type="O") and (l_Flags & OFN_ALLOWMULTISELECT)
        l_Flags|=OFN_ENABLEHOOK

    ;-- Create and, if needed, populate the buffer used to initialize the
    ;   File Name edit control.  The dialog will also use this buffer to return
    ;   the file(s) selected.
    VarSetCapacity(strFile,s_strFileMaxSize*TCharSize,0)
    SplitPath p_Root,l_RootFileName,l_RootDir
    if l_RootFileName is not Space
        DllCall("RtlMoveMemory"
            ,"Str",strFile
            ,"Str",l_RootFileName
            ,"UInt",(StrLen(l_RootFileName)+1)*TCharSize)

    ;-- Convert p_Filter into the format required by the API
    VarSetCapacity(strFilter,StrLen(p_Filter)*(A_IsUnicode ? 5:3),0)
        ;-- Enough space for the full description _and_ file pattern(s) of all
        ;   filter strings (ANSI and Unicode) plus null characters between all
        ;   of the pieces and a double null at the end.

    l_Offset:=&strFilter
    Loop Parse,p_Filter,|
        {
        ;-- Break the filter string into 2 parts
        l_LoopField=%A_LoopField%  ;-- Assign and AutoTrim
        l_Part1:=l_LoopField
            ;-- Part 1: The entire filter string which includes the description
            ;   and the file pattern(s) in parenthesis.  This is what is
            ;   displayed in  the "File Of Types" or the "Save As Type"
            ;   drop-down.

        l_Part2:=SubStr(l_LoopField,InStr(l_LoopField,"(")+1,-1)
            ;-- Part 2: File pattern(s) sans parenthesis.  The dialog uses this
            ;   to filter the files that are displayed.

        ;-- Calculate the length of the pieces
        l_lenPart1:=(StrLen(l_LoopField)+1)*TCharSize
            ;-- Size includes terminating null

        l_lenPart2:=(StrLen(l_Part2)+1)*TCharSize
            ;-- Size includes terminating null

        ;-- Copy the pieces to the filter string.  Each piece includes a
        ;   terminating null character.
        DllCall("RtlMoveMemory",PtrType,l_Offset,"Str",l_Part1,"UInt",l_lenPart1)
        DllCall("RtlMoveMemory",PtrType,l_Offset+l_lenPart1,"Str",l_Part2,"UInt",l_lenPart2)                          ;-- Length

        ;-- Calculate the offset of the next filter string
        l_Offset+=l_lenPart1+l_lenPart2
        }

    ;[==================]
    ;[  Pre-Processing  ]
    ;[==================]
    ;-- Create and populate the OPENFILENAME structure
    lStructSize:=VarSetCapacity(OPENFILENAME,(A_PtrSize=8) ? 152:88,0)
    NumPut(lStructSize,OPENFILENAME,0,"UInt")
        ;-- lStructSize
    NumPut(hOwner,OPENFILENAME,(A_PtrSize=8) ? 8:4,PtrType)
        ;-- hwndOwner
    NumPut(&strFilter,OPENFILENAME,(A_PtrSize=8) ? 24:12,PtrType)
        ;-- lpstrFilter
    NumPut(p_FilterIndex,OPENFILENAME,(A_PtrSize=8) ? 44:24,"UInt")
        ;-- nFilterIndex
    NumPut(&strFile,OPENFILENAME,(A_PtrSize=8) ? 48:28,PtrType)
        ;-- lpstrFile
    NumPut(s_strFileMaxSize,OPENFILENAME,(A_PtrSize=8) ? 56:32,"UInt")
        ;-- nMaxFile
    NumPut(&l_RootDir,OPENFILENAME,(A_PtrSize=8) ? 80:44,PtrType)
        ;-- lpstrInitialDir
    NumPut(&p_Title,OPENFILENAME,(A_PtrSize=8) ? 88:48,PtrType)
        ;-- lpstrTitle
    NumPut(l_Flags,OPENFILENAME,(A_PtrSize=8) ? 96:52,"UInt")
        ;-- Flags
    NumPut(&p_DfltExt,OPENFILENAME,(A_PtrSize=8) ? 104:60,PtrType)
        ;-- lpstrDefExt
    NumPut(l_FlagsEx,OPENFILENAME,(A_PtrSize=8) ? 148:84,"UInt")
        ;-- FlagsEx

    ;-- If needed, register hook
    if (p_Type="O") and (l_Flags & OFN_ALLOWMULTISELECT)
        {
        hookCallbackAddress:=RegisterCallback("Dlg_OFNHookCallback","Fast")
        NumPut(hookCallbackAddress,OPENFILENAME,(A_PtrSize=8) ? 120:68,PtrType)
            ;-- lpfnHook
        }

    ;-- If requested and a handler has been specified, turn on help monitoring
    if (l_Flags & OFN_SHOWHELP) and IsFunc(p_HelpHandler)
        {
        ;-- Register the Handler with the OnHelp function
        Dlg_OnHelpMsg("Register",p_HelpHandler,"","")

        ;-- Monitor the help message triggered by Help button
        OnMessage(l_HelpMsg:=DllCall("RegisterWindowMessage",PtrType,&HELPMSGSTRING),"Dlg_OnHelpMsg")
        }

    ;[===============]
    ;[  Show dialog  ]
    ;[===============]
    if (p_type="O")
        RC:=DllCall("comdlg32\GetOpenFileName" . (A_IsUnicode ? "W":"A"),PtrType,&OPENFILENAME)
     else
        RC:=DllCall("comdlg32\GetSaveFileName" . (A_IsUnicode ? "W":"A"),PtrType,&OPENFILENAME)

    ;-- If needed, free global memory allocated by RegisterCallback
    if hookCallbackAddress
        DllCall("GlobalFree",PtrType,hookCallbackAddress)

    ;[===================]
    ;[  Post-Processing  ]
    ;[===================]
    ;-- If needed, turn off monitoring of help message
    if l_HelpMsg
        OnMessage(l_HelpMsg,"")  ;-- Turn off monitoring

    ;-- Dialog canceled?
    if (RC=0)
        Return

    ;-- Rebuild r_Flags for output
    r_Flags  :=0
    l_Flags:=NumGet(OPENFILENAME,(A_PtrSize=8) ? 96:52,"UInt")
        ;-- Flags

    if p_DfltExt is not Space  ;-- Flag is ignored unless p_DfltExt contains a value
        if l_Flags & OFN_EXTENSIONDIFFERENT
            r_Flags|=OFN_EXTENSIONDIFFERENT

    if (p_Type="O")  ;-- i.e. flag is ignored if using the Save dialog
        if l_Flags & OFN_ALLOWMULTISELECT
            {
            ;-- Hook was used to collect ReadOnly status.  Collect the ReadOnly
            ;   status from the hook function.
            if Dlg_OFNHookCallback("GetReadOnly","","","")
                r_Flags|=OFN_READONLY
            }
         else
            ;-- Hook was NOT used to collect ReadOnly status.  Determine status
            ;   from l_Flags
            if l_Flags & OFN_READONLY
                r_Flags|=OFN_READONLY

    ;-- Extract file(s) from the buffer
    l_FileList:=""
    l_Offset  :=&strFile
    Loop
        {
        ;-- Get the size (length) of the next file
        if not nSize:=DllCall("lstrlen" . (A_IsUnicode ? "W":"A"),PtrType,l_Offset)
            {
            ;-- If end-of-list occurs on the 2nd iteration, it means that only
            ;   one file was selected
            if (A_Index=2)
                l_FileList:=l_FileName

            ;-- We're done
            Break
            }

        ;-- Copy the file name to a local variable
        VarSetCapacity(l_FileName,nSize*TCharSize,0)
        DllCall("lstrcpyn" . (A_IsUnicode ? "W":"A")
            ,"Str",l_FileName                           ;-- lpString1 [out]
            ,PtrType,l_Offset                           ;-- lpString2 [in]
            ,"Int",nSize+1)                             ;-- iMaxLength [in]

        ;-- Update the offset for next iteration
        l_Offset+=(StrLen(l_FileName)+1)*TCharSize

        ;-- If this is the first iteration, we have to wait until the next loop
        ;   before we can determine if this is a directory or file and if a
        ;   file, if it is the only file selected.
        if (A_Index=1)
            {
            l_Dir:=l_FileName
            if (StrLen(l_Dir)<>3)   ;-- Windows adds \ when in root of the drive and doesn't do that otherwise
                l_Dir.="\"

            ;-- Continue to next
            Continue
            }

        ;-- Add the file to the list
        l_FileList.=(StrLen(l_FileList) ? "`n":"") . l_Dir . l_FileName
        }

    ;-- Return to sender
    Return l_FileList
    }

Dlg_ReplaceText(hOwner,p_Flags,p_FindWhat,p_ReplaceWith,p_Handler,p_HelpHandler="") {
    
    ;{ Function: Dlg_ReplaceText
    ;
    ; Description:
    ;
    ;   Creates a system-defined modeless dialog box that lets the user specify a
    ;   string to search for and a replacement string, as well as options to control
    ;   the find and replace operations.
    ;   (see _Replace.jpg)
    ;
    ; Documentation:
    ;
    ;   All of the documentation for this function is included in the
    ;   <Dlg_FindReplaceText> function.
    ;
    ;}
    
    Return Dlg_FindReplaceText("R",hOwner,p_Flags,p_FindWhat,p_ReplaceWith,p_Handler,p_HelpHandler)
    }

Dlg_SaveFile(hOwner=0,p_Title="",p_Filter="",p_FilterIndex="",p_Root="",p_DfltExt="",ByRef r_Flags=0,p_HelpHandler="") {
    
    ;{ Function: Dlg_SaveFile
    ;
    ; Description:
    ;
    ;   Creates a Save dialog box that lets the user specify the drive, directory,
    ;   and name of a file to save.
    ;   (see _Save.jpg)
    ;
    ; Documentation:
    ;
    ;   All of the documentation for this function is included in the
    ;   <Dlg_OpenSaveFile> function.
    ;
    ;}
    
    Return Dlg_OpenSaveFile("S",hOwner,p_Title,p_Filter,p_FilterIndex,p_Root,p_DfltExt,r_Flags,p_HelpHandler)
    }
