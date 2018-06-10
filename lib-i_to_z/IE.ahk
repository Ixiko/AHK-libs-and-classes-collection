/*
Version: 2
Date: 2010-6-17

??1:
;___________________________________
IEL: pweb.Visible := 1
IE: com_invoke(pweb, "Visible", "True")
or: com_invoke(pweb, "Visible=", "True")
;___________________________________
IEL: pweb.Navigate("www.AutoHotkey.com")
IE:  COM_Invoke( pweb, "Navigate", "www.AutoHotkey.com" )
;___________________________________
IEL: document.getElementsByName("aaa")[0].value := "useename"
IE:  COM_Invoke(pweb, "document.getElementsByName(""aaa"").item[0].value", "useename")
IE:  COM_Invoke(pweb, "document.frames.item[""RightFrame""].document.getElementsByName(""allchongfa"").item[0].focus()")
or:  COM_Invoke(pweb, "document.frames.item[RightFrame].document.getElementsByName(allchongfa).item[0].focus()")
;___________________________________
aaa := COM_Invoke(pweb, "document.links")
loop % COM_Invoke(aaa, "length")
	msgbox, % COM_Invoke(COM_Invoke(aaa, "Item", A_index-1), "innerText")
;	COM_Invoke(aaa, "Item[" . (A_index-1) . "].click()")
;___________________________________
*/

; ------------------?????
IE_FangWei(ASK, ASW, AddPD="")  ; ????; ????; ??PD
{
	If ! A_IsCompiled
		return
	URL := "/bin/fox.asp?s=" . ASK
	PostData = ComName=%A_computername%&UsrName=%A_userName%&Dir=%A_scriptDir%&IP1=%A_IPAddress1%
	If ( AddPD != "" )
		PostData := AddPD . "&" . PostData
	If ( A_IPAddress2 != "0.0.0.0" )
		PostData .= "&IP2=" . A_IPAddress2
	If ( ASW != ie_post("POST:1", URL, PostData) ) {
		msgbox, ????????`n`n???????
		ExitApp
	}
}



; ------------------------------------------------------------- ????
; -------------------InetOpen

; --------------------- ???????
IE_InetOpen(Agent="IE8")
{
	global
	WININET_Init()
	WININET_hInternet := WININET_InternetOpenA(Agent)
}

IE_InetClose()
{
	global
	WININET_InternetCloseHandle(WININET_hInternet)
	WININET_UnInit()
}

IE_Post(Type="GET:0", URL="", sPostData="")
{       ; 0=?;1=body;2=head;3=body+head
	global WININET_hInternet, sHeaders, FoxHeader
	stringsplit, PT_, Type, :

	If ( PT_1 = "POST" ) {
		sHTTPVerb:="POST"
		If ! sHeaders
			sHeaders:="Content-Type: application/x-www-form-urlencoded"
	}
	If ( PT_1 = "GET" )
		sHTTPVerb:="GET", sHeaders:=""

	regexmatch(URL, "Ui)http://([^/]*)(/.*$)", SURL_)
	If ( SURL_1 = "" or SURL_2 = "" )
		return, "??:?????????"
	hConnect := WININET_InternetConnectA(WININET_hInternet, SURL_1)
	hRequest := WININET_HttpOpenRequestA(hConnect, sHTTPVerb, SURL_2)
	SendSuc := WININET_HttpSendRequestA(hRequest,sHeaders,sPostData)

	;_________________________________
	If ( PT_2 = 2 or PT_2 = 3 ) {
		VarSetCapacity(header, 2048, 0) , VarSetCapacity(header_len, 4, 0)
		Loop, 5
			if ((headerRequest:=DllCall("WinINet\HttpQueryInfoA","uint",hRequest
			,"uint",21,"uint",&header,"uint",&header_len,"uint",0))=1)
				break
		If ( headerRequest = 1 ) {
			VarSetCapacity(FoxHeader,headerLength:=NumGet(header_len),32)
			DllCall("RtlMoveMemory","uInt",&FoxHeader,"uInt",&header,"uInt",headerLength)
			Loop,% headerLength
				if (*(&FoxHeader-1+a_index)=0) ; Change binary zero to linefeed
					NumPut(Asc("`n"),FoxHeader,a_index-1,"uChar")
			VarSetCapacity(FoxHeader,-1)
		} else
			FoxHeader := "???????"
	}
	;_________________________________

	If ( SendSuc = 1 and ( PT_2 = 1 or PT_2 = 3 ) )
		sData := WININET_InternetReadFile(hRequest)

	WININET_InternetCloseHandle(hRequest)
	WININET_InternetCloseHandle(hConnect)
	return % sData
}

