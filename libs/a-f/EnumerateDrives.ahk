/*
    Enumera todas las unidades válidas en el sistema.
    Return:
        Si tuvo éxito devuelve un Array con la letra de cada unidad, caso contrario devuelve 0.
    Ejemplo:
        For Each, Drive In EnumerateDrives()
            List .= Drive
        MsgBox(List)
*/
EnumerateDrives()
{
    Local Buffer, List, Offset, String

    ; La función GetLogicalDriveStrings recupera las letras de cada unidad de la forma 'C:\' en cadenas terminadas en 0.
    ; El final está representado por un 0 adicional.
    VarSetCapacity(Buffer, 528)
    If (!DllCall('Kernel32.dll\GetLogicalDriveStringsW', 'UInt', 264, 'UPtr', &Buffer)) ;Devuelve la longitud de Buffer, en caracteres (sin contar los ceros)
        Return (FALSE) ;???

    List   := []
    Offset := 0
    String := StrGet(&Buffer, 'UTF-16')

    While (String != '')
    {
        List.Push(SubStr(String, 1, 1))
        String := StrGet(&Buffer + (Offset += StrLen(String) * 2 + 2), 'UTF-16')
    }

    /*
    Offset := -2
    C      := 1

    While (C)
    {
        While (C := NumGet(&Buffer + (Offset += 2), 'UShort')) ;Leemos caracter a caracter hasta encontrar un 0. Un cero indica el final de la cadena.
            If (A_Index == 1)     ;En la primera iteración (las dos siguientes iteraciones son los caracteres ':' y '\'), ya que...
                List.Push(Chr(C)) ;... solo añadimos el primer caracter (la letra de la unidad) y descartamos la parte ':\'. 'C:\' --> 'C'.
                                  ;Nota: utilizamos '+= 2' para avanzar al siguiente caracter, ya que estamos utilizando UTF-16 y cada caracter son 2 Bytes.
                                  ;offset de 0 a 1 tenemos 'C'. offset de 2 a 3 tenemos ':'. offset de 4 a 5 tenemos '\'. offset de 6 a 7 tenemos el cero.

        C := NumGet(&Buffer + (Offset + 2), 'UShort') ;Leemos un caracter más (parte de la siguiente iteración) para determinar si se ha alcanzado el final.
                                                      ;Si C=0 quiere decir que se ha alcanzado el final (dos ceros consecutivos), caso contrario indica el comienzo de una nueva letra.
    }
    */

    Return (List)
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/aa364975(v=vs.85).aspx
