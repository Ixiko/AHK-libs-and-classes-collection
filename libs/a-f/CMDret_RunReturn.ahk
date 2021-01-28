CMDret_RunReturn(CMDin)
{
  VarSetCapacity(lpBuffer,1024)
  VarSetCapacity(sui,68, 0)
  VarSetCapacity(pi, 16, 0)
  VarSetCapacity(pa, 12, 0)
  InsertInteger( 12, pa, 0)
  InsertInteger( 1,  pa, 8)

  IF (DllCall("CreatePipe", "UInt*",hRead, "UInt*",hWrite, UInt,&pa, Int,0) <> 0) {
    InsertInteger(68,    sui, 0)
    DllCall("GetStartupInfo", "UInt", &sui)
    InsertInteger(0x101, sui, 44)
    InsertInteger(0,     sui, 48)
    InsertInteger(hWrite,sui, 60)
    InsertInteger(hWrite,sui, 64)

    IF (DllCall("CreateProcess",Int,0,Str,CMDin,Int,0,Int,0,Int,1,UInt,0,Int,0,Int,0,UInt,&sui,UInt,&pi)<>0) {
      cmdretPID := GetUInt(pi, 8)
      Loop {
        IF DllCall("PeekNamedPipe",uint,hRead, uint,0, uint,0, uint,0, "UInt*",bSize, uint,0) = 0
          break
        Process Exist, %cmdretPID%
        IfEqual ErrorLevel,0, break
        IfEqual bSize, 0, Continue
        VarSetCapacity(lpBuffer, bSize)
        IF (DllCall("ReadFile",UInt,hRead, Str,lpBuffer, Int,bSize, "UInt*",bRead, Int,0) > 0) {
          IFEqual bRead,0, Continue
          DllCall("lstrcpyn", UInt,&lpBuffer, UInt,&lpBuffer, Int,bRead)
          CMDout = %CMDout%%lpBuffer%
          }
        Sleep 0
      } ; Loop
    } ; IF CreateProcess

    DllCall("CloseHandle", UInt, hWrite)
    DllCall("CloseHandle", UInt, hRead)
  } ; IF CreatePipe

  Return CMDout
}

InsertInteger(pInteger, ByRef pDest, pOffset = 0, pSize = 4) {
   Loop %pSize%
      DllCall("RtlFillMemory", UInt,&pDest+pOffset+A_Index-1, UInt,1, UChar,pInteger >> 8*A_Index-8)
}

GetUInt(ByRef pSource, pOffset = 0, Len = 4) {
   Loop %Len%
      result += *(&pSource+pOffset+A_Index-1) << 8*A_Index-8
   Return result
}
