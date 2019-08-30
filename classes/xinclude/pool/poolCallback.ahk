; Note that, 'callback', always refers to the thread callback, i.e., the compiled function which does the async work. 
; The synced call back to the script, is specified via 'scriptCallback', a functor.
class poolCallback {
	; class PCB_BASE is base class for
	;	* wait
	;	* work
	;	* timer
	;	* IO - not implemented.
	; The classes sets up a pointer to a thread entry function and its arguments, the thread entry is calling the udf and optionally syncs with the script thread, can be conditional. 
	; 	Also, optionally calls 'clean-up' functions, see cleanupfunction.c
	class PCB_BASE extends xlib.bases.cleanupBase {
		; Classes extending this base must specify raw32 and raw64 arrays. See initBins()
		; User
		
		__new(callback, callbackParams := 0, scriptCallback := 0, cleanup := 0, condFns := 0) {
			local
			global xlib
			this.initBins																	; initialises binary function, see xlib\c source\, for details on the function implementations.
			this.setupCallback callback, callbackParams, scriptCallback, cleanup, condFns
		}

		; When creating an object extending TP_BASE_CALLBACK, you should call getEntryBin and getpParams, and pass these to the constructor.
		getEntryBin() {
			local
			global xlib
			if !bin := this.entryBins[ type(this) ]
				xlib.exception a_thisfunc . ' failed, entry bin not initilised for: "' . type( this ) . '".'	; this should not be possible
			return bin
		}
		pParams := 0
		getpParams() {
			if !this.pParams
				xlib.exception a_thisfunc . ' failed, pParams not initilised.'	; this should not be possible
			return this.pParams.pointer
		}
		
		; Internal
		
		static z_ptr := { pointer : 0 } ; Used to pass a zero pointer for some optional parameters.
				
		static entryBins := []
		initBins() {
			; Initilises various binary codes
			; entryBins are defined in xlib\c source\xxxCallback.c
			; this.raw32 and this.raw64 must be defined in any object extendning this base class. rawput will (eventually) throw error if they are not defined.
			local
			global xlib
			if this.entryBins.haskey( t := type(this) )
				return
			this.entryBins[ t ] := xlib.mem.rawput(this.raw32, this.raw64)
			this.initCleanUpFnBin	; Only needs to be called once, surplus calls returns without any side effects.
		}
		static cleanUpFnBin := 0
		initCleanUpFnBin() {
			; Only needs to be done once
			; see xlib\c source\cleanupfunction.c
			local
			global xlib
			if this.cleanupFnBin
				return
			raw32 := [1398167381,2333928579,2335450204,2335188092,864748651,192212357,4280564873,82608918,2332050825,3229943875,9113460,2300853385,4278461508,3968009302,205753096,158646405,4280564873,3968010326,272861956,259309701,1015611531,608471332,207027972,2332617859,3229946947,9113460,2300853385,4278461508,3968012374,407079688,376750213,2298761355,2332566612,607947008,69485705,2199148287,1133186284,1958774044,2298514191,1149838396,1459553316,149717784,1528611971,3277676382]
			raw64 := [1398167381,686588744,141200200,1211796296,2303250057,3984935123,402589812,2303236168,2336751685,2236092483,1208579264,2303201419,139984881,410747720,1208382464,1476391305,1133201424,3229960224,2336754036,4052305936,1209554943,1210598283,158646405,1209043784,1476391305,1133201440,3229960240,2336492916,2336753728,4052305936,1210603519,1211646859,477413509,809995084,1209043784,2202595721,1583032516,4282998111,2149519328,0,683967304,1566531163,2425393347,2425393296]
			this.cleanupFnBin := xlib.mem.rawput(raw32, raw64) ; Will be put in context struct, see createContextStruct()
			return
		}
		setupCallback(callback, callbackParams, scriptCallback, cleanup, condFns) {
			; callback, function pointer to the thread callback
			; callbackParams, pointer to parameters to pass to callback.
			; scriptCallback, functor, to call when callback complete.
			; cleanup, parameters to the cleanup functions, see "callback.h". This should represent: size_t* cp[7] in struct cleanup, see createCleanUpStruct(cp)
			; condFns, array of arrays of function pointers to call before scriptCallback, only call scriptCallback if all return true. If no condition, always call scriptCallback if it is given.
			local
			global xlib
			if scriptCallback {								
				this.createSyncStruct 0, condFns			; sets this.ss, struct scriptSync
				xlib.poolCallback.messageReg				; initialises message handling
				this.scriptCallback := scriptCallback		; this will be called when the script syncs
				
			} else {
				this.ss := this.z_ptr	; let scriptSync sync struct be a zero pointer
			}
			
			this.createCleanUpStruct cleanup								; sets this.pcu 
			this.createUDFstruct callback, callbackParams, extraOffset := 0 ; note extraOffset not considered atm
			
			this.createContextStruct										; sets this.pParams
			
		}
		
