;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

GetURL(ByRef URL, tries := 20, delay := 3000) {
    While (!XMLHTTP_Request("GET", URL,, resp))
	If (A_Index > tries)
	    Throw Exception("Error downloading URL",, resp.status)
	Else
	    sleep delay
    
    return resp
}

XMLHTTP_Request(ByRef method, ByRef URL, ByRef POSTDATA:="", ByRef response:=0, ByRef moreHeaders:=0) {
    global debug
    static useObjName:=""
    ;Error at line 13 in #include file "\\Srv0.office0.mobilmir\profiles$\Share\config\_Scripts\Lib\XMLHTTP_Post.ahk".

    ;Line Text: local xhr := ComObjCreate(useObjName)
    ;Error: Local variables must not be declared in this function.

    ;The program will exit.
    ;local i, objName, hName, hVal, k, v
    
    If (IsObject(debug)) {
	If (moreHeaders)
	    For i, v in moreHeaders
		txtHeaders .= "`t" i ": " v "`n"
	FileAppend % method " " URL . (POSTDATA ? " ← " POSTDATA : "") ( moreHeaders ? "`n`tHeaders:`n" txtHeaders : "") "`n", **
    }
    If (useObjName) {
	xhr := ComObjCreate(useObjName)
    } Else {
	objNames := [ "Msxml2.XMLHTTP.6.0", "Msxml2.XMLHTTP.3.0", "Msxml2.XMLHTTP", "Microsoft.XMLHTTP" ]
	For i, objName in objNames {
	    ;xhr=XMLHttpRequest
	    If (IsObject(debug))
		FileAppend `tTrying to create object %objName%…
		
	    xhr := ComObjCreate(objName) ; https://msdn.microsoft.com/en-us/library/ms535874.aspx
	    If (IsObject(xhr)) {
		useObjName := objName
		If (IsObject(debug))
		    FileAppend Done!`n, **
		break
	    }
	    If (IsObject(debug))
		FileAppend nope`n, **
	}
	If (!useObjName)
	    Throw "Не удалось создать объект XMLHTTP"
    }
    ;xhr.open(bstrMethod, bstrUrl, varAsync, varUser, varPassword);
    xhr.open(method, URL, false)
    ;xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded")
    
    If (IsObject(moreHeaders))
	For hName, hVal in moreHeaders
	    xhr.setRequestHeader(hName, hVal)
    
    Try {
	xhr.send(POSTDATA)
	If (IsObject(response))
	    response := {status: xhr.status, headers: xhr.getAllResponseHeaders, responseText: xhr.responseText}
	Else If (IsByRef(response))
	    response := xhr.responseText
	If (IsObject(debug)) {
	    debug.Headers := xhr.getAllResponseHeaders
	    debug.Response := xhr.responseText
	    debug.Status := xhr.status	;can be 200, 404 etc., including proxy responses
	}
	return xhr.Status >= 200 && xhr.Status < 300
    } catch e {
	If (IsObject(debug)) {
	    debug.What:=e.What
	    debug.Message:=e.Message
	    debug.Extra:=e.Extra
	}
	return
    } Finally {
	xhr := ""
	If (IsObject(debug)) {
	    ;http://www.autohotkey.com/board/topic/56987-com-object-reference-autohotkey-l/#entry358974
	    ;static document
	    ;Gui Add, ActiveX, w750 h550 vdocument, % "MSHTML:" . debug.Response
	    ;Gui Show
	    For k,v in debug
		FileAppend %k%: %v%`n, **
	}
    }
}
