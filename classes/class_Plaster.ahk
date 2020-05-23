; Plaster attempts to fill in the cracks left by AutoHotkey's bad type system
; and introspection capabilities that let bugs in.

; If you just want to use Plaster you do not need to read this file.
;
; The code within is not intended for use outside Plaster.  It may not perform
; sufficient error checking and may change in the future.


class Plaster {
    ; This class is being abused as a namespace.  It is not intended for
    ; instantiation or to represent good object-oriented design.

    class Object {
        __Set(Key, Value) {
            ; Use "=" to match keys regardless of the "StringCaseSense" mode
            ; since AutoHotkey case folds keys.
            if (   (Key = "__Class")
                or (Key = "_NewEnum")
                or (Key = "base")
                or (Key = "Clone")
                or (Key = "GetAddress")
                or (Key = "GetCapacity")
                or (Key = "HasKey")
                or (Key = "Insert")
                or (Key = "MaxIndex")
                or (Key = "MinIndex")
                or (Key = "Remove")
                or (Key = "SetCapacity")) {
                throw Exception("key error", -1, "Dict key """ . Key . """ would overwrite a built-in member")
            }
        }

        __Get(Key) {
            ; Use "=" to match keys regardless of the "StringCaseSense" mode
            ; since AutoHotkey case folds keys.
            if (not (   (Key = "__Class")
                     or (Key = "base"))) {
                throw Exception("key error", -1, "Dict key " . Repr.(Key) . " does not exist")
            }
        }
    }

    class Array {
        __Set(Index, Value) {
            if (not IsType.(Index, "Int")) {
                throw Exception("type error", -1, "Array index " . Repr.(Index) . " is not an Int")
            }
            if (Index < 1) {
                throw Exception("index error", -1, "Array index " . Index . " < 1")
            }
        }

        __Get(Index) {
            ; Use "=" to match keys regardless of the "StringCaseSense" mode
            ; since AutoHotkey case folds keys.
            if (not (   (Index = "__Class")
                     or (Index = "base"))) {
                throw Exception("index error", -1, "Array index " . Repr.(Index) . " does not exist")
            }
        }
    }

    ; Avoid an allocation on each array construction.
    static ArrayBase := new Plaster.Array().base

    Type(Value) {
        ; Type(Any) -> Str
        ;
        ; Return an educated guess about the type of a value.
        ;
        ;
        ;                                Warnings
        ;
        ; "Type" always returns the most specific type that the value could be.
        ; That is not necessarily the correct type.  For example, it will return
        ; "Bool" for "0", when it may be "Int".
        ;
        ; If, or more likely, when, future AutoHotkey releases add more built-in
        ; types "Type" will have to be modified to recognize them.

        static BaseComObj              := ComObjCreate("Scripting.Dictionary")
        static BaseComObjEnum          := BaseComObj._NewEnum()
        static BaseEnum                := new Plaster.Object()._NewEnum()
        static BaseFile                := FileOpen(a_scriptfullpath, "r")
        static BaseFunc                := Func("Plaster.Type")
        static BaseRegExMatch, Garbage := RegExMatch("a" ,"O)a", BaseRegExMatch)

        ; If you try to convert the above to expressions and get their address
        ; the result is incorrect.
        static AddressToType := {NumGet(&BaseComObj)    : "ComObj"
                                ,NumGet(&BaseComObjEnum): "Enum"
                                ,NumGet(&BaseEnum)      : "Enum"
                                ,NumGet(&BaseFile)      : "File"
                                ,NumGet(&BaseFunc)      : "Func"
                                ,NumGet(&BaseRegExMatch): "RegExMatch"}

        if (IsObject(Value)) {
            ValueAddress := NumGet(&Value)
            if (AddressToType.HasKey(ValueAddress)) {
                Result := AddressToType[ValueAddress]
            } else if (Value.__Class != "") {
                ; If you try to access "__Class" on a COM object AutoHotkey
                ; usually throws an exception.
                ;
                ; Most built-in types have no "__Class" field.  "Enum" (both the
                ; AutoHotkey and COM varieties) has a "__Class" field containing
                ; the misleading value "0".
                ;
                ; It seems safest to check for a "__Class" field after built-in
                ; types that can be identified with the address trick.
                ;
                ; The "Object" and "Array" replacement functions cause
                ; dictionaries (objects) and arrays to have correct "__Class"
                ; field values.  This eliminates the need to check the type and
                ; value of all their keys to recognize them.
                Result := Value.__Class
            } else {
                ; While evaluation should not normally reach this point unless
                ; the value is an exception, it is possible to create
                ; dictionaries and arrays that have no "__Class" using the same
                ; tricks used in the "Object" and "Array" replacement functions.
                Count       := 0
                OnlyIntKeys := true
                for Key in Value {
                    ++Count
                    if (not IsType.(Key, "Int")) {
                        OnlyIntKeys := false
                    }
                }
                if (   (Count == 0)
                    or (    OnlyIntKeys
                        and (Value.MinIndex() >= 1))) {
                    Result := "Array"
                } else if (    ((4 <= Count) and (Count <= 5))
                           and IsType.(Value["File"], "Str")
                           and IsType.(Value["Line"], "Int")
                           and IsType.(Value["Message"], "Str")
                           and (    Value.HasKey("What")
                                and (   (Value["What"] == "")
                                     or IsType.(Value["What"], "Str")))
                           and (Count == 5 ? IsType.(Value["Extra"], "Str")
                                           : true)) {
                    Result := "Exception"
                } else {
                    Result := "Dict"
                }
            }
        } else {
            if ((Value == true) or (Value == false)) {
                Result := "Bool"
            } else if Value is integer
            {
                Result := "Int"
            } else if Value is float
            {
                Result := "Float"
            } else if (Value == "") {
                Result := "Null"
            } else {
                Result := "Str"
            }
        }
        return Result
    }

    static BuiltInTypeInfo := {}

    Address(Value) {
        ; Address(Object) -> Str
        ;
        ; Return a string representing the address of the value.

        OrigFormatInteger := a_formatinteger
        SetFormat, IntegerFast, H
        HexAddress := SubStr(&Value, 3)
        SetFormat, IntegerFast, %OrigFormatInteger%
        Leading0s := ""
        loop % (a_ptrsize * 2) - StrLen(HexAddress) {
            Leading0s .= "0"
        }
        return "0x" . Leading0s . HexAddress
    }

    IsIdentifier(Identifier) {
        ; IsIdentifier(Str) -> Bool
        ;
        ; Return whether a string is an identifier.
        ;
        ; This is useful for error checking.

        RegExMatch(Identifier, "OS)(*UCP)^[^\d\W]\w*$", IdentifierRegExMatch)
        return IdentifierRegExMatch[0] != ""
    }

    FuncCallRepr(Function, Args) {
        ; FuncCallRepr(Null or Str, Array(Any ...)) -> Str
        ;
        ; Return a string representing a function call.
        ;
        ; This is useful for error reporting.

        return Function . "(" . SubStr(Repr.(Args), 2, -1) . ")"
    }
}

; Remove the "Plaster." prefix.
; Avoid an assignment on each array construction.
ObjInsert(Plaster.ArrayBase, "__Class", "Array")

; Work around the nonsensical expression length limit.
Plaster.BuiltInTypeInfo["Null"]       := {".base"     : ""
                                         ,"Properties": ""
                                         ,"Methods"   : ""}
Plaster.BuiltInTypeInfo["Object"]     := {".base"     : ""
                                         ,"Properties": ""
                                         ,"Methods"   : ""}
Plaster.BuiltInTypeInfo["ComObj"]     := {".base"     : "Object"
                                         ,"Properties": ""
                                         ,"Methods"   : ""}
Plaster.BuiltInTypeInfo["Dict"]       := {".base"     : "Object"
                                         ,"Properties": ""
                                         ,"Methods"   : {".Clone"      : {"MinParams": 1, "MaxParams": 1, "IsVariadic": false}
                                                        ,".GetAddress" : {"MinParams": 2, "MaxParams": 2, "IsVariadic": false}
                                                        ,".GetCapacity": {"MinParams": 1, "MaxParams": 2, "IsVariadic": false}
                                                        ,".HasKey"     : {"MinParams": 2, "MaxParams": 2, "IsVariadic": false}
                                                        ,".Insert"     : {"MinParams": 2, "MaxParams": 2, "IsVariadic": true}
                                                        ,".MaxIndex"   : {"MinParams": 1, "MaxParams": 1, "IsVariadic": false}
                                                        ,".MinIndex"   : {"MinParams": 1, "MaxParams": 1, "IsVariadic": false}
                                                        ,".Remove"     : {"MinParams": 1, "MaxParams": 3, "IsVariadic": false}
                                                        ,".SetCapacity": {"MinParams": 2, "MaxParams": 3, "IsVariadic": false}
                                                        ,"._NewEnum"   : {"MinParams": 1, "MaxParams": 1, "IsVariadic": false}}}
Plaster.BuiltInTypeInfo["Array"]      := {".base"     : "Dict"
                                         ,"Properties": ""
                                         ,"Methods"   : ""}
Plaster.BuiltInTypeInfo["Exception"]  := {".base"     : "Dict"
                                         ,"Properties": ""
                                         ,"Methods"   : ""}
Plaster.BuiltInTypeInfo["Enum"]       := {".base"     : "Object"
                                         ,"Properties": ""
                                         ,"Methods"   : {".Next": ""}}
Plaster.BuiltInTypeInfo["File"]       := {".base"     : "Object"
                                         ,"Properties": {".AtEOF"   : ""
                                                        ,".Encoding": ""
                                                        ,".Length"  : ""
                                                        ,".Pos"     : ""
                                                        ,".Position": ""
                                                        ,".__Handle": ""}
                                         ,"Methods"   : {".Close"      : {"MinParams": 1, "MaxParams": 1, "IsVariadic": false}
                                                        ,".RawRead"    : {"MinParams": 3, "MaxParams": 3, "IsVariadic": false}
                                                        ,".RawWrite"   : {"MinParams": 3, "MaxParams": 3, "IsVariadic": false}
                                                        ,".Read"       : {"MinParams": 1, "MaxParams": 2, "IsVariadic": false}
                                                        ,".ReadChar"   : {"MinParams": 1, "MaxParams": 1, "IsVariadic": false}
                                                        ,".ReadDouble" : {"MinParams": 1, "MaxParams": 1, "IsVariadic": false}
                                                        ,".ReadFloat"  : {"MinParams": 1, "MaxParams": 1, "IsVariadic": false}
                                                        ,".ReadInt"    : {"MinParams": 1, "MaxParams": 1, "IsVariadic": false}
                                                        ,".ReadInt64"  : {"MinParams": 1, "MaxParams": 1, "IsVariadic": false}
                                                        ,".ReadLine"   : {"MinParams": 1, "MaxParams": 1, "IsVariadic": false}
                                                        ,".ReadShort"  : {"MinParams": 1, "MaxParams": 1, "IsVariadic": false}
                                                        ,".ReadUChar"  : {"MinParams": 1, "MaxParams": 1, "IsVariadic": false}
                                                        ,".ReadUInt"   : {"MinParams": 1, "MaxParams": 1, "IsVariadic": false}
                                                        ,".ReadUShort" : {"MinParams": 1, "MaxParams": 1, "IsVariadic": false}
                                                        ,".Seek"       : {"MinParams": 2, "MaxParams": 3, "IsVariadic": false}
                                                        ,".Tell"       : {"MinParams": 1, "MaxParams": 1, "IsVariadic": false}
                                                        ,".Write"      : {"MinParams": 2, "MaxParams": 2, "IsVariadic": false}
                                                        ,".WriteChar"  : {"MinParams": 2, "MaxParams": 2, "IsVariadic": false}
                                                        ,".WriteDouble": {"MinParams": 2, "MaxParams": 2, "IsVariadic": false}
                                                        ,".WriteFloat" : {"MinParams": 2, "MaxParams": 2, "IsVariadic": false}
                                                        ,".WriteInt"   : {"MinParams": 2, "MaxParams": 2, "IsVariadic": false}
                                                        ,".WriteInt64" : {"MinParams": 2, "MaxParams": 2, "IsVariadic": false}
                                                        ,".WriteLine"  : {"MinParams": 1, "MaxParams": 2, "IsVariadic": false}
                                                        ,".WriteShort" : {"MinParams": 2, "MaxParams": 2, "IsVariadic": false}
                                                        ,".WriteUChar" : {"MinParams": 2, "MaxParams": 2, "IsVariadic": false}
                                                        ,".WriteUInt"  : {"MinParams": 2, "MaxParams": 2, "IsVariadic": false}
                                                        ,".WriteUShort": {"MinParams": 2, "MaxParams": 2, "IsVariadic": false}}}
Plaster.BuiltInTypeInfo["Func"]       := {".base"     : "Object"
                                         ,"Properties": {".IsBuiltIn" : ""
                                                        ,".IsVariadic": ""
                                                        ,".MaxParams" : ""
                                                        ,".MinParams" : ""
                                                        ,".Name"      : ""}
                                         ,"Methods"   : {".IsByRef"   : {"MinParams": 1, "MaxParams": 2, "IsVariadic": false}
                                                        ,".IsOptional": {"MinParams": 1, "MaxParams": 2, "IsVariadic": false}}}
Plaster.BuiltInTypeInfo["RegExMatch"] := {".base"     : "Object"
                                         ,"Properties": {".Count": ""
                                                        ,".Len"  : ""
                                                        ,".Mark" : ""
                                                        ,".Name" : ""
                                                        ,".Pos"  : ""
                                                        ,".Value": ""}
                                         ,"Methods"   : {".Count": {"MinParams": 1, "MaxParams": 1, "IsVariadic": false}
                                                        ,".Len"  : {"MinParams": 1, "MaxParams": 2, "IsVariadic": false}
                                                        ,".Mark" : {"MinParams": 1, "MaxParams": 1, "IsVariadic": false}
                                                        ,".Name" : {"MinParams": 1, "MaxParams": 2, "IsVariadic": false}
                                                        ,".Pos"  : {"MinParams": 1, "MaxParams": 2, "IsVariadic": false}
                                                        ,".Value": {"MinParams": 1, "MaxParams": 2, "IsVariadic": false}}}
Plaster.BuiltInTypeInfo["Str"]        := {".base"     : ""
                                         ,"Properties": ""
                                         ,"Methods"   : ""}
Plaster.BuiltInTypeInfo["Float"]      := {".base"     : "Str"
                                         ,"Properties": ""
                                         ,"Methods"   : ""}
Plaster.BuiltInTypeInfo["Int"]        := {".base"     : "Str"
                                         ,"Properties": ""
                                         ,"Methods"   : ""}
Plaster.BuiltInTypeInfo["Bool"]       := {".base"     : "Int"
                                         ,"Properties": ""
                                         ,"Methods"   : ""}

Object(Args*) {
    ; Object(Any ...) -> Dict(Any: Any ...)
    ;
    ; Return a dictionary containing the arguments that can be quickly
    ; type-checked by "IsType" and sanity checks its use.

    if (Args.MaxIndex() & 1) {
        throw Exception("type error", -1, Plaster.FuncCallRepr("Object", Args) . " odd number of arguments")
    }
    Index := 1
    Result := new Plaster.Object()
    while (Index < Args.MaxIndex()) {
        try {
            Result[Args[Index]] := Args[Index + 1]
        } catch Exc {
            throw Exception(Exc["Message"], -1, Exc["Extra"])
        }
        Index += 2
    }
    ; Remove the "Plaster." prefix.
    ObjInsert(Result.base, "__Class", "Dict")
    return Result
}

Array(Args*) {
    ; Array(Any ...) -> Array(Any ...)
    ;
    ; Return an array containing the arguments that can be quickly type-checked
    ; by "IsType" and sanity checks its use.

    Args.base := Plaster.ArrayBase
    return Args
}

IsType(Value, Type) {
    ; IsType(Any, Str) -> Bool
    ;
    ; Return whether the value is an instance of the type.
    ;
    ; The following built-in types are recognized:
    ; Null
    ; Object
    ;     ComObj
    ;     Dict
    ;         Array
    ;         Exception
    ;     Enum
    ;     File
    ;     Func
    ;     RegExMatch
    ; Str
    ;     Float
    ;     Int
    ;         Bool
    ;
    ; Indention indicates their location in the type hierarchy.  Most types
    ; should be familiar to AutoHotkey programmers.  "Null" is the empty string.
    ; "Dict" is an "Object", that is not an instance of a user-defined type, and
    ; has keys that are not exclusively integers or are less than 1.  "Str" is
    ; anything that is not "Null" or an "Object".  "Bool" is "true" or "false".
    ;
    ; User-defined types (using classes) are also recognized.  Instances of
    ; subtypes are properly recognized as being instances of their supertypes.
    ;
    ; User-defined types can be marked as a subtype of a built-in object type.
    ; This will cause "IsType" to allow it anywhere the built-in type is
    ; allowed.  You will still need to implement all the members of the built-in
    ; supertype yourself.
    ;
    ; To mark a user-defined type as a subtype of a built-in type, include a
    ; line like:
    ; static BuiltInBase := "BuiltInTypeName"
    ; in your class definition outside any methods.  "BuiltInTypeName" will need
    ; to be replaced with the name of an actual built-in type, like "Func".
    ; This only works with "Object" and its subtypes, because it is impossible
    ; to make a class behave like a "non-object" type due to the lack of
    ; operator overloading.
    ;
    ;
    ;                                  Warnings
    ;
    ; If you define a type with the same name as a built-in type, code will
    ; usually break.  This is true whether or not you use Plaster.  Plaster's
    ; type names are usually the same as the class or function that constructs
    ; them.  Your class will make the original inaccessible, usually making it
    ; impossible to construct.
    ;
    ; If you mark your type as a subtype of a built-in type and you do not
    ; define a "Repr" method, Plaster will use the default algorithm for
    ; representing that type.  Be sure that works, or that you define an
    ; appropriate "Repr" method.

    ; We must exhaustively check for string types here, because recursing at
    ; this point would lead to infinite recursion.
    TypeType := Plaster.Type(Type)
    if TypeType not in Str,Float,Int,Bool
    {
        throw Exception("type error", -1, Plaster.FuncCallRepr("IsType", [Value, Type]) . " the Type argument " . Repr.(Type) . " is not a Str")
    }
    for Garbage, Identifier in StrSplit(Type, ".") {
        if (not Plaster.IsIdentifier(Identifier)) {
            throw Exception("value error", -1, Plaster.FuncCallRepr("IsType", [Value, Type]) . " the Type argument " . Repr.(Type) . " is not a valid qualified identifier")
        }
    }
    CurrentObject := Value
    CurrentType   := Plaster.Type(Value)
    ; Use "=" to allow case-insensitive matches.
    while (not (   (CurrentType = Type)
                or (CurrentType == ""))) {
        if (Plaster.BuiltInTypeInfo.HasKey(CurrentType)) {
            CurrentType := Plaster.BuiltInTypeInfo[CurrentType][".base"]
        } else {
            if (CurrentObject.base != "") {
                CurrentObject := CurrentObject.base
                CurrentType   := Plaster.Type(CurrentObject)
            } else {
                ; "Object" is the default supertype of user-defined types.
                CurrentType := CurrentObject.BuiltInBase != ""
                               ? CurrentObject.BuiltInBase
                               : "Object"
            }
        }
    }
    ; Use "=" to allow case-insensitive matches.
    return CurrentType = Type
}

HasProperty(Value, PropertyName) {
    ; HasProperty(Any, Str) -> Bool
    ;
    ; Return whether the value has the property.
    ;
    ; "HasProperty" supports the "properties" feature of AutoHotkey that allows
    ; methods to imitate a property.
    ;
    ;
    ;                                  Warnings
    ;
    ; "HasProperty" does not currently support Automation objects.  It will
    ; always return false, even if the property exists on the Automation object.
    ;
    ; "HasProperty", by design, does not report the keys or indices of built-in
    ; types as properties of that type.
    ;
    ; "HasProperty" returning true only guarantees the property exists and is
    ; readable, not that it is the type you desire or writable.

    if (not IsType.(PropertyName, "Str")) {
        throw Exception("type error", -1, Plaster.FuncCallRepr("HasProperty", [Value, PropertyName]) . " the PropertyName argument " . Repr.(PropertyName) . " is not a Str")
    }
    if (not Plaster.IsIdentifier(PropertyName)) {
        throw Exception("value error", -1, Plaster.FuncCallRepr("HasProperty", [Value, PropertyName]) . " the PropertyName argument " . Repr.(PropertyName) . " is not a valid identifier")
    }
    Result := false
    ; Handle the default base object being set.
    CurrentObject := Value == "" ? Value.base.base : Value
    while (    (Result == false)
           and (CurrentObject != "")) {
        CurrentType := Plaster.Type(CurrentObject)
        if (Plaster.BuiltInTypeInfo.HasKey(CurrentType)) {
            if (IsObject(CurrentObject)) {
                ; Handle properties of built-in object types.
                ;
                ; Work around being unable to store dictionary property names in
                ; "Plaster.BuiltInTypeInfo".
                DotPropertyName := "." . PropertyName
                while (    (Result == false)
                       and (CurrentType != "")) {
                    ; This "if" is necessary to correctly handle the default
                    ; base object having "HasKey".
                    if (Plaster.BuiltInTypeInfo[CurrentType]["Properties"] != "") {
                        Result := Plaster.BuiltInTypeInfo[CurrentType]["Properties"].HasKey(DotPropertyName)
                    }
                    CurrentType := Plaster.BuiltInTypeInfo[CurrentType][".base"]
                }
                CurrentObject := ""  ; Force termination.
            } else {
                ; Handle properties of "non-object" types.
                CurrentObject := CurrentObject.base.base
            }
        } else {
            ; Handle properties of user-defined types.
            ;
            ; Using "ObjHasKey" is necessary to correctly handle "HasKey" being
            ; redefined.
            Result := ObjHasKey(CurrentObject, PropertyName)
            CurrentObject := CurrentObject.base
        }
    }
    return Result
}

HasMethod(Value, MethodName, MinParams, MaxParams, IsVariadic) {
    ; HasMethod(Any, Str, Int, Int, Bool) -> Bool
    ;
    ; Return whether the value has a method matching the signature.
    ;
    ;
    ;                                  Warnings
    ;
    ; "HasMethod" does not currently support Automation objects.  It will always
    ; return false, even if the method exists on the Automation object.
    ;
    ; Do not forget the implicit "this" parameter when calculating "MinParams"
    ; and "MaxParams".
    ;
    ; "HasMethod", by design, does not report functions (including methods)
    ; stored in built-in types as methods of that type.
    ;
    ; "HasMethod" returning true only guarantees the method exists and can be
    ; called with a certain number of arguments, not that it can be stored in a
    ; variable or data structure (built-in methods cannot) or that it will work
    ; correctly with the arguments you pass.

    if (not IsType.(MethodName, "Str")) {
        throw Exception("type error", -1, Plaster.FuncCallRepr("HasMethod", [Value, MethodName, MinParams, MaxParams, IsVariadic]) . " the MethodName argument " . Repr.(MethodName) . " is not a Str")
    }
    if (not Plaster.IsIdentifier(MethodName)) {
        throw Exception("value error", -1, Plaster.FuncCallRepr("HasMethod", [Value, MethodName, MinParams, MaxParams, IsVariadic]) . " the MethodName argument " . Repr.(MethodName) . " is not a valid identifier")
    }
    if (not IsType.(MinParams, "Int")) {
        throw Exception("type error", -1, Plaster.FuncCallRepr("HasMethod", [Value, MethodName, MinParams, MaxParams, IsVariadic]) . " the MinParams argument " . Repr.(MinParams) . " is not an Int")
    }
    if (not IsType.(MinParams, "Int")) {
        throw Exception("type error", -1, Plaster.FuncCallRepr("HasMethod", [Value, MethodName, MinParams, MaxParams, IsVariadic]) . " the MaxParams argument " . Repr.(MaxParams) . " is not an Int")
    }
    if (MinParams > MaxParams) {
        throw Exception("value error", -1, Plaster.FuncCallRepr("HasMethod", [Value, MethodName, MinParams, MaxParams, IsVariadic]) . " the MinParams argument " . MinParams . " > the MaxParams argument " . MaxParams)
    }
    if (not IsType.(IsVariadic, "Bool")) {
        throw Exception("type error", -1, Plaster.FuncCallRepr("HasMethod", [Value, MethodName, MinParams, MaxParams, IsVariadic]) . " the IsVariadic argument " . Repr.(IsVariadic) . " is not a Bool")
    }
    Result := false
    ; Handle the default base object being set.
    CurrentObject := Value == "" ? Value.base.base : Value
    while (    (Result == false)
           and (CurrentObject != "")) {
        CurrentType := Plaster.Type(CurrentObject)
        if (Plaster.BuiltInTypeInfo.HasKey(CurrentType)) {
            if (IsObject(CurrentObject)) {
                ; Handle methods of built-in object types.
                ;
                ; Work around being unable to store dictionary method names in
                ; "Plaster.BuiltInTypeInfo".
                DotMethodName := "." . MethodName
                while (    (Result == false)
                       and (CurrentType != "")) {
                    ; This "if" is necessary to correctly handle the default
                    ; base object having "HasKey".
                    if (Plaster.BuiltInTypeInfo[CurrentType]["Methods"] != "") {
                        Result :=     Plaster.BuiltInTypeInfo[CurrentType]["Methods"].HasKey(DotMethodName)
                                  and MinParams  == Plaster.BuiltInTypeInfo[CurrentType]["Methods"][DotMethodName]["MinParams"]
                                  and MaxParams  == Plaster.BuiltInTypeInfo[CurrentType]["Methods"][DotMethodName]["MaxParams"]
                                  and IsVariadic == Plaster.BuiltInTypeInfo[CurrentType]["Methods"][DotMethodName]["IsVariadic"]
                    }
                    CurrentType := Plaster.BuiltInTypeInfo[CurrentType][".base"]
                }
                CurrentObject := ""  ; Force termination.
            } else {
                ; Handle methods of "non-object" types.
                CurrentObject := CurrentObject.base.base
            }
        } else {
            ; Handle methods of user-defined types.
            ;
            ; Using "ObjHasKey" is necessary to correctly handle "HasKey" being
            ; redefined.
            Result :=     ObjHasKey(CurrentObject, MethodName)
                      and IsType.(CurrentObject[MethodName], "Func")
                      and MinParams  == CurrentObject[MethodName].MinParams
                      and MaxParams  == CurrentObject[MethodName].MaxParams
                      and IsVariadic == CurrentObject[MethodName].IsVariadic
            CurrentObject := CurrentObject.base
        }
    }
    return Result
}

Repr(Value) {
    ; Repr(Any) -> Str
    ;
    ; Convert a value to a string representing the value.
    ;
    ; "Repr" attempts to return a string containing AutoHotkey source code that
    ; will produce the value of its argument.  When this is impossible, "Repr"
    ; reports what useful information it can between "<" and ">".
    ;
    ; User-defined types can define a method with the signature:
    ; Repr() -> Str
    ; that this function will use to convert them to a string.
    ;
    ;
    ;                                  Warnings
    ;
    ; AutoHotkey conflates dictionary, array, exception, and user-defined types,
    ; and integer and Boolean types.  The notation differs between them.  "Repr"
    ; assumes the type that is used most often when it cannot discriminate based
    ; on the value.
    ;
    ; Empty dictionaries created via the technique used in "Object" are
    ; represented as arrays.
    ;
    ; Exceptions are represented as dictionaries.  Representing them as they
    ; would be constructed would not produce the same value.
    ;
    ; Booleans are represented as integers.
    ;
    ; "Repr" does not attempt to handle reference cycles, but neither does
    ; AutoHotkey.

    ; "IsType" is used instead of "Plaster.Type" to assure that the type
    ; hierarchy is handled correctly.
    if (IsObject(Value)) {
        if (HasMethod.(Value, "Repr", 1, 1, false)) {
            Result := Value.Repr()
            if (not IsType.(Result, "Str")) {
                throw Exception("type error", -1, "<?>.Repr() invalid string representation returned")
            }
        } else {
            if (IsType.(Value, "Array")) {
                Result := "["
                loop % Value.MaxIndex() {
                    if (a_index != 1) {
                        Result .= ","
                    }
                    if (Value.HasKey(a_index)) {
                        if (a_index != 1) {
                            Result .= " "
                        }
                        Result .= Repr.(Value[a_index])
                    }
                }
                Result .= "]"
            } else if (IsType.(Value, "Dict")) {
                Result := "{"
                FirstElement := true
                for DictKey, DictValue in Value {
                    if (not FirstElement) {
                        Result .= ", "
                    }
                    Result .= Repr.(DictKey) . ": " . Repr.(DictValue)
                    FirstElement := false
                }
                Result .= "}"
            } else if (IsType.(Value, "Func")) {
                Result := "Func(""" . Value.Name . """)"
            } else if (IsType.(Value, "ComObj")) {
                Result := "<ComObj " . ComObjType(Value, "Name") . " at " . Plaster.Address(Value) . ">"
            } else {
                ; We cannot report any information other than the type.
                ;
                ; Currently used by:
                ; Enum
                ; File
                ; RegExMatch
                ; user-defined types without a Repr() method
                Result := "<" . Plaster.Type(Value) . " at " . Plaster.Address(Value) . ">"
            }
        }
    } else {
        if (   IsType.(Value, "Int")
            or IsType.(Value, "Float")) {
            Result := Value
        } else {
            Result := """"
            static EscapeSequences := {"`t": "``t"
                                      ,"`n": "``n"
                                      ,"`r": "``r"
                                      ,"""": """"""
                                      ,"``": "````"}
            loop, parse, Value
            {
                if (EscapeSequences.HasKey(a_loopfield)) {
                    Result .= EscapeSequences[a_loopfield]
                } else {
                    Result .= a_loopfield
                }
            }
            Result .= """"
        }
    }
    return Result
}

global Object         	:= Func("Object")
global Array          	:= Func("Array")
global IsType         	:= Func("IsType")
global HasProperty	:= Func("HasProperty")
global HasMethod 	:= Func("HasMethod")
global Repr          	:= Func("Repr")
