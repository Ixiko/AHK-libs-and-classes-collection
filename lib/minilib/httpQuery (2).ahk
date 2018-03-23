; httpQuery-0-3-5.ahk
; httpQuery GET and POST requests by DerRaphael
; http://www.autohotkey.com/forum/topic33506.html
httpQuery(byref Result, lpszUrl, POSTDATA="", HEADERS="")
{   ; v0.3.5 (w) Sep, 8 2008 by Heresy & derRaphael / zLib-Style release
   ; updates Aug, 28 2008   
   ; currently the verbs showHeader, storeHeader, and updateSize are supported in httpQueryOps
   ; in case u need a different UserAgent, Proxy, ProxyByPass, Referrer, and AcceptType just
   ; specify them as global variables - mind the varname for referrer is httpQueryReferer [sic].
   ; Also if any special dwFlags are needed such as INTERNET_FLAG_NO_AUTO_REDIRECT or cache
   ; handling this might be set using the httpQueryDwFlags variable as global
   global httpQueryOps, httpAgent, httpProxy, httpProxyByPass, httpQueryReferer, httpQueryAcceptType
       , httpQueryDwFlags
   ; Get any missing default Values
   defaultOps =
   (LTrim Join|
      httpAgent=AutoHotkeyScript|httpProxy=0|httpProxyByPass=0|INTERNET_FLAG_SECURE=0x00800000
      SECURITY_FLAG_IGNORE_UNKNOWN_CA=0x00000100|SECURITY_FLAG_IGNORE_CERT_CN_INVALID=0x00001000
      SECURITY_FLAG_IGNORE_CERT_DATE_INVALID=0x00002000|SECURITY_FLAG_IGNORE_CERT_WRONG_USAGE=0x00000200
      INTERNET_OPEN_TYPE_PROXY=3|INTERNET_OPEN_TYPE_DIRECT=1|INTERNET_SERVICE_HTTP=3
   )
   Loop,Parse,defaultOps,|
   {
      RegExMatch(A_LoopField,"(?P<Option>[^=]+)=(?P<Default>.*)",http)
      if StrLen(%httpOption%)=0
         %httpOption% := httpDefault
   }

   ; Load Library
   hModule := DllCall("LoadLibrary", "Str", "WinINet.Dll")

   ; SetUpStructures for URL_COMPONENTS / needed for InternetCrackURL
   ; http://msdn.microsoft.com/en-us/library/aa385420(VS.85).aspx
   offset_name_length:= "4-lpszScheme-255|16-lpszHostName-1024|28-lpszUserName-1024|"
                  . "36-lpszPassword-1024|44-lpszUrlPath-1024|52-lpszExtrainfo-1024"
   VarSetCapacity(URL_COMPONENTS,60,0)
   ; Struc Size               ; Scheme Size                  ; Max Port Number
   NumPut(60,URL_COMPONENTS,0), NumPut(255,URL_COMPONENTS,12), NumPut(0xffff,URL_COMPONENTS,24)
   
   Loop,Parse,offset_name_length,|
   {
      RegExMatch(A_LoopField,"(?P<Offset>\d+)-(?P<Name>[a-zA-Z]+)-(?P<Size>\d+)",iCU_)
      VarSetCapacity(%iCU_Name%,iCU_Size,0)
      NumPut(&%iCU_Name%,URL_COMPONENTS,iCU_Offset)
      NumPut(iCU_Size,URL_COMPONENTS,iCU_Offset+4)
   }

   ; Split the given URL; extract scheme, user, pass, authotity (host), port, path, and query (extrainfo)
   ; http://msdn.microsoft.com/en-us/library/aa384376(VS.85).aspx
   DllCall("WinINet\InternetCrackUrlA","Str",lpszUrl,"uInt",StrLen(lpszUrl),"uInt",0,"uInt",&URL_COMPONENTS)

   ; Update variables to retrieve results
   Loop,Parse,offset_name_length,|
   {
      RegExMatch(A_LoopField,"-(?P<Name>[a-zA-Z]+)-",iCU_)
      VarSetCapacity(%iCU_Name%,-1)
   }
   nPort:=NumGet(URL_COMPONENTS,24,"uInt")
   
   ; Import any set dwFlags
   dwFlags := httpQueryDwFlags
   ; For some reasons using a selfsigned https certificates doesnt work
   ; such as an own webmin service - even though every security is turned off
   ; https with valid certificates works when
   if (lpszScheme = "https")
      dwFlags |= (INTERNET_FLAG_SECURE|SECURITY_FLAG_IGNORE_CERT_CN_INVALID
               |SECURITY_FLAG_IGNORE_CERT_WRONG_USAGE)

   ; Check for Header and drop exception if unknown or invalid URL
   if (lpszScheme="unknown") {
      Result := "ERR: No Valid URL supplied."
      Return StrLen(Result)
   }

   ; Initialise httpQuery's use of the WinINet functions.
   ; http://msdn.microsoft.com/en-us/library/aa385096(VS.85).aspx
   hInternet := DllCall("WinINet\InternetOpenA"
                  ,"Str",httpAgent,"UInt"
                  ,(httpProxy != 0 ?  INTERNET_OPEN_TYPE_PROXY : INTERNET_OPEN_TYPE_DIRECT )
                  ,"Str",httpProxy,"Str",httpProxyBypass,"Uint",0)

   ; Open HTTP session for the given URL
   ; http://msdn.microsoft.com/en-us/library/aa384363(VS.85).aspx
   hConnect := DllCall("WinINet\InternetConnectA"
                  ,"uInt",hInternet,"Str",lpszHostname, "Int",nPort
                  ,"Str",lpszUserName, "Str",lpszPassword,"uInt",INTERNET_SERVICE_HTTP
                  ,"uInt",0,"uInt*",0)

   ; Do we POST? If so, check for header handling and set default
   if (Strlen(POSTDATA)>0) {
      HTTPVerb:="POST"
      if StrLen(Headers)=0
         Headers:="Content-Type: application/x-www-form-urlencoded"
   } else ; otherwise mode must be GET - no header defaults needed
      HTTPVerb:="GET"   

   ; Form the request with proper HTTP protocol version and create the request handle
   ; http://msdn.microsoft.com/en-us/library/aa384233(VS.85).aspx
   hRequest := DllCall("WinINet\HttpOpenRequestA"
                  ,"uInt",hConnect,"Str",HTTPVerb,"Str",lpszUrlPath . lpszExtrainfo
                  ,"Str",ProVer := "HTTP/1.1", "Str",httpQueryReferer,"Str",httpQueryAcceptTypes
                  ,"uInt",dwFlags,"uInt",Context:=0 )

   ; Send the specified request to the server
   ; http://msdn.microsoft.com/en-us/library/aa384247(VS.85).aspx
   sRequest := DllCall("WinINet\HttpSendRequestA"
                  , "uInt",hRequest,"Str",Headers, "uInt",Strlen(Headers)
                  , "Str",POSTData,"uInt",Strlen(POSTData))

   VarSetCapacity(header, 2048, 0)  ; max 2K header data for httpResponseHeader
   VarSetCapacity(header_len, 4, 0)
   
   ; Check for returned server response-header (works only _after_ request been sent)
   ; http://msdn.microsoft.com/en-us/library/aa384238.aspx
   Loop, 5
     if ((headerRequest:=DllCall("WinINet\HttpQueryInfoA","uint",hRequest
      ,"uint",21,"uint",&header,"uint",&header_len,"uint",0))=1)
      break

   If (headerRequest=1) {
      VarSetCapacity(res,headerLength:=NumGet(header_len),32)
      DllCall("RtlMoveMemory","uInt",&res,"uInt",&header,"uInt",headerLength)
      Loop,% headerLength
         if (*(&res-1+a_index)=0) ; Change binary zero to linefeed
            NumPut(Asc("`n"),res,a_index-1,"uChar")
      VarSetCapacity(res,-1)
   } else
      res := "timeout"

   ; Get 1st Line of Full Response
   Loop,Parse,res,`n,`r
   {
      RetValue := A_LoopField
      break
   }
   
   ; No Connection established - drop exception
   If (RetValue="timeout") {
      html := "Error: timeout"
      return -1
   }
   ; Strip protocol version from return value
   RetValue := RegExReplace(RetValue,"HTTP/1\.[01]\s+")
   
    ; List taken from http://en.wikipedia.org/wiki/List_of_HTTP_status_codes
   HttpRetCodes := "100=Continue|101=Switching Protocols|102=Processing (WebDAV) (RFC 2518)|"
              . "200=OK|201=Created|202=Accepted|203=Non-Authoritative Information|204=No"
              . " Content|205=Reset Content|206=Partial Content|207=Multi-Status (WebDAV)"
              . "|300=Multiple Choices|301=Moved Permanently|302=Found|303=See Other|304="
              . "Not Modified|305=Use Proxy|306=Switch Proxy|307=Temporary Redirect|400=B"
              . "ad Request|401=Unauthorized|402=Payment Required|403=Forbidden|404=Not F"
              . "ound|405=Method Not Allowed|406=Not Acceptable|407=Proxy Authentication "
              . "Required|408=Request Timeout|409=Conflict|410=Gone|411=Length Required|4"
              . "12=Precondition Failed|413=Request Entity Too Large|414=Request-URI Too "
              . "Long|415=Unsupported Media Type|416=Requested Range Not Satisfiable|417="
              . "Expectation Failed|418=I'm a teapot (RFC 2324)|422=Unprocessable Entity "
              . "(WebDAV) (RFC 4918)|423=Locked (WebDAV) (RFC 4918)|424=Failed Dependency"
              . " (WebDAV) (RFC 4918)|425=Unordered Collection (RFC 3648)|426=Upgrade Req"
              . "uired (RFC 2817)|449=Retry With|500=Internal Server Error|501=Not Implem"
              . "ented|502=Bad Gateway|503=Service Unavailable|504=Gateway Timeout|505=HT"
              . "TP Version Not Supported|506=Variant Also Negotiates (RFC 2295)|507=Insu"
              . "fficient Storage (WebDAV) (RFC 4918)|509=Bandwidth Limit Exceeded|510=No"
              . "t Extended (RFC 2774)"
   
   ; Gather numeric response value
   RetValue := SubStr(RetValue,1,3)
   
   ; Parse through return codes and set according informations
   Loop,Parse,HttpRetCodes,|
   {
      HttpReturnCode := SubStr(A_LoopField,1,3)    ; Numeric return value see above
      HttpReturnMsg  := SubStr(A_LoopField,5)      ; link for additional information
      if (RetValue=HttpReturnCode) {
         RetMsg := HttpReturnMsg
         break
      }
   }

   ; Global HttpQueryOps handling
   if strlen(HTTPQueryOps)>0 {
      ; Show full Header response (usefull for debugging)
      if (instr(HTTPQueryOps,"showHeader"))
         MsgBox % res
      ; Save the full Header response in a global Variable
      if (instr(HTTPQueryOps,"storeHeader"))
         global HttpQueryHeader := res
      ; Check for size updates to export to a global Var
      if (instr(HTTPQueryOps,"updateSize")) {
         Loop,Parse,res,`n
            If RegExMatch(A_LoopField,"Content-Length:\s+?(?P<Size>\d+)",full) {
               global HttpQueryFullSize := fullSize
               break
            }
         if (fullSize+0=0)
            HttpQueryFullSize := "size unavailable"
      }
   }

   ; Check for valid codes and drop exception if suspicious
   if !(InStr("100 200 201 202 302",RetValue)) {
      Result := RetValue " " RetMsg
      return StrLen(Result)
   }

   VarSetCapacity(BytesRead,4,0)
   fsize := 0
   Loop            ; the receiver loop - rewritten in the need to enable
   {               ; support for larger file downloads
      bc := A_Index
      VarSetCapacity(buffer%bc%,1024,0) ; setup new chunk for this receive round
      ReadFile := DllCall("wininet\InternetReadFile"
                  ,"uInt",hRequest,"uInt",&buffer%bc%,"uInt",1024,"uInt",&BytesRead)
      ReadBytes := NumGet(BytesRead)    ; how many bytes were received?
      If ((ReadFile!=0)&&(!ReadBytes))  ; we have had no error yet and received no more bytes
         break                         ; we must be done! so lets break the receiver loop
      Else {
         fsize += ReadBytes            ; sum up all chunk sizes for correct return size
         sizeArray .= ReadBytes "|"
      }
      if (instr(HTTPQueryOps,"updateSize"))
         Global HttpQueryCurrentSize := fsize
   }
   sizeArray := SubStr(sizeArray,1,-1)   ; trim last PipeChar
   
   VarSetCapacity(result,fSize+1,0)      ; reconstruct the result from above generated chunkblocks
   Dest := &result                       ; to a our ByRef result variable
   Loop,Parse,SizeArray,|
      DllCall("RtlMoveMemory","uInt",Dest,"uInt",&buffer%A_Index%,"uInt",A_LoopField)
      , Dest += A_LoopField
     
   DllCall("WinINet\InternetCloseHandle", "uInt", hRequest)   ; close all opened
   DllCall("WinINet\InternetCloseHandle", "uInt", hInternet)
   DllCall("WinINet\InternetCloseHandle", "uInt", hConnect)
   DllCall("FreeLibrary", "UInt", hModule)                    ; unload the library
   return fSize                          ; return the size - strings need update via VarSetCapacity(res,-1)
}