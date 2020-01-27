class _TypeSizes {
	__Get(Key) {
		return (Key != "") ? (TypeSizes[Key] := TypeSizes.GetTypeSize(Key)) : (0)
	}
}

class TypeSizes extends _TypeSizes {
	GetTypeSize(TypeName) {
		static TestBuffer
		static _ := VarSetCapacity(TestBuffer, 8, 0)
		
		return NumPut(0, &TestBuffer + 0, 0, TypeName) - (&TestBuffer)
	}
}

class ManagedScanningBuffer extends ScanningBuffer {
	static hProcessHeap := DllCall("GetProcessHeap")

	__New(Length) {
		static HEAP_ZERO_MEMORY := 0x00000008
	
		this.pBuffer := DllCall("HeapAlloc", "Ptr", ManagedScanningBuffer.hProcessHeap, "UInt", HEAP_ZERO_MEMORY, "UInt", Length)
		ScanningBuffer.__New.Call(this, this.pBuffer, Length)
	}
	__Delete() {
		DllCall("HeapFree", "Ptr", ManagedScanningBuffer.hProcessHeap, "UInt", 0, "Ptr", this.pBuffer)
	}
}

class ScanningBuffer {
	IsScanningBuffer() {
		return true
	}

	__New(pBuffer, Length) {
		this.Start := pBuffer
		this.Current := this.Start
		this.End := this.Start + Length
	}
	Tell() {
		return this.Current - this.Start
	}

	CheckBounds(TypeName) {
		NewCurrent := this.Current + TypeSizes[TypeName]
	
		if (NewCurrent > this.End || NewCurrent < this.Start) {
			Throw, Exception("Reading/Writing a " TypeName " will over/under-run the ScanningBuffer at " this.Start ".")
		}
		else {
			return NewCurrent
		}
	}
	_ReadType(TypeName) {
		NewCurrent := this.CheckBounds(TypeName)
		
		return (NumGet(this.Current + 0, 0, TypeName), this.Current := NewCurrent)
	}
	_WriteType(TypeName, Value) {
		NewCurrent := this.CheckBounds(TypeName)
		
		return (NumPut(Value, this.Current + 0, 0, TypeName), this.Current := NewCurrent)
	}
	SeekCurrent(Offset) {
		this.Current += Offset
		
		try {
			this.CheckBounds("")
		}
		catch {
			Throw, Exception("Invalid SeekCurrent using offset " Offset)
			this.Current -= Offset
		}
	}
	SeekStart(Offset) {
		OldCurrent := this.Current
		this.Current := this.Start + Offset
		
		try {
			this.CheckBounds("")
		}
		catch {
			Throw, Exception("Invalid SeekStart using offset " Offset) 
			this.Current := OldCurrent
		}
	}
	
	__Call(Key, Params*) {
		Base := ObjGetBase(this)
	
		if (SubStr(Key, 1, 4) = "Read") {
			return Base._ReadType.Call(this, SubStr(Key, 5), Params*)
		}
		else if (SubStr(Key, 1, 5) = "Write") {
			return Base._WriteType.Call(this, SubStr(Key, 6), Params*)
		}
	}
}
