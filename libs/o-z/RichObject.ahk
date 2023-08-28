RichObject()
{
    return new CRichObject()
}
Class CRichObject
{
    ; Checks if an object is the instance of a class. Class can be either class name or class object.
    Is(Class)
    {
        if (!Class)
            throw Exception("Invalid Class", -1)
        if (this.base.HasKey("__Class"))
            return IsObject(Class) ? (this.base = Class) : (this.base.__Class = Class)
        return 0
    }

    Extends(Class)
    {
        obj := this
        while(obj.Base)
        {
            obj := obj.base
            if (obj.__Class = Class)
                return true
        }
        return false
    }

    DeepCopy(reserved = 0)
    {
        if !reserved
            reserved := object("copied" . &this, 1)  ; to keep track of unique objects within top object
        if !isobject(this)
            return this
        func := "CRichObject.DeepCopy"
        if (IsObject(this.base) && this.base.HasKey("__Class"))
            copy := Object("base", this.base)
        else
            copy := object("base", %func%(this.base))
        enum := ObjNewEnum(this)
        while enum[key, value]
        {
            if reserved["copied" . &value]
                continue  ; don't copy repeat objects (circular references)
            if (IsObject(value))
                copy.Insert(key, %func%(value, reserved))
            else
                copy.Insert(key, value)
        }
        return copy
    }

    ToString(reserved = 0)
    {
        if !isobject(this)
            return " " this " "

        if !reserved
            reserved := object("seen" . &this, 1)  ; to keep track of unique objects within top object

        for key, value in this
        {
            if reserved["seen" . &value]
                string .= key . ": WARNING: CIRCULAR OBJECT SKIPPED !!!`n "
            else
                string .= key . ": " . value.Print(reserved)
        }
        return "(" string ") "
    }

    Equals(y, reserved=0)
    {
        if !reserved
            reserved := object("seen" . &this, 1)  ; to keep track of unique objects within top object

        if !(this != y) ; equal non-object values or exact same object
            return 1 ; note != obeys StringCaseSense, unlike = and ==
        if !isobject(this)
            return 0 ; unequal non-object value
        ; recursively compare contents of both objects:
        enumthis := this._newenum()
        enumy := y._newenum()
        while enumthis[thiskey, thisvalue] && enumy[ykey, yvalue]
        {
            if (thiskey != ykey)
                return 0

            if reserved["seen" . &value]
                continue  ; don't compare repeat objects (circular references)

            if !thisvalue.Equals(yvalue)
                return 0
        }
        ; finally, check that there are no excess key-value pairs in y:
        return ! enumy[ykey]
    }

    FindKeyWithValue(subitem, val){
        for k, v in this
          If (IsObject(v) && v[subitem] = val )
             Return, k
        Return 0
    }

    FindKeyWithValueBetween(subitem, val, val2){
        if (IsObject(val))
        {
            for k, v in this
              If (IsObject(v) && v[subitem] = val )
                 Return, k
            return 0
        }
        if (val2 = "")
            val2 := val
        Loop % this.MaxIndex()
            if (IsObject(this[A_Index]) && this[A_Index][subitem] >= val && this[A_Index][subitem] <= val2)
                Return A_Index
        Return 0
    }

    GetItemWithValue(subitem, val)
    {
        for k, v in this
          If (IsObject(v) && v[subitem] = val )
             Return, v
         Return ""
    }

    IsCircular(reserved=0)
    {
        if !reserved
            reserved := object("seen" . &this, 1)  ; to keep track of unique objects within top object

        if !isobject(this)
            return " " this " "
        for key, value in this
        {
            if reserved["seen" . &value]
            {
                msgbox error: circular references not supported
                return 1
            }
            value.IsCircular(reserved)
        }
        return 0
    }

    Flatten(reserved=0)
    {
        if !isobject(this)
            return this
        if !reserved
            reserved := object("seen" . &this, 1)  ; to keep track of unique objects within top object

        flat := new CRichObject() ; flat object

        for key, value in this
        {
            if !isobject(value)
                flat._Insert(value)
            else
            {
                if reserved["seen" . &value]
                    continue
                next := value.Flatten(reserved)
                loop % next._MaxIndex()
                    flat._Insert(next[A_Index])
            }
        }
        return flat
    }

    Count()
    {
        count := 0
        for key, value in this
            count++
        ; Debug("count " count)
        return count
    }
}
