; ----------------------------------------------------------------------------------------------------------------------
; Function .....: MCode
; Description ..: Allocate memory and write Machine Code there.
; Parameters ...: cBuf - Binary buffer that will receive the machine code.
; ..............: sHex - Hexadecimal representation of the machine code as a string.
; Author .......: Laszlo - http://www.autohotkey.com/board/topic/19483-machine-code-functions-bit-wizardry/
; ----------------------------------------------------------------------------------------------------------------------
MCode(ByRef cBuf, ByRef sHex) {
    VarSetCapacity(cBuf, szBuf:=StrLen(sHex)//2)
    Loop %szBuf%
        NumPut("0x" . SubStr(sHex, 2*A_Index-1, 2), cBuf, A_Index-1, "UChar")
}

; ----------------------------------------------------------------------------------------------------------------------
; Function .....: MCode_2
; Description ..: Allocate memory and write Machine Code there.
; Parameters ...: sMcode - String describing the machine code.
; Author .......: Bentschi
; ----------------------------------------------------------------------------------------------------------------------
MCode_2(ByRef sMcode) {
    Static e := {1:4, 2:1}, c := (A_PtrSize=8) ? "x64" : "x86"
    If ( !RegExMatch(sMcode, "^([0-9]+),(" c ":|.*?," c ":)([^,]+)", m) )
        Return
    If ( !DllCall( "Crypt32.dll\CryptStringToBinary", Str,m3, UInt,0, UInt,e[m1], Ptr,0, UInt*,s, Ptr,0, Ptr, 0 ) )
        Return
    p := DllCall( "GlobalAlloc", UInt,0, Ptr,s, Ptr )
    If ( c == "x64" )
        DllCall( "VirtualProtect", Ptr,p, Ptr,s, UInt,0x40, UInt*,op )
    If ( DllCall( "Crypt32.dll\CryptStringToBinary", Str,m3, UInt,0, UInt,e[m1], Ptr,p, UInt*,s, Ptr,0, Ptr,0 ) )
        Return p
    DllCall( "GlobalFree", Ptr,p )
}