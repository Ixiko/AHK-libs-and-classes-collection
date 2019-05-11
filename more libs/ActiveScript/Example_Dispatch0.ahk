#NoEnv
#Include ActiveScript.ahk
#Include ComDispatch0.ahk

/*
    ComDispatch0() can be used to wrap any AutoHotkey object to be used
    by a COM client such as JScript/VBScript.  Unlike ComDispatch(), it
    does not require the methods and IDs to be defined in advance, and
    it supports setting/getting.
*/

js := new ActiveScript("JScript")
code =
(
function ToJS(v) {
    MsgBox("JScript says foo is " + v.foo);
    ToAHK(v);
    return v;
}
)
js.Exec(code)

; Add functions callable by name:
js.AddObject("MsgBox", ComDispatch0(Func("MyMsgBox")))
js.AddObject("ToAHK", ComDispatch0(Func("ToAHK")))

; Pass an AutoHotkey object to a JScript function:
theirObj := js.ToJS(ComDispatch0(myObj := {foo: "bar"}))

; ...and check the object it returned to us.
MsgBox % "ToJS returned " (myObj=theirObj ? "the original":"a different") " object and foo is " theirObj.foo

; This works, but inefficiently: it goes through two wrapper objects.
theirObj.x := 10
MsgBox % myObj.x  ; 10

; This doesn't work, because theirObj is effectively a COM object.
y := {}, theirObj.y := y
MsgBox % theirObj.y != ""  ; 0

; So we need to unwrap it...
theirObj := ComDispatch0_Unwrap(theirObj)
y := {}, theirObj.y := y
MsgBox % theirObj.y == y  ; 1


ToAHK(v) {
    global myObj
    MsgBox 0, ToAHK, % "ToAHK got " (myObj=v ? "the original":"a different") " object and foo is " v.foo
}

MyMsgBox(s) {
    MsgBox 0, JScript, %s%
}
