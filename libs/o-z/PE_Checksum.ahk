; Link:   	
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

PE_CheckSum( PEfile ) {                            ; By SKAN | 10-Sep-2017
Local Chk1:=0, Chk2:=0
If ( DllCall( "ImageHlp.dll\MapFileAndCheckSumA", "AStr",PEfile, "PtrP",Chk1, "PtrP",Chk2 ) = 0 )
  Return ( Chk1 = Chk2 ? "Checksum okay!" : "Checksum incorrect!" )
       . ( "`nCurrent Checksum: " Format( "0x{:08X}", Chk1 ) )
       . ( "`nCorrect Checksum: " Format( "0x{:08X}", Chk2 ) )
}