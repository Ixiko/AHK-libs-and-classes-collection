; ; https://autohotkey.com/boards/viewtopic.php?t=3702
; CURL(){
; DetectHiddenWindows, off
; Q(),ret:=GetElementByName(Acc_ObjectFromWindow(Winactive("ahk_class Chrome_WidgetWin_1")),"Address and search bar").accValue(0) Q("END")
; DetectHiddenWindows, on
; return ret
; }
; URLPATH(sURL="") {
; RegExMatch((sURL=""?URL():sURL),"O)^(?<Protocol>https?|ftp)://(?<P>(?<Domain>(?:[\w-]+\.)+\w\w+)(?::(?<Port>\d+))?/?(?<Path>(?:[^:/?# ]*/?)+))(?:\?(?<Query>[^#]+)?)?(?:\#(?<Hash>.+)?)?$",M)
; return M
; }
; URL(t="A"){
; return t?GetActiveBrowserURL(t):""
; }
; GetActiveBrowserURL(t="A"){
; WinGetClass, sClass, % t
; return (wgat()="New Tab - Google Chrome") or !t?"":GetBrowserURL_ACC(sClass)
; ; If sClass In Chrome_WidgetWin_1,Chrome_WidgetWin_0,Chrome_WidgetWin_2,Chrome_WidgetWin_3,Maxthon3Cls_MainFrm
; ; Return GetBrowserURL_ACC(sClass)
; ; Else,	Return GetBrowserURL_DDE(sClass) ; empty string if DDE not supported (or not a browser)
; }
; GetElementByName(AccObj, name) {
;    if (AccObj.accName(0) = name) ; DetectHiddenWindows, off
;       return AccObj
;    for k, v in Acc_Children(AccObj)
;       if IsObject(obj := GetElementByName(v, name))
;          return obj
; }
; GetBrowserURL_ACC(sClass) {
; 	global nWindow, accAddressBar
; 	If (nWindow!=WinExist("ahk_class " sClass)) ; reuses accAddressBar if it's the same window
; accAddressBar := GetAddressBar(Acc_ObjectFromWindow((nWindow:=WinExist("ahk_class " sClass))))
; 	Try sURL := accAddressBar.accValue(0)
; 	If (sURL==""){
; 		WinGet, nWindows, List, % "ahk_class " sClass ; In case of a nested browser window as in CoolNovo
; 		If (nWindows>1){
; 			accAddressBar := GetAddressBar(Acc_ObjectFromWindow(nWindows2))
; 			Try sURL:=accAddressBar.accValue(0)
; 		}}
; Return ((sURL!="") and (SubStr(sURL, 1, 4)!="http"))?sURL := "http://" sURL:sURL
; }
; ; "GetAddressBar" based in code by uname Found at http://autohotkey.com/board/topic/103178-/?p=637687
; GetAddressBar(accObj) {
; 	Try If ((accObj.accName(0) != "") and IsURL(accObj.accValue(0)))
; 		Return accObj
; 	Try If ((accObj.accName(0) != "") and IsURL("http://" accObj.accValue(0))) ; Chromium omits "http://"
; 		Return accObj
; 	For nChild, accChild in Acc_Children(accObj)
; 		If IsObject(accAddressBar := GetAddressBar(accChild))
; 			Return accAddressBar
; }
; ; IsURL(sURL) {
; ; 	Return RegExMatch(sURL, "^(?<Protocol>https?|ftp)://(?<Domain>(?:[\w-]+\.)+\w\w+)(?::(?<Port>\d+))?/?(?<Path>(?:[^:/?# ]*/?)+)(?:\?(?<Query>[^#]+)?)?(?:\#(?<Hash>.+)?)?$")
; ; }
; ; Found at http://autohotkey.com/board/topic/77303-/?p=491516
; Acc_Init(){
; static h:=DllCall("LoadLibrary","Str","oleacc","Ptr")
; }Acc_ObjectFromWindow(hWnd, idObject = 0){
; 	Acc_Init()
; 	If DllCall("oleacc\AccessibleObjectFromWindow", "Ptr", hWnd, "UInt", idObject&=0xFFFFFFFF, "Ptr", -VarSetCapacity(IID,16)+NumPut(idObject==0xFFFFFFF0?0x46000000000000C0:0x719B3800AA000C81,NumPut(idObject==0xFFFFFFF0?0x0000000000020400:0x11CF3C3D618736E0,IID,"Int64"),"Int64"), "Ptr*", pacc)=0
; 	Return ComObjEnwrap(9,pacc,1)
; }Acc_Query(Acc) {
; 	Try Return ComObj(9, ComObjQuery(Acc,"{618736e0-3c3d-11cf-810c-00aa00389b71}"), 1)
; }Acc_Children(Acc) {
; 	If ComObjType(Acc,"Name") != "IAccessible"
; 		ErrorLevel := "Invalid IAccessible Object"
; 	Else {
; 		Acc_Init(), cChildren:=Acc.accChildCount, Children:=[]
; 		If DllCall("oleacc\AccessibleChildren", "Ptr",ComObjValue(Acc), "Int",0, "Int",cChildren, "Ptr",VarSetCapacity(varChildren,cChildren*(8+2*A_PtrSize),0)*0+&varChildren, "Int*",cChildren)=0 {
; 			Loop %cChildren%
; 				i:=(A_Index-1)*(A_PtrSize*2+8)+8, child:=NumGet(varChildren,i), Children.Insert(NumGet(varChildren,i-8)=9?Acc_Query(child):child), NumGet(varChildren,i-8)=9?ObjRelease(child):
; 			Return Children.MaxIndex()?Children:
; 		} Else, ErrorLevel := "AccessibleChildren DllCall Failed"
; 	}
; }
; GetBrowserURL_DDE(sClass) { ; Found at http://autohotkey.com/board/topic/17633-/?p=434518
; 	WinGet, sServer, ProcessName, % "ahk_class " sClass
; 	StringTrimRight, sServer, sServer, 4
; 	iCodePage := A_IsUnicode ? 0x04B0 : 0x03EC ; 0x04B0 = CP_WINUNICODE, 0x03EC = CP_WINANSI
; 	DllCall("DdeInitialize", "UPtrP", idInst, "Uint", 0, "Uint", 0, "Uint", 0)
; 	hServer := DllCall("DdeCreateStringHandle", "UPtr", idInst, "Str", sServer, "int", iCodePage)
; 	hTopic := DllCall("DdeCreateStringHandle", "UPtr", idInst, "Str", "WWW_GetWindowInfo", "int", iCodePage)
; 	hItem := DllCall("DdeCreateStringHandle", "UPtr", idInst, "Str", "0xFFFFFFFF", "int", iCodePage)
; 	hConv := DllCall("DdeConnect", "UPtr", idInst, "UPtr", hServer, "UPtr", hTopic, "Uint", 0)
; 	hData := DllCall("DdeClientTransaction", "Uint", 0, "Uint", 0, "UPtr", hConv, "UPtr", hItem, "UInt", 1, "Uint", 0x20B0, "Uint", 10000, "UPtrP", nResult) ; 0x20B0 = XTYP_REQUEST, 10000 = 10s timeout
; 	sData := DllCall("DdeAccessData", "Uint", hData, "Uint", 0, "Str")
; 	DllCall("DdeFreeStringHandle", "UPtr", idInst, "UPtr", hServer)
; 	DllCall("DdeFreeStringHandle", "UPtr", idInst, "UPtr", hTopic)
; 	DllCall("DdeFreeStringHandle", "UPtr", idInst, "UPtr", hItem)
; 	DllCall("DdeUnaccessData", "UPtr", hData)
; 	DllCall("DdeFreeDataHandle", "UPtr", hData)
; 	DllCall("DdeDisconnect", "UPtr", hConv)
; 	DllCall("DdeUninitialize", "UPtr", idInst)
; 	csvWindowInfo := StrGet(&sData, "CP0")
; 	StringSplit, sWindowInfo, csvWindowInfo, `" ; " ; this comment is here just to fix a syntax highlighting bug
; 	Return sWindowInfo2
; }
