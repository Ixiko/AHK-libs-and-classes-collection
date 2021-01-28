; This file is auto-included on AutoHotkey v1.
StrReplace(Input, SearchText, ReplaceText:="", ByRef OutputVarCount:="", Limit:="") {
    ErrLvl := ErrorLevel
    if (Limit != 1 && Limit != "")
        throw Exception("Limit must be 1 or omitted in v1", -1, Limit)
    if IsByRef(OutputVarCount) && Limit != ""
        throw Exception("OutputVarCount cannot be used with Limit in v1", -1)
    StringReplace Output, Input, %SearchText%, %ReplaceText%, % Limit=1 ? "" : "UseErrorLevel"
    OutputVarCount := ErrorLevel,  ErrorLevel := ErrLvl
    return Output
}