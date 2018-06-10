#persistent
#NoEnv  
SendMode Input  
SetWorkingDir %A_ScriptDir% 
#include <Shell>
#include <_filesystem>
#include <memlib\memlib>

RunAsAdmin()
if not A_iscompiled
{
	FileInstall, ..\Xinput.ahk, ?Dummy	
	FileInstall, gdi.hooks.ahk, ?Dummy	
	;compileScript("exlib.ahk")
	FileInstall, exlib.txt, ?Dummy
	;compileScript("remote_lib.ahk")
	FileInstall, remote_lib.txt, ?Dummy	
	;compileScript("dshow.hooks.ahk")
	FileInstall, dshow.hooks.txt, ?Dummy
	;compileScript("dsound.hooks.ahk")
	FileInstall, dsound.hooks.txt, ?Dummy	
	;compileScript("dinput.hooks.ahk")
	FileInstall, dinput.hooks.txt, ?Dummy
	compileScript("d3D.hooks.ahk")
	FileInstall, d3D.hooks.txt, ?Dummy	
	;compileScript("gl.hooks.ahk")
	FileInstall, gl.hooks.txt, ?Dummy
	runwait, Ahk2Exe.exe /in %A_scriptName% /out Injector.exe 	
}

OnMessage(0x4a, "Receive_WM_COPYDATA") 
global g_globals := parseCommandLine()
getRemoteScript()
launchTarget()

