class kbHook{
	; low level keyboard hook
	; Usage example:
	;	#Persistent
	;	#include kbHook.ahk
	;	kbh:= new kbHook(Func("myFunction")) 
	;	kbh.start()								; When pressing a key on the keyboard, the function myFunction is called.
	;	myFunction(event,info){
	;		[...]	
	;	}
	; Input:
	;	- callbackFunc, can be one of the following. 
	;		func object, this object will be called with the following parameters: event, info. See below for more details.
	;		pointer to a function in memory, eg as returned by RegisterCallback. This function is called with default LowLevelKeyboardProc() paramters, see https://msdn.microsoft.com/en-us/library/windows/desktop/ms644985(v=vs.85).aspx (LowLevelKeyboardProc function)
	;		string, "blockHook" to quickly block the next hook, but not suppressing the keypress.
	;		string, "blockKey" to quickly block the next hook and suppress the keypress.
	;		Caution: - Passing bad pointers or freeing the memory afterwards could cause unwanted behaviour such as keyboard unresponsiveness and application crashes. 
	;				 - By default, the memory is freed when you free the last reference to a derived kbHook object. To avoid see autoFree parameter.
	;	- subscriptions, a comma delimited string or array containing the litterals, "WM_KEYDOWN", "WM_KEYUP", "WM_SYSKEYDOWN","WM_SYSKEYUP". Omit this parameter for subscribing to all events. For more detatils, see https://msdn.microsoft.com/en-us/library/windows/desktop/ms644985(v=vs.85).aspx (Specifically, wParam)
	;	- callbackSetting, specify the string "fast" to avoid creating a new thread for the callback, see the option paramter for RegisterCallback(...) in the autohotkey help file. Omit this parameter to create a new thread, genereally recommended.
	;	- autoFree, true by default, automatically frees the callback function when the last reference to the derived kbHook object is freed. Set to false to avoid this behaviour.
	;	- mute, set to true to suppress exceptions be thrown, default is false.
	; The callbackFunc is called with the following parameters:
	;		event, either one of strings "WM_KEYDOWN", "WM_KEYUP", "WM_SYSKEYDOWN","WM_SYSKEYUP".
	;		info, an object containing information about the key event, it has the following keys: vkCode, scanCode, flags, time, dwExtraInfo
	;			  Example: ToolTip, % info.vkCode ; Shows the virtual key code of the press which generated the event
	;			  For more details, see https://msdn.microsoft.com/en-us/library/windows/desktop/ms644967(v=vs.85).aspx (KBDLLHOOKSTRUCT structure)
	;		wParam, byref. event is extracted from this parameter (address)
	;		lParam, byref. info  is extracted from this parameter (address)
	; The callbackFunc should return: 
	;  		"", to let the keypress through and call the next hook (usually recommended). ("" or a blank return or no return at all)
	; 		 1, to suppress the key and not call the next hook.
	;	 	 0, let the keypress through but do not call the next hook.
	;
	__new(callbackFunc,subscriptions:="",callbackSetting:="Safe", autoFree:=true, mute:=false){
		this.mute:=mute ; set to true to suppress error messages.
		IsObject(callbackFunc)  ? this.callbackFunc:=callbackFunc 																		; Call user callback function, users return determines if call next hook and / or block key.
								: this.regCallBack:= callbackFunc="blockHook" 	? this.returnInt(0) 									; Return 0 and do not call the next hook. Return 0 means the key is not suppressed.
																				: callbackFunc="blockKey"  	? this.returnInt(1)			; Return 1 and do not call the next hook. Return 1 means the key is     suppressed.
																											: callbackFunc 				; Using premade reg callback function doesn't include a reference to "this". 
																																		; Caution, when releasing the last reference to an object derived from hkHook, the registred callback will be freed. See __Delete() and clear()
		if this.lastError
			return exit																													; If there is an error, silent exit when muted. __delete is called and no object is returned.
		
		if autoFree																														; Automatically frees the callback function when the last reference to the derived kbHook object is freed.
			this.freeFn:= InStr(callbackFunc,"block") 	? ObjBindMethod(this,"VirtualFree") 											; Determine which memory free function to use. returnInt(n) need VirtualFree.
														: ObjBindMethod(this,"GlobalFree")												; RegisterCallback(...) uses GlobalFree.
		this.subscriptions := subscriptions ? this.makeSubscriptionArray(subscriptions) 												; Custom subscriptions specified
											: this.makeSubscriptionArray(["WM_KEYDOWN", "WM_KEYUP", "WM_SYSKEYDOWN","WM_SYSKEYUP"])		; No subscriptions specified, get all.
		this.callbackSetting := callbackSetting="Fast" 	? "Fast"		 																; Fast is specified for the callback, no new (ahk) thread is created, caution.
														: ""																			; Recommended - new (ahk) thread is created.
		this.init:=1																													; Indicates that the object has been properly initialised.
	}
	; User methods
	; Call start() to start monitoring keyboard, and call stop() to stop monitor.
	; Call refresh() to start a new identically set up hook and then discard the previous one.
	start(){
		if !this.init {																													; Error on using start() before object properly set up.
			this.lastError:=Exception("Object not initialised correctly.",-1)
			if this.mute 
				return this.lastError
			else
				throw this.lastError
		}
		if !this.regCallBack
			this.regCallBack:=RegisterCallback(this.LowLevelKeyboardProc , this.callbackSetting, 4, &this)								; Set up the internal callback function only once.
		if !this.hHook																													; If the hook is off, turn it on
			this.hHook:=this.hook()
		return
	}
	stop(){
		if this.hHook
			this.unHook()		; If the hook is on, turn it off.
		return this.hHook:=""
	}
	refresh(){
		; Install a new, identically set up hook, then unhooks the old.
		; The point is that there should always be a hook running, not missing anything.
		; Refreshing might cause your hook to be called earlier in the hook chain.
		local newHookHandle
		newHookHandle:=this.hook()
		this.unHook(this.hHook)
		this.hHook:=newHookHandle
		return
	}
	enableAutoDisable(time:=50){
		; Auto disable the hook if the input is injected, set a timer to reenable it after this.autoDisableTimeout ms.
		this.autoDisable:= time ? true : false
		this.autoDisableTimeout:=abs(time)
		return
	}
	disableAutoDisable(){
		; Turn of auto disable
		return this.enableAutoDisable(0)
	}
	getLastError(){
		; returns an "exception object" describing the most recent error.
		return this.lastError
	}
	; LLKHF_INJECTED, LLKHF_LOWER_IL_INJECTED and LLKHF_EXTENDED, the wParam covers up/down / alt.
	isExtended(flags){
		; Returns 1 if the key is extended: such as a function key or a key on the numeric keypad. If not extended, return 0.
		; LLKHF_EXTENDED:=1
		return flags & 1
	}
	isInjected(flags){
		; Returns 1 if the the key was injected, 2 if it was injected by a lower integrity level process, 0 otherwise.
		static LLKHF_INJECTED:=0x10, LLKHF_LOWER_IL_INJECTED:=0x2 
		return flags & LLKHF_INJECTED ? 1 + (flags & LLKHF_LOWER_IL_INJECTED ? 1 : 0) : 0
	}
	; Internal methods
	; Hook related
	
