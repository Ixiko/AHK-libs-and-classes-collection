; Available types:
;	UInt, Int, Int64, Short, UShort, Char, UChar, Double, Float, Ptr or UPtr, strbuf
; example:
; myChar:= new char(37)
; Specify a memory address for ptr for custom memory allocation, will not be free automatically. "Caller" frees.
; Otherwise, memory is allocated and freed when last reference to the type object is released, eg, myChar:=""

; todo: Add clean up function, see struct.

;<< float >>
class float extends xlib.type {
	min:="-inf"
	max:="inf"
	__new(val,ptr:="",type:="float") {
		base.__new(val,type,ptr)
	}
	outOfBounds(val) {
		local strVal := string(val)
		return InStr(strVal,"inf") || InStr(strVal,"nan")
	}
	outOfBoundsException(val) {
		throw Exception("Value out of bounds: " val)
	}
}
;<< double >>
class double extends xlib.float {
	__new(val,ptr:="") {
		base.__new(val,ptr,"double")
	}
}
;<< uptr >>
class uptr extends xlib.type {
	min:=A_PtrSize=4 ? 			 0 : -9223372036854775808
	max:=A_PtrSize=4 ?  4294967296 :  9223372036854775807
	__new(val,ptr:="") {
		base.__new(val,"Uptr",ptr)
	}
}
;<< ptr >>
class ptr extends xlib.type {
	min:=A_PtrSize=4 ? -2147483648 : -9223372036854775808
	max:=A_PtrSize=4 ?  2147483647 :  9223372036854775807
	__new(val,ptr:="") {
		base.__new(val,"Ptr",ptr)
	}
}
;<< int64 >>
class int64 extends xlib.type {
	min:=-9223372036854775808
	max:=9223372036854775807
	__new(val,ptr:="") {
		base.__new(val,"int64",ptr)
	}
}
;<< uint >>
class uint extends xlib.type {
	min:=0
	max:=4294967295
	__new(val,ptr:="") {
		base.__new(val,"Uint",ptr)
	}
}
;<< int >>
class int extends xlib.type {
	min:=-2147483648
	max:=2147483647
	__new(val,ptr:="") {
		base.__new(val,"Int",ptr)
	}
}
;<< ushort >>
class ushort extends xlib.type {
	min:=0
	max:=65535
	__new(val,ptr:="") {
		base.__new(val,"Ushort",ptr)
	}
}
;<< short >>
class short extends xlib.type {
	min:=-32768
	max:=32767
	__new(val,ptr:="") {
		base.__new(val,"Short",ptr)
	}
}
;<< uchar >>
class uchar extends xlib.type {
	min:=0
	max:=255
	__new(val,ptr:="") {
		base.__new(val,"Uchar",ptr)
	}
}
;<< char >>
class char extends xlib.type {
	min := -128
	max := 127
	__new(val, ptr := "") {
		base.__new(val, "Char", ptr)
	}
}
;<< strbuf >>
class strbuf extends xlib.type {
	; specify len, the maximum string length that the buffer can hold for the specified encoding, enc. Null terminator excluded.
	__new(len, enc := "") {
		this.len := len
		this.size := (len+1)*(enc="utf-16" || enc="cp1200" ? 2 : 1) ; Deduced from the manual. 
		this.ptr := xlib.mem.globalAlloc(this.size)
		this.enc := enc
	}
	str {
		get {
			return StrGet(this.ptr, this.enc)
		} set {
			if this.outOfBounds(value)
				this.outOfBoundsException(value)
			StrPut(value, this.ptr, this.enc)
		}
	}
	val {
		set {
			this.str := value
		} get {
			return this.str
		}
	}
	outOfBoundsException(value) {
		xlib.exception("String to long: " strlen(value) ". Maximum length: " this.len,,-2)
	}
	outOfBounds(val) {
		return (StrLen(val)+1) * (this.enc="utf-16" || this.enc="cp1200" ? 2 : 1)  > this.size
	}
}
;<< type >>
class type extends xlib.bases.cleanupBase {
	__new(val,type,ptr:="") {
		if !(this.size:=this.sizeof(type))
			xlib.exception("Invalid type: " type)
		this.ptr:= ptr ? ptr : xlib.mem.globalAlloc(this.size)
		this.isStructMember := ptr ? true : false	; Structs free their members.
		this.type:=type
		this.val:=val
	}
	outOfBounds(num) {
		return num<this.min || num>this.max
	}
	cleanUp(){ ; called "from" xlib.bases.cleanupBase.__Delete
		if !this.isStructMember && isobject(xlib) && isobject(xlib.mem)	; Structs free their members.
			xlib.mem.globalFree(this.ptr)
	}
	pointer {	; The pointer to the memory space
		set {
			xlib.exception("Access denied.",,-2)
		} get {
			return this.ptr
		}
	}
	; Max / min values of the type.
	max {	
		set {
			this.ub:=value
		} get {
			if (this.ub="")
				xlib.exception("Maximum value not defined for: " this.type)
			return this.ub
		}
	}
	min {
		set {
			this.lb:=value
		} get {
			if (this.lb="")
				xlib.exception("Minimum value not defined for: " this.type)
			return this.lb
		}
	}
	val { ; The value. Get it by myRef.val, set via myRef.val:=...
		set {
			if this.outOfBounds(value)
				this.outOfBoundsException(value)
			return NumPut(value,this.ptr,this.type)
		} get {
			local value:=NumGet(this.ptr,this.type)
			if this.outOfBounds(value)
				this.outOfBoundsException(value)
			return value
		}
	}
	outOfBoundsException(val) { ; Standart error message
		xlib.Exception("Value out of bounds: " val ". Expected value in range [" this.min "," this.max "]")
	}
	sizeof(type) {
		static sizeMap := {	 Ptr : A_PtrSize, Uptr : A_PtrSize, Uint : 4, Int : 4, Int64 : 8, Uint64 : 8
							,Ushort : 2, Short : 2, Uchar : 1, Char : 1, Float : 4, Double : 8}
		local
		global xlib
		if instr(type, 'str')
			return a_ptrsize
		ec := substr(type, -1) 		; end char.
		if ec == "*" || ec = "P" 	; type* or typeP
			return a_ptrsize
		if !sizeMap.haskey(type)
			xlib.exception("Invalid type: " type ".")
		return sizeMap[type]
	}	
}
;<< FILETIME >>
class FILETIME {
	; Very much unverified
	; Url:
	;	- https://https://msdn.microsoft.com/en-us/library/windows/desktop/ms724284(v=vs.85).aspx (FILETIME structure)
	/*
	typedef struct _FILETIME {
		DWORD dwLowDateTime;
		DWORD dwHighDateTime;
	} FILETIME, *PFILETIME;
	*/
	__new(time:=0,low:="",high:="") {
		this.mem:=xlib.mem.globalAlloc(8)
		if (low!="" && high!="") {
			this.dwLowDateTime:=low
			this.dwHighDateTime:=high
		} else if (time!="") {
			this.time:=time
		} else {
			xlib.exception("FILETIME error, invalid input, time: " time ", low: " low ", high: " high ".")
		}
	}
	pointer {
		get { 
			return this.mem
		}
	}
	time {
		set {
			this.dwLowDateTime	:= value << 32 >> 32
			this.dwHighDateTime	:= value >> 32 		
		} get {
			return NumGet(this.mem, 0, "Int64")
		}
	}
	low { ; cannot remember full names
		set {
			this.dwLowDateTime:=value
		} get {
			return this.dwLowDateTime
		}
	}
	high {
		set {
			this.dwHighDateTime:=value
		} get {
			return this.dwHighDateTime
		}
	}
	dwLowDateTime {	; "full names"
		set {
			NumPut(value,this.mem,0,"Uint")
			return 
		} get {
			return NumGet(this.mem,0,"Uint")
		}
	}
	dwHighDateTime {
		set {
			NumPut(value,this.mem,4,"Uint")
			return 
		} get {
			return NumGet(this.mem,4,"Uint")
		}
	}
	__Delete() {
		xlib.mem.globalFree(this.mem)
	}
	; Misc, db purposes
	systemTimeToFileTime(lpSystemTime, ByRef lpFileTime) {
		if !DllCall("Kernel32.dll\SystemTimeToFileTime", "Ptr", lpSystemTime, "Int64P", lpFileTime)
			xlib.exception("SystemTimeToFileTime failed")
	}
	GetSystemTime(ByRef st) {
		VarSetCapacity(st,16,0)
		DllCall("Kernel32.dll\GetSystemTime", "Ptr", &st)
	}
}