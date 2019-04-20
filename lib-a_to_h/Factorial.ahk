/*
    Determina el factorial de un número.
*/
Factorial(Number)
{
    Local Factorial := 1 

    Loop (Number)
        Factorial *= A_Index

    Return (Factorial)
} ;http://rosettacode.org/wiki/Factorial#AutoHotkey




/*
    Determina el factorial de un número utilizando recursividad (más lento)
*/
Factorial_R(Number)
{
    Return (Number > 1 ? Number-- * Factorial_R(Number) : 1)
}
