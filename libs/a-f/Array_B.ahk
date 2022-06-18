array_ToVerticleBarString(oArray)
{
    finalStr=
    length:=oArray.Length()
    for k, v in oArray {
        finalStr.=(k=length) ? v : v "|"
    }
    return finalStr
}

obj_toString(obj) {
    finalStr=
    length:=obj.Count()
    for k, v in obj {
        finalStr.=(A_Index=length) ? k ":" Array_String(v, true) : k ":" Array_String(v, true) "`r`n"
    }
    return finalStr
}

array_ToNewLineString(Byref oArray)
{
    finalStr=
    if IsArray(oArray) {
        length:=oArray.Length()
        if (IsObject(oArray[1])) { ;if array of objects 
            for k, v in oArray {
                finalStr.=(k=length) ? obj_toString(v) : obj_toString(v) "`r`n"
            }
        } else {
            for k, v in oArray {
                finalStr.=(k=length) ? v : v "`r`n"
            }
        }
    } else {
        finalStr:=obj_toString(oArray)
    }
    return finalStr
}

array_ToSpacedString(oArray)
{
    finalStr=
    length:=oArray.Length()
    for k, v in oArray {
        if v is number 
            finalStr.=(k=length) ? v : v " "
        else
            finalStr.=(k=length) ? """" v """" : """" v """ "
    }
    return finalStr
}

array_toCompactString(Byref oArray,Byref addBrackets:=false)
{
    if IsObject(oArray)
    {
        if IsArray(oArray)
            return (addBrackets) ? "[" Array_Print_nospace(oArray,true) "]" : Array_Print_nospace(oArray,true)
        else
            return (addBrackets) ? "{" ObjectPrint_nospace(oArray,true) "}" : ObjectPrint_nospace(oArray,true)
    }
    Else
        toReturn:=oArray
    return toReturn
}
array_toCommaString(oArray) ;no space
{
    if IsObject(oArray)
    {
        if IsArray(oArray)
            toReturn:=Array_Print_nospace(oArray)
        else
            toReturn:=ObjectPrint_nospace(oArray)
    }
    Else
        toReturn:=oArray

    return toReturn
}

array_tostring(oArray, addBrackets:=false)
{
    return Array_String(oArray,addBrackets)
}

Array_String(oArray, addBrackets:=false)
{
    if IsObject(oArray)
    {
        if IsArray(oArray)
            return (addBrackets) ? "[" Array_Print(oArray) "]" : Array_Print(oArray)
        else
            return (addBrackets) ? "{" ObjectPrint(oArray) "}" : ObjectPrint(oArray)
    }
    Else
        return oArray
}

Array_Same(array1, array2)
{
    global arrayEqual:=true
    a(array1, array2)
    return arrayEqual

}

a(arrayOrString1, arrayOrString2)
{
    global arrayEqual
    maxIndex1:=arrayOrString1.MaxIndex()
    maxIndex2:=arrayOrString2.MaxIndex()
    if (maxIndex1 != maxIndex2)
    {
        arrayEqual:=false
    }
    Else
    {
        if (maxIndex1>0)
        {
            for Key23, Value24 in arrayOrString1
            {
                if !arrayEqual
                    return
                a(Value24, arrayOrString2[Key23])
            }
        }
        Else if (arrayOrString1!=arrayOrString2)
        {
            arrayEqual:=false
        }
    }
}

Array_Sort(array)
{
    string23=
    for K1, V1 in array
    {
        string23.=V1 . ";"
    }
    string23:= Sort777(string23, ";")[1]
    array := StrSplit(string23 , ";")
    return array
}

