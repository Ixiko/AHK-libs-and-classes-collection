/*
    Determina si el número espesificado es un número primo. Un número primo es un entero positivo o negativo que solamente es divisible por él mismo y por uno.
    Parámetros:
        Number: El número a comprobar.
    Return:
        Devuelve 1 si Number es un número primo, caso contrario devuelve 0.
*/
IsPrime(Number) {
    Loop (Floor(Sqrt(Number)))
        If (A_Index > 1 && Mod(Number, A_Index) == 0)
            Return (FALSE)

    Return (TRUE)
}
