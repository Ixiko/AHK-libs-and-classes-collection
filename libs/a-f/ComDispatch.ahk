;
; File encoding:  UTF-8
; Author: fincs
;
; ComDispatch: Rewrite of Lexikos' DispatchObj() function
;

ComDispatch(this, disptable)
{
	static vtable := _CreateIDispatchVTable("_Dispatch_")
	if !IsObject(disptable)
	{
		disptable := ComDispTable(disptable)
		if !disptable
			return
	}
	
	 obj_mem := _CoTaskMemAlloc(2*A_PtrSize)
	,obj := {}
	,NumPut(vtable,      obj_mem+0*A_PtrSize)
	,NumPut(Object(obj), obj_mem+1*A_PtrSize)
	
	,obj.methods  := disptable[2]
	,obj.dispids  := disptable[1]
	,obj.refcount := 1
	,obj.pointer  := obj_mem
	,obj.this     := this
	
	return _ComObjParam(9, obj_mem)
}

_CreateIDispatchVTable(func)
{
	vtable_mem := _CoTaskMemAlloc(7 * A_PtrSize), var := "3112469"
	_var := A_AhkVersion < "2" ? "var" : var
	Loop Parse, %_var%
		idx := A_Index - 1
		, NumPut(RegisterCallback(func, "", A_LoopField, idx), vtable_mem + idx*A_PtrSize)
	return vtable_mem
}

