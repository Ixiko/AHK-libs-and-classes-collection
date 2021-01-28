; -- COMo Functions - temp01 - See http://www.autohotkey.com/forum/viewtopic.php?t=49433
COMo_GetVal(obj, name){
	global COM_VT
	Ret := COM_Invoke(obj.COMObj, name)
	If COM_VT=9	; thanks Lex!
		Return COMo(Ret)
	Else
		Return Ret
}
COMo_SetVal(obj, name, val){
	return COM_Invoke(obj.COMObj, name "=", val.COMObj ? "+" . val.COMObj : val)
}
COMo_Call(obj, func, prm1="vT_NoNe",prm2="vT_NoNe",prm3="vT_NoNe",prm4="vT_NoNe",prm5="vT_NoNe",prm6="vT_NoNe"){
	global COM_VT
	Loop, 6
		If CObj:=ObjGet(prm%A_Index%, "COMObj")
			prm%A_Index% := "+" . CObj
	Ret := COM_Invoke(obj.COMObj, func, prm1, prm2, prm3, prm4, prm5, prm6)
	If COM_VT=9
		Return COMo(Ret)
	Else
		Return Ret
}
COMo(param, sfn="CreateObject"){
	static COBase
	If !COBase
		COBase := Object("__Get", "COMo_GetVal", "__Set", "COMo_SetVal", "__Call", "COMo_Call", "__Delete", "COMo_Delete"), COM_Init()==1 ? COM_Term() : ""
	Return Object("COMObj", param+1 ? param : COM_%sfn%(param), "base", COBase)
}
COMo_Delete(obj){
	COM_Release(obj.COMObj)
}