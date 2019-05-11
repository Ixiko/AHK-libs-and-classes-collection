#NoEnv
#Include ActiveScript.ahk
/* Preferred usage:
      ; Put ActiveScript.ahk in a Lib folder, then:
      #Include <ActiveScript>
 */


vb := new ActiveScript("VBScript")
code = 
(
MsgBox "Hello, world!"
Dim Answer
Function GetAnswer
    GetAnswer = Answer
End Function
)
vb.Exec(code)  ; Execute some VBScript.
vb.Answer := 42  ; Set a previously-declared global variable.
MsgBox % vb.Answer  ; Get a global variable.
MsgBox % vb.GetAnswer()  ; Call a function.
MsgBox % vb.Eval("2 + 2")  ; Evaluate an expression.


; The same thing again, but with JScript:
js := new ActiveScript("JScript")
code =
(
shell = new ActiveXObject("WScript.Shell")
shell.Popup("Hello, world!")
var Answer
function GetAnswer() {
    return Answer
}
)
; These are all the same as before:
js.Exec(code)
js.Answer := 42
MsgBox % js.Answer
MsgBox % js.GetAnswer()
MsgBox % js.Eval("2 + 2")

; Show which scripting engine is in use; probably "5.8".
ShowVersion(js)

; To use the newer IE9+ version of JScript, use the following.
js := new ActiveScript("{16d51579-a30b-4c8b-a276-0ff4dc41e755}")
ShowVersion(js)

ShowVersion(as) {
    MsgBox % as.ScriptEngineMajorVersion() "." as.ScriptEngineMinorVersion()
}