; Author: Mono
; Time: 2022.11.08
; Version: 1.0.1

#Include <print\print>
#Include <std\init>

; Init DefProp & DelProp
DefProp := {}.DefineProp
DelProp := {}.DeleteProp


; Redefine Dims
0.0.Base.Dims := 0
0.Base.Dims := 0
"".Base.Dims := 0
Map().Base.Dims := 0
Object().Base.Dims := 0
DefProp([].Base, "Dims", {Get: GetArrDims})


; Redefine NDim
0.0.Base.NDim := 0
0.Base.NDim := 0
"".Base.NDim := 0
Map().Base.NDim := 0
Object().Base.NDim := 0
DefProp([].Base, "NDim", {Get: GetArrDims})


; Redefine In
DefProp(0.Base, "In", {Get: InObj})
DefProp(0.0.Base, "In", {Get: InObj})
DefProp("".Base, "In", {Get: InObj})
DefProp([].Base, "In", {Get: InObj})
DefProp(Map().Base, "In", {Get: InObj})
DefProp({}.Base, "In", {Get: InObj})


; Redefine Range
DefProp(0.Base, "Range", {Get: IntegerRange})
DefProp(0.0.Base, "Range", {Get: FloatRange})
DefProp("".Base, "Range", {Get: StringRange})


; Redefine Shape
0.0.Base.Shape := 0
0.Base.Shape := 0
"".Base.Shape := 0
Map().Base.Shape := 0
Object().Base.Shape := 0
DefProp([].Base, "Shape", {Get: GetArrShape})


; Redefine Sign
DefProp(0.0.Base, "Sign", {Get: FloatSign})
DefProp(0.Base, "Sign", {Get: IntegerSign})
DefProp("".Base, "Sign", {Get: StringSign})


; Redefine Array
DefProp([].Base, "Append", {Get: ArrAppend})
DefProp([].Base, "Copy", {Get: ArrCopy})
DefProp([].Base, "Count", {Get: ArrCount})
DefProp([].Base, "Extend", {Get: ArrExtend})
DefProp([].Base, "Index", {Get: ArrIndex})
DefProp([].Base, "Insert", {Get: ArrInsert})
DefProp([].Base, "IReshape", {Get: ArrIReshape})
DefProp([].Base, "Item", {Get: GetArrItem})
DefProp([].Base, "Max", {Get: GetArrMax})
DefProp([].Base, "MaxDim", {Get: GetArrMaxDim})
DefProp([].Base, "MaxDimIndex", {Get: GetArrMaxDimIndex})
DefProp([].Base, "MaxLength", {Get: GetArrMaxLength})
DefProp([].Base, "Min", {Get: GetArrMin})
DefProp([].Base, "MinDim", {Get: GetArrMinDim})
DefProp([].Base, "MinDimIndex", {Get: GetArrMinDimIndex})
DefProp([].Base, "Mul", {Get: ArrMul})
DefProp([].Base, "Product", {Get: GetArrProduct})
DefProp([].Base, "Ravel", {Get: ArrRavel})
DefProp([].Base, "Remove", {Get: ArrRemove})
DefProp([].Base, "Reshape", {Get: ArrReshape})
DefProp([].Base, "Reverse", {Get: ArrReverse})
DefProp([].Base, "SetItem", {Get: SetArrItem})
DefProp([].Base, "Size", {Get: GetArrSize})

if !HasProp([], "Sort")
    DefProp([].Base, "Sort", {Get: ArrSort})

DefProp([].Base, "Standardization", {Get: ArrStandardization})
DefProp([].Base, "Sum", {Get: GetArrSum})
DefProp([].Base, "Swap", {Get: ArrSwap})


; Redefine Float
DefProp(0.0.Base, "_", {Get: Float_})
DefProp(0.0.Base, "Array", {Get: StrSplit})


; Redefine Integer
DefProp(0.Base, "_", {Get: Integer_})
DefProp(0.Base, "Array", {Get: StrSplit})
DefProp(0.Base, "Bit_Count", {Get: IntegerBitCount})
DefProp(0.Base, "Bit_Length", {Get: IntegerBitLength})
DefProp(0.Base, "ToBase", {Get: IntegerToBase})


