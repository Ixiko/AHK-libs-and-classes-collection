DDBD(dic="",action="",ByRef Key="",ByRef Item="",skip=0,limit=9223372036854775807){
	static
	local CLSID,IID,CLSID_,IID_,nLen,nLenItm,bExist,label,penum,result,nCompMode,wStr,wItm,wKey,wItem,pFunc,n,MaxParams
			,split,split1,split2,Array_var,eline,pgit,Name,pName,pvName,this_postfix,vName,func_deref
	static CLSIDString:="{EE09B103-97E0-11CF-978F-00A02463E06F}", IIDString:="{42C642C1-97E1-11CF-978F-00A02463E06F}"
			,CLSID_StdGlobalInterfaceTable:="{00000323-0000-0000-C000-000000000046}"
			,IID_IGlobalInterfaceTable:="{00000146-0000-0000-C000-000000000046}"
	If IsLabel(label:="DDBD" . action)
		Goto % label
	else
		Return
	Return
	DDBDAdd:
		Gosub,DDBDAllocKey
		Gosub,DDBDAllocItm
		DllCall(NumGet(NumGet(pDic%dic%+0)+40), "UInt",pDic%dic%, "UInt",&var1, "UInt",&var2) 
		Gosub, DDBDFreeString
	Return
	DDBDChain:
		result:=Item
		Gosub, DDBDGet
		Item.=result
		Gosub,DDBDAllocKey
		Gosub,DDBDAllocItm
		DllCall(NumGet(NumGet(pDic%dic%+0)+32), "UInt",pDic%dic%, "UInt",&var1, "UInt",&var2)
		Gosub, DDBDFreeString
	Return
	DDBDGet:
;~ 		OutputDebug % key
		Item=
		Gosub,DDBDAllocKey
		DllCall(NumGet(NumGet(pDic%dic%+0)+48), "UInt",pDic%dic%, "UInt",&var1, "IntP",bExist)
		If bExist {
			DllCall(NumGet(NumGet(pDic%dic%+0)+36), "UInt",pDic%dic%, "UInt",&var1, "UInt",&var2)
			nLen := DllCall("WideCharToMultiByte", "UInt",0, "UInt",0, "UInt",NumGet(var2,8), "Int",-1, "UInt",0, "Int",0, "UInt",0, "UInt",0)
			VarSetCapacity(Item, nLen,0)
			DllCall("WideCharToMultiByte", "UInt",0, "UInt",0, "UInt",NumGet(var2,8), "Int",-1, "Str",Item, "Int",nLen, "UInt",0, "UInt",0)
			DllCall("oleaut32\SysFreeString", "UInt",NumGet(var2,8)),NumPut(0,var2,8)
		}
		DllCall("oleaut32\SysFreeString", "UInt",NumGet(var1,8)),NumPut(0,var1,8)
	Return Item
	DDBDSet:
		Gosub,DDBDAllocKey
		Gosub,DDBDAllocItm
		DllCall(NumGet(NumGet(pDic%dic%+0)+32), "UInt",pDic%dic%, "UInt",&var1, "UInt",&var2)  ; 8 (Set0 -> 7)
		Gosub, DDBDFreeString
	Return
	DDBDExists:
		If !pdic%dic%
			Return 0
		Gosub,DDBDAllocKey
		DllCall(NumGet(NumGet(pDic%dic%+0)+48), "UInt",pDic%dic%, "UInt",&var1, "IntP",bExist)
		DllCall("oleaut32\SysFreeString", "UInt",NumGet(var1,8))
	Return bExist
	DDBDFreeString:
		DllCall("oleaut32\SysFreeString", "UInt",NumGet(var2,8)),NumPut(0,var2,8)
		DllCall("oleaut32\SysFreeString", "UInt",NumGet(var1,8)),NumPut(0,var1,8)
	Return
	DDBDAllocItm: ;Internal
		VarSetCapacity(wItm, StrLen(Item)*2+1,0)
		DllCall("MultiByteToWideChar", "UInt",0, "UInt",0, "UInt",&Item, "Int",-1, "UInt",&wItm, "Int",StrLen(Item)+1)
		NumPut(DllCall("oleaut32\SysAllocString","Str",wItm),var2,8),wItm:=""
	Return
	DDBDAllocKey: ;Internal
		VarSetCapacity(wStr, StrLen(Key)*2+1,0)
		DllCall("MultiByteToWideChar", "UInt",0, "UInt",0, "UInt",&Key, "Int",-1, "UInt",&wStr, "Int",StrLen(Key)+1)
		NumPut(DllCall("oleaut32\SysAllocString","Str",wStr),var1,8),wstr:=""
	Return
	DDBDFind:
	DDBDMatch:
	DDBDRegEx:
	DDBDGetAll:
	DDBDCopy:
	DDBDSort:
	DDBDRegexReplace:
	DDBDReplace:
		wKey:=key,wItem:=Item
		DllCall(NumGet(NumGet(pDic%dic%+0)+80), "UInt",pDic%dic%, "UIntP",penum) ; create key-list in penum
		While % (penum 
				&& !(InStr("Clear0",pDic%dic%) 
				|| DllCall(NumGet(NumGet(penum+0)+12), "UInt",penum, "UInt",1, "UInt",&var1, "UInt",0))){
			nLen := DllCall("WideCharToMultiByte", "UInt",0, "UInt",0, "UInt",NumGet(var1,8), "Int",-1, "UInt",0, "Int",0, "UInt",0, "UInt",0)
			VarSetCapacity(key, nLen,0)
			DllCall("WideCharToMultiByte", "UInt",0, "UInt",0, "UInt",NumGet(var1,8), "Int",-1, "Str",key, "Int",nLen, "UInt",0, "UInt",0)
			If (InStr("DDBDFindDDBDMatchDDBDRegex",label) and (label="DDBDFind" 
				? (InStr(Key,wKey)=1) : (label="DDBDMatch" ? (InStr(key,wKey)) : (RegExMatch(key,wKey))))){
				bExist++
				If (bExist>skip){
					Gosub, DDBDGet
					result.= Item . wItem
					nLenItm++
					If (limit<=nLenItm){
						Break
					}
				}
		} else if (label="DDBDReplace"){
				Gosub, DDBDGet
				result:=Item
				StringReplace,result,result,%wKey%,%wItem%,All
				Item:=result
				Gosub, DDBDSet
			} else if (label="DDBDRegexReplace"){
				Gosub, DDBDGet
				Item:=RegExReplace(Item,wKey,wItem,"",-1)
				Gosub, DDBDSet
			} else if !InStr("DDBDFindDDBDMatchDDBDRegex",label){
				result.= Key . (label="DDBDGetAll" ? wKey : (Chr(2) . DDBD(dic,"get",Key) . Chr(3)))
			}
		}
		If (wItem!="" or (label="DDBDGetAll" and wKey!=""))
			StringTrimRight,result,result,1
		DllCall(NumGet(NumGet(penum+0)+8), "UInt",penum)
		If InStr("DDBDGetAllDDBDFindDDBDMatchDDBDRegEx",label)
			Return result
		else if (label="DDBDReplace"){
			Return
		} else if (label="DDBDCopy"){
			Gosub, DDBDGetCompMode
			dic:=wKey
	 } else {
		  Sort,result,% "D" . Chr(3) . wKey
		  Gosub, DDBDDeleteAll
		}
		If (label="DDBDCopy"){
			Key:= nCompMode ? nCompMode : wItem
			Gosub, DDBDCreate
		}
		Loop,Parse,result,% Chr(3)
			If (A_LoopField!=""){
				key:=SubStr(A_LoopField,1,InStr(A_LoopField,Chr(2))-1)
				Item:=SubStr(A_LoopField,InStr(A_LoopField,Chr(2))+1)
				Gosub, DDBDAdd
			}
	Return
	DDBD&:
	DDBDEnum:
		If Key>0
			penum%dic%:=Key
		else If (!penum%dic% or (Key="0" and !DllCall(NumGet(NumGet(penum%dic%+0)+8), "UInt",penum%dic%)))
			DllCall(NumGet(NumGet(pDic%dic%+0)+80), "UInt",pDic%dic%, "UIntP",penum%dic%) ; create key-list in penum
		If (InStr("Clear0",pDic%dic%) || DllCall(NumGet(NumGet(penum%dic%+0)+12), "UInt",penum%dic%, "UInt",1, "UInt",&var1, "UInt",0)) {
			DllCall(NumGet(NumGet(penum%dic%+0)+8), "UInt",penum%dic%)   ; END: destroy key-list
			penum%dic%=                                                  ; signal end of list
			ErrorLevel=                                                  ; empty
			Return      		                                           
		}
		nLen := DllCall("WideCharToMultiByte", "UInt",0, "UInt",0, "UInt",NumGet(var1,8), "Int",-1, "UInt",0, "Int",0, "UInt",0, "UInt",0)
		VarSetCapacity(wKey, nLen)
		DllCall("WideCharToMultiByte", "UInt",0, "UInt",0, "UInt",NumGet(var1,8), "Int",-1, "Str",wKey, "Int",nLen, "UInt",0, "UInt",0)
		DllCall("oleaut32\SysFreeString", "UInt",NumGet(var1,8)),NumPut(0,var1,8)
		ErrorLevel:=penum%dic%
	Return wKey
	DDBDEnumerate:
		If Key>0
			penum%dic%:=Key
		else If (!penum%dic% or (Key="0" and !DllCall(NumGet(NumGet(penum%dic%+0)+8), "UInt",penum%dic%)))
			DllCall(NumGet(NumGet(pDic%dic%+0)+80), "UInt",pDic%dic%, "UIntP",penum%dic%) ; create key-list in penum
		If (InStr("Clear0",pDic%dic%) || DllCall(NumGet(NumGet(penum%dic%+0)+12), "UInt",penum%dic%, "UInt",1, "UInt",&var1, "UInt",0)) {
			DllCall(NumGet(NumGet(penum%dic%+0)+8), "UInt",penum%dic%)   ; END: destroy key-list
			penum%dic%=                                                  ; signal end of list
			ErrorLevel=                                                  ; empty
			Return      		                                           
		}
		nLen := DllCall("WideCharToMultiByte", "UInt",0, "UInt",0, "UInt",NumGet(var1,8), "Int",-1, "UInt",0, "Int",0, "UInt",0, "UInt",0)
		VarSetCapacity(wKey, nLen)
		DllCall("WideCharToMultiByte", "UInt",0, "UInt",0, "UInt",NumGet(var1,8), "Int",-1, "Str",wKey, "Int",nLen, "UInt",0, "UInt",0)
		DllCall("oleaut32\SysFreeString", "UInt",NumGet(var1,8)),NumPut(0,var1,8)
		ErrorLevel:=wKey
	Return penum%dic%
	DDBDHash:
		Gosub, DDBDAllocKey
		DllCall(NumGet(NumGet(pDic%dic%+0)+48), "UInt",pDic%dic%, "UInt",&var1, "IntP",bExist)
		DllCall(NumGet(NumGet(pDic%dic%+0)+84), "UInt",pDic%dic%, "UInt",&var1, "UInt",&var2)
		result := NumGet(var2,8)
		Gosub, DDBDFreeString
		Return result
	Return
	DDBDRename:
		Gosub,DDBDAllocKey
		Gosub,DDBDAllocItm
		DllCall(NumGet(NumGet(pDic%dic%+0)+56), "UInt",pDic%dic%, "UInt",&var1, "UInt",&var2)
		Gosub, DDBDFreeString
	Return
	DDBDDelete:
		Gosub,DDBDAllocKey
		DllCall(NumGet(NumGet(pDic%dic%+0)+64), "UInt",pDic%dic%, "UInt",&var1)
		DllCall("oleaut32\SysFreeString", "UInt",NumGet(var1,8)),NumPut(0,var1,8)
	Return
	DDBDDeleteAll:
	Return DllCall(NumGet(NumGet(pDic%dic%+0)+68), "UInt",pDic%dic%)
	DDBDCount:
		DllCall(NumGet(NumGet(pDic%dic%+0)+44), "UInt",pDic%dic%, "IntP",result)
	Return result
	DDBDDestroy:
		DllCall(NumGet(NumGet(pDic%dic%+0)+8), "UInt",pDic%dic%)
		pDic%dic%:="",key:=dic,dic:=""
		Goto,DDBDDelete
	Return
	DDBDGetCompMode:
		DllCall(NumGet(NumGet(pDic%dic%+0)+76), "UInt",pDic%dic%, "IntP",nCompMode)
	return nCompMode
	DDBDDestroyAll:
		DllCall(NumGet(NumGet(pDic+0)+80), "UInt",pDic, "UIntP",penum) ; create key-list in penum
		While % (penum 
				&& !(InStr("Clear0",pDic) 
				|| DllCall(NumGet(NumGet(penum+0)+12), "UInt",penum, "UInt",1, "UInt",&var1, "UInt",0))){
			nLen := DllCall("WideCharToMultiByte", "UInt",0, "UInt",0, "UInt",NumGet(var1,8), "Int",-1, "UInt",0, "Int",0, "UInt",0, "UInt",0)
			VarSetCapacity(wStr, nLen)
			DllCall("WideCharToMultiByte", "UInt",0, "UInt",0, "UInt",NumGet(var1,8), "Int",-1, "Str",wStr, "Int",nLen, "UInt",0, "UInt",0)
			key:=wStr
			If key=+++
				continue
			Gosub, DDBDGet
			IfInString,key,+
			{
				key:=SubStr(key,1,Instr(key,"+")-1)
				valued_%key%=
				delimiter_%key%=
				continue
			}
			pdic%key%=
			If Item
				DllCall(NumGet(NumGet(Item+0)+8), "UInt",Item)
			DllCall("oleaut32\SysFreeString", "UInt",NumGet(var1,8)),NumPut(0,var1,8)
		}
		DllCall(NumGet(NumGet(penum+0)+8), "UInt",penum)
	Return
	DDBDCreate:
		If !Init
			DllCall("ole32\CoInitialize", "UInt",0),Init:=1
			,VarSetCapacity(var1, 16, 0),VarSetCapacity(var2, 16, 0),NumPut(8, var1),NumPut(8, var2)
		If (pdic%dic%=""){
			VarSetCapacity(CLSID, 16)
			VarSetCapacity(wKey, 79)
			DllCall("MultiByteToWideChar", "UInt",0, "UInt",0, "UInt",&CLSIDString, "Int",-1, "UInt",&wKey, "Int",39)
			DllCall("ole32\CLSIDFromString", "Str",wKey, "Str",CLSID)
			VarSetCapacity(IID, 16)
			DllCall("MultiByteToWideChar", "UInt",0, "UInt",0, "UInt",&IIDString, "Int",-1, "UInt",&wKey, "Int",39)
			DllCall("ole32\CLSIDFromString", "Str",wKey, "Str",IID)
			DllCall("ole32\CoCreateInstance", "Str",CLSID, "UInt",0, "UInt",5, "Str",IID, "UIntP",pDic%dic%) ; CLSCTX=5
			DllCall(NumGet(NumGet(pDic%dic%+0)+72), "UInt",pDic%dic%, "Int",Key) ; Set compare mode
			ErrorLevel:=dic
			Gosub, DDBDCreateFunctions
		}
		Key:=dic,Item:=pdic%dic%,dic:=""
		Gosub,DDBDSet
		dic:=key
	Return pdic%dic%
	DDBD:
	 If (!Init){
		DllCall("ole32\CoInitialize", "UInt",0),Init:=1
		,VarSetCapacity(var1, 16, 0),VarSetCapacity(var2, 16, 0),NumPut(8, var1),NumPut(8, var2)
		VarSetCapacity(wKey, 79)
		VarSetCapacity(CLSID, 16)
		DllCall("MultiByteToWideChar", "UInt",0, "UInt",0, "UInt",&CLSIDString, "Int",-1, "UInt",&wKey, "Int",39)
		DllCall("ole32\CLSIDFromString", "Str",wKey, "Str",CLSID)
		VarSetCapacity(IID, 16)
		DllCall("MultiByteToWideChar", "UInt",0, "UInt",0, "UInt",&IIDString, "Int",-1, "UInt",&wKey, "Int",39)
		DllCall("ole32\CLSIDFromString", "Str",wKey, "Str",IID)
		VarSetCapacity(CLSID_, 16)
		DllCall("MultiByteToWideChar", "UInt",0, "UInt",0, "UInt",&CLSID_StdGlobalInterfaceTable, "Int",-1, "UInt",&wKey, "Int",39)
		DllCall("ole32\CLSIDFromString", "Str",wKey, "Str",CLSID_)
		VarSetCapacity(IID_, 16)
		DllCall("MultiByteToWideChar", "UInt",0, "UInt",0, "UInt",&IID_IGlobalInterfaceTable, "Int",-1, "UInt",&wKey, "Int",39)
		DllCall("ole32\CLSIDFromString", "Str",wKey, "Str",IID_)
		DllCall("ole32\CoCreateInstance", "Str",CLSID_, "UInt",0, "UInt",5, "Str",IID_, "UIntP",pgit) ; CLSCTX=5
		DllCall(NumGet(NumGet(1*pgit)+20), "Uint", pgit, "Uint", 256, "Uint", &IID, "UintP", pDic)
		If (pDic=0){
			DllCall("ole32\CoCreateInstance", "Str",CLSID, "UInt",0, "UInt",5, "Str",IID, "UIntP",pDic) ; CLSCTX=5
			DllCall(NumGet(NumGet(pDic+0)+72), "UInt",pDic, "Int",1) ; Set compare mode
			key=+++
			Item:=pdic
			Gosub, DDBDAdd
			key:="",Item:=""
			If (A_IsCompiled){
				key=+AhkPath
				Item:=A_ScriptFullPath
				Gosub, DDBDAdd
				key:="",Item:=""
			}
			DllCall(NumGet(NumGet(1*pgit)+12), "Uint", pgit, "Uint", pDic, "Uint", &IID, "UintP", dwCookie)
		}
		Key=+++
		Gosub, DDBDGet
		If (Item){
			pdic:=Item
			DllCall(NumGet(NumGet(pDic+0)+80), "UInt",pDic, "UIntP",penum) ; create key-list in penum
			While % (penum 
					&& !(InStr("Clear0",pDic) 
					|| DllCall(NumGet(NumGet(penum+0)+12), "UInt",penum, "UInt",1, "UInt",&var1, "UInt",0))){
				nLen := DllCall("WideCharToMultiByte", "UInt",0, "UInt",0, "UInt",NumGet(var1,8), "Int",-1, "UInt",0, "Int",0, "UInt",0, "UInt",0)
				VarSetCapacity(wStr, nLen)
				DllCall("WideCharToMultiByte", "UInt",0, "UInt",0, "UInt",NumGet(var1,8), "Int",-1, "Str",wStr, "Int",nLen, "UInt",0, "UInt",0)
				DllCall("oleaut32\SysFreeString", "UInt",NumGet(var1,8)),NumPut(0,var1,8)
				If wStr=+++
					Continue
				key:=wStr
				Gosub, DDBDGet
				if (Key="+AhkPath"){
					AhkPath:=Item
					Continue
				}
				pdic%key%:=Item
				ErrorLevel:=key
				Gosub, DDBDCreateFunctions
			}
			DllCall(NumGet(NumGet(penum+0)+8), "UInt",penum)
		}
	} else {
		Gosub, DDBDDestroyAll
		Init=
		DllCall(NumGet(NumGet(pDic+0)+8), "UInt",pDic)
		pdic=
		DllCall("ole32\CoUnInitialize")
	 }
	Return
}

