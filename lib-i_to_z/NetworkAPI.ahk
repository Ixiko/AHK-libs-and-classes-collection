API_u2vClean:=1 ;enable u2v_clean()
API_SetSource("aspdm.ahkscript.org") ; Über Default packs source

; Other/mirror servers - [not always updated]
; --------------------------------------------
; API_SetSource("aspdm.2fh.co")
; 
; API_SetSource("ahk.cu.cc")
;
; API_SetSource("aspdm.cu.cc")
;
; API_SetSource("aspdm.1eko.com")
; --------------------------------------------

API_SetSource(domain) {
	Global Package_Source
	Global Packs_Source
	Global API_Source
	
	domain:=API_ParseSource(domain)
	
	if (Package_Source == domain)
		return 1
	
	if API_ValidateSource(domain) {
		Package_Source:=domain
		;Packs_Source:="http://packs." domain
		;API_Source:="http://api-php." domain
		Packs_Source:="http://" domain "/packs"
		API_Source:="http://" domain "/api-php"
		return 1
	}
	return 0
}

API_ParseSource(domain,mainonly:=0) {
	StringLower,domain,domain
	if (mainonly) {
		RegExMatch(domain "/","i)([a-z]+\.[a-z]+/)",m) ;Isolate main domain, ex:  http://packs.fansite.com/asdsd/sdds  -->  fansite.com
		StringTrimRight,domain,m1,1
		return domain
	} else {
		RegExMatch("/" domain "/","i)(/[\w\.]+/)",m) ;Isolate full domain, ex:  http://packs.fansite.com/asdsd/sdds  -->  packs.fansite.com
		StringTrimRight,domain,m1,1
		StringTrimLeft,domain,domain,1
		return domain
	}
}

API_ValidateSource(domain) {
	check:=A_NowUTC "|" A_TickCount
	;data:=JSON_ToObj(u2v_clean("http://api-php." domain "/status.php?_c=" check))
	data:=JSON_ToObj(u2v_clean("http://" domain "/api-php/status.php?_c=" check))
	if IsObject(data) {
		if ( (data["api"]["check"] == check) && (data["api"]["name"] == "aspdm") )
			return 1
	}
	return 0
}

CheckUpdate(version,silent:=0,Update_URL:="http://aspdm.ahkscript.org/client/update.ini") {
	URLDownloadToFile,%Update_URL%, % tempupdatefile:=Util_TempFile()
	IniRead,NewVersion,%tempupdatefile%,Update,Version,NULL (Error)
	IniRead,__URL,%tempupdatefile%,Update,URL
	FileDelete,%tempupdatefile%
	if (InStr(NewVersion,"NULL") || InStr(NewVersion,"Error"))
	{
		if (silent)
			return "ERROR"
		else
			MsgBox, 262192, %A_ScriptName% - Update, An error occured.`nPlease check your internet connection and try again.
	}
	else
	{
		if (Util_VersionCompare(NewVersion,Version))
		{
			if (silent==-1 || silent==0) {
				MsgBox, 262212, %A_ScriptName% - Update, A new version is available.`nCurrent Version: `t%Version%`nLatest Version: `t%NewVersion%`nWould you like to update?
				IfMsgBox, Yes
					run, %__URL%
			}
			return 1
		}
		else
		{
			if (!silent)
				MsgBox, 262208, %A_ScriptName% - Update, You have the latest version.
			return 0
		}
	}
}

u2v(u){
	URLDownloadToFile,%u%, % t:=Util_TempFile()
	FileRead,x,%t%
	FileDelete,%t%
	return x
}

v_clean(s){ ;the new free host adds junk, this filters it out
	/*
	j:=substr(k:=RegExReplace(u2v(u),"s)<!--.*"),1,1)
	return ((j=="?")?SubStr(k,2):k)
	*/
	i:=0, k:=RegExReplace(s,"s)<!--.*")
	loop % strlen(3)
		if (!Util_isASCII(SubStr(k,1,1)))
			i+=1
	k:=SubStr(k,i+1)
	return ((SubStr(k,1,1)=="?")?SubStr(k,2):k)
}

u2v_clean(u){ ;the new free host adds junk, this filters it out
	global API_u2vClean
	if (API_u2vClean)
		return v_clean(u2v(u))
	return u2v(u)
}

API_List(sort:=0) {
	global API_Source
	l:=StrSplit(u2v_clean(API_Source "/list.php" ((sort)?"&sort":"") ),"`n")
	l.Remove(l.MaxIndex())
	return l
}

API_ListNum(lim,origin:=0,sort:=0) {
	global API_Source
	return JSON_ToObj(u2v_clean(API_Source "/list.php?" ((lim)?"lim=" lim:"") ((origin) ? "&origin=" origin : "") ((sort)?"&sort":"") ))
}

API_ListAll(sort:=0) {
	global API_Source
	k:=u2v_clean(API_Source "/list.php?full" ((sort)?"&sort":"") )
	if (!InStr(SubStr(k,1,3),"{")) ;avoid javascript from error page to be considered as JSON
		return ""
	return JSON_ToObj(k)
}

API_Info(file,item="") {
	global API_Source
	return u2v_clean(API_Source "/info.php?f=" . file . "&c=" . item)
}

API_Get(file) {
	global Packs_Source
	StringLower,file,file
	DownloadFile(Packs_Source "/" file,t:=Util_TempFile())
	return t
}

API_GetDependencies(pack_ahkp) {
	reqCSV:=API_Info(pack_ahkp,"required")
	if InStr(reqCSV,"ERROR:")
		return Object()
	reqArr:=Object()
	Loop,Parse,reqCSV,CSV
	{
		reqArr.Insert(A_LoopField ".ahkp")
		k:=API_GetDependencies(A_LoopField ".ahkp")
		if (k.MaxIndex > 0)
			Util_ArrayInsert(reqArr,k)
	}
	return reqArr
}

API_UpdateExists(name,ver_local:="") {
	if !StrLen(ver_local)
		ver_local:=JSON_ToObj(Manifest_FromPackage(name)).version
	if (Util_VersionCompare(ver_server:=API_Info(name,"version"),ver_local))
		return ver_server
	return 0
}

