#NoEnv
#Warn All
#Warn LocalSameAsGlobal, Off
SetWorkingDir %A_ScriptDir%

#Include LibCurl.ahk

; First function to call is Curl.Initialize.
; Point it to the folder with all necessary dll-files.
Curl.Initialize("Libs")


; Create instance of curl's easy interface
myCurl := new Curl()



; Example 1: simplest HTTP GET to file
; ====================================
; Call .WriteToFile(filename) or .WriteToMem([maxCapacity]) to store downloaded data.
; Call .HeaderToFile(filename) or .HeaderToMem([maxCapacity]) to store headers.
; And finally, .ReadFromFile(filename) or .ReadFromMem(dataPtr, dataSize) for uploads.
myCurl.SetUrl("http://example.com")
myCurl.WriteToFile("example_1_httpget.htm")

myCurl.Perform()

MsgBox % "Example 1 result:`n"
. "`n" . myCurl.lastCode " : " myCurl.lastCodeText " (from " . myCurl.lastCodeSource . ")"



; Example 2: HTTPS GET
; ====================
myCurl.SetUrl("https://example.com")
myCurl.WriteToFile("example_2_httpget.htm")
myCurl.Perform()

MsgBox % "Example 2.1 result:`n"
. "`n" . myCurl.lastCode " : " myCurl.lastCodeText " (from " . myCurl.lastCodeSource . ")"

; Uh-oh, looks like we've got an error! And our output file is now empty!
; Let's set some options and try again.

If (securityMatters := False) {
	myCurl.SetOpt(Curl.Opt.SSL_VERIFYHOST, True)
	myCurl.SetOpt(Curl.Opt.SSL_VERIFYPEER, True)
	myCurl.SetOpt(Curl.Opt.CAINFO, "Libs\curl-ca-bundle.crt")
} Else {
	myCurl.SetOpt(Curl.Opt.SSL_VERIFYHOST, 0)
	myCurl.SetOpt(Curl.Opt.SSL_VERIFYPEER, 0)
}

myCurl.Perform()

MsgBox % "Example 2.2 result:`n"
. "`n" . myCurl.lastCode " : " myCurl.lastCodeText " (from " . myCurl.lastCodeSource . ")"



; Example 3: Download to memory buffer
; ====================================
; You can set maximum capacity that buffer can hold.
; By default capacity is 8 megabytes.
; If the data is bigger than the buffer, you'll get an error (and only partial result).
memBuffer := myCurl.WriteToMem( maxCapacity := 16384 )  ; 16kb should be enough
myCurl.Perform()

memBufferText := memBuffer.GetAsText("UTF-8")

MsgBox % "Example 3 result:`n"
. "`n" . myCurl.lastCode " : " myCurl.lastCodeText " (from " . myCurl.lastCodeSource . ")"
. "`n`n" . SubStr(memBufferText, 1, 128)
. "`n" . "...and more, total " . StrLen(memBufferText) . " symbols"



; Example 4: Download headers as well
; ===================================
headBuffer := myCurl.HeaderToMem( maxCapacity := 16384 )
myCurl.Perform()

headBufferText := headBuffer.GetAsText("UTF-8")

MsgBox % "Example 4 result:`n"
. "`n" . myCurl.lastCode " : " myCurl.lastCodeText " (from " . myCurl.lastCodeSource . ")"
. "`n`n" . SubStr(headBufferText, 1, 128)
. "`n" . "...and more, total " . StrLen(headBufferText) . " symbols"


; Example 5: Custom callbacks
; ===========================
; You can set .OnWrite, .OnHeader, .OnRead, .OnProgress and .OnDebug callbacks.
; If you return empty string, reading/writing will proceed as usual.
; If you return any value instead, it will assume you took care of the data,
; no reading/writing will occur and returned value will go back directly to libcurl.
; Be aware that some callbacks may be called repeatedly even if no real data transferred.
MyOnWrite(dataPtr, dataSize, curlInstance) {
	MsgBox % "Oh look, we've got " . dataSize . " bytes of data!"
	Return dataSize  ; Prevent writing
}
MyOnHeader(dataPtr, dataSize, curlInstance) {
	MsgBox % "Oh look, we've got " . dataSize . " bytes of headers!"
	Return dataSize  ; Prevent writing
}
MyOnRead(dataPtr, dataSize, curlInstance) {
	MsgBox % "Oh look, we need to fill the buffer with " . dataSize . " bytes of data!"
	Return dataSize  ; Prevent reading
}
MyOnProgress(dlTotal, dlNow, ulTotal, ulNow, curlInstance) {
	MsgBox % "Oh look, some progress happened:`n"
	. "We got  " . dlNow . " bytes of " . dlTotal " total`n"
	. "We sent " . ulNow . " bytes of " . ulTotal " total`n"
	Return 0
}
MyOnDebug(infoType, dataPtr, dataSize, curlInstance) {
	; This is complicated and rarely used.
}

myCurl.OnWrite    := Func("MyOnWrite")
myCurl.OnHeader   := Func("MyOnHeader")
myCurl.OnRead     := Func("MyOnRead")
myCurl.OnProgress := Func("MyOnProgress")
myCurl.Perform()


; And finally, some information!
MsgBox % "Example 5 result:`n"
. "`n" . "EFFECTIVE_URL:`t"           . myCurl.GetInfo(Curl.Info.EFFECTIVE_URL)
. "`n" . "EFFECTIVE_METHOD:`t"        . myCurl.GetInfo(Curl.Info.EFFECTIVE_METHOD)
. "`n" . "RESPONSE_CODE:`t"           . myCurl.GetInfo(Curl.Info.RESPONSE_CODE)
. "`n" . "REQUEST_SIZE:`t"            . myCurl.GetInfo(Curl.Info.REQUEST_SIZE)
. "`n" . "CONTENT_LENGTH_DOWNLOAD:`t" . myCurl.GetInfo(Curl.Info.CONTENT_LENGTH_DOWNLOAD_T)
. "`n" . "TOTAL_TIME:`t"              . myCurl.GetInfo(Curl.Info.TOTAL_TIME)
. "`n" . "CONTENT_TYPE:`t"            . myCurl.GetInfo(Curl.Info.CONTENT_TYPE)
. "`n" . "SPEED_DOWNLOAD:`t"          . myCurl.GetInfo(Curl.Info.SPEED_DOWNLOAD_T)