class typeArr {
	;<<typeArr>>
	; n, number of elements
	; type, type of the elements. Can be any of the regular "NumPut"-types, eg, "Uint", "Char"...
	; sizeOfType, the size in byte of the specified type, eg, Int -> 4
	;
	
	len:=0	; Number of elements in the array
	__new(n,type:="Ptr"){
		; Default size is A_PtrSize
		local sizeOf
		sizeOf:=xlib.type.sizeof(type)
		this.maxLen:=n						
		this.type:=type						
		this.size:=sizeOf
		this.totalSize:=n*sizeOf		; Total size of the array.
		this.ptr:=xlib.mem.GlobalAlloc(this.totalSize)
		
	}
	push(val){
		if this.outOfBounds(this.len+1,1,this.maxLen)
			xlib.exception(this.__Class . " failed @ push(), reason: Out of bounds, got: " . this.len+1 . ", expected value in range: [" . 1 . "," . this.maxLen "].",,-1,"Warn", "Exit")
		++this.len
		NumPut(val, this.ptr, (this.len-1)*this.size, this.type)
		
		return this.len
	}
	set(ind,val){
		; set the value at ind.
		if this.outOfBounds(ind,1,this.len)
			xlib.exception(this.__Class . " failed @ set()," 
										. (this.len ?  " reason: Out of bounds, got: " ind ", expected value in range:  [" 1 "," this.len "]." 
													: " reason: length of array is 0."),,-1,"Warn", "Exit")
		return NumPut(val,this.ptr,(ind-1)*this.size,this.type)
	}
	get(ind){
		; Get the value at ind.
		if this.outOfBounds(ind,1,this.len)
			xlib.exception(this.__Class . " failed @ get()," 
										. (this.len ?  " reason: Out of bounds, got: " ind ", expected value in range:  [" 1 "," this.len "]." 
													: " reason: length of array is 0."),,-1,"Warn", "Exit")
		return NumGet(this.ptr,(ind-1)*this.size,this.type)
	}
	getValPtr(ind){
		; Get the pointer to the value at ind.
		if this.outOfBounds(ind,1,this.maxLen)
			xlib.exception(this.__Class . " failed @ getValPtr(), reason: Out of bounds, got: " ind ", expected value in range: [" 1 "," this.maxLen "].",,-1,"Warn", "Exit")
		return this.getArrPtr()+this.size*(ind-1)
	}
	getArrPtr(){
		return this.ptr
	}
	getLength(){
		return this.len
	}
	outOfBounds(x,lb,ub){
		return x<lb || x>ub
	}
	__Delete(){
		if isobject(xlib) && isobject(xlib.mem) ; in case we are exiting the application and xlib has be deleted.
			xlib.mem.globalFree(this.ptr)
	}
	
	_NewEnum(){
		return new xlib.typeArr.Enum(this)
	}
	class Enum{
		; Enum class for for-looping the ptrArr
		__new(ref){
			this.ref:=ref
			this.ind:=0
		}
		next(byref k,byref v){
			if ((++this.ind)>this.ref.getLength())
				return 0
			k:=this.ind
			v:=this.ref.get(k)
			return 1
		}
	}
}   