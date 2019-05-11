/*
	Creates an indirect reference to an object
	This class will store the original reference
*/

Class IndirectReferenceHolder {
	static Storage := {}
	
	__New(Object) {
		for RefPtr, Obj in IndirectReferenceHolder.Storage
			if (&Obj = &Object)
				return Object(RefPtr)
		
		IndirectReferenceHolder.Storage[&this] := Object
		Object.base := {__Class: Object.base.__Class, __Delete: Func("IndirectReferenceDelete"), base: Object.base}
	}
	
	__Delete() {
		IndirectReferenceHolder.Storage.Delete(&this)
	}
	
	__Call(Method, Params*) {
		if Obj := IndirectReferenceHolder.Storage[&this]
			return Obj[Method](Params*)
	}
	
	__Get(Key) {
		if Obj := IndirectReferenceHolder.Storage[&this]
			return Obj[Key]
	}
	
	__Set(Key, Value) {
		if Obj := IndirectReferenceHolder.Storage[&this]
			return Obj[Key] := Value
	}
}

IndirectReferenceDelete(this) {
	for RefPtr, ObjPtr in IndirectReference.Storage
		if (&this = ObjPtr)
			IndirectReference.Storage.Delete(RefPtr)
	
	base := this.base
	while (base := base.base)
		if base.HasKey("__Delete")
			return Func(base.__Class ".__Delete").Call(this)
}