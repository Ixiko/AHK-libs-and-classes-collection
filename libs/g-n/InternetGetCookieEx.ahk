; Link:   	https://gist.github.com/tmplinshi/3ab1cd4821c3dd4608522ddab9f7d04b
; Author:	
; Date:   	
; for:     	


; Requires Internet Explorer 8.0 or later.
InternetGetCookieEx(URL) {
	Loop, 2 {
		if (A_Index = 2) {
			VarSetCapacity(cookieData, size, 0)
		}
		DllCall( "Wininet.dll\InternetGetCookieEx"
		       , "ptr", &URL, "ptr", 0, "ptr", &cookieData, "int*", size
		       , "uint", 8192 ; INTERNET_COOKIE_HTTPONLY
		       , "ptr", 0 )
	}
	return StrGet(&cookieData)
}