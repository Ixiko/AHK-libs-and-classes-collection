; To do: allow eg, "int*" and add method deref(member)
; Primitive struct class.
; Specify size, eg, myStruct:= new struct(16,cleanUpFn,name)
; then build struct:
;					myStruct.build(	 ["type",value[,"memberName"]]
;									,["Uint",37, "theNumber"]
;									,["pad",A_PtrSize=4?0:4]
;									,["Ptr",0,"opt_ptr"])
;									,["Ptr",x, "thePointer"])
; Types are the usual numput/dllcall types, "ptr", "int" .... and "pad", to pad value bytes. Note: not "str". Todo, add type = "strbuf"
; Change member values, myStruct.Set("memberName", value)
; Retrieve member values, value := myStruct.Get("memberName")
; Free memory, myStruct:="" (if last reference is freed.)
; Before memory is freed, the user defined clean up function is called with a reference to the the struct. For manual clean up of members or other things.
;
class struct extends xlib.bases.cleanupBase {
	
	members := {}
	nMembers:=0
	__new(size ,cleanUpFn := "",name := ""){
		local
		global xlib
		this.setCleanUpFunction(cleanUpFn)	; see xlib.bases.cleanupBase
		this.name:=name 																			; Only for db purposes, you'll get the name in the error msg.									
		this.ptr:=xlib.mem.globalAlloc(size)
		this.maxSize:=size
		this.offset:=0
	}
	build(members*){
		; members is an array of member arrays, [type,val,membername:=""]
		local k, member
		for k, member in members
			this.add(member*)
	}
	add(type, byref val, memberName := ""){
		; val is byref to avoid string copies, it is not modified.
		local
		global xlib
		if (type = "pad"){
			this.offset += val
			return
		}
		++this.nMembers
		size := xlib.type.sizeOf(type)
		this.offset += size	; Add to offset for error check
		
		memberName := memberName !== "" ? memberName : this.nMembers
		if instr(type, 'str') {
			; 'str' members are a copied to a new buffer, for convenience. Use '"ptr", &var' to avoid string copies
			; xstr*, xstrp unsupported.
			if instr(type, '*') || instr(type, 'p')
				xlib.exception('Unsupported type: ' type)
			; get encoding
			if !enc := type = 'str' ? (a_isunicode 	? 'UTF-16' 
													: 'cp0') 
									: (type = 'wstr' 	?  'UTF-16' 
														: (type = 'astr' ? 'cp0' : 0) )
				xlib.exception('Unsupported type: ' type)
			strBuf := new xlib.strbuf(strlen(val), enc)			; allocates string buffer.
			strBuf.val := val									; write string to buffer.
			typeObj := strBuf	; for clarity
		} else {
			typeObj := new xlib[ type ](val, this.ptr+this.offset-size)	; Subtract size because size was already added for error check.
		}
		this.members[this.nMembers] := this.members[memberName] := {offset:this.offset, typeObj:typeObj}	; members can be access via name or number
		
		return
	}
	get(memberName){
		local member := this.members[memberName]
		if member == ''
			xlib.exception("Struct " this.name " has no member " memberName ".")
		return member.typeObj.val
	}
	set(memberName, value){
		local member := this.members[memberName]
		if member == ''
			xlib.exception("Struct " this.name " has no member " memberName ".")
		member.typeObj.val := value
		return 
	}
	o := 0
	offset {
		set {
			if value > this.maxSize
				xlib.exception("struct " this.name " has exceeded maximum size " this.maxSize " by " value-this.maxSize " bytes.")
			return this.o := value
		} get {
			return this.o
		}
	}
	pointer {
		set {
			xlib.exception("Access denied.")
		} get {
			return this.ptr
		}
	}
	getMemberPointer(memberName){
		local member := this.members[memberName]
		if member == ''
			xlib.exception("Struct " this.name " has no member " memberName ".")
		return member.typeObj.Pointer
	}
	cleanUp(){	; called from __delete (xlib.bases.cleanUpBase)
		if isobject(xlib) && isobject(xlib.mem)
			xlib.mem.globalFree(this.ptr)
	}
}