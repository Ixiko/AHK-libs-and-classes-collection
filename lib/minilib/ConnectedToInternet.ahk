; How to find Internet Connection Status? by SKAN
; http://www.autohotkey.com/forum/viewtopic.php?p=60892#60892
ConnectedToInternet(flag=0x40) {
   Return DllCall("Wininet.dll\InternetGetConnectedState", "Str", flag,"Int",0)
}
