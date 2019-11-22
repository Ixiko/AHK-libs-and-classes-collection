#NoEnv

#Include Classifier.ahk

c := new Classifier

FileRead, Data, Features.txt
If !ErrorLevel
    c.Features := ParseObject(Data)
FileRead, Data, Items.txt
If !ErrorLevel
    c.Items := ParseObject(Data)
Return

F2::
InputBox, Category, Category, Enter the category
If !ErrorLevel
    c.Train(Clipboard,Category)
Return

F3::
FileDelete, Features.txt
FileAppend, % ShowObject(c.Features), Features.txt
FileDelete, Items.txt
FileAppend, % ShowObject(c.Items), Items.txt
Return

ParseObject(ObjectDescription)
{
    ListLines, Off
    PreviousIndentLevel := 1, PreviousKey := "", Result := Object(), ObjectPath := [], PathIndex := 0, TempObject := Result ;initialize values
    Loop, Parse, ObjectDescription, `n, `r ;loop over each line of the object description
    {
        IndentLevel := 1
        While, (SubStr(A_LoopField,A_Index,1) = "`t") ;retrieve the indentation level
            IndentLevel ++
        Temp1 := InStr(A_LoopField,":",0,IndentLevel)
        If !Temp1 ;not a key-value pair, treat as a continuation of the value of the previous pair
        {
            TempObject[PreviousKey] .= "`n" . A_LoopField
            Continue
        }
        Key := SubStr(A_LoopField,IndentLevel,Temp1 - IndentLevel), Value := SubStr(A_LoopField,Temp1 + 2)
        If (IndentLevel = PreviousIndentLevel) ;sibling object
            TempObject[Key] := Value
        Else If (IndentLevel > PreviousIndentLevel) ;nested object
            TempObject[PreviousKey] := Object(Key,Value), TempObject := TempObject[PreviousKey], ObjInsert(ObjectPath,PreviousKey), PathIndex ++
        Else ;(IndentLevel < PreviousIndentLevel) ;parent object
        {
            Temp1 := PreviousIndentLevel - IndentLevel, ObjRemove(ObjectPath,PathIndex - Temp1,PathIndex), PathIndex -= Temp1 ;update object path

            ;get parent object
            TempObject := Result
            Loop, %PathIndex%
                TempObject := TempObject[ObjectPath[A_Index]]
            TempObject[Key] := Value
        }
        PreviousIndentLevel := IndentLevel, PreviousKey := Key
    }
    ListLines, On
    Return, Result
}

ShowObject(ShowObject,Padding = "")
{
    ListLines, Off
    If !IsObject(ShowObject)
    {
        ListLines, On
        Return, ShowObject
    }
    ObjectContents := ""
    Enumerator := ObjNewEnum(ShowObject)
    While, Enumerator.Next(Key,Value)
    {
        If IsObject(Value)
            Value := "`n" . ShowObject(Value,Padding . A_Tab)
        ObjectContents .= Padding . Key . ": " . Value . "`n"
    }
    ObjectContents := SubStr(ObjectContents,1,-1)
    If (Padding = "")
        ListLines, On
    Return, ObjectContents
}