; Redefine Map
DefProp(Map().Base, "Array", {Get: MapArray})
DefProp(Map().Base, "Copy", {Get: MapCopy})
DefProp(Map().Base, "FromKeys", {Get: MapFromKeys})
DefProp(Map().Base, "Items", {Get: GetMapItems})
DefProp(Map().Base, "Keys", {Get: GetMapKeys})
DefProp(Map().Base, "Pop", {Get: MapPop})
DefProp(Map().Base, "PopItem", {Get: MapPopItem})
DefProp(Map().Base, "Setdefault", {Get: MapSetdefault})
DefProp(Map().Base, "Sort", {Get: MapSort})
DefProp(Map().Base, "Update", {Get: MapUpdate})
DefProp(Map().Base, "Values", {Get: GetMapValues})


; Redefine Object
DefProp({}.Base, "Copy", {Get: ObjectCopy})
DefProp({}.Base, "Extends", {Get: ObjectExtends})


; Redefine String
DefProp("".Base, "Array", {Get: StrSplit})
DefProp("".Base, "Decode", {Get: StrDecode})
DefProp("".Base, "Encode", {Get: StrEncode})
DefProp("".Base, "Format", {Get: StrFormat})
DefProp("".Base, "Join", {Get: StrJoin})
DefProp("".Base, "Replace", {Get: StrRep})
DefProp("".Base, "TmpType", {Value: Map()})
DefProp("".Base, "Type", {Get: (this) => this.TmpType.Has(this) ? this.TmpType[this] : ((SubStr(this, 1, 2) = "0b") ? "Bytes" : ((SubStr(this, 1, 2) = "0x") ? "Utf-8" : "String")), Set: (this, Value) => this.TmpType[this] := Value.in(["Base64", "Bytes", "String", "Unicode", "Url", "Utf-8"]) ? StrTitle(Value) : "String"})

; Related Func
ArrAppend(this)
{
    Return ArrAppend2
}

ArrAppend2(this, Content*)
{
    this.Push(Content*)
}

ArrCopy(this)
{
    Return ArrCopy2
}

ArrCopy2(this)
{
    Tmp := []
    
    For i in this
        Tmp.Push(i)
    
    Return Tmp
}

ArrCount(this)
{
    Return ArrCount2
}

ArrCount2(this, Obj)
{
    Return_Count := 0
        
    For i in this
    {
        if !ListCmp(i, Obj)
            Return_Count++
    }
    
    Return Return_Count
}

ArrExtend(this)
{
    Return ArrExtend2
}

ArrExtend2(this, Extend_Lst*)
{
    Loop Extend_Lst.Length
    {
        if !Extend_Lst[A_Index].Dims
            this.Push(Extend_Lst[A_Index])
        
        else
        {
            For i in Extend_Lst[A_Index]
                this.Push(i)
        }
    }
    
    Return this
}

ArrIndex(this)
{
    Return ArrIndex2
}

ArrIndex2(this, Obj)
{
    Index := -1
    
    For i in this
    {
        if !ListCmp(i, Obj)
        {
            Index := A_Index
            Break
        }
    }
    
    Return Index
}

ArrInsert(this)
{
    Return ArrInsert2
}

ArrInsert2(this, Index, Obj*)
{
    this.InsertAt(Index, Obj*)
    
    Return this
}

ArrIReshape(this)
{
    Return ArrIReshape2
}

ArrIReshape2(this, Shape)
{
    this.Ravel()
    
    Return this.Reshape(Shape)
}

ArrMul(this)
{
    Return ArrMul2
}

ArrMul2(this, Number := 1)
{
    Tmp := this.Clone()
    
    Loop Floor(Number) - 1
    {
        Try
        {
            For i in Tmp
                this.Push(i)
        }
        
        Catch
            this.Length += Tmp.Length
    }
    
    Return this
}

ArrRavel(this)
{
    Return ArrRavel2
}

ArrRavel2(this)
{
    if !this.MaxDim
        Return this
    
    Tmp := []
    
    For i in this
    {
        if !i.Dims
            Tmp.Push(i)
        
        else
            Tmp.Extend(ArrRavel2(i))
    }
    
    this.Length := 0
    
    For j in Tmp
        this.Push(j)
    
    Return this
}

