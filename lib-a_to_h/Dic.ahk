/* SubVersion Keywords
RegExMatch("$LastChangedRevision: 7 $"
         . "$LastChangedDate: 2007-06-18 22:10:59 +0200 (Mo, 18 Jun 2007) $"
         , "(?P<Num>\d+).*?(?P<Date>(?:\d+-?){3})", SVN_Rev)
*/
/* original by Sean
www.autohotkey.com/forum/topic17838.html
requires AHK 1.0.46.15
*/

;###############################################################################
;###  Scripting.Dictionary COM object Modul                                  ###
;###############################################################################
Dic(Option, pdic=""){
    static Initialized := False
    If (RegExMatch(Option, "i)^init") AND !Initialized){  ;initialize OLE
        DllCall("ole32\CoInitialize", UInt,0)
        Initialized := True
        Return 1
    }Else If (RegExMatch(Option, "i)^uninit") AND Initialized){  ;uninitialize OLE
        DllCall("ole32\CoUninitialize")
        Initialized := False
        Return 1
    }Else If (pdic AND RegExMatch(Option, "i)^(exit|del|rem|destr)") AND Initialized) { ;delete dictionary
        Dic_DestroyDictionary(pdic)
        Return 1
    }Else If (!pdic AND Option AND Initialized){      ;create dictionary
        pdic := Dic_CreateDictionary()
        If RegExMatch(Option, "i)insensi")
            Option := 1
        If RegExMatch(Option, "i)sensi")
            Option := 0
        Modes = btd                           ;with CompareModes:
        Loop, Parse, Modes                    ;     0: Binary, 1: Text, 2: Database, n: LCID
            If RegExMatch(Option, "i)^" A_LoopField)
                Option := A_Index - 1
        If RegExMatch(Option, "\d")
            DllCall(Dic_VTable(pdic,18), UInt,pdic, Int, Option)
        Return pdic
      }
  }

Dic_Add(pdic, sKey, sItm) {  ; If key exists: no effect (<--> Set)
   Dic_AllocBString(pKey, var1, sKey)
   Dic_AllocBString(pItm, var2, sItm)
   DllCall(Dic_VTable(pdic,10), UInt,pdic, UInt,&var1, UInt,&var2)
   DllCall("oleaut32\SysFreeString", UInt,pKey)
   DllCall("oleaut32\SysFreeString", UInt,pItm)
}

Dic_Set(pdic, sKey, sItm) {  ; If key exists, update the item, Else create a new entry
   Dic_AllocBString(pKey, var1, sKey)
   Dic_AllocBString(pItm, var2, sItm)
   DllCall(Dic_VTable(pdic,8), UInt,pdic, UInt,&var1, UInt,&var2)  ; 8 (Set0 -> 7)
   DllCall("oleaut32\SysFreeString", UInt,pKey)
   DllCall("oleaut32\SysFreeString", UInt,pItm)
}

Dic_Get(pdic, sKey) {  ; empty if not exists
   Dic_AllocBString(pKey, var1, sKey)
   DllCall(Dic_VTable(pdic,12), UInt,pdic, UInt,&var1, IntP,bExist)
   If bExist {     ; to avoid creating an unwanted new entry
      VarSetCapacity(var2, 16, 0)
      DllCall(Dic_VTable(pdic,9), UInt,pdic, UInt,&var1, UInt,&var2)
      pItm := *(&var2+8) | *(&var2+9) << 8 | *(&var2+10) << 16 | *(&var2+11) << 24
      Dic_Unicode2Ansi(pItm, sItm)
      DllCall("oleaut32\SysFreeString", UInt,pItm)
   }
   DllCall("oleaut32\SysFreeString", UInt,pKey)
   Return sItm
}

Dic_NextKey(ByRef penum, pdic = "") {                  ; penum = "": create new list
   If penum =                                          ; not static: allow multiple independent lists
      DllCall(Dic_VTable(pdic,20), UInt,pdic, UIntP,penum) ; create key-list in penum
   VarSetCapacity(var, 16, 0)
   If (InStr("Clear0",pdic) || DllCall(Dic_VTable(penum,3), UInt,penum, UInt,1, UInt,&var, UInt,0)) {
      DllCall(Dic_VTable(penum,2), UInt,penum)         ; END: destroy key-list
      penum =                                          ; signal end of list
      Return                                           ; empty
   }
   pKey := Dic_UInt@(&var + 8)
   Dic_Unicode2Ansi(pKey, sKey)
   DllCall("oleaut32\SysFreeString", UInt,pKey)
   Return skey
}

Dic_Count(pdic) {      ; #entries
   DllCall(Dic_VTable(pdic,11), UInt,pdic, IntP,nCount)
   Return nCount
}

Dic_Exists(pdic, sKey) {
   Dic_AllocBString(pKey, var, sKey)
   DllCall(Dic_VTable(pdic,12), UInt,pdic, UInt,&var, IntP,bExist)
   DllCall("oleaut32\SysFreeString", UInt,pKey)
   Return bExist
}

