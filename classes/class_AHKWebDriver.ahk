#noenv
;#include json.ahk

class WDSession{
	;-- Selectors -------------------------------------
	static CSS				:= "css selector"
	static LinkText 		:= "link text"
	static PartialLinkTExt  := "partial link text"
	static TagName			:= "tag name"
	static XPath			:= "xpath"
	;-- Key codes (UPV) -------------------------------
	static keys := {}
		keys.Unidentified 	:= chr(0xE000)
		keys.Cancel 		:= chr(0xE001)
		keys.Help			:= chr(0xE002)
		keys.Backspace 		:= chr(0xE003)
		keys.Tab 			:= chr(0xE004)
		keys.Clear 			:= chr(0xE005)
		keys.Return 		:= chr(0xE006)
		keys.Enter 			:= chr(0xE007)
		keys.Shift			:= chr(0xE008)
		keys.Control 		:= chr(0xE009)
		keys.Alt 			:= chr(0xE00A)
		keys.Pause 			:= chr(0xE00B)
		keys.Escape 		:= chr(0xE00C)
		keys.PageUp 		:= chr(0xE00E)
		keys.PageDown 		:= chr(0xE00F)
		keys.End 			:= chr(0xE010)
		keys.Home 			:= chr(0xE011)
		keys.ArrowLeft 		:= chr(0xE012)
		keys.ArrowUp 		:= chr(0xE013)
		keys.ArrowRight 	:= chr(0xE014)
		keys.ArrowDown 		:= chr(0xE015)
		keys.Insert 		:= chr(0xE016)
		keys.Delete 		:= chr(0xE017)
	;-- Sync modes -------------------------------
	static Async := "async"
	static Sync  := "sync"

