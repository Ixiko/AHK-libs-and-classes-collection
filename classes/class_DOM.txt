/*
    Library: dom
    Author: neovis
    https://github.com/neovis22/dom
*/

dom(html, removeScripts=true) {
    doc := ComObjCreate("htmlfile")
    
    ; 가능한 최신모델로 로드
    ; 명시하지 않을 경우 이후 추가될 내용에 따라 구버전이 로드될 수 있음
    doc.write("<meta http-equiv='X-UA-Compatible' content='IE=Edge'>")
    
    ; querySelectorAll, NodeList, HTMLCollection 지원가능한 버전 확인
    if (doc.documentMode < 9)
        throw Exception("document version " doc.documentMode " is not supported")
    
    if (removeScripts)
        html := RegExReplace(html
            , "i)\s*<script(\s.*?)?(/>|>[\s\S]*?</script>)\s*"
            ; 완전히 제거할 경우 index 탐색시 영향을 주므로 빈 요소로 치환
            , "<script></script>")
    doc.write(html)
    
    return new DOMElement(doc, doc)
}

class DOMElement {
    
    __new(element, doc="") {
        ObjRawSet(this, ".ref", element)
        ObjRawSet(this, ".doc", doc ? doc : element)
    }
    
    __get(name) {
        if (IsObject(res := (this[".ref"])[name]))
            return isNodeList(this[".doc"], res)
                ? new DOMElements(res, this[".doc"])
                : new DOMElement(res, this[".doc"])
        return res
    }
    
    __set(name, value) {
        return this[".ref"][name] := IsObject(value) && ObjHasKey(value, ".ref") ? value[".ref"] : value
    }
    
    __call(method, args*) {
        for i, v in args
            if (IsObject(v) && ObjHasKey(v, ".ref"))
                args[i] := v[".ref"]
        
        switch (method) {
            case "qs": method := "querySelector"
            case "qsa", "select": method := "querySelectorAll"
        }
        
        if (IsObject(res := (this[".ref"])[method](args*)))
            return isNodeList(this[".doc"], res)
                ? new DOMElements(res, this[".doc"])
                : new DOMElement(res, this[".doc"])
        return res
    }
}

class DOMElements {
    
    __new(elements, doc="") {
        ObjRawSet(this, ".ref", elements)
        ObjRawSet(this, ".doc", doc ? doc : elements)
    }
    
    __get(name) {
        if name is integer
            return new DOMElement(this[".ref"][name], this[".doc"])
        
        return IsObject(value := this[".ref"][name])
            ? new DOMElement(value,, this[".ref"])
            : value
    }
    
    __call(method, args*) {
        /*
            for문으로 열거 가능하도록 열거함수 바인드
            * 열거시 인덱스는 0부터 시작
            * 엘리먼트를 조작시 혼동을 줄이기 위해 1로 변환하지 않음
            
            기존 사용:
            loop % elements.length {
                element := elements[a_index-1]
            }
            
            for문 사용:
            for i, element in elements {
            }
        */
        if (method = "_newEnum")
            return {base:{next:DOMElements._enumNext}, elems:this[".ref"], doc:this[".doc"], i:0, length:this[".ref"].length}
        
        return (this[".ref"])[method](args*)
    }
    _enumNext(byref i, byref v="") {
        return this.i == this.length ? 0 : (1, v := new DOMElement(this.elems[i := this.i ++], this.doc))
    }
}

isNodeList(doc, obj) {
    return doc.parentWindow.NodeList.prototype.isPrototypeOf(obj)
        || doc.parentWindow.HTMLCollection.prototype.isPrototypeOf(obj)
}