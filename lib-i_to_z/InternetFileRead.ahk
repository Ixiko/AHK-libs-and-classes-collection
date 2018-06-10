/*
       ___       _                       _   _____ _ _      ____                _
      |_ _|_ __ | |_ ___ _ __ _ __   ___| |_|  ___(_) | ___|  _ \ ___  __ _  __| |
       | || '_ \| __/ _ \ '__| '_ \ / _ \ __| |_  | | |/ _ \ |_) / _ \/ _` |/ _` |
       | || | | | ||  __/ |  | | | |  __/ |_|  _| | | |  __/  _ <  __/ (_| | (_| |
      |___|_| |_|\__\___|_|  |_| |_|\___|\__|_|   |_|_|\___|_| \_\___|\__,_|\__,_|

                              by SKAN ( Suresh Kumar A N, arian.suresh@gmail.com )
                                      Created: 24-Jun-2009 | LastEdit: 03-Jul-2009
                       Forum Topic: www.autohotkey.com/forum/viewtopic.php?t=45718
           Included : InternetFileRead(), DLP() Progress Bar, VarZ_Save(),Examples
      ____________________________________________________________________________
      Credit:

      Olfen for his topics:

                          DllCall: HttpQueryInfo - Get HTTP headers
                          - www.autohotkey.com/forum/topic10510.html
                          UrlDownloadToVar()
                          - www.autohotkey.com/forum/topic10466.html
      Lexikos for:
                          For supporting this project with valuable info,
                          especially:

                          code/method to support FTP read
                          - www.autohotkey.com/forum/viewtopic.php?p=277646#277646

                          clarifying alternative parameter for proxy issues
                          - www.autohotkey.com/forum/viewtopic.php?p=279205#279205
                          - www.autohotkey.com/forum/viewtopic.php?p=279210#279210

      Thanks to all the replies in Forum Topic which motivates me to perfect this.
*/

#SingleInstance Force

; Example 1: Download the leading 100 bytes of default HTML and extract a part of text.
; URL := "http://www.formyip.com/"
; If ( InternetFileRead( IP, URL, 100, 100, "No-Progress" ) > 0 )
  ; MsgBox, 64, Your External IP Address
        ; , % IP := SubStr( IP,SP:=InStr(IP,"My ip address ")+17,InStr(IP," ",0,SP+1)-SP )


; Example 2, Download a binary file ( AHK Script Decompiler ) and save it.
URL := "http://www.autohotkey.com/download/Exe2Ahk.exe"
If ( InternetFileRead( binData, URL, False, 10240) > 0 && !ErrorLevel )
  If VarZ_Save( binData, A_ScriptDir "\Exe2Ahk.exe" )
     MsgBox, 64, AHK Script Compiler Downloaded and Saved, % A_ScriptDir "\Exe2Ahk.exe"


; Example 3, Download a FTP file: EditPlus 3.11 Evaluation Version (1 MB) and save it.
; URL := "ftp://ftp.editplus.com/epp311_en.exe"
; If ( InternetFileRead( binData, URL ) > 0 && !ErrorLevel )
    ; If VarZ_Save( binData, A_Temp "\epp311_en.exe" ) {
         ; Sleep 500
         ; DLP( False ) ; or use Progress, off
         ; Run %A_Temp%\epp311_en.exe
       ; }

; AHK will automatically unload libraries on exit. If you are particular, here is a method
; to unload Wininet library without a handle.
DllCall( "FreeLibrary", UInt,DllCall( "GetModuleHandle", Str,"wininet.dll") )
Return ;                                                 // end of auto-execute section //


