; Title:   	MapFile() : Maps a file and returns a memory pointer.
; Link:   	    https://www.autohotkey.com/boards/viewtopic.php?p=398997#p398997
; Author:	SKAN
; Date:   	May-10-2021
; for:     	AHK_L

/* MapFile(File object, Out Bytes)

The function is best used with x64 version of AutoHotkey. My system has 8 GiB RAM and there is competition for sub 4 GIB memory space.
Owing to this, I can hardly map a 700 MiB file in x86 version of AutoHotkey, though theoretically I should be able to map upto 2 GIB.
x64 is solid.. but anyways, there is not much use mapping a file greater than 4 GIB. Only a few functions would accept size_t bytes.

*/

/* Example 1
#NoEnv
#Warn
#SingleInstance, Force

File := FileOpen(A_AhkPath, "r")               ; Open file
pHaystack := MapFile(File, HaystackBytes:=0)   ; Create file mapping

nCrc := DllCall("ntdll.dll\RtlComputeCrc32", "Int",0, "Ptr",pHaystack, "Int",HaystackBytes, "UInt")

pHaystack := MapFile(File)                     ; Clear file mapping
File.Close()                                   ; Close file

MsgBox % Format("0x{:X}", nCrc)

*/

/* Example  2
#NoEnv
#Warn
#SingleInstance, Force

File := FileOpen(A_AhkPath . "\..\license.txt", "r")    ; Open file
pHaystack := MapFile(File, HaystackBytes:=0)            ; Create file mapping

; find the word "Cambridge", second occurence from bottom.
FoundPtr := InBin(pHaystack, HaystackBytes, "Cambridge", File.Encoding,, 0, 2)

; find the CRLF preceding the word.
FoundPtr := InBin(pHaystack, FoundPtr-pHaystack, 0x0A0D, -2,, 0) ; CRLF := 0x0A0D

File.Pos := FoundPtr-pHaystack +2 ; +2 to move past CRLF

MsgBox % File.ReadLine()

pHaystack := MapFile(File)                              ; Clear file mapping
File.Close()                                            ; Close file

*/

/* Example  3
#NoEnv
#Warn
#SingleInstance, Force
Gui, Show, w320 h180
Sleep 500
WinGetClass, Class, A
Gui, Show,, %Class%
Return

GuiClose:
  ExitApp

*/

/* Example  4
#NoEnv
#Warn
#SingleInstance, Force

File := FileOpen("test.exe", "rw")             ; Open file
pHaystack := MapFile(File, HaystackBytes:=0)   ; Create file mapping

If ! FoundPtr := InBin(pHaystack, HaystackBytes, "AutoHotkeyGUI", Encoding := "utf-16")
     FoundPtr := InBin(pHaystack, HaystackBytes, "AutoHotkeyGUI", Encoding := "cp0")

If ( FoundPtr )
{
    VarSetCapacity(Var, 28, 0)
    StrPut("SKAN-UI", &Var, Encoding)

    File.Pos := FoundPtr-pHaystack
    File.RawWrite(&Var, Encoding="utf-16" ? 26 : 13)
}

pHaystack := MapFile(File)                     ; Clear file mapping
File.Close()                                   ; Close file

*/

MapFile(File, ByRef Bytes:=0) {     ; MapFile V0.33 by SKAN on D459/D45A @ tiny.cc/mapfile
Local
Static db := {}
  If ! ( h := File.__handle )
       Return (0, "Invalid File object.")

  If ( IsByRef(Bytes) )
  If ( DB.HasKey(h) )
       Return (db[h].FileView, ErrorLevel := "")

  If ( !IsByRef(Bytes) )
  {
       If ( DB.HasKey(h) )
          , DllCall("UnmapViewOfFile", "Ptr",db[h].FileView)
          , DllCall("CloseHandle", "Ptr",db[h].MapFile)
          , db.Delete(h)
       Return (0, ErrorLevel := "")
  }

  VarSetCapacity(ioStatus, 12, 0)
  DllCall("ntdll.dll\NtQueryInformationFile", "Ptr",File.__handle, "Ptr",&ioStatus
        , "UIntP",ACCESS_MASK:=0, "Int",4, "Int",FileAccessInformation:=8)

  READ_ACCESS := ACCESS_MASK & 1,   WRITE_ACCESS := (ACCESS_MASK >> 1) & 1
  If ! ( READ_ACCESS )
         Return (0, ErrorLevel := "File object doesn't have read access.")

  If ! ( Bytes := File.Length )
         Return (0, ErrorLevel := "MapFile cannot map a zero byte file.")

  PAGE_READWRITE := 0x4,   PAGE_READONLY := 0x2
  hMapFile := DllCall("CreateFileMapping", "Ptr",h, "Ptr",0
                    , "Int",WRITE_ACCESS ? PAGE_READWRITE : PAGE_READONLY
                    , "Int",0, "Int",0, "Ptr",0, "Ptr")
  If ! ( hMapFile )
         Return (Bytes:=0, ErrorLevel := "MapFile failed.`nLastError: " . A_LastError)

  FILE_MAP_ALL_ACCESS := 0x000F001F,   FILE_MAP_READ := 0x00000004
  pFileView := DllCall("MapViewOfFile", "Ptr",hMapFile
                     , "Int",WRITE_ACCESS ? FILE_MAP_ALL_ACCESS : FILE_MAP_READ
                     , "Int",0, "Int",0, "Ptr",0, "Ptr")
  If ! ( pFileView )
  {
         Err := A_LastError
         DllCall("CloseHandle", "Ptr",hMapFile)
         Return (Bytes:=0, ErrorLevel := "MapFile failed.`nLastError: " . Err)
  }

Return ( (db[h]:={"MapFile":hMapFile, "FileView":pFileView}).FileView,  ErrorLevel := "" )
}