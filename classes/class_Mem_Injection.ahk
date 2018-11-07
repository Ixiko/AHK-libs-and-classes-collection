class ProcessEntry32
	{
		__New(Name, ID_)
			{
				this.name := Name
				this.ID  := ID_
			}
	}					

get_process_list()
	{
		process_list := {}
		snapshot_handle := dllcall("CreateToolhelp32Snapshot", "int", 0x00000002, int, 0)
		
		varsetcapacity(lppe, 556 , 0),	numput(556, lppe, 0,Int)
		success :=  dllcall("Process32First", "Ptr", snapshot_handle, "Ptr", &lppe)
		process_list.insert(new ProcessEntry32(StrGet(&lppe + 36, 520, 0), NumGet(lppe, 8, "Int")))    
		
		while success
			{
				varsetcapacity(lppe, 556 , 0),	numput(556, lppe, 0,Int)			
				success := dllcall("Process32Next", "Ptr", snapshot_handle, "Ptr", &lppe) 
				process_list.insert(new ProcessEntry32(StrGet(&lppe + 36, 520, 0), NumGet(lppe, 8, "Int")))
			}	
		return 	process_list
	}

open_process(ProcessID, access = "", InheritHandle = 0)
{
	;defautl acess flags = PROCESS_VM_OPERATION | PROCESS_VM_READ | PROCESS_VM_WRITE | PROCESS_QUERY_INFORMATION
	if access = 
		access := 0x0008 | 0x0010 | 0x0020 |  0x0400
	return DllCall("OpenProcess", "Int", access, "Char", InheritHandle, "UInt", ProcessID, "Uint")	
}

get_process_handle(process_, access = "")
{
	for k, v in get_process_list()
		{
			if v.name = process_
				return open_process(v.ID, access)	
		}	
}	

close_process_handle(hProcess){
	return dllcall("CloseHandle", "int", hProcess)
}	

write_process_memory(hProcess, adress, type_, value)
{	
	size := {"char": 1, "UChar": 1, "short": 2, "int": 4, "array": value._MaxIndex()
			, "float" : 4, "str" : (StrLen(value)+1) * 2}
	
	
	if (type_ = "array")
		{
			varsetcapacity(buffer, size[type_], 0)
			loop, % value._MaxIndex()
				Numput(value[A_index], buffer, A_index - 1, "UChar")								
		}	
	else if  (type_ = "str")
		{
			varsetcapacity(buffer, size[type_], 0)
			StrPut(value, &buffer, size[type_], "UTF-16")	
		}
	else
		{		
			varsetcapacity(buffer, size[type_], 0)
			Numput(value, buffer, 0, type_)
		}


	r := dllcall("WriteProcessMemory"
				,"Int", hProcess
				,"Ptr", adress
				,"Ptr", &buffer
				,"UInt", size[type_]
				,"Int", 0
				,"Uint")
	return r				
}

read_process_memory(hProcess, adress, type_, arraysize = "")
{
	size := {"char": 1, "UChar": 1, "short": 2, "int": 4, "Uint": 4, "Ptr": 4, "array": arraysize
			, "float" : 4}
	if (type_ = "array")
		varsetcapacity(buffer, arraysize, 0)
	else		
		varsetcapacity(buffer, size[type_], 0)		
			
	r := dllcall("ReadProcessMemory"
				,"Int", hProcess
				,"Ptr", adress
				,"Ptr", &buffer
				,"UInt", size[type_]
				,"Int", 0
				,"Uint")
	if ! r
		return
				
	if (type_ = "array")
		{
			return_value := []
			loop, % arraysize 
				return_value.insert(Numget(buffer,  A_index - 1, "UChar"))
		}	
	else return_value := Numget(buffer,  0, type_)
	return return_value			
}

read_pointer_sequence(hprocess, baseadress, offsets)
{
	pointer := read_process_memory(hprocess, baseadress, "Ptr") 
	;fileappend, % pointer "`n", *
	for k, offset in offsets
		{			
			adress := pointer + offset
			pointer := read_process_memory(hprocess, adress, "Ptr")
			;fileappend, % pointer "`n", *
		}
	return [adress, pointer] ; the last "pointer" is the value 	
}