DDBDCreateFunctions:
		_dic:=ErrorLevel
		script=
		(LTrim
		%_dic%(key,_Item="ÿÿÿÿ"){
			Return DDBD(%_dic%,_Item<>"ÿÿÿÿ" ? "set" : "get",key,_Item)
		}
		%_dic%delete(key=""){
			Return DDBD(%_dic%,"delete",key)
		}
		%_dic%count(){
			Return DDBD(%_dic%,"count")
		}
		%_dic%exist(key){
			Return DDBD(%_dic%,"exists",key)
		}
		%_dic%rename(from,to){
			Return DDBD(%_dic%,"rename",from,to)
		}
		%_dic%while(enum=""){
			Return DDBD(%_dic%,"enumerate",enum)
		}
		%_dic%loop(enum=""){
			Return DDBD(%_dic%,"enum",enum)
		}
		%_dic%find(key="",separator="",skip=0,limit=9223372036854775807){
			Return DDBD(%_dic%,"find",key,separator,skip,limit)
		}
		%_dic%match(key="",separator=""){
			Return DDBD(%_dic%,key,separator)
		}
		%_dic%regex(key="",separator=""){
			Return DDBD(%_dic%,key,separator)
		}
		%_dic%deleteall(){
			Return DDBD(%_dic%,"deleteall")
		}
		%_dic%append(key,_Item){
			Return DDBD(%_dic%,"Chain",key,_Item)
		}
		%_dic%getall(separator=""){
			Return DDBD(%_dic%,"GetAll",separator)
		}
		)
		If (A_Thread){
			DllCall((A_IsCompiled ? AhkPath : A_AhkPath) . "\ahkFunction","str","CreatePipe","str",script,"str",_dic,"Cdecl UInt")
			Sleep, 1000
			DllCall(A_Thread . "\addFile", "str", "\\.\pipe\" _dic, "uchar", 1,"uchar" , 1, "Cdecl UInt")
		} else {
			DllCall((A_IsCompiled ? A_ScriptFullPath : A_AhkPath) . "\addFile","str",CreatePipe(script,_dic),"uchar",1,"uchar",1,"Cdecl UInt")
		}
	Return