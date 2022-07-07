; ----------------------------------------------------------------------------------------------------------------------
; Name .........: EWinHook library
; Description ..: Implement the SetWinEventHook Win32 API
; AHK Version ..: AHK_L 1.1.13.01 x32 Unicode
; Author .......: Cyruz - http://ciroprincipe.info
; License ......: WTFPL - http://www.wtfpl.net/txt/copying/
; Changelog ....: Nov. 20, 2013 - v0.1 - First revision
; ----------------------------------------------------------------------------------------------------------------------
; Site .........: https://www.autohotkey.com/boards/viewtopic.php?f=6&t=830
; ----------------------------------------------------------------------------------------------------------------------
; Function .....: EWinHook_SetWinEventHook
; Description ..: Sets an event hook function for a range of events.
; Parameters ...: eventMin         - Lowest event constant to handle. Pass the name as a string (eg: "EVENT_MIN").
; ..............: eventMax         - Highest event constant to handle. Pass the name as a string (eg: "EVENT_MAX").
; ..............: hmodWinEventProc - Handle to the DLL containing the hook function at lpfnWinEventProc or NULL.
; ..............: lpfnWinEventProc - Name or pointer to the hook function. Must be a WinEventProc callback function.
; ..............: idProcess        - PID from which the hook will receive events or 0 for all desktop process.
; ..............: idThread         - Thread ID from which the hook will receive events or 0 for all desktop threads.
; ..............: dwflags          - Flag values specifying hook location and events to skip. Specify the value or
; ..............:                    the combination of values as a string. The accepted values are:
; ..............:                    "WINEVENT_INCONTEXT"
; ..............:                    "WINEVENT_INCONTEXT | WINEVENT_SKIPOWNPROCESS"
; ..............:                    "WINEVENT_INCONTEXT | WINEVENT_SKIPOWNTHREAD"
; ..............:                    "WINEVENT_OUTOFCONTEXT"
; ..............:                    "WINEVENT_OUTOFCONTEXT | WINEVENT_SKIPOWNPROCESS"
; ..............:                    "WINEVENT_OUTOFCONTEXT | WINEVENT_SKIPOWNTHREAD"
; Return .......: -1               - CoInitialize error. Check A_LastError error code:
; ..............:                    E_INVALIDARG  = 0x80070057
; ..............:                    E_OUTOFMEMORY = 0x8007000E
; ..............:                    E_UNEXPECTED  = 0x8000FFFF
; ..............: 0                - Parameters or SetWinEventHook error.
; ..............: HWINEVENTHOOK    - Value identifying the event hook instance.
; Remarks ......: Remember to create a WinEventProc callback function to take care of all the messages.
; ..............: A_LastError is set also in case of success of CoInitialize.
; ..............: The possible success values are: S_OK               = 0x00000000
; ..............:                                  S_FALSE            = 0x00000001
; ..............:                                  RPC_E_CHANGED_MODE = 0x80010106
; Info .........: CoInitialize     - http://goo.gl/UhCKNo
; ..............: SetWinEventHook  - http://goo.gl/DosZa9
; ..............: WinEventProc     - http://goo.gl/wUZU08
; ----------------------------------------------------------------------------------------------------------------------
EWinHook_SetWinEventHook(eventMin, eventMax, hmodWinEventProc, lpfnWinEventProc, idProcess, idThread, dwflags) {
    Static S_OK                              := 0x00000000, S_FALSE                           := 0x00000001
         , RPC_E_CHANGED_MODE                := 0x80010106, E_INVALIDARG                      := 0x80070057
         , E_OUTOFMEMORY                     := 0x8007000E, E_UNEXPECTED                      := 0x8000FFFF
         , EVENT_MIN                         := 0x00000001, EVENT_MAX                         := 0x7FFFFFFF
         , EVENT_SYSTEM_SOUND                := 0x0001,     EVENT_SYSTEM_ALERT                := 0x0002
         , EVENT_SYSTEM_FOREGROUND           := 0x0003,     EVENT_SYSTEM_MENUSTART            := 0x0004
         , EVENT_SYSTEM_MENUEND              := 0x0005,     EVENT_SYSTEM_MENUPOPUPSTART       := 0x0006
         , EVENT_SYSTEM_MENUPOPUPEND         := 0x0007,     EVENT_SYSTEM_CAPTURESTART         := 0x0008
         , EVENT_SYSTEM_CAPTUREEND           := 0x0009,     EVENT_SYSTEM_MOVESIZESTART        := 0x000A
         , EVENT_SYSTEM_MOVESIZEEND          := 0x000B,     EVENT_SYSTEM_CONTEXTHELPSTART     := 0x000C
         , EVENT_SYSTEM_CONTEXTHELPEND       := 0x000D,     EVENT_SYSTEM_DRAGDROPSTART        := 0x000E
         , EVENT_SYSTEM_DRAGDROPEND          := 0x000F,     EVENT_SYSTEM_DIALOGSTART          := 0x0010
         , EVENT_SYSTEM_DIALOGEND            := 0x0011,     EVENT_SYSTEM_SCROLLINGSTART       := 0x0012
         , EVENT_SYSTEM_SCROLLINGEND         := 0x0013,     EVENT_SYSTEM_SWITCHSTART          := 0x0014
         , EVENT_SYSTEM_SWITCHEND            := 0x0015,     EVENT_SYSTEM_MINIMIZESTART        := 0x0016
         , EVENT_SYSTEM_MINIMIZEEND          := 0x0017,     EVENT_SYSTEM_DESKTOPSWITCH        := 0x0020
         , EVENT_SYSTEM_END                  := 0x00FF,     EVENT_OEM_DEFINED_START           := 0x0101
         , EVENT_OEM_DEFINED_END             := 0x01FF,     EVENT_UIA_EVENTID_START           := 0x4E00
         , EVENT_UIA_EVENTID_END             := 0x4EFF,     EVENT_UIA_PROPID_START            := 0x7500
         , EVENT_UIA_PROPID_END              := 0x75FF,     EVENT_CONSOLE_CARET               := 0x4001
         , EVENT_CONSOLE_UPDATE_REGION       := 0x4002,     EVENT_CONSOLE_UPDATE_SIMPLE       := 0x4003
         , EVENT_CONSOLE_UPDATE_SCROLL       := 0x4004,     EVENT_CONSOLE_LAYOUT              := 0x4005
         , EVENT_CONSOLE_START_APPLICATION   := 0x4006,     EVENT_CONSOLE_END_APPLICATION     := 0x4007
         , EVENT_CONSOLE_END                 := 0x40FF,     EVENT_OBJECT_CREATE               := 0x8000
         , EVENT_OBJECT_DESTROY              := 0x8001,     EVENT_OBJECT_SHOW                 := 0x8002
         , EVENT_OBJECT_HIDE                 := 0x8003,     EVENT_OBJECT_REORDER              := 0x8004
         , EVENT_OBJECT_FOCUS                := 0x8005,     EVENT_OBJECT_SELECTION            := 0x8006
         , EVENT_OBJECT_SELECTIONADD         := 0x8007,     EVENT_OBJECT_SELECTIONREMOVE      := 0x8008
         , EVENT_OBJECT_SELECTIONWITHIN      := 0x8009,     EVENT_OBJECT_STATECHANGE          := 0x800A
         , EVENT_OBJECT_LOCATIONCHANGE       := 0x800B,     EVENT_OBJECT_NAMECHANGE           := 0x800C
         , EVENT_OBJECT_DESCRIPTIONCHANGE    := 0x800D,     EVENT_OBJECT_VALUECHANGE          := 0x800E
         , EVENT_OBJECT_PARENTCHANGE         := 0x800F,     EVENT_OBJECT_HELPCHANGE           := 0x8010
         , EVENT_OBJECT_DEFACTIONCHANGE      := 0x8011,     EVENT_OBJECT_ACCELERATORCHANGE    := 0x8012
         , EVENT_OBJECT_INVOKED              := 0x8013,     EVENT_OBJECT_TEXTSELECTIONCHANGED := 0x8014
         , EVENT_OBJECT_CONTENTSCROLLED      := 0x8015,     EVENT_SYSTEM_ARRANGMENTPREVIEW    := 0x8016
         , EVENT_OBJECT_END                  := 0x80FF,     EVENT_AIA_START                   := 0xA000
         , EVENT_AIA_END                     := 0xAFFF,     WINEVENT_OUTOFCONTEXT             := 0x0000
         , WINEVENT_SKIPOWNTHREAD            := 0x0001,     WINEVENT_SKIPOWNPROCESS           := 0x0002
         , WINEVENT_INCONTEXT                := 0x0004 

    ; eventMin/eventMax check
    If ( !%eventMin% || !%eventMax% )
        Return 0

    ; dwflags check
    If ( !RegExMatch( dwflags
                    , "S)^\s*(WINEVENT_(?:INCONTEXT|OUTOFCONTEXT))\s*\|\s*(WINEVENT_SKIPOWN(?:PROCESS|"
                    . "THREAD))[^\S\n\r]*$|^\s*(WINEVENT_(?:INCONTEXT|OUTOFCONTEXT))[^\S\n\r]*$"
                    , dwfArray ) )
        Return 0
    dwflags := (dwfArray1 && dwfArray2) ? %dwfArray1% | %dwfArray2% : %dwfArray3%
        
    nCheck := DllCall( "CoInitialize", Ptr,0       )
              DllCall( "SetLastError", UInt,nCheck ) ; SetLastError in case of success/error
              
    If ( nCheck == E_INVALIDARG || nCheck == E_OUTOFMEMORY ||  nCheck == E_UNEXPECTED )
        Return -1
    
    If ( isFunc(lpfnWinEventProc) )
        lpfnWinEventProc := RegisterCallback(lpfnWinEventProc)
        
    hWinEventHook := DllCall( "SetWinEventHook", UInt,%eventMin%, UInt,%eventMax%, Ptr,hmodWinEventProc
                                               , Ptr,lpfnWinEventProc, UInt,idProcess, UInt,idThread, UInt,dwflags )
    Return (hWinEventHook) ? hWinEventHook : 0
}

; ----------------------------------------------------------------------------------------------------------------------
; Function .....: EWinHook_UnhookWinEvent
; Description ..: Remove a previously istantiated hook.
; Parameters ...: hWinEventHook  - Handle to the event hook returned in the previous call to SetWinEventHook.
; Return .......: 1              - Success
; ..............: 0              - Error
; Info .........: UnhookWinEvent - http://goo.gl/9dDjE3
; ..............: CoUninitialize - http://goo.gl/bWYQ2a
; ----------------------------------------------------------------------------------------------------------------------
EWinHook_UnhookWinEvent(hWinEventHook) {
    nCheck := DllCall( "UnhookWinEvent", Ptr,hWinEventHook )
    DllCall( "CoUninitialize" )
    Return nCheck
}
