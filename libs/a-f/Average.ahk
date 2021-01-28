/*
    Calcula el promedio de los valores especificados.
    Parámetros:
        Numbers: Un Array con los números deseados.
    Return:
        Devuelve el promedio entre los valores especificados en Numbers.
*/
Average(Numbers)
{
    Local Each, Value
        , Total := 0

    For Each, Value In Numbers
        Total += Value + 0.0

    Return (Total / Numbers.MaxIndex())
}
