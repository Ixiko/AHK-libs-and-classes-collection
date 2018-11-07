;-----------------------------
;
; Function: Edit_TTSGUI v0.5
;
;   This function displays a Text-To-Speech player window to speak text from an
;   Edit control.
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
;   hEdit - Handle to the Edit control.
;
;   p_Options - Program options. [Optional] Valid options include the following:
;
;   p_Title - Title to the Text-To-Speech window. [Optional]  If not defined
;       or null then "Text-To-Speech" is used.
;
; Returns:
;
;   If a Edit_TTSGUI window is created, the handle to the window is returned,
;   otherwise FALSE (0) is returned. See the "Remarks" for more information.
;
; Calls To Other Functions:
;
;   * AddTooltip
;   * Edit [Library]
;   * Fnt [Library]
;   * MoveChildWindow
;   * WinGetPosEx
;
; Font:
;
;   The Font option in the p_Options parameter allows for a specific logical
;   font to specified when creating all GUI controls except for the buttons that
;   control playback.  The syntax is as follows:
;   {OptionName}={FontName}:{FontOptions}. Ex: Font="Arial:s10 bold".  Most
;   components of the option value are optional. If a typeface name is not
;   specified (Ex: ":s12 bold"), the default GUI font is used.  If no font
;   options are specified (Ex: "Arial" or "Arial:"), the default font options
;   are used. See the AutoHotkey documentation for a list of (and syntax of)
;   font options.
;
;   Exception: If the option value is set to "Message" (Ex: Font=Message), the
;   system font used for Message Box dialog is used.  In general, the Message
;   font is a bit larger and easier to read than the default GUI font and it is
;   commonly used in dialogs.
;
; Options:
;
;   The p_Options parameter contains options for the display and operation of
;   the Edit_TTSGUI window.  Valid options include the following:
;
;   -Options - Hide all Text-To-Speech options.  If this option is set, the
;       "Show Options" button is hidden so that the user cannot show any of
;       of the dialog's Text-To-Speech options.  If specified, this option makes
;       all options that begin with the negative character (Ex: -Rate)
;       redundant.
;
;   Font={Font} - Allows the developer to set a specific font for the GUI
;       objects.  See the *Font* section for the syntax of this option.  If this
;       option is not specified, the default GUI font is used.
;
;   -Format - Hide the "Format" option.
;
;   Rate={PlaybackRate} - Specify a playback rate from -10 to 10.  For example:
;       Rate=3.  The user can override the rate if the "Rate" option is
;       displayed.
;
;   -Rate - Hide the "Rate" option.
;
;   Skip={NumberOfSentencesToSkip} - Specify the number of sentences to skip
;       forward when the Skip button is pressed.  For example: Skip=3.  The user
;       can override this value if the "Skip" option is displayed.
;
;   -Skip - Hide the "Skip" option.
;
;   Speak - Begin to speak immediately.
;
;   TrackWord={EnableOrDisable} - Specify whether the program will track the
;       word on the edit control when speaking.  Set to 1 to enable.  Set to 0
;       to disable.  For example: TrackWord=1.  The user can override this value
;       if the "TrackWord" option is displayed.
;
;   -TrackWord - Hide the "Word tracking" option.  Don't confuse this option
;       with the TrackWord=0" option.
;
;   Voice={NameOfVoice} - Specify a Text-To-Speech voice.  For example:
;       Voice="Microsoft Mary".  The user can override this voice if the "Voice"
;       option is displayed.  If the specified voice is not found, the default
;       voice is used.
;
;   -Voice - Hide the "Voice" option.
;
;   Volume={VolumeLevel} - Specify a volume level from 0 to 100.  For example:
;       Volume=80.  The user can override the volume level if the "Volume"
;       option is displayed.
;
;   -Volume - Hide the "Volume" option.
;
;   To use more than one option, include a space between each option.  For
;   example: Volume=80 Rate=3 -Format.  If an option value contains one or more
;   space characters, enclose the entire value in single or double quote
;   characters.  Ex: Voice='Microsoft Mike' or Voice="Microsoft Mary".
;   IMPORTANT: Only options that can possibly contain space characters will
;   support the value enclosed single or double quote characters.
;
; Owner:
;
;   The p_Owner parameter is used to specify the owner of the Edit_TTSGUI
;   window.  Set to 0 for no owner.  For an AutoHotkey GUI, specify a valid GUI
;   number (1-99), a GUI name, or the handle to the GUI.  For a non-AutoHotkey
;   window, specify the handle to the window.  For all owner windows, the
;   Edit_TTSGUI window is positioned in the center of the owner window or as
;   close to the center as possible.  If no owner is specified or if a
;   non-AutoHotkey window is specified, the AlwaysOnTop attribute is added to
;   the Edit_TTSGUI dialog to make sure that the dialog is not lost.
;
; Remarks:
;
;   Since the Edit_TTSGUI window remains open until the user closes it or until
;   the developer closes it (for whatever reason), it's best to check to see if
;   the Edit_TTSGUI window is already open before calling this function. For
;   example:
;
;       (start code)
;       IfWinNotExist ahk_id %hEdit_TTSGUI%
;           hEdit_TTSGUI:=Edit_TTSGUI(...
;           .
;           .
;       (end)
;
;   The correct way to force the Edit_TTSGUI window to close is the *WinClose*
;   command.  For example:
;
;       (start code)
;       WinClose ahk_id %hEdit_TTSGUI%
;       (end)
;
;   The *WinClose* command will automatically trigger the standard *GUIClose*
;   label which will destroy the Edit_TTSGUI window and release COM and Speech
;   resources.
;
;   Important: Some voices do not support all of the features of this
;   Text-To-Speech player.  Examples: 1) Most voices allow the volume and rate
;   to be changed while the voice is speaking but some do not.  2) Most
;   voices support the Skip command but some do not.  For some voices, pressing
;   the Skip button will lock the player until the voice is done speaking.
;
;-------------------------------------------------------------------------------
Edit_TTSGUI(p_Owner,hEdit,p_Options="",p_Title="")
    {
    Global Edit_TTSGUI_hEdit
          ,Edit_TTSGUI_StartSelPos
          ,Edit_TTSGUI_EndSelPos
          ,Edit_TTSGUI_TrackWord

    Static Dummy2101
          ,hEdit_TTSGUI
          ,s_Max
          ,s_MinW
          ,s_MinH
          ,s_NOHIDESEL
          ,s_PauseRequest
          ,s_SpVoice
          ,s_Sink
          ,s_Skip:=1

          ;-- Constants
          ,ES_NOHIDESEL:=0x100

          ,SRSEWaitingToSpeak:=0x0
                ;-- Active but not speaking.  This status can occur under the
                ;   following conditions:
                ;
                ;     - Before the voice has begun speaking
                ;     - The voice has been paused
                ;     - The voice has been interrupted by an Alert voice
                ;
                ;   Note: There is no documented constant name for this status.

          ,SRSEDone:=0x1
                ;-- The voice has finished rendering all queued phrases.

          ,SRSEIsSpeaking:=0x2
                ;-- The SpVoice currently claims the audio queue.

          ,SVSFlagsAsync:=0x1
                ;-- Specifies that the Speak call should be asynchronous.  That
                ;   is, it will return immediately after the speak request is
                ;   queued.

          ,SVSFPurgeBeforeSpeak:=0x2
                ;-- Purges all pending speak requests prior to this speak call.

    ;[=================]
    ;[  Already open?  ]
    ;[=================]
    ;-- Bounce (with prejudice) if a Edit_TTSGUI window already showing
    gui Edit_TTSGUI:+LastFoundExist
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
    SplitPath A_ScriptName,,,,l_ScriptName
    s_NOHIDESEL:=Edit_IsStyle(hEdit,ES_NOHIDESEL)
    l_AudioOutputStreamFormatTypeDescriptionList=
       (ltrim join|
        8kHz 8 Bit Mono
        8kHz 8 Bit Stereo
        8kHz 16 Bit Mono
        8kHz 16 Bit Stereo
        11kHz 8 Bit Mono
        11kHz 8 Bit Stereo
        11kHz 16 Bit Mono
        11kHz 16 Bit Stereo
        12kHz 8 Bit Mono
        12kHz 8 Bit Stereo
        12kHz 16 Bit Mono
        12kHz 16 Bit Stereo
        16kHz 8 Bit Mono
        16kHz 8 Bit Stereo
        16kHz 16 Bit Mono
        16kHz 16 Bit Stereo
        22kHz 8 Bit Mono
        22kHz 8 Bit Stereo
        22kHz 16 Bit Mono
        22kHz 16 Bit Stereo
        24kHz 8 Bit Mono
        24kHz 8 Bit Stereo
        24kHz 16 Bit Mono
        24kHz 16 Bit Stereo
        32kHz 8 Bit Mono
        32kHz 8 Bit Stereo
        32kHz 16 Bit Mono
        32kHz 16 Bit Stereo
        44kHz 8 Bit Mono
        44kHz 8 Bit Stereo
        44kHz 16 Bit Mono
        44kHz 16 Bit Stereo
        48kHz 8 Bit Mono
        48kHz 8 Bit Stereo
        48kHz 16 Bit Mono
        48kHz 16 Bit Stereo
       )

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

    ;-- hEdit
    Edit_TTSGUI_hEdit:=hEdit

    ;-- Title
    p_Title:=Trim(p_Title," `f`n`r`t`v")
        ;-- Remove all leading/trailing white space

    if not StrLen(p_Title)
        p_Title:="Text-To-Speech"
     else
        {
        ;-- Append to script name if p_title begins with "++"?
        if (SubStr(p_Title,1,2)="++")
            {
            StringTrimLeft p_Title,p_Title,2
            p_Title:=l_ScriptName . A_Space . p_Title
            }
        }

    ;[===================]
    ;[  Init COM/Speech  ]
    ;[===================]
    ;-- Create SpVoice instance
    s_SpVoice:=ComObjCreate("SAPI.SpVoice")

    ;-- Build list of Voices
    l_VoiceList:=""
    Loop % s_SpVoice.GetVoices.Count
        l_VoiceList.=(StrLen(l_VoiceList) ? "|":"")
            . s_SpVoice.GetVoices.Item(A_Index-1).GetAttribute("Name")

    ;[===========]
    ;[  Options  ]
    ;[===========]
    ;-- Initialize/Set defaults
    l_ContinueFont :=False
    l_ContinueVoice:=False
    o_ShowOptions  :=True
    o_ShowVoice    :=True
    o_ShowVolume   :=True
    o_ShowRate     :=True
    o_ShowFormat   :=True
    o_ShowSkip     :=True
    o_ShowTrackWord:=True
    o_Voice        :=s_SpVoice.Voice.GetAttribute("Name")
    o_Volume       :=s_SpVoice.Volume
    o_Rate         :=s_SpVoice.Rate
    o_Speak        :=False
    Edit_TTSGUI_TrackWord:=True

    ;-- Extract from p_Options
    Loop Parse,p_Options,%A_Space%
        {
        if l_ContinueFont
            {
            o_Font.=A_Space . A_LoopField
            if (SubStr(o_Font,0)="""" or SubStr(o_Font,0)="'")
                {
                StringTrimRight o_Font,o_Font,1
                o_Font:=Trim(o_Font," `f`n`r`t`v")
                    ;-- Remove all leading/trailing white space
                l_ContinueFont:=False
                }

            Continue
            }

        if l_ContinueVoice
            {
            o_Voice.=A_Space . A_LoopField
            if (SubStr(o_Voice,0)="""" or SubStr(o_Voice,0)="'")
                {
                StringTrimRight o_Voice,o_Voice,1
                o_Voice:=Trim(o_Voice," `f`n`r`t`v")
                    ;-- Remove all leading/trailing white space
                l_ContinueVoice:=False
                }

            Continue
            }

        if (A_LoopField="-Options")
            {
            o_ShowOptions:=False
            Continue
            }

        if (A_LoopField="-Voice")
            {
            o_ShowVoice:=False
            Continue
            }

        if (A_LoopField="-Volume")
            {
            o_ShowVolume:=False
            Continue
            }

        if (A_LoopField="-Rate")
            {
            o_ShowRate:=False
            Continue
            }

        if (A_LoopField="-Format")
            {
            o_ShowFormat:=False
            Continue
            }

        if (A_LoopField="-Skip")
            {
            o_ShowSkip:=False
            Continue
            }

        if (A_LoopField="-TrackWord")
            {
            o_ShowTrackWord:=False
            Continue
            }

        if (SubStr(A_LoopField,1,5)="Font=")
            {
            o_Font:=SubStr(A_LoopField,6)
            if (SubStr(o_Font,1,1)="""" or SubStr(o_Font,1,1)="'")
                {
                StringTrimLeft o_Font,o_Font,1
                if (SubStr(o_Font,0)="""" or SubStr(o_Font,0)="'")
                    StringTrimRight o_Font,o_Font,1
                 else
                    l_ContinueFont:=True
                }

            Continue
            }

        if (SubStr(A_LoopField,1,6)="Voice=")
            {
            o_Voice:=SubStr(A_LoopField,7)
            if (SubStr(o_Voice,1,1)="""" or SubStr(o_Voice,1,1)="'")
                {
                StringTrimLeft o_Voice,o_Voice,1
                if (SubStr(o_Voice,0)="""" or SubStr(o_Voice,0)="'")
                    StringTrimRight o_Voice,o_Voice,1
                 else
                    l_ContinueVoice:=True
                }

            Continue
            }

        if (SubStr(A_LoopField,1,7)="Volume=")
            {
            t_Volume:=SubStr(A_LoopField,8)
            if t_Volume is Integer
                if o_Volume between 0 and 100
                    o_Volume:=t_Volume

            Continue
            }

        if (SubStr(A_LoopField,1,5)="Rate=")
            {
            t_Rate:=SubStr(A_LoopField,6)
            if t_Rate is Integer
                if t_Rate between -10 and 10
                    o_Rate:=t_Rate

            Continue
            }

        if (SubStr(A_LoopField,1,5)="Skip=")
            {
            s_Skip:=SubStr(A_LoopField,6)
            Continue
            }

        if (SubStr(A_LoopField,1,10)="TrackWord=")
            {
            Edit_TTSGUI_TrackWord:=SubStr(A_LoopField,11)
            Continue
            }

        if (A_LoopField="Speak")
            {
            o_Speak:=True
            Continue
            }
        }

    ;-- Reset voice to default if specified voice is not found
    if not InStr("|" . l_VoiceList . "|","|" . o_Voice . "|")
        o_Voice:=s_SpVoice.Voice.GetAttribute("Name")

    ;-- Set Voice, Volume, and Rate
    s_SpVoice.Voice :=s_SpVoice.GetVoices("Name=" . o_Voice).Item(0)
    s_SpVoice.Volume:=o_Volume
    s_SpVoice.Rate  :=o_Rate

    ;-- Font
    hFont:=0
    l_Font:=""
    l_FontOptions:=""
    if o_ShowOptions and o_Font
        {
        Loop Parse,o_Font,:
            if (A_Index=1)
                l_Font:=A_LoopField
             else
                {
                l_FontOptions:=A_LoopField
                Break
                }

        if (l_Font="Message")
            {
            l_Font:=Fnt_GetMessageFontName()
            if not Fnt_FOGetSize(l_FontOptions)
                Fnt_FOSetSize(l_FontOptions,Fnt_GetMessageFontSize())
            }

        hFont:=Fnt_CreateFont(l_Font,l_FontOptions)
        }

    ;[===================]
    ;[  Calculate sizes  ]
    ;[===================]
    ;-- Margins
    Fnt_GetDefaultGUIMargins(hFont,l_MarginX,l_MarginY,False)
    l_MarginX:=l_MarginY

    ;-- Calculate size of objects
    l_ClientW:=Fnt_HorzDTUs2Pixels(hFont,120)+(l_MarginX*2)
        ;-- Enough space for 30 average characters + margins

    ;-- Button size
    l_ButtonW:=Round(l_ClientW/5)
    l_ButtonH:=Round(l_ButtonW*0.70)

    ;-- Recalculate client width in case there was rounding
    l_ClientW:=l_ButtonW*5

    ;-- Button font size
    hButtonFont:=Fnt_CreateFont("Webdings","s12")  ;-- starting point
    ButtonFontSize:=Fnt_FontSizeToFitHeight(hButtonFont,l_ButtonH-6)
    Fnt_DeleteFont(hButtonFont)

    ;[=============]
    ;[  Build GUI  ]
    ;[=============]
    ;-- Set ownership
    ;   Note: Ownership commands must be performed before any other GUI commands
    if p_Owner
        gui Edit_TTSGUI:+Owner%p_Owner%  ;-- Modeless ownership
     else
        gui Edit_TTSGUI:+Owner           ;-- Assign to the script window

    ;-- GUI options
    gui Edit_TTSGUI:-DPIScale +hWndhEdit_TTSGUI +LabelEdit_TTSGUI_ -MinimizeBox
    gui Edit_TTSGUI:Margin,0,0
    if not p_Owner
        gui Edit_TTSGUI:+AlwaysOnTop

    ;-- GUI objects

    ;-- Set font for buttons
    gui Edit_TTSGUI:Font,s%ButtonFontSize%,Webdings
    gui Edit_TTSGUI:Font,% "s" ButtonFontSize+2
        ;-- Play, i.e. Speak, button icon is smaller than the others so a slight
        ;   adjustment for the Speak button is made here
    gui Edit_TTSGUI:Add
       ,Button
       ,% ""
            . "xm ym "
            . "w" . l_ButtonW . A_Space
            . "h" . l_ButtonH . A_Space
            . "hWndhEdit_TTSGUI_Speak "
            . "gEdit_TTSGUI_Speak "
       ,4
    AddTooltip(hEdit_TTSGUI_Speak,"Speak")

    gui Edit_TTSGUI:Font,s%ButtonFontSize%
        ;-- Reset font size to the default button size
    gui Edit_TTSGUI:Add
       ,Button
       ,% ""
            . "x+0 wp hp "
            . "hWndhEdit_TTSGUI_Pause "
            . "gEdit_TTSGUI_Pause "
       ,;
    AddTooltip(hEdit_TTSGUI_Pause,"Pause")

    gui Edit_TTSGUI:Font,% "s" ButtonFontSize-2
        ;-- Stop button icon looks larger than the others so a slight adjustment
        ;   is made here
    gui Edit_TTSGUI:Add
       ,Button
       ,% ""
            . "x+0 wp hp "
            . "hWndhEdit_TTSGUI_Stop "
            . "gEdit_TTSGUI_Stop "
       ,<
    AddTooltip(hEdit_TTSGUI_Stop,"Stop")

    gui Edit_TTSGUI:Font,s%ButtonFontSize%
        ;-- Reset font size to the default button size
    gui Edit_TTSGUI:Add
       ,Button
       ,% ""
            . "x+0 wp hp "
            . "hWndhEdit_TTSGUI_Skip "
            . "gEdit_TTSGUI_Skip "
       ,8
    AddTooltip(hEdit_TTSGUI_Skip,"Skip")

    if o_ShowOptions
        {
        gui Edit_TTSGUI:Add
           ,Button
           ,% ""
                . "x+0 wp hp "
                . "hWndhEdit_TTSGUI_ToggleOptions "
                . "gEdit_TTSGUI_ToggleOptions "
           ,6
        AddTooltip(hEdit_TTSGUI_ToggleOptions,"Show/Hide Options")
        }

    ;-- Reset font
    gui Edit_TTSGUI:Font
 
    ;-- Size GUI for just the buttons
    gui Edit_TTSGUI:Show,Hide AutoSize,%p_Title%

    ;-- Collect the size for future use
    l_DetectHiddenWindows:=A_DetectHiddenWindows
    DetectHiddenWindows On
    WinGetPos,,,s_MinW,s_MinH,ahk_id %hEdit_TTSGUI%
    DetectHiddenWindows %l_DetectHiddenWindows%

    ;-- Add option objects
    if o_ShowOptions
        {
        ;-- Set margin
        gui Edit_TTSGUI:Margin,%l_MarginX%,%l_MarginY%

        ;-- If specified, set font
        if l_Font or l_FontOptions
            gui Edit_TTSGUI:Font,%l_FontOptions%,%l_Font%

        ;-- Establish the width of the prompt field
        l_PromptW:=Fnt_GetStringWidth(hFont,"Volume:i")

        ;-- Calculate object width, i.e. whatever space is left
        l_ObjectW:=l_ClientW-l_PromptW-(l_MarginX*2)

        ;--  Add controls
        if o_ShowVoice
            {
            gui Edit_TTSGUI:Add
               ,Text
               ,% ""
                    . "xm" . A_Space
                    . "w" . l_PromptW . A_Space
               ,Voice:

            Static Edit_TTSGUI_Voice
            gui Edit_TTSGUI:Add
               ,DropDownList
               ,% ""
                    . "x+0 w" . l_ObjectW . A_Space
                    . "r5 "
                    . "vEdit_TTSGUI_Voice "
               ,%l_VoiceList%

            GUIControl
                ,Edit_TTSGUI:ChooseString
                ,Edit_TTSGUI_Voice
                ,%o_Voice%
            }

        if o_ShowVolume
            {
            gui Edit_TTSGUI:Add
               ,Text
               ,% ""
                    . "xm" . A_Space
                    . "w" . l_PromptW . A_Space
               ,Volume:

            Static Edit_TTSGUI_Volume
            gui Edit_TTSGUI:Add
               ,Slider
               ,% ""
                    . "x+0 w" . l_ObjectW . A_Space
                    . "Range0-100 "
                    . "TickInterval10 "
                    . "ToolTip "
                    . "vEdit_TTSGUI_Volume "
                    . "gEdit_TTSGUI_Volume "
               ,%o_Volume%
            }

        if o_ShowRate
            {
            gui Edit_TTSGUI:Add
               ,Text
               ,% ""
                    . "xm" . A_Space
                    . "w" . l_PromptW . A_Space
               ,Rate:

            Static Edit_TTSGUI_Rate
            gui Edit_TTSGUI:Add
               ,Slider
               ,% ""
                    . "x+0 "
                    . "w" . l_ObjectW . A_Space
                    . "Range-10-10 "
                    . "TickInterval10 "
                    . "ToolTip "
                    . "vEdit_TTSGUI_Rate "
                    . "gEdit_TTSGUI_Rate "
               ,%o_Rate%
            }

        if o_ShowFormat
            {
            gui Edit_TTSGUI:Add
               ,Text
               ,% ""
                    . "xm" . A_Space
                    . "w" . l_PromptW . A_Space
               ,Format:

            Static Edit_TTSGUI_AudioOutputStreamFormatType
            gui Edit_TTSGUI:Add
               ,DropDownList
               ,% ""
                    . "x+0 "
                    . "w" . l_ObjectW . A_Space
                    . "r5 "
                    . "+AltSubmit "
                    . "vEdit_TTSGUI_AudioOutputStreamFormatType "
               ,%l_AudioOutputStreamFormatTypeDescriptionList%

            GUIControl
                ,Edit_TTSGUI:Choose
                ,Edit_TTSGUI_AudioOutputStreamFormatType
                ,% s_SpVoice.AudioOutputStream.Format.Type-3
            }

        if o_ShowSkip
            {
            gui Edit_TTSGUI:Add
               ,Text
               ,% ""
                    . "xm" . A_Space
                    . "w" . l_PromptW . A_Space
               ,Skip:

            Static Edit_TTSGUI_Skip
            gui Edit_TTSGUI:Add
               ,Edit
               ,% ""
                    . "x+0 w50 r1 "
                    . "vEdit_TTSGUI_Skip "

            gui Edit_TTSGUI:Add
               ,UpDown
               ,% ""
                    . "x+0 hp "
                    . "Range1-99 "
               ,%s_Skip%
            }

        if o_ShowTrackWord
            {
            gui Edit_TTSGUI:Add
               ,CheckBox
               ,% ""
                    . "xm" . A_Space
                    . "Checked" . Edit_TTSGUI_TrackWord . A_Space
                    . "vEdit_TTSGUI_TrackWord "
                    . "gEdit_TTSGUI_TrackWord "
               ,Word tracking
            }

        ;-- Reset font
        gui Edit_TTSGUI:Font

        ;-- Final margins
        gui Edit_TTSGUI:Margin,0,%l_MarginY%
        }

    ;-- Delete logical font
    Fnt_DeleteFont(hFont)

    ;[===========]
    ;[  Show it  ]
    ;[===========]
    if hOwner
        MoveChildWindow(hOwner,hEdit_TTSGUI,"Show")
     else
        gui Edit_TTSGUI:Show,,%p_Title%

    ;[===================]
    ;[  Begin speaking?  ]
    ;[===================]
    If o_Speak
        SetTimer Edit_TTSGUI_Speak,0

    ;[====================]
    ;[  Return to sender  ]
    ;[====================]
    Return hEdit_TTSGUI   ;-- End of function


    ;*********************
    ;*                   *
    ;*    Subroutines    *
    ;*                   *
    ;*********************
    Edit_TTSGUI_Volume:
    gui Submit,NoHide
    s_SpVoice.Volume:=Edit_TTSGUI_Volume

    ;-- Do nothing else if Voice is not active (speaking, paused, or interrupted)
    if (s_SpVoice.Status.RunningState=SRSEDone)
        return

    ;-- Reset focus?
    if not s_NOHIDESEL
        ControlFocus,,ahk_id %Edit_TTSGUI_hEdit%

    return


    Edit_TTSGUI_Rate:
    gui Submit,NoHide
    s_SpVoice.Rate:=Edit_TTSGUI_Rate

    ;-- Do nothing else if voice is not active (speaking, paused, or interrupted)
    if (s_SpVoice.Status.RunningState=SRSEDone)
        return

    ;-- Reset focus?
    if not s_NOHIDESEL
        ControlFocus,,ahk_id %Edit_TTSGUI_hEdit%

    return


    Edit_TTSGUI_Speak:
    SetTimer %A_ThisLabel%,Off
    gui Edit_TTSGUI:Submit,NoHide

    ;-- If paused, button acts the same as the Pause button
    if s_PauseRequest
        {
        gosub Edit_TTSGUI_Pause
        return
        }

    ;-- If the Voice is speaking, stop.  This will also reposition the selection.
    if (s_SpVoice.Status.RunningState=SRSEIsSpeaking)
        {
        gosub Edit_TTSGUI_Stop

        ;-- Wait until the Voice instance has stopped speaking.  The voice must
        ;   be completely stopped in order to set/reset the AudioOutputStream
        ;   format type.  The delay also allows the EndStream event to occur.
        Loop 18  ;-- Max wait is 900ms
            {
            Sleep 50
            if (s_SpVoice.Status.RunningState=SRSEDone)
                Break
            }
        }

    ;-- Voice
    if Edit_TTSGUI_Voice is not Space
        s_SpVoice.Voice:=s_SpVoice.GetVoices("Name=" . Edit_TTSGUI_Voice).Item(0)

    ;-- AudioOutputStream format type
    if Edit_TTSGUI_AudioOutputStreamFormatType is not Space
        {
        ;-- Turn AllowAudioOutputFormatChangesOnNextSet off
        s_SpVoice.AllowAudioOutputFormatChangesOnNextSet:=False

        ;-- Set to selected type
        s_SpVoice.AudioOutputStream.Format.Type:=Edit_TTSGUI_AudioOutputStreamFormatType+3

        ;-- Assign to self
        s_SpVoice.AudioOutputStream:=s_SpVoice.AudioOutputStream
            ;-- This assignment is necessary so that SAPI picks up the new format

        ;-- Turn AllowAudioOutputFormatChangesOnNextSet back on
        s_SpVoice.AllowAudioOutputFormatChangesOnNextSet:=True
        }

    ;-- Collect text
    Edit_GetSel(Edit_TTSGUI_hEdit,Edit_TTSGUI_StartSelPos,Edit_TTSGUI_EndSelPos)

    l_EndSelPos:=Edit_TTSGUI_EndSelPos
    if (Edit_TTSGUI_StartSelPos=Edit_TTSGUI_EndSelPos)
        l_EndSelPos:=-1

    l_Text:=Edit_GetTextRange(Edit_TTSGUI_hEdit,Edit_TTSGUI_StartSelPos,l_EndSelPos)
        ;-- Text includes CR+LF characters (needed by the Word event)

    ;-- Anything to speak?
    if l_Text is Space
        {
        gui +OwnDialogs
        MsgBox
            ,0x30  ;-- 0x30 ("!" icon) + 0x0 (OK button)
            ,Text-To-Speech,
               (ltrim
                There is no text to speak.

                The starting point is determined by selection or by the position
                of the caret.  Select text or reposition the caret.
               )

        return
        }

    ;-- Initialize
    s_PauseRequest:=False

    ;-- If necessary, establish Sink (event interface)
    if not s_Sink
        {
        ComObjConnect(s_SpVoice,"Edit_TTSGUI_On")
        s_Sink:=True
        }

    ;-- Speak
    s_SpVoice.Speak(l_Text,SVSFlagsAsync|SVSFPurgeBeforeSpeak)

    ;-- Reset focus?
    if not s_NOHIDESEL
        ControlFocus,,ahk_id %Edit_TTSGUI_hEdit%

    return


    Edit_TTSGUI_Pause:

    ;-- Bounce if the voice is not active (speaking, paused, or interrupted)
    if (s_SpVoice.Status.RunningState=SRSEDone)
        return

    if s_PauseRequest
        {
        s_SpVoice.Resume
        s_PauseRequest:=False
        }
     else
        {
        s_SpVoice.Pause
        s_PauseRequest:=True
        }

    ;-- Reset focus?
    if not s_NOHIDESEL
        ControlFocus,,ahk_id %Edit_TTSGUI_hEdit%

    return


    Edit_TTSGUI_Stop:

    ;-- Bounce if the voice is not active (speaking, paused, or interrupted)
    if (s_SpVoice.Status.RunningState=SRSEDone)
        return

    ;-- Resume if paused (keeps the stream from getting lost/stuck)
    if s_PauseRequest
        {
        s_SpVoice.Resume
        s_PauseRequest:=False
        }

    ;-- Stop request
    s_SpVoice.Speak("",SVSFlagsAsync|SVSFPurgeBeforeSpeak)
        ;-- Send empty string with SVSFPurgeBeforeSpeak flag to stop playback

    ;-- Reset focus?
    if not s_NOHIDESEL
        ControlFocus,,ahk_id %Edit_TTSGUI_hEdit%

    return


    Edit_TTSGUI_Skip:
    gui Submit,NoHide

    ;-- Bounce if the voice is not speaking
    if (s_SpVoice.Status.RunningState<>SRSEIsSpeaking)
        return

    ;-- Skip
    s_SpVoice.Skip("Sentence",Edit_TTSGUI_Skip ? Edit_TTSGUI_Skip:s_Skip)

    ;-- Reset focus?
    if not s_NOHIDESEL
        ControlFocus,,ahk_id %Edit_TTSGUI_hEdit%

    return


    Edit_TTSGUI_ToggleOptions:
    SetTimer %A_ThisLabel%,Off
    if s_Max
        {
        WinMove ahk_id %hEdit_TTSGUI%,,,,%s_MinW%,%s_MinH%
        s_Max:=False
        }
     else
        {
        gui Edit_TTSGUI:Show,AutoSize
        s_Max:=True
        }

    return


    Edit_TTSGUI_TrackWord:
    gui Submit,NoHide

    ;-- Do nothing else if Voice is not active (speaking, paused, or interrupted)
    if (s_SpVoice.Status.RunningState=SRSEDone)
        return

    ;-- Reset focus?
    if not s_NOHIDESEL
        ControlFocus,,ahk_id %Edit_TTSGUI_hEdit%

    ;-- Only perform if TrackWord is turned on
    if not Edit_TTSGUI_TrackWord
        {
        ;-- Reset to original selection
        Edit_SetSel(Edit_TTSGUI_hEdit,Edit_TTSGUI_StartSelPos,Edit_TTSGUI_EndSelPos)
        Edit_ScrollCaret(Edit_TTSGUI_hEdit)
        }

    return


    ;[=================]
    ;[  Close up shop  ]
    ;[=================]
    Edit_TTSGUI_Escape:
    Edit_TTSGUI_Close:

    ;-- If needed, stop speaking voice
    if (s_SpVoice.Status.RunningState=SRSEIsSpeaking)
        {
        ;-- Ensure that the voice is the most responsive
        s_SpVoice.Rate:=10

        ;-- Stop request
        gosub Edit_TTSGUI_Stop

        ;-- Wait until the voice has stopped speaking
        Loop 18  ;-- Max wait is 900ms
            {
            Sleep 50
            if (s_SpVoice.Status.RunningState=SRSEDone)
                Break
            }
        }

    ;-- Remove all event notifications
    ;   Note: This step is performed after the voice has been stopped so that
    ;   the user selection can be automatically reset.
    if s_Sink
        {
        ComObjConnect(s_SpVoice)
        s_Sink:=False
        }

    ;-- Release object
    s_SpVoice:=""

    ;-- Destroy the window so that it can be reused
    gui Edit_TTSGUI:Destroy
    return
    }


;***********************
;*                     *
;*      Word event     *
;*    (Edit_TTSGUI)    *
;*                     *
;***********************
Edit_TTSGUI_OnWord(StreamNumber,StreamPosition,CharacterPosition,Length)
    {
    Global Edit_TTSGUI_hEdit
          ,Edit_TTSGUI_StartSelPos
          ,Edit_TTSGUI_TrackWord

    ;-- Bounce if not tracking
    if not Edit_TTSGUI_TrackWord
        return

    ;-- Calculdate start position
    l_StartPos:=CharacterPosition+Edit_TTSGUI_StartSelPos

    ;-- Select it
    Edit_SetSel(Edit_TTSGUI_hEdit,l_StartPos,l_StartPos+Length)

    ;-- Scroll if necessary
    Edit_ScrollCaret(Edit_TTSGUI_hEdit)
    return
    }


;*************************
;*                       *
;*    EndStream event    *
;*     (Edit_TTSGUI)     *
;*                       *
;*************************
Edit_TTSGUI_OnEndStream(StreamNumber,StreamPosition)
    {
    Global Edit_TTSGUI_hEdit
          ,Edit_TTSGUI_StartSelPos
          ,Edit_TTSGUI_EndSelPos
          ,Edit_TTSGUI_TrackWord

    ;-- Bounce if not tracking
    if not Edit_TTSGUI_TrackWord
        return

    ;-- Reset to original selection
    Edit_SetSel(Edit_TTSGUI_hEdit,Edit_TTSGUI_StartSelPos,Edit_TTSGUI_EndSelPos)
    Edit_ScrollCaret(Edit_TTSGUI_hEdit)
    return
    }
