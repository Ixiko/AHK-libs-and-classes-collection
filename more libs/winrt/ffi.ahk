
class FFITypes {
    static NumTypeSize := Map()
    static __new() {
        for t in [
            [1,  'Int8' ,  'char' ],  ; Int8 is not used in WinRT, but maybe Win32metadata.
            [1, 'UInt8' , 'uchar' ],
            [2,  'Int16',  'short'],
            [2, 'UInt16', 'ushort'],
            [4,  'Int32',  'int'  ],
            [4, 'UInt32', 'uint'  ],
            [8,  'Int64',  'int64'],
            [8, 'UInt64', 'uint64'],
            [4, 'Single', 'float' ],
            [8, 'Double', 'double'],
            [A_PtrSize, 'IntPtr', 'ptr'],
            ] {
            this.NumTypeSize[t[3]] := t[1]
            this.%t[2]% := NumberTypeInfo(t*)
        }
        for t in ['Attribute', 'Void'] {
            this.%t% := BasicTypeInfo(t)
        }
    }
}

class RtRootTypes extends FFITypes {
    static __new() {
        t := [
            ['Attribute', {
                TypeClass: RtTypeInfo.Attribute,
            }],
            ['Boolean', {
                ArgPassInfo: ArgPassInfo("char", v => !!v, Number),
            }],
            ['Char16', {
                ArgPassInfo: ArgPassInfo("ushort", Ord, Chr),
            }],
            ['Delegate', {
                TypeClass: RtTypeInfo.Delegate,
            }],
            ['Enum', {
                TypeClass: RtTypeInfo.Enum,
                Class: EnumValue,
            }],
            ['Guid', {
                Class: GUID, Size: 16
            }],
            ['Interface', {
                TypeClass: RtTypeInfo.Interface,
                Class: RtObject,
            }],
            ['Object', {
                TypeClass: RtTypeInfo.Object,
                ArgPassInfo: RtInterfaceArgPassInfo(),
                ReadWriteInfo: RtInterfaceReadWriteInfo(),
                Class: RtObject,
            }],
            ['String', {
                ArgPassInfo: ArgPassInfo("ptr", HStringFromString, HStringRet),
                ReadWriteInfo: ReadWriteInfo.FromClass(HString),
            }],
            ['Struct', {
                TypeClass: RtTypeInfo.Struct,
            }],
        ]
        for t in t {
            bti := this.%t[1]% := BasicTypeInfo(t*)
            if t[2].HasProp('TypeClass')
                t[2].TypeClass.Prototype.FundamentalType := bti
        }
    }
}

class BasicTypeInfo {
    __new(name, props:=unset) {
        this.Name := name
        if IsSet(props)
            for name, value in props.OwnProps()
                this.%name% := value
    }
    ToString() => this.Name
    FundamentalType => this
    static prototype.ArgPassInfo := false
    static prototype.ReadWriteInfo := false
}

class NumberTypeInfo extends BasicTypeInfo {
    __new(size, name, nt) {
        this.Name := name
        this.Size := size
        this.ReadWriteInfo := ReadWriteInfo.FromArgPassInfo(
            this.ArgPassInfo := ArgPassInfo(nt, false, false)
        )
    }
}

class ArgPassInfo {
    /*
    ScriptToNative := (scriptValue) => nativeValue
    NativeToScript := (nativeValue) => scriptValue
    NativeType := Ptr | Int | UInt | ...
    */
    __new(nt, stn, nts) {
        this.NativeType := nt
        this.ScriptToNative := stn
        this.NativeToScript := nts
    }
    
    static Unsupported := this('Unsupported', false, false)
}

class ReadWriteInfo {
    /*
    GetReader(offset:=0)
    GetWriter(offset:=0)
    GetDeleter(offset:=0)
    Size => Integer
    */
    
    static ForType(typeinfo) {
        return typeinfo.ReadWriteInfo
            || (api := typeinfo.ArgPassInfo) && this.FromArgPassInfo(api)
            || this.FromClass(typeinfo.Class)
    }
    
    class FromArgPassInfo extends ReadWriteInfo {
        __new(api) {
            this.api := api
            this.Size := FFITypes.NumTypeSize[api.NativeType]
        }
        
        GetReader(offset:=0) => (
            f := this.api.NativeToScript,
            nt := this.api.NativeType,
            f ? (ptr) => f(NumGet(ptr, offset, nt))
              : (ptr) =>  (NumGet(ptr, offset, nt))
        )
        
        GetWriter(offset:=0) => (
            f := this.api.ScriptToNative,
            nt := this.api.NativeType,
            f ? (ptr, value) => NumPut(nt, f(value), ptr, offset)
              : (ptr, value) => NumPut(nt,  (value), ptr, offset)
        )
        
        GetDeleter(offset:=0) => false
    }
    
