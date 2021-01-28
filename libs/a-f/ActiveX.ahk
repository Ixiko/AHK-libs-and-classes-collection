/*
COM‘€ìƒ‰ƒCƒuƒ‰ƒŠ	by —¬s‚ç‚¹‚éƒy[ƒWŠÇ—l
 Ver 3ƒÀ
*/

ActiveX(){
	global
	IID_IDispatch:=GUID("{00020400-0000-0000-C000-000000000046}")
	IID_IUnknown:=GUID("{00000000-0000-0000-C000-000000000046}")
	IID_NULL:=GUID("{00000000-0000-0000-0000-000000000000}")
	IID_IConnectionPointContainer:=GUID("{B196B284-BAB4-101A-B69C-00AA00341D07}")
	IID_IProvideClassInfo:=GUID("{B196B283-BAB4-101A-B69C-00AA00341D07}")
	;IID_IProvideClassInfo2:=GUID("{A6BC3AC0-DBAA-11CE-9DE3-00AA004BB851}")
	LOCALE_USER_DEFAULT:=DllCall("kernel32.dll\GetUserDefaultLCID")
	CoInitialize()
}



/*
	**********************************
	”Ä—pƒƒ‚ƒŠŠÇ—
	**********************************
*/

;ƒƒ‚ƒŠ‚ðŠm•Û‚µƒ|ƒCƒ“ƒ^‚ð•Ô‚·
Malloc(size,flag=0x40){
	return DllCall("kernel32.dll\GlobalAlloc","UInt",flag,"UInt",size,"UInt")
}
;ƒ|ƒCƒ“ƒ^‚ÅŽw’è‚³‚ê‚½ƒƒ‚ƒŠ‚ð‰ð•ú‚·‚é
Free(p){
	DllCall("kernel32.dll\GlobalFree",UInt,p,UInt)
}


/*
	**********************************
	GUIDŠÖ˜A
	**********************************
*/

;CLSID•¶Žš—ñ‚©‚çGUID\‘¢‘Ì‚ð¶¬‚µƒAƒhƒŒƒX‚ð“¾‚é(‰¼)
GUID(string){
	size:=DllCall("kernel32.dll\MultiByteToWideChar","UInt",0,"UInt",0,"Str",string,"Int",-1,"UInt",0,"Int",0)
	wstr:=Malloc((size+1)*2)
	DllCall("kernel32.dll\MultiByteToWideChar","UInt",0,"UInt",0,"Str",string,"Int",-1,"UInt",wstr,"Int",(size+1)*2)
	ptr:=Malloc(16)
	DllCall("ole32.dll\CLSIDFromString","UInt",wstr,"UInt",ptr)
	Free(wstr)
	return ptr
}
;ProgID•¶Žš—ñ‚©‚çGUID\‘¢‘Ì‚ð¶¬‚µƒAƒhƒŒƒX‚ð“¾‚é(‰¼)
ProgID(string){
	size:=DllCall("kernel32.dll\MultiByteToWideChar","UInt",0,"UInt",0,"Str",string,"Int",-1,"UInt",0,"Int",0)
	wstr:=Malloc((size+1)*2)
	DllCall("kernel32.dll\MultiByteToWideChar","UInt",0,"UInt",0,"Str",string,"Int",-1,"UInt",wstr,"Int",(size+1)*2)
	ptr:=Malloc(16)
	DllCall("ole32.dll\CLSIDFromProgID","UInt",wstr,"UInt",ptr)
	Free(wstr)
	return ptr
}

;GUID\‘¢‘Ì‚ð•¶Žš—ñ‚É•ÏŠ·
fromGUID(ByRef guid){
	ptr:=Malloc(80)
	DllCall("ole32.dll\StringFromGUID2","UInt",guid,"UInt",ptr,"Int",80)
	res:=wc2mb(ptr)
	Free(ptr)
	return res
}

/*
	**********************************
	UnicodeŠÖ˜A
	**********************************
*/

