WS2_CleanUp()
global num = 0
global received, lastmessage, firstStart = 1
IfWinNotExist, ahk_class MozillaWindowClass
{
    MsgBox Firefox Not Found`nLaunching with Extension`nPlease Install and Restart
	runwait, firefox.exe ext\mozrepl@hyperstruct.net.xpi
	MsgBox Firefox Restarting`nHit OK When Firefox Has Reopened
	reload
}
class FF
{
	__New(aUrl = "current", aMake = 1, pwb = ""){
		if(RegExMatch(aUrl, "(http://|https://|ftp://)")){
			aSearch := "spec"
			aUrl := __FF_urlCheck(aUrl)
		}
		else
			aSearch := "host"
		if(aUrl = "current"){
			if(pwb){
				this.pwb := pwb
			}
			else{
				this.pwb := __FF_genPwb()
			}
			FF_Do("var " . this.pwb . " = window.content;")
			FF_Do("var " . this.pwb . "1 = window.getBrowser().webProgress;")
			return this
		}
		if(aMake = 2){
			this.pwb := __FF_newTab(aUrl, pwb)
			return this
		}
		else{
			this.pwb := __FF_findTab(aUrl, aSearch, pwb) 
			if(aSearch = "spec"){
				if(!this.pwb){
					if(!this.pwb){
						tempUrl := RegExReplace(aUrl, "://\K(w{3}.)", "", replaced)
						tempUrl1 := aUrl
						if(!replaced){
							tempUrl := RegExReplace(tempUrl, "://\K(?!w{3}.)", "www.")
						}
						
						this.pwb := __FF_findTab(tempUrl, aSearch, pwb)
					}
						tempUrl := RegExReplace(tempUrl, "p\K(s)(?=:/{2})", "", replaced)
						tempUrl1 := RegExReplace(tempUrl1, "p\K(s)(?=:/{2})", "")
						if(!replaced){
							tempUrl := RegExReplace(tempUrl, "p\K(\W)(?=/{2})", "s$1")
							tempUrl1 := RegExReplace(tempUrl1, "p\K(\W)(?=/{2})", "s$1")
						}
						if(!this.pwb){
							this.pwb := __FF_findTab(tempUrl, aSearch, pwb)
							if(!this.pwb){
								this.pwb := __FF_findTab(tempUrl1, aSearch, pwb)
							}
						}
				}
			}
					if(!this.pwb){
					if(aSearch = "host"){
					if(RegExMatch(aUrl, "www.")){
						tempUrl := RegExReplace(aURl, "www.", "")
					}
					else if(RegExMatch(aUrl, "^[a-zA-Z]{1,4}\.") && (!RegExMatch(aUrl, "^[a-zA-Z]{1,4}\.(com|net|edu|org)"))){
						tempUrl := RegExReplace(aUrl, "^[a-zA-Z]{1,4}\.", "www.")
					}
					else{
						tempUrl := "www." . aUrl
					}
					this.pwb := __FF_findTab(tempUrl, aSearch)
				}
			}
			if(!this.pwb){
				aUrl := __FF_urlCheck(aUrl)
				if(aMake = 1){
					this.pwb := __FF_newTab(aUrl)
				}
				else {
					throw Exception("Couldn't find " . aUrl . " as " . aSearch . ".")
				}
			}
		}
	}
		
	Remove(){
		FF_Do("var " . this.pwb . " = null; var " . this.pwb . "1 = null;")
		this.pwb := ""
	}
	
	isAlive(){
		return RegExMatch(FF_Do(this.pwb), "object Window")
	}
	Navigate(url){
		if(!(RegExMatch(url, "Javascript:"))){
			url := __FF_urlCheck(url)
		}
		return FF_Do(this.pwb . ".location.href = '" . url . "';")
	}
	
	Stop(){
		return FF_Do(this.pwb . ".stop();")
	}

	Back() {
	  return FF_Do(this.pwb . ".window.back();")
	}

	Home() {
	  return FF_Do(this.pwb . ".window.home();")
	}

	Forward() {
	  return FF_Do(this.pwb . ".window.forward();")
	}

	Reload(force = false) {
		if(force){
			return FF_Do(this.pwb . ".parent.location.reload(" . force . ");")
		}
		else{
			reload := FF_Do(this.pwb . ".location.href")
			return this.Navigate(reload)
		}
	}

	Copy() {
	  return FF_Do(this.pwb . ".document.getSelection();")
	}
	
	execScript(js) {
		return FF_Do(this.pwb . ".document.location.href = 'JavaScript:" . js . "'")
	}
	
	LoadWait(){
		while(FF_Do(this.pwb . "1.isLoadingDocument") && FF_Do(this.pwb . "1.busyFlags")){
			sleep,25
		}
		return	
	}

	getHostName(){
		return FF_Do(this.pwb . ".location.host;")
	}
	
	getElementsByName(name, index, action)
	{
		if(index == null)
		{
		  command := this.pwb . ".document.getElementsByName('" . name . "')" . action
		}
		else    
		{
		  command := this.pwb . ".document.getElementsByName('" . name . "')[" . index . "]" . action
		}
		return FF_Do(" " . command)
	}

	getElementById(name, action)
	{
		return FF_Do(this.pwb . ".document.getElementById('" . name . "')" . action)
	}

	getElementsByTagName(name, index, action)
	{
		if(index == null){
		  command := this.pwb . ".document.getElementsByTagName('" . name . "')" . action
		}
		else    {
		  command := this.pwb . ".document.getElementsByTagName('" . name . "')[" . index . "]" . action
	  }
		return FF_Do(" " . command)
	}

	getElementsByClassName(name, index, action)
	{
		if(index == null){
		  command := this.pwb . ".document.getElementsByClassName('" . name . "')" . action
		}
		else    {
		  command := this.pwb . ".document.getElementsByClassName('" . name . "')[" . index . "]" . action
	  }
		return FF_Do(" " . command)
	}


	Close(){
	  return FF_Do(this.pwb . ".window.close()")
	}

	getWinTitle()
	{
		while(!FF_Do(this.pwb . ".top.document.title")){
			sleep,100
		}
	  return FF_Do(this.pwb . ".top.document.title")
	}
	
	getTextContent(){
		return FF_Do(this.pwb . ".document.body.textContent;")
	}

}



;##############################################################################
;*** Lower-level socket operations to connect to MozRepl

; save the global socket in a static variable, not in global namespace
__FF_Socket(setsocket="") {
  static mozrepl_socket := -1
  if (setsocket) {
    mozrepl_socket := setsocket
  }
  return mozrepl_socket
}

; connect global socket
; also sets socket to non-blocking and slurps initial MozRepl text
; returns 0 on success, nonzero on failure
FF_Connect(host = "127.0.0.1", port=4242) {
	FF_Disconnect()   ; disconnects if already connected
	try{
		sock := WS2_Connect(host . ":" . port)
	}
	catch e{
		TrayTip, Error,% e.Message
		return -1
	}
	if (sock <= 0) {
		return -1
	}
	try{
		WS2_AsyncSelect(sock, "__FF_RecvSock")
	}
	catch e{
		TrayTip, Error,% e.Message
		return -1
	}
	if(sock > 0){
		__FF_Socket(sock)
		FF_Send("")
		return 1
	}
}

; disconnects global socket (or does nothing if already disconnected)
FF_Disconnect() {
  sock := __FF_Socket()
  if (sock > 0) {
    WS2_Disconnect(sock)
  }
  __FF_Socket(-1)
}

; sends data to the global socket
; returns zero on success
FF_Send(senddata) {
    global lastmessage
    lastmessage = 0
    try{
		WS2_SendData(__FF_Socket(), senddata . "`n")
		Pause, Off
	}
	catch e{
		TrayTip, Error,% e.Message
		if(RegExMatch(e.Message, "target machine actively refused it.")){
			MsgBox MozRepl doesn't appear to be running!`n`Launching Firefox with Extension`nPlease Install then Reload Script
			runwait, firefox.exe ext\mozrepl@hyperstruct.net.xpi
			MsgBox Firefox is Restarting`nPress OK when Firefox is Open
			Reload
		}
		else{
			FF_Connect()
		}
		return
	}
	timeout = 200
    return FF_Recv(timeout)
}

; get data
; stream is essentially a sequence of strings delimited by "repl> " prompts
; this function returns the next string in the sequence
FF_Recv(timeout=0) {
  global lastmessage, received
    while(!lastmessage){
		if(A_Index > timeout){
			FF_Connect()
			break
		}
        sleep,5
    }
    response := received
    received := ""
    return response
}
;*
__FF_RecvSock(sock, buff = "") {
  global received, lastmessage, firstStart
    if(firstStart){
        initial .= buff
        if(RegExMatch(buff, "repl\d?>", output)){
            received := output
            firstStart = 0
            lastmessage = 1
        }
        return
    }
    else if(RegExMatch(buff, "repl\d?>")){
        received .= buff
        received := RegExReplace(received, "\n?repl\d?>")
		received := RegExReplace(received, """", "")
		received := RegExReplace(received, " $")
        lastmessage = 1
        return
    }
	else if(RegExMatch(buff, "....>")){
		WS2_SendData(__FF_Socket(), ";`n")
		return
	}
    else{
        received .= buff
        return
    }
	return
}
;##############################################################################
;*** Everythig else

