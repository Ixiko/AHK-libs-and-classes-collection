;------------------------------------------------------------------------------
; COM.ahk Standard Library
; by Sean
; http://www.autohotkey.com/forum/topic22923.html
;------------------------------------------------------------------------------

COM_Init(bUn = "")
{
	Static	h
	Return	(bUn&&!h:="")||h==""&&1==(h:=DllCall("ole32\OleInitialize","Uint",0))?DllCall("ole32\OleUninitialize"):0
}

COM_Term()
{
	COM_Init(1)
}

COM_VTable(ppv, idx)
{
	Return	NumGet(NumGet(1*ppv)+4*idx)
}

COM_QueryInterface(ppv, IID = "")
{
	If	DllCall(NumGet(NumGet(1*ppv:=COM_Unwrap(ppv))), "Uint", ppv+0, "Uint", COM_GUID4String(IID,IID ? IID:IID=0 ? "{00000000-0000-0000-C000-000000000046}":"{00020400-0000-0000-C000-000000000046}"), "UintP", ppv:=0)=0
	Return	ppv
}

COM_AddRef(ppv)
{
	Return	DllCall(NumGet(NumGet(1*ppv:=COM_Unwrap(ppv))+4), "Uint", ppv)
}

COM_Release(ppv)
{
	If Not	IsObject(ppv)
	Return	DllCall(NumGet(NumGet(1*ppv)+8), "Uint", ppv)
	Else
	{
	nRef:=	DllCall(NumGet(NumGet(COM_Unwrap(ppv))+8), "Uint", COM_Unwrap(ppv)), nRef==0 ? (ppv.prm_:=0):""
	Return	nRef
	}
}

COM_QueryService(ppv, SID, IID = "")
{
	If	DllCall(NumGet(NumGet(1*ppv:=COM_Unwrap(ppv))), "Uint", ppv, "Uint", COM_GUID4String(IID_IServiceProvider,"{6D5140C1-7436-11CE-8034-00AA006009FA}"), "UintP", psp)=0
	&&	DllCall(NumGet(NumGet(1*psp)+12), "Uint", psp, "Uint", COM_GUID4String(SID,SID), "Uint", IID ? COM_GUID4String(IID,IID):&SID, "UintP", ppv:=0)+DllCall(NumGet(NumGet(1*psp)+8), "Uint", psp)*0=0
	Return	COM_Enwrap(ppv)
}

COM_FindConnectionPoint(pdp, DIID)
{
	DllCall(NumGet(NumGet(1*pdp)+ 0), "Uint", pdp, "Uint", COM_GUID4String(IID_IConnectionPointContainer, "{B196B284-BAB4-101A-B69C-00AA00341D07}"), "UintP", pcc)
	DllCall(NumGet(NumGet(1*pcc)+16), "Uint", pcc, "Uint", COM_GUID4String(DIID,DIID), "UintP", pcp)
	DllCall(NumGet(NumGet(1*pcc)+ 8), "Uint", pcc)
	Return	pcp
}

COM_GetConnectionInterface(pcp)
{
	VarSetCapacity(DIID,16,0)
	DllCall(NumGet(NumGet(1*pcp)+12), "Uint", pcp, "Uint", &DIID)
	Return	COM_String4GUID(&DIID)
}

COM_Advise(pcp, psink)
{
	DllCall(NumGet(NumGet(1*pcp)+20), "Uint", pcp, "Uint", psink, "UintP", nCookie)
	Return	nCookie
}

COM_Unadvise(pcp, nCookie)
{
	Return	DllCall(NumGet(NumGet(1*pcp)+24), "Uint", pcp, "Uint", nCookie)
}

COM_Enumerate(penum, ByRef Result, ByRef vt = "")
{
	VarSetCapacity(varResult,16,0)
	If (0 =	hr:=DllCall(NumGet(NumGet(1*penum:=COM_Unwrap(penum))+12), "Uint", penum, "Uint", 1, "Uint", &varResult, "UintP", 0))
	Result:=(vt:=NumGet(varResult,0,"Ushort"))=9||vt=13?COM_Enwrap(NumGet(varResult,8),vt):vt=8||vt<0x1000&&COM_VariantChangeType(&varResult,&varResult)=0?StrGet(NumGet(varResult,8)) . COM_VariantClear(&varResult):NumGet(varResult,8)
	Return	hr
}

