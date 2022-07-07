MessageBoxTimeout(hWnd, Text, Title := "", Flags := 0, Milliseconds := 0) {
    Return DllCall("MessageBoxTimeout", "Ptr", hWnd, "Str", Text, "Str", Title, "UInt", Flags, "UShort", 0, "UInt", Milliseconds)
}