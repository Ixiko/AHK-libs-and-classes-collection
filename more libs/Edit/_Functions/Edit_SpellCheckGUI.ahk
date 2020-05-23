;-----------------------------
; 
; Function: Edit_SpellCheckGUI v0.2.5 (Preview)
;
; Description:
;
;   A specialty function that performs a spell check on the designated edit
;   control using the dictionary as defined by the hSpell variable.  A dialog is
;   displayed to prompt the user when a misspelled word is found.
;
; Type:
;
;   Add-on function.
;
; Parameters:
;
;   p_Owner - Owner GUI.  Set to 0 for no owner.  See the *Owner* section for
;       more information.
;
;   hEdit - Handle to the edit control that will be checked for spelling errors.
;
;   hSpell - Variable that contains Spell handle and function addresses.  See
;       the *Setup and Shutdown* section for more information.
;
;   p_CustomDic - Path to the custom dictionary file. [Optional] See the *Custom
;       Dictionary* section for more information.
;
;   p_Title - Window title. [Optional] The default is "Spell Check".
;
;   p_Font - Typeface name and/or font options. [Optional] See the *Font*
;       section for more information.
;
; Calls To Other Functions:
;
;   * Edit [Library]
;   * Fnt [Library]
;   * MoveChildWindow
;   * Spell v2.0+ [Library]
;   * WinGetPosEx (used by MoveChildWindow)
;
; Returns:
;
;   TRUE if the Spell Check window was created normally and the spell check
;   ended normally or was canceled by the user, otherwise FALSE if there was
;   error.  Use a debugger or debug viewer to see the details if an error
;   occurs.
;
; Custom Dictionary:
;
;   The p_CustomDic parameter contains the path to a custom dictionary file.  If
;   blank/null or not specified, the "Add Word" button on the Edit_SpellCheckGUI
;   dialog is not enabled.
;
;   Important 1: This function will only add words _to_ the custom dictionary
;   file specified in the p_CustomDic parameter.  Words that are already in the
;   custom dictionary should be pre-loaded by the parent script by using the
;   *Spell_InitCustom* function.
;
;   Important 2:  Some of the errors that occur with/because of the path/file
;   specified in the p_CustomDic parameter are handled internally by the
;   function and are treated as non-critical errors.  The function will continue
;   to operate in these cases.  Be sure to test thoroughly and use a debugger or
;   debug viewer to see any errors that may occur.
;
; Font:
;
;   p_Font is an optional parameter that allows the developer to set a specific
;   font for the Edit_SpellCheckGUI window.  The syntax is:
;   {FontName}:{FontOptions}.  Ex: "Arial:s10 bold".  All components of this
;   parameter are optional.  If a typeface name is not specified (Ex: ":s12
;   bold"), the default system GUI font is used.  If no font options are
;   specified (Ex: "Arial" or "Arial:"), the default font options are used.  See
;   the AutoHotkey documentation for a list of (and syntax of) font options.
;
;   Exception/Feature: If the p_Font parameter is set to "Message", the system
;   font used for Message Box dialog is used.  In general, this font is a bit
;   larger and easier to read than the default GUI font.
;
; Owner:
;
;   The p_Owner parameter is used to specify the owner of the Edit_SpellCheckGUI
;   window. Set to 0 for no owner.
;
;   For an AutoHotkey owner window, specify a valid GUI number (1-99), GUI name,
;   or handle to the window.  When the Edit_SpellCheckGUI window is created, the
;   owner window is disabled and ownership of the Edit_SpellCheckGUI window is
;   assigned to the owner window.  This makes makes the Edit_SpellCheckGUI
;   window modal which prevents the user from interacting with the owner window
;   until the Edit_SpellCheckGUI window is closed.
;
;   For a non-AutoHotkey owner window, specify the handle to the window.
;   Ownership is not assigned but the window's position and size is use to
;   position the Edit_SpellCheckGUI window.
;
;   If p_Owner is not specified or is set to the handle of a non-AutoHotkey
;   window, the AlwaysOnTop attribute is added to the Edit_SpellCheckGUI window
;   to ensure that the dialog is not lost.
;
;   For all owner windows, the Edit_SpellCheckGUI window is positioned in the
;   center of the owner window by default.
;
;   If p_Owner is zero (0), null, or contains a non-AutoHotkey GUI window
;   handle, the function will still work but the user will have the ability to
;   update the edit control while the spell check is running.  The function has
;   been designed to deal will most idiosyncrasies but there is still a chance
;   that changes to the edit control will interfere with the spell check
;   operation.  Since the function does not return until the spell check is
;   finished or is canceled, consider setting the edit control to read-only
;   while the spell check is operating if p_Owner is undefined.  Changes to the
;   document, if any, will still occur but the user will be blocked from making
;   manual changes.  For example:
;
;       (start code)
;       Edit_SetReadOnly(hEdit,True)
;       Edit_SpellCheckGUI(0,...)
;       Edit_SetReadOnly(hEdit,False)
;       (end)
;
; Setup and Shutdown:
;
;   This function uses v2.0+ of the Spell library to check the spelling of the
;   words in an Edit control.  This function only uses an existing spell object.
;   The parent script (i.e. your script) is responsible for creating, populating
;   (initially), and destroying the spell object.
;
;   To initialize the spell object, call the *Spell_Init* function.  This
;   command will create the spell object and will populate it with words and
;   rules from the specified Hunspell dictionary.  To load one or more custom
;   dictionaries to the spell object, call the *Spell_InitCustom* function.
;
;   The *Spell_Uninit* function is used to destroy the spell object and free up
;   all the memory used by the Hunspell API.  It can be called at any time after
;   this function ends but it should, at the least, be called before the script
;   ends.
;
;   See the example script for this function for an example of how to add the
;   necessary commands to initialize and destroy the spell object.
;
; Remarks:
;
; * The function does not return until the Spell Check is finished or is
;   cancelled.
;
; * Although not a requirement, adding the ES_NOHIDESEL style to the Edit
;   control when it is created improves usability by continuing to show the
;   selected text on the Edit control even when the Edit_SpellCheckGUI dialog is
;   active.  Note that the ES_NOHIDESEL style cannot be added after the Edit
;   control has been created.
;
; * Checking the spelling of a document is a resource intensive process.  If the
;   document is relatively small (<15K, ~2,500 words or less), response from
;   this module is nearly instananeous -- much less that 1 second on the high
;   end.  However, the response will start to degrade more and more as the
;   document size increases past this threshhold.  To improve performance, set
;   *<SetBatchLines at https://autohotkey.com/docs/commands/SetBatchLines.htm>*
;    to a high value before calling this function.  For example:
;
;       (start code)
;       SetBatchLines 200ms  ;-- Significant bump in priority
;       Edit_SpellCheckGUI(...)
;       SetBatchLines 10ms   ;-- This is the system default
;       (end)
;
;-------------------------------------------------------------------------------
Edit_SpellCheckGUI(p_Owner,hEdit,byRef hSpell,p_CustomDic="",p_Title="",p_Font="")
    {
    ;[===================]
    ;[  Already exists?  ]
    ;[===================]
    ;-- Bounce (with prejudice) if a Edit_SpellCheckGUI window already showing
    gui Edit_SpellCheckGUI:+LastFoundExist
    IfWinExist
        {
        outputdebug,
           (ltrim join`s
            End Func: %A_ThisFunc% -
            A %A_ThisFunc% window already exists.
           )

        SoundPlay *-1  ;-- System default beep
        Return False
        }

    ;[==============]
    ;[  Initialize  ]
    ;[==============]
    ;-- Flags
    l_GetText:=True

    ;-- Identify RegEx pattern codes
    PatternCodes=
       (ltrim join,
        39,138,142,146,154,158
        192-200
        201-214,216-246,248-255
        339
       )

    ;-- Build RegEx pattern
    l_RegExPattern:="["
    Loop Parse,PatternCodes,`,
        {
        l_StartCode:=l_EndCode:=A_LoopField
        if A_LoopField Contains -
            Loop Parse,A_LoopField,-
                if (A_Index=1)
                    l_StartCode:=A_LoopField
                  else
                    {
                    l_EndCode:=A_LoopField
                    Break
                    }

        l_Code:=l_StartCode+0  ;-- Assign and convert to decimal if needed
        Loop
            {
            if A_IsUnicode or (l_Code<=255)
                l_RegExPattern.=Chr(l_Code)
             else
                {
                VarSetCapacity(wChar,4,0)
                NumPut(l_Code,wChar,0,"UInt")
                Spell_Unicode2ANSI(&wChar,aChar)
                l_RegExPattern.=aChar
                }

            l_Code++
            if (l_Code>l_EndCode)
                Break
            }
        }

    l_RegExPattern.="\w]+"

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

    ;-- Custom dictionary
    ;   Note: The Spell library is already able to handle an invalid custom
    ;   dictionary path.  However, additional tests are performed here so that
    ;   the "Add Word" button is enabled/disabled appropriately.
    if StrLen(p_CustomDic)
        {
        IfNotExist %p_CustomDic%
            {
            outputdebug,
               (ltrim join`s
                Function: %A_ThisFunc% -
                Custom dictionary not found: %p_CustomDic%. "Add Word" button
                disabled.
               )

            p_CustomDic:=""
            }
        else
            ;-- Read only?
            if InStr(FileExist(p_CustomDic),"R")
                {
                outputdebug,
                   (ltrim join`s
                    Function: %A_ThisFunc% -
                    Read-only attribute set on the custom dictionary file. "Add
                    Word" button disabled.
                   )

                p_CustomDic:=""
                }
        }

    ;-- Title
    p_Title:=Trim(p_Title," `f`n`r`t`v")
        ;-- Remove all leading/trailing white space

    if not StrLen(p_Title)
        p_Title:="Spell Check"
     else
        {
        ;-- Append to script name if p_title begins with "++"?
        if (SubStr(p_Title,1,2)="++")
            {
            SplitPath A_ScriptName,,,,l_ScriptName
            StringTrimLeft p_Title,p_Title,2
            p_Title:=l_ScriptName . A_Space . p_Title
            }
        }

    ;-- Font
    p_Font:=Trim(p_Font," `f`n`r`t`v")
        ;-- Remove all leading/trailing white space

    if p_Font
        Loop Parse,p_Font,:
            if (A_Index=1)
                l_FontName:=A_LoopField
             else
                {
                l_FontOptions:=A_LoopField
                Break
                }

    ;[========]
    ;[  Font  ]
    ;[========]
    ;-- Create logical font to calculate the width/height of GUI objects
    ;   If needed, set/update the l_FontName and l_FontOptions variables
    h_Font:=0
    if l_FontName or l_FontOptions
        {
        if (l_FontName="Message")
            {
            l_FontName:=Fnt_GetMessageFontName()
            if not Fnt_FOGetSize(l_FontOptions)
                Fnt_FOSetSize(l_FontOptions,Fnt_GetMessageFontSize())
            }

        hFont:=Fnt_CreateFont(l_FontName,l_FontOptions)
        }

    ;-- Margins
    l_MarginX:=l_MarginY:=Round(Fnt_GetFontSize(hFont)*0.75)

    ;-- Object width
    Fnt_DialogTemplateUnits2Pixels(hFont,132,0,l_ObjectW)
        ;-- Enough space for ~32 average characters of the font

    ;-- Button width
    Fnt_GetStringSize(hFont,"Replace Allxxi",l_ButtonW)
    if Fnt_IsFixedPitchFont(hFont)
        l_ButtonW-=Fnt_GetFontAvgCharWidth(hFont)

    ;-- Delete logical font
    Fnt_DeleteFont(hFont)

    ;[=============]
    ;[  Build GUI  ]
    ;[=============]
    ;-- Set ownership
    ;   Note: Ownership commands must be performed before any other GUI commands
    if p_Owner
        {
        gui %p_Owner%:+Disabled      ;-- Disable Owner window
        gui Edit_SpellCheckGUI:+Owner%p_Owner%  ;-- Set ownership
        }
     else
        gui Edit_SpellCheckGUI:+Owner           ;-- Give ownership to the script window

    ;---------------
    ;-- GUI options
    ;---------------
    gui Edit_SpellCheckGUI:-DPIScale +Delimiter`n +hWndhEdit_SpellCheckGUI +LabelEdit_SpellCheckGUI_ -MinimizeBox
    gui Edit_SpellCheckGUI:Margin,%l_MarginX%,%l_MarginY%
    if not p_Owner
        gui Edit_SpellCheckGUI:+AlwaysOnTop

    ;-- GUI font
    if l_FontName or l_FontOptions
        gui Edit_SpellCheckGUI:Font,%l_FontOptions%,%l_FontName%

    ;---------------
    ;-- GUI objects
    ;---------------
    gui Edit_SpellCheckGUI:Font,cNavy
    gui Edit_SpellCheckGUI:Add
       ,Text
       ,% ""
            . "xm "
            . "w" . l_ObjectW . A_Space
            . "r2 "
            . "hWndhStatusText "
       ,Checking...  ;-- Initial value

    ;-- Reset font
    gui Edit_SpellCheckGUI:Font
    if l_FontName or l_FontOptions
        gui Edit_SpellCheckGUI:Font,%l_FontOptions%,%l_FontName%

    gui Edit_SpellCheckGUI:Add
       ,Text
       ,xm
       ,Replace with:

    Static Edit_SpellCheckGUI_ReplaceWith
    gui Edit_SpellCheckGUI:Add
       ,Edit
       ,% ""
            . "xm y+1 "
            . "w" . l_ObjectW . A_Space
            . "hWndhReplaceWith "
            . "vEdit_SpellCheckGUI_ReplaceWith "
            . "gEdit_SpellCheckGUI_ReplaceWithAction "

    gui Edit_SpellCheckGUI:Add
       ,Text
       ,% ""
            . "xm "
            . "w" . l_ObjectW . A_Space
            . "r1 "
            . "hWndhSuggestionsTitle "

    Static Edit_SpellCheckGUI_Suggestions
    gui Edit_SpellCheckGUI:Add
       ,ListBox
       ,% ""
            . "xm y+1 "
            . "w" . l_ObjectW . A_Space
            . "r6 "
            . "hWndhSuggestions "
            . "vEdit_SpellCheckGUI_Suggestions "
            . "gEdit_SpellCheckGUI_SuggestionsAction "

    gui Edit_SpellCheckGUI:Add
       ,Button
       ,% ""
            . "ym "
            . "w" . l_ButtonW . A_Space
            . "gEdit_SpellCheckGUI_Ignore"
       ,&Ignore

    gui Edit_SpellCheckGUI:Add
       ,Button
       ,% ""
            . "y+0 wp hp "
            . "gEdit_SpellCheckGUI_IgnoreAll "
       ,I&gnore All

    gui Edit_SpellCheckGUI:Add
       ,Button
       ,% ""
            . "y+" . l_MarginY*2 . A_Space
            . "wp hp "
            . "Default "
            . "Disabled "
            . "hWndhReplaceButton "
            . "gEdit_SpellCheckGUI_Replace "
       ,&Replace

    gui Edit_SpellCheckGUI:Add
       ,Button
       ,% ""
            . "y+0 wp hp "
            . "Disabled "
            . "hWndhReplaceAllButton "
            . "gEdit_SpellCheckGUI_ReplaceAll "
       ,Replace &All

    gui Edit_SpellCheckGUI:Add
       ,Button
       ,% ""
            . "y+" . l_MarginY*2 . A_Space
            . "wp hp "
            . (StrLen(p_CustomDic)=0 ? "Disabled ":"")
            . "hWndhAddWordButton "
            . "gEdit_SpellCheckGUI_Add "
       ,A&dd Word

    Static Edit_SpellCheckGUI_Close
    gui Edit_SpellCheckGUI:Add
       ,Button
       ,% ""
            . "y+" . l_MarginY*2 . A_Space
            . "wp hp "
            . "vEdit_SpellCheckGUI_Close "
            . "gEdit_SpellCheckGUI_Close "
       ,Cancel

    ;-- Reposition the Close button
    GUIControlGet $Group1Pos,Edit_SpellCheckGUI:Pos,Edit_SpellCheckGUI_Suggestions
    GUIControlGet $Group2Pos,Edit_SpellCheckGUI:Pos,Edit_SpellCheckGUI_Close
    GUIControl
        ,Edit_SpellCheckGUI:Move
        ,Edit_SpellCheckGUI_Close
        ,% "y" . $Group1PosY+$Group1PosH-$Group2PosH

    ;[=====================]
    ;[  Render & Position  ]
    ;[=====================]
    if hOwner
        {
        ;-- Render but don't show
        gui Edit_SpellCheckGUI:Show,Hide,%p_Title%

        ;-- Move (center) and show window
        MoveChildWindow(hOwner,hEdit_SpellCheckGUI,"Show")
        }
     else
        gui Edit_SpellCheckGUI:Show,,%p_Title%

    ;-- Give the window a chance to show
    Sleep 1

    ;[=========]
    ;[  Start  ]
    ;[=========]
    Edit_GetSel(hEdit,l_OriginalStartSelPos,l_OriginalEndSelPos)
    l_StartSpellCheckRange:=l_OriginalStartSelPos
    if (l_OriginalStartSelPos=l_OriginalEndSelPos)
        {
        l_EndSpellCheckRange:=Edit_GetTextLength(hEdit)
        Edit_SetSel(hEdit,0,0)
        }
     else
        {
        l_EndSpellCheckRange:=l_OriginalEndSelPos
        Edit_SetSel(hEdit,l_OriginalStartSelPos,l_OriginalStartSelPos)
        }

    gosub Edit_SpellCheckGUI_ContinueSpellCheck

    ;[=====================]
    ;[  Wait until window  ]
    ;[      is closed      ]
    ;[=====================]
    WinWaitClose ahk_id %hEdit_SpellCheckGUI%

    ;[===================]
    ;[  Post processing  ]
    ;[===================]
    ;-- Reselect or position caret
    if (l_OriginalStartSelPos<>l_OriginalEndSelPos)
        Edit_SetSel(hEdit,l_OriginalStartSelPos,l_OriginalEndSelPos)
     else
        {
        ;-- Anything selected?
        Edit_GetSel(hEdit,l_StartSelPos,l_EndSelPos)
        if (l_StartSelPos<>l_EndSelPos)
            Edit_SetSel(hEdit,l_EndSelPos,l_EndSelPos)
        }

    Return True  ;-- End of function


    ;******************************
    ;*                            *
    ;*         Subroutines        *
    ;*    (Edit_SpellCheckGUI)    *
    ;*                            *
    ;******************************
    Edit_SpellCheckGUI_Checking:
    SetTimer %A_ThisLabel%,Off
    GUIControl Edit_SpellCheckGUI:,%hStatusText%,Checking...
    return


    Edit_SpellCheckGUI_ContinueSpellCheck:

    ;-- Disable while checking
    ;   Note: This keeps the user from doing anything with the dialog (Ex:
    ;   pressing buttons) while the spell check is going on.
    gui Edit_SpellCheckGUI:+Disabled

    ;-- Update the text control if needed
    SetTimer Edit_SpellCheckGUI_Checking,150

    ;-- Start from the current position
    Edit_GetSel(hEdit,l_StartSelPos,l_EndSelPos)
    l_StartPos:=l_EndSelPos
    Loop
        {
        ;-- If needed, collect the text from the edit control
        if l_GetText
            {
            l_Text:=Edit_GetText(hEdit)
            l_GetText:=False
            }

        ;-- Find the next word
        l_FoundPos:=RegExMatch(l_Text,l_RegExPattern,l_RegExOut,l_StartPos+1)-1

        ;-- No more words or out of range?
        if (l_FoundPos=-1 or l_FoundPos>l_EndSpellCheckRange)
            {
            SetTimer Edit_SpellCheckGUI_Checking,Off
            l_GetText:=True

            ;-- Inform/Prompt user
            gui Edit_SpellCheckGUI:+OwnDialogs
            if (l_OriginalStartSelPos=l_OriginalEndSelPos)
                MsgBox
                    ,0x40   ;-- 0x40 (Info icon) + 0x0 (OK button)
                    ,Spell Check
                    ,Spell Check complete.  %A_Space%
             else
                {
                MsgBox
                    ,0x24     ;-- 0x20 (Question icon) + 0x4 (Yes/No Buttons)
                    ,Spell Check,
                       (ltrim join`s
                        Finished Spell Check for selection.  Continue checking
                        the remainder of the document?  %A_Space%
                       )

                IfMsgBox Yes
                    {
                    l_OriginalStartSelPos:=l_OriginalEndSelPos
                    l_EndSpellCheckRange:=Edit_GetTextLength(hEdit)
                    l_StartPos:=0
                    Continue
                    }
                }

            gosub Edit_SpellCheckGUI_Close
            Break
            }

        ;-- Check spelling
        if Spell_Spell(hSpell,l_RegExOut)
            {
            l_StartPos:=l_FoundPos+StrLen(l_RegExOut)
            Continue
            }
         else
            {
            ;-- Select it
            l_SelectedText:=l_RegExOut
            Edit_SetSel(hEdit,l_FoundPos,l_FoundPos+StrLen(l_SelectedText))

            ;-- Is the misspelled word on the l_ReplaceAllList?
            if StrLen(l_ReplaceAllList)
                {
                l_ReplaceAllReplace:=False
                Loop Parse,l_ReplaceAllList,`n
                    {
                    l_ReplaceWhat:=""
                    l_ReplaceWith:=""
                    Loop Parse,A_LoopField,|
                        if (A_Index=1)
                            l_ReplaceWhat:=A_LoopField
                         else
                            l_ReplaceWith:=A_LoopField

                    if (l_SelectedText==l_ReplaceWhat)
                        {
                        Edit_ReplaceSel(hEdit,l_ReplaceWith)
                        l_ReplaceAllReplace:=True
                        Break
                        }
                    }

                if l_ReplaceAllReplace
                    {
                    l_GetText:=True
                    l_StartPos:=l_FoundPos+StrLen(l_ReplaceWith)
                    Continue ;-- Go on to the next
                    }
                }

            ;-- If the function doesn't have any control over the edit control
            ;   or the window that contains the edit control, then reset the
            ;   search on the next iteration.  This is done just in case the
            ;   user makes changes to the edit control while the dialog is
            ;   waiting for a response.
            if !p_Owner and !Edit_IsReadOnly(hEdit)
                l_GetText:=True

            ;-- Turn off the "Checking..." timer
            SetTimer Edit_SpellCheckGUI_Checking,Off

            ;-- Scroll to the top
            Edit_GetSel(hEdit,l_StartSelPos,l_EndSelPos)
            l_CurrentLine     :=Edit_LineFromChar(hEdit,l_StartSelPos)
            l_FirstVisibleLine:=Edit_GetFirstVisibleLine(hEdit)
            Edit_LineScroll(hEdit,0,l_CurrentLine-l_FirstVisibleLine)
            Edit_ScrollCaret(hEdit)  ;-- Just in case the caret is not showing

            ;-- Get list of suggestions and populate
            ;   Note: This step is performed first because the Spell_Suggest
            ;   function can take a while for some dictionaries.  Ex: French.
            ;   Waiting until the suggest list is updated gives the dialog the
            ;   illusion that all the information is updated at the same time.
            if Spell_Suggest(hSPell,l_SelectedText,l_Suggestions)
                {
                GUIControl Edit_SpellCheckGUI:,%hSuggestionsTitle%,Suggestions:
                GUIControl Edit_SpellCheckGUI:,%hSuggestions%,`n%l_Suggestions%
                GUIControl Edit_SpellCheckGUI:Choose,%hSuggestions%,1
                }
             else
                {
                GUIControl Edit_SpellCheckGUI:,%hSuggestionsTitle%,There are no suggestions for this word.
                GUIControl Edit_SpellCheckGUI:,%hSuggestions%,`n
                }

            ;-- Set "word is not in the dictionary" message.
            GUIControl Edit_SpellCheckGUI:,%hStatusText%,"%l_SelectedText%" not in the dictionary.

            ;-- Set ReplaceWith
            gui Edit_SpellCheckGUI:Submit,NoHide  ;-- Recollect form values
            GUIControl Edit_SpellCheckGUI:,%hReplaceWith%,%Edit_SpellCheckGUI_Suggestions%

            ;-- Set focus
            GUIControl Edit_SpellCheckGUI:Focus,%hSuggestions%

            ;-- Enable window
            gui Edit_SpellCheckGUI:-Disabled

            ;-- We're done here
            Break
            }
        }

    return


    Edit_SpellCheckGUI_ReplaceWithAction:
    gui Edit_SpellCheckGUI:Submit,NoHide

    if Edit_SpellCheckGUI_ReplaceWith is not Space
        {
        GUIControl Edit_SpellCheckGUI:Enable,%hReplaceButton%
        GUIControl Edit_SpellCheckGUI:Enable,%hReplaceAllButton%
        }
     else
        {
        GUIControl Edit_SpellCheckGUI:Disable,%hReplaceButton%
        GUIControl Edit_SpellCheckGUI:Disable,%hReplaceAllButton%
        }

    return


    Edit_SpellCheckGUI_SuggestionsAction:
    gui Edit_SpellCheckGUI:Submit,NoHide
    if (A_GUIEvent="DoubleClick")
        {
        gosub Edit_SpellCheckGUI_Replace
        return
        }

    ;-- Update ReplaceWith
    GUIControl Edit_SpellCheckGUI:,%hReplaceWith%,%Edit_SpellCheckGUI_Suggestions%
    return


    Edit_SpellCheckGUI_Ignore:
    gosub Edit_SpellCheckGUI_ContinueSpellCheck
    return


    Edit_SpellCheckGUI_IgnoreAll:
    Spell_Add(hSpell,l_SelectedText,"L")
    gosub Edit_SpellCheckGUI_ContinueSpellCheck
    return


    Edit_SpellCheckGUI_Replace:
    gui Edit_SpellCheckGUI:Submit,NoHide
    Edit_SpellCheckGUI_ReplaceWith:=Trim(Edit_SpellCheckGUI_ReplaceWith," `f`n`r`t`v")
        ;-- Remove all leading/trailing white space
    Edit_ReplaceSel(hEdit,Edit_SpellCheckGUI_ReplaceWith)
    l_GetText:=True
    gosub Edit_SpellCheckGUI_ContinueSpellCheck
    return


    Edit_SpellCheckGUI_ReplaceAll:
    gui Edit_SpellCheckGUI:Submit,NoHide
    Edit_SpellCheckGUI_ReplaceWith:=Trim(Edit_SpellCheckGUI_ReplaceWith," `f`n`r`t`v")
        ;-- Remove all leading/trailing white space
    Edit_ReplaceSel(hEdit,Edit_SpellCheckGUI_ReplaceWith)

    ;-- Add to l_ReplaceAllList
    l_ReplaceAllList.=(StrLen(l_ReplaceAllList) ? "`n":"")
        . l_SelectedText
        . "|"
        . Edit_SpellCheckGUI_ReplaceWith

    l_GetText:=True
    gosub Edit_SpellCheckGUI_ContinueSpellCheck
    return


    Edit_SpellCheckGUI_Add:

    ;-- Add the word to the custom dictionary file
    if (Spell_AddCustom(p_CustomDic,l_SelectedText)=-1)
        {
        gui Edit_SpellCheckGUI:+OwnDialogs
        MsgBox
            ,0x10   ;-- 0x0 (OK button) + 0x10 (Error icon)
            ,Spell Check,
               (ltrim join`s
                Unable to add the word "%l_SelectedText%" to the custom
                dictionary file.  The file may be protected or is stored in a
                protected location.
               )

        GUIControl Edit_SpellCheckGUI:Disable,%hAddWordButton%
        return
        }

    ;-- Add the word to the active dictionary
    Spell_Add(hSpell,l_SelectedText)

    ;-- Continue checking
    gosub Edit_SpellCheckGUI_ContinueSpellCheck
    return


    Edit_SpellCheckGUI_Escape:
    Edit_SpellCheckGUI_Close:

    ;-- Enable Owner window
    if p_Owner
        gui %p_Owner%:-Disabled

    ;-- Destroy the Edit_SpellCheckGUI window so that it can be reused
    gui Edit_SpellCheckGUI:Destroy
    return  ;-- End of subroutines
    }
