;msgbox % DllListExports("D:\Program Files\运行\win 7\MD5Lib.dll")

/*
 _      _    _                 __ __      _      _                       _         _
| |__  | |_ | |_  _ __   _    / // /__ _ | |__  | | __ ___   ___  _ __  (_) _ __  | |_     ___   _ __  __ _
| '_ \ | __|| __|| '_ \ (_)  / // // _' || '_ \ | |/ // __| / __|| '__| | || '_ \ | __|   / _ \ | '__|/ _' |
| | | || |_ | |_ | |_) | _  / // /| (_| || | | ||   < \__ \| (__ | |    | || |_) || |_  _| (_) || |  | (_| |
|_| |_| \__| \__|| .__/ (_)/_/ _/  \__,_||_| |_||_|\_\|___/ \___||_|    |_|| .__/  \__|(_)\___/ |_|   \__, |
                 |_|                                                       |_|                        |___/
DllListExports() - List of Function exports of a DLL  |  http://ahkscript.org/boards/viewtopic.php?t=4563
Author: Suresh Kumar A N ( arian.suresh@gmail.com )
_________________________________________________________________________________________________________
*/

DllListExports( DLL, Hdr := 0 ) {   ;   By SKAN,  http://goo.gl/DsMqa6 ,  CD:26/Aug/2010 | MD:14/Sep/2014

Local LOADED_IMAGE, nSize := VarSetCapacity( LOADED_IMAGE, 84, 0 ), pMappedAddress, pFileHeader
    , pIMGDIR_EN_EXP, IMAGE_DIRECTORY_ENTRY_EXPORT := 0, RVA, VA, LIST := ""
    , hModule := DllCall( "LoadLibrary", "Str","ImageHlp.dll", "Ptr" )

  If ! DllCall( "ImageHlp\MapAndLoad", "AStr",DLL, "Int",0, "Ptr",&LOADED_IMAGE, "Int",True, "Int",True )
    Return

  pMappedAddress := NumGet( LOADED_IMAGE, ( A_PtrSize = 4 ) ?  8 : 16 )
  pFileHeader    := NumGet( LOADED_IMAGE, ( A_PtrSize = 4 ) ? 12 : 24 )

  pIMGDIR_EN_EXP := DllCall( "ImageHlp\ImageDirectoryEntryToData", "Ptr",pMappedAddress
                           , "Int",False, "UShort",IMAGE_DIRECTORY_ENTRY_EXPORT, "PtrP",nSize, "Ptr" )

  VA  := DllCall( "ImageHlp\ImageRvaToVa", "Ptr",pFileHeader, "Ptr",pMappedAddress, "UInt"
, RVA := NumGet( pIMGDIR_EN_EXP + 12 ), "Ptr",0, "Ptr" )

  If ( VA ) {
     VarSetCapacity( LIST, nSize, 0 )
     Loop % NumGet( pIMGDIR_EN_EXP + 24, "UInt" ) + 1
        LIST .= StrGet( Va + StrLen( LIST ), "" ) "`n"
             ,  ( Hdr = 0 and A_Index = 1 and ( Va := Va + StrLen( LIST ) ) ? LIST := "" : "" )
  }

  DllCall( "ImageHlp\UnMapAndLoad", "Ptr",&LOADED_IMAGE ),   DllCall( "FreeLibrary", "Ptr",hModule )

Return RTrim( List, "`n" )
}
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

