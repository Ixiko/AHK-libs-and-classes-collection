class callback {
	; Creates a 'compiled' callback function which can be passed to a threadHandler or pool object.
	; See jit.ahk for details.
	__new(fn, decl*){
		; fn, the function to call, an address, or [dll]\FuncName.
		; decl, paramter types and return type and calling convention, eg, "int", "ptr", ..., "cdecl ptr"
		local
		global xlib
		this.fn := this.getFn(fn)				; Get the function from string.
		this.bin := new xlib.jitFn(decl, rt)	; Compiles the function which will call fn
		this.decl := decl						; Stores decl for correct parameter passing and return retrieval
		this.numputParams := this.setupNumputParams()	; operates on this.decl
		this.o := this.setupOffsetArray(decl)	; parameter offset array
		this.rt := rt							; return type
	}
	getFn(fn){	; Either finds a function pointer from string or if fn is an address it just returns the address.
		local
		global xlib
		if type(fn) == "String" {	
			splitpath fn, outFnName, outDllPath
			if outDllPath !== ''
				fn := xlib.ui.getFnPtrFromLib(outDllPath, outFnName, -1)	; Dll file specified
			else
				fn := xlib.ui.getFnPtrFromLib(, outFnName, -1)				; Dll file omitted
		} ; else implies fn is a pointer
		if type(fn) !== "Integer" || !fn
			xlib.exception(A_ThisFunc . " failed, fn: " . string(fn))
		return fn
	}
	setupNumputParams(){
		local
		npp := []
		for k, type in this.decl
			npp[k] := instr(type, 'str') || ( (c:=substr(type, -1)) == '*' || c = 'p' ) ? 'ptr' : type
		return npp
	}
	setupOffsetArray(decl){
		; Builds an array of offsets for the parameters. In 32 bits each parameter offset is an multiple of 4, on 64 bit it is a multiple of 8 (bytes)
		
		static ofn := 	a_ptrsize == 8											; offset function.
						? (type) => 8 											; 64 bit functions takes 8 bytes per param
						: (type) => ( xlib.type.sizeof(type) == 8 ? 8 : 4 ) 	; 32 bit functions takes 4 bytes except for int64 and double
		local
		global xlib
		o := {0:0}	; offset of each parameter in the parameter array. First param is at offset 0, second param is at offset 0+ofn(param1)...
		
		for k, type in decl
			o[k] := o[k-1] + ofn.call(type)			; each iteration moves the offset ofn(type) bytes forward. Hence, param k+1 is at o[k]+ofn(paramk).
		this.paramSize := ceiln( o[o.maxindex()] )	; This is probably not needed, investigate.
		return o
		;
		;	Nested function
		;
		ceiln(x){
			; rounds up to a multiple of a_ptrsize
			return  ceil(x/a_ptrsize)*a_ptrsize
		}
	}
	
	callId := 0			; Each call has an id
	paramCache := []	; Stores all outstanding parameters at callId
	retCache := []		; -- "" -- for returns
	
	setupCall(params*){
		; Writes all parameters to memory and setup return address.
		local
		global xlib
		callId := this.callId++ ; In case of interruptions
		this.paramCache[ callId ] := p := xlib.mem.globalAlloc( this.paramSize )	; p - pointer to params
		, o := this.o																; offsets, zero based index
		, npp := this.numputParams													; numput params, types from decl
		
		for k, par in params														; Write parameters to memory
			numput( par, p, o[k-1], npp[k] )
		
		this.retCache[ callId ] := r :=	xlib.mem.globalAlloc( 8 )					; All returns are 8 bytes, r - return pointer
		
		;
		; This struct is passed to the callback (new thread)
		; It contains a pointer to the work function, its parameters
		; and a pointer to store the return value from the function.
		;
		static structSize := 3 * A_PtrSize
		
		; Set up clean up function for releasing memory when the pv struct is released.
		; => is a closure (due to free, p and r)
				
		free := xlib.mem.globalFree.bind('')						; func for freeing return and params
		cleanUpFn :=   ( struct ) => ( free.call(p), free.call(r) ) ; instances of xlib.struct passes this (it self) when it calls the clean up function.
		
		pv := new xlib.struct( structSize,  cleanUpFn, a_thisfunc . " ( pv )") ; name the struct 'a_thisfunc ( pv )' for db purposes.
		pv.build(	 
					["ptr",	this.fn,	"fn"],
					["ptr",	p, 			"params"],		; pointer to params
					["ptr",	r,			"ret"]			; return pointer
				)
		
		return [pv, callId]
	}
	
	; Object to store and get result from. 
	createResObj(pargs, savedParams, o, npp, pRet, rt, max) {
		; input, free vars.
		; pargs,		pointer to arguments passed by user.
		; savedParams,	list of saved parameters, for things such as 'str' and 'int*'
		; o,			offsets of arguments.
		; npp,			numputParams from the function declaration, for correct types.
		; pRet,			pointer to the return value.
		; rt,			return type, eg, str, int*, char
		; max,			the max index for k parameter of __get
		local
		return	{ base : { __get : func("__get"), __class : "resObj" } }
		__get(this, k := 0, derf*) { ; closure
			; k parameter number to retreive, omit to fetch the return, eg return := res[]
			; derf, dereference the parameter to this type. Eg, if parameter k is a pointer to a pointer to a 'string', str := res[k, "ptr", "str"]
			global xlib
			if type(k) !== "Integer"
				xlib.exception("Invalid type, must be integer, got:"  . type(k))
			if k == 0									; get return value
				r := instr(rt, 'str')	? strget(numget(pRet), rt = 'astr' ? 'cp0' : 'UTF-16') 									; return type is str, astr, wst
										: ( (c:=substr(rt, -1)) == '*' || c = 'p' ) ? numget(numget(pRet), rtrim(rt, '*pP')) 	; return type is int*, charP etc...
																					: numget(pRet, rt)							; return type is int, char etc...
			else if savedParams && savedParams.haskey(k)
				r := savedParams[ k ].val
			else if  k > 0 && k <= max					; get parameter
				r := numget(pargs, o[k-1], npp[k])
			else										; no such parameter
				xlib.exception("Index out of bounds: " . string(k) . " ( 0 - " . string(max) . " )")
			if derf.length() {
				stop := false	; Needs to stop after "str" since remaining values in the array derf are strget params.
				for k, type in derf
					r := instr(type, "str") ? (stop := true , strget( getStrGetParams(derf, k+1, r)* ))	; str
											: numget(r, type)											; number
				until stop
			}
			return r
			; Nested function
			getStrGetParams(arr, ind, strPtr){	; When type is "str", the remaining parameter can be parameters for strget, eg, ret[k, "str", length := 32, encoding := "UTF-8"]
				local
				ret := [strPtr]					; First param for strget is the address.
				while arr.haskey(ind)			; Maximum two iterations else error.
					ret.push arr[ind++]
				return ret
			}
		}
	}
}