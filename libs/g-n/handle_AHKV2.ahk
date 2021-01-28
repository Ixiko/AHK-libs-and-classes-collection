SetHandleInformation(
	hObject,
	dwMask,
	dwFlags ) {
	/*
	BOOL WINAPI SetHandleInformation(
		_In_ HANDLE hObject,
		_In_ DWORD  dwMask,
		_In_ DWORD  dwFlags
	);
	url:
		- https://msdn.microsoft.com/en-us/library/windows/desktop/ms724935(v=vs.85).aspx (SetHandleInformation function)
	*/
	return dllcall('Kernel32.dll\SetHandleInformation', 'ptr', hObject, 'uint', dwMask, 'uint', dwFlags, 'int')
}
GetStdHandle(nStdHandle){
	/*
	HANDLE WINAPI GetStdHandle(
		_In_ DWORD nStdHandle
	);
	*/
	local h := dllcall('Kernel32.dll\GetStdHandle', 'uint', nStdHandle, 'ptr')
	if !h
		throw exception('GetStdHandle failed to get: ' . string( nStdHandle ) . '.')
	return h
}
CloseHandle(hObject) {
	/*
	BOOL WINAPI CloseHandle(
		_In_ HANDLE hObject
	);
	*/
	return dllcall('Kernel32.dll\CloseHandle', 'ptr', hObject, 'int')
}