COM_Invoke(pdsp,name="",prm0="vT_NoNe",prm1="vT_NoNe",prm2="vT_NoNe",prm3="vT_NoNe",prm4="vT_NoNe",prm5="vT_NoNe",prm6="vT_NoNe",prm7="vT_NoNe",prm8="vT_NoNe",prm9="vT_NoNe")
{
	pdsp :=	COM_Unwrap(pdsp)
	If	name=
	Return	DllCall(NumGet(NumGet(1*pdsp)+8),"Uint",pdsp)
	If	name contains .
	{
		SubStr(name,1,1)!="." ? name.=".":name:=SubStr(name,2) . "."
	Loop,	Parse,	name, .
	{
	If	A_Index=1
	{
		name :=	A_LoopField
		Continue
	}
	Else If	name not contains [,(
		prmn :=	""
	Else If	InStr("])",SubStr(name,0))
	Loop,	Parse,	name, [(,'")]
	If	A_Index=1
		name :=	A_LoopField
	Else	prmn :=	A_LoopField
	Else
	{
		name .=	"." . A_LoopField
		Continue
	}
	If	A_LoopField!=
		pdsp:=	COM_Invoke(pdsp,name,prmn!="" ? prmn:"vT_NoNe"),name:=A_LoopField
	Else	Return	prmn!=""?COM_Invoke(pdsp,name,prmn,prm0,prm1,prm2,prm3,prm4,prm5,prm6,prm7,prm8):COM_Invoke(pdsp,name,prm0,prm1,prm2,prm3,prm4,prm5,prm6,prm7,prm8,prm9)
	}
	}
	Static	varg,namg,iidn,varResult,sParams
	VarSetCapacity(varResult,64,0),sParams?"":(sParams:="0123456789",VarSetCapacity(varg,160,0),VarSetCapacity(namg,88,0),VarSetCapacity(iidn,16,0)),mParams:=0,nParams:=10,nvk:=3
	Loop, 	Parse,	sParams
	If	(prm%A_LoopField%=="vT_NoNe")
	{
	 	nParams:=A_Index-1
		Break
	}
	Else If	prm%A_LoopField% is integer
		NumPut(SubStr(prm%A_LoopField%,1,1)="+"?9:prm%A_LoopField%=="-0"?(prm%A_LoopField%:=0x80020004)*0+10:3,NumPut(prm%A_LoopField%,varg,168-16*A_Index),-12)
	Else If	IsObject(prm%A_LoopField%)
		typ:=prm%A_LoopField%["typ_"],prm:=prm%A_LoopField%["prm_"],typ+0==""?(NumPut(&_nam_%A_LoopField%:=typ,namg,84-4*mParams++),typ:=prm%A_LoopField%["nam_"]+0==""?prm+0==""||InStr(prm,".")?8:3:prm%A_LoopField%["nam_"]):"",NumPut(typ==8?COM_SysString(prm%A_LoopField%,prm):prm,NumPut(typ,varg,160-16*A_Index),4)
	Else	NumPut(COM_SysString(prm%A_LoopField%,prm%A_LoopField%),NumPut(8,varg,160-16*A_Index),4)
	If	nParams
		SubStr(name,0)="="?(name:=SubStr(name,1,-1),nvk:=12,NumPut(-3,namg,4)):"",NumPut(nvk==12?1:mParams,NumPut(nParams,NumPut(&namg+4,NumPut(&varg+160-16*nParams,varResult,16))))
	Global	COM_HR, COM_LR:=""
	If	(COM_HR:=DllCall(NumGet(NumGet(1*pdsp)+20),"Uint",pdsp,"Uint",&iidn,"Uint",NumPut(&name,namg,84-4*mParams)-4,"Uint",1+mParams,"Uint",1024,"Uint",&namg,"Uint"))=0&&(COM_HR:=DllCall(NumGet(NumGet(1*pdsp)+24),"Uint",pdsp,"int",NumGet(namg),"Uint",&iidn,"Uint",1024,"Ushort",nvk,"Uint",&varResult+16,"Uint",&varResult,"Uint",&varResult+32,"Uint",0,"Uint"))!=0&&nParams&&nvk<4&&NumPut(-3,namg,4)&&(COM_LR:=DllCall(NumGet(NumGet(1*pdsp)+24),"Uint",pdsp,"int",NumGet(namg),"Uint",&iidn,"Uint",1024,"Ushort",12,"Uint",NumPut(1,varResult,28)-16,"Uint",0,"Uint",0,"Uint",0,"Uint"))=0
		COM_HR:=0
	Global	COM_VT:=NumGet(varResult,0,"Ushort")
	Return	COM_HR=0?COM_VT>1?COM_VT=9||COM_VT=13?COM_Enwrap(NumGet(varResult,8),COM_VT):COM_VT=8||COM_VT<0x1000&&COM_VariantChangeType(&varResult,&varResult)=0?StrGet(NumGet(varResult,8)) . COM_VariantClear(&varResult):NumGet(varResult,8):"":COM_Error(COM_HR,COM_LR,&varResult+32,name)
}

COM_InvokeSet(pdsp,name,prm0,prm1="vT_NoNe",prm2="vT_NoNe",prm3="vT_NoNe",prm4="vT_NoNe",prm5="vT_NoNe",prm6="vT_NoNe",prm7="vT_NoNe",prm8="vT_NoNe",prm9="vT_NoNe")
{
	Return	COM_Invoke(pdsp,name "=",prm0,prm1,prm2,prm3,prm4,prm5,prm6,prm7,prm8,prm9)
}

COM_DispInterface(this, prm1="", prm2="", prm3="", prm4="", prm5="", prm6="", prm7="", prm8="")
{
	Critical
	If	A_EventInfo = 6
		hr:=DllCall(NumGet(NumGet(0+p:=NumGet(this+8))+28),"Uint",p,"Uint",prm1,"UintP",pname,"Uint",1,"UintP",0),hr==0?(sfn:=StrGet(this+40) . StrGet(pname),COM_SysFreeString(pname),%sfn%(prm5,this,prm6)):""
	Else If	A_EventInfo = 5
		hr:=DllCall(NumGet(NumGet(0+p:=NumGet(this+8))+40),"Uint",p,"Uint",prm2,"Uint",prm3,"Uint",prm5)
	Else If	A_EventInfo = 4
		NumPut(0*hr:=0x80004001,prm3+0)
	Else If	A_EventInfo = 3
		NumPut(0,prm1+0)
	Else If	A_EventInfo = 2
		NumPut(hr:=NumGet(this+4)-1,this+4)
	Else If	A_EventInfo = 1
		NumPut(hr:=NumGet(this+4)+1,this+4)
	Else If	A_EventInfo = 0
		COM_IsEqualGUID(this+24,prm1)||InStr("{00020400-0000-0000-C000-000000000046}{00000000-0000-0000-C000-000000000046}",COM_String4GUID(prm1)) ? NumPut(NumPut(NumGet(this+4)+1,this+4)-8,prm2+0):NumPut(0*hr:=0x80004002,prm2+0)
	Return	hr
}

COM_DispGetParam(pDispParams, Position = 0, vt = 8)
{
	VarSetCapacity(varResult,16,0)
	DllCall("oleaut32\DispGetParam", "Uint", pDispParams, "Uint", Position, "Ushort", vt, "Uint", &varResult, "UintP", nArgErr)
	Return	(vt:=NumGet(varResult,0,"Ushort"))=8?StrGet(NumGet(varResult,8)) . COM_VariantClear(&varResult):vt=9||vt=13?COM_Enwrap(NumGet(varResult,8),vt):NumGet(varResult,8)
}

COM_DispSetParam(val, pDispParams, Position = 0, vt = 8)
{
	Return	NumPut(vt=8?COM_SysAllocString(val):vt=9||vt=13?COM_Unwrap(val):val,NumGet(NumGet(pDispParams+0)+(NumGet(pDispParams+8)-Position)*16-8),0,vt=11||vt=2 ? "short":"int")
}

COM_Error(hr = "", lr = "", pei = "", name = "")
{
	Static	bDebug:=1
	If Not	pei
	{
	bDebug:=hr
	Global	COM_HR, COM_LR
	Return	COM_HR&&COM_LR ? COM_LR<<32|COM_HR:COM_HR
	}
	Else If	!bDebug
	Return
	hr ? (VarSetCapacity(sError,1022),VarSetCapacity(nError,62),DllCall("kernel32\FormatMessage","Uint",0x1200,"Uint",0,"Uint",hr<>0x80020009?hr:(bExcep:=1)*(hr:=NumGet(pei+28))?hr:hr:=NumGet(pei+0,0,"Ushort")+0x80040200,"Uint",0,"str",sError,"Uint",512,"Uint",0),DllCall("kernel32\FormatMessage","Uint",0x2400,"str","0x%1!p!","Uint",0,"Uint",0,"str",nError,"Uint",32,"UintP",hr)):sError:="No COM Dispatch Object!`n",lr?(VarSetCapacity(sError2,1022),VarSetCapacity(nError2,62),DllCall("kernel32\FormatMessage","Uint",0x1200,"Uint",0,"Uint",lr,"Uint",0,"str",sError2,"Uint",512,"Uint",0),DllCall("kernel32\FormatMessage","Uint",0x2400,"str","0x%1!p!","Uint",0,"Uint",0,"str",nError2,"Uint",32,"UintP",lr)):""
	MsgBox, 260, COM Error Notification, % "Function Name:`t""" . name . """`nERROR:`t" . sError . "`t(" . nError . ")" . (bExcep ? SubStr(NumGet(pei+24) ? DllCall(NumGet(pei+24),"Uint",pei) : "",1,0) . "`nPROG:`t" . StrGet(NumGet(pei+4)) . COM_SysFreeString(NumGet(pei+4)) . "`nDESC:`t" . StrGet(NumGet(pei+8)) . COM_SysFreeString(NumGet(pei+8)) . "`nHELP:`t" . StrGet(NumGet(pei+12)) . COM_SysFreeString(NumGet(pei+12)) . "," . NumGet(pei+16) : "") . (lr ? "`n`nERROR2:`t" . sError2 . "`t(" . nError2 . ")" : "") . "`n`nWill Continue?"
	IfMsgBox, No, Exit
}

COM_CreateIDispatch()
{
	Static	IDispatch
	If Not	VarSetCapacity(IDispatch)
	{
		VarSetCapacity(IDispatch,28,0),   nParams=3112469
		Loop,   Parse,   nParams
		NumPut(RegisterCallback("COM_DispInterface","",A_LoopField,A_Index-1),IDispatch,4*(A_Index-1))
	}
	Return &IDispatch
}

COM_GetDefaultInterface(pdisp)
{
	DllCall(NumGet(NumGet(1*pdisp) +12), "Uint", pdisp , "UintP", ctinf)
	If	ctinf
	{
	DllCall(NumGet(NumGet(1*pdisp)+16), "Uint", pdisp, "Uint" , 0, "Uint", 1024, "UintP", ptinf)
	DllCall(NumGet(NumGet(1*ptinf)+12), "Uint", ptinf, "UintP", pattr)
	DllCall(NumGet(NumGet(1*pdisp)+ 0), "Uint", pdisp, "Uint" , pattr, "UintP", ppv)
	DllCall(NumGet(NumGet(1*ptinf)+76), "Uint", ptinf, "Uint" , pattr)
	DllCall(NumGet(NumGet(1*ptinf)+ 8), "Uint", ptinf)
	If	ppv
	DllCall(NumGet(NumGet(1*pdisp)+ 8), "Uint", pdisp),	pdisp := ppv
	}
	Return	pdisp
}

COM_GetDefaultEvents(pdisp)
{
	DllCall(NumGet(NumGet(1*pdisp)+16), "Uint", pdisp, "Uint" , 0, "Uint", 1024, "UintP", ptinf)
	DllCall(NumGet(NumGet(1*ptinf)+12), "Uint", ptinf, "UintP", pattr)
	VarSetCapacity(IID,16),DllCall("kernel32\RtlMoveMemory","Uint",&IID,"Uint",pattr,"Uint",16)
	DllCall(NumGet(NumGet(1*ptinf)+76), "Uint", ptinf, "Uint" , pattr)
	DllCall(NumGet(NumGet(1*ptinf)+72), "Uint", ptinf, "UintP", ptlib, "UintP", idx)
	DllCall(NumGet(NumGet(1*ptinf)+ 8), "Uint", ptinf)
	Loop, %	DllCall(NumGet(NumGet(1*ptlib)+12), "Uint", ptlib)
	{
		DllCall(NumGet(NumGet(1*ptlib)+20), "Uint", ptlib, "Uint", A_Index-1, "UintP", TKind)
		If	TKind <> 5
			Continue
		DllCall(NumGet(NumGet(1*ptlib)+16), "Uint", ptlib, "Uint", A_Index-1, "UintP", ptinf)
		DllCall(NumGet(NumGet(1*ptinf)+12), "Uint", ptinf, "UintP", pattr)
		nCount:=NumGet(pattr+48,0,"Ushort")
		DllCall(NumGet(NumGet(1*ptinf)+76), "Uint", ptinf, "Uint" , pattr)
		Loop, %	nCount
		{
			DllCall(NumGet(NumGet(1*ptinf)+36), "Uint", ptinf, "Uint", A_Index-1, "UintP", nFlags)
			If	!(nFlags & 1)
				Continue
			DllCall(NumGet(NumGet(1*ptinf)+32), "Uint", ptinf, "Uint", A_Index-1, "UintP", hRefType)
			DllCall(NumGet(NumGet(1*ptinf)+56), "Uint", ptinf, "Uint", hRefType , "UintP", prinf)
			DllCall(NumGet(NumGet(1*prinf)+12), "Uint", prinf, "UintP", pattr)
			nFlags & 2 ? DIID:=COM_String4GUID(pattr) : bFind:=COM_IsEqualGUID(pattr,&IID)
			DllCall(NumGet(NumGet(1*prinf)+76), "Uint", prinf, "Uint" , pattr)
			DllCall(NumGet(NumGet(1*prinf)+ 8), "Uint", prinf)
		}
		DllCall(NumGet(NumGet(1*ptinf)+ 8), "Uint", ptinf)
		If	bFind
			Break
	}
	DllCall(NumGet(NumGet(1*ptlib)+ 8), "Uint", ptlib)
	Return	bFind ? DIID : "{00000000-0000-0000-0000-000000000000}"
}

COM_GetGuidOfName(pdisp, Name)
{
	DllCall(NumGet(NumGet(1*pdisp)+16), "Uint", pdisp, "Uint", 0, "Uint", 1024, "UintP", ptinf)
	DllCall(NumGet(NumGet(1*ptinf)+72), "Uint", ptinf, "UintP", ptlib, "UintP", idx)
	DllCall(NumGet(NumGet(1*ptinf)+ 8), "Uint", ptinf), ptinf:=0
	DllCall(NumGet(NumGet(1*ptlib)+44), "Uint", ptlib, "Uint", &Name, "Uint", 0, "UintP", ptinf, "UintP", memID, "UshortP", 1)
	DllCall(NumGet(NumGet(1*ptlib)+ 8), "Uint", ptlib)
	DllCall(NumGet(NumGet(1*ptinf)+12), "Uint", ptinf, "UintP", pattr)
	GUID := COM_String4GUID(pattr)
	DllCall(NumGet(NumGet(1*ptinf)+76), "Uint", ptinf, "Uint" , pattr)
	DllCall(NumGet(NumGet(1*ptinf)+ 8), "Uint", ptinf)
	Return	GUID
}

COM_GetTypeInfoOfGuid(pdisp, GUID)
{
	DllCall(NumGet(NumGet(1*pdisp)+16), "Uint", pdisp, "Uint", 0, "Uint", 1024, "UintP", ptinf)
	DllCall(NumGet(NumGet(1*ptinf)+72), "Uint", ptinf, "UintP", ptlib, "UintP", idx)
	DllCall(NumGet(NumGet(1*ptinf)+ 8), "Uint", ptinf), ptinf := 0
	DllCall(NumGet(NumGet(1*ptlib)+24), "Uint", ptlib, "Uint", COM_GUID4String(GUID,GUID), "UintP", ptinf)
	DllCall(NumGet(NumGet(1*ptlib)+ 8), "Uint", ptlib)
	Return	ptinf
}

COM_ConnectObject(pdisp, prefix = "", DIID = "")
{
	pdisp:=	COM_Unwrap(pdisp)
	If Not	DIID
		0+(pconn:=COM_FindConnectionPoint(pdisp,"{00020400-0000-0000-C000-000000000046}")) ? (DIID:=COM_GetConnectionInterface(pconn))="{00020400-0000-0000-C000-000000000046}" ? DIID:=COM_GetDefaultEvents(pdisp):"":pconn:=COM_FindConnectionPoint(pdisp,DIID:=COM_GetDefaultEvents(pdisp))
	Else	pconn:=COM_FindConnectionPoint(pdisp,SubStr(DIID,1,1)="{" ? DIID:DIID:=COM_GetGuidOfName(pdisp,DIID))
	If	!pconn||!ptinf:=COM_GetTypeInfoOfGuid(pdisp,DIID)
	{
		MsgBox, No Event Interface Exists!
		Return
	}
	NumPut(pdisp,NumPut(ptinf,NumPut(1,NumPut(COM_CreateIDispatch(),0+psink:=COM_CoTaskMemAlloc(40+nSize:=StrLen(prefix)*2+2)))))
	DllCall("kernel32\RtlMoveMemory","Uint",psink+24,"Uint",COM_GUID4String(DIID,DIID),"Uint",16)
	DllCall("kernel32\RtlMoveMemory","Uint",psink+40,"Uint",&prefix,"Uint",nSize)
	NumPut(COM_Advise(pconn,psink),NumPut(pconn,psink+16))
	Return	psink
}

COM_DisconnectObject(psink)
{
	Return	COM_Unadvise(NumGet(psink+16),NumGet(psink+20))=0 ? (0,COM_Release(NumGet(psink+16)),COM_Release(NumGet(psink+8)),COM_CoTaskMemFree(psink)):1
}

COM_CreateObject(CLSID, IID = "", CLSCTX = 21)
{
	ppv :=	COM_CreateInstance(CLSID,IID,CLSCTX)
	Return	IID=="" ? COM_Enwrap(ppv):ppv
}

COM_GetObject(Name)
{
	COM_Init()
	If	DllCall("ole32\CoGetObject", "Uint", &Name, "Uint", 0, "Uint", COM_GUID4String(IID_IDispatch,"{00020400-0000-0000-C000-000000000046}"), "UintP", pdisp)=0
	Return	COM_Enwrap(pdisp)
}

COM_GetActiveObject(CLSID)
{
	COM_Init()
	If	DllCall("oleaut32\GetActiveObject", "Uint", COM_GUID4String(CLSID,CLSID), "Uint", 0, "UintP", punk)=0
	&&	DllCall(NumGet(NumGet(1*punk)), "Uint", punk, "Uint", COM_GUID4String(IID_IDispatch,"{00020400-0000-0000-C000-000000000046}"), "UintP", pdisp)+DllCall(NumGet(NumGet(1*punk)+8), "Uint", punk)*0=0
	Return	COM_Enwrap(pdisp)
}

COM_CreateInstance(CLSID, IID = "", CLSCTX = 21)
{
	COM_Init()
	If	DllCall("ole32\CoCreateInstance", "Uint", COM_GUID4String(CLSID,CLSID), "Uint", 0, "Uint", CLSCTX, "Uint", COM_GUID4String(IID,IID ? IID:IID=0 ? "{00000000-0000-0000-C000-000000000046}":"{00020400-0000-0000-C000-000000000046}"), "UintP", ppv)=0
	Return	ppv
}

COM_CLSID4ProgID(ByRef CLSID, ProgID)
{
	VarSetCapacity(CLSID,16,0)
	DllCall("ole32\CLSIDFromProgID", "Uint", &ProgID, "Uint", &CLSID)
	Return	&CLSID
}

COM_ProgID4CLSID(pCLSID)
{
	DllCall("ole32\ProgIDFromCLSID", "Uint", pCLSID, "UintP", pProgID)
	Return	StrGet(pProgID) . COM_CoTaskMemFree(pProgID)
}

COM_GUID4String(ByRef CLSID, String)
{
	VarSetCapacity(CLSID,16,0)
	DllCall("ole32\CLSIDFromString", "Uint", &String, "Uint", &CLSID)
	Return	&CLSID
}

COM_String4GUID(pGUID)
{
	VarSetCapacity(String,38*2)
	DllCall("ole32\StringFromGUID2", "Uint", pGUID, "str", String, "int", 39)
	Return	String
}

COM_IsEqualGUID(pGUID1, pGUID2)
{
	Return	DllCall("ole32\IsEqualGUID", "Uint", pGUID1, "Uint", pGUID2)
}

COM_CoCreateGuid()
{
	VarSetCapacity(GUID,16,0)
	DllCall("ole32\CoCreateGuid", "Uint", &GUID)
	Return	COM_String4GUID(&GUID)
}

COM_CoInitialize()
{
	Return	DllCall("ole32\CoInitialize", "Uint", 0)
}

COM_CoUninitialize()
{
		DllCall("ole32\CoUninitialize")
}

COM_CoTaskMemAlloc(cb)
{
	Return	DllCall("ole32\CoTaskMemAlloc", "Uint", cb)
}

COM_CoTaskMemFree(pv)
{
		DllCall("ole32\CoTaskMemFree", "Uint", pv)
}

COM_SysAllocString(str)
{
	Return	DllCall("oleaut32\SysAllocString", "Uint", &str)
}

COM_SysFreeString(pstr)
{
		DllCall("oleaut32\SysFreeString", "Uint", pstr)
}

COM_SafeArrayDestroy(psar)
{
	Return	DllCall("oleaut32\SafeArrayDestroy", "Uint", psar)
}

COM_VariantClear(pvar)
{
		DllCall("oleaut32\VariantClear", "Uint", pvar)
}

COM_VariantChangeType(pvarDst, pvarSrc, vt = 8)
{
	Return	DllCall("oleaut32\VariantChangeTypeEx", "Uint", pvarDst, "Uint", pvarSrc, "Uint", 1024, "Ushort", 0, "Ushort", vt)
}

COM_SysString(ByRef wString, sString)
{
	VarSetCapacity(wString,4+nLen:=2*StrLen(sString))
	Return	DllCall("kernel32\lstrcpyW","Uint",NumPut(nLen,wString),"Uint",&sString)
}

COM_AccInit()
{
	Static	h
	If Not	h
	COM_Init(), h:=DllCall("kernel32\LoadLibrary","str","oleacc")
}

COM_AccTerm()
{
	COM_Term()
}

COM_AccessibleChildren(pacc, cChildren, ByRef varChildren)
{
	VarSetCapacity(varChildren,cChildren*16,0)
	If	DllCall("oleacc\AccessibleChildren", "Uint", COM_Unwrap(pacc), "Uint", 0, "Uint", cChildren+0, "Uint", &varChildren, "UintP", cChildren:=0)=0
	Return	cChildren
}

COM_AccessibleObjectFromEvent(hWnd, idObject, idChild, ByRef _idChild_="")
{
	COM_AccInit(), VarSetCapacity(varChild,16,0)
	If	DllCall("oleacc\AccessibleObjectFromEvent", "Uint", hWnd, "Uint", idObject, "Uint", idChild, "UintP", pacc, "Uint", &varChild)=0
	Return	COM_Enwrap(pacc), _idChild_:=NumGet(varChild,8)
}

COM_AccessibleObjectFromPoint(x, y, ByRef _idChild_="")
{
	COM_AccInit(), VarSetCapacity(varChild,16,0)
	If	DllCall("oleacc\AccessibleObjectFromPoint", "int", x, "int", y, "UintP", pacc, "Uint", &varChild)=0
	Return	COM_Enwrap(pacc), _idChild_:=NumGet(varChild,8)
}

COM_AccessibleObjectFromWindow(hWnd, idObject=-4, IID = "")
{
	COM_AccInit()
	If	DllCall("oleacc\AccessibleObjectFromWindow", "Uint", hWnd, "Uint", idObject, "Uint", COM_GUID4String(IID, IID ? IID : idObject&0xFFFFFFFF==0xFFFFFFF0 ? "{00020400-0000-0000-C000-000000000046}":"{618736E0-3C3D-11CF-810C-00AA00389B71}"), "UintP", pacc)=0
	Return	COM_Enwrap(pacc)
}

COM_WindowFromAccessibleObject(pacc)
{
	If	DllCall("oleacc\WindowFromAccessibleObject", "Uint", COM_Unwrap(pacc), "UintP", hWnd)=0
	Return	hWnd
}

COM_GetRoleText(nRole)
{
	nLen:=	DllCall("oleacc\GetRoleTextW", "Uint", nRole, "Uint", 0, "Uint", 0)
	VarSetCapacity(sRole,nLen*2)
	If	DllCall("oleacc\GetRoleTextW", "Uint", nRole, "str", sRole, "Uint", nLen+1)
	Return	sRole
}

COM_GetStateText(nState)
{
	nLen:=	DllCall("oleacc\GetStateTextW", "Uint", nState, "Uint", 0, "Uint", 0)
	VarSetCapacity(sState,nLen*2)
	If	DllCall("oleacc\GetStateTextW", "Uint", nState, "str", sState, "Uint", nLen+1)
	Return	sState
}

COM_AtlAxWinInit(Version = "")
{
	Static	h
	If Not	h
	COM_Init(), h:=DllCall("kernel32\LoadLibrary","str","atl" . Version), DllCall("atl" . Version . "\AtlAxWinInit")
}

COM_AtlAxWinTerm(Version = "")
{
	COM_Term()
}

COM_AtlAxGetHost(hWnd, Version = "")
{
	If	DllCall("atl" . Version . "\AtlAxGetHost", "Uint", hWnd, "UintP", punk)=0
	Return	COM_Enwrap(COM_QueryInterface(punk)+COM_Release(punk)*0)
}

COM_AtlAxGetControl(hWnd, Version = "")
{
	If	DllCall("atl" . Version . "\AtlAxGetControl", "Uint", hWnd, "UintP", punk)=0
	Return	COM_Enwrap(COM_QueryInterface(punk)+COM_Release(punk)*0)
}

COM_AtlAxAttachControl(pdsp, hWnd, Version = "")
{
	If	DllCall("atl" . Version . "\AtlAxAttachControl", "Uint", punk:=COM_QueryInterface(pdsp,0), "Uint", hWnd, "Uint", COM_AtlAxWinInit(Version))+COM_Release(punk)*0=0
	Return	COM_Enwrap(pdsp)
}

COM_AtlAxCreateControl(hWnd, Name, Version = "")
{
	If	DllCall("atl" . Version . "\AtlAxCreateControl", "Uint", &Name, "Uint", hWnd, "Uint", 0, "Uint", COM_AtlAxWinInit(Version))=0
	Return	COM_AtlAxGetControl(hWnd,Version)
}

COM_AtlAxCreateContainer(hWnd, l, t, w, h, Name = "", Version = "")
{
	Return	DllCall("user32\CreateWindowEx", "Uint",0x200, "str", "AtlAxWin" . Version, "Uint", Name?&Name:0, "Uint", 0x54000000, "int", l, "int", t, "int", w, "int", h, "Uint", hWnd, "Uint", 0, "Uint", 0, "Uint", COM_AtlAxWinInit(Version))
}

COM_AtlAxGetContainer(pdsp, bCtrl = "")
{
	DllCall(NumGet(NumGet(1*pdsp:=COM_Unwrap(pdsp))), "Uint", pdsp, "Uint", COM_GUID4String(IID_IOleWindow,"{00000114-0000-0000-C000-000000000046}"), "UintP", pwin)
	DllCall(NumGet(NumGet(1*pwin)+12), "Uint", pwin, "UintP", hCtrl)
	DllCall(NumGet(NumGet(1*pwin)+ 8), "Uint", pwin)
	Return	bCtrl?hCtrl:DllCall("user32\GetParent", "Uint", hCtrl)
}

COM_ScriptControl(sCode, sEval = "", sName = "", Obj = "", bGlobal = "")
{
	oSC:=COM_CreateObject("ScriptControl"), oSC.Language(sEval+0==""?"VBScript":"JScript"), sName&&Obj?oSC.AddObject(sName,Obj,bGlobal):""
	Return	sEval?oSC.Eval(sEval+0?sCode:sEval oSC.AddCode(sCode)):oSC.ExecuteStatement(sCode)
}

COM_Parameter(typ, prm = "", nam = "")
{
	Return	IsObject(prm)?prm:Object("typ_",typ,"prm_",prm,"nam_",nam)
}

COM_Enwrap(obj, vt = 9)
{
	Static	base
	Return	IsObject(obj)?obj:Object("prm_",obj,"typ_",vt,"base",base?base:base:=Object("__Delete","COM_Invoke","__Call","COM_Invoke","__Get","COM_Invoke","__Set","COM_InvokeSet","base",Object("__Delete","COM_Term")))
}

COM_Unwrap(obj)
{
	Return	IsObject(obj)?obj.prm_:obj
}
