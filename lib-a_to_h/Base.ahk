class IUnknown
{
  __new(p=0){
		if (this.__:=p)
			this._v:=NumGet(p+0)
		else return
	}
	__call(aName,aParam*){
		if aName is Integer
			if this._i.HasKey(aName)
				return this[this._i[aName]](aParam*)
	}
	__get(aName){
		if this._i.haskey(aName)
			return this[this._i[aName]]()
		else return this[aName]()
	}
	__delete(){
		ObjRelease(this.__)
	}
	vt(n){
		return NumGet(this._v+n*A_PtrSize)
	}
	query(iid=0){
		if iid
			ComObjQuery(this.__,iid)
		else return ComObjQuery(this.__,this.iid)
	}
}

;;;;;;;;;;;;;;;;;;;;
;;Structed Storage;;
;;;;;;;;;;;;;;;;;;;;

class IStream extends IUnknown
{
	Read(pv,cb){
	_Error(DllCall(this.vt(3),"ptr",this.__,"ptr",pv,"uint",cb,"uint*",pcbRead),"Read")
	return pcbRead
	}

	Write(pv,cb){
	_Error(DllCall(this.vt(4),"ptr",this.__,"ptr",pv,"uint",cb,"uint*",pcbWritten),"Write")
	return pcbWritten
	}
	
	Seek(dlibMove,dwOrigin){
	_Error(DllCall(this.vt(5),"ptr",this.__,"uint64",dlibMove,"uint",dwOrigin,"uint64*",plibNewPosition),"Seek")
	return plibNewPosition
	}

	SetSize(libNewSize){
	return _Error(DllCall(this.vt(6),"ptr",this.__,"uint64",libNewSize),"SetSize")
	}

	CopyTo(pstm,cb){
	_Error(DllCall(this.vt(7),"ptr",this.__,"ptr",pstm,"uint64",cb,"uint64*",pcbRead,"uint64*",pcbWritten),"CopyTo")
	return [pcbRead,pcbWritten]
	}

	Commit(grfCommitFlags){
	return _Error(DllCall(this.vt(8),"ptr",this.__,"int",grfCommitFlags),"Commit")
	}

	Revert(){
	return _Error(DllCall(this.vt(9),"ptr",this.__),"Revert")
	}

	LockRegion(libOffset,cb,dwLockType){
	return _Error(DllCall(this.vt(10),"ptr",this.__,"uint64",libOffset,"uint64",cb,"uint",dwLockType),"LockRegion")
	}

	UnlockRegion(libOffset,cb,dwLockType){
	return _Error(DllCall(this.vt(11),"ptr",this.__,"uint64",libOffset,"uint64",cb,"uint",dwLockType),"UnlockRegion")
	}

	Stat(pstatstg,grfStatFlag){
	return _Error(DllCall(this.vt(12),"ptr",this.__,"ptr",pstatstg,"uint",grfStatFlag),"Stat")
	}

	Clone(){
	_Error(DllCall(this.vt(13),"ptr",this.__,"ptr*",ppstm),"Clone")
	return new IStream(ppstm)
	}
}

;;;;;;;;;;;;;;;
;;Fundamental;;
;;;;;;;;;;;;;;;

class IEnumUnknown extends IUnknown
{
	; Retrieves the specified number of items in the enumeration sequence.
	Next(celt,ByRef rgelt){ ; not completed
	_Error(DllCall(NumGet(this.vt+3*A_PtrSize),"ptr",this.__,"uint",celt,"ptr",rgelt,"uint*",pceltFetched),"Next")
	return pceltFetched
	}
	
	; Skips over the specified number of items in the enumeration sequence.
	Skip(celt){
	return _Error(DllCall(NumGet(this.vt+4*A_PtrSize),"ptr",this.__,"uint",celt),"Skip")
	}

	; Resets the enumeration sequence to the beginning.
	Reset(){
	return _Error(DllCall(NumGet(this.vt+5*A_PtrSize),"ptr",this.__),"Reset")
	}

	; Creates a new enumerator that contains the same enumeration state as the current one.
	; This method makes it possible to record a point in the enumeration sequence in order to return to that point at a later time. The caller must release this new enumerator separately from the first enumerator.
	Clone(){
	_Error(DllCall(NumGet(this.vt+6*A_PtrSize),"ptr",this.__,"ptr*",ppenum),"Clone")
	return new IEnumUnknown(ppenum)
	}
}

class IEnumString extends IUnknown
{
	Next(celt,ByRef rgelt){ ; not completed
	_Error(DllCall(NumGet(this.vt+3*A_PtrSize),"ptr",this.__,"uint",celt,"ptr",rgelt,"uint*",pceltFetched),"Next")
	return pceltFetched
	}
	Skip(celt){
	return _Error(DllCall(NumGet(this.vt+4*A_PtrSize),"ptr",this.__,"uint",celt),"Skip")
	}
	Reset(){
	return _Error(DllCall(NumGet(this.vt+5*A_PtrSize),"ptr",this.__),"Reset")
	}
	Clone(){
	_Error(DllCall(NumGet(this.vt+6*A_PtrSize),"ptr",this.__,"ptr*",ppenum),"Clone")
	return new IEnumUnknown(ppenum)
	}
}

