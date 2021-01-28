; Link:   	https://sites.google.com/site/ahkref/custom-functions/onmessageex
; Author:
; Date:
; for:     	AHK_L

/*


*/

OnMessageEx(MsgNumber, params*) {
    ;version 1.0.2 by A_Samurai http://sites.google.com/site/ahkref/custom-functions/onmessageex
    Static Functions := {}

    ;determine whether this is an on-message call
    FunctionName := params.1, OnMessage := True, DHW := A_DetectHiddenWindows
    DetectHiddenWindows, ON
    if ObjMaxIndex(params) <> 3            ;if the number of optional parameters are not three
        OnMessage := False
    else if FunctionName not between 0 and 4294967295    ;if the second parameter is not between 0 to 4294967295
        OnMessage := False
    else if !WinExist("ahk_id " params.3)    ;if the third parameter is not an existing Hwnd of a window/control
        OnMessage := False
    DetectHiddenWindows, % DHW

    if !OnMessage {
    ;if the function is manually called,
        Priority := params.2 ? params.2 : (params.2 = 0) ? 0 : 1
        If FunctionName    {
            ;if FunctionName is specified, it means to register it or if the priority is set to 0, remove it

            ;prepare for the function stack object
            Functions[MsgNumber] := Functions[MsgNumber] ? Functions[MsgNumber] : []

            ;check if there is already the same function in the stack object
            For index, oFunction in Functions[MsgNumber] {
                if (oFunction.Func = FunctionName) {
                    oRemoved := ObjRemove(Functions[MsgNumber], Index)
                    Break
                }
            }
            ;if the priority is 0, it means to remvoe the function
            if (Priority = 0)
                Return oRemoved.Func

            ;check if there is a function already registered for this message
            if (PrevFunc := OnMessage(MsgNumber)) && (PrevFunc <> A_ThisFunc) {
                ;this means there is one, so add this function to the stack object
                ObjInsert(Functions[MsgNumber], {Func: PrevFunc, Priority: 1})
            }

            ;find out the priority in each registered function and insert it before the element of the same priority
            IndexToInsert := 1
            For Index, oFunction in Functions[MsgNumber] {
                IndexToInsert := Index
            } Until (oFunction.Priority = Priority)

            ;retrieve the function name in the first priority for the return value
            FirstFunc := Functions[MsgNumber][ObjMinIndex(Functions[MsgNumber])].Func

            ;insert the given function in the function stack object
            if IsObject(FunctionName) {
                ;an object is passed for the second parameter
                ThisObj := Object(FunctionName.1), ThisMethod := FunctionName.2, AutoRemove := ObjHasKey(FunctionName, 3) ? FunctionName.3 : False
                If IsFunc(ThisObj[ThisMethod])    ;chceck if the method exists
                    ObjInsert(Functions[MsgNumber], IndexToInsert, {Func: FunctionName.2, Priority: Priority, ObjectAddress: FunctionName.1, AutoRemove: AutoRemove})
                else         ;if the passed function name is not a function, return false
                    return False
            } else {
                if IsFunc(FunctionName)    ;chceck if the function exists
                    ObjInsert(Functions[MsgNumber], IndexToInsert, {Func: FunctionName, Priority: Priority})
                else        ;if the passed function name is not a function, return false
                    return False
            }

            ;register it
            if (PrevFunc <> A_ThisFunc)
                OnMessage(MsgNumber, A_ThisFunc)

            Return FirstFunc
        } Else if ObjHasKey(params, 1) && (FunctionName = "") {
            ;if FunctionName is explicitly empty, remove the function and return its name

            ;remove the lowest priority function (the last element) in the object of the specified message.
            oRemoved := ObjRemove(Functions[MsgNumber], ObjMaxIndex(Functions[MsgNumber]))

            ;if there are no more registered functions, remove the registration of this function for this message
            if !ObjMaxIndex(Functions[MsgNumber])
                OnMessage(MsgNumber, "")

            Return oRemoved.Func
        } Else     ;return the registered function of the lowest priority for this message
            Return Functions[MsgNumber][ObjMaxIndex(Functions[MsgNumber])].Func
    } Else {
    ;if this is an on-message call,
        wParam := MsgNumber, lParam := params.1, msg := params.2, Hwnd := params.3
        For Index, Function in Functions[msg] {
            ThisFunc := Function.Func
            if ObjHasKey(Function, "ObjectAddress") {
                ;if it is an object method
                ThisObj := Object(Function.ObjectAddress)
                ThisObj[ThisFunc](wParam, lParam, msg, Hwnd)
                if Function.AutoRemove {        ;this means if the method no longer exists, remove it
                    If !IsFunc(ThisFunc) {
                        ObjRemove(Functions[MsgNumber], ThisFunc)

                        ;if there are no more registered functions, remove the registration of this function for this message
                        if !ObjMaxIndex(Functions[MsgNumber])
                            OnMessage(MsgNumber, "")
                    }
                }
            } else     ;if it is a function
                %ThisFunc%(wParam, lParam, msg, Hwnd)
        }
    }
}