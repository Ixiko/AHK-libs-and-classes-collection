global g_fileHooks := {}

global CSIDL_COMMON_APPDATA := 35
global CSIDL_LOCAL_APPDATA := 28
global CSIDL_APPDATA := 26
global CSIDL_PERSONAL := 5
global CSIDL_FLAG_CREATE := 0x8000

initFileHooks(byref config)
{
	path := g_globals.config.target_name 
	splitpath, path, , , ,name
	g_fileHooks.docs := g_globals.config.MyDocs "\Games\" name
	if not fileexist(g_fileHooks.docs) and (g_globals.config.saves or g_globals.config["/saves"] or g_globals.config["saves/"]){
		path := g_fileHooks.docs
		FileCreateDir, %path%
	}

	g_fileHooks.paths := []
	/*
	if g_globals.config["/saves"] 
	{
		g_fileHooks.paths.insert(g_globals.config.target_dir)
		docs := g_fileHooks.docs
		loop, %docs%\*.*
		printl("Simbolic link: Succes= " dllcall("CreateSymbolicLinkW"
		, str, A_WorkingDir "\" A_loopfilename, str, A_loopfilefullpath, uint, 0) " code= " A_lasterror)		
	}
	*/
			
	for k, v in strsplit(config, ";")
	{
		if g_globals.config.basepath
			g_fileHooks.paths.insert(g_globals.config.basepath "\" v)
		else g_fileHooks.paths.insert(v)
	}				
			
	g_fileHooks.filesList := ""	

	if g_globals.config["saves/"]
	{
		lnk := instr(g_globals.config["saves/"], ":") ? g_globals.config["saves/"] : A_workingdir "\" g_globals.config["saves/"]
		target := g_fileHooks.docs
		fileremovedir, %lnk%
		filecreatedir, %target%
		printl("Simbolic link : " lnk "-> Succes= " dllcall("CreateSymbolicLinkW", str, lnk, str, target, uint, 1) " code= " A_lasterror)
		logerr("Simbolic link : " lnk " -> " target)
	}
	
	if g_globals.config.mods or  g_globals.config["/saves"] 
	{
		hookW := isfunc("AltCreateFileW") ? "AltCreateFileW" : "CreateFileW"
		hookA := isfunc("AltCreateFileA") ? "AltCreateFileA" : "CreateFileA"
		
		printl("CreateFileW:  " . InstallHook(hookW, pOpenFileW, "Kernel32.dll", "CreateFileW"))
		printl("CreateFileA:  " . InstallHook(hookA, pOpenFileA, "Kernel32.dll", "CreateFileA"))
		
		g_fileHooks.pCreateFile := pOpenFileA
		g_fileHooks.pCreateFileW := pOpenFileW	
		
		hook := isfunc("AltOpenFile") ? "AltOpenFile" : "OpenFile"
		printl("OpenFile:  " . InstallHook(hook, pOpenFile, "Kernel32.dll", "OpenFile"))
		g_fileHooks.pOpenFile := pOpenFile		
	}
			
	if not g_globals.config.saves
		return
	
	h_SHGetFolderPathA := isfunc("AltSHGetFolderPathA") ? "AltSHGetFolderPathA" : "SHGetFolderPathA"
	h_SHGetFolderPathW := isfunc("AltSHGetFolderPathW") ? "AltSHGetFolderPathW" : "SHGetFolderPathW"
	
	printl("SHGetFolderPathA:  " . InstallHook(h_SHGetFolderPathA, pSHGetFolderPathA, "Shell32.dll", "SHGetFolderPathA"))
	printl("SHGetFolderPathW:  " . InstallHook(h_SHGetFolderPathW, pSHGetFolderPathW, "Shell32.dll", "SHGetFolderPathW"))
	
	g_fileHooks.pSHGetFolderPathA := pSHGetFolderPathA
	g_fileHooks.pSHGetFolderPathW := pSHGetFolderPathW	
	
	h_SHGetSpecialFolderPathA := isfunc("AltSHGetSpeciaFolderlPathA") ? "AltSHGetSpecialFolderPathA" : "SHGetSpecialFolderPathA"
	h_SHGetSpecialFolderPathW := isfunc("AltSHGetSpeciaFolderlPathW") ? "AltSHGetSpecialFolderPathW" : "SHGetSpecialFolderPathW"
	
	printl("SHGetSpecialFolderPathA:  " . InstallHook(h_SHGetSpecialFolderPathA, pSHGetSpecialFolderPathA, "Shell32.dll", "SHGetSpecialFolderPathA"))
	printl("SHGetSpecialFolderPathW:  " . InstallHook(h_SHGetSpecialFolderPathW, pSHGetSpecialFolderPathW, "Shell32.dll", "SHGetSpecialFolderPathW"))
	
	g_fileHooks.pSHGetSpecialFolderPathA := pSHGetSpecialFolderPathA
	g_fileHooks.pSHGetSpecialFolderPathW := pSHGetSpecialFolderPathW	
	
	h_SHGetKnownFolderPath := isfunc("AltSHGetKnownFolderPath") ? "AltSHGetKnownFolderPath" : "SHGetKnownFolderPath"	
	printl("SHGetKnownFolderPathA:  " . InstallHook(h_SHGetKnownFolderPath, pSHGetKnownFolderPath, "Shell32.dll", "SHGetKnownFolderPath"))		
	g_fileHooks.pSHGetKnownFolderPath := pSHGetKnownFolderPath	
}

CreateFileA(p1, p2, p3, p4, p5, p6, p7)
{
	critical
	string := strget(p1, "CP0")	
	VarSetCapacity(stringU, (strlen(string)+1)*2)
	strput(string, &stringU, "UTF-16")
	r := CreateFileW(&stringU, p2, p3, p4, p5, p6, p7)	
	return r
}	

CreateFileW(p1, p2, p3, p4, p5, p6, p7)
{
	critical
	;static excludes := {"" : True, "dll" : True, "drv" : True, "ogl" : True, "exe" : True, "dds" : True}
	isobject(g_fileHooks.filesList) ?: buildfileslist()
	
	file := strget(p1, "UTF-16")	
	stringreplace, file, file, /, \, 1	
	Splitpath, file, filename, filedir, ext
	;instr(file, "?") ?: printl("file" file " " ext)
		
	g_fileHooks.filesList[filename] ? file := g_fileHooks.filesList[filename] 
	/*: (g_globals.config["/saves"])
	? (filedir = A_workingdir or filedir = "") and not excludes[ext]
	? printl("Simbolic link: Succes= " filedir "\" filename "succes: " dllcall("CreateSymbolicLinkW"
	, str, A_WorkingDir "\" filename, str, g_fileHooks.docs "\" filename, uint, 0) " code= " A_lasterror) 
	*/
	
    r := dllcall(g_fileHooks.pCreateFileW, str, file, uint, p2, uint, p3, uint, p4, uint, p5, uint, p6, uint, p7)
	return r
}	

OpenFile(p1, p2, p3)
{
	critical	
	isobject(g_fileHooks.filesList) ?: buildfileslist()
		
	file := strget(p1, "CP0")	
	printl("open " file)
	stringreplace, file, file, /, \, 1	
	Splitpath, file, filename, filedir, ext
							
	g_fileHooks.filesList[filename] ? file := g_fileHooks.filesList[filename] 
	r := dllcall(g_fileHooks.pOpenFile , astr, file, uint, p2, uint, p3)
	return r
}	

buildfileslist()
{
	folders := g_fileHooks.paths 
	g_fileHooks.filesList := {}
	for k, v in folders
	{
		loop, %v%\*.*, 0, 1
			g_fileHooks.filesList[A_loopfilename] := A_loopfilefullpath		
	}
	err := g_lobals.config.error_log
	splitpath, err, errofile
	g_fileHooks.filesList.remove(errofile)
	/*
	if g_globals.config["/saves"]
	{
		wdir := g_fileHooks.docs 
		SetWorkingDir, %wdir%
		printl("FindFirstFileW:  " . InstallHook("FindFirstFileW", pFindFirstFileW, "Kernel32.dll", "FindFirstFileW") )
		g_fileHooks.pFindFirstFileW := pFindFirstFileW	
		printl("FindFirstFileA:  " . InstallHook("FindFirstFileA", pFindFirstFileA, "Kernel32.dll", "FindFirstFileA") )
		g_fileHooks.pFindFirstFileA := pFindFirstFileA	
		
		printl("PathFileExistsW: " . InstallHook("PathFileExistsW", pPathFileExistsW, "Shlwapi.dll", "PathFileExistsW") )
		g_fileHooks.pPathFileExistsW := pPathFileExistsW
		printl("PathFileExistsA: " . InstallHook("PathFileExistsA", pPathFileExistsA, "Shlwapi.dll", "PathFileExistsA") )
		g_fileHooks.pPathFileExistsA := pPathFileExistsA
		
		InstallHook("GetModuleFileNameA", pGetModuleFileNameA, "Kernel32.dll", "GetModuleFileNameA") 
		g_fileHooks.pGetModuleFileNameA := pGetModuleFileNameA		
		InstallHook("GetModuleFileNameW", pGetModuleFileNameW, "Kernel32.dll", "GetModuleFileNameW") 
		g_fileHooks.pGetModuleFileNameW := pGetModuleFileNameW				
	}
	*/
}

SHGetFolderPathA(p1, p2, p3, p4, p5)
{
	critical
	p2 &= ~ CSIDL_FLAG_CREATE
	printl("SHGetFolderPathA: " p2)		
	r := dllcall(g_fileHooks.pSHGetFolderPathA, uint, p1, uint, p2, uint, p3, uint, p4, uint, p5)
	
	if (p2 = CSIDL_COMMON_APPDATA) or( p2 = CSIDL_LOCAL_APPDATA) or (p2 = CSIDL_APPDATA) 
		strput(g_fileHooks.docs, p5+0, , "CP0")
	else if (p2 = CSIDL_PERSONAL)
		strput(g_globals.config.MyDocs "\Games\", p5+0, , "CP0")
	
	return r
}

SHGetFolderPathW(p1, p2, p3, p4, p5)
{
	critical	
	p2 &= ~ CSIDL_FLAG_CREATE
	printl("SHGetFolderPathW: " p2)	
	r := dllcall(g_fileHooks.pSHGetFolderPathW, uint, p1, uint, p2, uint, p3, uint, p4, uint, p5)
	
	if (p2 = CSIDL_COMMON_APPDATA) or( p2 = CSIDL_LOCAL_APPDATA) or (p2 = CSIDL_APPDATA) 
		strput(g_fileHooks.docs, p5+0, , "UTF-16")
	else if (p2 = CSIDL_PERSONAL)
		strput(g_globals.config.MyDocs "\Games\", p5+0, , "UTF-16")
	
	return r
}

SHGetSpecialFolderPathA(p1, p2, p3, p4)
{
	critical	
	p4=
	printl("SHGetSpecialFolderPathA")
	r := dllcall(g_fileHooks.pSHGetSpeciaFolderPathA, uint, p1, uint, p2, uint, p3, uint, p4)
	if ( (p3 = CSIDL_COMMON_APPDATA) or (p3 = CSIDL_LOCAL_APPDATA) or (p3 = CSIDL_APPDATA) )
		strput(g_fileHooks.docs, p2+0, , "CP0")
	else if (p3 = CSIDL_PERSONAL)
		strput(g_globals.config.MyDocs "\Games\", p2+0, , "CP0")
	
	return r
}

SHGetSpecialFolderPathW(p1, p2, p3, p4)
{
	critical
	p4=
	printl("SHGetSpecialFolderPathW")
	r :=  dllcall(g_fileHooks.pSHGetSpeciaFolderPathW, uint, p1, uint, p2, uint, p3, uint, p4)
	if ( (p3 = CSIDL_COMMON_APPDATA) or (p3 = CSIDL_LOCAL_APPDATA) or (p3 = CSIDL_APPDATA) )
		strput(g_fileHooks.docs, p2+0, , "UTF-16")
	else if (p3 = CSIDL_PERSONAL)
		strput(g_globals.config.MyDocs "\Games\", p2+0, , "UTF-16")
	
	return r
}

SHGetKnownFolderPath(p1, p2, p3, p4)
{
	critical
	static FOLDERID_LocalAppData := "{F1B32785-6FBA-4FCF-9D55-7B8E7F157091}"
	static FOLDERID_RoamingAppData := "{3EB685DB-65F9-4CF6-A03A-E3EF65729F3D}"
	static FOLDERID_ProgramData := "{62AB5D82-FDC1-4DC3-A9DD-070D1D495D97}"
	static FOLDERID_Documents := "{FDD39AD0-238F-46AF-ADB4-6C85480369C7}"
	id := StringFromIID(p1)
	printl("SHGetKnownFolderPath->" id)
	r := dllcall(g_fileHooks.pSHGetKnownFolderPath, uint, p1, uint, p2, uint, p3, uint, p4)	
	
	if ( (id = FOLDERID_LocalAppData) or (id = FOLDERID_RoamingAppData) or (id = FOLDERID_ProgramData))
		strput(g_fileHooks.docs, p4+0, , "UTF-16")
	else if (id = FOLDERID_Documents)
		strput(g_globals.config.MyDocs "\Games\", p4+0, , "UTF-16")
	
	return r
}

FindFirstFileW(p1, p2)
{
	Critical
	r := dllcall(g_fileHooks.pFindFirstFileW, uint, p1, uint, p2)
	if ( (r = -1) and (A_lasterror = 2) )
	{	
		file := strget(p1+0, "UTF-16") 
		stringreplace, file, file, /,\, 1
		printl("Filein " file)
		
		docs := g_fileHooks.docs
		target := g_globals.config.target_dir
		stringreplace, file, file, %docs%, %target%
		printl("Fileout " file)
		r := dllcall(g_fileHooks.pFindFirstFileW, str, file, uint, p2)
	}	
	return r	
}	

FindFirstFileA(p1, p2)
{
	Critical
	r := dllcall(g_fileHooks.pFindFirstFileA, uint, p1, uint, p2)
	if ( (r = -1) and (A_lasterror = 2) )
	{	
		file := strget(p1+0, "CP0") 
		stringreplace, file, file, /,\, 1
		printl("Filein " file)
		
		docs := g_fileHooks.docs
		target := g_globals.config.target_dir
		stringreplace, file, file, %docs%, %target%
		printl("Fileout " file)
		r := dllcall(g_fileHooks.pFindFirstFileA, astr, file, uint, p2)
	}	
	return r
}

PathFileExistsA(p1)
{
	Critical
	printl("e" strget(p1, "CP0"))
	return dllcall(g_fileHooks.pPathFileExistsA, uint, p1)
}

PathFileExistsW(p1)
{
	Critical
	printl("e" strget(p1, "UTF-16"))
	return dllcall(g_fileHooks.pPathFileExistsW, uint, p1)
}

GetModuleFileNameA(p1, p2, p3)
{
	Critical
	r := dllcall(g_fileHooks.pGetModuleFileNameA, uint, p1, uint, p2, uint, p3)
	if not p1	
		strput(g_globals.config.target_dir "\" g_globals.config.target_name, "CP0")	
			
	return r	
}

GetModuleFileNameW(p1, p2, p3)
{
	Critical	
	r := dllcall(g_fileHooks.pGetModuleFileNameW, uint, p1, uint, p2, uint, p3)	
	if not p1	
		strput(g_globals.config.target_dir "\" g_globals.config.target_name, p2+0, "UTF-16")	
	
	return r
}

