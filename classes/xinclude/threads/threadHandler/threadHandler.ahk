#include ccore.ahk	; compiled function.
class threadHandler {
	
	;<< new >>
	__new(maxTasks := 8){
		this.maxTasks := maxTasks
		this.initDataArrays()
		this.callbackFunctions := []
		this.callbackStructs := []
		this.stackSizes := []
		this.startOptions := []
		this.autoReleaseCallbackStructAfterCallback := [] ; See autoReleaseCallbackStruct
	}
	restartAllTasks(){
		; User should check that no threads are running before calling this methods. Exception on failure.
		local k
		if this.isAnyThreadRunning()		; Verify no threads still running. 
			xlib.exception("Cannot restart all tasks before all task finished.",,-1)
		for k in this.binArr
			this.restartTask(k)
	}
	restartTask(ind){
		this.cleanUpThread(ind)
		if this.callback
			this.registerTaskCallback(this.binArr.Get(ind),this.argArr.Get(ind),this.callbackFunctions[ind],this.startOptions[ind],this.stackSizes[ind], ind) ; ind will indicate restart and serve as callbackNumber
		else
			this.createTask(this.binArr.Get(ind),this.argArr.Get(ind),this.startOptions[ind],this.stackSizes[ind], ind)
		if !this.startOptions[ind] ; since we are restarting, over ride start option.
			this.startTask( ind )
	}
	;<<Task methods>>
	registerTaskCallback(pBin,pArgs,callbackFunction,start := true,stackSize := 0,restarting := false){
		; "Return values" from task function pBin, should be put in pArgs
		; The callback function must accept two parameters, a reference to "this" and the callbackNumber returned by this function.
		; callbackFunction can be the name of a function, a func or boundFunc object.
		; Eg: myCallbackFunction(param1,...,callbackNumber, this){...}
		local pCb, callbackNumber
		if !restarting {
			callbackFunction := xlib.verifyCallback(callbackFunction)
			callbackNumber := this.callbackFunctions.Push(callbackFunction)
			this.makeCallbackStruct(pBin,pArgs,callbackNumber)
		} else {
			callbackNumber := restarting
			start := this.startOptions[callbackNumber]
			stackSize := this.stackSizes[callbackNumber]
		}
		pCb := xlib.ccore.taskCallbackBin()
		this.OnMessageReg()
		this.createTask(pCb,this.callbackStructs[callbackNumber].params.pointer,start,stackSize,restarting)
		return callbackNumber
	}
	createTask(pBin, pArgs, start := true, stackSize := 0, restarting := false){
		; pBin, pointer to binary buffer with 
		; pArgs, pointer to the arguments for the binary code
		; "Return values" from task function pBin, should be put in pArgs
		static CREATE_SUSPENDED  :=  0x00000004
		local threadData,ind
		if !restarting {
			this.stackSizes.push(stackSize)
			this.startOptions.Push(start)
			this.binArr.push(pBin)
			this.argArr.push(pArgs)
		} else {
			ind := restarting
		}
		local crit  :=  a_isCritical
		critical(1000)	; Ensure callback doesn't interrupt before thread handle and id is set, since the callback reciever calls closeHandle()
		threadData  :=  xlib.thread.createThread(pBin, pArgs, 0, stackSize, start ? 0 : CREATE_SUSPENDED) ; For reference, threadData  :=  {hThread:th,threadId:lpThreadId}
		if !restarting {
			this.thHArr.Push(threadData.hThread)
			this.tIdArr.Push(threadData.threadId)
		} else { 
			this.thHArr.Set(ind,threadData.hThread)
			this.tIdArr.Set(ind,threadData.threadId)
		}
		critical(crit)
		return
	}
	startAllTasks(){
		local k, hThread
		if this.thHArr.getLength()
			for k, hThread in this.thHArr
				xlib.thread.resumeThread(hThread)
		else
			xlib.exception("No thread handles available.",,-1,"Warn")
		return 
	}
	setTask(ind,pBin := "",pArgs := ""){
		; Sets new binary and or arguments for task ind.
		; Thread must not run while this method is called, exception is thrown.
		if this.isThreadRunning(ind)
			xlib.exception("Cannot set task when thread is still runngin.",,-1)
		if pBin!=""
			this.binArr.Set(ind,pBin)
		if pArgs!=""
			this.argArr.Set(ind,pArgs)
		this.updateCallbackStruct(this.binArr.Get(ind),this.argArr.Get(ind),ind)
		return
	}
	setCallback(ind,callback){
		callback := xlib.verifyCallback(callback)
		this.callbackFunctions[ind] := callback
	}
	startTask(ind){
		return xlib.thread.resumeThread(this.thHArr.get(ind))
	}
	terminateAllThreads() {
		local k, tH
		if this.thHArr.getLength()
			for k, tH in this.thHArr
				xlib.thread.terminateThread(tH), xlib.misc.closeHandle(tH)
		return
	}
	terminateTask(ind){
		local th
		if !th := this.thHArr.get(ind)
			xlib.exception(A_ThisFunc " failed, no thread running for task: " ind,,-1)
		return xlib.thread.terminateThread(tH)
	}
	autoReleaseAllCallbackStructs(bool := true){
		; See autoReleaseAllCallbackStructs()
		loop this.maxTasks
			this.autoReleaseCallbackStructAfterCallback[A_Index] := bool
	}
	autoReleaseCallbackStruct(callbackNumber, bool := true){
		; Call this method for indicating wether to release the callback struct after the callback.
		; This is convenient when making new task as a local parameter and the returning without keeping a reference to task. The task will then be freed after the callback.
		; By default, structs are not released.
		; This should be called before starting the threads. Otherwise the callback might be recieved before this is set.
		this.autoReleaseCallbackStructAfterCallback[callbackNumber] := bool
	}
	cleanUpThread(ind){
		; Close thread handle and delete handle and id.
		local hThread
		if hThread := this.thHArr.Get(ind) {
			xlib.misc.closeHandle(hThread)
			this.thHArr.Set(ind,0)
			this.tIdArr.Set(ind,0)
		}
		return
	}
	;<<Wait functions>>
		;waitForMultipleObjects(nCount, lpHandles, bWaitAll := true, dwMilliseconds := 0xFFFFFFFF)
	waitForAllTasks(ms := 0xFFFFFFFF,waitForAll := true){
		; Returns true if all tasks are done.
		; Return -1 if the wait times out.
		static WAIT_OBJECT_0 := 	0x00000000
		static WAIT_TIMEOUT := 	0x00000102
		local r
		
		r  :=  xlib.wait.waitForMultipleObjects(this.thHArr.getLength(), this.thHArr.getArrPtr(),waitForAll,ms)
		if !waitForAll
			return r ; Handle return in waitForAnyTask()
		if ( r == WAIT_OBJECT_0 )
			return true
		else if ( r == WAIT_TIMEOUT )
			return -1
		xlib.exception("Unknown return from WaitForMultipleObjects.",[r],-1,"Warn","ExitApp")
	}
	waitForAnyTask(ms := 0xFFFFFFFF){
		; Returns the lowest task number of all tasks which have finished. (This is  the
		; zero-based  index  in the thHArr, add one to get based one index for user) 
		; Return -1 if the wait times out.
		static WAIT_TIMEOUT := 0x00000102
		local r
		r := xlib.wait.waitForAllTasks(ms,false)
		if ( r == WAIT_TIMEOUT )
			return -1
		return r+1
	}
	waitForTask(ind, ms := 0xFFFFFFFF){
		; Returns true if all task is done.
		; Return -1 if the wait times out.
		static WAIT_OBJECT_0 := 	0x00000000
		static WAIT_TIMEOUT := 		0x00000102
		local r
		r := xlib.wait.waitForSingleObject(this.thHArr.get(ind),ms)
		if ( r == WAIT_OBJECT_0 )
			return true
		else if ( r == WAIT_TIMEOUT )
			return -1
		xlib.exception("Unknown return from WaitForSingleObject.",[r],-1,"Warn","ExitApp")
		return
	}
	areAllThreadsRunning(){
		return this.waitForAnyTask(0)	== -1 ? true : false		; This one,...
	}
	isAnyThreadRunning(){
		return this.waitForAllTasks(0)	== -1 ? true : false		; ..., and this one might seem swaped, but they are not.
	}
	isThreadRunning(ind){
		; Return true (1) if thread is running.
		; Return blank ("") if no thread handle available
		; Return false (0) if thread is not running.
		if !this.thHArr.Get(ind)
			return ""
		return this.waitForTask(ind,0) 	== -1 ? true : false
	}
	;<< notification methods >>
	notifyOnAllTaskComplete(callback,rate := 50){
		; Needs a compiled waiting thread for this one. (TODO)
		return
	}
	notifyOnTaskComplete(ind,callback,rate := 50){
		; This will probably not be needed due registerTaskCallback()
		return
	}
	; Task callback methods - internal use but fits best here.
	; Task Message handler
	callbackReciever(wParam, lParam, msg, hwnd){
		; wParam is the address to the object which requested the callback
		; lParam is the callback number of that object.
		critical()
		static WAIT_TIMEOUT := 	0x00000102
		static max_wait :=  	100								
		local e
		this := Object(wParam)
		try {
			if this.waitForTask(lParam, max_wait) == WAIT_TIMEOUT												; This doesn't even happen on max_wait 0, in simple test case.  Consider remove.
				xlib.exception("Callback recieved but thread has not finished after waiting " max_wait " ms.")	; There isn't a problem closing the handle if the thread is running anyways, it seems.
			; Close thread handle here so it is done when user recieves the callback.
			this.cleanUpThread(lParam)
			if this.callbackFunctions.Haskey(lParam) 
				this.callbackFunctions[lParam].Call(lParam, this)
		} catch e {
			throw e														; throw exception after releasing struct.
		} finally {
			if this.autoReleaseCallbackStructAfterCallback[lParam]
				this.callbackStructs[lParam]  :=  ""					; this will decrement the reference count.
		}
		return 0
	}
	OnMessageReg() {
		; Set up for recieving callback messages.
		if xlib.threadHandler.isRegistredForCallbacks
			return
		local msgFn
		msgFn := xlib.threadHandler.msgFn := ObjBindMethod(xlib.threadHandler,"callbackReciever")
		OnMessage(xlib.constants.msgNumber, msgFn, 200)	; Ponder this, 200 that is.
		xlib.threadHandler.isRegistredForCallbacks := true
	}
	OnMessageUnReg(){	; unregister callbacks, needed to make script not persistent.
		if !xlib.threadHandler.isRegistredForCallbacks
			return
		OnMessage(xlib.constants.msgNumber, xlib.threadHandler.msgFn, 0)
		xlib.threadHandler.isRegistredForCallbacks := false
	}
	makeCallbackStruct(pBin,pArgs,callbackNumber){
		/*
		see xlib.ccore.taskCallbackBin()
		size: A_PtrSize*2
		typedef struct udf	{					// User defined function and pointer to arguments
			udFn	pudFn;						// Function pointer of type udFn
			void* 	pParams;					// Pointer to arguments
		} *pudf;
		Size: A_PtrSize*5+4
		typedef struct params {
			pudf			userStruct;			// A struct on the form of udf 
			_PostMessage 	pPostMessage;		// For posting message to "calling thread".
			HWND 			hwnd;				// handle to the window which will recieve the msg.
			WPARAM 			wParam;				// "this" reference
			LPARAM 			lParam;				// callbackNumber
			unsigned int 	msg;				// message number
		} *pPar;
		*/
		static sizeOfudf := A_PtrSize*2
		static sizeOfParams := A_PtrSize*5+4
		static pPostMessage  :=  0
		static msgHWND  :=  0
		static msgNumber := 0
		local 
		global xlib
		
		if !msgHWND {
			C  :=  xlib.constants
			pPostMessage  :=  C.pPostMessage
			msgHWND  :=  C.msgHWND
			msgNumber := C.msgNumber
		}
		
		udf		 :=  new xlib.struct(sizeOfudf,, "taskCallbackUDF")
		cleanupfn  :=  Func("ObjRelease").Bind(&this)
		params	 :=  new xlib.struct(sizeOfParams,, "taskCallbackParams")
		
		
		; udf struct
		udf.build(	 ["Ptr",	pBin, 	"pudFn"		]									; Pointer to binary code.					
					,["Ptr",	pArgs,	"pParams"	])									; Pointer to arguments.
		; params struct	
		params.build(	 ["Ptr",	udf.pointer,			"userStruct"		]		; pointer to the user struct.
						,["Ptr",	pPostMessage,			"pPostMessage"		]		;
						,["Ptr",	msgHWND,				"hwnd"				]		; See xlib.constants.msgHWND.
						,["Ptr",	&this,					"this"				]		; See callbackReciever.
						,["Ptr",	callbackNumber,			"callbackNumber"	]		; The threads index, internal.
						,["Uint",	msgNumber, 				"callbackMsgNumber"	])		; Defined at the top of this file.
		
		; Only increment ref count of 'this' and set clean up function after struct successfully has been built
		ObjAddRef(&this)	; Increment the reference count to ensure the object exists when the callback is recieved. See callbackReciever()
							; Needs to be released when the struct is deleted, hence Func("ObjRelease").Bind(&this) is used as clean up function for the struct.
		
		params.setCleanUpFunction( cleanupfn )
		this.callbackStructs[callbackNumber] := {udf:udf,params:params}
		return
	}
	updateCallbackStruct(pBin,pArgs,callbackNumber){
		static sizeOfudf := A_PtrSize*2
		local cbs
		cbs := this.callbackStructs[callbackNumber] ; convenience.
		cbs.udf :=  new xlib.struct(sizeOfudf, "taskCallbackUDF")
		cbs.udf.build(	 ["Ptr",	pBin, 	"pudFn"		]								; udf struct
						,["Ptr",	pArgs,	"pParams"	])
		cbs.params.Set("userStruct", cbs.udf.pointer)									; Set userStruct member of params struct.
		return
	}
	initDataArrays(restarting := false){
		if !restarting{
			this.binArr :=  new xlib.typeArr(this.maxTasks)	; User binary 		; Needed on restart.
			this.argArr :=  new xlib.typeArr(this.maxTasks)	; and arguments.
		}
		this.thHArr :=  new xlib.typeArr(this.maxTasks)		; thread handle array
		this.tIdArr :=  new xlib.typeArr(this.maxTasks)		; thread id array
	}
	verifyInd(ind){
		local caller := Exception("",-2).What
		if !this.indexInRange(ind,1,this.thHArr.getLength())
			xlib.exception("Invalid")
	}
	__Delete(){
		local k, hThread
		try {
			for k, hThread in this.thHArr
				xlib.misc.closeHandle(hThread)
		}
	}
}