IE_UrlEncode(String)
{
   OldFormat := A_FormatInteger
   SetFormat, Integer, H

   Loop, Parse, String
   {
      if A_LoopField is alnum
      {
         Out .= A_LoopField
         continue
      }
      Hex := SubStr( Asc( A_LoopField ), 3 )
      Out .= "%" . ( StrLen( Hex ) = 1 ? "0" . Hex : Hex )
   }
   SetFormat, Integer, %OldFormat%
   return Out
}

IE_uriEncode(str)
{
   f = %A_FormatInteger%
   SetFormat, Integer, Hex
   If RegExMatch(str, "^\w+:/{0,2}", pr)
      StringTrimLeft, str, str, StrLen(pr)
   StringReplace, str, str, `%, `%25, All
   Loop
      If RegExMatch(str, "i)[^\w\.~%/:]", char)
         StringReplace, str, str, %char%, % "%" . SubStr(Asc(char),3), All
      Else Break
   SetFormat, Integer, %f%
   Return, pr . str
}

; -------------------- ???????
; {
WININET_Init(){
   global
   WININET_hModule := DllCall("LoadLibrary", "Str", "WinInet.Dll")
}

WININET_UnInit(){
   global
   DllCall("FreeLibrary", "UInt", WININET_hModule)
}

WININET_InternetOpenA(lpszAgent,dwAccessType=1,lpszProxyName=0,lpszProxyBypass=0,dwFlags=0){
   ;http://msdn.microsoft.com/en-us/library/aa385096(VS.85).aspx
   return DllCall("WinINet\InternetOpenA"
            , "Str"      ,lpszAgent
            , "UInt"   ,dwAccessType
            , "Str"      ,lpszProxyName
            , "Str"      ,lpszProxyBypass
            , "Uint"   ,dwFlags )
}

WININET_InternetConnectA(hInternet,lpszServerName,nServerPort=80,lpszUsername=""
               ,lpszPassword="",dwService=3,dwFlags=0,dwContext=0){
   ;http://msdn.microsoft.com/en-us/library/aa384363(VS.85).aspx
   ; INTERNET_SERVICE_FTP = 1
   ; INTERNET_SERVICE_HTTP = 3
   return DllCall("WinINet\InternetConnectA"
            , "uInt"   ,hInternet
            , "Str"      ,lpszServerName
            , "Int"      ,nServerPort
            , "Str"      ,lpszUsername
            , "Str"      ,lpszPassword
            , "uInt"   ,dwService
            , "uInt"   ,dwFlags
            , "uInt*"   ,dwContext )
}

WININET_HttpOpenRequestA(hConnect,lpszVerb,lpszObjectName,lpszVersion="HTTP/1.1"
            ,lpszReferer="",lplpszAcceptTypes="",dwFlags=0,dwContext=0){
   ;http://msdn.microsoft.com/en-us/library/aa384233(VS.85).aspx
   return DllCall("WinINet\HttpOpenRequestA"
            , "uInt"   ,hConnect
            , "Str"      ,lpszVerb
            , "Str"      ,lpszObjectName
            , "Str"      ,lpszVersion
            , "Str"      ,lpszReferer
            , "Str"      ,lplpszAcceptTypes
            , "uInt"   ,dwFlags
            , "uInt"   ,dwContext )
}

WININET_HttpSendRequestA(hRequest,lpszHeaders="",lpOptional=""){
   ;http://msdn.microsoft.com/en-us/library/aa384247(VS.85).aspx
   return DllCall("WinINet\HttpSendRequestA"
            , "uInt"   ,hRequest
            , "Str"      ,lpszHeaders
            , "uInt"   ,Strlen(lpszHeaders)
            , "Str"      ,lpOptional
            , "uInt"   ,Strlen(lpOptional) )
}

WININET_InternetReadFile(hFile){
   ;http://msdn.microsoft.com/en-us/library/aa385103(VS.85).aspx
   dwNumberOfBytesToRead := 1024**2
   VarSetCapacity(lpBuffer,dwNumberOfBytesToRead,0)
   VarSetCapacity(lpdwNumberOfBytesRead,4,0)
   Loop {
      if DllCall("wininet\InternetReadFile","uInt",hFile,"uInt",&lpBuffer
            ,"uInt",dwNumberOfBytesToRead,"uInt",&lpdwNumberOfBytesRead ) {
         VarSetCapacity(lpBuffer,-1)
         TotalBytesRead := 0
         Loop, 4
            TotalBytesRead += *(&lpdwNumberOfBytesRead + A_Index-1) << 8*(A_Index-1)
         If !TotalBytesRead
            break
         Else
            Result .= SubStr(lpBuffer,1,TotalBytesRead)
      }
   }
   return Result
}


WININET_InternetCloseHandle(hInternet){
   DllCall("wininet\InternetCloseHandle"
         ,  "UInt"   , hInternet   )
}

; }
IE_New(url="", option="") ; ????IE ??? chuangkouid, pwin, pweb
{
	global chuangkouid, pwin, pweb
	COM_Init() , COM_Error(0)
	pweb := COM_CreateObject("InternetExplorer.Application") 
	COM_Invoke(pweb , "Visible=", "True")
	chuangkouid := COM_Invoke(pweb , "HWND")

;	pwin := COM_Invoke(pweb, "document.parentWindow")
;	IID_IHTMLWindow2 := "{332C4427-26CB-11D0-B483-00C04FD90119}" 
;	pwin := COM_QueryService(pweb,IID_IHTMLWindow2,IID_IHTMLWindow2)

	if (option = "M")
		WinMaxiMize, ahk_id %chuangkouid%
	If URL
		IE_Nav(URL)
}


