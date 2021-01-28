Is(Value, Type)
{
    local
    Result := false
    if ({"integer": ""
        ,"float":   ""
        ,"number":  ""
        ,"digit":   ""
        ,"xdigit":  ""
        ,"alpha":   ""
        ,"upper":   ""
        ,"lower":   ""
        ,"alnum":   ""
        ,"space":   ""
        ,"time":    ""}.HasKey(Type))
    {
        if Value is %Type%
        {
            Result := true
        }
    }
    else if (Type = "object")
    {
        Result := IsObject(Value)
    }
    else
    {
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
                Result        := CurrentObject == Type
                CurrentObject := ObjGetBase(CurrentObject)
            }
            catch
            {
                CurrentObject := ""
            }
        }
    }
    return Result
}