;•¶Žš—ñ‚©‚ç‚ÉUnicode‚Ö‚Ì•ÏŠ·‚ðs‚¤
;•Ô‚è’l‚ÍUnicode•¶Žš—ñ‚Ö‚Ìƒ|ƒCƒ“ƒ^
mb2wc(mbstr){
	size:=(DllCall("kernel32.dll\MultiByteToWideChar","UInt",0,"UInt",0,"Str",mbstr,"Int",-1,"UInt",0,"Int",0)+1)*2
	wstr:=Malloc(size)
	DllCall("kernel32.dll\MultiByteToWideChar","UInt",0,"UInt",0,"Str",mbstr,"Int",-1,"UInt",wstr,"Int",size)
	return wstr
}
mb2wc_ref(ByRef mbstr){
	size:=(DllCall("kernel32.dll\MultiByteToWideChar","UInt",0,"UInt",0,"Str",mbstr,"Int",-1,"UInt",0,"Int",0)+1)*2
	wstr:=Malloc(size)
	DllCall("kernel32.dll\MultiByteToWideChar","UInt",0,"UInt",0,"Str",mbstr,"Int",-1,"UInt",wstr,"Int",size)
	return wstr
}
;Unicode‚©‚çAnsi•¶Žš—ñ‚Ö‚Ì•ÏŠ·‚ðs‚¤
;•Ô‚è’l‚Í•¶Žš—ñ
wc2mb(wstr){
	size:=DllCall("kernel32.dll\WideCharToMultiByte","UInt",0,"UInt",0,"UInt",wstr,"Int",-1,"UInt",0,"Int",0,"UInt",0,"UInt",0)
	VarSetCapacity(mbstr,size)
	DllCall("kernel32.dll\WideCharToMultiByte","UInt",0,"UInt",0,"UInt",wstr,"Int",-1,"Str",mbstr,"Int",size,"UInt",0,"UInt",0)
	return mbstr
}

wc2mb_ref(wstr,ByRef mbstr){
	size:=DllCall("kernel32.dll\WideCharToMultiByte","UInt",0,"UInt",0,"UInt",wstr,"Int",-1,"UInt",0,"Int",0,"UInt",0,"UInt",0)
	VarSetCapacity(mbstr,size)
	DllCall("kernel32.dll\WideCharToMultiByte","UInt",0,"UInt",0,"UInt",wstr,"Int",-1,"Str",mbstr,"Int",size,"UInt",0,"UInt",0)
	return size
}


/*
	**********************************
	COM”Ä—p
	**********************************
*/

CoInitialize(){
	return DllCall("ole32.dll\CoInitialize","UInt",0,"UInt")
}
CoUninitialize(){
	return DllCall("ole32.dll\CoUninitialize","UInt",0,"UInt")
}
OleInitialize(){
	return DllCall("ole32.dll\OleInitialize","UInt",0,"UInt")
}
OleUninitialize(){
	return DllCall("ole32.dll\OleUninitialize","UInt",0,"UInt")
}
CoTaskMemAlloc(size){
 	return DllCall("ole32.dll\CoTaskMemAlloc","UInt",size,"UInt")
}
CoTaskMemFree(ptr){
 	return DllCall("ole32.dll\CoTaskMemFree","UInt",ptr,"UInt")
}
M(ByRef ip,idx=0){
	return NumGet(NumGet(ip+0)+4*idx)
}
QueryInterface(pObj,strIID=""){
	global IID_IDispatch
	guid:=0
	if(strIID=""){
		IID:=IID_IDispatch
	}else if(StrLen(strIID)=38){
		IID:=GUID(strIID)
	}else{
		IID:=strIID
	}
	res:=0
	ErrorLevel:=DllCall(M(pObj,0),"UInt",pObj,"UInt",IID,"UIntP",res)
	return res
}
AddRef(pObj){
	if(pObj){
		DllCall(M(pObj,1),"UInt",pObj)
	}
	return pObj
}
Release(pObj){
	if(pObj){
		return DllCall(M(pObj,2),"UInt",pObj)
	}
}
ReleaseL(p1,p2=-1,p3=-1,p4=-1,p5=-1,p6=-1,p7=-1,p8=-1,p9=-1){
	format:=A_FormatInteger
	SetFormat,Integer,D
	Loop,10{
		if(p%A_Index%!=-1){
			Release(p%A_Index%)
		}
	}
	SetFormat,Integer,%format%
}

/*
	**********************************
	VARIANTŠÖ˜A
	**********************************
*/

