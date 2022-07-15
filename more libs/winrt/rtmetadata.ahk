
class MetaDataModule {
    ptr := 0
    __delete() {
        (p := this.ptr) && ObjRelease(p)
    }
    StaticAttr => _rt_CacheAttributeCtors(this, this, 'StaticAttr')
    FactoryAttr => _rt_CacheAttributeCtors(this, this, 'FactoryAttr')
    ActivatableAttr => _rt_CacheAttributeCtors(this, this, 'ActivatableAttr')
    ComposableAttr => _rt_CacheAttributeCtors(this, this, 'ComposableAttr')
    
    ObjectTypeRef => _rt_memoize(this, 'ObjectTypeRef')
    _init_ObjectTypeRef() {
        mdai := ComObjQuery(this, "{EE62470B-E94B-424e-9B7C-2F00C9249F93}") ; IID_IMetaDataAssemblyImport
        asm := _rt_FindAssemblyRef(mdai, "mscorlib") || 1
        ; FindTypeRef
        if ComCall(55, this, "uint", asm, "wstr", "System.Object", "uint*", &tr:=0, "int") != 0 {
            ; System.Object not found
            ; @Debug-Breakpoint
            return -1
        }
        return tr
    }
    
    AddFactoriesToWrapper(w, t) {
        if t.HasIActivationFactory {
            this.AddIActivationFactoryToWrapper(w)
        }
        for f in t.Factories() {
            this.AddInterfaceToWrapper(w, f, false, "Call")
        }
        for f in t.Composers() {
            this.AddInterfaceToWrapper(w, f, false, "Call")
            if w.HasOwnProp("Call")
                AddMethodOverloadTo(w, "Call", w => w(0, 0), w.prototype.__class ".")
        }
    }
    
    AddIActivationFactoryToWrapper(w) {
        ActivateInstance(cls) {
            ComCall(6, ComObjQuery(cls, "{00000035-0000-0000-C000-000000000046}") ; IActivationFactory
                , "ptr*", inst := {base: cls.prototype})
            return inst
        }
        AddMethodOverloadTo(w, "Call", ActivateInstance, w.prototype.__class ".")
    }
    
    CreateInterfaceWrapper(t) {
        t_name := t.Name, base := RtObject
        switch 1 {
            case InStr(t_name, "Windows.Foundation.IAsync"): base := IAsyncInfo
            case InStr(t_name, "Windows.Foundation.Collections.IVector"): base := IVector
            case InStr(t_name, "Windows.Foundation.Collections.IIterator``"): base := IIterator
        }
        w := _rt_CreateClass(t_name, base)
        t.DefineProp 'Class', {value: w}
        this.AddInterfaceToWrapper(w.prototype, t, true)
        wrapped := Map()
        addreq(w.prototype, t)
        addreq(w, t) {
            for ti in t.Implements() {
                if wrapped.Has(ti_name := ti.Name)
                    continue
                wrapped[ti_name] := true
                ti.m.AddInterfaceToWrapper(w, ti, false)
                addreq(w, ti)
            }
        }
        return w
    }
    