	;-- instance vars ---------------------------------
    sessionId := ""
    prefijo   := ""
    rc        := ""
	capabilities := ""
    __New(location:="http://localhost:9515/", capabilities:=""){
 	    local body := {}
		 if(capabilities != ""){
        	body.capabilities := capabilities
			body := JSON.Stringify(body)
		 }
		else
			body := "{""capabilities"":{}}"
		this.prefijo:=location
        this.rc := WDSession.__ws("POST", this.prefijo "session",body )
		this.sessionId := this.rc.value.sessionid
		this.capabilities := this.rc.value.capabilities
       	return this
    }
    url(url){
        local body := {}
        body.url := url
        this.rc := WDSession.__ws("POST", this.prefijo "session/" this.sessionId "/url", JSON.Stringify(body))
		return this.rc.isError
    }
	getUrl(){
		this.rc := WDSession.__ws("GET", this.prefijo "session/" this.sessionId "/url")
		return this.rc.value
	}
	back(){
		this.rc := WDSession.__ws("POST", this.prefijo "session/" this.sessionId "/back", "{}")
		return this.rc.isError
	}
	forward(){
		this.rc := WDSession.__ws("POST", this.prefijo "session/" this.sessionId "/forward", "{}")
		return this.rc.isError
	}
	refresh(){
		this.rc := WDSession.__ws("POST", this.prefijo "session/" this.sessionId "/refresh", "{}")
		return this.rc.isError
	}
    delete(){
        this.rc := WDSession.__ws("DELETE", this.prefijo "session/" this.sessionId)
		return this.rc.isError
    }
	getTitle(){
		this.rc := WDSession.__ws("GET", this.prefijo "session/" this.sessionId "/title")
		return this.rc.value
	}
	getWindow(){
		this.rc := WDSession.__ws("GET", this.prefijo "session/" this.sessionId "/window")
		return this.rc.value
	}
	window(handle){
        local body := {}
        body.handle := handle
        this.rc := WDSession.__ws("POST", this.prefijo "session/" this.sessionId "/window", JSON.Stringify(body))
		return this.rc.isError
    }
	newWindow(type){
		local body := {}
        body.type := (type = "") ? "tab" : type
        this.rc := WDSession.__ws("POST", this.prefijo "session/" this.sessionId "/window/new", JSON.Stringify(body))
		return this.rc.value.handle
	}
	closeWindow(){
    	this.rc := WDSession.__ws("DELETE", this.prefijo "session/" this.sessionId "/window")
		return this.rc.isError
    }
	getWindowHandles(){
		this.rc := WDSession.__ws("GET", this.prefijo "session/" this.sessionId "/window/handles")
		return this.rc.value
	}
	windowMaximize(){
		this.rc := WDSession.__ws("POST", this.prefijo "session/" this.sessionId "/window/maximize", "{}")
		return this.rc.isError
	}
	windowMinimize(){
		this.rc := WDSession.__ws("POST", this.prefijo "session/" this.sessionId "/window/minimize", "{}")
		return this.rc.isError
	}
	windowFullscreen(){
		this.rc := WDSession.__ws("POST", this.prefijo "session/" this.sessionId "/window/fullscreen", "{}")
		return this.rc.isError
	}
	getWindowRect(){
		this.rc := WDSession.__ws("GET", this.prefijo "session/" this.sessionId "/window/rect")
		return this.rc.value
	}
	windowRect(x:="", y:="", width:="", height:=""){
		local body := {}
		if(IsObject(x))
			body := x
		else{
			if(x!="")
				body.x      := x
			if(y!="")
				body.y      := y
			if(width!="")
				body.width  := width
			if(height!="")
				body.height := height
		}
		this.rc := WDSession.__ws("POST", this.prefijo "session/" this.sessionId "/window/rect", JSON.Stringify(body))
		if(this.rc.isError)
			return ""
		return this.rc.value
	}
	frame(id:=""){
		local body := "{""id"": "
		if(id=""){
			body .= "null}"
		}else if(RegExMatch(id,"^\d+$")){
				body .= id "}"
			  }else	if(isObject(id) && id.uuid = WDSession.WDElement.weID){
						body .= "{""" WDSession.WDElement.weID """: """ id.ref """}}"
					}
					else
						body .= """" id """}"
		this.rc := WDSession.__ws("POST", this.prefijo "session/" this.sessionId "/frame", body)
		return this.rc.isError
	}
	frameParent(){
		this.rc := WDSession.__ws("POST", this.prefijo "session/" this.sessionId "/frame/parent", "{}")
		return this.rc.isError
	}
	getElementActive(){
		this.rc := WDSession.__ws("GET", this.prefijo "session/" this.sessionId "/element/active")
		if(this.rc.isError)
			return ""
		return new WDSession.WDElement(this.rc.value, this)
	}
	element(selector, value){
		local body := {using: selector, value: value }
		this.rc := WDSession.__ws("POST", this.prefijo "session/" this.sessionId "/element", JSON.Stringify(body))
		if(this.rc.isError)
			return ""
		return new WDSession.WDElement(this.rc.value, this)
	}
	elements(selector, value){
		local body := {using: selector, value: value }
		local list,i,k
		this.rc := WDSession.__ws("POST", this.prefijo "session/" this.sessionId "/elements", JSON.Stringify(body))
		if(this.rc.isError)
			return ""
		list:=[]
		loop % this.rc.value.Count()
			list.push(new WDSession.WDElement(this.rc.value[A_index], this))
		return list
	}
	getSource(){
		this.rc := WDSession.__ws("GET", this.prefijo "session/" this.sessionId "/source")
		if(this.rc.isError)
			return ""
		return this.rc.value
	}
	execute(script, args:="", sync:="sync"){
		local body:={}
		local x,i
		body.script := script
		if(args="")
			args:=[]
		else
			for x in args
				if(IsObject(args[x])){
					if(args[x].uuid = WDSession.WDElement.weID)
						args[x] := {WDSession.WDElement.weID: args[x].ref}
					else
						this.__dumpObj(args[x])
				}
		body.args:=args
		this.rc := WDSession.__ws("POST", this.prefijo "session/" this.sessionId "/execute/" sync, JSON.Stringify(body))
		if(isObject(this.rc.value))
			if(this.rc.value.HasKey(WDSession.WDElement.weID))
				this.rc.value := new WDSession.WDElement(obj, this)
			else
				this.__translateObj(this.rc.value)
		return this.rc.isError
	}
	getAllCookies(){
		this.rc := WDSession.__ws("GET", this.prefijo "session/" this.sessionId "/cookie")
		if(this.rc.isError)
			return ""
		return this.rc.value
	}
	getCookie(name){
		this.rc := WDSession.__ws("GET", this.prefijo "session/" this.sessionId "/cookie/" name)
		if(this.rc.isError)
			return ""
		return this.rc.value
	}
	cookie(name,value,path:="",domain:="",secure:="",httpOnly:="",expiry:=""){
		local body:={}
		cookieObj:={}
		cookieObj.name:=name
		cookieObj.value:=value
		if(isObject(path)){
			for k,v in path
				cookieObj[k]:=v
		}else{
			if(path!="")
				cookieObj.path:=path
			if(domain!="")
				cookieObj.domain:=domain
			if(secure!="")
				cookieObj.secure:=secure
			if(httpOnly!="")
				cookieObj.httpOnly:=httpOnly
			if(expiry!="")
				cookieObj.expiry:=expiry
		}
		body.cookie:=cookieObj
		this.rc := WDSession.__ws("POST", this.prefijo "session/" this.sessionId "/cookie", JSON.Stringify(body))
		return this.rc.isError
	}
	delCookie(name){
		this.rc := WDSession.__ws("DELETE", this.prefijo "session/" this.sessionId "/cookie/" name)
		return this.rc.isError
	}
	delAllCookies(){
		this.rc := WDSession.__ws("DELETE", this.prefijo "session/" this.sessionId "/cookie")
		return this.rc.isError
	}
	getScreenshot(){
		this.rc := WDSession.__ws("GET", this.prefijo "session/" this.sessionId "/screenshot")
		if(this.rc.isError)
			return ""
		return this.rc.value
	}
	alertDismiss(){
		this.rc := WDSession.__ws("POST", this.prefijo "session/" this.sessionId "/alert/dismiss", "{}")
		return this.rc.isError
	}
	alertAccept(){
		this.rc := WDSession.__ws("POST", this.prefijo "session/" this.sessionId "/alert/accept", "{}")
		return this.rc.isError
	}
	getAlertText(){
		this.rc := WDSession.__ws("GET", this.prefijo "session/" this.sessionId "/alert/text")
		return this.rc.value
	}
	; error in chromedriver: https://bugs.chromium.org/p/chromedriver/issues/detail?id=1120
	alertText(newText){
		local body:={}
		body.text:=newtext
		this.rc := WDSession.__ws("POST", this.prefijo "session/" this.sessionId "/alert/text", JSON.Stringify(body))
		return this.rc.isError
	}