;Ansi•¶Žš—ñ‚ðBSTRŒ`Ž®‚É•ÏŠ·‚·‚é
toBSTR(str){
	oc:=mb2wc(str)
	res:=DllCall("oleaut32.dll\SysAllocString","UInt",oc,"UInt")
	Free(oc)
	return res
}
;BSTR‚ðAnsi•¶Žš—ñ‚É•ÏŠ·‚·‚é
fromBSTR(bstr){
	return wc2mb(bstr)
}

;BSTR‚ð‰ð•ú‚·‚é(VariantClear“à‚Å‚â‚Á‚Ä‚­‚ê‚é‚Í‚¸‚È‚Ì‚Å‘½•ª•s—v)
freeBSTR(bstr,get=0){
	if(get!=0){
		wc2mb_ref(bstr,res)
	}else{
		res=
	}
	DllCall("oleaut32.dll\SysFreeString","UInt",bstr)
	return res
}

vNull(){
	return 0x7FFFFFFF00000000
}
vObj(obj){
	return 0x7FFFFFFF00000000 | obj
}
;VARIANT‚É•ÏŠ·(type‚É‚Í•ÏŠ·‚µ‚½‚¢Œ^‚ðŽw’è
;settype‚ðŽw’è‚·‚é‚ÆAŒ^•ÏŠ·‚µ‚½ã‚ÅAŒ^‚ðŽ¦‚·’l‚Æ‚µ‚Äsettype‚ÅŽw’è‚µ‚½Œ^‚ðŠi”[‚·‚é
toVariant(value,variant=0,type=0x08,settype=-1){
	global LOCALE_USER_DEFAULT
	;Ši”[æ‰Šú‰»
	if(variant=0){
		dest:=Malloc(16)
	}else{
		dest:=variant
	}
	DllCall("oleaut32.dll\VariantInit","UInt",dest)
	if(type=0x08){
		if(value >> 32 = 0x7FFFFFFF){
			if(value-0x7FFFFFFF00000000=0){
				;VT_NULL
				NumPut(0x01,dest+0,0,"UShort")
			}else{
				;VT_DISPATCH
				NumPut(0x09,dest+0,0,"UShort")
				NumPut(value - 0x7FFFFFFF00000000,dest+8,0)
			}
		}else{
			;•¶Žš—ñ‚Ìê‡
			NumPut(0x08,dest+0,0,"UShort")
			NumPut(toBSTR(value),dest+8,0)
		}
	}else{
		;‚»‚êˆÈŠO‚ÌŒ^‚Ìê‡
		tmp:=toVariant(value)
		DllCall("oleaut32.dll\VariantChangeTypeEx","UInt",dest,"UInt",tmp,"UInt",LOCALE_USER_DEFAULT,"UShort",0,"UShort",type)
		if(settype!=-1){
			NumPut(settype,dest+0,0,"UShort")
		}
		vFree(tmp)
	}
	return dest
}

;VARIANT‚ÉŠi”[‚³‚ê‚½“à—e‚ð’Êí‚ÌAutoHotkey•Ï”‚Æ‚µ‚ÄŽæ“¾
;rawsize‚ª1,2,4‚Ìê‡AŠi”[‚³‚ê‚Ä‚¢‚é¶‚Ì’l‚ðŽæ“¾
;rawsize‚ª0‚Ìê‡A•¶Žš—ñ‚É•ÏŠ·‚µ‚ÄŽæ“¾
fromVariant(var,rawsize=0){
	global LOCALE_USER_DEFAULT
	if(rawsize=0){
		type:=NumGet(var+0,0,"UShort")
		if((type=9)||(type=13)){
			;COMƒIƒuƒWƒFƒNƒg
			pObj:=NumGet(var+8)
			AddRef(pObj)
			return pObj
		}else if(type>0xFF){
			;ƒ|ƒCƒ“ƒ^‚à‚µ‚­‚Í”z—ñ		(Žb’è)
			return NumGet(var+8)
		}else{
			;VT_BSTR‚É•ÏŠ·
			var2:=Malloc(16)
			DllCall("oleaut32.dll\VariantInit","UInt",var2)
			DllCall("oleaut32.dll\VariantChangeTypeEx","UInt",var2,"UInt",var,"UInt",LOCALE_USER_DEFAULT,"UShort",0,"UShort",0x8)
			;’l‚ðAnsi‚É•ÏŠ·
			wc2mb_ref(NumGet(var2+8),res)
			vFree(var2)
			return res
		}
	}else if(rawsize=1){
		return NumGet(var+8,0,"UChar")
	}else if(rawsize=2){
		return NumGet(var+8,0,"UShort")
	}else if(rawsize=4){
		return NumGet(var+8)
	}else{
		return fromVariant(var,0)
	}
}

;VARIANT‚ð‰ð•ú(get‚É-1ˆÈŠO‚ðŽw’è‚·‚é‚ÆA’l‚ðŽæ“¾‚µ‚Ä•Ô‚·)
vFree(ByRef var,get=-1){
	if(get!=-1){
		res:=fromVariant(var,get)
	}else{
		res:=0
	}
	DllCall("oleaut32.dll\VariantClear","UInt",var)
	Free(var)
	return res
}


/*
	**********************************
	IDispatch—p
	**********************************
*/
;ƒIƒuƒWƒFƒNƒg‚ð¶¬‚·‚é
CreateObject(clsid,iid="",CLSCTX=5){	;CLSCTX_SERVER
	global IID_IDispatch
	if(!IID_IDispatch){
		ActiveX()
	}
	guid:=0
	if(RegExMatch(clsid,"^\{[\-0-9a-fA-F]{36}\}$")){
		guid:=GUID(clsid)
	}else{
		guid:=ProgID(clsid)
	}
	if(iid=""){
		iid2:=IID_IDispatch
	}else{
		iid2:=GUID(iid)
	}
	ppRes:=0
	el:=DllCall("ole32.dll\CoCreateInstance","UInt",guid,"UInt",0,"UInt",CLSCTX,"UInt",iid2,"UIntP",ppRes,"UInt")
	Free(guid)
	if(iid2!=IID_IDispatch){
		Free(iid2)
	}
	ErrorLevel:=el
	return ppRes
}


;obj‚ªŽ‚Ânameƒƒ“ƒo‚ÌDispatchID‚ð“¾‚é
GetDispID(ByRef obj,name){
	global IID_NULL,LOCALE_USER_DEFAULT
	wName:=mb2wc_ref(name)
	dispid:=0
	DllCall(M(obj,5),"UInt",obj,"UInt",IID_NULL,"UIntP",wName,"UInt",1,"UInt",LOCALE_USER_DEFAULT,"UIntP",dispid,"UInt")
	Free(wName)
	return dispid
}
;ˆø”‚©‚çDISPPARAMS‚ð¶¬
CreateParam(ByRef p1, ByRef p2, ByRef p3, ByRef p4, ByRef p5, ByRef p6, ByRef p7, ByRef p8, ByRef p9, ByRef p10){
	;ˆø”‚ð”‚¦‚é(0xFFFFFFFFFFFFFFFF‚Ì‘O‚Ü‚Å‚ª—^‚¦‚ç‚ê‚½ˆø”)
	num:=0
	format:=A_FormatInteger
	SetFormat,Integer,D
	Loop,10{
		if(p%A_Index%=0xFFFFFFFFFFFFFFFF){
			break
		}
		num++
	}
	;numŒÂ‚ÌVARIANTARG”z—ñ‚ðì¬
	if(num=0){
		pvArgs:=0
	}else{
		pvArgs:=Malloc(16*num)
		ptr:=pvArgs+16*(num-1)
		;ˆø”‚ðƒZƒbƒg‚µ‚Ä‚¢‚­
		Loop,%num%{
			toVariant(p%A_Index%,ptr)
			ptr-=16
		}
	}
	SetFormat,Integer,%format%

	;DISPPARAMSì¬
	res:=Malloc(16)
	NumPut(pvArgs,	res+0)
	NumPut(num,		res+8)
	return res
}
;DISPPARAMS‚ð‰ð•ú
FreeParam(ByRef params){
	num:=NumGet(params+8)
	pvArgs:=NumGet(params+0)
	pvNArgs:=NumGet(params+4)
	;VARIANTARG‚Ì‰ð•úˆ—
	ptr:=pvArgs
	Loop,%num%{
		vFree(ptr)
		ptr+=16
	}
	;VARIANTARGŽ©‘Ì‚Ì‰ð•ú
	Free(ptr)
	;rgdispidNamedArgs‚Ì‰ð•ú
	if(pvNArgs!=0){
		Free(pvNArgs)
	}
	;–{‘Ìƒƒ‚ƒŠ‰ð•ú
	Free(params)
}
Invoke(ByRef pObj,ByRef dispid,mode,ByRef params){
	global IID_NULL,LOCALE_USER_DEFAULT
	pvRes:=Malloc(16)
	DllCall("oleaut32.dll\VariantInit",UInt,pvRes)
	DllCall(M(pObj,6),UInt,pObj,UInt,dispid,UInt,IID_NULL,UInt,LOCALE_USER_DEFAULT,UInt,mode,UInt,params,UInt,pvRes,UInt,0,UInt,0,UInt)
	return pvRes
}
inv(obj,name,p1=0xFFFFFFFFFFFFFFFF,p2=0xFFFFFFFFFFFFFFFF,p3=0xFFFFFFFFFFFFFFFF,p4=0xFFFFFFFFFFFFFFFF,p5=0xFFFFFFFFFFFFFFFF,
p6=0xFFFFFFFFFFFFFFFF,p7=0xFFFFFFFFFFFFFFFF,p8=0xFFFFFFFFFFFFFFFF,p9=0xFFFFFFFFFFFFFFFF,p10=0xFFFFFFFFFFFFFFFF){
	if((dispid:=GetDispID(obj,name))!=0){
		params:=CreateParam(p1,p2,p3,p4,p5,p6,p7,p8,p9,p10)
		pvRes:=Invoke(obj,dispid,1,params)
		FreeParam(params)
		return vFree(pvRes,0)
	}
}
gp(obj,name,p1=0xFFFFFFFFFFFFFFFF,p2=0xFFFFFFFFFFFFFFFF,p3=0xFFFFFFFFFFFFFFFF,p4=0xFFFFFFFFFFFFFFFF,p5=0xFFFFFFFFFFFFFFFF,
p6=0xFFFFFFFFFFFFFFFF,p7=0xFFFFFFFFFFFFFFFF,p8=0xFFFFFFFFFFFFFFFF,p9=0xFFFFFFFFFFFFFFFF,p10=0xFFFFFFFFFFFFFFFF){
	if((dispid:=GetDispID(obj,name))!=0){
		params:=CreateParam(p1,p2,p3,p4,p5,p6,p7,p8,p9,p10)
		pvRes:=Invoke(obj,dispid,2,params)
		FreeParam(params)
		return vFree(pvRes,0)
	}
}
pp(obj,name,p1=0xFFFFFFFFFFFFFFFF,p2=0xFFFFFFFFFFFFFFFF,p3=0xFFFFFFFFFFFFFFFF,p4=0xFFFFFFFFFFFFFFFF,p5=0xFFFFFFFFFFFFFFFF,
p6=0xFFFFFFFFFFFFFFFF,p7=0xFFFFFFFFFFFFFFFF,p8=0xFFFFFFFFFFFFFFFF,p9=0xFFFFFFFFFFFFFFFF,p10=0xFFFFFFFFFFFFFFFF){
	if((dispid:=GetDispID(obj,name))!=0){
		params:=CreateParam(p1,p2,p3,p4,p5,p6,p7,p8,p9,p10)
		;rgdispidNamedArgs‚ÌƒZƒbƒg
		namedArgs:=Malloc(4)
		NumPut(namedArgs,	params+4)
		NumPut(0xFFFFFFFD,	namedArgs+0)
		NumPut(1,			params+12)
		pvRes:=Invoke(obj,dispid,4,params)
		FreeParam(params)
		return vFree(pvRes)
	}
}


GuidIsEqual(guid1,guid2){
	return DllCall("MSVCRT.dll\memcmp","UInt",guid1,"UInt",guid2,"UInt",16)=0
}
EVENTSINK_QueryInterface(pEv,iid,ppv){
	global
	if(GuidIsEqual(iid,NumGet(pEv+8))||GuidIsEqual(iid,IID_IDispatch)||GuidIsEqual(iid,IID_IUnknown)){
		NumPut(pEv,ppv+0)
		DllCall(M(pEv,1),"UInt",pEv)
		return 0
	}
	NumPut(0,ppv+0)
	return 0x80004002
}
EVENTSINK_AddRef(pEv){
	cRef:=NumGet(pEv+4)
	cRef++
	NumPut(cRef,pEv+4)
	return cRef
}
EVENTSINK_Release(pEv){
	cRef:=NumGet(pEv+4)
	cRef--
	NumPut(cRef,pEv+4)
	if(cRef==0){
		EVENTSINK_Destructor(pEv)
	}
	return cRef
}
EVENTSINK_GetTypeInfoCount(pEv,pct){
	NumPut(0,pct+0)
	return 0
}
EVENTSINK_GetTypeInfo(pEv,info,lcid,pInfo){
	return 0x8002000B	;DISP_E_BADINDEX
}
EVENTSINK_GetIDsOfNames(pEv,riid,szNames,cNames,lcid,pDispID){
	return 0x80020006	;DISP_E_UNKNOWNNAME
}
EVENTSINK_Invoke(pEv,dispid,riid,lcid,wFlags,params,pvRes,exinf,argerr){
	pTypeInfo:=NumGet(pEv+24)
	;GetNames
	hr:=DllCall(M(pTypeInfo,7),"UInt",pTypeInfo, "UInt",dispid, "UIntP",bstr, "UInt",1, "UIntP",count)
	if(hr!=0){
		return 0
	}
	wc2mb_ref(bstr,ev)

	cb:=GetOleEventCallback(NumGet(pEv+12),ev)
	if(cb){
		DllCall(cb,"UInt",NumGet(pEv+28), "UInt",params, "UInt",pvRes)
	}
}
EVENTSINK_Constructor(){
	static vtEventSink
	if(!vtEventSink){
		vtEventSink:=Malloc(28)
		NumPut(RegisterCallback("EVENTSINK_QueryInterface"),	vtEventSink+0)
		NumPut(RegisterCallback("EVENTSINK_AddRef"),			vtEventSink+4)
		NumPut(RegisterCallback("EVENTSINK_Release"),			vtEventSink+8)
		NumPut(RegisterCallback("EVENTSINK_GetTypeInfoCount"),	vtEventSink+12)
		NumPut(RegisterCallback("EVENTSINK_GetTypeInfo"),		vtEventSink+16)
		NumPut(RegisterCallback("EVENTSINK_GetIDsOfNames"),		vtEventSink+20)
		NumPut(RegisterCallback("EVENTSINK_Invoke"),			vtEventSink+24)
	}
	pEv:=Malloc(32)
	NumPut(vtEventSink,pEv+0)
	return pEv
}
EVENTSINK_Destructor(pEv){
	Release(NumGet(pEv+28))
	Free(pEv)
}






/*
	**********************************
	ƒRƒlƒNƒg—p‚ÌƒCƒ“ƒ^[ƒtƒFƒCƒXID‚ðŒŸõ
	**********************************
*/
find_iid(ByRef obj,ByRef itf,ByRef iid,ByRef refPTypeInfo=0xFFFFFFFFFFFFFFFF){
	global LOCALE_USER_DEFAULT
	;GetTypeInfo
	hr:=DllCall(M(disp,4),"UInt",obj, "UInt",0, "UInt",LOCALE_USER_DEFAULT, "UIntP",pTypeInfo)
	if(hr!=0){
		return hr
	}
	;GetContainingTypeLib
	hr:=DllCall(M(pTypeInfo,18),"UInt",pTypeInfo, "UIntP",pTypeLib, "UIntP",index)
	Release(pTypeInfo)
	if(hr!=0){
		return hr
	}
	if(!itf){
		;GetTypeInfoOfGuid
		hr:=DllCall(M(pTypeLib,5),"UInt",pTypeLib, "UIntP",iid, "UIntP",refPTypeInfo)
		Release(pTypeLib)
		return hr
	}
	count:=DllCall(M(pTypeLib,3),"UInt",pTypeLib)										;GetTypeInfoCount
	found:=0
	index:=0
	Loop,%count%{
		hr:=DllCall(M(pTypeLib,4),"UInt",pTypeLib, "UInt",index, "UIntP",pTypeInfo)		;GetTypeInfo
		if(hr!=0){
			break
		}
		hr:=DllCall(M(pTypeInfo,3),"UInt",pTypeInfo, "UIntP",pTypeAttr)					;GetTypeAttr
		if(hr!=0){
			Release(pTypeInfo)
			break
		}
		if(NumGet(pTypeAttr+40)==5){													;typekind==TKIND_COCLASS
			cTypes:=NumGet(pTypeAttr+48,"UShort")												;cImplTypes
			type:=0
			Loop,%cTypes%{
				hr:=DllCall(M(pTypeInfo,8),"UInt",pTypeInfo, "UInt",type, "UIntP",RefType)	;GetRefTypeOfImplType
				if(hr!=0){
					break
				}
				hr:=DllCall(M(pTypeInfo,14),"UInt",pTypeInfo, "UInt",RefType, "UIntP",pImplTypeInfo)	;GetRefTypeInfo
				if(hr!=0){
					break
				}
				;GetDocumentation
				hr:=DllCall(M(pImplTypeInfo,12),"UInt",pImplTypeInfo, "Int",-1, "UIntP",bstr, "UInt",0, "UInt",0, "UInt",0)
				if(hr!=0){
					Release(pImplTypeInfo)
					break
				}
				wc2mb_ref(bstr,str)
				if(str==itf){
					;GetTypeAttr
					if(DllCall(M(pImplTypeInfo,3),"UInt",pImplTypeInfo, "UIntP",pImplTypeAttr)=0){
						found:=1
						iid:=Malloc(16)
						DllCall("kernel32.dll\RtlMoveMemory", "UInt",iid, "UInt",pImplTypeAttr, "UInt",16)
						if(refPTypeInfo!=0xFFFFFFFFFFFFFFFF){
							refPTypeInfo:=pImplTypeInfo
							AddRef(pImplTypeInfo)
						}
						;ReleaseTypeAttr
						DllCall(M(pImplTypeInfo,3),"UInt",pImplTypeInfo, "UInt",pImplTypeAttr)
					}
				}
				Release(pImplTypeInfo)
				if(found||(hr!=0)){
					break
				}
				type++
			}
		}
		hr:=DllCall(M(pTypeInfo,3),"UInt",pTypeInfo, "UInt",pTypeAttr)	;ReleaseTypeAttr
		Release(pTypeInfo)
		if(found||(hr!=0)){
			break
		}
		index++
	}
	Release(pTypeLib)
	if(!found){
		return 0x80004002
	}else{
		return hr
	}
}
find_default_source(ByRef obj,ByRef iid,ByRef refPTypeInfo){
	global IID_IProvideClassInfo	;,IID_IProvideClassInfo2
/*
	pProvideClassInfo2:=QueryInterface(obj,IID_IProvideClassInfo2)
	if(ErrorLevel________==0){
		;GetGUID
		hr:=DllCall(M(pProvideClassInfo2,4),"UInt",pProvideClassInfo2, "UInt",1, "UIntP",iid)
		Release(pProvideClassInfo2)
		return find_iid(obj,"",iid,refPTypeInfo)
	}
*/
	pProvideClassInfo:=QueryInterface(obj,IID_IProvideClassInfo)
	if(ErrorLevel!=0){
		return ErrorLevel
	}
	;GetClassInfo
	hr:=DllCall(M(pProvideClassInfo,3),"UInt",pProvideClassInfo, "UIntP",pTypeInfo)
	Release(pProvideClassInfo)
	if(hr!=0){
		return hr
	}
	;GetTypeAttr
	hr:=DllCall(M(pTypeInfo,3),"UInt",pTypeInfo, "UIntP",pTypeAttr)
	if(hr!=0){
		Release(pTypeInfo)
		return hr
	}
	cTypes:=NumGet(pTypeAttr+48,"UShort")						;cImplTypes
	type:=0
	Loop,%cTypes%{
		hr:=DllCall(M(pTypeInfo,9),"UInt",pTypeInfo, "UInt",type, "UIntP",iFlags)	;GetImplTypeFlags
		if(hr!=0){
			continue
		}
		if((iFlags&0x3)=0x3){				;((iFlags & IMPLTYPEFLAG_FDEFAULT)&&(iFlags & IMPLTYPEFLAG_FSOURCE))
			hr:=DllCall(M(pTypeInfo,8),"UInt",pTypeInfo, "UInt",type, "UIntP",RefType)			;GetRefTypeOfImplType
			if(hr!=0){
				continue
			}
			hr:=DllCall(M(pTypeInfo,14),"UInt",pTypeInfo, "UInt",RefType, "UIntP",refPTypeInfo)	;GetRefTypeInfo
			if(hr!=0){
				break
			}
		}
		type++
	}
	DllCall(M(pTypeInfo,3),"UInt",pTypeInfo, "UInt",pTypeAttr)	;ReleaseTypeAttr
	Release(pTypeInfo)
	if(!refPTypeInfo){
		if(hr==0){
			return 0x8000FFFF
		}else{
			return hr
		}
	}
	if(DllCall(M(refPTypeInfo,3),"UInt",refPTypeInfo, "UIntP",pTypeAttr)=0){			;GetTypeAttr
		iid:=Malloc(16)
		DllCall("kernel32.dll\RtlMoveMemory", "UInt",iid, "UInt",pTypeAttr, "UInt",16)
		DllCall(M(refPTypeInfo,3),"UInt",refPTypeInfo, "UInt",pTypeAttr)				;ReleaseTypeAttr
	}else{
		Release(refPTypeInfo)
		refPTypeInfo:=""
	}
	return hr
}
EntryOleEventPrefix(ByRef prefix){
	global
	static OleEventCount=0
	if(OleEventID_%prefix%){
		return OleEventID_%prefix%
	}else{
		OleEventID_%prefix%:=OleEventCount
		OleEventPrefix_%OleEventCount%:=prefix
		return OleEventCount++
	}
}
GetOleEventCallback(id,ByRef evt){
	global
	local prefix,cb
	prefix:=OleEventPrefix_%id%
	if(prefix){
		if(OleEventCallback_%prefix%%evt%){
			return OleEventCallback_%prefix%%evt%
		}
		cb:=RegisterCallback(prefix . evt)
		if(cb){
			OleEventCallback_%prefix%%evt%:=cb
			return cb
		}
	}
}
ConnectObject(obj,prefix,itf=0xFFFFFFFFFFFFFFFF){
	global IID_IConnectionPointContainer

	if(itf==0xFFFFFFFFFFFFFFFF){
		hr:=find_default_source(obj,iid,pTypeInfo)
	}else{
		hr:=find_iid(obj,itf,iid,pTypeInfo)
	}
	if(hr!=0){
		ErrorLevel:=hr
		return 0
	}
	pContainer:=QueryInterface(obj,IID_IConnectionPointContainer)
	if(ErrorLevel!=0){
		Release(pTypeInfo)
		return 0
	}
	;FindConnectionPoint
	hr:=DllCall(M(pContainer,4),"UInt",pContainer, "UInt",iid, "UIntP",pConnectionPoint)
	Release(pContainer)
	if(hr!=0){
		Release(pTypeInfo)
		return 0
	}
	pIEV:=EVENTSINK_Constructor()
	NumPut(iid,				pIEV+8)
	;Advise
	hr:=DllCall(M(pConnectionPoint,5),"UInt",pConnectionPoint, "UInt",pIEV, "UIntP",dwCookie)
	if(hr!=0){
		return 0
	}
	AddRef(obj)
	evid:=EntryOleEventPrefix(prefix)
	NumPut(evid,			pIEV+12)
	NumPut(dwCookie,		pIEV+16)
	NumPut(pConnectionPoint,pIEV+20)
	NumPut(pTypeInfo,		pIEV+24)
	NumPut(obj,				pIEV+28)
}
evArgc(ByRef para){
	return NumGet(para+8)
}
evArgv(ByRef para,idx){
	num:=NumGet(para+8)
	if(idx<num){
		return fromVariant(NumGet(para+0)+(num-1-idx)*16)
	}
}
evReturn(ByRef res,value){
	toVariant(value,res)
}









/*
	**********************************
	ƒfƒBƒXƒpƒbƒ`ƒIƒuƒWƒFƒNƒgì¬
	**********************************
