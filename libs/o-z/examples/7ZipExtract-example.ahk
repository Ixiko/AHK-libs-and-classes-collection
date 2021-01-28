#SingleInstance, Force
SetWorkingDir, % A_ScriptDir

7ZipDLL := (A_PtrSize = 8 ? "7-zip64.dll" : "7-zip32.dll")

If (!hModule := DllCall("Kernel32.dll\LoadLibrary", "Str", 7ZipDLL, "Ptr")) {
	Throw, "LoadLibrary fail"
}

7Zip_SevenZip(7ZipDLL, "x ""test.zip"" -r- -o" A_ScriptDir " -aoa")

DllCall("Kernel32.dll\FreeLibrary", "Ptr", hModule)

ExitApp
return

7Zip_SevenZip(7ZipDLL, sCommand) {
	nSize := 32768
	VarSetCapacity(tOutBuffer, nSize)

	aRet := DllCall(7ZipDLL "\SevenZip", "Ptr", hWnd, "AStr", sCommand, "Ptr", &tOutBuffer, "Int", nSize)

	If (!ErrorLevel) {
		return StrGet(&tOutBuffer, nSize, "CP0"), ErrorLevel := aRet
	} Else {
		return 0
	}
}