InternetFileRead( ByRef V, URL="", RB=0, bSz=1024, DLP="DLP", F=0x84000000 ) {
 Static LIB="WININET\", QRL=16, CL="00000000000000", N=""
 If ! DllCall( "GetModuleHandle", Str,"wininet.dll" )
      DllCall( "LoadLibrary", Str,"wininet.dll" )
 If ! hIO:=DllCall( LIB "InternetOpen", Str,N, UInt,4, Str,N, Str,N, UInt,0 )
   Return -1
 If ! (( hIU:=DllCall( LIB "InternetOpenUrl", UInt,hIO, Str,URL, Str,N, Int,0, UInt,F
                                                            , UInt,0 ) ) || ErrorLevel )
   Return 0 - ( !DllCall( LIB "InternetCloseHandle", UInt,hIO ) ) - 2
 If ! ( RB  )
 If ( SubStr(URL,1,4) = "ftp:" )
    CL := DllCall( LIB "FtpGetFileSize", UInt,hIU, UIntP,0 )
 Else If ! DllCall( LIB "HttpQueryInfo", UInt,hIU, Int,5, Str,CL, UIntP,QRL, UInt,0 )
   Return 0 - ( !DllCall( LIB "InternetCloseHandle", UInt,hIU ) )
            - ( !DllCall( LIB "InternetCloseHandle", UInt,hIO ) ) - 4
 VarSetCapacity( V,64 ), VarSetCapacity( V,0 )
 SplitPath, URL, FN,,,, DN
 FN:=(FN ? FN : DN), CL:=(RB ? RB : CL), VarSetCapacity( V,CL,32 ), P:=&V,
 B:=(bSz>CL ? CL : bSz), TtlB:=0, LP := RB ? "Unknown" : CL,  %DLP%( True,CL,FN )
 Loop {
       If ( DllCall( LIB "InternetReadFile", UInt,hIU, UInt,P, UInt,B, UIntP,R ) && !R )
       Break
       P:=(P+R), TtlB:=(TtlB+R), RemB:=(CL-TtlB), B:=(RemB<B ? RemB : B), %DLP%( TtlB,LP )
       Sleep -1
 } TtlB<>CL ? VarSetCapacity( T,TtlB ) DllCall( "RtlMoveMemory", Str,T, Str,V, UInt,TtlB )
  . VarSetCapacity( V,0 ) . VarSetCapacity( V,TtlB,32 ) . DllCall( "RtlMoveMemory", Str,V
  , Str,T, UInt,TtlB ) . %DLP%( TtlB, TtlB ) : N
 If ( !DllCall( LIB "InternetCloseHandle", UInt,hIU ) )
  + ( !DllCall( LIB "InternetCloseHandle", UInt,hIO ) )
   Return -6
Return, VarSetCapacity(V)+((ErrorLevel:=(RB>0 && TtlB<RB)||(RB=0 && TtlB=CL) ? 0 : 1)<<64)
}
;  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; The following function is an add-on to provide "Download Progress" to InternetFileRead()
; InternetFileRead() calls DLP() dynamically, i.e., will not error-out if DLP() is missing
;  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

DLP( WP=0, LP=0, Msg="" ) {
 If ( WP=1 ) {
 SysGet, m, MonitorWorkArea, 1
 ;y:=(mBottom-46-2), x:=(mRight-370-2), VarSetCapacity( Size,16,0 )
 x:=(A_ScreenWidth/2), y:=(A_ScreenHeight/2 -150), VarSetCapacity( Size,16,0 )
 DllCall( "shlwapi.dll\StrFormatByteSize64", Int64,LP, Str,Size, UInt,16 )
 Size := ( Size="0 bytes" ) ? N :  Size 
 Progress, CWE6E3E4 CT000020 CBF73D00 x%x% y%y% w370 h46 B1 FS8 WM700 WS400 FM8 ZH8 ZY3
         ,, %Msg%  %Size%, InternetFileRead(), Tahoma
 WinSet, Transparent, 210, InternetFileRead()
 } Progress,% (P:=Round(WP/LP*100)),% "File Download: " wp " / " lp " [ " P "`% ]"
 IfEqual,wP,0, Progress, Off
}
;  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; The following function is a part of: VarZ 46L - Native Data Compression
; View topic : www.autohotkey.com/forum/viewtopic.php?t=45559
;  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

VarZ_Save( byRef V, File="" ) { ;   www.autohotkey.net/~Skan/wrapper/FileIO16/FileIO16.ahk
Return ( ( hFile :=  DllCall( "_lcreat", AStr,File, UInt,0 ) ) > 0 )
                 ?   DllCall( "_lwrite", UInt,hFile, Str,V, UInt,VarSetCapacity(V) )
                 + ( DllCall( "_lclose", UInt,hFile ) << 64 ) : 0
}