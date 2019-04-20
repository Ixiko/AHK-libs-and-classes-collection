/*
Title: Edit Library v2.0

Group: Introduction

    This library is designed for use on the standard Edit control.

Group: Issues/Consideration

    A few considerations...

 *  Some of functions are only for use on single-line Edit controls and some
    are only for use on multiline Edit controls.  See the documentation for each
    function for any restrictions.

 *  AutoHotkey supports the creation and manipulation of the standard edit
    control.  For this reason, there are a small number functions that were
    intentionally left out of this library because they provide no additional
    value to what the standard AutoHotkey commands provide.

 *  The Edit control does not support several key messages that are needed by
    this library.  Absent messages include EM_GETSELTEXT, EM_GETTEXTRANGE, and
    EM_FINDTEXT.  These messages have been replaced with AutoHotkey commands or
    with other messages.  Although the substitute code/messages are very
    capable, they are not quite as efficient (memory and/or speed) as the
    messages they replace (if they existed).  These inefficiencies are not
    really noticable if the control only contains a limited amount of text
    (~512K or less), but they become more pronounced with increasing text sizes.
    Efficiency also depends on the where work in the control is being done.  For
    example, extracting text from the top of the control uses less resources
    that extracting text from the end of the control.

Group: Credit

    This library was inspired by the Edit mini-library created by *Lexikos* and
    the HiEditor library created by *majkinetor*.  Some of the syntax and code
    ideas were extracted from these libraries.  Thanks to these authors for
    sharing their work.

Group: Functions
*/


;-----------------------------
;
; Function: Edit_ActivateParent
;
; Description:
;
;   Activates (makes foremost) the parent window of the Edit control if needed.
;   If the window is minimized, it is automatically restored prior to being
;   activated.
;
; Returns:
;
;   TRUE if successful, or FALSE otherwise.
;
; Remarks:
;
;   This function only actives the parent window of the Edit control.  It does
;   not give focus to the Edit control.  If needed, call <Edit_SetFocus> instead
;   of (or in addition to) this function.
;
;-------------------------------------------------------------------------------
Edit_ActivateParent(hEdit)
    {
    ;-- Get handle to the parent window
    hParent:=DllCall("GetParent","Ptr",hEdit,"Ptr")

    ;-- Activate if needed
    IfWinNotActive ahk_id %hParent%
        {
        WinActivate ahk_id %hParent%

        ;-- Still not active? (relatively rare)
        IfWinNotActive ahk_id %hParent%
            {
            ;-- Give the window an additional 250 ms to activate
            WinWaitActive ahk_id %hParent%,,0.25
            if ErrorLevel
                Return False
            }
        }

    Return True
    }


;-----------------------------
;
; Function: Edit_CanUndo
;
; Description:
;
;   Returns TRUE if there are any actions in the Edit control's undo queue,
;   otherwise FALSE.
;
;-------------------------------------------------------------------------------
Edit_CanUndo(hEdit)
    {
    Static EM_CANUNDO:=0xC6
    SendMessage EM_CANUNDO,0,0,,ahk_id %hEdit%
    Return ErrorLevel
    }


;-----------------------------
;
; Function: Edit_CharFromPos
;
; Description:
;
;   Gets information about the character and/or line closest to a specified
;   point in the the client area of the Edit control.
;
; Parameters:
;
;   X, Y - The coordinates of a point in the Edit control's client area
;       relative to the upper-left corner of the client area.
;
;   r_CharPos - [Output] The zero-based index of the character nearest the
;       specified point. [Optional] This index is relative to the beginning of
;       the control, not the beginning of the line.  If the specified point is
;       beyond the last character in the Edit control, the return value
;       indicates the last character in the control.  See the *Remarks* section
;       for more information.
;
;   r_LineIdx - [Output] Zero-based index of the line that contains the
;       character. [Optional] For single-line Edit controls, this value is zero.
;       The index indicates the line delimiter if the specified point is beyond
;       the last visible character in a line.  See the *Remarks* section for
;       more information.
;
; Returns:
;
;   The value of the r_CharPos variable.
;
; Calls To Other Functions:
;
; * <Edit_GetFirstVisibleLine>
; * <Edit_LineIndex>
;
; Remarks:
;
;   If the specified point is outside the bounds of the Edit control, the
;   return value and all output variables (r_CharPos and r_LineIdx) are set to
;   -1.
;
;-------------------------------------------------------------------------------
Edit_CharFromPos(hEdit,X,Y,ByRef r_CharPos="",ByRef r_LineIdx="")
    {
    Static Dummy3902

          ;-- Messages
          ,EM_CHARFROMPOS        :=0xD7
          ,EM_GETFIRSTVISIBLELINE:=0xCE
          ,EM_LINEINDEX          :=0xBB

    ;-- Collect character position from coordinates
    SendMessage EM_CHARFROMPOS,0,(Y<<16)|X,,ahk_id %hEdit%

    ;-- Out of bounds?
    if (ErrorLevel<<32>>32=-1)
        {
        r_CharPos:=-1
        r_LineIdx:=-1
        Return -1
        }

    ;-- Extract values (UShort)
    r_CharPos:=ErrorLevel&0xFFFF    ;-- LOWORD
    r_LineIdx:=ErrorLevel>>16       ;-- HIWORD

    ;-- Convert from UShort to UInt using known UInt values as reference
    SendMessage EM_GETFIRSTVISIBLELINE,0,0,,ahk_id %hEdit%
    FirstLine:=ErrorLevel-1
    if (FirstLine>r_LineIdx)
        r_LineIdx:=r_LineIdx+(65536*Floor((FirstLine+(65535-r_LineIdx))/65536))

    SendMessage EM_LINEINDEX,(FirstLine<0) ? 0:FirstLine,0,,ahk_id %hEdit%
    FirstCharPos:=ErrorLevel
    if (FirstCharPos>r_CharPos)
        r_CharPos:=r_CharPos+(65536*Floor((FirstCharPos+(65535-r_CharPos))/65536))

    Return r_CharPos
    }


;-----------------------------
;
; Function: Edit_Clear
;
; Description:
;
;   Clear (delete) the current selection, if any, from the Edit control.
;
; Remarks:
;
;   Undo can be used to reverse this action.
;
;-------------------------------------------------------------------------------
Edit_Clear(hEdit)
    {
    Static WM_CLEAR:=0x303
    SendMessage WM_CLEAR,0,0,,ahk_id %hEdit%
    }


;-----------------------------
;
; Function: Edit_ContainsSoftLineBreaks
;
; Description:
;
;   Returns TRUE if the Edit control contains any soft line-break characters
;   in the text.
;
; Type:
;
;   Experimental/Preview.  Subject to change.
;
; Calls To Other Functions:
;
; * <Edit_FmtLines>
; * <Edit_GetText>
; * <Edit_IsWordWrap>
;
; Remarks:
;
;   This function is resource intensive.  The entire document is formatted to
;   include soft line-break characters (if any) and then reverted back to the
;   original format.  Use sparingly.  When used on large documents, performance
;   can be significantly improved by setting *SetBatchLines* to a high value
;   before calling this function.  For example:
;
;       (start code)
;       SetBatchLines 100ms  ;-- Large bump in priority
;       RC:=Edit_ContainsSoftLineBreaks(hEdit)
;       SetBatchLines 10ms   ;-- Default priority
;       (end)
;
;   Warning: There is an extremely remote possiblity that a library function
;   that uses the WM_GETTEXT message (Ex: <Edit_GetSelText>) can collect
;   formatted text, i.e. text that includes soft line-break characters, while
;   this function is running.  This can occur if the the thread running this
;   function is interrupted by another thread immediately after formatting the
;   Edit control to include soft line-break characters.  In this scenario, the
;   interrupting thread uses a function that uses the WM_GETTEXT message and
;   collects formatted text.  The chances of this occurring are virtually nil
;   for small and medium-sized documents but the chances increase (although
;   still very unlikely) as the size of the document increases.  To
;   significantly reduce the chance of interruption, set *SetBatchLines* to a
;   high value (or -1) before calling this function.
;
;-------------------------------------------------------------------------------
Edit_ContainsSoftLineBreaks(hEdit)
    {
    ;-- Bounce if Word Wrap is not enabled
    ;
    ;   Note 1: The Edit_IsWordWrap function can return a false positive (very
    ;   rare, but possible) but so far, no false negatives have been identified
    ;   so it should be safe to use here.
    ;
    ;   Note 2: The Edit_IsWordWrap function does a lot of testing to exclude
    ;   invalid conditions (Ex: Is multiline Edit control?) so these same tests
    ;   do not have to be performed here.
    ;
    if not Edit_IsWordWrap(hEdit)
        Return FALSE

    ;-- Get formatted text from the control
    Edit_FmtLines(hEdit,True)
    l_FormattedText:=Edit_GetText(hEdit)
    Edit_FmtLines(hEdit,False)

    ;-- Any soft line-break characters?
    if l_FormattedText Contains `r`r`n
        Return True

    Return False
    }


;-----------------------------
;
; Function: Edit_Convert2DOS
;
; Description:
;
;   Converts Unix, DOS/Unix mix, and Mac EOL formats to DOS format.
;
;-------------------------------------------------------------------------------
Edit_Convert2DOS(p_Text)
    {
    StringReplace p_Text,p_Text,`r`n,`n,All             ;-- Convert DOS to Unix
    StringReplace p_Text,p_Text,`r,`n,All               ;-- Convert Mac to Unix
    StringReplace p_Text,p_Text,`n,`r`n,All             ;-- Convert Unix to DOS
    Return p_Text
    }


;-----------------------------
;
; Function: Edit_Convert2Mac
;
; Description:
;
;   Convert DOS, DOS/Unix mix, and Unix EOL formats to Mac format.
;
;-------------------------------------------------------------------------------
Edit_Convert2Mac(p_Text)
    {
    StringReplace p_Text,p_Text,`r`n,`r,All             ;-- Convert DOS to Mac
    StringReplace p_Text,p_Text,`n,`r,All               ;-- Convert Unix to Mac
    if StrLen(p_Text)
        if (SubStr(p_Text,0)<>"`r")
            p_Text.="`r"

    Return p_Text
    }


;-----------------------------
;
; Function: Edit_Convert2Unix
;
; Description:
;
;   Convert DOS, DOS/Unix mix, and Mac formats to Unix format.
;
;-------------------------------------------------------------------------------
Edit_Convert2Unix(p_Text)
    {
    StringReplace p_Text,p_Text,`r`n,`n,All             ;-- Convert DOS to Unix
    StringReplace p_Text,p_Text,`r,`n,All               ;-- Convert Mac to Unix
    if StrLen(p_Text)
        if (SubStr(p_Text,0)<>"`n")
            p_Text.="`n"

    Return p_Text
    }


;-----------------------------
;
; Function: Edit_ConvertCase
;
; Description:
;
;   Convert case of selected text.
;
; Parameters:
;
;   p_Case - Set to "Upper", "Lower", "Capitalize", "Sentence", or "Toggle".
;
; Calls To Other Functions:
;
; * <Edit_GetSel>
; * <Edit_GetSelText>
; * <Edit_ReplaceSel>
; * <Edit_SetSel>
;
;-------------------------------------------------------------------------------
Edit_ConvertCase(hEdit,p_Case)
    {
    StringUpper,p_Case,p_Case,T  ;-- Just in case StringCaseSense is On

    ;-- Collect current select postions
    Edit_GetSel(hEdit,l_StartSelPos,l_EndSelPos)
    if (l_StartSelPos=l_EndSelPos)  ;-- Nothing selected
        Return

    ;-- Collect selected text
    l_SelectedText:=Edit_GetSelText(hEdit)
    if l_SelectedText is Space
        Return

    ;-- Convert
    if p_Case in U,Upper,Uppercase
        StringUpper l_SelectedText,l_SelectedText
     else
        if p_Case in L,Lower,Lowercase
            StringLower l_SelectedText,l_SelectedText
         else
            if p_Case in C,Capitalize,Title,Titlecase
                StringLower l_SelectedText,l_SelectedText,T
             else
                if p_Case in S,Sentence,Sentencecase
                    {
                    StringLower l_SelectedText,l_SelectedText
                    l_SelectedText:=RegExReplace(l_SelectedText,"((?:^|[.!?]\s+)[a-z])","$u1")
                        ;-- Note: Pattern provided by ManaUser
                    }
                 else
                    if p_Case in T,Toggle,Togglecase,I,Invert,Invertcase
                        {
                        t_SelectedText:=""
                        Loop Parse,l_SelectedText
                            {
                            t_Char:=A_LoopField
                            if t_Char is Upper
                                StringLower t_Char,t_Char
                             else
                                if t_Char is Lower
                                    StringUpper t_Char,t_Char

                            t_SelectedText.=t_Char
                            }

                        l_SelectedText:=t_SelectedText
                        }

    ;-- Replace selected text with converted text
    Edit_ReplaceSel(hEdit,l_SelectedText)

    ;-- Reselect to the user's original positions
    Edit_SetSel(hEdit,l_StartSelPos,l_EndSelPos)
    }


;-----------------------------
;
; Function: Edit_Copy
;
; Description:
;
;   Copy the current selection to the clipboard in CF_TEXT format.
;
;-------------------------------------------------------------------------------
Edit_Copy(hEdit)
    {
    Static WM_COPY:=0x301
    SendMessage WM_COPY,0,0,,ahk_id %hEdit%
    }


;-----------------------------
;
; Function: Edit_Cut
;
; Description:
;
;   Delete the current selection, if any, and copy the deleted text to the
;   clipboard in CF_TEXT format.
;
;-------------------------------------------------------------------------------
Edit_Cut(hEdit)
    {
    Static WM_CUT:=0x300
    SendMessage WM_CUT,0,0,,ahk_id %hEdit%
    }


;------------------------------
;
; Function: Edit_Disable
;
; Description:
;
;   Disables ("greys out") an Edit control.
;
; Returns:
;
;   TRUE if successful, otherwise FALSE.
;
; Remarks:
;
;   For AutoHotkey GUIs, use the *GUIControl* command for improved efficiency.
;   Ex: GUIControl 24:Disable,MyEdit
;
;-------------------------------------------------------------------------------
Edit_Disable(hEdit)
    {
    Control Disable,,,ahk_id %hEdit%
    Return ErrorLevel ? False:True
    }


;------------------------------
;
; Function: Edit_DisableAllScrollBars
;
; Description:
;
;   Disables the horizontal and vertical scroll bars.
;
; Returns:
;
;   TRUE if successful, otherwise FALSE.
;
; Calls To Other Functions:
;
; * <Edit_EnableScrollBar>
;
; Remarks:
;
;   See <Edit_EnableScrollBar> for more information.
;
;-------------------------------------------------------------------------------
Edit_DisableAllScrollBars(hEdit)
    {
    Static SB_BOTH:=3,ESB_DISABLE_BOTH:=0x3
    Return Edit_EnableScrollBar(hEdit,SB_BOTH,ESB_DISABLE_BOTH)
    }


