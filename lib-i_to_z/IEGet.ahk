;; http://www.autohotkey.com/board/topic/47052-basic-webpage-controls-with-javascript-com-tutorial/

;// Access an IE object by WinTitle and Internet Explorer_Server Number:
WBGet(WinTitle="ahk_class IEFrame", Svr#=1) {               ;// based on ComObjQuery docs
   static msg := DllCall("RegisterWindowMessage", "str", "WM_HTML_GETOBJECT")
        , IID := "{0002DF05-0000-0000-C000-000000000046}"   ;// IID_IWebBrowserApp
;//     , IID := "{332C4427-26CB-11D0-B483-00C04FD90119}"   ;// IID_IHTMLWindow2
   SendMessage msg, 0, 0, Internet Explorer_Server%Svr#%, %WinTitle%
   if (ErrorLevel != "FAIL") {
      lResult:=ErrorLevel, VarSetCapacity(GUID,16,0)
      if DllCall("ole32\CLSIDFromString", "wstr","{332C4425-26CB-11D0-B483-00C04FD90119}", "ptr",&GUID) >= 0 {
         DllCall("oleacc\ObjectFromLresult", "ptr",lResult, "ptr",&GUID, "ptr",0, "ptr*",pdoc)
         return ComObj(9,ComObjQuery(pdoc,IID,IID),1), ObjRelease(pdoc)
      }
   }
}
;// Access an IE object by Window/Tab Name:
IEGet(name="",url="") {
   IfEqual, Name,, WinGetTitle, Name, ahk_class IEFrame     ;// Get active window if no parameter
   Name := (Name="New Tab - Windows Internet Explorer")? "about:Tabs":RegExReplace(Name, " - (Windows|Microsoft) Internet Explorer")
   for wb in ComObjCreate("Shell.Application").Windows
      if (name="" || instr(wb.LocationName,Name)) and InStr(wb.FullName, "iexplore.exe") && ((url="") || instr(wb.LocationUrl,url))
         return wb
}


