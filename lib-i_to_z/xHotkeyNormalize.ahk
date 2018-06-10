HotkeyNormalize(Hotkey, ByRef UseHook:="", ByRef HasTilde:="", Excp:=-1) {
    if p := InStr(Hotkey, " & ") {
        return HotkeyNormalize(RTrim(SubStr(Hotkey, 1, p)),,, -2) " & "
            .  HotkeyNormalize(LTrim(SubStr(Hotkey, p+3)),,, -2)
    }
    
    Hotkey := RegExReplace(Hotkey, "i)[ `t]up$", "", isKeyUp, 1)
    
    if !p := RegExMatch(Hotkey, "^[~$*<>^!+#]*\K(\w+|.)$")
        throw Exception("Invalid hotkey", Excp, Hotkey)
    
    mods := SubStr(Hotkey, 1, p-1)
    
    if UseHook := InStr(mods, "$") != 0
        mods := StrReplace(mods, "$")
    if HasTilde := InStr(mods, "~") != 0
        mods := StrReplace(mods, "~")
    
    static allMods := StrSplit("* <^ <! <+ <# >^ >! >+ ># ^ ! + #", " ")
    sortedMods := ""
    if mods
        for _, aMod in allMods
            if InStr(mods, aMod)
                sortedMods .= aMod, mods := StrReplace(mods, aMod)
    
    key := SubStr(Hotkey, p)
    if key ~= "i)^(.$|vk|sc)"
        key := StrLower(key)
    else if n := GetKeyName(key)
        key := n
    else
        throw Exception("Unknown key", Excp, key)
    return sortedMods . key . (isKeyUp ? " up" : "")
}