; Link:   	
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

PE_CompilationTime( PEfile ) {                       ; By SKAN | 10-Sep-2017
Local Bin, File := FileOpen(PEfile,"r"), nFILETIME := 0 
  If ! IsObject(File)
    Return
  File.RawRead(Bin,2048), File.Close()  
  If ( NumGet(Bin,0,"UShort")<>0x5A4D || NumGet(Bin,NumGet(Bin,60,"UInt"),"UInt")<>0x00004550 ) ;'MZ' and 'PE'
    Return
  nFILETIME := ( (NumGet(Bin,NumGet(Bin,60,"UInt")+8,"UInt")+11644473600 )*10000000 )  ; UNIXTIME to FILETIME  
  DllCall( "FileTimeToLocalFileTime", "Int64P",nFILETIME, "Int64P",nFILETIME )         ; FILETIME UTC to local
  DllCall( "FileTimeToSystemTime", "Int64P",nFILETIME, "Ptr",&Bin )                    ; Bin is SYSTEMTIME 
Return Format( "{1:04}{2:02}{3:02}{4:02}{5:02}{6:02}",   NumGet(Bin,00,"UShort"), NumGet(Bin,02,"UShort")
     , NumGet(Bin,06,"UShort"), NumGet(Bin,08,"UShort"), NumGet(Bin,10,"UShort"), NumGet(Bin,12,"UShort") )  
}