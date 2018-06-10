ObjShare(obj){
	static IDispatch,set:=VarSetCapacity(IDispatch, 16), init := NumPut(0x46000000000000c0, NumPut(0x20400, IDispatch, "int64"), "int64")
	if IsObject(obj)
		return  LresultFromObject(&IDispatch, 0, &obj)
	else if ObjectFromLresult(obj, &IDispatch, 0, getvar(com:=0))
		return MessageBox(NULL,A_ThisFunc ": LResult Object could not be created","Error",0)
	return ComObject(9,com,1)
}