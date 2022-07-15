
#include %A_ScriptDir%\..\overload.ahk
#include %A_ScriptDir%\..\guid.ahk
#include %A_ScriptDir%\..\hstring.ahk
#include %A_ScriptDir%\..\rtmetadata.ahk
#include %A_ScriptDir%\..\rtinterface.ahk
#include %A_ScriptDir%\..\delegate.ahk
#include %A_ScriptDir%\..\struct.ahk

MAX_NAME_CCH := 1024

/*
  Core WinRT functions.
    - WinRT(classname) creates a runtime object.
    - WinRT(rtobj) "casts" rtobj to its most derived class.
    - WinRT(ptr) wraps a runtime interface pointer, taking ownership of the reference.
    - WinRT.GetType(name) returns a TypeInfo for the given type.
*/
class WinRT {
    static Call(p) => (
        p is String ? this.GetType(p).Class :
        p is Object ? (ObjAddRef(p.ptr), _rt_WrapInspectable(p.ptr)) :
        _rt_WrapInspectable(p)
    )

    static TypeCache := Map(
        "Guid", RtRootTypes.Guid,  ; Found in type names returned by GetRuntimeClassName.
        "System.Guid", RtRootTypes.Guid,  ; Resolved from metadata TypeRef.
        ; All WinRT typedefs tested on Windows 10.0.19043 derive from one of these.
        'System.Attribute', RtRootTypes.Attribute,
        'System.Enum', RtRootTypes.Enum,
        'System.MulticastDelegate', RtRootTypes.Delegate,
        'System.Object', RtRootTypes.Object,
        'System.ValueType', RtRootTypes.Struct,
    )
    static __new() {
        cache := this.TypeCache
        for e, t in _rt_GetElementTypeMap() {
            ; Map the simple types in cache, for parsing generic type names.
            cache[t.Name] := t
        }
        this.DefineProp('__set', {call: RtAny.__set})
    }

    static _CacheGetMetaData(typename, &td) {
        #DllLoad wintypes.dll
        DllCall("wintypes.dll\RoGetMetaDataFile"
            , "ptr", HStringFromString(typename)
            , "ptr", 0
            , "ptr", 0
            , "ptr*", m := RtMetaDataModule()
            , "uint*", &td := 0
            , "hresult")
        static cache := Map()
        ; Cache modules by filename to conserve memory and so cached property values
        ; can be used by all namespaces within the module.
        return cache.get(mn := m.Name, false) || cache[mn] := m
    }

    static _CacheGetTypeNS(name) {
        if !(p := InStr(name, ".",, -1))
            throw ValueError("Invalid typename", -1, name)
        static cache := Map()
        ; Cache module by namespace, since all types *directly* within a namespace
        ; must be defined within the same file (but child namespaces can be defined
        ; in a different file).
        try {
            if m := cache.get(ns := SubStr(name, 1, p-1), false) {
                ; Module already loaded - find the TypeDef within it.
                td := m.FindTypeDefByName(name)
            }
            else {
                ; Since we haven't seen this namespace before, let the system work out
                ; which module contains its metadata.
                cache[ns] := m := this._CacheGetMetaData(name, &td)
            }
        }
        catch OSError as e {
            if e.number = 0x80073D54 {
                e.message := "(0x80073D54) Type not found."
                e.extra := name
            }
            throw
        }
        return RtTypeInfo(m, td)
    }

    static _CacheGetType(name) {
        if p := InStr(name, "<") {
            baseType := this.GetType(baseName := SubStr(name, 1, p-1))
            typeArgs := []
            while RegExMatch(name, "\G([^<>,]++(?:<(?:(?1)(?:,|(?=>)))++>)?)(?=[,>])", &m, ++p) {
                typeArgs.Push(this.GetType(m.0))
                p += m.Len
            }
            if p != StrLen(name) + 1
                throw Error("Parse error or bad name.", -1, SubStr(name, p) || name)
            return {
                typeArgs: typeArgs,
                m: baseType.m, t: baseType.t,
                base: baseType.base
            }
        }
        return this._CacheGetTypeNS(name)
    }

    static GetType(name) {
        static cache := this.TypeCache
        ; Cache typeinfo by full name.
        return cache.get(name, false)
            || cache[name] := this._CacheGetType(name)
    }
}

class RtMetaDataModule extends MetaDataModule {
    GetTypeByToken(t, typeArgs:=false) {
        scope := -1
        switch (t >> 24) {
        case 0x01: ; TypeRef (most common)
            ; TODO: take advantage of GetTypeRefProps's scope parameter
            return WinRT.GetType(this.GetTypeRefProps(t))
        case 0x02: ; TypeDef
            MsgBox 'DEBUG: GetTypeByToken was called with a TypeDef token.`n`n' Error().Stack
            ; TypeDefs usually aren't referenced directly, so just resolve it by
            ; name to ensure caching works correctly.  Although GetType resolving
            ; the TypeDef will be a bit redundant, it should perform the same as
            ; if a TypeRef token was passed in.
            return WinRT.GetType(this.GetTypeDefProps(t))
        case 0x1b: ; TypeSpec
            ; GetTypeSpecFromToken
            ComCall(44, this, "uint", t, "ptr*", &psig:=0, "uint*", &nsig:=0)
            ; Signature: 0x15 0x12 <typeref> <argcount> <args>
            nsig += psig++
            return _rt_DecodeSigGenericInst(this, &psig, nsig, typeArgs)
        default:
            throw Error(Format("Cannot resolve token 0x{:08x} to type info.", t), -1)
        }
    }
}

_rt_WrapInspectable(p, typeinfo:=false) {
    if !p
        return
    ; IInspectable::GetRuntimeClassName
    hr := ComCall(4, p, "ptr*", &hcls:=0, "int")
    if hr >= 0 {
        cls := HStringRet(hcls)
        if !typeinfo || !InStr(cls, "<")
            typeinfo := WinRT.GetType(cls)
        ; else it's not a full runtime class, so just use the predetermined typeinfo.
    }
    else if !typeinfo || hr != -2147467263 { ; E_NOTIMPL
        e := OSError(hr)
        e.Message := "IInspectable::GetRuntimeClassName failed`n`t" e.Message
        throw e
    }
    return {
        ptr: p,
        base: typeinfo.Class.prototype
    }
}


_rt_memoize(this, propname, f := unset) {
    value := IsSet(f) ? f(this) : this._init_%propname%()
    this.DefineProp propname, {value: value}
    return value
}
