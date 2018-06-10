; ==================================================================================================================================
; DoDragDrop -> msdn.microsoft.com/en-us/library/ms678486(v=vs.85).aspx
; Requires: IDataObject.ahk, IDropSource.ahk and IDragSourceHelper.ahk
; ==================================================================================================================================
; Carries out an OLE drag and drop operation using the current contents of the clipboard.
; Param1    -  A bitmap handle (HBITMAP) used by IDragSourceHelper_CreateFromBitmap() or
;           -  A window handle (HWND) used by IDragSourceHelper_CreateFromWindow() or
;           -  An array of user-defined cursors to use instead of the default cursors during the drag operation.
;              Index:   Used in case:
;              0        Drop target cannot accept the data.
;              1        Drop results in a copy.
;              2        Drop results in a move.
;              3        Drop results in a copy or move.
; OffCX     -  Cursor offset within the drag image (ignored if Param1 is an array of cursors).
; OffCY     -  Cursor offset within the drag image (ignored if Param1 is an array of cursors).
; ColorKey  -  The color used to fill the background of the drag image (ignored if Param1 isn't a HBITMAP handle).
; Return values:
;     If the data have been dropped successfully, the functions returns the performed drop operation (i.e. 1 for
;     DROPEFFECT_COPY or 2 for DROPEFFECT_MOVE). In all other cases the function returns 0.
;     If DROPEFFECT_MOVE is returned, the drag source should remove the data.
; ==================================================================================================================================
DoDragDrop(Param1 := "", OffCX := 0, OffCY := 0, ColorKey := 0x00FFFFFF) {
   ; DRAGDROP_S_DROP = 0x40100
   Static DropEffects := 0x03 ; DROPEFFECT_COPY | DROPEFFECT_MOVE
   IDS := IDropSource_Create()
   If !DllCall("Ole32.dll\OleGetClipboard", "PtrP", pDataObj, "UInt") {
      IDSH := Bitmap := False
      If IsObject(Param1)
         IDropSource_Cursors := Param1
      Else If (Param1 <> "") {
         If DllCall("IsWindow", "Ptr", Param1, "UInt")
            IDSH := IDragSourceHelper_CreateFromWindow(pDataObj, Param1)
         Else If DoDragDrop_GetBitmapSize(Param1, W, H)
            IDSH := IDragSourceHelper_CreateFromBitmap(pDataObj, Param1, W, H, W // 2, H)
      }
      RC := DllCall("Ole32.dll\DoDragDrop","Ptr", pDataObj, "Ptr", IDS, "UInt", DropEffects, "PtrP", Effect, "Int")
      If IDataObject_GetPerformedDropEffect(pDataObj, PerformedDropEffect)
         Effect := PerformedDropEffect
      ObjRelease(pDataObj)
      If (IDSH)
         ObjRelease(IDSH)
   }
   IDropSource_Free(IDS)
   IDropSource_Cursors := ""
   Return (RC = 0x40100 ? Effect : 0)
}
; ==================================================================================================================================
; Auxiliary functions.
; ==================================================================================================================================
DoDragDrop_GetBitmapSize(HBITMAP, ByRef W, ByRef H) {
   VarSetCapacity(BM, 32, 0)
   If DllCall("GetObject", "Ptr", HBITMAP, "Int", A_PtrSize = 8 ? 32 : 24, "Ptr", &BM, "Int") {
      W := NumGet(BM, 4, "Int"), H := NumGet(BM, 8, "Int")
      Return True
   }
   Return False
}
; ==================================================================================================================================
#Include *i IDataObject.ahk
#Include *i IDropSource.ahk
#Include *i IDragSourceHelper.ahk
; ==================================================================================================================================
