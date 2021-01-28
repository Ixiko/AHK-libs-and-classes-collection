getSlpWb(){
	arr:=[]
	winget,SlpControlList,ControlListHwnd,ahk_class SleipnirMainWindow
	loop,parse,SlpControlList,`n
	{
		WinGetClass,controlClass,ahk_id %a_loopfield%
		if(controlClass!="Internet Explorer_Server")
			continue
		static msg := DllCall("RegisterWindowMessage", "str", "WM_HTML_GETOBJECT")
		, IID := "{0002DF05-0000-0000-C000-000000000046}"
		SendMessage msg, 0, 0, ,ahk_id %a_loopfield%
		if (ErrorLevel != "FAIL") {
			lResult:=ErrorLevel, VarSetCapacity(GUID,16,0)
			if DllCall("ole32\CLSIDFromString", "wstr","{332C4425-26CB-11D0-B483-00C04FD90119}", "ptr",&GUID) >= 0 {
		DllCall("oleacc\ObjectFromLresult", "ptr",lResult, "ptr",&GUID, "ptr",0, "ptr*",pdoc)
		arr.insert(ComObj(9,ComObjQuery(pdoc,IID,IID),1)), ObjRelease(pdoc)
			}
		}else{
			continue
		}
	}
	return arr
}

renewSlpUrl(wb,sid){
	if regexmatch(href:=wb.LocationUrl,"i)SESSION=\w+")
		wb.Navigate(RegExReplace(href,"i)SESSION=\w+","SESSION=" sid))
	else if regexmatch(href,"is)/[^/\?]+(\?)?$",match)
	wb.Navigate(href (match1=""?"?":"") "SESSION=" sid)
	else if regexmatch(href,"is)/[^/&\?]+\?[^/\?]+(&?)$",match)
	wb.Navigate(href . (match1=""?"&":"") . "SESSION=" sid)
}