#include <GUID>
#include <DirectX\lib\DDSFile>


Class ComInterfaceWrapper
{
	__New(byref definition, ppInterface, version8 = False)
		{
			this.offsets := {}
			n := 0
			def := definition.def
			loop, parse, def, `n 
				{
					if instr(A_loopfield , "STDMETHOD")
						{
							method := RegExReplace(A_loopfield, "s)\).*" ,"")
							method := RegExReplace(method, "s).*\(" ,"")
							if instr(method, ",")
								{
									stringsplit, method_, method,`, 
									method := trim(method_2)
								}
							this.offsets[method] := n * 4
							n += 1							
						}	
				}		
			
			if version8
				pInterface := ppInterface
			else pInterface := numget(ppinterface+0, "ptr")
			if pInterface 
				{
					pInterface_Vtbl := numget(pInterface + 0, "Ptr")
					;printl("Interface " definition.name " " pInterface_Vtbl)
					for k, v in this.offsets
						{
							value := numget(pInterface_Vtbl + v, "Ptr")
							this[k] := value															
						}
				}
				
			this.pVTbl := pInterface_Vtbl					
			this.p := pInterface	
			this.def := def
			this.name := definition.name
			this.released := False
			this.hooks := {}
			this.isHooked := {}
		}
		
	Hook(Method, hook = "", options = "F")
	{
		if this.isHooked[Method]
			return "Method is already hooked"	
		
		if not this.p
			return "Failed to hook " this.name "::" Method " - The interface pointer is not valid"
		
		static hdtrs = "", sethooks = ""
		if not hdtrs 
			{
				hdtrs := dllcall("GetModuleHandleW", "str", "peixoto.dll") 
				sethooks := dllcall("GetProcAddress", "int", hdtrs , "astr", "sethook")			
			}	
		
		if not hdtrs or not sethooks
			return "Failed to hook " this.name "::" Method " - peixoto.dll or entry point could not be found"
		
		hook ?:	hook := isfunc("Alt_" Method) ? "Alt_" Method : isfunc("Alt" this.name "_" Method) 
		? "Alt" this.name "_" Method : this.name "_" Method 
		pHook := registerCallback(hook, options)
		if not pHook
			return "Failed to hook " this.name "::" Method " - could not create callback"
		
		pInterface_Vtbl := numget(this.p + 0, "Ptr")
		pHooked := numget(pInterface_Vtbl + this.offsets[Method], "Ptr")				
		r := dllcall(sethooks, "Ptr*", pHooked, "Ptr", pHook)	
		this[Method] := pHooked
		
		if r
			return "Failed to hook " this.name "::" Method " - detours error " r 
		else 
			{
				this.isHooked[Method] := True
				this.hooks[hook] := pHook
			}
			
		return "Succeeded to hook " this.name "::" Method 
	}	
	
	dllHook(Method, hook, dll = "peixoto.dll")
	{
		if this.isHooked[Method]
			return "Method is already hooked"	
		
		if not this.p
			return "Failed to hook " this.name "::" Method " - The interface pointer is not valid"
		
		static hdtrs = "", sethooks = ""
		if not hdtrs 
			{
				hdtrs := dllcall("GetModuleHandleW", "str", "peixoto.dll") 
				sethooks := dllcall("GetProcAddress", "int", hdtrs , "astr", "sethook")			
			}	
		
		if not hdtrs or not sethooks
			return "Failed to hook " this.name "::" Method " - peixoto.dll or entry point could not be found"
		
		
		pHook := dllcall("GetProcAddress", uint, dllcall("GetModuleHandle", str, dll), astr, hook)
		if not pHook
			return "Failed to hook " this.name "::" Method " - could not create callback"
		
		pInterface_Vtbl := numget(this.p + 0, "Ptr")
		pHooked := numget(pInterface_Vtbl + this.offsets[Method], "Ptr")				
		r := dllcall(sethooks, "Ptr*", pHooked, "Ptr", pHook)	
		this[Method] := pHooked
		
		if r
			return "Failed to hook " this.name "::" Method " - detours error " r
		else 
			{
				this.isHooked[Method] := "dll"
				this.hooks[hook] := pHook
			}
			
		return "Succeeded to hook " this.name "::" Method 
	}

	PatchVtable(method, table)
	{
		target := table+this.offsets[method]
		if not (hook := RegisterCallback(this.name "_" Method, "F"))
			return "Failed to hook " this.name "::" Method " - could not create callback"
		if not dllcall("VirtualProtect", uint, target, uint, 4, uint, (PAGE_READWRITE := 0x04), "uint*", old_protect)
			return "Failed to hook " this.name "::" Method " - VirtualProtect failed"
		numput(hook, table+this.offsets[method], "ptr")
		dllcall("VirtualProtect", uint, target, uint, 4, uint, old_protect, "uint*", _protect) 	
		return "Succeeded to hook " this.name "::" Method 	
	}
	
	__delete()	{		
			if not this.released
				dllcall(this.release, uint, this.p, uint)
		}
		
	__release()	{	
			this.released := True
			r := dllcall(this.Release, uint, this.p, uint) 
			return r
		}	
		
	UnHook(Method, hook = "")
		{
			if not this.isHooked[Method]
				return "Method is not hooked yet"				
			
			static hdtrs = "", unhook = ""
			if not hdtrs 
				{
					hdtrs  := dllcall("GetModuleHandle", "str", "peixoto.dll")
					unhook := dllcall("GetProcAddress", "int", hdtrs , "astr", "unhook")			
				}	
			
			if not hdtrs or not unhook
				return "Failed to unhook "	this.name "::" Method " - peixoto.dll or entry point could not be found"
			
			if not hook	
				hook := this.name "_" Method
			
			r := dllcall(unhook, "Ptr*", this[Method], "Ptr", this.hooks[hook])	
			if r
				return "Failed to unhook " this.name "::" Method " - detours error " r
			else 
				{
					if not this.isHooked[Method] = "dll"
						DllCall("GlobalFree", "Ptr", hooks[hook], "Ptr")
					this.hooks.remove(hook)	
					this.isHooked.remove(Method) 
				}
			return "Succeeded to unhook " this.name "::" Method 	
		}		
}

