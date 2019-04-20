;Monday, June 17, 2013
;reg.ahk
;some basic re-usable registry function wrappers

;read(whathive, whatkey, whatvalue="")
;write(whathive, whatkey, whatvaluename, whattype, whatvalue="")
;delete(whathive, whatkey, whatvaluename="")
;export(whathive, whatkey, whatregfile)
;isRegKey(RegistryKey, FullPath := True)


;make sure core.ahk is loaded since it is required - it will only be included again if it hasn't already
#include core.ahk
#include file.ahk

class reg 
{

load(){
	global
	HKLM := "HKEY_LOCAL_MACHINE" 
	HKCU := "HKEY_CURRENT_USER"
	HKCR := "HKEY_CLASSES_ROOT"
	HKCC := "HKEY_CURRENT_CONFIG"
}


;leave whatvalue blank to fetch the default key
read(whathive, whatkey, whatvalue=""){
	if(!whathive)
		return ""
	;keep from accidentally reading the hive itself
	if(!whatkey){
		return ""
	}
	regread, thisvalue, %whathive%, %whatkey%, %whatvalue%
	return thisvalue
}

;returns 0 if successful, 1 if there was an issue
;add some intuitive shortcut strings
;REG_SZ, REG_EXPAND_SZ, REG_MULTI_SZ, REG_DWORD, or REG_BINARY
;to use the default valuename, leave it blank
write(whathive, whatkey, whatvaluename, whattype, whatvalue){
	if(!whathive)
		return "No registry hive specified."	
	;keep from accidentally overwriting things things
	if(!whatkey)
		return "Can't write to invalid registry key"	
		
	if(whattype = "string")
		whattype := "REG_SZ"
	if(whattype = "expand")
		whattype := "REG_EXPAND_SZ"
	if(whattype = "multi")
		whattype := "REG_MULTI_SZ"
	if(whattype = "dword" or whattype = "bool")
		whattype := "REG_DWORD"
	if(whattype = "binary")
		whattype := "REG_BINARY"
	regwrite, %whattype%, %whathive%, %whatkey%, %whatvaluename%, %whatvalue%
	return errorlevel
}


;returns 0 if successful, 1 if there was an issue
;to remove the whole key, specify "" as whatvaluename
;to remove all the subkeys, don't specify whatvaluename at all
delete(whathive, whatkey, whatvaluename=""){
	;keep from accidentally deleting things
	if(!whathive)
		return "No registry hive specified."
	if(!whatkey)
		return "Can't delete invalid registry key"	
	regdelete, %whathive%, %whatkey%, %whatvaluename%
	return errorlevel
}

;USAGE:  reg.export("HKCR", "callto", "c:\arx\temp\test.reg")
;return true if there were no errors
export(whathive, whatkey, whatregfile){
	RunWait, reg.exe EXPORT %whathive%\%whatkey% "%whatregfile%",,UseErrorLevel
	if(errorlevel = "ERROR"){
		return false
	}	
	return true
}


;http://ahkscript.org/boards/viewtopic.php?f=6&t=3514&sid=d8b8e9e6bcb86e3f8a3b0ec8a62b42f9#p19610
;Check if RegKey is valid
;MsgBox % isRegKey("HKEY_CURRENT_USER\Software\AutoHotkey")
;MsgBox % isRegKey("HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion")
;MsgBox % isRegKey("HKEY_CORRENT_USER\Software\AutoHotkey")
;output:  1 1 0
isRegKey(RegistryKey, FullPath := True){
    return RegExMatch(RegistryKey, "(?i)\A\h*HK(CC|CR|CU|LM|U|EY_CLASSES_ROOT|EY_LOCAL_MACHINE|EY_USERS|EY_CURRENT_(USER|CONFIG))(64)?(?:\\[^\\]*)" ((FullPath) ? "+" : "*") "\z") = 1
}


} ;end reg class
