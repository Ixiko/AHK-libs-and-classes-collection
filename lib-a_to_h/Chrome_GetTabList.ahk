; Link:   	https://gist.github.com/tmplinshi/be40821c348195342f40874597cfccae
; Author:	tmplinshi
; Date:
; for:


Chrome_GetTabList() {
	whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	whr.Open("GET", "http://localhost:9222/json")
	whr.Send()

	out := []
	for i, tab in Jxon_Load(whr.ResponseText)
	{
		if (tab.type = "page")
			out.push( {url: tab.url, title: tab.title} )
	}
	return out
}