*/


DISPATCH_QueryInterface(ptr,iid,ppv){
	global
	if(GuidIsEqual(iid,IID_IDispatch)||GuidIsEqual(iid,IID_IUnknown)){
		NumPut(ptr,ppv+0)
		DllCall(M(ptr,1),"UInt",ptr)
		return 0
	}else{
		NumPut(0,ppv+0)
		return 0x80004002
	}
}
DISPATCH_AddRef(ptr){
	cRef:=NumGet(ptr+4)
	cRef++
	NumPut(cRef,ptr+4)
	return cRef
}
DISPATCH_Release(ptr){
	cRef:=NumGet(ptr+4)
	cRef--
	NumPut(cRef,ptr+4)
	if(cRef==0){
		Free(ptr)
	}
	return cRef
}
DISPATCH_GetTypeInfoCount(ptr,pct){
	NumPut(0,pct+0)
	return 0
}
DISPATCH_GetTypeInfo(ptr,info,lcid,pInfo){
	return 0x8002000B	;DISP_E_BADINDEX
}
DISPATCH_GetIDsOfNames(ptr,riid,pszNames,cNames,lcid,pDispID){
	wc2mb_ref(NumGet(pszNames+0),name)
	hr:=GetOleMethodCallback(NumGet(ptr+12),name,cb)
	NumPut(cb,pDispID+0)
	return hr
}
DISPATCH_Invoke(ptr,dispid,riid,lcid,wFlags,params,pvRes,exinf,argerr){
	DllCall(dispid,"UInt",ptr, "UInt",params, "UInt",pvRes, "UInt",wFlags)
	return 0
}



