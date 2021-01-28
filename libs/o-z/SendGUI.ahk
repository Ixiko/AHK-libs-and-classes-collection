SendGUI()
;-----------------------------
; 
; Function: SendGUI
;
; Description:
;
;   This function displays a dialog that will allow the user to select a hotkey
;   without using the keyboard.  See the "Processing and Usage Notes" section
;   for more information.
;
;
; Parameters:
;
;   p_Owner - The GUI owner of the SendGUI window. [Optional] The default is
;       0 (no owner).  If not defined, the AlwaysOnTop attribute is added to the
;       SendGUI window to make sure that the window is not lost.
;
;   p_Hotkey - The default hotkey value. [Optional] The default is blank.  To
;       only preselect modifiers and/or optional attributes, enter only the
;       associated characters.  For example, to only have the Ctrl and Shift
;       modifiers set as the default, enter "^+".
;
;   p_Limit - Hotkey limit. [Optional] The default is 0.  See the "Hotkey
;       Limits" section below for more information.
;
;   p_OptionalAttrib - Optional hotkey attributes. [Optional]  The default is
;       FALSE.  If set to TRUE, all items in the Optional Attributes group are
;       enabled and the user is allowed to add or remove optional attributes.
;
;   p_Title - Window title. [Optional]  The default is the current script name
;       (sans the extention) plus "Select Hotkey".
;
;
; Processing And Usage Notes:
;
; Stuff to know...
;
;    *  The function does not return until the SendGUI window is closed
;       (Accept or Cancel).
;
;    *  A shift-only key (Ex: ~!@#$%^&*()_+{}|:"<>?) cannot be directly selected
;       as a key by this function.  To use a shift-only key, select the Shift
;       modifier and then select the non-shift version of the key.  For example,
;       to set the "(" key as a hotkey, select the Shift modifier and then
;       select the "9" key.  The net result is the "(" key.  In addition,
;       shift-only keys are not supported as values for the p_Hotkey parameter
;       as a default hotkey.  If a shift-only key is used, no default key will
;       be selected.
;
;    *  To resolve a minor AutoHotkey inconsistency, the "Pause" key and the
;       "Break" keys are automatically converted to the "CtrlBreak" key if the
;       Ctrl modifier is selected.  The "CtrlBreak" key is automatically
;       converted to the "Pause" key if the Ctrl modifier is not selected.
;
;
; Hotkey Limits:
;
;   The p_Limit parameter allows the developer to restrict the types of keys
;   that are selected.  The following limit values are available:
;
;       (start code)
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
;       (end)
;
;   To use a limit, enter the sum of one or more of these limit values.  For
;   example, a limit value of 1 will prevent unmodified keys from being used.
;   A limit value of 31 (1 + 2 + 4 + 8 + 16) will require that at least two
;   modifier keys be used.
;
;
; Returns:
;
;   If the function ends after the user has selected a valid key and the
;   "Accept" button is pressed, the function returns the selected key in the
;   standard AutoHotkey hotkey format and ErrorLevel is set to 0.
;   Example: Hotkey=^a  ErrorLevel=0
;
;   If the SendGUI window is canceled (Cancel button, Close button, or Escape
;   key), the function returns the original hotkey value (p_Hotkey) and
;   Errorlevel is set to 1.
;
;   If the function is unable to create a SendGUI window for any reason,
;   ErrorLevel is set to the word FAIL.
;
;
; Calls To Other Functions:
;
;   PopupXY (optional)
;
;
; Hotkey Support:
;
;   AutoHotkey is a very robust program and can accept hotkey definitions in an
;   multitude of formats.  Unfortunately, this function is not that robust and
;   there are a couple of important limitations:
;
;    1.  The p_Limit parameter restricts the type of keys that can be supported.
;       For this reason, the following keys are not supported:
;
;        * *Modifier keys* (as hotkeys). Example: Alt, Shift, LWin, etc.
;        * *Joystick keys*. Example: Joy1, Joy2, etc.
;        * *Custom combinations*. Example: Numpad0 & Numpad1.
;
;    2.  Shift-only keys (Ex: "~","!","@","#",etc.) are not supported.  See the
;       "Processing and Usage Notes" section for more information.
;
;
; Programming Notes:
;
;   To keep the code as friendly as possible, static variables (in lieu of
;   global variables) are used whenever a GUI object needs a variable. Object
;   variables are defined so that a single "gui Submit" command can be used to
;   collect the GUI values instead of having to execute a "GUIControlGet"
;   command on every GUI control. For the few GUI objects that are
;   programmatically updated, the ClassNN (class name and instance number of the
;   object  Ex: Static4) is used.
;
;   Important: Any changes to the GUI (additions, deletions, etc.) may change
;   the ClassNN of objects that are updated.  Use Window Spy (or similar
;   program) to identify any changes.
;
;-------------------------------------------------------------------------------
SendGUI(p_Owner=0,p_Hotkey="",p_Limit="",p_OptionalAttrib=False,p_Title="")
    {
;	Gui, Options:+Disabled
    ;[====================]
    ;[  Static variables  ]
    ;[====================]
    Static s_GUI:=0
                ;-- This variable stores the currently active GUI.  If not zero
                ;   when entering the function, the GUI is currently showing.

          ,s_StartGUI:=53
                ;-- Default starting GUI window number for SendGUI window.
                ;   Change if desired.

          ,s_PopupXY_Function:="PopupXY"
                ;-- Name of the PopupXY function.  Defined as a variable so that
                ;   function will use if the "PopupXY" function is included but
                ;   will not fail if it's not.

    ;[===========================]
    ;[  Window already showing?  ]
    ;[===========================]
    if s_GUI
        {
        Errorlevel:="FAIL"
        outputdebug,
           (ltrim join`s
            End Func: %A_ThisFunc% -
            A %A_ThisFunc% window already exists.  Errorlevel=FAIL
           )

        Return
        }

    ;[==============]
    ;[  Initialize  ]
    ;[==============]
    SplitPath A_ScriptName,,,,l_ScriptName
    l_ErrorLevel  :=0

    ;-------------
    ;-- Key lists
    ;-------------
    ;-- Standard keys
    l_StandardKeysList=
       (ltrim join|
        a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z
        0|1|2|3|4|5|6|7|8|9|0        
        {``}|{-}|{=}|{[}|{]}|{`\}|{+}|;
        '|,|.|/
        {Space}
        {Tab}
        {Enter}
        {Escape}
        {Backspace}
        {Delete}
        {ScrollLock}
        {CapsLock}
        {NumLock}
        {PrintScreen}
        {CtrlBreak}
        {Pause}
        {Break}
        {Insert}
        {Home}
        {End}
        {PgUp}
        {PgDn}
        {Up}
        {Down}
        {Left}
        {Right}
       )

    ;-- Function keys
    l_FunctionKeysList=
       (ltrim join|
        {F1}|{F2}|{F3}|{F4}|{F5}|{F6}|{F7}|{F8}|{F9}|{F10}
        {F11}|{F12}|{F13}|{F14}|{F15}|{F16}|{F17}|{F18}|{F19}|{F20}
        {F21}|{F22}|{F23}|{F24}
       )

    ;-- Numpad
    l_NumpadKeysList=
       (ltrim join|
        {NumLock}
        {NumpadDiv}
        {NumpadMult}
        {NumpadAdd}
        {NumpadSub}
        {NumpadEnter}
        {NumpadDel}
        {NumpadIns}
        {NumpadClear}
        {NumpadUp}
        {NumpadDown}
        {NumpadLeft}
        {NumpadRight}
        {NumpadHome}
        {NumpadEnd}
        {NumpadPgUp}
        {NumpadPgDn}
        {Numpad0}
        {Numpad1}
        {Numpad2}
        {Numpad3}
        {Numpad4}
        {Numpad5}
        {Numpad6}
        {Numpad7}
        {Numpad8}
        {Numpad9}
        {NumpadDot}
       )

    ;-- Mouse
    l_MouseKeysList=
       (ltrim join|
        {LButton}
        {RButton}
        {MButton}
        {WheelDown}
        {WheelUp}
        {XButton1}
        {XButton2}
       )

    ;-- Multimedia
    l_MultimediaKeysList=
       (ltrim join|
        {Browser_Back}
        {Browser_Forward}
        {Browser_Refresh}
        {Browser_Stop}
        {Browser_Search}
        {Browser_Favorites}
        {Browser_Home}
        {Volume_Mute}
        {Volume_Down}
        {Volume_Up}
        {Media_Next}
        {Media_Prev}
        {Media_Stop}
        {Media_Play_Pause}
        {Launch_Mail}
        {Launch_Media}
        {Launch_App1}
        {Launch_App2}
       )

    ;-- Special
    l_SpecialKeysList:="{Help}|{Sleep}|{AppsKey}"

    ;[==================]
    ;[    Parameters    ]
    ;[  (Set defaults)  ]
    ;[==================]
    ;-- Owner
;    p_Owner=%p_Owner%  ;-- AutoTrim
;    if p_Owner is not Integer
;        p_Owner:=0
;     else
;        if p_Owner not Between 1 and 99
;            p_Owner:=0

    ;-- Owner window exists?
    if p_Owner
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

    ;-- Default hotkey
    l_Hotkey=%p_Hotkey%  ;-- AutoTrim

    ;-- Limit
    p_Limit=%p_Limit%  ;-- AutoTrim
    if p_Limit is not Integer
        p_Limit:=0
     else
        if p_Limit not between 0 and 2047
            p_Limit:=0

    ;-- Title
    p_Title=%p_Title%  ;-- AutoTrim
    if p_Title is Space
        p_Title:=l_ScriptName . " - Select Hotkey"
     else
        {
        ;-- Append to script name if p_title begins with "++"?
        if SubStr(p_Title,1,2)="++"
            {
            StringTrimLeft p_Title,p_Title,2
            p_Title:=l_ScriptName . A_Space . p_Title
            }
        }

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

            s_GUI:=0
            ErrorLevel:="FAIL"
            Return
            }

        ;-- Increment window
        s_GUI++
        }

    ;[=============]
    ;[  Build GUI  ]
    ;[=============]
    ;-- Assign ownership
    if p_Owner
        {
        gui %p_Owner%:+Disabled      ;-- Disable Owner window
        gui %s_GUI%:+Owner%p_Owner%  ;-- Set ownership
        }
     else
        gui %s_GUI%:+Owner           ;-- Gives ownership to the script window

    ;-- GUI options
    gui %s_GUI%:Margin,6,6
    gui %s_GUI%:-MinimizeBox +LabelSendGUI_

    if not p_Owner
        gui %s_GUI%:+AlwaysOnTop

    ;---------------
    ;-- GUI objects
    ;---------------
    ;-- Modifiers
    Static HG_ModifierGB
    gui %s_GUI%:Add
       ,GroupBox
       , xm y10 w170 h10 vHG_ModifierGB
       ,Modifier

    Static HG_CtrlModifier
    gui %s_GUI%:Add
       ,CheckBox
       ,xp+10 yp+20 Section vHG_CtrlModifier gSendGUI_UpdateHotkey
       ,Ctrl

    Static HG_ShiftModifier
    gui %s_GUI%:Add
       ,CheckBox
       ,xs vHG_ShiftModifier gSendGUI_UpdateHotkey
       ,Shift

    Static HG_WinModifier
    gui %s_GUI%:Add
       ,CheckBox
       ,xs vHG_WinModifier gSendGUI_UpdateHotkey Disabled
       ,Win

    Static HG_AltModifier
    gui %s_GUI%:Add
       ,CheckBox
       ,xs vHG_AltModifier gSendGUI_UpdateHotkey
       ,Alt

    ;-- Optional Attributes
    Static HG_OptionalAttributesGB
    gui %s_GUI%:Add
       ,GroupBox
       ,xs+160 y10 w170 h10 vHG_OptionalAttributesGB
       ,Optional Attributes

    Static HG_NativeOption
    gui %s_GUI%:Add
       ,CheckBox
       ,xp+10 yp+20 Disabled Section vHG_NativeOption gSendGUI_UpdateHotkey
       ,~ (Native)

    Static HG_WildcardOption
    gui %s_GUI%:Add
       ,CheckBox
       ,xs Disabled vHG_WildcardOption gSendGUI_UpdateHotkey
       ,*  (Wildcard)

    Static HG_LeftPairOption
    gui %s_GUI%:Add                                                 ;-- Button9
       ,CheckBox
       ,xs Disabled vHG_LeftPairOption gSendGUI_LeftPair
       ,< (Left pair only)

    Static HG_RightPairOption
    gui %s_GUI%:Add                                                 ;-- Button10
       ,CheckBox
       ,xs Disabled vHG_RightPairOption gSendGUI_RightPair
       ,> (Right pair only)

    ;-- Enable "Optional Attributes"?
    if p_OptionalAttrib
        {
        GUIControl %s_GUI%:Enable,HG_NativeOption
        GUIControl %s_GUI%:Enable,HG_WildcardOption
        GUIControl %s_GUI%:Enable,HG_LeftPairOption
        GUIControl %s_GUI%:Enable,HG_RightPairOption
        }

    ;-- Resize the Modifier and Optional Attributes group boxes
    GUIControlGet $Group1Pos,%s_GUI%:Pos,HG_OptionalAttributesGB
    GUIControlGet $Group2Pos,%s_GUI%:Pos,HG_RightPairOption
    GUIControl
        ,%s_GUI%:Move
        ,HG_ModifierGB
        ,% "h" . ($Group2PosY-$Group1PosY)+$Group2PosH+10

    GUIControl
        ,%s_GUI%:Move
        ,HG_OptionalAttributesGB
        ,% "h" . ($Group2PosY-$Group1PosY)+$Group2PosH+10

    ;-- Keys
    YPos:=($Group2PosY-$Group1PosY)+$Group2PosH+20
    gui %s_GUI%:Add
       ,GroupBox
       ,xm y%YPos% w340 h180
       ,Keys

    Static HG_StandardKeysView
    gui %s_GUI%:Add
       ,Radio
       ,xp+10 yp+20 Checked Section vHG_StandardKeysView gSendGUI_UpdateKeyList
       ,Standard

    Static HG_FunctionKeysView
    gui %s_GUI%:Add
       ,Radio
       ,xs vHG_FunctionKeysView gSendGUI_UpdateKeyList
       ,Function keys

    Static HG_NumpadKeysView
    gui %s_GUI%:Add
       ,Radio
       ,xs vHG_NumpadKeysView gSendGUI_UpdateKeyList
       ,Numpad

    Static HG_MouseKeysView
    gui %s_GUI%:Add
       ,Radio
       ,xs vHG_MouseKeysView gSendGUI_UpdateKeyList
       ,Mouse

    Static HG_MultimediaKeysView
    gui %s_GUI%:Add
       ,Radio
       ,xs vHG_MultimediaKeysView gSendGUI_UpdateKeyList
       ,Multimedia

    Static HG_SpecialKeysView
    gui %s_GUI%:Add
       ,Radio
       ,xs vHG_SpecialKeysView gSendGUI_UpdateKeyList
       ,Special

    Static HG_Key
    gui %s_GUI%:Add
       ,ListBox                                                     ;-- ListBox1
       ,xs+140 ys w180 h150 vHG_Key gSendGUI_UpdateHotkey

    ;-- Set initial values
    gosub SendGUI_UpdateKeyList

    ;-- Hotkey display
    YPos+=190
    gui %s_GUI%:Add
       ,Text
       ,xm y%YPos% w70
       ,Hotkey:

    gui %s_GUI%:Add
       ,Edit                                                        ;-- Edit1
       ,x+0 w270 +ReadOnly

    gui %s_GUI%:Add
       ,Text
       ,xm y+5 w70 r2 hp
       ,Desc:

    gui %s_GUI%:Add
       ,Text                                                        ;-- Static3
       ,x+0 w270 hp +ReadOnly
       ,None

    ;-- Buttons
    Static HG_AcceptButton
    gui %s_GUI%:Add                                                 ;-- Button18
       ,Button
       ,xm y+5 Default Disabled vHG_AcceptButton gSendGUI_AcceptButton
       ,%A_Space% &Accept %A_Space%
            ;-- Note: All characters are used to determine the button's W+H

    gui %s_GUI%:Add
       ,Button
       ,x+5 wp hp gSendGUI_Close
       ,Cancel
	Gui, %s_GUI%:Font, underline   
	Gui, %s_GUI%:Add, Text, x+150 cBlue gLinkLabel2, Hotkey Help ;linklabel is in the other hotkeygui (as 'link' stoppped working)
	Gui, %s_GUI%:Font, norm
	
    ;[================]
    ;[  Set defaults  ]
    ;[================]
    if l_Hotkey is not Space
        {
        ;-- Modifiers and optional attributes
        Loop
            {
            l_FirstChar:=SubStr(l_Hotkey,1,1)
            if l_FirstChar in ^,+,#,!,~,*,<,>
                {
                if (l_FirstChar="^")
                    GUIControl %s_GUI%:,HG_CtrlModifier,1
                else if (l_FirstChar="+")
                    GUIControl %s_GUI%:,HG_ShiftModifier,1
                else if (l_FirstChar="#")
                    GUIControl %s_GUI%:,HG_WinModifier,1
                else if (l_FirstChar="!")
                    GUIControl %s_GUI%:,HG_AltModifier,1
                else  if (l_FirstChar="~")
                    GUIControl %s_GUI%:,HG_NativeOption,1
                else if (l_FirstChar="*")
                    GUIControl %s_GUI%:,HG_WildcardOption,1
                else if (l_FirstChar="<")
                    GUIControl %s_GUI%:,HG_LeftPairOption,1
                else if (l_FirstChar=">")
                    GUIControl %s_GUI%:,HG_RightPairOption,1
    
                ;-- On to the next
                StringTrimLeft l_Hotkey,l_Hotkey,1
                Continue
                }
    
            ;-- We're done here
            Break
            }
    
        ;-- Find key in key lists
        if l_Hotkey is not Space
            {
            ;-- Standard keys
            if Instr("|" . l_StandardKeysList . "|","|" . l_Hotkey . "|")
                GUIControl %s_GUI%:,HG_StandardKeysView,1
            ;-- Function keys
            else if Instr("|" . l_FunctionKeysList . "|","|" . l_Hotkey . "|")
                GUIControl %s_GUI%:,HG_FunctionKeysView,1
            ;-- Numpad keys
            else if Instr("|" . l_NumpadKeysList . "|","|" . l_Hotkey . "|")
                GUIControl %s_GUI%:,HG_NumpadKeysView,1
            ;-- Mouse keys
            else if Instr("|" . l_MouseKeysList . "|","|" . l_Hotkey . "|")
                GUIControl %s_GUI%:,HG_MouseKeysView,1
            ;-- Multimedia keys
            else if Instr("|" . l_MultimediaKeysList . "|","|" . l_Hotkey . "|")
                GUIControl %s_GUI%:,HG_MultimediaKeysView,1
            ;-- Special keys
            else if Instr("|" . l_SpecialKeysList . "|","|" . l_Hotkey . "|")
                GUIControl %s_GUI%:,HG_SpecialKeysView,1
    
            ;-- Update keylist and select it
            gosub SendGUI_UpdateKeyList
            GUIControl %s_GUI%:ChooseString,HG_Key,%l_Hotkey%
            }

        ;-- Update Hotkey field and description
        gosub SendGUI_UpdateHotkey
        }
        
  If (p_Limit = 2046)
  {
    GUIControl %s_GUI%:Disable, HG_CtrlModifier
    GUIControl %s_GUI%:, HG_CtrlModifier, 0
    GUIControl %s_GUI%:Disable, HG_ShiftModifier
    GUIControl %s_GUI%:, HG_ShiftModifier,0
    GUIControl %s_GUI%:Disable, HG_WinModifier, 0
    GUIControl %s_GUI%:,HG_WinModifier,0
    GUIControl %s_GUI%:Disable, HG_AltModifier
    GUIControl %s_GUI%:, HG_AltModifier, 0  
  }

    ;[=============]
    ;[  Set focus  ]
    ;[=============]
    GUIControl %s_GUI%:Focus,HG_AcceptButton
        ;-- Note: This only works when the Accept button is enabled

    ;[================]
    ;[  Collect hWnd  ]
    ;[================]
    gui %s_GUI%:+LastFound
    WinGet l_SendGUI_hWnd,ID

    ;[===============]
    ;[  Show window  ]
    ;[===============]
     if p_Owner and IsFunc(s_PopupXY_Function)
        {
        gui %s_GUI%:Show,Hide,%p_Title%   ;-- Render but don't show
        %s_PopupXY_Function%(p_Owner,"ahk_id " . l_SendGUI_hWnd,PosX,PosY)
        gui %s_GUI%:Show,x%PosX% y%PosY%  ;-- Show in the correct location
        }
     else
        gui %s_GUI%:Show,,%p_Title%

    ;[=====================]
    ;[  Loop until window  ]
    ;[      is closed      ]
    ;[=====================]
    WinWaitClose ahk_id %l_SendGUI_hWnd%

    ;[====================]
    ;[  Return to sender  ]
    ;[====================]
    ErrorLevel:=l_ErrorLevel
    Return HG_HotKey  ;-- End of function

