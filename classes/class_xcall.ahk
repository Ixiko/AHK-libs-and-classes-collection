class xcall extends xlib.callback {
	
	__new(fn, decl*){
		base.__new(fn, decl*)									; initialises this.bin
		this.handler := new xlib.threadHandler()				;
		this.autoCleanUp( true )
		this.checkIfParamsNeedsToBeSaved						; operates on this.decl.
	}
	paramsToSaveList := ''
	checkIfParamsNeedsToBeSaved(){
		; parameters which have type such as 'str' or 'int*' needs to be internally allocated and saved.
		; This method checks which params needs to be saved
		local
		global xlib
		static str_type := 0
		static ptr_type := 1
		for k, type in this.decl
			if instr(type, 'str') 
				saveParam( [k, str_type, type = 'astr' ? 'cp0' : 'utf-16' ] )
			else if (c := substr(type, -1)) == '*' || c = 'p'
				saveParam( [k, ptr_type, rtrim(type, '*Pp')] )
		saveParam(o){
			; help function
			if this.paramsToSaveList == ''
				this.paramsToSaveList := []	; only create object if needed
			this.paramsToSaveList.push o
		}
	}
	autoCleanUp(bool := true){
		this.autoRelease := bool
		return this.handler.autoReleaseAllCallbackStructs( bool )		; automatic clean up if bool is true.
	}
	outstandingCallbacks := []
	nCallbacksRunning := 0
	call(callback, p*){
		; callback, udf script callback.	(Free variable, see callbackRouter below)
		; p, parameters for the worker function.
		; 
		local
		global xlib
		static str_type := 0
		static ptr_type := 1
		
		; Save parameters if needed. That is parameter types such as 'str', 'int*' etc...
		if this.paramsToSaveList !== '' {
			
			savedParams := []
			for k, item in this.paramsToSaveList {			; item is an array: [parameter_index, ptr_type or str_type, type or encoding]
				index := item.1
				if item.2 == str_type {
					savedParam := new xlib[ 'strbuf' ](strlen(p[ index ]), item.3)
					savedParam.str := p[ index ]						; copy the string
				} else {
					savedParam := new xlib[ item.3 ]( p[ index ] )		; copy the value
				}
				p[ index ]	:= savedParam.pointer	; set the pointer to the copied value or string as parameter to be passed to the function.
				savedParams[ index ] := savedParam	; save the parameters to ensure they exist when for the duration of the thread and script callback.
			}
			
		}
		; Note, multi-expression line(s)
		pvid 	 := this.setupCall(p*)	; pvid: [pv, callId], pv is of type 'struct'
		, pv 	 := pvid.1	;	free variable
		, callId := pvid.2  ;	-- '' --
		
		; setup callback free variables for callbackRouter (closure)
		; Avoids bindnig 'this'
		rt 		:= this.rt										; return type
		, o 	:= this.o										; offset array, offsets for each parameter
		, npp	:= this.numputParams							; numputParams, from declaration array
		scriptCallback := func('callbackRouter')				; Script callback, calls udf callback function.
		
		callbackNumber := this.handler.registerTaskCallback(	; Register the task
																;
																this.bin,												; Work function
																pv.pointer,												; Parameters
																scriptCallback,
																false													; Do not start
															)
		this.outstandingCallbacks[ callbackNumber ] := this.autoRelease ? true : pv
		, this.nCallbacksRunning++
		, this.handler.startTask( callbackNumber )																		; Start
		
		return callbackNumber
		;
		;	Callback closure
		;
		callbackRouter( callbackNumber, task ){ ; callbackNumber and task is passed by the thread handler. task == this.handler
			; This function is the scriptCallback called by threadHandler.callbackReciever, when it returns it releases the callback struct 
			; which has the last reference to this closure, hence 'pv' is released and its clean up function is called. It releases the return address and the parameter list.
			; Note, one line
			pRet := pv.get('ret')	; get the pointer to the return value. If desired, it will be dereferenced according to the declared return type, as stored in rt.
			, resObj := xlib.callback.createResObj( pv.get('params'), savedParams, o, npp, pRet, rt, p.length() )	; Create a result object.
			, callback.call(resObj) ; callback is a parameter of the outer function.
		}
	}
}