    class FromClass extends ReadWriteInfo {
        __new(cls) {
            this.Class := cls
            this.Size := cls.HasProp('Size') ? cls.Size : cls.Prototype.Size
            cls.HasProp('Align') && this.Align := cls.Align
        }
        
        GetReader(offset:=0) => this.Class.FromOffset.Bind(this.Class, , offset)
        
        GetWriter(offset:=0) {
            cls := this.Class
            ; TODO: implement struct coercion
            copyToPtr := (checkType := !cls.HasProp('CopyToPtr'))
                ? cls.Prototype.CopyToPtr  ; do not use an overridden method if subclassed
                : cls.CopyToPtr.Bind(cls)
            struct_writer(buf, value) {
                if checkType && !(value is cls)
                    throw TypeError('Expected ' cls.Prototype.__class ' but got ' Type(value) '.', -1)
                copyToPtr(value, buf.ptr + offset)
            }
            return struct_writer
        }
    
        GetDeleter(offset:=0) {
            cls := this.Class
            if !cls.Prototype.HasMethod('__delete')
                return false
            ; del := cls.Prototype.__delete
            ; return struct_delete_at_offset(buf) => del({ptr: buf.ptr + offset})
            proto := cls.Prototype
            ; FIXME: assumes all types other than ValueType are pointer types
            if HasBase(proto, ValueType.Prototype)
                return struct_delete_at_offset(buf) => ({ptr: buf.ptr + offset, base: proto}, "")
            else
                return ptr_delete_at_offset(buf) => ({ptr: NumGet(buf.ptr, offset, 'ptr'), base: proto}, "")
        }
    }
}

class RtInterfaceArgPassInfo extends ArgPassInfo {
    __new(typeinfo := unset) {
        ; _rt_WrapInspectable attempts to get the runtime class (at runtime) to make
        ; all methods available.  It sometimes fails for generic interfaces, so pass
        ; typeinfo as a default type to wrap.
        ; TODO: type checking for ScriptToNative
        super.__new("ptr", false,
            IsSet(typeinfo) ? _rt_WrapInspectable.Bind(, typeinfo) : _rt_WrapInspectable
        )
    }
}

class RtInterfaceReadWriteInfo extends ReadWriteInfo {
    __new(typeinfo:=false) {
        this.typeinfo := typeinfo
        this.Size := A_PtrSize
    }
    
    GetReader(offset:=0) => (ptr) => (
        p := NumGet(ptr, offset, "ptr"),
        ObjAddRef(p),
        _rt_WrapInspectable(p, this.typeinfo)
    )
    
    GetWriter(offset:=0) => (ptr, value) => (
        ; TODO: type checking
        ObjAddRef(pnew := value.ptr),
        (pold := NumGet(ptr, offset, "ptr")) && ObjRelease(pold),
        NumPut("ptr", pnew, ptr, offset)
    )
    
    ; Objects aren't supposed to be allowed in structs, but the HttpProgress struct
    ; has an IReference<UInt64>, which projects to C# as System.Nullable<ulong> but
    ; really is an interface pointer.
    GetDeleter(offset:=0) => (ptr) => (
        (p := NumGet(ptr, offset, "ptr")) && ObjRelease(p)
    )
}

class RtObjectArgPassInfo extends ArgPassInfo {
    __new(typeinfo) {
        local proto
        super.__new("ptr",
            false, ; TODO: type checking for ScriptToNative
            ; For composable classes, check class at runtime.
            !typeinfo.IsSealed ? _rt_WrapInspectable.Bind(, typeinfo) :
            ; For sealed classes, class is already known.
            rt_wrapSpecificClass(p) => p && {
                ptr: p,
                base: IsSet(proto) ? proto : proto := typeinfo.Class.prototype
            }
        )
    }
}

class RtEnumArgPassInfo extends ArgPassInfo {
    __new(typeinfo) {
        cls := typeinfo.Class
        super.__new(
            cls.__basicType.ArgPassInfo.NativeType,
            cls.Parse.Bind(cls),
            cls
        )
    }
}

class RtDelegateArgPassInfo extends ArgPassInfo {
    __new(typeinfo) {
        if !typeinfo.HasProp('Factory') {
            methods := [typeinfo.Methods()*]
            if methods.Length != 2 || (methods[1].Name '|' methods[2].Name) != '.ctor|Invoke'
                throw Error('Unexpected delegate typeinfo')
            method := methods[2] ; Invoke
            types := typeinfo.MethodArgTypes(method.sig)
            factory := DelegateFactory(typeinfo.GUID, types, types.RemoveAt(1))
            typeinfo.DefineProp('Factory', {value: factory})
        }
        else
            factory := typeinfo.Factory
        super.__new("ptr", factory, false)  ; TODO: delegate NativeToScript (e.g. for IAsyncOperation.Completed return value)
    }
}