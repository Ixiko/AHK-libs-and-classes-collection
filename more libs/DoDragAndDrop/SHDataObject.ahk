; ==================================================================================================================================
; !!! Win Vista+ !!!
; ==================================================================================================================================
; Creates a new IDataObject interface pointer.
; Optional parameter:
;     CBDataObj   -  A pointer to an IDataObject interface retrieved from the clipboard.
;                    The data contained in this data object will be included in the new data object.
; Return values:
;     An interface pointer on success, otherwise False.
; Requires:
;     IDataObject.ahk
;     IEnumFORMATETC.ahk
; MSDN:
;     SHCreateDataObject -> msdn.microsoft.com/en-us/library/bb762126(v=vs.85).aspx
; ==================================================================================================================================
SHDataObject_Create(CBDataObj := 0) {
   Static IID_IDataObject := "{0000010e-0000-0000-C000-000000000046}"
   VarSetCapacity(IID, 16, 0)
   DllCall("Ole32.dll\IIDFromString", "WStr", IID_IDataObject, "Ptr", &IID)
   HR := DllCall("Shell32.dll\SHCreateDataObject", "Ptr", 0, "UInt", 0, "Ptr", 0, "Ptr", CBDataObj, "Ptr", &IID, "PtrP", SHDataObj)
   Return (HR >= 0 ? SHDataObj : False)
}
; ==================================================================================================================================
; Creates a drag image from the specified bitmap used for the drag-and-drop operation.
; ==================================================================================================================================
SHDataObject_DragImageFromBitmap(DataObj, HBITMAP) {
   ; IDragSourceHelper interface  -> msdn.microsoft.com/en-us/library/bb762034(v=vs.85).aspx
   Static CLSID_DragDropHelper   := "{4657278A-411B-11D2-839A-00C04FD918D0}"
   Static IID_IDropSourcetHelper := "{DE5BF786-477A-11D2-839D-00C04FD918D0}"
   Static InitializeFromBitmap := A_PtrSize * 3
   VarSetCapacity(BM, 32, 0)
   If DllCall("GetObject", "Ptr", HBITMAP, "Int", A_PtrSize = 8 ? 32 : 24, "Ptr", &BM, "Int")
      Width := NumGet(BM, 4, "Int"), Height := NumGet(BM, 8, "Int")
   Else
      Return False
   HBITMAP := DllCall("CopyImage", "Ptr", HBITMAP, "UInt", 0, "Int", 0, "Int", 0, "UInt", 0, "UPtr")
   VarSetCapacity(SHDI, 32, 0) ; SHDRAGIMAGE structure, 64-bit size
   NumPut(Width, SHDI, 0, "Int")
   NumPut(Height, SHDI, 4, "Int")
   NumPut(Width // 2, SHDI, 8, "Int")
   NumPut(Height, SHDI, 12, "Int")
   NumPut(HBITMAP, SHDI, 16, "UPtr")
   NumPut(0x00FFFFFF, SHDI, 16 + A_PtrSize, "UInt")
   If (IDSH := ComObjCreate(CLSID_DragDropHelper, IID_IDropSourcetHelper)) {
      VTBL := NumGet(IDSH + 0, "UPtr")
      HR := DllCall(NumGet(VTBL + InitializeFromBitmap, "UPtr"), "Ptr", IDSH, "Ptr", &SHDI, "Ptr", DataObj, "Int")
      ObjRelease(IDSH)
   }
   Return (HR >= 0 ? True : False)
}
; ==================================================================================================================================
; Reserved, don't use it.
; ==================================================================================================================================
SHDataObject_SetDropDescription(pDataObj, Type := -1, Msg := "", Insert := "") {
   ; DROPDESCRIPTION -> msdn.microsoft.com/en-us/library/bb773268(v=vs.85).aspx
   Static DropDescription := DllCall("RegisterClipboardFormat", "Str", "DropDescription")
   IDataObject_CreateFormatEtc(FORMATETC, DropDescription)
   , VarSetCapacity(STGMEDIUM, 24, 0) ; 64-bit
   , NumPut(1, STGMEDIUM, "UInt") ; TYMED_HGLOBAL
   , hMem := DllCall("GlobalAlloc", "UInt", 0x42, "UInt", 1044, "UPtr") ; 0x42 = GMEM_MOVEABLE (0x02) | GMEM_ZEROINIT (0x40)
   , pMem := DllCall("GlobalLock", "Ptr", hMem, "UPtr")
   , NumPut(Type, pMem + 0, "Int")
   , StrPut(Msg, pMem + 4, 260, "UTF-16")
   , StrPut(Insert, pMem + 524, 260, "UTF-16")
   , DllCall("GlobalUnlock", "Ptr", hMem)
   , NumPut(hMem, STGMEDIUM, A_PtrSize, "UPtr")
   Return IDataObject_SetData(pDataObj, FORMATETC, STGMEDIUM)

}
; ==================================================================================================================================
#Include *i IDataObject.ahk
; ==================================================================================================================================