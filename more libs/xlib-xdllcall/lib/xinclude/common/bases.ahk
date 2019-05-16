; Common bases.
class bases {
	
	class setErrorBase {
		__set(k, p*) {
			xlib.exception 'Error setting key: ' . string( k ),, -1
		}
	}
	class cleanUpObjError {
		; extends cleanupBase extends getErrorBase, see xlib.bases.extObj
	}
	
	class setgetErrorCleanup {
		; extends cleanupBase, getErrorBase, setErrorBase
	}
	
	class cleanupBase {
		; Methods
		setCleanUpFunction(cleanUpFn) {
			if !cleanUpFn
				return
			if type(cleanUpFn) == 'String' && !cleanUpFn := func(cleanUpFn)
				xlib.exception('Unknown function: ' cleanUpFn)
			if !isobject(cleanUpFn)
				xlib.exception('Invalid function: ' cleanUpFn)
			this.cleanUpFn:=cleanUpFn
		}
		cleanUp(p*){					; Must be implemented
			xlib.exception('Not implemented.')
		}
		; Meta functions
		__delete(){
			local
			try cleanUpFn := this.cleanUpFn
			if cleanUpFn				; User defined clean up function.
				cleanUpFn.call(this)
			this.cleanUp()				; Class defined clean up function.
		}
	}
	
	class getErrorBase {
		__get(pars*){
			local
			global xlib
			errorMessage := "Unknown key(s) (for object of type '" . type(this) . "'):`n`n"
			for k, par in pars
				errorMessage .= (isobject(par) ? "[ object of type: '" . type(par) . "' @adr: " . string(&par) . " ]"  : par . "`t[ type: " . type(par) . " ]"  ) .  "`n"
			throw xlib.exception(errorMessage,, -1)
		}
	}
	
	; Dummy object for 'multiple inheritance'. Primitive, will do for now.
	class extObj {
		; cleanUpObjError
		static ___dummy0 := xlib.bases.extObj.extend(	xlib.bases.cleanUpObjError,
														xlib.bases.cleanupBase,
														xlib.bases.getErrorBase
													)
		
		;
		static ___dummy1 := xlib.bases.extObj.extend(	xlib.bases.setgetErrorCleanup,
														xlib.bases.cleanupBase,
														xlib.bases.getErrorBase,
														xlib.bases.setErrorBase
													)
		
		
		
		extend(o, bases*){
			; o extends bases*
			local
			for k, base in bases
				o := o.base := objclone(base)		
		}
	}
	
}