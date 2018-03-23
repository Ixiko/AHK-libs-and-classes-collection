; String version info for execs by SKAN, wOxxOm
; http://www.autohotkey.com/forum/viewtopic.php?p=233188#233188
; http://www.autohotkey.com/forum/viewtopic.php?p=52148#52148
FileGetVersionInfo( peFile="", StringFileInfo="" ) {
 FSz := DllCall( "Version\GetFileVersionInfoSizeA",Str,peFile,UInt,0 )
 IfLess, FSz,1, Return -1
 VarSetCapacity( FVI, FSz, 0 ), VarSetCapacity( Trans,8 )
 DllCall( "Version\GetFileVersionInfoA", Str,peFile, Int,0, Int,FSz, UInt,&FVI )
 If ! DllCall( "Version\VerQueryValueA", UInt,&FVI, Str,"\VarFileInfo\Translation"
                                       , UIntP,Translation, UInt,0 )
   Return -2
 If ! DllCall( "msvcrt.dll\sprintf", Str,Trans, Str,"%08X", UInt,NumGet(Translation+0) )
   Return -4
 subBlock := "\StringFileInfo\" SubStr(Trans,-3) SubStr(Trans,1,4) "\" StringFileInfo
 If ! DllCall( "Version\VerQueryValueA", UInt,&FVI, Str,SubBlock, UIntP,InfoPtr, UInt,0 )
   Return
 VarSetCapacity( Info, DllCall( "lstrlen", UInt,InfoPtr ) )
 DllCall( "lstrcpy", Str,Info, UInt,InfoPtr )
Return Info
}