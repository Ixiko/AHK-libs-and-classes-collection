; https://www.autohotkey.com/boards/viewtopic.php?t=66685

url := "https://www.autohotkey.com/boards/viewtopic.php?f=76&t=66685&p=286791"
DataFromUrl(url, data)
MsgBox, % StrGet(&data, "utf-8")

DataFromUrl(url, ByRef data) {
   static userAgent := "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0"
        , INTERNET_OPEN_TYPE_DIRECT := 1
        , OpenUrlFlags   := ( INTERNET_FLAG_IGNORE_CERT_CN_INVALID   := 0x00001000 )
                          | ( INTERNET_FLAG_IGNORE_CERT_DATE_INVALID := 0x00002000 )
                          | ( INTERNET_FLAG_RELOAD                   := 0x80000000 )
        , QueryInfoFlags := ( HTTP_QUERY_FLAG_NUMBER                 := 0x20000000 )
                          | ( HTTP_QUERY_CONTENT_LENGTH              := 0x00000005 )
        , FILE_BEGIN := 0, INVALID_SET_FILE_POINTER := -1, NO_ERROR := 0
        , HEAP_ZERO_MEMORY := 0x8

   #MaxMem 4095
   if !hLib := DllCall("LoadLibrary", Str, "Wininet.dll", Ptr)
      throw Exception("Can't load Wininet.dll")

   Loop 1 {
      if !hInternet := DllCall("Wininet\InternetOpen", Str, userAgent, UInt, INTERNET_OPEN_TYPE_DIRECT, Ptr, 0, Ptr, 0, UInt, 0, Ptr) {
         error := "InternetOpen fails. Last Error: " . A_LastError
         break
      }
      Loop {
         attemptCount := A_Index
         start := A_TickCount
         while !hUrl := DllCall("Wininet\InternetOpenUrl", Ptr, hInternet, Str, url, Ptr, 0, UInt, 0, UInt, OpenUrlFlags, Ptr, 0, Ptr) {
            if (A_TickCount - start > 30000 && error := "InternetOpenUrl fails. LastError: " . A_LastError . "`nCheck the internet connection!")
               break 2
            Sleep, 1000
         }
         if (attemptCount = 1) {
            DllCall("Wininet\HttpQueryInfo", Ptr, hUrl, UInt, QueryInfoFlags, UIntP, fullSize, UIntP, l := 4, UIntP, idx := 0)
            hHeap := DllCall("GetProcessHeap", Ptr)
            pHeap := DllCall("HeapAlloc", Ptr, hHeap, UInt, HEAP_ZERO_MEMORY, Ptr, buffSize := fullSize ? fullSize : 0x100000, Ptr)
            prevSize := bytesRead := 0
         }
         else {
            res := DllCall("Wininet\InternetSetFilePointer", Ptr, hUrl, UInt, bytesRead & 0xFFFFFFFF
                                                                      , IntP, h := (bytesRead >> 32), UInt, FILE_BEGIN, UInt, 0)
            if (res = INVALID_SET_FILE_POINTER && A_LastError != NO_ERROR) {
               error := "InternetSetFilePointer fails. Last Error: " . A_LastError
               break 2
            }
         }
         Loop {
            if !DllCall("Wininet\InternetQueryDataAvailable", Ptr, hUrl, UIntP, size, UInt, 0, Ptr, 0)
               break
            if (size = 0 && EOF := true)
               break
            if (bytesRead + size > buffSize) {
               pHeapNew := DllCall("HeapAlloc", Ptr, hHeap, UInt, HEAP_ZERO_MEMORY, Ptr, buffSize *= 2, Ptr)
               DllCall("RtlMoveMemory", Ptr, pHeapNew, Ptr, pHeap, Ptr, bytesRead)
               DllCall("HeapFree", Ptr, hHeap, UInt, 0, Ptr, pHeap)
               pHeap := pHeapNew
            }
            if !DllCall("Wininet\InternetReadFile", Ptr, hUrl, Ptr, pHeap + bytesRead, UInt, size, UIntP, read)
               break
            bytesRead += read
         }
         DllCall("Wininet\InternetCloseHandle", Ptr, hUrl)
      } until EOF || (attemptCount = 3 && error := "Can't download the file. Unknown error")
   }
   ( hInternet && DllCall("Wininet\InternetCloseHandle", Ptr, hInternet) )
   DllCall("FreeLibrary", Ptr, hLib)
   if error {
      DllCall("HeapFree", Ptr, hHeap, UInt, 0, Ptr, pHeap)
      throw Exception(error)
   }
   else {
      VarSetCapacity(data, bytesRead, 0)
      DllCall("RtlMoveMemory", Ptr, &data, Ptr, pHeap, Ptr, bytesRead)
   }
   DllCall("HeapFree", Ptr, hHeap, UInt, 0, Ptr, pHeap)
   Return bytesRead
}