;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

XMLHTTP_PostForm(ByRef URL, ByRef POSTDATA, ByRef response:=0, ByRef moreHeaders:=0) {
    ;wrapper for older scripts
    return XMLHTTP_Post(URL, POSTDATA, response, moreHeaders)
}

XMLHTTP_Post(ByRef URL, ByRef POSTDATA, ByRef response:=0, ByRef reqmoreHeaders:=0) {
    If (IsObject(reqmoreHeaders)) {
	If (reqmoreHeaders.HasKey("Content-Type")) {
	    moreHeaders := reqmoreHeaders
	} Else {
	    moreHeaders := reqmoreHeaders.Clone()
	    moreHeaders["Content-Type"] := "application/x-www-form-urlencoded"
	}
    } Else {
	moreHeaders := {"Content-Type": "application/x-www-form-urlencoded"}
    }
    return XMLHTTP_Request("POST", URL, POSTDATA, response, moreHeaders)
}

#include %A_LineFile%\..\XMLHTTP_Request.ahk

If (A_ScriptFullPath == A_LineFile) { ; this is direct call, not inclusion
    tries:=20
    retryDelay:=1000
    Loop %0%
    {
	arg:=%A_Index%
	argFlag:=SubStr(arg,1,1)
	If (argFlag=="/" || argFlag=="-") {
	    arg:=SubStr(arg,2)
	    foundPos := RegexMatch(arg, "([^=]+)=(.+)", argkv)
	    If (foundPos) {
		If (argkv1 = "tries") {
		    tries := argkv2
		} Else If (argkv1 = "retryDelay") {
		    retryDelay := argkv2
		} Else {
		    XMLHTTP_EchoWrongArg(arg)
		}
	    } Else {
		If (arg="debug") {
		    debug := Object()
		    FileAppend Включен режим отладки`n, **
		} Else {
		    XMLHTTP_EchoWrongArg(arg)
		}
	    }
	} Else If (!URL) {
	    URL:=arg
	} Else If (!POSTDATA) {
	    POSTDATA:=arg
	} Else {
	    XMLHTTP_EchoWrongArg(arg)
	}
    }
    Loop %tries%
    {
	response := Object()
	If (XMLHTTP_PostForm(URL,POSTDATA, response))
	    Exit 0
	sleep %retryDelay%
    }
    ExitApp response.status
}

XMLHTTP_EchoWrongArg(arg) {
    FileAppend Неправильный аргумент: %arg%`n, **
}
