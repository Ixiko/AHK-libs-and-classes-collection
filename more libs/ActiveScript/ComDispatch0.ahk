;
; ComDispatch0 - Alternative version of fincs' ComDispatch() function
;
; Authors: fincs, Coco, Lexikos
;

ComDispatch0(this)
{
    static vtable := ComDispatch0_VTable()
    static id_to_name := [], name_to_id := []
    
    obj := {}, obj.SetCapacity("_", 2*A_PtrSize)
    obj_mem := obj.GetAddress("_")
    ,NumPut(&obj, NumPut(vtable, obj_mem+0))
    ,ObjAddRef(&obj)
    
    ,obj.name_to_id := name_to_id
    ,obj.id_to_name := id_to_name
    ,obj.pointer    := obj_mem
    ,obj.this       := this
    
    return ComObject(9, obj_mem, 1)
}

ComDispatch0_VTable()
{
    static vtable
    if !VarSetCapacity(vtable) {
        VarSetCapacity(vtable, 7 * A_PtrSize)
        for idx, cnt in [3,1,1,2,4,6,9]
            NumPut(RegisterCallback("ComDispatch0_", "", cnt, (idx-1)), vtable, (idx-1)*A_PtrSize)
    }
    return &vtable
}

ComDispatch0_Unwrap(ComObject)
{
    static vtable := ComDispatch0_VTable()
    return ComObjType(ComObject) = 9 && NumGet(ComObjValue(ComObject)) == vtable
        ?  Object(NumGet(ComObjValue(ComObject)+A_PtrSize)).this
        :  ComObject
}

