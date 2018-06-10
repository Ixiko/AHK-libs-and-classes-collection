;By Sean
/* Example
CoInitialize()
pdic := Dictionary()
;SetCompareMode(pdic, 1) ; Set text mode, i.e., Case of Key is ignored. Otherwise case-sensitive defaultly.
Add(pdic, "Test1", "This is a Test1")
Add(pdic, "Test2", "This is a Test2")
Add(pdic, "Test1", "This is a Test3")

SetItem(pdic, "Result1", "This is a Result1")
SetItem(pdic, "Result2", "This is a Result2")
SetItem(pdic, "Result1", "This is a Result3")

OutputDebug, % "Test1: " . GetItem(pdic, "Test1")
OutputDebug, % "Test2: " . GetItem(pdic, "test2")
OutputDebug, % "Result1: " . GetItem(pdic, "Result1")
OutputDebug, % "Result2: " . GetItem(pdic, "result2")

MsgBox, % "Count: " . Count(pdic) . "`n" . Enumerate(pdic)

Release(pdic)
CoUninitialize()
*/


Dictionary() {
   CLSID_Dictionary := "{EE09B103-97E0-11CF-978F-00A02463E06F}"
    IID_IDictionary := "{42C642C1-97E1-11CF-978F-00A02463E06F}"
   Return CreateObject(CLSID_Dictionary, IID_IDictionary)
}

SetItem0(pdic, sKey, sItm) {  ; The difference with SetItem?

   pKey := SysAllocString(sKey)
   VarSetCapacity(var1, 8 * 2, 0)
   EncodeInteger(&var1 + 0, 8)
   EncodeInteger(&var1 + 8, pKey)

   pItm := SysAllocString(sItm)
   VarSetCapacity(var2, 8 * 2, 0)
   EncodeInteger(&var2 + 0, 8)
   EncodeInteger(&var2 + 8, pItm)

   DllCall(VTable(pdic, 7), "Uint", pdic, "Uint", &var1, "Uint", &var2)

   SysFreeString(pKey)
   SysFreeString(pItm)
}

SetItem(pdic, sKey, sItm) {  ; If the key exists, update the item, otherwise create a new one.

   pKey := SysAllocString(sKey)
   VarSetCapacity(var1, 8 * 2, 0)
   EncodeInteger(&var1 + 0, 8)
   EncodeInteger(&var1 + 8, pKey)

   pItm := SysAllocString(sItm)
   VarSetCapacity(var2, 8 * 2, 0)
   EncodeInteger(&var2 + 0, 8)
   EncodeInteger(&var2 + 8, pItm)

   DllCall(VTable(pdic, 8), "Uint", pdic, "Uint", &var1, "Uint", &var2)

   SysFreeString(pKey)
   SysFreeString(pItm)
}

GetItem(pdic, sKey) {  ; Added Exists check, to avoid creating an unwanted new one.

   pKey := SysAllocString(sKey)
   VarSetCapacity(var1, 8 * 2, 0)
   EncodeInteger(&var1 + 0, 8)
   EncodeInteger(&var1 + 8, pKey)

   DllCall(VTable(pdic, 12), "Uint", pdic, "Uint", &var1, "intP", bExist)

   If bExist
   {
      VarSetCapacity(var2, 8 * 2, 0)
      DllCall(VTable(pdic, 9), "Uint", pdic, "Uint", &var1, "Uint", &var2)
      pItm := DecodeInteger(&var2 + 8)
      Unicode2Ansi(pItm, sItm)
      SysFreeString(pItm)
   }

   SysFreeString(pKey)

   Return sItm
}

Add(pdic, sKey, sItm) {  ; If already existing one, will produce error, i.e., no update.

   pKey := SysAllocString(sKey)
   VarSetCapacity(var1, 8 * 2, 0)
   EncodeInteger(&var1 + 0, 8)
   EncodeInteger(&var1 + 8, pKey)

   pItm := SysAllocString(sItm)
   VarSetCapacity(var2, 8 * 2, 0)
   EncodeInteger(&var2 + 0, 8)
   EncodeInteger(&var2 + 8, pItm)

   DllCall(VTable(pdic, 10), "Uint", pdic, "Uint", &var1, "Uint", &var2)

   SysFreeString(pKey)
   SysFreeString(pItm)
}

Count(pdic) {

   DllCall(VTable(pdic, 11), "Uint", pdic, "intP", nCount)
   Return nCount
}

Exists(pdic, sKey) {
   pKey := SysAllocString(sKey)
   VarSetCapacity(var, 8 * 2, 0)
   EncodeInteger(&var + 0, 8)
   EncodeInteger(&var + 8, pKey)

   DllCall(VTable(pdic, 12), "Uint", pdic, "Uint", &var, "intP", bExist)

   SysFreeString(pKey)

   Return bExist
}

