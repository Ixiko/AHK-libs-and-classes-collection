; Link:   	https://gist.github.com/tmplinshi/524e5aefb28bb22bf6c1dae9154609db
; Link:   	https://github.com/jNizM/AHK_Scripts/blob/master/src/process_thread_handle_module/IsProcessElevated.ahk
; Author:   tmplinshi
; Date:
; for:          AHK_L


; ===============================================================================================================================
; Check if a process is elevated
; ===============================================================================================================================
IsProcessElevated(ProcessID) {
    if !(hProcess := DllCall("OpenProcess", "uint", 0x0400, "int", 0, "uint", ProcessID, "ptr"))
        throw Exception("OpenProcess failed", -1)
    if !(DllCall("advapi32\OpenProcessToken", "ptr", hProcess, "uint", 0x0008, "ptr*", hToken))
        throw Exception("OpenProcessToken failed", -1), DllCall("CloseHandle", "ptr", hProcess)
    if !(DllCall("advapi32\GetTokenInformation", "ptr", hToken, "int", 20, "uint*", IsElevated, "uint", 4, "uint*", size))
        throw Exception("GetTokenInformation failed", -1), DllCall("CloseHandle", "ptr", hToken) && DllCall("CloseHandle", "ptr", hProcess)
    return IsElevated, DllCall("CloseHandle", "ptr", hToken) && DllCall("CloseHandle", "ptr", hProcess)
}

; ===============================================================================================================================

;MsgBox % IsProcessElevated(DllCall("GetCurrentProcessId"))
; 0 => Process is not elevated
; 1 => Process is elevated