updateLibPath(createNew=1){
	if !fileexist(path:=A_scriptdir "\Lib.lnk"){
		if(createNew){
			filecreateshortcut,% substr(a_scriptdir,1,1) ":\scripts\AutoHotkey\Lib",% path
		}
		return
	}
	
	FileGetShortcut,% path,target
	filecreateshortcut,% substr(a_scriptdir,1,1) substr(target,2),% path
}