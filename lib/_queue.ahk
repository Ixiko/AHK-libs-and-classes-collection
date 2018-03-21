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
