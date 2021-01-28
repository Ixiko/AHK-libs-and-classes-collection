; ==================================================================================================================================
; DoDragDrop -> msdn.microsoft.com/en-us/library/ms678486(v=vs.85).aspx
; Requires: IDataObject.ahk, IDropSource.ahk
; ==================================================================================================================================
; Carries out an OLE drag and drop operation using the current contents of the clipboard.
; Return values:
;     If the data have been dropped successfully, the functions returns the performed drop operation (i.e. 1 for
;     DROPEFFECT_COPY or 2 for DROPEFFECT_MOVE). In all other cases the function returns 0.
;     If DROPEFFECT_MOVE is returned, the drag source should remove the data.
; ==================================================================================================================================
DoDragDrop() {
   ; DRAGDROP_S_DROP = 0x40100
   Static DropEffects := 0x03 ; DROPEFFECT_COPY | DROPEFFECT_MOVE
   IDS := IDropSource_Create()
   If !DllCall("Ole32.dll\OleGetClipboard", "PtrP", pDataObj, "UInt") {
      HBITMAP := IDragSourceHelper_LoadImage(A_ScriptDir . "\Test.bmp", 64, 64)
      IDSH := IDragSourceHelper_CreateFromBitmap(pDataObj, HBITMAP, 64, 64)
;       IDSH := IDragSourceHelper_CreateFromWindow(pDataObj, TVHWND)
      RC := DllCall("Ole32.dll\DoDragDrop","Ptr", pDataObj, "Ptr", IDS, "UInt", DropEffects, "PtrP", Effect, "Int")
      If IDataObject_GetPerformedDropEffect(pDataObj, PerformedDropEffect)
         Effect := PerformedDropEffect
      ObjRelease(pDataObj)
      ObjRelease(IDSH)
      DllCall("Gdi32.dll\DeleteObject", "Ptr", HBITMAP)
   }
   IDropSource_Free(IDS)
   Return (RC = 0x40100 ? Effect : 0)
}
; ==================================================================================================================================
#Include *i %A_ScriptDir%\IDataObject.ahk
#Include *i %A_ScriptDir%\IDropSource.ahk
; ==================================================================================================================================