#Persistent
Gui, Font, s20
Gui, Margin, 30, 30
Gui, Add, Text,, Click Here
Gui, Show
OnMessage(0x200, "MyFuncA")     ;a function registered via OnMessage() will be added in the list when OnMessageEx() is called for the first time.
OnMessageEx(0x200, "MyFuncB")
OnMessageEx(0x200, "MyFuncC")
OnMessageEx(0x201, "MyFuncD")
OnMessageEx(0x201, "MyFuncE")
OnMessageEx(0x201, "MyFuncF")
OnMessageEx(0x201, "MyFuncD")   ;a duplicated item will be removed and the function is inserted again
Return
GuiClose:
ExitApp

F1::msgbox % "Function Removed: " OnMessageEx(0x200, "")    ;removes the function in the lowest priority for 0x200
F2::msgbox % "Function Removed: " OnMessageEx(0x201, "")    ;removes the function in the lowest priority for 0x201
F3::msgbox % "The lowest priority function for 0x200 is: " OnMessageEx(0x200)
F4::msgbox % "The lowest priority function for 0x201 is: " OnMessageEx(0x201)
F5::msgbox % "Function Removed: " OnMessageEx(0x201, "MyFuncF", 0)    ;removes MyFuncF from 0x201

MyFuncA(wParam, lParam, msg, hwnd) {
    display := A_ThisFunc "`nwParam :`t" wParam "`nlParam :`t`t" lParam "`nMessage :`t" msg "`nHwnd :`t`t" hwnd
    mousegetpos, mousex, mousey
    tooltip, % display, mousex - 200, , 1
    SetTimer, RemoveToolTipA, -1000
    Return
    RemoveToolTipA:
        tooltip,,,,1
    Return
}
MyFuncB(wParam, lParam, msg, hwnd) {
    display := A_ThisFunc "`nwParam :`t" wParam "`nlParam :`t`t" lParam "`nMessage :`t" msg "`nHwnd :`t`t" hwnd
    mousegetpos, mousex, mousey
    tooltip, % display, mousex,, 2
    SetTimer, RemoveToolTipB, -1000
    Return
    RemoveToolTipB:
        tooltip,,,,2
    Return
}
MyFuncC(wParam, lParam, msg, hwnd) {
    display := A_ThisFunc "`nwParam :`t" wParam "`nlParam :`t`t" lParam "`nMessage :`t" msg "`nHwnd :`t`t" hwnd
    mousegetpos, mousex, mousey
    tooltip, % display, mousex + 200 ,, 3
    SetTimer, RemoveToolTipC, -1000
    Return
    RemoveToolTipC:
        tooltip,,,,3
    Return
}
MyFuncD(wParam, lParam, msg, hwnd) {
    display := A_ThisFunc "`nwParam :`t" wParam "`nlParam :`t`t" lParam "`nMessage :`t" msg "`nHwnd :`t`t" hwnd
    mousegetpos, mousex, mousey
    tooltip, % display, mousex - 200, mousey - 80, 4
    SetTimer, RemoveToolTipD, -1000
    Return
    RemoveToolTipD:
        tooltip,,,,4
    Return
}
MyFuncE(wParam, lParam, msg, hwnd) {
    display := A_ThisFunc "`nwParam :`t" wParam "`nlParam :`t`t" lParam "`nMessage :`t" msg "`nHwnd :`t`t" hwnd
    mousegetpos, mousex, mousey
    tooltip, % display, mousex, mousey - 80, 5
    SetTimer, RemoveToolTipE, -1000
    Return
    RemoveToolTipE:
        tooltip,,,,5
    Return
}
MyFuncF(wParam, lParam, msg, hwnd) {
    display := A_ThisFunc "`nwParam :`t" wParam "`nlParam :`t`t" lParam "`nMessage :`t" msg "`nHwnd :`t`t" hwnd
    mousegetpos, mousex, mousey
    tooltip, % display, mousex + 200 , mousey - 80, 6
    SetTimer, RemoveToolTipF, -1000
    Return
    RemoveToolTipF:
        tooltip,,,,6
    Return
}