;------------------------------
;
; Function: Edit_DisableHScrollBar
;
; Description:
;
;   Disables the horizontal scroll bar.
;
; Returns:
;
;   TRUE if successful, otherwise FALSE.
;
; Calls To Other Functions:
;
; * <Edit_EnableScrollBar>
;
; Remarks:
;
;   See <Edit_EnableScrollBar> for more information.
;
;-------------------------------------------------------------------------------
Edit_DisableHScrollBar(hEdit)
    {
    Static SB_HORZ:=0,ESB_DISABLE_BOTH:=0x3
    Return Edit_EnableScrollBar(hEdit,SB_HORZ,ESB_DISABLE_BOTH)
    }


;------------------------------
;
; Function: Edit_DisableVScrollBar
;
; Description:
;
;   Disables the vertical scroll bar.
;
; Returns:
;
;   TRUE if successful, otherwise FALSE.
;
; Calls To Other Functions:
;
; * <Edit_EnableScrollBar>
;
; Remarks:
;
;   See <Edit_EnableScrollBar> for more information.
;
;-------------------------------------------------------------------------------
Edit_DisableVScrollBar(hEdit)
    {
    Static SB_VERT:=1,ESB_DISABLE_BOTH:=0x3
    Return Edit_EnableScrollBar(hEdit,SB_VERT,ESB_DISABLE_BOTH)
    }


;-----------------------------
;
; Function: Edit_EmptyUndoBuffer
;
; Description:
;
;   Resets the undo flag of the Edit control.  The undo flag is set whenever an
;   operation within the Edit control can be undone.
;
;-------------------------------------------------------------------------------
Edit_EmptyUndoBuffer(hEdit)
    {
    Static EM_EMPTYUNDOBUFFER:=0xCD
    SendMessage EM_EMPTYUNDOBUFFER,0,0,,ahk_id %hEdit%
    }


;------------------------------
;
; Function: Edit_Enable
;
; Description:
;
;   Enables a Edit control if it was previously disabled.
;
; Returns:
;
;   TRUE if successful, otherwise FALSE.
;
; Remarks:
;
;   For AutoHotkey GUIs, use the *GUIControl* command for improved efficiency.
;   Ex: GUIControl 12:Enable,MyEdit
;
;-------------------------------------------------------------------------------
Edit_Enable(hEdit)
    {
    Control Enable,,,ahk_id %hEdit%
    Return ErrorLevel ? False:True
    }


;------------------------------
;
; Function: Edit_EnableAllScrollBars
;
; Description:
;
;   Enables the horizontal and vertical scroll bars.
;
; Returns:
;
;   TRUE if successful, otherwise FALSE.
;
; Calls To Other Functions:
;
; * <Edit_EnableScrollBar>
;
; Remarks:
;
;   See <Edit_EnableScrollBar> for more information.
;
;-------------------------------------------------------------------------------
Edit_EnableAllScrollBars(hEdit)
    {
    Static SB_BOTH:=3,ESB_ENABLE_BOTH:=0x0
    Return Edit_EnableScrollBar(hEdit,SB_BOTH,ESB_ENABLE_BOTH)
    }


;------------------------------
;
; Function: Edit_EnableHScrollBar
;
; Description:
;
;   Enables the horizontal scroll bar.
;
; Returns:
;
;   TRUE if successful, otherwise FALSE.
;
; Calls To Other Functions:
;
; * <Edit_EnableScrollBar>
;
; Remarks:
;
;   See <Edit_EnableScrollBar> for more information.
;
;-------------------------------------------------------------------------------
Edit_EnableHScrollBar(hEdit)
    {
    Static SB_HORZ:=0,ESB_ENABLE_BOTH:=0x0
    Return Edit_EnableScrollBar(hEdit,SB_HORZ,ESB_ENABLE_BOTH)
    }


;------------------------------
;
; Function: Edit_EnableVScrollBar
;
; Description:
;
;   Enables the vertical scroll bar.
;
; Returns:
;
;   TRUE if successful, otherwise FALSE.
;
; Calls To Other Functions:
;
; * <Edit_EnableScrollBar>
;
; Remarks:
;
;   See <Edit_EnableScrollBar> for more information.
;
;-------------------------------------------------------------------------------
Edit_EnableVScrollBar(hEdit)
    {
    Static SB_VERT:=1,ESB_ENABLE_BOTH:=0x0
    Return Edit_EnableScrollBar(hEdit,SB_VERT,ESB_ENABLE_BOTH)
    }


;------------------------------
;
; Function: Edit_EnableScrollBar
;
; Description:
;
;   Enables or disables one or both scroll bar arrows.
;
; Parameters:
;
;   wSBflags - Specifies the scroll bar type.  See the function's static
;       variables for a list of possible values.
;
;   wArrows - Specifies whether the scroll bar arrows are enabled or disabled
;       and indicates which arrows are enabled or disabled.  See the function's
;       static variables for a list of possible values.
;
; Returns:
;
;   TRUE if successful, otherwise FALSE.
;
; Remarks:
;
;   The function will return FALSE (not successful) if the scroll bar(s) are
;   already in the requested state (enabled/disabled).  To determine if a scroll
;   bar is already enabled, use <Edit_IsHScrollBarEnabled> and/or
;   <Edit_IsVScrollBarEnabled>.
;
;-------------------------------------------------------------------------------
Edit_EnableScrollBar(hEdit,wSBflags,wArrows)
    {
    Static Dummy5401

          ;-- Scrollbar Type
          ,SB_HORZ:=0
                ;-- Enables or disables the arrows on the horizontal scroll bar
                ;   associated with the specified window.

          ,SB_VERT:=1
                ;-- Enables or disables the arrows on the vertical scroll bar
                ;   associated with the specified window.

          ,SB_CTL:=2
                ;-- Indicates that the scroll bar is a scroll bar control.  The
                ;   hWnd  must be the handle to the scroll bar control.

          ,SB_BOTH:=3
                ;-- Enables or disables the arrows on the horizontal and
                ;   vertical scroll bars associated with the specified window.

          ;-- Scrollbar Arrows
          ,ESB_ENABLE_BOTH:=0x0
                ;-- Enables both arrows on a scroll bar.

          ,ESB_DISABLE_LEFT:=0x1
                ;-- Disables the left arrow on a horizontal scroll bar.

          ,ESB_DISABLE_BOTH:=0x3
                ;-- Disables both arrows on a scroll bar.

          ,ESB_DISABLE_DOWN:=0x2
                ;-- Disables the down arrow on a vertical scroll bar.

          ,ESB_DISABLE_UP:=0x1
                ;-- Disables the up arrow on a vertical scroll bar.

          ,ESB_DISABLE_LTUP:=0x1  ;-- Same as ESB_DISABLE_LEFT
                ;-- Disables the left arrow on a horizontal scroll bar or the up
                ;   arrow of a vertical scroll bar.

          ,ESB_DISABLE_RIGHT:=0x2
                ;-- Disables the right arrow on a horizontal scroll bar.

          ,ESB_DISABLE_RTDN:=0x2  ;-- Same as ESB_DISABLE_RIGHT
                ;-- Disables the right arrow on a horizontal scroll bar or the
                ;   down arrow of a vertical scroll bar.

    RC:=DllCall("EnableScrollBar"
        ,"Ptr",hEdit                                    ;-- hWnd
        ,"UInt",wSBflags                                ;-- wSBflags
        ,"UInt",wArrows)                                ;-- wArrows

    Return RC ? True:False
    }


;-----------------------------
;
; Function: Edit_FindText
;
; Description:
;
;   Find text within the Edit control.
;
; Parameters:
;
;   p_SearchText - Search text.
;
;   p_Min, p_Max -  Zero-based search range within the Edit control.  p_Min is
;       the character index of the first character in the range and p_Max is the
;       character index immediately following the last character in the range.
;       (Ex: To search the first 5 characters of the text, set p_Min to 0 and
;       p_Max to 5)  Set p_Max to -1 to search to the end of the text.  To
;       search backward, the roles and descriptions of the p_Min and p_Max are
;       reversed. (Ex: To search the first 5 characters of the control in
;       reverse, set p_Min to 5 and p_Max to 0)
;
;   p_Flags - Valid flags are as follows:
;
;       (Start code)
;       Flag        Description
;       ----        -----------
;       MatchCase   Search is case sensitive.  This flag is ignored if the
;                   "RegEx" flag is also defined.
;
;       RegEx       Regular expression search.
;
;       Static      [Advanced feature]
;                   Text collected from the Edit control remains in memory is
;                   used to satisfy the search request.  The text remains in
;                   memory until the "Reset" flag is used or until the
;                   "Static" flag is not used.
;
;                   Advantages: Search time is reduced 10 to 60 percent
;                   (or more) depending on the size of the text in the control.
;                   There is no speed increase on the first use of the "Static"
;                   flag.
;
;                   Disadvantages: Any changes in the Edit control are not
;                   reflected in the search.
;
;                   Hint: Don't use this flag unless performing multiple search
;                   requests on a control that will not be modified while
;                   searching.
;
;       Reset       [Advanced feature]
;                   Clears the saved text created by the "Static" flag so that
;                   the next use of the "Static" flag will get the text directly
;                   from the Edit control.  To clear the saved memory without
;                   performing a search, use the following syntax:
;
;                       Edit_FindText("","",0,0,"Reset")
;       (end)
;
;
;   r_RegExOutput - Variable that contains the part of the source text that
;       matched the RegEx pattern. [Optional]
;
; Returns:
;
;   Zero-based character index of the first character of the match or -1 if no
;   match is found.
;
; Calls To Other Functions:
;
; * <Edit_GetText>
; * <Edit_GetTextLength>
; * <Edit_GetTextRange>
;
; Programming Notes:
;
;   Searching using regular expressions (RegEx) can produce results that have a
;   dynamic number of characters.  For this reason, searching for the "next"
;   pattern (forward or backward) may produce different results from developer
;   to developer depending on how the values of p_Min and p_Max are determined.
;
;-------------------------------------------------------------------------------
Edit_FindText(hEdit,p_SearchText,p_Min=0,p_Max=-1,p_Flags="",ByRef r_RegExOut="")
    {
    Static s_Text

    ;-- Initialize
    r_RegExOut:=""
    if InStr(p_Flags,"Reset")
        s_Text:=""

    ;-- Anything to search?
    if not StrLen(p_SearchText)
        Return -1

    l_MaxLen:=Edit_GetTextLength(hEdit)
    if (l_MaxLen=0)
        Return -1

    ;-- Parameters
    if (p_Min<0 or p_Max>l_MaxLen)
        p_Min:=l_MaxLen

    if (p_Max<0 or p_Max>l_MaxLen)
        p_Max:=l_MaxLen

    ;-- Anything to search?
    if (p_Min=p_Max)
        Return -1

    ;-- Get text
    if InStr(p_Flags,"Static")
        {
        if not StrLen(s_Text)
            s_Text:=Edit_GetText(hEdit)

        l_Text:=SubStr(s_Text,(p_Max>p_Min) ? p_Min+1:p_Max+1,(p_Max>p_Min) ? p_Max:p_Min)
        }
     else
        {
        s_Text:=""
        l_Text:=Edit_GetTextRange(hEdit,(p_Max>p_Min) ? p_Min:p_Max,(p_Max>p_Min) ? p_Max:p_Min)
        }

    ;-- Look for it
    if not InStr(p_Flags,"RegEx")  ;-- Not RegEx
        l_FoundPos:=InStr(l_Text,p_SearchText,InStr(p_Flags,"MatchCase"),(p_Max>p_Min) ? 1:0)-1
     else  ;-- RegEx
        {
        p_SearchText:=RegExReplace(p_SearchText,"^P\)?","",1)   ;-- Remove P or P)
        if (p_Max>p_Min)  ;-- Search forward
            {
            l_FoundPos:=RegExMatch(l_Text,p_SearchText,r_RegExOut,1)-1
            if ErrorLevel
                {
                outputdebug,
                   (ltrim join`s
                    Function: %A_ThisFunc% - RegExMatch error.
                    ErrorLevel=%ErrorLevel%
                   )

                l_FoundPos:=-1
                }
            }
         else  ;-- Search backward
            {
            ;-- Programming notes:
            ;
            ;    -  The first search begins from the user-defined minimum
            ;       position.  This will establish the true minimum position to
            ;       begin search calculations.  If nothing is found, no
            ;       additional searching is necessary.
            ;
            ;    -  The RE_MinPos, RE_MaxPos, and RE_StartPos variables contain
            ;       1-based values.
            ;
            RE_MinPos     :=1
            RE_MaxPos     :=StrLen(l_Text)
            RE_StartPos   :=RE_MinPos
            Saved_FoundPos:=-1
            Saved_RegExOut:=""
            Loop
                {
                ;-- Positional search.  Last found match (if any) wins
                l_FoundPos:=RegExMatch(l_Text,p_SearchText,r_RegExOut,RE_StartPos)-1
                if ErrorLevel
                    {
                    outputdebug,
                       (ltrim join`s
                        Function: %A_ThisFunc% - RegExMatch error.
                        ErrorLevel=%ErrorLevel%
                       )

                    l_FoundPos:=-1
                    Break
                    }

                ;-- If found, update saved and RE_MinPos, else update RE_MaxPos
                if (l_FoundPos>-1)
                    {
                    Saved_FoundPos:=l_FoundPos
                    Saved_RegExOut:=r_RegExOut
                    RE_MinPos     :=l_FoundPos+2
                    }
                else
                    RE_MaxPos:=RE_StartPos-1

                ;-- Are we done?
                if (RE_MinPos>RE_MaxPos or RE_MinPos>StrLen(l_Text))
                    {
                    l_FoundPos:=Saved_FoundPos
                    r_RegExOut:=Saved_RegExOut
                    Break
                    }

                ;-- Calculate new start position
                RE_StartPos:=RE_MinPos+Floor((RE_MaxPos-RE_MinPos)/2)
                }
            }
        }

    ;-- Adjust FoundPos
    if (l_FoundPos>-1)
        l_FoundPos+=(p_Max>p_Min) ? p_Min:p_Max

    Return l_FoundPos
    }

;-----------------------------
;
; Function: Edit_FindTextReset
;
; Description:
;
;   Clears the saved text created by the "Static" flag.
;
; Calls To Other Functions:
;
; * <Edit_FindText>
;
;-------------------------------------------------------------------------------
Edit_FindTextReset()
    {
    Edit_FindText("","",0,0,"Reset")
    }


;-----------------------------
;
; Function: Edit_FmtLines
;
; Description:
;
;   Sets a flag that determines whether a multiline Edit control includes soft
;   line-break characters.  A soft line break consists of two carriage return
;   characters and a line feed character (CR+CR+LF) and is inserted at the end
;   of a line that is broken because of word wrapping.
;
; Parameters:
;
;   p_Flag - Set to TRUE to insert soft line-break characters characters, FALSE
;       to removes them.
;
; Returns:
;
;   The value of p_Flag.
;
; Remarks:
;
;   This message has no effect on the display of the text within the edit
;   control.  It affects the buffer returned by the EM_GETHANDLE message and
;   the text returned by the WM_GETTEXT message.  Since the WM_GETTEXT message
;   is used by other functions in this library, be sure to un-format the text as
;   soon as possible.  Example of use:
;
;       (start code)
;       Edit_FmtLines(hEdit,True)
;       FormattedText:=Edit_GetText(hEdit)
;       Edit_FmtLines(hEdit,False)
;       (end)
;
;-------------------------------------------------------------------------------
Edit_FmtLines(hEdit,p_Flag)
    {
    Static EM_FMTLINES:=0xC8
    SendMessage EM_FMTLINES,p_Flag,0,,ahk_id %hEdit%
    Return ErrorLevel
    }