keyevent(key)
{
	static state
	if not state
	{
		letters = abcdefghijklmnopqrstuvwxz123456789[]
		state := {}
		stringsplit, keys, letters
		loop, % strlen(letters)
			state[keys%A_index%] := ""	
		for k, v in ["PgUp", "PgDn", "Insert", "Up", "Down", "Left", "Right", "Home", "BS"]
			state[v] := ""	
	}

	event := False
	newstate := getkeystate(key)
	if ( (newstate = True) and (state[key] = False)  )
		event := True			
	state[key] := newstate
	return event	
}	

StringFromIID(pIID)
{	
	dllcall("Ole32.dll\StringFromIID", uint, pIID, "uint*", GUID)
	rtn := StrGet(GUID)  
	dllcall("Ole32.dll\CoTaskMemFree", uint, GUID) 
	return rtn
}	

zeromem(struct){
	varsetcapacity(struct[], struct.size(), 0)	
	}
	
newmem(struct){
	VarSetCapacity(st, struct.size(), 0)
	struct[] := &st
	}

logErr(msg){
	static file, call, maxlogs = 10
	call += 1
	if not file
	{
		file := strsplit(msg, "|")[1]
		maxlogs := strsplit(msg, "|")[2]
		filedelete, %file%
		return
	} 
	if (call < maxlogs + 2)
		fileAppend, %msg%`n, %file% 	
	printl(msg)
}

cicleColor(clr)
{
	static clrs := [0x00000000, 0x00FFFFFF, 0x00ff0000, 0x0000ff00, 0x000000ff, 0x00ffff00, 0x00ff00ff
				   ,0x0000ffff, 0x00000000]
	for k, v in clrs
	{
		if (clr = v)
		{
			clr := clrs[k+1]
			break
		}
	}return clr
}	
	
print(msg = "")
{
	static hnd
	if not hnd
		{
			/* DllCall("AllocConsole")
			 */
			DllCall("AttachConsole", uint, (ATTACH_PARENT_PROCESS := -1))
			hnd := DllCall("GetStdHandle", "int", -11)
		}
	/* fileappend, % msg, *	
	 */	
    return dllcall("WriteConsole", "int", hnd , "ptr", &msg, "int", strlen(msg))
}

printl(msg = "") {	
	return msg ? print(msg . "`n") : (g_globals.config.console) ?: DllCall("FreeConsole") 	
}	

parseConfig(item = "")
{
	if not item
	{
		envget, config, env_commandline
		config := strsplit(config, "^")	
		globals := {}
		globals.config := {}
		
		for k, v in config
		{
			Key := SubStr(v, 1, 1)
			_Key := SubStr(v, 2, strlen(v)-1)
			if _Key is number
				continue								
			if (Key = "-") 
				globals.config[SubStr(v, 2, strlen(v)-1)] := config[k + 1]	
			else if (Key = "/")
				globals.config[SubStr(v, 2, strlen(v)-1)] := True
		}
		return globals	
	} else {
		config := {}
		for k, v in strsplit(item, ";")
		{
			split := strsplit(v, "=")
			key := split[1]
			val := split[2]
			(val = "True") ? val := True
			(val = "False") ? val := False
			config[key] := val			
		}
		return config
	}	
}	

resume()  
{
	StringToSend := "resume"
	VarSetCapacity(CopyDataStruct, 3*A_PtrSize, 0)  
	SizeInBytes := (StrLen(StringToSend) + 1) * (A_IsUnicode ? 2 : 1)
	NumPut(SizeInBytes, CopyDataStruct, A_PtrSize)
	NumPut(&StringToSend, CopyDataStruct, 2*A_PtrSize)
	return dllcall("SendMessageW", uint, g_globals.config.script_hwnd, uint, 0x4a, uint, 0, uint, &CopyDataStruct) 	 
}

GetDesktopResolution()
{
	r := {}
	HORZRES := 8
	VERTRES := 10
	h_desk := dllcall("GetDC", uint, 0, uint)
	r.w := dllcall("GetDeviceCaps", uint, h_desk, uint, HORZRES, int)
	r.h := dllcall("GetDeviceCaps", uint, h_desk, uint, VERTRES, int)
	dllcall("ReleaseDC", uint, 0, uint, h_desk)
	return r
}

CreateLinksCollection(links, target_dir)
{
	target_dir := g_globals.config.mydocs "\games\" target_dir
	FileCreateDir, %target_dir%
	for k, v in  links {
		;logerr(A_workingdir "\" v " -> " _dir "\" v)
		printl("Simbolic link : " lnk "-> Succes= " dllcall("CreateSymbolicLinkW", str, A_workingdir "\" v
		, str, target_dir "\" v, uint, 0) " code= " A_lasterror)
	}
}

tFOV(oldfov, ratio)
{
	oldfov *= 0.01745329252 / 2
	return 2 * (ATan(tan(oldfov) * ratio[1]/ratio[2]) * 57.29578)
}

global GUID := "DWORD Data1; WORD  Data2;  WORD  Data3;  BYTE  Data4[8]"




