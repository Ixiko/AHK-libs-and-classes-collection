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