LinkLabel2:
	Run http://www.autohotkey.com/docs/Hotkeys.htm
	Return 	

    ;*****************************
    ;*                           *
    ;*                           *
    ;*        Subroutines        *
    ;*        (SendGUI)        *
    ;*                           *
    ;*                           *
    ;*****************************
    ;***********************
    ;*                     *
    ;*    Update Hotkey    *
    ;*                     *
    ;***********************
    SendGUI_UpdateHotkey:

    ;-- Collect form values
    gui %s_GUI%:Submit,NoHide

    ;-- Enable/Disable Accept button
    if (HG_Key || HG_Key = 0)
        GUIControl %s_GUI%:Enable,Button18
     else
        GUIControl %s_GUI%:Disable,Button18

    ;-- Substitute Pause|Break for CtrlBreak?
    if HG_Key in Pause,Break
        if HG_CtrlModifier
            HG_Key:="CtrlBreak"

    ;-- Substitute CtrlBreak for Pause (Break would work OK too)
    if (HG_Key="CtrlBreak")
        if not HG_CtrlModifier
            HG_Key:="Pause"

    ;[================]
    ;[  Build Hotkey  ]
    ;[================]
    ;-- Initialize
    HG_Hotkey:=""
    HG_HKDesc:=""

    ;-- Options
    if HG_NativeOption
        HG_Hotkey.="~"

    if HG_WildcardOption
        HG_Hotkey.="*"

    if HG_LeftPairOption
        HG_Hotkey.="<"

    if HG_RightPairOption
        HG_Hotkey.=">"

    ;-- Modifiers
    if HG_CtrlModifier
        {
        HG_Hotkey.="^"
        HG_HKDesc.="Ctrl + "
        }

    if HG_ShiftModifier
        {
        HG_Hotkey.="+"
        HG_HKDesc.="Shift + "
        }

    if HG_WinModifier
        {
        HG_Hotkey.="#"
        HG_HKDesc.="Win + "
        }

    if HG_AltModifier
        {
        HG_Hotkey.="!"
        HG_HKDesc.="Alt + "
        }

    HG_Hotkey.=HG_Key
    HG_HKDesc.=HG_Key

    ;-- Update Hotkey and HKDescr fields
    GUIControl %s_GUI%:,Edit1,%HG_Hotkey%
    GUIControl %s_GUI%:,Static3,%HG_HKDesc%
    return


    ;**********************
    ;*                    *
    ;*    Pair options    *
    ;*                    *
    ;**********************
    SendGUI_LeftPair:

    ;-- Deselect HG_RightPairOption
    GUIControl %s_GUI%:,Button10,0
    gosub SendGUI_UpdateHotkey
    return


    SendGUI_RightPair:

    ;-- Deselect HG_LeftPairOption
    GUIControl %s_GUI%:,Button9,0
    gosub SendGUI_UpdateHotkey
    return


    ;*************************
    ;*                       *
    ;*    Update Key List    *
    ;*                       *
    ;*************************
    SendGUI_UpdateKeyList:

    ;-- Collect form values
    gui %s_GUI%:Submit,NoHide

    ;-- Standard
    if HG_StandardKeysView
        l_KeysList:=l_StandardKeysList
     else
        ;-- Function keys
        if HG_FunctionKeysView
            l_KeysList:=l_FunctionKeysList
         else
            ;-- Numpad
            if HG_NumpadKeysView
                l_KeysList:=l_NumpadKeysList
             else
                ;-- Mouse
                if HG_MouseKeysView
                    l_KeysList:=l_MouseKeysList
                 else
                    ;-- Multimedia
                    if HG_MultimediaKeysView
                        l_KeysList:=l_MultimediaKeysList
                     else
                        ;-- Special
                        if HG_SpecialKeysView
                            l_KeysList:=l_SpecialKeysList

    ;-- Update l_KeysList
    GUIControl %s_GUI%:-Redraw,ListBox1
    GUIControl %s_GUI%:,ListBox1,|%l_KeysList%
    GUIControl %s_GUI%:+Redraw,ListBox1

    ;--- Reset HG_Hotkey and HG_HKDesc
    HG_Key:=""
    gosub SendGUI_UpdateHotkey
    return


    ;***********************
    ;*                     *
    ;*    Accept Button    *
    ;*                     *
    ;***********************
    SendGUI_AcceptButton:

    ;-- (The following test is now redundant but it is retained as a fail-safe)
    ;-- Any key?
    if HG_Key is Space
        {
        gui %s_GUI%:+OwnDialogs
        MsgBox
            ,16         ;-- Error icon
            ,%p_Title%
            ,A key must be selected.  %A_Space%

        return
        }

    ;[===============]
    ;[  Limit tests  ]
    ;[===============]
    l_Limit:=p_Limit
    l_LimitFailure:=False

    ;-- Loop until failure or until all tests have been performed
    Loop
        {
        ;-- Are we done here?
        if (l_limit<=0)
            Break

        ;-----------------
        ;-- Shift+Win+Alt
        ;-----------------
        if (l_limit>=1024)
            {
            if (HG_ShiftModifier and HG_WinModifier and HG_AltModifier)
                {
                l_Message:="SHIFT+WIN+ALT keys are not allowed."
                l_LimitFailure:=True
                Break
                }

            l_limit-=1024
            Continue
            }

        ;------------------
        ;-- Shift+Ctrl+Win
        ;------------------
        if (l_limit>=512)
            {
            if (HG_ShiftModifier and HG_CtrlModifier and HG_WinModifier)
                {
                l_Message:="SHIFT+CTRL+WIN keys are not allowed."
                l_LimitFailure:=True
                Break
                }

            l_limit-=512
            Continue
            }

        ;------------------
        ;-- Shift+Ctrl+Alt
        ;------------------
        if (l_limit>=256)
            {
            if (HG_ShiftModifier and HG_CtrlModifier and HG_AltModifier)
                {
                l_Message:="SHIFT+CTRL+ALT keys are not allowed."
                l_LimitFailure:=True
                Break
                }

            l_limit-=256
            Continue
            }

        ;-------------
        ;-- Shift+Win
        ;-------------
        if (l_limit>=128)
            {
            if (HG_ShiftModifier and HG_WinModifier)
                {
                l_Message:="SHIFT+WIN keys are not allowed."
                l_LimitFailure:=True
                Break
                }

            l_limit-=128
            Continue
            }

        ;-------------
        ;-- Shift+Alt
        ;-------------
        if (l_limit>=64)
            {
            if (HG_ShiftModifier and HG_AltModifier)
                {
                l_Message:="SHIFT+ALT keys are not allowed."
                l_LimitFailure:=True
                Break
                }

            l_limit-=64
            Continue
            }

        ;--------------
        ;-- Shift+Ctrl
        ;--------------
        if (l_limit>=32)
            {
            if (HG_ShiftModifier and HG_CtrlModifier)
                {
                l_Message:="SHIFT+CTRL keys are not allowed."
                l_LimitFailure:=True
                Break
                }

            l_limit-=32
            Continue
            }

        ;------------
        ;-- Win only
        ;------------
        if (l_limit>=16)
            {
            if (HG_WinModifier
            and not (HG_CtrlModifier or HG_ShiftModifier or HG_AltModifier))
                {
                l_Message:="WIN-only keys are not allowed."
                l_LimitFailure:=True
                Break
                }

            l_limit-=16
            Continue
            }

        ;------------
        ;-- Alt only
        ;------------
        if (l_limit>=8)
            {
            if (HG_AltModifier
            and not (HG_CtrlModifier or HG_ShiftModifier or HG_WinModifier))
                {
                l_Message:="ALT-only keys are not allowed."
                l_LimitFailure:=True
                Break
                }

            l_limit-=8
            Continue
            }

        ;-------------
        ;-- Ctrl only
        ;-------------
        if (l_limit>=4)
            {
            if (HG_CtrlModifier
            and not (HG_ShiftModifier or HG_WinModifier or HG_AltModifier))
                {
                l_Message:="CTRL-only keys are not allowed."
                l_LimitFailure:=True
                Break
                }

            l_limit-=4
            Continue
            }

        ;--------------
        ;-- Shift only
        ;--------------
        if (l_limit>=2)
            {
            if (HG_ShiftModifier
            and not (HG_CtrlModifier or HG_WinModifier or HG_AltModifier))
                {
                l_Message:="SHIFT-only keys are not allowed."
                l_LimitFailure:=True
                Break
                }

            l_limit-=2
            Continue
            }

        ;--------------
        ;-- Unmodified
        ;--------------
        if (l_limit>=1)
            {
            if not (HG_CtrlModifier
                or  HG_ShiftModifier
                or  HG_WinModifier
                or  HG_AltModifier)
                {
                l_Message=
                   (ltrim join`s
                    At least one modifier must be used.  Other restrictions
                    may apply.
                   )

                l_LimitFailure:=True
                Break
                }

            l_limit-=1
            Continue
            }
        }

    ;[====================]
    ;[  Display message?  ]
    ;[====================]
    if l_LimitFailure
        {
        ;-- Display message
        gui %s_GUI%:+OwnDialogs
        MsgBox
            ,16         ;-- Error icon
            ,%p_Title%
            ,%l_Message%  %A_Space%

        ;-- Send 'em back
        return
        }

    ;[==================]
    ;[  Ok, We're done  ]
    ;[   Shut it done   ]
    ;[==================]
    gosub SendGUI_Exit
    return


    ;***********************
    ;*                     *
    ;*    Close up shop    *
    ;*                     *
    ;***********************
    SendGUI_Escape:
    SendGUI_Close:
    HG_Hotkey:=p_Hotkey
    l_ErrorLevel:=1


    SendGUI_Exit:
;	Gui, Options:-Disabled
    ;-- Enable Owner window
    if p_Owner
        gui %p_Owner%:-Disabled

    ;-- Destroy the SendGUI window so that the window can be reused
    gui %s_GUI%:Destroy
    s_GUI:=0
    return  ;-- End of subroutines
    }