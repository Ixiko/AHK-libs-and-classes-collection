/*
Title: Font Library v0.4 (Preview)

Group: Introduction

    Fonts are logical objects that instruct the computer how to draw text on a
    device (display, printers, plotters, etc.).  This mini-library provides a
    means of managing some of the aspects of fonts used in AutoHotkey.

Group: Compatibility:

    This library was designed to run on all versions of AutoHotkey (Basic and
    v1.1+ (32 and 64-bit)) and Windows XP and greater.

Group: Links

    Font and Text Reference (Windows)
    - <http://msdn.microsoft.com/en-us/library/windows/desktop/dd144824(v=vs.85).aspx>

Group: Credit

 *  Some of the code in this library and in the example scripts was extracted
    from the AutoHotkey source.  Thanks to authors of *AutoHotkey*.

 *  The <Fnt_ChooseFont> function was adapted from the Dlg library which was
    published *majkinetor*.

 *  The <Fnt_GetListOfFonts> function was inspired by an example published by
    *Sean*.

Group: Functions
*/

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
;       can be any valid window handle, or it can be set to 0 or NULL if the
;       dialog box has no owner.
;
;   r_Name - Typeface name. [Input/Output] On input, this variable can contain
;       contain the default typeface name.  On output, this variable will
;       contain the selected typeface name.
;
;   r_Options - Font options. [Input/Output] On input, this variable can contain
;       the default font options.  On output, this variable will contain the
;       the selected options.  The following options (in alphabetical order) are
;       available:
;
;       (start code)
;       Option
;       ------
;               Description
;               -----------
;       bold
;               On input, this option will pre-select the "bold" font style.
;               On output, this option will be returned if a bold font was
;               selected.
;
;       c{Color}
;
;               Text color.  "{Color}" is a 6-digit hex RGB color value.
;               Example value: FF00FA.  On input, this option will attempt to
;               pre-select the text color.  On output, this option is returned
;               with the selected text color.
;
;               Exception 1: The color Black (000000) is the default text color.
;               On input, Black is pre-selected if this option is not defined.
;
;               Exception 2: If p_Effects is FALSE, this option is ignored on
;               input and is not returned.
;
;       italic
;               On input, this option will pre-select the "italic" font style.
;               On output, this option will be returned if an italic font was
;               selected.  Exception: If p_Effects is FALSE, this option is
;               ignored on input and is not returned.
;
;       s{size in points}
;
;               Font size (in points).  For example: s12.  On input, this option
;               will load the font size and if on the font-size list, will
;               pre-select the font size.  On output, the font size that was
;               entered/selected is returned.
;
;       SizeMax{Maximum point size}
;
;               [Input only]
;               The maximum point size the user can enter/select.  For example:
;               SizeMax72.  If this option is specified without also specifying
;               the SizeMin option, the SizeMin value is automatically set to 1.
;
;       SizeMin{Minimum point size}
;
;               [Input only]
;               The minimum point size the user can enter/select. For example:
;               SizeMin10.  If this option is specified without also specifying
;               the SizeMax option, the SizeMax value is automatically set to
;               0xBFFF (49151).
;
;       strike
;
;               On input, this option will check the "Strikeout" option.  On
;               output, this option will be returned if the "Strikeout" option
;               was checked.  Exception: If p_Effects is FALSE, this option is
;               ignored on input and is not returned.
;
;       underline
;
;               On input, this option will check the "Underline" option.  On
;               output, this option will be returned if the "Underline" option
;               was checked.  Exception: If p_Effects is FALSE, this option is
;               ignored on input and is not returned.
;
;       w{font weight}
;
;               [Input only]
;               Font weight (thickness or boldness), which is an integer between
;               1 and 1000 (400 is normal and 700 is bold).  If the font weight
;               is set to a value greater than or equal to 700, this option
;               will pre-select the "bold" font style.
;
;       To specify more than one option, include a space between each.  For
;       example: s12 cFF0000 bold.  On output, the selected options are defined
;       in the same format.
;       (end)
;
;   p_Effects - If set to TRUE (the default), the dialog box will display the
;       controls that allow the user to specify strikeout, underline, and
;       text color options.
;
;   p_Flags - [Advanced Feature] Additional ChooseFont flags. [Optional]  The
;       default is 0 (no additional flags).  See the *Remarks* section for more
;       information.
;
; Returns:
;
;   TRUE if a font was selected, otherwise FALSE is returned if the dialog was
;   canceled or if an error occurred.
;
; Remarks:
;
; * The Font dialog box supports the selection of text color.  Please note that
;   text color is an attribute of many common controls but it is not a font
;   attribute.
;
; * If a font size of blank/null or zero (0) is entered in the Font Size combo
;   box, the ChooseFont API will return the default font size for the specified
;   font.  Observation: The default font size is 10 for most (but not all)
;   fonts.
;
; * The SizeMin and SizeMax options (p_Options parameter) not only affect the
;   list of fonts sizes that are shown in the Font Size selection list box in
;   the Font dialog box, they affect the font size that can be manually entered
;   in the Font Size combo box.  If a font size that is outside the boundaries
;   set by the SizeMin and SizeMax options, an MsgBox dialog is shown and the'
;   user is not allowed to continue until a valid font size is entered/selected.
;   Warning: If the value of the SizeMin option is greater than the SizeMax
;   option, the "ChooseFont" API function will generate a CFERR_MAXLESSTHANMIN
;   error and will return without showing the Font dialog box.
;
; * Flexibility in the operation of the Font dialog box is available via a large
;   number of ChooseFont flags.  For this function, the flags are determined by
;   constants, options in the p_Options parameter, and the value of the
;   p_Effects parameter.  Although the flags set by these conditions will handle
;   the needs of the majority of developers, there are a few ChooseFont flags
;   that could provide additional value.  The p_Flags parameter is used to _add_
;   additional ChooseFont flags to control the operation of the Font dialog box.
;   See the function's static variables for a list of possible flag values.
;   Warning: This is an advanced feature.  Including invalid or conflicting
;   flags may produce unexpected results.  Be sure to test thouroughly.
;
;-------------------------------------------------------------------------------
Fnt_ChooseFont(hOwner=0,ByRef r_Name="",ByRef r_Options="",p_Effects=True,p_Flags=0)
    {
    Static Dummy3155

          ;-- ChooseFont flags
          ,CF_SCREENFONTS:=0x1
                ;-- List only the screen fonts supported by the system.  This
                ;   flag is automatically set.

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
                ;   added if the SizeMin and/or the SizeMax options (p_Options
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

    ;--------------
    ;-- Initialize
    ;--------------
    PtrType  :=(A_PtrSize=8) ? "Ptr":"UInt"
    PtrSize  :=A_PtrSize ? A_PtrSize:4
    TCharSize:=A_IsUnicode ? 2:1

    hDC:=DllCall("CreateDC","Str","DISPLAY",PtrType,0,PtrType,0,PtrType,0)
    l_LogPixelsY:=DllCall("GetDeviceCaps",PtrType,hDC,"Int",LOGPIXELSY)
    DllCall("DeleteDC",PtrType,hDC)

    ;--------------
    ;-- Parameters
    ;--------------
    r_Name=%r_Name%     ;-- AutoTrim

    ;-- p_Flags
    if p_Flags is not Integer
        p_Flags:=0x0

    p_Flags|=CF_SCREENFONTS|CF_INITTOLOGFONTSTRUCT
    if p_Effects
        p_Flags|=CF_EFFECTS

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
        else if (InStr(A_LoopField,"c")=1)
            o_Color:="0x" . SubStr(A_LoopField,2)
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
        o_Height:=-DllCall("MulDiv","Int",o_Size,"Int",l_LogPixelsY,"Int",72)

    ;-- Update flags
    if o_SizeMin or o_SizeMax
        p_Flags|=CF_LIMITSIZE

    ;-----------------------
    ;-- Populate structures
    ;-----------------------
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
    CFSize:=(A_PtrSize=8) ? 104:60
    VarSetCapacity(CHOOSEFONT,CFSize,0)
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

    ;---------------
    ;-- Choose font
    ;---------------
    if not DllCall("comdlg32\ChooseFont" . (A_IsUnicode ? "W":"A"),PtrType,&CHOOSEFONT)
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
        . Abs(DllCall("MulDiv"
            ,"Int",Abs(NumGet(LOGFONT,0,"Int"))         ;-- Height
            ,"Int",72
            ,"Int",l_LogPixelsY))
        . A_Space

    if p_Flags & CF_EFFECTS
        {
        l_Color:=NumGet(CHOOSEFONT,(A_PtrSize=8) ? 40:24,"UInt")
            ;-- rgbColors

        ;-- Convert to RGB in Hex format
        t_FormatInteger:=A_FormatInteger 
        SetFormat Integer,Hex
        l_Color:=((l_Color&0xFF)<<16)+(l_Color&0xFF00)+((l_Color>>16)&0xFF)
        SetFormat Integer,%t_FormatInteger% 

        ;-- Append to r_Options. Zero-pad if needed
        r_Options.="c" . SubStr("00000" . SubStr(l_Color,3),-5) . A_Space
        }

    if (NumGet(LOGFONT,16,"Int")=FW_BOLD)
        r_Options.="bold "

    if NumGet(LOGFONT,20,"UChar")
        r_Options.="italic "
   
    if NumGet(LOGFONT,21,"UChar")
        r_Options.="underline "

    if NumGet(LOGFONT,22,"UChar")
        r_Options.="strike "

    r_Options:=SubStr(r_Options,1,-1)

    ;-- Return to sender
    Return True
    }


;------------------------------
;
; Function: Fnt_CreateFont
;
; Description:
;
;   Creates a logical font with the specified characteristics.
;
; Parameters:
;
;   p_Name - Typeface name of the font. [Optional]  If blank, the default GUI
;       font name is used.
;
;   p_Options - Font options. [Optional] The following options (in alphabetical
;   order) are available:
;
;       (start code)
;       Option
;       ------
;               Description
;               -----------
;       bold
;               Set the font weight to bold (700).
;
;       italic
;               Create an italic font.
;
;       s{size in points}
;
;               Font size (in points).  For example: s12
;
;       strike
;               Create a strikeout font.
;
;       underline
;
;               Create an underlined font.
;
;       w{font weight}
;
;               Font weight (thickness or boldness), which is an integer between
;               1 and 1000 (400 is normal and 700 is bold).  For example: w600
;
;       To specify more than one option, include a space between each.  For
;       example: s12 bold
;       (end)
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
          ,LOGPIXELSY         :=90

          ;-- Misc. font constants
          ,CLIP_DEFAULT_PRECIS:=0
          ,DEFAULT_CHARSET    :=1
          ,FF_DONTCARE        :=0
          ,FW_NORMAL          :=400
          ,FW_BOLD            :=700
          ,OUT_TT_PRECIS      :=4
          ,PROOF_QUALITY      :=2

    ;-- Intialize
    PtrType:=(A_PtrSize=8) ? "Ptr":"Uint"

    ;-- Parameters
    p_Name=%p_Name%         ;-- AutoTrim

    ;-- Initialize options
    o_Italic   :=False
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
        else if (InStr(A_LoopField,"s")=1)
            o_Size:=SubStr(A_LoopField,2)
        else if (InStr(A_LoopField,"w")=1)
            o_Weight:=SubStr(A_LoopField,2)
        }

    ;-- Fix invalid or unspecified parameters/options
    if p_Name is Space
        p_Name:=Fnt_GetFontName()   ;-- Typeface name of default GUI font

    if o_Size is not Integer
        o_Size:=Fnt_GetFontSize()   ;-- Font size of default GUI font

    if o_Weight is not Integer
        o_Weight:=FW_NORMAL

    ;-- Convert point size to height, in logical units
    hDC:=DllCall("CreateDC","Str","DISPLAY",PtrType,0,PtrType,0,PtrType,0)
    o_Height:=-DllCall("MulDiv"
        ,"Int",o_Size
        ,"Int",DllCall("GetDeviceCaps",PtrType,hDC,"Int",LOGPIXELSY)
        ,"Int",72)

    DllCall("DeleteDC",PtrType,hDC)

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
        ,"UInt",PROOF_QUALITY                           ;-- fdwQuality
        ,"UInt",FF_DONTCARE                             ;-- fdwPitchAndFamily
        ,"Str",p_Name)                                  ;-- lpszFace

    Return hFont
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
    if hFont  ;-- Not 0 or null
        Return DllCall("DeleteObject",(A_PtrSize=8) ? "Ptr":"UInt",hFont) ? True:False

    Return True
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
;   lParam - The application-defined data passed by the EnumFontFamiliesEx
;       function. Not used at this time.
;
; Returns:
;
;   True.
;
; Remarks:
;
; * This function uses a global variable (Fnt_EnumFontFamExProc_List) to build
;   the list of typeface names.  Since this function is called many times for
;   every request, the typeface name is always appended to this variable.  Be
;   sure to set the Fnt_EnumFontFamExProc_List variable to null before every
;   request.
;
;-------------------------------------------------------------------------------
Fnt_EnumFontFamExProc(lpelfe,lpntme,FontType,lParam)
    {
    Global Fnt_EnumFontFamExProc_List

    Static Dummy6247

          ;-- Font types
          ,RASTER_FONTTYPE  :=0x1
          ,DEVICE_FONTTYPE  :=0x2
          ,TRUETYPE_FONTTYPE:=0x4

          ;-- LOGFONT constants
          ,LF_FACESIZE      :=32
          ,LF_FULLFACESIZE  :=64

    ;-- Initialize
    PtrType:=(A_PtrSize=8) ? "Ptr":"UInt"
    TCharSize:=A_IsUnicode ? 2:1

    ;-- Typeface name
    lpThis:=lpelfe+28
    nSize:=DllCall("lstrlen" . (A_IsUnicode ? "W":"A"),"UInt",lpThis)
    VarSetCapacity(l_FaceName,nSize*TCharSize,0)
    DllCall("lstrcpyn" . (A_IsUnicode ? "W":"A")
        ,"Str",l_FaceName
        ,PtrType,lpThis
        ,"Int",nSize+1)

    VarSetCapacity(l_FaceName,-1)

    ;-- Append typeface name to the list
    Fnt_EnumFontFamExProc_List.=(StrLen(Fnt_EnumFontFamExProc_List) ? "`n":"") . l_FaceName
    Return True  ;-- Continue enumeration
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
; Returns:
;
;   The default GUI margins in "X,Y" format.
;
; Calls To Other Functions:
;
; * <Fnt_GetFontSize>
;
; Remarks:
;
;   AutoHotkey documentation for GUI margins...
;   <http://www.autohotkey.com/docs/commands/Gui.htm#Margin>
;
;-------------------------------------------------------------------------------
Fnt_GetDefaultGUIMargins(hFont=0,ByRef r_MarginX="",ByRef r_MarginY="")
    {
    ;-- Get font size
    l_PointSize:=Fnt_GetFontSize(hFont)

    ;-- Calculate default margins
    r_MarginX:=Floor(l_PointSize*1.25)
    r_MarginY:=Floor(l_PointSize*0.75)

    ;-- Return to sender
    Return r_MarginX . "," . r_MarginY
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
; Returns:
;
;   A list of uniquely-named typeface font names that match the font
;   characteristics specified by the parameters if successful, otherwise Null.
;   Font names are delimited by the LF (Line Feed) character.
;   
; Calls To Other Functions:
;
; * <Fnt_EnumFontFamExProc> (via callback)
;
;-------------------------------------------------------------------------------
Fnt_GetListOfFonts(p_CharSet="",p_Name="")
    {
    Global Fnt_EnumFontFamExProc_List

    Static Dummy6561

          ;-- Character sets
          ,ANSI_CHARSET        :=0
          ,DEFAULT_CHARSET     :=1
          ,SYMBOL_CHARSET      :=2
          ,MAC_CHARSET         :=77
          ,SHIFTJIS_CHARSET    :=128
          ,HANGUL_CHARSET      :=129
          ,GB2312_CHARSET      :=134
          ,CHINESEBIG5_CHARSET :=136
          ,GREEK_CHARSET       :=161
          ,TURKISH_CHARSET     :=162
          ,VIETNAMESE_CHARSET  :=163
          ,BALTIC_CHARSET      :=186
          ,RUSSIAN_CHARSET     :=204
          ,EASTEUROPE_CHARSET  :=238
          ,OEM_CHARSET         :=255

          ;-- Device constants
          ,HWND_DESKTOP        :=0

          ;-- LOGFONT constants
          ,LF_FACESIZE         :=32     ;-- In TCHARS

    ;-- Initialize
    PtrType  :=(A_PtrSize=8) ? "Ptr":"UInt"
    TCharSize:=A_IsUnicode ? 2:1
    Fnt_EnumFontFamExProc_List:=""

    ;-- Parameters
    p_CharSet=%p_CharSet%  ;-- AutoTrim
    if p_CharSet is Space
        p_CharSet:=DEFAULT_CHARSET

    p_Name=%p_Name%  ;-- AutoTrim
    if (StrLen(p_Name)>=LF_FACESIZE)
        p_Name:=SubStr(p_Name,1,LF_FACESIZE-1)

    ;-- Create, initialize, and populate LOGFONT structure
    VarSetCapacity(LOGFONT,28+(TCharSize*LF_FACESIZE),0)
    NumPut(p_CharSet,LOGFONT,23,"UChar")                ;-- lfCharSet
    
    if StrLen(p_Name)
        DllCall("lstrcpyn" . (A_IsUnicode ? "W":"A")
            ,PtrType,&LOGFONT+28                        ;-- lpString1 [out]
            ,"Str",p_Name                               ;-- lpString2 [in]
            ,"Int",StrLen(p_Name)+1)                    ;-- iMaxLength [in]

    ;-- Enumerate fonts
    hDC:=DllCall("GetDC",PtrType,HWND_DESKTOP)
    DllCall("EnumFontFamiliesEx"
        ,PtrType,hDC                                    ;-- hdc
        ,PtrType,&LOGFONT                               ;-- lpLogfont
        ,PtrType,RegisterCallback("Fnt_EnumFontFamExProc","Fast")
            ;-- lpEnumFontFamExProc
        ,PtrType,0                                      ;-- lParam
        ,"UInt",0)                                      ;-- dwFlags
    
    DllCall("ReleaseDC",PtrType,HWND_DESKTOP,PtrType,hDC)

    ;-- Sort, remove duplicates, and return
    Sort Fnt_EnumFontFamExProc_List,U
    Return Fnt_EnumFontFamExProc_List
    }


;------------------------------
;
; Function: Fnt_GetFont
;
; Description:
;
;   Gets the font with which a control is currently drawing its text.
;
; Parameters:
;
;   hControl - Handle to a control.
;
; Returns:
;
;   The handle to the font (HFONT) used by the control or 0 if the using the
;   system font.
;
;-------------------------------------------------------------------------------
Fnt_GetFont(hControl)
    {
    Static WM_GETFONT:=0x31
    SendMessage WM_GETFONT,0,0,,ahk_ID %hControl%
    Return ErrorLevel
    }


;------------------------------
;
; Function: Fnt_GetFontAvgCharWidth
;
; Description:
;
;   Retrieves the average width of characters in the specified font (generally
;   defined as the width of the letter x).  This value does not include the
;   overhang required for bold or italic characters.
;
; Parameters:
;
;   hFont - Handle to a logical font. [Optional] Set to 0 (the default) to use
;       the default GUI font.
;
; Returns:
;
;   The average width of characters in the specified font, in pixels.
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
;   Retrieves the height (ascent + descent) of characters in the specified font.
;
; Parameters:
;
;   hFont - Handle to a logical font. [Optional] Set to 0 (the default) to use
;       the default GUI font.
;
; Returns:
;
;   The height of characters in the specified font.
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
;   Retrieves the width of the widest character in the font.
;
; Parameters:
;
;   hFont - Handle to a logical font. [Optional] Set to 0 (the default) to use
;       the default GUI font.
;
; Returns:
;
;   The width of the widest character in the specified font, in pixels.
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

    ;-- Initialize 
    PtrType  :=(A_PtrSize=8) ? "Ptr":"UInt"
    TCharSize:=A_IsUnicode ? 2:1

    ;-- If needed, get the handle to the default GUI font
    if not hFont
        hFont:=DllCall("GetStockObject","Int",DEFAULT_GUI_FONT)

    ;-- Select the font into the device context for the desktop window
    hDC      :=DllCall("GetDC",PtrType,HWND_DESKTOP)
    hFont_old:=DllCall("SelectObject",PtrType,hDC,PtrType,hFont)

    ;-- Get the metrics for the specified font
    VarSetCapacity(TEXTMETRIC,44+(TCharSize*4)+5,0)
    DllCall("GetTextMetrics",PtrType,hDC,PtrType,&TEXTMETRIC)

    ;-- Housekeeping    
    DllCall("SelectObject",PtrType,hDC,PtrType,hFont_old)
        ;-- Necessary to avoid memory leak

    DllCall("ReleaseDC",PtrType,HWND_DESKTOP,PtrType,hDC)

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
;   hFont - Handle to a logical font. [Optional]  Set to 0 to use the default
;       GUI font.
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
          ,LF_FACESIZE         :=32     ;-- In TCHARS
          ,MAX_FONT_NAME_LENGTH:=32     ;-- In TCHARS

    ;-- Initialize 
    PtrType:=(A_PtrSize=8) ? "Ptr":"UInt"

    ;-- If needed, get the handle to the default GUI font
    if not hFont
        hFont:=DllCall("GetStockObject","Int",DEFAULT_GUI_FONT)

    ;-- Select the font into the device context for the desktop window
    hDC      :=DllCall("GetDC",PtrType,HWND_DESKTOP)
    hFont_old:=DllCall("SelectObject",PtrType,hDC,PtrType,hFont)

    ;-- Get the font name
    VarSetCapacity(l_FontName,MAX_FONT_NAME_LENGTH*(A_IsUnicode ? 2:1))
    DllCall("GetTextFace",PtrType,hDC,"Int",MAX_FONT_NAME_LENGTH,PtrType,&l_FontName)
    VarSetCapacity(l_FontName,-1)

    ;-- Housekeeping    
    DllCall("SelectObject",PtrType,hDC,PtrType,hFont_old)
        ;-- Necessary to avoid memory leak

    DllCall("ReleaseDC",PtrType,HWND_DESKTOP,PtrType,hDC)

    ;-- Return to sender
    Return l_FontName
    }


;------------------------------
;
; Function: Fnt_GetFontOptions
;
; Description:
;
;   Retreives the characteristics of a logical font for use in other library
;   functions or by the AutoHotkey
;   <gui Font at http://www.autohotkey.com/docs/commands/Gui.htm#Font> command. 
;
; Parameters:
;
;   hFont - Handle to a logical font. [Optional] Set to 0 (the default) to use
;       the default GUI font.
;
; Returns:
;
;   Font options in an AutoHotkey format.  Possible values (in alphabetical
;   order) may be include:
;
;       (start code)
;       Option
;       ------
;               Description
;               -----------
;       bold
;               Font weight is 700.
;
;       italic
;               Italic font.
;
;       s{size in points}
;
;               Font size (in points).  For example: s12
;
;       strike
;               Strikeout font.
;
;       underline
;
;               Underlined font.
;
;       w{font weight}
;
;               Font weight (thickness or boldness), which is an integer between
;               1 and 1000.  For example: w600.  This option is only returned if
;               the font weight is not normal (400) and not bold (700).
;
;       If more than one option is included, it is delimited by a space.  For
;       example: s12 bold
;       (end)
;
; Calls To Other Functions:
;
; * <Fnt_GetFontMetrics>
;
; Remarks:
;
; * Color is an option of the AutoHotkey
;   <gui Font at http://www.autohotkey.com/docs/commands/Gui.htm#Font> command
;   and of the ChooseFont API and is included by these commands because text
;   color is often set with the font.  However, text color is a control
;   attribute, not a font attribute and so it is not (read: cannot be)
;   collected/returned by this function.  If text color is to be included as one
;   of the options sent to the AutoHotkey "gui Font" command or to the
;   ChooseFont API, it must must be collected and/or set independently.
;
; * Library functions that use font options in this format include
;   <Fnt_CreateFont> and <Fnt_ChooseFont>.
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

    ;-- Initialize
    PtrType  :=(A_PtrSize=8) ? "Ptr":"UInt"
    PtrSize  :=A_PtrSize ? A_PtrSize:4
    TCharSize:=A_IsUnicode ? 2:1

    ;-- Collect the number of pixels per logical inch along the screen height
    hDC:=DllCall("CreateDC","Str","DISPLAY",PtrType,0,PtrType,0,PtrType,0)
    l_LogPixelsY:=DllCall("GetDeviceCaps",PtrType,hDC,"Int",LOGPIXELSY)
    DllCall("DeleteDC",PtrType,hDC)

    ;-- Collect the metrics for the font
    pTM:=Fnt_GetFontMetrics(hFont)

    ;-- Size
    l_Options.="s"
        . DllCall("MulDiv"
            ,"Int",NumGet(pTM+0,0,"Int")-NumGet(pTM+0,12,"Int")
                ;-- Height - InternalLeading
            ,"Int",72
            ,"Int",l_LogPixelsY)
        . A_Space

    ;-- Weight
    l_Weight:=NumGet(pTM+0,28,"Int")
    if (l_Weight=FW_BOLD)
        l_Options.="bold "
     else
        if (l_Weight<>FW_NORMAL)
            l_Options.="w" . l_Weight . A_Space

    ;-- Italic
    if NumGet(pTM+0,44+(TCharSize*4),"UChar")
        l_Options.="italic "

    ;-- Underline
    if NumGet(pTM+0,44+(TCharSize*4)+1,"UChar")
        l_Options.="underline "

    ;-- Strikeout
    if NumGet(pTM+0,44+(TCharSize*4)+2,"UChar")
        l_Options.="strike "

    Return SubStr(l_Options,1,-1)
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
;   The point size of the specified font.
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

    ;-- Initialize 
    PtrType  :=(A_PtrSize=8) ? "Ptr":"UInt"
    TCharSize:=A_IsUnicode ? 2:1

    ;-- If needed, get the handle to the default GUI font
    if not hFont
        hFont:=DllCall("GetStockObject","Int",DEFAULT_GUI_FONT)

    ;-- Select the font into the device context for the desktop window
    hDC      :=DllCall("GetDC",PtrType,HWND_DESKTOP)
    hFont_old:=DllCall("SelectObject",PtrType,hDC,PtrType,hFont)

    ;-- Get text metrics for the specified font
    VarSetCapacity(TEXTMETRIC,44+(TCharSize*4)+5,0)
    DllCall("GetTextMetrics",PtrType,hDC,PtrType,&TEXTMETRIC)

    ;-- Convert height to points
    l_Size:=DllCall("MulDiv"
        ,"Int",NumGet(TEXTMETRIC,0,"Int")-NumGet(TEXTMETRIC,12,"Int")
            ;-- Height - InternalLeading
        ,"Int",72
        ,"Int",DllCall("GetDeviceCaps",PtrType,hDC,"Int",LOGPIXELSY))

    ;-- Housekeeping    
    DllCall("SelectObject",PtrType,hDC,PtrType,hFont_old)
        ;-- Necessary to avoid memory leak

    DllCall("ReleaseDC",PtrType,HWND_DESKTOP,PtrType,hDC)

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
;   The weight of the specified font.  Possible values are from 1 to 1000.
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
; Function: Fnt_GetMaxStringSize
;
; Description:
;
;   Calculates the size of a multiline string.  See the *Remarks* section for
;   more information.
;
; Parameters:
;
;   hFont - Handle to a logical font. Set to 0 to use the default GUI font.
;
;   p_String - Any string.
;
;   r_Width, r_Height - Output variables. [Optional] These variables are loaded
;       with the width and height of the specified string.
;
; Returns:
;
;   Address to a SIZE structure if successful, otherwise FALSE.
;
; Calls To Other Functions:
;
; * <Fnt_GetStringSize>
;
; Remarks:
;
; * This is specialty function to determine the size of a multiline string.  If
;   the string contains LF (Line Feed) and/or CR+LF (Carriage Return and Line
;   Feed) characters, the function uses these delimiters to logically break the
;   string into in multiple lines of text.  The width of the widest line and the
;   combined height of all of the lines is returned.  This information can be
;   used to estimate how much space the string will use when attached to a GUI
;   control that supports multiple lines of text.
;
; * This function assumes that the string (p_String) contains at least 1 line
;   of text.
;
; Observations:
;
;   The width of the tab character is usually determined by the control, not by
;   the font, so including tab characters in the string may not produce the
;   desired results.
;
;-------------------------------------------------------------------------------
Fnt_GetMaxStringSize(hFont,p_String,ByRef r_Width="",ByRef r_Height="")
    {
    Static SIZE

    ;-- Determine the number of lines
    StringReplace p_String,p_String,`n,`n,UseErrorLevel
    l_NumberOfLines:=ErrorLevel+1

    ;-- Determine the maximum width of the text
    r_Width:=0
    Loop Parse,p_String,`n,`r
        {
        Fnt_GetStringSize(hFont,A_LoopField,l_Width)
        if (l_Width>r_Width)
            r_Width:=l_Width
        }
    
    ;-- Calcuate the height by adding up the font height for each line, and
    ;   including the space between lines (ExternalLeading) if there is more
    ;   than one line.
    r_Height:=Floor((Fnt_GetFontHeight(hFont)*l_NumberOfLines)+(Fnt_GetFontExternalLeading(hFont)*(Floor(l_NumberOfLines+0.5)-1))+0.5)

    ;-- Create and populate SIZE structure.  Return to sender.
    VarSetCapacity(SIZE,8,0)
    NumPut(r_Width, SIZE,0,"Int")
    NumPut(r_Height,SIZE,4,"Int")
    Return &SIZE
    }


;------------------------------
;
; Function: Fnt_GetStringSize
;
; Description:
;
;   Calculates the width and height of the specified string of text.
;
; Parameters:
;
;   hFont - Handle to a logical font. Set to 0 to use the default GUI font.
;
;   p_String - Any string.
;
;   r_Width, r_Height - Output variables. [Optional] These variables are loaded
;       with the width and height of the specified string.
;
; Returns:
;
;   Address to a SIZE structure if successful, otherwise FALSE.
;
; Remarks:
;
;   CR (Carriage Return) and/or CR+LF (Carriage Return and Line Feed) characters
;   are not considered when calculating the height of the string.
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

    ;-- Initialize 
    PtrType:=(A_PtrSize=8) ? "Ptr":"UInt"

    ;-- If needed, get the handle to the default GUI font
    if not hFont
        hFont:=DllCall("GetStockObject","Int",DEFAULT_GUI_FONT)

    ;-- Select the font into the device context for the desktop window
    hDC      :=DllCall("GetDC",PtrType,HWND_DESKTOP)
    hFont_old:=DllCall("SelectObject",PtrType,hDC,PtrType,hFont)

    ;-- Get string size
    VarSetCapacity(SIZE,8,0)
    RC:=DllCall("GetTextExtentPoint32"
        ,PtrType,hDC                                    ;-- hDC
        ,"Str",p_String                                 ;-- lpString
        ,"Int",StrLen(p_String)                         ;-- c (string length)
        ,PtrType,&SIZE)                                 ;-- lpSize

    ;-- Housekeeping    
    DllCall("SelectObject",PtrType,hDC,PtrType,hFont_old)
        ;-- Necessary to avoid memory leak

    DllCall("ReleaseDC",PtrType,HWND_DESKTOP,PtrType,hDC)

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
;   Calculates the width of the specified string of text.
;
; Returns:
;
;   The width of the specified string of text if successful, otherwise -1.
;
; Calls To Other Functions:
;
; * <Fnt_GetStringSize>
;
; Remarks:
;
; * This function is just a shell call to <Fnt_GetStringSize> to get the width
;   of a specified string.  Note that there is no associated "GetStringHeight" 
;   function because the height of a string is the same as the font height.  In
;   addition to <Fnt_GetStringSize>, the height can collected from
;   <Fnt_GetFontHeight>.
;
;-------------------------------------------------------------------------------
Fnt_GetStringWidth(hFont,p_String)
    {
    if pSIZE:=Fnt_GetStringSize(hFont,p_String)
        Return NumGet(pSIZE+0,0,"Int")
     else
        Return -1
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
;   TRUE if the specified font is a fixed pitch font, otherwise FALSE.
;
; Calls To Other Functions:
;
; * <Fnt_GetFontMetrics>
;
;-------------------------------------------------------------------------------
Fnt_IsFixedPitchFont(hFont)
    {
    Static TMPF_FIXED_PITCH:=0x1
    TCharSize:=A_IsUnicode ? 2:1
    Return NumGet(Fnt_GetFontMetrics(hFont),44+(TCharSize*4)+3,"UChar") & TMPF_FIXED_PITCH ? False:True
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
;   TRUE if the specified font is a TrueType font, otherwise FALSE.
;
; Calls To Other Functions:
;
; * <Fnt_GetFontMetrics>
;
;-------------------------------------------------------------------------------
Fnt_IsTrueTypeFont(hFont)
    {
    Static TMPF_TRUETYPE:=0x4
    TCharSize:=A_IsUnicode ? 2:1
    Return NumGet(Fnt_GetFontMetrics(hFont),44+(TCharSize*4)+3,"UChar") & TMPF_TRUETYPE ? True:False
    }


;------------------------------
;
; Function: Fnt_IsVectorFont
;
; Description:
;
;   Determines if a font is a vector font.
;
; Parameters:
;
;   hFont - Handle to a logical font.
;
; Returns:
;
;   TRUE if the specified font is a vector font, otherwise FALSE.
;
; Calls To Other Functions:
;
; * <Fnt_GetFontMetrics>
;
;-------------------------------------------------------------------------------
Fnt_IsVectorFont(hFont)
    {
    Static TMPF_VECTOR:=0x2
    TCharSize:=A_IsUnicode ? 2:1
    Return NumGet(Fnt_GetFontMetrics(hFont),44+(TCharSize*4)+3,"UChar") & TMPF_VECTOR ? True:False
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
;   hFont - Handle to a logical font (HFONT).  Set to 0 to use the default
;       system font.
;
;   p_Redraw - Specifies whether the control should be redrawn immediately upon
;       setting the font.  If set to TRUE, the control redraws itself.
;
; Remarks:
;
;   The size of the control does not change as a result of receiving this
;   message.  To avoid clipping text that does not fit within the boundaries of
;   the control, the program should set/correct the size of the control window
;   before it sets the font.
;
;-------------------------------------------------------------------------------
Fnt_SetFont(hControl,hFont,p_Redraw=False)
    {
    Static WM_SETFONT:=0x30
    SendMessage WM_SETFONT,hFont,p_Redraw,,ahk_ID %hControl%
    }
