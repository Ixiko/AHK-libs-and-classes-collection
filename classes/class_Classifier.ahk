#NoEnv

class Classifier
{
    __New()
    {
        this.Features := Object() ;counts of categories assigned to features
        this.Items := Object() ;counts of item categories
    }

    Sanitize(Data)
    {
        Data := RegExReplace(Data,"S)[^\w]"," ") ;remove anything that is not a word
        Data := RegExReplace(Data,"S)\b(?:0x)?\d+\b") ;remove pure numbers
        While, InStr(Data,"  ") ;collapse spaces
            StringReplace, Data, Data, %A_Space%%A_Space%, %A_Space%, All
        Data := Trim(Data) ;trim leading and trailing whitespace

        Result := []
        Loop, Parse, Data, %A_Space%
            Result.Insert(A_LoopField)
        Return, Result
    }

    Train(Item,Category)
    {
        For Index, Feature In this.Sanitize(Item)
        {
            ;update the feature category counts
            If !ObjHasKey(this.Features,Feature)
                this.Features[Feature] := Object()
            If !ObjHasKey(this.Features[Feature],Category)
                this.Features[Feature][Category] := 0
            this.Features[Feature][Category] ++
        }

        ;update the item category counts
        If !ObjHasKey(this.Items,Category)
            this.Items[Category] := 0
        this.Items[Category] ++
    }

    Classify(Item)
    {
        Features := this.Sanitize(Item)

        ;determine the probabilities of each item
        Result := []
        For Category In this.Items
        {
            Probability := this.FeaturesCategoryProbability(Features,Category)
            Entry := Object()
            Entry.Category := Category
            Entry.Probability := Probability
            Result.Insert(Entry)
        }

        ;sort categories by probability, descending
        MaxIndex := ObjMaxIndex(Result), (MaxIndex = "") ? (MaxIndex := 0) : ""
        If MaxIndex < 2
            Return, Result
        Loop, % MaxIndex - 1
        {
            Index := A_Index
            While, Index > 0 && Result[Index].Probability < Result[Index + 1].Probability
                Value := Result[Index + 1], Result[Index + 1] := Result[Index], Result[Index] := Value, Index --
        }

        Return, Result
    }

    FeaturesCategoryProbability(Features,Category)
    {
        ;determine the probability of the category given features
        Probability := 0
        For Index, Feature In Features
            Probability += Ln(this.WeightedProbability(Feature,Category))
        Probability := Exp(Probability)

        ;determine the fit of the probability to an inverse chi squared distribution
        Term := Ln(Probability)
        Sum := Probability
        Value := -Term
        Loop, % ObjMaxIndex(Features) - 1
        {
            Term += Ln(Value / A_Index)
            Sum += Exp(Term)
        }
        Return, Sum
    }

    WeightedProbability(Feature,Category)
    {
        AssumedProbability = 0.5 ;the probability a feature is assumed to have if not previously encountered
        AssumedProbabilityWeight = 1.0 ;weight of the assumed probability, as a measure of the number of occurances

        If !ObjHasKey(this.Features,Feature)
            Return, AssumedProbability

        Probability := this.Probability(Feature,Category)

        Totals := 0
        For Category In this.Items
        {
            If ObjHasKey(this.Features[Feature],Category)
                Totals += this.Features[Feature][Category]
        }
        WeightedProbability := ((AssumedProbability * AssumedProbabilityWeight) + (Totals * Probability)) / (AssumedProbabilityWeight + Totals)
        Return, WeightedProbability
    }

    Probability(Feature,Category)
    {
        If !ObjHasKey(this.Features[Feature],Category)
            Return, 0

        FeatureCategoryProbability := this.Features[Feature][Category] / this.Items[Category]
        FeatureTotalProbability := 0
        For Category, Count In this.Items
        {
            If ObjHasKey(this.Features[Feature],Category)
                FeatureTotalProbability += this.Features[Feature][Category] / Count
        }
        Return, FeatureCategoryProbability / FeatureTotalProbability
    }
}