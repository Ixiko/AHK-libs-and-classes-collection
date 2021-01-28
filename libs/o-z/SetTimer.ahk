/*
    AutoHotkey: Asynchronous Timer API (SetTimer)
    Copyright © 2013 Donald Atkinson (a.k.a. FuzzicalLogic)
    ----------------------------------------------------------------------------
    
    Provides a convenience API Class and Function for reducing the code required
    to utilize Asynchronous Timers. This makes AsyncTimer stdlib compliant and 
    allows two distinct methods for include:
    
        - Call SetTimer()
        - include <settimer.ahk>
        
    SetTimer: A completely abstracted way to create disposable timers. Parameters
    are as follows:
    
        - callback (string)  - The function to callback. This may also be a global
             or static identifier/expression to an object's method.
        - time     (integer) - The lifetime (ms) of the Timer.
        - interval (integer) - The frequency (ms) of the Timer messages.
        - message  (integer) - The Windows Message ID.
        
    AsyncTimer Class:
    A convenience API for creating and managing disposable and reusable timers.
    This also automates several tasks for you, including getting the hwnd of the
    current script and retrieving the hwnd of the timer.
    
        Methods:
        - Start()
        - Pause()
        - Resume()
        - Stop(keep := false)
    ----------------------------------------------------------------------------
*/

SetTimer(pCallback := 0, pTime := 0, pInterval := 0, pMessage := 0, pTimerId := 0) {
    timer := new AsyncTimer(pCallback, pTime, pInterval)
    if (pMessage)
        timer.Message(pMessage)
    if (pTimerId)
        timer.ID(pTimerId)
    return timer.Start()
}

    class AsyncTimerPrivate {
        static MSG_PAUSE_ID  := 0x0CEC
        static MSG_RESUME_ID := 0x0CED
        static MSG_STOP_ID   := 0x0CEE
    
    
        setHWND() {
        ; Just in case
            old := A_DetectHiddenWindows
            DetectHiddenWindows, on
            AsyncTimer.hwnd  := WinExist("Ahk_PID " DllCall("GetCurrentProcessId"))
        ; Just in case - Preserve the old setting
            DetectHiddenWindows, %old%
        }
    
        RunTimer() {
        ; Build the Parameters string
            params := "/hwnd " . AsyncTimer.hwnd . " /msgid " . this.msg
            if (this.id)
                params := params . " /id " . this.index
            if (this.lifetime)
                params := params . " /time " . this.lifetime
            if (this.interval)
                params := params . " /interval " . this.interval
            if (this.debug)
                params := params . " /debug"
        ; Run the Script/Executable
            
            script := a_scriptdir "\lib\asynctimer.ahk "
            Run, % script params
        }
    }

/*
    Methods:
      Start
      Pause
      Resume
      Stop
*/
class AsyncTimer extends AsyncTimerPrivate {
    static DEFAULT_MSG := 0x0400
    
    static hwnd := 0
    static path := A_ScriptDir "\Lib\"
    
    static TIMERS := []

    index := 0
    msg := AsyncTimer.DEFAULT_MSG
    callback := ""
    lifetime := 250
    interval := 0
    disposable := false
    idtimer := 0

    debug := false
    
    __New(pCallback := 0, pTime := 0, pInterval := 0, pMsg := 0) {
    ;hWnd is shared across all Timers
    if (! AsyncTimer.hwnd)
            this.setHWND()
    ;This is required, but cannot stop "__New"
        if (pCallback)
            this.callback := pCallback

        if (pInterval) {
            this.interval := pInterval
            this.lifetime := pTime
        }
        else if (pTime) {
            this.lifetime := pTime
        }

        if (pMsg) {
            this.msg := pMsg
        }
        
        AsyncTimer.TIMERS.insert(this)
        this.index := AsyncTimer.TIMERS.MaxIndex()
    }
    
    Message(pMsg := 0) {
        if (pMsg) {
            this.msg := pMsg
            return this
        }
        else return this.msg
    }

    ID(pID := 0) {
        if (pID) {
            this.idtimer := pID
            return this
        }
        else return this.idtimer
    }
   
    Start() {
        OnMessage(this.msg, "AsyncTimerOnMessageProxy", 30)
        this.RunTimer()
    ; Chain the function
        return this
    }
    
    Pause() {
        PostMessage, % base.MSG_PAUSE_ID, 0, 0, , % "ahk_id " this.window
    ; Chain the function
        return this
    }
    
    Resume() {
        PostMessage, % base.MSG_RESUME_ID, 0, 0, , % "ahk_id " this.window
    ; Chain the function
        return this
    }
    
    Stop(dispose := 1) {
        PostMessage, % base.MSG_STOP_ID, 0, 0, , % "ahk_id " this.window
    ; Now, we decide whether to keep it in the TIMERS array
        if (!keep) {
;            if keep is integer {
;                keep := this.keepAlive
;            }
        }
        
;        if (!keep)
        
    ; Chain the function
        return this
    }
    
    DebugMode(value := 0) {
    ; Interrupt the Message
        this.debug := ! this.debug
        
        if (this.debug && this.running) {
            OnMessage(this.msg, "AsyncTimerDebug")
        }
        else if (this.running && !(this.debug)) {
            OnMessage(this.msg, this.callback)
        }
        
    ; Chain the function
        return this
    }
    
}


; TODO: Implement debug
;       Requires (a) connecting to hwnd
;       Requires (b) creating static array
AsyncTimerOnMessageProxy(wParam, lParam, msg, hwnd) {
    t := AsyncTimer.TIMERS[wParam]
    if (lParam = wParam)
        isFinal := true
    else
        isFinal := false
; Gets the hwnd of the Timer so that Pause/Resume/Stop work correctly
    if (! t.timerhwnd)
        t.timerhwnd := hwnd
; Call the Resolver
    fxn := ResolveFunction(t.callback)
    if (fxn)
        fxn.(t.idtimer, isFinal)
}

AsyncTimerDebug(wParam, lParam, msg, hwnd) {
    
}

ResolveFunction(name) {
; Begin the Callback Expression Resolution Array
    resolve := []
    scan := name

    if (Func(name)) {
        return %name%
    }
    else if (isLabel(name)) {
    }
    else {
        While scan {
            pos := InStr(scan, ".") 
            if (pos) {
                expression := SubStr(scan, 1, pos - 1)
                scan := SubStr(scan, pos + 1)
            }
            else {
                expression = %scan%
                scan := 0
            }
            resolve.Insert(expression)
        }
    ; Call the Function
        fxn := 0
        to := resolve.MaxIndex() 
        Loop %to% {
        if (!fxn) {
                e := resolve[A_Index]
                if (Func(e))
                    fxn := Func(e)
                else
                    fxn := %e%
            }
            else {
                f := resolve[A_Index]
                e := fxn[f]
                fxn := e
            }
        }
        return fxn
    }
}