		createSyncStruct(callbackNumber, condFns) {
		/*
			typedef struct scriptSync {
				syncCondition*	condFns;			// array of sync conditions. (only sync if all return TRUE)
				_PostMessage 	pPostMessage;		// For posting message to "calling thread".
				HWND 			hwnd;				// handle to the window which will recieve the msg.
				WPARAM 			wParam;				// "this" reference
				LPARAM 			lParam;				// callbackNumber
				unsigned int 	msg;				// message number
			} *ss;
		*/
			; this function is similar to xlib.threadHanlder.makeCallbackStruct
			static sizeof_ss := a_ptrsize * 5 + 4
			
			local
			global xlib
			
			; Retrieve some constants.
			C := xlib.constants 
			
			hwnd := C.msgHWND
			msg := C.msgNumber
			ppm := C.pPostMessage
			
			processCondFns	 ; closure
			
			ss := new xlib.struct(sizeof_ss,,  this.sn('scriptSync', a_thisfunc))	; Create struct and name it for db. purposes.
			static p := 'ptr'	; for convenince
			static u := 'uint'
			
			this_ptr := &this	; pointer to this, needs to be passed to identify the object when recieving the the sync message. 
			
			ss.build( 	; build the struct
						[p, condFns, 		'condFns'],
						[p, ppm, 			'pPostMessage'],
						[p, hwnd, 			'hwnd'],
						[p, this_ptr, 		'wParam'],
						[p, callbackNumber, 'lParam'],
						[u, msg, 			'msg']
					)
			
			; Only increment ref count of 'this' and set clean up function after struct successfully has been built
			; Increment the reference count to ensure the object exists when the callback is recieved.
			; Needs to be released when the struct is deleted, hence 'cleanupfn := (struct) => objrelease( this_ptr )' is used as clean up function for the struct.
			
			objaddref this_ptr
			cleanupfn := (struct) => objrelease( this_ptr )
			ss.setCleanUpFunction cleanupfn
			
			this.ss := ss ; Will be put in context struct, see createContextStruct()
			;
			;	closure
			;
			processCondFns() {
				if !condFns
					return 0
			}
		}
		
