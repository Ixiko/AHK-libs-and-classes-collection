; Link:   	
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

; AxC³ : FileStitch() and FileReadFile() | By SKAN, Suresh Kumar A N (arian.suresh@gmail.com) 
; Simple pair of functions to stitch multiple files as a single file, and read single file from a merged file.        
; Topic: https://autohotkey.com/boards/viewtopic.php?t=36270
; ------------------------------------------------------------------------------------------------------------

FileStitch( Files, OutputFile := "AxC3.bin" ) {                          ; by SKAN, 24-Aug-2017,  goo.gl/QeJDLv
  Local OutFile, InFile, Tailer, Bin, nBytes, tBytes := 0, Count := 0   
  StrReplace( Files, "`n", "`n", Count )
  VarSetCapacity(Tailer, 8*(Count+1), 0)  
  Count := 0
  OutFile := FileOpen(OutputFile, "rw")
  Loop, Parse, Files, `n, `r`t%A_Space%
    InFile := FileOpen(A_LoopField, "r")
  , InFile.RawRead(Bin, nBytes:=InFile.Length)
  , InFile.Close()
  , OutFile.RawWrite(Bin, nBytes)
  , NumPut(tBytes, Tailer, (Count*8)+0, "UInt")
  , NumPut(nBytes, Tailer, (Count*8)+4, "UInt")
  , Count := Count+1
  , tBytes := tBytes+nBytes
  OutFile.RawWrite(Tailer, Count*8)   
  OutFile.WriteUINT(Count)
  OutFile.WriteUINT(0xB3437841)  ; Marker: AxC³
  OutFile.Close()
Return tBytes
}
; ------------------------------------------------------------------------------------------------------------

FileReadFile( ByRef OutputVar := "", Filename := "", FileNum := "" )  { ; by SKAN, 24-Aug-2017,  goo.gl/QeJDLv
 Local Record := VarSetCapacity(Record,8), Count, nBytes, File := FileOpen( Filename, "r" )
 VarSetCapacity(OutputVar,128), VarSetCapacity(OutputVar,0)
 If ! IsObject( File )
      Return 
 File.Seek(-8,2),                           File.RawRead(Record,8)
 If (NumGet(Record,4,"UInt") <> 0xB3437841)  ; Marker: AxC³
    Return File.Close() + ""
 If ( (Count:=NumGet(Record,"UInt")) and FileNum="" )
    Return Count
 FileNum := (FileNum<1||FileNum>Count ? Count : FileNum) 
 File.Seek(0-(Count*8+16)+(FileNum*8),2),   File.RawRead(Record,8)    
 VarSetCapacity(OutputVar, nBytes:=NumGet(Record,4,"UInt"), 1)
 File.Seek(NumGet(Record,0,"UInt"),0),       File.RawRead(OutputVar,nBytes),  File.Close()
Return nBytes
}
; ------------------------------------------------------------------------------------------------------------