    CreateClassWrapper(t) {
        w := _rt_CreateClass(classname := t.Name, t.SuperType.Class)
        t.DefineProp 'Class', {value: w}
        ; Add any constructors:
        this.AddFactoriesToWrapper(w, t)
        ; Add static interfaces to the class:
        for ti in t.Statics() {
            this.AddInterfaceToWrapper(w, ti)
        }
        ; Need a factory?
        if ObjOwnPropCount(w) > 1 {
            static oiid := GUID("{AF86E2E0-B12D-4c6a-9C5A-D7AA65101E90}") ; IInspectable
            hr := DllCall("combase.dll\RoGetActivationFactory"
                , "ptr", HStringFromString(classname)
                , "ptr", oiid
                , "ptr*", w, "hresult")
        }
        wrapped := Map()
        addRequiredInterfaces(wp, t, isclass) {
            for ti, impl in t.Implements() {
                ; GetCustomAttributeByName
                isdefault := isclass && ComCall(60, this, "uint", impl
                    , "wstr", "Windows.Foundation.Metadata.DefaultAttribute"
                    , "ptr", 0, "ptr", 0) = 0
                if isdefault {
                    ; This is currently assigned to the Class and not t so that
                    ; t.Class.__DefaultInterface will cause this code to execute
                    ; if needed (i.e. if the class hasn't been wrapped yet).
                    w.DefineProp '__DefaultInterface', {value: ti}
                }
                if wrapped.has(ti_name := ti.Name)
                    continue
                wrapped[ti_name] := true
                ti.m.AddInterfaceToWrapper(wp, ti, isdefault)
                ; Interfaces "required" by ti are also implemented by the class
                ; even if it doesn't "require" them directly (sometimes it does).
                addRequiredInterfaces(wp, ti, false)
            }
        }
        ; Add instance interfaces:
        addRequiredInterfaces(w.prototype, t, true)
        return w
    }
    
    AddInterfaceToWrapper(w, t, isdefault:=false, nameoverride:=false) {
        pguid := t.GUID
        if !pguid {
            ; @Debug-Output => Interface {t.Name} can't be added because it has no GUID
            return
        }
        namebuf := Buffer(2*MAX_NAME_CCH)
        DllCall("ole32\StringFromGUID2", "ptr", pguid, "ptr", namebuf, "int", MAX_NAME_CCH)
        iid := StrGet(namebuf)
        name_prefix := w.HasOwnProp('prototype') ? w.prototype.__class "." : w.__class ".Prototype."
        for method in t.Methods() {
            name := nameoverride ? nameoverride : method.name
            types := t.MethodArgTypes(method.sig)
            wrapper := MethodWrapper(5 + A_Index, iid, types, name_prefix name)
            if method.flags & 0x400 { ; tdSpecialName
                switch SubStr(name, 1, 4) {
                case "get_":
                    w.DefineProp(SubStr(name, 5), {Get: wrapper})
                    continue
                case "put_":
                    w.DefineProp(SubStr(name, 5), {Set: wrapper})
                    continue
                }
            }
            AddMethodOverloadTo(w, name, wrapper, name_prefix)
        }
    }
    
    FindTypeDefByName(name) {
        ComCall(9, this, "wstr", name, "uint", 0, "uint*", &r:=0)
        return r
    }
    
    GetTypeDefProps(td, &flags:=0, &basetd:=0) {
        namebuf := Buffer(2*MAX_NAME_CCH)
        ; GetTypeDefProps
        ComCall(12, this, "uint", td
            , "ptr", namebuf, "uint", namebuf.Size//2, "uint*", &namelen:=0
            , "uint*", &flags:=0, "uint*", &basetd:=0)
        ; Testing shows namelen includes a null terminator, but the docs aren't
        ; clear, so rely on StrGet's positive-length behaviour to truncate.
        return StrGet(namebuf, namelen, "UTF-16")
    }
    
    GetTypeRefProps(r, &scope:=unset) {
        namebuf := Buffer(2*MAX_NAME_CCH)
        ComCall(14, this, "uint", r, "uint*", &scope:=0
            , "ptr", namebuf, "uint", namebuf.size//2, "uint*", &namelen:=0)
        return StrGet(namebuf, namelen, "UTF-16")
    }
    
    GetGuidPtr(td) {
        ; GetCustomAttributeByName
        if ComCall(60, this, "uint", td
            , "wstr", "Windows.Foundation.Metadata.GuidAttribute"
            , "ptr*", &pguid:=0, "uint*", &nguid:=0) != 0
            return 0
        ; Attribute is serialized with leading 16-bit version (1) and trailing 16-bit number of named args (0).
        if nguid != 20
            throw Error("Unexpected GuidAttribute data length: " nguid)
        return pguid + 2
    }
    
    EnumMethods(td)                 => _rt_Enumerator(18, this, "uint", td)
    EnumCustomAttributes(td, tctor) => _rt_Enumerator(53, this, "uint", td, "uint", tctor)
    EnumTypeDefs()                  => _rt_Enumerator(6, this)
    EnumInterfaceImpls(td)          => _rt_Enumerator(7, this, "uint", td)
    
    Name {
        get {
            namebuf := Buffer(2*MAX_NAME_CCH)
            ; GetScopeProps
            ComCall(10, this, "ptr", namebuf, "uint", namebuf.Size//2, "uint*", &namelen:=0, "ptr", 0)
            return StrGet(namebuf, namelen, "UTF-16")
        }
    }
    
    static Open(path) {
        static CLSID_CorMetaDataDispenser := GUID("{E5CB7A31-7512-11d2-89CE-0080C792E5D8}")
        static IID_IMetaDataDispenser := GUID("{809C652E-7396-11D2-9771-00A0C9B4D50C}")
        static IID_IMetaDataImport := GUID("{7DAC8207-D3AE-4C75-9B67-92801A497D44}")
        #DllLoad rometadata.dll
        DllCall("rometadata.dll\MetaDataGetDispenser"
            , "ptr", CLSID_CorMetaDataDispenser, "ptr", IID_IMetaDataDispenser
            , "ptr*", mdd := ComValue(13, 0), "hresult")
        ; IMetaDataDispenser::OpenScope
        ComCall(4, mdd, "wstr", path, "uint", 0
            , "ptr", IID_IMetaDataImport
            , "ptr*", mdm := this())
        return mdm
    }
}

_rt_Enumerator(args*) => _rt_Enumerator_f(false, args*)

_rt_Enumerator_f(f, methodidx, this, args*) {
    henum := index := count := 0
    ; Getting the items in batches improves performance, with diminishing returns.
    buf := Buffer(4 * batch_size:=32)
    ; Prepare the args for ComCall, with the caller's extra args in the middle.
    args.InsertAt(1, methodidx, this, "ptr*", &henum)
    args.Push("ptr", buf, "uint", batch_size, "uint*", &count)
    ; Call CloseEnum when finished enumerating.
    args.__delete := args => ComCall(3, this, "uint", henum, "int")
    next(&item) {
        if index = count {
            index := 0
            if ComCall(args*) ; S_FALSE (1) means no items.
                return false
        }
        item := NumGet(buf, (index++) * 4, "uint")
        (f) && f(&item)
        return true
    }
    return next
}

_rt_FindAssemblyRef(mdai, target_name) {
    namebuf := Buffer(2*MAX_NAME_CCH)
    ; EnumAssemblyRefs
    for asm in _rt_Enumerator(8, mdai) {
        ; GetAssemblyRefProps
        ComCall(4, mdai , "uint", asm, "ptr", 0, "ptr", 0
            , "ptr", namebuf, "uint", namebuf.Size//2, "uint*", &namelen:=0
            , "ptr", 0, "ptr", 0, "ptr", 0, "ptr", 0)
        if StrGet(namebuf, namelen, "UTF-16") = target_name
            return asm
    }
    return 0
}

_rt_CacheAttributeCtors(mdi, o, retprop) {
    mdai := ComObjQuery(mdi, "{EE62470B-E94B-424e-9B7C-2F00C9249F93}") ; IID_IMetaDataAssemblyImport
    ; Currently we assume if there's no reference to Windows.Foundation,
    ; the current scope of mdi (mdModule(1)) is Windows.Foundation.
    asm := _rt_FindAssemblyRef(mdai, "Windows.Foundation") || 1
    
    defOnce(o, n, v) {
        if o.HasOwnProp(n)  ; We currently only support one constructor overload for each usage.
            && o.%n% != v
            throw Error("Conflicting constructor found for " n, -1)
        o.DefineProp n, {value: v}
    }
    
    searchFor(attrType, nameForSig) {
        ; FindTypeRef
        if ComCall(55, mdi, "uint", asm, "wstr", attrType, "uint*", &tr:=0, "int") != 0 {
            defOnce(o, nameForSig(0), -1)
            return
        }
        ; EnumMemberRefs
        for mr in _rt_Enumerator(23, mdi, "uint", tr) {
            ; GetMemberRefProps
            ComCall(31, mdi, "uint", mr, "uint*", &ttype:=0
                , "ptr", 0, "uint", 0, "ptr", 0
                , "ptr*", &psig:=0, "uint*", &nsig:=0)
            defOnce(o, nameForSig(psig), mr)
        }
        else {
            ; This module doesn't contain any references to attrType, so none of
            ; its typedefs use that attribute.  Set -1 (invalid) to avoid reentry.
            defOnce(o, nameForSig(0), -1)
        }
    }
    
    searchFor("Windows.Foundation.Metadata.StaticAttribute"
        , psig => 'StaticAttr')
    
    searchFor("Windows.Foundation.Metadata.ActivatableAttribute"
        , psig => NumGet(psig, 3, "uchar") = 9 ? 'ActivatableAttr' : 'FactoryAttr') ; 9 = uint (first arg is uint, not interface name)
    
    searchFor("Windows.Foundation.Metadata.ComposableAttribute"
        , psig => 'ComposableAttr')
    
    return o.%retprop%
}

_rt_GetFieldConstant(mdi, field) {
    mdt := ComObjQuery(mdi, "{D8F579AB-402D-4B8E-82D9-5D63B1065C68}") ; IMetaDataTables
    
    static tabConstant := 11, GetTableInfo := 9
    ComCall(GetTableInfo, mdt, "uint", tabConstant
        , "ptr", 0, "uint*", &cRows := 0, "ptr", 0, "ptr", 0, "ptr", 0)
    
    static colType := 0, colParent := 1, colValue := 2, GetColumn := 13, GetBlob := 15
    Loop cRows {
        ComCall(GetColumn, mdt, "uint", tabConstant, "uint", colParent, "uint", A_Index, "uint*", &value:=0)
        if value != field
            continue
        ComCall(GetColumn, mdt, "uint", tabConstant, "uint", colValue, "uint", A_Index, "uint*", &value:=0)
        ComCall(GetBlob, mdt, "uint", value, "uint*", &ndata:=0, "ptr*", &pdata:=0)
        ComCall(GetColumn, mdt, "uint", tabConstant, "uint", colType, "uint", A_Index, "uint*", &value:=0)
        ; Type must be one of the basic element types (2..14) or CLASS (18) with value 0.
        ; WinRT only uses constants for enums, always I4 (8) or U4 (9).
        static primitives := _rt_GetElementTypeMap()
        return primitives[value].ReadWriteInfo.GetReader()(pdata)
        ;return {ptr: pdata, size: ndata}
    }
}

_rt_GetElementTypeMap() {
    static etm
    if !IsSet(etm) {
        etm := Map()
        eta := [
            0x1, 'Void',
            0x2, 'Boolean',
            0x3, 'Char16',
            0x4, 'Int8',
            0x5, 'UInt8',
            0x6, 'Int16',
            0x7, 'UInt16',
            0x8, 'Int32',
            0x9, 'UInt32',
            0xa, 'Int64',
            0xb, 'UInt64',
            0xc, 'Single',
            0xd, 'Double',
            0xe, 'String',
            0x18, 'IntPtr',
            0x1c, 'Object',
        ]
        i := 1
        loop eta.length//2 {
            etm[eta[i]] := RtRootTypes.%eta[i+1]%
            i += 2
        }
    }
    return etm
}

MethodWrapper(idx, iid, types, name:=unset) {
    rettype := types.RemoveAt(1)
    cca := [] ;, cca.Length := 1 + 2*types.Length, ccac := 0
    stn := Map()
    if iid
        stn[1] := ComObjQuery.Bind( , iid)
    args_to_expand := Map()
    for t in types {
        if pass := t.ArgPassInfo {
            if pass.ScriptToNative
                stn[1 + A_Index] := pass.ScriptToNative
            cca.Push( , pass.NativeType)
        }
        else {
            if !InStr('Struct|Guid', String(t.FundamentalType))
                MsgBox 'DEBUG: arg type ' String(t) ' of ' name ' is not a struct and has no ArgPassInfo'
            arg_size := t.Size
            if arg_size <= 8 || A_PtrSize = 4 {
                ; On x86, all structs need to be copied by value into the parameter list.
                ; On x64, structs <= 8 bytes need to be copied but larger structs are
                ; passed by value.
                ; Not sure how ARM64 does it.
                args_to_expand[A_Index + 1] := arg_size  ; +1 to account for `this`
                loop ceil(arg_size / A_PtrSize)
                    cca.Push( , 'ptr')
            }
            else {
                ; Large struct to be passed by address.
                cca.Push( , 'ptr')
            }
            ; TODO: check type of incoming parameter value
        }
    }
    if rettype != FFITypes.Void {
        if pass := rettype.ArgPassInfo {
            fri := () => &newvarref := 0
            cca.Push( , pass.NativeType '*')
            frr := ((nts, &ref) => nts(ref)).Bind(pass.NativeToScript || Number)
        }
        else {
            ; Struct?
            if !InStr('Struct|Guid', String(rettype.FundamentalType))
                MsgBox 'DEBUG: return type ' String(rettype) ' of ' name ' is not a struct and has no ArgPassInfo'
            fri := rettype.Class
            cca.Push( , 'ptr')
            frr := false
        }
    }
    else {
        frr := fri := false
    }
    ; Build the core ComCall function with predetermined type parameters.
    fc := ComCall.Bind(idx, cca*)
    ; Define internal properties for use by _rt_call.
    if IsSet(name)
        fc.DefineProp 'Name', {value: name}  ; For our use debugging; has no effect on any built-in stuff.
    fc.DefineProp 'MinParams', pv := {value: 1 + types.Length}  ; +1 for `this`
    fc.DefineProp 'MaxParams', pv
    ; Compose the ComCall and parameter filters into a function.
    fc := _rt_call.Bind(fc, stn, fri, frr)
    if args_to_expand.Count
        fc := _rt_get_struct_expander(args_to_expand, fc)
    ; Define external properties for use by OverloadedFunc and others.
    fc.DefineProp 'MinParams', pv
    fc.DefineProp 'MaxParams', pv
    return fc
}


_rt_get_struct_expander(sizes, fc) {
    ; Map the incoming parameter index and size to outgoing parameter index and size.
    ismap := Map(), offset := 0
    for i, size in sizes {
        if !IsSet(size)
            continue
        ismap[i + offset] := size
        offset += Ceil(size / A_PtrSize) - 1
    }
    return _rt_expand_struct_args.Bind(ismap, fc)
}

_rt_expand_struct_args(ismap, fc, args*) {
    for i, size in ismap {
        ; Removing struct from args shouldn't cause its destructor to be called (when this
        ; function returns) because it should still be on the caller's stack.  For simple
        ; structs it doesn't matter either way, because their values are copied here.
        struct := args.RemoveAt(i), new_args := []
        ; This specifically allows NumGet to read past the end of the struct when the size
        ; is not a multiple of A_PtrSize, with the additional bytes being "undefined".
        ptr := struct.ptr, endptr := ptr + struct.size
        while ptr < endptr
            new_args.Push(NumGet(ptr, 'ptr')), ptr += A_PtrSize
        args.InsertAt(i, new_args*)
    }
    return fc(args*)
}

_rt_rethrow(fc, e) {
    e.Stack := RegExReplace(e.Stack, 'm)^\Q' StrReplace(A_LineFile, '\E', '\E\\E\Q') '\E \(\d+\) :.*\R',, &count)
    if count && RegExMatch(e.Stack, '^(?<File>.*) \((?<Line>\d+)\) :', &m) {
        e.Stack := StrReplace(e.Stack, '[Func.Prototype.Call]', '[' fc.Name ']')
        e.File := m.File, e.Line := m.Line
    }
    throw
}

_rt_call(fc, fa, fri, frr, args*) {
    try {
        if args.Length != fc.MinParams
            throw Error(Format('Too {} parameters passed to function {}.', args.Length < fc.MinParams ? 'few' : 'many', fc.Name), -1)
        for i, f in fa
            args[i] := f(args[i])
        (fri) && args.Push(fri())
        fc(args*)
        return frr ? frr(args.Pop()) : fri ? args.Pop() : ""
    } catch OSError as e {
        _rt_rethrow(fc, e)
    }
}


class RtAny {
    static __new() {
        if this = RtAny ; Subclasses will inherit it anyway.
            this.DefineProp('__set', {call: this.prototype.__set})
    }
    static Call(*) {
        throw Error("This class is abstract and cannot be constructed.", -1, this.prototype.__class)
    }
    __set(name, *) {
        throw PropertyError(Format('This value of type "{}" has no property named "{}".', type(this), name), -1)
    }
}

class RtObject extends RtAny {
    static __new() {
        this.DefineProp('ptr', {value: 0})
        this.prototype.DefineProp('ptr', {value: 0})
        this.DefineProp('__delete', {call: this.prototype.__delete})
    }
    __delete() {
        (this.ptr) && ObjRelease(this.ptr)
    }
}

class IAsyncInfo extends RtObject {
    await() {
        loop
            Sleep 10
        until this.Status.n ; Non-zero means Completed, Canceled or Error in this case.
        return this.GetResults() ; Should throw if Canceled or Error.
    }
}

class IVector extends RtObject {
    __Item[index] {
        get => this.GetAt(index - 1)
        set => this.SetAt(index - 1, Value)
    }
    Length => this.Size
    __Enum(n) {
        l := this.Size, i := 0
        return (&v, *) => i < l ? (v := this.GetAt(i++), true) : false
    }
}

class IIterator extends RtObject {
    __Enum(n) => (&v, *) => this.HasCurrent ? (v := this.Current, this.MoveNext(), true) : false
}

_rt_CreateClass(classname, baseclass) {
    w := Class()
    w.base := baseclass
    w.prototype := {__class: classname, base: baseclass.prototype}
    return w
}

_rt_CreateStructWrapper(t) {
    w := _rt_CreateClass(t.Name, ValueType)
    t.DefineProp 'Class', {value: w}
    wp := w.prototype
    offset := 0, alignment := 1
    readwriters := Map(), destructors := []
    for f in t.Fields() {
        ft := f.type
        rwi := ReadWriteInfo.ForType(ft)
        fsize := rwi.Size
        falign := rwi.HasProp('Align') ? rwi.Align : fsize
        offset := align(offset, fsize)
        wp.DefineProp f.name, {
            get: reader := rwi.GetReader(offset),
            set: writer := rwi.GetWriter(offset)
        }
        readwriters[reader] := writer
        if fd := rwi.GetDeleter(offset)
            destructors.Push(fd)
        if alignment < falign
            alignment := falign
        offset += fsize
    }
    align(n, to) => (n + (to - 1)) // to * to
    w.DefineProp 'Align', {value: alignment}
    wp.DefineProp 'Size', {value: align(offset, alignment)}
    if destructors.Length {
        struct_delete(destructors, this) {
            if this.HasProp('_outer_') ; Lifetime managed by outer RtStruct.
                return
            for d in destructors
                try
                    d(this)
                catch as e ; Ensure all destructors are called ...
                    thrown := e
            if IsSet(thrown)
                throw thrown ; ... and the last error is reported.
        }
        struct_copy(readwriters, this, ptr) {
            for reader, writer in readwriters
                writer(ptr, reader(this))
        }
        wp.DefineProp 'CopyToPtr', {call: struct_copy.Bind(readwriters)}
        wp.DefineProp '__delete', {call: struct_delete.Bind(destructors)}
    }
    return w
}

_rt_stringPointerArray(strings) {
    chars := 0
    for s in strings
        chars += StrLen(s) + 1
    b := Buffer((strings.Length * A_PtrSize) + (chars * 2))
    p := b.ptr + strings.Length * A_PtrSize
    for s in strings {
        NumPut('ptr', p, b, (A_Index - 1) * A_PtrSize)
        p += StrPut(s, p)
    }
    return b
}

_rt_GetParameterizedIID(name, types) {
    static vt := Buffer(A_PtrSize), p_rt_MetaDataLocate := CallbackRevoker(_rt_MetaDataLocate, "F")
    static pvt := NumPut("ptr", p_rt_MetaDataLocate.ptr, vt) - A_PtrSize
    ; Make an array of pointers to the names.  StrPtr(names[1]) would return
    ; the address of a temporary string, so make more direct copies.
    names := [name]
    makeNames(types)
    makeNames(types) {
        for t in types {
            if t.HasProp('typeArgs') && t.typeArgs {
                ; Need the individual names of base type and each type arg.
                names.Push(t.m.GetTypeDefProps(t.t))
                makeNames(t.typeArgs)
            }
            else {
                names.Push(String(t))
            }
        }
    }
    namePtrArr := _rt_stringPointerArray(names)
    hr := DllCall("combase.dll\RoGetParameterizedTypeInstanceIID"
        , "uint", names.Length, "ptr", namePtrArr
        , "ptr*", pvt  ; "*" turns it into an "object" on DllCall's stack.
        , "ptr", oiid := GUID(), "ptr*", &pextra:=0, "hresult")
    DllCall("combase.dll\RoFreeParameterizedTypeExtra"
        , "ptr", pextra)
    return oiid
}

_rt_MetaDataLocate(this, pname, mdb) {
    name := StrGet(pname, "UTF-16")
    ; mdb : IRoSimpleMetaDataBuilder -- unconventional interface with no base type
    try {
        t := WinRT.GetType(name)
        switch String(t.FundamentalType) {
        case "Interface":
            if !(pguid := t.GUID)
                throw Error("GUID not found for " name)
            if p := InStr(name, "``") {
                ; SetParameterizedInterface
                ComCall(8, mdb, "ptr", pguid, "uint", SubStr(name, p + 1), "cdecl")
            }
            else {
                ; SetWinRtInterface
                ComCall(0, mdb, "ptr", pguid, "cdecl")
            }
        case "Object":
            t := WinRT.GetType(name).Class.__DefaultInterface
            ; SetRuntimeClassSimpleDefault
            ComCall(4, mdb, "ptr", pname, "wstr", t.Name, "ptr", t.GUID, "cdecl")
        case "Delegate":
            if !(pguid := t.GUID)
                throw Error("GUID not found for " name)
            if p := InStr(name, "``") {
                ; SetParameterizedDelete
                ComCall(9, mdb, "ptr", pguid, "uint", SubStr(name, p + 1), "cdecl")
            }
            else {
                ; SetDelegate
                ComCall(1, mdb, "ptr", pguid, "cdecl")
            }
        case "Struct":
            names := []
            for field in t.Fields()
                names.Push(String(field.type))
            namePtrArr := _rt_stringPointerArray(names)
            ; SetStruct
            ComCall(6, mdb, "ptr", pname, "uint", names.Length, "ptr", namePtrArr, "cdecl")
        case "Enum":
            ; SetEnum
            ComCall(7, mdb, "ptr", pname, "wstr", t.Class.__basicType.Name, "cdecl")
        default:
            throw Error('Unsupported fundamental type')
        }
    }
    catch as e {
        ; @Debug-Output => {e.__class} locating metadata for {name}: {e.message}
        ; @Debug-Breakpoint
        return 0x80004005 ; E_FAIL
    }
    return 0
}
