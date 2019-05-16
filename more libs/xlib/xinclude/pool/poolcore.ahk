;	<< Thread Pool Api >>
class pool {
	/*
	; Template function
	f(){
		; Url:
		;	-  ( function)
		; Parameters:
		;	
		; Note:
		;	- 
		DllCall("Kernel32.dll\")
	}
	*/
	; 	Thread Pool API
	; Url:	
	;	- https://msdn.microsoft.com/en-us/library/windows/desktop/ms686766(v=vs.85).aspx
	;
	;	Table of contents, in order of appearance:
	;
	;	Synch:
	;		- CloseThreadpoolWait
	;		- CreateThreadpoolWait
	;		- SetThreadpoolWait
	;		- WaitForThreadpoolWaitCallbacks
	;	Work:
	;		- CloseThreadpoolWork
	;		- CreateThreadpoolWork
	;		- SubmitThreadpoolWork
	;		- TrySubmitThreadpoolCallback
	;		- WaitForThreadpoolWorkCallbacks
	;	Timer:
	;		- CloseThreadpoolTimer
	;		- CreateThreadpoolTimer
	;		- IsThreadpoolTimerSet
	;		- SetThreadpoolTimer
	;		- WaitForThreadpoolTimerCallbacks
	;	I/O:
	;		- CancelThreadpoolIo
	;		- CloseThreadpoolIo
	;		- CreateThreadpoolIo
	;		- StartThreadpoolIo
	;		- WaitForThreadpoolIoCallbacks
	;	Clean-up group:
	;		 - CloseThreadpoolCleanupGroup
	;		 - CloseThreadpoolCleanupGroupMembers
	;		 - CreateThreadpoolCleanupGroup
	;	Pool:
	;		 - CloseThreadpool
	;		 - CreateThreadpool
	;		 - SetThreadpoolThreadMaximum
	;		 - SetThreadpoolThreadMinimum
	;	Callback environment:
	;		- DestroyThreadpoolEnvironment
	;		- InitializeThreadpoolEnvironment
	;		- SetThreadpoolCallbackCleanupGroup
	;		- SetThreadpoolCallbackLibrary
	;		- SetThreadpoolCallbackPool
	;		- SetThreadpoolCallbackPriority
	;		- SetThreadpoolCallbackRunsLong
	;	Callback:
	;		- CallbackMayRunLong
	;	Callback clean up:
	;		- DisassociateCurrentThreadFromCallback
	;		- FreeLibraryWhenCallbackReturns
	;		- LeaveCriticalSectionWhenCallbackReturns
	;		- ReleaseMutexWhenCallbackReturns
	;		- ReleaseSemaphoreWhenCallbackReturns
	;		- SetEventWhenCallbackReturns
	
	;	<< Synch >>
	;	CloseThreadpoolWait
	;	CreateThreadpoolWait
	;	SetThreadpoolWait
	;	WaitForThreadpoolWaitCallbacks

	closeThreadpoolWait(pwa){
		; Url:
		;	- https://msdn.microsoft.com/en-us/library/windows/desktop/ms682042(v=vs.85).aspx (CloseThreadpoolWait function)
		; Note:
		; - This function does not  return  a  value  
		; - The  wait  object  is  freed
		;   immediately  if  there  are no outstanding callbacks otherwise,
		;   the timer object is freed asynchronously after  the  outstanding
		;   callbacks  complete.  
		; - If there is a cleanup group associated
		;   with the wait object, it is not necessary to call this function
		;   calling the CloseThreadpoolCleanupGroupMembers function releases
		;   the work, wait, and timer objects associated  with  the  cleanup
		;   group.
		DllCall("Kernel32.dll\CloseThreadpoolWait", "ptr", pwa)
	}
	createThreadpoolWait(pfnwa, pv, pcbe){
		; Url:
		;	- https://msdn.microsoft.com/en-us/library/windows/desktop/ms682474(v=vs.85).aspx (CreateThreadpoolWait function)
		;	- https://msdn.microsoft.com/en-us/library/windows/desktop/ms687017(v=vs.85).aspx (WaitCallback callback function)
		; Note:
		;	- If the function fails, it returns NULL.
		/*
		PTP_WAIT_CALLBACK    pfnwa,
		PVOID                pv,
		PTP_CALLBACK_ENVIRON pcbe
		
		VOID CALLBACK WaitCallback(
		_Inout_     PTP_CALLBACK_INSTANCE Instance,
		_Inout_opt_ PVOID                 Context,
		_Inout_     PTP_WAIT              Wait,
		_In_        TP_WAIT_RESULT        WaitResult
		);
		*/
		local PTP_WAIT
		if !(PTP_WAIT:=DllCall("Kernel32.dll\CreateThreadpoolWait", "Ptr", pfnwa, "Ptr", pv, "Ptr", pcbe, "Ptr"))
			xlib.exception("CreateThreadpoolWait failed.")
		return PTP_WAIT
	}
	setThreadpoolWait(PTP_WAIT, h:=0, pftTimeout:=0){
		; Url:
		;	- https://https://msdn.microsoft.com/en-us/library/windows/desktop/ms686273(v=vs.85).aspx (SetThreadpoolWait function)
		; Note:
		;	- This function does not return a value.
		;	- pftTimeout, a pointer to a FILETIME structure that specifies the absolute or relative time at which the wait operation should time out. 
		;	  If this parameter points to a positive value, it indicates the absolute time since January 1, 1601 (UTC), in 100-nanosecond intervals.
		;     If this parameter points to a negative value, it indicates the amount of time to wait relative to the current time. For more information about time values, see File Times.
		; 	  If this parameter points to 0, the wait times out immediately. 
		;	  If this parameter is NULL, the wait will not time out. pftTimeout=0 (corresponds to NULL) is deafault.
		/*
		PTP_WAIT  pwa,
		HANDLE    h,
		PFILETIME pftTimeout
		*/
		DllCall("Kernel32.dll\SetThreadpoolWait", "Ptr", PTP_WAIT, "Ptr", h, "Ptr", pftTimeout)
		return
	}
	waitForThreadpoolWaitCallbacks(PTP_WAIT,fCancelPendingCallbacks:=false){
		; Url:
		;	- https://msdn.microsoft.com/en-us/library/windows/desktop/ms687047(v=vs.85).aspx (WaitForThreadpoolWaitCallbacks function)
		; Note:
		;	- This function does not return a value.
		/*
		_Inout_ PTP_WAIT pwa,
		_In_    BOOL     fCancelPendingCallbacks
		*/
		DllCall("Kernel32.dll\WaitForThreadpoolWaitCallbacks", "Ptr", PTP_WAIT, "Int", fCancelPendingCallbacks)
		return
	}
	;	<< Work >>
	;	CloseThreadpoolWork
	;	CreateThreadpoolWork
	;	SubmitThreadpoolWork
	;	TrySubmitThreadpoolCallback
	;	WaitForThreadpoolWorkCallbacks

