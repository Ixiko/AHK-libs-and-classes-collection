/*
    Calcula el valor hash estándar de la cadena especificada.
    El algoritmo hash rs es un algoritmo hash multiplicativo que toma 8 bits de clave hash en un ciclo, y utiliza constantes múltiples en el proceso de multiplicación para aumentar la aleatoriedad en cada ciclo.
    Parámetros:
        String: La cadena.
        Length: La longitud de String, en caracteres. Este parámetro es opcional.
    Ejemplo:
        MsgBox(Format("0x{:X}",RSHash('<Hola Mundo!>'))) ;0x2B18CE8C
*/
RSHash(String, Length := 0)
{
    Local a := 0xF8C9
          b := 0x5C6B7
          h := 0

    Loop Parse, Length ? SubStr(String, 1, Length) : String
    {
        h := h * a + Ord(A_LoopField)
        a *= b
    }

    Return (h & 0x7FFFFFFF)
} ;https://autohotkey.com/boards/viewtopic.php?f=6&t=3514&start=40#p87929
