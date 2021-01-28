; http://www.autohotkey.com/forum/viewtopic.php?t=62180
/*
              +-+-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+-+ +-+-+-+ +-+-+-+-+-+-+-+-+
              |R|e|s|o|u|r|c|e|-|O|n|l|y| |D|L|L| |f|o|r| |D|u|m|m|i|e|s|!|
              +-+-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+-+ +-+-+-+ +-+-+-+-+-+-+-+-+

 - Humble 36L wrapper to create and use DLL resources in AutoHotkey Scripting Language -

                  By SKAN - Suresh Kumar A N  ( arian.suresh@gmail.com )
            Created: 05-Sep-2010 / Last Modified: 01-Jun-2011 / Version: 0.7u

  For usage, please refer Forum Topic : www.autohotkey.com/forum/viewtopic.php?t=62180


*/

DllPackFiles( Folder, DLL, Section="Files" ) {
 IfNotExist,%DLL%, SetEnv,DLL,% DLLCreateEmpty( DLL )
 VarSetCapacity(Bin,64,Ix:=0)
 If hUPD := DllCall( "BeginUpdateResource", Str,DLL, Int,0 )
  Loop, %Folder%\*.*  {
  VarSetCapacity( Bin,0 )
  FileRead, Bin, *c %A_LoopFileLongPath%
  If nSize := VarSetCapacity(Bin)
  DllCall( "UpdateResource", UInt,hUpd, Str,DllCall( "CharUpper", Str,Section, Str ), Str
 ,DllCall( "CharUpper", Str,A_LoopFileName, Str ), Int,0, UInt,&Bin, UInt,nSize ),Ix:=Ix+1
} Return Ix, DllCall( "EndUpdateResource", UInt,hUpd, Int,0 )
}


DllCreateEmpty( F="empty.dll" ) { ; www.autohotkey.com/forum/viewtopic.php?p=381161#381161
;Creates Empty Resource-Only DLL (1024 bytes)  / CD:05-Sep-2010 | LM:01-Jun-2011 - by SKAN
 IfNotEqual,A_Tab, % TS:=A_NowUTC, EnvSub,TS,1970,S 
 Src := "0X5A4DY3CXC0YC0X4550YC4X1014CYD4X210E00E0YD8XA07010BYE0X200YECX1000YF0X1000YF4X1"
 . "0000YF8X1000YFCX200Y100X4Y108X4Y110X2000Y114X200Y11CX4000003Y120X40000Y124X1000Y128X1"
 . "00000Y12CX1000Y134X10Y148X1000Y14CX10Y1B8X7273722EY1BCX63Y1C0X10Y1C4X1000Y1C8X200Y1CC"
 . "X200Y1DCX40000040", VarSetCapacity( Trg,1024,0 ), Numput( TS,Trg,200 ), DA:=0x40000000
 Loop, Parse, Src, XY                                                           
   Mod( A_Index,2 ) ? O := "0x" A_LoopField : NumPut( "0x" A_LoopField, Trg, O )
 If ( hF := DllCall( "CreateFile", Str,F, UInt,DA, UInt,2,Int,0,UInt,2,Int,0,Int,0 ) ) > 0
   B := DllCall( "_lwrite", UInt,hF,Str,Trg,UInt,1024 ),  DllCall( "CloseHandle",UInt,hF )
 Loop %F%
Return B ? A_LoopFileLongPath :
}


DllRead( ByRef Var, Filename, Section, Key ) {          ; Functionality and Parameters are
 VarSetCapacity( Var,64 ), VarSetCapacity( Var,0 )      ; identical to IniRead command ;-)
 If hMod := DllCall( "LoadLibrary", Str,Filename )
  If hRes := DllCall( "FindResource", UInt,hMod, Str,Key, Str,Section )
   If hData := DllCall( "LoadResource", UInt,hMod, UInt,hRes )
    If pData := DllCall( "LockResource", UInt,hData )
 Return VarSetCapacity( Var,nSize := DllCall( "SizeofResource", UInt,hMod, UInt,hRes ),32)
     , DllCall( "RtlMoveMemory", UInt,&Var, UInt,pData, UInt,nSize )
     , DllCall( "FreeLibrary", UInt,hMod )
Return DllCall( "FreeLibrary", UInt,hMod ) >> 32
}
