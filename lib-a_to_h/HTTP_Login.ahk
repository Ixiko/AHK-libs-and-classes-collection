; Link:   	https://raw.githubusercontent.com/DonCorleon/UGD/8f2a2ad680c66c47f8102abfec5ebc41f9b2b36b/Functions/HTTP-Login.ahk
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

HTTP_Login(UserName,UserPass){
	global DebugMode,HTTP,Cookie:="",myConsole,Version
	tt("HTTP:`tLogin Started")
	Options := "+Flag: INTERNET_FLAG_NO_COOKIES`n+NO_AUTO_REDIRECT"
	. (A_IsUnicode ? "`nCharset: UTF-8" : "")
	HTTPRequest(url:="http://www.gog.com/", InOutData := "", InOutHeader := Headers(), Options "`nMETHOD:POST") ; first request to get a gutm and game Ids for initial login request
	if (DebugMode) ;--------------- DEBUG
		tt("HTTP:Step 1","URL : " URL,"Header`n" InOutHeader)
	if !(RegExMatch(InOutData,"U)GalaxyAccounts\(\'(.*)\'",Auth_URL))
	{
		tt("[red]ERROR[/]:`tNo AUTH_URL Found")
		goto HTTPFailed
	}
	if (DebugMode) ;--------------- DEBUG
		tt("Debug Mode")
	tto("[green]HTTP:`tPhase 1 passed[/]")
	;*************** Step 2
	StringReplace,Clean_Auth_URL,Auth_URL1,&amp;,&,All
	url := Clean_Auth_URL
	Cookie:= GetCookies(InOutHeader)
	Redo2: ;----------------- Redirect
	HTTPRequest(url, InOutData := "", InOutHeader := Headers() , Options)
	if (DebugMode) ;--------------- DEBUG
		tt("HTTP:Step 2","URL : " URL,"Cookie : " cookie,"Header`n" InOutHeader)
	Found:=RegExMatch(InOutHeader,"U)Location: (.*)\n",New_URL)
	if (found){ ;----------------- Check for Redirect
		url:=New_URL1
		if (DebugMode) ;--------------- DEBUG
			tt("Debug Mode")
		tto("[Red]Redirecting[/]")
		goto Redo2
	}
	FoundToken:=RegExMatch(InOutData,"U)name=""login\[_token\]"" value=""(.*)"" \/\>",Login_Token)
	if !FoundToken
	{
		tt("[Red]ERROR[/]:No login token Found")
		goto HTTPFailed
	}
	FoundID:=RegExMatch(URL,"U)client_id=(.*)\&",Login_ID)
	if !FoundID
	{
		tt("[Red]ERROR[/]:No Client ID Found")
		goto HTTPFailed
	}
	if (DebugMode) ;--------------- DEBUG
		tt("Debug Mode")
	tto("[green]HTTP:`tPhase 2 passed[/]")
	;**************** Step 3
	Referer:=URL
	url:="https://login.gog.com/login_check"
	data =
	(LTrim Join&
	login`%5Busername`%5D=%UserName%
	login`%5Bpassword`%5D=%UserPass%
	login`%5Blogin`%5D=
	login`%5B_token`%5D=%Login_Token1%
	)
	Redo3: ;----------------- Redirect
	Cookie.=GetCookies(InOutHeader)
	HTTPRequest(url, InOutData := data, InOutHeader := Headers(Referer), Options "`nMethod:POST")
	if (DebugMode) ;--------------- DEBUG
		tt("HTTP:Step 3","URL : " URL,"Cookie : " cookie,"Header`n" InOutHeader)
	Found:=RegExMatch(InOutHeader,"U)Location: (.*)\n",New_URL)
	if (found){ ;----------------- Check for Redirect
		url:=New_URL1
		if (DebugMode) ;--------------- DEBUG
			tt("Debug Mode")
		tto("[Red]Redirecting[/]")
		goto Redo3
	}
	Cookie.=GetCookies(InOutHeader)
	if DebugMode ;--------------- DEBUG
		tt("Debug Mode")
	tto("[green]HTTP:`tPhase 3 passed[/]")
	;**************** Step 4
	URL:="https://www.gog.com/account/settings/personal"
	Referer:=URL
	Redo4:
	HTTPRequest(URL, InOutData, InOutHeader := Headers(Referer), Options)
	if DebugMode ;--------------- DEBUG
		tt("HTTP:[Red]Step 4[/]","URL : " URL,"Cookie : " cookie,"Header`n" InOutHeader)
	Found:=RegExMatch(InOutHeader,"U)Location: (.*)\n",New_URL)
	if (found){ ;----------------- Check for Redirect
		url:=New_URL1
		Cookie.=GetCookies(InOutHeader)
		if (DebugMode) ;--------------- DEBUG
			tt("Debug Mode")
		tto("[Red]Redirecting[/]")
		goto Redo4
	}
	If RegExMatch(InOutData, "U)Username<\/span><strong class=""settings-item__value settings-item__section"">(.*)<\/strong>", NickName)
	{
		if (DebugMode) ;--------------- DEBUG
			tt("Debug Mode")
		tto("[green]HTTP:`tPhase 4 passed[/]")
		Gui,Show,,Ultimate GoG Downloader v%Version% - %NickName1%
	}
	else
		goto HTTPFailed
	
	HTTP.GoGCookie:=Cookie
	HTTP.GoGOptions:=Options
	if (DebugMode) ;--------------- DEBUG
		tt("Debug Mode")
	tto("[green]HTTP:`tLogin Successful[/]")
	;tt("HTTP:`tLogin Successful")
	return,1
	
	HTTPFailed:
	{
		GuiControl,Main:Enable,ButtonSelectGames
		GuiControl,Main:Enable,ButtonLogin
		GuiControl,Main:Enable,ConfigWindow
		GuiControl,Main:Enable,ButtonUpdate
		tt("HTTP:`tLogin Failed"),
		tt("HTTP Error:`tSkipping API login")
		Return,0
	}
}