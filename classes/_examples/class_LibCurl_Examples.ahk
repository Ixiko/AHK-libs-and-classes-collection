#Include Libcurl.ahk
Curl.Initialize(A_ScriptDir . "\libs")


myFirstCurl := new Curl()

myCurl := myFirstCurl.Duplicate()  ; This will copy all options you set before.

MsgBox % "1. Download to file"
; =========================
myCurl.SetUrl("http://httpbin.org/get")
myCurl.SetOutputFile("example_01_output.txt")
myCurl.SetHeaderFile("example_01_header.txt")
myCurl.Perform()


MsgBox % "2. Download to memory"
; ===========================
myCurl.SetOutputFile(":")
myCurl.SetHeaderFile(":")
myCurl.Perform()

MsgBox % "Output data: `n`n" . StrGet(myCurl.output.dataPtr, myCurl.output.dataSize, "CP0")
MsgBox % "Header data: `n`n" . StrGet(myCurl.header.dataPtr, myCurl.header.dataSize, "CP0")


MsgBox % "3. Getting info"
; ========================
MsgBox % Format("Final URL: {1}`nHTTP code: {2}`nTransfer time: {3:.3f} / {4:.3f} seconds"
,  myCurl.GetInfo(Curl.Info.EFFECTIVE_URL)  ; String
,  myCurl.GetInfo(Curl.Info.RESPONSE_CODE)  ; Int
,  myCurl.GetInfo(Curl.Info.TOTAL_TIME)     ; Double
,  myCurl.GetInfo(Curl.Info.TOTAL_TIME_T) / 1000000)  ; Curl_off_t


MsgBox % "4. POST form (x-www-form-urlencoded)"
;==============================================
myCurl.SetUrl("http://httpbin.org/post")
myCurl.SetOutputFile("example_04_output.txt")
myCurl.SetDebugFile("example_04_debug.txt")
myCurl.SetPostForm( "hello","wörld",  "whatis","love" )  ; Using key-value pairs
; myCurl.SetPostForm( {hello:"wörld",  whatis:"love"} )  ; Using object
myCurl.Perform()


MsgBox % "5. POST form (multipart/form-data)"
; ===========================================
myCurl.SetOutputFile("example_05_output.txt")
myCurl.SetDebugFile("example_05_debug.txt")
myItem := { name:"mimename"
          , type:"text/plain"
		  , filedata:"example_01_header.txt"
		  , filename:"return_to_sender.txt" }

myMimePtr := myCurl.ArrayToMime( [myItem] )
myCurl.SetOpt(Curl.Opt.MIMEPOST, myMimePtr)
myCurl.Perform()


MsgBox % "6. HTTPS"
; =================
myCurl.Reset()
myCurl.SetUrl("https://curl.haxx.se/logo/curl-logo.svg")
myCurl.SetOutputFile("example_06_output.svg")
myCurl.SetDebugFile("example_06_debug.txt")

; We can either disable secure checks..
myCurl.SetOpt(Curl.Opt.SSL_VERIFYPEER, 0)
myCurl.SetOpt(Curl.Opt.SSL_VERIFYHOST, 0)
; ..or provide certificate bundle:
;   myCurl.SetOpt(Curl.Opt.CAINFO, A_ScriptDir . "\libs\curl-ca-bundle.crt")
myCurl.Perform()


MsgBox % "7. OnProgress Callback"
; ===============================
myCurl.Reset()
myCurl.SetUrl("http://www.ovh.net/files/1Mio.dat")  ; 1 megabyte test file
myCurl.SetOutputFile("1Mio.dat")
myCurl.SetDebugFile("")
myCurl.SetProgressFunc( Func("WatcherFn") )

WatcherFn(DT := "", DN := "", UT := "", UN := "", curlRef := "") {
	percentage := Floor(100 * DN / DT)
	Progress, 1:%percentage%, % Format("{1} / {2} bytes", DN, DT)
	Sleep 50
	Return 0  ; Return non-zero to abort transfer
}

Progress, 1:Show
myCurl.Perform()
Sleep 1000
Progress, 1:Off


MsgBox % "8. This website uses cookies to improve your experience"
; ================================================================
myCurl.SetCookieFile(A_ScriptDir . "\cookies.txt")  ; Must be absolute path
myCurl.SetOpt(Curl.Opt.COOKIE, "hey=jude")

myCurl.SetUrl("http://httpbin.org/cookies/set/my_cookie/my_value")
myCurl.SetOutputFile(":")
myCurl.SetDebugFile("example_08a_debug.txt")
myCurl.Perform()

myCurl.SetUrl("http://httpbin.org/cookies/set/another_cookie/in_the_wall")
myCurl.SetDebugFile("example_08b_debug.txt")
myCurl.Perform()

cookieList := myCurl.GetInfo(Curl.Info.COOKIELIST)
cMsg := "Cookies in the engine:`n`n"
For index, cookieString In cookieList {
	cMsg .= cookieString . "`n"
}
MsgBox % cMsg

myCurl.Cleanup()  ; CookieJar will be saved only after the end of the session.


MsgBox % "That's all folks!"