googl(url) {
	;// Forum topic: http://goo.gl/3kR4PO
	static q := Chr(34) ;// double quote
	static api_url := "
	(Join LTrim C
	https://www.googleapis.com/urlshortener/v1/url?key=
	AIzaSyBXD-RmnD2AKzQcDHGnzZh4humG-7Rpdmg ;// API Key
	)"

	http := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	http.Open("POST", api_url, false)
	http.SetRequestHeader("Content-Type", "application/json")
	http.Send("{" . q . "longUrl" . q . ": " . q . url . q . "}")
	res := http.ResponseText
	return SubStr(
	(Join Q C
		res,
		p := InStr(res, q . "id" . q . ": " . q)+7,
		InStr(res, q,, p+1)-p
	))
}