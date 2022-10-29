/*
    Library: events
    Author: neovis
    https://github.com/neovis22/events
    
    nodejs EventEmitter 클래스의 일부분을 오토핫키로 구현
    https://nodejs.org/api/events.html#class-eventemitter
*/

class EventEmitter {
    
    static on := EventEmitter.addListener
    
    static off := EventEmitter.removeListener
    
    emit(type, args*) {
        list := this.listeners(type)
        if (!list.length())
            return false
        i := 1
        loop % list.length() {
            try list[i].listener.call(args*)
            if (list[i].once)
                list.removeAt(i)
            else
                i ++
        }
        return true
    }
    
    eventNames() {
        names := []
        for type in this.listeners()
            names.push(type)
        return names
    }
    
    listeners(type="") {
        if (!e := ObjRawGet(this, ".events"))
            ObjRawSet(this, ".events", e := [])
        return type == "" ? e : ObjHasKey(e, type) ? e[type] : e[type] := []
    }
    
    addListener(type, listener) {
        return this, this.listeners(type).push({listener:listener})
    }
    
    once(type, listener) {
        return this, this.listeners(type).push({listener:listener, once:true})
    }
    
    prependListener(type, listener) {
        return this, this.listeners(type).insertAt(1, {listener:listener})
    }
    
    prependOnceListener(type, listener) {
        return this, this.listeners(type).insertAt(1, {listener:listener, once:true})
    }
    
    removeAllListeners(type="") {
        if (type == "")
            ObjRawSet(this, ".events", [])
        else
            this.listeners().delete(type)
        return this
    }
    
    removeListener(type, listener) {
        list := this.listeners(type)
        for i, v in list
            if (v.listener == listener)
                return this, list.removeAt(i)
        return this
    }
}