class CodeInjection
{
	__New(hprocess, addy, newcode)
		{
			format := A_FormatInteger			
			setformat, integer, H
			this.process_ := hprocess
			this.addy := addy
			this.newcode := newcode
			;fileappend, % this.process_ ":" this.addy ":" this.newcode._maxIndex(),*
			this.original_code := read_process_memory(hprocess, this.addy, "array", this.newcode._maxIndex())
			;for k, v in this.original_code
				;fileappend, % v, *		
			setformat, integer, %format%		
		}		
		
	_enable()
		{
			return write_process_memory(this.process_, this.addy, "array", this.newcode)	
		}	
	
	_disable()
		{	
			return write_process_memory(this.process_, this.addy, "array", this.original_code)	
		}	

	switch()	
		{
			current_code := read_process_memory(this.process_, this.addy, "array", this.newcode._maxIndex())
			for k, v in current_code
				fileappend, % v ":" this.original_code[k] ":" this.newcode[k]"`n", *	
			
			if arrays_are_equal(current_code, this.original_code)
				{
					;fileappend, disabled, *	
					if this._enable()
						return 64
					else return 16
				}	
			else if arrays_are_equal(current_code, this.newcode)
				{
					;fileappend, enabled, *	
					if this._disable()
						return -1
					else return 16
				}	
		}
	__Delete()	{
		this._disable()
	}		
}		
	
VirtualAllocEx(hProcess, mem_size)
{
	adress := dllcall("VirtualAllocEx"
			,"Int", hProcess
			,"Int", 0
			,"Int", mem_size
			,"Int", 0x00001000 | 0x00002000
			,"Int", 0x10)
			
	;fileappend, % "add: " adress "`n", *		
	return_value := []
	loop, % adress_size 
		return_value.insert(Numget(adress,  A_index - 1, "UChar"))
	return adress
}	

dllcallEx(h_process, Lib, function, argument)
{
	/*  Errors - erroelevel has the reason for failure:
		0: success		
		1: GetProcAddressEx or LoadLibraryW Failed: dll and function names are case sensitive
		2: VirtualAllocEx failed
		3: WriteProcessMemory failed
		4: CreateRemoteThread failed
	*/	
	
	if (Lib = "Kernel32.dll")
		procedure := dllcall("Kernel32.dll\GetProcAddress", uint, dllcall("LoadLibraryW", str, Lib, uint), astr, function)
	else
		procedure := GetProcAddressEx(h_process, Lib, function)
	
	if not procedure
		return 1
	
	adress := VirtualAllocEx(h_process, StrLen(argument) * 2)
	if not adress
		return 2
	
	if not write_process_memory(h_process, adress, "str", argument)
		return 3	

	if not dllcall("CreateRemoteThread"
	,uint, h_process
	,uint, 0                     ;lpThreadAttributes,
	,uint, 0                     ;dwStackSize,
	,uint, procedure
	,uint, adress                ;lpParameter,
	,uint, 0 
	,uint, 0)
		return 4		
	return 0	
}

GetProcAddressEx(h_process, module, function)
{
	this_fucntion_add := dllcall("Kernel32.dll\GetProcAddress", uint, dllcall("LoadLibraryW", str, module, uint), astr, function)
	this_module_info := find_module(module, DllCall("GetCurrentProcessId"))	
	offset := this_fucntion_add - this_module_info.BaseAddr	
	;msgbox % "offset: " offset
		
	module_info := find_module(module, dllcall("GetProcessId", uint, h_process, uint))		
	address := module_info.BaseAddr + offset 
	;msgbox % "addres: " address
	
	return address
}	

ReverseInt32bytes(int32)
{
	format := A_FormatInteger	
	setformat, integer, H
	stringreplace, int32, int32, 0x, ,
	while (strlen(int32) < 8)
		int32 := "0" int32				
			
	;fileappend, % "i:" int32 "`n", *
	
	add_ := []
	loop, 4
		add_.insert("0x" substr(int32, 7 - (A_index - 1)*2, 2))
	
	setformat, integer, %format%
	return add_
}

