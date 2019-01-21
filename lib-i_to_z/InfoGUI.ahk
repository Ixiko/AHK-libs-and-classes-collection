;-----------------------------
;
; Function: InfoGUI
;
; Description:
;
;   This function displays a simple read-only text window.  See the "Processing
;   And Usage Notes" section for more information.
;
;
; Parameters:
;
;   p_Owner - GUI owner of the InfoGUI window. [Optional] The default is 0 (no
;       owner).  If the value is not an integer between 1 and 99, the
;       AlwaysOnTop attribute is added to the InfoGUI window to make sure that
;       the window is not lost.
;
;   p_Text - The text that is displayed in the information window.
;
;   p_Title - Window title. [Optional] The default is the current script name
;       sans the extension.
;
;   p_GUIOptions - GUI Options. [Optional] The default are the options in the
;       s_DefaultGUIOptions variable (if any).  Some common options:
;
;       (start code)
;       Option          Description
;       ------          -----------
;       Border          Also known as "+Border".  If used with the "-Caption"
;                       option, creates a thin border around the window.
;
;       -Border         If used without the "-Caption" option, removes the title
;                       bar from the window and creates a thick border around
;                       the window.
;
;       -Caption        Removes the title bar from the window.
;
;       -MaximizeBox    Disables the maximize button in the title bar (if it
;                       exists).  This option is commonly used with the +Resize
;                       option.
;
;       -MinimizeBox    Disables the minimize button in the title bar (if it
;                       exists).
;
;       Resize          Also known as "+Resize".  Makes the window resizable and
;                       enables the maximize button (if it exists).  See the
;                       "-MaximizeBox" option.  This option is best used with
;                       the "Edit" object type and when the text is long or
;                       dynamic.
;
;       -SysMenu        This option removes the following from the title bar:
;                       System Menu, Program icon, Minimize button, Maximize
;                       button, And Close button.
;
;       ToolWindow      Also know as "+ToolWindow".  Creates a narrow title bar
;                       and removes the minimize and maximize buttons (if they
;                       exist).
;       (end)
;
;       To use more than one option, include a space between  each option.  For
;       example: "+Resize -MaximizeBox".
;
;       To insure that InfoGUI window is modal (and/or acts like it), the
;       "-MinimizeBox" option is always added to this parameter.
;
;       For more information, see the AutoHotkey documentation (Keyword: GUI,
;       Section: Options)
;
;   p_ObjectType - Object Type. [Optional] Valid values are "Edit" and "Text".
;       The "Edit" object type (the default) is selectable (the users can mark
;       and copy) and a vertical scroll bar is created so the user can scroll
;       through large amounts of text.  The "Resize" GUI option is sometimes
;       used with this object type. The "Text" object type is not selectable and
;       a scroll bar is not created.  However, the entire InfoGUI window can be
;       moved by dragging anywhere inside of the text object.
;
;
;   p_ObjectOptions - Object options. [Optional] The default are the options in
;       the s_DefaultObjectOptions variable (if any)  Some common options
;       include the following (not case sensitive):
;
;       (start code)
;       Option      Description
;       ------      -----------
;       Border      Also known as "+Border".  This option creates a thin-line
;                   border around the object.  Depending on what other parameter
;                   values are defined (or not defined), the border may give the
;                   object the illusion that it is indented (sunken).
;
;       c{Color}    Font color.  "Color" is an HTML color name or 6-digit hex
;                   RGB color value.  If this option is used, it will override
;                   the "color" option of the p_FontOptions parameter (if
;                   defined).
;
;       Center      Also known as "+Center".  Centers the text within its
;                   available width.
;
;       h{pixels}   Height (in pixels) of the object.  This option is NOT
;                   recommended.  Use the r{#OfRows} option instead.
;
;       r{#OfRows}  Rows of text to display.
;
;       Right       Also known as "+Right".  Right-justifies the text within its
;                   available width.
;
;       -VScroll    Removes the vertical scroll bar ("Edit" object type only).
;
;       w{pixels}   Width (in pixels) of the object.
;       (end)
;
;       To use more than one option, include a space between each option.
;       Example: "w200 r20 Border".
;
;       If the "width" option is not specified by the developer or by default,
;       the width of the object is determined by the width of the lines of text
;       in the p_Text parameter.
;
;       If the "height" or "row" options are not specified by the developer or
;       by default, the height of the object is determined by the number of
;       lines of text in the p_Text parameter.
;
;       For more information, see the AutoHotkey documentation (Keyword: GUI,
;       Section: Positioning and Sizing of Controls)
;
;   p_BGColor - Sets the background color of the object. [Optional] The default
;       is blank (uses the system default color).  To set, specify one of the 16
;       primary HTML color names or a 6-digit hex RGB color value.  For more
;       information, see the AutoHotkey documentation (Keyword: color names)
;
;   p_Font - The text font. [Optional] The default is blank (uses the system
;       default font).  For a list of available font names, see the AutoHotkey
;       documentation (Keyword: Fonts)
;
;   p_FontOptions - Font Options. [Optional] The default is blank (uses the
;       system defaults).  The following options are available (not case
;       sensitive):
;
;       (start code)
;       Option      Description
;       ------      -----------
;       Bold
;
;       c{Color}    Font color.  "Color" is an HTML color name or 6-digit hex
;                   RGB color value.
;
;       Italic
;
;       s{Size}     Font size in points.
;
;       Strike
;
;       Underline
;       (end)
;
;       To use more than one option, include a space between each option.
;       Example: "cBlue s10 bold underline".
;
;       For more information, see the AutoHotkey documentation (Keyword: GUI,
;       Section: Font).
;
;   p_Timeout - Window timeout (in seconds). [Optional] The default is blank
;       (no timeout).
;
;
; Returns:
;
;   True if the InfoGUI window was created and closed successfully.  False if
;   the function was unable to create the InfoGUI window (very rare) or if a
;   InfoGUI window is already open when the function is called.  The second
;   condition can occur if the script contains multiple triggers (usually
;   hotkeys and/or buttons) that call the InfoGUI function.
;
;
; Calls To Other Functions:
;
;   PopupXY (optional)
;
;
; Processing And Usage Notes:
;   A few notes...
;
;   *   This function does not return until the InfoGUI window is closed.
;
;   *   If a GUI number (integer between 1 and 99) is specified for the p_Owner
;       parameter, the InfoGUI window is made modal.  If a non-modal window is
;       desired, set p_Owner to the window's handle or to 0 (if the PopupXY
;       function is not included).  Programming note: Ownership is only assigned
;       if p_Owner contains a GUI number.  This limitation may change in the
;       future.
;
;   *   Because of the large number of possible values, many of the function
;       parameters are not checked for integrity.  Most of the time, invalid
;       values are simply ignored.  However, invalid values may cause the script
;       to fail.  Be sure to carefully select the parameter values and test
;       your script thoroughly.
;
;
; Customizing:
;
;   This function can be customized in an infinite number of ways.  The quickest
;   and most effective customization would be to change the default values for
;   the parameters.  Note that default values were purposely excluded from the
;   function definition so that the default values would not have to be changed
;   twice -- once in the function definition and again in the "Parameters"
;   section of the code.
;
;-------------------------------------------------------------------------------
InfoGUI(p_Owner=""
       ,p_Text=""
       ,p_Title=""
       ,p_GUIOptions=""
       ,p_ObjectType=""
       ,p_ObjectOptions=""
       ,p_BGColor=""
       ,p_Font=""
       ,p_FontOptions=""
       ,p_Timeout="")
    {
    ;[====================]
    ;[  Static variables  ]
    ;[====================]
    Static s_GUI:=0
                ;-- This variable stores the currently active GUI.  If not zero
                ;   when entering the function, the GUI is currently showing.

          ,s_StartGUI:=56
                ;-- Default starting GUI window number for InfoGUI window.
                ;   Change if desired.

          ,s_PopupXY_Function:="PopupXY"
                ;-- Name of the PopupXY function.  Defined as a variable so that
                ;   function will use if the "PopupXY" function is included but
                ;   will not fail if it's not.

          ,s_DefaultGUIOptions:=""
                ;-- Default GUI options.  Leave blank for no defaults.

          ,s_DefaultObjectOptions:="w500 r15"
                ;-- Default object options.  Set to blank for no defaults.

    ;[===========================]
    ;[  Window already showing?  ]
    ;[===========================]
    if s_GUI
        {
        outputdebug,
           (ltrim join`s
            End Func: %A_ThisFunc% -
            A %A_ThisFunc% window already exists.
           )

        Return False
        }

    ;[==================]
    ;[    Parameters    ]
    ;[  (Set defaults)  ]
    ;[==================]
    ;---------
    ;-- Owner
    ;---------
    p_Owner=%p_Owner%  ;-- AutoTrim
    if p_Owner is not Integer
        p_Owner:=0

    ;-- Owner window exist?
    if p_Owner Between 1 and 99
        {
        gui %p_Owner%:+LastFoundExist
        IfWinNotExist
            {
            outputdebug,
               (ltrim join`s
                Function: %A_ThisFunc% -
                Owner window does not exist.  p_Owner=%p_Owner%
               )

            p_Owner:=0
            }
        }

    ;---------
    ;-- Title
    ;---------
    p_Title=%p_Title%  ;-- AutoTrim
    SplitPath A_ScriptName,,,,l_ScriptName
    if StrLen(p_Title)=0
        p_Title:=l_ScriptName
     else
        {
        ;-- Append to script name if p_title begins with "++"?
        if SubStr(p_Title,1,2)="++"
            {
            StringTrimLeft p_Title,p_Title,2
            p_Title:=l_ScriptName . A_Space . p_Title
            }
        }

    ;---------------
    ;-- GUI Options
    ;---------------
    p_GUIOptions=%p_GUIOptions%  ;-- AutoTrim
    if p_GUIOptions is Space
        p_GUIOptions:=s_DefaultGUIOptions

    p_GUIOptions:=p_GUIOptions . " -MinimizeBox"

    ;---------------
    ;-- Object Type
    ;---------------
    p_ObjectType=%p_ObjectType%  ;-- AutoTrim
    if p_ObjectType not in Edit,Text
        p_ObjectType:="Edit"

    ;-- Identify Move command and ClassNN
    l_MoveCmd:="Move"
    l_ClassNN:="Edit1"
    if (p_ObjectType="Text")
        {
        l_MoveCmd:="MoveDraw"
        l_ClassNN:="Static1"
        }

    ;------------------
    ;-- Object options
    ;------------------
    p_ObjectOptions=%p_ObjectOptions%  ;-- AutoTrim
    if p_ObjectOptions is Space
        p_ObjectOptions:=s_DefaultObjectOptions

    ;---------
    ;-- Misc.
    ;---------
    p_BGColor=%p_BGColor%           ;-- AutoTrim
    p_Font=%p_Font%                 ;-- AutoTrim
    p_FontOptions=%p_FontOptions%   ;-- AutoTrim

    ;-----------
    ;-- Timeout
    ;-----------
    p_Timeout=%p_Timeout%  ;-- Autotrim
    if p_Timeout is Number
        p_Timeout:=p_Timeout*1000
     else
        p_Timeout:=""

    ;[==============================]
    ;[     Find available window    ]
    ;[  (Starting with s_StartGUI)  ]
    ;[==============================]
    s_GUI:=s_StartGUI
    Loop
        {
        ;-- Window available?
        gui %s_GUI%:+LastFoundExist
        IfWinNotExist
            Break

        ;-- Nothing available?
        if (s_GUI=99)
            {
            MsgBox
                ,262160
                    ;-- 262160=0 (OK button) + 16 (Error icon) + 262144 (AOT)
                ,%A_ThisFunc% Error,
                   (ltrim join`s
                    Unable to create a %A_ThisFunc% window.  GUI windows
                    %s_StartGUI% to 99 are already in use.  %A_Space%
                   )

            Return False
            }

        ;-- Increment window number
        s_GUI++
        }

    ;[================]
    ;[  Context Menu  ]
    ;[================]
    ;-- Create stub (needed for the 1st call)
    Menu InfoGUI_ContextMenu,Add
    
    ;-- Clear menu
    Menu InfoGUI_ContextMenu,DeleteAll

    ;-- Context menu items
    Menu InfoGUI_ContextMenu
        ,Add
        ,&Copy All`tCtrl+C
        ,InfoGUI_CopyToClipboard

    Menu InfoGUI_ContextMenu,Add

    Menu InfoGUI_ContextMenu
        ,Add
        ,Close`tAlt+F4
        ,InfoGUI_Close

    ;[=============]
    ;[  Build GUI  ]
    ;[=============]
    ;-- Owner?
    if p_Owner Between 1 and 99
        {
        ;-- Disable Owner, give ownership of GUI to Owner
        gui %p_Owner%:+Disabled      ;-- Disable Owner window
        gui %s_GUI%:+Owner%p_Owner%  ;-- Set ownership
        }
     else
        gui %s_GUI%:+Owner           ;-- Give ownership to the script window

    ;-- GUI Options
    gui %s_GUI%:Margin,0,0
    gui %s_GUI%:+LabelInfoGUI_ %p_GUIOptions%
    if p_Owner not Between 1 and 99
        gui %s_GUI%:+AlwaysOnTop

    ;-- Set background color
    if p_BGColor is not Space
        gui %s_GUI%:Color,%p_BGColor%

    ;-- Set font and font options
    gui %s_GUI%:Font,%p_FontOptions%,%p_Font%

    ;-- Create object (Text or Edit)
    Static InfoGUI_Object
    gui %s_GUI%:Add
       ,%p_ObjectType%
       ,%p_ObjectOptions%
            || +ReadOnly
            || vInfoGUI_Object
            || gInfoGUI_Move
       ,%p_Text%
        ;-- Note: The object is populated here just in case the contents are
        ;   needed to determine the width and/or height of the control.

    ;-- Reset font to system default
    gui %s_GUI%:Font

    ;-- Clear object
    GUIControl %s_GUI%:,InfoGUI_Object,%A_Space%
        ;-- Note: Object is cleared here so that the user will not experience a
        ;   Screen flicker ("Edit" object type only) when the window is shown.

    ;-- Collect window handle
    gui %s_GUI%:+LastFound
    WinGet l_InfoGUI_hWnd,ID
    GroupAdd InfoGUI_Group,ahk_id %l_InfoGUI_hWnd%

    ;-- Show it
    if p_Owner and IsFunc(s_PopupXY_Function)
        {
        ;-- Render, identify center position, and show
        gui %s_GUI%:Show,Hide,%p_Title%
        %s_PopupXY_Function%(p_Owner,l_InfoGUI_hWnd,PosX,PosY)
        gui %s_GUI%:Show,x%PosX% y%PosY%
        }
     else
        gui %s_GUI%:Show,,%p_Title%

    ;-- Populate object
    GUIControl %s_GUI%:,InfoGUI_Object,%p_Text%
        ;-- Note: Object is (re)populated after the window is displayed so that
        ;   the contents are not selected.

    ;[====================]
    ;[  Timer and Hotkey  ]
    ;[====================]
    if p_Timeout
        SetTimer InfoGUI_Timer,%p_Timeout%

    if (p_ObjectType="Text")
        {
        Hotkey IfWinActive,ahk_group InfoGUI_Group
        Hotkey ^c,InfoGUI_CopyToClipboard,On
        Hotkey IfWinActive
        }

    ;[=====================]
    ;[  Wait until window  ]
    ;[      is closed      ]
    ;[=====================]
    WinWaitClose ahk_id %l_InfoGUI_hWnd%
    Return True  ;-- End of function


    ;*****************************
    ;*                           *
    ;*                           *
    ;*        Subroutines        *
    ;*         (InfoGUI)         *
    ;*                           *
    ;*                           *
    ;*****************************
    ;***************************
    ;*                         *
    ;*    Copy to Clipboard    *
    ;*                         *
    ;***************************
    InfoGUI_CopyToClipboard:

    ;-- Add CR if/where needed
    l_Text:=p_Text
    if l_Text not Contains `r`n
        StringReplace l_Text,l_Text,`n,`r`n,All

    ;-- Add final CR+LF if needed
    if SubStr(l_Text,0)<>"`n"
        l_Text.="`r`n"

    ;-- Paste to clipboard
    Clipboard:=l_Text

    ;-- Tooltip
    ToolTip All text copied to the clipboard.,25,40
    SetTimer InfoGUI_HideToolTip,4000
    return


    ;**********************
    ;*                    *
    ;*    Context menu    *
    ;*                    *
    ;**********************
    InfoGUI_ContextMenu:
    ;-- Show.  Note: This menu will only show if object type is "Text"
    Menu InfoGUI_ContextMenu,Show,%A_GUIX%,%A_GUIY%
    return

    
    ;**********************
    ;*                    *
    ;*    Hide Tooltip    *
    ;*                    *
    ;**********************
    InfoGUI_HideToolTip:
    SetTimer %A_ThisLabel%,Off
    ToolTip
    return


    ;**************
    ;*            *
    ;*    Move    *
    ;*            *
    ;**************
    InfoGUI_Move:
    PostMessage 0xA1,2  ;-- SKAN trick.  Only works if object type is "Text"
    return


    ;****************
    ;*              *
    ;*    Resize    *
    ;*              *
    ;****************
    InfoGUI_Size:
    if (A_EventInfo=1)  ;-- Minimize
        return

    ;-- Move it
    GUIControl
        ,%s_GUI%:%l_MoveCmd%
        ,%l_ClassNN%
        ,% "w" . A_GUIWidth . " h" . A_GUIHeight


    return


    ;***********************
    ;*                     *
    ;*    Close up shop    *
    ;*                     *
    ;***********************
    InfoGUI_Timer:
    InfoGUI_Escape:
    InfoGUI_Close:

    ;-- Turn off timer
    SetTimer InfoGUI_Timer,Off

    ;-- Hide Tooltip
    gosub InfoGUI_HideToolTip

    ;-- Disable hotkey
    if (p_ObjectType="Text")
        {
        Hotkey IfWinActive,ahk_group InfoGUI_Group
        Hotkey ^c,InfoGUI_CopyToClipboard,Off
        Hotkey IfWinActive
        }

    ;-- Enable Owner window
    if p_Owner Between 1 and 99
        gui %p_Owner%:-Disabled

    ;-- Destroy the InfoGUI window so that it can be be reused
    gui %s_GUI%:Destroy
    s_GUI:=0
    return  ;-- End of subroutines
    }
