; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=6&t=37083
; Author:	Capn Odin
; Date:
; for:     	AHK_L

/*


*/

Class OrderedAssociativeArray {
	__New() {
		ObjRawSet(this, "__Data", {})
		ObjRawSet(this, "__Order", [])
	}

	__Get(args*) {
		return this.__Data[args*]
	}

	__Set(args*) {
		key := args[1]
		val := args.Pop()
		if(args.Length() < 2 && this.__Data.HasKey(key)) {
			this.Delete(key)
		}
		if(!this.__Data.HasKey(key)) {
			this.__Order.Push(key)
		}
		this.__Data[args*] := val
		return val
	}

	InsertAt(pos, key, val) {
		this.__Order.InsertAt(pos, key)
		this.__Data[key] := val
	}

	RemoveAt(pos) {
		val := this.__Data[this.__Order[pos]]
		this.__Data.Delete(this.__Order[pos])
		this.__Order.RemoveAt(pos)
		return val
	}

	Delete(key) {
		for i, v in this.__Order {
			if(key == v) {
				return this.RemoveAt(i)
			}
		}
	}

	Length() {
		return this.__Order.Length()
	}

	HasKey(key) {
		return this.__Data.HasKey(key)
	}

	_NewEnum() {
		return new OrderedAssociativeArray.Enum(this.__Data, this.__Order)
	}

	Class Enum {
		__New(Data, Order) {
			this.Data := Data
			this.oEnum := Order._NewEnum()
		}

		Next(ByRef key, ByRef val := "") {
			res := this.oEnum.next(, key)
			val := this.Data[key]
			return res
		}
	}
}