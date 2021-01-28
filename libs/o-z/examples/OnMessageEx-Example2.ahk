#Persistent
Gui, Font, s20
Gui, Margin, 30, 30
Gui, Add, Text,, Click Here
Gui, Show

Obj := {MyMethodA : Func("MyFuncA"), MyMethodB : Func("MyFuncB")}
OnMessageEx(0x200, [&Obj, "MyMethodA"])
OnMessageEx(0x201, [&Obj, "MyMethodB", False])

Return
GuiClose:
ExitApp

F1::Obj.MyMethodA := ""     ;remove the function reference. That is, the method no longer exists
F2::Obj.MyMethodB := ""     ;since the Auto-Remove option is disabled, this function name is still stored in the stack object.
F3::msgbox % "Function Removed: " OnMessageEx(0x201, "MyMethodB", 0)        ;to manually remove it

MyFuncA(this, wParam, lParam, msg, hwnd) {
    display := A_ThisFunc "`nwParam :`t" wParam "`nlParam :`t`t" lParam "`nMessage :`t" msg "`nHwnd :`t`t" hwnd
    mousegetpos, mousex, mousey
    tooltip, % display, mousex - 200, , 1
    SetTimer, RemoveToolTipA, -1000
    Return
    RemoveToolTipA:
        tooltip,,,,1
    Return
}
MyFuncB(this, wParam, lParam, msg, hwnd) {
    display := A_ThisFunc "`nwParam :`t" wParam "`nlParam :`t`t" lParam "`nMessage :`t" msg "`nHwnd :`t`t" hwnd
    mousegetpos, mousex, mousey
    tooltip, % display, mousex - 200, mousey - 80, 2
    SetTimer, RemoveToolTipB, -1000
    Return
    RemoveToolTipB:
        tooltip,,,,2
    Return
}