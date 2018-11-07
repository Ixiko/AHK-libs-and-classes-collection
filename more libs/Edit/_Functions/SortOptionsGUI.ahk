;------------------------------
;
; Function: SortOptionsGUI
;
; Description:
;
;   Displays a dialog that will allow the user to enter/select AutoHotkey sort
;   options.
;
; Parameters:
;
;   p_Owner - Owner GUI.  Set to 0 for no owner.  See the *Owner* section for
;       more information.
;
;   p_SortOptions - Default sort options. [Optional]  The default is blank.
;       IMPORTANT: Not all AutoHotkey sort options are supported.  Only the
;       options represented in this GUI are supported.  Additional options may
;       be added in the future.
;
;   p_Title - Window title. [Optional]  The default is "Sort Options".
;
;   p_Font - Typeface name and/or font options. [Optional] See the *Font*
;       section for more information.
;
; Returns:
;
;   If the user clicks on the "OK" button, the function returns the selected
;   sort options and ErrorLevel is set to 0.  Note: A return value of blank/null
;   is possible/likely.  It indicates that all sort defaults are used.  See the
;   AutoHotkey documentation for more information.
;
;   If the SortOptionsGUI window is canceled ("Cancel" button, Close button, or
;   Escape key), the function returns the original sort options (p_SortOptions)
;   and Errorlevel is set to 1.
;
;   If the function is unable to create a SortOptionsGUI window for any reason,
;   the original sort options (p_SortOptions) are returned and ErrorLevel is set
;   to the word FAIL.
;
;   Important: ErrorLevel is a system variable and is used by many commands.
;   If unable to test ErrorLevel immediate after calling this function, assign
;   the value to another variable so that the return value is retained.
;
; Calls To Other Functions:
;
; * Fnt [Library]
; * MoveChildWindow
; * WinGetPosEx (called from MoveChildWindow)
;
; Font:
;
;   p_Font is an optional parameter that allows the developer to set a specific
;   font for the SortOptionsGUI window.  The syntax is: {FontName}:{FontOptions}.  Ex:
;   "Arial:s10 bold".  All components of this parameter are optional.  If a
;   typeface name is not specified (Ex: ":s12 bold"), the default system GUI
;   font is used.  If no font options are specified (Ex: "Arial" or "Arial:"),
;   the default font options are used.  See the AutoHotkey documentation for a
;   list of (and syntax of) font options.
;
;   Exception/Feature: If the p_Font parameter is set to "Message", the system
;   font used for Message Box dialog is used.  In general, this font is a bit
;   larger and easier to read than the default GUI font.
;
; Owner:
;
;   The p_Owner parameter is used to specify the owner of the SortOptionsGUI
;   window. Set to 0 for no owner.  For an AutoHotkey GUI, specify a valid GUI
;   number (1-99), a GUI name, or the handle to the GUI.  For a non-AutoHotkey
;   window, specify the handle to the window.  If an AutoHotkey window is
;   specified, the owner window is disabled and ownership of the SortOptionsGUI
;   window is assigned to the owner window.  This makes the SortOptionsGUI
;   window modal which prevents the user from interacting with the owner window
;   until the SortOptionsGUI window is closed.  For all owner windows, the
;   SortOptionsGUI window is positioned in the center of the owner window or as
;   close to the center as possible.  If no owner is specified or if a
;   non-AutoHotkey window is specified, the AlwaysOnTop attribute is added to
;   the SortOptionsGUI dialog to make sure that the window is not lost.
;
; Processing and Usage Notes:
;
;   The function does not return until the user closes the SortOptionsGUI
;   window.
;
; Programming Notes:
;
;   Static variables (in lieu of global variables) are used whenever a GUI
;   object needs a variable.  Object variables are defined so that a single "gui
;   Submit" command can be used to collect the GUI values instead of having to
;   execute a "GUIControlGet" command on every GUI control.
;
;-------------------------------------------------------------------------------
SortOptionsGUI(p_Owner="",p_SortOptions="",p_Title="",p_Font="")
    {
    Static Dummy2590

          ;-- System metrics variables
          ,CXMENUCHECK
          ,CYMENUCHECK

          ;-- GUI constants
          ,GUI_CTL_VERTICAL_DEADSPACE:=8

          ;-- System metrics constants
          ,SM_CXMENUCHECK:=71
                ;-- Width of the default menu check-mark bitmap, in pixels.
          ,SM_CYMENUCHECK:=72
                ;-- Height of the default menu check-mark bitmap, in pixels.

          ;-- General constants
          ,s_FirstCall:=True

    ;[====================]
    ;[  Already showing?  ]
    ;[====================]
    ;-- Bounce (with prejudice) if a SortOptionsGUI window already showing
    gui SortOptionsGUI:+LastFoundExist
    IfWinExist
        {
        outputdebug,
           (ltrim join`s
            End Func: %A_ThisFunc% -
            A %A_ThisFunc% window already exists.  Errorlevel=FAIL
           )

        SoundPlay *-1  ;-- System beep
        Errorlevel:="FAIL"
        Return p_SortOptions
        }

    ;[==============]
    ;[  Initialize  ]
    ;[==============]
    SplitPath A_ScriptName,,,,l_ScriptName
    l_ErrorLevel:=0

    ;-- First call
    if s_FirstCall
        {
        s_FirstCall:=False

        ;-- System Metrics
        SysGet CXMENUCHECK,%SM_CXMENUCHECK%
        SysGet CYMENUCHECK,%SM_CYMENUCHECK%
        }

    ;[==================]
    ;[    Parameters    ]
    ;[  (Set defaults)  ]
    ;[==================]
    ;-- Owner
    if p_Owner  ;-- Not null/zero
        {
        ;-- Assign to hOwner if p_Owner is a valid window handle
        hOwner:=WinExist("ahk_id " . p_Owner)

        ;-- Determine if p_Owner is a valid AutoHotkey window and if so,
        ;   identify the window handle.  Note: The Try command is used because
        ;   AutoHotkey will generate a run-time error if p_Owner is not a valid
        ;   GUI number (1 thru 99), a valid GUI name, or a window handle that is
        ;   not an AutoHotkey GUI.
        Try
            {
            gui %p_Owner%:+LastFoundExist
            IfWinExist
                {
                gui %p_Owner%:+LastFound
                hOwner:=WinExist()
                }
             else  ;-- GUI not found
                p_Owner:=0
            }
         Catch  ;-- Not an AutoHotkey GUI
            p_Owner:=0
        }

    ;-- Title
    p_Title:=Trim(p_Title," `f`n`r`t`v")
        ;-- Remove all leading/trailing white space
    if p_Title is Space
        p_Title:="Sort Options"

    ;-- Font
    hFont:=0
    if p_Font
        {
        Loop Parse,p_Font,:
            if (A_Index=1)
                l_FontName:=A_LoopField
             else
                {
                l_FontOptions:=A_LoopField
                Break
                }

        if (l_FontName="Message")
            {
            l_FontName:=Fnt_GetMessageFontName()
            if not Fnt_FOGetSize(l_FontOptions)
                Fnt_FOSetSize(l_FontOptions,Fnt_GetMessageFontSize())
            }

        hFont:=Fnt_CreateFont(l_FontName,l_FontOptions)
        }

    ;[=============]
    ;[  Build GUI  ]
    ;[=============]
    ;-- Assign ownership
    ;   Note: Ownership commands must be performed before any other GUI commands
    if p_Owner
        {
        gui %p_Owner%:+Disabled      ;-- Disable Owner window
        gui SortOptionsGUI:+Owner%p_Owner%  ;-- Set ownership
        }
     else
        gui SortOptionsGUI:+Owner           ;-- Gives ownership to the script window

    ;-- Establish initial font characteristics
    Fnt_GetDefaultGUIMargins(hFont,l_MarginX,l_MarginY,False)
    l_MarginX  :=l_MarginY:=l_MarginY+1
    l_FontH    :=Fnt_GetFontHeight(hFont)
    l_CheckboxH:=l_RadioH:=(CYMENUCHECK>l_FontH ? CYMENUCHECK:l_FontH)

    Fnt_GetStringSize(hFont,"Cancelxxxx",l_ButtonW)
    if Fnt_IsFixedPitchFont(hFont)
        l_ButtonW-=Fnt_GetFontAvgCharWidth(hFont)*2

    l_GroupBoxW:=(l_ButtonW*3)+(l_MarginX*2)

    ;-- GUI options
    gui SortOptionsGUI:-DPIScale +hWndhSortOptionsGUI +LabelSortOptionsGUI_ -MinimizeBox
    gui SortOptionsGUI:Margin,%l_MarginX%,%l_MarginY%
    if not p_Owner
        gui SortOptionsGUI:+AlwaysOnTop

    ;-- Set font
    if hFont
        gui SortOptionsGUI:Font,%l_FontOptions%,%l_FontName%

    ;-- GUI objects
    Static SortOptionsGUI_TypeGB
    gui SortOptionsGUI:Add
       ,GroupBox
       ,% ""
            . "xm ym "
            . "w" . l_GroupBoxW . A_Space
            . "vSortOptionsGUI_TypeGB "
       ,Type

    Static SortOptionsGUI_AlphabeticalSort
    gui SortOptionsGUI:Add
       ,Radio
       ,% ""
            . "xp+" . l_MarginX . A_Space
            . "yp+" . Round(l_FontH*1.2) . A_Space
            . "h" . l_RadioH . A_Space
            . "Checked "
            . "Section "
            . "hWndhAlphabeticalSort "
            . "vSortOptionsGUI_AlphabeticalSort "
            . "gSortOptionsGUI_AlphabeticalSort "
       ,Alphabetical

    Static SortOptionsGUI_CaseSensitive
    gui SortOptionsGUI:Add
       ,Checkbox
       ,% ""
            . "xs+" . CXMENUCHECK+Fnt_HorzDTUs2Pixels(hFont,1) . A_Space
            . "y+" . l_MarginY . A_Space
            . "hp "
            . "hWndhCaseSensitive "
            . "vSortOptionsGUI_CaseSensitive "
       ,Case sensitive

    Static SortOptionsGUI_NumericalSort
    gui SortOptionsGUI:Add
       ,Radio
       ,% ""
            . "xs "
            . "hp "
            . "Group "
            . "hWndhNumericalSort "
            . "vSortOptionsGUI_NumericalSort "
            . "gSortOptionsGUI_NumericalSort "
       ,Numerical

    ;-- Resize the Type group box.  Establish width for all Groupbox controls.
    GUIControlGet l_Group1Pos,SortOptionsGUI:Pos,SortOptionsGUI_TypeGB
    GUIControlGet l_Group2Pos,SortOptionsGUI:Pos,SortOptionsGUI_NumericalSort
    l_GroupBoxH:=(l_Group2PosY-l_Group1PosY)+l_Group2PosH+l_MarginY
    GUIControl
        ,SortOptionsGUI:Move
        ,SortOptionsGUI_TypeGB
        ,h%l_GroupBoxH%

    ;-- Identify the YPos of the Order group box
    l_YPos:=l_Group1PosY+l_GroupBoxH

    Static SortOptionsGUI_OrderGB
    gui SortOptionsGUI:Add
       ,GroupBox
       ,% ""
            . "xm "
            . "y" . l_YPos . A_Space
            . "w" . l_GroupBoxW . A_Space
            . "vSortOptionsGUI_OrderGB "
       ,Order

    gui SortOptionsGUI:Add
       ,Radio
       ,% ""
            . "xp+" . l_MarginX . A_Space
            . "yp+" . Round(l_FontH*1.2) . A_Space
            . "h" . l_RadioH . A_Space
            . "Section "
            . "Checked "
            . "hWndhSortAscending "
       ,Ascending

    Static SortOptionsGUI_SortDescending
    gui SortOptionsGUI:Add
       ,Radio
        ,% ""
            . "xs hp "
            . "vSortOptionsGUI_SortDescending "
       ,Descending

    Static SortOptionsGUI_SortRandom
    gui SortOptionsGUI:Add
        ,Radio
        ,% ""
            . "xs hp "
            . "vSortOptionsGUI_SortRandom "
        ,Random

    ;-- Resize the Order group box
    GUIControlGet l_Group1Pos,SortOptionsGUI:Pos,SortOptionsGUI_OrderGB
    GUIControlGet l_Group2Pos,SortOptionsGUI:Pos,SortOptionsGUI_SortRandom
    l_GroupBoxH:=(l_Group2PosY-l_Group1PosY)+l_Group2PosH+l_MarginY
    GUIControl
        ,SortOptionsGUI:Move
        ,SortOptionsGUI_OrderGB
        ,h%l_GroupBoxH%

    ;-- Identify the YPos of the Miscellaneous group box
    l_YPos:=l_Group1PosY+l_GroupBoxH

    Static SortOptionsGUI_MiscellaneousGB
    gui SortOptionsGUI:Add
       ,GroupBox
       ,% ""
            . "xm "
            . "y" . l_YPos . A_Space
            . "w" . l_GroupBoxW . A_Space
            . "vSortOptionsGUI_MiscellaneousGB "
       ,Miscellaneous

    l_PromptW:=Fnt_GetStringWidth(hFont,"Delimiter:x")
    l_EditW  :=Fnt_GetFontAvgCharWidth(hFont)*7
    if Fnt_IsFixedPitchFont(hFont)
        l_EditW-=Fnt_GetFontAvgCharWidth(hFont)

    gui SortOptionsGUI:Add
       ,Text
       ,% ""
            . "xp+" . l_MarginX . A_Space
            . "yp+" . Round(l_FontH*1.2) . A_Space
            . "w" . l_PromptW . A_Space
            . "h" . l_RadioH . A_Space
            . "Section "
       ,Delimiter:

    Static SortOptionsGUI_SortDelimiter
    gui SortOptionsGUI:Add
       ,Edit
       ,% ""
            . "x+0 "
            . "w" . l_EditW . A_Space
            . "hWndhSortDelimiter "
            . "vSortOptionsGUI_SortDelimiter "

    gui SortOptionsGUI:Add
       ,Text
       ,% ""
            . "xs "
            . "w" . l_PromptW . A_Space
       ,Sort pos:

    Static SortOptionsGUI_SortPos
    gui SortOptionsGUI:Add
       ,Edit
       ,% ""
            . "x+0 "
            . "w" . l_EditW . A_Space
            . "Number "
            . "hWndhSortPos "
            . "vSortOptionsGUI_SortPos "
       ,1

    Static SortOptionsGUI_RemoveDuplicates
    gui SortOptionsGUI:Add
       ,CheckBox
       ,% ""
            . "xs "
            . "h" . l_CheckboxH . A_Space
            . "hWndhRemoveDuplicates "
            . "vSortOptionsGUI_RemoveDuplicates "
       ,Remove duplicates

    ;-- Resize the Miscellaneous group box
    GUIControlGet l_Group1Pos,SortOptionsGUI:Pos,SortOptionsGUI_MiscellaneousGB
    GUIControlGet l_Group2Pos,SortOptionsGUI:Pos,SortOptionsGUI_RemoveDuplicates
    l_GroupBoxH:=(l_Group2PosY-l_Group1PosY)+l_Group2PosH+l_MarginY
    GUIControl
        ,SortOptionsGUI:Move
        ,SortOptionsGUI_MiscellaneousGB
        ,h%l_GroupBoxH%

    ;-- Identify the YPos of the buttons
    l_YPos:=l_Group1PosY+l_GroupBoxH+l_MarginY

    ;-- Buttons
    Static SortOptionsGUI_OK
    gui SortOptionsGUI:Add
       ,Button
       ,% ""
            . "xm "
            . "y" . l_YPos . A_Space
            . "w" . l_ButtonW . A_Space
            . "Default "
            . "vSortOptionsGUI_OK "
            . "gSortOptionsGUI_OK "
       ,&OK

    gui SortOptionsGUI:Add
       ,Button
       ,% ""
            . "x+" . l_MarginX . A_Space
            . "wp "
            . "gSortOptionsGUI_Reset "
       ,&Reset

    gui SortOptionsGUI:Add
       ,Button
       ,% ""
            . "x+" . l_MarginX . A_Space
            . "wp "
            . "gSortOptionsGUI_Close "
       ,Cancel

    ;-- Set focus
    GUIControl SortOptionsGUI:Focus,SortOptionsGUI_OK

    ;-- Delete logical font (if any)
    Fnt_DeleteFont(hFont)

    ;[=====================]
    ;[  Set user defaults  ]
    ;[=====================]
    ;-- Initialize
    l_SortOptions  :=p_SortOptions
    l_SortPos      :=""
    l_SortPosFlag  :=False
    l_SortDelimFlag:=False

    ;-- Random?
    if InStr(A_Space . l_SortOptions," Random")
        {
        StringReplace l_SortOptions,l_SortOptions,Random,,All
            ;-- Remove option from the list of options so that it cannot be
            ;   mininterpreted for the "R" (sort in reverse order) option.
        GUIControl SortOptionsGUI:,SortOptionsGUI_SortRandom,1
        }

    ;-- Identify sort options, one character at a time
    Loop Parse,l_SortOptions
        {
        if l_SortDelimFlag
            {
            ;-- Convert selected delimiter characters into escape characters
            l_LoopField:=A_LoopField
            StringReplace l_LoopField,l_LoopField,`a,``a,All
            StringReplace l_LoopField,l_LoopField,`b,``b,All
            StringReplace l_LoopField,l_LoopField,`f,``f,All
            StringReplace l_LoopField,l_LoopField,`n,``n,All
            StringReplace l_LoopField,l_LoopField,`r,``r,All
            StringReplace l_LoopField,l_LoopField,`t,``t,All
            StringReplace l_LoopField,l_LoopField,`v,``v,All
            StringReplace l_LoopField,l_LoopField,`%,% "``%",,All
            GUIControl SortOptionsGUI:,SortOptionsGUI_SortDelimiter,%l_LoopField%
            l_SortDelimFlag:=False
            Continue
            }

        if l_SortPosFlag
            {
            if A_LoopField is Integer
                {
                l_SortPos.=A_LoopField
                Continue
                }

            if l_SortPos is Integer
                if (l_SortPos>0)
                    GUIControl SortOptionsGUI:,SortOptionsGUI_SortPos,%l_SortPos%

            l_SortPosFlag:=False
            ;-- Keep going.  No break or continue here
            }

        if A_LoopField is Space
            Continue

        if (A_LoopField="C")
            {
            GUIControl SortOptionsGUI:,SortOptionsGUI_CaseSensitive,1
            Continue
            }

        if (A_LoopField="D")
            {
            l_SortDelimFlag:=True
            Continue
            }

        if (A_LoopField="N")
            {
            GUIControl SortOptionsGUI:,SortOptionsGUI_NumericalSort,1
            gosub SortOptionsGUI_NumericalSort
            Continue
            }

        if (A_LoopField="P")
            {
            l_SortPosFlag:=True
            Continue
            }

        if (A_LoopField="R")
            {
            GUIControl SortOptionsGUI:,SortOptionsGUI_SortDescending,1
            Continue
            }

        if (A_LoopField="U")
            {
            GUIControl SortOptionsGUI:,SortOptionsGUI_RemoveDuplicates,1
            Continue
            }
        }

    if l_SortPosFlag
        if l_SortPos is Integer
            if (l_SortPos>0)
                GUIControl SortOptionsGUI:,SortOptionsGUI_SortPos,%l_SortPos%

    ;[===============]
    ;[  Show window  ]
    ;[===============]
    if hOwner
        {
        gui SortOptionsGUI:Show,Hide,%p_Title%
            ;-- Render but don't show

        MoveChildWindow(hOwner,hSortOptionsGUI,"Show")
            ;-- Move (center) and show window
        }
     else
        gui SortOptionsGUI:Show,,%p_Title%

    ;[=====================]
    ;[  Wait until window  ]
    ;[      is closed      ]
    ;[=====================]
    WinWaitClose ahk_id %hSortOptionsGUI%

    ;-- Return to sender
    ErrorLevel:=l_ErrorLevel
    Return l_SortOptions  ;-- End of function


    ;**************************
    ;*                        *
    ;*       Subroutines      *
    ;*    (SortOptionsGUI)    *
    ;*                        *
    ;**************************
    ;[================]
    ;[  Sort options  ]
    ;[================]
    SortOptionsGUI_AlphabeticalSort:
    GUIControl SortOptionsGUI:,%hNumericalSort%,0
    GUIControl SortOptionsGUI:Enable,%hCaseSensitive%
    return


    SortOptionsGUI_NumericalSort:
    GUIControl SortOptionsGUI:,%hAlphabeticalSort%,0
    GUIControl SortOptionsGUI:,%hCaseSensitive%,0
    GUIControl SortOptionsGUI:Disable,%hCaseSensitive%
    return


    ;[=============]
    ;[  OK button  ]
    ;[=============]
    SortOptionsGUI_OK:
    gui SortOptionsGUI:Submit,NoHide

    ;-- Convert escape character into actual character
    Transform SortOptionsGUI_SortDelimiter,Deref,%SortOptionsGUI_SortDelimiter%

    ;-- Sort options
    l_SortOptions:=""
    if StrLen(SortOptionsGUI_SortDelimiter)
        l_SortOptions.="D" . SubStr(SortOptionsGUI_SortDelimiter,1,1) . A_Space

    if SortOptionsGUI_CaseSensitive
        l_SortOptions.="C "

    if SortOptionsGUI_NumericalSort
        l_SortOptions.="N "

    if SortOptionsGUI_SortPos is Integer
        if (SortOptionsGUI_SortPos<>1)
            l_SortOptions.="P" . SortOptionsGUI_SortPos . A_Space

    if SortOptionsGUI_RemoveDuplicates
        l_SortOptions.="U "

    if SortOptionsGUI_SortDescending
        l_SortOptions.="R "

    if SortOptionsGUI_SortRandom
        l_SortOptions.="Random "

    ;-- Ok, We're done.  Shut it down.
    gosub SortOptionsGUI_Exit
    Return


    ;[================]
    ;[  Reset button  ]
    ;[================]
    SortOptionsGUI_Reset:
    GUIControl SortOptionsGUI:,%hAlphabeticalSort%,1
    GUIControl SortOptionsGUI:Enable,%hCaseSensitive%
    GUIControl SortOptionsGUI:,%hCaseSensitive%,0
    GUIControl SortOptionsGUI:,%hNumericalSort%,0
    GUIControl SortOptionsGUI:,%hSortAscending%,1
    GUIControl SortOptionsGUI:,%hSortDelimiter%
    GUIControl SortOptionsGUI:,%hSortPos%,1
    GUIControl SortOptionsGUI:,%hRemoveDuplicates%,0
    return


    ;[==========]
    ;[  Cancel  ]
    ;[==========]
    SortOptionsGUI_Escape:
    SortOptionsGUI_Close:
    l_SortOptions:=p_SortOptions
    l_ErrorLevel:=1

    ;[=================]
    ;[  Close up shop  ]
    ;[=================]
    SortOptionsGUI_Exit:

    ;-- Enable Owner window
    if p_Owner
        gui %p_Owner%:-Disabled

    ;-- Destroy the SortOptionsGUI window so that it can be reused
    gui SortOptionsGUI:Destroy
    return  ;-- End of subroutines
    }
