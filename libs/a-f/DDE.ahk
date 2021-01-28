;By majkinetor

/*
DDE_Callback(nType, nFormat, hConv, hString1, hString2, hData, nData1, nData2)
{
}
*/

DDE_Initialize(idInst = 0, pCallback = 0, nFlags = 0)
{
	If	DllCall("DdeInitialize", "UintP", idInst, "Uint", pCallback, "Uint", nFlags, "Uint", 0)=0
	Return	idInst
}

DDE_Uninitialize(idInst)
{
	Return	DllCall("DdeUninitialize", "Uint", idInst)
}

DDE_GetLastError(idInst)
{
	Return	DllCall("DdeGetLastError", "Uint", idInst)
}

DDE_NameService(idInst, sServ = "", nCmd = 1)
{
	Return	DllCall("DdeNameService", "Uint", idInst, "Uint", hServ:=sServ="" ? 0 : DDE_CreateStringHandle(idInst,sServ), "Uint", 0, "Uint", nCmd), hServ ? DDE_FreeStringHandle(idInst,hServ) : ""
}

DDE_EnableCallback(idInst, hConv = 0, nCmd = 0)
{
	Return	DllCall("DdeEnableCallback", "Uint", idInst, "Uint", hConv, "Uint", nCmd)
}

DDE_PostAdvise(idInst, sTopic = "", sItem = "")
{
	Return	DllCall("DdePostAdvise", "Uint", idInst, "Uint", hTopic:=sTopic="" ? 0 : DDE_CreateStringHandle(idInst,sTopic), "Uint", hItem:=sItem="" ? 0 : DDE_CreateStringHandle(idInst,sItem))
	,	hTopic ? DDE_FreeStringHandle(idInst,hTopic) : ""
	,	hItem  ? DDE_FreeStringHandle(idInst,hItem)  : ""
}

DDE_ClientTransaction(idInst, hConv, sType = "EXECUTE", sItem = "", pData = 0, cbData = 0, CF_Format = 1, bAsync = False){
	static  XTYP_ADVSTART := 0x1030,  XTYP_ADVSTOP := 0x8040, XTYP_EXECUTE := 0x4050, XTYP_POKE	:= 0x4090, XTYP_REQUEST	:= 0x20B0
	Return	DllCall("DdeClientTransaction", "Uint", pData, "Uint", cbData, "Uint", hConv, "Uint", hItem:=sItem="" ? 0 : DDE_CreateStringHandle(idInst,sItem), "Uint", CF_Format, "Uint", XTYP_%sType%, "Uint", bAsync ? TIMEOUT_ASYNC:=-1 : 10000, "UintP", nResult), hItem ? DDE_FreeStringHandle(idInst,hItem) : ""
}

DDE_AbandonTransaction(idInst, hConv = 0, idTransaction = 0)
{
	Return	DllCall("DdeAbandonTransaction", "Uint", idInst, "Uint", hConv, "Uint", idTransaction)
}

DDE_Connect(idInst, sServ = "", sTopic = "", pCC = 0)
{
	Return	DllCall("DdeConnect", "Uint", idInst, "Uint", hServ:=sServ="" ? 0 : DDE_CreateStringHandle(idInst,sServ), "Uint", hTopic:=sTopic="" ? 0 : DDE_CreateStringHandle(idInst,sTopic), "Uint", pCC)
	,	hTopic ? DDE_FreeStringHandle(idInst,hTopic) : ""
	,	hServ  ? DDE_FreeStringHandle(idInst,hServ)  : ""
}

DDE_Reconnect(hConv)
{
	Return	DllCall("DdeReconnect", "Uint", hConv)
}

DDE_Disconnect(hConv)
{
	Return	DllCall("DdeDisconnect", "Uint", hConv)
}

