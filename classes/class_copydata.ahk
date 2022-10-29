/*
    Library: copydata
    Author: neovis
    https://github.com/neovis22/copydata
*/

class copydata {
    
    static _handlers := ([], OnMessage(0x4A, "_copydata_receive"))
    
    static _sessions := []
    
    static TYPE_BUFFER := 0xF00001
    static TYPE_STRING := 0xF00002
    static TYPE_OBJECT := 0xF00003
    static TYPE_CALLFUNCTION := 0xF00004
    
    ; `call`, `gosub` 호출시 대기하는 시간(초)
    static timeout := 3
    
    send(hwnd, value, length="") {
        if (length == "") {
            if (IsObject(value))
                value := copydata.ason.stringify(value), type := copydata.TYPE_OBJECT
            else
                type := copydata.TYPE_STRING
            return _copydata_send(hwnd, value, (StrLen(value)+1)*2, type)
        }
        return _copydata_send(hwnd, IsByRef(value) ? &value : value, length, copydata.TYPE_BUFFER)
    }
    
    ; 함수를 호출하고 반환값을 반환
    call(hwnd, func, args*) {
        return _copydata_call(hwnd, func, args*)
    }
    
    ; 반환값을 기다리지 않고 함수를 호출
    postCall(hwnd, func, args*) {
        return _copydata_postCall(hwnd, func, args*)
    }
    
    goto(hwnd, label) {
        _copydata_postCall(hwnd, "_copydata_gosub", label)
        exit
    }
    
    gosub(hwnd, label) {
        return _copydata_call(hwnd, "_copydata_gosub", label)
    }
    
    setVar(hwnd, var, value) {
        return _copydata_call(hwnd, "_copydata_setVar", var, value)
    }
    
    getVar(hwnd, var) {
        return _copydata_call(hwnd, "_copydata_getVar", var)
    }
    
    ; WM_COPYDATA 메시지를 받을 콜백함수 등록
    onReceive(callback, addRemove=1) {
        if (!IsObject(callback))
            callback := Func(callback)
        switch (addRemove) {
            case  1: copydata._handlers.push(callback)
            case -1: copydata._handlers.insertAt(1, callback)
            case  0: copydata._handlers := []
            default: throw Exception("invalid parameter value for addRemove: " addRemove)
        }
    }
    
    #Include %a_lineFile%\..\ason.ahk
}

_copydata_receive(wparam, lparam, msg, hwnd) {
    try {
        ptr := NumGet(lparam+2*a_ptrSize)
        switch (NumGet(lparam+0)) {
            case copydata.TYPE_BUFFER:
                type := "Buffer"
                data := {ptr:ptr, length:NumGet(lparam+a_ptrSize)}
            case copydata.TYPE_STRING:
                type := "String"
                data := StrGet(ptr)
            case copydata.TYPE_OBJECT:
                type := "Object"
                data := copydata.ason.parse(StrGet(ptr))
            case copydata.TYPE_CALLFUNCTION:
                data := copydata.ason.parse(StrGet(ptr))
                if (InStr(data.func, ".")) {
                    parts := StrSplit(data.func, ".")
                    ref := parts.removeAt(1)
                    method := parts.pop()
                    func := ObjBindMethod(parts.length() ? %ref%[parts*] : %ref%, method, data.args*)
                } else {
                    func := Func(data.func).bind(data.args*)
                }
                if (data.sessId)
                    _copydata_postCall(wparam, "_copydata_response", data.sessId, func.call())
                else
                    func.call()
                return true
            default:
                return false
        }
        
        for i, v in copydata._handlers
            if ((res := v.call(wparam, type, data)) != "")
                return res
    } catch {
        return false
    }
    return true
}

_copydata_send(hwnd, ptr, length, type) {
    static buf := (0, VarSetCapacity(buf, 3*a_ptrSize))
    NumPut(type, buf), NumPut(length, buf, a_ptrSize), NumPut(ptr, buf, 2*a_ptrSize)
    return DllCall("SendMessage", "ptr",hwnd, "uint",0x4A, "uptr",a_scriptHwnd, "ptr",&buf)
}

_copydata_call(hwnd, func, args*) {
    ; 세션 객체를 생성하고 객체의 포인터를 전달하여 응답 상태를 확인
    sess := {wait:1}, copydata._sessions[p := &sess] := sess
    data := copydata.ason.stringify({func:func, args:args, sessId:p})
    if (!_copydata_send(hwnd, &data, (StrLen(data)+1)*2, copydata.TYPE_CALLFUNCTION))
        return
    t := a_tickCount+copydata.timeout*1000
    while (sess.wait) {
        if (copydata.timeout != 0 && a_tickCount > t) {
            copydata._sessions.delete(p)
            throw Exception("copydata: timeout")
        }
        Sleep 10
    }
    copydata._sessions.delete(p)
    return sess.res
}

_copydata_postCall(hwnd, func, args*) {
    data := copydata.ason.stringify({func:func, args:args})
    return _copydata_send(hwnd, &data, (StrLen(data)+1)*2, copydata.TYPE_CALLFUNCTION)
}

; 응답온 데이터를 저장
_copydata_response(sessId, res) {
    if (sess := copydata._sessions[sessId])
        sess.res := res, sess.wait := 0
}

_copydata_getVar(var) {
    if (InStr(var, ".")) {
        parts := StrSplit(var, ".")
        ref := parts.removeAt(1)
        return %ref%[parts*]
    } else {
        return (%var%)
    }
}

_copydata_setVar(var, value) {
    if (InStr(var, ".")) {
        parts := StrSplit(var, ".")
        ref := parts.removeAt(1)
        %ref%[parts*] := value
    } else {
        %var% := value
    }
}

_copydata_gosub(label) {
    gosub % label
}