;;;;;;;;;;;;;;;;;
;;Base Function;;
;;;;;;;;;;;;;;;;;

; variant type
VariantType(type){
	static _:={2:[2,"short"]	; 16 位有符号整数
	,3:[4,"int"]	; 32 位有符号整数
	,4:[4,"float"]	; 32 位浮点数
	,5:[8,"double"]	; 64 位浮点数
	,0xA:[4,"uint"]	; Error 码 (32 位整数)
	,0xB:[2,"short"]	; 布尔值 True (-1) 或 False (0)
	,0x10:[1,"char"]	; 8 位有符号整数
	,0x11:[1,"uchar"]	; 8 位无符号整数
	,0x12:[2,"ushort"]	; 16 位无符号整数
	,0x13:[4,"uint"]	; 32 位无符号整数
	,0x14:[8,"int64"]	; 64 位有符号整数
	,0x15:[8,"uint64"]}	; 64 位无符号整数
	return _.haskey(type)?_[type]:[A_PtrSize,"ptr"]
}

; Get Value in variant
GetVariantValue(v){
	if (type:=NumGet(v+0,"ushort"))&0x2000
		return GetSafeArrayValue(NumGet(v+8),type&0xFF)
	else{
	return (type=8)?StrGet(NumGet(v+8,varianttype(type).2),"utf-16"):NumGet(v+8,varianttype(type).2)
	}
}

; create safearray
SafeArray(ByRef array,type,count,p*){
	array:=ComObjArray(type,count)
	loop % p.maxindex()
		array[A_Index-1]:=p[A_Index]
	return ComObjValue(array)
}

; Get Value in SafeArray
GetSafeArrayValue(p,type){ ; //not completed, only 1 dim
	/*
	cDims:=NumGet(p+0,"ushort")
	fFeatures:=NumGet(p+2,"ushort")
	cbElements:=NumGet(p+4,"uint")
	cLocks:=NumGet(p+8,"uint")
	pvData:=NumGet(p+8+A_PtrSize,"ptr")
	;dim 1
	cElements:=NumGet(p+8+2*A_PtrSize,"uint") 
	lLbound:=NumGet(p+12+2*A_PtrSize,"uint")
	;dim 2
	cElements:=NumGet(p+16+2*A_PtrSize,"uint") 
	lLbound:=NumGet(p+20+2*A_PtrSize,"uint")
	
	r1:=NumGet(pvData+0)
	*/
	t:=varianttype(type),item:={},pv:=NumGet(p+8+A_PtrSize,"ptr")
	loop % NumGet(p+8+2*A_PtrSize,"uint")
		item.Insert((type=8)?StrGet(NumGet(pv+(A_Index-1)*t.1,t.2),"utf-16"):NumGet(pv+(A_Index-1)*t.1,t.2))
	return item
}

_error(a,ByRef b){
	static err:={0x8000FFFF:"Catastrophic failure error.",0x80004001:"Not implemented error.",0x8007000E:"Out of memory error.",0x80070057:"One or more arguments are not valid error.",0x80004002:"Interface not supported error.",0x80004003:"Pointer not valid error.",0x80070006:"Handle not valid error.",0x80004004:"Operation aborted error.",0x80004005:"Unspecified error.",0x80070005:"General access denied error.",0x800401E5:"The object identified by this moniker could not be found."}
	if a && (a&=0xFFFFFFFF)
		msgbox, % b " : " (err.haskey(a)?err[a]:a)
	return a
}

GUID(ByRef GUID, sGUID){
	VarSetCapacity(GUID, 16, 0)
	return DllCall("ole32\CLSIDFromString", "wstr", sGUID, "ptr", &GUID) >= 0 ? &GUID : ""
}
DEFINE_GUID(ByRef GUID, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11){
	VarSetCapacity(GUID,16)
	,NumPut(p1+p2<<32+p3<<48,GUID,0,"int64")
	,NumPut(p4+p5<<8+p6<<16+p7<<24+p8<<32+p9<<40+p10<<48+p11<<56,GUID,8,"int64")
	return &GUID
}
PROPVARIANT(Byref var){
	VarSetCapacity(var,8+2*A_PtrSize)
	; ...
	return &var
}

_struct(type,p){
	; wtypes.h
	rect:=struct("LONG left;LONG top;LONG right;LONG bottom;")
	point:=struct("LONG x;LONG y;")
	size:=struct("LONG cx;LONG cy;")
	SYSTEMTIME:=struct("WORD wYear;WORD wMonth;WORD wDayOfWeek;WORD wDay;WORD wHour;WORD wMinute;WORD wSecond;WORD wMilliseconds;")
}

StructArray(__,n){
	return IsObject(__)?struct("__[" n "]"):IsObject(_:=struct(__))?struct("_[" n "]"):
}

IsInteger(p){
	if p is Integer
		return true
	else return false
}
