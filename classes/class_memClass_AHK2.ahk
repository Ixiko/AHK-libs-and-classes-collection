/* Memory Reader for AHK v2
Example:
	#include memClass.ahk
	#SingleInstance force
	
	cmd := new memClass(WinGetPID("Command Prompt"), "conhost.exe")
	cmd.listModules()
	
	msgbox(   cmd.modules[1].name 
			. " is loaded at " 
			. cmd.modules[1].baseadd  
			. " = " 
			. cmd.modules[1].baseadd + 0 )
			
	ptrBaseAdd := cmd.readNum(,,0x8be80, 0x158, 0x570, 0x20)
	while WinExist("ahk_pid " cmd.parentPID) { 
		curr1 := cmd.readNum(2, ptrBaseAdd, 0x18, 0xA) 
		curr2 := cmd.readNum(2, ptrBaseAdd, 0x20)
		curr := curr2 == 0 ? curr1 : curr2    
		ToolTip(   cmd.readStr( 11, "UTF-8", 0x7FF71125A5E0) "`n" 
				. "Current Line Number: " curr)
		sleep 100
	}
	
	^1::
		if cmd.suspended
			cmd.resume()
		else	
			cmd.suspend()
		return
*/

class memClass {
	modules:=[]
	suspended := false
	__New(pid, childName := "") {
		if childName
			for process in ComObjGet("winmgmts:").ExecQuery("SELECT * FROM Win32_Process WHERE Name = '" childName "'")
				if process.ParentProcessID == pid {
					pid:= process.ProcessID
					this.parentPID := process.ParentProcessID
				}	
						
		this.phandle := DllCall("OpenProcess", "UInt", 0xFFFF, "Char", 0, "UInt", pid, "Ptr")
		this._getModuleList()
		this.pid := pid
		return this
	}
	
	__Delete() {
		return DllCall("CloseHandle", "Ptr", this.phandle)
	}
	
	suspend() {
		this.suspended := true
		;return DllCall("DebugActiveProcess", "Ptr", this.phandle)
		return DllCall("ntdll\NtSuspendProcess", "Ptr", this.phandle)
	}
	
	resume() {
		this.suspended := false
		;return DllCall("DebugActiveProcessStop", "Ptr", this.phandle)
		return DllCall("ntdll\NtResumeProcess", "Ptr", this.phandle)
	}
	
	readstr(len, en:="utf-16", add:=-1, offsets*) {
		offsetsLen := offsets.length()
		if add == -1
			add := this.baseadd
		i := 1
		while i < offsetsLen {
			add:=this._readptr(add + offsets[i++])
		}
		if en = "utf-16"
			mul := 2
		else if en = "utf-8"
			mul := 1
		size := len * mul
		VarSetCapacity(mval, size)
		add += offsetsLen > 0 ? offsets[i] : 0 
		this._donothing(0)
		DllCall("ReadProcessMemory", "UInt", this.phandle, "Ptr", add, "Ptr", &mval, "UInt", size)
		return StrGet(&mval, len, en)
	}
	
	readnum(size:=8, add:=-1, offsets*) {
		offsetsLen := offsets.length()
		if add == -1
			add := this.baseadd
		i := 1
		while i < offsetsLen {
			add:=this._readptr(add + offsets[i++])
		}
		_type := {8:"Int64", 4:"UInt", 2:"UShort", 1:"UChar"}
		VarSetCapacity(mval, size, 0)
		add += offsetsLen > 0 ? offsets[i] : 0 

		this._donothing(0)
		DllCall("ReadProcessMemory", "UInt", this.phandle, "Ptr", add, "Ptr", &mval, "Uint", size)
		return NumGet(&mval, 0, _type[size])
	}
	
	listModules() {
		moduleList := GuiCreate(,"Module List => this.modules[i].(baseadd | name)")
		moduleList.SetFont("s10", "Consolas")
		moduleListEdit := moduleList.Add("Edit", "r25 w500 ReadOnly -Wrap", "")
		modSize := this.modules.Length()
		indexLen := StrLen(modSize)
		for key, val in this.modules {
			str := Format("{1:7} {2:14} : {3}", "[" key "]", val.baseadd, val.name)
			;s .= Format("|{:-10}|`r`n|{:10}|`r`n", "Left", "Right")
			moduleListEdit.Value := moduleListEdit.Value str (key == modSize ? "" : "`n")
		}
		moduleList.Show()
	}
	
	findPtr(ptr, startAdd := 0) {
		endAdd := 0x7fffffffffff
		add := startAdd
		result := this._readptr(add)
		i := 0
		while result != ptr and add + A_PtrSize <= endAdd {
			add := A_PtrSize * ++i
			result := this._readptr(add)
			
		}
		fileappend("[" i "] " add ":" result "`n", "*")
	}
	
	_readptr(add) {
		VarSetCapacity(mval, A_PtrSize, 0)
		this._donothing(0)
		DllCall("ReadProcessMemory", "UInt", this.phandle, "Ptr", add, "Ptr", &mval, "Uint", A_PtrSize)
		return NumGet(&mval, 0, A_PtrSize == 8 ? "Int64" : "UInt")
	}
		
	_getModuleList() {
		h_msvcrt := DllCall("LoadLibrary", "str", "msvcrt.dll") ; Preload dll
		h_psapi := DllCall("LoadLibrary", "str", "psapi.dll") ; Preload dll
		hm_list_size := 1024*8  ;make this larger than necessary
		VarSetCapacity( hm_list, hm_list_size, 0 )
		VarSetCapacity( hm_list_actual, A_PtrSize )
		;this._donothing(0)
		r := DllCall("psapi.dll\EnumProcessModules", "Ptr", this.phandle, "Ptr", &hm_list, "Ptr", hm_list_size, "Ptr*", hm_list_actual)
		
		i := 0
		while i < hm_list_actual//A_PtrSize {
			hwnd:=NumGet(&hm_list + A_PtrSize*i, "Ptr")
			VarSetCapacity(name, 512)
			len := DllCall("psapi.dll\GetModuleBaseName", "Ptr", this.phandle, "Ptr", hwnd, "Str", name, "UInt", 1024)
			this.modules[++i] := { "name":StrLower(name), "baseadd":"0x" StrUpper(this._convertDecToHex(hwnd))}
		}
		
		this.baseadd := this.modules[1].baseadd
		return r
	}
	
	_convertDecToHex(number) {
		static u := A_IsUnicode ? "_wcstoui64" : "_strtoui64"
		static v := A_IsUnicode ? "_i64tow"    : "_i64toa"
		
		VarSetCapacity(s, 65, 0)
		value := DllCall("msvcrt.dll\" u, "Str", number, "UInt", 0, "UInt", 10, "CDECL Int64")
		DllCall("msvcrt.dll\" v, "Int64", value, "Str", s, "UInt", 16, "CDECL")
		return s
	}
	
	_donothing(x) {	;somehow I need this dummy code to get ReadProcessMemory to work properly
		return x	;could this be a permission issue?
	}
}