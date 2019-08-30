class error {
	__new(msg:="",r:="",depth:=-1,output:="obj"){
		return this.exception(msg,r,depth,output)
	}
	exception(msg,r,depth,output){
		; Note: Removed critical here, because caught exceptions caused incorrect critical settings.
		; Could restore setting but doesn't seem to be worth the bother.
		msg.="`n`nErrorLevel: " . ErrorLevel . "`nLast error: " . this.formatLastError() . (IsObject(r) ? "`nFunction returned: " . r[1] : "`nNo return value specified.") . this.getCallStack()
		this.lastError:=Exception(msg,-abs(depth)-3) ; -3 to never show inside error class.
		if (output="string"){
			this.lastError :=	  "Error: " 	. this.lastError.Message 
								. "`n`nWhat: " 	. this.lastError.What 
								. "`n`nLine: " 	. this.lastError.Line 
								. "`n`nFile: " 	. this.lastError.File 
		}
		return this.lastError
	}
	formatLastError(msgn:=""){
		; Url:
		;	- https://msdn.microsoft.com/en-us/library/windows/desktop/ms679351(v=vs.85).aspx (FormatMessage function)
		; 
		local msg
		local lpBuffer:=0 ; avoids #warn all message. 
		static FORMAT_MESSAGE_ALLOCATE_BUFFER:=0x00000100
		static FORMAT_MESSAGE_FROM_SYSTEM:=0x00001000
		if (msgn="")
			msgn:=A_LastError
		DllCall("Kernel32.dll\FormatMessage", "Uint", FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_ALLOCATE_BUFFER, "Ptr", 0, "Uint",  msgn, "Uint", 0, "PtrP", lpBuffer,  "Uint", 0, "Ptr", 0, "Uint")
		msg:=StrGet(lpBuffer)
		if !DllCall("Kernel32.dll\HeapFree", "Ptr", DllCall("Kernel32.dll\GetProcessHeap","Ptr"), "Uint", 0, "Ptr", lpBuffer) ; If the function succeeds, the return value is nonzero.
			throw Exception("HeapFree failed.")
		return StrReplace(msg,"`r`n") . "  " . msgn . Format(" (0x{:04x})",msgn)
	}
	getCallStack(){
		; The goal was to make this as ugly as possible, mission completed.
		local c,o,h,k,v,str,e
		o:=[]
		h:=0
		while !(( e:=exception("",-5-abs(h)) ).What is 'number') 
			o.insertAt(1, e.What "`t`t" . e.line),h++
		str:="`n`nCallstack:`n"
		for k, v in o
			str.=k " " v "`n" 
		return str
	}
}
