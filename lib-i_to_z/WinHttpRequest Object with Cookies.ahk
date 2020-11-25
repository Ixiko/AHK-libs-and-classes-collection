; Link:   	
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

SaveCookies(ByRef WebRequest, ByRef cookies) {
    While (p := RegexMatch(WebRequest.GetAllResponseHeaders, "U)(^|\R)Set-Cookie:\s(.+)=(.+);.+domain=(.+)(\R|;|$)", match, p?p+1:1))
        cookies[match4, match2] := match3
}

SetCookies(ByRef WebRequest, ByRef cookies) {
    url := WebRequest.Option(1) ;the url that we are going to send our request to
    If (p := InStr(url,"://"))
        url := SubStr(url, p+3)
    If (p := InStr(url,"/"))
        url := SubStr(url, 1, p-1)
    If (p := InStr(url,"@"))
        url := SubStr(url, p+1)
    If (p := InStr(url,":"))
        url := SubStr(url, 1, p-1)
    StringSplit, a, url, .
    b := a0-1
    domain := a%b%
    ext := a%a0%
    url := "." . domain . "." . ext
    
    cookieString := ""
    For id, value in cookies[url]
        cookieString .= id . "=" . value . "; "
    
    If (cookieString) ;if there are any cookies
        WebRequest.SetRequestHeader("Cookie", cookieString)
}
