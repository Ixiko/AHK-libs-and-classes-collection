#Include RegExHotstring.ahk
#SingleInstance Force

; the upmost function will be triggered if it has the same expression
RegExHotstring("(\w)abc(\w)", "$2abc$1")
RegExHotstring("(\w)abc", "dbc$1")
RegExHotstring("(\w)dbc", call)
RegExHotstring("!@(\d+)s", rand)

; calls with RegExMatchInfo
call(match) {
    MsgBox("matched: " match[1])
}

char := "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
rand(match) {
    loop match[1] {
        r := Random(1, StrLen(char))
        str .= SubStr(char, r, 1)
    }
    Send(str)
}