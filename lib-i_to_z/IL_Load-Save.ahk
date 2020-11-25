; Link:   	https://www.autohotkey.com/boards/viewtopic.php?p=191244
; Author:	SKAN
; Date:
; for:     	AHK_L

/*


*/

IL_Save(HIL, File) {
   ; Originally released by SKAN -> www.autohotkey.com/forum/viewtopic.php?t=72282
   Size := 0
   If (FileObj := FileOpen(File, "w")) {
      DllCall("Ole32.dll\CreateStreamOnHGlobal", "Ptr", 0, "Int", 1, "PtrP", IStream, "UInt")
      DllCall("ImageList_Write", "Ptr", HIL, "Ptr", IStream, "UInt")
      DllCall("Ole32.dll\GetHGlobalFromStream", "Ptr", IStream, "PtrP", HGlobal, "UInt")
      Data := DllCall("GlobalLock", "Ptr", HGlobal )
      Size := DllCall("GlobalSize", "Ptr", HGlobal )
      Size := FileObj.RawWrite(Data + 0, Size)
      FileObj.Close()
      DllCall("GlobalUnlock", "Ptr", Data)
      ObjRelease(IStream)
      DllCall("GlobalFree", "Ptr", HGlobal)
   }
   Return Size
}
; ================================================================================================================================
IL_Load(File) {
   ; Originally released by SKAN -> www.autohotkey.com/forum/viewtopic.php?t=72282
   HIL := 0
   If (FileObj := FileOpen(File, "r")) {
      Size := FileObj.Length
      HGlobal := DllCall("GlobalAlloc", "UInt", 2, "UInt", Size, "UPtr")
      Data := DllCall("GlobalLock",  "Ptr", HGlobal, "UPtr")
      FileObj.RawRead(Data + 0, Size)
      FileObj.Close()
      DllCall("GlobalUnlock", "Ptr", Data)
      DllCall("Ole32.dll\CreateStreamOnHGlobal", "Ptr", HGlobal, "Int", 1, "PtrP", IStream, "UInt")
      HIL := DllCall("ImageList_Read", "Ptr", IStream, "UPtr")
      ObjRelease(IStream)
      DllCall("GlobalFree", "Ptr", HGlobal)
   }
   Return HIL
}