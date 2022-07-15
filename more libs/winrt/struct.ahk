class ValueType extends RtAny {
    static Call() {
        proto := this.Prototype
        b := Buffer(proto.Size, 0)
        return {ptr: b.ptr, _buf_: b, base: proto}
    }
    ; static FromPtr(ptr) {
    ;     return {ptr: ptr, base: this.Prototype}
    ; }
    static FromOffset(buf, offset) {
        return {ptr: buf.ptr + offset, _outer_: buf, base: this.Prototype}
    }
    CopyToPtr(ptr) {
        DllCall('msvcrt\memcpy', 'ptr', ptr, 'ptr', this, 'ptr', this.Size, 'cdecl')
    }
}

class EnumValue extends RtAny {
    static Call(n) {
        if e := this.__item.get(n, 0)
            return e
        return {n: n, base: this.prototype}
    }
    static Parse(v) { ; TODO: parse space-delimited strings for flag enums
        if v is this
            return v.n
        if v is Integer
            return v ; this[v].n would only permit explicitly defined values, but Parse is currently used for all enum args, so this isn't suitable for flag enums.
        if v is String
            return this.%v%.n
        throw TypeError(Format('Value of type "{}" cannot be converted to {}.', type(v), this.prototype.__class), -1)
    }
    s => String(this.n) ; TODO: produce space-delimited strings for flag enums
    ToString() => this.s
}

_rt_CreateEnumWrapper(t) {
    w := _rt_CreateClass(t.Name, EnumValue)
    t.DefineProp 'Class', {value: w}
    def(n, v) => w.DefineProp(n, {value: v})
    def '__item', items := Map()
    for f in t.Fields() {
        switch f.flags {
            case 0x601: ; Private | SpecialName | RTSpecialName
                def '__basicType', f.type
            case 0x8056: ; public | static | literal | hasdefault
                def f.name, items[f.value] := {n: f.value, s: f.name, base: w.prototype}
        }
    }
    return w
}
