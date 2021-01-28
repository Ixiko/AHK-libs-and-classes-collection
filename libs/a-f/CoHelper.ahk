;By Sean

VTable(ppv, idx) {
   Return   NumGet(NumGet(1*ppv)+4*idx)
}

QueryInterface(ppv, ByRef IID) {
   If   StrLen(IID) = 38
   GUID4String(IID, IID)
   DllCall(NumGet(NumGet(1*ppv)), "Uint", ppv, "str", IID, "UintP", ppv)
   Return   ppv
}

AddRef(ppv) {
   Return   DllCall(NumGet(NumGet(1*ppv)+4), "Uint", ppv)
}

Release(ppv){
   Return   DllCall(NumGet(NumGet(1*ppv)+8), "Uint", ppv)
}

QueryService(ppv, ByRef SID, ByRef IID){
   If   StrLen(SID) = 38
   GUID4String(SID, SID)
   If   StrLen(IID) = 38
   GUID4String(IID, IID)
   GUID4String(IID_IServiceProvider, "{6D5140C1-7436-11CE-8034-00AA006009FA}")
   DllCall(NumGet(NumGet(1*ppv)+4*0), "Uint", ppv, "str", IID_IServiceProvider, "UintP", psp)
   DllCall(NumGet(NumGet(1*psp)+4*3), "Uint", psp, "str", SID, "str", IID, "UintP", ppv)
   DllCall(NumGet(NumGet(1*psp)+4*2), "Uint", psp)
   Return   ppv
}

GetIDispatch(ppv, LCID = 0){
   DllCall(NumGet(NumGet(1*ppv)+12), "Uint", ppv, "UintP", cti)
   If !cti
   Return
   DllCall(NumGet(NumGet(1*ppv)+16), "Uint", ppv, "Uint", 0, "Uint", LCID, "UintP", pti)
   DllCall(NumGet(NumGet(1*pti)+12), "Uint", pti, "UintP", pattr)
   DllCall(NumGet(NumGet(1*ppv)+ 0), "Uint", ppv, "Uint" , pattr, "UintP", pdisp)
   DllCall(NumGet(NumGet(1*pti)+76), "Uint", pti, "Uint" , pattr)
   DllCall(NumGet(NumGet(1*pti)+ 8), "Uint", pti)
   If pdisp
   DllCall(NumGet(NumGet(1*ppv)+ 8), "Uint", ppv)
   Return   pdisp
}

Invoke(pdisp, sName, arg1="vT_NoNe",arg2="vT_NoNe",arg3="vT_NoNe",arg4="vT_NoNe",arg5="vT_NoNe",arg6="vT_NoNe",arg7="vT_NoNe",arg8="vT_NoNe",arg9="vT_NoNe"){
   nParams:=0
   Loop,   9
   {
      If (arg%A_Index% == "vT_NoNe")
          Break
      nParams++
   }
   VarSetCapacity(DispParams,4*4,0), VarSetCapacity(varResult,8*2,0), VarSetCapacity(IID_NULL,16,0), VarSetCapacity(varg,16*nParams,0)
   NumPut(&varg,DispParams,0), NumPut(nParams,DispParams,8)
   If   (nFlags := SubStr(sName,0) <> "=" ? 3 : 12) = 12
      NumPut(&varResult,DispParams,4), NumPut(1,DispParams,12), NumPut(-3,varResult), sName:=SubStr(sName,1,-1)
   Loop,   %nParams%
   {
      If arg%A_Index% Is Not Integer
         NumPut(8,varg,16*(nParams-A_Index),"Ushort"), NumPut(SysAllocString(arg%A_Index%),varg,16*(nParams-A_Index)+8)
      Else   NumPut(SubStr(arg%A_Index%,1,1)="+" ? 9 : 3,varg,16*(nParams-A_Index),"Ushort"), NumPut(arg%A_Index%,varg,16*(nParams-A_Index)+8)
   }
   DllCall(NumGet(NumGet(1*pdisp)+20), "Uint", pdisp, "str", IID_NULL, "UintP", Unicode4Ansi(wName, sName), "Uint", 1, "Uint", LCID, "intP", dispID)
   DllCall(NumGet(NumGet(1*pdisp)+24), "Uint", pdisp, "int", dispID, "str", IID_NULL, "Uint", LCID, "Ushort", nFlags, "Uint", &DispParams, "Uint", &varResult, "Uint", 0, "Uint", 0)
   Loop,   %nParams%
      NumGet(varg,16*(A_Index-1),"Ushort")=8 ? SysFreeString(NumGet(varg,16*(A_Index-1)+8)) : ""
   If nFlags = 3
   InStr(" 0 4 5 6 7 14 "," " . NumGet(varResult,0,"Ushort") . " ") ? DllCall("oleaut32\VariantChangeTypeEx","Uint",&varResult,"Uint",&varResult,"Uint",LCID,"Ushort",0,"Ushort",8) : "", NumGet(varResult,0,"Ushort")=8 ? (hResult:=Ansi4Unicode(NumGet(varResult,8))) . SysFreeString(NumGet(varResult,8)) : hResult:=NumGet(varResult,8)
   Return   hResult
}

