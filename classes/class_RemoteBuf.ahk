Class _RemoteBuf {
	var pid:=0,bufAdr:=0,size:=0,hProc:=0,buffer:=0,ptr:=0,Encoding:="CP0"
	__New(hwnd=0,size=0){
		this.size:=size
		If !hwnd
			return
		this.Open(size,hwnd)
	}
	__Delete(){
		static MEM_RELEASE:=0x8000
		If !this.hProc
			Return
		If this.bufAdr
			If !DllCall("VirtualFreeEx","uint",this.hProc,"uint",this.bufAdr,"uint",0,"uint",MEM_RELEASE)
				return DllCall("MessageBox","PTR",0,"Str","Unable to free memory (" A_LastError ")","Str","OpenProcess Failed","UInt",0)
		DllCall( "CloseHandle", "uint", this.hProc)
	}
	Open(size="",hwnd=""){
		static MEM_COMMIT:=0x1000,PAGE_READWRITE:=4,MEM_RELEASE:=0x8000
		If (!this.hProc||hwnd) {
			If this.bufAdr
				DllCall("VirtualFreeEx","uint",this.hProc,"uint",this.bufAdr,"uint",0,"uint",MEM_RELEASE)
			If this.hProc
				DllCall( "CloseHandle", "uint", this.hProc)
			DetectHidden:=A_DetectHiddenWindows
			DetectHiddenWindows,On
			WinGet, pid, PID,% "ahk_id " (hwnd?hwnd:this.hwnd)
			DetectHiddenWindows % DetectHidden
			If !this.hProc:=DllCall("OpenProcess","uint",0x38,"int",0,"uint",pid) ;0x38 = PROCESS_VM_OPERATION | PROCESS_VM_READ | PROCESS_VM_WRITE
				return DllCall("MessageBox","PTR",0,"Str","Unable to open process (" A_LastError ")","Str","OpenProcess Failed","UInt",0)
		}
		If (size<>"")
			this.size:=size
		If this.bufAdr
			DllCall("VirtualFreeEx","uint",this.hProc,"uint",this.bufAdr,"uint",0,"uint",MEM_RELEASE)
		If size
			If !this.bufAdr := DllCall("VirtualAllocEx","uint",this.hProc,"uint",0,"uint",size,"uint",MEM_COMMIT,"uint",PAGE_READWRITE)
				return DllCall("MessageBox","PTR",0,"Str","Unable to allocate memory (" A_LastError ")","Str","OpenProcess Failed","UInt",0),this.hProc:=0
		Return size
	}
	Read(size=0,offset=0){
		If !this.hProc
			return DllCall("MessageBox","PTR",0,"Str","Invalid remote buffer handle","Str","Handle is NULL","UInt",0)
		If (offset>this.size)
			DllCall("MessageBox","PTR",0,"Str","Offset (" offset ") is bigger then size (" this.size ")","Str","Offset bigger than size","UInt",0)
		this.SetCapacity("buffer",size?size:this.size)
		return DllCall("ReadProcessMemory","uint",this.hProc,"uint",this.bufAdr+offset,"uint",this.ptr:=this.GetAddress("buffer"),"uint",(size?size:this.size)+1,"uint",0)
	}
	Write(value,offset=0,CP=""){
		static empty:=""
		If !this.hProc
			return DllCall("MessageBox","PTR",0,"Str","Invalid remote buffer handle","Str","Handle is NULL","UInt",0)
		If (offset>this.size)
			return DllCall("MessageBox","PTR",0,"Str","Offset (" offset ") is larger then size (" this.size ")","Str","Offset bigger than size","UInt",0)
		If (value=""){
			return DllCall("WriteProcessMemory","uint",this.hProc,"uint",this.bufAdr+offset,"uint",&empty,"uint",4,"uint",0)
		} else {
			If (this.size<Strlen(value)*2)
				this.Open(StrLen(value)*2)
			this.SetCapacity("buffer",this.size),StrPut(value,this.ptr:=this.GetAddress("buffer"),CP?CP:this.Encoding)
		}
		return DllCall("WriteProcessMemory","uint",this.hProc,"uint",this.bufAdr+offset,"uint",this.ptr,"uint",(StrLen(value)+1)*((CP="CP0"||this.Encoding="CP0")||CP=""?2:4),"uint",0)
	}
	NumPut(value,offset=0,Type="UInt"){
		static empty:=""
		If !this.hProc
			return DllCall("MessageBox","PTR",0,"Str","Invalid remote buffer handle","Str","Handle is NULL","UInt",0)
		If (offset>this.size)
			return DllCall("MessageBox","PTR",0,"Str","Offset (" offset ") is larger then size (" this.size ")","Str","Offset bigger than size","UInt",0)
		If (value=""){
			return DllCall("WriteProcessMemory","uint",this.hProc,"uint",this.bufAdr+offset,"uint",&empty,"uint",A_PtrSize,"uint",0)
		} else {
			If (this.size<Strlen(value)*2)
				this.Open(StrLen(value)*2)
			this.SetCapacity("buffer",this.size),NumPut(value,this.ptr:=this.GetAddress("buffer"),0,Type)
		}
		return DllCall("WriteProcessMemory","uint",this.hProc,"uint",this.bufAdr+offset,"uint",this.ptr,"uint",Type="int64"||(Type="PTR"&&A_PtrSize=8)?8:4,"uint",0)
	}
}