/*
Code cave will use:

	push asolute_adress
	ret
	
so 6 bytes will be ovewriten
use the argument "nops" to ovewrite extra bytes in the case that
any instructions got trucated

this code  (push adress, ret) is automatically inserted to return from the code cave as well
so there is no need to translate that part of the assembly script
*/

Class CodeCave
{
	__New(hprocess, from, code, nops = 0)
		{
			format := A_FormatInteger
			setformat, integer, H
			to := VirtualAllocEx(hprocess, code._MaxIndex() + 6 + nops)
			if not to
				return
			;fileappend, % to "`n", *
			this.orginal_code := read_process_memory(hProcess, from, "array", 6 + nops)
			this.code := code
			this.from := from
			this.to := to
			this.hprocess := hprocess
			adress2go := ReverseInt32bytes(to)	
			adress2return := ReverseInt32bytes(from + 6 + nops)								
			
			this.jump_instruction := [0x68]	
			loop, 4
				this.jump_instruction.insert(adress2go[A_index])
			this.jump_instruction.insert(0xc3)
			loop, % nops
				this.jump_instruction.insert(0x90)
			;for k, v in this.jump_instruction 
				;fileappend, % v "`n", *
			
			this.jumpback_instruction := [0x68]	
			loop, 4
				this.jumpback_instruction.insert(adress2return[A_index])
			this.jumpback_instruction.insert(0xc3)	
			;for k, v in this.jumpback_instruction 
				;fileappend, % v "`n", *	
			
			setformat, integer, %format%
		}
		
	_enable()
		{
			if not write_process_memory(this.hprocess, this.from, "array", this.jump_instruction)
				return
			for k, v in this.jumpback_instruction
				this.code.insert(v)							
			return write_process_memory(this.hprocess, this.to, "array", this.code)
		}	
		
	_disable()	{
			return write_process_memory(this.hprocess, this.from, "array", this.orginal_code)				
		}
		
	switch()	
		{
			if arrays_are_equal(read_process_memory(this.hprocess, this.from, "array"
												   ,this.orginal_code._MaxIndex()), this.orginal_code)
				{
					if this._enable()
						return 64
					else return 16
				}	
			else if arrays_are_equal(read_process_memory(this.hprocess, this.from, "array"
														,this.jump_instruction._MaxIndex()), this.jump_instruction)	
				{
					if this._disable()
						return -1
					else return 16
				}	
		}	

	__Delete()	{
		this._disable()
		return dllcall("VirtualFreeEx", uint, this.hprocess, uint, this.to, uint, 0, uint, (MEM_RELEASE := 0x8000) )
	}


}

GetSystemInfo()
{
	varsetcapacity(lpSystemInfo, 36)
	dllcall("GetSystemInfo", "Int", &lpSystemInfo)
	MinimumApplicationAddres := numget(lpSystemInfo, 8, "int32")
	MaximumApplicationAddress := numget(lpSystemInfo, 12, "int32")
	fileappend, % MinimumApplicationAddres	" " MaximumApplicationAddress "`n", *
	return [MinimumApplicationAddres, MaximumApplicationAddress] 
}

VirtualQueryEx(hprocess, base_adress)
 {
	varsetcapacity(MEMORY_BASIC_INFORMATION, 28)
	success := dllcall("VirtualQueryEx"
				  ,"Int", hProcess
				  ,"Int", base_adress
				  ,"Ptr", &MEMORY_BASIC_INFORMATION
				  ,"Int", 28)
				  
	if not success
		return False
		
	;fileappend, % numget(MEMORY_BASIC_INFORMATION, 4, "int32") "`n", *
	;fileappend, % read_process_memory(hprocess, numget(MEMORY_BASIC_INFORMATION, 4, "int32"), "int") "`n", *
	return [numget(MEMORY_BASIC_INFORMATION, 0, "int32"), numget(MEMORY_BASIC_INFORMATION, 8, "int32")
		   ,numget(MEMORY_BASIC_INFORMATION, 12, "int32"), numget(MEMORY_BASIC_INFORMATION, 20, "int32")]
}	

