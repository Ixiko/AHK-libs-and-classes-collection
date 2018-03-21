/*
XCLASS_DATA  := 0x2000
XCLASS_FLAGS := 0x4000
XTYP_EXECUTE := 0x0050 | XCLASS_FLAGS
XTYP_POKE    := 0x0090 | XCLASS_FLAGS
XTYP_REQUEST := 0x00B0 | XCLASS_DATA
*/

DdeInitialize(pCallback = 0, nFlags = 0)
{
   DllCall("DdeInitialize", "UintP", idInst, "Uint", pCallback, "Uint", nFlags, "Uint", 0)
   Return idInst
}

DdeUninitialize(idInst)
{
   Return DllCall("DdeUninitialize", "Uint", idInst)
}

DdeConnect(idInst, hServer, hTopic, pCC = 0)
{
   Return DllCall("DdeConnect", "Uint", idInst, "Uint", hServer, "Uint", hTopic, "Uint", pCC)
}

DdeDisconnect(hConv)
{
   Return DllCall("DdeDisconnect", "Uint", hConv)
}

DdeAccessData(hData)
{
   Return DllCall("DdeAccessData", "Uint", hData, "Uint", 0, "str")
}

DdeUnaccessData(hData)
{
   Return DllCall("DdeUnaccessData", "Uint", hData)
}

DdeFreeDataHandle(hData)
{
   Return DllCall("DdeFreeDataHandle", "Uint", hData)
}

DdeCreateStringHandle(idInst, sString, nCodePage = 1004)         ; CP_WINANSI = 1004
{
   Return DllCall("DdeCreateStringHandle", "Uint", idInst, "Uint", &sString, "int", nCodePage)
}

DdeFreeStringHandle(idInst, hString)
{
   Return DllCall("DdeFreeStringHandle", "Uint", idInst, "Uint", hString)
}

DdeClientTransaction(nType, hConv, hItem, sData = "", nFormat = 1, nTimeOut = 10000)   ; CF_TEXT = 1
{
   Return DllCall("DdeClientTransaction", "Uint", sData = "" ? 0 : &sData, "Uint", sData = "" ? 0 : StrLen(sData)+1, "Uint", hConv, "Uint", hItem, "Uint", nFormat, "Uint", nType, "Uint", nTimeOut, "UintP", nResult)
}
