#include %a_Scriptdir%\..\lib-a_to_h\callbackcreate.ahk
; Example from the docs
callback := CallbackCreate("TheFunc", "F&", 3)  ; Parameter list size must be specified for 32-bit.
DllCall(callback, float, 10.5, int64, 42)
TheFunc(params) {
    MsgBox % NumGet(params+0, "float") ", " NumGet(params+A_PtrSize, "int64")
}