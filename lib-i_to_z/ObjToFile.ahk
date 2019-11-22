
D:=[{a:1,b:2,c:3},{a:2,b:3,c:1},{a:3,b:1,c:2}]
Msgbox % D[1]["c"] . ", " . D[2,"b"] . ", " . D[3,"a"] ;Ausgabe: 3, 3, 3
ObjToFile(D,"Test.dat")
F:=ObjFromFile("Test.dat")
Msgbox % F[1]["c"] . ", " . F[2,"b"] . ", " . F[3,"a"] ;Ausgabe: , ,

D:=["a","b", ["c","d"], "e"]
Msgbox % D[1] . ", " . D[2] . ", " . D[3][1] . ", " . D[3][2] . ", " . D[4] ;Ausgabe: a, b, c, d, e
ObjToFile(D,"Test.dat")
F:=ObjFromFile("Test.dat")
Msgbox % F[1] . ", " . F[2] . ", " . F[3][1] . ", " . F[3][2] . ", " . F[4] ;Ausgabe: a, b, c, d㐀, 

ObjToFile(Obj,Filename)
{
    Length:=ObjToBinary(Obj)
    VarSetCapacity(Bin,Length,0)
    ObjToBinary(Obj,&Bin)
    
    File:=FileOpen(Filename,"w")
    File.RawWrite(Bin,Length)
    File.Close()

    Return Length
}

ObjFromFile(Filename)
{
    
    File:=FileOpen(Filename,"r")
    File.RawRead(Bin,File.Length)
    File.Close()

    Return ObjFromBinary(&Bin)
}

ObjToBinary(Obj,Ptr=0)
{
    Len:=4
    Nr:=0
    Arr:=[]
    For Key, Value in Obj
    {
        Nr++
        Len+=StrPut(Key,"UTF-16")*2
        If (Value|0=="")
        {
            If IsObject(Value)
            {
                TypeNr:=3
                Len+=StrPut(GetClassName(Value),"UTF-16")*2
                Len+=ObjToBinary(Value)
            }
            Else
            {
                TypeNr:=0
                Len+=StrPut(Value,"UTF-16")*2
            }
        }
        Else
        {
            TypeNr:=1+!(InStr(Value,"."))
            Len+=8
        }
        Arr.Insert({Key:Key,Value:Value,TypeNr:TypeNr})
    }
    If !Ptr
        Return Len
    Ptr1:=Ptr+4
    Ptr2:=Ptr+Ceil(Nr/4)+4
    NumPut(Nr,(Ptr+0),"UInt")
    B:=C:=0
    For Index,KeyValue in Arr
    {
        B:=(B<<2)|KeyValue.TypeNr
        C++
        If (C=4)
        {
            NumPut(B,(Ptr1+0),"UChar")
            C:=B:=0
            Ptr+=1
        }
        Ptr2+=StrPut(KeyValue.Key,Ptr2,"UTF-16")*2
        If !KeyValue.TypeNr
            Ptr2+=StrPut(KeyValue.Value,Ptr2,"UTF-16")*2
        Else If (KeyValue.TypeNr<3)
        {
            NumPut(KeyValue.Value,(Ptr2+0),(KeyValue.TypeNr-1)?"Double":"Int64")
            Ptr2+=8
        }
        Else
        {
            Ptr2+=StrPut(GetClassName(KeyValue.Value),Ptr2,"UTF-16")*2
            Ptr2+=ObjToBinary(KeyValue.Value,Ptr2)
        }
    }
    Return Len
}

ObjFromBinary(Ptr,Obj="")
{
    If !Ptr
        Return
    If !IsObject(Obj)
        Obj:={}
    Ptr1:=Ptr
    Nr:=NumGet(Ptr1+0,"UInt")
    Ptr2:=(Ptr1+=4)+Ceil(Nr/16)
    C:=0
    Loop % Nr
    {
        C--
        If (C<0)
        {
            B:=NumGet(Ptr1+0,"UChar")
            Ptr+=1
            C:=4
        }
        TypeNr:=(B&0xC0)>>6
        B<<=2
        Key:=StrGet(Ptr2+0,"UTF-16")
        Ptr2+=StrPut(Key,"UTF-16")*2
        If (TypeNr=3)
        {
            ValueClass:=StrGet(Ptr2+0,"UTF-16")
            Ptr2+=StrPut(ValueClass,"UTF-16")*2
            If (ValueClass)
                Obj[Key]:=New %ValueClass%()
            Else
                Obj[Key]:={}
            Ptr2+=ObjFromBinary(Ptr2,Obj[Key])
        }
        Else If (TypeNr=1)
        {
            Obj[Key]:=NumGet(Ptr2+0,"Double")
            Ptr2+=8
        }
        Else If (TypeNr=2)
        {
            Obj[Key]:=NumGet(Ptr2+0,"Int64")
            Ptr2+=8
        }
        Else
        {
            Obj[Key]:=StrGet(Ptr2+0,"UTF-16")
            Ptr2+=StrPut(Obj[Key],"UTF-16")*2
        }
    }
    Return Obj
}

GetClassName(C)
{
    While (IsObject(C:=C.base)&&!C.HasKey("__Class"))
        Continue
    Return C.__Class
}