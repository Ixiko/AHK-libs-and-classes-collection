; Compability:
;	Thread pool api is for windows vista or newer. (A few features are windows 7 or newer only.)
; Note:
; 	TP_IO currently not implemented.
;	Uses clean-up group, all callback objects must be created with parameter: poolHasCleanUpGroup := true
;	This should probably be redesigned - split timer, work and wait handling.
class threadPool extends xlib.bases.cleanupBase {

	; Important class members:
	;	pool - the thread pool structure
	;	cbe - the callback environment structure
	;	cleanUpGroup - the thread pool clean-up group
	;
	; Important return values:
	;	cbid - callback id, returned by submitWork, setTimer,... addWork, addTimer. It is used to reference the callback. Use with eg, start and wait.
	__new(min  := 4, max := 4, pfng := 0){
		this.initThreadPool(min, max, pfng)
	}
	; Internal use methods
	initThreadPool(min, max, pfng){
		; Creates thread pool of min-max threads.
		; Initialises threadPoolEnvironment and cleanup group.
		max := max ? max : min														; Set max to min if max was omitted.
		this.pool := new xlib.poolbase.TP_POOL()									; Create threadPool. 	
		                                                                       		
		this.pool.max :=	max														; Set max threads
		this.pool.min :=	min                                                   	; Set min threads				
		            	                                                        	
		this.cbe := new xlib.poolbase.TP_CALLBACK_ENVIRON()  						; Create a thread pool callback environment
		this.cleanUpGroup := new xlib.poolbase.TP_CLEANUP_GROUP() 					; Create thread pool clean-up group
		this.cbe.pool := this.pool.getPointer()										; Associate the this thread pool with the callback environment.	(Sets the Pool (ptpp) member of cbe struct)
		this.cbe.cleanUpGroup[pfng] := this.cleanUpGroup.getPointer()				; Associate the clean-up group with the callback environment.	(Sets the CleanupGroup (ptpcg) and the CleanupGroupCancelCallback (pfng) members of the cbe struct)
				
		return
	}
	static poolHasCleanUpGroup := true	; Indicates that a clean-up group closes all callback objects.
	callbacks := []	; Contains all callback objects. On the form: {callback:TP_X, params:params}. X is work, timer or wait. params are for the submition.
	; User methods
	startAll(){
		; Starts all added work, timer and wait objects.
		local
		if !this.callbacks.length()
			return false
		for k, cbo in this.callbacks
			this.submitCallbackObject(cbo)
		return true
	}
	start(cbid){
		; Starts a work, timer or wait object, callback id - cbid.
		local
		if !this.callbacks.haskey(cbid)
			return false
		this.submitCallbackObject(this.callbacks[cbid])
		return true
	}
	waitAll(){
		; Wait for all callbacks to return
		; Waiting freezes the script thread.
		if !this.callbacks.length()
			return false
		for k, cbo in this.callbacks
			cbo.callback.wait()
		return true
	}
	wait(cbid){
		; Wait for a callback to return.
		; Waiting freezes the script thread.
		if !this.callbacks.haskey(cbid)
			return false
		this.callbacks[cbid].callback.wait()
		return true
	}
	
