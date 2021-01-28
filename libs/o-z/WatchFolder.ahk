; Link:   	https://raw.githubusercontent.com/HelgeffegleH/AHK-misc./master/functions/watch_folder/watch_folder.ahk
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

watch_folder(
	dir,
	dwNotifyFilter,
	callback,
	bWatchSubtree := true ) {
	; params:
	;
	;	dir,			(string), 	the directory to watch-
	;	dwNotifyFilter,	(integer),	any valid combination of FILE_NOTIFY_CHANGE_XXX flags, see:
	;									https://docs.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-readdirectorychangesw
	;	callback, 		(func), 	the function to call when an event occurs. This function should accept one parameter:
	;								an object { Action, FileName, Directory },
	;								the function should return true to continue monitoring the folder.
	;
	;	bWatchSubtree,	(integer),	specify true (default) to also watch subfolders, else false.
	;
	; return:
	;
	;	function object, (closure),	call this function without any parameters to stop the watch and free memory. 
	;					 			You must not call this function object while the completion function executes.
	
	
	; constants:
	static NULL := 0
	
	static  FILE_SHARE_READ  			:= 1
          , FILE_SHARE_WRITE 			:= 2
          , OPEN_EXISTING    			:= 3
		  , FILE_FLAG_OVERLAPPED		:= 0x40000000
          , FILE_FLAG_BACKUP_SEMANTICS	:= 0x02000000
     
	
	static FILE_LIST_DIRECTORY := 0x0001
	
	local
	
	static timer_func := 0				
	if !timer_func
		timer_func := func('check_IO')	; Need a unique reference for the timer.
	
	hDirectory := CreateFileW(
		&dir,												; lpFileName
		FILE_LIST_DIRECTORY,								; dwDesiredAccess
		FILE_SHARE_READ | FILE_SHARE_WRITE,					; dwShareMode
		NULL,												; lpSecurityAttributes
		OPEN_EXISTING,										; dwCreationDisposition
		FILE_FLAG_BACKUP_SEMANTICS | FILE_FLAG_OVERLAPPED,	; dwFlagsAndAttributes
		NULL												; hTemplateFile
	)
	
	static nBufferLength := 1024
	
	try {
		lpBuffer := bufferalloc(nBufferLength)
		lpOverlapped := bufferalloc(a_ptrsize * 3 + 8, 0)
		lpCompletionRoutine := callbackcreate('CompletionRoutine')
		ReadDirectoryChangesW(
			hDirectory,
			lpBuffer,
			nBufferLength,
			bWatchSubtree,
			dwNotifyFilter, 
			0,						; lpBytesReturned
			lpOverlapped,
			lpCompletionRoutine 
		)
	} catch e {
		if isSet(lpCompletionRoutine) ; for the rare case where callbackcreate or bufferalloc failed, probably out of mem.
			callbackfree lpCompletionRoutine
		CloseHandle hDirectory
		throw e
	}
	
	set_sleep_timer +1
	can_stop := true	; free var, used by stop_watch to make sure it is not called while the callback is executing.
	return func('stop_watch')
	
	; Nested functions:
	
	check_IO(*) => SleepEx(0, true) 
	
	stop_watch() {
		; this function must be called by the user to stop the watch
		; and to free memory.
		; This can be called at any time except when the user completion routine executes.
		if !can_stop
			throw exception(a_thisfunc . ' failed.', -1, 'Callback is executing')
		if lpCompletionRoutine == '' 
			|| hDirectory == ''
			return
		if CancelIoEx(hDirectory, NULL)
			check_IO
		set_sleep_timer -1
		callbackfree lpCompletionRoutine
		CloseHandle hDirectory
		lpCompletionRoutine := ''
		hDirectory := ''
	}
	set_sleep_timer(count) {
		; The completion routine is only called when the thread is in an alertable state
		; Calling SleepEx with the second parameter set to TRUE causes the thread
		; to be alertable.
		static counter := 0
		static timer_interval := 50
		counter += count
		if count == 1 && counter == 1
			settimer timer_func, timer_interval
		else if count == -1 && counter <= 0 {
			count := 0
			settimer timer_func, 0
		}
	}
	
	CompletionRoutine( 
		dwErrorCode,
		dwNumberOfBytesTransfered,
		lpOverlapped_ptr) { ; this is the pointer to the lpOverlapped buffer to which
							; lpOverlapped refers, must let lpOverlapped be a free var
							; to keep it alive. This parameter is not used.
		
		critical(30), can_stop := false
		
		dwErrorCode &= 0xffffffff
		dwNumberOfBytesTransfered &= 0xffffffff
		
		if !dwErrorCode && dwNumberOfBytesTransfered { ; Success
			local NextEntryOffset := 0 ; free var
			local cb_result := 0
			try {
				loop 
					cb_result :=  % callback %( next_record() )
				until !NextEntryOffset || !cb_result
				; Continue monitor
				if cb_result	
					ReadDirectoryChangesW(
						hDirectory,
						lpBuffer,
						nBufferLength,
						bWatchSubtree,
						dwNotifyFilter, 
						0,						; lpBytesReturned
						lpOverlapped,
						lpCompletionRoutine 
					)	
			}				
			finally
				can_stop := true
		}
		else
			can_stop := true
		return
		next_record() {
			local result :=  {
				Action : numget(lpBuffer, NextEntryOffset + 4, 'uint'),
				FileName : strget(lpBuffer.ptr + 12 + NextEntryOffset,
					numget(lpBuffer, 8, 'uint') // 2 ),
				Directory : dir
			}
			local bytes_to_skip := numget(lpBuffer, NextEntryOffset, 'uint')
			if bytes_to_skip
				NextEntryOffset += bytes_to_skip
			else
				NextEntryOffset := 0
			return result
		}
	} ; end CompletionRoutine
	#include lib\kernel32.ahk
}