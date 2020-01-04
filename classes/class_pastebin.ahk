/*
Pastebin API v0.0.0.1 (fully functional)
Avi Aryan

Example
	pbin := new pastebin()
	msgbox % Clipboard := pbin.pasteAsGuest("some text to paste", "paste_name", "autohotkey")
*/

class pasteBin
{
	__New(username="", password=""){ 		; dev_key is nothing special and can be made public
		
		this.dev_key := "a5570948bfe060e3df15b9ac02d8b93f" , this.username := username , this.password := password
		this.http := ComObjCreate("WinHttp.WinHttpRequest.5.1")
		; done - 
		if ( username != "" ) && ( Password != "" ) 		;return if invalid data
		{
			f := "api_dev_key=" this.dev_key "&api_user_name=" this._UrlEncode(this.username) "&api_user_password=" this._UrlEncode(this.password)
			this._openRequest("http://pastebin.com/api/api_login.php")
			this.http.Send(f)
			this.userkey := this._return(this.http.ResponseText) 		; return 0 if key is wrong invalid
		}
	}

	paste(code, pname="paste thorugh pastebin api", pformat="autohotkey", pexpiry="N", psecret=0) {
		option := "paste"
		this._openRequest()
		f := "api_option=" option "&api_user_key=" this.userkey "&api_paste_private=" psecret "&api_paste_name=" this._URLEncode(pname) "&api_paste_expire_date=" 
		     . pexpiry "&api_paste_format=" pformat "&api_dev_key=" this.dev_key "&api_paste_code=" this._UrlEncode(code)
		this.http.Send(f)
		return  this._return(this.http.ResponseText)
	}

	pasteAsGuest(code, pname="paste thorugh pastebin api", pformat="autohotkey", pexpiry="N", psecret=0){
		bk := this.userkey , this.userkey := "rubbish"
		url := this.paste(code, pname, pformat, pexpiry, psecret)
		this.userkey := bk
		return url
	}

	listPosts(results_limit=50){
		this._openRequest()
		f := "api_option=list&api_user_key=" this.userkey "&api_dev_key=" this.dev_key "&api_results_limit=" results_limit
		this.http.Send(f)
		if this._return(this.http.ResponseText)
			return this.parseXML(r, "paste", 0)
		else return 0
	}

	listTrends(){
		this._openRequest()
		f := "api_option=trends&api_dev_key=" this.dev_key
		this.http.Send(f)
		if this._return( r:=this.http.ResponseText)
			return this.parseXML(r, "paste", 0)
		else return 0
	}

	; returns 1 if paste deleted or 0 if failed
	deletePaste(link){
		this._openRequest()
		f := "api_option=delete&api_user_key=" this.userkey "&api_dev_key=" this.dev_key "&api_paste_key=" this.getPastekey(link)
		this.http.Send(f)
		return  this._return( this.http.ResponseText, 0, 1 )
	}

	getUserInfo(){
		this._openRequest()
		f := "api_option=userdetails&api_user_key=" this.userkey "&api_dev_key=" this.dev_key
		this.http.Send(f)
		if this._return( r:=this.http.ResponseText )
			return this.parseXML(r, "user")
		else return 0
	}

	getPastedata(link){
		if !IsObject(this.http)
			this.http := ComObjCreate("WinHttp.WinHttpRequest.5.1")
		this.http.open("GET", "http://pastebin.com/raw.php?i=" this.getPastekey(link), 0)
		this.http.Send()
		return this.http.ResponseText
	}

	editPaste(link, mode=1){
		; total auto sign - in
		; just open
		page := "http://pastebin.com/edit.php?i=" ( id:=this.getPastekey(link) )

		if !mode
			return 1 , this.BrowserRun(page)

		ie := ComObjCreate( "InternetExplorer.Application" )
		ie.navigate(page)
		ie.visible := 0
		while ie.busy
			sleep 100
		if !Instr(ie.document.url, "edit.php?i=" id) 		; means already signed in --
		{
			ie.document.all.user_name.value := this.username
			ie.document.all.user_password.value := this.password
			ie.document.all.submit.click()
		}
		while ie.busy
			sleep 100
		ie.visible := 1
		return 1
	}

	printPaste(link){
		return 1 , this.BrowserRun("http://pastebin.com/print.php?i=" this.getPastekey(link))
	}

	getPastekey(link){
		return RegExReplace(link, "i).*pastebin\.com[\\\/]")
	}

	getEmbedlink(link){
		return "http://pastebin.com/embed.php?i=" this.getPastekey(link)
	}

	;---------------------- 2nd deegree methods ------------------------------------

	parseXML(xml, mainkey, ret_type=1){
		; parses XML to Objects
		; ret_type=1 will return single masked obj if return has 1 mainkey
		c := 0
		loop, parse, xml, `r, `n
		{
			a := Trim(A_LoopField)
			if !a
				continue
			if ( Instr(a, "<" mainkey ">") = 1 ) or ( Instr(a, "</" mainkey ">") = 1 )
			{ ; manage endings
				if !Instr(a, "/")
					c+=1 , obj := {}
				Else obj%c% := obj
				continue
			}
			k := Substr(a, 2, (p:=Instr(a, ">"))-1-1)  ;-1 for the 2
			d := Substr(a, p+1, Instr(a, "</" k ">", 0, 0)-p-1)
			obj[k] := d
		}
		if ret_type && (c=1)
			return obj1

		; write everything to main obj
		mainobj := {}
		loop % c
			mainobj.Insert(obj%A_index%)
		return mainobj
	}

	_return(s, iffail="0", ifsuccess=""){
		if ifsuccess =
			ifsuccess := s
		return ( Instr(s, "Bad API") = 1 ) ? iffail : ifsuccess
	}

	_openRequest(url="http://pastebin.com/api/api_post.php"){
		this.http.open("POST", url, false)
		this.http.SetRequestHeader("Content-type", "application/x-www-form-urlencoded")
	}


	;------------------------ CONSTANT methods --------------------------------------

	_UrlEncode( String )
	{ 	; by http://www.autohotkey.com/board/topic/35660-url-encoding-function/
		OldFormat := A_FormatInteger
		SetFormat, Integer, H
		Loop, Parse, String
		{
			if A_LoopField is alnum
			{
				Out .= A_LoopField
				continue
			}
			Hex := SubStr( Asc( A_LoopField ), 3 ) , Out .= "%" . ( StrLen( Hex ) = 1 ? "0" . Hex : Hex )
		}
		SetFormat, Integer, %OldFormat%
		return Out
	}

	BrowserRun(site){
		; https://github.com/avi-aryan/autohotkey-scripts/blob/master/Functions/Miscellaneous-Functions.ahk
		RegRead, OutputVar, HKCR, http\shell\open\command 
		IfNotEqual, Outputvar
		{
			StringReplace, OutputVar, OutputVar,"
			SplitPath, OutputVar,,OutDir,,OutNameNoExt, OutDrive
			run,% OutDir . "\" . OutNameNoExt . ".exe" . " """ . site . """"
		}
		else
			run,% "iexplore.exe" . " """ . site . """"	;internet explorer
	}
}