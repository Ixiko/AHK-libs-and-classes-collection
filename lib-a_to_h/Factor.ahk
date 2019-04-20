/*
    Descomposición prima. Descompone el número especificado en en forma de producto.
    Parámetros:
        Number: El número deseado.
        Delimiter: El caracter de delimitación deseado. Por defecto es una nueva línea.
    Observaciones:
        Un número primo es un número natural que tiene dos divisores naturales: el uno y él mismo. Los demás números, se llaman integrantes.
        La factorización es la descomposición de un número natural en un producto de factores primos.
    Return:
        Devuelve un Array con todos los valores.
*/
Factor(Number)
{
    Local OutputVar := []
        , F         := 2

    While (F <= Number)
    {
        If (Mod(Number, F) == 0)
        {
            OutputVar.Push(F)
            OutputVar.Push(Factor(Number / F)*)

            Return (OutputVar)
        }
    }

    Return ("")
} ;http://rosettacode.org/wiki/Prime_decomposition#AutoHotkey
