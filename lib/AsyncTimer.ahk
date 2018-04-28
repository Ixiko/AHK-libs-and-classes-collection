/*
    AutoHotkey:Asynchronous Timer
    Copyright © 2013 Donald Atkinson (a.k.a. FuzzicalLogic)
    ----------------------------------------------------------------------------

    An External Timer that runs in its own memory space to post windows messages
    a specified intervals. If /time is specified, the script will post a message
    when the script completes. If /interval is specified, the script will post a
    message every X milliseconds until /time has been reached, and then a final
    message will be sent.
    
    This is not meant to send information, merely to indicate when a window should
    perform a timed action.
    
    Released under the LGPLv3 licence
    http://www.gnu.org/licenses/lgpl.txt

    Usage: Run, path\to\timer.ahk %parameters%
           Run, path\to\timer.exe %parameters%
           
    Command Line Parameters:
    
    /hwnd      - REQUIRED - the hwnd of the script/window that is requesting
                 the timed messages.
    /id        - A numerical identifier passed back in the message wParam. In 
                 case there are multiple timers using the same message
    /msg       - The windows message to return. Defaults to 1024 (0x0400)
    /time      - The lifetime (in ms) of the timer. 
    /interval  - The frequency (in ms) of messages
    /debug     - Whether to display debug messages (currently only in msgbox)
    
    ----------------------------------------------------------------------------
*/

#NoEnv
#NoTrayIcon
#SingleInstance off
DetectHiddenWindows, on

    PAUSE_MESSAGE_ID    := 0x0400
    RESUME_MESSAGE_ID   := 0x0401
    STOP_MESSAGE_ID     := 0x0402
    
; Initialize values
    AsyncTimer_TimerID      := 0
    AsyncTimer_Millisecs    := 0
    AsyncTimer_MessageID    := 1024

; Status Variables
    AsyncTimer_IsStopped    := false
    AsyncTimer_IsPaused     := false
    

; Handle Script Parameters
; ------------------------
; This script doesn't do anything. It just waits for the passed amount of time and returns
; the value that was sent to it. This allows multiple "Timers" to be run "asynchronously"
; with different responses.

    Loop %0%
    {
        param := %a_index%
        if (param = "/id")
        {   idx := a_index + 1
            val := %idx%
            if (val)
                AsyncTimer_TimerID = %val%
        }
        else if (param = "/time")
        {   idx := a_index + 1
            val := %idx%
            if (val)
                AsyncTimer_Millisecs = %val%
        }
        else if (param = "/hwnd")
        {   idx := a_index + 1
            val := %idx%
            if (val)
                AsyncTimer_ForPID = %val%
        }
        else if (param = "/msgid")
        {   idx := a_index + 1
            val := %idx%
            if (val)
                AsyncTimer_MessageID = %val%
        }
        else if (param = "/interval")
        {   idx := a_index + 1
            val := %idx%
            if (val)
                AsyncTimer_Interval = %val%
        }
        else if (param = "/debug")
            AsyncTimer_Debug := true
    }

    OnMessage(STOP_MESSAGE_ID, "StopAsyncTimer")
    if (AsyncTimer_Interval)
        OnMessage(PAUSE_MESSAGE_ID, "PauseAsyncTimer")
    
    if (!AsyncTimer_ForPID) {
        if (AsyncTimer_Debug)
            msgbox An Invalid HWND was provided to AsyncTimer.
        ExitApp 
    }

; Prepare for Stop Message
    if (AsyncTimer_Interval && AsyncTimer_Millisecs)
    {   While (AsyncTimer_Millisecs > AsyncTimer_Interval)
        {   if (AsyncTimer_IsStopped) {
                break
            }
            else if (AsyncTimer_IsPaused) {
                Sleep, %AsyncTimer_Interval%
            }
            else {
                Sleep, %AsyncTimer_Interval%
                AsyncTimer_Millisecs := AsyncTimer_Millisecs - AsyncTimer_Interval
                PostMessage, %AsyncTimer_MessageID%, %AsyncTimer_TimerID%, , , ahk_id 

%AsyncTimer_ForPID%
            }
        }
    }
    else if (AsyncTimer_Interval && !AsyncTimer_Millisecs)
    {   While (AsyncTimer_Interval)
        {   if (AsyncTimer_IsStopped) {
                break
            }
            else if (AsyncTimer_IsPaused) {
                Sleep, %AsyncTimer_Interval%
            }
            else {
                Sleep, %AsyncTimer_Interval%
                PostMessage, %AsyncTimer_MessageID%, %AsyncTimer_TimerID%, , , ahk_id 

%AsyncTimer_ForPID%
            }
        }
    }

    
; Do nothing for the specified amount of time
    if (! AsyncTimer_IsStopped)
        Sleep, %AsyncTimer_Millisecs%
; Return the expected answer
    if (! AsyncTimer_IsStopped) {
        PostMessage, %AsyncTimer_MessageID%, %AsyncTimer_TimerID%, %AsyncTimer_TimerID%, , ahk_id 

%AsyncTimer_ForPID%
    }
    ExitApp

StopAsyncTimer(wParam, lParam, msg, hwnd) {
    if (hwnd = AsyncTimer_ForPID)
        AsyncTimer_IsStopped := true
}

PauseAsyncTimer(wParam, lParam, msg, hwnd) {
    if (hwnd = AsyncTimer_ForPID) {
        AsyncTimer_IsPaused := true
        OnMessage(RESUME_MESSAGE_ID, "ResumeAsyncTimer")
        OnMessage(PAUSE_MESSAGE_ID, "")
    }
}

ResumeAsyncTimer(wParam, lParam, msg, hwnd) {
    if (hwnd = AsyncTimer_ForPID) {
        AsyncTimer_IsPaused := true
        OnMessage(PAUSE_MESSAGE_ID, "PauseAsyncTimer")
        OnMessage(RESUME_MESSAGE_ID, "")
    }
}
