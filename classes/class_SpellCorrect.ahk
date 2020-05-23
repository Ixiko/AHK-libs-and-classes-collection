#NoEnv

/*
SetBatchLines, -1

s := new Spell

s.Train("something")
s.Train("something")
s.Train("soothing")
s.Train("seething")

Result := ""
For Index, Word In s.Correct("oething")
    Result .= Word . "`n"
MsgBox % SubStr(Result,1,-1)
Return
*/

/*
SetBatchLines, -1

FileRead, Data, %A_ScriptDir%\Spelling Data.txt
Model := Object()
Loop, Parse, Data, `n
{
    StringSplit, Field, A_LoopField, %A_Tab%
    Model[Field1] := Field2
}

s := new Spell
s.Load(Model)

Result := ""
For Index, Word In s.Correct("omthing")
    Result .= Word . "`n"
MsgBox % SubStr(Result,1,-1)
Return
*/

class Spell
{
    __New()
    {
        this.Model := Object()
    }

    Load(Model,Replace = 1)
    {
        If Replace
            this.Model := Model
        Else
        {
            For Word, Occurrences In Model
            {
                If ObjHasKey(this.Model,Word)
                    this.Model[Word] += Occurrences
                Else
                    this.Model[Word] := Occurrences
            }
        }
    }

    Train(Word)
    {
        If !ObjHasKey(this.Model,Word)
            this.Model[Word] := 1
        Else
            this.Model[Word] ++
    }

    Edits1(Word)
    {
        CharSet := "abcdefghijklmnopqrstuvwxyz"

        Result := Object()
        Length := StrLen(Word)

        Index := 0
        Loop, %Length%
        {
            Result[SubStr(Word,1,Index) . SubStr(Word,Index + 2)] := 1 ;deletes
            Loop, Parse, CharSet
            {
                Result[SubStr(Word,1,Index) . A_LoopField . SubStr(Word,Index + 2)] := 1 ;replaces
                Result[SubStr(Word,1,Index) . A_LoopField . SubStr(Word,Index + 1)] := 1 ;inserts
            }
            Index ++
        }
        Loop, Parse, CharSet
            Result[Word . A_LoopField] := 1 ;inserts

        ;transposes
        Loop, % Length - 1
            Result[SubStr(Word,1,A_Index - 1) . SubStr(Word,A_Index + 1,1) . SubStr(Word,A_Index,1) . SubStr(Word,A_Index + 2)] := 1

        Return, Result
    }

    Rank(Values)
    {
        Candidates := []
        For Word, Occurrences In Values
            Candidates.Insert(Object("Word",Word,"Occurrences",Occurrences))
        Loop, % Candidates.MaxIndex() - 1
        {
            Index := A_Index
            While, Index > 0 && Candidates[Index].Occurrences < Candidates[Index + 1].Occurrences
                Value := Candidates[Index + 1], Candidates[Index + 1] := Candidates[Index], Candidates[Index] := Value, Index --
        }
        Result := []
        For Index, Value In Candidates
            Result.Insert(Value.Word)
        Return, Result
    }

    Correct(Word)
    {
        If ObjHasKey(this.Model,Word)
            Return, [Word]

        Result := Object()

        For Value In this.Edits1(Word)
        {
            If ObjHasKey(this.Model,Value)
                Result[Value] := this.Model[Value]
        }
        For Value In Result
            Return, this.Rank(Result)

        For Edit1 In this.Edits1(Word)
        {
            For Value In this.Edits1(Edit1)
            {
                If ObjHasKey(this.Model,Value)
                    Result[Value] := this.Model[Value]
            }
        }
        For Value In Result
            Return, this.Rank(Result)

        Return, [Word]
    }
}