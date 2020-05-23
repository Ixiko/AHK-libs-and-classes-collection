class xHotkey {
    static hk := {}
    static contexts := new xHotkey_Array
    static context := ""
    SetHotkey(KeyName, Callback, Enable:="") {
        if InStr(" On Off Toggle 0 1 ", " " Callback " ")
            Enable := Callback, Callback := ""
        fn := (IsObject(Callback) || Callback = "") ? Callback : Func(Callback)
        if !fn && Callback != ""
            throw Exception("Invalid callback", -2, Callback)

        KeyName := xHotkeyNormalize(KeyName, useHook, hasTilde)

        hkNew := false
        if !hk := this.hk[KeyName] {
            hk := new xHotkey
            hk.name := KeyName
            hkNew := true
        }
        if !variant := hk.FindVariant(this.context) {
            if !fn
                throw Exception("Non-existent hotkey", -2, KeyName)
            variant := hk.AddVariant(this.context)
        }

        if fn
            variant.callback := fn
        else if (Enable = "")
            Enable := Callback

        if variant.hasTilde := hasTilde
            hk.hasTilde := true

        if (Enable = "Toggle")
            enabled := !variant.enabled
        else if (Enable+0 != "")
            enabled := Enable != 0
        else if (Enable = "On" || Enable = "Off")
            enabled := Enable != "Off"
        else
            enabled := ""
        wasActive := hk.activeCount != 0
        if (enabled != "" && enabled != variant.enabled) {
            hk.activeCount += enabled ? +1 : -1
            variant.enabled := enabled
        }

        if (hkNew || (wasActive != (hk.activeCount != 0))) {
            this._Hotkey(KeyName, hk.activeCount ? "On" : "Off")
            hk.appliedTilde := false
            if hkNew
                this.hk[KeyName] := hk
        }

        ; UseHook generally isn't needed: the "reg" method will only be used if this
        ; hotkey has a global variant created outside this function, since we always
        ; use a "context-sensitive" hotkey (see "Hotkey If" above).
        if useHook && !hk.useHook {
            ; As at 2014-12-31, the '$' prefix can't be added to an existing hotkey,
            ; but the '~' prefix can, and it also forces the hook to be used.
            this._Hotkey("~" KeyName)
            hk.useHook := true  ; $ applies to all variants of the hotkey.
            hk.appliedTilde := true  ; It will be unapplied if necessary.
        }
    }
    _Hotkey(KeyName, Options:="") {
        Hotkey If, xHotkey.ShouldFire(A_ThisHotkey)
        try
            Hotkey %KeyName%, xHotkey_Fire, %Options%
        finally
            Hotkey If
        return
        xHotkey_Fire:
            xHotkey.Fire(A_ThisHotkey)
        return
    }
    Fire(KeyName) {
        if variant := this.pending
            this.pending := ""
        else if !(hk := this.hk[KeyName])
             || !(variant := hk.FindActiveVariant())
            return
        fn := variant.callback, ComObjType(fn) ? fn.call() : %fn%()
    }
    SetContext(Command, WinTitle, WinText) {
        if (WinTitle = "" && WinText = "") {
            this.context := ""
            return
        }
        if !context := this.FindContext(this.contexts, Command, WinTitle, WinText) {
            context := {Command: Command, WinTitle: WinTitle, WinText: WinText}
            this.contexts.Push(context)
        }
        this.context := context
    }
    FindContext(Contexts, Command, WinTitle, WinText) {
        for _, context in Contexts
            if    context.Command = Command
               && context.WinTitle == WinTitle
               && context.WinText == WinText
                return context
    }
    ShouldFire(KeyName) {
        if !(hk := this.hk[KeyName]) || !hk.activeCount
            return false
        if hk.HasGlobalVariant() && !hk.hasTilde
            return true
        if !variant := hk.FindActiveVariant()
           return false
        if variant.hasTilde != hk.appliedTilde {
            ; Control pass-through for this key-press by modifying the hotkey:
            this._Hotkey((variant.hasTilde ? "~" : "") KeyName)
            hk.appliedTilde := variant.hasTilde
        }
        this.pending := variant
        return true
    }
    IfWinActive(WinTitle:="", WinText:="") {
        return this.SetContext("IfWinActive", WinTitle, WinText)
    }
    IfWinExist(WinTitle:="", WinText:="") {
        return this.SetContext("IfWinExist", WinTitle, WinText)
    }
    IfWinNotActive(WinTitle:="", WinText:="") {
        return this.SetContext("IfWinNotActive", WinTitle, WinText)
    }
    IfWinNotExist(WinTitle:="", WinText:="") {
        return this.SetContext("IfWinNotExist", WinTitle, WinText)
    }

    activeCount := 0
    variants := new xHotkey_Array
    gvariant := ""
    hasTilde := false
    appliedTilde := false
    AddVariant(context) {
        if context
            this.variants.Push(variant := new context)
        else
            this.gvariant := variant := {}
        variant.enabled := true
        this.activeCount += 1
        return variant
    }
    FindVariant(context) {
        if !context
            return this.gvariant
        for _, variant in this.variants
            if variant.base == context
                return variant
    }
    FindActiveVariant() {
        for _, variant in this.variants {
            if InStr(variant.Command, "Active")
                cond := WinActive(variant.WinTitle, variant.WinText)
            else if InStr(variant.Command, "Exist")
                cond := WinExist(variant.WinTitle, variant.WinText)
            if InStr(variant.Command, "Not")
                cond := !cond
            if cond
                return variant
        }
        return this.gvariant
    }
    HasGlobalVariant() {
        return this.gvariant != ""
    }
}
#If xHotkey.ShouldFire(A_ThisHotkey)
#If

class xHotkey_Array {
    v1() {
        static x := A_AhkVersion<"2" ? xHotkey_Array.v1() : ""
        this.Push := Func("ObjInsert")
        this.Length := Func("ObjLength")
    }
}

xHotkey(KeyName, Callback:="", Enable:="") {
    if KeyName ~= "i)^IfWin(Not)?(Active|Exist)$"
        return xHotkey.SetContext(KeyName, Callback, Enable)
    return xHotkey.SetHotkey(KeyName, Callback, Enable)
}