Dic_Rename(pdic, sKeyFr, sKeyTo) {
   Dic_AllocBString(pKeyFr, var1, sKeyFr)
   Dic_AllocBString(pKeyTo, var2, sKeyTo)
   DllCall(Dic_VTable(pdic,14), UInt,pdic, UInt,&var1, UInt,&var2)
   DllCall("oleaut32\SysFreeString", UInt,pKeyFr)
   DllCall("oleaut32\SysFreeString", UInt,pKeyTo)
}

Dic_Remove(pdic, sKey) {
   Dic_AllocBString(pKey, var, sKey)
   DllCall(Dic_VTable(pdic,16), UInt,pdic, UInt,&var)
   DllCall("oleaut32\SysFreeString", UInt,pKey)
}

Dic_RemoveAll(pdic) {
   Return DllCall(Dic_VTable(pdic,17), UInt,pdic)
}

Dic_GetCompareMode(pdic) {
   DllCall(Dic_VTable(pdic,19), UInt,pdic, IntP,nCompMode)
   Return nCompMode
}

Dic_HashVal(pdic, sKey) {
   Dic_AllocBString(pKey, var1, sKey)
   DllCall(Dic_VTable(pdic,12), UInt,pdic, UInt,&var1, IntP,bExist)
   VarSetCapacity(var2, 16, 0)
   DllCall(Dic_VTable(pdic,21), UInt,pdic, UInt,&var1, UInt,&var2)
   nHashVal := *(&var2+8) | *(&var2+9) << 8 | *(&var2+10) << 16 | *(&var2+11) << 24
   DllCall("oleaut32\SysFreeString", UInt,pKey)
   Return nHashVal
}

Dic_About() {
	local version := "$LastChangedRevision: 7 $"
      , link :="www.autohotkey.com/forum/topic17838.html"
	return "Dic " . RegExReplace(version,"\$LastChangedRevision: (\d+) \$", "$1")
     . "`nCreated by: Sean with modifications by Laszlo and toralf`nSee: " . link
}

;#########  PRIVATE FUNCTIONS   ################################################

Dic_CreateDictionary() {
    CLSID_Dictionary := "{EE09B103-97E0-11CF-978F-00A02463E06F}"
    IID_IDictionary  := "{42C642C1-97E1-11CF-978F-00A02463E06F}"
    Return Dic_CreateObject(CLSID_Dictionary, IID_IDictionary)
  }

Dic_DestroyDictionary(pdic) {
    DllCall(Dic_UInt@(Dic_UInt@(pdic)+8), UInt,pdic)
  }

Dic_AllocBString(ByRef Key, ByRef Var, sString) {
   Dic_Ansi2Unicode(sString, wString)
   Key := DllCall("oleaut32\SysAllocString", Str,wString)
   VarSetCapacity(Var, 16, 0)
   DllCall("ntdll\RtlFillMemoryUlong", UInt,&Var,  UInt,4, UInt,8)
   DllCall("ntdll\RtlFillMemoryUlong", UInt,&Var+8,UInt,4, UInt,Key)
}

Dic_UInt@(ptr) {
   Return *ptr | *(ptr+1) << 8 | *(ptr+2) << 16 | *(ptr+3) << 24
}

Dic_CreateObject(ByRef CLSID, ByRef IID, CLSCTX = 5) {
   If StrLen(CLSID) = 38
      Dic_GUID4String(CLSID, CLSID)
   If StrLen(IID) = 38
      Dic_GUID4String(IID, IID)
   DllCall("ole32\CoCreateInstance", Str,CLSID, UInt,0, UInt,CLSCTX, Str,IID, UIntP,ppv)
   Return ppv
}
Dic_GUID4String(Byref CLSID, sString) {
   VarSetCapacity(CLSID, 16)
   Dic_Ansi2Unicode(sString, wString, 38)
   DllCall("ole32\CLSIDFromString", Str,wString, Str,CLSID)
}
Dic_Ansi2Unicode(ByRef sString, ByRef wString, nLen = 0) {
   If !nLen
      nLen := DllCall("MultiByteToWideChar", UInt,0, UInt,0, UInt,&sString, Int,-1, UInt,0, Int,0)
   VarSetCapacity(wString, nLen*2 + 1)
   DllCall("MultiByteToWideChar", UInt,0, UInt,0, UInt,&sString, Int,-1, UInt,&wString, Int,nLen)
}
Dic_VTable(ppv, idx) {
   Return Dic_UInt@(Dic_UInt@(ppv) + idx*4)
}
Dic_Unicode2Ansi(ByRef wString, ByRef sString, nLen = 0) {
   pString := wString + 0 > 65535 ? wString : &wString
   If !nLen
      nLen := DllCall("WideCharToMultiByte", UInt,0, UInt,0, UInt,pString, Int,-1, UInt,0, Int,0, UInt,0, UInt,0)
   VarSetCapacity(sString, nLen)
   DllCall("WideCharToMultiByte", UInt,0, UInt,0, UInt,pString, Int,-1, Str,sString, Int,nLen, UInt,0, UInt,0)
}