	closeThreadpoolWork(pwk){
		; Url:
		;	-	https://msdn.microsoft.com/en-us/library/windows/desktop/ms682043(v=vs.85).aspx	(CloseThreadpoolWork function)
		; Parameters:                                                                                                                         
		;	- pwk  [in,  out]  A  TP_WORK  structure  that  defines  the  work  object.  The
		;	  CreateThreadpoolWork function returns this structure.  
		; Note:
		; 	- This function does not return a value.
		;
		;	The work object is freed immediately if  there  are  no  outstanding  callbacks;
		;	otherwise,  the  work  object  is  freed  asynchronously  after  the outstanding
		;	callbacks complete. If there is a cleanup group associated with the work object,
		;	it   is    not    necessary    to    call    this    function;    calling    the
		;	CloseThreadpoolCleanupGroupMembers  function  releases the work, wait, and timer
		;	objects associated with the cleanup group.
				
		DllCall("Kernel32.dll\CloseThreadpoolWork", "ptr", pwk)
	}
	createThreadpoolWork(pfnwk, pv, pcbe){
		; Url:
		;	- https://msdn.microsoft.com/en-us/library/windows/desktop/ms682478(v=vs.85).aspx (CreateThreadpoolWork function)
		; Note:
		;	- If the function fails, it returns NULL.
		/*
		PTP_WORK_CALLBACK    pfnwk,
		PVOID                pv,
		PTP_CALLBACK_ENVIRON pcbe
		*/
		local pwk
		if !(pwk:=DllCall("Kernel32.dll\CreateThreadpoolWork", "Ptr", pfnwk, "Ptr", pv, "Ptr", pcbe, "Ptr"))
			xlib.exception("CreateThreadpoolWork failed.")
		return pwk
	}
	submitThreadpoolWork(pwk){
	; Url:
	;	- https://msdn.microsoft.com/en-us/library/windows/desktop/ms686338(v=vs.85).aspx (SubmitThreadpoolWork function)
	; Note:
	;	- pwk, A TP_WORK structure that defines the work object. The CreateThreadpoolWork function returns this structure.
		DllCall("Kernel32.dll\SubmitThreadpoolWork", "Ptr", pwk) ; This function does not return a value.
		return
	}
	trySubmitThreadpoolCallback(pfns,pv,pcbe){
		; Url:
		;	- https://msdn.microsoft.com/en-us/library/windows/desktop/ms686862(v=vs.85).aspx (TrySubmitThreadpoolCallback function)
		; Parameters:
		;	PTP_SIMPLE_CALLBACK  pfns,
		;	PVOID                pv,
		;	PTP_CALLBACK_ENVIRON pcbe
		; Note:
		;	- If the function succeeds, it returns TRUE. If the function  fails,  it  returns
		;	  FALSE. To retrieve extended error information, call GetLastError.
		;	- If the function succeeds, it returns TRUE. If the function  fails,  it  returns
		;	  FALSE. To retrieve extended error information, call GetLastError.
		if !DllCall("Kernel32.dll\TrySubmitThreadpoolCallback", "ptr", pfns, "ptr", pv, "ptr", pcbe)
			xlib.exception(A_ThisFunc " failed")
	}
	waitForThreadpoolWorkCallbacks(pwk, fCancelPendingCallbacks:=false){
		; Url:
		;	- https://https://msdn.microsoft.com/en-us/library/windows/desktop/ms687053(v=vs.85).aspx (WaitForThreadpoolWorkCallbacks function)
		; Note:
		;	- Waits for outstanding work callbacks to complete and optionally cancels pending callbacks that have not yet started to execute.
		;	- This function does not return a value.
		DllCall("Kernel32.dll\WaitForThreadpoolWorkCallbacks", "Ptr", pwk, "Int", fCancelPendingCallbacks)
		return 
	}
	;	<< Timer >>
	;	CloseThreadpoolTimer
	;	CreateThreadpoolTimer
	;	IsThreadpoolTimerSet
	;	SetThreadpoolTimer
	;	WaitForThreadpoolTimerCallbacks
	closeThreadpoolTimer(pti) {
		; Url:
		;	- https://msdn.microsoft.com/en-us/library/windows/desktop/ms682040(v=vs.85).aspx (CloseThreadpoolTimer function)
		; Parameters:
		; 	_Inout_ PTP_TIMER pti
		; Note:
		;	- This function does not return a value.
		DllCall("Kernel32.dll\CloseThreadpoolTimer", "ptr", pti)
	}
	createThreadpoolTimer(pfnti, pv, pcbe){
		; Url:
		;	- https://msdn.microsoft.com/en-us/library/windows/desktop/ms682466(v=vs.85).aspx (CreateThreadpoolTimer function)
		;	- https://msdn.microsoft.com/en-us/library/windows/desktop/ms686790(v=vs.85).aspx (TimerCallback callback function)
		; Note:
		;	- If the function fails, it returns NULL. (CreateThreadpoolTimer function)
		/*
		_In_        PTP_TIMER_CALLBACK   pfnti, (See TimerCallback callback function)
		_Inout_opt_ PVOID                pv,
		_In_opt_    PTP_CALLBACK_ENVIRON pcbe
		
		TimerCallback function:
		VOID CALLBACK TimerCallback(
		_Inout_     PTP_CALLBACK_INSTANCE Instance,
		_Inout_opt_ PVOID                 Context,
		_Inout_     PTP_TIMER             Timer
		);
		*/
		local TP_TIMER
		if !(TP_TIMER:=DllCall("Kernel32.dll\CreateThreadpoolTimer", "Ptr", pfnti, "Ptr", pv, "Ptr", pcbe, "Ptr"))
			xlib.exception("CreateThreadpoolTimer failed.",,-2)
		return TP_TIMER
	}
	isThreadpoolTimerSet(pti) {
		; Url:
		;	- https://msdn.microsoft.com/en-us/library/windows/desktop/ms682040(v=vs.85).aspx (IsThreadpoolTimerSet function)
		; Parameters:
		; 	_Inout_ PTP_TIMER pti
		; Note:
		;	The return value is TRUE if the timer is set otherwise,  the  return  value  is
		; 	FALSE.
		return DllCall("Kernel32.dll\IsThreadpoolTimerSet", "ptr", pti)
	}
	setThreadpoolTimer(pti, pftDueTime, msPeriod, msWindowLength){
		; Url:
		;	- https://msdn.microsoft.com/en-us/library/windows/desktop/ms686271(v=vs.85).aspx (SetThreadpoolTimer function)
		; Note:
		;	- This function does not return a value.
		;	- Setting the timer cancels the previous timer, if any.
		/*
		_Inout_  PTP_TIMER pti,
		_In_opt_ PFILETIME pftDueTime,
		_In_     DWORD     msPeriod,
		_In_opt_ DWORD     msWindowLength
		*/
		DllCall("Kernel32.dll\SetThreadpoolTimer", "Ptr", pti, "Ptr", pftDueTime, "Uint", msPeriod, "Uint", msWindowLength)
		return
	}
	waitForThreadpoolTimerCallbacks(pti, fCancelPendingCallbacks){
		; Url:
		;	- https://msdn.microsoft.com/en-us/library/windows/desktop/ms686862(v=vs.85).aspx (WaitForThreadpoolTimerCallbacks function)
		; Parameters:
		;	_Inout_ PTP_TIMER pti,
		;	_In_    BOOL      fCancelPendingCallbacks	
		; Note:
		;	- This function does not return a value.
		DllCall("Kernel32.dll\WaitForThreadpoolTimerCallbacks", "ptr", pti, "int", fCancelPendingCallbacks)
			
	}
	;	<< I/O >>
	;	CancelThreadpoolIo
	;	CloseThreadpoolIo
	;	CreateThreadpoolIo
	;	StartThreadpoolIo
	;	WaitForThreadpoolIoCallbacks
	cancelThreadpoolIo(pio){
		; Url:
		;	- https://msdn.microsoft.com/en-us/library/windows/desktop/ms681983(v=vs.85).aspx (CancelThreadpoolIo function)
		; Parameters:
		;	 _Inout_ PTP_IO pio
		;
		; Note:
		;	- This function does not return a value.
		DllCall("Kernel32.dll\CancelThreadpoolIo", "ptr", pio)
	}
	closeThreadpoolIo(pio){
		; Url:
		;	- https://msdn.microsoft.com/en-us/library/windows/desktop/ms682038(v=vs.85).aspx (CloseThreadpoolIo function)
		; Parameters:
		;	 _Inout_ PTP_IO pio
		; Note:
		;	- This function does not return a value.
		DllCall("Kernel32.dll\CloseThreadpoolIo", "ptr", pio)
	}
	createThreadpoolIo(fl,pfnio,pv:=0,pcbe:=0){
		; Url:
		;	- https://msdn.microsoft.com/en-us/library/windows/desktop/ms682464(v=vs.85).aspx (CreateThreadpoolIo function)
		; Parameters:
		;	_In_        HANDLE                fl,
		;	_In_        PTP_WIN32_IO_CALLBACK pfnio,
		;	_Inout_opt_ PVOID                 pv,
		;	_In_opt_    PTP_CALLBACK_ENVIRON  pcbe
		; Note:
		;	If the function succeeds, it returns a TP_IO structure  that  defines  the  I/O
		;   object.   Applications  do  not  modify  the  members  of  this
		;   structure. If the function fails, it returns NULL. To  retrieve
		;   extended error information, call GetLastError.
		local TP_IO
		if !TP_IO:=DllCall("Kernel32.dll\CreateThreadpoolIo", "ptr", fl, "ptr", pfnio, "ptr", pv, "ptr", pcbe, "ptr")
			xlib.exception(A_ThisFunc " failed for handle: " fl)
		return TP_IO
	}
	startThreadpoolIo(pio){
		; Url:
		;	- https://msdn.microsoft.com/en-us/library/windows/desktop/ms686326(v=vs.85).aspx (StartThreadpoolIo function)
		; Parameters:
		;	 _Inout_ PTP_IO pio
		; Note:
		;	- This function does not return a value.
		DllCall("Kernel32.dll\StartThreadpoolIo", "ptr", pio)
	}
	waitForThreadpoolIoCallbacks(pio, fCancelPendingCallbacks){
		; Url:
		;	- https://msdn.microsoft.com/en-us/library/windows/desktop/ms687038(v=vs.85).aspx (WaitForThreadpoolIoCallbacks function)
		; Parameters:
		;	_Inout_ PTP_IO pio,
		;	_In_    BOOL   fCancelPendingCallbacks
		; Note:
		;	- This function does not return a value.
		DllCall("Kernel32.dll\WaitForThreadpoolIoCallbacks", "ptr", pio, "int", fCancelPendingCallbacks)
	}
	;	<< Clean-up group >>
	;	CloseThreadpoolCleanupGroup
	;	CloseThreadpoolCleanupGroupMembers
	;	CreateThreadpoolCleanupGroup
	closeThreadpoolCleanupGroup(ptpcg){
		
		; Url:
		;	- https://msdn.microsoft.com/en-us/library/windows/desktop/ms682033(v=vs.85).aspx (CloseThreadpoolCleanupGroup function)
		; Parameters:
		;	_Inout_ PTP_CLEANUP_GROUP ptpcg
		; Note:
		;	- This function does not return a value.
		DllCall("Kernel32.dll\CloseThreadpoolCleanupGroup", "ptr", ptpcg)
	}
	closeThreadpoolCleanupGroupMembers(ptpcg,fCancelPendingCallbacks,pvCleanupContext:=0){
		; Url:
		;	- https://msdn.microsoft.com/en-us/library/windows/desktop/ms682036(v=vs.85).aspx (closeThreadpoolCleanupGroupMembers function)
		; Parameters:
		;	_Inout_     PTP_CLEANUP_GROUP ptpcg,
		;	_In_        BOOL              fCancelPendingCallbacks,
		;	_Inout_opt_ PVOID             pvCleanupContext
		; Note:
		;	- This function does not return a value.
		DllCall("Kernel32.dll\CloseThreadpoolCleanupGroupMembers", "ptr", ptpcg, "int", fCancelPendingCallbacks, "ptr", pvCleanupContext)
	}
	createThreadpoolCleanupGroup(){
		; Url:
		;	- https://msdn.microsoft.com/en-us/library/windows/desktop/ms682462(v=vs.85).aspx (CreateThreadpoolCleanupGroup function)
		; Parameters:
		;	This function has no parameters.
		; Note:
		;	- If the function succeeds, it returns a TP_CLEANUP_GROUP structure of the  newly
		;     allocated cleanup group. Applications do not modify the members
		;     of  this  structure.  If  function  fails,  it returns NULL. To
		;     retrieve extended error information, call GetLastError.

		local PTP_CLEANUP_GROUP
		if !PTP_CLEANUP_GROUP:=DllCall("Kernel32.dll\CreateThreadpoolCleanupGroup","Ptr")
			xlib.exception("CreateThreadpoolCleanupGroup failed.")
		return PTP_CLEANUP_GROUP
	}
	