ArrRemove(this)
{
    Return ArrRemove2
}

ArrRemove2(this, Obj*)
{
    Loop Obj.Length
    {
        Index := this.Index(Object[A_Index])
        
        if Index != -1
            this.Pop(Index)
    }
    
    Return this
}

ArrReshape(this)
{
    Return ArrReshape2
}

ArrReshape2(this, Shape)
{
    OldShape := this.Shape
    TmpShape := Shape.Clone()
    
    For i in TmpShape
    {
        if i = -1
            TmpShape[A_Index] := OldShape.Product // Abs(Shape.Product)
    }
    
    if OldShape.Product !== TmpShape.Product
        Return this
    
    if TmpShape.Length == 1
        Return this.Ravel()
    
    this.Ravel()
    Tmpthis := this.Clone()
    Tmp := []
    LoopTimes := TmpShape.RemoveAt(1)
    
    Loop LoopTimes
    {
        Tmp2 := []
        Loop TmpShape.Product
            Tmp2.Push(Tmpthis.RemoveAt(1))
        
        Tmp.Push(ArrReshape2(Tmp2, TmpShape))
    }
    
    this.Length := 0
    
    For j in Tmp
        this.Push(j)
    
    Return this
}

ArrReverse(this)
{
    Return ArrReverse2
}

ArrReverse2(this)
{
    Loop this.Length // 2
        this.Swap(A_Index, this.Length - A_Index + 1)
    
    Return this
}

ArrSort(this)
{
    Return ArrSort2
}

ArrSort2(this, cmp := "", key := "", reverse := False)
{
    if (key is String) && InStr(key, "reverse")
        reverse := Trim(StrSplit(key, "=")[2])
    
    if (cmp is String) && InStr(cmp, "key")
        key := %Trim(StrSplit(cmp, "=")[2])%
    
    if (cmp is String) && InStr(cmp, "reverse")
        reverse := Trim(StrSplit(cmp, "=")[2])
    
    if !(cmp is Func)
        cmp := ListCmp
    
    if !key
    {
        Loop this.Length
        {
            Index := A_Index
            
            Loop this.Length - Index
            {
                if cmp(this[Index], this[A_Index + Index]) > 0
                    this.Swap(Index, A_Index + Index)
            }
        }
    }
    
    else
    {
        Loop this.Length
        {
            Index := A_Index
            
            Loop this.Length - Index
            {
                if key(this[Index]) > key(this[A_Index + Index])
                    this.Swap(Index, A_Index + Index)
            }
        }
    }
    
    if reverse
        this.Reverse()
    
    Return this
}

ArrStandardization(this)
{
    Return ArrStandardization2
}

ArrStandardization2(this)
{
    if this.Dims == 1
        Return this
    
    Shape := []
    
    Loop this.Dims
        Shape.Push(this.MaxLength(A_Index))
    
    Ret := ArrStandardShape(this, Shape)
    
    For i in Ret
        this[A_Index] := i
    
    Return this
}

ArrStandardShape(this, Shape)
{
    if Shape.Length == 1
    {
        Tmp := this.Dims ? this : [this]
        
        Loop Shape[1] - Tmp.Length
            Tmp.Push(0)
        
        Return Tmp
    }
    
    Tmp := this.Dims ? this : [this]
    
    Loop Shape[1] - Tmp.Length
        Tmp.Push(0)
    
    TmpShape := Shape.Clone()
    TmpShape.RemoveAt(1)
    
    For i in Tmp
        Tmp[A_Index] := ArrStandardShape(i, TmpShape)
    
    Return Tmp
}

ArrSwap(this)
{
    Return ArrSwap2
}

ArrSwap2(this, Index1, Index2)
{
    if Index1 > this.Length || Index2 > this.Length || Index1 == Index2
        Return this
    
    Temp := this[Index1]
    this[Index1] := this[Index2]
    this[Index2] := Temp
    
    Return this
}

Float_(this)
{
    Return Integer(this) ":"
}