Invoke_(pdisp, sName, type1="",arg1="",type2="",arg2="",type3="",arg3="",type4="",arg4="",type5="",arg5="",type6="",arg6="",type7="",arg7="",type8="",arg8="",type9="",arg9=""){
   Global   _TEMP_VT_BYREF_
   nParams:=0
   Loop,   9
   {
      If (type%A_Index% = "")
          Break
      nParams++
   }
   VarSetCapacity(dispParams,4*4,0), VarSetCapacity(varResult,8*2,0), VarSetCapacity(IID_NULL,16,0), VarSetCapacity(varg,16*nParams,0)
      NumPut(&varg,dispParams,0), NumPut(nParams,dispParams,8)
   If   (nFlags := SubStr(sName,0) <> "=" ? 1|2 : 4|8) & 12
      NumPut(&varResult,dispParams,4), NumPut(1,dispParams,12), NumPut(-3,varResult), sName:=SubStr(sName,1,-1)
   Loop,   %nParams%
      NumPut(type%A_Index%,varg,16*(nParams-A_Index),"Ushort"), type%A_Index%&0x4000=0 ? NumPut(type%A_Index%=8 ? SysAllocString(arg%A_Index%) : arg%A_Index%,varg,16*(nParams-A_Index)+8,type%A_Index%=5||type%A_Index%=7 ? "double" : type%A_Index%=4 ? "float" : "int64") : type%A_Index%=0x400C||type%A_Index%=0x400E ? NumPut(arg%A_Index%,varg,(nParams-A_Index)*16+8) : VarSetCapacity(ref%A_Index%,8,0) . NumPut(&ref%A_Index%,varg,16*(nParams-A_Index)+8) . NumPut(type%A_Index%=0x4008 ? SysAllocString(arg%A_Index%) : arg%A_Index%,ref%A_Index%,0,type%A_Index%=0x4005||type%A_Index%=0x4007 ? "double" : type%A_Index%=0x4004 ? "float" : "int64")
   DllCall(NumGet(NumGet(1*pdisp)+20), "Uint", pdisp, "str", IID_NULL, "UintP", Unicode4Ansi(wName, sName), "Uint", 1, "Uint", LCID, "intP", dispID)
   DllCall(NumGet(NumGet(1*pdisp)+24), "Uint", pdisp, "int", dispID, "str", IID_NULL, "Uint", LCID, "Ushort", nFlags, "Uint", &dispParams, "Uint", &varResult, "Uint", 0, "Uint", 0)
   Loop,   %nParams%
      type%A_Index%&0x4000=0 ? (type%A_Index%=8 ? SysFreeString(NumGet(varg,16*(nParams-A_Index)+8)) : "") : type%A_Index%=0x400C||type%A_Index%=0x400E ? "" : type%A_Index%=0x4008 ? (_TEMP_VT_BYREF_%A_Index%:=Ansi4Unicode(NumGet(ref%A_Index%))) . SysFreeString(NumGet(ref%A_Index%)) : (_TEMP_VT_BYREF_%A_Index%:=NumGet(ref%A_Index%,0,type%A_Index%=0x4005||type%A_Index%=0x4007 ? "double" : type%A_Index%=0x4004 ? "float" : "int64"))
   If   nFlags & 3
      InStr(" 0 4 5 6 7 14 "," " . NumGet(varResult,0,"Ushort") . " ") ? DllCall("oleaut32\VariantChangeTypeEx","Uint",&varResult,"Uint",&varResult,"Uint",LCID,"Ushort",0,"Ushort",8) : "", NumGet(varResult,0,"Ushort")=8 ? (hResult:=Ansi4Unicode(NumGet(varResult,8))) . SysFreeString(NumGet(varResult,8)) : (hResult:=NumGet(varResult,8))
   Return   hResult
}

