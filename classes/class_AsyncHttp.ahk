﻿; AsyncHttp

/*
; create new instance
reqs := new AsyncHttp()

; optionally with "finished" callback
reqs := new AsyncHttp(Func("MyHandler"))

; start making requests, 
reqs.Request("GET", url1, "", {options: option})
reqs.Request("GET", url2)
reqs.Request("GET", url3)

; wait 1 second for all current requests to finish
reqs.Wait(1)

; wait indefinitely for specific requests to finish
reqs.Wait(-1, [1,3])

; abort all or specific pending requests after waiting
reqs.Abort()
reqs.Abort([1,5,7])

*/

#Include ..\WinHttpRequest\WinHttpRequest.ahk

class AsyncHttp {
    idx := 0
    list := []
    
    __new(callbacks = "") {
        this.callbacks := callbacks
    }
    
    _NewEnum() {
        return this.list._NewEnum()
    }
    
    __get(key) {
        return this.list[key]
    }
    
    Request(verb, url, body = "", options = "") {
        this.idx++
        StringUpper, verb, verb
        whr := new WinHttpRequest(this.callbacks, { pthis: &this, idx: this.idx })
        this.list[this.idx] := { whr: whr, idx: this.idx, url: url, verb: verb, body: body, options: options }
        whr.Open(verb, url, true)
        whr.Send(body)
        return this.idx
    }
    
    wait( seconds = -1, indices = "`r" ) {
        start := A_TickCount
        for idx, item in this
            if (indices == "`r" || IsObject(indices) && indices.HasKey(idx)) {
                time := seconds <= 0 ? seconds : seconds - (A_TickCount - start) // 1000
                if (time < 0 && seconds > 0 || !item.whr.WaitForResponse(time))
                    return false
            }
        return true
    }
    
    abort( indices = "`r" ) {
        for idx, item in this
            if (indices == "`r" || IsObject(indices) && indices.HasKey(idx))
                item.whr.Abort()
    }
    
    MaxIndex() {
        return this.idx
    }
    
    Remove( idx ) {
        return this.list.remove(idx, "")
    }
}



class _queue {
    
    _list := []
    insert := _Queue.add
    
    __new(callback, limit = "", type = "fifo") {
        if !IsFunc(callback) || !{ fifo: 1, lifo: 1 }[type]
            return ""
        ObjInsert(this, "_type", type)
        ObjInsert(this, "_callback", callback)
        ObjInsert(this, "_limit", limit)
        ObjInsert(this, "_count", 0)
    }
    
    __get(key) {
        return this._list[key]
    }
    
    remove(key = "") {
        if !key
            key := this._list.maxindex()
        
    }
    
    add(id, value) {
        this._list.insert(this._type = "fifo" || !this._list.maxindex() ? 1 : this._list.maxindex()+1, { id: id, value: value })
    }
    
    Emit() {
        this._callback.(this[1])
        this._count++
    }
}
