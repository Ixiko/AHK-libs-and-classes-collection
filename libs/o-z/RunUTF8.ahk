RunUTF8(target, workdir:=".") {
    ; PROCESS_INFORMATION pi;
    VarSetCapacity(pi, 24, 0)
    ; STARTUPINFO si; si.cb = sizeof(si);
    VarSetCapacity(si, si_size := 32+9*A_PtrSize, 0), NumPut(si_size, si)
    ; Encode command line as UTF-8.
    VarSetCapacity(utf8, StrPut(target, "utf-8"))
    StrPut(target, &utf8, "utf-8")
    ; Launch process.
    if !DllCall("CreateProcessA", "ptr", 0, "ptr", &utf8, "ptr", 0
        , "ptr", 0, "int", false, "uint", 0, "ptr", 0, "str", workdir
        , "ptr", &si, "ptr", &pi)
        throw Exception("CreateProcessA failed; error " A_LastError, -1)
    ; Clean up.
    DllCall("CloseHandle", "ptr", NumGet(pi, 0))
    DllCall("CloseHandle", "ptr", NumGet(pi, A_PtrSize))
}