ReadDirectoryChangesW(
	hDirectory,
	lpBuffer,
	nBufferLength,
	bWatchSubtree,
	dwNotifyFilter,
	byref lpBytesReturned,
	lpOverlapped,
	lpCompletionRoutine) {
	
	if !dllcall( 'kernel32.dll\ReadDirectoryChangesW',
		'ptr',		hDirectory,				; HANDLE                         
	    'ptr',		lpBuffer,               ; LPVOID                         
	    'uint',		nBufferLength,          ; DWORD                          
	    'int' ,		bWatchSubtree,          ; BOOL                           
	    'uint',		dwNotifyFilter,         ; DWORD                          
	    'uint*',	lpBytesReturned,        ; LPDWORD                        
	    'ptr' ,		lpOverlapped,           ; LPOVERLAPPED                   
	    'ptr' ,		lpCompletionRoutine,    ; LPOVERLAPPED_COMPLETION_ROUTINE
		'int'								; BOOL
	)
		throw exception(a_thisfunc . ' failed.', -1, a_lasterror)
	return true
}

CreateFileW(
	lpFileName,				
	dwDesiredAccess,
	dwShareMode,
	lpSecurityAttributes,
	dwCreationDisposition,
	dwFlagsAndAttributes,
	hTemplateFile) {
	
	local
	if !h := dllcall('kernel32.dll\CreateFileW',
		'ptr',	lpFileName,				; LPCWSTR              		
		'uint',	dwDesiredAccess,        ; DWORD                
		'uint',	dwShareMode,            ; DWORD                
		'ptr',	lpSecurityAttributes,   ; LPSECURITY_ATTRIBUTES
		'uint',	dwCreationDisposition,  ; DWORD                
		'uint',	dwFlagsAndAttributes,   ; DWORD                
		'ptr',	hTemplateFile,          ; HANDLE               
		'ptr'							; HANDLE
	)
		throw exception(a_thisfunc . ' failed.', -1, a_lasterror)
	return h
}

CloseHandle( 
	hObject ) {
	
	if !dllcall('kernel32.dll\CloseHandle', 
		'ptr', hObject,					; HANDLE
		'int'							; BOOL
	)
		throw exception(a_thisfunc . ' failed.', -1, a_lasterror)
	return true
}

CancelIoEx(
	hFile,
	lpOverlapped) {
	static ERROR_NOT_FOUND := 1168
	local
	if (!r := dllcall('kernel32.dll\CancelIoEx',
		'ptr', hFile,					; HANDLE
		'ptr', lpOverlapped,			; LPOVERLAPPED
		'int'							; BOOL
	) )
		&& a_lasterror !== ERROR_NOT_FOUND
		throw exception(a_thisfunc . ' failed.', -1, a_lasterror)
	return r
}

SleepEx(
	dwMilliseconds,
	bAlertable) {
	
	return dllcall('kernel32\SleepEx', 
		'uint',	dwMilliseconds,			; DWORD
		'int',	bAlertable, 			; BOOL
		'uint'							; DWORD
	)
}