	hook(){
		; Url:
		;	- https://msdn.microsoft.com/en-us/library/windows/desktop/ms644990(v=vs.85).aspx (SetWindowsHookEx function)
		local hHook
		static WH_KEYBOARD_LL:=13
		if !(hHook:=DllCall("User32.dll\SetWindowsHookEx", "Int", WH_KEYBOARD_LL, "Ptr", this.regCallBack, "Uint", 0, "Uint", 0, "Ptr")) { ; Returns a hook handle
			 this.lastError:=Exception("Hook initialising failed.",-1)
			if this.mute
				return this.lastError
			else 
				throw this.lastError
		}
		return hHook
	}
	unHook(hHook){
		; Url:
		;	- https://msdn.microsoft.com/en-us/library/windows/desktop/ms644993(v=vs.85).aspx (UnhookWindowsHookEx function)
		DllCall("User32.dll\UnhookWindowsHookEx", "Ptr", hHook)																
		return 
	}
	LowLevelKeyboardProc(args*) {
		local nCode, wParam, lParam, KBDLLHOOKSTRUCT,disabled,reEnableFn,r
		static Msg:={0x0100:"WM_KEYDOWN", 0x0101:"WM_KEYUP", 0x0104:"WM_SYSKEYDOWN",0x0105:"WM_SYSKEYUP"}
		Critical
		;  this, nCode, wParam, lParam:
		; Url:
		;	- https://msdn.microsoft.com/en-us/library/windows/desktop/ms644985(v=vs.85).aspx (LowLevelKeyboardProc function)
		this:=Object(A_EventInfo), nCode:=NumGet(args+0,-A_PtrSize,"Int"), wParam:=NumGet(args+0,0,"Ptr"), lParam:=NumGet(args+0,A_PtrSize,"UPtr")
		if !this.subscriptions.HasKey(Msg[wParam])			; If not subscribing to this event, callNextHook and return.
			return this.callNextHook(nCode,wParam,lParam)
		; Url:
		;	- https://msdn.microsoft.com/en-us/library/windows/desktop/ms644967(v=vs.85).aspx (KBDLLHOOKSTRUCT structure)
		KBDLLHOOKSTRUCT:={	  vkCode		: NumGet(lParam+0,  0, "Uint")
							, scanCode		: NumGet(lParam+0,  4, "Uint")
							, flags			: NumGet(lParam+0,  8, "Uint")
							, time			: NumGet(lParam+0, 12, "Uint")
							, dwExtraInfo	: NumGet(lParam+0, 16, "UPtr")}
		; Handle auto disable. (Optional)
		; Auto disable the hook if the input is injected, set a timer to reenable it after this.autoDisableTimeout ms.
		if (this.autoDisable && kbHook.isInjected(KBDLLHOOKSTRUCT.flags)) {
			disabled:=true	; Indicates that the callback function should not be called, the next hook is called.
			this.stop()
			reEnableFn:=ObjBindMethod(this,"start")
			SetTimer, % reEnableFn, % -this.autoDisableTimeout
		}
		Critical, off
		return disabled || (r:=this.callbackFunc.Call(Msg[wParam],KBDLLHOOKSTRUCT,wParam,lParam))="" ? this.callNextHook(nCode,wParam,lParam) : (r=1?1:0)	; If the hook was disabled, the next hook is called. (Maybe it shouldn't)
																																							; The next hook is called if the callback function returns nothing, or ""
																																							; If the callback function returns  1, the next hook isn't called and the key event is suppressed.
																																							; If the callback function returns  0, the next hooks isn't called, but the key event is not suppressed.
	}
	callNextHook(nCode,wParam,lParam){
		; Passes on the hook params to the next hook.
		; Url:
		;	- https://msdn.microsoft.com/en-us/library/windows/desktop/ms644974(v=vs.85).aspx (CallNextHookEx function)
		return DllCall("User32.dll\CallNextHookEx", "Uint", 0, "Int", nCode, "Ptr", wParam, "Uptr", lParam)
	}
	; Clean up
	clear(){
		; Frees the memory occupied by this.regCallBack.
		; Caution: If you have supplied your own this.regCallBack, by passing RegisterCallback(...) as the callbackFunc, it will be freed too.
		this.stop()								; Turn off the hook before freeing.
		if (this.regCallBack && this.autoFree)
			this.freeFn.Call(this.regCallBack), this.freeFn:=""	; Free memory, release self references.
		this.regCallBack:=0
		return
	}
	; Free memory functions.
	GlobalFree(hMem){
		; URL:
		;	- https://msdn.microsoft.com/en-us/library/windows/desktop/aa366579(v=vs.85).aspx (GlobalFree function)
		local h
		h:=DllCall("Kernel32.dll\GlobalFree", "Ptr", hMem, "Ptr")
		if h {
			this.lastError:=Exception("GlobalFree failed: " A_LastError)
			if this.mute
				return this.lastError
			else
				throw this.lastError
		}
		return h
	}
	VirtualFree(lpAddress){
		; Url:
		;	- https://msdn.microsoft.com/en-us/library/windows/desktop/aa366892(v=vs.85).aspx (VirtualFree function)
		; Input:
		;	- lpAddress, a pointer to the base address of the region of pages to be freed.
		; Returns:
		;	- If the function succeeds, the return value is nonzero.
		;	  If the function fails, the return value is 0 (zero). To get extended error information, call GetLastError.
		static dwFreeType:=0x8000 ; MEM_RELEASE
		if !DllCall("Kernel32.dll\VirtualFree", "Ptr", lpAddress, "Ptr", 0, "Uint", dwFreeType) { ; Non-zero is ok!
			this.lastError:=Exception("VirtualFree failed, error: " A_LastError)
			if this.mute
				return this.lastError
			else
				throw this.lastError
		}
		return 
	}
	; Init
	makeSubscriptionArray(arr){
		; Turns values in arr to keys in ssa
		local ssa, k, v
		ssa:={}
		arr:= IsObject(arr) ? arr : [StrSplit(arr,",",A_Space A_Tab)*]
		for k, v in arr
			ssa[v]:=""
		return ssa
	}
	; Properties
	; the hook handle is stored in this._hh
	; the callback pointer is stored in this._rcb
	; these values aren't ment to be modified externally.
	; This serves as a weak protection against incorrect usage, which could cause keyboard unresponsiveness and application crash
	hHook{
		Set {
			if this.hHook
				this.unHook(this.hHook)
			this._hh:=value
			return 
		} Get {
			return this._hh
		}
	}
	regCallBack{
		Set {
			if (mod(value,A_PtrSize)!=0) {
				this.lastError:=Exception("Bad pointer or callback function",-2)	; -2 To avoid "what" pointing here
				if this.mute
					return this.lastError
				else
					throw this.lastError
			} else {
				this._rcb:=value
			}
			return
		} Get {
			return this._rcb
		}
	}
	; Misc
	returnInt(n){
		; Input: 
		;	- n, integer in range (-2**31, 2**31-1), i.e., (-2147483648, 2147483647)
		; Return:
		;	- bin, address pointing to binary code for returning the integer, n.
		; Misc:
		;	When making "many" allocations, call VirtualFree(bin) when done with bin. 
		; Example:
		;	r:=returnInt(37)
		;	MsgBox, % DllCall(r) ; 37
		; Url:
		;	- https://msdn.microsoft.com/en-us/library/windows/desktop/aa366887(v=vs.85).aspx 	(VirtualAlloc function)
		;	- https://msdn.microsoft.com/en-us/library/windows/desktop/aa366786(v=vs.85).aspx 	(Memory Protection Constants)
		;	- http://ref.x86asm.net 															(X86 Opcode and Instruction Reference)
		;
		local bin
		static dwSize:=6, flProtect:=0x40	; PAGE_EXECUTE_READWRITE
		static flAllocationType:=0x1000 	; MEM_COMMIT
		static mov:=0xb8, ret:=0xc3
		bin:=DllCall("Kernel32.dll\VirtualAlloc", "Uptr",0, "Ptr", dwSize, "Uint", flAllocationType, "Uint", flProtect, "Ptr")
		NumPut(mov,bin+0,"Char"),NumPut(n,bin+1,"Int"),NumPut(ret,bin+5,"Char")	
		return bin
	}
} 