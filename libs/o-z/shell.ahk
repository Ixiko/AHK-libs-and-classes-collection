GetCommandLineAsList(index = 0)
{
	cmds := []
	cmd := dllcall("GetCommandLine", str)
	VarSetCapacity(argcount, 4)
	p_args := dllcall("Shell32.dll\CommandLineToArgvW", str, cmd, ptr, &argcount, ptr)
	loop , % numget(argcount, "int")
		cmds.insert(strget(numget(p_args+(A_index - 1)*4, "ptr"), "UTF-16"))
		
	if index = 0 
		return cmds
	
	else if (index > cmds.maxindex()  or  (cmds.maxindex() + 1 + index < 1))
		return "_invalid index_"
	
	else if (index > 0) 
		return cmds[index]
	
	else if (index < 0) 
		return cmds[cmds.maxindex() + 1 + index]		
}

GetCommandLineValueB(switch, value = "")
{
	lst := GetCommandLineAsList()
	for k, v in lst {
		if (v = switch)
			value := lst[k+1]
	}return value
}

GetCommandLineValue(switch, value = "")
{
	lst := GetScriptParamsAsList()
	for k, v in lst {
		if (v = switch)
			value := lst[k+1]
	}return value
}	

HijackShortCut(lnk, newTarget, abspath = False, cmdline = False)
{
	FileGetShortcut, %lnk%, Target, workingdir, args, desc, _Icon, Iconnum, State
	if errorlevel
		return errorlevel
	
	cmdline ? args := cmdline
	
	if not abspath
		newTarget := workingdir "\" newTarget
	
	if (Target = newTarget)
		return
	
	FileCreateShortcut, %newTarget%, %lnk%, %workingdir%, "%Target%" %args%, %desc%, %_Icon%, ,%Iconnum%, %state%	
	return errorlevel
}

GetScriptParamsAsList()
{
	global
	local params := []
	Loop, %0%  
		params.insert(%A_Index%) 
	return params
}

GetScriptParams()
{
	global
	local params := ""
	Loop, %0%  
		params .=  A_Space . """" %A_Index% """"
	return params
}

getRunCommand(path = False)
{
	path ?: path=%A_scriptdir%
	path = "%path%\%A_scriptname%"
	if not A_iscompiled 
		path="%A_AhkPath%" %path%
	stringreplace, path, path, % "\\", \, 1
	return path
}	

RunAsAdmin(condition = False, foo = "temp", args = "")
{
	params := GetScriptParams()  
	
	if (A_scriptdir = A_temp) {
		%foo%()
		exitapp
	}
		
	if not A_isadmin 
	{
		ShellExecute := A_IsUnicode ? "shell32\ShellExecute" : "shell32\ShellExecuteA"
		A_IsCompiled
			? DllCall(ShellExecute, uint, 0, str, "RunAs", str, A_ScriptFullPath, str, params, str, A_WorkingDir, int, 1)
			: DllCall(ShellExecute, uint, 0, str, "RunAs", str, A_AhkPath, str, """" . A_ScriptFullPath . """" . A_Space . params
			, str, A_WorkingDir, int, 1)
		ExitApp	
	}
	
	else
	{
		if condition 	
		{
			filecopy, %A_scriptfullpath%, %A_temp%\%A_scriptname%, 1
			run %A_temp%\%A_scriptname% %params% %args%, %A_temp%
			exitapp
		}
		return
	}			
}


/* GetCommonPath - Get path to standard system folder by majkinetor
 * http://www.autohotkey.com/forum/topic10325.html
 */
GetCommonPath( csidl )
{
	CSIDL_APPDATA = 0x001A               ; Application Data, new for NT4
	CSIDL_COMMON_APPDATA = 0x0023        ; All Users\Application Data
	CSIDL_COMMON_DOCUMENTS = 0x002e      ; All Users\Documents
	CSIDL_DESKTOP = 0x0010               ; C:\Documents and Settings\username\Desktop
	CSIDL_FONTS = 0x0014                 ; C:\Windows\Fonts
	CSIDL_LOCAL_APPDATA = 0x001C         ; non roaming, user\Local Settings\Application Data
	CSIDL_MYMUSIC = 0x000d               ; "My Music" folder
	CSIDL_MYPICTURES = 0x0027            ; My Pictures, new for Win2K
	CSIDL_PERSONAL = 0x0005              ; My Documents
	CSIDL_PROGRAM_FILES_COMMON = 0x002b  ; C:\Program Files\Common
	CSIDL_PROGRAM_FILES = 0x0026         ; C:\Program Files
	CSIDL_PROGRAMS = 0x0002              ; C:\Documents and Settings\username\Start Menu\Programs
	CSIDL_RESOURCES = 0x0038             ; %windir%\Resources\, For theme and other windows resources.
	CSIDL_STARTMENU = 0x000b             ; C:\Documents and Settings\username\Start Menu
	CSIDL_STARTUP = 0x0007               ; C:\Documents and Settings\username\Start Menu\Programs\Startup.
	CSIDL_SYSTEM = 0x0025                ; GetSystemDirectory()
	CSIDL_WINDOWS = 0x0024               ; GetWindowsDirectory()
	
	val = % CSIDL_%csidl%
	SHGetFolderPath := A_IsUnicode ? "shell32\SHGetFolderPath" : "shell32\SHGetFolderPathA"
	VarSetCapacity(fpath, A_IsUnicode ? 260 * 2 : 260)
	DllCall(SHGetFolderPath, uint, 0, int, val, uint, 0, int, 0, str, fpath)
	return %fpath%
}


