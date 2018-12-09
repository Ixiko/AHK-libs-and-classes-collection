class HashTable
{
    __New()
    {
        ; The Buckets property is intended for internal use only.
        ;
        ; An AutoHotkey Array takes the place of the array that would normally
        ; be used to implement a hash table.
        ;
        ; Masking to remove the unwanted high bits to fit within the array
        ; bounds is unnecessary because AutoHotkey Arrays are sparse arrays that
        ; support negative indexes.
        ;
        ; Rehashing everything and placing it in a new array that has the next
        ; highest power of 2 elements when over 3/4ths of the buckets are full
        ; is unnecessary for the same reason.
        local
        this.Buckets := []
        this.Count   := 0
        return this
    }

    GetHash(Key)
    {
        ; GetHash(Key) is intended for internal use only.  It is used to find
        ; the bucket a key would be stored in.
        local
        if (not IsObject(Key))
        {
            if Key is integer
            {
                HashCode := Key
            }
            else if Key is float
            {
                RoundedValue := Round(Key)
                if (Key == RoundedValue)
                {
                    HashCode := RoundedValue
                }
                else
                {
                    ; This reinterpret casts a floating point number to an
                    ; integer with the same bitwise representation.
                    ;
                    ; Removing the first step will result in warnings about
                    ; reading an uninitialized variable if warnings are turned
                    ; on.
                    VarSetCapacity(HashCode, 8)
                    NumPut(Key, HashCode,, "Double")
                    HashCode := NumGet(HashCode,, "Int64")
                }
            }
            else
            {
                ; This is the string hashing algorithm used in Java.  It makes
                ; use of the wrap around in integer overflow.
                HashCode := 0
                loop parse, Key
                {
                    HashCode := 31 * HashCode + Ord(A_LoopField)
                }
            }
        }
        else
        {
            HashCode := &Key
        }
        return HashCode
    }

    HasKey(Key, HashCode := "")
    {
        ; The HashCode optional parameter is intended for internal use only.  It
        ; is used to avoid repeated hashing.
        ;
        ; HasKey(Key) has the side effect of moving whatever was searched for to
        ; the start of the bucket's chain if it is not already there.  This
        ; speeds future lookups.
        ;
        ; Set(Key, Value) and Get(Key) require almost identical logic, so they
        ; use HasKey(Key) internally to avoid code duplication.  They depend on
        ; the chain reordering behavior.
        local
        Found        := false
        if (HashCode == "")
        {
            HashCode := this.GetHash(Key)
        }
        Item         := this.Buckets.HasKey(HashCode) ? this.Buckets[HashCode]
                                                      : ""
        PreviousItem := ""
        while ((not Found) and (Item != ""))
        {
            if (Item.Key == Key)
            {
                if (PreviousItem != "")
                {
                    PreviousItem.Next      := Item.Next
                    Item.Next              := this.Buckets[HashCode]
                    this.Buckets[HashCode] := Item
                }
                Found := true
            }
            else
            {
                PreviousItem := Item
                Item         := Item.Next
            }
        }
        return Found
    }

    Set(Key, Value)
    {
        local
        HashCode := this.GetHash(Key)
        if (this.HasKey(Key, HashCode))
        {
            this.Buckets[HashCode].Value := Value
        }
        else
        {
            Next := this.Buckets.HasKey(HashCode) ? this.Buckets[HashCode] : ""
            this.Buckets[HashCode] := {"Key":   Key
                                      ,"Value": Value
                                      ,"Next":  Next}
            this.Count             += 1
        }
        return Value
    }

    Get(Key)
    {
        local
        HashCode := this.GetHash(Key)
        if (this.HasKey(Key, HashCode))
        {
            Value := this.Buckets[HashCode].Value
        }
        else
        {
            throw Exception("Key Error", -1, "Key not found.")
        }
        return Value
    }

    Delete(Key)
    {
        ; Delete(Key) does not use HasKey(Key) internally because only the
        ; chain traversal logic is the same and reordering the chain would
        ; waste time.
        local
        Found        := false
        HashCode     := this.GetHash(Key)
        Item         := this.Buckets.HasKey(HashCode) ? this.Buckets[HashCode]
                                                      : ""
        PreviousItem := ""
        while (not Found)
        {
            if (Item == "")
            {
                throw Exception("Key Error", -1, "Key not found.")
            }
            if (Item.Key == Key)
            {
                if (PreviousItem == "")
                {
                    if (Item.Next == "")
                    {
                        this.Buckets.Delete(HashCode)
                    }
                    else
                    {
                        this.Buckets[HashCode] := Item.Next
                    }
                }
                else
                {
                    PreviousItem.Next := Item.Next
                }
                this.Count -= 1
                Value      := Item.Value
                Found      := true
            }
            else
            {
                PreviousItem := Item
                Item         := Item.Next
            }
        }
        return Value
    }

    class Enum
    {
        __New(HashTable)
        {
            ; The BucketsEnum and PreviousItem properties are intended for
            ; internal use only.  They are used to store the stopping place
            ; across calls to Next(byref Key, byref Value).
            local
            this.BucketsEnum  := HashTable.Buckets._NewEnum()
            this.PreviousItem := ""
            return this
        }

        Next(byref Key, byref Value)
        {
            local
            if ((this.PreviousItem == "") or (this.PreviousItem.Next == ""))
            {
                Result := this.BucketsEnum.Next(Garbage, Item)
            }
            else
            {
                Item   := this.PreviousItem.Next
                Result := true
            }
            if (Result)
            {
                Key               := Item.Key
                Value             := Item.Value
                this.PreviousItem := Item
            }
            return Result
        }
    }

    _NewEnum()
    {
        local
        global HashTable
        return new HashTable.Enum(this)
    }

    Clone()
    {
        local
        global HashTable
        Clone := new HashTable()
        ; Avoid rehashing when cloning.
        for HashCode, Item in this.Buckets
        {
            PreviousCloneItem := ""
            while (Item != "")
            {
                CloneItem       := {"Key": "", "Value": "", "Next": ""}
                CloneItem.Key   := Item.Key
                CloneItem.Value := Item.Value
                if (PreviousCloneItem == "")
                {
                    Chain := CloneItem
                }
                else
                {
                    PreviousCloneItem.Next := CloneItem
                }
                PreviousCloneItem := CloneItem
                Item              := Item.Next
            }
            Clone.Buckets[HashCode] := Chain
        }
        Clone.Count := this.Count
        return Clone
    }
}
