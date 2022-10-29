ChallengeInput = 
(
CONSUBSTANTIATION
WRONGHEADED
UNINTELLIGIBILITY
SUPERGLUE
)

For each, Word in StrSplit(ChallengeInput, "`n", "`r") {
    MsgBox % BalanceWord(Word)
}

BalanceWord(Word) {
    NumericalValues := [] ;Declare an Array to store
    Alphabet := StrSplit("abcdefghijklmnopqrstuvwxyz", "", "`r") ;Add Alphabet Characters to Array
    BalanceIndex := 2 ;Start balancing at Pos 2 in our Word
    Results := {1: 0, 2:0} ;Declare Object to hold our Results
    i := 1 ;To be used as an Index
    Count := 0
    ;Return the Numerical values for our and place them in our Array
    For each, Char in StrSplit(Word, "", "`r") { 
        NumericalValues.Insert(NumerizeAlpha(Format("{:L}", Char), Alphabet*))
    }
    ;Find if the Word Balances 
    While (BalanceIndex < NumericalValues.MaxIndex()) { 
        For each, Value in NumericalValues {
            Count++
            If (A_Index = BalanceIndex) {
                Count := 0
                i := 2
            }
            Else {
                Results[i] += i = 1 ? (value * (BalanceIndex - A_Index)) 
                                    : (Count * Value)		
            }
        }
        If (Results[1] = Results[2]) { ;If Results are Equal Return Formated Word and Numerical Results
            x := Balance(Word, BalanceIndex) . " - " . Results[1]
            Return x
        }
        Count := 0
        i := 1
        BalanceIndex++
        Results := {1: 0, 2:0}
    }
    Return Word . " Cannot Be balanced"
}
    
NumerizeAlpha(Char, Alphabet*) { ;Returns Numeric Value of a Letter in the Alphabet ie A = 1 b = 2 etc..
            For Key, Value in Alphabet {
                (Char == Value) ? (NumericalValue := Key) : Continue
            }
        Return NumericalValue
    }
    
Balance(Word, BalanceIndex) { ;Formats word BalancePoint
    For each, Char in StrSplit(Word, "", "`r") {			 
        Results .= (A_Index == BalanceIndex) ? (A_Space . Char . A_Space) : Char
    }
    Return Results	
}