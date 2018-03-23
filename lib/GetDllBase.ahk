GetDllBase(DllName, PID = 0)
{
    TH32CS_SNAPMODULE := 0x00000008
    INVALID_HANDLE_VALUE = -1
    VarSetCapacity(me32, 548, 0)
    NumPut(548, me32)
    snapMod := DllCall("CreateToolhelp32Snapshot", "Uint", TH32CS_SNAPMODULE
                                                 , "Uint", PID)
    If (snapMod = INVALID_HANDLE_VALUE) {
        Return 0
    }
    If (DllCall("Module32First", "Uint", snapMod, "Uint", &me32)){
        while(DllCall("Module32Next", "Uint", snapMod, "UInt", &me32)) {
            If !DllCall("lstrcmpi", "Str", DllName, "UInt", &me32 + 32) {
                DllCall("CloseHandle", "UInt", snapMod)
                Return NumGet(&me32 + 20)
            }
        }
    }
    DllCall("CloseHandle", "Uint", snapMod)
    Return 0
}