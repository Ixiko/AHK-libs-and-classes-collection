class WindowFader {
    
    __New(hwnd) {
        this.speed := 6.0
        this.isFadeIn := true
        this.interval := 1
        this.hwnd := hwnd
        this.alpha := 0.0
        
        
        ; Tick() has an implicit parameter "this" which is a reference to
        ; the object, so we need to create a function which encapsulates
        ; "this" and the method to call:
        this.timer := ObjBindMethod(this, "_tick")
    }
    
    
    
    fadeIn() {
        this.isFadeIn := true
        this._startTimer()
    }
    
    fadeOut() {
        this.isFadeIn := false
        this._startTimer()
    }
    
    _startTimer() {

        ; KNOWN LIMITATION: SetTimer requires a plain variable reference.
        timer := this.timer
        SetTimer % timer, % this.interval
        
        this.lastTime := A_TickCount
    }
    
    _stopTimer() {
        ; To turn off the timer, we must pass the same object as before:
        timer := this.timer
        SetTimer % timer, Off
    }
    
    ; In this example, the timer calls this method:
    _tick() {

        delta := (A_TickCount - this.lastTime) / 1000.0
        this.lastTime := A_TickCount
    
        if (this.isFadeIn and this.alpha > 1.0) {
            this.alpha := 1.0
            this._stopTimer()
        }  
        if ( !this.isFadeIn and this.alpha <= 0.0 ) {
            this.alpha := 0.0
            this._stopTimer()
        }
        
        if (this.alpha > 0.0) {
            WinShow, % "ahk_id " this.hwnd
        }
        if (this.alpha <= 0.0) {
            WinHide, % "ahk_id " this.hwnd
        }
        
        
        ; Apply animation curve
        val := sin( this.alpha * 1.57079632679 ) * 256
        
        
        WinSet, Transparent, % val, % "ahk_id " this.hwnd
        
        
        step := delta * this.speed
        step := this.isFadeIn ? step : -step
        this.alpha += step
    }

}