class ChromeRemoteObject {
    
    __new(object, cdp) {
        switch (object.type) {
            case "object", "function", "symbol":
                ObjRawSet(this, "_objectId", object.objectId)
                ObjRawSet(this, "_cdp", cdp)
            case "undefined":
                return ""
            case "string", "number", "boolean":
                return object.value
            case "bigint":
                return object.unserializableValue
        }
    }
    
    __get(key) {
        res := this._cdp.call("Runtime.callFunctionOn", {
        (join, ltrim
            functionDeclaration:"function(key) { return this[key] }"
            objectId:this._objectId
            arguments:[{value:key}]
        )}).result
        return new ChromeRemoteObject(res, this._cdp)
    }
    
    __set(key, value) {
        this._cdp.call("Runtime.callFunctionOn", {
        (join, ltrim
            functionDeclaration:"function(key, value) { this[key] = value }"
            objectId:this._objectId
            arguments:[{value:key}, this._arguments(value)[1]]
        )})
        return value
    }
    
    __call(method, args*) {
        switch (method) {
            case "_newEnum":
                keys := Chrome.jxon_load(this._cdp.call("Runtime.callFunctionOn", {
                (join, ltrim
                    functionDeclaration:"function() { return JSON.stringify(Object.keys(this)) }"
                    objectId:this._objectId
                )}).result.value)
                return {base:{next:ChromeRemoteObject._enumNext}, obj:this, keys:ObjNewEnum(keys)}
            
            case "_arguments":
                res := []
                for i, arg in args {
                    if (IsObject(arg)) {
                        if (arg._objectId == "")
                            arg := this._cdp.evaluate("(" Chrome.jxon_dump(arg) ")")
                        
                        res.push({objectId:arg._objectId})
                    } else {
                        res.push({value:arg})
                    }
                }
                return res
        }
        
        params := []
        params.functionDeclaration := "function() { return this." method "(...arguments) }"
        params.objectId := this._objectId
        
        if (args.length())
            params.arguments := this._arguments(args*)
        
        res := this._cdp.call("Runtime.callFunctionOn", params).result
        return new ChromeRemoteObject(res, this._cdp)
    }
    
    _enumNext(byref key, byref value="") {
        return this.keys[i, key] ? (1, value := this.obj[key]) : 0
    }
    
    eval(args*) {
        static _ := ("", Chrome.Page.eval := ChromeRemoteObject.eval)
        return new ChromeRemoteObject(Chrome.Page.evaluate.call(this, args*), this)
    }
}

#Include *i %a_lineFile%\..\Chrome.ahk
