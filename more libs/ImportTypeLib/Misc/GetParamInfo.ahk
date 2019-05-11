GetParamInfo(elem, method, index)
{
	; typeinfo - retrieve expected vt for first param:
	local info, hr, arr, vt, td_p, vt_p, href, tkind, refInfo := 0, refName := 0, refAttr := 0, dispid := -1, fnindex := -1, fndesc := 0
	static sizeof_ELEMDESC := 4 * A_PtrSize

	info := elem[ITL.Properties.TYPE_TYPEINFO] ; retrieve raw pointer
	hr := DllCall(NumGet(NumGet(info+0), 10*A_PtrSize, "Ptr"), "Ptr", info, "Str*", method, "UInt", 1, "UInt*", dispid, "Int") ; ITypeInfo::GetIDsOfNames()
	MsgBox % "ID: " dispid

	hr := DllCall(NumGet(NumGet(info+0), 24*A_PtrSize, "Ptr"), "Ptr", info, "UInt", dispid, "UInt", 1, "UInt*", fnindex, "Int") ; ITypeInfo2::GetFuncIndexOfMemId()
	MsgBox % "Index: " fnindex

	hr := DllCall(NumGet(NumGet(info+0), 05*A_PtrSize, "Ptr"), "Ptr", info, "UInt", fnindex, "Ptr*", fndesc, "Int") ; ITypeInfo::GetFuncDesc()
	MsgBox % "FNDESC: " fndesc

	arr := NumGet(1*fndesc, 04 + 1*A_PtrSize, "Ptr") ; FUNCDESC::lprgelemdescParam
	MsgBox % "ARR: " arr

	vt := NumGet(1*arr, (index - 1) * sizeof_ELEMDESC + A_PtrSize, "UShort") ; FUNCDESC::lprgelemdescParam[0]::tdesc::vt
	MsgBox % "VT: " vt

	if (vt == 26)
	{
		td_p := NumGet(1*arr, (index - 1) * sizeof_ELEMDESC + 00, "Ptr")
		vt_p := NumGet(1*td_p, A_PtrSize, "UShort")
		MsgBox % "VT - p: " vt_p
	}
	else if (vt == 29)
	{
		href := NumGet(1*arr, 00, "UInt")
		hr := DllCall(NumGet(NumGet(info+0), 14*A_PtrSize, "Ptr"), "Ptr", info, "UInt", href, "Ptr*", refInfo, "Int")
		hr := DllCall(NumGet(NumGet(refInfo+0), 03*A_PtrSize, "Ptr"), "Ptr", refInfo, "Ptr*", refAttr, "Int")
		tkind := NumGet(1*refAttr, 36+A_PtrSize, "UInt")
		hr := DllCall(NumGet(NumGet(refInfo+0), 12*A_PtrSize, "Ptr"), "Ptr", refInfo, "Int", -1, "Ptr*", refName, "Ptr", 0, "Ptr", 0, "Ptr", 0, "Int")

		MsgBox % "TYPEKIND: " tkind " [ " StrGet(refName) " ]"
	}

	DllCall(NumGet(NumGet(info+0), 20*A_PtrSize, "Ptr"), "Ptr", info, "Ptr", fndesc) ; ITypeInfo::ReleaseFuncDesc()
}