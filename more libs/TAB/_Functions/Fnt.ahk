/*
    To Do:

     *  xxxxx
*/
/*
    v3.0.x release notes

    Updates/Bug Fixes
    -----------------
    * xxxxx

    New Functions
    -------------
    * Fnt_PT2PX                 ##### UC/Experimental.  Not documented.
    * Fnt_PX2PT                 ##### UC/Experimental.  Not documented.

    New Helper Functions
    --------------------
    * xxxxx

    New Add-On Functions
    --------------------
    * xxxxx

    Bug Fixes, Updates, Enhancements
    --------------------------------
    * General.  The "bold", "italic", "norm", "strike", and "underline" font
        options are now recognized for any font option that begins with the
        letters of these options.  For example, "strike" and "strikeout" are
        now treated the same.  This matches the behavior of AutoHotkey.  This
        only affects font option in input mode.  Font options set/returned by
        a function are in the same format as before.

*/
/*
Title: Fnt Library v2.0.8

Group: Introduction

    Fonts are logical objects that instruct the computer how to draw text on a
    device (display, printers, plotters, etc.).  This library provides a means
    of managing some of the aspects of fonts used in AutoHotkey.

Group: AutoHotkey Compatibility

    This library is designed to run on all versions of AutoHotkey v1.1+: ANSI,
    Unicode, and Unicode 64-bit.

Group: Common Parameters

    Common function parameters of note.

    *hFont*

    This input parameter should contain the handle to to a logical font.

    hFont is the de facto first parameter for most of the library functions.  It
    is critical to the success of the library.  To avoid errors and to improve
    flexibility, many (but not all) of the library function will automatically
    collect the handle to the default GUI font (a stock object) if the hFont
    parameter is zero, null, or unspecified.

Group: Terminology

    (see _FontMetrics.png)

    Image courtesy of <csharphelper.com at
    http://csharphelper.com/blog/2014/08/get-font-metrics-in-c/>.  Used with
    permission.

    Font terminology is not always intuitive and is often ambigious.  The
    following are a few of the terms that may be used in this library.

    Ascent - The part of the character cell above the baseline.  This includes
        the internal leading.  Also known as "ascender".

    Baseline - An imaginary line on which the majority of the characters in a
        font rest.

    Bitmap Font - A type of font that stores each character as an array of
        pixels, i.e. a bitmap.  It is less commonly known as a raster font.

    Cell Height - See the *Height* definition for more information.

    Character Cell - An imaginary box that surrounds the individual character.
        It includes the ascent (which includes the internal leading) and the
        decent.

    Descent - The part of the character cell below the baseline.  Also known as
        "descender".

    Device Font - Hardware fonts created for a specific device (Ex: printer).

    Em Height - The height within which the characters are drawn.  This is the
        cell height less the internal leading.  This is sometimes known as the
        "character height" or "text height".  The font's point size is
        calculated based on the em height.  Use <Fnt_GetFontEmHeight> to get the
        font's em height.

    External Leading - When multiple lines of text are displayed, external
        leading is extra space left below one line and above the next.  This
        value may be zero.  Use <Fnt_GetFontExternalLeading> to get the font's
        external leading.  Note: External leading is not a part of the character
        cell.  It is up to the developer/OS to determine if it is used or not.
        Most (all?) GUI controls do _not_ use external leading to space multiple
        lines of text.

    Font Family - See the <Font Family> and <Font Family[Secondary Definition]>
        topics for more information.

    Font Mapping - The process of finding the physical font that most closely
        matches a specified logical font.  In addition, the font mapping
        algorithm is used to establish the necessary values of the font when the
        logical font is created.  This allows the developer to create a font
        with little or no pertinent information.

    Height - The height (ascent (includes internal leading) + descent) of
        the font characters.  Also known as *cell height*.  Use
        <Fnt_GetFontHeight> to get the font's height.

    Internal Leading - Extra space left above the characters but considered part
        of the text.  This value may be zero.  Use <Fnt_GetFontInternalLeading>
        to get the font's internal leading.

    Italic - A (mostly) slanted font style.

    Kerning - The process of adjusting the spacing between characters in a
        proportional font, usually to create a visually pleasing result.  More
        information can be found <here at
        https://en.wikipedia.org/wiki/Kerning>.

    Logical Font - An object that contains a description of a font.  Logical
        fonts are created by the "CreateFont" or "CreateFontIndirect" API
        functions.  In the Fnt library, this task is accomplished by library
        functions with names that begin with "Fnt_Create".  For example,
        <Fnt_CreateFont>.

    Monospaced Font - A font whose letters and characters each occupy the same
        amount of horizontal space.  Also called a fixed-pitch, fixed-width, or
        non-proportional font.

    Outline Font - A type of font that uses Bézier curves, drawing instructions,
        and algorithms to describe each character, which make the character
        outlines scalable to any size.  Outline fonts are also called vector
        fonts.  Not to be confused with fonts that only draw the outline of each
        character.

    Physical Font - The fonts stored on a device (Ex: printer) or in the
        operating system.

    Pitch - For fonts (and this library), the term "pitch" is used to identify
        whether the width of each letter/character is fixed (i.e. fixed-pitch or
        monospaced) or is variable (i.e. variable-pitch or proportional).

    Point Size - The traditional way font size is measured.  Each point
        represents approximately 1/72 of an inch.  Fonts created using the
        AutoHotkey "gui Font" command are created in point size.  Also, the size
        selected in the ChooseFont dialog is in point size.  See the *Em Height*
        definition for more information.

    Proportional Font - A font whose letters and characters each occupy a
        different amount of horizontal space.   Also called a variable-pitch or
        proportional-pitch font.

    Raster Font - See the *Bitmap Font* definition for more information.

    Scalable - A type of font that can be resized (enlarged or reduced) without
        introducing distortion.  Scalable fonts are often called outline fonts.
        See the *Outline Font* definition for more information.  Note: All
        TrueType fonts are outline fonts and therefore are scalable but not all
        scalable fonts are TrueType fonts.

    Strikeout - A font style that causes text to appear as though it is crossed
        out.  Also known as "strikethrough".

    TrueType - An outline font standard developed by Apple and Microsoft as a
        competitor to Adobe's Type 1 fonts used in PostScript.  It is the most
        common format for fonts on the macOS and Microsoft Windows operating
        systems.

    Typeface - A particular design of type.  For example, Arial, Garamond, and
        Times New Roman are all unique typefaces.

    Vector Font - See the *Outline Font* definition for more information.

    Underline - A font style that causes text to appear as though it is
        underlined.

    Weight - The thickness or boldness of a font.

Group: Issues and Considerations

  Topic: Differences from AutoHotkey

    This library attempts to emulate AutoHotkey behavior when possible but there
    are a few notable exceptions.

    Font Name Not Specified Or Not Found:

    When creating a font, AutoHotkey and the Fnt library operate the same in
    most cases but there are notable exceptions.

    If the font name _and_ font options are not specified, AutoHotkey and the
    Fnt library operate the same.  In both cases, the default GUI font is used.

    If the font name is not specified but one or more font options are
    specified, Autohotkey uses the last valid font name that was defined, if
    any.  If no previous font was specified, the font name of the default GUI
    font is used.  For the Fnt library, the font name of the default GUI font is
    used in this situation.

    If a typeface that does not exist on the current computer is specified (Ex :
    "BobIsYourUncle Light"), AutoHotkey will use the font name of the previously
    defined font or the font name of the default GUI font if no previous font
    was defined.  If this condition occurs when using the Fnt library, the font
    mapping algorithm chooses a font name based upon the default pitch and font
    family.  For most computers, the default typeface is "Arial" but it could be
    anything.  The value of font options (Ex: size, bold, etc.) can factor into
    which typeface is selected.

    Retained Font Attributes:

    In AutoHotkey, the font name and/or font attributes (Ex: bold, underline,
    etc.) are retained from the previous "gui font" command(s).  They are only
    reset when a "gui font" command is performed without any other command
    options.  The Fnt library does not support this behavior.  All fonts are
    created independent of any other fonts.

    Text Color:

    In AutoHotkey, color is one of the possible font option when
    creating/setting a font (Ex: "gui Font,s12 cBlue").  When applicable, the
    specified color is applied to the text of a GUI control.  Although text
    color is an attribute of many common GUI controls, it is not a font
    attribute and therefore it is not a supported font option when creating a
    font using the Fnt library.  If specified, the color option is ignored.
    However, the color option is a recognized font option and is supported by
    several standard and helper Fnt library functions.  Please note that there
    are no Fnt library functions at this writing that apply a color to a GUI
    control.  If needed, this action must be performed outside of this library.

  Topic: DPI-Aware

    The functions in this library are not DPI-aware.  Specified position and
    size values are used as-is and the values returned from library
    functions are not adjusted to reflect a non-standard screen DPI.

    Starting with AutoHotkey v1.1.11, a *<DPIScale at
    https://autohotkey.com/docs/commands/Gui.htm#DPIScale>* option was added for
    AutoHotkey GUIs which makes most "gui" commands DPI-aware.  Although the
    AutoHotkey "gui" commands will not interfere with with any of the library
    commands (and vice versa), the size and position used by each may be
    incompatible when used on a computer that is using a non-standard DPI.  The
    DPIScale feature is enabled by default so if necessary, it must be
    explicitly disabled for each GUI.  Ex: gui -DPIScale.

  Topic: Font Family

    Definition:

    For fonts used in Windows, a font family is the font or group of fonts that
    represent a particular typeface.  For example, the "Verdana" font family
    contains the following fonts:

        (start code)
        Verdana
        Verdana Bold
        Verdana Bold Italic
        Verdana Italic
        (end)

    Notice that the fonts in this font family are for different styles or
    combination of styles but they are all for the same typeface, i.e. Verdana.

    Typeface vs. Font Family:

    For many fonts, the terms "typeface" and "font family" can be used
    interchangeably.  For example, the only font family available for the
    Verdana typeface is "Verdana".  However, some typeface are represented by
    multiple font families.  For example, the Arial typeface is represented by
    two font families - "Arial" and "Arial Black".

    Multiple font families per typeface is a necessary evil because of how fonts
    are designed to work in Windows.  From a positive perspective, it allows
    font developers the ability to 1) make changes to existing fonts and to
    2) introduce new font families without breaking existing programs.

    Considerations:

    When creating a font using native AutoHotkey commands or the "CreateFont"
    functions in this library, the the correct font family must be specified.
    For example, the font mapping algorithm will never find the "Arial Black"
    font family no matter what font attributes are specified if the "Arial" font
    family is specified.

    Although it is perfectly acceptable for the developer to specify the font's
    full name when creating a font (Ex: "Arial Bold Italic"), it's better
    practice to specify the font family (i.e. "Arial") with the desired font
    options (i.e. bold, italic, etc.) and let the font mapping algorithm
    determine the font that is used.

    It should be noted that some programs (especially native Windows programs)
    try hard to combine like font families into a single group.  For example,
    the Font window in the Control Panel and the ChooseFont API (used by
    <Fnt_ChooseFont>) combine like font families into a single group.  This
    works OK for some typefaces like Arial but doesn't work as well for
    typefaces like Segoe which are represented by a large number of font
    families.

  Topic: Font Family [Secondary Definition]

    Definition:

    Font families describe the look of a font in a general way.  They are
    intended for specifying fonts when the exact typeface desired is not
    available.  The values for font families are as follows.

    FF_DONTCARE (0x0) - No font family.
    FF_ROMAN (0x1) - Proportional fonts with serifs.  Ex: Times New Roman.
    FF_SWISS (0x2) - Proportional fonts without serifs.  Ex: Arial.
    FF_MODERN (0x3) - Monospaced fonts, with or without serifs.  Ex: Courier New.
    FF_SCRIPT (0x4) - Fonts designed to look like handwriting.  Ex: Script.
    FF_DECORATIVE (0x5) - Novelty fonts.

    Issues and Considerations:

    Most fonts are categorized correctly but there are a few notable exceptions.
    The following are observations of the fonts on my computer but these issues
    probably occur on most computers.

    1) A few fonts may be categorized incorrectly.  For example, a font may be
    categorized as Modern (i.e. a monospaced font) but the font may be a
    proportional font.

    2) A notable number of fonts are not categorized, i.e. the font family is
    set to FF_DONTCARE.  The font's designer sets the font family so the
    decision to set the font family to FF_DONTCARE may be arbitrary.  The "Don't
    Care" constant name probably doesn't help.

  Topic: Font Height

    Starting with v3.0, a font created using the Fnt library can be created with
    a specific height.  In many cases, fonts created with a specified height do
    not have an exact point size equivalent.  This means that the font cannot be
    duplicated using AutoHotkey commands.  See the *Font Height* section of
    <Fnt_CreateFont> for more information.

  Topic: Global Variables

    This library uses a few global variables.  They are as follows.

    Fnt_EnumFontFamExProc_List - [Input/Output] Used by <Fnt_EnumFontFamExProc>
        to build a list of unique font names.  <Fnt_GetListOfFonts> returns the
        list of fonts stored in this global variable to any program that calls
        the function.

  Topic: Measuring Text Size

    Introduction:

    Version 3.0 of the library introduces changes to how text can be measured.
    Library functions that use the "GetTextExtentPoint32" API function to
    measure text have not been modified (except where noted).  Ex:
    <Fnt_GetStringSize>.  New versions of these library functions that use the
    "DrawText" API function to measure text  have been created for v3.0.  The
    new function names are the same as as old except "DT" is appended to the end
    of the name.  Ex: <Fnt_GetStringSizeDT>.

    What's The Difference?:

    In general, the library functions that use the "DrawText" API function
    return a more accurate and consistent result than the functions that use the
    "GetTextExtentPoint32" API function.

    For width, the measurement differences of "GetTextExtentPoint32" function as
    compared to the "DrawText" function vary from font to font and from the text
    is measured.  The measurements from the two functions are often the same.
    If there is a measurement difference, it is often just a few pixels.  On
    occasion, depending on the font and the text, the differences can be
    significant.

    With a bug fix introduced in v3.0, the height measurements are the same.

    Other Differences:

    By default, the "GetTextExtentPoint32" API function does not consider
    carriage return and line feed characters characters when it computes the
    height of a text string.  In addition, tab characters are not expanded.
    However, if these characters are included in the text, they are treated as
    ordinary characters and are measured.

    For the "DrawText" API function, carriage return and line feed characters
    are treated as ordinary characters if the DT_SINGLELINE format is
    specified.  If the DT_EXPANDTABS format is not specified, tab characters
    are treated as ordinary characters.

    The measurements from the "GetTextExtentPoint32" function for these
    characters can be (and usually are) different than the measurements from
    "DrawText" function.  Sometimes the differences are significant.

    Performance:

    The "DrawText" API function is significantly less efficient than
    "GetTextExtentPoint32" API function.  For most fonts and for the average
    amount of text that is measured, the response difference is negligible.
    However, for some fonts and when a large amount of text is measured, the
    time to measure the text can be substantial and so consideration and
    planning are a must.  Note: The resources to measure the text are used by
    the "DrawText" API function and so increasing the priority of the script
    does not improve response in these cases.

    When To Use:

    The library functions that use the "GetTextExtentPoint32" API function
    should be used when the results of the measurement are not critical and/or
    when a large number of strings are measured.  Since they are more efficent
    that the library functions that use the "DrawText" API function (sometimes
    significantly), they should be used whenever possible.

    The library functions that use the "DrawText" API function should be used
    when the results of the measurement are critical.  For example, when
    measuring text to see if it fits within a tab stop, the functions that use
    the "DrawText" API function return the most accurate results.

    Most of the common/default fonts work fine when the "GetTextExtentPoint32"
    API function is used to measure the text.  Testing should give the developer
    the necessary information to determine which functions should be used on a
    case by case basis.  If the user is allowed to select the font that is used,
    more thorough testing is merited.

    New Functions:

    Version 3.0 also includes entirely new functions that use the "DrawText" API
    function to measure text.  <Fnt_CalculateSize> is the most flexible but
    there are new functions designed specifically for certain GUI controls (Ex:
    <Fnt_GetSizeForButton>.  The "DrawText" function is used because if provides
    new options to help accurately determine the size of text that will be used
    for certain GUI controls.  Because of the additional resources required by
    the "DrawText" API function, consideration and planning are a must.

  Topic: Non-Client Fonts

    Non-Client (sometimes written as "nonclient") fonts are the fonts used by
    the caption (text on the title bar), small caption, message box, status bar,
    and tooltips.  These fonts are set by default when the user selects a theme
    and text size (DPI).  These settings can be customized by the user by going
    to the Advanced Appearance Settings in the Control Panel.  These font
    setting are rarely changed by an application.  The exceptions are the fonts
    for tooltips and the status bar.

    Tooltip:

    Although the tooltip font is rarely changed, it can be changed by the
    developer to reflect the needs of the application.  This library includes a
    fairly reliable method to find the handle of the last tooltip created.

    Status Bar:

    When a status bar is added to an AutoHotkey GUI, AutoHotkey will use
    whatever font was last set or the default GUI font if nothing else was set.
    This means that font used by the status bar is never set to the appropriate
    non-client font unless the developer explicitly sets it.  See the example
    scripts to see how to use the Fnt library to set the font for the status bar
    to the appropriate non-client font.

  Topic: Row Height

    When the "r" (row) GUI option (Ex: gui Add, Text, *r10*) is used to
    determine the height of the text displayed in GUI controls that can display
    multiple lines of text (Button, Edit, Text, WebBrowser, etc.), AutoHotkey
    calculates the height by adding up the font height for each row, including
    the space between each row (external leading) if there is more than one row.
    This calculation is incorrect because GUI controls don't use the font's
    external leading value to separate lines of text.  The calculation error is
    off by the external leading value for the font times the number of lines
    minus 1, i.e. ExternalLeading*(NbrOfLines-1).  For example, if the external
    leading value for a font is 2 and the number of rows is 10, the calculation
    will be off (too tall) by 18 pixels (2 pixels * (10 rows - 1)). This
    calculation error doesn't present itself often because many fonts have a
    zero (0) external leading value.

    The workaround is to calculate the row height manually.  Multiplying the
    font's height by the desired number of rows (Ex: Fnt_GetFontHeight(hFont)*9)
    is a good start.  This calculation works fine as-is for a few GUI controls
    (Ex: Text and WebBrowser), however, for many other controls that display
    multiple lines of text (Ex: Edit control) a fixed amount of space (usually 8
    pixels) must be added to the height to give it the correct height.  In
    addition, space for other controls (Ex: horizontal scroll bar) must be
    included if needed.  See the example scripts for more examples.

 Topic: Tab Stop Size

    The content for this topic can be found <here at
    https://autohotkey.com/boards/viewtopic.php?p=173326#p173326>.

Group: Links

    Font and Text Reference
    - <https://msdn.microsoft.com/en-us/library/windows/desktop/dd144824%28v=vs.85%29.aspx>

    What’s The Difference Between A Font And A Typeface?
    - <https://www.fastcodesign.com/3028971/whats-the-difference-between-a-font-and-a-typeface>

Group: Credit

    Some of the code in this library and in the example scripts was extracted
    from the AutoHotkey source.  Thanks to authors of *AutoHotkey*.

    The <Fnt_ChooseFont> function was originally adapted from the Dlg library
    which was published by *majkinetor*.

    The <Fnt_GetListOfFonts> function was inspired by an example published by
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
; Parameters:
;
;   p_File - The full path and name of the font file.
;
;   p_Private - If set to TRUE, only the process that called this function can
;       use the added font(s).
;
;   p_Hidden - If set to TRUE, the added font(s) cannot be enumerated, i.e. not
;       included when any program requests a list of fonts from the OS.  The
;       default is FALSE, i.e. not hidden.
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
Fnt_AddFontFile(p_File,p_Private,p_Hidden:=False)
    {
    Static Dummy94084243

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
; Function: Fnt_CalculateSize
;
; Description:
;
;   Calculate the width and height of text.  See the *Remarks* section for more
;   information.
;
; Parameters:
;
;   hFont - Handle to a logical font.  Set to null or 0 to use the default GUI
;       font.
;
;   r_Text - [Input/Output] A variable that contains the text used to determine
;       the size of the rectangle.  See the *End-Of-Line Character(s)* section
;       for more information.  If the p_Options parameter contains options to
;       modify the text, this variable will be updated to contain the modified
;       text.
;
;   p_Options - Options used to determine how the DrawTextEx function is used.
;       [Optional] See the *Options* section for more information.
;
;   r_Width, r_Height - [Output, Optional] These variables are loaded with the
;       calculated width and height of the rectangle.
;
; Returns:
;
;   The address to a SIZE structure.  The cx member contains the maximum width
;   of the text.  The cy member contains the height of the text.
;
; Maximum Width:
;
;   The Width option (p_Options parameter) is used to set the maximum width of
;   rectangle, in pixels.
;
;   If the Width option and WordBreak format is set, lines are automatically
;   broken between words if a word extends past the maximum width.  Also, lines
;   are broken into multiple lines if the text contains end-of-line (EOL)
;   sequences (LF or CR+LF).
;
;   If the Width option is not set but the WordBreak format is set, the width of
;   the rectangle is entirely determined by the text contained in the r_Text
;   parameter.  Lines are only broken into multiple lines if the text contains
;   EOL characters.
;
; Options:
;
;   The following options and DrawTextEx formats can be used in the p_Options
;   parameter.
;
;   Bottom - [Format] Justifies the text to the bottom of the rectangle.  This
;       format is used only with the SingleLine format.
;
;   Center - [Format] Centers text horizontally in the rectangle.
;
;   CalcRect - [Format] Determines the width and height of the rectangle but
;       does not draw the text.  Note: This option is for reference only.  This
;       format is included by default.
;
;   EditControl - [Format] Duplicates the text-displaying characteristics of a
;       multiline edit control.  Specifically, the average character width is
;       calculated in the same manner as for an Edit control, and the function
;       does not display a partially visible last line.
;
;   End_Ellipsis - [Format] For displayed text, replaces the end of a string
;       with ellipses so that the result fits in the specified rectangle.  Any
;       word (not at the end of the string) that goes beyond the limits of the
;       rectangle is truncated without ellipses. The text is not modified unless
;       the ModifyString option is specified.  Compare with the Path_Ellipsis
;       and Word_Ellipsis options.
;
;   ExpandTabs - [Format] Expands tab characters. The default number of
;       characters per tab is 8.
;
;   ExternalLeading - [Format] Includes the font external leading in line
;       height.  Normally, external leading is not included in the height of a
;       line of text.
;
;   Format={Format} - Sets the DrawTextEx format as an integer value.  Ex:
;       Format=0x18D40.  Note: This option will override any format value(s)
;       that may have been previously defined.  If other format options follow
;       this option, their values are added to this value.
;
;   HidePrefix - [Format] Ignores the ampersand (&) prefix character in the
;       text.  The letter that follows will not be underlined, but other
;       mnemonic-prefix characters are still processed.  Compare with the
;       NoPrefix and PrefixOnly formats.  See the full documentation on the
;       DT_HIDEPREFIX flag for examples.
;
;   Internal - [Format] Uses the system font to calculate text metrics.
;
;   Left - [Format] Aligns text to the left.  This format is for reference only.
;       Text is automatically left-justified unless there is an overriding
;       format (Ex: Right).
;
;   LeftMargin={LeftMargin} - The left margin, in pixels.  Ex: LeftMargin=12.
;       If this option is not specified, the left margin is set to 0.  Note:
;       The Microsoft documentation incorrectly states that the left margin
;       should be in units equal to the average character width.
;
;   ModifyString - [Format] Modifies the text in the r_Text variable to match
;       the displayed text.  This format has no effect unless the End_Ellipsis,
;       Path_Ellipsis, or Word_Ellipsis formats are specified.
;
;   NoClip - [Format] Draws without clipping.  The DrawTextEx function is
;       somewhat faster when this format is used.
;
;   NoFullWidthCharBreak - [Format] Prevents a line break at a DBCS (double-wide
;       character string), so that the line-breaking rule is equivalent to SBCS
;       strings.  For example, this can be used in Korean windows, for more
;       readability of icon labels.  This format has no effect unless
;       WordBreak format is specified.
;
;   NoPrefix - [Format] Turns off processing of prefix characters.  Normally,
;       the DrawTextEx function interprets the ampersand (&) mnemonic-prefix
;       character as a directive to underscore the character that follows, and
;       the double-ampersand (&&) mnemonic-prefix characters as a directive to
;       print a single ampersand.  By specifying this format, this processing is
;       turned off.  Compare with HidePrefix and PrefixOnly formats.
;
;   Path_Ellipsis - [Format] For displayed text, replaces characters in the
;       middle of the string with ellipses so that the result fits in the
;       specified rectangle. If the string contains backslash (\) characters,
;       this format preserves as much as possible of the text after the last
;       backslash.  The text is not modified unless the ModifyString option is
;       specified. Compare with the End_Ellipsis and Word_Ellipsis options.
;
;   PrefixOnly - [Format] Draws only an underline at the position of the
;       character following the ampersand (&) prefix character.  Does not draw
;       any character in the string.  Compare with the NoPrefix and HidePrefix
;       formats.  See the full documentation for the DT_PREFIXONLY format for
;       examples.
;
;   Right - [Format] Aligns text to the right.
;
;   RightMargin={RightMargin} - The right margin, in pixels.  Ex: RightMargin=8.
;       If this option is not specified, the right margin is set to 0.  Note:
;       The Microsoft documentation incorrectly states that the right margin
;       should be in units equal to the average character width.
;
;   RTLReading - [Format] Layout in right-to-left reading order for
;       bidirectional text when the using is a Hebrew or Arabic font.  The
;       default reading order for all text is left-to-right.
;
;   SingleLine - [Format] Displays text on a single line only.  Carriage returns
;       and line feeds do not break the line.
;
;   TabStop - [Format] Sets tab stops.  This format is used in conjunction with
;       the ExpandTabs format and the TabLength option.  If the TabLength option
;       is not specified or is set to 0, the default tab length (8 average
;       characters) is used.
;
;   TabLength={TabLength} - The size of each tab stop, in units equal to the
;       average character width.  Ex: TabLength=8.  This option is used in
;       conjunction with the ExpandTabs and TabStop formats.  If either of these
;       formats are not set, this option is ignored.  If this option is not
;       specified, the default tab length (8) is used.
;
;   Top - [Format] Justifies the text to the top of the rectangle.  This format
;       is for reference only.  Text is automatically top-justified unless there
;       is an overriding format (Ex: Bottom).
;
;   VCenter - [Format] Centers text vertically.  This value is used only with
;       the SingleLine format.
;
;   Width={WidthInPixels} - The width of the rectangle in pixels.  Ex:
;       Width=450.  See the *Maximum Width* section for more information.  Note:
;       The value returned in the r_Width variable represents the calculated
;       width of the rectangle which can be significantly different than this
;       value.
;
;   WordBreak - [Format] Breaks words.  Lines are automatically broken between
;       words if a word extends past the edge of the rectangle.  A carriage
;       return-line feed sequence also breaks the line.  Note: This format does
;       not modify the text.  It is used to calculate the height of of the
;       rectangle.
;
;   Word_Ellipsis - [Format] Truncates any word that does not fit in the
;       rectangle and adds ellipses.  Compare with the End_Ellipsis and
;       Path_Ellipsis formats.
;
;   A few notes...
;
;   Options are processed in the order they are are defined, i.e. from left to
;   right.  To use more than one option/format, include a space between each
;   each.  For example: "NoClip ExpandTabs Width=500"
;
; Average Character:
;
;   For the "DrawTextEx" API function, an "average character" is a font-specific
;   value.  How it is calculated depends on whether or not the DT_EDITCONTROL
;   format is used.
;
;   If the DT_EDITCONTROL format is not used, an "average character" is the
;   average width of characters in a font which is generally defined as the
;   width of the letter x.  This value is collected directly from the font's
;   text metrics. See <Fnt_GetFontAvgCharWidth> for more information.
;
;   If the DT_EDITCONTROL format is used, an average character is the
;   equivalent of 1 dialog base unit.  This is the average size of a specific
;   string of characters.  See <Fnt_GetDialogBaseUnits> for more information.
;
;   The "average character" size is only important when setting or calculating
;   the tab stop size.  When calculating the tab stop size based upon a custom
;   tab stop size, the DT_TABSTOP and DT_EXPANDTABS formats must be used.  If
;   just calculating the default tab stop size, only the DT_EXPANDTABS format is
;   necessary.
;
; Tab Stop Size:
;
;   When defining a custom tab stop size, the "DrawTextEx" function only
;   supports a single tab stop size which means that all tab stops must be the
;   same size.  For example, if the TabLength option (p_Options parameter) is
;   set to 10, the first tab stop position is 10 average characters, the second
;   is 20 average characters, and so on.  If the GUI control does not use a
;   single custom tab stop size, the returned text size will not be accurate.
;
;   The "DrawTextEx" function only supports tab stops in increments of "average
;   characters".  This increment size is 4 times larger than what is supported
;   by GUI controls that support a custom tab stop size.  If the actual tab stop
;   size is not equal to an exact factor of an average character, the returned
;   text size will not be accurate.  For example, tab stops for the Edit control
;   are measured in "dialog template units" (DTUs).  There are 4 DTUs per
;   "dialog base unit" (DBUs).  A DBU is the same as an "average character".
;   A tab stop of 32 DTUs can be converted to exactly 8 "average characters"
;   (32 DTUs/4 = 8 DBUs = 8 "average characters").  However, if the tab stop on
;   the Edit control is 30 DBUs, the conversion is 7.5 "average characters".
;   Only integer values are supported so any conversion to "average characters"
;   (i.e. 7 or 8) would be value that does not match the actual tab stop size so
;   the returned text size will not be accurate.
;
; Remarks:
;
;   This function uses the "DrawTextEx" function to calculate the width and
;   height of the specified text.  It is powerful and flexible but the correct
;   options and format must be specified in order for accurate results to be
;   returned.  Experimenting and testing are required in many cases.  See the
;   example scripts for examples.
;
;   A few of the format options provide no value because they do not affect the
;   size calculation but they remain for completeness.
;
;-------------------------------------------------------------------------------
Fnt_CalculateSize(hFont,ByRef r_Text,p_Options,ByRef r_Width:="",ByRef r_Height:="")
    {
    Static Dummy57788508
          ,DEFAULT_GUI_FONT:=17
          ,HWND_DESKTOP    :=0
          ,MAXINT          :=0x7FFFFFFF
          ,OBJ_FONT        :=6
          ,SIZE

          ;-- DrawText flags
          ,DT_LEFT:=0x0
                ;-- Aligns text to the left.  Note: This format is used by
                ;   default unless there is an overriding format (Ex: DT_RIGHT).

          ,DT_TOP:=0x0
                ;-- Justifies the text to the top of the rectangle.  Note: This
                ;   format is used by default unless there is an overriding
                ;   format (Ex: DT_BOTTOM).

          ,DT_CENTER:=0x1
                ;-- Centers text horizontally in the rectangle.

          ,DT_RIGHT:=0x2
                ;-- Aligns text to the right.

          ,DT_VCENTER:=0x4
                ;-- Centers text vertically.  This value is used only with the
                ;   DT_SINGLELINE format.

          ,DT_BOTTOM:=0x8
                ;-- Justifies the text to the bottom of the rectangle.  This
                ;   format is used only with the DT_SINGLELINE format.

          ,DT_WORDBREAK:=0x10
                ;-- Breaks words.  Lines are automatically broken between words
                ;   if a word extends past the edge of the rectangle specified
                ;   by the lprc parameter.  A carriage return-line feed sequence
                ;   also breaks the line.

          ,DT_SINGLELINE:=0x20
                ;-- Displays text on a single line only.  Carriage returns and
                ;   line feeds do not break the line.

          ,DT_EXPANDTABS:=0x40
                ;-- Expands tab characters.  The default number of characters
                ;   per tab is eight.

          ,DT_TABSTOP:=0x80
                ;-- Sets tab stops.  The DRAWTEXTPARAMS structure pointed to by
                ;   the lpDTParams parameter specifies the number of average
                ;   character widths per tab stop.

          ,DT_NOCLIP:=0x100
                ;-- Draws without clipping.  DrawTextEx is somewhat faster when
                ;   DT_NOCLIP is used.

          ,DT_EXTERNALLEADING:=0x200
                ;-- Includes the font external leading in line height.
                ;   Normally, external leading is not included in the height of
                ;   a line of text.

          ,DT_CALCRECT:=0x400
                ;-- Determines the width and height of the rectangle.  The text
                ;   is not drawn.

          ,DT_NOPREFIX:=0x800
                ;-- Turns off processing of prefix characters.  Normally,
                ;   DrawTextEx interprets the ampersand (&) mnemonic-prefix
                ;   character as a directive to underscore the character that
                ;   follows, and the double-ampersand (&&) mnemonic-prefix
                ;   characters as a directive to print a single ampersand.  By
                ;   specifying DT_NOPREFIX, this processing is turned off.
                ;   Compare with DT_HIDEPREFIX and DT_PREFIXONLY.

          ,DT_INTERNAL:=0x1000
                ;-- Uses the system font to calculate text metrics.

          ,DT_EDITCONTROL:=0x2000
                ;-- Duplicates the text-displaying characteristics of a
                ;   multiline edit control.  Specifically, the average character
                ;   width is calculated in the same manner as for an Edit
                ;   control, and the function does not display a partially
                ;   visible last line.

          ,DT_PATHELLIPSIS :=0x4000  ;-- Alias
          ,DT_PATH_ELLIPSIS:=0x4000
                ;-- For displayed text, replaces characters in the middle of the
                ;   string with ellipses so that the result fits in the
                ;   specified rectangle.  If the string contains backslash (\)
                ;   characters, DT_PATH_ELLIPSIS preserves as much as possible
                ;   of the text after the last backslash.  The string is not
                ;   modified unless the DT_MODIFYSTRING flag is specified.
                ;   Compare with DT_END_ELLIPSIS and DT_WORD_ELLIPSIS.

          ,DT_ENDELLIPSIS :=0x8000  ;-- Alias
          ,DT_END_ELLIPSIS:=0x8000
                ;-- For displayed text, replaces the end of a string with
                ;   ellipses so that the result fits in the specified rectangle.
                ;   Any word (not at the end of the string) that goes beyond the
                ;   limits of the rectangle is truncated without ellipses. The
                ;   string is not modified unless the DT_MODIFYSTRING flag is
                ;   specified.  Compare with DT_PATH_ELLIPSIS and
                ;   DT_WORD_ELLIPSIS.

          ,DT_MODIFYSTRING:=0x10000
                ;-- Modifies the specified string to match the displayed text.
                ;   This format has no effect unless DT_END_ELLIPSIS or
                ;   DT_PATH_ELLIPSIS is specified.

          ,DT_RTLREADING:=0x20000
                ;-- Layout in right-to-left reading order for bidirectional text
                ;   when the font selected into the hdc is a Hebrew or Arabic
                ;   font.  The default reading order for all text is
                ;   left-to-right.

          ,DT_WORDELLIPSIS :=0x40000  ;-- Alias
          ,DT_WORD_ELLIPSIS:=0x40000
                ;-- Truncates any word that does not fit in the rectangle and
                ;   adds ellipses.  Compare with DT_END_ELLIPSIS and
                ;   DT_PATH_ELLIPSIS.

          ,DT_NOFULLWIDTHCHARBREAK:=0x80000
                ;-- Prevents a line break at a DBCS (double-wide character
                ;   string), so that the line-breaking rule is equivalent to
                ;   SBCS strings.  For example, this can be used in Korean
                ;   windows, for more readability of icon labels.  This format
                ;   has no effect unless DT_WORDBREAK is specified.

          ,DT_HIDEPREFIX:=0x100000
                ;-- Ignores the ampersand (&) prefix character in the text.  The
                ;   letter that follows will not be underlined, but other
                ;   mnemonic-prefix characters are still processed.  Compare
                ;   with DT_NOPREFIX and DT_PREFIXONLY.  See the full
                ;   documentation on this flag for examples.

          ,DT_PREFIXONLY:=0x200000
                ;-- Draws only an underline at the position of the character
                ;   following the ampersand (&) prefix character.  Does not draw
                ;   any character in the string.  Compare with DT_NOPREFIX and
                ;   DT_HIDEPREFIX.  See the full documentation on this flag for
                ;   examples.

    ;-- Initialize
    VarSetCapacity(SIZE,8,0)
    l_LeftMargin :=0
    l_RightMargin:=0
    l_Width      :=MAXINT
    l_TabLength  :=0

    r_Width :=0
    r_Height:=0

    ;-- If needed, get the handle to the default GUI font
    if (DllCall("GetObjectType","Ptr",hFont)<>OBJ_FONT)
        hFont:=DllCall("GetStockObject","Int",DEFAULT_GUI_FONT)

    ;-- Extract DrawText format and option values
    l_DTFormat:=DT_CALCRECT
    Loop Parse,p_Options,%A_Space%
        {
        if A_LoopField is Space
            Continue

        if (SubStr(A_LoopField,1,7)="Format=")
            {
            l_DTFormat:=DT_CALCRECT|SubStr(A_LoopField,8)
            Continue
            }

        if (SubStr(A_LoopField,1,11)="LeftMargin=")
            {
            l_LeftMargin:=SubStr(A_LoopField,12)
            Continue
            }

        if (SubStr(A_LoopField,1,12)="RightMargin=")
            {
            l_RightMargin:=SubStr(A_LoopField,13)
            Continue
            }

        if (SubStr(A_LoopField,1,10)="TabLength=")
            {
            l_TabLength:=SubStr(A_LoopField,11)
            Continue
            }

        if (SubStr(A_LoopField,1,6)="Width=")
            {
            l_Width:=SubStr(A_LoopField,7)
            Continue
            }

        ;-- Check for invalid format name characters
        ;   The format name must only contain characters that can be represented
        ;   as part of an AutoHotkey static variable name.  This test keeps the
        ;   script from crashing if invalid characters are included in the
        ;   options.
        l_ValidFormatName:=True
        Loop Parse,A_LoopField
            {
            if A_LoopField is AlNum
                Continue

            if A_LoopField in #,_,@,$
                Continue

            l_ValidFormatName:=False
            Break
            }

        if not l_ValidFormatName  ;-- Debugging condition only
            {
            outputdebug,
               (ltrim join`s
                Func: %A_ThisFunc% - Invalid format name: %A_LoopField%.
                Option skipped.
               )

            Continue
            }

        ;-- Format option
        if DT_%A_LoopField% is not Space
            l_DTFormat|=DT_%A_LoopField%
        }

    ;-- Create and populate DRAWTEXTPARAMS structure
    VarSetCapacity(DRAWTEXTPARAMS,20,0)
    NumPut(20,           DRAWTEXTPARAMS,0,"UInt")       ;-- cbSize
    NumPut(l_TabLength,  DRAWTEXTPARAMS,4,"Int")        ;-- iTabLength
    NumPut(l_LeftMargin, DRAWTEXTPARAMS,8,"Int")        ;-- iLeftMargin
    NumPut(l_RightMargin,DRAWTEXTPARAMS,12,"Int")       ;-- iRightMargin

    ;-- Create and populate the RECT structure
    VarSetCapacity(RECT,16,0)
    NumPut(l_Width,RECT,8,"Int")                        ;-- right

    ;-- Select the font into the device context for the desktop
    hDC      :=DllCall("GetDC","Ptr",HWND_DESKTOP)
    old_hFont:=DllCall("SelectObject","Ptr",hDC,"Ptr",hFont)

    ;-- Create a buffer that can be expanded to contain up to four (4)
    ;   additional characters.  In theory, this could require up to 16
    ;   additional bytes of space.
    VarSetCapacity(l_Text,VarSetCapacity(r_Text)+16,0)
    l_Text:=r_Text

    ;-- DrawText
    DllCall("DrawTextEx"
        ,"Ptr",hDC                                      ;-- hdc [in]
        ,"Str",l_Text                                   ;-- lpchText [in, out]
        ,"Int",-1                                       ;-- cchText [in]
        ,"Ptr",&RECT                                    ;-- lprc [in, out]
        ,"UInt",l_DTFormat                              ;-- dwDTFormat [in]
        ,"Ptr",&DRAWTEXTPARAMS)                         ;-- lpDTParams [in]

    ;-- Release the objects needed by the DrawTextEx function
    DllCall("SelectObject","Ptr",hDC,"Ptr",old_hFont)
        ;-- Necessary to avoid memory leak

    DllCall("ReleaseDC","Ptr",HWND_DESKTOP,"Ptr",hDC)

    ;-- Update output variables and populate SIZE structure
    r_Text:=l_Text
    NumPut(r_Width:=NumGet(RECT,8,"Int"),SIZE,0,"Int")
        ;-- right, cx

    NumPut(r_Height:=NumGet(RECT,12,"Int"),SIZE,4,"Int")
        ;-- bottom, cy

    ;-- Return calculated values
    Return &SIZE
    }

;------------------------------
;
; Function: Fnt_ChooseFont
;
; Description:
;
;   Creates and shows a Font dialog box that enables the user to choose
;   attributes for a logical font.
;
; Parameters:
;
;   hOwner - A handle to the window that owns the dialog box.  This parameter
;       can be any valid window handle or it can be set to 0 or null if the
;       dialog box has no owner.
;
;   r_Name - Font name. [Input/Output] On input, this variable can contain the
;       default font name.  On output, this variable will contain the selected
;       font name.
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
; Returns:
;
;   TRUE if a font was selected, otherwise FALSE if the dialog was canceled or
;   if an error occurred.
;
; Calls To Other Functions:
;
; * <Fnt_ColorName2RGB>
; * <Fnt_CreateFont>
; * <Fnt_DeleteFont>
; * <Fnt_GetFontName>
; * <Fnt_GetFontOptions>
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
; Options:
;
;   On input, the r_Options parameter contains the default font options.  On
;   output, r_Options will contain the selected font options.  The following
;   space-delimited options (in alphabetical order) are available:
;
;   bold - On input, this option will preselect the "Bold" font style.  On
;       output, this option is returned if a bold font was selected.
;
;   c{color} - Text color.  {color} is one of 16 color names (see the AutoHotkey
;       documentation for a list of supported color names) or a 6-digit hex RGB
;       color value.  Example values: Blue or FF00FA.  On input, this option
;       will attempt to pre-select the text color.  On output, this option is
;       returned with the selected text color.  Notes and Exceptions: 1) The
;       default text color is pre-selected if a color option is not specified or
;       if the "Default" color is specified.  2) Color names (Ex: "Blue") are
;       only accepted on input.  A 6-digit hex RGB color value is set on output
;       (Ex: 0000FF).  Exception: If the default text color is selected, the
;       color name "Default" is set.  3) If p_Effects is FALSE, this option is
;       ignored on input and is not returned.
;
;   h{HeightInPixels} - [Input Only]  Font height in pixels.  Ex: h20.  See the
;       *Height* section for more information.
;
;   italic - On input, this option will preselect the "italic" font style.  On
;       output, this option is returned if an italic font was selected.
;       Exception: If p_Effects is FALSE, this option is ignored on input and is
;       not returned.
;
;   s{SizeInPoints} -  Font size in points.  For example: s12.  On input,
;       this option will load the font size and if on the dialog's "Size" list,
;       will preselect the font size.  On output, the font size that was
;       entered/selected is returned.
;
;   SizeMax{MaximumPointSize} - [Input only] Sets the maximum point size the
;       user can enter/select.  See the *Size Limits* section for more
;       information.
;
;   SizeMin{MinimumPointSize} - [Input only] Sets the minimum point size the
;       user can enter/select.  See the *Size Limits* section for more
;       information.
;
;   strike - On input, this option will check the "Strikeout" option.  On
;       output, this option is returned if the "Strikeout" option was checked.
;       Exception: If p_Effects is FALSE, this option is ignored on input and is
;       not returned.
;
;   underline - On input, this option will check the "Underline" option.  On
;       output, this option is returned if the "Underline" option was checked.
;       Exception: If p_Effects is FALSE, this option is ignored on input and is
;       not returned.
;
;   w{FontWeight} - Font weight (thickness or boldness), which is an integer
;       between 1 and 1000.  For example, 400 is Normal and 700 is Bold.  On
;       input, this option will preselect the font style that most closely
;       matches the weight specified.  If not specified, the default weight for
;       the font is selected.  On output, this option is only returned if the
;       weight is not Normal (400) and not Bold (700).
;
;   To specify more than one option, include a space between each.  For
;   example: s12 cFF0000 bold.  On output, the selected options are defined
;   in the same format.
;
; Height:
;
;   The "h{HeightInPixels}" option (p_Options parameter) allows the developer to
;   specify a font size based on height instead of point size.  This option has
;   the same precedence as the "s"ize option.  If both the "h" and "s" options
;   are specified, the last one specified is used.
;
;   If the height value is positive (Ex: "h30"), the font mapping algorithm
;   matches it against the cell height (ascent + descent) of the available fonts
;   and will set/select the closest point size value.
;
;   If the height value is negative (Ex: "h-25"), the font mapping algorithm
;   matches the absolute value against the em height (cell height less internal
;   leading) of the available fonts and will set/select the closest point size
;   value.
;
;   Note: This is an "input only" option.  The "h"eight option is not returned.
;   Instead, the function returns the point size selected.  Ex: "s16".
;
; Size Limits:
;
;   By default, the font size is not tested.  The user can enter whatever they
;   want in most cases.  The SizeMin and SizeMax options (r_Options parameter)
;   change that by ensuring the size is between a certain range of values.  In
;   addition, they also limit the sizes that are shown in the Size list box.
;
;   The SizeMin{MinimumPointSize} option sets the minimum point size the user
;   can enter/select.  Ex: SizeMin10.  If this option is specified without also
;   specifying the SizeMax option, the SizeMax value is automatically set to
;   the maximum point size - 0xBFFF (49151).
;
;   The SizeMax{MaximumPointSize} option sets the the maximum point size the
;   user can enter/select.  Ex: SizeMax72.  If this option is specified without
;   also specifying the SizeMin option, the SizeMin value is automatically set
;   to 0.
;
;   If the user enters a font size that is outside the boundaries set by the
;   SizeMin and SizeMax options, a MsgBox dialog is shown and the user is not
;   allowed to continue until a valid font size is entered/selected.
;
;   Note: If the SizeMin value is greater than the SizeMax value, both size
;   limits are invalidated and no size limits are enforced.
;
; Remarks:
;
;   The ChooseFont dialog box supports the selection of text color.  Although
;   text color is an attribute of many common controls, please note that it is
;   not a font attribute.
;
;   Although the font weight can be any number between 1 and 1000, most fonts
;   only support 2 weights.  For most fonts, the weights are 400
;   (Normal/Regular) and 700 (Bold).  A small number of fonts support other
;   weights.  At this writing, the ChooseFont dialog does not display weight as
;   a number.  Instead, weight is displayed as a font style like ExtraLight,
;   Regular, Bold, Black, etc.  See the <CreateFont at
;   http://tinyurl.com/n2qe72w> documentation for a list of common font weight
;   names and their associated values.
;
;   The ChooseFont dialog combines as many fonts into the fewest number of font
;   names as possible.  For example, the "Arial" and "Arial Black" font families
;   are combined into a single "Arial" font.  The "Arial Black" typeface is only
;   returned when the "Arial" typeface is selected with the "Black" font style.
;   The merge algorithm works OK for most fonts but sometimes, some typeface and
;   weight combinations cannot be selected.  For example, the "Segoe UI
;   Semibold" font is available with weights of 600 and 800.  Only the font with
;   the 600 weight can be selected.
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
; Programming Notes:
;
;   Support for the CF_SHOWHELP flag was intentionally left out of this library
;   because it would require the use of OnMessage commands.  The OnMessage
;   command in turn would make any script that uses the Fnt library to be
;   persistent.  Any script that included the Fnt library would need to use the
;   ExitApp command to terminate the script.  If support for the CF_SHOWHELP
;   flag is desired, use the Dlg_ChooseFont function in the Dlg2 library or
;   use the <Fnt_ChooseFontDlg> add-on function.
;
;-------------------------------------------------------------------------------
Fnt_ChooseFont(hOwner:=0,ByRef r_Name:="",ByRef r_Options:="",p_Effects:=True,p_Flags:=0)
    {
    Static Dummy31554570
          ,s_MaximumSize:=0xBFFF

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
                ;-- The lpszStyle member is a pointer to a buffer that contains
                ;   style data that ChooseFont should use to initialize the Font
                ;   Style combo box.  This function uses the LOGFONT structure
                ;   to specify the font style so this flag is not supported.  Do
                ;   not use.

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
          ,FW_DONTCARE:=0
          ,FW_NORMAL  :=400
          ,FW_BOLD    :=700
          ,LF_FACESIZE:=32     ;-- In TCHARS

          ;-- Error constants
          ,CFERR_MAXLESSTHANMIN:=0x2002

    ;[==============]
    ;[  Initialize  ]
    ;[==============]
    l_WindowTextColor:=Fnt_GetWindowTextColor()
        ;-- The default window text color

    ;[==============]
    ;[  Parameters  ]
    ;[==============]
    r_Name:=Trim(r_Name," `f`n`r`t`v")
        ;-- Remove all leading/trailing white space

    ;-- p_Flags
    if p_Flags is not Integer
        p_Flags:=0x0

    p_Flags|=CF_SCREENFONTS|CF_INITTOLOGFONTSTRUCT
    if p_Effects
        p_Flags|=CF_EFFECTS

    p_Flags&=~CF_LIMITSIZE
        ;-- In case the developer manually set it for some reason

    ;-- Collect the font name and options
    ;   Note: To improve usability, a temporary font is created using the font
    ;   name and options provided by the developer.  The font name and options
    ;   from this temporary font are prepended to the current values (if any).
    ;   This step usually generates redundant values but in a few cases it
    ;   provides additional information necessary to preselect default
    ;   or necessary values in the dialog.
    hFont    :=Fnt_CreateFont(r_Name,r_Options)
    r_Name   :=Fnt_GetFontName(hFont)
    r_Options:=Fnt_GetFontOptions(hFont) . A_Space . r_Options
    Fnt_DeleteFont(hFont)

;;;;;    outputdebug r_Name=%r_Name%, r_Options=%r_Options%

    ;[===========]
    ;[  Options  ]
    ;[===========]
    ;-- Initialize
    o_Color    :=l_WindowTextColor
    o_Height   :=""             ;-- Undefined
    o_Italic   :=False
    o_Size     :=""             ;-- Undefined
    o_SizeMin  :=""             ;-- Undefined
    o_SizeMax  :=""             ;-- Undefined
    o_Strikeout:=False
    o_Underline:=False
    o_Weight   :=FW_DONTCARE

    ;-- Extract options from r_Options
    ;   Note: Options are processed in the order they are defined, i.e. from
    ;   left to right.  If an option is defined more than once, the last
    ;   occurrence of the option takes precedence.
    Loop Parse,r_Options,%A_Space%
        {
        if A_LoopField is Space
            Continue

        if (SubStr(A_LoopField,1,4)="bold")
            o_Weight:=FW_BOLD
        else if (SubStr(A_LoopField,1,6)="italic")
            o_Italic:=True
        else if (InStr(A_LoopField,"sizemin")=1)
            o_SizeMin:=SubStr(A_LoopField,8)
        else if (InStr(A_LoopField,"sizemax")=1)
            o_SizeMax:=SubStr(A_LoopField,8)
        else if (SubStr(A_LoopField,1,6)="strike")
            o_Strikeout:=True
        else if (SubStr(A_LoopField,1,9)="underline")
            o_Underline:=True
        else if (SubStr(A_LoopField,1,1)="c")
            o_Color:=SubStr(A_LoopField,2)
        else if (SubStr(A_LoopField,1,1)="h")
            {
            o_Height:=SubStr(A_LoopField,2)
            o_Size  :=""  ;-- Undefined
            }
        else if (SubStr(A_LoopField,1,1)="s")
            {
            o_Size  :=SubStr(A_LoopField,2)
            o_Height:=""  ;-- Undefined
            }
        else if (SubStr(A_LoopField,1,1)="w")
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
    if o_Color is Space
        o_Color:=l_WindowTextColor
     else
        {
        if o_Color is xDigit
            {
            ;-- If not set already, prepend hex prefix
            if (SubStr(o_Color,1,2)<>"0x")
                o_Color:="0x" . o_Color
            }
         else
            o_Color:=Fnt_ColorName2RGB(l_Color)
        }

    o_Color:=((o_Color&0xFF)<<16)+(o_Color&0xFF00)+((o_Color>>16)&0xFF)
        ;-- Convert to BRG

    ;-- If needed, convert point size to height, in logical units
    if o_Size is Integer
        {
        ;-- Collect the number of pixels per logical inch along the screen height
        hDC:=DllCall("CreateDC","Str","DISPLAY","Ptr",0,"Ptr",0,"Ptr",0)
        l_LogPixelsY:=DllCall("GetDeviceCaps","Ptr",hDC,"Int",LOGPIXELSY)
        DllCall("DeleteDC","Ptr",hDC)

        ;-- Convert size to em height
        o_Height:=Round(o_Size*l_LogPixelsY/72)*-1
        }

    if o_Height is not Integer
        o_Height:=0

    if o_SizeMin is not Integer
        o_SizeMin:=""  ;-- Undefined

    if o_SizeMax is not Integer
        o_SizeMax:=""  ;-- Undefined

    if o_SizeMin is Integer
        if o_SizeMax is not Integer
            o_SizeMax:=s_MaximumSize+0

    if o_SizeMax is Integer
        {
        if (o_SizeMax>s_MaximumSize)
            o_SizeMax:=s_MaximumSize+0

        if o_SizeMin is not Integer
            o_SizeMin:=0
        }

    if o_SizeMin is Integer
        if (o_SizeMin>o_SizeMax)
            {
            o_SizeMin:=""  ;-- Undefined
            o_SizeMax:=""  ;-- Undefined
            outputdebug Function: %A_ThisFunc% - SizeMin>SizeMax. No size limit set.
            }

    if o_Weight is not Integer
        o_Weight:=FW_DONTCARE

    ;[================]
    ;[  Update flags  ]
    ;[================]
    if o_SizeMin is Integer
        p_Flags|=CF_LIMITSIZE

    ;[==================]
    ;[  Pre-Processing  ]
    ;[==================]
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

    if o_SizeMin  ;-- Not 0 (the default) or null/blank
        NumPut(o_SizeMin,CHOOSEFONT,(A_PtrSize=8) ? 92:52,"Int")
            ;-- nSizeMin

    if o_SizeMax  ;-- Not 0 or null/blank
        NumPut(o_SizeMax,CHOOSEFONT,(A_PtrSize=8) ? 96:56,"Int")
            ;-- nSizeMax

    ;[===============]
    ;[  Show dialog  ]
    ;[===============]
    RC:=DllCall("comdlg32\ChooseFont" . (A_IsUnicode ? "W":"A"),"Ptr",&CHOOSEFONT)
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

    ;[==================]
    ;[  Rebuild output  ]
    ;[==================]
    ;-- Font name
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

    ;-- ##### Temporary/Experimental
;;;;;    CharSet:=NumGet(LOGFONT,23,"UChar")
;;;;;    outputdebug Character set: %CharSet%

;;;;;    FontType:=NumGet(CHOOSEFONT,(A_PtrSize=8) ? 88:48,"UShort")
;;;;;    outputdebug Font type: %FontType%
    ;-- ##### End Temporary/Experimental

    Return True
    }

;------------------------------
;
; Function: Fnt_CloneFont
;
; Description:
;
;   Creates a logical font with the same attributes as the specified logical
;   font.
;
; Returns:
;
;   A handle to a logical font.
;
; Credit:
;
;   jeeswg
;
; Remarks:
;
;   When no longer needed, call <Fnt_DeleteFont> to delete the font.
;
;-------------------------------------------------------------------------------
Fnt_CloneFont(hFont:="")
    {
    Static Dummy84506521
          ,DEFAULT_GUI_FONT:=17
          ,OBJ_FONT        :=6

    ;-- If needed, get the handle to the default GUI font
    if (DllCall("GetObjectType","Ptr",hFont)<>OBJ_FONT)
        hFont:=DllCall("GetStockObject","Int",DEFAULT_GUI_FONT)

    ;-- Clone
	VarSetCapacity(LOGFONT,A_IsUnicode ? 92:60,0)
	DllCall("GetObject","Ptr",hFont,"Int",A_IsUnicode ? 92:60,"Ptr",&LOGFONT)
	Return DllCall("CreateFontIndirect","Ptr",&LOGFONT,"Ptr")
    }

;------------------------------
;
; Function: Fnt_Color2ColorName
;
; Description:
;
;   Convert a color value into one of 16 color names if a match is found.
;
; Type:
;
;   Internal function.  Subject to change.  Do not use.
;
; Parameters:
;
;   p_Color - A color value in any format supported by the "c"olor option of the
;       AutoHotkey "gui Font" command.  Example values: FF00FA, 0xABCDEF, Blue,
;       Default
;
;   p_ConvertDefaultName - See the *Convert Default Name* section for more
;       information.
;
; Returns:
;
;   A color name (Ex: "Blue") if a match is found, otherwise the original value
;   is returned.
;
; Calls To Other Functions:
;
; * <Fnt_RGB2ColorName>
; * <Fnt_GetWindowTextColor>
;
; Convert Default Name:
;
;   The p_ConvertDefaultName parameter allows the developer to determine what
;   occurs if the "Default" color name is specified in the p_Color parameter.
;
;   If p_ConvertDefaultName is set to TRUE, the "Default" color value is
;   converted to one of the 16 color names if a the default text color matches
;   one of the 16 color names.  If no match is found, the original value (i.e.
;   "Default") is returned.
;
;   If p_ConvertDefaultName is set to FALSE (the default), the original value
;   (i.e. "Default") is returned in all cases.
;
;-------------------------------------------------------------------------------
Fnt_Color2ColorName(p_Color,p_ConvertDefaultName:=False)
    {
    l_Color:=Trim(p_Color," `f`n`r`t`v")
        ;-- Remove all leading/trailing white space

    if (p_ConvertDefaultName and l_Color="Default")
        l_Color:=Fnt_GetWindowTextColor()

    if l_Color is xDigit
        {
        if (SubStr(l_Color,1,2)<>"0x")
            l_Color:="0x" . l_Color

        l_Color:=Fnt_RGB2ColorName(l_Color)
        if l_Color is Alpha
            Return l_Color
        }

    Return p_Color
    }

;------------------------------
;
; Function: Fnt_Color2RGB
;
; Description:
;
;   Convert a color value to it's 6-digit hexadecimal RGB value.
;
; Type:
;
;   Internal function.  Subject to change.  Do not use.
;
; Parameters:
;
;   p_Color - A color value in any format supported by the "c"olor option of the
;       AutoHotkey "gui Font" command.  Example values: FF00FA, 0xABCDEF, Blue,
;       Default
;
; Returns:
;
;   A 6-digit hexadecimal RGB value.  Ex: 0xFF00FF.  If the function is unable
;   to identify the color value, the value from <Fnt_GetWindowTextColor> is
;   returned.
;
; Calls To Other Functions:
;
; * <Fnt_ColorName2RGB>
; * <Fnt_GetWindowTextColor>
;
; Remarks:
;
;   This function should not be confused with <Fnt_ColorName2RGB> which only
;   converts color names to RGB.
;
;-------------------------------------------------------------------------------
Fnt_Color2RGB(p_Color)
    {
    if p_Color is Space
        Return Fnt_GetWindowTextColor()

    if p_Color is xDigit
        {
        if (SubStr(p_Color,1,2)<>"0x")
            p_Color:="0x" . p_Color

        Return Format("0x{:06X}",p_Color)
        }

    if p_Color is Alpha
        Return Fnt_ColorName2RGB(p_Color)

    Return Fnt_GetWindowTextColor()
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
    Static ColorTable:={Aqua:"0x00FFFF",Black:"0x000000",Blue:"0x0000FF",Fuchsia:"0xFF00FF",Gray:"0x808080",Green:"0x008000",Lime:"0x00FF00",Maroon:"0x800000",Navy:"0x000080",Olive:"0x808000",Purple:"0x800080",Red:"0xFF0000",Silver:"0xC0C0C0",Teal:"0x008080",White:"0xFFFFFF",Yellow:"0xFFFF00"}

    ;-- Remove all leading/trailing white space
    p_ColorName:=Trim(p_ColorName," `f`n`r`t`v")

    ;-- Search for the name in the list of colors.  Return matching RGB if found.
    For l_ColorName,l_ColorRGB in ColorTable
        if (p_ColorName=l_ColorName)
            Return l_ColorRGB

    ;-- Return the default text color (covers the "Default" color name)
    Return Fnt_GetWindowTextColor()
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
;   hFont - Handle to a logical font.  Set to null or 0 to use the default GUI
;       font.
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
; Calls To Other Functions:
;
; * <Fnt_GetStringWidth>
;
; Remarks:
;
;   By default, the path is not compacted beyond a minimum value which is
;   usually a base file name preceded by ellipses.  If the value of p_MaxW is
;   too small (relative to the specified font), the width of the minimum path
;   value (measured in pixels) may be larger than p_MaxW.  If the p_Strict
;   parameter is set to TRUE, the return value is set to null if the compacted
;   path is wider than p_MaxW.  If p_Strict is set to FALSE (the default), the
;   function will return whatever value is returned from the "PathCompactPath"
;   function.
;
;-------------------------------------------------------------------------------
Fnt_CompactPath(hFont,p_Path,p_MaxW,p_Strict:=False)
    {
    Static Dummy65138236
          ,DEFAULT_GUI_FONT:=17
          ,HWND_DESKTOP    :=0
          ,MAX_PATH        :=260
          ,OBJ_FONT        :=6

    ;-- If needed, get the handle to the default GUI font
    if (DllCall("GetObjectType","Ptr",hFont)<>OBJ_FONT)
        hFont:=DllCall("GetStockObject","Int",DEFAULT_GUI_FONT)

    ;-- Select the font into the device context for the desktop
    hDC      :=DllCall("GetDC","Ptr",HWND_DESKTOP)
    old_hFont:=DllCall("SelectObject","Ptr",hDC,"Ptr",hFont)

    ;-- Compact path
    VarSetCapacity(l_Path,MAX_PATH*(A_IsUnicode ? 2:1),0)
    l_Path:=p_Path
    DllCall("shlwapi\PathCompactPath" . (A_IsUnicode ? "W":"A")
        ,"Ptr",hDC                                      ;-- hDC,
        ,"Str",l_Path                                   ;-- lpszPath
        ,"UInt",p_MaxW)                                 ;-- dx

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
;   p_Name - Font name. [Optional]  If null or unspecified, the default GUI font
;       name is used.
;
;   p_Options - Font options. [Optional] See the *Options* section for more
;       information.
;
; Options:
;
;   The following options can be used in the p_Options parameter.
;
;   bold - Set the font weight to the heaviest weight available.  The heaviest
;       weight is 700 for most fonts but it can be higher for a few fonts.
;
;   h{HeightInPixels} - Font height in pixels.  Ex: h20.  See the *Font Height*
;       section for more information.
;
;   italic - Create an italic font.
;
;   norm - Sets the font to normal weight/boldness and turns off italic, strike,
;       and underline but the height/size is not modified.  See the *Remarks*
;       section for more information.
;
;   q{Quality} - Output quality.  Ex: q3.  See the function's static variables
;       for a list of possible quality values.
;
;   s{SizeInPoints} - Font size in points.  Ex: s12.  See the *Font Size*
;       section for more information.
;
;   -s - Remove the "s"ize option.  See the *Font Size* and *Remarks* sections
;       for more information.
;
;   strike - Create a strikeout font.
;
;   underline - Create an underlined font.
;
;   w{FontWeight} - Font weight (thickness or boldness), which is an integer
;       between 1 and 1000.  Ex: w600.  This option is usually unnecessary
;       unless a specific weight is desired.  Use "bold" to select the font's
;       heaviest weight.
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
; Font Height:
;
;   The "h" option (p_Options parameter) allows the developer to create a font
;   with a specific height.  This option has the same precedence as the "s"ize
;   option.  If both the "h" and "s" options are specified, the last one
;   defined is used.
;
;   If the height value is positive (Ex: "h30"), the font mapping algorithm
;   matches it against the cell height (ascent + descent) of the available
;   fonts. Observation: For scalable fonts, the height of the new font is equal
;   to or less than the requested height in most cases.
;
;   If the height value is negative (Ex: "h-25"), the font mapping algorithm
;   matches the absolute value against the em height (cell height less internal
;   leading) of the available fonts.
;
;   If the height value is zero (Ex: "h0"), the font mapping algorithm uses a
;   default height value when searching for a match.
;
;   *Important*: Fonts created by height have a more precise size than fonts
;   created using using the "s" (size) option.  Fonts created by height may not
;   have an exact "s" (point size) equivalent.  To precisely duplicate a font
;   created by height, use the same height value that was used to create the
;   original font or use <Fnt_CloneFont>.
;
;   The "h" option is not available in AutoHotkey.  Like the "q" (quality)
;   option, the "h" option is only available when creating a font.  This option
;   is not returned when using <Fnt_GetFontOptions>.  After the font has been
;   created, use <Fnt_GetFontHeight> to get the font's height.
;
; Font Size:
;
;   The "s" option (p_Options parameter) allows the developer to create a font
;   with a specific point size.  Ex: s12.
;
;   If the font size is zero (Ex: "s0"), the font mapping algorithm uses a
;   default height value when searching for a match.  Note: This is same as
;   setting the "h"eight value to zero (Ex: "h0").
;
;   If a "s"ize, "-s", or "h"eight option is not specified, the font size is set
;   to the font size of the default GUI font.  This duplicates AutoHotkey
;   behavior.  Observation: The point size of the default GUI font may be
;   impractically small for the specified typeface.   Be sure to specify a
;   point size if possible.  If unsure, try "s0".
;
; Remarks:
;
;   When no longer needed, call <Fnt_DeleteFont> to delete the font.
;
;   If both the p_Name and p_Options parameters are null or unspecified, the
;   handle to the default GUI font (a stock object) is returned.  This emulates
;   the AutoHotkey behavior when no font has specified or when the "gui Font"
;   command with no options is used.
;
;   The "norm" and "-s" font options (p_Options parameter) do not have any
;   practical value for this function but they were included to be compatible
;   with the AutoHotkey font options.  If used, they will generate the same
;   results as if they were used in the "gui Font" command.
;
;-------------------------------------------------------------------------------
Fnt_CreateFont(p_Name:="",p_Options:="")
    {
    Static Dummy34361446

          ;-- Device constants
          ,LOGPIXELSY:=90

          ;-- Misc. font constants
          ,CLIP_DEFAULT_PRECIS:=0
          ,DEFAULT_CHARSET    :=1
          ,DEFAULT_GUI_FONT   :=17
          ,OUT_TT_PRECIS      :=4

          ;-- Font family
          ,FF_DONTCARE  :=0x0
          ,FF_ROMAN     :=0x1
          ,FF_SWISS     :=0x2
          ,FF_MODERN    :=0x3
          ,FF_SCRIPT    :=0x4
          ,FF_DECORATIVE:=0x5

          ;-- Font pitch
          ,DEFAULT_PITCH :=0
          ,FIXED_PITCH   :=1
          ,VARIABLE_PITCH:=2

          ;-- Font quality
          ,DEFAULT_QUALITY       :=0
          ,DRAFT_QUALITY         :=1
          ,PROOF_QUALITY         :=2  ;-- AutoHotkey default
          ,NONANTIALIASED_QUALITY:=3
          ,ANTIALIASED_QUALITY   :=4
          ,CLEARTYPE_QUALITY     :=5

          ;-- Font weight
          ,FW_DONTCARE:=0
          ,FW_NORMAL  :=400
          ,FW_BOLD    :=700

    ;-- Parameters
    ;   Remove all leading/trailing white space
    p_Name   :=Trim(p_Name," `f`n`r`t`v")
    p_Options:=Trim(p_Options," `f`n`r`t`v")

    ;-- If both parameters are null or unspecified, return the handle to the
    ;   default GUI font.
    if (p_Name="" and p_Options="")
        Return DllCall("GetStockObject","Int",DEFAULT_GUI_FONT)

    ;-- Initialize options
    o_Height   :=""             ;-- Undefined
    o_Italic   :=False
    o_Quality  :=PROOF_QUALITY  ;-- AutoHotkey default
    o_Size     :=""             ;-- Undefined
    o_Strikeout:=False
    o_Underline:=False
    o_Weight   :=FW_DONTCARE

    ;-- Extract options (if any) from p_Options
    Loop Parse,p_Options,%A_Space%
        {
        if A_LoopField is Space
            Continue

        if (SubStr(A_LoopField,1,4)="bold")
            o_Weight:=1000
        else if (SubStr(A_LoopField,1,6)="italic")
            o_Italic:=True
        else if (SubStr(A_LoopField,1,4)="norm")
            {
            o_Italic   :=False
            o_Strikeout:=False
            o_Underline:=False
            o_Weight   :=FW_DONTCARE
            }
        else if (A_LoopField="-s")
            o_Size:=0
        else if (SubStr(A_LoopField,1,6)="strike")
            o_Strikeout:=True
        else if (SubStr(A_LoopField,1,9)="underline")
            o_Underline:=True
        else if (SubStr(A_LoopField,1,1)="h")
            {
            o_Height:=SubStr(A_LoopField,2)
            o_Size  :=""  ;-- Undefined
            }
        else if (SubStr(A_LoopField,1,1)="q")
            o_Quality:=SubStr(A_LoopField,2)
        else if (SubStr(A_LoopField,1,1)="s")
            {
            o_Size  :=SubStr(A_LoopField,2)
            o_Height:=""  ;-- Undefined
            }
        else if (SubStr(A_LoopField,1,1)="w")
            o_Weight:=SubStr(A_LoopField,2)
        }

    ;----------------------------------
    ;-- Convert/Fix invalid or
    ;-- unspecified parameters/options
    ;----------------------------------
    if p_Name is Space
        p_Name:=Fnt_GetFontName()   ;-- Font name of the default GUI font

    if o_Height is not Integer
        o_Height:=""                ;-- Undefined

    if o_Quality is not Integer
        o_Quality:=PROOF_QUALITY    ;-- AutoHotkey default

    if o_Size is Space              ;-- Undefined
        o_Size:=Fnt_GetFontSize()   ;-- Font size of the default GUI font
     else
        if o_Size is not Integer
            o_Size:=""              ;-- Undefined
         else
            if (o_Size=0)
                o_Size:=""          ;-- Undefined

    if o_Weight is not Integer
        o_Weight:=FW_DONTCARE       ;-- A font with a default weight is created

    ;-- If needed, convert point size to em height
    if o_Height is Space        ;-- Undefined
        if o_Size is Integer    ;-- Allows for a negative size (emulates AutoHotkey)
            {
            hDC:=DllCall("CreateDC","Str","DISPLAY","Ptr",0,"Ptr",0,"Ptr",0)
            o_Height:=-Round(o_Size*DllCall("GetDeviceCaps","Ptr",hDC,"Int",LOGPIXELSY)/72)
            DllCall("DeleteDC","Ptr",hDC)
            }

    if o_Height is not Integer
        o_Height:=0                 ;-- A font with a default height is created

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
        ,"UInt",(FF_DONTCARE<<4)|DEFAULT_PITCH          ;-- fdwPitchAndFamily
        ,"Str",SubStr(p_Name,1,31))                     ;-- lpszFace

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
; Function: Fnt_CreatePitchAndFamilyFont
;
; Description:
;
;   Create a font by pitch and font family rather than by font name.
;
; Type:
;
;   Experimental/Preview.  Subject to change.
;
; Parameters:
;
;   p_Pitch - Font pitch.  The default is 0 which represents the default pitch.
;       See the function's static variables for a list of possible font pitch
;       values.  Alternatively, set to one of the following string values:
;
;       (start code)
;       Value       Description
;       ------      -----------
;       Default     Default pitch.
;       Fixed       Fixed-pitch (i.e. monospaced).
;       Variable    Variable-pitch (i.e. proportional).
;       (end)
;
;   p_Family - Font family.  The default is 0 which represents an instruction to
;       use the default font.  See the function's static variables for a list of
;       possible font family values.  Alternatively, set to one of the following
;       string values:
;
;       (start code)
;       Value       Description
;       ------      -----------
;       Decorative  Novelty fonts.
;       DontCare    Use the default font.
;       Modern      Monospaced fonts, with or without serifs.  Ex: Courier New.
;       Roman       Proportional fonts with serifs.  Ex: Times New Roman.
;       Script      Fonts designed to look like handwriting.
;       Swiss       Proportional fonts without serifs.  Ex: Arial.
;       (end)
;
;   p_Options - Font options. [Optional] See the *Options* section of
;       <Fnt_CreateFont> for more information.
;
; Returns:
;
;   A handle to a logical font.
;
; Remarks:
;
;   When no longer needed, call <Fnt_DeleteFont> to delete the font.
;
;   This function instructs the font mapping algorithm to choose from only
;   TrueType fonts.  If there are no TrueType fonts installed in the system, the
;   font mapping algorithm returns to default behavior.
;
;   Unlike <Fnt_CreateFont>, there is no condition where the handle to the
;   default GUI font (a stock object) is returned.  In addition, there is no
;   condition where the font size is set to the font size of the default GUI
;   font.
;
;-------------------------------------------------------------------------------
Fnt_CreatePitchAndFamilyFont(p_Pitch:=0,p_Family:=0,p_Options:="")
    {
    Static Dummy34361446

          ;-- Device constants
          ,LOGPIXELSY:=90

          ;-- Misc. font constants
          ,CLIP_DEFAULT_PRECIS:=0
          ,DEFAULT_CHARSET    :=1
          ,OUT_TT_ONLY_PRECIS :=7

          ;-- Font family
          ,FF_DONTCARE  :=0x0
          ,FF_ROMAN     :=0x1
          ,FF_SWISS     :=0x2
          ,FF_MODERN    :=0x3
          ,FF_SCRIPT    :=0x4
          ,FF_DECORATIVE:=0x5

          ;-- Font pitch
          ,DEFAULT_PITCH :=0
          ,FIXED_PITCH   :=1
          ,VARIABLE_PITCH:=2

          ;-- Font quality
          ,DEFAULT_QUALITY       :=0
          ,DRAFT_QUALITY         :=1
          ,PROOF_QUALITY         :=2  ;-- AutoHotkey default
          ,NONANTIALIASED_QUALITY:=3
          ,ANTIALIASED_QUALITY   :=4
          ,CLEARTYPE_QUALITY     :=5

          ;-- Font weight
          ,FW_DONTCARE:=0
          ,FW_NORMAL  :=400
          ,FW_BOLD    :=700

    ;-- Parameters
    if p_Pitch is Alpha
        if (p_Pitch="Fixed")
            p_Pitch:=FIXED_PITCH
        else if (p_Pitch="Variable")
            p_Pitch:=VARIABLE_PITCH
        else if (p_Pitch="Default")
            p_Pitch:=DEFAULT_PITCH

    if p_Pitch is not Integer
        p_Pitch:=DEFAULT_PITCH

    if p_Family is Alpha
        if FF_%p_Family% is not Space
            p_Family:=FF_%p_Family%

    if p_Family is not Integer
        p_Family:=FF_DONTCARE

    ;-- Initialize options
    o_Height   :=""             ;-- Undefined
    o_Italic   :=False
    o_Quality  :=PROOF_QUALITY  ;-- AutoHotkey default
    o_Size     :=""             ;-- Undefined
    o_Strikeout:=False
    o_Underline:=False
    o_Weight   :=FW_DONTCARE

    ;-- Extract options (if any) from p_Options
    Loop Parse,p_Options,%A_Space%
        {
        if A_LoopField is Space
            Continue

        if (SubStr(A_LoopField,1,4)="bold")
            o_Weight:=1000
        else if (SubStr(A_LoopField,1,6)="italic")
            o_Italic:=True
        else if (SubStr(A_LoopField,1,4)="norm")
            {
            o_Italic   :=False
            o_Strikeout:=False
            o_Underline:=False
            o_Weight   :=FW_DONTCARE
            }
        else if (A_LoopField="-s")
            o_Size:=0
        else if (SubStr(A_LoopField,1,6)="strike")
            o_Strikeout:=True
        else if (SubStr(A_LoopField,1,9)="underline")
            o_Underline:=True
        else if (SubStr(A_LoopField,1,1)="h")
            {
            o_Height:=SubStr(A_LoopField,2)
            o_Size  :=""  ;-- Undefined
            }
        else if (SubStr(A_LoopField,1,1)="q")
            o_Quality:=SubStr(A_LoopField,2)
        else if (SubStr(A_LoopField,1,1)="s")
            {
            o_Size  :=SubStr(A_LoopField,2)
            o_Height:=""  ;-- Undefined
            }
        else if (SubStr(A_LoopField,1,1)="w")
            o_Weight:=SubStr(A_LoopField,2)
        }

    ;----------------------------------
    ;-- Convert/Fix invalid or
    ;-- unspecified parameters/options
    ;----------------------------------
    if o_Height is not Integer
        o_Height:=""                ;-- Undefined

    if o_Quality is not Integer
        o_Quality:=PROOF_QUALITY    ;-- AutoHotkey default

    if o_Size is not Integer
        o_Size:=""                  ;-- Undefined
     else
        if (o_Size=0)
            o_Size:=""              ;-- Undefined

    if o_Weight is not Integer
        o_Weight:=FW_DONTCARE       ;-- A font with a default weight is created

    ;-- If needed, convert point size to em height
    if o_Height is Space        ;-- Undefined
        if o_Size is Integer    ;-- Allows for a negative size (emulates AutoHotkey)
            {
            hDC:=DllCall("CreateDC","Str","DISPLAY","Ptr",0,"Ptr",0,"Ptr",0)
            o_Height:=Round(o_Size*DllCall("GetDeviceCaps","Ptr",hDC,"Int",LOGPIXELSY)/72)
            DllCall("DeleteDC","Ptr",hDC)
            }

    if o_Height is not Integer
        o_Height:=0                 ;-- A font with a default height is created

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
        ,"UInt",OUT_TT_ONLY_PRECIS                      ;-- fdwOutputPrecision
        ,"UInt",CLIP_DEFAULT_PRECIS                     ;-- fdwClipPrecision
        ,"UInt",o_Quality                               ;-- fdwQuality
        ,"UInt",(p_Family<<4)|p_Pitch                   ;-- fdwPitchAndFamily
        ,"Str","")                                      ;-- lpszFace

    Return hFont
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
; Function: Fnt_CreateTooltipFont
;
; Description:
;
;   Creates a logical font with the same attributes as the font used in
;   tooltips.
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
;   This function is a clone of <Fnt_CreateStatusFont>.
;
;-------------------------------------------------------------------------------
Fnt_CreateTooltipFont()
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
;   hFont - Handle to a logical font.  Set to null or 0 to use the default GUI
;       font.
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
;   The address to a SIZE structure.
;
; Calls To Other Functions:
;
; * <Fnt_GetDialogBaseUnits>
;
;-------------------------------------------------------------------------------
Fnt_DialogTemplateUnits2Pixels(hFont,p_HorzDTUs,p_VertDTUs:=0,ByRef r_Width:="",ByRef r_Height:="")
    {
    Static Dummy44524052
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
;       about the font, the result can be case as an ENUMLOGFONTEX or
;       ENUMLOGFONTEXDV structure.
;
;   lpntme - A pointer to a structure that contains information about the
;       physical attributes of a font.  The function uses the NEWTEXTMETRICEX
;       structure for TrueType fonts; and the TEXTMETRIC structure for other
;       fonts.  This can be an ENUMTEXTMETRIC structure.
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
;   the list of font names.  Since this function is called many times for every
;   request, the font name is always appended to this variable.  Be sure to set
;   the Fnt_EnumFontFamExProc_List variable to null before every request.
;
;-------------------------------------------------------------------------------
Fnt_EnumFontFamExProc(lpelfe,lpntme,FontType,p_Flags)
    {
    Global Fnt_EnumFontFamExProc_List
    Static Dummy62479817

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

          ;-- Font family
          ,FF_DONTCARE  :=0x0
          ,FF_ROMAN     :=0x1
          ,FF_SWISS     :=0x2
          ,FF_MODERN    :=0x3
          ,FF_SCRIPT    :=0x4
          ,FF_DECORATIVE:=0x5
          ,FF_NONE      :=0xF  ;-- Custom flag

          ;-- LOGFONT constants
          ,LF_FACESIZE     :=32  ;-- In TCHARS
          ,LF_FULLFACESIZE :=64  ;-- In TCHARS

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

;;;;;    outputdebug FontType: %FontType%, %l_FaceName%

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

    if l_Family:=p_Flags & 0xF  ;-- Font family value specified in p_Flags
        {
        if (l_Family=FF_NONE)
            {
            if ((l_PitchAndFamily>>4)<>FF_DONTCARE)
                Return True   ;-- Continue enumeration
            }
         else if ((l_PitchAndFamily>>4)<>l_Family)
            Return True  ;-- Continue enumeration
        }

    ;-- Append the font name to the list
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
;   Determines if a typeface exists on the current computer.
;
; Type:
;
;   Experimental/Preview.  Subject to change.
;
; Parameters:
;
;   p_Name* - Zero or more parameters containing a font name (Ex: "Arial"), an
;       AutoHotkey object with an array of font names (Ex:
;       ["Calibri","Consolas","Courier"]), a comma-delimited list of font names
;       (Ex: "Arial,Verdana,Helvetica"), or any combination of these types.  See
;       the *Remarks* section for more information.
;
; Returns:
;
;   The first font name that exists from the p_Name parameter(s) (also tests as
;   TRUE) if successful, otherwise null (also tests as FALSE).  See the
;   *Remarks* section for more information.
;
; Calls To Other Functions:
;
; * <Fnt_GetFontName>
;
; Remarks:
;
;   Although not case sensitive, the exact font name must be specified.
;
;   Leading and trailing white space, single quote, and double quote characters
;   are ignored.  For example, "Arial,Segoe UI,Verdana" is the same as "Arial,
;   'Segoe UI', Verdana"
;
;   The font name is returned (i.e. success) if the font name is a valid font
;   substitute.  Ex: "Helv", "MS Shell Dlg", "Times", etc.
;
; Programming Note:
;
;   This function confirms the existence of a typeface by creating a temporary
;   font and then collecting typeface name from the font and then comparing it
;   to the specified name.  This method is used instead of font enumeration to
;   avoid the rare but possible false positive that can occur when a typeface is
;   only available for particular character set.
;
;-------------------------------------------------------------------------------
Fnt_FontExists(p_Name*)
    {
    Global Fnt_FontExists
    Static Dummy23598612

          ;-- Character sets
          ,DEFAULT_CHARSET:=1

          ;-- Misc. font constants
          ,CLIP_DEFAULT_PRECIS:=0
          ,OUT_TT_PRECIS      :=4

          ;-- Font quality
          ,DEFAULT_QUALITY:=0
          ,PROOF_QUALITY  :=2  ;-- AutoHotkey default

          ;-- Font weight
          ,FW_DONTCARE:=0

          ;-- LOGFONT constants
          ,LF_FACESIZE:=32  ;-- In TCHARS

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

                    if l_Name is not Space  ;-- Ignore blank/null names
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

                if l_Name is not Space  ;-- Ignore blank/null names
                    FontNames.Push(l_Name)
                }
            }
        }

    ;-- Determine if the fonts name(s) exist
    For l_Key,l_Name in FontNames
        {
        ;-- Create temporary font
        hFont:=DllCall("CreateFont"
            ,"Int",0                                    ;-- nHeight
            ,"Int",0                                    ;-- nWidth
            ,"Int",0                                    ;-- nEscapement (0=normal horizontal)
            ,"Int",0                                    ;-- nOrientation
            ,"Int",FW_DONTCARE                          ;-- fnWeight
            ,"UInt",False                               ;-- fdwItalic
            ,"UInt",False                               ;-- fdwUnderline
            ,"UInt",False                               ;-- fdwStrikeOut
            ,"UInt",DEFAULT_CHARSET                     ;-- fdwCharSet
            ,"UInt",OUT_TT_PRECIS                       ;-- fdwOutputPrecision
            ,"UInt",CLIP_DEFAULT_PRECIS                 ;-- fdwClipPrecision
            ,"UInt",DEFAULT_QUALITY                     ;-- fdwQuality
            ,"UInt",0                                   ;-- fdwPitchAndFamily
            ,"Str",SubStr(l_Name,1,31))                 ;-- lpszFace

        ;-- Get the font name that was created
        l_CreatedName:=Fnt_GetFontName(hFont)

        ;-- Delete temporary font
        DllCall("DeleteObject","Ptr",hFont)

        ;-- Return name if it matches the font name from the temporary font
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
;   hFont - Handle to a logical font.  Set to null or 0 to use the default GUI
;       font.
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
; * <Fnt_GetStringWidth>
;
; Remarks:
;
;   This function uses a brute-force method to determine the font size needed.
;   The current font (from the hFont parameter) is checked first and then
;   the size is incremented or decremented by one until the desired size is
;   found.  Although this method is crude and can be resource intensive if
;   there is large difference between the initial and final font size, it
;   appears to be accurate for all fonts and all strings.  The function works
;   the most efficiently  if the developer starts with a font that is as close
;   to desired size as possible.  If possible, this methodology will be improved
;   in the future.
;
;   If the string cannot fit into the specified width, the smallest font size
;   available is returned.  For scalable fonts, this size will always be 1.
;   For non-scalable fonts, the size will be whatever is the lowest font size
;   is available.
;
;   This function identifies the point size of a font that is needed for a
;   specified width.  However, the height of the font is not taken into
;   consideration.  If the value returned by this function is used to set the
;   font of a GUI control, the program may need to also set/correct the height
;   of the control to avoid clipping or gaps.
;
;   The amount of space necessary to fit text within a fixed-size GUI control is
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
;   The resources used by this function are very reasonable if the font size
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
    Static Dummy11744130
          ,DEFAULT_GUI_FONT:=17
          ,OBJ_FONT        :=6
          ,s_MaxFontSize   :=1500

    ;-- If needed, get the handle to the default GUI font
    if (DllCall("GetObjectType","Ptr",hFont)<>OBJ_FONT)
        hFont:=DllCall("GetStockObject","Int",DEFAULT_GUI_FONT)

    ;-- Collect font name and font options
    l_FontName   :=Fnt_GetFontName(hFont)
    l_FontOptions:=Fnt_GetFontOptions(hFont)

    ;-- Extract size from the options
    l_Size:=Fnt_FOGetSize(l_FontOptions,10)  ;-- 10 is the fail-safe default

    ;-- Bounce if p_String is null
    if not StrLen(p_String)
        Return l_Size

    ;-- Get the width of the string with the current font
    l_Width:=Fnt_GetStringWidth(hFont,p_String)

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
        hFontTemp:=Fnt_CreateFont(l_FontName,l_FontOptions . " s" . l_Size)

        ;-- Collect the width of the string with the temporary font
        l_Width:=Fnt_GetStringWidth(hFontTemp,p_String)

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
; Function: Fnt_FontSizeToFitDT
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
; Remarks:
;
;   This function is the same as <Fnt_FontSizeToFit> except that "DrawText" is
;   used instead of "GetTextExtentPoint32" to measure the text size.  See
;   <Fnt_FontSizeToFit> for more information.
;
;-------------------------------------------------------------------------------
Fnt_FontSizeToFitDT(hFont,p_String,p_Width)
    {
    Static Dummy87103840
          ,DEFAULT_GUI_FONT:=17
          ,OBJ_FONT        :=6
          ,s_MaxFontSize   :=1500

    ;-- If needed, get the handle to the default GUI font
    if (DllCall("GetObjectType","Ptr",hFont)<>OBJ_FONT)
        hFont:=DllCall("GetStockObject","Int",DEFAULT_GUI_FONT)

    ;-- Collect font name and font options
    l_FontName   :=Fnt_GetFontName(hFont)
    l_FontOptions:=Fnt_GetFontOptions(hFont)

    ;-- Extract size from the options
    l_Size:=Fnt_FOGetSize(l_FontOptions,10)  ;-- 10 is the fail-safe default

    ;-- Bounce if p_String is null
    if not StrLen(p_String)
        Return l_Size

    ;-- Get the width of the string with the current font
    l_Width:=Fnt_GetStringWidthDT(hFont,p_String)

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
        hFontTemp:=Fnt_CreateFont(l_FontName,l_FontOptions . " s" . l_Size)

        ;-- Collect the width of the string with the temporary font
        l_Width:=Fnt_GetStringWidthDT(hFontTemp,p_String)

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
;   hFont - Handle to a logical font.  Set to null or 0 to use the default GUI
;       font.
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
    Static Dummy38515859
          ,s_MaxFontSize:=1500

          ;-- Device constants
          ,LOGPIXELSY:=90

    ;-- Create a temporary font using the specified height
    hTempFont1:=Fnt_CreateFont(Fnt_GetFontName(hFont),Fnt_GetFontOptions(hFont) . " h" . p_Height)

    ;-- Create a 2nd temporary font using the point size returned from the 1st
    ;   temporary font
    ;
    ;   Note: This step is necessary because the point size returned from the
    ;   1st temporary font may not exactly match to a point size because the
    ;   font was created by height, not by point size.  This step will create a
    ;   font with an exact point size match.  The height will be very close to
    ;   (or exactly the) requested height.
    hTempFont2:=Fnt_CreateFont(Fnt_GetFontName(hTempFont1),Fnt_GetFontOptions(hTempFont1))

    ;-- Collect font information
    l_FontName   :=Fnt_GetFontName(hTempFont2)
    l_FontOptions:=Fnt_GetFontOptions(hTempFont2)
    l_Height     :=Fnt_GetFontHeight(hTempFont2)

    ;-- Extract the size from the font options.  It may be different than the
    ;   requested size.
    l_Size:=Fnt_FOGetSize(l_FontOptions,10)  ;-- 10 is the fail-safe default

    ;-- Delete the temporary fonts
    Fnt_DeleteFont(hTempFont1)
    Fnt_DeleteFont(hTempFont2)

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
        hTempFont:=Fnt_CreateFont(l_FontName,l_FontOptions . " s" . l_Size)

        ;-- Collect the height of the temporary font
        l_Height:=Fnt_GetFontHeight(hTempFont)

        ;-- Collect the actual size of the new font
        ;   Note: For non-scalable fonts, the actual size of the font may be
        ;   different than the requested size.
        l_ActualSize:=Fnt_GetFontSize(hTempFont)

        ;-- Delete the temporary font
        Fnt_DeleteFont(hTempFont)

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

        ;-- Break if the actual point size has not changed in 8 iterations
        ;   Note: This can occur if using a non-scalable font
        if (l_NoSizeChangeCount>7)
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
Fnt_FODecrementSize(ByRef r_FO,p_DecrementValue:=1,p_MinSize:=1)
    {
    if l_Size:=Fnt_FOGetSize(r_FO)  ;-- Specified and value not zero (0)
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
;   Get the color name or RGB color value from the color option within a font
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
;       the Windows default text color, or null (the default) to indicate no
;       default color.  Example values: "Red", "FF23AB", "Default".
;
;   p_ColorName2RGB - If set to TRUE and the color option (or p_DefaultColor
;       if no color options are found) contains a valid color name (Ex:
;       "Fuchsia"), the color name is converted to a 6-digit RGB Hex value (Ex:
;       "FF00FF").
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
; Calls To Other Functions:
;
; * <Fnt_ColorName2RGB>
;
;-------------------------------------------------------------------------------
Fnt_FOGetColor(p_FO,p_DefaultColor:="",p_ColorName2RGB:=False)
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
    if (p_ColorName2RGB and StrLen(l_Color))
        if l_Color is not xDigit
            l_Color:=SubStr(Fnt_ColorName2RGB(l_Color),3)

    Return l_Color
    }

;------------------------------
;
; Function: Fnt_FOGetQuality
;
; Description:
;
;   Get the value of the last Quality option within a font options string.
;
; Type:
;
;   Helper function.
;
; Parameters:
;
;   p_FO - A string that contains font options in the AutoHotkey format.
;
;   p_DefaultQuality - The value returned if no "q"uality option has been
;       specified.  The default is 2 (Proof) which is the AutoHotkey default.
;
; Returns:
;
;   The quality specified by the last "q"uality option if found, otherwise the
;       value of the p_DefaultQuality parameter.
;
; Remarks:
;
;   If defined correctly, quality is an integer from 0 to 5.  See the static
;   variables in <Fnt_GetFontQuality> for a list of valid values.  However, the
;   value is stored in a single BYTE field and so any value from 0 to 255 can be
;   returned.  If a value greater than 255 is specified, the number is truncated
;   so that only the first byte of the value is returned.
;
;-------------------------------------------------------------------------------
Fnt_FOGetQuality(p_FO,p_DefaultQuality:=2)
    {
    l_Quality :=""
    l_FoundPos:=1
    Loop
        {
        if not l_FoundPos:=RegExMatch(A_Space . p_FO . A_Space,"i) q[0-9]+ ",l_REOutput,l_FoundPos)
            Break

        l_Quality:=SubStr(l_REOutput,3,-1)
        l_FoundPos+=StrLen(l_REOutput)-1
        }

    Return StrLen(l_Quality) ? l_Quality&0xFF:p_DefaultQuality
    }

;------------------------------
;
; Function: Fnt_FOGetSize
;
; Description:
;
;   Get the size value of the last size option within a font options string.
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
;       The default is 0.
;
;   p_IgnoreZero - See the *Ignore Zero* section for more information.
;
; Returns:
;
;   The size specified by the last "s"ize option if found and is not ignored,
;   otherwise the value of the p_DefaultSize parameter.
;
; Ignore Zero:
;
;   Zero (0) is a possible value for the "s"ize option in a font option string.
;   Ex: "s0 bold italic".  When used to create a font, a size of 0 will instruct
;   the font mapping algorithm to use a default height value.  It's not
;   discussed in the AutoHotkey documentation so it's use is tenuous at best.  A
;   few developers may use it because they know or figured out what it does but
;   most developers only specify a non-zero size.
;
;   The p_IgnoreZero parameter determines what happens if the p_FO parameter
;   contains a "s"ize option with a zero (0) value.
;
;   If the p_IgnoreZero parameter is set to TRUE (the default), a "s"ize
;   value of 0 is treated the same as if the p_FO parameter does not contain a
;   "s"ize option at all.  This only affects the use of the p_DefaultSize
;   parameter which is only used if the p_FO parameter does not contain a "s"ize
;   option.
;
;   If the p_IgnoreZero parameter is set to FALSE, a "s"ize value of 0 is
;   treated the same as any other size and will be returned as-is.  Note:
;   Setting the p_IgnoreZero parameter to FALSE without also setting the
;   p_DefaultSize to some non-zero value (Ex: -1) effectively does little
;   because 0 is returned when a "s"ize value of 0 is set _and_ when no "s"ize
;   option is specified.
;
;   Please note that if the font option string contains more than one "s"ize
;   option (Ex: "s12 bold s0"), only the last "s"ize option is used to
;   determine the size of the font or if a valid/usable "s"ize option has been
;   specified.
;
;-------------------------------------------------------------------------------
Fnt_FOGetSize(p_FO,p_DefaultSize:=0,p_IgnoreZero:=True)
    {
    l_Size    :=""
    l_FoundPos:=1
    Loop
        {
        if not l_FoundPos:=RegExMatch(A_Space . p_FO . A_Space,"i) s[0-9]+ ",l_REOutput,l_FoundPos)
            Break

        l_Size:=SubStr(l_REOutput,3,-1)
        l_FoundPos+=StrLen(l_REOutput)-1
        }

    if (l_Size=0 and p_IgnoreZero)
        l_Size:=""

    Return StrLen(l_Size) ? l_Size:p_DefaultSize
    }

;------------------------------
;
; Function: Fnt_FOGetWeight
;
; Description:
;
;   Get the weight value of the last weight option within a font options string.
;
; Type:
;
;   Helper function.
;
; Parameters:
;
;   p_FO - A string that contains font options in the AutoHotkey format.
;
;   p_DefaultWeight - The value returned if no "w"eight or "bold" option has
;       been specified.  The default is null.
;
; Returns:
;
;   The weight specified by the last "w"eight option if found or 700 if any
;   "bold" option is found after any "w"eight options, otherwise the value of
;   the p_DefaultWeight parameter.
;
; Remarks:
;
;   Since the weight value can be 0 (Ex: "w0"), testing the return value for a
;   TRUE/FALSE value will not always give the desired result.  Instead, check
;   for a null/not null value or check the length of the return value.
;
;-------------------------------------------------------------------------------
Fnt_FOGetWeight(p_FO,p_DefaultWeight:="")
    {
    l_Weight  :=""
    l_StartPos:=1
    Loop
        {
        l_FoundPos1:=RegExMatch(A_Space . p_FO . A_Space,"i) w[0-9]+ ",l_REOutput1,l_StartPos)
        l_FoundPos2:=RegExMatch(A_Space . p_FO . A_Space,"i) bold[a-z]* ",l_REOutput2,l_StartPos)

        if !l_FoundPos1 and !l_FoundPos2
            Break

        if (l_FoundPos1 and l_FoundPos1>l_FoundPos2)
            {
            l_Weight  :=SubStr(l_REOutput1,3,-1)
            l_StartPos:=l_FoundPos1+StrLen(l_REOutput1)-1
            }
         else
            {
            l_Weight  :=700
            l_StartPos:=l_FoundPos2+StrLen(l_REOutput2)-1
            }
        }

    Return StrLen(l_Weight) ? l_Weight:p_DefaultWeight
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
Fnt_FOIncrementSize(ByRef r_FO,p_IncrementValue:=1,p_MaxSize:=999)
    {
    l_Size:=Fnt_FOGetSize(r_FO,-1,False)  ;-- Set to -1 if "s"ize option is not specified
    if (l_Size>-1)
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
;-------------------------------------------------------------------------------
Fnt_FORemoveColor(ByRef r_FO)
    {
    Static s_RegExPattern:="i) c[0-9|a-z]+ "
    l_Count   :=0
    l_StartPos:=1
    Loop
        {
        if not l_StartPos:=RegExMatch(A_Space . r_FO . A_Space,s_RegExPattern,l_REOutput,l_StartPos)
            Break

        r_FO:=RegExReplace(A_Space . r_FO . A_Space,s_RegExPattern,A_Space,,1,l_StartPos)
        r_FO:=SubStr(r_FO,2,-1)
        l_Count++
        }

    Return l_Count ? True:False
    }

;------------------------------
;
; Function: Fnt_FORemoveQuality
;
; Description:
;
;   Removes all quality options from a font options string.
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
;   TRUE if at least one quality option was removed, otherwise FALSE.
;
;-------------------------------------------------------------------------------
Fnt_FORemoveQuality(ByRef r_FO)
    {
    Static s_RegExPattern:="i) q[0-9]+ "
    l_Count   :=0
    l_StartPos:=1
    Loop
        {
        if not l_StartPos:=RegExMatch(A_Space . r_FO . A_Space,s_RegExPattern,l_REOutput,l_StartPos)
            Break

        r_FO:=RegExReplace(A_Space . r_FO . A_Space,s_RegExPattern,A_Space,,1,l_StartPos)
        r_FO:=SubStr(r_FO,2,-1)
        l_Count++
        }

    Return l_Count ? True:False
    }

;------------------------------
;
; Function: Fnt_FORemoveWeight
;
; Description:
;
;   Removes all "w"eight and "bold" options from a font options string.
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
;   TRUE if at least one "w"eight or "bold" option was removed, otherwise FALSE.
;
;-------------------------------------------------------------------------------
Fnt_FORemoveWeight(ByRef r_FO)
    {
    Static Dummy99628051
          ,s_RegExPattern1:="i) w[0-9]+ "
          ,s_RegExPattern2:="i) bold[a-z]* "

    ;-- Remove all "w"eight options
    l_Count   :=0
    l_StartPos:=1
    Loop
        {
        if not l_StartPos:=RegExMatch(A_Space . r_FO . A_Space,s_RegExPattern1,l_REOutput,l_StartPos)
            Break

        r_FO:=RegExReplace(A_Space . r_FO . A_Space,s_RegExPattern1,A_Space,,1,l_StartPos)
        r_FO:=SubStr(r_FO,2,-1)
        l_Count++
        }

    ;-- Remove all "bold" options
    l_StartPos:=1
    Loop
        {
        if not l_StartPos:=RegExMatch(A_Space . r_FO . A_Space,s_RegExPattern2,l_REOutput,l_StartPos)
            Break

        r_FO:=RegExReplace(A_Space . r_FO . A_Space,s_RegExPattern2,A_Space,,1,l_StartPos)
        r_FO:=SubStr(r_FO,2,-1)
        l_Count++
        }

    Return l_Count ? True:False
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
;   p_Color - Color value.  This can be one of 16 color names (Ex: "Blue"),
;       "Default" to indicate the system default text color, a 6-digit
;       hexadecimal RGB color value (Ex: "FF00FA"), or a 6-digit hexadecimal RGB
;       color number (Ex: 0xAABBCC).  See the AutoHotkey documentation for a
;       list of supported color names
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
; Function: Fnt_FOSetQuality
;
; Description:
;
;   Sets or replaces all quality options within a font options string.
;
; Type:
;
;   Helper function.
;
; Parameters:
;
;   r_FO - Variable that contains font options in the AutoHotkey format.
;
;   p_Quality - Font quality to set.
;
; Calls To Other Functions:
;
; * <Fnt_FOGetQuality>
;
; Remarks:
;
;   No changes are made if p_Quality does not contain a positive integer value.
;
;-------------------------------------------------------------------------------
Fnt_FOSetQuality(ByRef r_FO,p_Quality)
    {
    Static s_RegExPattern:="i) q[0-9]+ "

    ;-- Bounce if not a positive integer value
    p_Quality:=Trim(p_Quality," `f`n`r`t`v")
        ;-- Remove all leading/trailing white space

    if p_Quality is not Integer
        return

    if (p_Quality<0)
        return

    ;-- If a "q"uality option has not set, add to the end
    if (Fnt_FOGetQuality(r_FO,-1)=-1)
        {
        r_FO.=(StrLen(r_FO) ? A_Space:"") . "q" . p_Quality
        return
        }

    ;-- Update all "q"uality options
    l_StartPos:=1
    Loop
        {
        if not l_StartPos:=RegExMatch(A_Space . r_FO . A_Space,s_RegExPattern,l_REOutput,l_StartPos)
            Break

        ;-- Replace
        r_FO:=RegExReplace(A_Space . r_FO . A_Space,s_RegExPattern,A_Space . "q" . p_Quality . A_Space,l_Count,1,l_StartPos)

        ;-- Remove leading and trailing spaces
        r_FO:=SubStr(r_FO,2,-1)

        ;-- Update start position
        l_StartPos+=StrLen(A_Space . "q" . p_Quality)
        }
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
;   No changes are made if p_Size does not contain a positive integer value.
;
;-------------------------------------------------------------------------------
Fnt_FOSetSize(ByRef r_FO,p_Size)
    {
    Static s_RegExPattern:="i) s[0-9]+ "

    ;-- Bounce if not a positive integer value
    p_Size:=Trim(p_Size," `f`n`r`t`v")
        ;-- Remove all leading/trailing white space

    if p_Size is not Integer
        return

    if (p_Size<0)
        return

    ;-- If a "s"ize option has not been set, add to the end
    if (Fnt_FOGetSize(r_FO,-1,False)=-1)
        {
        r_FO.=(StrLen(r_FO) ? A_Space:"") . "s" . p_Size
        return
        }

    ;-- Update all "s"ize options
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
; Function: Fnt_FOSetWeight
;
; Description:
;
;   Sets or replaces all weight options within a font options string.
;
; Type:
;
;   Helper function.
;
; Parameters:
;
;   r_FO - Variable that contains font options in the AutoHotkey format.
;
;   p_Weight - Weight to set.  Ex: 500.  This must be an integer between 0 and
;       1000.
;
; Calls To Other Functions:
;
; * <Fnt_FOGetWeight>
;
; Remarks:
;
;   "bold" is considered a weight option (equivalent to "w700") and is replaced
;   if found.
;
;-------------------------------------------------------------------------------
Fnt_FOSetWeight(ByRef r_FO,p_Weight)
    {
    Static Dummy99628051
          ,s_RegExPattern1:="i) w[0-9]+ "
          ,s_RegExPattern2:="i) bold[a-z]* "

    ;-- Bounce if not a positive integer value
    p_Weight:=Trim(p_Weight," `f`n`r`t`v")
        ;-- Remove all leading/trailing white space

    if p_Weight is not Integer
        return

    if p_Weight not Between 0 and 1000
        return

    ;-- If a "w"eight or "bold" option not specified, append "w"eight option to
    ;   the end
    if (Fnt_FOGetWeight(r_FO)="")
        {
        r_FO.=(StrLen(r_FO) ? A_Space:"") . "w" . p_Weight
        return
        }

    ;-- Update all "w"eight font options
    l_StartPos:=1
    Loop
        {
        if not l_StartPos:=RegExMatch(A_Space . r_FO . A_Space,s_RegExPattern1,l_REOutput,l_StartPos)
            Break

        ;-- Replace
        r_FO:=RegExReplace(A_Space . r_FO . A_Space,s_RegExPattern1,A_Space . "w" . p_Weight . A_Space,l_Count,1,l_StartPos)

        ;-- Remove leading and trailing spaces
        r_FO:=SubStr(r_FO,2,-1)

        ;-- Update start position
        l_StartPos+=StrLen(A_Space . "w" . p_Weight)
        }

    ;-- Update all "bold" font options
    l_StartPos:=1
    Loop
        {
        if not l_StartPos:=RegExMatch(A_Space . r_FO . A_Space,s_RegExPattern2,l_REOutput,l_StartPos)
            Break

        ;-- Replace
        r_FO:=RegExReplace(A_Space . r_FO . A_Space,s_RegExPattern2,A_Space . "w" . p_Weight . A_Space,l_Count,1,l_StartPos)

        ;-- Remove leading and trailing spaces
        r_FO:=SubStr(r_FO,2,-1)

        ;-- Update start position
        l_StartPos+=StrLen(A_Space . "w" . p_Weight)
        }
    }

;------------------------------
;
; Function: Fnt_GetAverageCharWidth
;
; Description:
;
;   Calculates the average width of characters in a font.
;
; Parameters:
;
;   hFont - Handle to a logical font.  Set to null or 0 to use the default GUI
;       font.
;
; Returns:
;
;   The average width of characters in the font, in pixels.
;
; Calls To Other Functions:
;
; * <Fnt_GetStringWidth>
;
; Remarks:
;
;   This function should not be confused with <Fnt_GetFontAvgCharWidth> which
;   returns the average character width as defined by the font's designer which
;   is usually the width of the letter "x".  Although the results are similar,
;   this function uses a Microsoft calculation which generates a consistent
;   result regardless of the font.  Also note that this function returns the
;   same value as the r_HorzDBUs output parameter of <Fnt_GetDialogBaseUnits>
;   which contains the horizontal base units for the font.
;
;   The value returned by this function can be used to calculate the default tab
;   stop size for several common controls (Edit, ListBox, RichEdit, others?).
;   For these controls, the default tab stop size is the font's calculated
;   average character width times 8. Ex: Fnt_GetAverageCharWidth(hFont)*8.
;
;-------------------------------------------------------------------------------
Fnt_GetAverageCharWidth(hFont)
    {
    l_StringW:=Fnt_GetStringWidth(hFont,"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz")
    Return Floor((l_StringW/26+1)/2)
    }

;------------------------------
;
; Function: Fnt_GetCaptionFontName
;
; Description:
;
;   Returns the font name of the caption font.
;
; Calls To Other Functions:
;
; * <Fnt_GetNonClientMetrics>
;
; Remarks:
;
;   This function gets the font name of the caption font without creating
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
; Function: Fnt_GetCaptionFontOptions
;
; Description:
;
;   Returns the font options of the caption font.
;
; Type:
;
;   Helper function.
;
; Calls To Other Functions:
;
; * <Fnt_CreateCaptionFont>
; * <Fnt_DeleteFont>
; * <Fnt_GetFontOptions>
;
; Remarks:
;
;   This function converts the steps needed to collect the font options of the
;   caption font into a single function call.
;
;-------------------------------------------------------------------------------
Fnt_GetCaptionFontOptions()
    {
    hFont:=Fnt_CreateCaptionFont()
    l_Options:=Fnt_GetFontOptions(hFont)
    Fnt_DeleteFont(hFont)
    Return l_Options
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

    ;-- Get the number of pixels per logical inch along the screen height
    hDC:=DllCall("CreateDC","Str","DISPLAY","Ptr",0,"Ptr",0,"Ptr",0)
    l_LogPixelsY:=DllCall("GetDeviceCaps","Ptr",hDC,"Int",LOGPIXELSY)
    DllCall("DeleteDC","Ptr",hDC)

    ;-- Get the height for the Caption font
    ;   Note: The height collected from the non-client metrics is negative which
    ;   indicates that the absolute value is the em height of the font.  Em
    ;   height is the cell height less internal leading.  Having font's em
    ;   height allows the conversion to point size to be accurate.
    l_EmHeight:=Abs(NumGet(Fnt_GetNonClientMetrics()+24,0,"Int"))

    ;-- Convert em height to point size
    Return Round(l_EmHeight*72/l_LogPixelsY)
    }

;------------------------------
;
; Function: Fnt_GetBoldGUIFont
;
; Description:
;
;   Returns the handle to a font that has the same attributes as the default GUI
;   font but with a weight of 700, i.e. bold.
;
; Type:
;
;   Helper function.
;
; Calls To Other Functions:
;
; * <Fnt_CreateFont>
;
; Remarks:
;
;   The font created by this function has the same attributes of the font
;   created by AutoHotkey if the following command(s) are used:
;
;       (start code)
;       gui Font       ;-- Only needed if a previous Font command was used
;       gui Font,Bold
;       (end)
;
;   This helper function creates and reuses a single logical font.  If the font
;   is deleted (intentionally or otherwise), a new font is automatically created
;   the next time the function is called.
;
; Programming Note:
;
;   This function depends on the <Fnt_CreateFont> function and the font that is
;   created when default parameter values are specified.  If the default
;   behavior of Fnt_CreateFont is modified, this function may need to be
;   modified as well.
;
;-------------------------------------------------------------------------------
Fnt_GetBoldGUIFont()
    {
    Static Dummy85967096
          ,OBJ_FONT:=6
          ,hFont

    if (DllCall("GetObjectType","Ptr",hFont)<>OBJ_FONT)
        hFont:=Fnt_CreateFont("","bold")

    Return hFont
    }

;------------------------------
;
; Function: Fnt_GetDefaultGUIFont
;
; Description:
;
;   Returns the handle to the default GUI font.
;
; Remarks:
;
;   The default GUI font is a stock font.  It is created and maintained by the
;   OS.  It is not necessary (but it is not harmful) to delete stock objects.
;
;   For many Fnt library functions, the default GUI font is automatically used
;   if the hFont parameter is zero, null, or unspecified.
;
;-------------------------------------------------------------------------------
Fnt_GetDefaultGUIFont()
    {
    Static DEFAULT_GUI_FONT:=17
    Return DllCall("GetStockObject","Int",DEFAULT_GUI_FONT)
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
;   hFont - Handle to a logical font. Set to null or 0 to use the default GUI
;       font.
;
;   r_MarginX, r_MarginY - Output variables. [Optional] These variables are
;       loaded with the default margins (in pixels) for an AutoHotkey GUI.
;
;   p_DPIScale - Factor in the current display DPI into the default margin
;       calculations.  Set to TRUE (the default) to enable or FALSE to disable.
;
; Returns:
;
;   The address to a POINT structure.
;
; Calls To Other Functions:
;
; * <Fnt_GetFontSize>
;
; Remarks:
;
;   AutoHotkey documentation for GUI margins...
;
;   * <https://autohotkey.com/docs/commands/Gui.htm#DPIScale>
;
;   Important: On rare occasion, the margins returned from this function may not
;   match the actual GUI margins because the calculations are based on the
;   actual font size of control, not the requested font size.  For example, if
;   the developer uses the "gui Font" command to create a 24 point Courier (not
;   "Courier New") font, AutoHotkey will calculate margins based on this
;   font/size.  However, when the font is actually created, the 24 point size is
;   not available and so a Courier 15 point font is created instead.  So... the
;   actual margins (based on the _requested_ font/size) will not match the
;   calculated margins (based on the actual font/size).  Hint: Stick to scalable
;   fonts and this idiosyncrasy will never occur.
;
;   Starting with AutoHotkey v1.1.11, the formula to calculate the default GUI
;   margins was changed to always factor in the current display DPI.  The "gui
;   -DPIScale" command has no effect on this change.  The p_DPIScale parameter
;   instructs the function whether or not to factor in the current display DPI.
;   If set to TRUE (the default), the current display DPI is factored into the
;   calculation.  If set to FALSE, the default display DPI (96) is used.
;
;-------------------------------------------------------------------------------
Fnt_GetDefaultGUIMargins(hFont:="",ByRef r_MarginX:="",ByRef r_MarginY:="",p_DPIScale:=True)
    {
    Static Dummy91045657
          ,POINT

          ;-- Device constants
          ,LOGPIXELSX:=88
          ,LOGPIXELSY:=90

    ;-- Initialize
    VarSetCapacity(POINT,8,0)
    l_LogPixelsX:=96
    l_LogPixelsY:=96

    ;-- If needed, collect the current horizontal and vertical display DPI
    if p_DPIScale
        {
        hDC:=DllCall("CreateDC","Str","DISPLAY","Ptr",0,"Ptr",0,"Ptr",0)
        l_LogPixelsX:=DllCall("GetDeviceCaps","Ptr",hDC,"Int",LOGPIXELSX)
        l_LogPixelsY:=DllCall("GetDeviceCaps","Ptr",hDC,"Int",LOGPIXELSY)
        DllCall("DeleteDC","Ptr",hDC)
        }

    ;-- Calculate the default margins
    ;   Note: If hFont is null, zero, or unspecified, the font size for the
    ;   default GUI font is used
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
;   hFont - Handle to a logical font.  Set to null or 0 to use the default GUI
;       font.
;
;   r_HorzDBUs, r_VertDBUs - Output variables. [Optional] These variables are
;       loaded with the horizontal and vertical base units for the font.
;
; Returns:
;
;   The address to a SIZE structure.  The cx member of the SIZE structure
;   contains the horizontal dialog base units for the font.  The cy member
;   contains the vertical dialog base units.
;
; Calls To Other Functions:
;
; * <Fnt_GetStringSize>
;
; Remarks:
;
;   Unlike <Fnt_GetFontAvgCharWidth> which returns the average character width
;   as defined by the font's designer (usually the width of the letter "x"),
;   this function uses a Microsoft calculation which generates an accurate and
;   consistent result regardless of the font.
;
;-------------------------------------------------------------------------------
Fnt_GetDialogBaseUnits(hFont:="",ByRef r_HorzDBUs:="",ByRef r_VertDBUs:="")
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
;   Generate a list of uniquely-named font names.
;
; Parameters:
;
;   p_CharSet - Character set. [Optional].  If blank/null (the default), the
;       DEFAULT_CHARSET character set is used which will generate fonts from all
;       character sets.  See the function's static variables for a list of
;       possible values for this parameter.
;
;   p_Name - Font name. [Optional]  If blank/null (the default), one item
;       for every unique font name is generated.  If set to a font name,
;       that name is returned if valid.  Note: If specified, the font name
;       must be exact (not case sensitive).  A partial name will return nothing.
;
;   p_Flags - Flags to filter the list of font names that are returned.
;       [Optional] See the *Flags* section for more information.
;
; Returns:
;
;   A list of uniquely-named font names that match the font characteristics
;   specified by the parameters if successful, otherwise null. Font names are
;   delimited by the LF (Line Feed) character.
;
; Calls To Other Functions:
;
; * <Fnt_EnumFontFamExProc> (via callback)
;
; Flags:
;
;   The p_Flags parameter is used to filter the list of font names that are
;   returned.  This parameter can be a combination of any ChooseFont flag and a
;   Font Family value.  See the function's static variables for a list of
;   possible flag values.  Note: Only one Font Family value can be specified per
;   request.  The default is FF_DONTCARE.
;
; Programming Notes:
;
;   This function uses constants created for the ChooseFont dialog (constants
;   that begin with "CF_") and Font Family values (constants that begin with
;   "FF_") as possible values for the p_Flags parameter.  These constant names
;   and values are from Microsoft.  In addition, custom constant names/values
;   were created to support additional filter conditions.  The custom constant
;   names begin with "CF_" for consistency but they are clearly marked as
;   "custom".
;
;   The Font Family values are stored in the first 4 bits (0 through 3) of the
;   p_Flags parameter.  This only works because the Microsoft ChooseFont
;   constants that fit into this bit range are not used to filter the list of
;   font names.  Note that the Font Family constants contain a numeric
;   value, not bit flag values.  Unlike the ChooseFont bit flag values that can
;   can be combined, only one Font Family value can be specified per request.
;
;-------------------------------------------------------------------------------
Fnt_GetListOfFonts(p_CharSet:="",p_Name:="",p_Flags:=0)
    {
    Global Fnt_EnumFontFamExProc_List
    Static Dummy65612414

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
                ;-- [Future] Exclude font simulations.

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

          ,CF_FUTURE01:=0x40000000
                ;-- [Custom Flag]  Future.

          ,CF_FULLNAME:=0x80000000
                ;-- [Custom Flag, Advanced Feature]  If specified, returns the
                ;   full unique name of the font.  For example, ABC Font Company
                ;   TrueType Bold Italic Sans Serif.

          ;-- Font family
          ,FF_DONTCARE  :=0x0
          ,FF_ROMAN     :=0x1
          ,FF_SWISS     :=0x2
          ,FF_MODERN    :=0x3
          ,FF_SCRIPT    :=0x4
          ,FF_DECORATIVE:=0x5
          ,FF_NONE      :=0xF  ;-- Custom flag

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
        ,"UInt",0)                                      ;-- dwFlags (must be 0)

    DllCall("ReleaseDC","Ptr",HWND_DESKTOP,"Ptr",hDC)

    ;-- Sort, remove duplicates, and return
    Sort Fnt_EnumFontFamExProc_List,U
    Return Fnt_EnumFontFamExProc_List
    }

;------------------------------
;
; Function: Fnt_GetLastTooltip
;
; Description:
;
;   Get the handle to last created tooltip control (if any).
;
; Type:
;
;   Helper function.
;
; Returns:
;
;   The handle to last created tooltip control (tests as TRUE) if successful,
;   otherwise 0 (tests as FALSE).
;
; Remarks:
;
;   This function will return the handle to the last tooltip that was created.
;   If searching for the tooltip created by the AutoHotkey Tooltip command, this
;   function should be called immediately after the tooltip has been created.
;   For example:
;
;       (start code)
;       Tooltip Brown Chicken`, Brown Cow
;       hTT:=Fnt_GetLastTooltip()
;       (end)
;
;   After a tooltip control has been created, the same tooltip control is used
;   even if the tooltip text is updated many times.  The tooltip control is only
;   destroyed when the Tooltip command is called without specifying tooltip
;   text.  For example:
;
;       (start code)
;       Tooltip Brown Chicken                       ;-- New tooltip control is created
;       hTT:=Fnt_GetLastTooltip()                   ;-- The handle for the Tooltip control is collected
;       Sleep 2000
;       Tooltip Brown Cow
;           ;-- New text, same tooltip control.
;           ;   No need to get the handle to the
            ;   tooltip control again.
;       Sleep 2000
;       Tooltip                                     ;-- The Tooltip control is destroyed
;       (end)
;
;-------------------------------------------------------------------------------
Fnt_GetLastTooltip()
    {
    ;-- Initialize
    hTT:=0

    ;-- Get the current process ID
    Process Exist
    ScriptPID:=ErrorLevel

    ;-- Find the first (last created) tooltip
    WinGet IDList,List,ahk_pid %ScriptPID%
    Loop %IDList%
        {
        WinGetClass Class,% "ahk_ID " . IDList%A_Index%
        if (Class="tooltips_class32")
            {
            hTT:=IDList%A_Index%
            Break
            }
        }

    Return hTT
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
;   hFont - Handle to a logical font.  Set to null or 0 to use the default GUI
;       font.
;
;   p_String* - Zero or more parameters containing a string, an array of
;       strings, a list of strings delimited by end-of-line character(s) (see
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
    Static Dummy89695054
          ,DEFAULT_GUI_FONT:=17
          ,HWND_DESKTOP    :=0
          ,OBJ_FONT        :=6
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
    if (DllCall("GetObjectType","Ptr",hFont)<>OBJ_FONT)
        hFont:=DllCall("GetStockObject","Int",DEFAULT_GUI_FONT)

    ;-- Select the font into the device context for the desktop
    hDC      :=DllCall("GetDC","Ptr",HWND_DESKTOP)
    old_hFont:=DllCall("SelectObject","Ptr",hDC,"Ptr",hFont)

    ;-- Determine the longest string
    For l_Key,l_String in ArrayOfStrings
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

    ;-- Release the objects needed by the GetTextExtentPoint32 function
    DllCall("SelectObject","Ptr",hDC,"Ptr",old_hFont)
        ;-- Necessary to avoid memory leak

    DllCall("ReleaseDC","Ptr",HWND_DESKTOP,"Ptr",hDC)

    ;-- Return to sender
    ErrorLevel:=l_LongestStringW
    Return l_LongestString
    }

;------------------------------
;
; Function: Fnt_GetLongestStringDT
;
; Description:
;
;   Determines the longest string (measured in pixels) from a list of strings.
;
; Remarks:
;
;   This function is the same as <Fnt_GetLongestString> except that "DrawText"
;   is used instead of "GetTextExtentPoint32" to measure the text size.  See
;   <Fnt_GetLongestString> for more information.
;
;-------------------------------------------------------------------------------
Fnt_GetLongestStringDT(hFont,p_String*)
    {
    Static Dummy97145054
          ,DEFAULT_GUI_FONT:=17
          ,HWND_DESKTOP    :=0
          ,OBJ_FONT        :=6

          ;-- DrawText format
          ,DT_NOCLIP:=0x100
                ;-- Draws without clipping.  DrawText is somewhat faster when
                ;   DT_NOCLIP is used.

          ,DT_CALCRECT:=0x400
                ;-- Determines the width and height of the rectangle.  The text
                ;   is not drawn.

          ,DT_NOPREFIX:=0x800
                ;-- Turns off processing of prefix characters.

          ,s_DTFormat:=DT_NOCLIP|DT_CALCRECT|DT_NOPREFIX

    ;-- Initialize
    l_LongestString :=""
    l_LongestStringW:=0
    ArrayOfStrings  :=[]

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
    if (DllCall("GetObjectType","Ptr",hFont)<>OBJ_FONT)
        hFont:=DllCall("GetStockObject","Int",DEFAULT_GUI_FONT)

    ;-- Select the font into the device context for the desktop
    hDC      :=DllCall("GetDC","Ptr",HWND_DESKTOP)
    old_hFont:=DllCall("SelectObject","Ptr",hDC,"Ptr",hFont)

    ;-- Create/Initialize the RECT structure
    VarSetCapacity(RECT,16,0)

    ;-- Determine the longest string
    For l_Key,l_String in ArrayOfStrings
        {
        DllCall("DrawText"
            ,"Ptr",hDC                                  ;-- hdc [in]
            ,"Str",l_String                             ;-- lpchText [in, out]
            ,"Int",StrLen(l_String)                     ;-- cchText [in]
            ,"Ptr",&RECT                                ;-- lprc [in, out]
            ,"UInt",s_DTFormat)                         ;-- uFormat [in]

        l_Width:=NumGet(RECT,8,"Int")                   ;-- right
        if (l_Width>l_LongestStringW)
            {
            l_LongestString :=l_String
            l_LongestStringW:=l_Width
            }
        }

    ;-- Release the objects needed by the DrawText function
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
;   the width of the letter "x").  This value does not include the overhang
;   required for bold or italic characters.
;
; Parameters:
;
;   hFont - Handle to a logical font.  Set to null or 0 to use the default GUI
;       font.
;
; Returns:
;
;   The average width of characters in the font, in pixels.
;
; Calls To Other Functions:
;
; * <Fnt_GetFontMetrics>
;
; Remarks:
;
;   This function should not be confused with <Fnt_GetAverageCharWidth> which
;   returns a calulcated average character width.  Although the values are
;   similar, this function returns a value as defined by the font's designer.
;
;   The value returned by this function can be used to calculate the tab stop
;   size for some common controls (Text, Tooltip, others?) and dialogs (MsgBox).
;   For these controls/dialogs, the tab stop size is the font's average
;   character width times 8.  Ex: Fnt_GetFontAvgCharWidth(hFont)*8.
;
;-------------------------------------------------------------------------------
Fnt_GetFontAvgCharWidth(hFont:="")
    {
    Return NumGet(Fnt_GetFontMetrics(hFont),20,"Int")
    }

;------------------------------
;
; Function: Fnt_GetFontEmHeight
;
; Description:
;
;   Retrieves the em height of characters in a font.
;
; Parameters:
;
;   hFont - Handle to a logical font.  Set to null or 0 to use the default GUI
;       font.
;
; Returns:
;
;   The em height of characters in the font.
;
; Calls To Other Functions:
;
; * <Fnt_GetFontMetrics>
;
;-------------------------------------------------------------------------------
Fnt_GetFontEmHeight(hFont:="")
    {
    pTM:=Fnt_GetFontMetrics(hFont)
    Return NumGet(pTM+0,0,"Int")-NumGet(pTM+0,12,"Int")
        ;-- Height - Internal Leading
    }

;------------------------------
;
; Function: Fnt_GetFontExternalLeading
;
; Description:
;
;   Retrieves the amount of extra leading space (if any) that an application
;   may add between rows.
;
; Parameters:
;
;   hFont - Handle to a logical font.  Set to null or 0 to use the default GUI
;       font.
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
Fnt_GetFontExternalLeading(hFont:="")
    {
    Return NumGet(Fnt_GetFontMetrics(hFont),16,"Int")
    }

;------------------------------
;
; Function: Fnt_GetFontHeight
;
; Description:
;
;   Retrieves the cell height (ascent + descent) of characters in a font.
;
; Parameters:
;
;   hFont - Handle to a logical font.  Set to null or 0 to use the default GUI
;       font.
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
Fnt_GetFontHeight(hFont:="")
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
;   hFont - Handle to a logical font.  Set to null or 0 to use the default GUI
;       font.
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
Fnt_GetFontInternalLeading(hFont:="")
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
;   hFont - Handle to a logical font.  Set to null or 0 to use the default GUI
;       font.
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
Fnt_GetFontMaxCharWidth(hFont:="")
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
;   hFont - Handle to a logical font.  Set to null or 0 to use the default GUI
;       font.
;
; Returns:
;
;   The address to a TEXTMETRIC structure.
;
;-------------------------------------------------------------------------------
Fnt_GetFontMetrics(hFont:="")
    {
    Static Dummy65966804
          ,DEFAULT_GUI_FONT:=17
          ,HWND_DESKTOP    :=0
          ,OBJ_FONT        :=6
          ,TEXTMETRIC

    ;-- If needed, get the handle to the default GUI font
    if (DllCall("GetObjectType","Ptr",hFont)<>OBJ_FONT)
        hFont:=DllCall("GetStockObject","Int",DEFAULT_GUI_FONT)

    ;-- Select the font into the device context for the desktop
    hDC      :=DllCall("GetDC","Ptr",HWND_DESKTOP)
    old_hFont:=DllCall("SelectObject","Ptr",hDC,"Ptr",hFont)

    ;-- Get the text metrics for the font
    VarSetCapacity(TEXTMETRIC,A_IsUnicode ? 60:56,0)
    DllCall("GetTextMetrics","Ptr",hDC,"Ptr",&TEXTMETRIC)

    ;-- Release the objects needed by the GetTextMetrics function
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
;   Retrieves the typeface name of the font.
;
; Parameters:
;
;   hFont - Handle to a logical font.  Set to null or 0 to use the default GUI
;       font.
;
; Returns:
;
;   The font name of the font.
;
;-------------------------------------------------------------------------------
Fnt_GetFontName(hFont:="")
    {
    Static Dummy87890484
          ,DEFAULT_GUI_FONT    :=17
          ,HWND_DESKTOP        :=0
          ,OBJ_FONT            :=6
          ,MAX_FONT_NAME_LENGTH:=32     ;-- In TCHARS

    ;-- If needed, get the handle to the default GUI font
    if (DllCall("GetObjectType","Ptr",hFont)<>OBJ_FONT)
        hFont:=DllCall("GetStockObject","Int",DEFAULT_GUI_FONT)

    ;-- Select the font into the device context for the desktop
    hDC      :=DllCall("GetDC","Ptr",HWND_DESKTOP)
    old_hFont:=DllCall("SelectObject","Ptr",hDC,"Ptr",hFont)

    ;-- Get the font name
    VarSetCapacity(l_FontName,MAX_FONT_NAME_LENGTH*(A_IsUnicode ? 2:1))
    DllCall("GetTextFace","Ptr",hDC,"Int",MAX_FONT_NAME_LENGTH,"Str",l_FontName)

    ;-- Release the objects needed by the GetTextFace function
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
;   hFont - Handle to a logical font.  Set to null or 0 to use the default GUI
;       font.
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
;   bold - Font weight is exactly 700, i.e. bold.
;
;   italic - Italic font.
;
;   q{Quality} - Output quality. Ex: q3.  See the function's static variables
;       for a list of possible quality values.  This option is only returned if
;       the quality value is not 2 (the AutoHotkey default).
;
;   s{SizeInPoints} - Font size in points.  For example: s12
;
;   strike - Strikeout font.
;
;   underline - Underlined font.
;
;   w{Weight} - Font weight (thickness or boldness), which is an integer between
;       1 and 1000.  Ex: w600.  This option is only returned if the weight is
;       not normal (400) and not bold (700).
;
;   If more than one option is included, it is delimited by a space.  For
;   example: s12 bold italic
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
Fnt_GetFontOptions(hFont:="")
    {
    Static Dummy89348980
          ,DEFAULT_GUI_FONT:=17
          ,OBJ_FONT        :=6

          ;-- Device constants
          ,LOGPIXELSY:=90

          ;-- Font quality
          ,DEFAULT_QUALITY       :=0
          ,DRAFT_QUALITY         :=1
          ,PROOF_QUALITY         :=2  ;-- AutoHotkey default
          ,NONANTIALIASED_QUALITY:=3
          ,ANTIALIASED_QUALITY   :=4
          ,CLEARTYPE_QUALITY     :=5

          ;-- Font weight
          ,FW_NORMAL:=400
          ,FW_BOLD  :=700

    ;-- If needed, get the handle to the default GUI font
    if (DllCall("GetObjectType","Ptr",hFont)<>OBJ_FONT)
        hFont:=DllCall("GetStockObject","Int",DEFAULT_GUI_FONT)

    ;-- Collect the number of pixels per logical inch along the screen height
    hDC:=DllCall("CreateDC","Str","DISPLAY","Ptr",0,"Ptr",0,"Ptr",0)
    l_LogPixelsY:=DllCall("GetDeviceCaps","Ptr",hDC,"Int",LOGPIXELSY)
    DllCall("DeleteDC","Ptr",hDC)

    ;-- Collect the text metrics for the font
    pTM:=Fnt_GetFontMetrics(hFont)

;;;;;    outputdebug % "Height from text metrics: " . NumGet(pTM+0,0,"Int")

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

    ;-- Quality
	VarSetCapacity(LOGFONT,A_IsUnicode ? 92:60,0)
	DllCall("GetObject","Ptr",hFont,"Int",A_IsUnicode ? 92:60,"Ptr",&LOGFONT)
    l_Quality:=NumGet(LOGFONT,26,"UChar")               ;-- lfQuality
    if (l_Quality<>PROOF_QUALITY)
        l_Options.=A_Space . "q" . l_Quality

    Return l_Options
    }

;------------------------------
;
; Function: Fnt_GetLogicalFontName
;
; Description:
;
;   Retrieves the typeface name of the font.  See the *Remarks* section for more
;   information.
;
; Type:
;
;   Helper/Debug.  Experimental (for now).  Subject to change.
;
; Parameters:
;
;   hFont - Handle to a logical font.  Set to null or 0 to use the default GUI
;       font.
;
; Returns:
;
;   Font options in the AutoHotkey "gui Font" format.  See the *Options* section
;   for more information.
;
; Remarks:
;
;   The return value is the typeface specified when the font was created by the
;   "CreateFont" or "CreateFontIndirect" API functions (can be null).  For stock
;   or non-client fonts, this typeface is set by the operating system.  This
;   typeface is used by the font mapping algorithm to find a physical font.  It
;   may or may not match the typeface of a font that has been installed on the
;   current computer.  This information might be useful when testing or
;   debugging.
;
;-------------------------------------------------------------------------------
Fnt_GetLogicalFontName(hFont)
    {
    Static Dummy46244566
          ,DEFAULT_GUI_FONT:=17
          ,LF_FACESIZE     :=32  ;-- In TCHARS
          ,OBJ_FONT        :=6
          ,sizeofLOGFONT   :=A_IsUnicode ? 92:60

    ;-- If needed, get the handle to the default GUI font
    if (DllCall("GetObjectType","Ptr",hFont)<>OBJ_FONT)
        hFont:=DllCall("GetStockObject","Int",DEFAULT_GUI_FONT)

    ;-- Get the font object
	VarSetCapacity(LOGFONT,sizeofLOGFONT,0)
	DllCall("GetObject","Ptr",hFont,"Int",sizeofLOGFONT,"Ptr",&LOGFONT)
    Return StrGet(&LOGFONT+28,LF_FACESIZE)
    }

;------------------------------
;
; Function: Fnt_GetLogicalFontOptions
;
; Description:
;
;   Retrieves the attributes of a logical font in the AutoHotkey "gui Font"
;   format.  See the *Remarks* section for more information.
;
; Type:
;
;   Helper/Debug.  Experimental (for now).  Subject to change.
;
; Parameters:
;
;   hFont - Handle to a logical font.  Set to null or 0 to use the default GUI
;       font.
;
; Returns:
;
;   Font options in the AutoHotkey "gui Font" format.  See the *Options* section
;   for more information.
;
; Options:
;
;   Font options returned by this function may include the following.
;
;   bold - Font weight is exactly 700, i.e. bold.
;
;   h{HeightInPixels} - Font height in pixels.  Ex: h20.  This option is only
;       returned if the font was created using the "h"eight option with a
;       positive value (Ex: "h30").  If is option is returned, the "s"ize
;       option is not returned.
;
;   italic - Italic font.
;
;   q{Quality} - Output quality. Ex: q3.  See the function's static variables
;       for a list of possible quality values.  This option is only returned if
;       the quality value is not 2 (the AutoHotkey default).
;
;   s{SizeInPoints} - Font size in points.  For example: s12
;
;   strike - Strikeout font.
;
;   underline - Underlined font.
;
;   w{Weight} - Font weight (thickness or boldness), which is an integer between
;       0 and 1000.  Ex: w600.  This option is only returned if the weight is
;       not normal (400) and not bold (700).
;
;   If more than one option is included, it is delimited by a space.  For
;   example: s12 bold italic
;
; Remarks:
;
;   These options represent the font attributes that were specified (explicitly
;   or by default) when the font was created by the "CreateFont" or
;   "CreateFontIndirect" API functions.  For stock or non-client fonts, these
;   options are set by the operating system.  These options are used by the font
;   mapping algorithm to find a physical font.  They may or may not match the
;   attributes of the physical font.  Some options are explicitly set to
;   default/don't care values to force the font mapping algorithm to find the
;   correct/best value for the font.  This information might be useful when
;   testing or debugging.
;
;   If the font was created using the Fnt library, it's possible that options
;   only supported by the Fnt library are returned.  For example, if the height
;   option was specified with a positive (and greater than 0) value when
;   creating the font (Ex: "h25"), this function will return the "h"eight option
;   instead of the "s"ize option.
;
;-------------------------------------------------------------------------------
Fnt_GetLogicalFontOptions(hFont:="")
    {
    Static Dummy71753384
          ,DEFAULT_GUI_FONT:=17
          ,OBJ_FONT        :=6
          ,sizeofLOGFONT   :=A_IsUnicode ? 92:60

          ;-- Device constants
          ,LOGPIXELSY:=90

          ;-- Font quality
          ,DEFAULT_QUALITY       :=0
          ,DRAFT_QUALITY         :=1
          ,PROOF_QUALITY         :=2  ;-- AutoHotkey default
          ,NONANTIALIASED_QUALITY:=3
          ,ANTIALIASED_QUALITY   :=4
          ,CLEARTYPE_QUALITY     :=5

          ;-- Font weight
          ,FW_NORMAL:=400
          ,FW_BOLD  :=700

    ;-- If needed, get the handle to the default GUI font
    if (DllCall("GetObjectType","Ptr",hFont)<>OBJ_FONT)
        hFont:=DllCall("GetStockObject","Int",DEFAULT_GUI_FONT)

    ;-- Get the font object
	VarSetCapacity(LOGFONT,sizeofLOGFONT,0)
	DllCall("GetObject","Ptr",hFont,"Int",sizeofLOGFONT,"Ptr",&LOGFONT)

    ;-- Height or Size (first and always included)
    l_Height:=NumGet(LOGFONT,0,"Int")                   ;-- lfHeight
    if (l_Height=0)
        l_Options:="s0"
     else if (l_Height>0)
        l_Options:="h" . l_Height
     else  ;-- Less than 0.  Absolute value is the em height of the font
        {
        ;-- Collect the number of pixels per logical inch along the screen height
        hDC:=DllCall("CreateDC","Str","DISPLAY","Ptr",0,"Ptr",0,"Ptr",0)
        l_LogPixelsY:=DllCall("GetDeviceCaps","Ptr",hDC,"Int",LOGPIXELSY)
        DllCall("DeleteDC","Ptr",hDC)

        ;-- Point size
        l_Options:="s" . Round((Abs(l_Height)*72)/l_LogPixelsY)
            ;-- (Em Height * 72) / LogPixelsY
        }

    ;-- Weight
    l_Weight:=NumGet(LOGFONT,16,"Int")                  ;-- lfWeight
    if (l_Weight=FW_BOLD)
        l_Options.=A_Space . "bold"
     else
        if (l_Weight<>FW_NORMAL)
            l_Options.=A_Space . "w" . l_Weight

    ;-- Italic
    if NumGet(LOGFONT,20,"UChar")                       ;-- lfItalic
        l_Options.=A_Space . "italic"

    ;-- Underline
    if NumGet(LOGFONT,21,"UChar")                       ;-- lfUnderline
        l_Options.=A_Space . "underline"

    ;-- Strikeout
    if NumGet(LOGFONT,22,"UChar")                       ;-- lfStrikeOut
        l_Options.=A_Space . "strike"

    ;-- Quality
    l_Quality:=NumGet(LOGFONT,26,"UChar")               ;-- lfQuality
    if (l_Quality<>PROOF_QUALITY)
        l_Options.=A_Space . "q" . l_Quality

    Return l_Options
    }

;------------------------------
;
; Function: Fnt_GetFontQuality
;
; Description:
;
;   Get the font's output quality.
;
; Parameters:
;
;   hFont - Handle to a logical font.  Set to null or 0 to use the default GUI
;       font.
;
; Returns:
;
;   The font's output quality.  This value defines how carefully the graphics
;   device interface (GDI) must attempt to match the logical font attributes to
;   those of an actual physical font.  See the function's static variables for a
;   list of possible quality values.
;
;-------------------------------------------------------------------------------
Fnt_GetFontQuality(hFont:="")
    {
    Static Dummy96380605
          ,DEFAULT_GUI_FONT:=17
          ,OBJ_FONT        :=6
          ,sizeofLOGFONT   :=A_IsUnicode ? 92:60

          ;-- Font quality
          ,DEFAULT_QUALITY       :=0
          ,DRAFT_QUALITY         :=1
          ,PROOF_QUALITY         :=2  ;-- AutoHotkey default
          ,NONANTIALIASED_QUALITY:=3
          ,ANTIALIASED_QUALITY   :=4
          ,CLEARTYPE_QUALITY     :=5

    ;-- If needed, get the handle to the default GUI font
    if (DllCall("GetObjectType","Ptr",hFont)<>OBJ_FONT)
        hFont:=DllCall("GetStockObject","Int",DEFAULT_GUI_FONT)

    ;-- Get font quality
	VarSetCapacity(LOGFONT,sizeofLOGFONT,0)
	DllCall("GetObject","Ptr",hFont,"Int",sizeofLOGFONT,"Ptr",&LOGFONT)
    Return NumGet(LOGFONT,26,"UChar")                   ;-- lfQuality
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
;   hFont - Handle to a logical font.  Set to null or 0 to use the default GUI
;       font.
;
; Returns:
;
;   The point size of the font.
;
;-------------------------------------------------------------------------------
Fnt_GetFontSize(hFont:="")
    {
    Static Dummy64998752

          ;-- Device constants
          ,HWND_DESKTOP:=0
          ,LOGPIXELSY  :=90

          ;-- Misc.
          ,DEFAULT_GUI_FONT:=17
          ,OBJ_FONT        :=6

    ;-- If needed, get the handle to the default GUI font
    if (DllCall("GetObjectType","Ptr",hFont)<>OBJ_FONT)
        hFont:=DllCall("GetStockObject","Int",DEFAULT_GUI_FONT)

    ;-- Select the font into the device context for the desktop
    hDC      :=DllCall("GetDC","Ptr",HWND_DESKTOP)
    old_hFont:=DllCall("SelectObject","Ptr",hDC,"Ptr",hFont)

    ;-- Collect the number of pixels per logical inch along the screen height
    l_LogPixelsY:=DllCall("GetDeviceCaps","Ptr",hDC,"Int",LOGPIXELSY)

    ;-- Get text metrics for the font
    VarSetCapacity(TEXTMETRIC,A_IsUnicode ? 60:56,0)
    DllCall("GetTextMetrics","Ptr",hDC,"Ptr",&TEXTMETRIC)

    ;-- Convert em height to point size
    l_Size:=Round((NumGet(TEXTMETRIC,0,"Int")-NumGet(TEXTMETRIC,12,"Int"))*72/l_LogPixelsY)
        ;-- (Height - Internal Leading) * 72 / LogPixelsY

    ;-- Release the objects needed by the GetTextMetrics function
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
;   hFont - Handle to a logical font.  Set to null or 0 to use the default GUI
;       font.
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
Fnt_GetFontWeight(hFont:="")
    {
    Return NumGet(Fnt_GetFontMetrics(hFont),28,"Int")
    }

;------------------------------
;
; Function: Fnt_GetMenuFontName
;
; Description:
;
;   Returns the font name of the font used in menu bars.
;
; Calls To Other Functions:
;
; * <Fnt_GetNonClientMetrics>
;
; Remarks:
;
;   This function gets the font name of the font used in menu bars without
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

    ;-- Get the number of pixels per logical inch along the screen height
    hDC:=DllCall("CreateDC","Str","DISPLAY","Ptr",0,"Ptr",0,"Ptr",0)
    l_LogPixelsY:=DllCall("GetDeviceCaps","Ptr",hDC,"Int",LOGPIXELSY)
    DllCall("DeleteDC","Ptr",hDC)

    ;-- Get the height for the Menu font
    ;   Note: The height collected from the non-client metrics is negative which
    ;   indicates that the absolute value is the em height of the font.  Em
    ;   height is the cell height less internal leading.  Having font's em
    ;   height allows the conversion to point size to be accurate.
    l_EmHeight:=Abs(NumGet(Fnt_GetNonClientMetrics()+(A_IsUnicode ? 224:160),0,"Int"))

    ;-- Convert em height to point size
    Return Round(l_EmHeight*72/l_LogPixelsY)
    }

;------------------------------
;
; Function: Fnt_GetMenuFontOptions
;
; Description:
;
;   Returns the font options of the font that is used in menu bars.
;
; Type:
;
;   Helper function.
;
; Calls To Other Functions:
;
; * <Fnt_CreateMenuFont>
; * <Fnt_DeleteFont>
; * <Fnt_GetFontOptions>
;
; Remarks:
;
;   This function converts the steps needed to collect the font options of the
;   the font used in menu bars into a single function call.
;
;-------------------------------------------------------------------------------
Fnt_GetMenuFontOptions()
    {
    hFont:=Fnt_CreateMenuFont()
    l_Options:=Fnt_GetFontOptions(hFont)
    Fnt_DeleteFont(hFont)
    Return l_Options
    }

;------------------------------
;
; Function: Fnt_GetMessageFontName
;
; Description:
;
;   Returns the font name of the font that is used in message boxes.
;
; Calls To Other Functions:
;
; * <Fnt_GetNonClientMetrics>
;
; Remarks:
;
;   This function gets the font name of the font used in message boxes
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
; Function: Fnt_GetMessageFontOptions
;
; Description:
;
;   Returns the font options of the font that is used in message boxes.
;
; Type:
;
;   Helper function.
;
; Calls To Other Functions:
;
; * <Fnt_CreateMessageFont>
; * <Fnt_DeleteFont>
; * <Fnt_GetFontOptions>
;
; Remarks:
;
;   This function converts the steps needed to collect the font options of the
;   the font used in message boxes into a single function call.
;
;-------------------------------------------------------------------------------
Fnt_GetMessageFontOptions()
    {
    hFont:=Fnt_CreateMessageFont()
    l_Options:=Fnt_GetFontOptions(hFont)
    Fnt_DeleteFont(hFont)
    Return l_Options
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

    ;-- Get the number of pixels per logical inch along the screen height
    hDC:=DllCall("CreateDC","Str","DISPLAY","Ptr",0,"Ptr",0,"Ptr",0)
    l_LogPixelsY:=DllCall("GetDeviceCaps","Ptr",hDC,"Int",LOGPIXELSY)
    DllCall("DeleteDC","Ptr",hDC)

    ;-- Get the height for the Message font
    ;   Note: The height collected from the non-client metrics is negative which
    ;   indicates that the absolute value is the em height of the font.  Em
    ;   height is the cell height less internal leading.  Having font's em
    ;   height allows the conversion to point size to be accurate.
    l_EmHeight:=Abs(NumGet(Fnt_GetNonClientMetrics()+(A_IsUnicode ? 408:280),0,"Int"))

    ;-- Convert em height to point size
    Return Round(l_EmHeight*72/l_LogPixelsY)
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
;   hFont - Handle to a logical font.  Set to null or 0 to use the default GUI
;       font.
;
;   p_String - The multiline string to be measured.  See the
;       *End-Of-Line Character(s)* section for more information.
;
;   r_Width, r_Height - [Output, Optional] These variables are loaded with the
;       width and height of the string.
;
; Returns:
;
;   The address to a SIZE structure if successful, otherwise FALSE.
;
; Calls To Other Functions:
;
; * <Fnt_GetFontHeight>
;
; End-Of-Line Character(s):
;
;   This function uses the LF (line feed) and/or CR+LF (carriage return and line
;   feed) characters in the string as delimiters to logically break the string
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
;   This function is not deprecated but new functions introduced in v3.0 of the
;   library might be more appropriate for measuring text size.  See <Measuring
;   Text Size> for more information.
;
;-------------------------------------------------------------------------------
Fnt_GetMultilineStringSize(hFont,p_String,ByRef r_Width:="",ByRef r_Height:="")
    {
    Static Dummy47233892
          ,DEFAULT_GUI_FONT:=17
          ,HWND_DESKTOP    :=0
          ,OBJ_FONT        :=6
          ,SIZE

    ;-- Initialize
    r_Width :=0
    r_Height:=0
    VarSetCapacity(SIZE,8,0)
        ;-- Note: This structure is used by the "GetTextExtentPoint32"
        ;   function _and_ is used to store the width and height return values
        ;   of the function.


    ;-- Bounce if p_String is null.  All output values are zero.
    if not StrLen(p_String)
        Return &SIZE

    ;-- If needed, get the handle to the default GUI font
    if (DllCall("GetObjectType","Ptr",hFont)<>OBJ_FONT)
        hFont:=DllCall("GetStockObject","Int",DEFAULT_GUI_FONT)

    ;-- Select the font into the device context for the desktop
    hDC      :=DllCall("GetDC","Ptr",HWND_DESKTOP)
    old_hFont:=DllCall("SelectObject","Ptr",hDC,"Ptr",hFont)

    ;-- Determine the number of lines
    StringReplace p_String,p_String,`n,`n,UseErrorLevel
    l_LineCount:=ErrorLevel+1

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

    ;-- Release the objects needed by the GetTextExtentPoint32 function
    DllCall("SelectObject","Ptr",hDC,"Ptr",old_hFont)
        ;-- Necessary to avoid memory leak

    DllCall("ReleaseDC","Ptr",HWND_DESKTOP,"Ptr",hDC)

    ;-- Calculate the height
    r_Height:=Fnt_GetFontHeight(hFont)*l_LineCount

    ;-- Populate the SIZE structure
    NumPut(r_Width, SIZE,0,"Int")
    NumPut(r_Height,SIZE,4,"Int")
    Return &SIZE
    }

;------------------------------
;
; Function: Fnt_GetMultilineStringSizeDT
;
; Description:
;
;   Calculates the size of a multiline string for a font.
;
; Remarks:
;
;   This function is the same as <Fnt_GetMultilineStringSize> except that
;   "DrawText" is used instead of "GetTextExtentPoint32" to measure the text
;   size.  See <Fnt_GetMultilineStringSize> for more information.
;
;   This function is similar to <Fnt_GetSize>.  It is more efficient but has
;   less flexibility than <Fnt_GetSize>.
;
;-------------------------------------------------------------------------------
Fnt_GetMultilineStringSizeDT(hFont,p_String,ByRef r_Width:="",ByRef r_Height:="")
    {
    Static Dummy64026703
          ,DEFAULT_GUI_FONT:=17
          ,HWND_DESKTOP    :=0
          ,OBJ_FONT        :=6
          ,SIZE

          ;-- DrawText format
          ,DT_NOCLIP:=0x100
                ;-- Draws without clipping.  DrawText is somewhat faster when
                ;   DT_NOCLIP is used.

          ,DT_CALCRECT:=0x400
                ;-- Determines the width and height of the rectangle.  The text
                ;   is not drawn.

          ,DT_NOPREFIX:=0x800
                ;-- Turns off processing of prefix characters.

          ,s_DTFormat:=DT_NOCLIP|DT_CALCRECT|DT_NOPREFIX

    ;-- Initialize
    r_Width :=0
    r_Height:=0
    VarSetCapacity(SIZE,8,0)

    ;-- Bounce if p_String is null.  All return and output values are zero.
    if not StrLen(p_String)
        Return &SIZE

    ;-- If needed, get the handle to the default GUI font
    if (DllCall("GetObjectType","Ptr",hFont)<>OBJ_FONT)
        hFont:=DllCall("GetStockObject","Int",DEFAULT_GUI_FONT)

    ;-- Select the font into the device context for the desktop
    hDC      :=DllCall("GetDC","Ptr",HWND_DESKTOP)
    old_hFont:=DllCall("SelectObject","Ptr",hDC,"Ptr",hFont)

    ;-- Calculate the size of the string
    VarSetCapacity(RECT,16,0)
    DllCall("DrawText"
        ,"Ptr",hDC                                      ;-- hdc [in]
        ,"Str",p_String                                 ;-- lpchText [in, out]
        ,"Int",StrLen(p_String)                         ;-- cchText [in]
        ,"Ptr",&RECT                                    ;-- lprc [in, out]
        ,"UInt",s_DTFormat)                             ;-- uFormat [in]

    ;-- Release the objects needed by the DrawText function
    DllCall("SelectObject","Ptr",hDC,"Ptr",old_hFont)
        ;-- Necessary to avoid memory leak

    DllCall("ReleaseDC","Ptr",HWND_DESKTOP,"Ptr",hDC)

    ;-- Update the output variables and populate the SIZE structure
    NumPut(r_Width:=NumGet(RECT,8,"Int"),SIZE,0,"Int")
        ;-- right, cx

    NumPut(r_Height:=NumGet(RECT,12,"Int"),SIZE,4,"Int")
        ;-- bottom, cy

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
;   The address to a NONCLIENTMETRICS structure if successful, otherwise FALSE.
;
;-------------------------------------------------------------------------------
Fnt_GetNonClientMetrics()
    {
    Static Dummy15105062
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
;   Get the position and size of a GUI control.  See the *Remarks* section
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
;   If using a DPI setting that is smaller or larger than the default/standard
;   (Ex: 120 DPI, 144 DPI, or custom) _and_ if using the DPIScale feature
;   (AutoHotkey v1.1.11+, enabled by default), the values returned from the
;   *GUIControlGet,OutputVar,Pos* command will reflect the calculations that
;   were used by the DPIScale feature to create the control.  For example, if a
;   control were created with the "x20 y20 w500 h200" options and if using 120
;   DPI, the actual position and size of the control will be "x25 y25 w625
;   h250".  When the *GUIControlGet,OutputVar,Pos* command is used on this
;   control, it returns values that reflect the original "x20 y20 w500 h200"
;   options.  This function returns the _actual_ position and/or size of the
;   control regardless of the current display DPI.  It can be useful if the
;   current display DPI is unknown and/or the disposition of the DPIScale
;   feature is unknown.  In addition, this function works on all GUI controls
;   whereas the <GUIControlGet at
;   https://autohotkey.com/docs/commands/GuiControlGet.htm> command only works
;   on controls created using the AutoHotkey "gui Add" command.
;
;   The <ControlGetPos at
;   https://autohotkey.com/docs/commands/ControlGetPos.htm> and <WinGetPos at
;   https://autohotkey.com/docs/commands/WinGetPos.htm> commands are not
;   DPI-aware and so if only interested in the width and/or height values, these
;   commands can be used on GUI controls.  Hint: The native AutoHotkey commands
;   are more efficient and should be used whenever possible.
;
;-------------------------------------------------------------------------------
Fnt_GetPos(hControl,ByRef X:="",ByRef Y:="",ByRef Width:="",ByRef Height:="")
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

    ;-- Update output variables
    X:=NumGet(RECT,0,"Int")                             ;-- left
    Y:=NumGet(RECT,4,"Int")                             ;-- top
    }

;------------------------------
;
; Function: Fnt_GetSmCaptionFontName
;
; Description:
;
;   Returns the font name of the small caption font.
;
; Calls To Other Functions:
;
; * <Fnt_GetNonClientMetrics>
;
; Remarks:
;
;   This function gets the font name of the small caption font without
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
; Function: Fnt_GetSmCaptionFontOptions
;
; Description:
;
;   Returns the font options of the small caption font.
;
; Type:
;
;   Helper function.
;
; Calls To Other Functions:
;
; * <Fnt_CreateSmCaptionFont>
; * <Fnt_DeleteFont>
; * <Fnt_GetFontOptions>
;
; Remarks:
;
;   This function converts the steps needed to collect the font options of the
;   the small caption font into a single function call.
;
;-------------------------------------------------------------------------------
Fnt_GetSmCaptionFontOptions()
    {
    hFont:=Fnt_CreateSmCaptionFont()
    l_Options:=Fnt_GetFontOptions(hFont)
    Fnt_DeleteFont(hFont)
    Return l_Options
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

    ;-- Get the number of pixels per logical inch along the screen height
    hDC:=DllCall("CreateDC","Str","DISPLAY","Ptr",0,"Ptr",0,"Ptr",0)
    l_LogPixelsY:=DllCall("GetDeviceCaps","Ptr",hDC,"Int",LOGPIXELSY)
    DllCall("DeleteDC","Ptr",hDC)

    ;-- Get the height for the SmCaption font
    ;   Note: The height collected from the non-client metrics is negative which
    ;   indicates that the absolute value is the em height of the font.  Em
    ;   height is the cell height less internal leading.  Having font's em
    ;   height allows the conversion to point size to be accurate.
    l_EmHeight:=Abs(NumGet(Fnt_GetNonClientMetrics()+(A_IsUnicode ? 124:92),0,"Int"))

    ;-- Convert em height to point size
    Return Round(l_EmHeight*72/l_LogPixelsY)
    }

;------------------------------
;
; Function: Fnt_GetStatusFontName
;
; Description:
;
;   Returns the font name of the font used in status bars and tooltips.
;
; Calls To Other Functions:
;
; * <Fnt_GetNonClientMetrics>
;
; Remarks:
;
;   This function gets the font name of the font used in status bars and
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
; Function: Fnt_GetStatusFontOptions
;
; Description:
;
;   Returns the font options of the font that is used in status bars and
;   tooltips.
;
; Type:
;
;   Helper function.
;
; Calls To Other Functions:
;
; * <Fnt_CreateStatusFont>
; * <Fnt_DeleteFont>
; * <Fnt_GetFontOptions>
;
; Remarks:
;
;   This function converts the steps needed to collect the font options for the
;   status font into a single function call.
;
;-------------------------------------------------------------------------------
Fnt_GetStatusFontOptions()
    {
    hFont:=Fnt_CreateStatusFont()
    l_Options:=Fnt_GetFontOptions(hFont)
    Fnt_DeleteFont(hFont)
    Return l_Options
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

    ;-- Get the number of pixels per logical inch along the screen height
    hDC:=DllCall("CreateDC","Str","DISPLAY","Ptr",0,"Ptr",0,"Ptr",0)
    l_LogPixelsY:=DllCall("GetDeviceCaps","Ptr",hDC,"Int",LOGPIXELSY)
    DllCall("DeleteDC","Ptr",hDC)

    ;-- Get the height for the Status font
    ;   Note: The height collected from the non-client metrics is negative which
    ;   indicates that the absolute value is the em height of the font.  Em
    ;   height is the cell height less internal leading.  Having font's em
    ;   height allows the conversion to point size to be accurate.
    l_EmHeight:=Abs(NumGet(Fnt_GetNonClientMetrics()+(A_IsUnicode ? 316:220),0,"Int"))

    ;-- Convert em height to point size
    Return Round(l_EmHeight*72/l_LogPixelsY)
    }

;------------------------------
;
; Function: Fnt_GetTooltipFontName
;
; Description:
;
;   Returns the font name of the font used in tooltips.
;
; Calls To Other Functions:
;
; * <Fnt_GetNonClientMetrics>
;
; Remarks:
;
;   This function gets the font name of the font used in tooltips without
;   creating the font.
;
;   This function is a clone of <Fnt_GetStatusFontName>.
;
;-------------------------------------------------------------------------------
Fnt_GetTooltipFontName()
    {
    Static LF_FACESIZE:=32  ;-- In TCHARS
    Return StrGet(Fnt_GetNonClientMetrics()+(A_IsUnicode ? 316:220)+28,LF_FACESIZE)
    }

;------------------------------
;
; Function: Fnt_GetTooltipFontOptions
;
; Description:
;
;   Returns the font options of the font that is used in tooltips.
;
; Type:
;
;   Helper function.
;
; Calls To Other Functions:
;
; * <Fnt_CreateTooltipFont>
; * <Fnt_DeleteFont>
; * <Fnt_GetFontOptions>
;
; Remarks:
;
;   This function converts the steps needed to collect the font options for the
;   font that is used in tooltips into a single function call.
;
;-------------------------------------------------------------------------------
Fnt_GetTooltipFontOptions()
    {
    hFont:=Fnt_CreateTooltipFont()
    l_Options:=Fnt_GetFontOptions(hFont)
    Fnt_DeleteFont(hFont)
    Return l_Options
    }

;------------------------------
;
; Function: Fnt_GetTooltipFontSize
;
; Description:
;
;   Returns the point size of the font that is used in tooltips.
;
; Calls To Other Functions:
;
; * <Fnt_GetNonClientMetrics>
;
; Remarks:
;
;   This function calculates the point size of the font used in tooltips without
;   creating the font.
;
;   This function is a clone of <Fnt_GetStatusFontSize>.
;
;-------------------------------------------------------------------------------
Fnt_GetTooltipFontSize()
    {
    Static LOGPIXELSY:=90

    ;-- Get the number of pixels per logical inch along the screen height
    hDC:=DllCall("CreateDC","Str","DISPLAY","Ptr",0,"Ptr",0,"Ptr",0)
    l_LogPixelsY:=DllCall("GetDeviceCaps","Ptr",hDC,"Int",LOGPIXELSY)
    DllCall("DeleteDC","Ptr",hDC)

    ;-- Get the height for the Status font
    ;   Note: The height collected from the non-client metrics is negative which
    ;   indicates that the absolute value is the em height of the font.  Em
    ;   height is the cell height less internal leading.  Having font's em
    ;   height allows the conversion to point size to be accurate.
    l_EmHeight:=Abs(NumGet(Fnt_GetNonClientMetrics()+(A_IsUnicode ? 316:220),0,"Int"))

    ;-- Convert em height to point size
    Return Round(l_EmHeight*72/l_LogPixelsY)
    }

;------------------------------
;
; Function: Fnt_GetSize
;
; Description:
;
;   Calculates the width and height of text that will used in a GUI control.
;   See the *Remarks* section for more information.
;
; Parameters:
;
;   hFont - Handle to a logical font.  Set to null or 0 to use the default GUI
;       font.
;
;   p_Text - The string of text to be measured.
;
;   p_MaxW - The maximum width, in pixels, of the text. [Optional] See the
;       *Maximum Width* section for more information.
;
;   r_Width, r_Height - [Output, Optional] These variables are loaded with the
;       calculated width and height of the string.
;
; Returns:
;
;   The address to a SIZE structure.  The cx member contains the maximum width
;   of the text.  The cy member contains the height of the text.
;
; Maximum Width:
;
;   The optional p_MaxW parameter is used to set the maximum width, in pixels,
;   of the text contained in the p_Text parameter.  If unspecified, null, or
;   zero (0) (the default), the maximum width is entirely determined by the text
;   contained in the p_Text parameter which can contain end-of-line (EOL)
;   sequences (LF or CR+LF) to break the text into multiple lines.  If p_MaxW
;   contains a non-zero positive integer value, lines are automatically broken
;   between words if a word extends past the maximum width.  EOL character(s) in
;   the text also breaks the line.
;
; Remarks:
;
;   This is a general-purpose function to calculate the size of the text that
;   will be display in a GUI control.  It will work for most controls with the
;   following exceptions:  1) tab characters are not expanded and 2) prefix
;   characters (i.e. "&") are not processed.
;
;   Warning: If a very large amount of text is specified, the "DrawText" API
;   function may take an unusually long time to calculate the size.  If needed,
;   limit the amount of the text that is passed to this function.  Setting the
;   p_MaxW parameter to a reasonable limit (i.e. the width of the screen or
;   less) can also improve response when a very large amount of text is
;   specified.
;
;   Do not confuse this function with <Fnt_GetFontSize>.
;
;-------------------------------------------------------------------------------
Fnt_GetSize(hFont,p_Text,p_MaxW:=0,ByRef r_Width:="",ByRef r_Height:="")
    {
    Static Dummy53646684
          ,DEFAULT_GUI_FONT:=17
          ,HWND_DESKTOP    :=0
          ,MAXINT          :=0x7FFFFFFF
          ,OBJ_FONT        :=6
          ,SIZE

          ;-- DrawText formats
          ,DT_WORDBREAK:=0x10
                ;-- Breaks words.  Lines are automatically broken between words
                ;   if a word extends past the edge of the rectangle specified
                ;   by the lprc parameter.  A carriage return line feed sequence
                ;   also breaks the line.

          ,DT_NOCLIP:=0x100
                ;-- Draws without clipping.  DrawText is somewhat faster when
                ;   DT_NOCLIP is used.

          ,DT_CALCRECT:=0x400
                ;-- Determines the width and height of the rectangle.  The text
                ;   is not drawn.

          ,DT_NOPREFIX:=0x800
                ;-- Turns off processing of prefix characters.

          ,s_DTFormat:=DT_WORDBREAK|DT_NOCLIP|DT_CALCRECT|DT_NOPREFIX

    ;-- Initialize
    VarSetCapacity(SIZE,8,0)
    r_Width :=0
    r_Height:=0
    l_Width :=MAXINT
    if p_MaxW is Integer
        if (p_MaxW>0)
            l_Width:=p_MaxW

    ;-- Bounce if p_Text is null.  All output and return values are zero.
    if not StrLen(p_Text)
        Return &SIZE

    ;-- If needed, get the handle to the default GUI font
    if (DllCall("GetObjectType","Ptr",hFont)<>OBJ_FONT)
        hFont:=DllCall("GetStockObject","Int",DEFAULT_GUI_FONT)

    ;-- Create and populate the RECT structure
    VarSetCapacity(RECT,16,0)
    NumPut(l_Width,RECT,8,"Int")                       ;-- right

    ;-- Select the font into the device context for the desktop
    hDC      :=DllCall("GetDC","Ptr",HWND_DESKTOP)
    old_hFont:=DllCall("SelectObject","Ptr",hDC,"Ptr",hFont)

    ;-- DrawText
    DllCall("DrawText"
        ,"Ptr",hDC                                      ;-- hdc [in]
        ,"Str",p_Text                                   ;-- lpchText [in, out]
        ,"Int",-1                                       ;-- cchText [in]
        ,"Ptr",&RECT                                    ;-- lprc [in, out]
        ,"UInt",s_DTFormat)                             ;-- uFormat [in]

    ;-- Release the objects needed by the DrawText function
    DllCall("SelectObject","Ptr",hDC,"Ptr",old_hFont)
        ;-- Necessary to avoid memory leak

    DllCall("ReleaseDC","Ptr",HWND_DESKTOP,"Ptr",hDC)

    ;-- Update output variables and populate SIZE structure
    NumPut(r_Width:=NumGet(RECT,8,"Int"),SIZE,0,"Int")
        ;-- right, cx

    NumPut(r_Height:=NumGet(RECT,12,"Int"),SIZE,4,"Int")
        ;-- bottom, cy

    ;-- Return
    Return &SIZE
    }

;------------------------------
;
; Function: Fnt_GetSizeForButton
;
; Description:
;
;   Calculates the width and height of text that will used in a button control.
;   See the *Remarks* section for more information.
;
; Parameters:
;
;   hFont - Handle to a logical font.  Set to null or 0 to use the default GUI
;       font.
;
;   p_Text - The string of text to be measured.
;
;   p_MaxW - The maximum width, in pixels, of the string. [Optional] See the
;       *Maximum Width* section for more information.
;
;   r_Width, r_Height - [Output, Optional] These variables are loaded with the
;       calculated width and height of the string.
;
; Returns:
;
;   The address to a SIZE structure.  The cx member contains the maximum width
;   of the text.  The cy member contains the height of the text.
;
; Maximum Width:
;
;   The optional p_MaxW parameter is used to set the maximum width, in pixels,
;   of the text contained in the p_Text parameter.  If unspecified, null, or
;   zero (0) (the default), the maximum width is entirely determined by the text
;   contained in the p_Text parameter which can contain end-of-line (EOL)
;   sequences (LF or CR+LF) to break the text into multiple lines.  If p_MaxW
;   contains a non-zero positive integer value, lines are automatically broken
;   between words if a word extends past the maximum width.  EOL character(s) in
;   the text also breaks the line.
;
; Remarks:
;
;   This function is designed to  calculate the size of the text that will
;   displayed in a button control.  Buttons share some of the characteristics of
;   other multiline controls (Ex: Edit control) but they have some unique
;   characteristics which affect the size calculation.  These characteristics
;   include but are not limited to:
;
;    *  *Tabs*.  Tab characters are not expanded,
;
;    *  *Prefix*.  Prefix characters are processed.  The ampersand (&)
;       mnemonic-prefix character is a directive to underscore the character
;       that follows and the double-ampersand (&&) mnemonic-prefix characters is
;       a directive to draw a single ampersand.
;
;   This function can also be used to calculate the width of strings that will
;   be used in other controls that have similar characteristics (Ex: Menu) but
;   in most cases these controls do not support multiple lines and so the p_MaxW
;   parameter should not be set and the string should not contain EOL
;   characters.
;
;   Warning: If a very large amount of text is specified, the "DrawText" API
;   function may take an unusually long time to calculate the size.  If needed,
;   limit the amount of the text that is passed to this function.  Setting the
;   p_MaxW parameter to a reasonable limit (i.e. the width of the screen or
;   less) can also improve response when a very large amount of text is
;   specified.
;
;-------------------------------------------------------------------------------
Fnt_GetSizeForButton(hFont,p_Text,p_MaxW:=0,ByRef r_Width:="",ByRef r_Height:="")
    {
    Static Dummy13373556
          ,DEFAULT_GUI_FONT:=17
          ,HWND_DESKTOP    :=0
          ,MAXINT          :=0x7FFFFFFF
          ,OBJ_FONT        :=6
          ,SIZE

          ;-- DrawText formats
          ,DT_WORDBREAK:=0x10
                ;-- Breaks words.  Lines are automatically broken between words
                ;   if a word extends past the edge of the rectangle specified
                ;   by the lprc parameter.  A carriage return line feed sequence
                ;   also breaks the line.

          ,DT_NOCLIP:=0x100
                ;-- Draws without clipping.  DrawText is somewhat faster when
                ;   DT_NOCLIP is used.

          ,DT_CALCRECT:=0x400
                ;-- Determines the width and height of the rectangle.  The text
                ;   is not drawn.

          ,s_DTFormat:=DT_WORDBREAK|DT_NOCLIP|DT_CALCRECT

    ;-- Initialize
    VarSetCapacity(SIZE,8,0)
    r_Width :=0
    r_Height:=0
    l_Width :=MAXINT
    if p_MaxW is Integer
        if (p_MaxW>0)
            l_Width:=p_MaxW

    ;-- Bounce if p_Text is null.  All output and return values are zero.
    if not StrLen(p_Text)
        Return &SIZE

    ;-- If needed, get the handle to the default GUI font
    if (DllCall("GetObjectType","Ptr",hFont)<>OBJ_FONT)
        hFont:=DllCall("GetStockObject","Int",DEFAULT_GUI_FONT)

    ;-- Create and populate the RECT structure
    VarSetCapacity(RECT,16,0)
    NumPut(l_Width,RECT,8,"Int")                       ;-- right

    ;-- Select the font into the device context for the desktop
    hDC      :=DllCall("GetDC","Ptr",HWND_DESKTOP)
    old_hFont:=DllCall("SelectObject","Ptr",hDC,"Ptr",hFont)

    ;-- DrawText
    DllCall("DrawText"
        ,"Ptr",hDC                                      ;-- hdc [in]
        ,"Str",p_Text                                   ;-- lpchText [in, out]
        ,"Int",-1                                       ;-- cchText [in]
        ,"Ptr",&RECT                                    ;-- lprc [in, out]
        ,"UInt",s_DTFormat)                             ;-- uFormat [in]

    ;-- Release the objects needed by the DrawText function
    DllCall("SelectObject","Ptr",hDC,"Ptr",old_hFont)
        ;-- Necessary to avoid memory leak

    DllCall("ReleaseDC","Ptr",HWND_DESKTOP,"Ptr",hDC)

    ;-- Update output variables and populate SIZE structure
    NumPut(r_Width:=NumGet(RECT,8,"Int"),SIZE,0,"Int")
        ;-- right, cx

    NumPut(r_Height:=NumGet(RECT,12,"Int"),SIZE,4,"Int")
        ;-- bottom, cy

    Return &SIZE
    }

;------------------------------
;
; Function: Fnt_GetSizeForEdit
;
; Description:
;
;   Calculates the width and height of text that will used in an Edit control.
;   See the *Remarks* section for more information.
;
; Parameters:
;
;   hFont - Handle to a logical font.  Set to null or 0 to use the default GUI
;       font.
;
;   p_Text - The string of text to be measured.
;
;   p_MaxW - The maximum width, in pixels, of the string. [Optional] See the
;       *Maximum Width* section for more information.
;
;   r_Width, r_Height - [Output, Optional] These variables are loaded with the
;       calculated width and height of the string.
;
; Returns:
;
;   The address to a SIZE structure.  The cx member contains the maximum width
;   of the text.  The cy member contains the height of the text.
;
; Maximum Width:
;
;   The optional p_MaxW parameter is used to set the maximum width, in pixels,
;   of the text contained in the p_Text parameter.  If unspecified, null, or
;   zero (0) (the default), the maximum width is entirely determined by the text
;   contained in the p_Text parameter which can contain end-of-line (EOL)
;   sequences (LF or CR+LF) to break the text into multiple lines.  If p_MaxW
;   contains a non-zero positive integer value, lines are automatically broken
;   between words if a word extends past the maximum width.  EOL character(s) in
;   the text also breaks the line.
;
; Remarks:
;
;   This function is designed to calculate the size of the text that will
;   displayed in an Edit control.  The Edit control has spacing characteristics
;   that are unique to most other controls.  Some of these characteristics
;   include but are not limited to:
;
;    *  *Tabs*.  Tab characters are expanded to the default tab size.  The
;       average character width is calculated differently for the Edit control
;       than some other controls.
;
;   The calculated values returned by function do not factor in a left or right
;   margin or a custom tab stop size.  To include these factors in the
;   calculation, use <Fnt_CalculateSize> instead.
;
;   Warning: If a very large amount of text is specified, the "DrawText" API
;   function may take an unusually long time to calculate the size.  If needed,
;   limit the amount of the text that is passed to this function.  Setting the
;   p_MaxW parameter to a reasonable limit (i.e. the width of the screen or
;   less) can also improve response when a very large amount of text is
;   specified.
;
;-------------------------------------------------------------------------------
Fnt_GetSizeForEdit(hFont,p_Text,p_MaxW:=0,ByRef r_Width:="",ByRef r_Height:="")
    {
    Static Dummy13373556
          ,DEFAULT_GUI_FONT:=17
          ,HWND_DESKTOP    :=0
          ,MAXINT          :=0x7FFFFFFF
          ,OBJ_FONT        :=6
          ,SIZE

          ;-- DrawText formats
          ,DT_WORDBREAK:=0x10
                ;-- Breaks words.  Lines are automatically broken between words
                ;   if a word extends past the edge of the rectangle specified
                ;   by the lprc parameter.  A carriage return line feed sequence
                ;   also breaks the line.

          ,DT_EXPANDTABS:=0x40
                ;-- Expands tab characters. The default number of characters per
                ;   tab is eight.

          ,DT_NOCLIP:=0x100
                ;-- Draws without clipping.  DrawText is somewhat faster when
                ;   DT_NOCLIP is used.

          ,DT_CALCRECT:=0x400
                ;-- Determines the width and height of the rectangle.  The text
                ;   is not drawn.

          ,DT_NOPREFIX:=0x800
                ;-- Turns off processing of prefix characters.

          ,DT_EDITCONTROL:=0x2000
                ;-- Duplicates the text-displaying characteristics of a
                ;   multiline edit control.  Specifically, the average character
                ;   width is calculated in the same manner as for an Edit
                ;   control, and the function does not display a partially
                ;   visible last line.

          ,s_DTFormat:=DT_WORDBREAK|DT_EXPANDTABS|DT_NOCLIP|DT_CALCRECT|DT_NOPREFIX|DT_EDITCONTROL

    ;-- Initialize
    VarSetCapacity(SIZE,8,0)
    r_Width :=0
    r_Height:=0
    l_Width :=MAXINT
    if p_MaxW is Integer
        if (p_MaxW>0)
            l_Width:=p_MaxW

    ;-- Bounce if p_Text is null.  All output and return values are zero.
    if not StrLen(p_Text)
        Return &SIZE

    ;-- If needed, get the handle to the default GUI font
    if (DllCall("GetObjectType","Ptr",hFont)<>OBJ_FONT)
        hFont:=DllCall("GetStockObject","Int",DEFAULT_GUI_FONT)

    ;-- Create and populate the RECT structure
    VarSetCapacity(RECT,16,0)
    NumPut(l_Width,RECT,8,"Int")                       ;-- right

    ;-- Select the font into the device context for the desktop
    hDC      :=DllCall("GetDC","Ptr",HWND_DESKTOP)
    old_hFont:=DllCall("SelectObject","Ptr",hDC,"Ptr",hFont)

    ;-- DrawText
    DllCall("DrawText"
        ,"Ptr",hDC                                      ;-- hdc [in]
        ,"Str",p_Text                                   ;-- lpchText [in, out]
        ,"Int",-1                                       ;-- cchText [in]
        ,"Ptr",&RECT                                    ;-- lprc [in, out]
        ,"UInt",s_DTFormat)                             ;-- uFormat [in]

    ;-- Release the objects needed by the DrawText function
    DllCall("SelectObject","Ptr",hDC,"Ptr",old_hFont)
        ;-- Necessary to avoid memory leak

    DllCall("ReleaseDC","Ptr",HWND_DESKTOP,"Ptr",hDC)

    ;-- Update output variables and populate SIZE structure
    NumPut(r_Width:=NumGet(RECT,8,"Int"),SIZE,0,"Int")
        ;-- right, cx

    NumPut(r_Height:=NumGet(RECT,12,"Int"),SIZE,4,"Int")
        ;-- bottom, cy

    Return &SIZE
    }

;------------------------------
;
; Function: Fnt_GetSizeForText
;
; Description:
;
;   Calculates the width and height of text that will used in a static control
;   like the Text control.  See the *Remarks* section for more information.
;
; Parameters:
;
;   hFont - Handle to a logical font.  Set to null or 0 to use the default GUI
;       font.
;
;   p_Text - The string of text to be measured.
;
;   p_MaxW - The maximum width, in pixels, of the string. [Optional] See the
;       *Maximum Width* section for more information.
;
;   r_Width, r_Height - [Output, Optional] These variables are loaded with the
;       calculated width and height of the string.
;
; Returns:
;
;   The address to a SIZE structure.  The cx member contains the maximum width
;   of the text.  The cy member contains the height of the text.
;
; Maximum Width:
;
;   The optional p_MaxW parameter is used to set the maximum width, in pixels,
;   of the text contained in the p_Text parameter.  If unspecified, null, or
;   zero (0) (the default), the maximum width is entirely determined by the text
;   contained in the p_Text parameter which can contain end-of-line (EOL)
;   sequences (LF or CR+LF) to break the text into multiple lines.  If p_MaxW
;   contains a non-zero positive integer value, lines are automatically broken
;   between words if a word extends past the maximum width.  EOL character(s) in
;   the text also breaks the line.
;
; Remarks:
;
;   This function is designed to calculate the size of the text that will
;   displayed in a static control like the Text control.  Text controls share
;   some of the characteristics of other multiline controls (Ex: Edit control)
;   but they have some unique characteristics which affect the size calculation.
;   These characteristics include but are not limited to:
;
;    *  *Tabs*.  Tab characters are expanded.  Note: The default (and
;       only) tab stop size for a static control is different than the default
;       tab stop size for other GUI controls like the Edit control.
;
;   Warning: If a very large amount of text is specified, the "DrawText" API
;   function may take an unusually long time to calculate the size.  If needed,
;   limit the amount of the text that is passed to this function.  Setting the
;   p_MaxW parameter to a reasonable limit (i.e. the width of the screen or
;   less) can also improve response when a very large amount of text is
;   specified.
;
;-------------------------------------------------------------------------------
Fnt_GetSizeForText(hFont,p_Text,p_MaxW:=0,ByRef r_Width:="",ByRef r_Height:="")
    {
    Static Dummy30954994
          ,DEFAULT_GUI_FONT:=17
          ,HWND_DESKTOP    :=0
          ,MAXINT          :=0x7FFFFFFF
          ,OBJ_FONT        :=6
          ,SIZE

          ;-- DrawText formats
          ,DT_WORDBREAK:=0x10
                ;-- Breaks words.  Lines are automatically broken between words
                ;   if a word extends past the edge of the rectangle specified
                ;   by the lprc parameter.  A carriage return line feed sequence
                ;   also breaks the line.

          ,DT_EXPANDTABS:=0x40
                ;-- Expands tab characters. The default number of characters per
                ;   tab is eight.

          ,DT_NOCLIP:=0x100
                ;-- Draws without clipping.  DrawText is somewhat faster when
                ;   DT_NOCLIP is used.

          ,DT_CALCRECT:=0x400
                ;-- Determines the width and height of the rectangle.  The text
                ;   is not drawn.

          ,s_DTFormat:=DT_WORDBREAK|DT_EXPANDTABS|DT_NOCLIP|DT_CALCRECT

    ;-- Initialize
    VarSetCapacity(SIZE,8,0)
    r_Width :=0
    r_Height:=0
    l_Width :=MAXINT
    if p_MaxW is Integer
        if (p_MaxW>0)
            l_Width:=p_MaxW

    ;-- Bounce if p_Text is null.  All output and return values are zero.
    if not StrLen(p_Text)
        Return &SIZE

    ;-- If needed, get the handle to the default GUI font
    if (DllCall("GetObjectType","Ptr",hFont)<>OBJ_FONT)
        hFont:=DllCall("GetStockObject","Int",DEFAULT_GUI_FONT)

    ;-- Create and populate the RECT structure
    VarSetCapacity(RECT,16,0)
    NumPut(l_Width,RECT,8,"Int")                       ;-- right

    ;-- Select the font into the device context for the desktop
    hDC      :=DllCall("GetDC","Ptr",HWND_DESKTOP)
    old_hFont:=DllCall("SelectObject","Ptr",hDC,"Ptr",hFont)

    ;-- DrawText
    DllCall("DrawText"
        ,"Ptr",hDC                                      ;-- hdc [in]
        ,"Str",p_Text                                   ;-- lpchText [in, out]
        ,"Int",-1                                       ;-- cchText [in]
        ,"Ptr",&RECT                                    ;-- lprc [in, out]
        ,"UInt",s_DTFormat)                             ;-- uFormat [in]

    ;-- Release the objects needed by the DrawText function
    DllCall("SelectObject","Ptr",hDC,"Ptr",old_hFont)
        ;-- Necessary to avoid memory leak

    DllCall("ReleaseDC","Ptr",HWND_DESKTOP,"Ptr",hDC)

    ;-- Update output variables and populate SIZE structure
    NumPut(r_Width:=NumGet(RECT,8,"Int"),SIZE,0,"Int")
        ;-- right, cx

    NumPut(r_Height:=NumGet(RECT,12,"Int"),SIZE,4,"Int")
        ;-- bottom, cy

    Return &SIZE
    }

;------------------------------
;
; Function: Fnt_GetSizeForTextNoPrefix
;
; Description:
;
;   Calculates the width and height of text that will used in a static control
;   like the Text control.
;
; Remarks:
;
;   This function is the same as <Fnt_GetSizeForText> except that the
;   DT_NOPREFIX format is also used when calculating the size.  This can be
;   useful when the text is used on a text control that has the SS_NOPREFIX
;   style.  See <Fnt_GetSizeForText> for more information.
;
;-------------------------------------------------------------------------------
Fnt_GetSizeForTextNoPrefix(hFont,p_Text,p_MaxW:=0,ByRef r_Width:="",ByRef r_Height:="")
    {
    Static Dummy32227873
          ,DEFAULT_GUI_FONT:=17
          ,HWND_DESKTOP    :=0
          ,MAXINT          :=0x7FFFFFFF
          ,OBJ_FONT        :=6
          ,SIZE

          ;-- DrawText formats
          ,DT_WORDBREAK:=0x10
                ;-- Breaks words.  Lines are automatically broken between words
                ;   if a word extends past the edge of the rectangle specified
                ;   by the lprc parameter.  A carriage return line feed sequence
                ;   also breaks the line.

          ,DT_EXPANDTABS:=0x40
                ;-- Expands tab characters. The default number of characters per
                ;   tab is eight.

          ,DT_NOCLIP:=0x100
                ;-- Draws without clipping.  DrawText is somewhat faster when
                ;   DT_NOCLIP is used.

          ,DT_CALCRECT:=0x400
                ;-- Determines the width and height of the rectangle.  The text
                ;   is not drawn.

          ,DT_NOPREFIX:=0x800
                ;-- Turns off processing of prefix characters.

          ,s_DTFormat:=DT_WORDBREAK|DT_EXPANDTABS|DT_NOCLIP|DT_CALCRECT|DT_NOPREFIX

    ;-- Initialize
    VarSetCapacity(SIZE,8,0)
    r_Width :=0
    r_Height:=0
    l_Width :=MAXINT
    if p_MaxW is Integer
        if (p_MaxW>0)
            l_Width:=p_MaxW

    ;-- Bounce if p_Text is null.  All output and return values are zero.
    if not StrLen(p_Text)
        Return &SIZE

    ;-- If needed, get the handle to the default GUI font
    if (DllCall("GetObjectType","Ptr",hFont)<>OBJ_FONT)
        hFont:=DllCall("GetStockObject","Int",DEFAULT_GUI_FONT)

    ;-- Create and populate the RECT structure
    VarSetCapacity(RECT,16,0)
    NumPut(l_Width,RECT,8,"Int")                       ;-- right

    ;-- Select the font into the device context for the desktop
    hDC      :=DllCall("GetDC","Ptr",HWND_DESKTOP)
    old_hFont:=DllCall("SelectObject","Ptr",hDC,"Ptr",hFont)

    ;-- DrawText
    DllCall("DrawText"
        ,"Ptr",hDC                                      ;-- hdc [in]
        ,"Str",p_Text                                   ;-- lpchText [in, out]
        ,"Int",-1                                       ;-- cchText [in]
        ,"Ptr",&RECT                                    ;-- lprc [in, out]
        ,"UInt",s_DTFormat)                             ;-- uFormat [in]

    ;-- Release the objects needed by the DrawText function
    DllCall("SelectObject","Ptr",hDC,"Ptr",old_hFont)
        ;-- Necessary to avoid memory leak

    DllCall("ReleaseDC","Ptr",HWND_DESKTOP,"Ptr",hDC)

    ;-- Update output variables and populate SIZE structure
    NumPut(r_Width:=NumGet(RECT,8,"Int"),SIZE,0,"Int")
        ;-- right, cx

    NumPut(r_Height:=NumGet(RECT,12,"Int"),SIZE,4,"Int")
        ;-- bottom, cy

    Return &SIZE
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
;   hFont - Handle to a logical font.  Set to null or 0 to use the default GUI
;       font.
;
;   p_String - The string to be measured.
;
;   r_Width, r_Height - Output variables. [Optional] These variables are loaded
;       with the width and height of the string.
;
; Returns:
;
;   The address to a SIZE structure.  The cx member contains the width of the
;   string.  The cy member contains the height of the string.
;
; Remarks:
;
;   This function is designed to get the size of a single line of text.  End of
;   line (EOL) characters (LF or CR+LF) in the string are not considered when
;   calculating the height of the text.  Use <Fnt_GetMultilineStringSize> to get
;   the size of multiline text.
;
;   Tab characters are not expanded when calculating the size of text.  If
;   needed, use <Fnt_GetTabbedStringSize> instead.
;
;-------------------------------------------------------------------------------
Fnt_GetStringSize(hFont,p_String,ByRef r_Width:="",ByRef r_Height:="")
    {
    Static Dummy65968999
          ,DEFAULT_GUI_FONT:=17
          ,HWND_DESKTOP    :=0
          ,OBJ_FONT        :=6
          ,SIZE

    ;-- Initialize
    r_Width :=0
    r_Height:=0

    ;-- If needed, get the handle to the default GUI font
    if (DllCall("GetObjectType","Ptr",hFont)<>OBJ_FONT)
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

    ;-- Release the objects needed by the GetTextExtentPoint32 function
    DllCall("SelectObject","Ptr",hDC,"Ptr",old_hFont)
        ;-- Necessary to avoid memory leak

    DllCall("ReleaseDC","Ptr",HWND_DESKTOP,"Ptr",hDC)

    ;-- Update output variables and return
    if RC
        {
        r_Width :=NumGet(SIZE,0,"Int")
        r_Height:=NumGet(SIZE,4,"Int")
        }

    Return &SIZE
    }

;------------------------------
;
; Function: Fnt_GetStringSizeDT
;
; Description:
;
;   Calculates the width and height (in pixels) of a string of text.
;
; Remarks:
;
;   This function is the same as <Fnt_GetStringSize> except that "DrawText" is
;   used instead of "GetTextExtentPoint32" to measure the text size.  See
;   <Fnt_GetStringSize> for more information.
;
;-------------------------------------------------------------------------------
Fnt_GetStringSizeDT(hFont,p_String,ByRef r_Width:="",ByRef r_Height:="")
    {
    Static Dummy37499608
          ,DEFAULT_GUI_FONT:=17
          ,HWND_DESKTOP    :=0
          ,OBJ_FONT        :=6
          ,SIZE

          ;-- DrawText flags
          ,DT_SINGLELINE:=0x20
                ;-- Displays text on a single line only.  Carriage return and
                ;   line feed characters do not break the line.

          ,DT_NOCLIP:=0x100
                ;-- Draws without clipping.  DrawText is somewhat faster when
                ;   DT_NOCLIP is used.

          ,DT_CALCRECT:=0x400
                ;-- Determines the width and height of the rectangle.  The text
                ;   is not drawn.

          ,DT_NOPREFIX:=0x800
                ;-- Turns off processing of prefix characters.

          ,s_DTFormat:=DT_SINGLELINE|DT_NOCLIP|DT_CALCRECT|DT_NOPREFIX

    ;-- Initialize
    VarSetCapacity(SIZE,8,0)
    r_Width :=0
    r_Height:=0

    ;-- Bounce if p_String is null.  All output values are zero.
    if not StrLen(p_String)
        Return &SIZE

    ;-- If needed, get the handle to the default GUI font
    if (DllCall("GetObjectType","Ptr",hFont)<>OBJ_FONT)
        hFont:=DllCall("GetStockObject","Int",DEFAULT_GUI_FONT)

    ;-- Select the font into the device context for the desktop
    hDC      :=DllCall("GetDC","Ptr",HWND_DESKTOP)
    old_hFont:=DllCall("SelectObject","Ptr",hDC,"Ptr",hFont)

    ;-- Calculate the size of the string
    VarSetCapacity(RECT,16,0)
    DllCall("DrawText"
        ,"Ptr",hDC                                      ;-- hdc [in]
        ,"Str",p_String                                 ;-- lpchText [in, out]
        ,"Int",-1                                       ;-- cchText [in]
        ,"Ptr",&RECT                                    ;-- lprc [in, out]
        ,"UInt",s_DTFormat)                             ;-- uFormat [in]

    ;-- Release the objects needed by the DrawText function
    DllCall("SelectObject","Ptr",hDC,"Ptr",old_hFont)
        ;-- Necessary to avoid memory leak

    DllCall("ReleaseDC","Ptr",HWND_DESKTOP,"Ptr",hDC)

    ;-- Update the output variables and populate the SIZE structure
    NumPut(r_Width:=NumGet(RECT,8,"Int"),SIZE,0,"Int")
        ;-- right, cx

    NumPut(r_Height:=NumGet(RECT,12,"Int"),SIZE,4,"Int")
        ;-- bottom, cy

    Return &SIZE
    }

;------------------------------
;
; Function: Fnt_GetStringWidth
;
; Description:
;
;   Calculates the width (in pixels) of a string of text.
;
; Parameters:
;
;   hFont - Handle to a logical font.  Set to null or 0 to use the default GUI
;       font.
;
;   p_String - The string to be measured.
;
; Returns:
;
;   The width of the specified string, in pixels.
;
; Remarks:
;
;   This function is designed to get the width of a single line of text.  End of
;   line (EOL) characters (LF or CR+LF) in the string are not considered when
;   calculating the width of the text.  Use <Fnt_GetMultilineStringSize> or
;   <Fnt_GetSize> to get the size of multiline text.
;
;   Tab characters are not expanded when calculating the size of text.  This
;   library includes a number of functions that expand tab characters when
;   calculating the size of text. <Fnt_CalculateSize> is the most flexible but
;   there a number of other specialty functions that might be more useful.
;
;-------------------------------------------------------------------------------
Fnt_GetStringWidth(hFont,p_String)
    {
    Static Dummy88611714
          ,DEFAULT_GUI_FONT:=17
          ,HWND_DESKTOP    :=0
          ,OBJ_FONT        :=6

    ;-- If needed, get the handle to the default GUI font
    if (DllCall("GetObjectType","Ptr",hFont)<>OBJ_FONT)
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

    ;-- Release the objects needed by the GetTextExtentPoint32 function
    DllCall("SelectObject","Ptr",hDC,"Ptr",old_hFont)
        ;-- Necessary to avoid memory leak

    DllCall("ReleaseDC","Ptr",HWND_DESKTOP,"Ptr",hDC)

    ;-- Return width
    Return RC ? NumGet(SIZE,0,"Int"):0
    }

;------------------------------
;
; Function: Fnt_GetStringWidthDT
;
; Description:
;
;   Calculates the width (in pixels) of a string of text.
;
; Remarks:
;
;   This function is the same as <Fnt_GetStringWidth> except that "DrawText" is
;   used instead of "GetTextExtentPoint32" to measure the text size.  See
;   <Fnt_GetStringWidth> for more information.
;
;-------------------------------------------------------------------------------
Fnt_GetStringWidthDT(hFont,p_String)
    {
    Static Dummy54881201
          ,DEFAULT_GUI_FONT:=17
          ,HWND_DESKTOP    :=0
          ,OBJ_FONT        :=6

          ;-- DrawText flags
          ,DT_SINGLELINE:=0x20
                ;-- Displays text on a single line only.  Carriage return and
                ;   line feed characters do not break the line.

          ,DT_NOCLIP:=0x100
                ;-- Draws without clipping.  DrawText is somewhat faster when
                ;   DT_NOCLIP is used.

          ,DT_CALCRECT:=0x400
                ;-- Determines the width and height of the rectangle.  The text
                ;   is not drawn.

          ,DT_NOPREFIX:=0x800
                ;-- Turns off processing of prefix characters.

          ,s_DTFormat:=DT_SINGLELINE|DT_NOCLIP|DT_CALCRECT|DT_NOPREFIX

    ;-- Return 0 if string is null
    if not StrLen(p_String)
        Return 0

    ;-- If needed, get the handle to the default GUI font
    if (DllCall("GetObjectType","Ptr",hFont)<>OBJ_FONT)
        hFont:=DllCall("GetStockObject","Int",DEFAULT_GUI_FONT)

    ;-- Select the font into the device context for the desktop
    hDC      :=DllCall("GetDC","Ptr",HWND_DESKTOP)
    old_hFont:=DllCall("SelectObject","Ptr",hDC,"Ptr",hFont)

    ;-- Calculate the size of the string
    VarSetCapacity(RECT,16,0)
    DllCall("DrawText"
        ,"Ptr",hDC                                      ;-- hdc [in]
        ,"Str",p_String                                 ;-- lpchText [in, out]
        ,"Int",-1                                       ;-- cchText [in]
        ,"Ptr",&RECT                                    ;-- lprc [in, out]
        ,"UInt",s_DTFormat)                             ;-- uFormat [in]

    ;-- Release the objects needed by the DrawText function
    DllCall("SelectObject","Ptr",hDC,"Ptr",old_hFont)
        ;-- Necessary to avoid memory leak

    DllCall("ReleaseDC","Ptr",HWND_DESKTOP,"Ptr",hDC)

    ;-- Return width
    Return NumGet(RECT,8,"Int")                         ;-- right
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
;   The display element color in an AutoHotkey hexadecimal value.  Ex: 0x12FF7B.
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
; Function: Fnt_GetTabbedStringSize
;
; Description:
;
;   Calculates the width and height (in pixels) of a string of text.  If the
;   string contains one or more tab characters, the width of the string is based
;   upon the specified tab stops.
;
; Parameters:
;
;   hFont - Handle to a logical font.  Set to null or 0 to use the default GUI
;       font.
;
;   p_String - The string to be measured.
;
;   r_Width, r_Height - Output variables. [Optional] These variables are loaded
;       with the width and height of the string.
;
;   p_TabStops - Zero or more tab stop positions in pixels.  The tab stops must
;       be set in increasing order.  Ex: 125, 200, 295.  If no tab stop are
;       specified, tabs are expanded to eight times the average character width,
;       i.e. 32 dialog template units.  Note: This is the default tab stop size
;       of the Edit, ListBox, and some other controls.  If only one tab stop is
;       set, the tab stops are separated by the distance specified by the first
;       value. For example, setting p_TabStops to 111 is the equivalent of
;       setting p_TabStops to 111, 222, 333, etc.
;
; Returns:
;
;   The address to a SIZE structure.  The cx member contains the width of the
;   string.  The cy member contains the height of the string.
;
; Tab Stop Size:
;
;   This function sets the tab stop in pixels.  For some GUI controls and common
;   dialogs, the tab stop size is measured in pixels (Example: Text control and
;   MsgBox dialog). For other GUI controls (Ex: Edit, ListBox, etc.), the tab
;   stop is measured in dialog template units.  To ensure that this function
;   works correctly when the text is displayed on a GUI control that uses dialog
;   template units when setting the tab stop, the tab stop size should be an
;   exact factor of a dialog template unit for the specified font.
;
; Remarks:
;
;   This function is designed to get the size of a single line of text.  End of
;   line (EOL) characters (LF or CR+LF) in the string are not considered when
;   calculating the height of the text.
;
;   This function does not process prefix characters (i.e. "&").  If the string
;   contains prefix characters and is to used in a GUI control that processes
;   prefix characters (Ex: Text control without the SS_NOPREFIX style), the
;   calculated width will be incorrect.  In these cases, use a function that
;   process prefix characters (Ex: <Fnt_CalculateSize> or <Fnt_GetSizeForText>).
;
; Observations:
;
;   If the p_TabStops contains more than one tab stop, tab stop values for all
;   tabs defined in p_String must be specified, otherwise the default size, i.e.
;   8 average characters (32 dialog template units), is used for all tab stops.
;
;-------------------------------------------------------------------------------
Fnt_GetTabbedStringSize(hFont,p_String,ByRef r_Width:="",ByRef r_Height:="",p_TabStops*)
    {
    Static Dummy62475635
          ,DEFAULT_GUI_FONT:=17
          ,HWND_DESKTOP    :=0
          ,OBJ_FONT        :=6
          ,SIZE

    ;-- Initialize
    VarSetCapacity(SIZE,8,0)
    l_NbrOfTabPositions:=0
    l_TabStopPositions :=""

    r_Width :=0
    r_Height:=0

    ;-- Bounce if p_String is null.  All output and return values are zero.
    if not StrLen(p_String)
        Return &SIZE

    ;-- Parameters
    if p_TabStops.MaxIndex()  ;-- Not null
        {
        l_NbrOfTabPositions:=p_TabStops.MaxIndex()
        VarSetCapacity(l_TabStopPositions,p_TabStops.MaxIndex()*4,0)
        For l_Key,l_TabStop in p_TabStops
            NumPut(l_TabStop,l_TabStopPositions,4*(A_Index-1),"Int")
        }

    ;-- If needed, get the handle to the default GUI font
    if (DllCall("GetObjectType","Ptr",hFont)<>OBJ_FONT)
        hFont:=DllCall("GetStockObject","Int",DEFAULT_GUI_FONT)

    ;-- Select the font into the device context for the desktop
    hDC      :=DllCall("GetDC","Ptr",HWND_DESKTOP)
    old_hFont:=DllCall("SelectObject","Ptr",hDC,"Ptr",hFont)

    ;-- Get tabbed string size
    l_Size:=DllCall("GetTabbedTextExtent"
        ,"Ptr",hDC                                      ;-- hDC
        ,"Str",p_String                                 ;-- lpString
        ,"Int",StrLen(p_String)                         ;-- nCount
        ,"Int",l_NbrOfTabPositions                      ;-- nTabPositions
        ,"Ptr",&l_TabStopPositions)                     ;-- lpnTabStopPositions

    ;-- Release the objects needed by the GetTabbedTextExtent function
    DllCall("SelectObject","Ptr",hDC,"Ptr",old_hFont)
        ;-- Necessary to avoid memory leak

    DllCall("ReleaseDC","Ptr",HWND_DESKTOP,"Ptr",hDC)

    ;-- Update the output variables and populate SIZE control
    if l_Size  ;-- Not zero
        {
        NumPut(r_Width:=l_Size&0xFFFF,SIZE,0,"Int")
        NumPut(r_Height:=l_Size>>16,SIZE,4,"Int")
        }

    Return &SIZE
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
;   hFont - Handle to a logical font.  Set to null or 0 to use the default GUI
;       font.
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
;   each row, including the space between each row (external leading) if there
;   is more than one row.  This calculation was extracted from the AutoHotkey
;   source and is the same or similar calculation used by AutoHotkey when the
;   r{NumberOfRows} GUI option is used.  Note: This calculation does not include
;   any extra space that a GUI control may need in order to correctly display
;   the text in the control.  Ex: Edit control.
;
;   *Note*: Although this calculation is able to duplicate the same height as
;   the AutoHotkey r{NumberOfRows} GUI option, the result is inaccurate for most
;   (all?) GUI controls if the font contains a non-zero external leading value
;   and more than 1 row is specified.  See <Row Height> for more information.
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
; Calls To Other Functions:
;
; * <Fnt_GetSysColor>
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
; Calls To Other Functions:
;
; * <Fnt_GetSysColor>
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
; Function: Fnt_IsFont
;
; Description:
;
;   Determines if the hFont parameter contains the handle to valid logical font.
;
; Parameters:
;
;   hFont - Handle to a logical font.
;
; Returns:
;
;   TRUE if hFont contains the handle to valid logical font, otherwise FALSE.
;
; Remarks:
;
;   TRUE is returned if hFont contains the handle to a stock font (Ex: Default
;   GUI font).
;
;-------------------------------------------------------------------------------
Fnt_IsFont(hFont)
    {
    Static OBJ_FONT:=6
    Return (DllCall("GetObjectType","Ptr",hFont)=OBJ_FONT) ? True:False
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
;   hFont - Handle to a logical font.
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
;   The address to a SIZE structure.  The cx member of the SIZE structure
;   contains the horizontal dialog template units for the specified width.  The
;   cy member contains the vertical dialog template units for the specified
;   height.
;
; Calls To Other Functions:
;
; * <Fnt_GetDialogBaseUnits>
;
;-------------------------------------------------------------------------------
Fnt_Pixels2DialogTemplateUnits(hFont,p_Width,p_Height:=0,ByRef r_HorzDTUs:="",ByRef r_VertDTUs:="")
    {
    Static Dummy14616490
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


;-- ##### UC/Experimental
;-- ##### UC/Experimental
;-- ##### UC/Experimental
Fnt_PT2PX(p_PT)
    {
;;;;;    Return Round((p_PT*1.333333)*(A_ScreenDPI/96))
;;;;;    Return (p_PT*1.333333)*(A_ScreenDPI/96)
;;;;;    Return (p_PT*(96/72))
    Return (p_PT*(96/72))*(A_ScreenDPI/96)
    }

Fnt_PX2PT(p_PX)
    {
;;;;;    Return p_PX*72/96
    Return p_PX*72/A_ScreenDPI
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
Fnt_RemoveFontFile(p_File,p_Private,p_Hidden:=False)
    {
    Static Dummy97551939

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
; Function: Fnt_RGB2ColorName
;
; Description:
;
;   Convert a RGB value into one of 16 color names if a match is found.  See
;       the function's static variables for a list of supported color names.
;
; Type:
;
;   Internal function.  Subject to change.  Do not use.
;
; Parameters:
;
;   p_ColorRBG - An RGB integer.  Examples: 0xFF0000, 16711680.
;
;   p_ReturnDefaultName - See the *Return Default Name* section for more
;       information.
;
; Returns:
;
;   A color name (Ex: "Blue") if a match is found, otherwise the original value
;   is returned.
;
; Calls To Other Functions:
;
; * <Fnt_GetWindowTextColor>
;
; Return Default Name:
;
;   The p_ReturnDefaultName parameter allows the developer to determine what
;   color name (if any) is returned if the p_ColorRBG contains the default text
;   color.
;
;   If p_ReturnDefaultName is set to TRUE, "Default" is returned if p_ColorRGB
;   contains the default text color.  If p_ColorRGB contains any other value,
;   it is processed normally.
;
;   If p_ReturnDefaultName is set to FALSE (the default), the p_ColorRGB
;   parameter is processed normally.
;
;-------------------------------------------------------------------------------
Fnt_RGB2ColorName(p_ColorRGB,p_ReturnDefaultName:=False)
    {
    Static ColorTable:={Aqua:0x00FFFF,Black:0x000000,Blue:0x0000FF,Fuchsia:0xFF00FF,Gray:0x808080,Green:0x008000,Lime:0x00FF00,Maroon:0x800000,Navy:0x000080,Olive:0x808000,Purple:0x800080,Red:0xFF0000,Silver:0xC0C0C0,Teal:0x008080,White:0xFFFFFF,Yellow:0xFFFF00}

    ;-- Default text color?
    if (p_ReturnDefaultName and p_ColorRGB=Fnt_GetWindowTextColor())
        Return "Default"

    ;-- Search
    For l_ColorName,l_ColorRGB in ColorTable
        if (p_ColorRGB=l_ColorRGB)
            Return l_ColorName

    Return p_ColorRGB
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
;   hFont - Handle to a logical font.  Set to null or 0 to use the default GUI
;       font.
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
Fnt_SetFont(hControl,hFont:="",p_Redraw:=False)
    {
    Static Dummy30050039
          ,DEFAULT_GUI_FONT:=17
          ,OBJ_FONT        :=6

          ;-- Messages
          ,WM_SETFONT:=0x30

    ;-- If needed, get the handle to the default GUI font
    if (DllCall("GetObjectType","Ptr",hFont)<>OBJ_FONT)
        hFont:=DllCall("GetStockObject","Int",DEFAULT_GUI_FONT)

    ;-- Set font
    l_DetectHiddenWindows:=A_DetectHiddenWindows
    DetectHiddenWindows On
    SendMessage WM_SETFONT,hFont,p_Redraw,,ahk_id %hControl%
    DetectHiddenWindows %l_DetectHiddenWindows%
    }

;------------------------------
;
; Function: Fnt_SetTooltipFont
;
; Description:
;
;   Creates a font and sets the last created tooltip control to use the font.
;   See the *Usage Notes* section for more information.
;
; Type:
;
;   Helper function.
;
; Parameters:
;
;   p_Name - Name of the font. [Optional]  If null (the default), the default
;       GUI font name is used.
;
;   p_Options - Font options. [Optional] See the *Options* section in
;       <Fnt_CreateFont> for more information.
;
; Returns:
;
;   A handle to a logical font.
;
; Credit:
;
;   Idea and and proof of concept of combining all of this functionality into a
;   single function from rommmcek.
;
;    *  https://autohotkey.com/boards/viewtopic.php?p=128531#p128531
;
; Calls To Other Functions:
;
; * <Fnt_CreateFont>
; * <Fnt_GetLastTooltip>
; * <Fnt_SetFont>
; * <Fnt_UpdateTooltip>
;
; Usage Notes:
;
;   This helper function 1) finds the last created tooltip, 2) creates a font,
;   and 3) sets the font to the tooltip.  There are a few notes/considerations:
;
;   This function should be called immediately after a tooltip is created using
;   the AutoHotkey Tooltip command.  For example:
;
;       (start code)
;       Tooltip Brown Chicken`, Brown Cow
;       hTTFont:=Fnt_SetTooltipFont("Arial","s14")
;       (end)
;
;   For completeness, the font created for the tooltip should be destroyed after
;   the tooltip is destroyed.  For example:
;
;       (start code)
;       Tooltip Brown Chicken`, Brown Cow
;       hTTFont:=Fnt_SetTooltipFont("Arial","s14")
;       Sleep 2000
;       Tooltip  ;-- Destroy the tooltip
;       Fnt_DeleteFont(hTTFont)
;       (end)
;
;   Even if the tooltip text is updated many times, this function should only be
;   called once for every tooltip control created.  For example:
;
;       (start code)
;       Tooltip Brown Chicken                       ;-- New tooltip control is created
;       hTTFont:=Fnt_SetTooltipFont("Arial","s14")  ;-- Font for tooltip is created and set
;       Sleep 2000
;       Tooltip Brown Cow                           ;-- New text, same tooltip control
;       ;-- No need to set/update the font here
;       Sleep 2000
;       Tooltip                                     ;-- The tooltip control is destroyed
;       Fnt_DeleteFont(hTTFont)
;       (end)
;
;   AutoHotkey can create up to 20 unique tooltips.  A font can be created and
;   set for each.  For example:
;
;       (start code)
;       ;-- Create tooltips
;       Tooltip Brown Chicken,100,100,1
;       hTTFont1:=Fnt_SetTooltipFont("Arial","s12")
;       Sleep 1000
;       Tooltip Brown Cow,200,150,2
;       hTTFont2:=Fnt_SetTooltipFont("Arial","s16")
;       Sleep 1000
;       Tooltip Once upon a time...,300,200,3
;       hTTFont3:=Fnt_SetTooltipFont("Arial","s20")
;       Sleep 2000
;
;       ;-- Destroy tooltips
;       Tooltip,,,,1
;       Fnt_DeleteFont(hTTFont1)
;       Sleep 1000
;       Tooltip,,,,2
;       Fnt_DeleteFont(hTTFont2)
;       Sleep 1000
;       Tooltip,,,,3
;       Fnt_DeleteFont(hTTFont3)
;       Sleep 1000
;       (end)
;
;   Although this function gives the developer the ability to easily change the
;   font on a tooltip, this change occurs after AutoHotkey creates and displays
;   the tooltip.  The user may see the tooltip window resize when the new font
;   is set.  In some cases, the tooltip window may even flash when the font is
;   set or when tooltip window is resized.  In most cases, the change is barely
;   noticeable, if at all.  However, for tooltips with a lot of text, the change
;   may be very noticeable.
;
;-------------------------------------------------------------------------------
Fnt_SetTooltipFont(p_Name:="",p_Options:="")
    {
    ;-- Get the last created tooltip
    hTT:=Fnt_GetLastTooltip()

    ;-- Create font
    hFont:=Fnt_CreateFont(p_Name,p_Options)

    ;-- Set the font and update
    Fnt_SetFont(hTT,hFont)
    Fnt_UpdateTooltip(hTT)
        ;-- This forces the tooltip to redraw without deactivating it first

    Return hFont
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
;   hFont - Handle to a logical font.  Set to null or 0 to use the default GUI
;       font.
;
;   p_String - The string to be measured.
;
;   r_HorzDTUs, r_VertDTUs - Output variables. [Optional] These variables are
;       loaded with the horizontal and vertical dialog template units for the
;       specified string.
;
; Returns:
;
;   The address to a SIZE structure.  The cx member of the SIZE structure
;   contains the horizontal dialog template units for the specified string.  The
;   cy member contains the vertical dialog template units.
;
; Calls To Other Functions:
;
; * <Fnt_GetDialogBaseUnits>
; * <Fnt_GetStringSize>
;
;-------------------------------------------------------------------------------
Fnt_String2DialogTemplateUnits(hFont,p_String,ByRef r_HorzDTUs:="",ByRef r_VertDTUs:="")
    {
    Static Dummy50214556
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
; Function: Fnt_String2DialogTemplateUnitsDT
;
; Description:
;
;   Converts a string to dialog template units for a font.
;
; Remarks:
;
;   This function is the same as <Fnt_String2DialogTemplateUnits> except that
;   "DrawText" is used instead of "GetTextExtentPoint32" to measure the text
;   size.  See <Fnt_String2DialogTemplateUnits> for more information.
;
;-------------------------------------------------------------------------------
Fnt_String2DialogTemplateUnitsDT(hFont,p_String,ByRef r_HorzDTUs:="",ByRef r_VertDTUs:="")
    {
    Static Dummy50214556
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
    Fnt_GetStringSizeDT(hFont,p_String,l_StringW,l_StringH)
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
;    specified maximum width, in pixels.
;
; Parameters:
;
;   hFont - Handle to a logical font.  Set to null or 0 to use the default GUI
;       font.
;
;   p_String - The string to process.
;
;   p_MaxW - The maximum width for the return string, in pixels.
;
; Returns:
;
;   A string with a width (measured in pixels) that is less than or equal to the
;   value in p_MaxW.
;
; Calls To Other Functions:
;
; * <Fnt_GetFontMaxCharWidth>
;
; Remarks:
;
;   Common control characters like tab, carriage control, and line feed are
;   always counted but they may or may not contain a size (width and height).
;   Every font is different.  Note: Tab characters are never expanded by this
;   function.
;
;-------------------------------------------------------------------------------
Fnt_TruncateStringToFit(hFont,p_String,p_MaxW)
    {
    Static Dummy94264906
          ,DEFAULT_GUI_FONT:=17
          ,HWND_DESKTOP    :=0
          ,OBJ_FONT        :=6

    ;-- Parameters
    if not StrLen(p_String)
        Return p_String

    if p_MaxW is not Integer
        Return p_String
     else
        if (p_MaxW<1)  ;-- Zero or negative
            Return ""

    ;-- If needed, get the handle to the default GUI font
    if (DllCall("GetObjectType","Ptr",hFont)<>OBJ_FONT)
        hFont:=DllCall("GetStockObject","Int",DEFAULT_GUI_FONT)

    ;-- Select the font into the device context for the desktop
    hDC      :=DllCall("GetDC","Ptr",HWND_DESKTOP)
    old_hFont:=DllCall("SelectObject","Ptr",hDC,"Ptr",hFont)

    ;-- Determine string size for specified maximum width
    VarSetCapacity(l_Fit,4,0)
    VarSetCapacity(SIZE,8,0)
    DllCall("GetTextExtentExPoint"
        ,"Ptr",hDC                                      ;-- hdc
        ,"Str",p_String                                 ;-- lpszStr
        ,"Int",StrLen(p_String)                         ;-- cchString
        ,"Int",p_MaxW                                   ;-- nMaxExtent
        ,"IntP",l_Fit                                   ;-- lpnFit [out]
        ,"Ptr",0                                        ;-- alpDx [out]
        ,"Ptr",&SIZE)                                   ;-- lpSize

    ;-- Release the objects needed by the GetTextExtentPoint32 function
    DllCall("SelectObject","Ptr",hDC,"Ptr",old_hFont)
        ;-- Necessary to avoid memory leak

    DllCall("ReleaseDC","Ptr",HWND_DESKTOP,"Ptr",hDC)

    ;-- Return string
    Return SubStr(p_String,1,l_Fit)
    }

;------------------------------
;
; Function: Fnt_TruncateStringWithEllipsis
;
; Description:
;
;   Similar to <Fnt_TruncateStringToFit> except that if the string is truncated,
;   the end of a string is replaced with an ellipses.
;
; Parameters:
;
;   hFont - Handle to a logical font.  Set to null or 0 to use the default GUI
;       font.
;
;   p_String - The string to process.
;
;   p_MaxW - The maximum width for the return string, in pixels.
;
; Returns:
;
;   A string with a width (measured in pixels) that is less than or equal to the
;   value in p_MaxW.
;
; Remarks:
;
;   This function is designed to truncate a single line of text.  Tab characters
;   are not expanded when calculating the size but if the returned text contains
;   tab characters, the tab characters may by expanded, depending on the
;   control.  End-of-line (EOL) characters (LF or CR+LF) are treated as regular
;   characters and do not break the line.  The height of the text is considered
;   to be the height the specified font.  However, if the returned text contains
;   EOL characters, the text may display on multiple lines, depending on the
;   control.
;
;   The space calculated for tab characters varies from font to font.  For most
;   fonts, the tab characters is given no size (0 pixels) but for other fonts,
;   it's given some non-zero value.  It's unclear how much space is calculated
;   for an EOL character but it's some non-zero value.
;
;-------------------------------------------------------------------------------
Fnt_TruncateStringWithEllipsis(hFont,p_String,p_MaxW)
    {
    Static Dummy43392262
          ,DEFAULT_GUI_FONT:=17
          ,HWND_DESKTOP    :=0
          ,OBJ_FONT        :=6

          ;-- DrawText formats
          ,DT_SINGLELINE:=0x20
                ;-- Displays text on a single line only.  Carriage return and
                ;   line feed characters do not break the line.

          ,DT_NOCLIP:=0x100
                ;-- Draws without clipping.  DrawText is somewhat faster when
                ;   DT_NOCLIP is used.

          ,DT_CALCRECT:=0x400
                ;-- Determines the width and height of the rectangle.  The text
                ;   is not drawn.

          ,DT_NOPREFIX:=0x800
                ;-- Turns off processing of prefix characters.

          ,DT_END_ELLIPSIS:=0x8000
                ;-- For displayed text, replaces the end of a string with
                ;   ellipses so that the result fits in the specified rectangle.
                ;   Any word (not at the end of the string) that goes beyond the
                ;   limits of the rectangle is truncated without ellipses. The
                ;   string is not modified unless the DT_MODIFYSTRING flag is
                ;   specified.  Compare with DT_PATH_ELLIPSIS and
                ;   DT_WORD_ELLIPSIS.

          ,DT_MODIFYSTRING:=0x10000
                ;-- Modifies the specified string to match the displayed text.
                ;   This format has no effect unless DT_END_ELLIPSIS or
                ;   DT_PATH_ELLIPSIS is specified.

          ,s_DTFormat:=DT_SINGLELINE|DT_NOCLIP|DT_CALCRECT|DT_NOPREFIX|DT_END_ELLIPSIS|DT_MODIFYSTRING

    ;-- Parameters
    ;   Bounce if appropriate
    if not StrLen(p_String)
        Return p_String

    if p_MaxW is not Integer
        Return p_String
     else
        if (p_MaxW<1)  ;-- Zero or negative
            Return ""

    ;-- If needed, get the handle to the default GUI font
    if (DllCall("GetObjectType","Ptr",hFont)<>OBJ_FONT)
        hFont:=DllCall("GetStockObject","Int",DEFAULT_GUI_FONT)

    ;-- Assign the string to local variable
    l_String:=p_String

    ;-- Create and populate the RECT structure
    VarSetCapacity(RECT,16,0)
    NumPut(p_MaxW,RECT,8,"Int")                         ;-- right

    ;-- Select the font into the device context for the desktop
    hDC      :=DllCall("GetDC","Ptr",HWND_DESKTOP)
    old_hFont:=DllCall("SelectObject","Ptr",hDC,"Ptr",hFont)

    ;-- Calculate rectangle
    DllCall("DrawText"
        ,"Ptr",hDC                                      ;-- hdc [in]
        ,"Str",l_String                                 ;-- lpchText [in, out]
        ,"Int",-1                                       ;-- cchText [in]
        ,"Ptr",&RECT                                    ;-- lprc [in, out]
        ,"UInt",s_DTFormat)                             ;-- uFormat [in]

    ;-- Release the objects needed by the DrawText function
    DllCall("SelectObject","Ptr",hDC,"Ptr",old_hFont)
        ;-- Necessary to avoid memory leak

    DllCall("ReleaseDC","Ptr",HWND_DESKTOP,"Ptr",hDC)

    ;-- Return same or modified string
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
;       number of twips for each pixel along the screen width (X) and height
;       (Y).
;
; Returns:
;
;   The address to a SIZE structure.  The cx member of the SIZE structure
;   contains the number of twips for each pixel along the screen width.  The cy
;   member contains the number of twips for each pixel along the screen height.
;
;-------------------------------------------------------------------------------
Fnt_TwipsPerPixel(ByRef X:="",ByRef Y:="")
    {
    Static Dummy38714358
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
    Fnt_DialogTemplateUnits2Pixels(hFont,0,p_VertDTUs,,l_Height)
    Return l_Height
    }
