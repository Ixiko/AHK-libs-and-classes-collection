#include COM_L.ahk
/*
	IEL_new(url="", option="") ; ????IE, ?? chuangkouid, pweb, [document]
	IEL_attach() ; IE Attach :??: pweb document
	IEL_Nav(URL="", timeout=30) ; [??,?]??????
	IEL_tanchu(daima, text="??", cishu=1) ; ?????
	IEL_tupian(show="") ; ????(??),???0????
	IEL_daili(daili="") ; ????(????)
;	IEL_GUI_new(url="", option="") ; ??GUI(IE),???:chuangkouid pctn pweb document
;	IEL_GUI_Quit() ; ??GUI,??????
*/

IEL_new(url="", option="") ; ????IE, ?? chuangkouid, pweb, [document]
{
	global chuangkouid, pweb, document
	COM_Init()
	COM_Error(0)
	pweb := COM_CreateObject("InternetExplorer.Application")
	pweb.Visible := 1
	chuangkouid := pweb.HWND

	if (option = "M")
		WinMaxiMize, ahk_id %chuangkouid%
	if url {
		IEL_Nav(url)
		document := pweb.document
	}
}

IEL_attach() ; IE Attach :??: pweb document
{
	global chuangkouid, pweb, document
	if ! chuangkouid
		chuangkouid := winexist("A")
	loop { ; ----- ??IE???????
		sleep 500
		ControlGet, hIESvr, Hwnd, , Internet Explorer_Server1, ahk_id %chuangkouid% 
		IfEqual, ErrorLevel, 0, break
	}

	; ----- ???COM
;	IID_IHTMLWindow2 := "{332C4427-26CB-11D0-B483-00C04FD90119}" 
	IID_IWebBrowserApp := "{0002DF05-0000-0000-C000-000000000046}"
	COM_Init()
	COM_Error(0)
	DllCall("SendMessageTimeout", "Uint", hIESvr, "Uint", DllCall("RegisterWindowMessage", "str", "WM_HTML_GETOBJECT"), "Uint", 0, "Uint", 0, "Uint", 2, "Uint", 1000, "UintP", lResult) 
	DllCall("oleacc\ObjectFromLresult", "Uint", lResult, "Uint", COM_GUID4String(IID_IHTMLDocument2,"{332C4425-26CB-11D0-B483-00C04FD90119}"), "int", 0, "UintP", pdoc) 
	document := COM_EnWrap(pdoc)
	pweb := COM_QueryService(document,IID_IWebBrowserApp,IID_IWebBrowserApp)
;	COM_Term()
}

IEL_Nav(URL="", timeout=30) ; [??,?]??????
{
	global pweb

	if URL
		pweb.navigate2(URL)

	Loop %timeout% {
		Sleep 1000
		if ( (pweb.readyState = 4) && (pweb.Busy = 0) ) 
			Break 
  	}
	pweb.stop()
}

IEL_tanchu(daima, text="??", cishu=1) ; ?????
{
	global chuangkouid, pweb

	pweb.navigate(daima)
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

IEL_tanchu2(daima, text="??", cishu=1) ; ?????
{
	global chuangkouid, pweb

	pweb.navigate(daima)
;	ControlSetText, Edit1, %daima%, ahk_id %chuangkouid% ; ?????????
;	ControlSend, Edit1, {enter}, ahk_id %chuangkouid%

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


IEL_tupian(show) ; 1????,0???
{
	lujing := "SOFTWARE\Microsoft\Internet Explorer\Main"
	if show
		regwrite, REG_SZ, HKCU, %lujing%, Display Inline Images, yes ;????
	else
		regwrite, REG_SZ, HKCU, %lujing%, Display Inline Images, no ;????
}


IEL_daili(daili="") ; ????(????)
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

; pdoc := COM_CreateObject("{25336920-03F9-11CF-8FD0-00AA00686F13}") ; pdoc.write(html) ; pdoc.close()

/*
IEL_GUI_new(url="", option="") ; ??GUI(IE),???:chuangkouid pctn pweb document
{
	global chuangkouid, pctn, pweb, document
	GUi, +LastFound +Resize ; ?? GUI
	COM_AtlAxWinInit() ; ??? AtlAxWin
	COM_Error(0)
	pweb:=COM_AtlAxGetControl(pctn:=COM_AtlAxCreateContainer(chuangkouid:=WinExist(),0,0,555,400,"Shell.Explorer"))
	gui,show, w555 h400, ????? ; ?? GUI

	if ( option = "M" )
		WinMaxiMize, ahk_id %chuangkouid%
	if url 
	{
		IEL_Nav(url)
		document := pweb.document
	}
	; WinSetTitle, ahk_id %chuangkouid%, ,  ???
}

IEL_GUI_Quit() ; ??GUI,??????
{
	Gui, Destroy
	COM_AtlAxWinTerm() ; ????
}


; ---------------------------------------------------- ????: ??IEL_GUI
GuiSize:
	WinMove, % "ahk_id " . pctn, , 0,0, A_GuiWidth, A_GuiHeight ; ??IE??????
return

GuiEscape:
	pweb.Stop() ; ????,??????
return

GuiClose:
	Gui, Destroy
	COM_AtlAxWinTerm() ; ????
return
*/

