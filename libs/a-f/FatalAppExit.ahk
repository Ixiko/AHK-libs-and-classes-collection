; https://msdn.microsoft.com/en-us/library/windows/desktop/ms679336(v=vs.85).aspx
FatalAppExit(Message) {
    DllCall("kernel32.dll\FatalAppExit", "UInt", 0, "Str", Message)
}