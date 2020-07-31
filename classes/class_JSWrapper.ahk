; Link:   	
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

class JSWrapper {
	static IID_IDispatchEx := "{A6EF9860-C720-11d0-9337-00A0C90DCAA9}"
	_self := {}

	__New(obj) {
		this._self.obj := obj
		if !(inf := ComObjQuery(obj, JSWrapper.IID_IDispatchEx)) {
			throw Exception("JSWrapper.__New: Failed to get IDispatchEx interface")
		}
		this._self.inf := inf
		this._self.getDispIDAddr := NumGet(NumGet(inf+0), 7 * A_PtrSize)
		this._self.invokeExAddr  := NumGet(NumGet(inf+0), 8 * A_PtrSize)
	}

	__Delete() {
		ObjRelease(this._self.inf)
	}

	__Set(key, value) {
		if (key != "_self")
			return this._self.obj[key] := value
	}

	__Get(key) {
		if (key != "_self") {
			ceEnabled := ComObjError(false)
			value := this._self.obj[key]
			if (A_LastError & 0xffffffff = 0x80020006) { ; DISP_E_UNKNOWNNAME
				dispId := 0
				bname := DllCall("OleAut32\SysAllocString", "Str", key, "Ptr")
				if !bname
					throw Exception("JSWrapper.__Get(" key "): SysAllocString failed")
				hr := DllCall(this._self.getDispIDAddr, "Ptr", this._self.inf, "Ptr", bname, "UInt", 0x8, "Int*", dispId, "UInt")
				DllCall("OleAut32\SysFreeString", "Ptr", bname)
				if hr
					throw Exception("JSWrapper.__Get(" key "): GetDispID HRESULT " Format("{:#x}", hr & 0xffffffff))

				VarSetCapacity(noparams, 24, 0)
				VarSetCapacity(result, 24, 0)
				hr := DllCall(this._self.invokeExAddr, "Ptr", this._self.inf, "Int", dispId, "UInt", 0x400, "UShort", 0x2, "Ptr", &noparams, "Ptr", &result, "Ptr", 0, "Ptr", 0)
				if hr
					throw Exception("JSWrapper.__Get(" key "): InvokeEx HRESULT " Format("{:#x}", hr & 0xffffffff))

				; "Casting" to VT_BYREF and dereferencing with [] makes a copy of the result variant
				; using VariantCopyInd and then converts that to a corresponding AHK COM wrapper
				; (see ComObject in script_com.h). This does the same thing that a typical
				; ComObject::Invoke + IT_GET does with the result variant of IDispatch::Invoke,
				; except that, unlike Invoke, we give a copy of result to VariantToToken so we have
				; to clear result.
				value := ComObject(0x4000 | NumGet(result, 0, "Short"), &result+8, 0)[]
				hr := DllCall("OleAut32\VariantClear", "Ptr", &result)
				if hr
					throw Exception("JSWrapper.__Get(" key "): VariantClear HRESULT " Format("{:#x}", hr & 0xffffffff))
			}
			else if A_LastError {
				throw Exception("JSWrapper.__Get(" key "): built-in-get HRESULT " Format("{:#x}", A_LastError & 0xffffffff))
			}
			ComObjError(ceEnabled)
			return value
		}
	}

	__Call(name, params*) {
		f := this[name]
		return %f%(params*)
	}
}