ComDispatch0_(this_, prm0 := 0, prm1 := 0, prm2 := 0, prm3 := 0, prm4 := 0, prm5 := 0, prm6 := 0, prm7 := 0, prm8 := 0)
{
    Critical
    
    ; Get our object
    this := Object(this_ptr := NumGet(this_+A_PtrSize))
    
    goto cd0_%A_EventInfo%

cd0_0: ; IUnknown::QueryInterface
    ; Beware of the hack code!
     iid1 := NumGet(prm0+0, "Int64")
    ,iid2 := NumGet(prm0+8, "Int64")
    if (iid2 = 0x46000000000000C0) && (!iid1 || iid1 = 0x20400)
    {
        NumPut(this_, prm1+0), ObjAddRef(this_ptr)
        return 0
    }
    else
    {
        NumPut(0, prm1+0)
        return 0x80004002 ; E_NOINTERFACE
    }

cd0_1: ; IUnknown::AddRef
    return ObjAddRef(this_ptr)

cd0_2: ; IUnknown::Release
    return ObjRelease(this_ptr)

cd0_3: ; IDispatch::GetTypeInfoCount
    NumPut(0, prm0+0, "UInt")
    return 0

cd0_4: ; IDispatch::GetTypeInfo
    return 0x80004001 ; E_NOTIMPL

    ; All the funny 0xFF... masking in the code below is because
    ; of the x64 calling convention. For parameters whose size is
    ; < 64 bits, the upper bits are garbage. So we clear them out.

cd0_5: ; IDispatch::GetIDsOfNames
    status := 0, name := StrGet(NumGet(prm1+0), "UTF-16")
    if !(dispid := this.name_to_id[name])
    {
        dispid := this.id_to_name.Push(name)
        this.name_to_id[name] := dispid
    }
    NumPut(dispid, prm4 + 0, "int")
    Loop, % (prm2 & 0xFFFFFFFF) - 1
        NumPut(-1, prm4 + A_Index*4, "int") ; DISPID_UNKNOWN: -1
        , status := 0x80020006 ; DISP_E_UNKNOWNNAME
    return status

cd0_6: ; IDispatch::Invoke
    prm3 &= 0xFFFF
    name := this.id_to_name[prm0 &= 0xFFFFFFFF]
    if (name = "" && prm0 != 0)
        return 0x80020003 ; DISP_E_MEMBERNOTFOUND
     paramarray := NumGet(prm4+0)
    ,nparams := NumGet(prm4+2*A_PtrSize, "UInt")
    ,params := []
    if !nparams
        goto cd0_call
    else if NumGet(prm4+2*A_PtrSize+4, "UInt") != ((prm3 & 12) ? 1 : 0)
        return 0x80020007 ; DISP_E_NONAMEDARGS
    
    ; Make a SAFEARRAY out of the raw VARIANT array
    static pad := A_PtrSize = 8 ? 4 : 0, sizeof_SAFEARRAY := 20+pad+A_PtrSize, sizeof_VARIANT := 8+2*A_PtrSize
     VarSetCapacity(SAhdr, sizeof_SAFEARRAY, 0)
    ,NumPut(1, SAhdr, 0, "UShort")
    ,NumPut(0x0812, SAhdr, 2, "UShort") ; FADF_STATIC | FADF_FIXEDSIZE | FADF_VARIANT
    ,NumPut(sizeof_VARIANT, SAhdr, 4, "UInt")
    ,NumPut(paramarray, SAhdr, 12+pad)
    ,NumPut(nparams, SAhdr, 12+pad+A_PtrSize, "UInt")
    ,params_safearray := ComObject(0x200C, &SAhdr)
    
    ; Copy the parameters to a regular AutoHotkey array
    Loop % nparams
        ObjPush(params, params_safearray[idx := nparams - A_Index])
    Loop % nparams
    {
        a := params[A_Index]
        while ComObjType(a) = 0x400C ; VT_BYREF | VT_VARIANT
            NumPut(1, NumPut(ComObjValue(a), SAhdr, 12+pad), "UInt")
           ,a := params_safearray[0]
        params[A_Index] := ComDispatch0_Unwrap(a)
    }
    if (prm3 & 12)
        value := ObjPop(params)
    
cd0_call:
    ; Prepare a SAFEARRAY of VARIANT for converting the return value.
    ret := NumGet(ComObjValue(retarr:=ComObjArray(0xC,1)) + 8+A_PtrSize)
    
    ; Call the function
    try
    {
        if ((prm3 & 3) = 1)  ; DISPATCH_METHOD and not DISPATCH_PROPERTYGET
        {
            if (prm0 = 0) ; DISPID_VALUE: "call" the object itself
                name := this.this, retarr[0] := %name%(params*)
            else
                retarr[0] := (this.this)[name](params*)
        }
        else  ; Property
        {
            if (prm0 != 0) ; != DISPID_VALUE
                ObjInsertAt(params, 1, name)
            retarr[0] := (prm3 & 12)
                ? ((this.this)[params*] := value)
                : ((this.this)[params*])
        }
    }
    catch e
    {
        ; Clear caller-supplied VARIANT.
        if prm5
        Loop % sizeof_VARIANT // 8
            NumPut(0, prm5+8*(A_Index-1), "Int64")
        ; Fill exception info
        if prm6
        {
            NumPut(0, prm6+0) ; wCode, wReserved, padding
            NumPut(cd0_BSTR(e.what), prm6+A_PtrSize) ; bstrSource
            NumPut(cd0_BSTR(e.message), prm6+2*A_PtrSize) ; bstrDescription
            NumPut(cd0_BSTR(e.file ":" e.line), prm6+3*A_PtrSize) ; bstrHelpFile
            NumPut(0, prm6+4*A_PtrSize) ; dwHelpContext, padding
            NumPut(0, prm6+5*A_PtrSize) ; pvReserved
            NumPut(0, prm6+6*A_PtrSize) ; pfnDeferredFillIn
            NumPut(0x80020009, prm6+7*A_PtrSize, "UInt") ; scode
        }
        return 0x80020009 ; DISP_E_EXCEPTION
    }
    if prm5
    ; MOVE the converted return value to the caller-supplied VARIANT.
    Loop % sizeof_VARIANT // 8
    {
        idx := 8*(A_Index-1)
        NumPut(NumGet(ret+idx, "Int64"), prm5+idx, "Int64")
        NumPut(0, ret+idx, "Int64")
    }
    
    return 0
}

cd0_BSTR(ByRef a)
{
    return DllCall("oleaut32\SysAllocString", "wstr", a, "ptr")
}
