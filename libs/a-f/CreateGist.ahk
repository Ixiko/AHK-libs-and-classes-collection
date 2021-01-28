CreateGist(content, description:="", filename:="file1.ahk", token:="", public:=true) {
	url := "https://api.github.com/gists"
	obj := { "description": description
	       , "public": (public ? "true" : "false")
	       , "files": { (filename): {"content": content} } }

	whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	whr.Open("POST", url)
	whr.SetRequestHeader("Content-Type", "application/json; charset=utf-8")
	if token {
		whr.SetRequestHeader("Authorization", "token " token)
	}
	whr.Send( JSON_FromObj(obj) )

	if retUrl := JSON_ToObj(whr.ResponseText).html_url
		return retUrl
	else
		throw, whr.ResponseText
}