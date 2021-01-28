; Link:   	https://www.autohotkey.com/boards/viewtopic.php?t=44115
; Author:
; Date:
; for:     	AHK_L

/*


*/

; DOWNLOAD BIN DATA TO A VARIABLE
DownloadBin(url, byref buf){
    static a := "AutoHotkey/" A_AhkVersion
    if (!DllCall("LoadLibrary", "str", "wininet") || !(h := DllCall("wininet\InternetOpen", "str", a, "uint", 1, "ptr", 0, "ptr", 0, "uint", 0, "ptr")))
        return 0
    c := s := 0
    if (f := DllCall("wininet\InternetOpenUrl", "ptr", h, "str", url, "ptr", 0, "uint", 0, "uint", 0x80003000, "ptr", 0, "ptr"))
    {
        while (DllCall("wininet\InternetQueryDataAvailable", "ptr", f, "uint*", s, "uint", 0, "ptr", 0) && s > 0)
        {
            VarSetCapacity(b, c + s, 0)
            if (c > 0)
                DllCall("RtlMoveMemory", "ptr", &b, "ptr", &buf, "ptr", c)
            DllCall("wininet\InternetReadFile", "ptr", f, "ptr", &b + c, "uint", s, "uint*", r)
            c += r
            VarSetCapacity(buf, c, 0)
            if (c > 0)
                DllCall("RtlMoveMemory", "ptr", &buf, "ptr", &b, "ptr", c)
        }
        DllCall("wininet\InternetCloseHandle", "ptr", f)
    }
    DllCall("wininet\InternetCloseHandle", "ptr", h)
    return c
}