GetParentPID() {
	hScriptProc := DllCall("GetCurrentProcess", "ptr")

	VarSetCapacity(pbi, sizeof_pbi := 6*A_PtrSize)
	if DllCall("ntdll\NtQueryInformationProcess", "ptr", hScriptProc, "uint", 0, "ptr", &pbi, "uint", sizeof_pbi, "ptr", 0, "uint") ; 0=ProcessBasicInformation
		throw Exception("NtQueryInformationProcess()", 0, rc " - " w " - " sizeof_pbi) ; Short msg since so rare.

	return NumGet(pbi, 5*A_PtrSize)
}