	;	<< Pool >>
	;	CloseThreadpool
	;	CreateThreadpool
	;	SetThreadpoolThreadMaximum
	;	SetThreadpoolThreadMinimum

	closeThreadpool(ptpp){
		; Url:
		;	- https://msdn.microsoft.com/en-us/library/windows/desktop/ms682030(v=vs.85).aspx (CloseThreadpool function)
		; Parameters:
		;	 _Inout_ PTP_POOL ptpp
		; Note:
		;	- This function does not return a value.
		DllCall("Kernel32.dll\CloseThreadpool", "ptr", ptpp)
	}
	createThreadPool(){
		; Url:
		;	- https://msdn.microsoft.com/en-us/library/windows/desktop/ms682456(v=vs.85).aspx (CreateThreadpool function)
		; Parameters:
		;	_Reserved_ PVOID reserved - This parameter is reserved and must be NULL.
		; Note:
		;	- If function fails, it returns NULL.
		local TP_POOL
		if !TP_POOL:=DllCall("Kernel32.dll\CreateThreadpool", "ptr", 0, "Ptr")
			xlib.exception("Failed to create thread pool.",0,0,0)
		return TP_POOL
	}
	setThreadpoolThreadMaximum(ptpp, cthrdMost){
		; Url:
		;	- https://msdn.microsoft.com/en-us/library/windows/desktop/ms686266(v=vs.85).aspx (SetThreadpoolThreadMaximum function)
		; Parameters:
		;	_Inout_ PTP_POOL ptpp,
		;	_In_    DWORD    cthrdMost
		; Note:
		;       - Sets the maximum number of threads that the specified thread pool  can
		;         allocate to process callbacks 
		; 		- This function does not return a value.
		DllCall("Kernel32.dll\SetThreadpoolThreadMaximum", "Ptr", ptpp, "Uint", cthrdMost)
		return
	}
	setThreadpoolThreadMinimum(ptpp, cthrdMic){
		; Url:
		;	- https://msdn.microsoft.com/en-us/library/windows/desktop/ms686268(v=vs.85).aspx (SetThreadpoolThreadMinimum function)
		; Parameters:
		;	_Inout_ PTP_POOL ptpp,
		;	_In_    DWORD    cthrdMic
		; Note:
		;	- Sets the minimum number of threads that the specified  thread  pool  must  make
		; 	  available to process callbacks.
		;	- If the function succeeds, it returns TRUE. If the function fails, it returns FALSE.
		if !DllCall("Kernel32.dll\SetThreadpoolThreadMinimum", "Ptr", ptpp, "Uint", cthrdMic)
			xlib.exception("SetThreadpoolThreadMinimum failed for minimum: " cthrdMic) 
		return true
	}
	