CreateObject(ByRef CLSID, ByRef IID, CLSCTX = 5){
   If   StrLen(CLSID)  =  38
   GUID4String(CLSID, CLSID)
   If   StrLen(IID) = 38
   GUID4String(IID, IID)
   DllCall("ole32\CoCreateInstance", "str", CLSID, "Uint", 0, "Uint", CLSCTX, "str", IID, "UintP", ppv)
   Return   ppv
}

ActiveXObject(ProgID, CLSCTX = 5){
   InStr(ProgID, "{") ? GUID4String(CLSID, ProgID) : CLSID4ProgID(CLSID, ProgID)
   GUID4String(IID_IDispatch, "{00020400-0000-0000-C000-000000000046}")
   DllCall("ole32\CoCreateInstance", "str", CLSID, "Uint", 0, "Uint", CLSCTX, "str", IID_IDispatch, "UintP", ppv)
   Return   (pdisp := GetIDispatch(ppv)) ? pdisp : ppv
}

GetObject(Moniker){
   Ansi2Unicode(Moniker, wMoniker)
   GUID4String(IID_IDispatch, "{00020400-0000-0000-C000-000000000046}")
   DllCall("ole32\CoGetObject", "str", wMoniker, "Uint", 0, "str", IID_IDispatch, "UintP", ppv)
   Return   (pdisp := GetIDispatch(ppv)) ? pdisp : ppv
}

GetActiveObject(ProgID){
   InStr(ProgID, "{") ? GUID4String(CLSID, ProgID) : CLSID4ProgID(CLSID, ProgID)
   GUID4String(IID_IDispatch, "{00020400-0000-0000-C000-000000000046}")
   DllCall("oleaut32\GetActiveObject", "str", CLSID, "Uint", 0, "UintP", punk)
   DllCall(NumGet(NumGet(1*punk)+0), "Uint", punk, "str", IID_IDispatch, "UintP", ppv)
   DllCall(NumGet(NumGet(1*punk)+8), "Uint", punk)
   Return   (pdisp := GetIDispatch(ppv)) ? pdisp : ppv
}

CLSID4ProgID(ByRef CLSID, sProgID, nOffset = 0){
   VarSetCapacity(CLSID, 16 + nOffset)
   Ansi2Unicode(sProgID, wProgID)
   DllCall("ole32\CLSIDFromProgID", "Uint", &wProgID, "Uint", &CLSID + nOffset)
   Return   &CLSID
}

ProgID4CLSID(ByRef CLSID, nOffset = 0){
   pCLSID := CLSID + 0 > 65535 ? CLSID : &CLSID
   DllCall("ole32\ProgIDFromCLSID", "Uint", pCLSID + nOffset, "UintP", pProgID)
   Unicode2Ansi(pProgID, sProgID)
   CoTaskMemFree(pProgID)
   Return   sProgID
}

GUID4String(ByRef CLSID, sString, nOffset = 0){
   VarSetCapacity(CLSID, 16 + nOffset)
   Ansi2Unicode(sString, wString, 38)
   DllCall("ole32\CLSIDFromString", "Uint", &wString, "Uint", &CLSID + nOffset)
   Return   &CLSID
}

