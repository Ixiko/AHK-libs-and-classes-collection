#NoEnv
#Include ActiveScript.ahk
#Include JsRT.ahk
/* Preferred usage:
      ; Put ActiveScript.ahk and JsRT.ahk in a Lib folder, then:
      #Include <ActiveScript>
      #Include <JsRT>
 */

MsgBox 4,, Use Edge version of JsRT?
IfMsgBox Yes
    js := new JsRT.Edge
else
    js := new JsRT.IE

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
js.AddObject("MsgBox", Func("MyMsgBox"))
js.AddObject("ToAHK", Func("ToAHK"))

; Pass an AutoHotkey object to a JScript function:
theirObj := js.ToJS(myObj := {foo: "bar"})

; ...and check the object it returned to us.
MsgBox % "ToJS returned " (myObj=theirObj ? "the original":"a different") " object and foo is " theirObj.foo


ToAHK(v) {
    global myObj
    MsgBox 0, ToAHK, % "ToAHK got " (myObj=v ? "the original":"a different") " object and foo is " v.foo
}

MyMsgBox(s) {
    MsgBox 0, JScript, %s%
}