	;	<< Callback environment >>
	;	DestroyThreadpoolEnvironment
	;	InitializeThreadpoolEnvironment
	;	SetThreadpoolCallbackCleanupGroup
	;	SetThreadpoolCallbackLibrary
	;	SetThreadpoolCallbackPool
	;	SetThreadpoolCallbackPriority
	;	SetThreadpoolCallbackRunsLong

	destroyThreadpoolEnvironment(pcbe){ 
		; Url:
		;	- https://msdn.microsoft.com/en-us/library/windows/desktop/ms682576(v=vs.85).aspx (DestroyThreadpoolEnvironment function)
		; Parameters:
		;	_Inout_ PTP_CALLBACK_ENVIRON pcbe
		; Note:
		;	- This function does not return a value.
		;	- This function is implemented as an inline function.
		;	//
		;	// For the current version of the callback environment, no actions
		;	// need to be taken to tear down an initialized structure.  This
		;	// may change in a future release.
		;	//
		xlib.mem.globalFree(pcbe)
		return
	}
	initializeThreadpoolEnvironment(){
		; Url:
		;	- https://msdn.microsoft.com/en-us/library/windows/desktop/ms683486(v=vs.85).aspx (InitializeThreadpoolEnvironment function)
		; Note:
		;	- Initializes a callback environment.
		;	- Forced inline function.
		;	
		/*
			
		Source, winnt.h
		#if (_WIN32_WINNT >= _WIN32_WINNT_WIN7)

		typedef struct _TP_CALLBACK_ENVIRON_V3 {										offset:
			TP_VERSION (ULONG)                 Version;									0
			PTP_POOL                           Pool;									4  : 8
			PTP_CLEANUP_GROUP                  CleanupGroup;							8  : 16
			PTP_CLEANUP_GROUP_CANCEL_CALLBACK  CleanupGroupCancelCallback;				12 : 24
			PVOID                              RaceDll;									16 : 32
			struct _ACTIVATION_CONTEXT        *ActivationContext;						20 : 40
			PTP_SIMPLE_CALLBACK                FinalizationCallback;					24 : 48
			union {
				DWORD                          Flags;									28 : 56	
				struct {
					DWORD                      LongFunction :  1;
					DWORD                      Persistent   :  1;
					DWORD                      Private      : 30;
				} s;
			} u;    
			TP_CALLBACK_PRIORITY               CallbackPriority;						32 : 60
			DWORD                              Size;									36 : 64 
		} TP_CALLBACK_ENVIRON_V3;
		size: A_PtrSize == 4 ?  40 : 72 
		typedef TP_CALLBACK_ENVIRON_V3 TP_CALLBACK_ENVIRON, *PTP_CALLBACK_ENVIRON;

		#else

		typedef struct _TP_CALLBACK_ENVIRON_V1 {
			TP_VERSION                         Version;
			PTP_POOL                           Pool;
			PTP_CLEANUP_GROUP                  CleanupGroup;
			PTP_CLEANUP_GROUP_CANCEL_CALLBACK  CleanupGroupCancelCallback;
			PVOID                              RaceDll;
			struct _ACTIVATION_CONTEXT        *ActivationContext;
			PTP_SIMPLE_CALLBACK                FinalizationCallback;
			union {
				DWORD                          Flags;
				struct {
					DWORD                      LongFunction :  1;
					DWORD                      Persistent   :  1;
					DWORD                      Private      : 30;
				} s;
			} u;    
		} TP_CALLBACK_ENVIRON_V1;
		size: A_PtrSize == 4 ?  32 : 64 
		
		typedef enum _TP_CALLBACK_PRIORITY {
			TP_CALLBACK_PRIORITY_HIGH,			(0)
			TP_CALLBACK_PRIORITY_NORMAL,		(1)
			TP_CALLBACK_PRIORITY_LOW,			(2)
			TP_CALLBACK_PRIORITY_INVALID		(3)
		} TP_CALLBACK_PRIORITY;
		
		FORCEINLINE
		VOID
		TpInitializeCallbackEnviron(
			__out PTP_CALLBACK_ENVIRON CallbackEnviron
			)
		{

		#if (_WIN32_WINNT >= _WIN32_WINNT_WIN7)

			CallbackEnviron->Version = 3;

		#else

			CallbackEnviron->Version = 1;

		#endif

			CallbackEnviron->Pool = NULL;
			CallbackEnviron->CleanupGroup = NULL;
			CallbackEnviron->CleanupGroupCancelCallback = NULL;
			CallbackEnviron->RaceDll = NULL;
			CallbackEnviron->ActivationContext = NULL;
			CallbackEnviron->FinalizationCallback = NULL;
			CallbackEnviron->u.Flags = 0;

		#if (_WIN32_WINNT >= _WIN32_WINNT_WIN7)

			CallbackEnviron->CallbackPriority = TP_CALLBACK_PRIORITY_NORMAL;
			CallbackEnviron->Size = sizeof(TP_CALLBACK_ENVIRON);

		#endif

		}
		*/
		local envVersion, pcbe
		
		static TP_CALLBACK_PRIORITY_NORMAL:=1
		static sizeOf_TP_CALLBACK_ENVIRON_V1 := A_PtrSize == 4 ? 32 : 64	; The size depends on the os version.	(This is for Vista)
		static sizeOf_TP_CALLBACK_ENVIRON_V3 := A_PtrSize == 4 ? 40 : 72	;										(This is for >vista)
		envVersion := xlib.getEnvironmentVersion()
		pcbe := xlib.mem.globalAlloc( envVersion == 1 ? sizeOf_TP_CALLBACK_ENVIRON_V1 : sizeOf_TP_CALLBACK_ENVIRON_V3)
		NumPut(envVersion, pcbe, 0, "Uint")																		; CallbackEnviron->Version
		if (envVersion == 3){
			NumPut(TP_CALLBACK_PRIORITY_NORMAL,		pcbe, A_PtrSize == 4 ? 32 : 60, "Uint")						; CallbackEnviron->CallbackPriority
			NumPut(sizeOf_TP_CALLBACK_ENVIRON_V3, 	pcbe, A_PtrSize == 4 ? 36 : 64, "Uint")						; CallbackEnviron->Size
		}
		return pcbe
	}
	setThreadpoolCallbackCleanupGroup(pcbe, ptpcg, pfng:=0){
		; Url:
		;	- https://msdn.microsoft.com/en-us/library/windows/desktop/ms686255(v=vs.85).aspx  (SetThreadpoolCallbackCleanupGroup function)
		; Parameters:
		;	_Inout_  PTP_CALLBACK_ENVIRON              pcbe,
		;	_In_     PTP_CLEANUP_GROUP                 ptpcg,
		;	_In_opt_ PTP_CLEANUP_GROUP_CANCEL_CALLBACK pfng
		; Note:
		;	- This function does not return a value.
		;	- This function is implemented as an inline function.
		;
		;	CallbackEnviron->CleanupGroup = CleanupGroup;
		;	CallbackEnviron->CleanupGroupCancelCallback = CleanupGroupCancelCallback;
		;
		numput(ptpcg,	pcbe,	A_PtrSize == 4 ? 8  : 16, "ptr")
		numput(pfng, 	pcbe,	A_PtrSize == 4 ? 12 : 24, "ptr")
		return
	}
	setThreadpoolCallbackLibrary(pcbe, mod){
		; Url:
		;	- https://msdn.microsoft.com/en-us/library/windows/desktop/ms686258(v=vs.85).aspx (SetThreadpoolCallbackLibrary function)
		; Parameters:
		;	_Inout_ PTP_CALLBACK_ENVIRON pcbe,
		;	_In_    PVOID                mod
		; Note:
		;	- This function does not return a value.
		DllCall("Kernel32.dll\SetThreadpoolCallbackLibrary", "ptr," pcbe, "ptr", mod)
		return
	}
	setThreadpoolCallbackPool(pcbe,ptpp){
		; Url:
		;	- https://msdn.microsoft.com/en-us/library/windows/desktop/ms686261(v=vs.85).aspx (SetThreadpoolCallbackPool function)
		; Parameters:
		;	_Inout_ PTP_CALLBACK_ENVIRON pcbe,
		;	_In_    PTP_POOL             ptpp
		; Note:
		;	- Sets the thread pool to be used when generating callbacks.
		;	- Forced inline function.
		;
		; Parameters:
		; 	pcbe, 		a TP_CALLBACK_ENVIRON structure  that  defines  the  callback  environment.  The
		;				InitializeThreadpoolEnvironment  function  returns  this  structure. 
		;	TP_POOL, 	structure that defines the thread pool.  The  CreateThreadpool  function
		;				returns this structure.
		/*
			FORCEINLINE
			VOID
			TpSetCallbackThreadpool(
				__inout PTP_CALLBACK_ENVIRON CallbackEnviron,							(pcbe)
				__in    PTP_POOL             Pool
				)
			{
				CallbackEnviron->Pool = Pool;
			}
		*/
		NumPut(ptpp, pcbe, A_PtrSize == 4 ? 4 : 8, "Ptr")												; CallbackEnviron->Pool
		return
	}
	setThreadpoolCallbackPriority(pcbe, Priority:=1){
		; Url:
		;	- https://msdn.microsoft.com/en-us/library/windows/desktop/dd405519(v=vs.85).aspx (SetThreadpoolCallbackPriority function)
		; Parameters:
		;	_Inout_ PTP_CALLBACK_ENVIRON pcbe,
		;	_In_    TP_CALLBACK_PRIORITY Priority
		; Note:
		;	- This function does not return a value.
		;	- Forced inline function.
		;	- Higher priority callbacks are guaranteed to be run first by the first  available
		;	  worker  thread,  but  they  are  not guaranteed to finish before lower priority
		;	  callbacks.

		;	CallbackEnviron->CallbackPriority = Priority;
		; 	Priorities:
		/*
			TP_CALLBACK_PRIORITY_HIGH 		(0)	The callback should run at high priority.
			TP_CALLBACK_PRIORITY_LOW 		(1)	The callback should run at low priority.
			TP_CALLBACK_PRIORITY_NORMAL 	(2)	The callback should run at normal priority.
			TP_CALLBACK_PRIORITY_INVALID	(3)
		*/
		if type(Priority) !== 'Integer' || Priority < 0 || Priority > 2 
			xlib.exception("Invalid Priority value: " Priority ". Priority must be 0, 1 or 2.")
		local envVersion := xlib.getEnvironmentVersion()
		if (envVersion == 3)
			NumPut(Priority,	pcbe, A_PtrSize == 4 ? 32 : 60, "Uint")											; CallbackEnviron->CallbackPriority
		else
			xlib.exception(A_ThisFunc " not supported for this OS. Specifically, " envVersion)
		return
	
	}
	setThreadpoolCallbackRunsLong(pcbe){
		; Url:
		;	-  https://msdn.microsoft.com/en-us/library/windows/desktop/ms686263(v=vs.85).aspx (SetThreadpoolCallbackRunsLong function)
		; Parameters:
		;	_Inout_ PTP_CALLBACK_ENVIRON pcbe
		; Note:
		;	- This function does not return a value.
		;
		;	CallbackEnviron->u.s.LongFunction = 1;
		;
		;	union {
		;			DWORD                          Flags;									28 : 56	
		;			struct {
		;				DWORD                      LongFunction :  1;
		;				DWORD                      Persistent   :  1;
		;				DWORD                      Private      : 30;
		;			} s;
		;	} u;
		local Flags := numget(pcbe, A_PtrSize == 4 ?  28 : 56, "uint")	
		numput(Flags | 1, pcbe, A_PtrSize == 4 ?  28 : 56, "uint")		; Set LongFunction = 1
	}
	;<< Callback >>
	;	CallbackMayRunLong
	callbackMayRunLong(pci){
		; Url:
		;	- https://msdn.microsoft.com/en-us/library/windows/desktop/ms681981(v=vs.85).aspx (CallbackMayRunLong function)
		; Parameters:
		;	_Inout_ PTP_CALLBACK_INSTANCE pci
		; Note:
		;	The CallbackMayRunLong function should be called only  by  the  thread  that  is
		;	processing  the  callback. Calling this function from another thread may cause a
		;	race condition. The CallbackMayRunLong function always  marks  the  callback  as
		;	long-running,  whether  or not a thread is available for processing callbacks or
		;	the threadpool is able to allocate a new thread. Therefore, this function should
		;	be called only once, even if it returns FALSE.
		return DllCall("Kernel32.dll\CallbackMayRunLong", "ptr", pci, "int")
	}
	;	<< Callback clean up >>
	;	DisassociateCurrentThreadFromCallback
	;	FreeLibraryWhenCallbackReturns
	;	LeaveCriticalSectionWhenCallbackReturns
	;	ReleaseMutexWhenCallbackReturns
	;	ReleaseSemaphoreWhenCallbackReturns
	;	SetEventWhenCallbackReturns
	disassociateCurrentThreadFromCallback(pci){
		; Url:
		;	- https://msdn.microsoft.com/en-us/library/windows/desktop/ms682581(v=vs.85).aspx (DisassociateCurrentThreadFromCallback function)
		; Parameters:
		;	_Inout_ PTP_CALLBACK_INSTANCE pci
		; Note:
		;	- This function does not return a value.
		DllCall("Kernel32.dll\DisassociateCurrentThreadFromCallback", "ptr", pci)
	}
	freeLibraryWhenCallbackReturns(pci, mod){
		; Url:
		;	-  https://msdn.microsoft.com/en-us/library/windows/desktop/ms683154(v=vs.85).aspx (FreeLibraryWhenCallbackReturns function)
		; Parameters:
		;	_Inout_ PTP_CALLBACK_INSTANCE pci,
		;	_In_    HMODULE               mod
		; Note:
		;	- This function does not return a value.
		DllCall("Kernel32.dll\FreeLibraryWhenCallbackReturns", "ptr", pci, "ptr", mod)
	}