FloatRange(this)
{
    Return Integer(this)
}

FloatSign(this)
{
    if this >= 0
        Return 1
    
    if this < 0
        Return -1
}

GetArrDims(this)
{
    Tmp := [0]
    
    For i in this
        Tmp.Push(HasProp(i, "Dims") ? i.Dims : 0)
    
    Return Max(Tmp*) + 1
}

GetArrItem(this)
{
    Return GetArrItem2
}

GetArrItem2(this, Pos*)
{
    Tmp := [this]
    
    While Pos.Length
        Tmp.Push(Tmp.Pop()[Pos.RemoveAt(1)])
    
    Return Tmp[-1]
}

GetArrMax(this)
{
    Tmp := this.Clone()
    
    Return this.Length ? Tmp.Sort()[-1] : ""
}

GetArrMaxDim(this)
{
    Return this[GetArrMaxDimIndex(this)].Dims
}

GetArrMaxDimIndex(this)
{
    MaxDim := 0
    MaxDimIndex := 1
    
    For i in this
    {
        if i.Dims > MaxDim
        {
            MaxDim := i.Dims
            MaxDimIndex := A_Index
        }
    }
    
    Return MaxDimIndex
}

GetArrMaxLength(this)
{
    Return GetArrMaxLength2
}

GetArrMaxLength2(this, Dim := 1)
{
    if !this.Dims || Dim > this.Dims
        Return 1
    
    if Dim == 1
        Return this.Length
    
    MaxLength := 1
    Dim--
    
    For i in this
    {
        if GetArrMaxLength2(i, Dim) > MaxLength
            MaxLength := GetArrMaxLength2(i, Dim)
    }
    
    Return MaxLength
}

GetArrMin(this)
{
    Tmp := this.Clone()
    
    Return this.Length ? Tmp.Sort()[1] : ""
}

GetArrMinDim(this)
{
    Return this[GetArrMinDimIndex(this)].Dims
}

GetArrMinDimIndex(this)
{
    MinDim := this[1].Dims
    MinDimIndex := 1
    
    For i in this
    {
        if MinDim == 0
            Break
        
        if i.Dims < MinDim
        {
            MinDim := i.Dims
            MinDimIndex := A_Index
        }
    }
    
    Return MinDimIndex
}

GetArrProduct(this)
{
    Ret := 1
    
    For i in this
    {
        if Ret == 0
            Return Ret
        
        if i.Dims
            Ret *= GetArrProduct(i)
        
        else
        {
            Try
                Ret *= i
        }
    }
    
    Return Ret
}

GetArrShape(this)
{
    this.Standardization()
    
    Tmp := this.Clone()
    Shape := []
    
    While Tmp.MaxDim
    {
        Shape.Push(Tmp.Length)
        Tmp := Tmp[Tmp.MaxDimIndex]
    }
    
    Shape.Push(Tmp.Length)
    
    Return Shape
}

GetArrSize(this)
{
    Return this.Shape.Product
}

GetArrSum(this)
{
    Ret := 0
    
    For i in this
    {
        if i.Dims
            Ret += GetArrSum(i)
        
        else
        {
            Try
                Ret += i
        }
    }
    
    Return Ret
}

GetMapItems(this)
{
    Return GetMapItems2
}

GetMapItems2(this)
{
    Tmp := []
    
    For Key, Value in this
        Tmp.Push([Key, Value])
    
    Return Tmp
}

GetMapKeys(this)
{
    Return GetMapKeys2
}

GetMapKeys2(this)
{
    Tmp := []
    
    For Key in this
        Tmp.Push(Key)
    
    Return Tmp
}

GetMapValues(this)
{
    Return GetMapValues2
}

GetMapValues2(this)
{
    Tmp := []
    
    For Key, Value in this
        Tmp.Push(Value)
    
    Return Tmp
}

InObj(this)
{
    Return InObj2
}

