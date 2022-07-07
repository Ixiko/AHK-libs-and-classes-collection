/*
 *  ActiveScript for AutoHotkey v1.1
 *
 *  Provides an interface to Active Scripting languages like VBScript and JScript,
 *  without relying on Microsoft's ScriptControl, which is not available to 64-bit
 *  programs.
 *
 *  License: Use, modify and redistribute without limitation, but at your own risk.
 */
class ActiveScript extends ActiveScript._base
{
    __New(Language)
    {
        if this._script := ComObjCreate(Language, ActiveScript.IID)
            this._scriptParse := ComObjQuery(this._script, ActiveScript.IID_Parse)
        if !this._scriptParse
            throw Exception("Invalid language", -1, Language)
        this._site := new ActiveScriptSite(this)
        this._SetScriptSite(this._site.ptr)
        this._InitNew()
        this._objects := {}
        this.Error := ""
        this._dsp := this._GetScriptDispatch()  ; Must be done last.
        try
            if this.ScriptEngine() = "JScript"
                this.SetJScript58()
    }

    SetJScript58()
    {
        static IID_IActiveScriptProperty := "{4954E0D0-FBC7-11D1-8410-006008C3FBFC}"
        if !prop := ComObjQuery(this._script, IID_IActiveScriptProperty)
            return false
        VarSetCapacity(var, 24, 0), NumPut(2, NumPut(3, var, "short") + 6)
        hr := DllCall(NumGet(NumGet(prop+0)+4*A_PtrSize), "ptr", prop, "uint", 0x4000
            , "ptr", 0, "ptr", &var), ObjRelease(prop)
        return hr >= 0
    }
    
    Eval(Code)
    {
        pvar := NumGet(ComObjValue(arr:=ComObjArray(0xC,1)) + 8+A_PtrSize)
        this._ParseScriptText(Code, 0x20, pvar)  ; SCRIPTTEXT_ISEXPRESSION := 0x20
        return arr[0]
    }
    
    Exec(Code)
    {
        this._ParseScriptText(Code, 0x42, 0)  ; SCRIPTTEXT_ISVISIBLE := 2, SCRIPTTEXT_ISPERSISTENT := 0x40
        this._SetScriptState(2)  ; SCRIPTSTATE_CONNECTED := 2
    }
    
    AddObject(Name, DispObj, AddMembers := false)
    {
        static a, supports_dispatch ; Test for built-in IDispatch support.
            := a := ((a:=ComObjArray(0xC,1))[0]:=[42]) && a[0][1]=42
        if IsObject(DispObj) && !(supports_dispatch || ComObjType(DispObj))
            throw Exception("Adding a non-COM object requires AutoHotkey v1.1.17+", -1)
        this._objects[Name] := DispObj
        this._AddNamedItem(Name, AddMembers ? 8 : 2)  ; SCRIPTITEM_ISVISIBLE := 2, SCRIPTITEM_GLOBALMEMBERS := 8
    }
    
    _GetObjectUnk(Name)
    {
        return !IsObject(dsp := this._objects[Name]) ? dsp  ; Pointer
            : ComObjValue(dsp) ? ComObjValue(dsp)  ; ComObject
            : &dsp  ; AutoHotkey object
    }
    
    class _base
    {
        __Call(Method, Params*)
        {
            if ObjHasKey(this, "_dsp")
                try
                    return (this._dsp)[Method](Params*)
                catch e
                    throw Exception(e.Message, -1, e.Extra)
        }
        
        __Get(Property, Params*)
        {
            if ObjHasKey(this, "_dsp")
                try
                    return (this._dsp)[Property, Params*]
                catch e
                    throw Exception(e.Message, -1, e.Extra)
        }
        
        __Set(Property, Params*)
        {
            if ObjHasKey(this, "_dsp")
            {
                Value := Params.Pop()
                try
                    return (this._dsp)[Property, Params*] := Value
                catch e
                    throw Exception(e.Message, -1, e.Extra)
            }
        }
    }
    
    _SetScriptSite(Site)
    {
        hr := DllCall(NumGet(NumGet((p:=this._script)+0)+3*A_PtrSize), "ptr", p, "ptr", Site)
        if (hr < 0)
            this._HRFail(hr, "IActiveScript::SetScriptSite")
    }
    
