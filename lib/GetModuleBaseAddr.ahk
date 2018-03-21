; ===============================================================================================================================
; Gets the base address and size of the module in the context of the owning process
; ===============================================================================================================================

GetModuleBaseAddr(ModuleName, ProcessID)
{
    if !(hSnapshot := DllCall("CreateToolhelp32Snapshot", "uint", 0x18, "uint", ProcessID))
        throw Exception("CreateToolhelp32Snapshot", -1)

    NumPut(VarSetCapacity(MODULEENTRY32, (A_PtrSize = 8 ? 568 : 548), 0), MODULEENTRY32, "uint")
    if !(DllCall("Module32First", "ptr", hSnapshot, "ptr", &MODULEENTRY32))
        throw Exception("Module32First", -1), DllCall("CloseHandle", "ptr", hSnapshot)

    ME32 := {}
    while (DllCall("Module32Next", "ptr", hSnapshot, "ptr", &MODULEENTRY32)) {
        if (ModuleName = StrGet(&MODULEENTRY32+ (A_PtrSize = 8 ? 48 : 32), 256, "cp0")) {
            ME32.Addr := Format("{:#016x}", NumGet(MODULEENTRY32, (A_PtrSize = 8 ? 24 : 20), "uptr"))
            ME32.Size := Format("{:#016x}", NumGet(MODULEENTRY32, (A_PtrSize = 8 ? 32 : 24), "uint"))
        }
    }

    return ME32, DllCall("CloseHandle", "ptr", hSnapshot)
}

; ===============================================================================================================================

OwnPID   := DllCall("GetCurrentProcessId")
ModuleBase := GetModuleBaseAddr("user32.dll", OwnPID)

MsgBox % "modBaseAddr:`t" ModuleBase.Addr "`nmodBaseSize:`t" ModuleBase.Size " bytes"
; modBaseAddr:    0x007ffa841e0000
; modBaseSize:    0x00000000165000 bytes