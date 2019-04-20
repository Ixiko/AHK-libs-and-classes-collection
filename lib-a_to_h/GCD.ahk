/*
    Halla el mayor común divisor (MCD) de dos números usando el algoritmo euclideano.
*/
GCD(X, Y)
{
    While (Y)
        Y := Mod(X | 0, X := Y)
    
    Return (X)
} ;https://autohotkey.com/boards/viewtopic.php?f=6&t=3514&start=20#p23995
