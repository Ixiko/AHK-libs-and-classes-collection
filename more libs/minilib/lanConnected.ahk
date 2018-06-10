lanConnected(){
    if(!dllCall("Wininet.dll\InternetGetConnectedState","Str","","Int",0))
        return 0
    return 1
}