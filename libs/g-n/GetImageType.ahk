GetImageType(PID) { ;from AHK-Spy

    ; PROCESS_QUERY_INFORMATION
    hProc := DllCall("OpenProcess", "UInt", 0x400, "Int", False, "UInt", PID, "Ptr")
    If !hProc
        Return "N/A"

    If A_Is64bitOS
        Try DllCall("IsWow64Process", "Ptr", hProc, "Int*", Is32Bit := True) ; Determines whether the specified process is running under WOW64.
    else
        Is32Bit := True

    DllCall("CloseHandle", "Ptr", hProc)

Return (Is32Bit) ? "32-bit" : "64-bit"
}
