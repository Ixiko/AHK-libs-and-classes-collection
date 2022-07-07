; =============================================================
; Example
; =============================================================

; Global IdleMonMenu := Menu()

; Global shutdownTimer := 30, shutdownTimer_reset := 30, _shutdownGui := {hwnd:0}
; Global profiles := Map()
; profiles.CaseSense := false

; ^!+t::{
    ; Global
    ; idler.Toggle() ; hotkey to toggle timer with tray notification
; }

; Global idler := IdleMon() ; create IdleMon instance
; idler.timer_callback := Idle_event ; set callback function (below)

; IdleMonMenu.Add("Open Idle Monitor",menu_idler)
; IdleMonMenu.Add("Toggle Idle Monitor",menu_idler)
; If idler.watchIdle = true
    ; IdleMonMenu.Check("Toggle Idle Monitor")

; A_TrayMenu.Insert("1&","Idle Monitor",IdleMonMenu)

; menu_idler(ItemName, ItemPos, m) {
    ; Global
    
    ; If (ItemName = "Open Idle Monitor")
        ; idler.MakeGui()
    ; Else If (ItemName = "Toggle Idle Monitor") {
        ; If idler.watchIdle {
            ; m.UnCheck(ItemName)
            ; idler.OFF()
        ; } Else {
            ; m.Check(ItemName)
            ; idler.ON()
        ; }
    ; }
; }

; idler.ON() ; turn on timer

; profiles["Computer1"] := [20,"min"] ; define profiles for different computers
; profiles["Computer2"]  := [10,"min"]
; profiles["Computer3"]  := [10,"min"]

; data := profiles[A_ComputerName]
; idler.idleTrigger := data[1]
; idler.idleUnit    := data[2]

; Idle_event(obj, notify:=true) { ; user defined callback
    ; Global
    
    ; If (obj.event = "On") {
    
        ; shutdownTimer := shutdownTimer_reset
        ; If notify
            ; TrayTip "Monitor is ON", "Idle Monitor", 17
        ; IdleMonMenu.Check("Toggle Idle Monitor")   ; Tray Menu modification
        
    ; } Else If (obj.event = "Off") {
    
        ; shutdownTimer := shutdownTimer_reset
        ; SetTimer _ShutdownTimer, 0
        ; If notify
            ; TrayTip "Monitor is OFF", "Idle Monitor", 17
        ; IdleMonMenu.UnCheck("Toggle Idle Monitor")   ; Tray Menu modification
        
    ; } Else If (obj.event = "Execute") {
    
        ; g := Gui("-MinimizeBox -MaximizeBox +AlwaysOnTop","Shutting Down...")
        ; g.OnEvent("close",gui_close)
        ; g.Add("Text","w200 vMsg","Press ESCAPE to cancel shutdown.`r`n`r`nYou have " shutdownTimer " seconds left.")
        ; SetTimer _ShutdownTimer, 1000
        ; g.Show()
        ; _shutdownGui := g
        
    ; } Else If (obj.event = "Cycle") { ; do stuff on cycle
        
    ; }
; }

; _ShutdownTimer() {
    ; Global
    
    ; shutdownTimer -= 1
    
    ; If _shutdownGui.hwnd
        ; _shutdownGui["Msg"].Value := "Press ESCAPE to cancel shutdown.`r`n`r`nYou have " shutdownTimer " seconds left."
    
    ; If shutdownTimer = 0 {
        ; CloseShutdownGui() ; just to close the window, doesn't actually cancel in this case
        ; Shutdown 9 ; force shutdown = 13 ; shutdown power off = 9
    ; }
    
    ; If (idler.Check() = false)
        ; CloseShutdownGui()
; }

; CloseShutdownGui() {
    ; Global
    
    ; If (_shutdownGui.hwnd)
        ; _shutdownGui.Destroy(), _shutdownGui := {hwnd:0}
    ; SetTimer _ShutdownTimer, 0
    ; shutdownTimer := shutdownTimer_reset
    
    ; idler.Reset(false) ; user calls idler.Reset(), passes user-defined parameter
; }

