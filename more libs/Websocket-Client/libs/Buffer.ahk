class Buffer
{
    __New(len) {
        this.SetCapacity("buffer", len)
        this.length := len
        this.index := 0
    }

    FromString(str, encoding = "UTF-8") {
        length := Buffer.GetStrSize(str, encoding)
        buffer := new Buffer(length)
        buffer.WriteStr(str)
        return buffer
    }

    GetStrSize(str, encoding = "UTF-8") {
        encodingSize := ((encoding="utf-16" || encoding="cp1200") ? 2 : 1)
        ; length of string, minus null char
        return StrPut(str, encoding) - encodingSize
    }

    WriteStr(str, encoding := "UTF-8") {
        length := this.GetStrSize(str, encoding)
        
        VarSetCapacity(text, length)
        StrPut(str, &text, encoding)

        this.Write(&text, length)
        return length
    }

    ; data is a pointer to the data
    Write(data, length) {
        if (this.index + length > this.length) {
            this.SetCapacity("buffer", this.index + length)
        }

        p := this.GetPointer()
        DllCall("RtlMoveMemory", "ptr", p + this.index, "ptr", data, "uint", length)
        this.index += length
    }

    Append(ByRef buffer) {
        destP := this.GetPointer()
        sourceP := buffer.GetPointer()

        DllCall("RtlMoveMemory", "ptr", destP + this.length, "ptr", sourceP, "uint", buffer.length)
        this.length += buffer.length
    }

    GetPointer() {
        return this.GetAddress("buffer")
    }

    Done() {
        this.SetCapacity("buffer", this.length)
    }
}