#SingleInstance Force

SacHook := InputHook("VI")
; match when pressed
SacHook.KeyOpt("{Space}", "+N")
SacHook.OnKeyDown := KeyDown
SacHook.Start()
Hs := RegExHs()

KeyDown(ih, vk, sc) {
    ; return when triggered by Hotstrings
    if HotstringIsQueued() {
        ih.Stop()
        Critical false	; Enable immediate thread interruption.
        Sleep -1	; Process any pending messages.
        ih.Start()
        return
    }

    ; loop through ench strings and find the first match
    input := SubStr(ih.Input, 1, StrLen(ih.Input) - 1)
    ih.Stop()
    loop Hs.Len() {
        str := Hs.str_arr[A_Index]
        call := Hs.call_arr[A_Index]
        if (RegExMatch(input, str, &match)) {
            ; delete matched string
            Send("{BS " (match.Len[0] + 1) "}")
            if (call is String) {
                Send(RegExReplace(input, str, call))
            } else if (call is Func) {
                call(match)
            } else
                throw Error('callback type error `ncallback should be "Func" or "String"')
            ih.Start()
            return
        }
    }
    ih.Start()
}

; thanks lexikos - https://www.autohotkey.com/boards/viewtopic.php?f=82&t=104538#p464744
; detect if hotstring is triggered
HotstringIsQueued() {
    static AHK_HOTSTRING := 1025
    msg := Buffer(4 * A_PtrSize + 16)
    return DllCall("PeekMessage", "ptr", msg, "ptr", A_ScriptHwnd
        , "uint", AHK_HOTSTRING, "uint", AHK_HOTSTRING, "uint", 0)
}

RegExHotstring(Str, Callback) {
    Hs.Append(Str, Callback)
}

Class RegExHs {
    ; stores hotstrings and callbacks
    str_arr := Array()
    call_arr := Array()

    ; append new RegExHotstring
    Append(Str, CallBack) {
        this.str_arr.Push(Str)
        this.call_arr.Push(CallBack)
    }

    Len() {
        return this.str_arr.Length
    }
}