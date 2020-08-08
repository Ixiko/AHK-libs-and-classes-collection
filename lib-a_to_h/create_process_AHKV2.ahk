CreateProcess(
	lpApplicationName,
    lpCommandLine,
    lpProcessAttributes,
    lpThreadAttributes,
    bInheritHandles,
    dwCreationFlags,
    lpEnvironment,
    lpCurrentDirectory,
    lpStartupInfo,
    lpProcessInformation ){
	/*
	BOOL CreateProcessW(
		LPCWSTR               lpApplicationName,
		LPWSTR                lpCommandLine,
		LPSECURITY_ATTRIBUTES lpProcessAttributes,
		LPSECURITY_ATTRIBUTES lpThreadAttributes,
		BOOL                  bInheritHandles,
		DWORD                 dwCreationFlags,
		LPVOID                lpEnvironment,
		LPCWSTR               lpCurrentDirectory,
		LPSTARTUPINFOW        lpStartupInfo,
		LPPROCESS_INFORMATION lpProcessInformation
	);
	*/
	return dllcall('Kernel32.dll\CreateProcess',
		'ptr', 	lpApplicationName,
		'ptr', 	lpCommandLine,
		'ptr', 	lpProcessAttributes,
		'ptr', 	lpThreadAttributes,
		'int', 	bInheritHandles,
		'uint', dwCreationFlags,
		'ptr',	lpEnvironment,
		'ptr', 	lpCurrentDirectory,
		'ptr', 	lpStartupInfo,
		'ptr', 	lpProcessInformation,
		'int')
}