	__dumpObj(obj){
		local key, value
		for key, value in obj
		{
			if(isObject(value)){
				if( value.uuid=WDSession.WDElement.weID )
					obj[key] := {WDSession.WDElement.weID: value.ref}
				else
					this.__dumpObj(value)
			}
		}
	}

	__translateObj(obj){
		local key, value
		for key, value in obj
		{
			if(IsObject(value))
				if(value.hasKey(WDSession.WDElement.weID)){
					obj[key]:=new WDSession.WDElement(value, this)
				}else
					this.__translateObj(value)
		}
	}


	;..............................................................................................................
	class WDElement{
		static weID := "element-6066-11e4-a52e-4f735466cecf"
		uuid	   := WDSession.WDElement.weId
		ref        := ""
		objSession := ""
		rc 		   := ""
		__New(obj, objSession){
			this.ref 		:= obj[WDSession.WDElement.weID]
			this.objSession := objSession
		}
		getSelected(){
			this.rc := WDSession.__ws("GET", this.objSession.prefijo "session/" this.objSession.sessionId "/element/" this.ref "/selected")
			if(this.rc.isError)
				return ""
			return this.rc.value
		}
		getAttribute(name){
			this.rc := WDSession.__ws("GET", this.objSession.prefijo "session/" this.objSession.sessionId "/element/" this.ref "/attribute/" name)
			if(this.rc.isError)
				return ""
			return this.rc.value
		}
		getProperty(name){
			this.rc := WDSession.__ws("GET", this.objSession.prefijo "session/" this.objSession.sessionId "/element/" this.ref "/property/" name)
			if(this.rc.isError)
				return ""
			return this.rc.value
		}
		getCSS(propertyName){
			this.rc := WDSession.__ws("GET", this.objSession.prefijo "session/" this.objSession.sessionId "/element/" this.ref "/css/" propertyName)
			if(this.rc.isError)
				return ""
			return this.rc.value
		}
		getText(){
			this.rc := WDSession.__ws("GET", this.objSession.prefijo "session/" this.objSession.sessionId "/element/" this.ref "/text")
			if(this.rc.isError)
				return ""
			return this.rc.value
		}
		getName(){
			this.rc := WDSession.__ws("GET", this.objSession.prefijo "session/" this.objSession.sessionId "/element/" this.ref "/name")
			if(this.rc.isError)
				return ""
			return this.rc.value
		}
		getRect(){
			this.rc := WDSession.__ws("GET", this.objSession.prefijo "session/" this.objSession.sessionId "/element/" this.ref "/rect")
			if(this.rc.isError)
				return ""
			return this.rc.value
		}
		getEnabled(){
			this.rc := WDSession.__ws("GET", this.objSession.prefijo "session/" this.objSession.sessionId "/element/" this.ref "/enabled")
			if(this.rc.isError)
				return ""
			return this.rc.value
		}
		click(){
			this.rc := WDSession.__ws("POST", this.objSession.prefijo "session/" this.objSession.sessionId "/element/" this.ref "/click", "{}")
			return this.rc.isError
		}
		clear(){
			this.rc := WDSession.__ws("POST", this.objSession.prefijo "session/" this.objSession.sessionId "/element/" this.ref "/clear", "{}")
			return this.rc.isError
		}
		value(keys){
			this.rc := WDSession.__ws("POST", this.objSession.prefijo "session/" this.objSession.sessionId "/element/" this.ref "/value", JSON.Stringify({text: keys}))
			return this.rc.isError
		}
		getScreenshot(){
			this.rc := WDSession.__ws("GET", this.objSession.prefijo "session/" this.objSession.sessionId "/element/" this.ref "/screenshot")
			if(this.rc.isError)
				return ""
			return this.rc.value
		}
	}

