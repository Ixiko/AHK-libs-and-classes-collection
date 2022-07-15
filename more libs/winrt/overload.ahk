AddMethodOverloadTo(obj, name, f, name_prefix:="") {
    if obj.HasOwnProp(name) {
        if (pd := obj.GetOwnPropDesc(name)).HasProp('Call')
            prev := pd.Call
    }
    if IsSet(prev) {
        if !((of := prev) is OverloadedFunc) {
            obj.DefineProp(name, {Call: of := OverloadedFunc()})
            of.Name := name_prefix . name
            of.Add(prev)
        }
        of.Add(f)
    }
    else
        obj.DefineProp(name, {Call: f})
}

class OverloadedFunc {
    m := Map()
    Add(f) {
        n := f.MinParams
        Loop (f.MaxParams - n) + 1
            if this.m.has(n)
                throw Error("Ambiguous function overloads", -1)
            else
                this.m[n++] := f
    }
    Call(p*) {
        if (f := this.m.get(p.Length, 0))
            return f(p*)
        else
            throw Error(Format('Overloaded function "{}" does not accept {} parameters.'
                , this.Name, p.Length), -1)
    }
    static __new() {
        this.prototype.Name := ""
    }
}