	LeaveCriticalSectionWhenCallbackReturns(pci, pcs){
		; Url:
		;	- https://msdn.microsoft.com/en-us/library/windows/desktop/ms684171(v=vs.85).aspx (LeaveCriticalSectionWhenCallbackReturns function)
		; Parameters:
		;	_Inout_ PTP_CALLBACK_INSTANCE pci,
		;	_Inout_ PCRITICAL_SECTION     pcs	
		; Note:
		;	- This function does not return a value.
		DllCall("Kernel32.dll\LeaveCriticalSectionWhenCallbackReturns", "ptr", pci, "ptr", pcs)
	}
	ReleaseMutexWhenCallbackReturns(pci, mut){
		; Url:
		;	- https://msdn.microsoft.com/en-us/library/windows/desktop/ms685070(v=vs.85).aspx (ReleaseMutexWhenCallbackReturns function)
		; Parameters:
		;	_Inout_ PTP_CALLBACK_INSTANCE pci,
		;	_In_    HANDLE                mut
		; Note:
		;	- This function does not return a value.
		DllCall("Kernel32.dll\ReleaseMutexWhenCallbackReturns", "ptr", pci, "ptr", mut)
	}

	ReleaseSemaphoreWhenCallbackReturns(pci, sem, crel){
		; Url:
		;	- https://msdn.microsoft.com/en-us/library/windows/desktop/ms685073(v=vs.85).aspx (ReleaseSemaphoreWhenCallbackReturns function)
		; Parameters:
		;	_Inout_ PTP_CALLBACK_INSTANCE pci,
		;	_In_    HANDLE                sem,
		;	_In_    DWORD                 crel
		; Note:
		;	- This function does not return a value.
		DllCall("Kernel32.dll\ReleaseSemaphoreWhenCallbackReturns", "ptr", pci, "ptr", sem, "uint", crel)
	}
	setEventWhenCallbackReturns(pci, evt){
		; Url:
		;	-	https://msdn.microsoft.com/en-us/library/windows/desktop/ms686214(v=vs.85).aspx	(SetEventWhenCallbackReturns function)
		; Parameters:
		;	pci [in, out]
		;		A TP_CALLBACK_INSTANCE structure that defines the callback instance. 
		;		The structure is passed to the callback function.
		;	evt [in]	
		;		A handle to the event to be set.
		; Note:
		;	- This function does not return a value
		DllCall("Kernel32.dll\SetEventWhenCallbackReturns", "ptr", pci,"ptr", evt)
	}
}	; End pool