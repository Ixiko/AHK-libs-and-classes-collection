class HashTable
{
    __New(Items*)
    {
        local
        ; An AutoHotkey Array takes the place of the array that would normally
        ; be used to implement a hash table's buckets.
        ;
        ; Masking to remove the unwanted high bits to fit within the array
        ; bounds is unnecessary because AutoHotkey Arrays are sparse arrays that
        ; support negative indexes.
        ;
        ; Rehashing everything and placing it in a new array that has the next
        ; highest power of 2 elements when over 3/4ths of the buckets are full
        ; is unnecessary for the same reason.
        this._Buckets := []
        this._Count   := 0
        loop % Items.Length()
        {
            if (not Items.HasKey(a_index))
            {
                throw Exception("Missing Argument Error", -1
                               ,"HashTable.__New(Items*)")
            }
            if (not (    IsObject(Items[a_index])
                     and Items[a_index].HasKey("HasKey") != ""))
            {
                throw Exception("Type Error", -1
                               ,"HashTable.__New(Items*)  Invalid argument.")
            }
            if (not (    Items[a_index].HasKey(1)
                     and Items[a_index].HasKey(2)
                     and Items[a_index].Count() == 2))
            {
                throw Exception("Value Error", -1
                               ,"HashTable.__New(Items*)  Invalid argument.")
            }
            this.Set(Items[a_index][1], Items[a_index][2])
        }
        return this
    }

    _GetHash(Key)
    {
        ; _GetHash(Key) is used to find the bucket a key would be stored in.
        local
        if (IsObject(Key))
        {
            HashCode := &Key
        }
        else
        {
            if Key is integer
            {
                HashCode := Key
            }
            else if Key is float
            {
                TruncatedKey := Key & -1
                if (Key == TruncatedKey)
                {
                    HashCode := TruncatedKey
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
                ; use of modular arithmetic via integer overflow.
                HashCode := 0
                for _, Char in StrSplit(Key)
                {
                    HashCode := 31 * HashCode + Ord(Char)
                }
            }
        }
        return HashCode
    }

    HasKey(Key, _HashCode := "")
    {
        ; The _HashCode optional parameter is used to avoid repeated hashing.
        local
        ; HasKey(Key) has the side effect of moving whatever was searched for to
        ; the start of the bucket's chain if it is not already there.  This
        ; speeds future lookups.
        ;
        ; Set(Key, Value) and Get(Key) require almost identical logic, so they
        ; use HasKey(Key) internally to avoid code duplication.  They depend on
        ; the chain reordering behavior.
        Found        := false
        HashCode     := _HashCode == "" ? this._GetHash(Key) : _HashCode
        Item         := this._Buckets.HasKey(HashCode) ? this._Buckets[HashCode]
                      : ""
        PreviousItem := ""
        while (not Found and Item != "")
        {
            if (Item.Key == Key)
            {
                if (PreviousItem != "")
                {
                    PreviousItem.Next       := Item.Next
                    Item.Next               := this._Buckets[HashCode]
                    this._Buckets[HashCode] := Item
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
        HashCode := this._GetHash(Key)
        if (this.HasKey(Key, HashCode))
        {
            this._Buckets[HashCode].Value := Value
        }
        else
        {
            Next := this._Buckets.HasKey(HashCode) ? this._Buckets[HashCode]
                  : ""
            this._Buckets[HashCode] := {"Key":   Key
                                       ,"Value": Value
                                       ,"Next":  Next}
            this._Count             += 1
        }
        return Value
    }

    Get(Key)
    {
        local
        HashCode := this._GetHash(Key)
        if (this.HasKey(Key, HashCode))
        {
            Value := this._Buckets[HashCode].Value
        }
        else
        {
            throw Exception("Key Error", -1
                           ,"HashTable.Get(Key)  Key not found.")
        }
        return Value
    }

    Delete(Key)
    {
        local
        ; Delete(Key) does not use HasKey(Key) internally because only the
        ; chain traversal logic is the same and reordering the chain would
        ; waste time.
        Found        := false
        HashCode     := this._GetHash(Key)
        Item         := this._Buckets.HasKey(HashCode) ? this._Buckets[HashCode]
                      : ""
        PreviousItem := ""
        while (not Found)
        {
            if (Item == "")
            {
                throw Exception("Key Error", -1
                               ,"HashTable.Delete(Key)  Key not found.")
            }
            if (Item.Key == Key)
            {
                if (PreviousItem == "")
                {
                    if (Item.Next == "")
                    {
                        this._Buckets.Delete(HashCode)
                    }
                    else
                    {
                        this._Buckets[HashCode] := Item.Next
                    }
                }
                else
                {
                    PreviousItem.Next := Item.Next
                }
                this._Count -= 1
                Value       := Item.Value
                Found       := true
            }
            else
            {
                PreviousItem := Item
                Item         := Item.Next
            }
        }
        return Value
    }

    Count()
    {
        local
        return this._Count
    }

    class _Enum
    {
        __New(HashTable)
        {
            local
            ; The _BucketsEnum and _PreviousItem properties are used to store
            ; the stopping place across calls to Next(byref Key, byref Value).
            this._BucketsEnum  := HashTable._Buckets._NewEnum()
            this._PreviousItem := ""
            return this
        }

        Next(byref Key, byref Value)
        {
            local
            if (this._PreviousItem == "" or this._PreviousItem.Next == "")
            {
                Result := this._BucketsEnum.Next(Garbage, Item)
            }
            else
            {
                Item   := this._PreviousItem.Next
                Result := true
            }
            if (Result)
            {
                Key                := Item.Key
                Value              := Item.Value
                this._PreviousItem := Item
            }
            return Result
        }
    }

    _NewEnum()
    {
        local
        global HashTable
        return new HashTable._Enum(this)
    }

    Clone()
    {
        local
        global HashTable
        Clone := new HashTable()
        ; Avoid rehashing when cloning.
        for HashCode, Item in this._Buckets
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
            Clone._Buckets[HashCode] := Chain
        }
        Clone._Count := this._Count
        return Clone
    }
}