Sort777(x, delim="") { ; LOGIC SORT, x IS terminated with delimiter!
    p=
    y=
    z=
    count1=0

    IfEqual delim,, SetEnv delim, `n

    Sort x, D%delim%

    Loop Parse, x, %delim%
    {
        count1++
        If (p = PreText777(A_LoopField))

        y = %y%%delim%%A_LoopField%

        Else {

            Sort y, % "N D" delim " P" StrLen(p)+1

            z = %z%%y%%delim%

            p := PreText777(A_LoopField)

            y = %A_LoopField%

        }

    }

    StringTrimLeft z, z, 1

    Return [z, count1]

}

PreText777(x) {

    Loop Parse, x, 0123456789

    Return A_LoopField

}

;https://autohotkey.com/board/topic/85201-array-deep-copy-treeview-viewer-and-more/ by GeekDude
Array_Print_nospace(Array,noQuotes:=false) 
{
    ; if Array_IsCircle(Array)
    ; return "Error: Circular reference"
    Output=
    For Key23, Value24 in Array
    {

        If (IsObject(Value24))
        {
            if IsArray(Value24)
                Output .= "[" . Array_Print_nospace(Value24,noQuotes) . "]"
            else
                Output .= "{" . ObjectPrint_nospace(Value24,noQuotes) . "}"
        }
        Else If Value24 is not number
            Output .= """" . Value24 . """"
        Else
            Output .= Value24

        Output .= ","
    }
    StringTrimRight, OutPut, OutPut, 1 ;remove the last "," from the end
    Return OutPut
}

ObjectPrint_nospace(Array, noQuotes:=false) {
    ; if Array_IsCircle(Array)
    ; return "Error: Circular refrence"
    Output=
    For Key23, Value24 in Array
    {
        If Key23 is not Number
            Output .= (noQuotes) ? Key23 ":" : """" . Key23 . """:"
        Else
            Output .= Key23 . ":"

        If (IsObject(Value24))
        {
            if IsArray(Value24)
                Output .= "[" . Array_Print_nospace(Value24,noQuotes) . "]"
            else
                Output .= "{" . ObjectPrint_nospace(Value24,noQuotes) . "}"
        }
        Else If Value24 is not number
            Output .= """" . Value24 . """"
        Else
            Output .= Value24

        Output .= ","
    }
    StringTrimRight, OutPut, OutPut, 1 ;remove the last "," from the end
    Return OutPut
}

Array_Print(Array) 
{
    ; if Array_IsCircle(Array)
    ; return "Error: Circular reference"
    Output=
    For Key23, Value24 in Array
    {

        If (IsObject(Value24))
        {
            if IsArray(Value24)
                Output .= "[" . Array_Print(Value24) . "]"
            else
                Output .= "{" . ObjectPrint(Value24) . "}"
        }

        Else If Value24 is not number
            Output .= """" . Value24 . """"
        Else
            Output .= Value24

        Output .= ", "
    }
    StringTrimRight, OutPut, OutPut, 2 ;remove the last 2 "," from the end
    Return OutPut
}

ObjectPrint(Array) {
    ; if Array_IsCircle(Array)
    ; return "Error: Circular refrence"
    Output=
    For Key23, Value24 in Array
    {
        If Key23 is not Number
            Output .= """" . Key23 . """:"
        Else
            Output .= Key23 . ":"

        If (IsObject(Value24))
        {
            if IsArray(Value24)
                Output .= "[" . Array_Print(Value24) . "]"
            else
                Output .= "{" . ObjectPrint(Value24) . "}"
        }
        Else If Value24 is not number
            Output .= """" . Value24 . """"
        Else
            Output .= Value24

        Output .= ", "
    }
    StringTrimRight, OutPut, OutPut, 2 ;remove the last 2 "," from the end
    Return OutPut
}

;
; Function:
; Array_Gui
; Description:
; Displays an array as a treeview in a GUI
; Syntax:
; Array_Gui(Array)
; Parameters:
; Param1 - Array
; An array, associative array, or object.
; Return Value24:
; Null
; Remarks:
; Resizeable
; Related:
; Array_Print, Array_DeepClone, Array_IsCircle
; Example:
; Array_Gui({"GeekDude":["Smart", "Charming", "Interesting"], "tidbit":"Weird"})
Array_Gui(Array, Parent="") {
    static
    global GuiArrayTree, GuiArrayTreeX, GuiArrayTreeY
    if Array_IsCircle(Array)
    {
        MsgBox, 16, GuiArray, Error: Circular refrence
        return "Error: Circular refrence"
    }
    if !Parent
    {
        Gui, +HwndDefault
        Gui, GuiArray:New, +HwndGuiArray +LabelGuiArray +Resize
        Gui, Add, TreeView, vGuiArrayTree

        Parent := "P1"
        %Parent% := TV_Add("Array", 0, "+Expand")
        Array_Gui(Array, Parent)
        GuiControlGet, GuiArrayTree, Pos
        Gui, Show,, GuiArray
        Gui, %Default%:Default

        WinWaitActive, ahk_id%GuiArray%
        WinWaitClose, ahk_id%GuiArray%
        return
    }
    For Key23, Value24 in Array
    {
        %Parent%C%A_Index% := TV_Add(Key23, %Parent%)
        Key23Parent := Parent "C" A_Index
        if (IsObject(Value24))
            Array_Gui(Value24, Key23Parent)
        else
            %Key23Parent%C1 := TV_Add(Value24, %Key23Parent%)
    }
    return

    GuiArrayClose:
        Gui, Destroy
    return

    GuiArraySize:
        if !(A_GuiWidth || A_GuiHeight) ; Minimized
            return
        GuiControl, Move, GuiArrayTree, % "w" A_GuiWidth - (GuiArrayTreeX * 2) " h" A_GuiHeight - (GuiArrayTreeY * 2)
    return
}

;
; Function:
; Array_DeepClone
; Description:
; Deep clone
; Syntax:
; Arrary_DeepClone(Array)
; Parameters:
; Param1 - Array
; An array, associative array, or object.
; Return Value24:
; A copy of the array, that is not linked to the original
; Remarks:
; Supports sub-arrays, and circular refrences
; Related:
; Array_Gui, Array_Print, Array_IsCircle
; Example:
; Array1 := {"A":["Aardvark", "Antelope"], "B":"Bananas"}
; Array2 := Array_DeepClone(Array1)
;

Array_DeepClone(Array, Objs=0)
{
    if !Objs
        Objs := {}
    Obj := Array.Clone()
    Objs[&Array] := Obj ; Save this new array
    For Key23, Val in Obj
        if (IsObject(Val)) ; If it is a subarray
        Obj[Key23] := Objs[&Val] ; If we already know of a refrence to this array
    ? Objs[&Val] ; Then point it to the new array
    : Array_DeepClone(Val,Objs) ; Otherwise, clone this sub-array
    return Obj
}

;
; Function:
; Array_IsCircle
; Description:
; Checks for circular refrences that could crash my other functions
; Syntax:
; Arrary_IsCircle(Array)
; Parameters:
; Param1 - Array
; An array, associative array, or object.
; Return Value24:
; Boolean Value24 according to whether it has a circular refrence
; Remarks:
; Takes an average of 0.023 seconds
; Related:
; Array_Gui, Array_Print(), Array_DeepClone()
; Example:
; Array1 := {"A":["Aardvark", "Antelope"], "B":"Bananas"}
; Array2 := Array_Copy(Array1)
;

Array_IsCircle(Obj, Objs=0)
{
    if !Objs
        Objs := {}
    For Key23, Val in Obj
        if (IsObject(Val)&&(Objs[&Val]||Array_IsCircle(Val,(Objs,Objs[&Val]:=1))))
    return 1
return 0
}

