
CommandLineToArgs(cmd) {
    argv := DllCall("shell32\CommandLineToArgvW", "wstr", cmd, 'int*', &narg:=0, "ptr")
    try {
        args := []
        Loop args.Capacity := narg
            args.Push(StrGet(NumGet(argv, (A_Index-1)*A_PtrSize, "ptr"), "UTF-16"))
    }
    finally
        DllCall("LocalFree", "ptr", argv)
    return args
}
