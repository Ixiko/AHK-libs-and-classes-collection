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


; Please note: this example will not use MsgBox,
; instead most data will be written to files.
; Check them to see how examples 


; Example 1: Headers
; ==================
; We'll set some headers and get them as a reply from echo server.
; If you want to pass special headers for proxy, use .SetProxyHeaders( headersArray )

myCurl.SetUrl("http://httpbin.org/get?key=value&hey=valve")

myCurl.SetOpt(Curl.Opt.ACCEPT_ENCODING, "")  ; Empty string should set all encodings libcurl can understand
myCurl.SetReferer("http://example.com")             ; For redirects autoreferer is more useful
myCurl.SetRedirects(3, False)                       ; Maximum of 3 redirects and no autoreferer
myCurl.SetUserAgent("totally not curl")             ; 
myCurl.SetCookie("foo=bar&baz=baq")                 ; This will not enable cookie engine, it's just a header
myCurl.SetHeaders(["Another-Header: in_the_wall"])  ; .SetHeaders require array of header-lines

myCurl.WriteToFile("example_c1_headers.reply.txt")
myCurl.Perform()


; Example 2: Authorization
; ========================
; Use .SetCredentials( user, pass [, authType] );  default authType is Basic
; You may probably need proxy credentials too, but I couldn't find the way to test it.
; myCurl.SetProxy( proxyUrl [, httpTunnel] )
; myCurl.SetProxyCredentials( user, pass [, proxyAuth] )myCurl.Reset()
myCurl.Reset()

myCurl.SetUrl("http://httpbin.org/basic-auth/userfoo/passbar")
myCurl.SetCredentials("userfoo", "passbar", "Basic")

myCurl.WriteToFile("example_c2-1_authbasic.reply.txt")
myCurl.Perform()

myCurl.SetUrl("http://httpbin.org/digest-auth/auth/foouser/barpass")
myCurl.SetCredentials("foouser", "barpass", "Digest Only")

myCurl.WriteToFile("example_c2-2_authdigest.reply.txt")
myCurl.Perform()



; Example 3: Cookies
; ==================
myCurl.Reset()
myCurl.SetUrl("http://httpbin.org/cookies/set/cookiename/cookiedata")
myCurl.SetCookieFile("")  ; Read cookies from file, empty string enables the cookie engine
myCurl.SetCookieJar("example_c3_cookies.jar.txt")   ; Write cookies to file

myCurl.SetRedirects(3, True)  ; We'll be redirected to /cookies in this example.

myCurl.WriteToFile("example_c3_cookies.reply.txt")
myCurl.Perform()


; We can force flush cookies to the jar before cleanup with this trick:
myCurl.SetOpt(Curl.Opt.COOKIELIST, "FLUSH")



; Example 4: POST
; ===============
Global example_c4_debugFile := FileOpen("example_c4.debug.txt", "w")

MyOnDebug(infoType, dataPtr, dataSize, curlInstance) {
	Static DBG_TYPE := ["Text", "Header_In", "Header_Out", "Data_In", "Data_Out", "SSL_In", "SSL_Out"]
	example_c4_debugFile.WriteLine( DBG_TYPE[infoType+1] )
	example_c4_debugFile.WriteLine(StrGet(dataPtr, dataSize, "CP0"))
}


; Example 4-1: Form data
myCurl.Reset()

myCurl.SetUrl("http://httpbin.org/post", "POST")
myCurl.SetPostForm( {"place":"Aperture Science's Lab",  "subject":"Chell",  "affections":"cakes, cubes"} )

myCurl.OnDebug := Func("MyOnDebug")
myCurl.WriteToFile("example_c4-1_postform.reply.txt")
myCurl.Perform()


; Example 4-2: Raw post body
myCurl.Reset()

VarSetCapacity(postBody := "", 256)
postBodyLen := StrPut("POST data to send", &postBody, "CP0") - 1

myCurl.SetUrl("http://httpbin.org/post", "POST")
myCurl.SetPostData(&postBody, postBodyLen)

myCurl.OnDebug := Func("MyOnDebug")
myCurl.WriteToFile("example_c4-2_postdata.reply.txt")
myCurl.Perform()


; Example 4-3: Multipart mime
myCurl.Reset()

myCurl.SetUrl("http://httpbin.org/post", "POST")
mimeObj := [{name:"MPName", type:"text/plain", encoder:"base64", dataPtr: &postBody, dataSize: postBodyLen}]
mimePtr := Curl.ArrayToMime(mimeObj)
myCurl.SetPostMime(mimePtr)

myCurl.OnDebug := Func("MyOnDebug")
myCurl.WriteToFile("example_c4-3_postmime.reply.txt")
myCurl.Perform()

Curl.FreeMime(mimePtr)

example_c4_debugFile.Close()