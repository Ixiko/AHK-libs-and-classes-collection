
#include %A_LineFile%\..\winrt.ahk

class RtNamespace {
    static __new() {
        this.DefineProp '__set', {call: RtAny.__set}
        this.prototype.DefineProp '__set', {call: RtAny.__set}
    }
    __new(name) {
        this.DefineProp '_name', {value: name}
    }
    __call(name, params) => this.__get(name, [])(params*)
    __get(name, params) {
        this._populate()
        if this.HasOwnProp(name)
            return params.Length ? this.%name%[params*] : this.%name%
        try
            cls := WinRT(typename := this._name "." name)
        catch OSError as e {
            throw (e.number != 0x80073D54 || e.extra != typename) ? e
                : PropertyError("Unknown property, class or namespace", -1, typename)
        }
        this.DefineProp name, {get: this => cls, call: (this, p*) => cls(p*)}
        return params.Length ? cls[params*] : cls
    }
    __enum(n:=1) => (
        this._populate(),
        this.__enum(n)
    )
    _populate() {
        ; Subclass should override this and call super._populate().
        enum_ns_props(this, n:=1) {
            next_prop := this.OwnProps()
            next_namespace(&name:=unset, &value:=unset) {
                loop
                    if !next_prop(&name, &value)
                        return false
                until value is RtNamespace
                return true
            }
            return next_namespace
        }
        ; Subsequent calls to __enum() should enumerate the populated properties.
        this.DefineProp '__enum', {call: enum_ns_props}
        ; Subsequent calls to _populate() should have no effect.
        this.DefineProp '_populate', {call: IsObject}
        ; Find any direct child namespaces defined in files (for Windows and Windows.UI).
        Loop Files A_WinDir "\System32\WinMetadata\" this._name ".*.winmd", "F" {
            name := SubStr(A_LoopFileName, StrLen(this._name) + 2)
            name := SubStr(name, 1, InStr(name, ".") - 1)
            if !this.HasOwnProp(name)
                this.DefineProp name, {value: RtNamespace(this._name "." name)}
        }
        ; Find namespaces in winmd files.
        this._populateFromModule()
    }
    _populateFromModule() {
        if this.HasOwnProp('_m')
            return
        this.DefineProp '_m', {
            value: m := RtMetaDataModule.Open(RtNamespace.GetPath(this._name))
        }
        prefix := this._name '.'
        ; Find all namespaces strings in this module.
        static tabTypeDef := 2, colNamespace := 2
        static GetTableInfo := 9, GetColumn := 13, GetString := 14
        mdt := ComObjQuery(m, "{D8F579AB-402D-4B8E-82D9-5D63B1065C68}") ; IMetaDataTables
        ComCall(GetTableInfo, mdt, "uint", tabTypeDef
            , "ptr", 0, "uint*", &cRows := 0, "ptr", 0, "ptr", 0, "ptr", 0)
        ; Find all unique namespace strings referenced by the TypeDef table.
        unique_names := Map()
        Loop cRows {
            ComCall(GetColumn, mdt, "uint", tabTypeDef, "uint", colNamespace, "uint", A_Index, "uint*", &index:=0)
            unique_names[index] := 1
        }
        ; For each unique namespace string...
        for index in unique_names {
            ComCall(GetString, mdt, "uint", index, "ptr*", &name:=0)
            name := StrGet(name, "UTF-8")
            if SubStr(name, 1, StrLen(prefix)) = prefix {
                x := this, len := StrLen(prefix) - 1
                Loop Parse SubStr(name, len + 2), '.' {
                    len += 1 + StrLen(A_LoopField)
                    if !x.HasOwnProp(A_LoopField) {
                        ns := RtNamespace(SubStr(name, 1, len))
                        ; Since this namespace hasn't already been discovered as a *.winmd,
                        ; it must only be defined in this module.
                        ns.DefineProp '_m', {value: m}
                        x.DefineProp A_LoopField, {value: ns}
                    }
                    x := x.%A_LoopField%
                }
            }
            ; else it should be either "" or this._name itself.
        }
    }
    static GetPath(name) => A_WinDir "\System32\WinMetadata\" name ".winmd"
}

class Windows {
    static __new() {
        ; Transform this static class into an instance of RtNamespace.
        this._name := "Windows"
        this.DeleteProp 'Prototype'
        this.base := RtNamespace.Prototype
    }
    static __get(name, params) {
        if !FileExist(RtNamespace.GetPath(fname := this._name "." name))
            throw Error("Non-existent namespace or missing winmd file.", -1, name)
        this.DefineProp name, {value: n := RtNamespace(fname)}
        return n
    }
    static _populateFromModule() => 0
}
