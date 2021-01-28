; ************************
; *                      *
; *    HotkeyGUI v0.2    *
; *                      *
; ************************
;
;
;   Description
;   ===========
;   This function displays a GUI window that will allow a user to enter/select a
;   hotkey without using the keyboard.  See the "Processing Notes" section for
;   more information.
;
;
;
;   Parameters
;   ==========
;
;       Name                Description
;       -----               -----------
;       p_GUI               The GUI window number.  [Optional]  The default
;                           is 81.  Only specify a window number here if it is
;                           important to know the exact window number that will
;                           be used.  See the "Processing Notes" section (below)
;                           for more information.
;
;
;       p_ParentGUI         The GUI owner of the HotkeyGUI window.  [Optional]
;                           The default is 1.
;
;
;       p_Title             Window title.  [Optional]  The default is the
;                           current script name (sans the extention) plus
;                           " - Select Hotkey".
;
;
;       p_Limit             Hotkey limit.  [Optional]  The default is 0.  See
;                           the "Hotkey Limit" section below for more
;                           information.
;
;
;       p_LimitMsg          Hotkey Limit message.  [Optional].  The default is
;                           true.
;
;                           If true and a hotkey limit is reached, an error
;                           message is displayed and the user returned back to
;                           the HotkeyGUI window.
;
;                           If false and a hotkey limit is reached, the function
;                           returns the selected hotkey and ErrorLevel (system
;                           variable) is set to the Hotkey limit that was
;                           reached.
;
;                           See the "Hotkey Limit" section below for more
;                           information.
;
;
;       p_OptionalAttrib    Optional hotkey attributes.  [Optional].  The
;                           default is true.
;
;                           If true, all fields in the "Optional Attributes"
;                           group are enabled.  If false, all of these fields
;                           are disabled.
;
;    p_filter      Used for hotkey collision check, if program-specific
;              hotkeys are used, to allow overrides
;
;    p_exclude      Used for hotkey collision check, this key is not considered
;              a collision (useful when editing existing hotkey)
;
;
;   Processing Notes
;   ================
;    o  This function disables the parent window and assigns ownership of the
;       HotkeyGUI window to the parent window.  This makes the HotkeyGUI window
;       modal which prevents the user from interacting with the parent window
;       until the HotkeyGUI window is closed.  Unfortunately, it doesn't
;       prevent the end user from interacting with the parent window via
;       hotkeys, timers, etc.
;
;    o  To improve usability, this function does not exit until the user closes
;       the the HotkeyGUI window.  If a hotkey is used to trigger a call to this
;       function, that same hotkey cannot be triggered again (if using the
;       system default of #MaxThreadsPerHotkey 1) until the HotkeyGUI window is
;       closed.
;
;   o   This function uses the first GUI window that is available in the p_GUI
;       (usually 81) to 99 range. If an available window cannot be found, an
;       error message is displayed.
;
;       Important:  Although this function can theoretically create up to 99
;       independent windows, creating more than one HotkeyGUI window at a time
;       is not recommended because the parent GUI window is automatically
;       re-enabled when a HotkeyGUI window is closed.  When this occurs, any
;       HotkeyGUI window still open becomes modeless (non-modal).
;
;
;
;   Hotkey Limits
;   =============
;   The p_Limit parameter allows the developer to restrict the types of keys
;   that are selected.  The following limit values are available:
;
;       Limit   Description
;       -----   -----------
;       1       Prevent unmodified keys
;       2       Prevent Shift-only keys
;       4       Prevent Ctrl-only keys
;       8       Prevent Alt-only keys
;       16      Prevent Win-only keys
;       32      Prevent Shift-Ctrl keys
;       64      Prevent Shift-Alt keys
;       128     Prevent Shift-Win keys
;       256     Prevent Shift-Ctrl-Alt keys
;       512     Prevent Shift-Ctrl-Win keys
;       1024    Prevent Shift-Win-Alt keys
;
;   To use a limit, enter the sum of one or more of these limit values.  For
;   example, a limit value of 1 will prevent unmodified keys from being used.
;   A limit value of 31 (1 + 2 + 4 + 8 + 16) will require that at least two
;   modifier keys be used.
;
;
;
;   Return Codes
;   ============
;   If the function ends after the user has selected a valid key and the
;   "Accept" button is clicked, the function returns the selected key in the
;   standard AHK hotkey format and ErrorLevel is set to 0.
;   Example: Hotkey=^a  ErrorLevel=0
;
;   If p_LimitMsg is false and a key limit test has failed, the function will
;   return the selected hotkey and ErrorLevel is set to the limit value that
;   failed.  Example: Hotkey=^a  ErrorLevel=4
;
;   If the HotkeyGUI window is canceled (Cancel button, Close button, or Escape
;   key), the function returns a null value and Errorlevel is set to 10003.
;
;
;   Important: ErrorLevel is a system variable and is used by many commands.
;   If you are unable to test ErrorLevel immediate after calling this function,
;   assign the value to another variable so that the return value is retained.
;
;
;
;   Calls To Other Functions
;   ========================
;   DisplayMessage
;   EMessage
;
;
;
;   Programming Notes
;   =================
;   No global variables are used.  However, to get around the use of global
;   variables (especially when creating a GUI inside of a function), several
;   changes were made:
;
;    -  To keep the code as friendly as possible, static variables (in lieu of
;       global variables) are used whenever a GUI object needs a variable.
;       Object variables are defined so that a single "gui Submit" command can
;       be used to collect the GUI values instead of having to execute a
;       "GUIControlGet" command on every GUI control.
;
;   -   For the few GUI objects that are programmatically updated, the ClassNN
;       (class name and instance number of the object  Ex: Static4) is used.
;
;   Important: Any changes to the GUI (additions, deletions, etc.) may change
;   the ClassNN of objects that are updated.  Use Window Spy (or similar
;   program) to identify any changes.
;
;
;-------------------------------------------------------------------------------
HotkeyGUI(p_GUI=""
    ,p_ParentGUI=""
    ,p_Title=""
    ,p_Limit=""
    ,p_LimitMsg=""
    ,p_OptionalAttrib=""
 ,p_filter=""
  ,p_exclude="")
    {
  Critical, Off
    ;[==============]
    ;[  Initialize  ]
    ;[==============]
    SplitPath A_ScriptName,,,,l_ScriptName
    l_GUIDelimiter:="ƒ"
    l_ErrorLevel=0


    ;[==================]
    ;[    Parameters    ]
    ;[  (Set defaults)  ]
    ;[==================]
    ;-- GUI
    p_GUI=%p_GUI%  ;-- AutoTrim
    if p_GUI is not Integer
        p_GUI=81
     else
        if p_GUI not between 1 and 99
            p_GUI=81


    ;-- Parent GUI
    p_ParentGUI=%p_ParentGUI%  ;-- AutoTrim
    if p_ParentGUI is not Integer
        p_ParentGUI=1
     else
        if p_ParentGUI not between 1 and 99
            p_ParentGUI=1


    ;-- Title
    p_Title=%p_Title%  ;-- AutoTrim
    if strlen(p_Title)=0
        p_Title:=l_ScriptName . " - Select Hotkey"
     else
        {
        ;-- Append to script name if p_title begins with "++"?
        if instr(p_Title,"++")=1
            {
            StringTrimLeft p_Title,p_Title,2
            p_Title:=l_ScriptName . A_Space . p_Title
            }
        }


    ;-- Limit
    p_Limit=%p_Limit%  ;-- AutoTrim
    if p_Limit is not Integer
        p_Limit=0
     else
        if p_Limit not between 0 and 2047
            p_Limit=0


    ;-- LimitMsg
    p_LimitMsg=%p_LimitMsg%  ;-- AutoTrim
    if p_LimitMsg is not Integer
        p_LimitMsg:=true
     else
        if p_LimitMsg not between 0 and 1
            p_LimitMsg:=true


    ;-- OptionalAttrib
    p_OptionalAttrib=%p_OptionalAttrib%  ;-- AutoTrim
    if p_OptionalAttrib is not Integer
        p_OptionalAttrib:=true
     else
        if p_OptionalAttrib not between 0 and 1
            p_OptionalAttrib:=true

  HG_Filter := p_filter
  HG_Exclude := p_exclude
    ;[=========================]
    ;[  Find available window  ]
    ;[  (Starting with p_GUI)  ]
    ;[=========================]
    l_GUI:=p_GUI
    loop
        {
        ;-- Window available?
        gui %l_GUI%:+LastFoundExist
        IfWinNotExist
            break

        ;-- Nothing available?
        if l_GUI=99
            {
            MsgBox 262160
                ,HotkeyGUI Error
                ,Unable to create HotkeyGUI window. GUI windows %p_GUI% to 99 are already in use.
            ErrorLevel=9999
            return ""
            }

        ;-- Increment window
        l_GUI++
        }

    ;[===================]
    ;[  Set GUI default  ]
    ;[===================]
    gui %l_GUI%:Default


    ;[=====================]
    ;[  Build/Display GUI  ]
    ;[=====================]
    ;-- Disable parent GUI
    gui %p_ParentGUI%:+Disabled

    ;-- Set ownership
    gui +Owner%p_ParentGUI%

    ;-- Set margins
    gui Margin,6,6

    ;-- GUI options
    gui -MinimizeBox +LabelHotkeyGUI +Delimiter%l_GUIDelimiter%


    ;[===============]
    ;[  GUI Objects  ]
    ;[===============]
    ;-- Modifier
    gui Add
       ,GroupBox
       ,x06 y10 w120 h140
       ,Modifier

    static HG_CtrlModifier
    gui Add
       ,CheckBox
       ,x16 y30 w40 h20 vHG_CtrlModifier gHotkeyGUI_UpdateHotkey
       ,Ctrl

    static HG_ShiftModifier
    gui Add
       ,CheckBox
       ,y+0 w40 h20 vHG_ShiftModifier gHotkeyGUI_UpdateHotkey
       ,Shift

    static HG_WinModifier
    gui Add
       ,CheckBox
       ,y+0 w40 h20 vHG_WinModifier gHotkeyGUI_UpdateHotkey
       ,Win

    static HG_AltModifier
    gui Add
       ,CheckBox
       ,y+0 w40 h20 vHG_AltModifier gHotkeyGUI_UpdateHotkey
       ,Alt


    ;-- Optional Attributes
    gui Add
       ,GroupBox
       ,x126 y10 w120 h140
       ,Optional Attributes

    static HG_NativeOption
    gui Add
       ,CheckBox                                                                ;-- Button7
       ,x136 y30 w100 h20 Disabled vHG_NativeOption gHotkeyGUI_UpdateHotkey
       ,~ (Native)

    static HG_WildcardOption
    gui Add
       ,CheckBox                                                                ;-- Button8
       ,y+0 w100 h20 Disabled vHG_WildcardOption gHotkeyGUI_UpdateHotkey
       ,*  (Wildcard)

    static HG_LeftPairOption
    gui Add
       ,CheckBox                                                                ;-- Button9
       ,y+0 w100 h20 Disabled vHG_LeftPairOption gHotkeyGUI_LeftPair
       ,< (Left pair only)

    static HG_RightPairOption
    gui Add
       ,CheckBox                                                                ;-- Button10
       ,y+0 w100 h20 Disabled vHG_RightPairOption gHotkeyGUI_RightPair
       ,> (Right pair only)

  static HG_UpOption
    gui Add
       ,CheckBox                                                                ;-- Button11
       ,y+0 w100 h20 Disabled vHG_UpOption gHotkeyGUI_UpdateHotkey
       ,Up (Key release)

    ;-- Enable "Optional Attributes"?
    if p_OptionalAttrib
        {
        GUIControl Enable,Button7
        GUIControl Enable,Button8
        GUIControl Enable,Button9
        GUIControl Enable,Button10
        GUIControl Enable,Button11
        }


    ;-- Keys
    gui Add
       ,GroupBox
       ,x6 y150 w240 h180
       ,Keys

    static HG_StandardKeysView
    gui Add
       ,Radio
       ,x16 y170 w100 h20 vHG_StandardKeysView gHotkeyGUI_UpdateKeyList Checked
       ,Standard

    static HG_FunctionKeysView
    gui Add
       ,Radio
       ,y+0 w100 h20 vHG_FunctionKeysView gHotkeyGUI_UpdateKeyList
       ,Function keys

    static HG_NumpadKeysView
    gui Add
       ,Radio
       ,y+0 w100 h20 vHG_NumpadKeysView gHotkeyGUI_UpdateKeyList
       ,Numpad

    static HG_MouseKeysView
    gui Add
       ,Radio
       ,y+0 w100 h20 vHG_MouseKeysView gHotkeyGUI_UpdateKeyList
       ,Mouse

    static HG_MultimediaKeysView
    gui Add
       ,Radio
       ,y+0 w100 h20 vHG_MultimediaKeysView gHotkeyGUI_UpdateKeyList
       ,Multimedia

    static HG_SpecialKeysView
    gui Add
       ,Radio
       ,y+0 w100 h20 vHG_SpecialKeysView gHotkeyGUI_UpdateKeyList
       ,Special

    static HG_Key
    gui Add
       ,ListBox                                                                 ; -- ListBox1
       ,x116 y170 w120 h150 vHG_Key gHotkeyGUI_UpdateHotkey

    gosub HotkeyGUI_UpdateKeyList


    ;-- Hotkey Display
    gui Add
       ,Text
       ,x6 y340 w40 h20
       ,Hotkey:

    gui Add
       ,Edit                                                                    ;-- Edit1
       ,x+5 w190 h20 +ReadOnly

    gui Add
       ,Text
       ,x6 y+5 w40 h20
       ,Desc:

    gui Add
       ,Text                                                                    ;-- Static3
       ,x+5 w190 h20 +ReadOnly
       ,None


    ;-- Buttons
    gui Add
       ,Button
       ,x6 y400 w70 h25 gHotkeyGUI_AcceptButton +Default
       ,&Accept

    gui Add
       ,Button
       ,x+5 w70 h25 gHotkeyGUIClose
       ,&Cancel


    ;-- Display HotkeyGUI window
    ;     Generated using SmartGUI Creator 4.0
    gui Show,,%p_Title%


    ;[=====================]
    ;[  Collect window ID  ]
    ;[=====================]
    gui +LastFound
    WinGet HotkeyGUI_hWnd,ID


    ;[=====================]
    ;[  Loop until window  ]
    ;[      is closed      ]
    ;[=====================]
    loop
  {
        sleep 250
    IfWinNotExist ahk_id %HotkeyGUI_hWnd%
            break
  }


    ;-- Set GUI default back to parent
    gui %p_ParentGUI%:Default


    ;[====================]
    ;[  Return to sender  ]
    ;[====================]
    ErrorLevel:=l_ErrorLevel
    return HG_HotKey  ;-- End of function





    ; *****************************
    ; *                           *
    ; *                           *
    ; *        Subroutines        *
    ; *                           *
    ; *                           *
    ; *****************************
    ; ***********************
    ; *                     *
    ; *    Update Hotkey    *
    ; *                     *
    ; ***********************
    HotkeyGUI_UpdateHotkey:
    ;-- Set GUI default
    gui %l_GUI%:Default

    ;-- Attach any messages to the current GUI
    gui +OwnDialogs

    ;-- Collect form values
    gui Submit,NoHide


    ;-- Substitute Pause|Break for CtrlBreak?
    if HG_Key in Pause,Break
        if HG_CtrlModifier
            HG_Key=CtrlBreak


    ;-- Substitute CtrlBreak for Pause (Break would work OK too)
    if HG_Key=CtrlBreak
        if not HG_CtrlModifier
            HG_Key=Pause


    ;[================]
    ;[  Build Hotkey  ]
    ;[================]
    ;-- Initialize
    HG_Hotkey=
    HG_HKDesc=


    ;-- Options
    if HG_NativeOption
        HG_Hotkey:=HG_Hotkey . "~"

    if HG_WildcardOption
        HG_Hotkey:=HG_Hotkey . "*"

    if HG_LeftPairOption
        HG_Hotkey:=HG_Hotkey . "<"

    if HG_RightPairOption
        HG_Hotkey:=HG_Hotkey . ">"

    ;-- Modifiers
    if HG_CtrlModifier
        {
        HG_Hotkey:=HG_Hotkey . "^"
        HG_HKDesc:=HG_HKDesc . "Ctrl + "
        }

    if HG_ShiftModifier
        {
        HG_Hotkey:=HG_Hotkey . "+"
        HG_HKDesc:=HG_HKDesc . "Shift + "
        }

    if HG_WinModifier
        {
        HG_Hotkey:=HG_Hotkey . "#"
        HG_HKDesc:=HG_HKDesc . "Win + "
        }

    if HG_AltModifier
        {
        HG_Hotkey:=HG_Hotkey . "!"
        HG_HKDesc:=HG_HKDesc . "Alt + "
        }

    HG_Hotkey:=HG_Hotkey . HG_Key
    HG_HKDesc:=HG_HKDesc . HG_Key
  if HG_UpOption
  {
        HG_Hotkey:=HG_Hotkey . " Up"
   HG_HKDesc:=HG_HKDesc . " Up"
  }
    ;-- Update Hotkey and HKDescr fields
    GUIControl ,,Edit1,%HG_Hotkey%
    GUIControl ,,Static3,%HG_HKDesc%

    ;-- Return to sender
    return



    ; **********************
    ; *                    *
    ; *    Pair Options    *
    ; *                    *
    ; **********************
    HotkeyGUI_LeftPair:

    ;-- Set GUI default
    gui %l_GUI%:Default


    ;-- Deselect HG_RightPairOption
    GUIControl ,,Button10,0
    gosub HotkeyGUI_UpdateHotkey
    return



    HotkeyGUI_RightPair:

    ;-- Set GUI default
    gui %l_GUI%:Default


    ;-- Deselect HG_LeftPairOption
    GUIControl ,,Button9,0
    gosub HotkeyGUI_UpdateHotkey
    return


    ; *************************
    ; *                       *
    ; *    Update Key List    *
    ; *                       *
    ; *************************
    HotkeyGUI_UpdateKeyList:

    ;-- Set GUI default
    gui %l_GUI%:Default

    ;-- Collect form values
    gui Submit,NoHide


    ;-- Standard
    if HG_StandardKeysView
        HG_KeyList=
           (ltrim join
            AƒBƒCƒDƒEƒFƒGƒHƒIƒJƒKƒLƒMƒNƒOƒPƒQƒRƒSƒTƒUƒVƒWƒXƒYƒZƒ
            0ƒ1ƒ2ƒ3ƒ4ƒ5ƒ6ƒ7ƒ8ƒ9ƒ0ƒ
            ``ƒ-ƒ=ƒ[ƒ]ƒ`\ƒ;ƒ
            'ƒ,ƒ.ƒ/ƒ
            SpaceƒTabƒEnterƒEscapeƒBackspaceƒDeleteƒ
            ScrollLockƒCapsLockƒNumLockƒ
            PrintScreenƒCtrlBreakƒPauseƒBreakƒ
            InsertƒHomeƒEndƒPgUpƒPgDnƒ
            UpƒDownƒLeftƒRightƒ
           )


    ;-- Function keys
    if HG_FunctionKeysView
        HG_KeyList=
           (ltrim join
            F1ƒF2ƒF3ƒF4ƒF5ƒF6ƒF7ƒF8ƒF9ƒF10ƒF11ƒF12ƒ
            F13ƒF14ƒF15ƒF16ƒF17ƒF18ƒF19ƒF20ƒF21ƒF22ƒF23ƒF24
           )


    ;-- Numpad
    if HG_NumpadKeysView
        HG_KeyList=
           (ltrim join
            NumLockƒNumpadDivƒNumpadMultƒNumpadAddƒNumpadSubƒNumpadEnterƒ
            NumpadDelƒNumpadInsƒNumpadClearƒNumpadUpƒNumpadDownƒNumpadLeftƒ
            NumpadRightƒNumpadHomeƒNumpadEndƒNumpadPgUpƒNumpadPgDnƒNumpad0ƒ
            Numpad1ƒNumpad2ƒNumpad3ƒNumpad4ƒNumpad5ƒNumpad6ƒNumpad7ƒNumpad8ƒ
            Numpad9ƒNumpadDot
           )


    ;-- Mouse
    if HG_MouseKeysView
        HG_KeyList=LButtonƒRButtonƒMButtonƒWheelDownƒWheelUpƒXButton1ƒXButton2


    ;-- Multimedia
    if HG_MultimediaKeysView
        HG_KeyList=
           (ltrim join
            Browser_BackƒBrowser_ForwardƒBrowser_RefreshƒBrowser_Stopƒ
            Browser_SearchƒBrowser_FavoritesƒBrowser_HomeƒVolume_Muteƒ
            Volume_DownƒVolume_UpƒMedia_NextƒMedia_PrevƒMedia_Stopƒ
            Media_Play_PauseƒLaunch_MailƒLaunch_MediaƒLaunch_App1ƒLaunch_App2ƒ
           )


    ;-- Special
    if HG_SpecialKeysView
        HG_KeyList=HelpƒSleep


    ;-- Update HG_KeyList
    GUIControl -Redraw,ListBox1
    GUIControl ,,ListBox1,%l_GUIDelimiter%%HG_KeyList%
    GUIControl +Redraw,ListBox1


    ;--- Reset HG_Hotkey and HG_HKDesc
    HG_Key=
    gosub HotkeyGUI_UpdateHotkey


    ;-- Return to sender
    return



    ; ***********************
    ; *                     *
    ; *    Accept Button    *
    ; *                     *
    ; ***********************
    HotkeyGUI_AcceptButton:

    ;-- Attach any messages to the current GUI
    gui +OwnDialogs


    ;-- Any key?
    if not HG_Key
        {
        MsgBox 262160
            ,%p_Title%
            ,A key must be selected.
        return
        }


    ;[===============]
    ;[  Limit Tests  ]
    ;[===============]
    l_ErrorLevel=0
    l_Limit:=p_Limit


    ;-- Loop until failure or until all tests have been performed
    loop
        {
        ;-- Are we done here?
        if l_limit<=0
            break


        ;-----------------
        ;-- Shift+Win+Alt
        ;-----------------
        if l_limit>=1024
            {
            if (HG_ShiftModifier and HG_WinModifier and HG_AltModifier)
                {
                l_Message=SHIFT+WIN+ALT keys are not allowed.
                l_ErrorLevel=1024
                break
                }

            l_limit:=l_limit-1024
            continue
            }


        ;------------------
        ;-- Shift+Ctrl+Win
        ;------------------
        if l_limit>=512
            {
            if (HG_ShiftModifier and HG_CtrlModifier and HG_WinModifier)
                {
                l_Message=SHIFT+CTRL+WIN keys are not allowed.
                l_ErrorLevel=512
                break
                }

            l_limit:=l_limit-512
            continue
            }


        ;------------------
        ;-- Shift+Ctrl+Alt
        ;------------------
        if l_limit>=256
            {
            if (HG_ShiftModifier and HG_CtrlModifier and HG_AltModifier)
                {
                l_Message=SHIFT+CTRL+ALT keys are not allowed.
                l_ErrorLevel=256
                break
                }

            l_limit:=l_limit-256
            continue
            }


        ;-------------
        ;-- Shift+Win
        ;-------------
        if l_limit>=128
            {
            if (HG_ShiftModifier and HG_WinModifier)
                {
                l_Message=SHIFT+WIN keys are not allowed.
                l_ErrorLevel=128
                break
                }

            l_limit:=l_limit-128
            continue
            }


        ;-------------
        ;-- Shift+Alt
        ;-------------
        if l_limit>=64
            {
            if (HG_ShiftModifier and HG_AltModifier)
                {
                l_Message=SHIFT+ALT keys are not allowed.
                l_ErrorLevel=64
                break
                }

            l_limit:=l_limit-64
            continue
            }


        ;--------------
        ;-- Shift+Ctrl
        ;--------------
        if l_limit>=32
            {
            if (HG_ShiftModifier and HG_CtrlModifier)
                {
                l_Message=SHIFT+CTRL keys are not allowed.
                l_ErrorLevel=32
                break
                }

            l_limit:=l_limit-32
            continue
            }


        ;------------
        ;-- Win only
        ;------------
        if l_limit>=16
            {
            if (HG_WinModifier
            and not (HG_CtrlModifier or HG_ShiftModifier or HG_AltModifier))
                {
                l_Message=WIN-only keys are not allowed.
                l_ErrorLevel=16
                break
                }

            l_limit:=l_limit-16
            continue
            }


        ;------------
        ;-- Alt only
        ;------------
        if l_limit>=8
            {
            if (HG_AltModifier
            and not (HG_CtrlModifier or HG_ShiftModifier or HG_WinModifier))
                {
                l_Message=ALT-only keys are not allowed.
                l_ErrorLevel=8
                break
                }

            l_limit:=l_limit-8
            continue
            }


        ;-------------
        ;-- Ctrl only
        ;-------------
        if l_limit>=4
            {
            if (HG_CtrlModifier
            and not (HG_ShiftModifier or HG_WinModifier or HG_AltModifier))
                {
                l_Message=CTRL-only keys are not allowed.
                l_ErrorLevel=4
                break
                }

            l_limit:=l_limit-4
            continue
            }


        ;--------------
        ;-- Shift only
        ;--------------
        if l_limit>=2
            {
            if (HG_ShiftModifier
            and not (HG_CtrlModifier or HG_WinModifier or HG_AltModifier))
                {
                l_Message=SHIFT-only keys are not allowed.
                l_ErrorLevel=2
                break
                }

            l_limit:=l_limit-2
            continue
            }


        ;--------------
        ;-- Unmodified
        ;--------------
        ;if l_limit>=1
        ;    {
        ;    if not (HG_CtrlModifier
        ;        or  HG_ShiftModifier
        ;        or  HG_WinModifier
        ;        or  HG_AltModifier)
        ;        {
        ;        l_Message=
        ;           (ltrim join`s
        ;            At least one modifier must be used.
        ;           )

        ;        l_ErrorLevel=1
        ;        break
        ;        }

        ;    l_limit:=l_limit-1
        ;    continue
        ;    }
        l_limit := -1
        }


    ;[====================]
    ;[  Display message?  ]
    ;[====================]
    if l_ErrorLevel
        if p_LimitMsg
            {
            ;-- Display message
            MsgBox 262160
                ,%p_Title%
                ,%l_Message%

            ;-- Reset l_ErrorLevel
            l_ErrorLevel=0

            ;-- Send 'em back
            return
            }


    ;[==================]
    ;[  Ok, We're done  ]
    ;[   Shut it done   ]
    ;[==================]
    gosub HotkeyGUIExit


    ;-- Return to sender
    return



    ; ***********************
    ; *                     *
    ; *    Close up shop    *
    ; *                     *
    ; ***********************
    HotkeyGUIEscape:
    HotkeyGUIClose:
    HG_Hotkey:=""
    l_ErrorLevel=10003


    HotkeyGUIExit:

;;;;;    ;-- Set GUI default (needed because of timer)
;;;;;    gui %l_GUI%:Default


    ;-- Enable the parent window
    gui %p_ParentGUI%:-Disabled


    ;-- Destroy the HotkeyGUI window so that the window can be reused
    gui destroy

    return  ;-- End of subroutines
    }
