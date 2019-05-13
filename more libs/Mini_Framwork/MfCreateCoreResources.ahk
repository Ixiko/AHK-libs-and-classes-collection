
ResFolder := A_ScriptDir . "\Framework\src\System\Resource"

try {
	SetWorkingDir %ResFolder%
	strF := ResFolder . "\Resources"
	DllPack_Files(strF, "MfResource_Core_en-US.dll")
} catch e {
	MsgBox, 8240, Error, % "An error has occured!`r`n" . e.Message
}
MsgBox All done!



;Include <Resource_Only_Dll>
/*
              +-+-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+-+ +-+-+-+ +-+-+-+-+-+-+-+-+
              |R|e|s|o|u|r|c|e|-|O|n|l|y| |D|L|L| |f|o|r| |D|u|m|m|i|e|s|!|
              +-+-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+-+ +-+-+-+ +-+-+-+-+-+-+-+-+

 - Humble 36L wrapper to create and use DLL resources in AutoHotkey Scripting Language -

                  By SKAN - Suresh Kumar A N  ( arian.suresh@gmail.com )
            Created: 05-Sep-2009 / Last Modified: 28-Oct-2010 / Version: 0.6u

  For usage, please refer Forum Topic : www.autohotkey.com/forum/viewtopic.php?t=62180

http://www.autohotkey.com/board/topic/57631-crazy-scripting-resource-only-dll-for-dummies-36l-v07/
*/

DllPack_Files( Folder, DLL, Section="Files" ) {
 IfNotExist,%DLL%, SetEnv,DLL,% DLLPack_CreateEmpty( DLL )
 VarSetCapacity(Bin,64,Ix:=0)
 If hUPD := DllCall( "BeginUpdateResource", Str,DLL, Int,0 )
  Loop, %Folder%\*.* 
  {
   VarSetCapacity( Bin,0 )
   FileRead, Bin, *c %A_LoopFileLongPath%
   If nSize := VarSetCapacity(Bin)
   DllCall( "UpdateResource", Ptr,hUpd, Str,DllCall( "CharUpper", Str,Section, Str ), Str
  ,DllCall( "CharUpper", Str,A_LoopFileName, Str ), Int,0, Ptr,&Bin, UInt,nSize ),Ix:=Ix+1
 } 
Return Ix, DllCall( "EndUpdateResource", Ptr,hUpd, Int,0 )
}

DllPack_File( File, DLL, Section="Files" ) {
 IfNotExist,%DLL%, SetEnv,DLL,% DLLPack_CreateEmpty( DLL )
 VarSetCapacity(Bin,64,Ix:=0)
 If hUPD := DllCall( "BeginUpdateResource", Str,DLL, Int,0 )
 if(FileExist(File))
 {
  SplitPath, File, fName
  VarSetCapacity( Bin,0 )
  FileRead, Bin, *c %File%
  If nSize := VarSetCapacity(Bin)
  DllCall( "UpdateResource", Ptr,hUpd, Str,DllCall( "CharUpper", Str,Section, Str ), Str
 ,DllCall( "CharUpper", Str, fName, Str ), Int,0, Ptr,&Bin, UInt,nSize ),Ix:=Ix+1
 }
  Return Ix, DllCall( "EndUpdateResource", Ptr,hUpd, Int,0 )
}


DllPack_CreateEmpty( F="empty.dll" ) { ; www.autohotkey.com/forum/viewtopic.php?p=381161#381161       
;Creates Empty Resource-Only DLL (1536 bytes)  / CD:05-Sep-2010 | LM:25-Oct-2010 - by SKAN
 IfNotEqual,A_Tab, % TS:=A_NowUTC, EnvSub,TS,1970,S  ;
 Src := "0X5A4DY3CXB8YB8X4550YBCX2014CYCCX210E00E0YD0X7010BYD8X400YE4X1000YE8X1000YECX78A"
 . "E0000YF0X1000YF4X200YF8X10005YFCX10005Y100X4Y108X3000Y10CX200Y114X2Y118X40000Y11CX200"
 . "0Y120X100000Y124X1000Y12CX10Y140X1000Y144X10Y158X2000Y15CX8Y1B0X7273722EY1B4X63Y1B8X1"
 . "0Y1BCX1000Y1C0X200Y1C4X200Y1D4X40000040Y1D8X6C65722EY1DCX636FY1E0X8Y1E4X2000Y1E8X200Y"
 . "1ECX400Y1FCX42000040", VarSetCapacity(Trg,1536,0), Numput(TS,Trg,192),AC := 0x40000000
 Loop, Parse, Src, XY
   Mod( A_Index,2 ) ? O := "0x" A_LoopField : NumPut( "0x" A_LoopField, Trg, O )
 If ( hF := DllCall( "CreateFile", Str,F, UInt,AC,UInt,2,Ptr,0,UInt,2,Int,0,Int,0 ) ) > 0
   B := DllCall( "_lwrite", Ptr,hF,Ptr,&Trg,UInt,1536 ),  DllCall( "CloseHandle",Ptr,hF )
Return B ? F :
}

DllPack_Read( ByRef Var, Filename, Section, Key ) {          ; Functionality and Parameters are
 VarSetCapacity( Var,64 ), VarSetCapacity( Var,0 )      ; identical to IniRead command ;-)
 If hMod := DllCall( "LoadLibrary", Str,Filename )
  If hRes := DllCall( "FindResource", Ptr,hMod, Str,Key, Str,Section )
   If hData := DllCall( "LoadResource", Ptr,hMod, Ptr,hRes )
    If pData := DllCall( "LockResource", Ptr,hData )
 Return VarSetCapacity( Var,nSize := DllCall( "SizeofResource", Ptr,hMod, Ptr,hRes ),32)
     , DllCall( "RtlMoveMemory", Ptr,&Var, Ptr,pData, UInt,nSize )
     , DllCall( "FreeLibrary", Ptr,hMod )
Return DllCall( "FreeLibrary", Ptr,hMod ) >> 32
}
