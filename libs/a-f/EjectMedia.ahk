;example from autohotkey help
EjectMedia(driveLetter) {
    local ; Force-local mode
    hVolume := DllCall("CreateFile"
        , "Str", "\\.\" . driveLetter
        , "UInt", 0x80000000 | 0x40000000  ; GENERIC_READ | GENERIC_WRITE
        , "UInt", 0x1 | 0x2  ; FILE_SHARE_READ | FILE_SHARE_WRITE
        , "UInt", 0
        , "UInt", 0x3  ; OPEN_EXISTING
        , "UInt", 0, "UInt", 0)
    if (hVolume != -1) {
        DllCall("DeviceIoControl"
            , "UInt", hVolume
            , "UInt", 0x2D4808   ; IOCTL_STORAGE_EJECT_MEDIA
            , "UInt", 0, "UInt", 0, "UInt", 0, "UInt", 0
            , "UIntP", dwBytesReturned  ; Unused.
            , "UInt", 0)
        DllCall("CloseHandle", "UInt", hVolume)
    }
}
