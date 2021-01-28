RunGetStdOut(sCmd, sEncoding := "CP0", sDir := "", ByRef nExitCode := 0, Callback := "") {
    DllCall("CreatePipe", "Ptr*", hStdOutRd, "Ptr*", hStdOutWr, "Ptr", 0, "UInt", 0)
    DllCall("SetHandleInformation", "Ptr", hStdOutWr, "UInt", 1, "UInt", 1)

    ; STARTUPINFO
    NumPut(VarSetCapacity(si, A_PtrSize == 4 ? 68 : 104, 0), si, 0, "UInt")
    NumPut(0x100,     si, A_PtrSize == 4 ? 44 : 60, "UInt") ; dwFlags: STARTF_USESTDHANDLES
    NumPut(hStdOutWr, si, A_PtrSize == 4 ? 60 : 88, "Ptr" ) ; hStdOutput
    NumPut(hStdOutWr, si, A_PtrSize == 4 ? 64 : 96, "Ptr" ) ; hStdError

    ; PROCESS_INFORMATION
    VarSetCapacity(pi, A_PtrSize == 4 ? 16 : 24, 0)
    ; CREATE_NO_WINDOW = 0x08000000
    If (!DllCall("CreateProcess", "Ptr", 0, "Ptr", &sCmd, "Ptr", 0, "Ptr", 0, "Int", True
      , "UInt", 0x08000000, "Ptr", 0, "Ptr", sDir ? &sDir : 0, "Ptr", &si, "Ptr", &pi)) {
        DllCall("CloseHandle", "Ptr", hStdOutWr)
        DllCall("CloseHandle", "Ptr", hStdOutRd)
        Return ""
    }

    DllCall("CloseHandle", "Ptr", hStdOutWr) ; The write pipe must be closed before reading the stdout.

    sOutput := ""
    While (1) {
        ; Before reading, we check if the pipe has been written to, so we avoid freezings.
        If (!DllCall("PeekNamedPipe", "Ptr", hStdOutRd, "Ptr", 0, "UInt", 0, "Ptr", 0, "UInt*", nTot, "Ptr", 0)) {
            Break
        }

        If (!nTot) { ; If the pipe buffer is empty, sleep and continue checking.
            Sleep 100
            Continue
        }

        ; Pipe buffer is not empty, so we can read it.
        VarSetCapacity(sTemp, nTot + 1)
        DllCall("ReadFile", "Ptr", hStdOutRd, "Ptr", &sTemp, "UInt", nTot, "Ptr*", nSize, "Ptr", 0)
        sOutput .= sStdOut := StrGet(&sTemp, nSize, sEncoding)
        If (Callback != "") {
            %Callback%(sStdOut)
        }
    }

    DllCall("GetExitCodeProcess", "Ptr", NumGet(pi, 0), "UInt*", nExitCode)
    DllCall("CloseHandle", "Ptr", NumGet(pi, 0)) ; hProcess
    DllCall("CloseHandle", "Ptr", NumGet(pi, A_PtrSize)) ; hThread
    DllCall("CloseHandle", "Ptr", hStdOutRd)
    Return sOutput
}