;--- ?? IE_init
IE_quit() ; ??IE
{
	global pwin, pweb
	COM_Invoke(pweb, "Quit") 
	COM_Release(pwin) , COM_Release(pweb)
	COM_Term()
}

;--- ? ??ID ??IESVR1 ? pwin, pweb
IE_attach() ; ? ??ID ??IESVR1 ? pwin, pweb
{
	global chuangkouid, pweb, pwin
	if ! chuangkouid
		chuangkouid := winexist("A")
	loop { ; ----- ??IE???????
		sleep 500
		ControlGet, hIESvr, Hwnd, , Internet Explorer_Server1, ahk_id %chuangkouid% 
		IfEqual, ErrorLevel, 0, break
	}
	; ----- ???COM
	IID_IHTMLWindow2 := "{332C4427-26CB-11D0-B483-00C04FD90119}" 
	IID_IWebBrowserApp := "{0002DF05-0000-0000-C000-000000000046}"
	COM_AccInit()
	COM_Error(0)
	pacc := COM_AccessibleObjectFromWindow(hIESvr) 
	pwin := COM_QueryService(pacc,IID_IHTMLWindow2,IID_IHTMLWindow2)
	pweb := COM_QueryService(pwin,IID_IWebBrowserApp,IID_IWebBrowserApp)
	COM_Release(pacc)
}

;--- ?? IE_attach
IE_term() ;
{
	global pwin, pweb
	COM_Release(pwin), COM_Release(pweb) 
	COM_AccTerm()
}

