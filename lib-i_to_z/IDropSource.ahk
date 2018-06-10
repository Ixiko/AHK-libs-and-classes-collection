; ==================================================================================================================================
; IDropSource interface -> msdn.microsoft.com/en-us/library/ms690071(v=vs.85).aspx
; Note: Right-drag is not supported as yet!
; ==================================================================================================================================
; Super-global object to store user-defined cursors used by IDropSource_GiveFeedback().
; The cursor handles (HCURSOR) for the different drop-effects have to be stored using the following indices:
; 0 : DROPEFFECT_NONE - Drop target cannot accept the data.
; 1 : DROPEFFECT_COPY - Drop results in a copy.
; 2 : DROPEFFECT_MOVE - Drop results in a move.
; 3 : Copy or move.
; 4 : DROPEFFECT_LINK - Drop should result in creating a link.
Global IDropSource_Cursors
; ==================================================================================================================================
IDropSource_Create() {
   Static Methods := ["QueryInterface", "AddRef", "Release", "QueryContinueDrag", "GiveFeedback"]
   Static Params  := [3, 1, 1, 3, 2]
   Static VTBL, Dummy := VarSetCapacity(VTBL, A_PtrSize, 0)
   If (NumGet(VTBL, "UPtr") = 0) {
      VarSetCapacity(VTBL, (Methods.Length() + 2) * A_PtrSize, 0)
      NumPut(&VTBL + A_PtrSize, VTBL, "UPtr")
      For Index, Method In Methods {
         CB := RegisterCallback("IDropSource_" . Method, "", Params[Index])
         NumPut(CB, VTBL, Index * A_PtrSize, "UPtr")
      }
   }
   Return &VTBL
}
; ----------------------------------------------------------------------------------------------------------------------------------
IDropSource_Free(IDropSource) {
   IDropSource := 0
   Return True
}
; ==================================================================================================================================
; The following functions must not be called directly, they are reserved for internal and system use.
; ==================================================================================================================================
IDropSource_QueryInterface(IDropSource, RIID, PPV) {
   ; IUnknown.QueryInterface -> msdn.microsoft.com/en-us/library/ms682521(v=vs.85).aspx
   Static IID := "{00000121-0000-0000-C000-000000000046}", IID_IDropSource := 0
        , Init := VarSetCapacity(IID_IDropSource, 16, 0) + DllCall("Ole32.dll\IIDFromString", "WStr", IID, "Ptr", &IID_IDropSource)
   If DllCall("Ole32.dll\IsEqualGUID", "Ptr", RIID, "Ptr", &IID_IDropSource) {
      NumPut(IDropSource, PPV + 0, "Ptr")
      Return 0 ; S_OK
   }
   Else {
      NumPut(0, PPV + 0, "Ptr")
      Return 0x80004002 ; E_NOINTERFACE
   }
}
; ----------------------------------------------------------------------------------------------------------------------------------
IDropSource_AddRef(IDropSource) {
   ; IUnknown.AddRef -> msdn.microsoft.com/en-us/library/ms691379(v=vs.85).aspx
   ; Reference counting is not needed in this case.
   Return 1
}
; ----------------------------------------------------------------------------------------------------------------------------------
IDropSource_Release(IDropSource) {
   ; IUnknown.Release -> msdn.microsoft.com/en-us/library/ms682317(v=vs.85).aspx
   ; Reference counting is not needed in this case.
   Return 0
}
; ----------------------------------------------------------------------------------------------------------------------------------
IDropSource_QueryContinueDrag(IDropSource, fEscapePressed, grfKeyState) {
   ; QueryContinueDrag -> msdn.microsoft.com/en-us/library/ms690076(v=vs.85).aspx
   ; DRAGDROP_S_CANCEL : S_OK : DRAGDROP_S_DROP
   Return (fEscapePressed ? 0x40101 : (grfKeyState & 0x01) ? 0 : 0x40100)
}
; ----------------------------------------------------------------------------------------------------------------------------------
IDropSource_GiveFeedback(IDropSource, dwEffect) {
   ; GiveFeedback -> msdn.microsoft.com/en-us/library/ms693723(v=vs.85).aspx
   If (DragCursor := IDropSource_Cursors[dwEffect & 0x07]) {
      DllCall("SetCursor", "Ptr", DragCursor)
      Return 0
   }
   Return 0x40102 ; DRAGDROP_S_USEDEFAULTCURSORS
}
; ==================================================================================================================================