InObj2(this, Obj)
{
    if !IsObject(this) && !IsObject(Obj)
        Return InStr(Obj, this)
    
    else if (Obj is Array)
    {
        For i in Obj
        {
            if Print.ToString(i) = Print.ToString(this)
                Return A_Index
        }
    }
    
    else if (Obj is Map)
    {
        For i, Value in Obj
        {
            if Print.ToString(Value) = Print.ToString(this)
                Return i
        }
    }
    
    else if (Obj is Object)
    {
        For i, Value in Obj.Map
        {
            if Print.ToString(Value) = Print.ToString(this)
                Return i
        }
    }
    
    Return False
}

Integer_(this)
{
    Return Integer__(this)
}

Class Integer__
{
    __New(Start)
    {
        this.Start := Start
    }
    
    __Get(End, _)
    {
        End := End is Integer ? End : %End%
        Return this.Start ":" End
    }
}

IntegerBitCount(this)
{
    Return IntegerBitCount2
}

IntegerBitCount2(this)
{
    Return Abs(this).ToBase(2).Array.Count("1")
}

IntegerBitLength(this)
{
    Return IntegerBitLength2
}

IntegerBitLength2(this)
{
    Return StrLen(LTrim(Abs(this).ToBase(2), "0"))
}

IntegerRange(this)
{
    Return this
}

IntegerSign(this)
{
    if this >= 0
        Return 1
    
    if this < 0
        Return -1
}

IntegerToBase(this)
{
    Return IntegerToBase2
}

IntegerToBase2(this, Base := 2)
{
    Sign := this.Sign
    Ret := IntegerToBase3(Abs(this), Base)
    
    if Base == 2
    {
        Tmp := Ret
        
        Loop Mod(8 - Mod(StrLen(Tmp), 8), 8)
            Ret := "0" Ret
    }
    
    Return Sign = -1 ? "-" Ret : Ret
}

