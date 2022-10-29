/*
    Library: buffer
    Author: neovis
    https://github.com/neovis22/buffer
*/

buffer(length, fill="", encoding="utf-8") {
    return new __Buffer__(length, fill, encoding)
}

/*
    buffer := buffer_from(buffer, [offset], [length])
    buffer := buffer_from(data, [encoding])
*/
buffer_from(byref data, args*) {
    ; buffer
    if (IsObject(data)) {
        offset := args[1] ? args[1] : 0
        length := args[2] ? args[2] : data.length-offset
        
        buf := buffer(length)
        DllCall("RtlMoveMemory"
            , "ptr",buf.ptr
            , "ptr",data.ptr+offset
            , "uint",length)
        return buf
    }
    
    ; string
    switch (args[1]) {
        case "base64":
            if (!DllCall("crypt32\CryptStringToBinary"
                , "str",data
                , "uint",0
                , "uint",1 ; CRYPT_STRING_BASE64
                , "ptr",0
                , "uintp",length
                , "ptr",0
                , "ptr",0))
                throw Exception("CryptStringToBinary")
            
            buf := buffer(length)
            if (!DllCall("crypt32\CryptStringToBinary"
                , "str",data
                , "uint",0
                , "uint",1 ; CRYPT_STRING_BASE64
                , "ptr",buf.ptr
                , "uintp",length
                , "ptr",0
                , "ptr",0))
                throw Exception("CryptStringToBinary")
        
        case "hex":
            buf := buffer(length := StrLen(data)//2)
            loop % length
                NumPut("0x" SubStr(data, a_index*2-1, 2), buf.ptr, a_index-1, "uchar")
        
        default:
            if (args[1] == "")
                args[1] := "utf-8"
            length := StrPut(data, args[1])*(args[1] = "utf-16" || args[1] = "cp1200" ? 2 : 1)-1
            
            buf := buffer(length)
            StrPut(data, buf.ptr, buf.length, args[1])
    }
    return buf
}

buffer_fromFile(path, offset=0, length=0) {
    file := FileOpen(path, "r")
    
    if (offset)
        file.pos := offset
    if (length == 0)
        length := file.length-offset
    
    buf := buffer(length)
    file.rawRead(buf.ptr, length)
    return buf
}

class __Buffer__ {
    
    __new(length, fill="", encoding="utf-8") {
        this.length := length
        this.encoding := encoding
        
        if (fill != "")
            this.fill(fill)
    }
    
    __get(name) {
        ; byte := buffer[index]
        if name is integer
            return NumGet(this.ptr, name, "uchar")
    }
    
    __set(name, value) {
        ; buffer[index] := byte
        if name is integer
            return NumPut(value, this.ptr, name, "uchar")
    }
    
    /*
        바이트로 열거
    */
    _newEnum() {
        return {base:{next:this._nextEnum}, data:this, i:0, length:this.length}
    }
    _nextEnum(byref i, byref v="") {
        return this.i == this.length ? 0 : (1, v := this.data[i := this.i ++])
    }
    
    toString(encoding="", offset=0, length=0) {
        if (encoding == "")
            encoding := this.encoding
        
        if (length == 0)
            length := this.length-offset
        
        switch (encoding) {
            case "base64":
                if (!DllCall("crypt32\CryptBinaryToString"
                    , "ptr",this.ptr+offset
                    , "uint",length
                    , "uint",1 | 0x40000000 ; CRYPT_STRING_BASE64 | CRYPT_STRING_NOCRLF
                    , "ptr",0
                    , "uintp",bytes))
                    throw Exception("CryptBinaryToString")
                
                VarSetCapacity(base64, bytes*2, 0)
                if (!DllCall("crypt32\CryptBinaryToString"
                    , "ptr",this.ptr+offset
                    , "uint",length
                    , "uint",1 | 0x40000000 ; CRYPT_STRING_BASE64 | CRYPT_STRING_NOCRLF
                    , "str",base64
                    , "uintp",bytes))
                    throw Exception("CryptBinaryToString")
                return base64
            
            case "hex":
                static h := StrSplit("0123456789ABCDEF")
                loop % length
                    res .= h[((x := NumGet(this.ptr+offset, a_index-1, "uchar"))>>4)+1] h[(x&15)+1]
                return res
            
            default:
                return StrGet(this.ptr+offset, length, encoding)
        }
    }
    
    save(path, offset=0, length=0) {
        if (length == 0)
            length := this.length-offset
        
        file := IsObject(path) ? path : FileOpen(path, "w")
        file.rawWrite(this.ptr+offset, length)
    }
    
    fill(value=0, offset=0, length=0) {
        if (length == 0)
            length := this.length-offset
        
        DllCall("NtDll\RtlFillMemory"
            , "ptr",this.ptr+offset
            , "uint",length
            , "uchar",value)
    }
    
    write(data, offset=0, length=0, encoding="") {
        length := length == 0 ? this.length-offset : Min(this.length-offset, length)
        if (encoding == "")
            encoding := this.encoding
        
        ; buffer
        if (IsObject(data)) {
            length := Min(data.length, length)
            
            DllCall("RtlMoveMemory"
                , "ptr",this.ptr+offset
                , "ptr",data.ptr
                , "uint",length)
            return length
        }
        
        ; string
        length := Min(length, StrPut(data, encoding)*(encoding = "utf-16" || encoding = "cp1200" ? 2 : 1)-1)
        return StrPut(data, this.ptr+offset, length, encoding)
    }
    
    length[] {
        get {
            return this._length
        }
        set {
            if (this.setCapacity("data", this._length := value) == "")
                throw Exception("invalid length: " value)
            
            this.ptr := this.getAddress("data")
            return value
        }
    }
}
