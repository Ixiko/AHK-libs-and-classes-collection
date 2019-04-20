
class CaseSensitiveObject
{
    static SuperKey := {}
    /*
    About SuperKey: 
        Object keys are allowed to be objects themselfs. (E.g. { []: "123" }).
        When an object is used as a key, the only way to get to the contents of that
        key is to use the EXACT SAME object, not just an object with identical contents.
        
        By using a specific object key for the contents of all instances of CaseSensitiveObject
        we can ensure that the user CANNOT accidentally overwrite or directly get to the contents
        of the untranslated object. This is because the only way to get to the actual contents is
        to use the full key: CaseSensitiveObject.SuperKey
    */
    static _Insert      := CaseSensitiveObject.Insert
    static _Remove      := CaseSensitiveObject.Remove
    static _MinIndex    := CaseSensitiveObject.MinIndex
    static _MaxIndex    := CaseSensitiveObject.MaxIndex
    static _GetCapacity := CaseSensitiveObject.GetCapacity
    static _SetCapacity := CaseSensitiveObject.SetCapacity
    static _GetAddress  := CaseSensitiveObject.GetAddress
    static _Clone       := CaseSensitiveObject.Clone
    static _HasKey      := CaseSensitiveObject.HasKey
    static _NewEnum     := CaseSensitiveObject.NewEnum
    
    __new(base = "") {
        ObjInsert(this, CaseSensitiveObject.SuperKey, IsObject(base) ? {base: base} : {})
    }
    
    __get(keys*) {
        key := CaseSensitiveObject.FormatKey.(keys[1])
        realthis := this[CaseSensitiveObject.SuperKey]
        if realthis.HasKey(key) || keys[1] = "SuperKey"
        {
            keys.remove(1)
            if keys.MaxIndex()
                return realthis[key][keys*]
            else
                return realthis[key]
        }
    }
    
    __set(args*) {
        key := CaseSensitiveObject.FormatKey.(args.remove(1))
        value := args.remove()
        if args.MaxIndex()
            return this[CaseSensitiveObject.SuperKey][key][args*] := value
        else
            return this[CaseSensitiveObject.SuperKey][key] := value
    }
    
    __call(target, args*) {
        if !ObjHasKey(CaseSensitiveObject,target)
            return this[CaseSensitiveObject.SuperKey][CaseSensitiveObject.FormatKey.(target)].(args*)
    }
    
    Insert(args*) {
        loop % args.MaxIndex() // 2
            args[A_Index*2-1] := CaseSensitiveObject.FormatKey.(args[A_Index*2-1]) ;format all keys
        return this[CaseSensitiveObject.SuperKey].Insert(args*)
    }
    
    Remove(args*) {
        loop % args.MaxIndex()
            args[A_Index] := CaseSensitiveObject.FormatKey.(args[A_Index])
        return this[CaseSensitiveObject.SuperKey].Remove(args*)
    }
    
    MinIndex() {
        return this[CaseSensitiveObject.SuperKey].MinIndex()
    }
    
    MaxIndex() {
        return this[CaseSensitiveObject.SuperKey].MaxIndex()
    }
    
    GetCapacity(args*) {
        return this[CaseSensitiveObject.SuperKey].GetCapacity(args*)
    }
    
    SetCapacity(args*) {
        if args.MaxIndex() > 1
            args[1] := CaseSensitiveObject.FormatKey.(args[1])
        return this[CaseSensitiveObject.SuperKey].SetCapacity(args*)
    }
    
    GetAddress(key) {
        return this[CaseSensitiveObject.SuperKey].GetAddress(CaseSensitiveObject.FormatKey.(key))
    }
    
    HasKey(key) {
        return this[CaseSensitiveObject.SuperKey].HasKey(CaseSensitiveObject.FormatKey.(key))
    }
    
    Clone() {
        ret := new CaseSensitiveObject()
        ret[CaseSensitiveObject.SuperKey] := this[CaseSensitiveObject.SuperKey].Clone()
        return ret
    }
    
    FormatKey() {
        if !IsObject(this)
            if this is not number
            {
                f := "{1:0" 2*(1+A_IsUnicode) "X}"
                loop, parse, this
                    ret .= Format(f, Asc(A_LoopField))
                this := "s" ret
            }
        return this
    }
    
    UnformatKey() {
        sz := 2*(1+A_IsUnicode)
        this := SubStr(this, 2)
        loop % StrLen(this) // sz
            ret .= Chr("0x" SubStr(this, (A_Index-1)*sz+1, sz))
        return ret
    }
    
    NewEnum() {
        return new CaseSensitiveObject.Enumerator(this[CaseSensitiveObject.SuperKey])
    }
    
    class Enumerator {
        __new(obj) {
            this.enum := ObjNewEnum(obj)
        }
        
        Next(ByRef key, ByRef value = "") {
            return this.enum.Next(k, value), key := CaseSensitiveObject.UnFormatKey.(k)
        }
    }
}
