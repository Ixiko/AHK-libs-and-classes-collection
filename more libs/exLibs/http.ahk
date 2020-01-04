class http{
	static whr := comObjCreate('WinHttp.WinHttpRequest.5.1')
	get(url){
		http.whr.open 'GET', url, false
		http.whr.send()
		return http.whr.responseText
		}
}