    _SetScriptState(State)
    {
        hr := DllCall(NumGet(NumGet((p:=this._script)+0)+5*A_PtrSize), "ptr", p, "int", State)
        if (hr < 0)
            this._HRFail(hr, "IActiveScript::SetScriptState")
    }
    
    _AddNamedItem(Name, Flags)
    {
        hr := DllCall(NumGet(NumGet((p:=this._script)+0)+8*A_PtrSize), "ptr", p, "wstr", Name, "uint", Flags)
        if (hr < 0)
            this._HRFail(hr, "IActiveScript::AddNamedItem")
    }
    
    _GetScriptDispatch()
    {
        hr := DllCall(NumGet(NumGet((p:=this._script)+0)+10*A_PtrSize), "ptr", p, "ptr", 0, "ptr*", pdsp)
        if (hr < 0)
            this._HRFail(hr, "IActiveScript::GetScriptDispatch")
        return ComObject(9, pdsp, 1)
    }
    
    _InitNew()
    {
        hr := DllCall(NumGet(NumGet((p:=this._scriptParse)+0)+3*A_PtrSize), "ptr", p)
        if (hr < 0)
            this._HRFail(hr, "IActiveScriptParse::InitNew")
    }
    
    _ParseScriptText(Code, Flags, pvarResult)
    {
        VarSetCapacity(excp, 8 * A_PtrSize, 0)
        hr := DllCall(NumGet(NumGet((p:=this._scriptParse)+0)+5*A_PtrSize), "ptr", p
            , "wstr", Code, "ptr", 0, "ptr", 0, "ptr", 0, "uptr", 0, "uint", 1
            , "uint", Flags, "ptr", pvarResult, "ptr", 0)
        if (hr < 0)
            this._HRFail(hr, "IActiveScriptParse::ParseScriptText")
    }
    
    _HRFail(hr, what)
    {
        if e := this.Error
        {
            this.Error := ""
            throw Exception("`nError code:`t" this._HRFormat(e.HRESULT)
                . "`nSource:`t`t" e.Source "`nDescription:`t" e.Description
                . "`nLine:`t`t" e.Line "`nColumn:`t`t" e.Column
                . "`nLine text:`t`t" e.LineText, -3)
        }
        throw Exception(what " failed with code " this._HRFormat(hr), -2)
    }
    
    _HRFormat(hr)
    {
        return Format("0x{1:X}", hr & 0xFFFFFFFF)
    }
    
