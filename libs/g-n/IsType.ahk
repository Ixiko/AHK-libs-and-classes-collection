#Include <Is>

Type(Value)
{
    local
    ; This should be updated when a new built-in type is added to AutoHotkey.
    static BoundFunc     := Func("Type").Bind("")
    static ComObjEnum    := ComObjCreate("Scripting.Dictionary")._NewEnum()
    static Enum          := {}._NewEnum()
    static File          := FileOpen(a_scriptfullpath, "r")
    static Func          := Func("Type")
    static RegExMatch, _ := RegExMatch("a" ,"O)a", RegExMatch)
    ; If you try to convert the above to expressions and get the addresses, the
    ; result is incorrect.
    static TypeFromAddress := {NumGet(&BoundFunc):  "BoundFunc"
                              ,NumGet(&ComObjEnum): "ComObject.Enumerator"
                              ,NumGet(&Enum):       "Object.Enumerator"
                              ,NumGet(&File):       "File"
                              ,NumGet(&Func):       "Func"
                              ,NumGet(&RegExMatch): "RegExMatch"}
    if (Is(Value, "object"))
    {
        if (TypeFromAddress.HasKey(NumGet(&Value)))
        {
            Result := TypeFromAddress[NumGet(&Value)]
        }
        else if (ComObjType(Value) != "")
        {
            if (ComObjType(Value) & 0x2000)
            {
                Result := "ComObjArray"
            }
            else if (ComObjType(Value) & 0x4000)
            {
                Result := "ComObjRef"
            }
            else if (    (ComObjType(Value) == 9 or ComObjType(Value) == 13)
                     and ComObjValue(Value) != 0                            )
            {
                Result := ComObjType(Value, "Class") != "" ? ComObjType(Value, "Class")
                        : "ComObject"
            }
            else
            {
                Result := "ComObj"
            }
        }
        else
        {
            ; This is complicated because it must avoid running meta-functions.
            Result        := ObjHasKey(Value, "__Class") ? "Class" : ""
            CurrentObject := Value
            while (Result == "" and CurrentObject != "")
            {
                try
                {
                    Result        := ObjRawGet(CurrentObject, "__Class")
                    CurrentObject := ObjGetBase(CurrentObject)
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
        Result := Is(Value, "integer") ? "Integer"
                : Is(Value, "float")   ? "Float"
                : "String"
    }
    return Result
}
