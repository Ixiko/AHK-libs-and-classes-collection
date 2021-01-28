#Warn
#SingleInstance, Force

pBASE := DllCall( "LoadLibrary", "Str","shell32.dll", "UPtr" )

; Locate Structure IMAGE_EXPORT_DIRECTORY 
pIMAGE_EXPORT_DIRECTORY := DllCall( "ImageHlp\ImageDirectoryEntryToData", "Ptr",pBASE, "Int",True
                         , "UShort",IMAGE_DIRECTORY_ENTRY_EXPORT := 0, "PtrP",nSize := 0, "UPtr" )

If not ( pIMAGE_EXPORT_DIRECTORY and nSize ) 
{
   MsgBox, No Export Directory found!
   ExitApp
}   
    
/*
Structure IMAGE_EXPORT_DIRECTORY
----------------------------------------------------------------------------------------------------
Off Size Type   Description            Comment
----------------------------------------------------------------------------------------------------
  0    4 UInt   Characteristics
  4    4 UInt   TimeDateStamp
  8    2 UShort MajorVersion
 10    2 UShort MinorVersion
 12    4 UInt   Name
 16    4 UInt   Base
 20    4 UInt   NumberOfFunctions
 24    4 UInt   NumberOfNames
 28    4 UInt   AddressOfFunctions     RVA from base of image 
 32    4 UInt   AddressOfNames         RVA from base of image
 36    4 UInt   AddressOfNameOrdinals  RVA from base of image   
----------------------------------------------------------------------------------------------------
 40 bytes in total.  Note: AddressOfNameOrdinals should be pronounced as "AddressOfName's Ordinals".
----------------------------------------------------------------------------------------------------
*/

pAddressOfFunctions    := pBASE + NumGet( pIMAGE_EXPORT_DIRECTORY + 28, "UInt" )  ; Array of UINTs
pAddressOfNames        := pBASE + NumGet( pIMAGE_EXPORT_DIRECTORY + 32, "UInt" )  ; Array of UINTs
pAddressOfNameOrdinals := pBASE + NumGet( pIMAGE_EXPORT_DIRECTORY + 36, "UInt" )  ; Array of USHORTs

; Note: AddressOfNameOrdinals does not contain any Address (RVA). It is list of zero-based ordinals.

nNumberOfNames := NumGet( pIMAGE_EXPORT_DIRECTORY + 24, "UInt" )

List := ""
Loop % nNumberOfNames
{
   zbIndex   := A_Index - 1 
   RVA1      := NumGet( pAddressOfNames + ( zbIndex * 4 ), "UInt" )
   sFunction := StrGet( pBASE + RVA1, "" ) 
   
   Ordinal   := NumGet( pAddressOfNameOrdinals + ( zbIndex * 2 ), "UShort" )  
   RVA2      := NumGet( pAddressOfFunctions    + ( Ordinal * 4 ), "UInt"   )
   pProc     := pBASE + RVA2   
    
   List .=  sFunction A_Tab pProc "`n" 
}
 
MsgBox % Clipboard := List