launchTarget()
{
	print("`r")
	g_ahkpath := FileExist(A_scriptdir "\AutoHotkey.dll") ? A_scriptdir "\AutoHotkey.dll" : A_mydocuments "\Autohotkey\dlls\AutoHotkey.dll"
	g_peixotopath := FileExist(A_scriptdir "\peixoto.dll") ? A_scriptdir "\peixoto.dll" : A_mydocuments "\Autohotkey\dlls\peixoto.dll"	
		
	target := g_globals.target
	splitpath, target, name
	process, exist, %name%	
	fileexist(g_globals.target) ?: quit(name " not found in`n`n" g_globals.target_dir)	
	errorlevel ? quit(name ".exe already running")
			
	dllcall("LoadLibraryW", str, g_peixotopath) ?: Quit("Unable to find or load`n" g_peixotopath)
	dllcall("LoadLibraryW", str, g_ahkpath) ?: Quit("Unable to find or load`n" g_ahkpath)
	
	compat := g_globals.compatLayer 
	if compat
		EnvSet, __COMPAT_LAYER, %compat%
	
	if g_globals["/saves"]
		argv0 := g_globals.MyDocs "\Games\" strsplit(name, ".ex")[1] "\" name 
	else argv0 := g_globals.target 
	
	if g_globals.no_argv0
		g_globals.proc := CreateIdleProcess(g_globals.target, g_globals.target_dir, g_globals.args)
	else g_globals.proc := CreateIdleProcess(g_globals.target, g_globals.target_dir, """" argv0 """ " g_globals.args)
		
	(g_globals.singlecore) & True ? dllcall("SetProcessAffinityMask", uint, g_globals.proc.hProcess, uint, 0x00000008) 
	? : dllcall("SetProcessAffinityMask", uint, g_globals.proc.hProcess, uint, 0x00000002) 
					
	dllcallEx(g_globals.proc.hProcess, "Kernel32.dll", "LoadLibraryW", g_ahkpath)
	sleep, 1000
	dllcallEx(g_globals.proc.hProcess, "Kernel32.dll", "LoadLibraryW", g_peixotopath)
	sleep, 1000
		
	success := 1
	while success = 1 {				
		success := dllcallEx(g_globals.proc.hProcess, "autohotkey.dll", "ahktextdll", g_globals.remoteScript)
						
		if (success = 2)
			quit("Could not allocate memory for dll injection: " A_lasterror)
		else if (success = 3)
			quit("Could not write to memory allocated for dll injection")
		else if (success = 4)
			quit("Could not create remote thread for dll injection")
	}	
		
	id := g_globals.proc.Process_id
	process, waitclose, %id%	
	if g_globals["saves/"] 
	{
		lnk := instr(g_globals["saves/"], ":") ? g_globals["saves/"] : g_globals.target_dir "\" g_globals["saves/"]
		Print("`nRemoving simbolic link : " lnk)
		fileremovedir, %lnk%
	}
	if  g_globals["saves"]
	{
		docs := g_globals.MyDocs "\Games\" strsplit(g_globals.target_name, ".ex")[1]
		fileremovedir, %docs%
	}
	exitapp
}

resume()
{
	static childRunning := False
	if childRunning
		return
	loop % ResumeProcess(g_globals.proc.hThread)
		ResumeProcess(g_globals.proc.hThread)
	childRunning := True
	if g_globals.ex_script
	{
		ahktextdll := dllcall("GetProcAddress", uint, dllcall("GetModuleHandle", str, "AutoHotkey.dll"), astr, "ahktextdll")
		envget, cmd, env_commandLine
		dllcall(ahktextdll, Str, g_globals.ex_script, Str, cmd, Str, "", "Cdecl UPTR")		
	}
}	

getRemoteScript()
{
	g_globals.remoteScript := LoadResource("remote_lib.txt")
	g_globals.remoteScript .= "`n" LoadResource("..\Xinput.ahk") 
	if g_globals.dshow
		g_globals.remoteScript .= "`n`r" LoadResource("dshow.hooks.txt")
	if g_globals.dsound
		g_globals.remoteScript .= "`n`r" LoadResource("dsound.hooks.txt")
	if g_globals.GDIHooks 	
		g_globals.remoteScript .= "`n" LoadResource("GDI.hooks.ahk") 
	if g_globals.controller 	
		g_globals.remoteScript .= "`n" LoadResource("dinput.hooks.txt")	"`n"	
	if (g_globals.d3D > 0 and g_globals.d3D < 4) or g_globals.d3D = 7 or g_globals.upScale or g_globals.8bitColorFix or g_globals.ddraw
		g_globals.remoteScript .= "`n" LoadResource("d3D.hooks.txt")
	if 	g_globals.d3D = -1
		g_globals.remoteScript .= "`n" LoadResource("gl.hooks.txt")
	if g_globals.Script
		{
			g_globals.ex_script := LoadResource("exlib.txt") "`n"
			g_globals.ex_script .= LoadResource("..\Xinput.ahk") "`n"			
			script_file := g_globals.Script
			fileread, script, %script_file%
			script := strsplit(script, ";REMOTE SCRIPT START")
			g_globals.remoteScript .= "`n" script[2] "`n"
			g_globals.ex_script .= "`n" script[1]						
		}	
		
	if not g_globals.console and not g_globals.dev
		g_globals.remoteScript .= "`nprintl()"	
	g_globals.remoteScript .= "`n" r_script . "`nresume()"	
	;msgbox % g_globals.remoteScript
}	

print(msg = "")
{
	static hnd
	if not hnd
		{
			target := g_globals.target
			splitpath, target, name			
			(g_globals.icon) ? g_globals.console_icon.h := dllcall("LoadImage", uint, 0, wstr, g_globals.icon
			, uint, 1, int, 32, int, 32, uint, (LR_LOADFROMFILE := 0x00000010)) : EnumIcons(g_globals.target)
			DllCall("AllocConsole")			
			hnd := DllCall("GetStdHandle", "int", -11)			
			dllcall("SetConsoleIcon", uint, g_globals.console_icon.h)
			dllcall("SetConsoleTitle", str, " AHK Injector (" name ")")
		}
	return dllcall("WriteConsole", "int", hnd , "ptr", &msg, "int", strlen(msg))
}

compileScript(script)
{
	if A_iscompiled 
		return	
	splitpath, script, , , ,script_name	
	runwait, Ahk2Exe.exe /in %script% /out %script_name%.exe 							
	script_txt := LoadResource(">AUTOHOTKEY SCRIPT<", script_name ".exe")
	filedelete, %script_name%.txt
	fileappend, %script_txt%, %script_name%.txt
}	

LoadResource(resource, module = "")
{
	if not module
		hModule := dllcall("GetModuleHandle", uint,  0)
	else FreeLater := hModule := dllcall("LoadLibraryW", str, module)
	HRSRC := dllcall("FindResourceW", uint, hModule, str, resource, ptr, 10)
	hResource := dllcall("LoadResource", uint, hModule, uint, HRSRC)
	DataSize := DllCall("SizeofResource", ptr, hModule, ptr, HRSRC, uint)
	pResData := dllcall("LockResource", uint, hResource, ptr)
	ret := strget(pResData, DataSize, "UTF-8")
	;dllcall("FreeResource", uint, hResource) 
	FreeLater ? dllcall("FreeLibrary", uint, hModule)
	return ret
}

parseCommandLine()
{
	parent := GetParentDir()
	config := {}
	cmd := ""
	pid := DllCall("GetCurrentProcessId")
	for k, v in GetCommandLineAsList()
		cmd .= "^" v	
	cmd .= "^-script_hwnd^" A_scripthwnd
	cmd .= "^-error_log^" A_scriptdir "\error.log"
	cmd .= "^-Mydocs^" A_mydocuments
	cmd .= "^-injector_dir^" A_scriptdir
	
	stringreplace, cmd, cmd, ^, , 0	
	stringreplace, cmd, cmd, p?, %parent%, All	
	stringreplace, cmd, cmd, d?, %A_mydocuments%, All
	stringreplace, cmd, cmd, c?, %A_scriptdir%, All
	envset, env_commandLine, %cmd%
	cmd := strsplit(cmd, "^")	
	
	for k, v in cmd
	{
		Key := SubStr(v, 1, 1)
		if (Key = "-")
			config[SubStr(v, 2, strlen(v)-1)] := cmd[k + 1]	
		else if (Key = "/")
			config[SubStr(v, 2, strlen(v)-1)] := True
	}
	
	if not config.target 
		quit("No target supplied!")
	else 
	{
		VarSetCapacity(OSVERSIONINFO, 276)
		numput(276, &OSVERSIONINFO+0)
		dllcall("GetVersionExW", ptr, &OSVERSIONINFO)
		os_version := numget(&OSVERSIONINFO+4, "int") + numget(&OSVERSIONINFO+8, "int")*0.1
		target := config.target
		splitpath, target, taget_name, dir 
		config.target_dir := dir
		config.target_name := taget_name
		envget, cmd, env_commandLine
		cmd .= "^-os_version^" os_version
		OSVERSIONINFO := ""
		cmd .= "^-target_dir^" dir
		cmd .= "^-target_name^" taget_name
		envset, env_commandLine, %cmd%
	}	
	config.console_icon := {"h" : 0, "w" : 0, "pitch" : 0}
	return config
}	

quit(msg)
{
	msgbox, 16, , % msg
	ExitApp
}

Receive_WM_COPYDATA(wParam, lParam)
{	
	StringAddress := NumGet(lParam + 2*A_PtrSize)  
    CopyOfData := StrGet(StringAddress)
	if isfunc(CopyOfData)
		%CopyOfData%()
	return True
}

EnumIcons(Filename, Type=14)
{
    hModule := DllCall("LoadLibraryW", "str", Filename)
	enumproc := RegisterCallback("EnumIconsCallback","F")	
	       
    DllCall("EnumResourceNamesW", "uint", hModule, "uint", Type, "uint", enumproc, "uint", hModule) 
    DllCall("GlobalFree", "uint", enumproc)    
    DllCall("FreeLibrary", "uint", hModule)	
    return NumGet(param,4)
}

EnumIconsCallback(hModule, lpszType, lpszName, lParam)
{
	critical
	static ICONINFO, BITMAP 
	ICONINFO ?: VarSetCapacity(ICONINFO, 20)
	BITMAP ?: VarSetCapacity(ICONINFO, 28)
	hIcon := dllcall("LoadImageW", uint, lParam, "uint", lpszName, int, 1, int, 0, int, 0, uint, 0x00000040)
	dllcall("GetIconInfo", uint, hIcon, ptr, &ICONINFO)
	dllcall("GetObject", uint, numget(&ICONINFO+16, "uint"), uint, 28, ptr, &BITMAP)
	
	if (numget(&BITMAP+4, "uint") >= g_globals.console_icon.w) and (numget(&BITMAP+12, "uint") >= g_globals.console_icon.pitch)
	{
		fileappend, updating `n, *
		if g_globals.console_icon.h 
		{
			dllcall("DestroyIcon", uint, g_globals.console_icon.h)
			fileappend, destroying `n, *
		}
		g_globals.console_icon := {"h" : hIcon, "w" : numget(&BITMAP+4, "uint"), "pitch" : numget(&BITMAP+12, "uint")}
	}	
	fileappend, % numget(&BITMAP+4, "uint") " x " numget(&BITMAP+8, "uint") " x " numget(&BITMAP+12, "uint")  "`n" , *	
	return true
}	