; gui_close(g) {
    ; Global
    
    ; _shutdownGui := {hwnd:0}
; }

; =============================================================
; Idle Monitor
;
;       =======================================================
;       === Methods ===========================================
;       =======================================================
;
;       obj.Check()
;
;           - Returns true when idle, false when not idle.
;           - This is useful for interrupting a user-defined callback that has been
;             executed (with obj.event = "execute"), such as a shutdown function with
;             an additional timer and a GUI to allow the user to cancel by simply moving
;             the mouse or pressing a key on the keyboard.
;
;       obj.MakeGui()
;
;           - The default GUI for monitoring idle data, and to change the timer settings.
;           - You don't have to use this, you can change the settings manually with the
;             properties described below.
;
;       obj.On(p*), obj.Off(p*), obj.Toggle(p*), obj.Reset(p*)
;
;           - Manages the idle timer.  These method meanings are self explanitory.
;           - All of these methods call the user-defined timer callback func.
;           - You can pass additional parameters to process in your callback function.
;           - These additional params are useful, such as to determine if a notification
;             should be shown.
;           - You don't need to specify any params to call these methods.  If you do,
;             they are simply passed on to the timer_callback function.
;
;       obj.AutoCalc()
;
;           - Returns the number of seconds depending on how [ obj.idleTrigger ] and
;             [ obj.idleUnits ] are set.
;           - This return value is only meaningful if [ obj.timerInterval := 1000 ].
;
;       =======================================================
;       === Properties ========================================
;       =======================================================
;
;       obj.timer_callback := your_func
;
;           - User func must take at least 1 parameter.
;           - First param will pass the IdleMon object.
;           - Check [ obj.event ] for "On", "Off", "Execute", or "Cycle".
;           - Note that a CYCLE event can also happen right after an EXECUTE event.
;           - Different events use different properties for useful info.  Read more below.
;
;           Your user func should look something like this...
;
;           your_func(obj, other:="", params:="", ...) {
;
;               If (obj.event = "On") {
;
;                   ; ... do stuff
;
;               } Else If (obj.event = "Off") {
;
;                   ; ... do stuff
;
;               } Else If (obj.event = "Execute") {
;
;                   ; ... do stuff
;
;               }
;
;           }
;
;           ; =====================================
;           ON/OFF event properties
;           ; =====================================
;           
;           obj.IsReset, obj.IsToggle
;
;           ; =====================================
;           Cycle/Execute event properties
;           ; =====================================
;
;           obj.timeIdle                = the number of cycles elapsed (usually seconds)
;           obj.ResetIdleTime           = HH:mm:ss of last reset
;           obj.ResetIdleReason         = mouse, keyboard, or sound
;           obj.triggered               = always true on Execute event
;           obj.mouse, obj.keyboard     = total ticks accumulated
;           obj.sound                   = current sound level (from 0.0 to 1.0)
;
;           ; =====================================
;
;       obj.exit_callback := your_exit_func
;
;           - This script registers its own exit callback to ensure that COM resources are
;             not leaked as a result of the audio devices being polled.  If you want to
;             define your own, it is recommended to do so with this property so that
;             your exit func can coesist with the func defined in this class.
;           - Your func must have ExitReason and ExitCode parameters, or just specify
;             your_exit_func(*) { ...
;
;           your_exit_func(ExitReason, ExitCode) {
;
;               ; ... do stuff
;
;           }
;
;       obj.timerInterval
;
;           - By default the timer is 1000 ms (1 second).
;           - You can set this to any value, and simply count "cycles" instead of seconds.
;
;       obj.idleTrigger
;
;           - By default, this is the "number of cycles" that must elapse before the timer_callback
;             is called.  By default this means "seconds" if [ obj.timerInterval := 1000 ].
;
;       obj.idleUnit
;
;           - by default this is "min" for "minutes"
;           - This is used to properly calculate the number of seconds defined by [ obj.idleTrigger ].
;           - If [ obj.timerInterval != 1000 ] then this property is not used for anything.
;           - If you set this value manually, it should be "days", "hrs", "min", or "sec".
;
;       obj.CheckSound
;
;           - Enabled (true) by default.
;           - Idle status is reset when sound is detected if enabled.
;           - Programatically set this value as needed to modify idle timer functionality.
;
;       obj.watchIdle
;
;           - This acsts as an on/off switch for the idle monitor timer callback.
;           - Setting this to false will NOT send the "Execute" event to the timer_callback
;             when the specified number of cycles in [ obj.idleTrigger ] has elapsed.
;
; 
; =============================================================
class IdleMon {
    _gui := {hwnd:0}, unitOptions := ["days","hrs","min","sec"] ; default for display in main/default idle tracking GUI
    audioMeter := 0
    
    event := "" ; for timer_callback:  values:  On, Off, Execute, Cycle
    
    ; =======================================
    ; Properties useful during ON/OFF events
    ; =======================================
    IsReset := false        ; Toggle/Reset events are comprised of ON/OFF events.
    IsToggle := false       ; Use these properties to find out if an ON/OFF event is spawned from a Toggle() or Reset().
    
    ; =======================================
    ; Properties useful for cycle event
    ; =======================================
    ResetIdleReason := ""
    ResetIdleTime := ""
    timeIdle := 0
    triggered := false
    mouse := 0, keyboard := 0, sound := 0
    
    ; =======================================
    ; Properties set by user
    ; =======================================
    watchIdle := true
    timerInterval := 1000 ; milliseconds
    checkSound := true
    idleTrigger := 20
    idleUnit := "min"
    
    timer_callback := "" ; must accept one parameter for "ON" and "OFF", can accept other params
    exit_callback := ""  ; must have (ExitReason, ExitCode) params
    ; =======================================
    
    __New() {
        this.IdleExitFunc := ObjBindMethod(this,"ExitIdleMonitor") ; set exit func
        OnExit this.IdleExitFunc
        this.IdleTimerFunc := ObjBindMethod(this,"IdleData")
    }
    __Delete() {
        OnExit this.IdleExitFunc, 0
    }
    
    Check() {
        If RegExMatch(this.idleUnit,"i)(sec|min|hrs|days)") ; maybe expand this
            return (this.timeIdle > this.AutoCalc()) ? true : false ; true = idle / false = not idle
        Else
            return (this.timeIdle > this.idleTrigger)
    }
    
    AutoCalc() {
        If (this.idleUnit = "min")
            result := this.idleTrigger * 60
        ELse If (this.idleUnit = "hrs")
            result := this.idleTrigger * 60 * 60
        ELse
            result := this.idleTrigger ; for seconds and non-standard cycles
        
        return result
    }
    
    ExitIdleMonitor(ExitReason, ExitCode) { ; Exit Func, don't leak COM resources
        If this.audioMeter
            ObjRelease(this.audioMeter)
        If (f := this.exit_callback)
            f(ExitReason, ExitCode)
    }
    
    ; =========================================================
    ; ON/OFF funcs
    ; =========================================================
    ON(p*) {
        this.watchIdle := true
        this.triggered := false
        this.timeIdle := 0
        this.event := "On"
        
        SetTimer this.IdleTimerFunc, this.timerInterval
        
        If (f := this.timer_callback)
            f(this,p*)
    }

    OFF(p*) {
        this.watchIdle := false
        this.triggered := false
        this.timeIdle := 0
        this.event := "Off"
        
        SetTimer this.IdleTimerFunc, 0
        
        If (f := this.timer_callback)
            f(this,p*)
    }

    Toggle(p*) {
        this.IsToggle := true
        If this.watchIdle    ; if on, turn off
            this.OFF(p*)
        Else                    ; if off, turn on
            this.ON(p*)
        this.IsToggle := false
    }
    
    Reset(p*) {
        this.IsReset := true
        this.Off(p*)
        this.On(p*)
        this.IsReset := false
    }
    
    MakeGui() {
        g := Gui("+AlwaysOnTop -MaximizeBox -MinimizeBox","Idle Monitor")
        g.OnEvent("close",ObjBindMethod(this,"gui_close"))
        g.Add("Edit","h100 w300 vDisplay ReadOnly")
        g.Add("Text","y+10","Idle Trigger Time:")
        ctl := g.Add("DropDownList","yp-4 w50 vIdleTriggerTime Center",[1,2,3,4,5,10,15,20,30,45])
        ctl.OnEvent("change",ObjBindMethod(this,"gui_events"))
        ctl.Text := this.idleTrigger
        
        ctl := g.Add("DropDownList","x+0 w50 vIdleUnit",this.unitOptions)
        ctl.OnEvent("change",ObjBindMethod(this,"gui_events"))
        ctl.Text := this.idleUnit
        
        ctl := g.Add("Checkbox","vCheckSound x+10 yp+4","Monitor sound")
        ctl.OnEvent("click",ObjBindMethod(this,"gui_events"))
        ctl.Value := this.checkSound
        
        g.Show()
        
        this._gui := g
    }
    gui_events(ctl,info) {
        If ctl.Name = "IdleUnit"
            this.idleUnit := ctl.Text
        Else If ctl.Name = "IdleTriggerTime"
            this.IdleTrigger := ctl.Text
        Else If ctl.Name = "CheckSound"
            this.CheckSound := ctl.value
    }
    
    gui_close(g) {
        g.Destroy(), this._gui := {hwnd:0}
    }
    
    IdleData() { ; main monitor func
        If (this.checkSound)
            this.audioMeter := SoundGetInterface("{C02216F6-8C67-4B5B-9D00-D008E73E0064}")
        
        if this.audioMeter                                          ; set current peak value
            ComCall 3, this.audioMeter, "float*", &peak:=0          ; audioMeter->GetPeakValue(&peak)
        else
            peak := 0
        
        m := A_TimeIdleMouse, k := A_TimeIdleKeyboard ; mouse, keyboard
        
        If (this.mouse < m And this.keyboard < k And peak = 0) { ; analyze for shutdown
            this.timeIdle += 1
            tt := this.idleTrigger * ((this.idleUnit = "sec") ? 1 : (this.idleUnit = "min") ? 60 : (this.idleUnit = "hrs") ? 60*60 : -1)
            
            If this.timeIdle > tt And !this.triggered {
                this.triggered := true
                this.event := "Execute"
                
                If (f := this.timer_callback)
                    f(this) ; execute callback
            }
        } Else { ; not shutting down, idle is reset
            this.timeIdle := 0
            If this.mouse < m
                this.ResetIdleReason := "mouse" ; record reason for idle reset
            Else If this.keyboard < k
                this.ResetIdleReason := "keyboard"
            Else If peak > 0
                this.ResetIdleReason := "sound"
            
            this.ResetIdleTime := FormatTime("HH:mm:ss") ; record time of idle reset
        }
        
        this.mouse := m        ; record data
        this.keyboard := k
        this.sound := peak
        
        If this._gui.hwnd {                  ; show if GUI visible
            idleInfo := "Mouse:`t`t" this.mouse "`r`n"
                      . "Keyboard:`t" this.keyboard "`r`n"
                      . "Sound:`t`t" this.sound "`r`n"
                      . "Time Idle:`t`t" this.timeIdle
            
            this._gui["Display"].Value := idleInfo
        }
        
        If (this.audioMeter)
            ObjRelease(this.audioMeter), this.audioMeter := 0
        
        If (f := this.timer_callback) {
            this.event := "Cycle"
            f(this) ; user callback for timer cycle
        }
    }
}
