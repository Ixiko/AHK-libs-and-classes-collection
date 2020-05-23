/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
__      __      ______
\ \    / /     |___  /           V A R Z  >>>  N A T I V E  D A T A  C O M P R E S S I O N
 \ \  / /_ _ _ __ / /            http://www.autohotkey.com/community/viewtopic.php?t=45559
  \ \/ / _` | '__/ /             Author: Suresh Kumar A N  (email: arian.suresh@gmail.com)
   \  / (_| | | / /__            Ver 2.0 | Created 19-Jun-2009 | Last Modified 27-Sep-2012
    \/ \__,_|_|/_____|           > http://tinyurl.com/skanbox/AutoHotkey/VarZ/2.0/VarZ.ahk
                                                  |
 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
*/

VarZ_Compress( ByRef Data, DataSize, CompressionMode = [color=#FF0000]0x2,RECURSIVE = 0[/color] ) { ; 0x100 = COMPRESSION_ENGINE_MAXIMUM / 0x2 = COMPRESSION_FORMAT_LZNT1

 Static STATUS_SUCCESS := 0x0,   HdrSz := 18

 If ( NumGet( Data ) = 0x005F5A4C )                           ; "LZ_" + Chr(0)
    Return 0, ErrorLevel := -1                                ; already compressed

 DllCall( "ntdll\RtlGetCompressionWorkSpaceSize"
        , UInt,  CompressionMode
        , UIntP, CompressBufferWorkSpaceSize
        , UIntP, CompressFragmentWorkSpaceSize )

 VarSetCapacity( CompressBufferWorkSpace, CompressBufferWorkSpaceSize )

 TempSize := VarSetCapacity( TempData, DataSize )             ; Workspace for Compress

 NTSTATUS := DllCall( "ntdll\RtlCompressBuffer"
                    , UInt,  CompressionMode
                    , UInt,  &Data                            ; Uncompressed data
                    , UInt,  DataSize
                    , UInt,  &TempData                        ; Compressed data
                    , UInt,  TempSize
                    , UInt,  CompressFragmentWorkSpaceSize
                    , UIntP, FinalCompressedSize              ; Compressed data size
                    , UInt,  &CompressBufferWorkSpace
                          ,  UInt )

 If ( NTSTATUS <> STATUS_SUCCESS  ||  FinalCompressedSize + HdrSz > DataSize )
    Return 0, ErrorLevel := ( NTSTATUS ? NTSTATUS : -2 )      ; unable to compress data

 VarSetCapacity( Data, FinalCompressedSize + HdrSz, 0 )       ; Renew variable capacity

 NumPut( 0x005F5A4C, Data )                                   ; "LZ_" + Chr(0)
 Numput( CompressionMode, Data, 8 )                           ; actually "UShort"
 NumPut( DataSize, Data, 10 )                                 ; Uncompressed data size
 NumPut( FinalCompressedSize, Data, 14 )                      ; Compressed data size

 DllCall( "RtlMoveMemory", UInt,  &Data + HdrSz               ; Target pointer
                         , UInt,  &TempData                   ; Source pointer
                         , UInt,  FinalCompressedSize )       ; Data length in bytes

 DllCall( "shlwapi\HashData", UInt,  &Data + 8                ; Read data pointer
                            , UInt,  FinalCompressedSize + 10 ; Read data size
                            , UInt,  &Data + 4                ; Write data pointer
                            , UInt,  4 )                      ; Write data length in bytes
[color=#FF0000] If !RECURSIVE && NumPut( 0x315F5A4C, Data, "UInt" ) ; Try extra compression
    If MultiCompressedSize:= VarZ_Compress(Data,FinalCompressedSize + HdrSz,CompressionMode,1)
     return MultiCompressedSize
    else NumPut( 0x005F5A4C, Data, "UInt" )[/color]
  Return FinalCompressedSize + HdrSz
}

VarZ_Uncompress( ByRef D ) {  ; Shortcode version of VarZ_Decompress() of VarZ 2.0 wrapper
; VarZ 2.0 by SKAN, 27-Sep-2012. http://www.autohotkey.com/community/viewtopic.php?t=45559
 IfNotEqual, A_Tab, % ID:=NumGet(D), IfNotEqual, ID, 0x5F5A4C,  Return 0, ErrorLevel := -1
 savedHash := NumGet(D,4), TZ := NumGet(D,10), DZ := NumGet(D,14)
 DllCall( "shlwapi\HashData", UInt,&D+8, UInt,DZ+10, UIntP,Hash, UInt,4 )
 IfNotEqual, Hash, %savedHash%, Return 0, ErrorLevel := -2
 VarSetCapacity( TD,TZ,0 ), NTSTATUS := DllCall( "ntdll\RtlDecompressBuffer", UInt
 , NumGet(D,8,"UShort"), UInt, &TD, UInt,TZ, UInt,&D+18, UInt,DZ, UIntP,Final, UInt )
 IfNotEqual, NTSTATUS, 0, Return 0, ErrorLevel := NTSTATUS
 VarSetCapacity( D,Final,0 ), DllCall( "RtlMoveMemory", UInt,&D, UInt,&TD, UInt,Final )
 [color=#FF0000]If NumGet(D)=0x315F5A4C && NumPut(0x005F5A4C,D)
  Return VarZ_Uncompress( D )[/color]
Return Final, VarSetCapacity( D,-1 )
}

VarZ_Decompress( ByRef Data ) {

 Static STATUS_SUCCESS := 0x0,   HdrSz := 18

 If ( NumGet( Data ) <> 0x005F5A4C )                          ; "LZ_" + Chr(0)
    Return 0, ErrorLevel := -1                                ; not natively compressed

 DataSize := NumGet( Data, 14 )                               ; Compressed data size

 DllCall( "shlwapi\HashData", UInt,  &Data + 8                ; Read data pointer
                            , UInt,  DataSize + 10            ; Read data size
                            , UIntP, Hash                     ; Write data pointer
                            , UInt,  4 )                      ; Write data length in bytes

 If ( Hash <> NumGet( Data, 4 ) )                             ; Hash vs Saved hash
    Return 0, ErrorLevel := -2                                ; Hash failed = Data corrupt

 TempSize := NumGet( Data, 10 )                               ; Decompressed data size
 VarSetCapacity( TempData, TempSize, 0 )                      ; Workspace for Decompress

 NTSTATUS := DllCall( "ntdll\RtlDecompressBuffer"
                    , UInt,  NumGet( Data, 8, "UShort" )      ; Compression mode
                    , UInt,  &TempData                        ; Decompressed data
                    , UInt,  TempSize
                    , UInt,  &Data + HdrSz                    ; Compressed data
                    , UInt,  DataSize
                    , UIntP, FinalUncompressedSize            ; Decompressed data size
                           , UInt )

 If ( NTSTATUS <> STATUS_SUCCESS )
    Return 0, ErrorLevel := NTSTATUS                          ; Unable to decompress data

 VarSetCapacity( Data, FinalUncompressedSize, 0 )             ; Renew variable capacity

 DllCall( "RtlMoveMemory", UInt,  &Data                       ; Target pointer
                         , UInt,  &TempData                   ; Source pointer
                         , UInt,  FinalUncompressedSize )     ; Data length in bytes
 [color=#FF0000]If NumGet(Data)=0x315F5A4C && NumPut(0x005F5A4C,Data)
  Return VarZ_Uncompress( Data )[/color]
Return FinalUncompressedSize, VarSetCapacity( Data, -1 )
}

VarZ_Load( ByRef Data, SrcFile ) {
 FileGetSize, DataSize, %SrcFile%
 IfNotEqual, ErrorLevel, 0, Return
 FileRead, Data, *c %SrcFile%
Return DataSize
}
VarZ_Save( ByRef Data, DataSize, TrgFile ) {
 hFile :=  DllCall( "_lcreat", ( A_IsUnicode ? "AStr" : "Str" ),TrgFile, UInt,0 )
 IfLess, hFile, 1, Return "", ErrorLevel := 1
 nBytes := DllCall( "_lwrite", UInt,hFile, UInt,&Data, UInt,DataSize, UInt )
 DllCall( "_lclose", UInt,hFile )
Return nBytes
}
