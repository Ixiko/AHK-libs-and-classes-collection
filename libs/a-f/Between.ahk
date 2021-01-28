/*
    Determina si un número esta contenido entre otros dos valores (inclusive).
    Parámetros:
        Number: El número deseado.
        Low: El número menor.
        High: El número mayor.
        ExcludeValues: Un Array con los valores a excluir. Si Number es igual a uno de estos valores, la función devuelve 0.
*/
Between(Number, Low, High, ExcludeValues := '')
{
    Local Each, ExcludeValue

    For Each, ExcludeValue in ExcludeValues
        If (ExcludeValue == Number)
            Return (FALSE)

    Return (Number >= Low && Number <= High)
}