;-----------------------------
;
; Function: Edit_GetActiveHandles
;
; Description:
;
;   Finds the handles for the active control and active window.
;
; Type:
;
;   Helper function.
;
; Parameters:
;
;   hEdit - Variable that contains the handle of the active Edit control.
;       [Optional] Value is zero if the active control is not an Edit control.
;
;   hWindow - Variable that contains the handle of the active window. [Optional]
;
;   p_MsgBox - Display error message. [Optional] If TRUE, an error MsgBox is
;       displayed if the active control is not an Edit control.
;
; Returns:
;
;   Handle of the active Edit control or FALSE (0) if the active control is not
;   an Edit control.
;
;-------------------------------------------------------------------------------
Edit_GetActiveHandles(ByRef hEdit="",ByRef hWindow="",p_MsgBox=False)
    {
    WinGet hWindow,ID,A
    ControlGetFocus l_Control,A
    if (SubStr(l_Control,1,4)="Edit")
        {
        ControlGet hEdit,hWnd,,%l_Control%,A
        Return hEdit
        }

    if p_MsgBox
        MsgBox
            ,0x40010
                ;-- 0x0 (OK button) + 0x10 ("Error" icon) + 0x40000 (AOT)
            ,Error
            ,This request cannot be performed on this control.  %A_Space%

    Return False
    }


;------------------------------
;
; Function: Edit_GetComboBoxEdit
;
; Description:
;
;   Returns the handle to the Edit control attached to a combo box.
;
; Parameters:
;
;   hCombo - Handle to a combo box control.
;
; Credit:
;
;   Code adapted from an example posted by *just me*.
;   Post: http://www.autohotkey.com/community/viewtopic.php?p=569444#p569444
;
;-------------------------------------------------------------------------------
Edit_GetComboBoxEdit(hCombo)
    {
    ;-- Define/Populate the COMBOBOXINFO structure
    cbSize:=(A_PtrSize=8) ? 64:52
    VarSetCapacity(COMBOBOXINFO,cbSize,0)
    NumPut(cbSize,COMBOBOXINFO,0,"UInt")                ;-- cbSize

    ;-- Get ComboBox info
    DllCall("GetComboBoxInfo","Ptr",hCombo,"Ptr",&COMBOBOXINFO)
    Return NumGet(COMBOBOXINFO,(A_PtrSize=8) ? 48:44,"Ptr")
        ;-- hwndItem
    }


;-----------------------------
;
; Function: Edit_GetCueBanner
;
; Description:
;
;   Gets the text that is displayed as the textual cue, or tip, in an edit
;   control.
;
; Parameters:
;
;   p_MaxSize - The maximum number of characters including the terminating null.
;       [Optional] The default is 1024.
;
; Returns:
;
;   Cue bannter text from the designated control.
;
; Requirements:
;
;   Documented:  Windows XP+,
;   Observation: Vista+
;
; Remarks:
;
;   Single-line Edit control only.
;
;-------------------------------------------------------------------------------
Edit_GetCueBanner(hEdit,p_MaxSize=1024)
    {
    Static EM_GETCUEBANNER:=0x1502                      ;-- ECM_FIRST+2
    VarSetCapacity(wText,p_MaxSize*(A_IsUnicode ? 2:1),0)
    SendMessage EM_GETCUEBANNER,&wText,p_MaxSize,,ahk_id %hEdit%
    if ErrorLevel  ;-- Cue banner text found
        Return A_IsUnicode ? wText:StrGet(&wText,-1,"UTF-16")
    }


;-----------------------------
;
; Function: Edit_GetFirstVisibleLine
;
; Description:
;
;   Returns the zero-based index of the uppermost visible line.  For single-line
;   Edit controls, the return value is the zero-based index of the first visible
;   character.
;
;-------------------------------------------------------------------------------
Edit_GetFirstVisibleLine(hEdit)
    {
    Static EM_GETFIRSTVISIBLELINE:=0xCE
    SendMessage EM_GETFIRSTVISIBLELINE,0,0,,ahk_id %hEdit%
    Return ErrorLevel
    }


;------------------------------
;
; Function: Edit_GetFont
;
; Description:
;
;   Gets the font with which the Edit control is currently drawing its text.
;
; Parameters:
;
;   hEdit - Handle to the Edit control.
;
; Returns:
;
;   The handle to the font (HFONT) used by the Edit control or 0 if the
;   using the system font.
;
; Remarks:
;
;   This function can be used to get the font of any control.  Just specify
;   the handle to the desired control as the first parameter.
;   Ex: Edit_GetFont(hLV) where "hLV" is the handle to a ListView control.
;
;-------------------------------------------------------------------------------
Edit_GetFont(hEdit)
    {
    Static WM_GETFONT:=0x31
    SendMessage WM_GETFONT,0,0,,ahk_id %hEdit%
    Return ErrorLevel
    }


;-----------------------------
;
; Function: Edit_GetLastVisibleLine
;
; Description:
;
;   Returns the zero-based line index of the last visible line on the edit
;   control.
;
; Calls To Other Functions:
;
; * <Edit_GetRect>
; * <Edit_LineFromPos>
;
; Remarks:
;
;   To calculate the total number of visible lines, use the following...
;
;       (start code)
;       Edit_GetLastVisibleLine(hEdit) - Edit_GetFirstVisibleLine(hEdit) + 1
;       (end)
;
;-------------------------------------------------------------------------------
Edit_GetLastVisibleLine(hEdit)
    {
    Edit_GetRect(hEdit,Left,Top,Right,Bottom)
    Return Edit_LineFromPos(hEdit,0,Bottom-1)
    }


;-----------------------------
;
; Function: Edit_GetLimitText
;
; Description:
;
;   Returns the current text limit for the Edit control.
;
; Remarks:
;
;   Windows NT+: The maximum text length is 0x7FFFFFFE (2,147,483,646)
;   characters for single-line Edit controls and 0xFFFFFFFF (4,294,967,295) for
;   multiline Edit controls.  These values are returned if no limit has been set
;   on the Edit control.
;
;-------------------------------------------------------------------------------
Edit_GetLimitText(hEdit)
    {
    Static EM_GETLIMITTEXT:=0xD5
    SendMessage EM_GETLIMITTEXT,0,0,,ahk_id %hEdit%
    Return ErrorLevel
    }


;-----------------------------
;
; Function: Edit_GetLine
;
; Description:
;
;   Get the text of the desired line from the Edit control.
;
; Parameters:
;
;   p_LineIdx - The zero-based index of the line to retrieve. [Optional] Use
;       -1 (the default) to get the current line.  This parameter is ignored if
;       used for a single-line Edit control.
;
;   p_Length - Length of the line or length of the text to be extracted.
;       [Optional] Use -1 (the default) to automatically determine the length
;       of the line.
;
; Returns:
;
;   The text of the specified line up to the length (p_Length) specified.  An
;   empty string is returned if the line number specified by p_LineIdx is
;   greater than the number of lines in the Edit control.
;
; Calls To Other Functions:
;
; * <Edit_LineFromChar>
; * <Edit_LineIndex>
; * <Edit_LineLength>
;
;-------------------------------------------------------------------------------
Edit_GetLine(hEdit,p_LineIdx=-1,p_Length=-1)
    {
    Static EM_GETLINE:=0xC4
    if (p_LineIdx<0)
        p_LineIdx:=Edit_LineFromChar(hEdit,Edit_LineIndex(hEdit))

    l_TCHARs:=(p_Length<0) ? Edit_LineLength(hEdit,p_LineIdx):p_Length
    if (l_TCHARs=0)
        Return

    ;-- Create and initialize buffer
    nSize:=A_IsUniCode ? l_TCHARs*2:(l_TCHARs=1) ? 2:l_TCHARs
        ;-- Programming note: This is size of the buffer, not necessarily the
        ;   size of the string returned.  Since the first WORD (aka UShort) of
        ;   the buffer is set to the size, in TCHARs, of the buffer, the
        ;   minimum buffer size is 2 bytes.

    VarSetCapacity(l_Text,nSize,0)
    NumPut((l_TCHARs=1) ? 2:l_TCHARs,l_Text,0,"UShort")

    ;-- Get Line
    SendMessage EM_GETLINE,p_LineIdx,&l_Text,,ahk_id %hEdit%
    Return SubStr(l_Text,1,l_TCHARs)
    }


;-----------------------------
;
; Function: Edit_GetLineCount
;
; Description:
;
;   Returns an integer specifying the total number of text lines in a multiline
;   Edit control.  If the control has no text, the return value is 1.  The
;   return value will never be less than 1.
;
; Remarks:
;
;   The value returned is for the number of lines in the Edit control.  Very
;   long lines (>1024 characters) or word wrap may introduce additional lines to
;   the control.
;
;-------------------------------------------------------------------------------
Edit_GetLineCount(hEdit)
    {
    Static EM_GETLINECOUNT:=0xBA
    SendMessage EM_GETLINECOUNT,0,0,,ahk_id %hEdit%
    Return ErrorLevel
    }


;-----------------------------
;
; Function: Edit_GetMargins
;
; Description:
;
;   Gets the widths of the left and right margins for the Edit control.  If
;   defined, these values are returned in the r_LeftMargin and r_RightMargin
;   variables.
;
; Parameters:
;
;   r_LeftMargin - Left margin, in pixels. [Optional]
;   r_RightMargin - Right margin, in pixels. [Optional]
;
; Returns:
;
;   The Edit control's left margin.
;
;-------------------------------------------------------------------------------
Edit_GetMargins(hEdit,ByRef r_LeftMargin="",ByRef r_RightMargin="")
    {
    Static EM_GETMARGINS:=0xD4
    SendMessage EM_GETMARGINS,0,0,,ahk_id %hEdit%
    r_LeftMargin :=ErrorLevel&0xFFFF    ;-- LOWORD of result
    r_RightMargin:=ErrorLevel>>16       ;-- HIWORD of result
    Return r_LeftMargin
    }


;-----------------------------
;
; Function: Edit_GetModify
;
; Description:
;
;   Gets the state of the Edit control's modification flag.  The flag indicates
;   whether the contents of the Edit control have been modified.
;
; Returns:
;
;   TRUE if the Edit control has been modified, otherwise FALSE.
;
;-------------------------------------------------------------------------------
Edit_GetModify(hEdit)
    {
    Static EM_GETMODIFY:=0xB8
    SendMessage EM_GETMODIFY,0,0,,ahk_id %hEdit%
    Return ErrorLevel
    }


;-----------------------------
;
; Function: Edit_GetPasswordChar
;
; Description:
;
;   Gets the password character that an Edit control displays when the user
;   enters text.
;
; Returns:
;
;   The decimal value of the character that is displayed in place of the
;   characters typed by the user.  If a password character has not been set, 0
;   is returned.
;
; Remarks:
;
; * Single-line Edit controls only.
;
; * If the return value is an ANSI value (between 1 and 255), the built-in
;   AutoHotkey *Chr* function can be used to convert the value to a character.
;   For example:
;
;       (start code)
;       Character:=Chr(Edit_GetPasswordChar(hEdit))
;       (end code)
;
; * For most versions of Windows, the default password character decimal value
;   is 9679 (black circle).
;
; Requirements:
;
;   Windows 2000+
;
;-------------------------------------------------------------------------------
Edit_GetPasswordChar(hEdit)
    {
    Static EM_GETPASSWORDCHAR:=0xD2
    Return DllCall("SendMessageW","Ptr",hEdit,"UInt",EM_GETPASSWORDCHAR,"UInt",0,"UInt",0)
    }


;------------------------------
;
; Function: Edit_GetPos
;
; Description:
;
;   Gets the position and size of the Edit control.  See the *Remarks* section
;   for more information.
;
; Parameters:
;
;   X, Y, W, H - Output variables. [Optional]  If defined, these variables
;       contain the coordinates of the Edit control relative to the client-area
;       of the parent window (X and Y), and the width and height of the Edit
;       control (W and H).
;
; Remarks:
;
;   This function returns the same values as the *GUIControlGet,OutputVar,Pos*
;   command and can be used when the *GUIControlGet* command is not available
;   (non-AutoHotkey GUI, GUI name unknown, variable name unknown, etc.)
;
;   If only interested in the W (Width) and/or H (Height) values, the
;   AutoHotkey *ControlGetPos* or *WinGetPos* commands can be used instead.
;
;   Hint: The built-in AutoHotkey *GUIControlGet*, *ControlGetPos*, and
;   *WinGetPos* commands are more efficient and should be used whenever
;   possible.
;
;-------------------------------------------------------------------------------
Edit_GetPos(hEdit,ByRef X="",ByRef Y="",ByRef W="",ByRef H="")
    {
    ;-- Initialize
    VarSetCapacity(RECT,16,0)

    ;-- Get the dimensions of the bounding rectangle of the Edit control
    DllCall("GetWindowRect","Ptr",hEdit,"Ptr",&RECT)
    W:=NumGet(RECT,8,"Int")-NumGet(RECT,0,"Int")        ;-- W=right-left
    H:=NumGet(RECT,12,"Int")-NumGet(RECT,4,"Int")       ;-- H=bottom-top

    ;-- Convert the screen coordinates of the Edit control to client-area
    ;   coordinates.  Note: The API reads/updates the first 8-bytes of the RECT
    ;   structure.
    DllCall("ScreenToClient"
        ,"Ptr",DllCall("GetParent","Ptr",hEdit,"Ptr")
        ,"Ptr",&RECT)

    X:=NumGet(RECT,0,"Int")                             ;-- left
    Y:=NumGet(RECT,4,"Int")                             ;-- top
    }


;-----------------------------
;
; Function: Edit_GetRect
;
; Description:
;
;   Gets the formatting rectangle of the Edit control.
;
; Parameters:
;
;   r_Left..r_Bottom - Output variables. [Optional]
;
; Returns:
;
;   The address to a RECT structure that contains the formatting rectangle.
;
;-------------------------------------------------------------------------------
Edit_GetRect(hEdit,ByRef r_Left="",ByRef r_Top="",ByRef r_Right="",ByRef r_Bottom="")
    {
    Static EM_GETRECT:=0xB2,RECT
    VarSetCapacity(RECT,16,0)
    SendMessage EM_GETRECT,0,&RECT,,ahk_id %hEdit%
    r_Left  :=NumGet(RECT,0,"Int")
    r_Top   :=NumGet(RECT,4,"Int")
    r_Right :=NumGet(RECT,8,"Int")
    r_Bottom:=NumGet(RECT,12,"Int")
    Return &RECT
    }


