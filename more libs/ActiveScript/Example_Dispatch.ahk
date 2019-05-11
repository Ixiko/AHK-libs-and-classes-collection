#NoEnv
#Include ActiveScript.ahk
; Requires Lib\ComDispatch.ahk - https://github.com/cocobelgica/AutoHotkey-ComDispatch
#Include <ComDispatch>


js := new ActiveScript("JScript")

; Add an object callable by name:
js.AddObject("AHK", ComDispatch("AHK", "Greet = Dsp_Greet"))
js.Exec("AHK.Greet('Hello')")

; Add global functions via an object:
js.AddObject("G", ComDispatch("world", "GGreet = Dsp_Greet"), true)
js.Exec("GGreet('Hello')")

Dsp_Greet(this, Greeting)
{
    MsgBox %Greeting%, %this%!
}

; Add an object defined as a class (exposing methods only):
js.AddObject("myObj", ComDispatch(new MyClass, MyClass.DispTable))
js.Exec("myObj.Method(['first value', 'second value'])")

class MyClass
{
    Method(x)
    {
        ; Just to show we can pass arrays from JScript to AHK:
        MsgBox % "Method: " x[0] ", " x[1]
    }
    static DispTable := [[MyClass.Method], {Method:1}]
}