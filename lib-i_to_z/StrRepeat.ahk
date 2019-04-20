/*
    Repite una cadena una determinada cantidad de veces.
    Parámetros:
        String: La cadena a repetir.
        Count : La cantidad de veces a repetir la cadena especificada.
    Return:
        Devuelve la cadena repetida tantas veces especificada en Count.
*/
StrRepeat(String, Count)
{
    Return (StrReplace(Format('{:' . Count . '}', ''), A_Space, String))
}