		createUDFstruct(fn, par := 0, extraOffset := 0) {
			/*
			typedef struct udf	{					// User defined function and pointer to arguments
				udFn	pudFn;						// Function pointer of type udFn
				void* 	pParams;					// Pointer to arguments
				size_t*	extraOffset;				// Write extra pointer of pParams[*extraOffset];
			} *pudf;
			*/
		
			static sizeof_udf := a_ptrsize * 3
			local
			global xlib
			
			udf := new xlib.struct(sizeof_udf,, this.sn('udf', a_thisfunc))
			static p := 'ptr'
			udf.build(
						[p, fn, 			'pudFn'],
						[p, par,			'pParams'],
						[p, extraOffset,	'extraOffset']
					)
			this.udf := udf	; Will be put in context struct, see createContextStruct()
		}
		static culib := 0
		createCleanupLib() {
		; Creates the following stuct,
		/*
			typedef struct cleanuplib {
				CallbackMayRunLong							cbmrl;
				DisassociateCurrentThreadFromCallback		dctfc;
				FreeLibraryWhenCallbackReturns				flwcbr;
				LeaveCriticalSectionWhenCallbackReturns		lcswcbr;
				ReleaseMutexWhenCallbackReturns				rmwcbr;
				ReleaseSemaphoreWhenCallbackReturns			rswcbr;
				SetEventWhenCallbackReturns					sewcbr;
			} *pculib;
			See callback.h
		*/
			if this.culib
				return
			this.culib := xlib
					.ui.createLib(	[	; Returns a xlib.struct object.
										['kernel32.dll\CallbackMayRunLong', 						'cbmrl'],
										['kernel32.dll\DisassociateCurrentThreadFromCallback',		'dctfc'],
										['kernel32.dll\FreeLibraryWhenCallbackReturns', 			'flwcbr'],
										['kernel32.dll\LeaveCriticalSectionWhenCallbackReturns', 	'lcswcbr'],
										['kernel32.dll\ReleaseMutexWhenCallbackReturns', 			'rmwcbr'],
										['kernel32.dll\ReleaseSemaphoreWhenCallbackReturns',		'rswcbr'],
										['kernel32.dll\SetEventWhenCallbackReturns',				'sewcbr']
									],, this.sn('cleanuplib', a_thisfunc))	; Creates struct and names it for db. purposes.                                                         
			; Will be put in cleanup struct, see createCleanUpStruct()
		}
			
		createCleanUpStruct(cp) {
		/*
			typedef struct cleanup {
				pculib lib;							// function library 
				size_t* cp[7];						// clean-up params for the above functions. Define cp[x], to call function number (x-1) in lib, passing (cp[x][0], ...) as appropriate.
			} *pcu;
		*/
			
			static sizeof_pcu := a_ptrsize * 2
			
			local
			global xlib
			; if no clean up parameters are specified, there is no need to construct a struct, use the zero pointer to indicate.
			if !cp {
				this.pcu := this.z_ptr
				return
			}
			; cp should contain a pointer at each element k to the arguments for function number k in lib. k \in [1, 7]
			pcu :=	new xlib.struct(sizeof_pcu,, this.sn('cleanup', a_thisfunc))
			pcp := new xlib.typeArr( 7 )
			for k, params in cp
				pcp.set k, params
			static p := 'ptr'
			pcu.build(
						[p, this.culib.pointer, 'lib'],
						[p, pcp.pointer, 'cp']
					)
			cleanupfn := (s) =>  pcp := ''	; closure, holds the last reference to the type array, clear when struct is released.
			pcu.setCleanUpFunction cleanupfn
			this.pcu := pcu	; Will be put in context struct, see createContextStruct()
		}
		
		createContextStruct() {
		/*
			typedef struct context {
				pudf			userStruct;			// A struct on the form of udf 
				ss				sync;				// A struct on the form of scriptSync
				cleanupfunction	cufn;				// Clean-up function. Will call the appropriate functions in cp->lib, passing the appropriate paramaters cp->cp.
				pcu				cp;					// passed fp cufn.
			} *pcontext;
		*/
			static sizeof_context := a_ptrsize * 4
			
			local
			global xlib
			
			con := new xlib.struct(sizeof_context,, this.sn('context', a_thisfunc))
			static p := 'ptr'
			con.build(												;	created in:
						[p, this.udf.pointer, 		'userStruct'],	;	createUDFstruct() 
						[p, this.ss.pointer, 		'sync'],		;	createSyncStruct()
						[p, this.cleanupFnBin,		'cufn'],		;	initCleanUpFnBin()
						[p, this.pcu.pointer,		'cp']			;	createCleanUpStruct
						)
			
			this.pParams := con
		}
		
		; sn - struct name - standard message
		sn(name, fn := '') { ; formats struct name, for db.
			return name . (fn ? '`n`nCreated in: ' . fn : '')
		}
		
