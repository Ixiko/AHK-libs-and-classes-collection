class ui {
	; User classes and methods.
	
	
	#include createLib.ahk
	; Misc user methods
	nLogicalCores(){
		; Returns the number logical processor cores on the system.
		static nCores := envget("Number_Of_Processors")
		return nCores
	}
	getFnPtrFromLib(lib:="",fn:="",suffixWA:=false,free:=false){
		; lib, path to the library  / dll where the function resides
		; fn, name of the function.
		;	  suffixWA, if false (0) the fn name is not suffixed with W or  A  depending  on
		; 	  A_IsUnicode,  if  true (1) the fn name is always suffixed, if this parameter is
		; 	  (-1), the fn name is suffixed if the first attempt to get the address fails.
		static common_libs := ["User32.dll", "Kernel32.dll", "ComCtl32.dll", "Gdi32.dll", "MSVCRT.dll"]
		local
		global xlib
		if !fn
			xlib.exception("No function specified",,-1)
		if IsObject(lib)
			dll:=lib[1]
		if !lib {	; no lib specified, search common libs.
			for k, clib in common_libs {
				try 
					fnPtr := xlib.ui.getFnPtrFromLib(clib, fn, suffixWA, false)
				if fnPtr
					return fnPtr
			}
			xlib.exception("No library found for function:`t" fn)
		}
		
		if !dll
			(dll := xlib.ui.getModuleHandle(lib)) ? free := false : dll := xlib.ui.loadLibrary(lib)
		if !dll
			xlib.exception("Failed to load library: " lib)
		if (suffixWA==1)
			fn.= A_IsUnicode ? "W" : "A"
		
		fnPtr := xlib.ui.getProcAddress(dll, fn)
		
		if (!fnPtr && suffixWA==-1)
			fnPtr:=xlib.ui.getProcAddress(dll, fn . (A_IsUnicode ? "W" : "A"))

		if free ; This is probably not wanted.
			xlib.ui.freeLibrary(dll)

			if !fnPtr
			xlib.exception("Failed to get procedure address:`t" . fn)
		
		return fnPtr
	}
	getModuleHandle(byref lib){
		; No error handling!
		return DllCall("Kernel32.dll\GetModuleHandle", "Ptr", &lib, "Ptr")
	}
	loadLibrary(byref lib){
		; No error handling!
		return DllCall("Kernel32.dll\LoadLibrary", "Ptr", &lib, "Ptr")
	}
	getProcAddress(dll, fn){
		; No error handling!
		return DllCall("Kernel32.dll\GetProcAddress", "Ptr", dll, "astr", fn, "Ptr")
	}
	freeLibrary(lib){
		; Url:
		;	- https://msdn.microsoft.com/en-us/library/windows/desktop/ms683152(v=vs.85).aspx FreeLibrary function
		; Notes:
		;	If the function succeeds, the return value is nonzero.
		if !DllCall("Kernel32.dll\FreeLibrary", "Ptr", lib)
			xlib.exception("Free library failed for: " lib,,-2)
		return 1
	}
	setMemoryReadOnly(ptr,size){
		; Returns previous memory settings and set new to PAGE_READONLY
		static PAGE_READONLY:=0x02
		return xlib.mem.virtualProtect(ptr,size,PAGE_READONLY)
	}
}