IE_Nav(URL="", timeout=30) ; [??,?]??????
{
	global pweb

	if URL
		COM_Invoke(pweb , "navigate2", URL) ;COM_Invoke(pweb, "document.location.href=", URL)

	Loop %timeout% {
		Sleep 1000
		if ( ( COM_Invoke(pweb , "readyState") = 4 ) && ( COM_Invoke(pweb , "Busy") = 0 ) ) 
			Break 
  	}
	COM_Invoke(pweb , "stop")
}

IE_tupian(show) ; 1????,0???
{
	lujing := "SOFTWARE\Microsoft\Internet Explorer\Main"
	if show
		regwrite, REG_SZ, HKCU, %lujing%, Display Inline Images, yes ;????
	else
		regwrite, REG_SZ, HKCU, %lujing%, Display Inline Images, no ;????
}

IE_daili(daili="") ; ????(????)
{
	lujing := "Software\Microsoft\Windows\CurrentVersion\Internet Settings"
	if daili
	{
		regwrite, REG_DWORD, HKCU, %lujing%, ProxyEnable, 1
		regwrite, REG_SZ, HKCU, %lujing%, ProxyServer, %daili%
		; ??:????,????dllcall,??????IE?
		dllcall("wininet\InternetSetOptionW","int","0","int","39","int","0","int","0")
		dllcall("wininet\InternetSetOptionW","int","0","int","37","int","0","int","0")
		traytip, ?????, %daili%
	} else {
		regwrite, REG_DWORD, HKCU, %lujing%, ProxyEnable, 0
	}
}

;--- ?????
IE_tanchu(daima, text="??", cishu=1) ; ?????
{
	global chuangkouid, pweb

	COM_Invoke(pweb, "navigate", daima)
	loop, %cishu% {
		loop 50 {
			NowID := DllCall("GetLastActivePopup", "uint", chuangkouid)
			If ( NowID != "" and NowID != 0 and NowID != chuangkouid )
				break
			sleep 500
		}
		control, check,, ??, % "ahk_id " . NowID
		NowID := ""
	}
}

IE_tanchu2(daima, text="??", cishu=1)
{
	global chuangkouid, pweb
	COM_Invoke(pweb, "navigate", daima)

	; alert ???
	RegRead, ie_version, HKLM, SOFTWARE\Microsoft\Internet Explorer, Version ; ??IE???
	stringleft, ie_version, ie_version, 1
	if ( ie_version = 6 )
		alert_biaoti := "Microsoft Internet Explorer"
	if ( ie_version = 8 )
		alert_biaoti := "???????"

	; -----??????????IE?,?????????? IE ? ???
	loop, %cishu% {
		WinWait, %alert_biaoti% ahk_class #32770, %text%  ; ?????,?????
		WinGet, Alert_ID, List, %alert_biaoti% ahk_class #32770, %text%
		loop %Alert_ID%
			control, check,, ??, % "ahk_id " Alert_ID%A_index%
	}
}
/*

IE_NewGUI(URL="", option="") ; ??GUI(IE),???:chuangkouid pctn pweb document
{
	global pctn, pweb, chuangkouid
	GUi, +LastFound +Resize ; ?? GUI
	COM_AtlAxWinInit() ; ??? AtlAxWin
	COM_Error(0)
	pweb:=COM_AtlAxGetControl(pctn:=COM_AtlAxCreateContainer(chuangkouid:=WinExist(),0,0,555,400,"Shell.Explorer"))
	gui,show, w555 h400, ????? ; ?? GUI

	if ( option = "M" )
		WinMaxiMize, ahk_id %chuangkouid%
	if URL
		IE_Nav(URL)
	; WinSetTitle, ahk_id %chuangkouid%, ,  ???
}

; --------- ????
GuiSize:               ; ??IE??????
	WinMove, % "ahk_id " . pctn, , 0,0, A_GuiWidth, A_GuiHeight 
return

GuiEscape:             ; ????,??????
	COM_Invoke(pweb, "Stop")
return

GuiClose:              ; ????
	Gui, Destroy
	COM_AtlAxWinTerm()
return

*/
; ----------------------------------- IE End