class MemoryPage
	{
		__New(Base_, Alocation, Size)
			{
				this.base_ := base_
				this.Size := Size
				this.Alocation :=  Alocation
			}
	}		

find_memory_pages(hprocess)
{
	r := GetSystemInfo()
	Min := r[1]
	Max := r[2]
	
	pages := []
	result := True	
	while result
		{
			result :=  VirtualQueryEx(hprocess, Min)
			if (result[4] && 0x10) and (result[2] && 0x10) ; PAGE_EXECUTE
				pages.insert(new MemoryPaGe(result[1], result[4], result[3]))
			Min := result[1] + result[3]
		}	
	for k, v in pages
		{
			Execute := v.Alocation && 0x10
			;fileappend, % "BaseAdress:" v.base_ " Size:" v.size " Execute:" Execute "`n", *
		}	
	return pages
}

arrays_are_equal(a1, a2)
{
	format := A_FormatInteger
	setformat, integer, H
	if not (isobject(a1) or not isobject(a2)) {
		setformat, integer, %format%
		return 0
		}
			
	for k, v in a1
		{
			if a2[k] is not number {
				setformat, integer, %format%
				return 0
				}
			if (v != a2[k]) {
				setformat, integer, %format%
				return 0
				}
		}

	for k, v in a1
		fileappend, % "arrays " v " " a2[k] "`n", *
	
	setformat, integer, %format%
	return 1	
}

get_process_ID(_process)
{
	for k, v in get_process_list() {
			if (v.name = _process)
				return v.ID	
		}	
}

class MODULEENTRY32
{
	__New(BaseAddr, BaseSize, Name)
		{
			this.BaseAddr := BaseAddr
			this.BaseSize := BaseSize 
			this.Name := Name			
		}	
}	

get_modules_list(proccessID)
{
	snapshot_handle := 24 ;ERROR_BAD_LENGTH   
	while snapshot_handle = 24
		snapshot_handle := dllcall("CreateToolhelp32Snapshot"
								  ,"int", (TH32CS_SNAPMODULE := 0x00000008)
								  ,"int", proccessID)
	
	modules := []
	varsetcapacity(module_info, 1061 , 0),	numput(1061, module_info, 0, "Int")
	success := dllcall("Module32First", "Ptr", snapshot_handle, "Ptr", &module_info)
	modules.insert(new MODULEENTRY32(numget(module_info, 20, "UInt")
									,numget(module_info, 24, "UInt")
									,strget(&module_info+32, 512, "UTF-8")))
									
	fileappend, % strget(module_info+32, 512, "UTF-8"), *
	while success
		{
			varsetcapacity(module_info, 2061 , 0),	numput(1061, module_info, 0, "Int")
			success := dllcall("Module32Next", "Ptr", snapshot_handle, "Ptr", &module_info)
			modules.insert(new MODULEENTRY32(numget(module_info, 20, "UInt")
									        ,numget(module_info, 24, "UInt")
											,strget(&module_info+32, 512, "UTF-8"))) 
		}	
	return modules
}

