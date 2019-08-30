;<< Thread Api >>
	
class thread {

	createThread(lpStartAddress,lpParameter:=0,lpThreadAttributes:=0,dwStackSize:=0,dwCreationFlags:=0){
		; Url:
		;	- https://msdn.microsoft.com/en-us/library/windows/desktop/ms682453(v=vs.85).aspx (CreateThread function)
		; Note:
		;	- If the function fails, the return value is NULL.
		;	- The thread object remains in the system until the thread has terminated and all handles to it have been closed through a call to CloseHandle.
		/*
		LPSECURITY_ATTRIBUTES  lpThreadAttributes,
		SIZE_T                 dwStackSize,
		LPTHREAD_START_ROUTINE lpStartAddress,
		LPVOID                 lpParameter,
		DWORD                  dwCreationFlags,
		LPDWORD                lpThreadId
		*/
		local th, lpThreadId
		if !th:=DllCall("Kernel32.dll\CreateThread"	,"Ptr",		lpThreadAttributes 
													,"Uptr",	dwStackSize        
													,"Ptr",		lpStartAddress		
													,"Ptr",		lpParameter		
													,"Uint",	dwCreationFlags    
													,"PtrP",	lpThreadId
													,"Ptr")		; Return type
			xlib.exception("Thread initialise failed",[th],-2)
		return {hThread:th,threadId:lpThreadId}
	}
	resumeThread(hThread){
		; Url:
		;	- https://msdn.microsoft.com/en-us/library/windows/desktop/ms685086(v=vs.85).aspx (ResumeThread function)
		
		local r:=DllCall("Kernel32.dll\ResumeThread", "Ptr", hThread, "Uint")
		if (r == 0xFFFFFFFF)
			xlib.exception("ResumeThread failed. Thread handle: " . hThread . ".",[r],-2)
		return r
	}
	terminateThread(hThread,dwExitCode:=1){
		; Url:
		;	 - https://msdn.microsoft.com/en-us/library/windows/desktop/ms686717(v=vs.85).aspx (TerminateThread function) 
		; Notes:
		;	TerminateThread is used to cause a thread to exit. When this occurs, the  target
		;	thread  has no chance to execute any user-mode code. DLLs attached to the thread
		;	are not notified that the thread is terminating. The system frees  the  thread's
		;	initial  stack.  Windows Server 2003 and Windows XP: The target thread's initial
		;	stack is not freed, causing a resource leak.
		;	TerminateThread is used to cause a thread to exit. When this occurs, the  target
		;	thread  has no chance to execute any user-mode code. DLLs attached to the thread
		;	are not notified that the thread is terminating. The system frees  the  thread's
		;	initial  stack.  
		;	Windows Server 2003 and Windows XP: The target thread's initial
		;	stack is not freed, causing a resource leak.
		static STILL_ACTIVE:=259
		if !hThread
			xlib.exception("TherminateThread failed, thread handle invalid.",,-2,"Warn")
		else if (dwExitCode==STILL_ACTIVE)
			xlib.exception("TherminateThread failed, bad exit code: STILL_ACTIVE=259.",,-2,"Warn")
		else if !DllCall("Kernel32.dll\TerminateThread", "PtrP", hThread, "Uint",  dwExitCode)		; If the function fails, the return value is zero
			xlib.exception("","","",-2)
		else
			this.closeHandle(hThread)
	}
}	; End thread

;<< Wait Api >>		
class wait {
	waitForMultipleObjects(nCount, lpHandles, bWaitAll:=true, dwMilliseconds:=0xFFFFFFFF){
		; Url:
		;	https://msdn.microsoft.com/en-us/library/windows/desktop/ms687025(v=vs.85).aspx (WaitForMultipleObjects function)
		/*
		DWORD  nCount,
		HANDLE *lpHandles,
		BOOL   bWaitAll,
		DWORD  dwMilliseconds
		*/
		static WAIT_OBJECT_0:=	0x00000000
		static WAIT_ABANDONED:=	0x00000080
		static WAIT_TIMEOUT:=	0x00000102
		static WAIT_FAILED:=	0xFFFFFFFF
		local r
		r:=DllCall("Kernel32.dll\WaitForMultipleObjects", "Uint", nCount, "Ptr", lpHandles, "Int", bWaitAll, "Uint", dwMilliseconds, "Uint")
		if (r == WAIT_FAILED)
			xlib.exception("WaitForMultipleObjects failed for " . nCount . " number of objects.",[r],-1)
		if (r == WAIT_ABANDONED)
			xlib.exception("WaitForMultipleObjects failed for " . nCount . " number of objects. Reason: Wait abandoned" ,[r],-2)
		return r
	}
	waitForSingleObject(hHandle,dwMilliseconds){
		; Url:
		;	- https://msdn.microsoft.com/en-us/library/windows/desktop/ms687032(v=vs.85).aspx (WaitForSingleObject function)
		/*
		HANDLE hHandle,
		DWORD  dwMilliseconds
		*/
		static WAIT_OBJECT_0:=	0x00000000
		static WAIT_ABANDONED:=	0x00000080
		static WAIT_TIMEOUT:=	0x00000102
		static WAIT_FAILED:=	0xFFFFFFFF
		local r
		r:=DllCall("Kernel32.dll\WaitForSingleObject", "Ptr", hHandle, "Uint", dwMilliseconds, "Uint")
		if (r == WAIT_FAILED)
			xlib.exception("WaitForSingleObject failed for handle " . hHandle . ".",[r],-1)
		if (r == WAIT_ABANDONED)
			xlib.exception("WaitForSingleObject failed for handle " . hHandle . ". Reason: Wait abandoned" ,[r],-2)

		return r
	}
	waitOnAddress(Address,CompareAddress,AddressSize,dwMilliseconds){
		; Url:
		;	- https://msdn.microsoft.com/en-us/library/windows/desktop/hh706898(v=vs.85).aspx (WaitOnAddress function)
		/*
		VOID   volatile *Address,
		PVOID           CompareAddress,
		SIZE_T          AddressSize,
		DWORD           dwMilliseconds
		*/
		; Note: TRUE if the wait succeeded. If the operation fails, the function returns
		; FALSE.  If  the  wait  fails,  call  GetLastError  to  obtain  extended   error
		; information.  In  particular,  if the operation times out, GetLastError returns
		; ERROR_TIMEOUT.
		
		static ERROR_TIMEOUT:=1460  ; This operation returned because the timeout period expired. (0x5B4)
		local r
		r:=DllCall("Kernel32.dll\WaitOnAddress", "Ptr", Address, "Ptr", CompareAddress, "Ptr", AddressSize, "Uint", dwMilliseconds)
		if (!r && A_LastError==ERROR_TIMEOUT)
			return false
		else if r
			return true
		xlib.exception("WaitOnAddress failed, Address: " Address ", CompareAddress: " CompareAddress ", AddressSize: " AddressSize,,-2) 
	}
}	; End Wait