;------------------------------
;
; Function: Edit_GetScrollBarInfo
;
; Description:
;
;   Gets information about the specified scroll bar.
;
; Type:
;
;   Internal function.  Subject to change.  Do not use.
;
; Parameters:
;
;   idObject - Specifies the scroll bar object.  See the function's static
;       variables for a list of possible values.
;
; Returns:
;
;   The address to a SCROLLBARINFO structure that contains the information
;   requested.
;
;-------------------------------------------------------------------------------
Edit_GetScrollBarInfo(hEdit,idObject)
    {
    Static Dummy4820
          ,SCROLLBARINFO

          ;-- Object identifiers
          ,OBJID_HSCROLL:=0xFFFFFFFA
          ,OBJID_VSCROLL:=0xFFFFFFFB
          ,OBJID_CLIENT :=0xFFFFFFFC

          ;-- rgstate flags
          ,STATE_SYSTEM_UNAVAILABLE:=0x1
          ,STATE_SYSTEM_PRESSED    :=0x8
          ,STATE_SYSTEM_INVISIBLE  :=0x8000
          ,STATE_SYSTEM_OFFSCREEN  :=0x10000

    ;-- Create and initialize SCROLLBARINFO structure
    VarSetCapacity(SCROLLBARINFO,60,0)
    NumPut(60,SCROLLBARINFO,0,"UInt")                   ;-- cbSize

    ;-- Collect scrollbar info
    DllCall("GetScrollBarInfo"
        ,"Ptr",hEdit                                    ;-- hwnd
        ,"Int",idObject                                 ;-- idObject
        ,"Ptr",&SCROLLBARINFO)                          ;-- psbi

    ;-- Return address of SCROLLBARINFO structure
    Return &SCROLLBARINFO
    }


;------------------------------
;
; Function: Edit_GetScrollBarState
;
; Description:
;
;   Gets the state of specified scroll bar.
;
; Type:
;
;   Internal function.  Subject to change.  Do not use.
;
; Parameters:
;
;   idObject - Specifies the scroll bar object.  See the function's static
;       variables for a list of possible values.
;
; Returns:
;
;   The state of the specified scrollbar.  See the function's static variables
;   for a list of possible return values.
;
; Remarks:
;
;   This function returns the state of the scroll bar itself.  It does not
;   include the state of the arrow buttons, scroll box, etc.  If needed, use
;   <Edit_GetScrollBarInfo> to get this information.
;
;-------------------------------------------------------------------------------
Edit_GetScrollBarState(hEdit,idObject)
    {
    Static Dummy8290

          ;-- Object identifiers
          ,OBJID_HSCROLL:=0xFFFFFFFA
          ,OBJID_VSCROLL:=0xFFFFFFFB
          ,OBJID_CLIENT :=0xFFFFFFFC

          ;-- rgstate flags
          ,STATE_SYSTEM_UNAVAILABLE:=0x1
          ,STATE_SYSTEM_PRESSED    :=0x8
          ,STATE_SYSTEM_INVISIBLE  :=0x8000
          ,STATE_SYSTEM_OFFSCREEN  :=0x10000

    ;-- Create and initialize SCROLLBARINFO structure
    VarSetCapacity(SCROLLBARINFO,60,0)
    NumPut(60,SCROLLBARINFO,0,"UInt")                   ;-- cbSize

    ;-- Collect scrollbar info
    DllCall("GetScrollBarInfo"
        ,"Ptr",hEdit                                    ;-- hwnd
        ,"Int",idObject                                 ;-- idObject
        ,"Ptr",&SCROLLBARINFO)                          ;-- psbi

    ;-- Return scroll bar state
    Return NumGet(SCROLLBARINFO,36,"UInt")              ;-- rgstate
    }


;-----------------------------
;
; Function: Edit_GetSel
;
; Description:
;
;   Gets the starting and ending character positions of the current selection in
;   the Edit control.  If defined, these values are returned in the
;   r_StartSelPos and r_EndSelPos variables.
;
; Parameters:
;
;   r_StartSelPos - [Output] Variable that contains the starting position of the
;       selection. [Optional]
;
;   r_EndSelPos - [Output] Variable that contains the end position of the
;       selection. [Optional]
;
; Returns:
;
;   Starting position of the selection.
;
;-------------------------------------------------------------------------------
Edit_GetSel(hEdit,ByRef r_StartSelPos="",ByRef r_EndSelPos="")
    {
    Static Dummy3304
          ,s_StartSelPos
          ,s_EndSelPos
          ,Dummy1:=VarSetCapacity(s_StartSelPos,4,0)
          ,Dummy2:=VarSetCapacity(s_EndSelPos,4,0)

          ;-- Message
          ,EM_GETSEL:=0xB0

    ;-- Get the select positions
    SendMessage EM_GETSEL,&s_StartSelPos,&s_EndSelPos,,ahk_id %hEdit%
    r_StartSelPos:=NumGet(s_StartSelPos,0,"UInt")
    r_EndSelPos  :=NumGet(s_EndSelPos,0,"UInt")
    Return r_StartSelPos
    }

;-----------------------------
;
; Function: Edit_GetSelText
;
; Description:
;
;   Returns the currently selected text (if any).
;
; Calls To Other Functions:
;
; * <Edit_GetLine>
; * <Edit_GetSel>
; * <Edit_GetText>
; * <Edit_LineFromChar>
; * <Edit_LineIndex>
; * <Edit_LineLength>
;
; Remarks:
;
;   Since the Edit control does not support the EM_GETSELTEXT message, the
;   EM_GETLINE (if the selection is on one line) and the WM_GETTEXT messages are
;   used instead.
;
;-------------------------------------------------------------------------------
Edit_GetSelText(hEdit)
    {
    Edit_GetSel(hEdit,l_StartSelPos,l_EndSelPos)
    if (l_StartSelPos=l_EndSelPos)
        Return

    ;-- Get line indexes of the selection
    l_FirstSelectedLine:=Edit_LineFromChar(hEdit,l_StartSelPos)
    l_LastSelectedLine :=Edit_LineFromChar(hEdit,l_EndSelPos)

    ;-- Get selected text
    l_FirstPos:=Edit_LineIndex(hEdit,l_FirstSelectedLine)
     if (l_FirstSelectedLine=l_LastSelectedLine)
    and (l_EndSelPos<=l_FirstPos+Edit_LineLength(hEdit,l_FirstSelectedLine))
        Return SubStr(Edit_GetLine(hEdit,l_FirstSelectedLine,l_EndSelPos-l_FirstPos),l_StartSelPos-l_FirstPos+1)
     else
        Return SubStr(Edit_GetText(hEdit,l_EndSelPos),l_StartSelPos+1)
    }


;------------------------------
;
; Function: Edit_GetStyle
;
; Description:
;
;   Returns an integer that represents the styles currently set for the Edit
;   control.
;
; Remarks:
;
;   For a complete list of syles:
;
;       <http://msdn.microsoft.com/en-us/library/windows/desktop/bb775464(v=vs.85).aspx>
;
;-------------------------------------------------------------------------------
Edit_GetStyle(hEdit)
    {
    ControlGet l_Style,Style,,,ahk_id %hEdit%
    Return l_Style
    }


;-----------------------------
;
; Function: Edit_GetText
;
; Description:
;
;   Returns all text from the control up to p_Length length.  If p_Length=-1
;   (the default), all text is returned.
;
; Calls To Other Functions:
;
; * <Edit_GetTextLength>
;
; Remarks:
;
;   This function is similar to the AutoHotkey *GUIControlGet* command (for AHK
;   GUIs) and the *ControlGetText* command except that end-of-line (EOL)
;   characters from the retrieved text are not automatically converted
;   (CR+LF to LF).  If needed, use <Edit_Convert2Unix> to convert the text to
;   the AutoHotkey text format.
;
;-------------------------------------------------------------------------------
Edit_GetText(hEdit,p_Length=-1)
    {
    Static WM_GETTEXT:=0xD
    if (p_Length<0)
        p_Length:=Edit_GetTextLength(hEdit)

    VarSetCapacity(l_Text,p_Length*(A_IsUnicode ? 2:1)+1,0)
    SendMessage WM_GETTEXT,p_Length+1,&l_Text,,ahk_id %hEdit%
    Return l_Text
    }


;-----------------------------
;
; Function: Edit_GetTextLength
;
; Description:
;
;   Returns the length, in characters, of the text in the Edit control.
;
;-------------------------------------------------------------------------------
Edit_GetTextLength(hEdit)
    {
    Static WM_GETTEXTLENGTH:=0xE
    SendMessage WM_GETTEXTLENGTH,0,0,,ahk_id %hEdit%
    Return ErrorLevel
    }


;-----------------------------
;
; Function: Edit_GetTextRange
;
; Description:
;
;   Get a range of characters.
;
; Parameters:
;
;   p_Min - Character position index immediately preceding the first character
;       in the range.
;
;   p_Max - Character position immediately following the last character in the
;       range.  Set to -1 to indicate the end of the text.
;
; Calls To Other Functions:
;
; * <Edit_GetText>
;
; Remarks:
;
;   Since the Edit control does not support the EM_GETTEXTRANGE message,
;   <Edit_GetText> (WM_GETTEXT message) is used to collect the desired range of
;   of characters.
;
;-------------------------------------------------------------------------------
Edit_GetTextRange(hEdit,p_Min=0,p_Max=-1)
    {
    Return SubStr(Edit_GetText(hEdit,p_Max),p_Min+1)
    }


