;AHK_V2

CreatePipe(
	hReadPipe,
	hWritePipe,
	lpPipeAttributes,
	nSize ) {
	/*
	BOOL WINAPI CreatePipe(
		_Out_    PHANDLE               hReadPipe,
		_Out_    PHANDLE               hWritePipe,
		_In_opt_ LPSECURITY_ATTRIBUTES lpPipeAttributes,
		_In_     DWORD                 nSize
	);
	url:
		- https://msdn.microsoft.com/en-us/library/windows/desktop/aa365152(v=vs.85).aspx (CreatePipe function)
	*/
	return dllcall('Kernel32.dll\CreatePipe',
		'ptr', 	hReadPipe,
		'ptr', 	hWritePipe,
		'ptr', 	lpPipeAttributes,
		'uint',	nSize,
		'int' )
}
WriteToPipe()
	; Read from a file and write its contents to the pipe for the child's STDIN.
	; Stop when there is no more data.
{
	local dwRead := 0, dwWritten := 0
	local chBuf := malloc( BUFSIZE )		; todo return and free
	local bSuccess := false

	loop
	{
		bSuccess := ReadFile(g_hInputFile, chBuf, BUFSIZE, &dwRead, NULL)
		if ( ! bSuccess || dwRead == 0 )
			break

		bSuccess := WriteFile(g_hChildStd_IN_Wr, chBuf, dwRead, &dwWritten, NULL)
		if ( ! bSuccess )
			break
	}

	; Close the pipe handle so the child process stops reading.
	if ( ! CloseHandle(g_hChildStd_IN_Wr) )
		ErrorExit(TEXT("StdInWr CloseHandle"))
}
ReadFromPipe()
	; Read output from the child process's pipe for STDOUT
	; and write to the parent process's pipe for STDOUT.
	; Stop when there is no more data.
{
	local dwRead := 0, dwWritten := 0
	local chBuf := malloc( BUFSIZE )		; todo return and free
	local bSuccess := false
	local hParentStdOut := GetStdHandle( STD_OUTPUT_HANDLE )

	loop
	{

		bSuccess := ReadFile( g_hChildStd_OUT_Rd, chBuf, BUFSIZE, &dwRead, NULL)
		if( ! bSuccess || dwRead == 0 )
			break

		bSuccess := WriteFile(hParentStdOut, chBuf, dwRead, &dwWritten, NULL)
		if (! bSuccess
			|| instr(strget(chBuf, 'cp0'), '__end__'))	; avoids parent script to get stuck in ReadFile
			break
	}
}
