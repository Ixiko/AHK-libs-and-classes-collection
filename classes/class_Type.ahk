class Type {

    Property
    {
    }
}

Type(Value) {
    local
    global Type
    ; This should be updated when a new built-in type is added to AutoHotkey.
    static BoundFunc             := Func("Type").Bind("")
    static ComObjArrayEnumerator := ComObjArray(0x11, 1)._NewEnum()
    static ComObjectEnumerator   := ComObjCreate("Scripting.Dictionary")._NewEnum()
    static File                  := FileOpen(A_ScriptFullPath, "r")
    static Func                  := Func("Type")
    static ObjectEnumerator      := {}._NewEnum()
    static Property              := ObjRawGet(Type, "Property")
    static RegExMatch, _         := RegExMatch("a" ,"O)a", RegExMatch)
    ; If you try to convert the above to expressions and get the addresses, the
    ; result is incorrect.
    static TypeFromAddress := {NumGet(&BoundFunc):             "BoundFunc"
                              ,NumGet(&ComObjArrayEnumerator): "Enumerator"
                              ,NumGet(&ComObjectEnumerator):   "Enumerator"
                              ,NumGet(&File):                  "File"
                              ,NumGet(&Func):                  "Func"
                              ,NumGet(&ObjectEnumerator):      "Enumerator"
                              ,NumGet(&Property):              "Property"
                              ,NumGet(&RegExMatch):            "RegExMatch"}
    if (IsObject(Value))
    {
        if (TypeFromAddress.HasKey(NumGet(&Value)))
        {
            Result := TypeFromAddress[NumGet(&Value)]
        }
        else if ((TypeCode := ComObjType(Value)) != "")
        {
            Result := TypeCode & 0x2000                                             ? "ComObjArray"
                    : TypeCode & 0x4000                                             ? "ComValueRef"
                    : (TypeCode == 9 or TypeCode == 13) and ComObjValue(Value) != 0 ? (ClassName := ComObjType(Value, "Class")) != "" ? ClassName : "ComObject"
                    : "ComValue"
        }
        else
        {
            ; This must avoid executing meta-functions.
            Result        := ObjHasKey(Value, "__Class") ? "Class" : ""
           ,CurrentObject := ObjGetBase(Value)
            while (Result == "" and CurrentObject != "")
            {
                ; This will throw an exception if one of Value's bases is not
                ; Object-based.
                try
                {
                    Result        := ObjRawGet(CurrentObject, "__Class")
                   ,CurrentObject := ObjGetBase(CurrentObject)
                }
                catch
                {
                    CurrentObject := ""
                }
            }
            Result := Result == "" ? "Object" : Result
        }
    }
    else
    {
        Result := IsInteger(Value) ? "Integer"
                : IsFloat(Value)   ? "Float"
                : "String"
    }
    return Result
}

IsNumber(Value) {
    local
    Result := false
    if Value is Number
    {
        Result := true
    }
    return Result
}

IsString(Value){
    local
    return not IsObject(Value)
}

IsInteger(Value){
    local
    Result := false
    if Value is Integer
    {
        Result := true
    }
    return Result
}

HasProp(Value, Name){

    local
    ; This should be updated when a new built-in type or property is added to
    ; AutoHotkey.
    static BuiltIns := {"BoundFunc":  {}
                       ,"Enumerator": {}
                       ,"File":       {".AtEOF":      ""
                                      ,".Encoding":   ""
                                      ,".Length":     ""
                                      ,".Pos":        ""
                                      ,".Position":   ""
                                      ,".__Handle":   ""}
                       ,"Func":       {".IsBuiltIn":  ""
                                      ,".IsVariadic": ""
                                      ,".MaxParams":  ""
                                      ,".MinParams":  ""
                                      ,".Name":       ""}
                       ,"Object":     {}
                       ,"Property":   {}
                       ,"RegExMatch": {}}
    if (ComObjType(Value) != "")
    {
        throw Exception("Type Error", -1
                       ,"HasProp(Value, Name)  Value is a COM object.")
    }
    ; This must avoid executing meta-functions.
    Result := false
    if (Name = "base")
    {
        if (IsObject(Value))
        {
            ; This will throw an exception if Value is not Object-based.
            try
            {
                ObjGetBase(Value)
               ,Result := true
            }
            catch
            {
            }
        }
        else
        {
            Result := true
        }
    }
    else
    {
        CurrentObject := IsObject(Value) ? Value : Value.base
        while (not Result and CurrentObject != "")
        {
            ; Objects can have built-in and user-defined properties.
            if (    BuiltIns.HasKey(Type := Type(CurrentObject))
                and BuiltIns[Type].HasKey("." . Name))
            {
                Result := true
            }
            else
            {
                ; This will throw an exception if Value or one of its bases is
                ; not Object-based.
                try
                {
                    ; ObjHasKey(Object, Key) returns the empty String when Object
                    ; is not Object-based.
                    Result        := ObjHasKey(CurrentObject, Name) ? true : false
                   ,CurrentObject := ObjGetBase(CurrentObject)
                }
                catch
                {
                    CurrentObject := ""
                }
            }
        }
    }
    return Result
}