EntryOleMethodsPrefix(ByRef prefix,ByRef id){
	global
	static OleMethodsCount=0
	if(OleMethodsID_%prefix%){
		id:=OleMethodsID_%prefix%
	}else{
		OleMethodsID_%prefix%:=OleMethodsCount
		OleMethodsPrefix_%OleMethodsCount%:=prefix
		id:=OleMethodsCount++
	}
}
GetOleMethodCallback(id,ByRef name,ByRef cb){
	global
	local prefix
	cb:=0
	prefix:=OleMethodsPrefix_%id%
	if(prefix){
		if(OleMethodCallback_%prefix%%name%){
			cb:=OleMethodCallback_%prefix%%name%
			return 0
		}else{
			cb:=RegisterCallback(prefix . name)
			if(cb){
				OleMethodCallback_%prefix%%name%:=cb
				return 0
			}else{
				return 0x80020006
			}
		}
	}
}

CreateDispatchObject(prefix,exsize=0){
	global IID_IDispatch
	static vtDispatch
	if(!vtDispatch){
		vtDispatch:=Malloc(28)
		NumPut(RegisterCallback("DISPATCH_QueryInterface"),		vtDispatch+0)
		NumPut(RegisterCallback("DISPATCH_AddRef"),				vtDispatch+4)
		NumPut(RegisterCallback("DISPATCH_Release"),			vtDispatch+8)
		NumPut(RegisterCallback("DISPATCH_GetTypeInfoCount"),	vtDispatch+12)
		NumPut(RegisterCallback("DISPATCH_GetTypeInfo"),		vtDispatch+16)
		NumPut(RegisterCallback("DISPATCH_GetIDsOfNames"),		vtDispatch+20)
		NumPut(RegisterCallback("DISPATCH_Invoke"),				vtDispatch+24)
	}
	EntryOleMethodsPrefix(prefix,id)
	ptr:=Malloc(12+exsize)
	NumPut(vtDispatch		,ptr+0)
	NumPut(IID_IDispatch	,ptr+8)
	NumPut(id				,ptr+12)
	return ptr
}
