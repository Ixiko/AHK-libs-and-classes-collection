; Note: Maybe add uFlags to globalAlloc params.
class mem {
	;<< Memory allocation/free methods >>
	globalAlloc(dwBytes){
		; URL:
		;	- https://msdn.microsoft.com/en-us/library/windows/desktop/aa366574(v=vs.85).aspx (GlobalAlloc function)
		static GMEM_ZEROINIT:=0x0040	; Zero fill memory
		static uFlags:=GMEM_ZEROINIT	; For clarity.
		local hMem
		if !(hMem:=DllCall("Kernel32.dll\GlobalAlloc", "Uint", uFlags, "Ptr", dwBytes, "Ptr"))
			xlib.exception("GlobalAlloc failed for dwBytes: " dwBytes,[hMem])
		return hMem
	}
	globalFree(hMem){
		; URL:
		;	- https://msdn.microsoft.com/en-us/library/windows/desktop/aa366579(v=vs.85).aspx (GlobalFree function)
		local h
		if h:=DllCall("Kernel32.dll\GlobalFree", "Ptr", hMem, "Ptr")
			xlib.exception("GlobalFree failed at hMem: " hMem,[h])
		return h
	}
	virtualAlloc(dwSize,flProtect:=0x40,flAllocationType:=0x1000 ){ ; These defaults are relied upon by rawPut. 
		; Url:
		;	- https://msdn.microsoft.com/en-us/library/windows/desktop/aa366887(v=vs.85).aspx (VirtualAlloc function)
		; Input:
		;	- dwSize, The size of the region, in bytes.
		; Defaults:
		; flProtect:=0x40 - PAGE_EXECUTE_READWRITE 
		; flAllocationType:=0x1000- MEM_COMMIT
		local bin
		if !(bin:=DllCall("Kernel32.dll\VirtualAlloc", "Uptr",0, "Ptr", dwSize, "Uint", flAllocationType, "Uint", flProtect, "Ptr"))
			xlib.exception("VirtualAlloc failed for dwSize: " . dwSize . " flProtect: " . flProtect . " flAllocationType: " . flAllocationType . "." ,[bin])
		return bin
	}
	virtualFree(lpAddress){
		; Url:
		;	- https://msdn.microsoft.com/en-us/library/windows/desktop/aa366892(v=vs.85).aspx (VirtualFree function)
		; Input:
		;	- lpAddress, a pointer to the base address of the region of pages to be freed.
		; Returns:
		;	- If the function succeeds, the return value is nonzero.
		;	  If the function fails, the return value is 0 (zero). To get extended error information, call GetLastError.
		static dwFreeType:=0x8000 ; MEM_RELEASE
		if !DllCall("Kernel32.dll\VirtualFree", "Ptr", lpAddress, "Ptr", 0, "Uint", dwFreeType, "Int") ; Non-zero is ok!
			xlib.exception("VirtualFree failed for address: " lpAddress)
		return 
	}
	virtualProtect(lpAddress, dwSize, flNewProtect){
		; Url:
		;	- msdn.microsoft.com/en-us/library/windows/desktop/aa366898(v=vs.85).aspx (VirtualProtect function)
		local r, lpflOldProtect:=0
		if !(r:=DllCall("Kernel32.dll\VirtualProtect", "Ptr", lpAddress, "Ptr", dwSize, "Uint", flNewProtect, "Uint*", lpflOldProtect, "Int")) ; If the function fails, the return value is zero. 
			xlib.exception("VirtualProtect failed to apply new memory protection: . " flNewProtect . " at adress: " . lpAddress . " (" . dwSize . " bytes).", [r])
		return lpflOldProtect
	}
	_aligned_malloc(size, alignment){
		/*
		void * _aligned_malloc(  
			size_t size,   
			size_t alignment  
		); 
		*/
		local p := dllcall("MSVCRT.dll\_aligned_malloc", "ptr", size, "ptr", alignment, "cdecl ptr")
		if !p
			xlib.exception(a_thisfunc " failed for size: " size ", alignment: " alignment ".")
		return p
	}
	rawPut(raw32, raw64){	; For writing binary code to memory.
		local k, i, bin, raw
		bin:=xlib.mem.virtualAlloc((raw:=(A_PtrSize==4?raw32:raw64)).length()*4)
		for k, i in raw
			NumPut(i,bin+(k-1)*4,"Int")
		return bin
	}
}