find_pages_in_range(hprocess, start, end_)
{
	pages := []
	for k, v in find_memory_pages(hprocess)
		{
			fileappend, % "BaseAdress:" v.base_ " Size:" v.size " ", *
			if  ((v.base_ >= start) and (v.base_ + v.size <= end_))
				{
					fileappend, in range `n, *	
					pages.insert(v)
				}	
			else fileappend, not in range `n, *				
		}	
	return pages		
}	

read_process_struct(hProcess, byref struct, size, adress)
{	
	varsetcapacity(bytes_read, 4, 0)
	r := dllcall("ReadProcessMemory"
				,"Int", hProcess
				,"Ptr", adress
				,"Ptr", &struct
				,"UInt", size
				,"Int", &bytes_read
				,"Uint")
				
	;fileappend, % A_lasterror " ", *	
	;varsetcapacity(buffer, 0, 0)	
	
	return numget(bytes_read, 0, "int")
}	

find_module(name, id_process)
{
	for k, v in get_modules_list(id_process)
		{
			if (name = v.name)
				return v
		}		
}	

aobscan(hprocess, id_process, module_name, bytes, dllname = "peixoto.dll", range_ = 1)
{
	static sigscan
	if not sigscan
		{
			if not DllCall("LoadLibrary", "Str", dllname, "Ptr")
				return "L " . dllname
			
			dllModule := DllCall("GetModuleHandle", "wstr", dllname) 
			if not dllModule
				return "G " . dllname
			
			sigscan := dllCall("GetProcAddress", "int", dllModule, "astr", "sigscan")			
			if not sigscan
				return "S " . A_lasterror 
		}	
	
	module := find_module(module_name, id_process)
	if not module
		return "M " module_name
	
	if (range_ = 1)
		pages := find_pages_in_range(hprocess, module.BaseAddr, module.BaseAddr + module.BaseSize)	
	else if (range_ = 0)
		pages := find_memory_pages(hprocess)
	else if (range_ > 1)
		pages := find_pages_in_range(hprocess, range_, 0xffffffff)	
	
	if not isobject(pages)
		return "P " range_
	
	for k, v in pages
		{
			varsetcapacity(pagemem, v.size)
			varsetcapacity(buffer, bytes._maxindex(), 0)
			loop, % bytes._MaxIndex()
				Numput(bytes[A_index], buffer, A_index - 1, "UChar")
			r := read_process_struct(hProcess, pagemem,  v.size, v.base_)	
			  	
			s := dllcall(sigscan
						,"ptr", &pagemem, "int", v.size
						,"ptr", &buffer, "int", bytes._maxindex())					
						
			varsetcapacity(pagemem, 0)
			varsetcapacity(buffer, 0)
			
			if (s > 0)			
					return v.base_ + s
									
		}	
	
	return
}	

CreateIdleProcess(Target, workingdir = "", args = "", noWindow = "")
{	
	varsetcapacity(SECURITY_ATTRIBUTES, 12)
	numput(12, SECURITY_ATTRIBUTES, 0, "Int") ; nlenth
    numput(1, SECURITY_ATTRIBUTES, 8, "uInt")  ; BOOL  bInheritHandle 
	
	varsetcapacity(THREAD_SECURITY_ATTRIBUTES, 12)
	numput(12, THREAD_SECURITY_ATTRIBUTES, 0, "Int") ; nlenth
	numput(1, THREAD_SECURITY_ATTRIBUTES, 8, "Int")  ; BOOL  bInheritHandle 
	
	varsetcapacity(STARTUPINFO, 68) 
	numput(68, STARTUPINFO, 0 , "uInt") ; cb	
	
    varsetcapacity(PROCESS_INFORMATION, 16) 
   
    if not workingdir
		{
			SplitPath, Target, OutFileName, OutDir
			if not OutDir
				workingdir := A_WorkingDir 
			else workingdir := OutDir
		}	
		
	flags := (CREATE_SUSPENDED := 0x00000004)
	if noWindow
		flags |= (CREATE_NO_WINDOW := 0x08000000)
				
	r := dllcall("CreateProcess"
	  ,"str", Target
	  ,"str", args
	  ,"Ptr", &SECURITY_ATTRIBUTES 
	  ,"Ptr", &THREAD_SECURITY_ATTRIBUTES    	;LPSECURITY_ATTRIBUTES lpThreadAttributes,
	  ,"uInt", 1    							;BOOL bInheritHandles,
	  ,"Int", flags                             ;DWORD dwCreationFlags,
	  ,"Ptr", 0     							;LPVOID lpEnvironment,
	  ,"Str", workingdir        				;LPCTSTR lpCurrentDirectory,
	  ,"Ptr", &STARTUPINFO          			;LPSTARTUPINFO lpStartupInfo,
	  ,"Ptr", &PROCESS_INFORMATION)
  
    if (r = 0)	{	
		return A_lasterror
		}	
		
	else {			
		pInfo := {}	
		pInfo.hProcess := numget(PROCESS_INFORMATION, 0, "UInt")
		pInfo.hThread := numget(PROCESS_INFORMATION, 4, "UInt")
		pInfo.Process_id := numget(PROCESS_INFORMATION, 8, "UInt")
		pInfo.hhread_id := numget(PROCESS_INFORMATION, 12 "UInt")	    
		return pInfo
	}	
}	

ResumeProcess(hThread){
		return dllcall("ResumeThread", uint, hThread)
	}

BlockNewProcess(parent_id, child_list)
{
	if not isobject(child_list)
		child_list := [child_list]
	
	for k, v in child_list
	{
		h_app := ""
		while not h_app
			{
				process, exist, %parent_id%
				if not errorlevel
					return
				
				h_app := get_process_handle(v, (PROCESS_CREATE_THREAD := 0x0002)
										   | (PROCESS_QUERY_INFORMATION := 0x0400) 
										   | (PROCESS_VM_OPERATION := 0x0008) 
								           | (PROCESS_VM_READ := 0x0010) 
										   | (PROCESS_VM_WRITE := 0x0020))	
				sleep, 100									   
			}
		dllcallEx(h_app, "Kernel32.dll", "ExitProcess", "0")		
	}
}	

memlib_Number2String(num, typ, reverse = False)
{
	format := A_FormatInteger
	VarSetCapacity(var, 4)
	numput(num, var, typ)
	setformat, integer, h
	string :=
	if not reverse
	{
		loop, 4
			string .= numget(var, A_index-1, "uchar") " "
	}
	else 
	{
		loop, 4
			string .= numget(var, 4-A_index, "uchar") " "
	}
	setformat, integer, %format%
	return string		
}	

memlib_String2ByteArray(string)
{
	ret := []
	loop, parse, string, %A_space%
		{
			if instr(A_loopfield, "0x")
				field := A_loopfield
			else field := "0x" A_loopfield
			ret.insert(field + 0)
		}		
	return ret	
}	

/*
Functions to get info about a module image(in disk, not in process memory space)
so not really of any use
*/


GetModuleFileNameEx(hProcess, hModule)
{
	varsetcapacity(name, 1024)	
	r := DllCall( "psapi.dll\GetModuleFileNameEx"
				,"Int", hprocess 
				,"Int", hModule
				,"str", name
				,"uint", 512)

	
	SplitPath, name, FileName
	;fileappend, % FileName "`n", *
	return FileName 
}

EnumProcessModules(hprocess)
{
	VarSetCapacity(module, 128)
	VarSetCapacity(required_size, 4, 0)
	r := dllcall("psapi.dll\EnumProcessModules" 
				,"int", hProcess
				,"Uint", &module
				,"Int", 1024
				,"Uint*", required_size)
				
	if 	(size < required_size)
		{
			VarSetCapacity(module, required_size)
			VarSetCapacity(required_size, 4, 0)
			r := dllcall("psapi.dll\EnumProcessModules" 
						,"int", hProcess
						,"Uint", &module
						,"Int", 1024
						,"Uint*", required_size)
		}				
			
	;fileappend, % errorlevel "`n", *
	;fileappend, % r "`n", *
	
	n := 0
	modules := []
	while not (n > required_size)
		{
			h_module := numget(module, n, "int")
			;fileappend, % n ": " h_module GetModuleFileNameEx(hprocess, h_module) "`n", *
			modules.insert(h_module)
			n += 4
		}	
	;fileappend, % required_size "`n", *
	return modules	
}	

Get_Module_handle(hprocess, module)
{
	modules := EnumProcessModules(hprocess)	
	for k, v in modules
		{
			if GetModuleFileNameEx(hprocess, v) = module
				return v
		}				
}	

Get_module_memory_space(hprocess, module)
{
	hModule := Get_Module_handle(hprocess, module)
	VarSetCapacity(lpmodinfo, 12)
	
	dllcall("psapi.dll\GetModuleInformation"
			,"int", hProcess
			,"Int", hModule
			,"Int",&lpmodinfo
			,"int", 12)
	
	lpBaseOfDll := numget(lpmodinfo, 0, int)
    SizeOfImage := numget(lpmodinfo, 4, int)
    EntryPoint := numget(lpmodinfo, 8, int)
	;fileappend, % lpBaseOfDll " "	SizeOfImage	" " EntryPoint, *
}	