    _OnScriptError(err) ; IActiveScriptError err
    {
        VarSetCapacity(excp, 8 * A_PtrSize, 0)
        DllCall(NumGet(NumGet(err+0)+3*A_PtrSize), "ptr", err, "ptr", &excp) ; GetExceptionInfo
        DllCall(NumGet(NumGet(err+0)+4*A_PtrSize), "ptr", err, "uint*", srcctx, "uint*", srcline, "int*", srccol) ; GetSourcePosition
        DllCall(NumGet(NumGet(err+0)+5*A_PtrSize), "ptr", err, "ptr*", pbstrcode) ; GetSourceLineText
        code := StrGet(pbstrcode, "UTF-16"), DllCall("OleAut32\SysFreeString", "ptr", pbstrcode)
        if fn := NumGet(excp, 6 * A_PtrSize) ; pfnDeferredFillIn
            DllCall(fn, "ptr", &excp)
        wcode := NumGet(excp, 0, "ushort")
        hr := wcode ? 0x80040200 + wcode : NumGet(excp, 7 * A_PtrSize, "uint")
        this.Error := {HRESULT: hr, Line: srcline, Column: srccol, LineText: code}
        static Infos := "Source,Description,HelpFile"
        Loop Parse, % Infos, `,
            if pbstr := NumGet(excp, A_Index * A_PtrSize)
                this.Error[A_LoopField] := StrGet(pbstr, "UTF-16"), DllCall("OleAut32\SysFreeString", "ptr", pbstr)
        return 0x80004001 ; E_NOTIMPL (let Exec/Eval get a fail result)
    }
    
    __Delete()
    {
        if this._script
        {
            DllCall(NumGet(NumGet((p:=this._script)+0)+7*A_PtrSize), "ptr", p)  ; Close
            ObjRelease(this._script)
        }
        if this._scriptParse
            ObjRelease(this._scriptParse)
    }
    
    static IID := "{BB1A2AE1-A4F9-11cf-8F20-00805F2CD064}"
    static IID_Parse := A_PtrSize=8 ? "{C7EF7658-E1EE-480E-97EA-D52CB4D76D17}" : "{BB1A2AE2-A4F9-11cf-8F20-00805F2CD064}"
}

class ActiveScriptSite
{
    __New(Script)
    {
        ObjSetCapacity(this, "_site", 3 * A_PtrSize)
        NumPut(&Script
        , NumPut(ActiveScriptSite._vftable("_vft_w", "31122", 0x100)
        , NumPut(ActiveScriptSite._vftable("_vft", "31125232211", 0)
            , this.ptr := ObjGetAddress(this, "_site"))))
    }
    
    _vftable(Name, PrmCounts, EIBase)
    {
        if p := ObjGetAddress(this, Name)
            return p
        ObjSetCapacity(this, Name, StrLen(PrmCounts) * A_PtrSize)
        p := ObjGetAddress(this, Name)
        Loop Parse, % PrmCounts
        {
            cb := RegisterCallback("_ActiveScriptSite", "F", A_LoopField, A_Index + EIBase)
            NumPut(cb, p + (A_Index-1) * A_PtrSize)
        }
        return p
    }
}

_ActiveScriptSite(this, a1:=0, a2:=0, a3:=0, a4:=0, a5:=0)
{
    Method := A_EventInfo & 0xFF
    if A_EventInfo >= 0x100  ; IActiveScriptSiteWindow
    {
        if Method = 4  ; GetWindow
        {
            NumPut(0, a1+0) ; *phwnd := 0
            return 0 ; S_OK
        }
        if Method = 5  ; EnableModeless
        {
            return 0 ; S_OK
        }
        this -= A_PtrSize     ; Cast to IActiveScriptSite
    }
    ;else: IActiveScriptSite
    if Method = 1  ; QueryInterface
    {
        iid := _AS_GUIDToString(a1)
        if (iid = "{00000000-0000-0000-C000-000000000046}"  ; IUnknown
         || iid = "{DB01A1E3-A42B-11cf-8F20-00805F2CD064}") ; IActiveScriptSite
        {
            NumPut(this, a2+0)
            return 0 ; S_OK
        }
        if (iid = "{D10F6761-83E9-11cf-8F20-00805F2CD064}") ; IActiveScriptSiteWindow
        {
            NumPut(this + A_PtrSize, a2+0)
            return 0 ; S_OK
        }
        NumPut(0, a2+0)
        return 0x80004002 ; E_NOINTERFACE
    }
    if Method = 5  ; GetItemInfo
    {
        a1 := StrGet(a1, "UTF-16")
        , (a3 && NumPut(0, a3+0))  ; *ppiunkItem := NULL
        , (a4 && NumPut(0, a4+0))  ; *ppti := NULL
        if (a2 & 1) ; SCRIPTINFO_IUNKNOWN
        {
            if !(unk := Object(NumGet(this + A_PtrSize*2))._GetObjectUnk(a1))
                return 0x8002802B ; TYPE_E_ELEMENTNOTFOUND
            ObjAddRef(unk), NumPut(unk, a3+0)
        }
        return 0 ; S_OK
    }
    if Method = 9  ; OnScriptError
        return Object(NumGet(this + A_PtrSize*2))._OnScriptError(a1)
    
    ; AddRef and Release don't do anything because we want to avoid circular references.
    ; The site and IActiveScript are both released when the AHK script releases its last
    ; reference to the ActiveScript object.
    
    ; All of the other methods don't require implementations.
    return 0x80004001 ; E_NOTIMPL
}

_AS_GUIDToString(pGUID)
{
    VarSetCapacity(String, 38*2)
    DllCall("ole32\StringFromGUID2", "ptr", pGUID, "str", String, "int", 39)
    return String
}
