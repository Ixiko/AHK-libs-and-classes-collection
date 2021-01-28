;=========================================
; Name:     	  RichEdit OleCallback
; Namespace:      RichEdit
; Authors:        just me & DigiDon
; Description:    IRichEditOleCallback interface AHK implementation for the RichEdit control
;=========================================
;
;=========================================
;RE_SetOleCallback
;Need to call this function just after creation of the RichEdit control
;HRE - Handle of the RichEdit Control
;ex: RE_SetOleCallback(RE2.HWND)
;Specify your contextmenu in IREOleCB_GetContextMenu() if you have one because it won't be called otherwise
;and disable existing dropfiles special GUI label for the RichEdit Control
;Then you can start dragging and dropping any document into the RichEdit field.
;=========================================
RE_SetOleCallback(HRE) {
   ; EM_SETOLECALLBACK = 0x0446
   SendMessage, 0x0446 , 0, % IREOleCB_Create() , , ahk_id %HRE%
   If (ErrorLevel = "FAIL") || (ErrorLevel = 0) {
      MsgBox, 16, %A_ThisFunc%, ERROR: %ErrorLevel%!
      Return False
   }
   Return True
}
; ================================================================================================================================
; IRichEditOleCallback -> msdn.microsoft.com/en-us/library/windows/desktop/bb774308(v=vs.85).aspx
; ================================================================================================================================
IREOleCB_Create() {
   Static VTBL := [RegisterCallback("IREOleCB_QueryInterface")
                 , RegisterCallback("IREOleCB_AddRef")
                 , RegisterCallback("IREOleCB_Release")
                 , RegisterCallback("IREOleCB_GetNewStorage")
                 , RegisterCallback("IREOleCB_GetInPlaceContext")
                 , RegisterCallback("IREOleCB_ShowContainerUI")
                 , RegisterCallback("IREOleCB_QueryInsertObject")
                 , RegisterCallback("IREOleCB_DeleteObject")
                 , RegisterCallback("IREOleCB_QueryAcceptData")
                 , RegisterCallback("IREOleCB_ContextSensitiveHelp")
                 , RegisterCallback("IREOleCB_GetClipboardData")
                 , RegisterCallback("IREOleCB_GetDragDropEffect")
                 , RegisterCallback("IREOleCB_GetContextMenu")]
   Static HeapSize := A_PtrSize * 20 ; VTBL pointer + 13 method pointers + 4 unused pointers + reference count + HEAP handle
   Static HeapOffset := A_PtrSize * 19 ; offset to store the heap handle within the heap
   Heap := DllCall("HeapCreate", "UInt", 0x05, "Ptr", 0, "Ptr", 0, "UPtr")
   IREOleCB := DllCall("HeapAlloc", "Ptr", Heap, "UInt", 0x08, "Ptr", HeapSize, "UPtr")
   Addr := IREOleCB
   Addr := NumPut(Addr + A_PtrSize, Addr + 0, "UPtr")
   For Each, CB In VTBL
      Addr := NumPut(CB, Addr + 0, "UPtr")
   NumPut(Heap, IREOleCB + HeapOffset, "UPtr")
   Return IREOleCB
}
; --------------------------------------------------------------------------------------------------------------------------------
; IUnknown::QueryInterface
; --------------------------------------------------------------------------------------------------------------------------------
IREOleCB_QueryInterface(IREOleCB, REFIID, ByRef IFPtr) {
   OutputDebug, %A_ThisFunc%
   Return 0 ; S_OK
}
; --------------------------------------------------------------------------------------------------------------------------------
; IUnknown::AddRef
; --------------------------------------------------------------------------------------------------------------------------------
IREOleCB_AddRef(IREOleCB) {
   Static RefOffset := A_PtrSize * 18
   OutputDebug, %A_ThisFunc%
   NumPut(RefCount := NumGet(IREOleCB + RefOffset, "UInt") + 1, IREOleCB + RefOffset, "UInt")
   Return RefCount
}
; --------------------------------------------------------------------------------------------------------------------------------
; IUnknown::Release
; --------------------------------------------------------------------------------------------------------------------------------
IREOleCB_Release(IREOleCB) {
   Static RefOffset := A_PtrSize * 18
        , HeapOffset := A_PtrSize * 19
   OutputDebug, %A_ThisFunc%
   NumPut(RefCount := NumGet(IREOleCB + RefOffset, "UInt") - 1, IREOleCB + RefOffset, "UInt")
   If (RefCount = 0) {
      Heap := NumGet(IREOleCB + HeapOffset, "UPtr")
      DllCall("HeapDestroy", "Ptr", Heap)
   }
   Return RefCount
}
; --------------------------------------------------------------------------------------------------------------------------------
; IRichEditOleCallback::GetNewStorage
; --------------------------------------------------------------------------------------------------------------------------------
IREOleCB_GetNewStorage(IREOleCB, IStoragePtr) {
   OutputDebug, %A_ThisFunc%
   ; msdn.microsoft.com/en-us/library/windows/desktop/aa378977(v=vs.85).aspx
	If !(HR := DllCall("Ole32.dll\CreateILockBytesOnHGlobal", "Ptr", 0, "Int", 1, "PtrP", ILockBytes)) {
      ; msdn.microsoft.com/en-us/library/windows/desktop/aa380324(v=vs.85).aspx
      ; STGM_READWRITE = 0x02, STGM_SHARE_EXCLUSIVE = 0x10, STGM_CREATE = 0x1000
   	If (HR := DllCall("Ole32.dll\StgCreateDocfileOnILockBytes", "Ptr", ILockBytes, "UInt", 0x1012, "UInt", 0, "PtrP", IStorage))
         ObjRelease(ILockBytes)
      Else
         NumPut(IStorage, IStoragePtr + 0, "UPtr")
   }
   Return HR
}
; --------------------------------------------------------------------------------------------------------------------------------
; IRichEditOleCallback::GetInPlaceContext - not implemented
; --------------------------------------------------------------------------------------------------------------------------------
IREOleCB_GetInPlaceContext(IREOleCB, Frame, Doc, FrameInfo) {
   OutputDebug, %A_ThisFunc%
   Return 0x80004001 ; E_NOTIMPL
}
; --------------------------------------------------------------------------------------------------------------------------------
; IRichEditOleCallback::ShowContainerUI - not implemented
; --------------------------------------------------------------------------------------------------------------------------------
IREOleCB_ShowContainerUI(IREOleCB, Show) {
   OutputDebug, %A_ThisFunc%
   Return 0x80004001 ; E_NOTIMPL
}
; --------------------------------------------------------------------------------------------------------------------------------
; IRichEditOleCallback::QueryInsertObject - returns S_OK
; --------------------------------------------------------------------------------------------------------------------------------
IREOleCB_QueryInsertObject(IREOleCB, CLSID, STG, CP) {
   OutputDebug, %A_ThisFunc%
   Return 0 ; S_OK
}
; --------------------------------------------------------------------------------------------------------------------------------
; IRichEditOleCallback::DeleteObject - returns S_OK
; --------------------------------------------------------------------------------------------------------------------------------
IREOleCB_DeleteObject(IREOleCB, OleObj) {
   OutputDebug, %A_ThisFunc%
   Return 0 ; S_OK
}
; --------------------------------------------------------------------------------------------------------------------------------
; IRichEditOleCallback::QueryAcceptData - returns S_OK
; --------------------------------------------------------------------------------------------------------------------------------
IREOleCB_QueryAcceptData(IREOleCB, DataObj, Format, Operation, Really, MetaPic) {
   OutputDebug, %A_ThisFunc%
   Return 0 ; S_OK
}
; --------------------------------------------------------------------------------------------------------------------------------
; IRichEditOleCallback::ContextSensitiveHelp - not implemented
; --------------------------------------------------------------------------------------------------------------------------------
IREOleCB_ContextSensitiveHelp(IREOleCB, EnterMode) {
   OutputDebug, %A_ThisFunc%
   Return 0x80004001 ; E_NOTIMPL
}
; --------------------------------------------------------------------------------------------------------------------------------
; IRichEditOleCallback::GetClipboardData - not implemented
; --------------------------------------------------------------------------------------------------------------------------------
IREOleCB_GetClipboardData(IREOleCB, CharRange, Operation, DataObj) {
   OutputDebug, %A_ThisFunc%
   Return 0x80004001 ; E_NOTIMPL
}
; --------------------------------------------------------------------------------------------------------------------------------
; IRichEditOleCallback::GetDragDropEffect - returns S_OK
; --------------------------------------------------------------------------------------------------------------------------------
IREOleCB_GetDragDropEffect(IREOleCB, Drag, KeyState, Effect) {
   OutputDebug, %A_ThisFunc%
   Return 0 ; S_OK
}
; --------------------------------------------------------------------------------------------------------------------------------
; IRichEditOleCallback::GetContextMenu - not implemented
; --------------------------------------------------------------------------------------------------------------------------------
IREOleCB_GetContextMenu(IREOleCB, SelType, OleObj, CharRange, HMENU) {
	;PUT YOUR  CONTEXT MNU HERE
	;Menu, RN_ContextMenu, Show
   ; OutputDebug, %A_ThisFunc%
   Return 0x80004001 ; E_NOTIMPL
}