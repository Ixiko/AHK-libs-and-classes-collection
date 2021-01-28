/* Example
MsgBox % GetBinaryType("C:\Windows\System32\notepad.exe")    ; -> 64BIT
MsgBox % GetBinaryType("C:\Windows\SysWOW64\notepad.exe")    ; -> 32BIT
MsgBox % GetBinaryType("C:\Temp\ThisFileDoesNotExist.exe")   ; -> 0
*/

GetBinaryType(Application) {
    static GetBinaryType := "GetBinaryType" (A_IsUnicode ? "W" : "A")
    static Type := {0 : "32BIT", 1: "DOS", 2: "WOW", 3: "PIF", 4: "POSIX", 5: "OS216", 6: "64BIT"}
    if !(DllCall(GetBinaryType, "str", Application, "uint*", BinaryType))
        return 0
    return Type[BinaryType]
}