	; Work:
	work_callback := 0
	addWork(pfnwk, pv := 0, p*){
		; Creates a work object, which is associated with the pools callback environment
		; but doesn't submit it. Use startAll() or start(cbid)
		; This method depends on createWork being called already. Redesign.
		local work := this.createWork(pfnwk, pv, p*)
		local cbo := {callback : work, params : [], work_callback : this.work_callback}	; create a callback object to store data
		local cbid := this.callbacks.push( cbo )										; save it
		if this.work_callback
			setCleanUpFunction cbo, (self) => self.work_callback.ss := '' ; releases the sync struct, must be done to properly release the poolCallback object. 
		this.work_callback := ''	; this is setup in createWork if user wants script callback, it is saved in the callback object and pushed to the pool callbacks above
		return cbid
		setCleanUpFunction(o, cuf){
			objsetbase o, {__delete : cuf}	; call cuf when o is released
		}
	}
	createWork(pfnwk, pv := 0, p*){
		; returns a work object, which is associated with the pools callback environment
		local
		global xlib
		if p.length() {	; handle script callback
			;cbid := this.callbacks.length() + 1
			
			this.work_callback := this.wrapCallback(pfnwk, pv, xlib.poolCallback.work, p)	; pfnwk and pv are byref an updated to point to the wrapper function and its arguments
			;work_callback := new xlib.poolCallback.work(pfnwk, pv, p*)			
			;pfnwk := work_callback.getEntryBin()
			;pv := work_callback.getpParams()
			;this.work_callback := work_callback
		}
		work := new xlib.poolbase.TP_WORK(pfnwk, pv, this.cbe.getPointer(), this.poolHasCleanUpGroup)
		return work
	}
	submitWork(callback := 0, pfnwk := 0, pv := 0){
		; Creates a work object, which is associated with the pools callback environment
		; and submits it
		
		if !pfnwk
			xlib.exception('pfnwk must be passed.')
		
		local p := this.setupCallbackParam(callback)
		local cbid := this.addWork(pfnwk, pv, p*)
		this.start(cbid)
		return cbid
	}
	; Timer:
	timer_callback := 0 ; 
	addTimer(pfnti, pv := 0, msPeriod := 0, ftDueTime := 0, msWindowLength := 0, p*){
		if p.length()  ; handle script callback
			this.timer_callback := this.wrapCallback(pfnti, pv, xlib.poolCallback.timer, p)		
		local cbo := this.createTimer(pfnti, pv, msPeriod, ftDueTime, msWindowLength, p*)
		local cbid := this.callbacks.push(cbo)	
		return cbid
	}
	createTimer(pfnti, pv := 0, msPeriod := 0, ftDueTime := 0, msWindowLength := 0, p*){
		; Creates a timer object
		; this method depends on addTimer being called before it. See this.timer_callback. Redesign
		static ft_factor := 10000	; Automatically converts ftDueTime to ms rather than nano-seconds. Set to 1 to avoid this.
		local ft, pftDueTime
		
		local timer := new xlib.poolbase.TP_TIMER(pfnti, pv, this.cbe.getPointer(), this.poolHasCleanUpGroup)
		; Set up pftDueTime
		if ftDueTime == '' {								; If blank, the timer is canceled. Note: Use cancelTimer instead.
			pftDueTime := 0
		} else if type(ftDueTime) == 'Integer' {
			ft := new xlib.FILETIME(ftDueTime*ft_factor)
			pftDueTime := ft.pointer
			timer.ft := ft ; Need to store the FILETIME object, it will be released when the TIMER object is released.
		} else if type(ftDueTime) == 'xlib.FILETIME' {
			pftDueTime := ftDueTime.pointer
		} ; end set up pftDueTime
		local cbo := {callback:timer, params:[pftDueTime, msPeriod, msWindowLength], timer_callback : this.timer_callback} 	; Note the order of params [...]
		if this.timer_callback
			setCleanUpFunction cbo, (self) => self.timer_callback.ss := '' ; releases the sync struct, must be done to properly release the poolCallback object.
		
		this.timer_callback := ''	; this is setup in addTimer if user wants script callback, it is saved in the callback object and pushed to the pool callbacks above
		return cbo
		setCleanUpFunction(o, cuf){
			objsetbase o, {__delete : cuf}	; call cuf when o is released
		}
	}
	setTimer(callback := 0, pfnti := 0, pv := 0, msPeriod := 0, ftDueTime := 0, msWindowLength := 0){
		if !pfnti
			xlib.exception('pfnti must be passed.')
		local p := this.setupCallbackParam(callback)
		local cbid := this.addTimer(pfnti,pv, msPeriod, ftDueTime, msWindowLength, p*)
		this.start(cbid)
		return cbid
	}
	cancelTimer(cbid){
		local
		global xlib
		; cancels the timer at cbid  - callback id.
		if !this.callbacks.haskey( cbid )
			xlib.exception('Invalid callback id: ' . string(cbid) . '.') 
		timer := this.callbacks[cbid].callback
		if type(timer) !== 'xlib.poolbase.TP_TIMER'
			xlib.exception('Invalid method for type: ' . type(timer) . ' ( callback id: ' . string(cbid) . ' ).') 
		timer.submit(0, 0, 0)
	}
	; Internal methods
	wrapCallback(byref thread_callback, byref pv, wrapper_class, script_callback){
		; Help function for createWork, createTimer, ...
		local
		global xlib
		wrapped_callback := new wrapper_class(thread_callback, pv, script_callback*)
		thread_callback := wrapped_callback.getEntryBin()	; Replacing the thread_callback with the wrapper function
		pv := wrapped_callback.getpParams()					; and new arguments which contains the wrapped function and its arguments.
		return wrapped_callback								; Must be saved by the caller to avoid early release.
		
	}
	setupCallbackParam(callback){
		; Help function for submitWork, setTimer, ...
		return callback ? (isobject(callback) ? callback : [callback]) 		; callback is an array of parameters suitable for the relevant poolCallback object.
						: []												; No callback 
	}
	submitCallbackObject(cbo){
		; Help function for start()
		local callback, params
		callback := cbo.callback
		params := cbo.params
		callback.submit(params*)
	}
	; Mandatory clean-up
	cleanUp(){
		; Destroys the pool, the callback environment and clean-up group
		
		this.callbacks := ''
		this.cleanUpGroup := ''
		this.cbe := ''
		this.pool := ''
	}
}