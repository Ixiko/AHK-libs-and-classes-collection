;?add Modified by Tuncay. Just renamed functions, so it have the "DLL_" prefix.
/*
       |~) _  _ _     _ _ _ __/~\ _ |    |~\| |    |` _  _  |~\    _ _  _ _ . _  _|
       |~\(/__\(_)|_|| (_(/_  \_/| ||\/  |_/|_|_  ~|~(_)|   |_/|_|| | || | ||(/__\.
                                     /
 - Humble 36L wrapper to create and use DLL resources in AutoHotkey Scripting Language -


                  By SKAN - Suresh Kumar A N  ( arian.suresh@gmail.com )
                    Created/Last Modified : 05-Sep-2009 | Version: 0.6


  For usage, please refer Forum Topic : www.autohotkey.com/forum/viewtopic.php?t=62180

*/



Dll_PackFiles( Folder, DLL, Section="Files" ) {
 IfNotExist,%DLL%, SetEnv,DLL,% DLL_CreateEmpty( DLL )
 StringUpper, Folder, Folder
 IfEqual,Section,, StringTrimLeft,Section,Folder,3
 If hUPD := DllCall( "BeginUpdateResource", Str,DLL, Int,0 ), VarSetCapacity(Bin,64,Ix:=0)
  Loop, %Folder%\*.*  {
  VarSetCapacity( Bin,0 )
  FileRead, Bin, %A_LoopFileLongPath%
  If nSize := VarSetCapacity(Bin)
  DllCall( "UpdateResource", UInt,hUpd, Str,DllCall( "CharUpper", Str,Section, Str ), Str
 ,DllCall( "CharUpper", Str,A_LoopFileName, Str ), Int,0, UInt,&Bin, UInt,nSize ),Ix:=Ix+1
} Return Ix, DllCall( "EndUpdateResource", UInt,hUpd, Int,0 )
}



Dll_CreateEmpty( F="empty.dll" ) {  ; Creates an Empty Resource-Only DLL (size: 1024 bytes)
; By SKAN : 05-Sep-2010  | Posted @ www.autohotkey.com/forum/viewtopic.php?p=322224#322224
 IfNotEqual,A_Tab, % TS:=A_NowUTC, EnvSub,TS,1970,S
 Src := "0X5A4DY3CXB8YB8X4550YBCX2014CYCCX210E00E0YD0X7010BYD8X400YE4X1000YE8X1000YECX78A"
 . "E0000YF0X1000YF4X200YF8X10005YFCX10005Y100X4Y108X3000Y10CX200Y114X2Y118X40000Y11CX200"
 . "0Y120X100000Y124X1000Y12CX10Y140X1000Y144X10Y158X2000Y15CX8Y1B0X7273722EY1B4X63Y1B8X1"
 . "0Y1BCX1000Y1C0X200Y1C4X200Y1D4X40000040Y1D8X6C65722EY1DCX636FY1E0X8Y1E4X2000Y1E8X200Y"
 . "1ECX400Y1FCX42000040",              VarSetCapacity( Trg,1024,0 ), Numput( TS,Trg,192 )
 Loop, Parse, Src, XY
   Mod( A_Index,2 ) ? O := "0x" A_LoopField : NumPut( "0x" A_LoopField, Trg, O )
 H := DllCall( "_lcreat",Str,F,Int,0 ),  B := DllCall( "_lwrite",UInt,H,Str,Trg,Int,1024 )
Return ( !DllCall( "_lclose",UInt,H ) && B ) ? F :
}



Dll_Read( ByRef Var, Filename, Section, Key ) {          ; Functionality and Parameters are
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