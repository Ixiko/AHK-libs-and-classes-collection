CallbackCreate(Function , Options := "", ParamCount := ""){
	; Address := CallbackCreate(Function , Options := "", ParamCount := Function.MinParams)
	; see: https://lexikos.github.io/v2/docs/commands/CallbackCreate.htm
	; Note that the v2 version doesn't affect A_EventInfo, this version does.
	/*
	This function fails when:
	Function is not an object or a valid function name.
	Function has a MinParams property which exceeds the number of parameters that the callback will supply.
	ParamCount is negative.
	ParamCount is omitted and: 1) Function has no MinParams property; or 2) the & option is used with the standard 32-bit calling convention.
	*/
	local
	; Input validation start. This is partly 'ported' from BIF_CallbackCreate (a097)
	if (!io := isobject(Function)) && !isfunc(Function)
		throw exception("Parameter #1 invalid.", -1)
	
	fn := "" ; If a function name was passed, retrieve the function reference below.
	minparams := ( io ? Function : fn := func(Function) ).MinParams 
	
	if (minparams != "")	
		if minparams is not number	; if the MinParams property doesn't return a number, minparams is 0.
			minparams := 0
	has_minparams := minparams != "" ? true : false
	minparams := has_minparams ? minparams : 0
	
	use_cdecl := instr(options, "C")
	
	require_param_count := a_ptrsize == 4 && !use_cdecl
	pass_params_pointer := instr(options, "&", true)
		
	if (ParamCount != "") {
		actual_param_count := ParamCount
		if ( actual_param_count < 0 || ( has_minparams && (pass_params_pointer ? 1 : actual_param_count) < minparams ) )
			throw exception("Parameter #3 invalid.", -1)
	} else if (!has_minparams || (pass_params_pointer && require_param_count)) {
		throw exception("Parameter #3 must not be blank in this case.", -1)
	} else {
		actual_param_count := minparams
	}
	if (a_ptrsize == 4 && (!use_cdecl && actual_param_count > 31) )
		throw exception("Parameter #3 invalid.", -1)
	; Input validation end.
	
	Function := io ? Function : fn ; Make sure Function is a function reference and not just a name, avoids finding the reference on each callback.
	
	cbo := { 	actual_param_count : actual_param_count			; Callback object, its address is passed to the callback router vi a_eventinfo
			,	pass_params_pointer : pass_params_pointer
			, 	Function : Function } 
	
	if (fn && !pass_params_pointer && !fn.isvariadic) {
		; Meaning the name of a non variadic function was passed as Function, and not using the '&' option.
		; No need to route the callback.
		cb := registercallback(fn.name, options, actual_param_count)
	} else {
		; A Function object or name of a variadic function or '&' option was passed. Needs to route the callback
		static router_fn := "__callbackcreate_router__"
		cb := registercallback(router_fn, options, actual_param_count, &cbo)
	}
	if !cb	; Hopefully, this shouldn't happen
		throw exception("registercallback failed")	
		
	objaddref( &cbo )		; This is decremented in CallbackFree when freeing the callback.
	CallbackFree(cbo, cb)	; Add to cache.
	return cb				; Return the callback address
}

CallbackFree(Address, cb := "")	{
	; Address, the address to free.
	; cb, internal use, always omit. Used for setting/getting callback functions
	; see: https://lexikos.github.io/v2/docs/commands/CallbackCreate.htm
	static callback_cache := []	; Contains all callback objects.
	if cb { ; add to cache
		if isobject(Address)
			return callback_cache[ cb ] := Address
		throw exception("?")
	}
	if address is not number
		address := 0
	if (address < 65536 && address >= 0)
		throw exception("Parameter #1 invalid.", -1)
	; Free the address and callback object.
	dllcall("GlobalFree", "Ptr", Address, "Ptr")
	objrelease( &callback_cache.delete( Address ) )
	return
}

__callbackcreate_router__(p*) {	
	; Help function.
	; Routes all callbacks.
	; Since this function is variadic, all parameters are passed by address.
	static p_type := a_ptrsize == 4 ? "uint" : "int64"
	local
	cbo := object( a_eventinfo )	; a_eventinfo contains the address of the callback object.
	if !cbo.pass_params_pointer {	; The '&' option was not used, fetch all parameters and pass directly to the script callback.
		args := []
		loop % cbo.actual_param_count
			args.push( numget(p+0, a_ptrsize * (a_index-1), p_type) )
	} else {						; using the "&" option, just pass the pointer to the arguments to the script callback.
		args := [p]
	}
	return cbo.function.call( args* )	; Call script callback
}