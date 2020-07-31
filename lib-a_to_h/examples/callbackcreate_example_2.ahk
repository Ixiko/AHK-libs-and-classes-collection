#include %a_Scriptdir%\..\lib-a_to_h\callbackcreate.ahk
; Class method callback
i := new myClass("Apple")
callbackFunc := objbindmethod(i, "myMethod", "BoundParam1")
address := CallbackCreate(callbackFunc,, 1)
dllcall(address, "int", 37)
callbackfree(address)
msgbox done

class myClass {
	__new(name){
		this.name := name
	}
	myMethod(arg1, arg2){
		msgbox % this.name "`n" arg1 "`n" arg2
	}
}