Items(pdic) {  ; Returns SafeArray.

   VarSetCapacity(var, 8 * 2, 0)
   DllCall(VTable(pdic, 13), "Uint", pdic, "Uint", &var)
   pItms := DecodeInteger(&var + 8)
   Return DllCall("oleaut32\SafeArrayDestroy", "Uint", pItms)
}

Rename(pdic, sKeyFr, sKeyTo) {
   pKeyFr := SysAllocString(sKeyFr)
   VarSetCapacity(var1, 8 * 2, 0)
   EncodeInteger(&var1 + 0, 8)
   EncodeInteger(&var1 + 8, pKeyFr)

   pKeyTo := SysAllocString(sKeyTo)
   VarSetCapacity(var2, 8 * 2, 0)
   EncodeInteger(&var2 + 0, 8)
   EncodeInteger(&var2 + 8, pKeyTo)

   DllCall(VTable(pdic, 14), "Uint", pdic, "Uint", &var1, "Uint", &var2)

   SysFreeString(pKeyFr)
   SysFreeString(pKeyTo)
}

Keys(pdic) {  ; Returns SafeArray.

   VarSetCapacity(var, 8 * 2, 0)
   DllCall(VTable(pdic, 15), "Uint", pdic, "Uint", &var)
   pKeys := DecodeInteger(&var + 8)
   Return DllCall("oleaut32\SafeArrayDestroy", "Uint", pKeys)
}

Remove(pdic, sKey) {
   pKey := SysAllocString(sKey)
   VarSetCapacity(var, 8 * 2, 0)
   EncodeInteger(&var + 0, 8)
   EncodeInteger(&var + 8, pKey)

   DllCall(VTable(pdic, 16), "Uint", pdic, "Uint", &var)

   SysFreeString(pKey)
}

RemoveAll(pdic) {
   Return DllCall(VTable(pdic, 17), "Uint", pdic)
}

SetCompareMode(pdic, nCompMode = 1) {
   DllCall(VTable(pdic, 18), "Uint", pdic, "int", nCompMode)
;   0: Binary, 1: Text, 2: Database, n: LCID
}

GetCompareMode(pdic) {
   DllCall(VTable(pdic, 19), "Uint", pdic, "intP", nCompMode)
   Return nCompMode
}

Enumerate(pdic) {
   DllCall(VTable(pdic, 20), "Uint", pdic, "UintP", penm)

   VarSetCapacity(var, 8 * 2, 0)

   Loop, % Count(pdic)
   {
      DllCall(VTable(penm, 3), "Uint", penm, "Uint", 1, "Uint", &var, "Uint", 0)
      pKey := DecodeInteger(&var + 8)
      DllCall(VTable(pdic, 9), "Uint", pdic, "Uint", &var, "Uint", &var)
      pItm := DecodeInteger(&var + 8)

      Unicode2Ansi(pKey, sKey)
      Unicode2Ansi(pItm, sItm)
      SysFreeString(pKey)
      SysFreeString(pItm)
      sKeys .= sKey . " : " . sItm . "`n"
   }

   DllCall(VTable(penm, 2), "Uint", penm)

   Return sKeys
}

NextKey(ByRef penm, pdic = 0) {                      ; penm = "": create new list

   If !penm                                                 ; not static: allow multiple independent lists
   DllCall(VTable(pdic, 20), "Uint", pdic, "UintP", penm)   ; create key-list in penm

   VarSetCapacity(var, 16, 0)
   If DllCall(VTable(penm, 3), "Uint", penm, "Uint", 1, "Uint", &var, "Uint", 0)
   {
      DllCall(VTable(penm, 2), "Uint", penm)             ; END: destroy key-list
      penm := ""                                         ; signal end of list
      Return                                             ; empty
   }
   pKey := DecodeInteger(&var + 8)

   Unicode2Ansi(pKey, sKey)
   SysFreeString(pKey)
   Return sKey
}

HashVal(pdic, sKey) {
   pKey := SysAllocString(sKey)
   VarSetCapacity(var1, 8 * 2, 0)
   EncodeInteger(&var1 + 0, 8)
   EncodeInteger(&var1 + 8, pKey)

   DllCall(VTable(pdic, 12), "Uint", pdic, "Uint", &var1, "intP", bExist)

   If bExist
   {
      VarSetCapacity(var2, 8 * 2, 0)
      DllCall(VTable(pdic, 21), "Uint", pdic, "Uint", &var1, "Uint", &var2)
      nHashVal := DecodeInteger(&var2 + 8)
   }

   SysFreeString(pKey)

   Return nHashVal
}

#Include CoHelper.ahk