		cleanUp() {
			msgbox 'clean up not implemented yet'
		}
		
	}
	class work extends xlib.poolCallback.PCB_BASE {
		; workCallback.c, gcc -O3
		static raw32 := [3968029526,611617556,610044708,205949728,175423621,69485705,4280556681,109774934,2332575883,3380937808,160105844,2307529865,285156372,2231656075,2334029019,1958774019,2333510432,76088402,609519908,2333146884,1959953683,1975551244,348422920,214064731,272861952,203703433,2299282315,2332566596,1149834307,1133184036,604277000,2198098943,3296923884,3260963604,2425356300,2425393296]
		static raw64 := [2202555222,2303207660,1384859862,3414771736,1959953736,274136835,1208388424,1209028747,1208502411,125096581,1209174856,4291894409,1586186256,3682945032,2336759412,3229960195,2336759412,3246999574,139627336,2202538239,208928827,141934725,683967304,2428722779,1210602379,1209027467,1275609995,1277184907,1209549707,1529398403,3774826590,2425393296]
		
	}
	class wait extends xlib.poolCallback.PCB_BASE {
		; waitCallback.c, gcc -O3
		static raw32 := [1474660693,3968029526,340101932,2332849547,1166608477,205949924,175423621,69485705,4280556681,109774934,2332575883,3380937808,965414516,2344230025,160162941,277511305,4280554633,73304848,510974853,3229942667,378217076,2298761867,1418273796,285148196,3531936651,3229945460,1703742069,1600019444,1098333,2299544459,1133188165,272992524,2299806603,1133186117,138774792,2365866891,1583084645,3774831967,2425393296,2425393296]
		static raw64 := [1213421143,1210117251,2336806537,2303203410,3481879755,1959953736,274136835,1208388424,1209028747,1208502411,242537093,1241680716,1220615305,2089357963,285155473,140413768,1960543560,59459614,1958774088,378226723,1220643144,4278735499,998459408,2232513536,1208841664,1528874115,264462174,17439,1210602379,1209027467,1275609995,1277184907,1209549707,1528874115,4282933086,2425393376]
	}
	class timer extends xlib.poolCallback.PCB_BASE {
		; timerCallback.c, gcc -O3
		static raw32 := [3968029526,611617556,610044708,205949728,175423621,69485705,4280556681,109774934,2332575883,3380937808,160105844,2307529865,285156372,2231656075,2334029019,1958774019,2333510432,76088402,609519908,2333146884,1959953683,1975551244,348422920,214064731,272861952,203703433,2299282315,2332566596,1149834307,1133184036,604277000,2198098943,3296923884,3260963604,2425356300,2425393296]
		static raw64 := [2202555222,2303207660,1384859862,3414771736,1959953736,274136835,1208388424,1209028747,1208502411,125096581,1209174856,4291894409,1586186256,3682945032,2336759412,3229960195,2336759412,3246999574,139627336,2202538239,208928827,141934725,683967304,2428722779,1210602379,1209027467,1275609995,1277184907,1209549707,1529398403,3774826590,2425393296]
	}
	
	; Message handling - for script sync.
		
	messageReceiver(wParam, lParam, msg, hwnd) {
		/*
			see scriptSync struct,
			HWND 			hwnd;				// handle to the window which will recieve the msg.
			WPARAM 			wParam;				// "this" reference
			LPARAM 			lParam;				// callbackNumber
			
		*/
		local
		global xlib
		pc := object(wParam)					; get the poolCallback object.
		pc.scriptCallback.call pc.getpParams()	; call the script callback.
		;pc.ss := ''	; release the sync struct, it holds a reference to pc. If user has no more references to pc, pc is released when this function returns.
	}
	
	
	static isMonitoringMessages := false
	messageReg() {
	; Set up for recieving callback messages.
		if xlib.poolCallback.isMonitoringMessages
			return
		local msgFn
		msgFn := xlib.poolCallback.msgFn := objBindMethod(xlib.poolCallback, 'messageReceiver')
		onMessage xlib.constants.msgNumber, msgFn, 200
		xlib.poolCallback.isMonitoringMessages := true
	}
	
	messageUnreg(){	; unregister callbacks, needed to make script not persistent.
		if !xlib.poolCallback.isMonitoringMessages
			return
		onMessage xlib.constants.msgNumber, xlib.poolCallback.msgFn, 0
		xlib.poolCallback.isMonitoringMessages := false
	}
	
}