	;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	__ws(metodo, url, cuerpo:=""){
		static WS_SERVIDOR := ComObjCreate("Msxml2.XMLHTTP")
		local rc:={}
		WS_SERVIDOR.Open(metodo,url, false)
		WS_SERVIDOR.setRequestHeader("Content-Type","application/json; charset=UTF-8")
		WS_SERVIDOR.Send(cuerpo)
		rc.status  := WS_SERVIDOR.Status
		rc.isError := (WS_SERVIDOR.Status < 200 or WS_SERVIDOR.Status > 299)
		rc.raw     := WS_SERVIDOR.ResponseText
		rc.value    := JSON.Parse(rc.raw).value
		return rc
	}

	debug(copyToClipboard:=true){
		if(copyToClipboard)
			Clipboard:=this.rc.raw
		msg := this.rc.raw
			. "`n---------------------------------------"
	    	. "`n Error:" this.rc.isError
    		. "`n Status:" this.rc.status
			. "`n---------------------------------------"
		if(isObject(this.rc.value)){
			msg .= "`n Value:"
    		for k,v in this.rc.value
				msg .= "`n " k ":" v
		}
		else
			msg .= "`n Value:" this.rc.value
		msgbox % msg
	}
}

/* sample chorme capabilities
{"value":
    {
        "capabilities":{
            "acceptInsecureCerts":false,
            "browserName":"chrome",
            "browserVersion":"77.0.3865.120",
            "chrome":{"chromedriverVersion":"77.0.3865.40 (f484704e052e0b556f8030b65b953dce96503217-refs/branch-heads/3865@{#442})",
            "userDataDir":"C:\\Users\\devnu\\AppData\\Local\\Temp\\scoped_dir13836_1519564804"},
            "goog:chromeOptions":{"debuggerAddress":"localhost:54290"},
            "networkConnectionEnabled":false,
            "pageLoadStrategy":"normal",
            "platformName":"windows nt",
            "proxy":{},
            "setWindowRect":true,
            "strictFileInteractability":false,
            "timeouts":{"implicit":0,"pageLoad":300000,"script":30000},
            "unhandledPromptBehavior":"dismiss and notify"
        },
            "sessionId":"bf39f8f8ea5174cb0c6d928039bb0981"
    }
}
*/
