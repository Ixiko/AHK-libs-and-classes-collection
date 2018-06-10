internetConnected(url:="http://google.com"){    
    if(!dllCall("Wininet.dll\InternetCheckConnection","Str",url,"Uint",1,"Uint",0))
        return 0
    return 1
}
