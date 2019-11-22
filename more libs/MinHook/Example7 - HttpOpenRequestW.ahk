#NoEnv
#Include <MinHook>
SetWorkingDir %A_ScriptDir%
#SingleInstance, force

global g_baseUrl := {}
hook1 := new MinHook("Wininet.dll", "InternetConnectW", "InternetConnectW_Hook")
hook2 := new MinHook("Wininet.dll", "HttpOpenRequestW", "HttpOpenRequestW_Hook")

; hook1.Enable()
; hook2.Enable()
MH_EnableHook() ; Enable all hooks

Gui, Add, ActiveX, w800 h400 vWB, Shell.Explorer
Gui, Add, ListView, xm wp h200, #|URL|Method
Gui, Show

for idx, width in [38, 684, 59] {
	LV_ModifyCol(idx, width)
}

WB.Navigate("https://docs.microsoft.com/en-us/windows/win32/api/wininet/nf-wininet-httpopenrequestw")
Return

GuiClose:
	hook1 := hook2 := "" ; Remove hook
ExitApp

InternetConnectW_Hook(hInternet, lpszServerName, nServerPort, lpszUserName, lpszPassword, dwService, dwFlags, dwContext) {
	hConnect := DllCall(Object(A_EventInfo).original
		, "ptr", hInternet
		, "ptr", lpszServerName
		, "uint", nServerPort
		, "ptr", lpszUserName
		, "ptr", lpszPassword
		, "uint", dwService
		, "uint", dwFlags
		, "uint", dwContext)

	protocol            := (nServerPort = 443) ? "https" : "http"
	host                := StrGet(lpszServerName)
	g_baseUrl[hConnect] := protocol "://" host

	return hConnect
}

HttpOpenRequestW_Hook(hConnect, lpszVerb, lpszObjectName, lpszVersion, lpszReferrer, lplpszAcceptTypes, dwFlags, dwContext) {
	URL    := g_baseUrl[hConnect] . StrGet(lpszObjectName)
	Method := StrGet(lpszVerb)

	RowNumber := LV_Add("",, URL, Method)
	LV_Modify(RowNumber, "Vis", RowNumber)

	return DllCall(Object(A_EventInfo).original
		, "ptr", hConnect
		, "ptr", lpszVerb
		, "ptr", lpszObjectName
		, "ptr", lpszVersion
		, "ptr", lpszReferrer
		, "ptr", lplpszAcceptTypes
		, "uint", dwFlags
		, "uint", dwContext)
}