FF_Do(command) {
	response := FF_Send(command)
  return response
}

__FF_findTab(url, search, pwb = ""){
	if(!pwb){
		pwb := __FF_genPwb()
	}
   js := ""
   . "var wm = Components.classes['@mozilla.org/appshell/window-mediator;1']"
     . ".getService(Components.interfaces.nsIWindowMediator);"
   . "var browserEnumerator = wm.getEnumerator('navigator:browser');"
   . "var found = false;"
   . "while (!found && browserEnumerator.hasMoreElements())"
    . "{"
    . "var browserWin = browserEnumerator.getNext();"
     . "var tabbrowser = browserWin.gBrowser;"
     . "var numTabs = tabbrowser.browsers.length;"
     . "for (var index = 0; index < numTabs; index++)"
      . "{"
            . "var currentBrowser = tabbrowser.getBrowserAtIndex(index);"
            . "if ('" . url . "' == currentBrowser.currentURI." . search . ")"
            . " {"
                . "var " . pwb . " = tabbrowser.tabContainer.childNodes[index];"
				. "var " . pwb . "1 = " . pwb . ".linkedBrowser.webProgress;"
                . " " . pwb . " = " . pwb . ".linkedBrowser.contentWindow;"
                . "found = true;"
                . " break;"
              . "}"
      . "}"
   . "}"
	if(FF_Do(js) = ""){
		if(FF_Do(js) = ""){
			FF_Do(js)
		}
		
	}
	
	if(RegExMatch(FF_Do(pwb), "object Window")) {
		return pwb
	}	
	else {
		return 0
	}
		
} 


__FF_newTab(url, pwb = "")
{
	if(!pwb){
		pwb := __FF_genPwb()
	}
   js := "var " . pwb . " = gBrowser.loadOneTab('" . url . "');"
	. " " . pwb . "1 = " . pwb . ".linkedBrowser.webProgress;"
	. " " . pwb . " = " . pwb . ".linkedBrowser.contentWindow;"
    FF_Do(js)
	if(RegExMatch(FF_Do(pwb), "object Window")){
		return pwb
	}
	else{
		return 0
	}
}

__FF_genPwb()
{
	global num
	tempPwb := ""
	tempPwb := "newTab" . num
	num += 1
    return tempPwb
}

__FF_urlCheck(url){
	if(!(RegExMatch(url, "(http(|s)|ftp):(?=/{2})"))){
		url := "http://" . url
	}
	if((!(RegExMatch(url, "/$"))) && RegExMatch(url, ".(com|org|edu|net|info|xxx)$")){
		url := url . "/"
	}
	return url
}

