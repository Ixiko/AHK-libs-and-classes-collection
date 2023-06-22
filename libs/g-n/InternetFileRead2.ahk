
; 0x84000000 is INTERNET_FLAG_NO_CACHE_WRITE (0x04000000) and INTERNET_FLAG_RELOAD (0x80000000)
InternetFileRead2( ByRef V, URL, bSz=1024, F=0x84000000 ) {
  Static LIB="WININET\", N=""
  If (!DllCall( "GetModuleHandle", Str,"wininet.dll" )) {
    DllCall( "LoadLibrary", Str,"wininet.dll" ) ; load wininet.dll if it's not already loaded
  }
  hIO:=DllCall( LIB "InternetOpenA", Str,N, UInt,4, Str,N, Str,N, UInt,0 )
  If (!hIO) {
    Return -1 ; couldn't open internet IO
  }

  hIU:=DllCall( LIB "InternetOpenUrlA", UInt,hIO, Str,URL, Str,N, Int,0, UInt, F, UInt,0)
  If (!hIU) { ; failed to open handle to url
    DllCall( LIB "InternetCloseHandle", UInt,hIO ) ; clean up the open internet handle
    Return -2
  }

  ; make sure query returned 200 ok
  VarSetCapacity(QStatus, 100) ; 100 characters for status
  HTTP_QUERY_STATUS_CODE := 19
  if (DllCall( LIB "HttpQueryInfoA", UInt, hIU, Int, HTTP_QUERY_STATUS_CODE, Str, QStatus, UIntP, 100, UInt, 0)) {
    if (QStatus != "200") {
      return -3
    }
  }
  else {
    return -4 ; couldn't get status code, treat this as a fatal error
  }

  TtlB := 0
  outspace := 1024
  VarSetCapacity(Q, outspace)
  VarSetCapacity(recvbuf, bSz) ; set receive buffer size (will be reused for each read)
  Loop {
    if (!DllCall( LIB "InternetReadFile", UInt, hIU, UInt, &recvbuf, UInt, bSz, UIntP, R )) {
      ; read failed for some reason
      if (A_LastError == 122) { ; 122 is ERROR_INSUFFICIENT_BUFFER
        MsgBox, InternetReadFile failed for having too small a buffer
        if (bSz > 5000000) { ; set a hard limit of 10MB to prevent it from blowing up
          return -10
        }
        bSz *= 2
        VarSetCapacity(recvbuf, bSz)
        continue ; try again with larger buffer
      }
      else {
        MsgBox, InternetReadFile failed for some unknown reason
        return -11
      }
    }
    if (R == 0) {
      break ; successfully read and number of bytes returned was zero
    }
    while (TtlB + R > outspace) {
      VarSetCapacity(T, TtlB)
      DllCall("RtlMoveMemory", Str, T, Str, Q, UInt, TtlB) ; copy to temp space
      VarSetCapacity(Q, outspace*2, 0) ; allocate more space for Q
      DllCall("RtlMoveMemory", Str, Q, Str, T, UInt, TtlB) ; copy back
      VarSetCapacity(T, 0) ; free temp space
      outspace := outspace * 2
    }
    DllCall("RtlMoveMemory", UInt, &Q+TtlB, UInt, &recvbuf, UInt, R)
    TtlB += R
  }

  VarSetCapacity(V, 64)
  VarSetCapacity(V, 0) ; shrink V to the actual bytes received
  VarSetCapacity(V, TtlB) ; allocate exact space for V
  DllCall("RtlMoveMemory", Str, V, Str, Q, UInt, TtlB) ; copy data from accum buffer
  VarSetCapacity(Q, 0) ; free accumulation buffer
  ErrorLevel := 0
  return TtlB
}

DLP( WP=0, LP=0, Msg="" ) {
 If ( WP=1 ) {
 SysGet, m, MonitorWorkArea, 1
 y:=(mBottom-46-2), x:=(mRight-370-2), VarSetCapacity( Size,16,0 )
 DllCall( "shlwapi.dll\StrFormatByteSize64A", Int64,LP, Str,Size, UInt,16 )
 Size := ( Size="0 bytes" ) ? N : "«" Size "»"
 Progress, CWE6E3E4 CT000020 CBF73D00 x%x% y%y% w370 h46 B1 FS8 WM700 WS400 FM8 ZH8 ZY3
         ,, %Msg%  %Size%, InternetFileRead(), Tahoma
 WinSet, Transparent, 210, InternetFileRead()
 } Progress,% (P:=Round(WP/LP*100)),% "Memory Download: " wp " / " lp " [ " P "`% ]"
 IfEqual,wP,0, Progress, Off
}
;  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; The following function is a part of: VarZ 46L - Native Data Compression
; View topic : www.autohotkey.com/forum/viewtopic.php?t=45559
;  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

VarZ_Save( byRef V, File="" ) { ;   www.autohotkey.net/~Skan/wrapper/FileIO16/FileIO16.ahk
Return ( ( hFile :=  DllCall( "_lcreat", Str,File, UInt,0 ) ) > 0 )
                 ?   DllCall( "_lwrite", UInt,hFile, Str,V, UInt,VarSetCapacity(V) )
                 + ( DllCall( "_lclose", UInt,hFile ) << 64 ) : 0
}
