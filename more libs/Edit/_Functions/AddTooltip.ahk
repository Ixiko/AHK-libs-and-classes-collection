;------------------------------
;
; Function: AddToolTip
;
; Description:
;
;   Add/Update tooltips to GUI controls.
;
; Parameters:
;
;   hControl - Handle to a GUI control.  Alternatively, this field can be set
;       to "Deactivate" to disable the tooltip control, "Activate" to enable the
;       tooltip control, or "AutoPopDelay" to set the Autopop delay time.
;
;   p_Text - Tooltip text.  Exception: If the hControl parameter contains
;       "AutoPopDelay", set to the desired AutoPop delay time, in seconds.
;       Ex: 10.  Note: The maximum AutoPop delay time is ~32 seconds.
;
; Returns:
;
;   Handle to the tooltip control.
;
; Remarks:
;
; * This function accomplishes this task by creating a single Tooltip control
;   and then creates, updates, or delete tools which are/were attached to the
;   individual GUI controls.
;
; * This function returns the handle to the Tooltip control so that, if desired,
;   additional actions can be performed on the Tooltip control outside of this
;   function.  Once created, this function reuses the same Tooltip control.
;   If the tooltip control is destroyed outside of this function, subsequent
;   calls to this function will fail.  If desired, the tooltip control can be
;   destroyed just before the script ends.
;
; * The tooltip control is enabled by default.  There is no need to "Activate"
;   the tooltip control unless it has been "Deactivated" previously.
;
; Credit and History:
;
; * Original author: Superfraggle
;   Post: <http://www.autohotkey.com/board/topic/27670-add-tooltips-to-controls/>
;
; * Updated to support Unicode: art
;   Post: <http://www.autohotkey.com/board/topic/27670-add-tooltips-to-controls/page-2#entry431059>
;
; * Additional: jballi
;   Bug fixes.  Added support for x64.  Removed Modify parameter.  Added
;   additional functionality, documentation, and constants.
;
;-------------------------------------------------------------------------------
AddToolTip(hControl,p_Text="")
    {
    Static hTT

          ;-- Misc. constants
          ,CW_USEDEFAULT:=0x80000000
          ,HWND_DESKTOP :=0

          ;-- Tooltip delay time constants
          ,TTDT_AUTOPOP:=2
                ;-- Set the amount of time a tooltip window remains visible if
                ;   the pointer is stationary within a tool's bounding
                ;   rectangle.

          ;-- Tooltip styles
          ,TTS_ALWAYSTIP:=0x1
                ;-- Indicates that the ToolTip control appears when the cursor
                ;   is on a tool, even if the ToolTip control's owner window is
                ;   inactive.  Without this style, the ToolTip appears only when
                ;   the tool's owner window is active.

          ,TTS_NOPREFIX:=0x2
                ;-- Prevents the system from stripping ampersand characters from
                ;   a string or terminating a string at a tab character.
                ;   Without this style, the system automatically strips
                ;   ampersand characters and terminates a string at the first
                ;   tab character. This allows an application to use the same
                ;   string as both a menu item and as text in a ToolTip control.

          ;-- TOOLINFO uFlags
          ,TTF_IDISHWND:=0x1
                ;-- Indicates that the uId member is the window handle to the
                ;   tool.  If this flag is not set, uId is the identifier of the
                ;   tool.

          ,TTF_SUBCLASS:=0x10
                ;-- Indicates that the ToolTip control should subclass the
                ;   window for the tool in order to intercept messages, such
                ;   as WM_MOUSEMOVE.  If you do not set this flag, you must use
                ;   the TTM_RELAYEVENT message to forward messages to the
                ;   ToolTip control.  For a list of messages that a ToolTip
                ;   control processes, see TTM_RELAYEVENT.

          ;-- Extended styles
          ,WS_EX_TOPMOST:=0x8

          ;-- Messages
          ,TTM_ACTIVATE      :=0x401                    ;-- WM_USER + 1
          ,TTM_ADDTOOLA      :=0x404                    ;-- WM_USER + 4
          ,TTM_ADDTOOLW      :=0x432                    ;-- WM_USER + 50
          ,TTM_DELTOOLA      :=0x405                    ;-- WM_USER + 5
          ,TTM_DELTOOLW      :=0x433                    ;-- WM_USER + 51
          ,TTM_GETTOOLINFOA  :=0x408                    ;-- WM_USER + 8
          ,TTM_GETTOOLINFOW  :=0x435                    ;-- WM_USER + 53
          ,TTM_SETDELAYTIME  :=0x403                    ;-- WM_USER + 3
          ,TTM_SETMAXTIPWIDTH:=0x418                    ;-- WM_USER + 24
          ,TTM_UPDATETIPTEXTA:=0x40C                    ;-- WM_USER + 12
          ,TTM_UPDATETIPTEXTW:=0x439                    ;-- WM_USER + 57

    ;-- Save/Set DetectHiddenWindows
    l_DetectHiddenWindows:=A_DetectHiddenWindows
    DetectHiddenWindows On

    ;-- Tooltip control exists?
    if not hTT
        {
        ;-- Create Tooltip window
        hTT:=DllCall("CreateWindowEx"
            ,"UInt",WS_EX_TOPMOST                       ;-- dwExStyle
            ,"Str","TOOLTIPS_CLASS32"                   ;-- lpClassName
            ,"Ptr",0                                    ;-- lpWindowName
            ,"UInt",TTS_ALWAYSTIP|TTS_NOPREFIX          ;-- dwStyle
            ,"UInt",CW_USEDEFAULT                       ;-- x
            ,"UInt",CW_USEDEFAULT                       ;-- y
            ,"UInt",CW_USEDEFAULT                       ;-- nWidth
            ,"UInt",CW_USEDEFAULT                       ;-- nHeight
            ,"Ptr",HWND_DESKTOP                         ;-- hWndParent
            ,"Ptr",0                                    ;-- hMenu
            ,"Ptr",0                                    ;-- hInstance
            ,"Ptr",0                                    ;-- lpParam
            ,"Ptr")                                     ;-- Return type

;;;;;        ;-- ##### Temporary/Experimental 
;;;;;        ;-- Disable visual style
;;;;;        DllCall("uxtheme\SetWindowTheme","Ptr",hTT,"Ptr",0,"UIntP",0)

        ;-- Set the maximum width for the tooltip window
        ;   Note: This message makes multi-line tooltips possible
        SendMessage TTM_SETMAXTIPWIDTH,0,A_ScreenWidth,,ahk_id %hTT%
        }

    ;-- Other commands
    if hControl is not Integer
        {
        StringUpper hControl,hControl,T
            ;-- Just in case StringCaseSense is On

        if (hControl="Activate")
            SendMessage TTM_ACTIVATE,True,0,,ahk_id %hTT%

        if (hControl="Deactivate")
            SendMessage TTM_ACTIVATE,False,0,,ahk_id %hTT%

        if (InStr(hControl,"Autopop")=1)  ;-- Starts with "AutoPop"
            SendMessage TTM_SETDELAYTIME,TTDT_AUTOPOP,p_Text*1000,,ahk_id %hTT%
        
        ;-- Restore DetectHiddenWindows
        DetectHiddenWindows %l_DetectHiddenWindows%
    
        ;-- Return the handle to the tooltip control
        Return hTT
        }

    ;-- Create/Populate TOOLINFO structure
    uFlags:=TTF_IDISHWND|TTF_SUBCLASS
    cbSize:=VarSetCapacity(TOOLINFO,(A_PtrSize=8) ? 64:44,0)
    NumPut(cbSize,      TOOLINFO,0,"UInt")              ;-- cbSize
    NumPut(uFlags,      TOOLINFO,4,"UInt")              ;-- uFlags
    NumPut(HWND_DESKTOP,TOOLINFO,8,"Ptr")               ;-- hwnd
    NumPut(hControl,    TOOLINFO,(A_PtrSize=8) ? 16:12,"Ptr")
        ;-- uId

    VarSetCapacity(l_Text,4096,0)
    NumPut(&l_Text,     TOOLINFO,(A_PtrSize=8) ? 48:36,"Ptr")
        ;-- lpszText

    ;-- Check to see if tool has already been registered for the control
    SendMessage
        ,A_IsUnicode ? TTM_GETTOOLINFOW:TTM_GETTOOLINFOA
        ,0
        ,&TOOLINFO
        ,,ahk_id %hTT%

    RegisteredTool:=ErrorLevel

    ;-- Update TOOLTIP structure
    NumPut(&p_Text,TOOLINFO,(A_PtrSize=8) ? 48:36,"Ptr")
        ;-- lpszText

    ;-- Add, Update, or Delete tool
    if RegisteredTool
        {
        if StrLen(p_Text)
            SendMessage
                ,A_IsUnicode ? TTM_UPDATETIPTEXTW:TTM_UPDATETIPTEXTA
                ,0
                ,&TOOLINFO
                ,,ahk_id %hTT%
         else
            SendMessage
                ,A_IsUnicode ? TTM_DELTOOLW:TTM_DELTOOLA
                ,0
                ,&TOOLINFO
                ,,ahk_id %hTT%
        }
    else
        if StrLen(p_Text)
            SendMessage
                ,A_IsUnicode ? TTM_ADDTOOLW:TTM_ADDTOOLA
                ,0
                ,&TOOLINFO
                ,,ahk_id %hTT%

    ;-- Restore DetectHiddenWindows
    DetectHiddenWindows %l_DetectHiddenWindows%

    ;-- Return the handle to the tooltip control
    Return hTT
    }
