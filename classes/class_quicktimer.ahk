class quickTimer {
	; User methods
	__new(callback, priority:=0){
		this.callback := callback
		this.priority := priority
		quickTimer.timers[this] := ""	; store the instance for xxxAll() methods
	}
	; Timer states:
	; 1 - running
	; 0 - stopped
	; -1 - deleted (or never started)
	state := -1
	start(){
		if this.state == 1
			return
		setTimer(this.callback, 0, this.priority)
		this.state := 1	
		local pte := quickTimer.enabled++
		if !pte
			quickTimer.toggleQT()
		return this
	}
	stop(){
		if this.state != 1
			return
		this.state := 0
		quickTimer.enabled--
		setTimer(this.callback, "off")
	}
	delete(){
		if this.state == 1
			this.stop()
		this.state := -1
		setTimer(this.callback, "delete")
		quickTimer.timers.delete this
		this.base := "" ; will throw error on further use.
	}
	startAll(){
		this.loopTimers(quickTimer.start)
	}
	stopAll(){
		this.loopTimers(quickTimer.stop)
	}
	deleteAll(){
		this.loopTimers(quickTimer.delete)
	}
	; Interal methods
	static timers := []
	loopTimers(fn){
		local
		global quickTimer
		for timer in quickTimer.timers
			fn.call(timer)
	}
	static enabled := 0
	toggleQT(){
		static tfn := quickTimer.quickFn.bind(quickTimer)
		setTimer(tfn, "-0")
	}
	static speed := -1 ; fastest. Set to -1 for fastest, 0 for fast or 1+ for 'quite' slow
	quickFn(){
		static dllsleep := func("dllcall").bind("Sleep", "uint")
		critical false
		while this.enabled
			(this.speed == -1) ? "" : dllsleep.call(this.speed), sleep(-1)
		
	}
}