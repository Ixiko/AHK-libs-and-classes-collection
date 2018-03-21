;UrlDownloadToVar replacement by Uberi
#NoEnv

;MsgBox % Download(Result,"http://google.ca") . "`n" . SubStr(Result,1,100)

Download(ByRef Result,URL)
{
 UserAgent := "" ;User agent for the request
 Headers := "" ;Headers to append to the request

 hModule := DllCall("LoadLibrary","Str","wininet.dll"), hInternet := DllCall("wininet\InternetOpenA","UInt",&UserAgent,"UInt",0,"UInt",0,"UInt",0,"UInt",0), hURL := DllCall("wininet\InternetOpenUrlA","UInt",hInternet,"UInt",&URL,"UInt",&Headers,"UInt",-1,"UInt",0x80000000,"UInt",0)
 If Not hURL
 {
  DllCall("FreeLibrary","UInt",hModule)
  Return, 0
 }
 VarSetCapacity(Buffer,512,0), TotalRead := 0
 Loop
 {
  DllCall("wininet\InternetReadFile","UInt",hURL,"UInt",&Buffer,"UInt",512,"UInt*",ReadAmount)
  If Not ReadAmount
   Break
  Temp1 := DllCall("LocalAlloc","UInt",0,"UInt",ReadAmount), DllCall("RtlMoveMemory","UInt",Temp1,"UInt",&Buffer,"UInt",ReadAmount), BufferList .= Temp1 . "|" . ReadAmount . "`n", TotalRead += ReadAmount
 }
 BufferList := SubStr(BufferList,1,-1), TotalRead -= 2, VarSetCapacity(Result,TotalRead,122), pResult := &Result
 Loop, Parse, BufferList, `n
 {
  StringSplit, Temp, A_LoopField, |
  DllCall("RtlMoveMemory","UInt",pResult,"UInt",Temp1,"UInt",Temp2), DllCall("LocalFree","UInt",Temp1), pResult += Temp2
 }
 DllCall("wininet\InternetCloseHandle","UInt",hURL), DllCall("wininet\InternetCloseHandle","UInt",hInternet), DllCall("FreeLibrary","UInt",hModule)
 Return, TotalRead
}
