InternetGetRedirect( URL ) { ; SKAN www.autohotkey.com/forum/viewtopic.php?p=467841#467841
 hMod := DllCall( "LoadLibrary", str,"wininet.dll" ), StrGet := "StrGet"  ; CD 19-Aug-2011
 CS := ( A_IsUnicode ? "W" : "A" ), VarSetCapacity( Data, nSz := 1024, 0 )
 hIO := DllCall( "wininet\InternetOpen" CS, Str,"", UInt,4, Str,"", Str,"", UInt,0 )
 hIU := DllCall( "wininet\InternetOpenUrl" CS, UInt,hIO, Str,URL, Str,"", Int,0
      , UInt,0x84000000|0x00200000, UInt,0 )
 DllCall( "wininet\HttpQueryInfo" CS, UInt,hIU, Int,19, Str,Data, UIntP,nSz, UInt,0 )
 If ( Data=301 || Data=302 ) ; HTTP_STATUS_MOVED | HTTP_STATUS_REDIRECT
    DllCall( "wininet\InternetReadFile", UInt,hIU, Str,Data, UInt,1024, UIntP,R )
 DllCall( "wininet\InternetCloseHandle", UInt,hIO )
 DllCall( "wininet\InternetCloseHandle", UInt,hIU ), DllCall( "FreeLibrary", UInt,hMod )
 RegExMatch( A_IsUnicode ? %StrGet%( &Data,"" ) : Data,  "i)href=""(.*)""",  Data  )
Return Data1
}

GoogleGetRedirect( SearchFor, Site="" ) {  ; Google I'm Feeling Lucky Search
Return InternetGetRedirect( "http://www.google.com/search?sourceid=navclient&btnI&q="
                           . SearchFor . ( Site ? "+site:" Site : "" ) )
}
