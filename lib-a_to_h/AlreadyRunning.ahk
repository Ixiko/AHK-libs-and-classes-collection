;************************
;*                      *
;*    AlreadyRunning    *
;*                      *
;************************
;
;
;   Description
;   ===========
;   This function checks to see if multiple occurrences of the script are
;   running.
;
;
;
;   Parameters
;   ==========
;
;       Name            Description
;       ----            -----------
;       p_MsgBox        If set to TRUE and there are multiple occurrences of the
;                       script running, an appropriate error message is
;                       displayed.  [Optional]  The default is TRUE.
;
;
;       p_ExitApp       If set to TRUE and there are multiple occurrences of the
;                       script running, the "ExitApp" command is performed.
;                       [Optional]  The default is TRUE.
;
;
;
;   Return Codes
;   ============
;   Returns TRUE if multiple occurrences of the script are running, otherwise
;   returns FALSE.
;
;
;
;   Credit
;   ======
;   The original idea/script from jonny
;       http://www.autohotkey.com/forum/viewtopic.php?p=108296#108296
;
;
;
;   Programming and Usage Notes
;   ===========================
;    -  The function only works if the "#SingleInstance off" directive has been
;       defined and is active.
;
;    -  Please note that setting p_Message to FALSE and p_ExitApp to TRUE is the
;       functional equivalent of using the "#SingleInstance ignore" directive.
;   
;   
;-------------------------------------------------------------------------------
#SingleInstance off
AlreadyRunning(p_MsgBox=True,p_ExitApp=True)
    {
    ;[==============]
    ;[  Initialize  ]
    ;[==============]
    l_DetectHiddenWindows:=A_DetectHiddenWindows
    DetectHiddenWindows On


    ;[========================]
    ;[  Find other processes  ]
    ;[        (if any)        ]
    ;[========================]
    Process Exist
    WinGetTitle l_Title,ahk_pid %ErrorLevel%
    WinGet l_Count,Count,%l_Title%
    DetectHiddenWindows %l_DetectHiddenWindows%


    ;[======================]
    ;[  Only 1 occurrence?  ]
    ;[======================]
    if l_Count=1
        return False


    ;[===================]
    ;[  Already running  ]
    ;[===================]
    ;-- Initialize
    l_Type=script
    SplitPath l_Title,,,l_TitleExt
    if l_TitleExt=exe
        l_Type=program


    ;[==================]
    ;[  Error message?  ]
    ;[==================]
    if p_MsgBox
        {
        SplitPath A_ScriptName,,,,l_ScriptName
        MsgBox
            ,262192
                ;          0 ("OK" button)
                ;   +     48 (Exclamation Icon)
                ;   + 262144 (Always On Top)
                ;     ------
                ;     262192
                ;
            ,%l_ScriptName%
            ,The "%A_ScriptName%" %l_Type% is already running.  %A_Space%
        }


    ;[=====================]
    ;[  Terminate script?  ]
    ;[=====================]
    if p_ExitApp
        ExitApp


    ;-- Return to sender
    return True
    }
