IsUpdated() {
	ver := A_AhkVersion
	whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	whr.Open("GET", "http://ahkscript.org/download/" SubStr(ver, 1, 3) "/version.txt")
	whr.Send()
	return SubStr(ver, 1, 8+(ver<2)) >= whr.ResponseText
}