String4GUID(ByRef GUID, nOffset = 0){
   pGUID := GUID + 0 > 65535 ? GUID : &GUID
   VarSetCapacity(wString, 38 * 2 + 1)
   DllCall("ole32\StringFromGUID2", "Uint", pGUID + nOffset, "Uint", &wString, "int", 38 + 1)
   Unicode2Ansi(wString, sString, 38)
   Return   sString
}

CoCreateGuid(){
   VarSetCapacity(GUID, 16, 0)
   DllCall("ole32\CoCreateGuid", "Uint", &GUID)
   Return   String4GUID(GUID)
}

CoTaskMemAlloc(cb){
   Return   DllCall("ole32\CoTaskMemAlloc", "Uint", cb)
}

CoTaskMemFree(pv){
   Return   DllCall("ole32\CoTaskMemFree", "Uint", pv)
}

CoInitialize(){
   Return   DllCall("ole32\CoInitialize", "Uint", 0)
}

CoUninitialize(){
   Return   DllCall("ole32\CoUninitialize")
}

OleInitialize(){
   Return   DllCall("ole32\OleInitialize", "Uint", 0)
}

OleUninitialize(){
   Return   DllCall("ole32\OleUninitialize")
}

SysAllocString(sString){
   Return   DllCall("oleaut32\SysAllocString", "Uint", Ansi2Unicode(sString, wString))
}

SysFreeString(pString){
   Return   DllCall("oleaut32\SysFreeString", "Uint", pString)
}

Ansi4Unicode(pString, nSize = 0){
   If !nSize
       nSize := DllCall("WideCharToMultiByte", "Uint", 0, "Uint", 0, "Uint", pString, "int", -1, "Uint", 0, "int",  0, "Uint", 0, "Uint", 0)
   VarSetCapacity(sString, nSize)
   DllCall("WideCharToMultiByte", "Uint", 0, "Uint", 0, "Uint", pString, "int", -1, "str", sString, "int", nSize + 1, "Uint", 0, "Uint", 0)
   Return   sString
}

Unicode4Ansi(ByRef wString, sString, nSize = 0){
   If !nSize
       nSize := DllCall("MultiByteToWideChar", "Uint", 0, "Uint", 0, "Uint", &sString, "int", -1, "Uint", 0, "int", 0)
   VarSetCapacity(wString, nSize * 2 + 1)
   DllCall("MultiByteToWideChar", "Uint", 0, "Uint", 0, "Uint", &sString, "int", -1, "Uint", &wString, "int", nSize + 1)
   Return   &wString
}

Ansi2Unicode(ByRef sString, ByRef wString, nSize = 0){
   If !nSize
       nSize := DllCall("MultiByteToWideChar", "Uint", 0, "Uint", 0, "Uint", &sString, "int", -1, "Uint", 0, "int", 0)
   VarSetCapacity(wString, nSize * 2 + 1)
   DllCall("MultiByteToWideChar", "Uint", 0, "Uint", 0, "Uint", &sString, "int", -1, "Uint", &wString, "int", nSize + 1)
   Return   &wString
}

Unicode2Ansi(ByRef wString, ByRef sString, nSize = 0){
   pString := wString + 0 > 65535 ? wString : &wString
   If !nSize
       nSize := DllCall("WideCharToMultiByte", "Uint", 0, "Uint", 0, "Uint", pString, "int", -1, "Uint", 0, "int",  0, "Uint", 0, "Uint", 0)
   VarSetCapacity(sString, nSize)
   DllCall("WideCharToMultiByte", "Uint", 0, "Uint", 0, "Uint", pString, "int", -1, "str", sString, "int", nSize + 1, "Uint", 0, "Uint", 0)
   Return   &sString
}

DecodeInteger(ref, nSize = 4){
   DllCall("RtlMoveMemory", "int64P", val, "Uint", ref, "Uint", nSize)
   Return   val
}

EncodeInteger(ref, val = 0, nSize = 4){
   DllCall("RtlMoveMemory", "Uint", ref, "int64P", val, "Uint", nSize)
}
