;Settings Saved in AppData or A_scriptDir ("portable mode")

Settings_File(sf:="settings.json") {
	if !FileExist(d:=(A_AppData "\aspdm"))
		FileCreateDir, % d
	f:=d "\" sf
	return f
}

Settings_Get() {
	f:=Settings_File()
	if !FileExist(f) {
		;Save default settings
		Settings_Save(Settings_Default())
	}
	FileRead,s, % f
	return Settings_Validate(JSON_ToObj(s))
}

Settings_Validate(j) {
	j_default:=Settings_Default()
	vars:="stdlib_folder|userlib_folder|customlib_folder|local_repo|local_archive|hide_installed|Show_AllPackSources|only_show_stdlib|package_source|package_sources|Check_ClientUpdates|ContentSensitiveSearch|DefaultLibMode|RememberLibMode"
	loop,Parse,vars,`|
		if (!j.Haskey(A_LoopField))
			j[A_LoopField]:=j_default[A_LoopField]
	return j
}

Settings_Default(key="") {
	j:={stdlib_folder:		RegExReplace(A_AhkPath,"\w+\.exe","lib")
		,userlib_folder:	A_MyDocuments "\AutoHotkey\Lib"
		,customlib_folder:	A_MyDocuments "\AutoHotkey\aspdm\Lib"
		,local_repo:		A_AppData "\aspdm\repo"
		,local_archive:		A_AppData "\aspdm\archive"
		,hide_installed:	true
		,Show_AllPackSources: false
		,only_show_stdlib:	false
		,package_source:	"aspdm.ahkscript.org"
		,package_sources:	["aspdm.ahkscript.org","aspdm.2fh.co","aspdm.1eko.com"]
		,Check_ClientUpdates: true
		,ContentSensitiveSearch: true
		,DefaultLibMode:	"Global"
		,RememberLibMode:	false}
	if (key=="")
		return j
	return j[key]
}

Settings_Save(j) {
	s:=JSON_FromObj(j)
	f:=Settings_File()
	FileDelete, % f
	if ( FileExist(f) && (ErrorLevel) )
		return ErrorLevel
	FileAppend, % s, % f
	return ErrorLevel
}

Settings_InstallGet(f) {
	f := f . "\aspdm.json"
	if !FileExist(f) {
		Settings_InstallSave(f,false)
	}
	FileRead,s, % f
	j:=JSON_ToObj(s)
	if IsObject(j.installed)
		return j
	return j:={installed:{}}
}

Settings_InstallSave(f,j) {
	if (j)
		j.installed:=Util_ArraySort(j.installed)
	else
		j := {installed:{}}
	s:=JSON_FromObj(j)
	f := f . "\aspdm.json"
	FileDelete, % f
	if ( FileExist(f) && (ErrorLevel) )
		return ErrorLevel
	FileAppend, % s, % f
	return ErrorLevel
}