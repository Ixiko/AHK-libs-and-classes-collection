; Simple example
#Include Libcurl.ahk

; Don't forget to put dlls there!
Curl.Initialize(A_ScriptDir . "\libs")
; Curl.Deinitialize will be called automatically on exit.

myCurl := new Curl()
myCurl.SetUrl("http://example.com")
myCurl.WriteToFile("example_1_httpget.htm")
headBuffer := myCurl.HeaderToMem()
myCurl.Perform()

MsgBox % "Perform result:`n`n"
. myCurl.lastCode " : " myCurl.lastCodeText  ; Should be '0 : No error'

MsgBox % "Headers:`n`n"
. headBuffer.GetAsText("UTF-8")

MsgBox % "Info:`n"
. "`n" . myCurl.GetInfo(Curl.Info.EFFECTIVE_URL)
. "`n" . myCurl.GetInfo(Curl.Info.RESPONSE_CODE)
. "`n" . myCurl.GetInfo(Curl.Info.TOTAL_TIME_T) / 1000000