IntegerToBase3(this, Base)
{
    Ret := (this < Base ? "" : IntegerToBase3(this // Base, Base)) . ((Modify := Mod(this, Base)) < 10 ? Modify : Chr(Modify + 55))
            
    Return Ret
}

ListCmp(Lst1, Lst2)
{
    Lst1 := Print.ToString(Lst1)
    Lst2 := Print.ToString(Lst2)
    
    if StrCompare(Lst1, Lst2) < 0
        Return -1
    
    else if StrCompare(Lst1, Lst2) > 0
        Return 1
    
    else
        Return 0
}

MapArray(this)
{
    Lst_Map := []
    
    For Key, Value in this
        Lst_Map.Push([Key, Value])
    
    Return Lst_Map
}

MapCopy(this)
{
    Return MapCopy2
}

MapCopy2(this)
{
    Return this.Clone()
}

MapFromKeys(this)
{
    Return MapFromKeys2
}

MapFromKeys2(this, seq, value := "")
{
    For i in seq
        this[i] := value
    
    Return this
}

MapPop(this)
{
    Return MapPop2
}

MapPop2(this, Key, Default := "")
{
    if this.Has(Key)
        Return this.Delete(Key)
    
    Return Default
}

MapPopItem(this)
{
    Return MapPopItem2
}

MapPopItem2(this)
{
    if !this.Count
        Throw IndexError("This Map() is empty.")
    
    For Key, Value in this
        Tmp := Key
    
    Return this.Delete(Tmp)
}

MapSetdefault(this)
{
    Return MapSetdefault2
}

MapSetdefault2(this, Key, Default := "")
{
    if this.Has(Key)
        Return this
    
    else
        this[Key] := Default
    
    Return this
}

MapSort(this)
{
    Return MapSort2
}

MapSort2(this, cmp := "", key := "", reverse := False)
{
    Lst_Map := this.Array
    Lst_Map.Sort(cmp, key, reverse)
    
    Return Lst_Map
}

MapUpdate(this)
{
    Return MapUpdate2
}

MapUpdate2(this, NewMap)
{
    For Key, Value in NewMap
        this[Key] := Value
    
    Return this
}

ObjectCopy(this)
{
    Return ObjectCopy2
}

ObjectCopy2(this)
{
    Return this.Clone()
}

ObjectExtends(this)
{
    Return ObjectExtends2
}

ObjectExtends2(this, _Class)
{
    Try
        this.Base := _Class
    Try
        this.ProtoType := _Class.ProtoType
    
    Return this
}

Class Range
{
    __New(Start, Stop := "", Step := 1)
    {
        if !Step
            Throw ValueError("Step cannot be 0.")
        
        if Stop == ""
        {
            Tmp := Start
            Start := 1
            Stop := Tmp
        }
        
        this.Length := Max(0, (Stop - Start) // Abs(Step) + 1)
        this.Start := Start
        this.Stop := Stop
        this.Step := Step
    }
    
    __Enum(_)
    {
        this.LoopTimes := this.Length
        this.Index := 0
        
        Return Fn
        
        Fn(&Idx := 0, &Value := 0)
        {
            if !this.LoopTimes
                Return False
            
            Idx := (IsSet(Value)) ? this.Start + this.Index * this.Step : this.Index + 1
            Value := this.Start + this.Index * this.Step
            this.Index++
            
            Return this.LoopTimes--
        }
    }
    
    Array()
    {
        Ret := []
        
        Loop this.Length
        {
            if this.Step > 0
                Ret.Push(this.Start + (A_Index - 1) * this.Step)
            
            else
                Ret.Push(this.Stop + (A_Index - 1) * this.Step)
        }
        
        Return Ret
    }
}

SetArrItem(this)
{
    Return SetArrItem2
}

SetArrItem2(this, Pos*)
{
    Value := Pos.Pop()
    Tmp := [this]
    
    Loop Pos.Length - 2
        Tmp.Push(Tmp.Pop()[Pos[A_Index]])
    
    Tmp[-1][Pos[-1]] := Value
    
    Return this
}

StrDecode(this)
{
    Return StrDecode2
}

StrDecode2(this, Encoding := -1)
{
    if Encoding == -1
    {
        if this.Type != "String"
            Encoding := this.Type
        
        else
            Encoding := "Utf-8"
    }
    
    if Encoding = "Base64"
    {
        B64 := this
        nBytes := Floor((B64Len := StrLen(B64 := RTrim(B64, "="))) * 3 / 4)
        Bin := Buffer(nBytes)
        
        DllCall("Crypt32.dll\CryptStringToBinary", "Str",B64, "Int", B64Len, "Int",1, "Ptr", Bin, "Uintp", nBytes, "Int",0, "Int",0)
        
        Return StrGet(Bin, "Utf-8")
    }
    
    else if Encoding = "Unicode_Escape" || Encoding = "Unicode"
    {
        Lst_this := StrSplit(this, "\u")
                
        Loop Lst_this.Length - 1
        {
            Index_this := Lst_this[A_Index + 1]
            Unicode_this := SubStr(Index_this, 1, 4)
            Unicode_Base := Chr(Integer("0x" Unicode_this))
            Lst_this[A_Index + 1] := StrReplace(Index_this, Unicode_this, Unicode_Base, , , 1)
        }
        
        Return "".Join(Lst_this)
    }
    
    else if Encoding == "Url"
    {
        Chi_Index := 0
        Temp_Hex := ""
        Lst_this := StrReplace(this, "%", "%$")
        Lst_this := StrSplit(Lst_this, "%")
        
        Loop Lst_this.Length - 1
        {
            StrTar := SubStr(Lst_this[A_Index + 1], 1, 3)
            NumTar := SubStr(Lst_this[A_Index + 1], 2, 2)
            
            NumNeed := Integer("0x" NumTar)
            
            if (NumNeed >= 0x20 && NumNeed <= 0x7F)
            {
                StrNeed := Chr(NumNeed)
                Lst_this[A_Index + 1] := StrReplace(Lst_this[A_Index + 1], StrTar, StrNeed)
            }
            
            else
            {
                Chi_Index++
                
                if Chi_Index < 3
                {
                    if Chi_Index == 1
                        Temp_Hex .= SubStr(Integer("0x" NumTar).ToBase(), 5)
                    
                    else
                        Temp_Hex .= SubStr(Integer("0x" NumTar).ToBase(), 3)
                    
                    Lst_this[A_Index + 1] := ""
                    Continue
                }
                
                else
                {
                    Temp_Hex .= SubStr(Integer("0x" NumTar).ToBase(), 3)
                    Chi_Index := 0
                    NumNeed := 0
                    
                    For i in Temp_Hex.Array
                        NumNeed += (2 ** (Temp_Hex.Array.Length - A_Index)) * i
                    StrNeed := Chr(NumNeed)
                    Temp_Hex := ""
                    Lst_this[A_Index + 1] := StrReplace(Lst_this[A_Index + 1], StrTar, StrNeed)
                }
            }
        }
        
        Return "".Join(Lst_this)
    }
    
    else if Encoding = "Utf-8"
    {
        this := StrReplace(this, "\x", "%")
        
        Return StrDecode2(this, "Url")
    }
}

StrEncode(this)
{
    Return StrEncode2
}

StrEncode2(this, Encoding := -1)
{
    if Encoding == -1
    {
        if this.Type != "String"
            Encoding := this.Type
        
        else
            Encoding := "Utf-8"
    }
    
    if Encoding = "Base64"
    {
        Bin := this
        Buf := Buffer(Ceil(StrPut(Bin, "utf-8") * 3 / 4))
        StrPut(Bin, Buf, "utf-8")
        
        DllCall("Crypt32.dll\CryptBinaryToString", "Ptr", Buf, "UInt", Buf.Size, "UInt", 0x40000001, "Ptr", 0, "Uint*", &nSize := 0)
        
        VarSetStrCapacity(&B64, nSize << 1)
        
        DllCall("Crypt32.dll\CryptBinaryToString", "Ptr", Buf, "UInt", Buf.Size, "UInt", 0x40000001, "Str", B64, "Uint*", &nSize)
        
        B64.Type := "Base64"
        Return B64
    }
    
    else if Encoding = "Url"
    {
        Res := ""
        Var := Buffer(StrPut(this, "UTF-8"), 0)
        StrPut(this, Var, "UTF-8")
        
        While Code := NumGet(Var, A_Index - 1, "UChar")
        {
            if (Code >= 0x30 && Code <= 0x39
                || Code >= 0x41 && Code <= 0x5A
                || Code >= 0x61 && Code <= 0x7A)
                Res .= Chr(Code)
            
            else
                Res .= "%" StrUpper(Code.ToBase(16))
        }
        
        Res.Type := "Url"
        Return Res
    }
    
    else if Encoding = "Utf-8"
    {
        Res := ""
        Var := Buffer(StrPut(this, "UTF-8"), 0)
        StrPut(this, Var, "UTF-8")
        
        While Code := NumGet(Var, A_Index - 1, "UChar")
        {
            if (Code >= 0x30 && Code <= 0x39
                || Code >= 0x41 && Code <= 0x5A
                || Code >= 0x61 && Code <= 0x7A)
                Res .= Chr(Code)
            
            else
                Res .= "\x" StrLower(Code.ToBase(16))
        }
        
        Res.Type := "Utf-8"
        Return Res
    }
}

StringRange(this)
{
    if !InStr(this, ":")
        Return Integer(this)
    
    Lst_this := StrSplit(this, ":")
    Lst_this[1] := Lst_this[1] ? Lst_this[1] : 1
    Lst_this[2] := Lst_this[2] ? Lst_this[2] : -1
    
    Return Lst_this
}

StringSign(this)
{
    if IsNumber(this)
    {
        if this >= 0
            Return 1
        
        if this < 0
            Return -1
    }
    
    Return 0
}

StrFormat(this)
{
    Return StrFormat2
}

StrFormat2(this, param*)
{
    Return Format(this, param*)
}

StrJoin(this)
{
    Return StrJoin2
}

StrJoin2(this, Arr)
{
    if Arr is String
        Arr := StrSplit(Arr)
    
    Ret := Arr[1]
    
    Loop Arr.Length - 1
        Ret .= this Arr[A_Index + 1]
    
    Return Ret
}

StrRep(this)
{
    Return StrRep2
}

StrRep2(this, SearchText, ReplaceText := "", CaseSense := 0, &OutputVarCount := 0, Limit := -1)
{
    this := StrReplace(this, SearchText, ReplaceText, CaseSense, &OutputVarCount, Limit)
    
    Return this
}
