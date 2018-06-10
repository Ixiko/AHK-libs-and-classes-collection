; ==================================================================================================================================
; !!! Win Vista+ !!!
; ==================================================================================================================================
; Executes a drag-and-drop operation. Supports drag source creation on demand, as well as drag images.
; Drag-and-drop data must be stored in the clipboard before you call the function.
; Optional Parameters:
;     DragImage            -  SHDoDragDrop (API) uses a default drag image if no other option is available. You may pass:
;                             -  a HWND of a window or control which will create an own drag image in response to the
;                                DI_GETDRAGIMAGE message (e.g. ListViews and TreeViews support this message).
;                             -  a HBITMAP handle of a bitmap to be used as the drag image.
;     DropEffect           -  By default, the function sets both 1 (copy) and 2 (move) as possible actions for the
;                             drag-and-drop operation. You may pass either 1 (copy) or 2 (move) to override the default.
;     PreferredDropEffect  -  If the drop-effect equals the default value (0x03) most drop targets use 1 (copy) as their default.
;                             You can pass either 1 (copy) or 2 (move) as your preferred default if it hasn't been already set
;                             in the clipboard.
; Return values:
;     On success: The performed drop operation (1 = DROPEFFECT_COPY, 2 = DROPEFFECT_MOVE).
;                 If DROPEFFECT_MOVE is returned, the drag source is responsible for removing the data.
;     On failure: False (0).
; Requires:
;     SHDataObject.ahk
;     IDataObject.ahk
;     IEnumFORMATETC.ahk
; MSDN:
;     SHDoDragDrop -> msdn.microsoft.com/en-us/library/windows/desktop/bb762151(v=vs.85).aspx
; ==================================================================================================================================
SHDoDragDrop(DragImage := 0, DropEffect := 0x03, PreferredDropEffect := 0) {
   Static PermittedDropEffects := 0x03 ; DROPEFFECT_COPY (0x01) | DROPEFFECT_MOVE (0x02)
   VarSetCapacity(FPL, 8, 0)  ; FormatPriorityList
   NumPut(1, FPL, 0, "UInt")  ; CF_TEXT
   NumPut(15, FPL, 4, "UInt") ; CF_HDROP
   If (DllCall("GetPriorityClipboardFormat", "Ptr", &FPL, "Int", 2, "Int") < 1)
      Return False
   If !(DropEffect &= PermittedDropEffects)
      Return False
   PreferredDropEffect &= PermittedDropEffects
   HWND := 0
   If !DllCall("Ole32.dll\OleGetClipboard", "PtrP", CBDO, "Int") {
      If (SHDO := SHDataObject_Create(CBDO)) {
         If (Dropeffect = 3) && PreferredDropEffect
            IDataObject_SetPreferredDropEffect(SHDO, PreferredDropEffect)
         If (DragImage) {
            If DllCall("IsWindow", "Ptr", DragImage, "Int")
               HWND := DragImage
            Else If (DllCall("GetObjectType", "Ptr", DragImage, "UInt") = 7) ; OBJ_BITMAP
               SHDataObject_DragImageFromBitmap(SHDO, DragImage)
         }
         HR := DllCall("Shell32.dll\SHDoDragDrop", "Ptr", HWND, "Ptr", SHDO, "Ptr", 0, "UInt", DropEffect, "UIntP", Effect, "Int")
         If IDataObject_GetPerformedDropEffect(SHDO, PerformedDropEffect)
            Effect := PerformedDropEffect
         ObjRelease(SHDO)
      }
      ObjRelease(CBDO)
   }
   Return (HR = 0x40100 ? ((Effect = 0x03) ? 1 : Effect) : False) ; DRAGDROP_S_DROP = 0x40100
}
; ==================================================================================================================================
#Include *i SHDataObject.ahk
; ==================================================================================================================================