;------------------------------
;
; Function: Edit_HasFocus
;
; Description:
;
;   Determines if the Edit control has functional input focus, aka "keyboard
;   focus".
;
; Returns:
;
;   TRUE if the Edit control has functional input focus, otherwise FALSE.
;
; Credit:
;
;   Adapted from an example in the AutoHotkey documentation.
;
;-------------------------------------------------------------------------------
Edit_HasFocus(hEdit)
    {
    Static Dummy7291
          ,GUITHREADINFO

          ;-- Create and initialize GUITHREADINFO structure
          ,cbSize:=(A_PtrSize=8) ? 72:48
          ,Dummy1:=VarSetCapacity(GUITHREADINFO,cbSize)
          ,Dummy2:=NumPut(cbSize,GUITHREADINFO,0,"UInt")

    ;-- Collect GUI Thread Info
    if not DllCall("GetGUIThreadInfo","UInt",0,"Ptr",&GUITHREADINFO)
        {
        outputdebug,
           (ltrim join`s
            Function: %A_ThisFunc% -
            DllCall to "GetGUIThreadInfo" API failed. A_LastError=%A_LastError%
           )

        Return False
        }

    Return (hEdit=NumGet(GUITHREADINFO,(A_PtrSize=8) ? 16:12,"Ptr"))
        ;-- hwndFocus
    }


;------------------------------
;
; Function: Edit_Hide
;
; Description:
;
;   Hides a Edit control.
;
; Returns:
;
;   TRUE if successful, otherwise FALSE.
;
; Remarks:
;
; * For AutoHotkey GUIs, use the *GUIControl* command for improved efficiency.
;   Ex: GUIControl 33:Hide,MyEdit
;
; * This command only hides the control, it does not disable it.  To prevent use
;   of the control's shortcut keys, be sure to disable the control as well.
;
;-------------------------------------------------------------------------------
Edit_Hide(hEdit)
    {
    Control Hide,,,ahk_id %hEdit%
    Return ErrorLevel ? False:True
    }


;------------------------------
;
; Function: Edit_HideAllScrollBars
;
; Description:
;
;   Hides the horizontal and vertical scroll bars on a Edit control.
;
; Returns:
;
;   TRUE if successful, otherwise FALSE.
;
; Calls To Other Functions:
;
; * <Edit_ShowScrollBar>
;
; Remarks:
;
;   See <Edit_ShowScrollBar> for more information.
;
;-------------------------------------------------------------------------------
Edit_HideAllScrollBars(hEdit)
    {
    Static SB_BOTH:=3
    Return Edit_ShowScrollBar(hEdit,SB_BOTH,False)
    }


;-----------------------------
;
; Function: Edit_HideBalloonTip
;
; Description:
;
;   Hides any balloon tip associated with an Edit control.
;
; Returns:
;
;   TRUE if successful, otherwise FALSE.
;
; Remarks:
;
;   This function is usually unnecessary.  A balloon tip will usually auto-hide
;   after short period of time (5 to 15 seconds).  In addition, the balloon tip
;   will auto-hide if the contents of the control are changed or if focus is
;   moved to another control.
;
; Requirements:
;
;   Windows XP+
;
;-------------------------------------------------------------------------------
Edit_HideBalloonTip(hEdit)
    {
    Static EM_HIDEBALLOONTIP:=0x1504
    SendMessage EM_HIDEBALLOONTIP,0,0,,ahk_id %hEdit%
    Return ErrorLevel
    }


;------------------------------
;
; Function: Edit_HideHScrollBar
;
; Description:
;
;   Hides the horizontal scroll bar on a Edit control.
;
; Returns:
;
;   TRUE if successful, otherwise FALSE.
;
; Calls To Other Functions:
;
; * <Edit_ShowScrollBar>
;
; Remarks:
;
;   See <Edit_ShowScrollBar> for more information.
;
;-------------------------------------------------------------------------------
Edit_HideHScrollBar(hEdit)
    {
    Static SB_HORZ:=0
    Return Edit_ShowScrollBar(hEdit,SB_HORZ,False)
    }


;------------------------------
;
; Function: Edit_HideVScrollBar
;
; Description:
;
;   Hides the vertical scroll bar on a Edit control.
;
; Returns:
;
;   TRUE if successful, otherwise FALSE.
;
; Calls To Other Functions:
;
; * <Edit_ShowScrollBar>
;
; Remarks:
;
;   See <Edit_ShowScrollBar> for more information.
;
;-------------------------------------------------------------------------------
Edit_HideVScrollBar(hEdit)
    {
    Static SB_VERT:=1
    Return Edit_ShowScrollBar(hEdit,SB_VERT,False)
    }


;------------------------------
;
; Function: Edit_IsDisabled
;
; Description:
;
;   Returns TRUE if the Edit control is disabled.
;
; Calls To Other Functions:
;
; * <Edit_GetStyle>
;
;-------------------------------------------------------------------------------
Edit_IsDisabled(hEdit)
    {
    Static WS_DISABLED:=0x8000000
    Return Edit_GetStyle(hEdit) & WS_DISABLED ? True:False
    }


;-----------------------------
;
; Function: Edit_IsHScrollBarEnabled
;
; Description:
;
;   Determines if the horizontal scroll bar is enabled.
;
; Returns:
;
;   TRUE if the horizontal scroll bar is enabled, otherwise FALSE.
;
; Calls To Other Functions:
;
; * <Edit_GetScrollBarState>
;
; Observation:
;
; * The return value from this function is unusable (always returns TRUE) if
;   the scroll bar is hidden.  The scroll bar can still be enabled or disabled
;   while the scroll bar is hidden.  There is just no way to determine the
;   current enabled/disabled status while the scroll bar is hidden.
;
;-------------------------------------------------------------------------------
Edit_IsHScrollBarEnabled(hEdit)
    {
    Static OBJID_HSCROLL:=0xFFFFFFFA
          ,STATE_SYSTEM_UNAVAILABLE:=0x1

    Return Edit_GetScrollBarState(hEdit,OBJID_HSCROLL) & STATE_SYSTEM_UNAVAILABLE ? False:True
    }


;-----------------------------
;
; Function: Edit_IsHScrollBarVisible
;
; Description:
;
;   Determines if the horizontal scroll bar is visible.
;
; Returns:
;
;   TRUE if the horizontal scroll bar is visible, otherwise FALSE.
;
; Calls To Other Functions:
;
; * <Edit_GetScrollBarState>
;
;-------------------------------------------------------------------------------
Edit_IsHScrollBarVisible(hEdit)
    {
    Static OBJID_HSCROLL:=0xFFFFFFFA
          ,STATE_SYSTEM_INVISIBLE:=0x8000
          ,STATE_SYSTEM_OFFSCREEN:=0x10000

    Return Edit_GetScrollBarState(hEdit,OBJID_HSCROLL) & (STATE_SYSTEM_INVISIBLE|STATE_SYSTEM_OFFSCREEN) ? False:True
    }


;-----------------------------
;
; Function: Edit_IsMultiline
;
; Description:
;
;   Returns TRUE if the Edit control is multiline, otherwise FALSE.
;
;-------------------------------------------------------------------------------
Edit_IsMultiline(hEdit)
    {
    Static ES_MULTILINE:=0x4
    Return Edit_GetStyle(hEdit) & ES_MULTILINE ? True:False
    }


;-----------------------------
;
; Function: Edit_IsReadOnly
;
; Description:
;
;   Returns TRUE if the ES_READONLY style has been set, otherwise FALSE.
;
;-------------------------------------------------------------------------------
Edit_IsReadOnly(hEdit)
    {
    Static ES_READONLY:=0x800
    Return Edit_GetStyle(hEdit) & ES_READONLY ? True:False
    }


;-----------------------------
;
; Function: Edit_IsStyle
;
; Description:
;
;   Returns TRUE if the specified style has been set, otherwise FALSE.
;
; Parameters:
;
;   p_Style - Style of the Edit control.
;
;   Some common Edit control styles...
;
;   (start code)
;   ES_LEFT       :=0x0         ;-- Can't actually check this style.  It's the absence of ES_CENTER or ES_RIGHT.
;   ES_CENTER     :=0x1
;   ES_RIGHT      :=0x2
;   ES_MULTILINE  :=0x4
;   ES_UPPERCASE  :=0x8
;   ES_LOWERCASE  :=0x10
;   ES_PASSWORD   :=0x20        ;-- Single-line Edit control only
;   ES_AUTOVSCROLL:=0x40
;   ES_AUTOHSCROLL:=0x80
;   ES_NOHIDESEL  :=0x100
;   ES_COMBO      :=0x200
;   ES_OEMCONVERT :=0x400
;   ES_READONLY   :=0x800
;   ES_WANTRETURN :=0x1000
;   ES_NUMBER     :=0x2000
;   WS_TABSTOP    :=0x10000
;   WS_HSCROLL    :=0x100000
;   WS_VSCROLL    :=0x200000
;   (end)
;
;-------------------------------------------------------------------------------
Edit_IsStyle(hEdit,p_Style)
    {
    Return Edit_GetStyle(hEdit) & p_Style ? True:False
    }


;-----------------------------
;
; Function: Edit_IsVScrollBarEnabled
;
; Description:
;
;   Determines if the vertical scroll bar is enabled.
;
; Returns:
;
;   TRUE if the vertical scroll bar is enabled, otherwise FALSE.
;
; Calls To Other Functions:
;
; * <Edit_GetScrollBarState>
;
; Observation:
;
;   The return value from this function is unusable (always returns TRUE) if
;   the scroll bar is hidden.  The scroll bar can still be enabled and/or
;   disabled while the scroll bar is hidden.  There is just no way to determine
;   the current enabled/disabled status while the scroll bar is hidden.
;
;-------------------------------------------------------------------------------
Edit_IsVScrollBarEnabled(hEdit)
    {
    Static OBJID_VSCROLL:=0xFFFFFFFB
          ,STATE_SYSTEM_UNAVAILABLE:=0x1

    Return Edit_GetScrollBarState(hEdit,OBJID_VSCROLL) & STATE_SYSTEM_UNAVAILABLE ? False:True
    }


;-----------------------------
;
; Function: Edit_IsVScrollBarVisible
;
; Description:
;
;   Determines if the vertical scroll bar is visible.
;
; Returns:
;
;   TRUE if the vertical scroll bar is visible, otherwise FALSE.
;
; Calls To Other Functions:
;
; * <Edit_GetScrollBarState>
;
;-------------------------------------------------------------------------------
Edit_IsVScrollBarVisible(hEdit)
    {
    Static OBJID_VSCROLL:=0xFFFFFFFB
          ,STATE_SYSTEM_INVISIBLE:=0x8000
          ,STATE_SYSTEM_OFFSCREEN:=0x10000

    Return Edit_GetScrollBarState(hEdit,OBJID_VSCROLL) & (STATE_SYSTEM_INVISIBLE|STATE_SYSTEM_OFFSCREEN) ? False:True
    }


;-----------------------------
;
; Function: Edit_IsWordWrap
;
; Description:
;
;   Returns TRUE if word wrap is enabled on the Edit control.
;
; Remarks:
;
;   This function may return a false positive, i.e. Word Wrap is enabled, by
;   hiding the horizontal scroll bar after the Edit control has been created.
;   Although this situation is rare, it is a possiblity.  One way to ensure that
;   the function always returns FALSE correctly (i.e. Word Wrap is not enabled)
;   is to always include the ES_AUTOHSCROLL style (0x80 or -Wrap) when the
;   WS_HSCROLL style (0x100000) is also included.
;
;-------------------------------------------------------------------------------
Edit_IsWordWrap(hEdit)
    {
    Static Dummy8256

          ;-- Styles
          ,ES_LEFT       :=0x0
          ,ES_CENTER     :=0x1
          ,ES_RIGHT      :=0x2
          ,ES_MULTILINE  :=0x4
          ,ES_AUTOHSCROLL:=0x80
          ,WS_HSCROLL    :=0x100000

    ;-- Get style
    l_Style:=Edit_GetStyle(hEdit)

    ;---------------------------------------------------------------------------
    ;
    ;   Note: The following tests must be performed in the current order.  All
    ;   tests assume that conditions from previous tests have been met.
    ;
    ;---------------------------------------------------------------------------

    ;-- FALSE if not multiline
    ;   Background: Word wrap is only an option of a multiline Edit control.
    if not (l_Style & ES_MULTILINE)
        Return False

    ;-- TRUE if ES_CENTER or ES_RIGHT style is set.
    ;   Background: ES_AUTOHSCROLL is ignored by a multiline Edit control that
    ;   is not left-aligned.  Centered and right-aligned multiline Edit controls
    ;   cannot be horizontally scrolled.
    if l_Style & (ES_CENTER|ES_RIGHT)
        Return True

    ;-- FALSE if ES_AUTOHSCROLL style is set
    if l_Style & ES_AUTOHSCROLL
        Return False

    ;-- FALSE if WS_HSCROLL style
    ;   Background: ES_AUTOHSCROLL is automatically applied to a left-aligned,
    ;   multiline Edit control that has a WS_HSCROLL style.
    if l_Style & WS_HSCROLL
        Return False

    ;-- Otherwise, TRUE
    Return True
    }


;-----------------------------
;
; Function: Edit_LineFromChar
;
; Description:
;
;   Gets the index of the line that contains the specified character index.
;
; Parameters:
;
;   p_CharPos - The character index of the character contained in the line
;       whose number is to be retrieved. [Optional] If –1 (the default), the
;       function retrieves either the line number of the current line (the line
;       containing the caret) or, if there is a selection, the line number of
;       the line containing the beginning of the selection.
;
; Returns:
;
;   The zero-based line number of the line containing the character index
;   specified by p_CharPos.
;
;-------------------------------------------------------------------------------
Edit_LineFromChar(hEdit,p_CharPos=-1)
    {
    Static EM_LINEFROMCHAR:=0xC9
    SendMessage EM_LINEFROMCHAR,p_CharPos,0,,ahk_id %hEdit%
    Return ErrorLevel
    }


;-----------------------------
;
; Function: Edit_LineFromPos
;
; Description:
;
;   This function is the same as <Edit_CharFromPos> except the line index
;   (r_LineIdx) is returned.
;
;-------------------------------------------------------------------------------
Edit_LineFromPos(hEdit,X,Y,ByRef r_CharPos="",ByRef r_LineIdx="")
    {
    Edit_CharFromPos(hEdit,X,Y,r_CharPos,r_LineIdx)
    Return r_LineIdx
    }


;-----------------------------
;
; Function: Edit_LineIndex
;
; Description:
;
;   Gets the character index of the first character of a specified line.
;
; Parameters:
;
;   p_LineIdx - Zero-based line number. [Optional] Use -1 (the default) for the
;       current line.
;
; Returns:
;
;   The character index of the specified line or -1 if the specified line is
;   greater than the total number of lines in the Edit control.
;
;-------------------------------------------------------------------------------
Edit_LineIndex(hEdit,p_LineIdx=-1)
    {
    Static EM_LINEINDEX:=0xBB
    SendMessage EM_LINEINDEX,p_LineIdx,0,,ahk_id %hEdit%
    Return ErrorLevel<<32>>32  ;-- Convert UInt to Int
    }


;-----------------------------
;
; Function: Edit_LineLength
;
; Description:
;
;   Gets the length of a line.
;
; Parameters:
;
;   p_LineIdx - The zero-based line index of the desired line.  Use -1
;       (the default) for the current line.
;
; Returns:
;
;   The length, in characters, of the specified line.  If p_LineIndex is greater
;   than the total number of lines in the Edit control, the length of the last
;   (or only) line is returned.
;
; Calls To Other Functions:
;
; * <Edit_GetTextLength>
; * <Edit_LineIndex>
;
;-------------------------------------------------------------------------------
Edit_LineLength(hEdit,p_LineIdx=-1)
    {
    Static EM_LINELENGTH:=0xC1
    l_CharPos:=Edit_LineIndex(hEdit,p_LineIdx)
    if (l_CharPos<0)  ;-- Invalid p_LineIdx
        l_CharPos:=Edit_LineIndex(hEdit,Edit_GetTextLength(hEdit)-1)

    SendMessage EM_LINELENGTH,l_CharPos,0,,ahk_id %hEdit%
    Return ErrorLevel
    }


;-----------------------------
;
; Function: Edit_LineScroll
;
; Description:
;
;   Scrolls the text vertically or horizontally in a multiline Edit control.
;
; Parameters:
;
;   xScroll, yScroll - The number of characters to scroll horizontally (xScroll)
;       or vertically (yScroll).  Use a negative number to scroll to the left
;       (xScroll) or up (yScroll) and a positive number to scroll to the right
;       (xScroll) or to scroll down (yScroll).  Alternatively, these parameters
;       can contain one or more of the following values:
;
;       (start code)
;       Option  Description
;       ------   -----------
;       Left    Scroll to the left edge of the control.
;       Right   Scroll to the right edge of the control.
;       Top     Scroll to the top of the control.
;       Bottom  Scroll to the bottom of the control.
;
;       If more than one option is specified, the options must be delimited by a
;       space.  Ex: "Top Left".  See the *Remarks* section for more information.
;       (end)
;       
; Remarks:
;
;   The xScroll parameter is processed first and then yScroll.  If either of
;   these parameters contains multiple values (Ex: "Top Left"), the values are
;   processed individually from left to right.  If there are conflicting values
;   (Ex: "Top Bottom"), the last value specified will take precedence.
;
;-------------------------------------------------------------------------------
Edit_LineScroll(hEdit,xScroll=0,yScroll=0)
    {
    Static Dummy3496

          ;-- Horizontal scroll values
          ,SB_LEFT :=6
          ,SB_RIGHT:=7

          ;-- Vertical scroll values
          ,SB_TOP   :=6
          ,SB_BOTTOM:=7

          ;-- Messages
          ,EM_LINESCROLL:=0xB6
          ,WM_HSCROLL   :=0x114
          ,WM_VSCROLL   :=0x115

    if xScroll is Integer
        {
        if xScroll  ;-- Any value other than 0
            SendMessage EM_LINESCROLL,xScroll,0,,ahk_id %hEdit%
        }
     else
        Loop Parse,xScroll,%A_Space%
            {
            if InStr(A_LoopField,"Left")
                SendMessage WM_HSCROLL,SB_LEFT,0,,ahk_id %hEdit%
             else if InStr(A_LoopField,"Right")
                SendMessage WM_HSCROLL,SB_RIGHT,0,,ahk_id %hEdit%
             else if InStr(A_LoopField,"Top")
                SendMessage WM_VSCROLL,SB_TOP,0,,ahk_id %hEdit%
             else if InStr(A_LoopField,"Bottom")
                SendMessage WM_VSCROLL,SB_BOTTOM,0,,ahk_id %hEdit%
            }

    if yScroll is Integer
        {
        if yScroll  ;-- Any value other than 0
            SendMessage EM_LINESCROLL,0,yScroll,,ahk_id %hEdit%
        }
     else
        Loop Parse,yScroll,%A_Space%
            {
            if InStr(A_LoopField,"Left")
                SendMessage WM_HSCROLL,SB_LEFT,0,,ahk_id %hEdit%
             else if InStr(A_LoopField,"Right")
                SendMessage WM_HSCROLL,SB_RIGHT,0,,ahk_id %hEdit%
             else if InStr(A_LoopField,"Top")
                SendMessage WM_VSCROLL,SB_TOP,0,,ahk_id %hEdit%
             else if InStr(A_LoopField,"Bottom")
                SendMessage WM_VSCROLL,SB_BOTTOM,0,,ahk_id %hEdit%
            }
    }


;-----------------------------
;
; Function: Edit_LoadFile
;
; Description:
;
;   Calls <Edit_ReadFile> to load the contents of a file to the Edit control.
;   See <Edit_ReadFile> for the requirements.
;
; Returns:
;
;   TRUE if successful, otherwise FALSE.
;
; Remarks:
;
;   This function is deprecated.  Use <Edit_ReadFile> instead.
;
;-------------------------------------------------------------------------------
Edit_LoadFile(hEdit,p_File,p_Convert2DOS=False,ByRef r_EOLFormat="")
    {
    RC:=Edit_ReadFile(hEdit,p_File,A_FileEncoding,p_Convert2DOS,r_EOLFormat)
    Return (RC>-1) ? True:False
    }


;------------------------------
;
; Function: Edit_MouseInSelection
;
; Description:
;
;   Determines if the mouse is somewhere within selected text of a specified
;   Edit control.
;
; Returns:
;
;   Returns TRUE if the mouse is somewhere within selected text of the edit
;   control, otherwise FALSE.
;
; Calls To Other Functions:
;
; * <Edit_CharFromPos>
; * <Edit_GetSel>
;
;-------------------------------------------------------------------------------
Edit_MouseInSelection(hEdit)
    {
    ;-- FALSE if nothing is selected
    Edit_GetSel(hEdit,l_StartSelPos,l_EndSelPos)
    if (l_StartSelPos=l_EndSelPos)
        Return False

    ;-- Initialize
    VarSetCapacity(POINT,8,0)

    ;-- Collect the cursor position and convert to coordinates relative to the
    ;   Edit control.  Note: This method is used instead of collecting the
    ;   position from the MouseGetPos command because the current coordinate
    ;   mode does not have to be considered.
    DllCall("GetCursorPos","Ptr",&POINT)
    DllCall("ScreenToClient","Ptr",hEdit,"Ptr",&POINT)

    ;-- Collect the character position of the mouse
    l_CharPos:=Edit_CharFromPos(hEdit,NumGet(POINT,0,"Int"),NumGet(POINT,4,"Int"))

    ;-- Determine if the mouse is somewhere within the selection
    Return (l_CharPos>=l_StartSelPos and l_CharPos<=l_EndSelPos) ? True:False
    }


;-----------------------------
;
; Function: Edit_Paste
;
; Description:
;
;   Copies the current content of the clipboard to the Edit control at the
;   current caret position.  Data is inserted only if the clipboard contains
;   data in CF_TEXT format.
;
;-------------------------------------------------------------------------------
Edit_Paste(hEdit)
    {
    Static WM_PASTE:=0x302
    SendMessage WM_PASTE,0,0,,ahk_id %hEdit%
    }


;-----------------------------
;
; Function: Edit_PosFromChar
;
; Description:
;
;   Gets the client area coordinates of a specified character in the edit
;   control.
;
; Parameters:
;
;   p_CharPos - The zero-based index of the character.
;
;   X, Y - Output variables.  [Optional] These variables are used to return the
;       x/y-coordinates of a point in the Edit control's client relative to the
;       upper-left corner of the client area.
;
; Returns:
;
;   Address to a POINT structure.
;
; Remarks:
;
;   If p_CharPos is greater than the index of the last character in the
;   control, the returned coordinates are of the position just past the last
;   character of the control.
;
;-------------------------------------------------------------------------------
Edit_PosFromChar(hEdit,p_CharPos,ByRef X="",ByRef Y="")
    {
    Static Dummy5026
          ,POINT

          ;-- Message
          ,EM_POSFROMCHAR:=0xD6

    ;-- Inialize
    VarSetCapacity(POINT,8,0)

    ;-- Collect information and populate POINT structure
    SendMessage EM_POSFROMCHAR,p_CharPos,0,,ahk_id %hEdit%
    NumPut(X:=(ErrorLevel&0xFFFF)<<48>>48,POINT,0,"Int")
        ;-- LOWORD of result and converted from UShort to Short
    NumPut(Y:=(ErrorLevel>>16)<<48>>48,POINT,0,"Int")
        ;-- HIWORD of result and converted from UShort to Short
    Return &POINT
    }


;-----------------------------
;
; Function: Edit_ReadFile
;
; Description:
;
;   Reads the contents of a file into the Edit control.
;
; Parameters:
;
;   p_File - The path of the file.
;
;   p_Encoding - The code page to use if the file does not contain a UTF-8 or
;       UTF-16 byte order mark. [Optional] If omitted or set to null (the
;       default), the current value of A_FileEncoding is used.  Set to "CP0" to
;       force the program to use the system default ANSI code page.
;
;   p_Convert2DOS - If set TRUE, the text will be converted from Unix, DOS/Unix
;       mix, or Mac format, to DOS format before it is loaded to the edit
;       control. [Optional]
;
;   r_EOLFormat - Contains the end-of-line (EOL) format variable. [Optional]
;       This variable is set to the EOL format of the loaded file which will be
;       "DOS", "Unix", or "Mac". This information is useful if the contents of
;       the Edit control will be be converted back to the original EOL format
;       when the file is saved.
;
; Returns:
;
;   The number of characters loaded to Edit control (can be 0) if successful,
;   otherwise -1 if the file could not be found, -2 if the file could not be
;   opened, or -3 if the text could not be loaded to the Edit control (very
;   rare).
;
; Calls To Other Functions:
;
; * <Edit_Convert2DOS>
; * <Edit_SetText>
; * <Edit_SystemMessage>
;
; Convert To DOS:
;
;   For text computing, a new line, also known as end of line (EOL) or
;   line break, is a special character or sequence of characters signifying the
;   end of a line of text and the start of a new line.  Internally, the Edit
;   control only supports the DOS EOL format which consists of a carriage return
;   and line feed (CR+LF) characters.  If a file is not already in the the DOS
;   format, the text will not display correctly when it loaded to the Edit
;   control _unless_ it is first converted to the DOS format.
;
;   If the p_Convert2DOS parameter is set to TRUE, the text read from the file
;   is converted into the DOS format before the text is loaded to the
;   Edit control.  This will ensure that the text is the correct format for
;   the Edit control.  This conversion is essential if the file is in a Unix
;   (EOL=LF) or Mac (EOL=CR) format but it can also be beneficial if the file
;   is in a DOS/Unix mix where the DOS and Unix new line sequences are both
;   used.
;
;   Conversion requires additional processing.  The extra processing is not
;   noticeable for small files, barely noticeable for medium-sized files, but
;   may be very noticeable for large and very-large text files.  When conversion
;   is performed on a large text file, performance can be significantly improved
;   by setting *SetBatchLines* to a high value before calling this function.
;   For example:
;
;       (start code)
;       SetBatchLines 100ms  ;-- Large bump in priority
;       RC:=Edit_ReadFile(hEdit,...)
;       SetBatchLines 10ms   ;-- Default priority
;       (end)
;
;   Note: The Mac EOL format (CR) is only used on Mac OS version 9 and earlier.
;   Mac OS 10+ uses the Unix (LF) format.
;
; Encoding:
;
;   When reading a text file using AutoHotkey's standard file commands
;   (FileRead, FileReadLine, the Read method of AutoHotkey's File object, etc.),
;   the file's byte order mark (BOM), if it exists, takes precedence over
;   whatever encoding the developer may specify, if anything.  However, if the
;   file has been encoding in some non-ANSI way and file does not contain a byte
;   order mark (BOM), the file will not decoded correctly.  This is mentioned
;   because many common programs/utilities will automatically detect and decode
;   a text file without a BOM, especially if the file contains UTF-8 characters.
;   AutoHotkey file commands do not include a mechanism to automatically
;   identify and decode a non-ANSI file so specifying the correct encoding
;   whether the file has a BOM or not is good practice.
;
; Remarks:
;
;   This request will replace the entire Edit control with the contents of the
;   the specified file.  Consequently, the Undo buffer is flushed.
;
;   If the p_Convert2DOS paramter is set to TRUE, the number of characters
;   loaded to the Edit control can be different that the number characters read
;   from the file.
;
;   If this function fails, i.e. returns a negative value, a developer-friendly
;   message is dumped to the debugger.  Use a debugger or debug viewer to see
;   the message.
;
;-------------------------------------------------------------------------------
Edit_ReadFile(hEdit,p_File,p_Encoding="",p_Convert2DOS=False,ByRef r_EOLFormat="")
    {
    ;-- File exists?
    IfNotExist %p_File%
        {
        outputdebug Function: %A_ThiSFunc% - File "%p_File%" not found.
        Return -1
        }

    ;-- Open for read
    if not File:=FileOpen(p_File,"r",StrLen(p_Encoding) ? p_Encoding:A_FileEncoding)
        {
        l_Message:=Edit_SystemMessage(A_LastError)
        outputdebug,
           (ltrim join`s
            Function: %A_ThisFunc% -
            Unexpected return code from FileOpen function.
            A_LastError=%A_LastError% - %l_Message%
           )

        Return -2
        }

    ;-- Read the contents of the file into a variable
    l_Text:=File.Read()
    File.Close()

    ;-- Determine EOL format
    if l_Text Contains `r`n
        r_EOLFormat:="DOS"
     else
        if l_Text Contains `n
            r_EOLFormat:="UNIX"
         else
            if l_Text Contains `r
                r_EOLFormat:="MAC"
             else
                r_EOLFormat:="DOS"

    ;-- Convert EOL format?
    if p_Convert2DOS
        l_Text:=Edit_Convert2DOS(l_Text)

    ;-- Load text to the Edit control
    if not Edit_SetText(hEdit,l_Text)
        {
        outputdebug,
           (ltrim join`s
            Function: %A_ThisFunc% -
            Unable to load text to the Edit control
           )

        Return -3
        }

    ;-- Return to sender
    Return StrLen(l_Text)
    }


;-----------------------------
;
; Function: Edit_ReplaceSel
;
; Description:
;
;   Replaces the selected text with the specified text.  If there is no
;   selection, the replacement text is inserted at the caret.
;
; Parameters:
;
;   p_Text - Text to replace selection with.
;   p_CanUndo - If TRUE (the default), replace can be undone.
;
;-------------------------------------------------------------------------------
Edit_ReplaceSel(hEdit,p_Text="",p_CanUndo=True)
    {
    Static EM_REPLACESEL:=0xC2
    SendMessage EM_REPLACESEL,p_CanUndo,&p_Text,,ahk_id %hEdit%
    }


;-----------------------------
;
; Function: Edit_SaveFile
;
; Description:
;
;   Calls <Edit_WriteFile> to save the contents of the Edit control to a file.
;   See <Edit_WriteFile> for the requirements.
;
; Returns:
;
;   TRUE if successful, otherwise FALSE.
;
; Remarks:
;
;   [v2.0+] In previous versions of the library, this function created a new
;   file in all situations, deleting the old file first if needed.  This
;   function now calls <Edit_WriteFile> which will overwrite the file if it
;   already exist.
;
;   This function is deprecated.  Use <Edit_WriteFile> instead.
;
;-------------------------------------------------------------------------------
Edit_SaveFile(hEdit,p_File,p_Convert="")
    {
    RC:=Edit_WriteFile(hEdit,p_File,A_FileEncoding,p_Convert)
    Return (RC>-1) ? True:False
    }


;-----------------------------
;
; Function: Edit_SelectAll
;
; Description:
;
;   Selects all characters in an Edit control.
;
;-------------------------------------------------------------------------------
Edit_SelectAll(hEdit)
    {
    Static EM_SETSEL:=0x0B1
    SendMessage EM_SETSEL,0,-1,,ahk_id %hEdit%
    }


;-----------------------------
;
; Function: Edit_Scroll
;
; Description:
;
;   Scrolls the text vertically in a multiline Edit control.
;
; Parameters:
;
;   p_Pages - The number of pages to scroll.  Use a negative number to page up
;       and a positive number to page down.
;
;   p_Lines - The number of lines to scroll.  Use a negative number to scroll up
;       and a positive number to scroll down.
;
; Returns:
;
;   The number of lines that the command scrolls.  The value will be negative if
;   scrolling up, positive if scrolling down, and zero (0) if no scrolling
;   occurred.
;
;-------------------------------------------------------------------------------
Edit_Scroll(hEdit,p_Pages=0,p_Lines=0)
    {
    Static EM_SCROLL  :=0xB5
          ,SB_LINEUP  :=0x0     ;-- Scroll up one line
          ,SB_LINEDOWN:=0x1     ;-- Scroll down one line
          ,SB_PAGEUP  :=0x2     ;-- Scroll up one page
          ,SB_PAGEDOWN:=0x3     ;-- Scroll down one page

    ;-- Initialize
    l_ScrollLines:=0

    ;-- Pages
    Loop % Abs(p_Pages)
        {
        SendMessage EM_SCROLL,(p_Pages>0) ? SB_PAGEDOWN:SB_PAGEUP,0,,ahk_id %hEdit%
        if not ErrorLevel
            Break

        l_ScrollLines+=((ErrorLevel&0xFFFF)<<48>>48)
            ;-- LOWORD of result and converted from UShort to Short
        }

    ;-- Lines
    Loop % Abs(p_Lines)
        {
        SendMessage EM_SCROLL,(p_Lines>0) ? SB_LINEDOWN:SB_LINEUP,0,,ahk_id %hEdit%
        if not ErrorLevel
            Break

        l_ScrollLines+=((ErrorLevel&0xFFFF)<<48>>48)
            ;-- LOWORD of result and converted from UShort to Short
        }

    Return l_ScrollLines
    }


;-----------------------------
;
; Function: Edit_ScrollCaret
;
; Description:
;
;   Scrolls the caret into view in an Edit control.
;
;-------------------------------------------------------------------------------
Edit_ScrollCaret(hEdit)
    {
    Static EM_SCROLLCARET:=0xB7
    SendMessage EM_SCROLLCARET,0,0,,ahk_id %hEdit%
    }


;-----------------------------
;
; Function: Edit_ScrollPage
;
; Description:
;
;   Scrolls the Edit control by page.
;
; Parameters:
;
;   p_HPages - The number of horizontal pages to scroll.  Use a postive number
;       to page right and a negative number to page left.
;
;   p_VPages - The number of vertical pages to scroll. [Optional] Use a positive
;       number to page down and a negative number to page up.
;
; Remarks:
;
;   This function duplicates some of the functionality of <Edit_Scroll>.  If
;   scrolling vertically and the return value is needed, use the *Edit_Scroll*
;   function instead.
;
;------------------------------------------------------------------------------
Edit_ScrollPage(hEdit,p_HPages=0,p_VPages=0)
    {
    Static Dummy3535

          ;-- Horizontal scroll values
          ,SB_PAGELEFT :=2
          ,SB_PAGERIGHT:=3

          ;-- Vertical scroll values
          ,SB_PAGEUP  :=2
          ,SB_PAGEDOWN:=3

          ;-- Messages
          ,WM_HSCROLL :=0x114
          ,WM_VSCROLL :=0x115

    ;-- Horizontal
    Loop % Abs(p_HPages)
        SendMessage WM_HSCROLL,(p_HPages>0) ? SB_PAGERIGHT:SB_PAGELEFT,0,,ahk_id %hEdit%

    ;-- Vertical
    Loop % Abs(p_VPages)
        SendMessage WM_VSCROLL,(p_VPages>0) ? SB_PAGEDOWN:SB_PAGEUP,0,,ahk_id %hEdit%
    }


;-----------------------------
;
; Function: Edit_SetCueBanner
;
; Description:
;
;   Sets the textual cue, or tip, that is displayed by the Edit control to
;   prompt the user for information.
;
; Parameters:
;
;   p_Text - Cue banner text.
;
;   p_ShowWhenFocused - [Vista+] Set to TRUE to show the cue banner even if the
;       Edit control has focus.  The default is FALSE (don't show when the edit
;       control has focus).
;
; Returns:
;
;   TRUE if successful, otherwise FALSE.
;
; Remarks:
;
;   Single-line Edit control only.
;
; Requirements:
;
;   Windows XP+
;
;-------------------------------------------------------------------------------
Edit_SetCueBanner(hEdit,p_Text,p_ShowWhenFocused=False)
    {
    Static EM_SETCUEBANNER:=0x1501  ;-- ECM_FIRST+1

    ;-- Initialize
    wText:=p_Text  ;-- Working and Unicode copy

    ;-- Convert to Unicode if needed
    if !A_IsUnicode and StrLen(p_Text)
        {
        VarSetCapacity(wText,StrLen(p_Text)*2,0)
        StrPut(p_Text,&wText,"UTF-16")
        }

    ;-- Set cue banner
    SendMessage EM_SETCUEBANNER,p_ShowWhenFocused,&wText,,ahk_id %hEdit%
    Return ErrorLevel
    }


;-----------------------------
;
; Function: Edit_SetFocus
;
; Description:
;
;   Sets input focus to the specified Edit control.
;
; Parameters:
;
;   p_ActivateParent - If TRUE, the function will call <Edit_ActivateParent>
;       which will activate the parenet window if it is not already active.  The
;       default is FALSE.
;
; Returns:
;
;   TRUE if successful, or FALSE otherwise.
;
; Calls To Other Functions:
;
; * <Edit_ActivateParent>
; * <Edit_HasFocus>
;
; Remarks:
;
; * Functional input focus, aka "keyboard focus", can only be achieved if the
;   control has focus AND the parent window is active (foremost).  If requested,
;   this function will activate the parent window if is not already active.
;
; * For AutoHotkey GUIs, use the *GUIControl* command for improved efficiency.
;   Ex: GUIControl 32:Focus,MyEdit
;
; * This function uses the AutoHotKey *ControlFocus* command.  See the AHK
;   documentation for additional restrictions (Ex: SetControlDelay).
;
; * This function can be used to set focus on any control.  Just specify the
;   handle to the desired control as the first parameter.
;   Ex: Edit_SetFocus(hLV) where "hLV" is the handle to a ListView control.
;
;-------------------------------------------------------------------------------
Edit_SetFocus(hEdit,p_ActivateParent=False)
    {
    ;-- If requested, activate parent
    if p_ActivateParent
        if not Edit_ActivateParent(hEdit)
            Return False

    ;-- Does the control already have focus?
    if Edit_HasFocus(hEdit)
        Return True

    ;-- Set focus
    ControlFocus,,ahk_id %hEdit%
    Return ErrorLevel ? False:True
    }


;------------------------------
;
; Function: Edit_SetFont
;
; Description:
;
;   Sets the font that the Edit control is to use when drawing text.
;
; Parameters:
;
;   hEdit - Handle to the Edit control.
;
;   hFont - Handle to the font (HFONT).  Set to 0 to use the default system
;       font.
;
;   p_Redraw - Specifies whether the control should be redrawn immediately upon
;       setting the font.  If set to TRUE, the control redraws itself.
;
; Remarks:
;
; * This function can be used to set the font on any control.  Just specify
;   the handle to the desired control as the first parameter.
;   Ex: Edit_SetFont(hLV,hFont) where "hLV" is the handle to ListView control.
;
; * The size of the control does not change as a result of receiving this
;   message.  To avoid clipping text that does not fit within the boundaries of
;   the control, the program should set/correct the size of the control before
;   the font is set.
;
;-------------------------------------------------------------------------------
Edit_SetFont(hEdit,hFont,p_Redraw=False)
    {
    Static WM_SETFONT:=0x30
    SendMessage WM_SETFONT,hFont,p_Redraw,,ahk_id %hEdit%
    }


;-----------------------------
;
; Function: Edit_SetLimitText
;
; Description:
;
;   Sets the text limit of the Edit control.
;
; Parameters:
;
;   p_Limit - The maximum number of characters the user can enter.
;       Windows NT+: If this parameter is zero, the text length is set to
;       0x7FFFFFFE (2,147,483,646) characters for single-line Edit controls and
;       0xFFFFFFFF (4,294,967,295) for multiline Edit controls.
;
; Remarks:
;
; * This message limits only the text the user can enter.  It does not affect
;   any text already in the Edit control when the message is sent, nor does it
;   affect the length of the text copied to the Edit control by the WM_SETTEXT
;   message.  For more information:
;
;       <http://msdn.microsoft.com/en-us/library/bb761607(VS.85).aspx>
;
; * For AutoHotkey GUI's, use the +Limitnn and -Limit options.
;
; * Warning: Although this message can be sent to any Edit control, not all
;   programs will respond well to a limit change.
;
;-------------------------------------------------------------------------------
Edit_SetLimitText(hEdit,p_Limit)
    {
    Static EM_LIMITTEXT:=0xC5
    SendMessage EM_LIMITTEXT,p_Limit,0,,ahk_id %hEdit%
    }


;-----------------------------
;
; Function: Edit_SetMargins
;
; Description:
;
;   Sets the width of the left and/or right margin, in pixels, for the edit
;   control.  The message automatically redraws the control to reflect the new
;   margins.
;
; Parameters:
;
;   p_LeftMargin - Left margin, in pixels.  If blank/null, the left margin is
;       not set.  Specify the EC_USEFONTINFO value (0xFFFF or 65535) to set the
;       left margin to a narrow width calculated using the text metrics of the
;       control's current font.
;
;   p_RightMargin - Right margin, in pixels.  If blank/null, the right margin is
;       not set.  Specify the EC_USEFONTINFO value (0xFFFF or 65535) to set the
;       right margin to a narrow width calculated using the text metrics of the
;       control's current font.
;
; Observations:
;
;   The documentation states that the EM_SETMARGINS message automatically
;   redraws the control to reflect the new margins.  However, only the left
;   margin is set correctly if the control contains text.  The only way to get
;   the right margin to show correctly is to reload the text to the control.
;   This is messy becase all selected data and the modify status of the Edit
;   control is lost when then data is reloaded to the control.  If possible, set
;   the margins before text is loaded to the control.  If this is not possible,
;   see the "Set Margins" example script for one way to work around the problem.
;
;   For the EM_SETMARGINS message, the Edit control does not appear to be DPI
;   aware.  The control assumes that the screen always has 96 pixels per inch,
;   i.e. 96 DPI.  This makes conversion from inches to pixel easy.  Simply
;   multiply inches by 96 to get the number of pixels.  Ex: 0.5 inches * 96 =
;   48 pixels.
;
;-------------------------------------------------------------------------------
Edit_SetMargins(hEdit,p_LeftMargin="",p_RightMargin="")
    {
    Static EM_SETMARGINS :=0xD3
          ,EC_LEFTMARGIN :=0x1
          ,EC_RIGHTMARGIN:=0x2
          ,EC_USEFONTINFO:=0xFFFF

    l_Flags  :=0
    l_Margins:=0
    if p_LeftMargin is Integer
        {
        l_Flags  |=EC_LEFTMARGIN
        l_Margins|=p_LeftMargin       ;-- LOWORD
        }

    if p_RightMargin is Integer
        {
        l_Flags  |=EC_RIGHTMARGIN
        l_Margins|=p_RightMargin<<16  ;-- HIWORD
        }

    if l_Flags
        SendMessage EM_SETMARGINS,l_Flags,l_Margins,,ahk_id %hEdit%
    }


;-----------------------------
;
; Function: Edit_SetModify
;
; Description:
;
;   Sets or clears the modification flag for the Edit control.  The modification
;   flag indicates whether the text within the control has been modified.
;
; Parameters:
;
;   p_Flag - Set to TRUE to set the modification flag.  Set to FALSE to clear
;       the modification flag.
;
;-------------------------------------------------------------------------------
Edit_SetModify(hEdit,p_Flag)
    {
    Static EM_SETMODIFY:=0xB9
    SendMessage EM_SETMODIFY,p_Flag,0,,ahk_id %hEdit%
    }


;-----------------------------
;
; Function: Edit_SetPasswordChar
;
; Description:
;
;   Sets or removes the password character for a single-line Edit control.
;
; Parameters:
;
;   p_CharValue - The decimal value of the character that is displayed in place
;       of the characters typed by the user. [Optional] The default is an 9679
;       (black circle).  Set to 0 (null) to remove the password character.
;
; Returns:
;
;   Documented: This message does not return a value.  Undocumented and/or does
;   not apply to all OS versions: Returns TRUE if successful or "FAIL" if
;   unsuccessful.
;
; Remarks:
;
; * The code for this function extracted from:
;   http://www.autohotkey.com/forum/viewtopic.php?p=392973#392973
;   Author: Unknown
;
; * Use <Edit_IsStyle> to determine if the ES_PASSWORD style has been set.
;
; Observations:
;
; * On Windows 2000+, the ES_Password style cannot be removed once added unless
;   the request is made from the same process that created the control.
;
; * This style is not supposed to work on multiline Edit control but it appears
;   work on more recent versions of Windows (tested on Windows 7) _if_ the style
;   is added after the Edit control is created.  Probably should still assume
;   that the style is only good for single-line Edit controls.
;
;-------------------------------------------------------------------------------
Edit_SetPasswordChar(hEdit,p_CharValue=9679)
    {
    Static EM_SETPASSWORDCHAR:=0xCC
    RC:=DllCall("SendMessageW","Ptr",hEdit,"UInt",EM_SETPASSWORDCHAR,"UInt",p_CharValue,"UInt",0)
    WinSet Redraw,,ahk_id %hEdit%  ;-- Force style change to show
    Return RC
    }


;-----------------------------
;
; Function: Edit_SetReadOnly
;
; Description:
;
;   Sets or removes the read-only style (ES_READONLY) of the Edit control.
;
; Parameters:
;
;   p_Flag - Set to TRUE to add the ES_READONLY style.  Set to FALSE to remove
;       the ES_READONLY style.
;
; Returns:
;
;   TRUE if successful, otherwise FALSE.
;
; Remarks:
;
;   For AutoHotkey GUIs, this is same as using the +ReadOnly or -ReadOnly
;   option when creating the Edit control or using the GUIControl command after
;   the Edit control has been created.  Ex: GUIControl +ReadOnly,Edit1
;
;-------------------------------------------------------------------------------
Edit_SetReadOnly(hEdit,p_Flag)
    {
    Static EM_SETREADONLY:=0xCF
    SendMessage EM_SETREADONLY,p_Flag,0,,ahk_id %hEdit%
    Return ErrorLevel ? True:False
    }


;-----------------------------
;
; Function: Edit_SetRect
;
; Description:
;
;   Sets the formatting rectangle of a multiline Edit control.  The formatting
;   rectangle is the limiting rectangle into which the control draws the text.
;   The limiting rectangle is independent of the size of the Edit control
;   window.
;
; Parameters:
;
;   p_Left..p_Bottom - Rectangle coordinates.
;
; Remarks:
;
;   Advanced feature.  For additional information, see the following...
;
;       <http://msdn.microsoft.com/en-us/library/bb761657(VS.85).aspx>
;
;-------------------------------------------------------------------------------
Edit_SetRect(hEdit,p_Left,p_Top,p_Right,p_Bottom)
    {
    Static EM_SETRECT:=0xB3
    VarSetCapacity(RECT,16,0)
    NumPut(p_Left,  RECT,0,"Int")
    NumPut(p_Top,   RECT,4,"Int")
    NumPut(p_Right, RECT,8,"Int")
    NumPut(p_Bottom,RECT,12,"Int")
    SendMessage EM_SETRECT,0,&RECT,,ahk_id %hEdit%
    }


;-----------------------------
;
; Function: Edit_SetTabStops
;
; Description:
;
;   Sets the tab stops in a multiline Edit control.  When text is copied to the
;   control, any tab character in the text causes space to be generated up to
;   the next tab stop.
;
; Parameters:
;
;   p_NbrOfTabStops - Number of tab stops. [Optional] Set to 0 (the default) to
;       set the tab stops to the system default.  Set to 1 to have all tab stops
;       set to the value of the p_DTU parameter or 32 if the p_DTU parameter is
;       not specified.  Any value greater than 1 will set that number of tab
;       stops.
;
;   p_DTU - Dialog Template Units. [Optional] This parameter can contain a
;       single value (Ex: 32), a comma-delimited list of values (Ex:
;       "29,72,122,174") or an AutoHotkey object with an array of values (Ex:
;       [150,180,205,255].  If p_NbrOfTabStops=0, this parameter is ignored.  If
;       this parameter contains a single value (Ex: 30), all tab stops will be
;       set to a factor of that value (Ex: 30, 60, 90, etc.).  Otherwise, this
;       parameter should contain values for all requested tab stops.
;
; Returns:
;
;   TRUE if all the tabs are set, otherwise FALSE.
;
;-------------------------------------------------------------------------------
Edit_SetTabStops(hEdit,p_NbrOfTabStops=0,p_DTU=32)
    {
    Static EM_SETTABSTOPS:=0xCB
    VarSetCapacity(l_TabStops,p_NbrOfTabStops*4,0)
    if IsObject(p_DTU)
        {
        l_NbrOfElements:=0  ;-- Not assuming correctly formed simple array
        For l_Key,l_Value in p_DTU
            {
            l_NbrOfElements++
            if (A_Index<=p_NbrOfTabStops)
                NumPut(l_Value+0,l_TabStops,(A_Index-1)*4,"UInt")
            }

        if (l_NbrOfElements=1 and p_NbrOfTabStops>1)
            Loop %p_NbrOfTabStops%
                NumPut(l_Value*A_Index,l_TabStops,(A_Index-1)*4,"UInt")
        }
     else
        if p_DTU Contains ,,
            {
            Loop Parse,p_DTU,`,,%A_Space%
                if (A_Index<=p_NbrOfTabStops)
                    NumPut(A_LoopField+0,l_TabStops,(A_Index-1)*4,"UInt")
            }
         else
            Loop %p_NbrOfTabStops%
                NumPut(p_DTU*A_Index,l_TabStops,(A_Index-1)*4,"UInt")

    SendMessage EM_SETTABSTOPS,p_NbrOfTabStops,&l_TabStops,,ahk_id %hEdit%
    Return ErrorLevel
    }


;-----------------------------
;
; Function: Edit_SetText
;
; Description:
;
;   Set the text of the Edit control.
;
; Parameters:
;
;   p_Text - Text to set the Edit control.
;
;   p_SetModify - If set to TRUE, the modification flag is set after the text is
;       set.  If FALSE (the default), the modification flag is not set (remains
;       cleared) after the text is set.
;
; Returns:
;
;   TRUE if successful, otherwise FALSE.
;
; Remarks:
;
; * The system automatically clears the modification flag whenever an edit
;   control receives a WM_SETTEXT message.  Set the p_SetModify parameter
;   to TRUE to set the modification flag after the text is set.
;
; * The system automatically resets the undo flag whenever an Edit control
;   receives a WM_SETTEXT message.  Use <Edit_SetSel> (select all) and
;   <Edit_ReplaceSel> to populate the control if undo is desired.
;
; * This function is similar to the AutoHotkey *ControlSetText* command except
;   there is no delay after the command has executed.
;
;-------------------------------------------------------------------------------
Edit_SetText(hEdit,p_Text,p_SetModify=False)
    {
    Static WM_SETTEXT:=0xC
    SendMessage WM_SETTEXT,0,&p_Text,,ahk_id %hEdit%
    if RC:=ErrorLevel  ;-- Text set successfully
        if p_SetModify
            Edit_SetModify(hEdit,True)

    Return RC  ;-- Return code from the WM_SETTEXT message
    }


;-----------------------------
;
; Function: Edit_SetSel
;
; Description:
;
;   Selects a range of characters.
;
; Parameters:
;
;   p_StartSelPos - Starting character position of the selection.  If set to -1,
;       the current selection (if any) will be deselected.
;
;   p_EndSelPos - Ending character position of the selection.  Set to -1 to use
;       the position of the last character in the control.
;
;-------------------------------------------------------------------------------
Edit_SetSel(hEdit,p_StartSelPos=0,p_EndSelPos=-1)
    {
    Static EM_SETSEL:=0x0B1
    SendMessage EM_SETSEL,p_StartSelPos,p_EndSelPos,,ahk_id %hEdit%
    }


;-----------------------------
;
; Function: Edit_SetStyle
;
; Description:
;
;   Adds, removes, or toggles a style for an Edit control.
;
; Parameters:
;
;   p_Style - Style to set.
;
;   p_Option - Use "+" (the default) to add, "-" to remove, and "^" to toggle.
;
; Returns:
;
;   TRUE if the request completed successfully, otherwise FALSE.
;
; Remarks:
;
;   Styles that can be modified after the Edit control has been created include
;   the following:
;
;   (start code)
;   ES_UPPERCASE  :=0x8
;   ES_LOWERCASE  :=0x10
;   ES_PASSWORD   :=0x20    ;-- Use the Edit_SetPasswordChar function
;   ES_OEMCONVERT :=0x400
;   ES_READONLY   :=0x800   ;-- Use the Edit_SetReadOnly function
;   ES_WANTRETURN :=0x1000
;   ES_NUMBER     :=0x2000
;   (end)
;
;   Use <Edit_IsStyle> to determine if a style is currently set.
;
;-------------------------------------------------------------------------------
Edit_SetStyle(hEdit,p_Style,p_Option="+")
    {
    Control Style,%p_Option%%p_Style%,,ahk_id %hEdit%
    Return ErrorLevel ? False:True
    }


;------------------------------
;
; Function: Edit_Show
;
; Description:
;
;   Shows a Edit control if it was previously hidden.
;
; Returns:
;
;   TRUE if successful, otherwise FALSE.
;
; Remarks:
;
;   For AutoHotkey GUIs, use the *GUIControl* command for improved efficiency.
;   Ex: GUIControl MyGUI:Show,MyEdit
;
;-------------------------------------------------------------------------------
Edit_Show(hEdit)
    {
    Control Show,,,ahk_id %hEdit%
    Return ErrorLevel ? False:True
    }


;------------------------------
;
; Function: Edit_ShowAllScrollBars
;
; Description:
;
;   Shows the horizontal and vertical scroll bars on a Edit control.
;
; Returns:
;
;   TRUE if successful, otherwise FALSE.
;
; Calls To Other Functions:
;
; * <Edit_ShowScrollBar>
;
; Remarks:
;
;   See <Edit_ShowScrollBar> for more information.
;
;-------------------------------------------------------------------------------
Edit_ShowAllScrollBars(hEdit)
    {
    Static SB_BOTH:=3
    Return Edit_ShowScrollBar(hEdit,SB_BOTH,True)
    }


;-----------------------------
;
; Function: Edit_ShowBalloonTip
;
; Description:
;
;   Displays a balloon tip associated with an Edit control.
;
; Parameters:
;
;   p_Title - Balloon tip title.  Can be empty/null.
;
;   p_Text - Balloon tip text.
;
;   p_Icon - Type of icon to associate with the balloon tip. [Optional]  The
;       default is 0 (No icon).  See the function's static variables for a list
;       of possible values.
;
; Returns:
;
;   TRUE if successful, otherwise FALSE.
;
; Requirements:
;
;   Windows XP+
;
; Remarks:
;
; * Sending the EM_SHOWBALLOONTIP message will automatically move focus to the
;   designated Edit control.
;
; * A balloon tip will not show if the "EnableBalloonTips" registry key is
;       disabled (set to 0).  The key can be found here:
;           HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\
;
; * The balloon tip icon (if specified) will not be displayed unless a title
;       (p_Title) is also specified.
;
; Observations:
;
;   The EM_SHOWBALLOONTIP message does not fail (return FALSE) if the
;   "EnableBalloonTips" registry key is disabled (set to 0).
;
;-------------------------------------------------------------------------------
Edit_ShowBalloonTip(hEdit,p_Title,p_Text,p_Icon=0)
    {
    Static Dummy8144

          ;-- p_Icon values
          ,TTI_NONE         :=0
          ,TTI_INFO         :=1
          ,TTI_WARNING      :=2
          ,TTI_ERROR        :=3

          ;-- p_Icon values (Vista+ only)
          ,TTI_INFO_LARGE   :=4
          ,TTI_WARNING_LARGE:=5
          ,TTI_ERROR_LARGE  :=6

          ;-- Messages
          ,EM_SHOWBALLOONTIP:=0x1503

    ;-- Working and Unicode copies the title and text
    wTitle:=p_Title
    wText :=p_Text

    ;-- If necessary, convert title and text to Unicode
    if not A_IsUnicode
        {
        if StrLen(p_Title)
            {
            VarSetCapacity(wTitle,StrLen(p_Title)*2,0)
            StrPut(p_Title,&wTitle,"UTF-16")
            }

        if StrLen(p_Text)
            {
            VarSetCapacity(wText,StrLen(p_Text)*2,0)
            StrPut(p_Text,&wText,"UTF-16")
            }
        }

    ;-- Define and populate EDITBALLOONTIP structure
    cbSize:=(A_PtrSize=8) ? 32:16
    VarSetCapacity(EDITBALLOONTIP,cbSize)
    NumPut(cbSize, EDITBALLOONTIP,0,"Int")
    NumPut(&wTitle,EDITBALLOONTIP,(A_PtrSize=8) ? 8:4,"Ptr")
    NumPut(&wText, EDITBALLOONTIP,(A_PtrSize=8) ? 16:8,"Ptr")
    NumPut(p_Icon, EDITBALLOONTIP,(A_PtrSize=8) ? 24:12,"Int")

    ;-- Show it
    SendMessage EM_SHOWBALLOONTIP,0,&EDITBALLOONTIP,,ahk_id %hEdit%
    Return ErrorLevel
    }


;------------------------------
;
; Function: Edit_ShowHScrollBar
;
; Description:
;
;   Shows the horizontal scroll bar on a Edit control.
;
; Returns:
;
;   TRUE if successful, otherwise FALSE.
;
; Calls To Other Functions:
;
; * <Edit_ShowScrollBar>
;
; Remarks:
;
;   See <Edit_ShowScrollBar> for more information.
;
;-------------------------------------------------------------------------------
Edit_ShowHScrollBar(hEdit)
    {
    Static SB_HORZ:=0
    Return Edit_ShowScrollBar(hEdit,SB_HORZ,True)
    }


;------------------------------
;
; Function: Edit_ShowScrollBar
;
; Description:
;
;   Shows or hides the specified scroll bar on a Edit control.
;
; Parameters:
;
;   wBar - Specifies the scroll bar(s) to be shown or hidden.  See the
;       function's static variables for a list of possible values.
;
;   p_Show - Determines whether the scroll bar is shown or hidden.  If set to
;       TRUE (the default), the scroll bar is shown; otherwise, it is hidden.
;
; Returns:
;
;   TRUE if successful, otherwise FALSE.
;
; Calls To Other Functions:
;
; * <Edit_GetScrollBarState>
;
; Remarks:
;
;   Do not call this function to show or hide a scroll bar while processing a
;   scroll bar message.
;
; Observations:
;
;   Unlike <Edit_EnableScrollBar>, this function returns TRUE (successful) even
;   if the scroll bar(s) are already in the requested state (showing/hidden).
;   To determine if a scroll bar is showing, use <Edit_IsHScrollBarVisible> or
;   <Edit_IsVScrollBarVisible>.
;
;-------------------------------------------------------------------------------
Edit_ShowScrollBar(hEdit,wBar,p_Show=True)
    {
    Static Dummy6622

          ;-- Object identifiers
          ,OBJID_HSCROLL:=0xFFFFFFFA
          ,OBJID_VSCROLL:=0xFFFFFFFB

          ;-- rgstate flags
          ,STATE_SYSTEM_UNAVAILABLE:=0x1
          ,STATE_SYSTEM_PRESSED    :=0x8
          ,STATE_SYSTEM_INVISIBLE  :=0x8000
          ,STATE_SYSTEM_OFFSCREEN  :=0x10000

          ;-- Scroll bar flags
          ,SB_HORZ:=0
            ;-- Shows or hides a window's standard horizontal scroll bars.

          ,SB_VERT:=1
            ;-- Shows or hides a window's standard vertical scroll bar.

          ,SB_CTL:=2
            ;-- Shows or hides a scroll bar control.  The hEdit parameter must
            ;   be the handle to the scroll bar control.

          ,SB_BOTH:=3
            ;-- Shows or hides a window's standard horizontal and vertical
            ;   scroll bars.

    ;-- Request to show?
    ;   If Status=STATE_SYSTEM_OFFSCREEN, (try to) hide first
    if p_Show
        {
        ;-- Horizontal
        if wBar in %SB_HORZ%,%SB_BOTH%
            if Edit_GetScrollBarState(hEdit,OBJID_HSCROLL) & STATE_SYSTEM_OFFSCREEN
                DllCall("ShowScrollBar","Ptr",hEdit,"UInt",wBar,"UInt",False)

        ;-- Vertical
        if wBar in %SB_VERT%,%SB_BOTH%
            if Edit_GetScrollBarState(hEdit,OBJID_VSCROLL) & STATE_SYSTEM_OFFSCREEN
                DllCall("ShowScrollBar","Ptr",hEdit,"UInt",wBar,"UInt",False)
        }

    ;-- Show/Hide scroll bar
    ;   Note: The return code from this DllCall is used when setting the
    ;   function's return value
    RC:=DllCall("ShowScrollBar"
        ,"Ptr",hEdit                                    ;-- hWnd
        ,"UInt",wBar                                    ;-- wbar
        ,"UInt",p_Show)                                 ;-- bShow

    ;-- Request to hide?
    ;   In rare situations, a request to hide a scroll bar may set off a series
    ;   of conditions that will change the status of the scroll bar to
    ;   STATE_SYSTEM_OFFSCREEN.  If this occurs, the program will attempt to
    ;   clear the "Offscreen" status by hiding the scroll bar again.  Without
    ;   this extra request to hide the scroll bar, the scroll bar may remain
    ;   hidden but will retain the "Offscreen" status or it may start showing
    ;   again (will appear that it was never hidden) if the opposing scroll bar
    ;   is hidden.
    if not p_Show
        {
        ;-- Horizontal
        if wBar in %SB_HORZ%,%SB_BOTH%
            if Edit_GetScrollBarState(hEdit,OBJID_HSCROLL) & STATE_SYSTEM_OFFSCREEN
                DllCall("ShowScrollBar","Ptr",hEdit,"UInt",wBar,"UInt",False)

        ;-- Vertical
        if wBar in %SB_VERT%,%SB_BOTH%
            if Edit_GetScrollBarState(hEdit,OBJID_VSCROLL) & STATE_SYSTEM_OFFSCREEN
                DllCall("ShowScrollBar","Ptr",hEdit,"UInt",wBar,"UInt",False)
        }

    Return RC ? True:False
    }


;------------------------------
;
; Function: Edit_ShowVScrollBar
;
; Description:
;
;   Shows the vertical scroll bar.
;
; Returns:
;
;   TRUE if successful, otherwise FALSE.
;
; Calls To Other Functions:
;
; * <Edit_ShowScrollBar>
;
; Remarks:
;
;   See <Edit_ShowScrollBar> for more information.
;
;-------------------------------------------------------------------------------
Edit_ShowVScrollBar(hEdit)
    {
    Static SB_VERT:=1
    Return Edit_ShowScrollBar(hEdit,SB_VERT,True)
    }


;------------------------------
;
; Function: Edit_SystemMessage
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
Edit_SystemMessage(p_MessageNbr)
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


;-----------------------------
;
; Function: Edit_TextIsSelected
;
; Description:
;
;   Returns TRUE if text is selected, otherwise FALSE.
;
; Parameters:
;
;   r_StartSelPos, r_EndSelPos - [Output] Variables that contains the starting
;       and ending position of the selection. [Optional]
;
; Calls To Other Functions:
;
; * <Edit_GetSel>
;
;-------------------------------------------------------------------------------
Edit_TextIsSelected(hEdit,ByRef r_StartSelPos="",ByRef r_EndSelPos="")
    {
    Edit_GetSel(hEdit,r_StartSelPos,r_EndSelPos)
    Return (r_StartSelPos<>r_EndSelPos)
    }


;-----------------------------
;
; Function: Edit_Undo
;
; Description:
;
;   Undo the last operation.
;
; Returns:
;
;   For a single-line Edit control, the return value is always TRUE.  For a
;   multiline Edit control, the return value is TRUE if the undo operation is
;   successful, otherwise FALSE.
;
;-------------------------------------------------------------------------------
Edit_Undo(hEdit)
    {
    Static EM_UNDO:=0xC7
    SendMessage EM_UNDO,0,0,,ahk_id %hEdit%
    Return ErrorLevel
    }


;-----------------------------
;
; Function: Edit_WriteFile
;
; Description:
;
;   Write the contents of the Edit control to a file.  See the *File Processing*
;   section for more information.
;
; Parameters:
;
;   p_File - The file path.
;
;   p_Encoding - The code page for character encoding. [Optional]  If omitted
;       or if set to null (the default), the current value of A_FileEncoding is
;       used.  Set to "CP0" to force the program to use the system default ANSI
;       code page.
;
;   p_Convert - Convert end-of-line (EOL) format. [Optional]  If omitted or if
;       set to null (the default), no conversion is performed.  The EOL format
;       will remain in the DOS format which is the EOL format used by the Edit
;       control.  Set to "M" or "Mac" to convert to Mac.  Set to "U" or "Unix"
;       to convert to Unix.
;
; Returns:
;
;   The number bytes (not characters) written to the file (can be zero),
;   otherwise -1 if the file could not be created or opened.
;
; Calls To Other Functions:
;
; * <Edit_Convert2Mac>
; * <Edit_Convert2Unix>
; * <Edit_GetText>
; * <Edit_SystemMessage>
;
; File Processing:
;
;   If the file (p_File parameter) does not exist, it will be created and the
;   contents of the Edit control will be written to the file.
;
;   If the file already exists, the contents of the file will be overwritten
;   with the contents of the Edit control.  All other attributes of the file are
;   not modified.  This includes the standard attributes like creation date but
;   if the file is on NTFS, it can include permissions, compression, encryption,
;   properties, etc.  To force a new file to be created, the existing file must
;   be deleted before calling this function.
;
;   In all cases, a byte order mark (BOM) is automatically added to the
;   beginning of the file if encoding (p_Encoding parameter or A_FileEncoding if
;   p_Encoding is null) is set to UTF-8 or UTF-16.
;
; Remarks:
;
;   If the function fails, i.e. returns -1, a developer-friendly message is
;   dumped to the debugger.  Use a debugger or debug viewer to see the message.
;
;-------------------------------------------------------------------------------
Edit_WriteFile(hEdit,p_File,p_Encoding="",p_Convert="")
    {
    ;-- Open file for write
    ;   Note: File is created if it doesn't exist, overwritten otherwise
    if not File:=FileOpen(p_File,"w",StrLen(p_Encoding) ? p_Encoding:A_FileEncoding)
        {
        l_Message:=Edit_SystemMessage(A_LastError)
        outputdebug,
           (ltrim join`s
            Function: %A_ThisFunc% -
            Unexpected return code from FileOpen function.
            A_LastError=%A_LastError% - %l_Message%
           )

        Return -1
        }

    ;-- Get text from the Edit control
    l_Text:=Edit_GetText(hEdit)

    ;-- If requested, convert EOL format
    if p_Convert
        {
        StringUpper,p_Convert,p_Convert,T
            ;-- Just in case StringCaseSense is On

        if p_Convert in U,Unix
            l_Text:=Edit_Convert2Unix(l_Text)
         else
            if p_Convert in M,Mac
                l_Text:=Edit_Convert2Mac(l_Text)
        }

    ;-- Save to file
    l_NumberOfBytesWritten:=File.Write(l_Text)

    ;-- Close file
    File.Close()

    ;-- Return to sender
    Return l_NumberOfBytesWritten
    }
