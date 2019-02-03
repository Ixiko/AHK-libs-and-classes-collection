SoftModalMessageBox(Text, Title, Buttons, DefBtn := 1, Options := 0x1, IconRes := "", IconID := 1, Timeout := -1, Owner := 0, Callback := "") {

    If (IconRes != "") {
        hModule := DllCall("GetModuleHandle", "Str", IconRes, "Ptr")
        LoadLib := !hModule
            && hModule := DllCall("kernel32.dll\LoadLibraryEx", "Str", IconRes, "UInt", 0, "UInt", 0x2, "Ptr")
        Options |= 0x80 ; MB_USERICON
    } Else {
        hModule := 0
        LoadLib := False
    }

    cButtons := Buttons.Length()
    VarSetCapacity(ButtonIDs, cButtons * A_PtrSize, 0)
    VarSetCapacity(ButtonText, cButtons * A_PtrSize, 0)
    Loop %cButtons% {
        NumPut(Buttons[A_Index][1], ButtonIDs, 4 * (A_Index - 1), "UInt")
        NumPut(&(b%A_Index% := Buttons[A_Index][2]), ButtonText, A_PtrSize * (A_Index - 1), "Ptr")
    }

    If (Callback != "") {
        Callback := RegisterCallback(Callback, "F")
    }

    x64 := A_PtrSize == 8
    Offsets := (A_Is64BitOS) ? (x64 ? [96, 104, 112, 116, 120, 124] : [52, 56, 60, 64, 68, 72]) : [48, 52, 56, 60, 64, 68]

    ; MSGBOXPARAMS and MSGBOXDATA structures
    ;NumPut(VarSetCapacity(MBCONFIG, (x64) ? 136 : 80, 0), MBCONFIG, 0, "UInt")
    NumPut(VarSetCapacity(MBCONFIG, (x64) ? 128 : 76, 0), MBCONFIG, 0, "UInt")
    NumPut(Owner,    MBCONFIG, 1 * A_PtrSize, "Ptr")  ; Owner window
    NumPut(hModule,  MBCONFIG, 2 * A_PtrSize, "Ptr")  ; Icon resource
    NumPut(&Text,    MBCONFIG, 3 * A_PtrSize, "Ptr")  ; Message
    NumPut(&Title,   MBCONFIG, 4 * A_PtrSize, "Ptr")  ; Window title
    NumPut(Options,  MBCONFIG, 5 * A_PtrSize, "UInt") ; Options
    NumPut(IconID,   MBCONFIG, 6 * A_PtrSize, "Ptr")  ; Icon resource ID
    NumPut(Callback, MBCONFIG, 8 * A_PtrSize, "Ptr")  ; Callback
    NumPut(&ButtonIDs,  MBCONFIG, Offsets[1], "Ptr")  ; Button IDs
    NumPut(&ButtonText, MBCONFIG, Offsets[2], "Ptr")  ; Button texts
    NumPut(cButtons,    MBCONFIG, Offsets[3], "UInt") ; Number of buttons
    NumPut(DefBtn - 1,  MBCONFIG, Offsets[4], "UInt") ; Default button
    NumPut(1,           MBCONFIG, Offsets[5], "UInt") ; Allow cancellation
    NumPut(Timeout,     MBCONFIG, Offsets[6], "Int")  ; Timeout (ms)

    ProcAddr := DllCall("GetProcAddress", Ptr, DllCall("LoadLibrary", Str, "user32.dll", Ptr), AStr, "SoftModalMessageBox", Ptr)
    Ret := DllCall(ProcAddr, "Ptr", &MBCONFIG)

    If (LoadLib) {
        DllCall("FreeLibrary", "Ptr", hModule)
    }

    If (Callback != "") {
        DllCall("GlobalFree", "Ptr", Callback)
    }

    Return Ret
}