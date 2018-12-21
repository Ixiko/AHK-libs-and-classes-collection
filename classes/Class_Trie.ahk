Class Trie {
	__Data := {}
	__Count := 0
	__Bool := False
	
	__New(Max := False, params*) {
		this.__Max := Max
		for i, v in params {
			this.__Set(v, "")
		}
	}
	
	__Get(key) {
		if(!__StrInList(key, ["__Data", "__Count", "__Max", "__Bool"])) {
			if(StrLen(key) > 0) {
				obj := this.__Data
				for i, char in StrSplit(key) {
					obj := obj[char]
				}
				this.__Count := 0
				return obj ? StrSplit(SubStr(this.getKeys(obj, key), 1, -1), "`n") : []
			}
		}
	}
	
    __Set(key, val) {
		if(!__StrInList(key, ["__Data", "__Count", "__Max", "__Bool"])) {
			if(StrLen(key) > 0) {
				this.__Bool := True
				obj := this.__Data
				for i, char  in StrSplit(key) {
					; Save reference to the parent of the leaf for use after loop
					preObj := obj
					
					obj := this.addCharToTrie(obj, char)
					
				}
				; Handle if word is ending inside the trie
				if(!this.objIsEmty(obj)) {
					obj["word"] := True
				}
				; If the key ends in a leaf it don't need to be an object
				if(this.objIsEmty(obj)) {
					preObj[char] := True ; (this is to save memory)
				}
			}
		}
	}
	
	remove(key) {
		if(this.__Data.HasKey(SubStr(key, 1, 1))) {
			; Get references to all the characters in the branch
			branch := [this.__Data[SubStr(key, 1, 1)]]
			for i, char in StrSplit(SubStr(key, 2)) {
				if(branch[i].HasKey(char)) {
					branch.Push(branch[i][char])
				} else {
					return
				}
			}
			
			len := branch.Length()
			
			; Handle if the key is not ending in a leaf
			branch[branch.MaxIndex()].Delete("word")
			
			; Deleat chars from the leaf to the root if nothing else will disappear as a result of the deletion
			loop % len {
				index := len + 1 - A_Index
				if(this.objIsEmty(branch[index], "")) {
					branch[index - 1].Delete(SubStr(key, index, 1))
				} else {
					if(this.objIsEmty(branch[index])) {
						branch[index - 1][SubStr(key, index, 1)] := True ; (this is to save memory)
					}
					return
				}
			}
		}
	}
	
	getKeys(obj, key) {
		if(this.objIsEmty(obj)) {
			this.__Count++
			return key "`n"
		}
		if(obj.HasKey("word")) {
			this.__Count++
			res := key "`n"
		}
		for char in obj {
			if(this.__Max && this.__Count >= this.__Max) {
				Break
			}
			if(StrLen(char) == 1) {
				res .= this.getKeys(obj[char], key char)
			}
		}
		return res
	}
	
	addCharToTrie(obj, key) {
		if(!obj.HasKey(key)) {
			; If a new leaf is added from an empty leaf, there must have been a word ending in the late leaf
			if(this.__Bool && this.objIsEmty(obj) && obj != this.__Data) {
				obj["word"] := True
			}
			this.addLeaf(obj, key)
			this.__Bool := False
		}
		
		; If it is a leaf it will not ba an object
		if(!IsObject(obj[key])){
			this.addLeaf(obj, key)
		}
		
		return obj[key]
	}
	
	addLeaf(obj, char) {
		obj[char] := {}
		obj.SetCapacity(0) ; (this is to save memory)
	}
	
	objIsEmty(obj, except := "word") {
		for key in obj {
			if(key != except) {
				return False
			}
		}
		return True
	}
}

__StrInList(str, lst) {
	if str in % __Join(",", lst)
		return True
	return False
}

__Join(sep, params*) {
	for index, param in params {
		str .= param sep
		if (index>50)	; added
			break
	}
	return SubStr(str, 1, -StrLen(sep))
}

MsgObj(obj) {
	MsgBox, % SubStr(ObjectToString(obj), 1, -1)
}

ObjectToString(obj){
	if(!IsObject(obj)){
		return """" obj """"
	}
	res := "{"
	for key, value in obj {
		res .= """" key """ : " ObjectToString(value) ", "
	}
	return SubStr(res, 1, -2) "}"
}