DDE_ConnectList(idInst, sServ = "", sTopic = "", hConvList = 0, pCC = 0)
{
	Return	DllCall("DdeConnectList", "Uint", idInst, "Uint", hServ:=sServ="" ? 0 : DDE_CreateStringHandle(idInst,sServ), "Uint", hTopic:=sTopic="" ? 0 : DDE_CreateStringHandle(idInst,sTopic), "Uint", hConvList, "Uint", pCC)
	,	hTopic ? DDE_FreeStringHandle(idInst,hTopic) : ""
	,	hServ  ? DDE_FreeStringHandle(idInst,hServ)  : ""
}

DDE_DisconnectList(hConvList)
{
	Return	DllCall("DdeDisconnectList", "Uint", hConvList)
}

DDE_QueryNextServer(hConvList, hConvPrev = 0)
{
	Return	DllCall("DdeQueryNextServer", "Uint", hConvList, "Uint", hConvPrev)
}

DDE_QueryConvInfo(hConv, idTransaction = -1, ByRef ci = "")	; QID_SYNC=-1
{
	Return	DllCall("DdeQueryConvInfo", "Uint", hConv, "Uint", idTransaction, "Uint", NumPut(VarSetCapacity(ci,64,0),ci)-4)
}

DDE_AccessData(hData, ByRef cbData = "")
{
	Return	DllCall("DdeAccessData", "Uint", hData, "UintP", cbData)
}

DDE_UnaccessData(hData)
{
	Return	DllCall("DdeUnaccessData", "Uint", hData)
}

DDE_AddData(hData, pData, cbData, cbOff = 0)
{
	Return	DllCall("DdeAddData", "Uint", hData, "Uint", pData, "Uint", cbData, "Uint", cbOff)
}

DDE_GetData(hData, ByRef sData = "", cbOff = 0)
{
	cb  :=	DllCall("DdeGetData", "Uint", hData, "Uint", 0, "Uint", 0, "Uint", cbOff)
	VarSetCapacity(sData, cb)
	If	DllCall("DdeGetData", "Uint", hData, "str", sData, "Uint", cb, "Uint", cbOff)
	Return	sData
}

DDE_QueryString(idInst, hString, nCodePage = 1004)	; CP_WINANSI = 1004, CP_WINUNICODE = 1200
{
	cch :=	DllCall("DdeQueryString", "Uint", idInst, "Uint", hString, "Uint", 0, "Uint", 0, "int", nCodePage)
	VarSetCapacity(sString, cch)
	If	DllCall("DdeQueryString", "Uint", idInst, "Uint", hString, "str", sString, "Uint", cch+1, "int", nCodePage)
	Return	sString
}

DDE_CreateDataHandle(idInst, sItem = "", pData = 0, cbData = 0, cbOff = 0, CF_Format = 1, bOwned = True)
{
	Return	DllCall("DdeCreateDataHandle", "Uint", idInst, "Uint", pData, "Uint", cbData, "Uint", cbOff, "Uint", hItem:=sItem="" ? 0 : DDE_CreateStringHandle(idInst,sItem), "Uint", CF_Format, "Uint", bOwned ? HDATA_APPOWNED:=1 : 0), hItem ? DDE_FreeStringHandle(idInst,hItem) : ""
}

DDE_FreeDataHandle(hData)
{
	Return	DllCall("DdeFreeDataHandle", "Uint", hData)
}

DDE_CreateStringHandle(idInst, sString, nCodePage = 1004)
{
	Return	DllCall("DdeCreateStringHandle", "Uint", idInst, "Uint", &sString, "int", nCodePage)
}

DDE_KeepStringHandle(idInst, hString)
{
	If	DllCall("DdeKeepStringHandle", "Uint", idInst, "UintP", hString)
	Return	hString
}

DDE_FreeStringHandle(idInst, hString)
{
	Return	DllCall("DdeFreeStringHandle", "Uint", idInst, "Uint", hString)
}

DDE_CmpStringHandles(hString1, hString2)
{
	Return	DllCall("DdeCmpStringHandles", "Uint", hString1, "Uint", hString2)
}

DDE_SetUserHandle(hConv, hUser)
{
	Return	DllCall("DdeSetUserHandle", "Uint", hConv, "Uint", -1, "Uint", hUser)
}
