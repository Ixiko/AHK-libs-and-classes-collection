SysError(ErrorNum = ""){
   static flag := (FORMAT_MESSAGE_ALLOCATE_BUFFER := 0x100) | (FORMAT_MESSAGE_FROM_SYSTEM := 0x1000)
   (ErrorNum = "" && ErrorNum := A_LastError)
   DllCall("FormatMessage", "UInt", flag, "UInt", 0, "UInt", ErrorNum, "UInt", 0, "PtrP", pBuff, "UInt", 512, "Str", "")
   Return (str := StrGet(pBuff)) ? str : ErrorNum
}