IsInstance(Value, Class){
    local
    if (not (Type := Type(Class)) == "Class")
    {
        throw Exception("Type Error", -1
                       ,Format("IsInstance(Value, Class)  Class is not a Class.  Class's type is {1}.", Type))
    }
    ; This must avoid executing meta-functions.
    Result := false
    ; This will throw an exception if Value or one of its bases is not
    ; Object-based.
    try
    {
        CurrentObject := ObjGetBase(Value)
    }
    catch
    {
        CurrentObject := ""
    }
    while (not Result and CurrentObject != "")
    {
        try
        {
            Result        := CurrentObject == Class
           ,CurrentObject := ObjGetBase(CurrentObject)
        }
        catch
        {
            CurrentObject := ""
        }
    }
    return Result
}

IsFloat(Value){
    local
    Result := false
    if Value is Float
    {
        Result := true
    }
    return Result
}

HasMethod(Value, Name){
    local
    ; This should be updated when a new built-in type or method is added to
    ; AutoHotkey.
    static BuiltIns := {"BoundFunc":  {".Call":        ""}
                       ,"Enumerator": {".Next":        ""}
                       ,"File":       {".Close":       ""
                                      ,".RawRead":     ""
                                      ,".RawWrite":    ""
                                      ,".Read":        ""
                                      ,".ReadChar":    ""
                                      ,".ReadDouble":  ""
                                      ,".ReadFloat":   ""
                                      ,".ReadInt":     ""
                                      ,".ReadInt64":   ""
                                      ,".ReadLine":    ""
                                      ,".ReadShort":   ""
                                      ,".ReadUChar":   ""
                                      ,".ReadUInt":    ""
                                      ,".ReadUShort":  ""
                                      ,".Seek":        ""
                                      ,".Tell":        ""
                                      ,".Write":       ""
                                      ,".WriteChar":   ""
                                      ,".WriteDouble": ""
                                      ,".WriteFloat":  ""
                                      ,".WriteInt":    ""
                                      ,".WriteInt64":  ""
                                      ,".WriteLine":   ""
                                      ,".WriteShort":  ""
                                      ,".WriteUChar":  ""
                                      ,".WriteUInt":   ""
                                      ,".WriteUShort": ""}
                       ,"Func":       {".Bind":        ""
                                      ,".Call":        ""
                                      ,".IsByRef":     ""
                                      ,".IsOptional":  ""}
                       ,"Object":     {".Clone":       ""
                                      ,".Count":       ""
                                      ,".Delete":      ""
                                      ,".GetAddress":  ""
                                      ,".GetCapacity": ""
                                      ,".HasKey":      ""
                                      ,".Insert":      ""
                                      ,".InsertAt":    ""
                                      ,".Length":      ""
                                      ,".MaxIndex":    ""
                                      ,".MinIndex":    ""
                                      ,".Pop":         ""
                                      ,".Push":        ""
                                      ,".Remove":      ""
                                      ,".RemoveAt":    ""
                                      ,".SetCapacity": ""
                                      ,"._NewEnum":    ""}
                       ,"Property":   {}
                       ,"RegExMatch": {".Count":       ""
                                      ,".Len":         ""
                                      ,".Mark":        ""
                                      ,".Name":        ""
                                      ,".Pos":         ""
                                      ,".Value":       ""}}
    if (ComObjType(Value) != "")
    {
        throw Exception("Type Error", -1
                       ,"HasMethod(Value, Name)  Value is a COM object.")
    }
    ; This must avoid executing meta-functions.
    Result := false
    if (IsObject(Value))
    {
        CurrentObject := Value
       ,CurrentName   := Name
        while (not Result and CurrentObject != "")
        {
            ; Objects can have built-in and user-defined methods.
            if (    BuiltIns.HasKey(Type := Type(CurrentObject))
                and BuiltIns[Type].HasKey("." . CurrentName))
            {
                Result := true
            }
            else
            {
                ; ObjHasKey(Object, Key) does not throw an exception when Object
                ; is not Object-based.
                if (ObjHasKey(CurrentObject, CurrentName))
                {
                    CurrentObject := ObjRawGet(CurrentObject, CurrentName)
                   ,CurrentName   := "Call"
                }
                else
                {
                    ; This will throw an exception if Value or one of its bases
                    ; is not Object-based.
                    try
                    {
                        CurrentObject := ObjGetBase(CurrentObject)
                    }
                    catch
                    {
                        CurrentObject := ""
                    }
                }
            }
        }
    }
    else
    {
        ; Only user-defined methods are both properties and methods.
        Result := HasProp(Value.base, Name) and HasMethod(Value.base, Name)
    }
    return Result
}




