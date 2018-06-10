SetTitleMatchMode 2

xHotkey("#z", bind("Launch", "http://ahkscript.org", "AHKScript"))
xHotkey("^!n", bind("Launch", "notepad", "Untitled - Notepad"))

xHotkey("esc", "MyExitApp")

xHotkey.IfWinActive("ahk_class Notepad")
xHotkey("esc", "MyWinClose")


; ExitApp and WinClose could be used directly on AutoHotkey v2.
MyExitApp() {
    ExitApp
}
MyWinClose(a:="", b:="", c:="", d:="", e:="") {
    WinClose %a%, %b%, %c%, %d%, %e%
}

Launch(program, title) {
    if WinExist(title)
        WinActivate
    else
        Run % program
}

bind(fn, args*) {
    return new BoundFunc(fn, args*)
}

class BoundFunc {
    __New(fn, args*) {
        this.fn := IsObject(fn) ? fn : Func(fn)
        this.args := args
    }
    __Call(callee) {
        if (callee = "") {
            fn := this.fn
            return %fn%(this.args*)
        }
    }
}
