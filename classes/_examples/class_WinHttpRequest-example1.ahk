; Link:   	https://raw.githubusercontent.com/infogulch/WinHttpRequest/master/testing-whr.ahk_l
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

#SingleInstance, Force
; #Include ..\LSON\LSON.ahk
#Include WinHttpRequest.ahk
; #Include COM.ahk

url := "http://google.com/search?q=test"

x := new WinHttpRequest({ OnResponseFinished: Func("Finished") })
x.Open("GET", url, true)
x.Send()

while !x.WaitForResponse(0) 
    tooltip % "waiting"
tooltip

msgbox % "status: " x.status
msgbox % "response:`n`n" SubStr(x.ResponseText, 1, 1000)

Finished(id) {
    msgbox Finished!
}