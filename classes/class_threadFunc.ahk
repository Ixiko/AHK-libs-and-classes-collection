class threadFunc {
	boundParams:=[]													; Holds bound parameters. Set via bind() method.
	retVals:=[]														; Holds return values until properly returned.
	retId:=0														; For tracking positions in retVals.
	; User methods
	__new(fn,boundParams:="",threadSettings:="",failRet:="",mute:=true){
		this.fn:= IsObject(fn) ? fn : Func(fn)						; No check for isFunc, want to be able to pass bound func.
		this.bind(boundParams*)
		this.setThreadSettings(threadSettings)
		this.failRet:=failRet										; Specify what to return if the new thread fails.
		this.mute:=mute												; Set to true to suppress exceptions. True is default.
	}
	call(params*){
		local
		retId:=++this.retId											; Increment the retId.
		el:=ErrorLevel												; Save the errorlevel for the calling thread.
		success:=DllCall(rc:=callbackcreate(this.newThread.bind(this, params, retId),,0))	; Call in a new thread.		
		callbackfree(rc)											; Free memory.
		ErrorLevel:=el												; Restore the calling threads errorlevel.
		if success
			ret:=this.retVals[retId], this.retVals.Delete(retId)	; Fetch the return value, and remove it from the array.
		return success ? ret : this.failRet							; Return it.
	}	
	bind(params*){
		return this.boundParams := params 							; These params will be passed first when "this" threadFunc is called
	}
	setThreadSettings(set:=""){
		local
		this.settingFuncs:=""
		if (set="")													; thread settings cleared.
			return
		this.settingFuncs:=[]
		for fn, params in set {										; Make array of func objects to call in the new thread.
			params:=IsObject(params)?params:StrSplit(params,",")
			fn:=IsObject(fn)?fn:func(fn)							; Mostly intended to fit v2.
			this.settingFuncs[fn]:=params							; Keep all f/bf objects in the settingFuncs arrays.
		}
		return
	}
	; Internal methods
	newThread(params, retId){
		local
		; This is in a new thread.
		; Prepare thread settings
		if this.settingFuncs
			for sFn, sParams in this.settingFuncs
				sFn.call(sParams*)									; Call the settings function.
		; Prepare call parameters
		combinedParams:=[]											; For combining bound params and "call" params.
		if this.boundParams.length()
			combinedParams.Push(this.boundParams*)					; First bound params.
		combinedParams.Push(params*)								; The "call" params.
		this.retVals[retId]:=this.fn.call(combinedParams*)			; Call the function and store the return in this.retVals[retId].
		return true													; Return true to indicate success.
	}
}