_Dispatch_(this_, prm0 := 0, prm1 := 0, prm2 := 0, prm3 := 0, prm4 := 0, prm5 := 0, prm6 := 0, prm7 := 0, prm8 := 0)
{
	Critical
	
	; Get our object
	this := Object(this_ptr := NumGet(this_+A_PtrSize))
	
	goto _%A_EventInfo%

_0: ; IUnknown::QueryInterface
	; Beware of the hack code!
	 iid1 := NumGet(prm0+0, "Int64")
	,iid2 := NumGet(prm0+8, "Int64")
	if (iid2 = 0x46000000000000C0) && (!iid1 || iid1 = 0x20400)
	{
		this.refcount := this.refcount + 1, NumPut(this_, prm1+0)
		return 0
	}else
	{
		NumPut(0, prm1+0)
		return 0x80004002 ; E_NOINTERFACE
	}

_1: ; IUnknown::AddRef
	return this.refcount := this.refcount + 1

_2: ; IUnknown::Release
	if !(_new := (this.refcount := this.refcount - 1))
	{
		if func := this.dispids[this.methods.__Delete] && func.MinParams = 1
			%func%(this.this)
			; func.(this.this)
		 _CoTaskMemFree(this_)
		,this := ""
		,ObjRelease(this_ptr)
	}
	return _new

_3: ; IDispatch::GetTypeInfoCount
	NumPut(0, prm0+0, "UInt")
	return 0

_4: ; IDispatch::GetTypeInfo
	return 0x80004001 ; E_NOTIMPL

	; All the funny 0xFF... masking in the code below is because
	; of the x64 calling convention. For parameters whose size is
	; < 64 bits, the upper bits are garbage. So we clear them out.

_5: ; IDispatch::GetIDsOfNames
	status := 0, prm1 &= 0xFFFFFFFF
	Loop, % prm2 & 0xFFFFFFFF
	{
		 idx := A_Index - 1
		,name := StrGet(NumGet(prm1 + idx*A_PtrSize), "UTF-16")
		,dispid := this.methods[name]
		if dispid = ""
			dispid := 0xFFFFFFFB ; DISPID_UNKNOWN: (DWORD)(-5)
			,status := 0x80020006 ; DISP_E_UNKNOWNNAME
		NumPut(dispid, prm4 + idx*4, "UInt")
	}
	return status

_6: ; IDispatch::Invoke
	func := this.dispids[prm0 & 0xFFFFFFFF]
	if !func || !((prm3 & 0xFFFF) & 1)
		return 0x80020003 ; DISP_E_MEMBERNOTFOUND
	 nexpectedparams := func.MinParams - 1
	,paramarray := NumGet(prm4+0)
	,nparams := NumGet(prm4+2*A_PtrSize, "UInt")
	,params := []
	if (nparams < nexpectedparams)
		return 0x8002000E ; DISP_E_BADPARAMCOUNT
	else if !nparams
		goto _call
	else if NumGet(prm4+2*A_PtrSize+4, "UInt")
		return 0x80020007 ; DISP_E_NONAMEDARGS
	
	; Make a SAFEARRAY out of the raw VARIANT array
	static pad := A_PtrSize = 8 ? 4 : 0, sizeof_SAFEARRAY := 20+pad+A_PtrSize, sizeof_VARIANT := 16+2*(A_PtrSize-4)
	 VarSetCapacity(SAhdr, sizeof_SAFEARRAY, 0)
	,NumPut(1, SAhdr, 0, "UShort")
	,NumPut(0x0812, SAhdr, 2, "UShort") ; FADF_STATIC | FADF_FIXEDSIZE | FADF_VARIANT
	,NumPut(sizeof_VARIANT, SAhdr, 4, "UInt")
	,NumPut(paramarray, SAhdr, 12+pad)
	,NumPut(nparams, SAhdr, 12+pad+A_PtrSize, "UInt")
	,params_safearray := _ComObjParam(0x200C, &SAhdr)
	
	; Copy the parameters to a regular AutoHotkey array
	Loop, % nparams
		params.Insert(a := params_safearray[idx := nparams - A_Index])
	
_call:
	; Prepare a ComVar for converting the return value to VARIANT
	 retvar   := ComVar()
	,ret      := ComObjValue(retvar.ref)
	
	; Call the function
	try retvar[] := %func%(this.this, params*) ;// func.(this.this, params*)
	catch e
	{
		; Clear caller-supplied VARIANT.
		Loop, % sizeof_VARIANT // 8
			NumPut(0, prm5+8*(A_Index-1), "Int64")
		; Fill exception info
		if prm6
		{
			NumPut(0, prm6+0) ; wCode, wReserved, padding
			NumPut(_BSTR(e.what), prm6+A_PtrSize) ; bstrSource
			NumPut(_BSTR(e.message), prm6+2*A_PtrSize) ; bstrDescription
			NumPut(_BSTR(e.file ":" e.line), prm6+3*A_PtrSize) ; bstrHelpFile
			NumPut(0, prm6+4*A_PtrSize) ; dwHelpContext, padding
			NumPut(0, prm6+5*A_PtrSize) ; pvReserved
			NumPut(0, prm6+6*A_PtrSize) ; pfnDeferredFillIn
			NumPut(0x80020009, prm6+7*A_PtrSize, "UInt") ; scode
		}
		return 0x80020009 ; DISP_E_EXCEPTION
	}
	; Move the converted return value to the caller-supplied VARIANT. Also clear the ComVar.
	Loop, % sizeof_VARIANT // 8
	{
		idx := 8*(A_Index-1)
		/* try -> for v2.0-a
		 * NumPut() throws an 'Invalid parameter #2' error if 'prm5' is 0.
		 * This usually happens if user does not specify a variable to
		 * store the return value to. prm5=pVarResult -> see: http://goo.gl/2vT600
		 */
		try NumPut(NumGet(ret+idx, "Int64"), prm5+idx, "Int64")
		NumPut(0, ret+idx, "Int64")
	}
	
	return 0
}

_BSTR(ByRef a)
{
	return DllCall("oleaut32\SysAllocString", "wstr", a, "ptr")
}

_CoTaskMemAlloc(size)
{
	return DllCall("ole32\CoTaskMemAlloc", "ptr", size, "ptr")
}

_CoTaskMemFree(mem)
{
	DllCall("ole32\CoTaskMemAlloc", "ptr", mem)
}
;// For v1.1 and v2.0-a compatability
_ComObjParam(args*) ;// VarType, Value [, Flags]
{
	static ComObjP := A_AhkVersion < "2" ? "ComObjParameter" : "ComObject"
	return %ComObjP%(args*)
}