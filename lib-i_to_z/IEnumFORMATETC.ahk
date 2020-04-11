; ==================================================================================================================================
; IEnumFORMATETC interface -> msdn.microsoft.com/en-us/library/ms682337(v=vs.85).aspx
; Partial implementation, 'Clone' method is missing.
; ==================================================================================================================================
IEnumFORMATETC_Next(pEnumObj, ByRef FORMATETC) {
   ; Next -> msdn.microsoft.com/en-us/library/dd542673(v=vs.85).aspx
   Static Next := A_PtrSize * 3
   VarSetCapacity(FORMATETC, A_PtrSize = 8 ? 32 : 20, 0)
   , pVTBL := NumGet(pEnumObj + 0, "UPtr")
   Return !DllCall(NumGet(pVTBL + Next, "UPtr"), "Ptr", pEnumObj, "UInt", 1, "Ptr", &FORMATETC, "Ptr", 0, "Int")
}
; ----------------------------------------------------------------------------------------------------------------------------------
IEnumFORMATETC_Reset(pEnumObj) {
   ; Reset -> msdn.microsoft.com/en-us/library/dd542674(v=vs.85).aspx
   Static Reset := A_PtrSize * 5
   pVTBL := NumGet(pEnumObj + 0, "UPtr")
   Return !DllCall(NumGet(pVTBL + Reset, "UPtr"), "Ptr", pEnumObj, "Int")
}
; ----------------------------------------------------------------------------------------------------------------------------------
IEnumFORMATETC_Skip(pEnumObj, ItemCount) {
   ; Skip -> msdn.microsoft.com/en-us/library/dd542674(v=vs.85).aspx
   Static Skip := A_PtrSize * 4
   pVTBL := NumGet(pEnumObj + 0, "UPtr")
   Return !DllCall(NumGet(pVTBL + Skip, "UPtr"), "Ptr", pEnumObj, "UInt", ItemCount, "Int")
}
; ==================================================================================================================================